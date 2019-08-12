defmodule BsvRpc.Transaction do
  # TODO Move to a separate library?
  @moduledoc """
  Functions for Bitcoin transaction manipulation.
  """

  @enforce_keys [:hash, :inputs, :outputs, :version, :locktime, :size]

  @typedoc """
  A Bitcoin transaction.
  """
  defstruct [:hash, :version, :size, :locktime, :inputs, :outputs, :block, :confirmations, :time]

  @type t :: %__MODULE__{
          hash: binary(),
          inputs: [BsvRpc.TransactionInput.t()],
          outputs: [BsvRpc.TransactionOutput.t()],
          version: non_neg_integer(),
          locktime: non_neg_integer(),
          # Optional block hash.
          block: binary(),
          confirmations: non_neg_integer(),
          time: DateTime.t(),
          size: non_neg_integer()
        }

  @doc """
  Creates a transaction from a binary blob.

  ## Examples

    iex> tx = "01000000010000000000000000000000000000000000000000000000000000000000000000FFFFFFFF4D04FFFF001D0104455468652054696D65732030332F4A616E2F32303039204368616E63656C6C6F72206F6E206272696E6B206F66207365636F6E64206261696C6F757420666F722062616E6B73FFFFFFFF0100F2052A01000000434104678AFDB0FE5548271967F1A67130B7105CD6A828E03909A67962E0EA1F61DEB649F6BC3F4CEF38C4F35504E51EC112DE5C384DF7BA0B8D578A4C702B6BF11D5FAC00000000"
    iex> t = tx |> Base.decode16!() |> BsvRpc.Transaction.create()
    iex> t.size
    204
    iex> Base.encode16(t.hash)
    "4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E2CC77AB2127B7AFDEDA33B"
  """
  def create(tx_blob) do
    <<version::little-size(32), rest::binary>> = tx_blob

    {num_inputs, rest} = BsvRpc.Helpers.get_varint(rest)
    {inputs, rest} = BsvRpc.TransactionInput.create(rest, num_inputs)

    {num_outputs, rest} = BsvRpc.Helpers.get_varint(rest)
    {outputs, <<locktime::little-size(32)>>} = BsvRpc.TransactionOutput.create(rest, num_outputs)

    <<hash_big::size(256)>> = BsvRpc.Helpers.double_sha256(tx_blob)
    hash_little = <<hash_big::integer-little-size(256)>>

    %__MODULE__{
      hash: hash_little,
      inputs: inputs,
      outputs: outputs,
      version: version,
      locktime: locktime,
      size: byte_size(tx_blob)
    }
  end

  @doc """
  Gets binary representation of the transaction.
  """
  @spec to_binary(__MODULE__.t()) :: binary
  def to_binary(transaction) do
    inputs =
      transaction.inputs
      |> Enum.map(fn input -> BsvRpc.TransactionInput.to_binary(input) end)
      |> Enum.reduce(fn input, acc -> acc <> input end)

    outputs =
      transaction.outputs
      |> Enum.map(fn output -> BsvRpc.TransactionOutput.to_binary(output) end)
      |> Enum.reduce(fn output, acc -> acc <> output end)

    <<transaction.version::little-size(32)>> <>
      BsvRpc.Helpers.to_varint(length(transaction.inputs)) <>
      inputs <>
      BsvRpc.Helpers.to_varint(length(transaction.outputs)) <>
      outputs <>
      <<transaction.locktime::little-size(32)>>
  end

  @doc """
  Gets hex representation of the transaction.

  ## Examples

    iex> tx = "01000000010000000000000000000000000000000000000000000000000000000000000000FFFFFFFF4D04FFFF001D0104455468652054696D65732030332F4A616E2F32303039204368616E63656C6C6F72206F6E206272696E6B206F66207365636F6E64206261696C6F757420666F722062616E6B73FFFFFFFF0100F2052A01000000434104678AFDB0FE5548271967F1A67130B7105CD6A828E03909A67962E0EA1F61DEB649F6BC3F4CEF38C4F35504E51EC112DE5C384DF7BA0B8D578A4C702B6BF11D5FAC00000000"
    iex> t = tx |> Base.decode16!() |> BsvRpc.Transaction.create()
    iex> BsvRpc.Transaction.to_hex(t)
    "01000000010000000000000000000000000000000000000000000000000000000000000000FFFFFFFF4D04FFFF001D0104455468652054696D65732030332F4A616E2F32303039204368616E63656C6C6F72206F6E206272696E6B206F66207365636F6E64206261696C6F757420666F722062616E6B73FFFFFFFF0100F2052A01000000434104678AFDB0FE5548271967F1A67130B7105CD6A828E03909A67962E0EA1F61DEB649F6BC3F4CEF38C4F35504E51EC112DE5C384DF7BA0B8D578A4C702B6BF11D5FAC00000000"
  """
  @spec to_hex(__MODULE__.t()) :: String.t()
  def to_hex(transaction) do
    Base.encode16(to_binary(transaction))
  end
end
