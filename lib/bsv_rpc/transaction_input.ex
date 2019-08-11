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
  ## Arguments

    - `tx_in_blob` - Binary blob to parse transaction inputs from.
    - `input_count` - Number of transactions inputs to parse.

  ## Example

    iex> tx_in = "8149C4A82A52AD851562780A99FF1ABB8A051BF0D1520E3CE78349EEC539423E020000006A47304402200FB61D66AEB74B471DA8B8B648609C0C1E7F02DB01E6FA573699B2A0AD377D940220065BC14DBB05D5F7981F9294BD5EA90F4AC6B4A6F0771C870B10622B8E8EA57741210244936527CED7DC6FBB30491E5BFBC31E208EEAA87EB3FCA2C748D098EF8614D3FFFFFFFF" <> "812667A59695ECCC55724AB10C6469535F0639FEF73D0C802EFB5E609A6316B4000000006A47304402207268E3F27C94E59426A1698AD00CD186D2095C8A38CB273DA6FD4448AD345ECF02203021A7A4A54EBBB63D606E83CF0DC471FE0FD210B326395C9E6D498DF358C6EA41210244936527CED7DC6FBB30491E5BFBC31E208EEAA87EB3FCA2C748D098EF8614D3FFFFFFFF" <> "AABB"
    iex> {[tx1, tx2], <<0xAA, 0xBB>>} = BsvRpc.TransactionInput.create(Base.decode16!(tx_in), 2)
    iex> tx1.previous_transaction
    <<129, 73, 196, 168, 42, 82, 173, 133, 21, 98, 120,
      10, 153, 255, 26, 187, 138, 5, 27, 240, 209, 82, 14, 60, 231, 131, 73,
      238, 197, 57, 66, 62>>
    iex> tx1.previous_output
    2
    iex> tx2.previous_transaction
    <<129, 38, 103, 165, 150, 149, 236, 204, 85, 114, 74,
      177, 12, 100, 105, 83, 95, 6, 57, 254, 247, 61, 12, 128, 46, 251, 94, 96,
      154, 99, 22, 180>>
    iex> tx2.previous_output
    0
  """
  @spec create(binary, non_neg_integer) :: {[__MODULE__.t()], binary}
  def create(tx_in_blob, input_count), do: do_create(tx_in_blob, [], input_count)

  @doc """
  Creates a single transaction input from a binary blob.

  Raises `MatchError` if the binary includes any more data after the first input.

  ## Example

    iex> tx_in = "CF3E4414A1A65B96A5485F7A497FED32C0C90E95E4FF334A79559AD9B14920E90100000006AABBCCDDEEFFFFFFFFFF"
    iex> BsvRpc.TransactionInput.create_single(Base.decode16!(tx_in))
    %BsvRpc.TransactionInput{
      previous_output: 1,
      previous_transaction: <<207, 62, 68, 20, 161, 166, 91, 150, 165, 72, 95, 122,
        73, 127, 237, 50, 192, 201, 14, 149, 228, 255, 51, 74, 121, 85, 154, 217,
        177, 73, 32, 233>>,
      script_sig: <<170, 187, 204, 221, 238, 255>>,
      sequence: 4294967295
    }
    iex> tx_in = tx_in <> "FF"
    iex> BsvRpc.TransactionOutput.create_single(Base.decode16!(tx_in))
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
