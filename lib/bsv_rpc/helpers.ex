defmodule BsvRpc.Helpers do
  # TODO Move to a separate library?
  @moduledoc """
  Various helper functions.
  """

  @doc """
  Gets the double sha256 hash of the input data.

  ## Examples

    iex> BsvRpc.Helpers.double_sha256(<<>>)
    <<93, 246, 224, 226, 118, 19, 89, 211, 10, 130, 117, 5, 142, 41, 159, 204, 3,
      129, 83, 69, 69, 245, 92, 244, 62, 65, 152, 63, 93, 76, 148, 86>>

    iex> BsvRpc.Helpers.double_sha256(<<0, 0, 0, 0>>)
    <<140, 185, 1, 37, 23, 200, 23, 254, 173, 101, 2, 135, 214, 27, 221, 156, 104,
      128, 59, 107, 249, 198, 65, 51, 220, 171, 62, 101, 181, 165, 12, 185>>

    iex(4)> BsvRpc.Helpers.double_sha256(<<0xff, 0xff, 0xff, 0xff>>)
    <<59, 177, 48, 41, 206, 123, 31, 85, 158, 245, 231, 71, 252, 172, 67, 159, 20,
      85, 162, 236, 124, 95, 9, 183, 34, 144, 121, 94, 112, 102, 80, 68>>
  """
  @spec double_sha256(binary) :: binary
  def double_sha256(data) do
    :crypto.hash(:sha256, :crypto.hash(:sha256, data))
  end

  @doc """
  Gets variable length integer from the beginning of a binary.

  ## Examples

    iex> BsvRpc.Helpers.get_varint(<<0x01>>)
    {1, <<>>}

    iex> BsvRpc.Helpers.get_varint(<<0xFD, 0x80, 0x00, 0x12, 0x34>>)
    {128, <<0x12, 0x34>>}

    iex> BsvRpc.Helpers.get_varint(<<0xFE, 0xFF, 0xFF, 0xFF, 0xFF, 0x00>>)
    {4294967295, <<0x00>>}

    iex> BsvRpc.Helpers.get_varint(<<0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xEE>>)
    {18446744073709551615, <<0xEE>>}
  """
  @spec get_varint(binary) :: {non_neg_integer(), binary()}
  def get_varint(<<prefix::little-size(8), rest::binary>>) do
    case prefix do
      0xFF ->
        <<len::little-size(64), rest::binary>> = rest
        {len, rest}

      0xFE ->
        <<len::little-size(32), rest::binary>> = rest
        {len, rest}

      0xFD ->
        <<len::little-size(16), rest::binary>> = rest
        {len, rest}

      _ ->
        {prefix, rest}
    end
  end

  @doc """
  Gets variable length data (defines with variable length prefix bytes) from the beginning of the binary.

  Returns a tuple with the variable length data as the first element and the rest of the original binary as
  the second.

  ## Examples
    iex> BsvRpc.Helpers.get_varlen_data(<<0x01, 0xFF, 0xEE>>)
    {<<255>>, <<0xEE>>}

    iex> BsvRpc.Helpers.get_varlen_data(<<0xFD, 0x01, 0x00, 0xEE, 0x34>>)
    {<<0xEE>>, <<0x34>>}
  """
  @spec get_varlen_data(binary) :: {binary, binary}
  def get_varlen_data(data) do
    {len, data} = get_varint(data)
    <<data::binary-size(len), rest::binary>> = data
    {data, rest}
  end

  @doc """
  Gets variable length integer representation of a number.

  ## Examples

    iex> BsvRpc.Helpers.to_varint(1)
    <<0x01>>

    iex> BsvRpc.Helpers.to_varint(32768)
    <<0xFD, 0x00, 0x80>>

    iex> BsvRpc.Helpers.to_varint(4294967295)
    <<0xFE, 0xFF, 0xFF, 0xFF, 0xFF>>

    iex> BsvRpc.Helpers.to_varint(18446744073709551615)
    <<0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF>>
  """
  @spec to_varint(non_neg_integer) :: binary
  def to_varint(number) when number < 0xFD, do: <<number::little-size(8)>>
  def to_varint(number) when number <= 0xFFFF, do: <<0xFD, number::little-size(16)>>
  def to_varint(number) when number <= 0xFFFFFFFF, do: <<0xFE, number::little-size(32)>>
  def to_varint(number), do: <<0xFF, number::little-size(64)>>

  @doc """
  Prefixed data with the varlen prefix.

  ## Examples

    iex> BsvRpc.Helpers.to_varlen_data(<<0xff, 0xee>>)
    <<0x02, 0xff, 0xee>>

    iex> BsvRpc.Helpers.to_varlen_data(<<0xff>>)
    <<0x01, 0xff>>
  """
  @spec to_varlen_data(binary) :: binary
  def to_varlen_data(data) do
    BsvRpc.Helpers.to_varint(byte_size(data)) <> data
  end

  @doc """
  Gets letgth of PUSHDATA from the beginning of a binary.

  ## Examples

    iex> BsvRpc.Helpers.get_pushdata_length(<<0x01>>)
    {1, <<>>}

    iex> BsvRpc.Helpers.get_pushdata_length(<<0x4C, 0x80, 0x00, 0x12, 0x34>>)
    {128, <<0x00, 0x12, 0x34>>}

    iex> BsvRpc.Helpers.get_pushdata_length(<<0x4D, 0x01, 0xFF, 0x00>>)
    {65281, <<0x00>>}

    iex> BsvRpc.Helpers.get_pushdata_length(<<0x4E, 0x01, 0x00, 0x00, 0xFF, 0xEE>>)
    {4278190081, <<0xEE>>}
  """
  @spec get_pushdata_length(binary) :: {non_neg_integer(), binary()}
  def get_pushdata_length(<<prefix::little-size(8), rest::binary>>) do
    case prefix do
      0x4E ->
        <<len::little-size(32), rest::binary>> = rest
        {len, rest}

      0x4D ->
        <<len::little-size(16), rest::binary>> = rest
        {len, rest}

      0x4C ->
        <<len::little-size(8), rest::binary>> = rest
        {len, rest}

      _ ->
        {prefix, rest}
    end
  end

  @doc """
  Gets OP_PUSHDATA data from the beginning of the binary.

  Returns a tuple with the OP_PUSHDATA data as the first element and the rest of the original binary as
  the second.

  ## Examples
    iex> BsvRpc.Helpers.get_pushdata(<<0x01, 0xFF, 0xEE>>)
    {<<255>>, <<0xEE>>}

    iex> BsvRpc.Helpers.get_pushdata(<<0x4C, 0x01, 0xEE, 0x34>>)
    {<<0xEE>>, <<0x34>>}

    iex> BsvRpc.Helpers.get_pushdata(<<0x4D, 0x01, 0x00, 0xEE, 0x34>>)
    {<<0xEE>>, <<0x34>>}

    iex> BsvRpc.Helpers.get_pushdata(<<0x4E, 0x01, 0x00, 0x00, 0x00, 0xEE, 0x34>>)
    {<<0xEE>>, <<0x34>>}
  """
  @spec get_pushdata(binary) :: {binary, binary}
  def get_pushdata(data) do
    {len, data} = get_pushdata_length(data)
    <<data::binary-size(len), rest::binary>> = data
    {data, rest}
  end

  @doc """
  Gets variable length integer representation of a number.

  ## Examples

    iex> BsvRpc.Helpers.get_pushdata_opcode(<<0x00, 0x00>>)
    <<0x02>>

    iex> BsvRpc.Helpers.get_pushdata_opcode(:crypto.strong_rand_bytes(0x4F))
    <<0x4C, 0x4F>>

    iex> BsvRpc.Helpers.get_pushdata_opcode(:crypto.strong_rand_bytes(0xFF00))
    <<0x4D, 0x00, 0xFF>>

    iex> BsvRpc.Helpers.get_pushdata_opcode(:crypto.strong_rand_bytes(0xFFFF01))
    <<0x4E, 0x01, 0xFF, 0xFF, 0x00>>
  """
  @spec get_pushdata_opcode(binary) :: binary
  def get_pushdata_opcode(data) when byte_size(data) < 0x4C,
    do: <<byte_size(data)::little-size(8)>>

  def get_pushdata_opcode(data) when byte_size(data) <= 0xFF,
    do: <<0x4C, byte_size(data)::little-size(8)>>

  def get_pushdata_opcode(data) when byte_size(data) <= 0xFFFF,
    do: <<0x4D, byte_size(data)::little-size(16)>>

  def get_pushdata_opcode(data) when byte_size(data) <= 0xFFFFFFFF,
    do: <<0x4E, byte_size(data)::little-size(32)>>

  def get_pushdata_opcode(_), do: raise("Can't push more than 4GB.")

  @doc """
  Prefixed data with the relevant OP_PUSHDATA op code.

  ## Examples

    iex> BsvRpc.Helpers.to_pushdata(<<0xFF, 0xEE>>)
    <<0x02, 0xFF, 0xEE>>

    iex> BsvRpc.Helpers.to_pushdata(<<0xFF>>)
    <<0x01, 0xFF>>
  """
  @spec to_pushdata(binary) :: binary
  def to_pushdata(data) do
    BsvRpc.Helpers.get_pushdata_opcode(data) <> data
  end

  @doc """
  Converts endianess of a binary blob.

  ## Examples

    iex> BsvRpc.Helpers.reverse_endianess(<<0xff, 0xee, 0xdd, 0xcc>>)
    <<0xcc, 0xdd, 0xee, 0xff>>

    iex> BsvRpc.Helpers.reverse_endianess(<<0x00, 0x11, 0x22, 0x33>>)
    <<0x33, 0x22, 0x11, 0x00>>
  """
  def reverse_endianess(data) do
    len = byte_size(data) * 8
    <<as_number::size(len)>> = data
    <<as_number::integer-little-size(len)>>
  end
end
