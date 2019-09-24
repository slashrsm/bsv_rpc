defmodule BsvRpc.MetaNet do
  # TODO Move to a separate library?
  @moduledoc """
  Function for MetaNet operations.
  """
  alias BsvRpc.MetaNet.Graph

  @network_flag "meta"

  @spec create_root_node(ExtendedKey.key(), BsvRpc.PrivateKey.t()) :: BsvRpc.MetaNet.Graph.t()
  def create_root_node(%ExtendedKey{} = metanet_key, %BsvRpc.PrivateKey{} = funding_key) do
    graph = Graph.create(metanet_key, funding_key)
    {:ok, graph, _published_node} = publish_node(graph, funding_key, "0")
    graph
  end

  @spec publish_node(BsvRpc.MetaNet.Graph.t(), BsvRpc.PrivateKey.t(), String.t(), list()) ::
          {:ok, BsvRpc.MetaNet.Graph.t(), BsvRpc.Transaction.t()}
  defp publish_node(
         %Graph{} = graph,
         %BsvRpc.PrivateKey{} = funding_key,
         derivation_path,
         content \\ []
       ) do
    metanet_key = ExtendedKey.derive_path(graph.metanet_key, "m/#{derivation_path}")

    node_address =
      ExtendedKey.neuter(metanet_key)
      |> BsvRpc.PublicKey.create()
      |> elem(1)
      |> BsvRpc.Address.create!(:mainnet, :pubkey)

    # Simplest MetaNet transaction with one input and one OP_RETURN output will
    # be about 250 bytes.
    # TODO need to consider multiple inputs
    # TODO count any content
    amount = 250

    funding_tx = funding_tx(funding_key, node_address, amount)
    BsvRpc.broadcast_transaction(funding_tx)

    [funding_utxo | _] = funding_tx.outputs

    metanet_headers = [
      @network_flag,
      node_address.address,
      # TODO this will only work for parents.
      "NULL"
    ]

    meta_node_tx =
      metanet_node_tx(metanet_key, funding_tx, funding_utxo, metanet_headers ++ content)

    BsvRpc.broadcast_transaction(meta_node_tx)

    {:ok, Graph.add_node(graph, meta_node_tx, derivation_path), meta_node_tx}
  end

  @spec funding_tx(BsvRpc.PrivateKey.t(), BsvRpc.Address.t(), non_neg_integer) ::
          BsvRpc.Transaction.t()
  defp funding_tx(%BsvRpc.PrivateKey{} = funding_key, %BsvRpc.Address{} = destination, amount) do
    funding_address =
      funding_key
      |> BsvRpc.PublicKey.create()
      |> elem(1)
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
          previous_output: utxo["tx_out"],
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

    BsvRpc.Transaction.sign(
      funding_tx,
      funding_key,
      %BsvRpc.TransactionOutput{
        value: utxo["value"],
        script_pubkey: BsvRpc.TransactionOutput.p2pkh_script_pubkey(funding_address)
      }
    )
  end

  @spec metanet_node_tx(
          ExtendedKey.key(),
          BsvRpc.Transaction.t(),
          BsvRpc.TransactionOutput.t(),
          list()
        ) :: BsvRpc.Transaction.t()
  defp metanet_node_tx(
         %ExtendedKey{} = metanet_key,
         %BsvRpc.Transaction{} = funding_tx,
         %BsvRpc.TransactionOutput{} = utxo,
         content
       ) do
    tx = %BsvRpc.Transaction{
      version: 1,
      locktime: 0,
      inputs: [
        %BsvRpc.TransactionInput{
          previous_transaction: BsvRpc.Transaction.id(funding_tx),
          previous_output: 0,
          sequence: 0xFFFFFFFF,
          script_sig: <<>>
        }
      ],
      outputs: [BsvRpc.TransactionOutput.get_data_output(content)]
    }

    {:ok, signing_key} = BsvRpc.PrivateKey.create(metanet_key)
    BsvRpc.Transaction.sign(tx, signing_key, utxo)
  end
end
