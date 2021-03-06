defmodule BsvRpc.MetaNet do
  # TODO Move to a separate library?
  @moduledoc """
  Function for MetaNet operations.
  """
  alias BsvRpc.MetaNet.Graph
  require Logger

  @network_flag "meta"

  @doc """
  Creates a MetaNet root node on the blockchain and creates a graph struct representing it.
  """
  @spec create_root_node(ExtendedKey.key(), BsvRpc.PrivateKey.t()) :: BsvRpc.MetaNet.Graph.t()
  def create_root_node(%ExtendedKey{} = metanet_key, %BsvRpc.PrivateKey{} = funding_key) do
    graph = Graph.create(metanet_key, funding_key)
    {:ok, graph, _published_node} = publish_node(graph, "", [])
    graph
  end

  @doc """
  Publishes a MetaNet node on the blockchain.

  Uses `funding_utxo` to fund the MetaNet node transaction.
  """
  @spec publish_node(
          BsvRpc.MetaNet.Graph.t(),
          BsvRpc.UTXO.t(),
          String.t(),
          list(),
          (BsvRpc.Transaction.t() -> {:ok, String.t()} | {:error, String.t()})
        ) ::
          {:ok, BsvRpc.MetaNet.Graph.t(), BsvRpc.Transaction.t()}
  def publish_node(
        %Graph{} = graph,
        %BsvRpc.UTXO{} = funding_utxo,
        derivation_path,
        content,
        broadcaster_functon
      ) do
    metanet_key = derive_metanet_key(graph, derivation_path)

    node_address =
      ExtendedKey.neuter(metanet_key)
      |> BsvRpc.PublicKey.create()
      |> elem(1)
      |> BsvRpc.Address.create!(:mainnet, :pubkey)

    parent_key =
      if is_toplevel(derivation_path) do
        metanet_key
      else
        derive_metanet_key(graph, get_parent_derivation_path(derivation_path))
      end

    metanet_headers =
      if is_toplevel(derivation_path) do
        # Parent has no reference to the parent.
        [
          @network_flag,
          node_address.address,
          "NULL"
        ]
      else
        {:ok, parent_tx} = Graph.get_parent(graph, derivation_path)

        [
          @network_flag,
          node_address.address,
          BsvRpc.Transaction.id(parent_tx) |> String.downcase()
        ]
      end

    meta_node_tx = metanet_node_tx(parent_key, funding_utxo, metanet_headers ++ content)

    id = BsvRpc.Transaction.id(meta_node_tx) |> String.downcase()
    {:ok, ^id} = broadcaster_functon.(meta_node_tx)
    Logger.info("Node TX for MetaNet node #{node_address.address}: #{id}")

    {:ok, Graph.add_node(graph, meta_node_tx, derivation_path), meta_node_tx}
  end

  @spec publish_node(BsvRpc.MetaNet.Graph.t(), BsvRpc.UTXO.t(), String.t(), list()) ::
          {:ok, BsvRpc.MetaNet.Graph.t(), BsvRpc.Transaction.t()}
  def publish_node(
        %Graph{} = graph,
        %BsvRpc.UTXO{} = funding_utxo,
        derivation_path,
        content
      ) do
    publish_node(graph, funding_utxo, derivation_path, content, fn tx ->
      BsvRpc.broadcast_transaction(tx)
    end)
  end

  @doc """
  Publishes a MetaNet node on the blockchain.

  Uses funding key in the graph struct to fund the MetaNet node transaction.
  """
  @spec publish_node(
          BsvRpc.MetaNet.Graph.t(),
          String.t(),
          list(),
          (BsvRpc.Transaction.t() -> {:ok, String.t()} | {:error, String.t()})
        ) ::
          {:ok, BsvRpc.MetaNet.Graph.t(), BsvRpc.Transaction.t()}
  def publish_node(
        %Graph{} = graph,
        derivation_path,
        content,
        broadcaster_functon
      ) do
    metanet_key = derive_metanet_key(graph, derivation_path)

    node_address =
      ExtendedKey.neuter(metanet_key)
      |> BsvRpc.PublicKey.create()
      |> elem(1)
      |> BsvRpc.Address.create!(:mainnet, :pubkey)

    parent_key =
      if is_toplevel(derivation_path) do
        metanet_key
      else
        derive_metanet_key(graph, get_parent_derivation_path(derivation_path))
      end

    parent_address =
      parent_key
      |> ExtendedKey.neuter()
      |> BsvRpc.PublicKey.create()
      |> elem(1)
      |> BsvRpc.Address.create!(:mainnet, :pubkey)

    # Simplest MetaNet transaction with one input and one OP_RETURN output will
    # be about 250 bytes. But dust limit is 546 so at least that.
    # TODO need to consider multiple inputs
    amount =
      case 250 + Enum.reduce(content, 0, fn item, acc -> acc + byte_size(item) end) do
        fee when fee > 546 -> fee
        _ -> 546
      end

    ftx = funding_tx(graph.funding_key, parent_address, amount)
    id = BsvRpc.Transaction.id(ftx) |> String.downcase()
    {:ok, ^id} = broadcaster_functon.(ftx)
    Logger.debug("Funding TX for MetaNet node #{node_address.address}: #{id}")

    funding_utxo = BsvRpc.UTXO.create(ftx, 0)

    publish_node(graph, funding_utxo, derivation_path, content)
  end

  @spec publish_node(BsvRpc.MetaNet.Graph.t(), String.t(), list()) ::
          {:ok, BsvRpc.MetaNet.Graph.t(), BsvRpc.Transaction.t()}
  def publish_node(
        %Graph{} = graph,
        derivation_path,
        content
      ) do
    publish_node(graph, derivation_path, content, fn tx -> BsvRpc.broadcast_transaction(tx) end)
  end

  @spec funding_tx(BsvRpc.PrivateKey.t(), BsvRpc.Address.t(), non_neg_integer) ::
          BsvRpc.Transaction.t()
  defp funding_tx(%BsvRpc.PrivateKey{} = funding_key, %BsvRpc.Address{} = destination, amount) do
    funding_address =
      funding_key
      |> BsvRpc.PublicKey.create!()
      |> BsvRpc.Address.create!(:mainnet, :pubkey)

    %HTTPoison.Response{status_code: 200, body: body} =
      HTTPoison.get!(
        "https://api.whatsonchain.com/v1/bsv/main/address/#{funding_address.address}/unspent"
      )

    {:ok, utxos} = Poison.decode(body)
    [utxo | _rest] = Enum.sort(utxos, &(Map.get(&1, "value") >= Map.get(&2, "value")))
    # TODO make smarter - calculate how much do we actally need
    funding_tx = %BsvRpc.Transaction{
      version: 1,
      locktime: 0,
      inputs: [
        %BsvRpc.TransactionInput{
          previous_transaction: Base.decode16!(utxo["tx_hash"], case: :mixed),
          previous_output: utxo["tx_pos"],
          sequence: 0xFFFFFFFF,
          script_sig: <<>>
        }
      ],
      outputs: [
        %BsvRpc.TransactionOutput{
          value: amount,
          script_pubkey: BsvRpc.TransactionOutput.p2pkh_script_pubkey(destination)
        }
      ]
    }

    funding_tx =
      if utxo["value"] > 1.5 * amount do
        BsvRpc.Transaction.add_output(funding_tx, %BsvRpc.TransactionOutput{
          # TODO fee dynamically
          value: utxo["value"] - amount - 230,
          script_pubkey: BsvRpc.TransactionOutput.p2pkh_script_pubkey(funding_address)
        })
      else
        funding_tx
      end

    BsvRpc.Transaction.sign!(
      funding_tx,
      funding_key,
      BsvRpc.get_transaction(utxo["tx_hash"]) |> elem(1) |> BsvRpc.UTXO.create(utxo["tx_pos"])
    )
  end

  @spec metanet_node_tx(
          ExtendedKey.key(),
          BsvRpc.UTXO.t(),
          list()
        ) :: BsvRpc.Transaction.t()
  defp metanet_node_tx(
         %ExtendedKey{} = parent_key,
         %BsvRpc.UTXO{} = utxo,
         content
       ) do
    tx = %BsvRpc.Transaction{
      version: 1,
      locktime: 0,
      inputs: [
        %BsvRpc.TransactionInput{
          previous_transaction: utxo.transaction,
          previous_output: utxo.output,
          sequence: 0xFFFFFFFF,
          script_sig: <<>>
        }
      ],
      outputs: [BsvRpc.TransactionOutput.get_data_output(content)]
    }

    {:ok, signing_key} = BsvRpc.PrivateKey.create(parent_key)
    BsvRpc.Transaction.sign!(tx, signing_key, utxo)
  end

  @spec get_parent_derivation_path(String.t()) :: String.t()
  defp get_parent_derivation_path(derivation_path) do
    if is_toplevel(derivation_path) do
      raise "Can't get parent of the top level path."
    else
      String.split(derivation_path, "/")
      |> List.pop_at(-1)
      |> elem(1)
      |> Enum.join("/")
    end
  end

  @spec is_toplevel(String.t()) :: boolean()
  defp is_toplevel(""), do: true
  defp is_toplevel(_), do: false

  @spec derive_metanet_key(BsvRpc.MetaNet.Graph.t(), String.t()) :: ExtendedKey.key()
  defp derive_metanet_key(%BsvRpc.MetaNet.Graph{} = graph, ""), do: graph.metanet_key

  defp derive_metanet_key(%BsvRpc.MetaNet.Graph{} = graph, derivation_path),
    do: ExtendedKey.derive_path(graph.metanet_key, "m/#{derivation_path}")
end
