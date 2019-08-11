defmodule BsvRpc.TransactionInput do
  # TODO Move to a separate library?
  @moduledoc """
  Functions for Bitcoin transaction inputs manipulation.
  """

  @enforce_keys [:script_sig, :sequence]

  @typedoc """
  A Bitcoin transaction input.
  """
  defstruct [:previous_transaction, :previous_output, :script_sig, :sequence]

  @type t :: %__MODULE__{
          previous_transaction: binary(),
          previous_output: non_neg_integer(),
          script_sig: binary(),
          sequence: non_neg_integer()
        }

  @doc """
  Creates transaction inputs from a binary blob.

  Blob can include multiple inputs.

  Returns a tuple with the list of inputs and the remaining of the binary blob.
  """
  @spec create(binary, non_neg_integer) :: {[__MODULE__.t()], binary}
  def create(tx_in_blob, input_count), do: do_create(tx_in_blob, [], input_count)

  @doc """
  Creates a single transaction input from a binary blob.

  Raises `MatchError` if the binary includes any more data after the first input.
  """
  @spec create_single(binary) :: __MODULE__.t()
  def create_single(tx_in_blob) do
    {[tx_in | []], <<>>} = do_create(tx_in_blob, [], 1)
    tx_in
  end

  @spec do_create(binary, [t()], non_neg_integer) :: {[t()], binary}
  defp do_create(rest, inputs, 0), do: {Enum.reverse(inputs), rest}

  defp do_create(
         <<prev_tx::little-binary-size(32), prev_txout::little-size(32), rest::binary>>,
         inputs,
         input_count
       ) do
    {script_sig, <<sequence::little-size(32), rest::binary>>} =
      BsvRpc.Helpers.get_varlen_data(rest)

    input = %__MODULE__{
      previous_transaction: prev_tx,
      previous_output: prev_txout,
      script_sig: script_sig,
      sequence: sequence
    }

    do_create(rest, [input | inputs], input_count - 1)
  end
end
