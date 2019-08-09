defmodule BsvRpc.Base58Check do
  # TODO Move to a separate library?
  @moduledoc """
  Base58Check encoder/decoder.
  """

  @base58_alphabet ~c(123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz)

  @doc """
  Decodes a base58check encoded data.

  An ArgumentError exception is raised if the invalid input is provided or MatchError exception is raised if
  the checksum does not validate.

  ## Examples
    iex> BsvRpc.Base58Check.decode!("1AGNa15ZQXAZUgFiqJ2i7Z2DPU2J6hW62i")
    <<0, 101, 161, 96, 89, 134, 74, 47, 219, 199, 201, 154, 71, 35, 168, 57, 91, 198, 241, 136, 235>>

    iex> <<_prefix::size(8), decoded::binary>> = BsvRpc.Base58Check.decode!("3CMNFxN1oHBc4R1EpboAL5yzHGgE611Xou")
    iex> Base.encode16(decoded, case: :lower)
    "74f209f6ea907e2ea48f74fae05782ae8a665257"

    iex> <<_prefix::size(8), decoded::binary>> = BsvRpc.Base58Check.decode!("mo9ncXisMeAoXwqcV5EWuyncbmCcQN4rVs")
    iex> Base.encode16(decoded, case: :lower)
    "53c0307d6851aa0ce7825ba883c6bd9ad242b486"
  """
  @spec decode!(String.t()) :: binary
  def decode!(str) do
    common =
      str
      |> to_charlist()
      |> base58_decode(0)
      # From the node implementaiton
      # https://github.com/bitcoin-sv/bitcoin-sv/blob/f5503f0fe1a30db70b9a07b2a22e27468bf1b59a/src/base58.cpp#L37
      |> num_to_bytes(round(String.length(str) * 733 / 1000), :big)

    common =
      if count_leading_zero_bytes(common, 0) > 0 and
           String.length(String.trim_leading(str, "1")) == String.length(str) do
        remove_leading_zero_bytes(common)
      else
        common
      end

    payload_size = byte_size(common) - 4
    <<payload::binary-size(payload_size), checksum::binary-size(4)>> = common

    ## Validate the checksum.
    <<checksum_valid::binary-size(4), _rest::binary>> = double_sha256(payload)
    ^checksum = checksum_valid

    payload
  end

  @doc """
  Decodes a base58check encoded data.

  ## Examples
    iex> BsvRpc.Base58Check.decode("1AGNa15ZQXAZUgFiqJ2i7Z2DPU2J6hW62i")
    {:ok, <<0, 101, 161, 96, 89, 134, 74, 47, 219, 199, 201, 154, 71, 35, 168, 57, 91, 198, 241, 136, 235>>}

    iex> {:ok, <<_prefix::size(8), decoded::binary>>} = BsvRpc.Base58Check.decode("3CMNFxN1oHBc4R1EpboAL5yzHGgE611Xou")
    iex> Base.encode16(decoded, case: :lower)
    "74f209f6ea907e2ea48f74fae05782ae8a665257"

    iex> {:ok, <<_prefix::size(8), decoded::binary>>} = BsvRpc.Base58Check.decode("mo9ncXisMeAoXwqcV5EWuyncbmCcQN4rVs")
    iex> Base.encode16(decoded, case: :lower)
    "53c0307d6851aa0ce7825ba883c6bd9ad242b486"
  """
  @spec decode(String.t()) :: {:ok, binary()} | {:error, String.t()}
  def decode(str) do
    try do
      decoded = decode!(str)
      {:ok, decoded}
    rescue
      MatchError -> {:error, "Checksum validation failed."}
      ArgumentError -> {:error, "Input invalid."}
    end
  end

  defp base58_decode([], acc), do: acc

  defp base58_decode([c | cs], acc) do
    base58_decode(cs, acc * 58 + Enum.find_index(@base58_alphabet, &(&1 == c)))
  end

  @doc """
  Encodes binary using base58check.

  ## Examples
    iex> BsvRpc.Base58Check.encode(<<0, 101, 161, 96, 89, 134, 74, 47, 219, 199, 201, 154, 71, 35, 168, 57, 91, 198, 241, 136, 235>>)
    "1AGNa15ZQXAZUgFiqJ2i7Z2DPU2J6hW62i"

    iex> hex_encoded = Base.decode16!("74f209f6ea907e2ea48f74fae05782ae8a665257", case: :lower)
    iex> BsvRpc.Base58Check.encode(<<0x05>> <> hex_encoded)
    "3CMNFxN1oHBc4R1EpboAL5yzHGgE611Xou"

    iex> hex_encoded = Base.decode16!("53c0307d6851aa0ce7825ba883c6bd9ad242b486", case: :lower)
    iex> BsvRpc.Base58Check.encode(<<0x6f>> <> hex_encoded)
    "mo9ncXisMeAoXwqcV5EWuyncbmCcQN4rVs"
  """
  @spec encode(binary) :: String.t()
  def encode(data) do
    <<checksum::binary-size(4), _rest::binary>> = double_sha256(data)

    encoded = base58_encode(:binary.decode_unsigned(data <> checksum, :big), "")

    String.pad_leading(
      encoded,
      String.length(encoded) + count_leading_zero_bytes(data, 0),
      ["1"]
    )
  end

  defp base58_encode(0, acc), do: acc

  defp base58_encode(num, acc) do
    base58_encode(
      div(num, 58),
      to_string([Enum.at(@base58_alphabet, rem(num, 58))]) <> acc
    )
  end

  defp remove_leading_zero_bytes(<<0::size(8), rest::binary>>) do
    remove_leading_zero_bytes(rest)
  end

  defp remove_leading_zero_bytes(rest), do: rest

  defp count_leading_zero_bytes(<<0::size(8), rest::binary>>, count) do
    count_leading_zero_bytes(rest, count + 1)
  end

  defp count_leading_zero_bytes(_data, count), do: count

  @spec double_sha256(binary) :: binary
  defp double_sha256(data) do
    :crypto.hash(:sha256, :crypto.hash(:sha256, data))
  end

  defp num_to_bytes(number, num_bytes, endian) do
    result = :binary.encode_unsigned(number, endian)
    missing = (num_bytes - byte_size(result)) * 8

    cond do
      missing > 0 ->
        <<0::size(missing)>> <> result

      missing < 0 ->
        raise ArgumentError, "Number exceed the requested byte size"

      true ->
        result
    end
  end
end
