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
    iex> {[tx1, tx2], <<0xAA, 0xBB>>} = tx_in |> Base.decode16!() |> BsvRpc.TransactionInput.create(2)
    iex> tx1.previous_transaction
    <<62, 66, 57, 197, 238, 73, 131, 231, 60, 14, 82, 209, 240, 27, 5,
      138, 187, 26, 255, 153, 10, 120, 98, 21, 133, 173, 82, 42, 168,
      196, 73, 129>>
    iex> tx1.previous_output
    2
    iex> tx2.previous_transaction
    <<180, 22, 99, 154, 96, 94, 251, 46, 128, 12, 61, 247, 254, 57, 6,
      95, 83, 105, 100, 12, 177, 74, 114, 85, 204, 236, 149, 150, 165,
      103, 38, 129>>
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
    iex> tx_in |> Base.decode16!() |> BsvRpc.TransactionInput.create_single()
    %BsvRpc.TransactionInput{
      previous_output: 1,
      previous_transaction: <<233, 32, 73, 177, 217, 154, 85, 121, 74, 51, 255, 228, 149, 14, 201, 192, 50, 237, 127,
        73, 122, 95, 72, 165, 150, 91, 166, 161, 20, 68, 62, 207>>,
      script_sig: <<170, 187, 204, 221, 238, 255>>,
      sequence: 4294967295
    }
    iex> tx_in = tx_in <> "FF"
    iex> tx_in |> Base.decode16!() |> BsvRpc.TransactionOutput.create_single()
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
         <<prev_tx::binary-size(32), prev_txout::little-size(32), rest::binary>>,
         inputs,
         input_count
       ) do
    {script_sig, <<sequence::little-size(32), rest::binary>>} =
      BsvRpc.Helpers.get_varlen_data(rest)

    # We have to reverse the hash bytes in order to store it in little endian.
    <<prev_tx_reversed::size(256)>> = prev_tx

    input = %__MODULE__{
      previous_transaction: <<prev_tx_reversed::integer-little-size(256)>>,
      previous_output: prev_txout,
      script_sig: script_sig,
      sequence: sequence
    }

    do_create(rest, [input | inputs], input_count - 1)
  end

  @doc """
  Gets the binary representation of the transaction input.

  ## Examples

    iex> tx_in = "CF3E4414A1A65B96A5485F7A497FED32C0C90E95E4FF334A79559AD9B14920E90100000006AABBCCDDEEFFFFFFFFFF"
    iex> t = tx_in |> Base.decode16!() |> BsvRpc.TransactionInput.create_single()
    iex> t |> BsvRpc.TransactionInput.to_binary() |> Base.encode16()
    "CF3E4414A1A65B96A5485F7A497FED32C0C90E95E4FF334A79559AD9B14920E90100000006AABBCCDDEEFFFFFFFFFF"
  """
  @spec to_binary(__MODULE__.t()) :: binary
  def to_binary(tx_in) do
    # We have to reverse the hash bytes in order to store it in little endian.
    <<prev_tx_reversed::size(256)>> = tx_in.previous_transaction

    <<prev_tx_reversed::integer-little-size(256)>> <>
      <<tx_in.previous_output::little-size(32)>> <>
      BsvRpc.Helpers.to_varint(byte_size(tx_in.script_sig)) <>
      tx_in.script_sig <>
      <<tx_in.sequence::little-size(32)>>
  end
end
