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

  @spec create(ExtendedKey.key(), BsvRpc.PrivateKey.t(), map) :: __MODULE__.t()
  def create(%ExtendedKey{} = metanet_key, %BsvRpc.PrivateKey{} = funding_key, nodes \\ %{}) do
    %__MODULE__{
      metanet_key: metanet_key,
      funding_key: funding_key,
      nodes: nodes
    }
  end

  @spec add_node(__MODULE__.t(), BsvRpc.Transaction.t(), String.t()) :: __MODULE__.t()
  def add_node(%__MODULE__{} = graph, %BsvRpc.Transaction{} = node, derivation_path) do
    %{graph | :nodes => graph |> Map.get(:nodes, %{}) |> Map.put(derivation_path, node)}
  end
end
