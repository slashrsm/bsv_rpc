defmodule BsvRpc.TransactionOutput do
  # TODO Move to a separate library?
  @moduledoc """
  Functions for Bitcoin transaction outputs manipulation.
  """

  @enforce_keys [:value, :script_pubkey]

  @typedoc """
  A Bitcoin transaction output.
  """
  defstruct [:value, :script_pubkey]

  @type t :: %__MODULE__{
          value: non_neg_integer(),
          script_pubkey: binary()
        }

  @doc """
  Creates transaction outputs from a binary blob.

  Blob can include multiple outputs.
  """
  @spec create(binary, non_neg_integer) :: {[__MODULE__.t()], binary}
  def create(tx_in_blob, output_count), do: do_create(tx_in_blob, [], output_count)

  @doc """
  Creates a single transaction input from a binary blob.

  Raises `MatchError` if the binary includes any more data after the first transaction output.

  Returns a tuple with the list of outputs and the remaining of the binary blob.
  """
  @spec create_single(binary) :: __MODULE__.t()
  def create_single(tx_in_blob) do
    {[tx_in | []], <<>>} = do_create(tx_in_blob, [], 1)
    tx_in
  end

  @spec do_create(binary, [__MODULE__.t()], non_neg_integer) :: {[__MODULE__.t()], binary}
  defp do_create(rest, inputs, 0), do: {Enum.reverse(inputs), rest}

  defp do_create(<<value::size(64), rest::binary>>, outputs, output_count) do
    {script_pubkey, <<rest::binary>>} = BsvRpc.Helpers.get_varlen_data(rest)

    output = %__MODULE__{
      value: value,
      script_pubkey: script_pubkey
    }

    do_create(rest, [output | outputs], output_count - 1)
  end

  @doc """
  Gets the output value in Bitcoins.
  """
  @spec value(__MODULE__.t()) :: float
  def value(output), do: output.value / 100_000_000
end
