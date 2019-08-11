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

  Returns a tuple with the list of outputs and the remaining of the binary blob.

  ## Arguments

    - `tx_out_blob` - Binary blob to parse transaction outputs from.
    - `output_count` - Number of transactions outputs to parse.

  ## Example

    iex> tx_out = "D1CA5065020000001976A91437E5CF12EDEC76CC89DA3A731940A1F1932D853F88AC" <> "9504D702000000001976A914B9B9EDB47415C3D6980FEC683C60B8B74754DF9988AC" <> "AABB"
    iex> BsvRpc.TransactionOutput.create(Base.decode16!(tx_out), 2)
    {[
      %BsvRpc.TransactionOutput{
        script_pubkey: <<118, 169, 20, 55, 229, 207, 18, 237, 236, 118, 204, 137, 218,
          58, 115, 25, 64, 161, 241, 147, 45, 133, 63, 136, 172>>,
        value: 10289728209
      },
      %BsvRpc.TransactionOutput{
        script_pubkey: <<118, 169, 20, 185, 185, 237, 180, 116, 21, 195, 214, 152,
          15, 236, 104, 60, 96, 184, 183, 71, 84, 223, 153, 136, 172>>,
        value: 47645845
      }
    ], <<0xAA, 0xBB>>}
  """
  @spec create(binary, non_neg_integer) :: {[__MODULE__.t()], binary}
  def create(tx_out_blob, output_count), do: do_create(tx_out_blob, [], output_count)

  @doc """
  Creates a single transaction output from a binary blob.

  Raises `MatchError` if the binary includes any more data after the first transaction output.

  ## Example

    iex> tx_out = "D1CA5065020000001976A91437E5CF12EDEC76CC89DA3A731940A1F1932D853F88AC"
    iex> BsvRpc.TransactionOutput.create_single(Base.decode16!(tx_out))
    %BsvRpc.TransactionOutput{
      script_pubkey: <<118, 169, 20, 55, 229, 207, 18, 237, 236, 118, 204, 137, 218,
        58, 115, 25, 64, 161, 241, 147, 45, 133, 63, 136, 172>>,
      value: 10289728209
    }
    iex> tx_out = tx_out <> "FF"
    iex> BsvRpc.TransactionOutput.create_single(Base.decode16!(tx_out))
    ** (MatchError) no match of right hand side value: {[%BsvRpc.TransactionOutput{script_pubkey: <<118, 169, 20, 55, 229, 207, 18, 237, 236, 118, 204, 137, 218, 58, 115, 25, 64, 161, 241, 147, 45, 133, 63, 136, 172>>, value: 10289728209}], <<255>>}
  """
  @spec create_single(binary) :: __MODULE__.t()
  def create_single(tx_out_blob) do
    {[tx_in | []], <<>>} = do_create(tx_out_blob, [], 1)
    tx_in
  end

  @spec do_create(binary, [__MODULE__.t()], non_neg_integer) :: {[__MODULE__.t()], binary}
  defp do_create(rest, inputs, 0), do: {Enum.reverse(inputs), rest}

  defp do_create(<<value::little-size(64), rest::binary>>, outputs, output_count) do
    {script_pubkey, <<rest::binary>>} = BsvRpc.Helpers.get_varlen_data(rest)

    output = %__MODULE__{
      value: value,
      script_pubkey: script_pubkey
    }

    do_create(rest, [output | outputs], output_count - 1)
  end

  @doc """
  Gets the output value in Bitcoins.

  ## Example

    iex> tx_out = %BsvRpc.TransactionOutput{script_pubkey: <<0x00, 0x00>>, value: 100_000_000}
    iex> BsvRpc.TransactionOutput.value(tx_out)
    1.0

    iex> tx_out = %BsvRpc.TransactionOutput{script_pubkey: <<0x00, 0x00>>, value: 12_345_678_999}
    iex> BsvRpc.TransactionOutput.value(tx_out)
    123.45678999
  """
  @spec value(__MODULE__.t()) :: float
  def value(output), do: output.value / 100_000_000
end
