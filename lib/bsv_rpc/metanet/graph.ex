defmodule BsvRpc.MetaNet.Graph do
  # TODO Move to a separate library?
  @moduledoc """
  Function for MetaNet operations.
  """

  @enforce_keys [:metanet_key, :funding_key]

  @typedoc """
  A MetaNet graph.
  """
  defstruct [:metanet_key, :funding_key, :nodes]

  @type t :: %__MODULE__{
          metanet_key: ExtendedKey.key(),
          funding_key: BsvRpc.PrivateKey.t(),
          nodes: map()
        }

  @doc """
  Creates a MetaNet graph struct.

  ## Examples

    iex> meta_key = %ExtendedKey{
    ...>  chain_code: <<105, 183, 126, 110, 23, 105, 199, 184, 137, 146, 206, 27, 4,
    ...>    159, 85, 14, 42, 28, 94, 29, 254, 252, 8, 108, 114, 125, 173, 37, 5, 124,
    ...>    61, 103>>,
    ...>  child_num: 0,
    ...>  depth: 0,
    ...>  key: <<7, 195, 21, 39, 143, 145, 107, 160, 195, 209, 211, 201, 62, 15, 193,
    ...>    75, 9, 63, 56, 49, 39, 19, 191, 150, 24, 184, 96, 119, 20, 151, 49, 103>>,
    ...>  parent_fingerprint: <<0, 0, 0, 0>>,
    ...>  version: <<4, 136, 173, 228>>
    ...>}
    iex> funding_key = %BsvRpc.PrivateKey{
    ...>   key: <<20, 25, 37, 10, 205, 108, 92, 206, 133, 180, 29, 209, 13, 2, 29, 254,
    ...>     191, 18, 130, 12, 255, 57, 251, 199, 92, 120, 134, 83, 127, 175, 198, 27>>,
    ...>   network: :mainnet
    ...> }
    iex> BsvRpc.MetaNet.Graph.create(meta_key, funding_key)
    %BsvRpc.MetaNet.Graph{
      funding_key: %BsvRpc.PrivateKey{
        key: <<20, 25, 37, 10, 205, 108, 92, 206, 133, 180, 29, 209, 13,
          2, 29, 254, 191, 18, 130, 12, 255, 57, 251, 199, 92, 120, 134,
          83, 127, 175, 198, 27>>,
        network: :mainnet
      },
      metanet_key: %ExtendedKey{
        chain_code: <<105, 183, 126, 110, 23, 105, 199, 184, 137, 146,
          206, 27, 4, 159, 85, 14, 42, 28, 94, 29, 254, 252, 8, 108,
          114, 125, 173, 37, 5, 124, 61, 103>>,
        child_num: 0,
        depth: 0,
        key: <<7, 195, 21, 39, 143, 145, 107, 160, 195, 209, 211, 201,
          62, 15, 193, 75, 9, 63, 56, 49, 39, 19, 191, 150, 24, 184, 96,
          119, 20, 151, 49, 103>>,
        parent_fingerprint: <<0, 0, 0, 0>>,
        version: <<4, 136, 173, 228>>
      },
      nodes: %{}
    }
  """
  @spec create(ExtendedKey.key(), BsvRpc.PrivateKey.t(), map) :: __MODULE__.t()
  def create(%ExtendedKey{} = metanet_key, %BsvRpc.PrivateKey{} = funding_key, nodes \\ %{}) do
    %__MODULE__{
      metanet_key: metanet_key,
      funding_key: funding_key,
      nodes: nodes
    }
  end

  @doc """
  Adds a node to the graph.

  ## Examples

    iex> graph = %BsvRpc.MetaNet.Graph{
    ...>   funding_key: %BsvRpc.PrivateKey{
    ...>     key: <<20, 25, 37, 10, 205, 108, 92, 206, 133, 180, 29, 209, 13,
    ...>       2, 29, 254, 191, 18, 130, 12, 255, 57, 251, 199, 92, 120, 134,
    ...>       83, 127, 175, 198, 27>>,
    ...>     network: :mainnet
    ...>   },
    ...>   metanet_key: %ExtendedKey{
    ...>     chain_code: <<105, 183, 126, 110, 23, 105, 199, 184, 137, 146,
    ...>       206, 27, 4, 159, 85, 14, 42, 28, 94, 29, 254, 252, 8, 108,
    ...>       114, 125, 173, 37, 5, 124, 61, 103>>,
    ...>     child_num: 0,
    ...>     depth: 0,
    ...>     key: <<7, 195, 21, 39, 143, 145, 107, 160, 195, 209, 211, 201,
    ...>       62, 15, 193, 75, 9, 63, 56, 49, 39, 19, 191, 150, 24, 184, 96,
    ...>       119, 20, 151, 49, 103>>,
    ...>     parent_fingerprint: <<0, 0, 0, 0>>,
    ...>     version: <<4, 136, 173, 228>>
    ...>   },
    ...>   nodes: %{}
    ...> }
    iex> node = BsvRpc.Transaction.create_from_hex("01000000019D1D057F52A81B6A317A197EB32315F5CA5D11AF5BB7884ECF1313C360AF0F05000000006B483045022100F794B063316EB772E605F0CCD4248CB2A453738B8069AD7772836331F7AB3003022064D917DE2B398434099CB38FEAA80C5C033AF8DA268BDA04B35C501930D70509412102646BAC61ABBF4F191419FA27808700A0E6D29EFEC721070BE9907737B9C67813FFFFFFFF020000000000000000396A046D65746122314C5773393164774351456974553753664E676E68736D6A32527A6D52425259704D044E554C4C0A546573742020726F6F747C4F0100000000001976A9143D187590262DF8ED316A25FBA9E6F156EDAB9C6F88AC00000000")
    iex> graph = BsvRpc.MetaNet.Graph.add_node(graph, node, "0/0")
    iex> Map.has_key?(graph.nodes, "0/0")
    true
    iex> BsvRpc.Transaction.id(graph.nodes["0/0"])
    "6D57C8D5284379590CF68F8BF12DC02E2519AA72CE8F45670D8A22BFDC2220DD"
  """
  @spec add_node(__MODULE__.t(), BsvRpc.Transaction.t(), String.t()) :: __MODULE__.t()
  def add_node(%__MODULE__{} = graph, %BsvRpc.Transaction{} = node, derivation_path) do
    %{graph | :nodes => graph |> Map.get(:nodes, %{}) |> Map.put(derivation_path, node)}
  end

  @doc """
  Gets a node from the graph.

  ## Examples

    iex> graph = %BsvRpc.MetaNet.Graph{
    ...>      funding_key: %BsvRpc.PrivateKey{
    ...>        key: <<20, 25, 37, 10, 205, 108, 92, 206, 133, 180, 29, 209, 13,
    ...>          2, 29, 254, 191, 18, 130, 12, 255, 57, 251, 199, 92, 120, 134,
    ...>          83, 127, 175, 198, 27>>,
    ...>        network: :mainnet
    ...>      },
    ...>      metanet_key: %ExtendedKey{
    ...>        chain_code: <<105, 183, 126, 110, 23, 105, 199, 184, 137, 146,
    ...>          206, 27, 4, 159, 85, 14, 42, 28, 94, 29, 254, 252, 8, 108,
    ...>          114, 125, 173, 37, 5, 124, 61, 103>>,
    ...>        child_num: 0,
    ...>        depth: 0,
    ...>        key: <<7, 195, 21, 39, 143, 145, 107, 160, 195, 209, 211, 201,
    ...>          62, 15, 193, 75, 9, 63, 56, 49, 39, 19, 191, 150, 24, 184, 96,
    ...>          119, 20, 151, 49, 103>>,
    ...>        parent_fingerprint: <<0, 0, 0, 0>>,
    ...>        version: <<4, 136, 173, 228>>
    ...>      },
    ...>      nodes: %{
    ...>        "0/1" => BsvRpc.Transaction.create_from_hex("01000000019D1D057F52A81B6A317A197EB32315F5CA5D11AF5BB7884ECF1313C360AF0F05000000006B483045022100F794B063316EB772E605F0CCD4248CB2A453738B8069AD7772836331F7AB3003022064D917DE2B398434099CB38FEAA80C5C033AF8DA268BDA04B35C501930D70509412102646BAC61ABBF4F191419FA27808700A0E6D29EFEC721070BE9907737B9C67813FFFFFFFF020000000000000000396A046D65746122314C5773393164774351456974553753664E676E68736D6A32527A6D52425259704D044E554C4C0A546573742020726F6F747C4F0100000000001976A9143D187590262DF8ED316A25FBA9E6F156EDAB9C6F88AC00000000"),
    ...>      }
    ...>    }
    iex> BsvRpc.MetaNet.Graph.get_node(graph, "0/0")
    {:error, "Node not found."}
    iex> {:ok, tx} = BsvRpc.MetaNet.Graph.get_node(graph, "0/1")
    iex> BsvRpc.Transaction.id(tx)
    "6D57C8D5284379590CF68F8BF12DC02E2519AA72CE8F45670D8A22BFDC2220DD"
  """
  @spec get_node(__MODULE__.t(), String.t()) ::
          {:ok, BsvRpc.Transaction.t()} | {:error, String.t()}
  def get_node(%__MODULE__{nodes: nodes}, derivation_path) do
    if Map.has_key?(nodes, derivation_path) do
      {:ok, nodes[derivation_path]}
    else
      {:error, "Node not found."}
    end
  end

  @doc """
  Gets a node's parent from the graph.

  ## Examples

    iex> graph = %BsvRpc.MetaNet.Graph{
    ...>      funding_key: %BsvRpc.PrivateKey{
    ...>        key: <<20, 25, 37, 10, 205, 108, 92, 206, 133, 180, 29, 209, 13,
    ...>          2, 29, 254, 191, 18, 130, 12, 255, 57, 251, 199, 92, 120, 134,
    ...>          83, 127, 175, 198, 27>>,
    ...>        network: :mainnet
    ...>      },
    ...>      metanet_key: %ExtendedKey{
    ...>        chain_code: <<105, 183, 126, 110, 23, 105, 199, 184, 137, 146,
    ...>          206, 27, 4, 159, 85, 14, 42, 28, 94, 29, 254, 252, 8, 108,
    ...>          114, 125, 173, 37, 5, 124, 61, 103>>,
    ...>        child_num: 0,
    ...>        depth: 0,
    ...>        key: <<7, 195, 21, 39, 143, 145, 107, 160, 195, 209, 211, 201,
    ...>          62, 15, 193, 75, 9, 63, 56, 49, 39, 19, 191, 150, 24, 184, 96,
    ...>          119, 20, 151, 49, 103>>,
    ...>        parent_fingerprint: <<0, 0, 0, 0>>,
    ...>        version: <<4, 136, 173, 228>>
    ...>      },
    ...>      nodes: %{
    ...>        "0" => BsvRpc.Transaction.create_from_hex("01000000019D1D057F52A81B6A317A197EB32315F5CA5D11AF5BB7884ECF1313C360AF0F05000000006B483045022100F794B063316EB772E605F0CCD4248CB2A453738B8069AD7772836331F7AB3003022064D917DE2B398434099CB38FEAA80C5C033AF8DA268BDA04B35C501930D70509412102646BAC61ABBF4F191419FA27808700A0E6D29EFEC721070BE9907737B9C67813FFFFFFFF020000000000000000396A046D65746122314C5773393164774351456974553753664E676E68736D6A32527A6D52425259704D044E554C4C0A546573742020726F6F747C4F0100000000001976A9143D187590262DF8ED316A25FBA9E6F156EDAB9C6F88AC00000000"),
    ...>        "0/1" => BsvRpc.Transaction.create_from_hex("010000000117DF7322B8435C240754D9D4B8230FB67EFB94BE8C811C58AE672FE41A621B92000000006A47304402203EF265114433AA660555AD06077477CA8FEF2A25D60F2123D6302779BDD6FA590220236A0053ECCF07D92789D4E3CD0CD6F1BDB58DD5C7F04B3B608180B0D3714A43412103DCEB1793DDDB6664DB904BE9958A3A511FCB50A0199659231D0C5F83F3FF9588FFFFFFFF010000000000000000766A046D657461223135346A747746576D5946375346477A713631643679417275777071466B6173673840366435376338643532383433373935393063663638663862663132646330326532353139616137326365386634353637306438613232626664633232323064640B5465737420666F6C64657200000000"),
    ...>      }
    ...>    }
    iex> {:ok, tx} = BsvRpc.MetaNet.Graph.get_parent(graph, "0/0")
    iex> BsvRpc.Transaction.id(tx)
    "6D57C8D5284379590CF68F8BF12DC02E2519AA72CE8F45670D8A22BFDC2220DD"
    iex> BsvRpc.MetaNet.Graph.get_parent(graph, "0/0/1")
    {:error, "Node not found."}
  """
  @spec get_parent(__MODULE__.t(), String.t()) ::
          {:ok, BsvRpc.Transaction.t()} | {:error, String.t()}
  def get_parent(%__MODULE__{} = graph, derivation_path) do
    parent_derivation_path =
      String.split(derivation_path, "/")
      |> List.pop_at(-1)
      |> elem(1)
      |> Enum.join("/")

    get_node(graph, parent_derivation_path)
  end
end
