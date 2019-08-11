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

  ## Example

    iex> tx_in = "cf3e4414a1a65b96a5485f7a497fed32c0c90e95e4ff334a79559ad9b14920e90100000006aabbccddeeffffffffff"
    iex> BsvRpc.TransactionInput.create_single(Base.decode16!(tx_in, case: :lower))
    %BsvRpc.TransactionInput{
      previous_output: 1,
      previous_transaction: <<207, 62, 68, 20, 161, 166, 91, 150, 165, 72, 95, 122,
        73, 127, 237, 50, 192, 201, 14, 149, 228, 255, 51, 74, 121, 85, 154, 217,
        177, 73, 32, 233>>,
      script_sig: <<170, 187, 204, 221, 238, 255>>,
      sequence: 4294967295
    }
    iex> tx_in = tx_in <> "ff"
    iex> BsvRpc.TransactionOutput.create_single(Base.decode16!(tx_in, case: :lower))
    ** (MatchError) no match of right hand side value: <<72, 95, 122, 73, 127, 237, 50, 192, 201, 14, 149, 228, 255, 51, 74, 121, 85, 154, 217, 177, 73, 32, 233, 1, 0, 0, 0, 6, 170, 187, 204, 221, 238, 255, 255, 255, 255, 255, 255>>
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
