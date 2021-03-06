defmodule BsvRpc.TransactionOutput do
  # TODO Move to a separate library?
  @moduledoc """
  Functions for Bitcoin transaction outputs manipulation.
  """

  @op_dup 0x76
  @op_hash160 0xA9
  @op_equalverify 0x88
  @op_checksig 0xAC
  @op_false 0x00
  @op_return 0x6A

  @typedoc """
  A Bitcoin transaction output.
  """
  @enforce_keys [:value, :script_pubkey]
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
    iex> tx_out |> Base.decode16!() |> BsvRpc.TransactionOutput.create(2)
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
    iex> tx_out|> Base.decode16!() |> BsvRpc.TransactionOutput.create()
    %BsvRpc.TransactionOutput{
      script_pubkey: <<118, 169, 20, 55, 229, 207, 18, 237, 236, 118, 204, 137, 218,
        58, 115, 25, 64, 161, 241, 147, 45, 133, 63, 136, 172>>,
      value: 10289728209
    }
    iex> tx_out = tx_out <> "FF"
    iex> tx_out |> Base.decode16!() |> BsvRpc.TransactionOutput.create()
    ** (MatchError) no match of right hand side value: {[%BsvRpc.TransactionOutput{script_pubkey: <<118, 169, 20, 55, 229, 207, 18, 237, 236, 118, 204, 137, 218, 58, 115, 25, 64, 161, 241, 147, 45, 133, 63, 136, 172>>, value: 10289728209}], <<255>>}
  """
  @spec create(binary) :: __MODULE__.t()
  def create(tx_out_blob) do
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
  Gets the binary representation of the transaction output.

  ## Examples

    iex> tx_out = "D1CA5065020000001976A91437E5CF12EDEC76CC89DA3A731940A1F1932D853F88AC"
    iex> t = tx_out |> Base.decode16!() |> BsvRpc.TransactionOutput.create()
    iex> t |> BsvRpc.TransactionOutput.to_binary() |> Base.encode16()
    "D1CA5065020000001976A91437E5CF12EDEC76CC89DA3A731940A1F1932D853F88AC"
  """
  @spec to_binary(__MODULE__.t()) :: binary
  def to_binary(tx_out) do
    <<tx_out.value::little-size(64)>> <>
      BsvRpc.Helpers.to_varint(byte_size(tx_out.script_pubkey)) <>
      tx_out.script_pubkey
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

  @doc """
  Gets the script pubKey to pay to the address.

  ## Examples

    iex> {:ok, a} = BsvRpc.Address.create("1KqbPy3xFdHuL6gmWLgzhVz1tUMUgY5xWe")
    iex> BsvRpc.TransactionOutput.p2pkh_script_pubkey(a) |> Base.encode16()
    "76A914CEA2F14D4ADB6CCDD185BA6BA45DF49597E409C488AC"
  """
  @spec p2pkh_script_pubkey(%BsvRpc.Address{}) :: binary
  def p2pkh_script_pubkey(address) do
    hash = BsvRpc.Address.hash160(address)

    <<@op_dup, @op_hash160>> <>
      BsvRpc.Helpers.to_varlen_data(hash) <>
      <<@op_equalverify, @op_checksig>>
  end

  @doc """
  Creates a data (OP_RETURN) output.

  ## Examples

    iex> BsvRpc.TransactionOutput.get_data_output(["foo", "barbaz", <<0xFF, 0xFF>>])
    %BsvRpc.TransactionOutput{
      value: 0,
      script_pubkey: <<0x00, 0x6A, 3, "foo"::binary, 6, "barbaz"::binary, 2, 0xFF, 0xFF>>
    }
  """
  @spec get_data_output([String.t() | binary()]) :: __MODULE__.t()
  def get_data_output(content) do
    %__MODULE__{
      value: 0,
      script_pubkey:
        <<@op_false, @op_return>> <>
          Enum.reduce(content, <<>>, fn item, acc ->
            acc <> BsvRpc.Helpers.to_pushdata(item)
          end)
    }
  end

  @doc """
  Gets the index of an output with the provided script pubkey.

  Returns index of the matching output or nil if not found.

  ## Examples

    iex> BsvRpc.TransactionOutput.find_by_script_pubkey!([
    ...>   %BsvRpc.TransactionOutput{
    ...>     value: 0,
    ...>     script_pubkey: <<0x00>>
    ...>   },
    ...>   %BsvRpc.TransactionOutput{
    ...>     value: 0,
    ...>     script_pubkey: <<0xFF>>
    ...>   }], <<0xFF>>)
    1

    iex> BsvRpc.TransactionOutput.find_by_script_pubkey!([
    ...>   %BsvRpc.TransactionOutput{
    ...>     value: 0,
    ...>     script_pubkey: <<0x00>>
    ...>   },
    ...>   %BsvRpc.TransactionOutput{
    ...>     value: 0,
    ...>     script_pubkey: <<0xFF>>
    ...>   }], <<0xAA>>)
    nil
  """
  @spec find_by_script_pubkey!([__MODULE__.t()], binary()) :: non_neg_integer | nil
  def find_by_script_pubkey!(outputs, script_pub_key) do
    Enum.find_index(outputs, fn output ->
      output.script_pubkey == script_pub_key
    end)
  end

  @doc """
  Gets the index of an output with the provided script pubkey.

  Returns {:ok, index} or {:error, "Could not find output."} nil if not found.

  ## Examples

    iex> BsvRpc.TransactionOutput.find_by_script_pubkey([
    ...>   %BsvRpc.TransactionOutput{
    ...>     value: 0,
    ...>     script_pubkey: <<0x00>>
    ...>   },
    ...>   %BsvRpc.TransactionOutput{
    ...>     value: 0,
    ...>     script_pubkey: <<0xFF>>
    ...>   }], <<0xFF>>)
    {:ok, 1}

    iex> BsvRpc.TransactionOutput.find_by_script_pubkey([
    ...>   %BsvRpc.TransactionOutput{
    ...>     value: 0,
    ...>     script_pubkey: <<0x00>>
    ...>   },
    ...>   %BsvRpc.TransactionOutput{
    ...>     value: 0,
    ...>     script_pubkey: <<0xFF>>
    ...>   }], <<0xAA>>)
    {:error, "Could not find output."}
  """
  @spec find_by_script_pubkey([__MODULE__.t()], binary()) ::
          {:ok, non_neg_integer} | {:error, String.t()}
  def find_by_script_pubkey(outputs, script_pub_key) do
    case find_by_script_pubkey!(outputs, script_pub_key) do
      nil -> {:error, "Could not find output."}
      index -> {:ok, index}
    end
  end

  @doc """
  Gets the index of an output with the provided value.

  Returns index of the matching output or nil if not found.

  ## Examples

    iex> BsvRpc.TransactionOutput.find_by_value!([
    ...>   %BsvRpc.TransactionOutput{
    ...>     value: 123,
    ...>     script_pubkey: <<0x00>>
    ...>   },
    ...>   %BsvRpc.TransactionOutput{
    ...>     value: 456,
    ...>     script_pubkey: <<0xFF>>
    ...>   }], 456)
    1

    iex> BsvRpc.TransactionOutput.find_by_value!([
    ...>   %BsvRpc.TransactionOutput{
    ...>     value: 123,
    ...>     script_pubkey: <<0x00>>
    ...>   },
    ...>   %BsvRpc.TransactionOutput{
    ...>     value: 456,
    ...>     script_pubkey: <<0xFF>>
    ...>   }], 0)
    nil
  """
  @spec find_by_value!([__MODULE__.t()], non_neg_integer()) :: non_neg_integer | nil
  def find_by_value!(outputs, value) do
    Enum.find_index(outputs, fn output ->
      output.value == value
    end)
  end

  @doc """
  Gets the index of an output with the provided value.

  Returns {:ok, index} or {:error, "Could not find output."} nil if not found.

  ## Examples

    iex> BsvRpc.TransactionOutput.find_by_value([
    ...>   %BsvRpc.TransactionOutput{
    ...>     value: 123,
    ...>     script_pubkey: <<0x00>>
    ...>   },
    ...>   %BsvRpc.TransactionOutput{
    ...>     value: 456,
    ...>     script_pubkey: <<0xFF>>
    ...>   }], 456)
    {:ok, 1}

    iex> BsvRpc.TransactionOutput.find_by_value([
    ...>   %BsvRpc.TransactionOutput{
    ...>     value: 123,
    ...>     script_pubkey: <<0x00>>
    ...>   },
    ...>   %BsvRpc.TransactionOutput{
    ...>     value: 456,
    ...>     script_pubkey: <<0xFF>>
    ...>   }], 0)
    {:error, "Could not find output."}
  """
  @spec find_by_value([__MODULE__.t()], non_neg_integer()) ::
          {:ok, non_neg_integer} | {:error, String.t()}
  def find_by_value(outputs, value) do
    case find_by_value!(outputs, value) do
      nil -> {:error, "Could not find output."}
      index -> {:ok, index}
    end
  end

  @doc """
  Gets the index of a data output (OP_FALSE OP_RETURN or OP_RETURN ...).

  Returns index of the matching output or nil if not found.

  ## Examples

    iex> BsvRpc.TransactionOutput.find_data_output!([
    ...>   %BsvRpc.TransactionOutput{
    ...>     value: 123,
    ...>     script_pubkey: <<0x00, 0x6A, 0xFF>>
    ...>   },
    ...>   %BsvRpc.TransactionOutput{
    ...>     value: 456,
    ...>     script_pubkey: <<0xFF>>
    ...>   }])
    0

    iex> BsvRpc.TransactionOutput.find_data_output!([
    ...>   %BsvRpc.TransactionOutput{
    ...>     value: 123,
    ...>     script_pubkey: <<0x00>>
    ...>   },
    ...>   %BsvRpc.TransactionOutput{
    ...>     value: 456,
    ...>     script_pubkey: <<0xFF>>
    ...>   }])
    nil
  """
  @spec find_data_output!([__MODULE__.t()]) :: non_neg_integer() | nil
  def find_data_output!(outputs) do
    Enum.find_index(outputs, fn output ->
      case output.script_pubkey do
        <<0x00, 0x6A, _rest::binary>> -> true
        <<0x6A, _rest::binary>> -> true
        _ -> false
      end
    end)
  end

  @doc """
  Gets the index of a data output (OP_FALSE OP_RETURN or OP_RETURN ...).

  Returns {:ok, index} or {:error, "Data output not found."} nil if not found.

  ## Examples

    iex> BsvRpc.TransactionOutput.find_data_output([
    ...>   %BsvRpc.TransactionOutput{
    ...>     value: 123,
    ...>     script_pubkey: <<0x00, 0x6A, 0xFF>>
    ...>   },
    ...>   %BsvRpc.TransactionOutput{
    ...>     value: 456,
    ...>     script_pubkey: <<0xFF>>
    ...>   }])
    {:ok, 0}

    iex> BsvRpc.TransactionOutput.find_data_output([
    ...>   %BsvRpc.TransactionOutput{
    ...>     value: 123,
    ...>     script_pubkey: <<0x00>>
    ...>   },
    ...>   %BsvRpc.TransactionOutput{
    ...>     value: 456,
    ...>     script_pubkey: <<0xFF>>
    ...>   }])
    {:error, "Data output not found."}
  """
  @spec find_data_output([__MODULE__.t()]) ::
          {:ok, non_neg_integer()} | {:error, String.t()}
  def find_data_output(outputs) do
    case find_data_output!(outputs) do
      nil -> {:error, "Data output not found."}
      index -> {:ok, index}
    end
  end
end
