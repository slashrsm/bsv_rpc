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
end
