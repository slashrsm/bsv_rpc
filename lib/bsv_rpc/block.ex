defmodule BsvRpc.Block do
  # TODO Move to a separate library?
  @moduledoc """
  Functions for Bitcoin block manipulation.
  """
  use Bitwise

  @enforce_keys [:version, :previous_block, :merkle_root, :timestamp, :bits, :nonce]

  @typedoc """
  A Bitcoin block.
  """
  defstruct [
    :hash,
    :version,
    :previous_block,
    :merkle_root,
    :timestamp,
    :bits,
    :nonce,
    :transactions
  ]

  @type t :: %__MODULE__{
          hash: binary() | nil,
          version: non_neg_integer(),
          previous_block: binary(),
          merkle_root: binary(),
          timestamp: DateTime.t(),
          bits: binary(),
          nonce: binary(),
          transactions: [binary()] | nil
        }

  @doc """
  Creates a block from a binary blob.

  ## Examples

    iex> block = "010000006FE28C0AB6F1B372C1A6A246AE63F74F931E8365E15A089C68D6190000000000982051FD1E4BA744BBBE680E1FEE14677BA1A3C3540BF7B1CDB606E857233E0E61BC6649FFFF001D01E362990101000000010000000000000000000000000000000000000000000000000000000000000000FFFFFFFF0704FFFF001D0104FFFFFFFF0100F2052A0100000043410496B538E853519C726A2C91E61EC11600AE1390813A627C66FB8BE7947BE63C52DA7589379515D4E0A604F8141781E62294721166BF621E73A82CBF2342C858EEAC00000000"
    iex> block = block |> Base.decode16!() |> BsvRpc.Block.create!()
    iex> Base.encode16(block.hash)
    "00000000839A8E6886AB5951D76F411475428AFC90947EE320161BBF18EB6048"
  """
  @spec create!(binary) :: __MODULE__.t()
  def create!(
        <<version::little-size(32), previous_block::binary-size(32), merkle_root::binary-size(32),
          timestamp::little-size(32), bits::binary-size(4), nonce::binary-size(4),
          rest::binary>> = tx_blob
      ) do
    if rest == <<>> do
      %__MODULE__{
        hash: tx_blob |> BsvRpc.Helpers.double_sha256() |> BsvRpc.Helpers.reverse_endianess(),
        version: version,
        previous_block: previous_block,
        merkle_root: merkle_root,
        timestamp: DateTime.from_unix!(timestamp),
        bits: bits,
        nonce: nonce,
        transactions: []
      }
    else
      # TODO transactions
      block = %__MODULE__{
        version: version,
        previous_block: previous_block,
        merkle_root: merkle_root,
        timestamp: DateTime.from_unix!(timestamp),
        bits: bits,
        nonce: nonce,
        transactions: []
      }

      Map.put(
        block,
        :hash,
        block
        |> to_binary()
        |> BsvRpc.Helpers.double_sha256()
        |> BsvRpc.Helpers.reverse_endianess()
      )
    end
  end

  @doc """
  Creates a block from a hex blob.

  ## Examples

    iex> block = BsvRpc.Block.create_from_hex!("010000006fe28c0ab6f1b372c1a6a246ae63f74f931e8365e15a089c68d6190000000000982051fd1e4ba744bbbe680e1fee14677ba1a3c3540bf7b1cdb606e857233e0e61bc6649ffff001d01e362990101000000010000000000000000000000000000000000000000000000000000000000000000ffffffff0704ffff001d0104ffffffff0100f2052a0100000043410496b538e853519c726a2c91e61ec11600ae1390813a627c66fb8be7947be63c52da7589379515d4e0a604f8141781e62294721166bf621e73a82cbf2342c858eeac00000000")
    iex> Base.encode16(block.hash)
    "00000000839A8E6886AB5951D76F411475428AFC90947EE320161BBF18EB6048"
  """
  @spec create_from_hex!(String.t()) :: __MODULE__.t()
  def create_from_hex!(hex) do
    hex |> Base.decode16!(case: :mixed) |> create!()
  end

  @doc """
  Gets binary representation of the block.
  """
  @spec to_binary(__MODULE__.t()) :: binary
  def to_binary(%__MODULE__{} = block) do
    timestamp = DateTime.to_unix(block.timestamp)

    <<block.version::little-size(32)>> <>
      block.previous_block <>
      block.merkle_root <>
      <<timestamp::little-size(32)>> <>
      block.bits <>
      block.nonce
  end

  @doc """
  Gets hex representation of the block.

  ## Examples

    iex> block = BsvRpc.Block.create_from_hex!("010000006FE28C0AB6F1B372C1A6A246AE63F74F931E8365E15A089C68D6190000000000982051FD1E4BA744BBBE680E1FEE14677BA1A3C3540BF7B1CDB606E857233E0E61BC6649FFFF001D01E362990101000000010000000000000000000000000000000000000000000000000000000000000000FFFFFFFF0704FFFF001D0104FFFFFFFF0100F2052A0100000043410496B538E853519C726A2C91E61EC11600AE1390813A627C66FB8BE7947BE63C52DA7589379515D4E0A604F8141781E62294721166BF621E73A82CBF2342C858EEAC00000000")
    iex> BsvRpc.Block.to_hex(block)
    "010000006FE28C0AB6F1B372C1A6A246AE63F74F931E8365E15A089C68D6190000000000982051FD1E4BA744BBBE680E1FEE14677BA1A3C3540BF7B1CDB606E857233E0E61BC6649FFFF001D01E36299"
  """
  @spec to_hex(__MODULE__.t()) :: String.t()
  def to_hex(transaction), do: Base.encode16(to_binary(transaction))

  @doc """
  Gets the block id (hash in the hex form).

  Examples

    iex> block = BsvRpc.Block.create_from_hex!("010000006FE28C0AB6F1B372C1A6A246AE63F74F931E8365E15A089C68D6190000000000982051FD1E4BA744BBBE680E1FEE14677BA1A3C3540BF7B1CDB606E857233E0E61BC6649FFFF001D01E362990101000000010000000000000000000000000000000000000000000000000000000000000000FFFFFFFF0704FFFF001D0104FFFFFFFF0100F2052A0100000043410496B538E853519C726A2C91E61EC11600AE1390813A627C66FB8BE7947BE63C52DA7589379515D4E0A604F8141781E62294721166BF621E73A82CBF2342C858EEAC00000000")
    iex> BsvRpc.Block.id(block)
    "00000000839A8E6886AB5951D76F411475428AFC90947EE320161BBF18EB6048"
  """
  @spec id(__MODULE__.t()) :: String.t()
  def id(block) do
    case block.hash do
      nil ->
        block
        |> to_binary()
        |> BsvRpc.Helpers.double_sha256()
        |> BsvRpc.Helpers.reverse_endianess()
        |> Base.encode16()

      _ ->
        Base.encode16(block.hash)
    end
  end

  @doc """
  Gets the block hash.

  ## Examples

    iex> block = BsvRpc.Block.create_from_hex!("010000006FE28C0AB6F1B372C1A6A246AE63F74F931E8365E15A089C68D6190000000000982051FD1E4BA744BBBE680E1FEE14677BA1A3C3540BF7B1CDB606E857233E0E61BC6649FFFF001D01E362990101000000010000000000000000000000000000000000000000000000000000000000000000FFFFFFFF0704FFFF001D0104FFFFFFFF0100F2052A0100000043410496B538E853519C726A2C91E61EC11600AE1390813A627C66FB8BE7947BE63C52DA7589379515D4E0A604F8141781E62294721166BF621E73A82CBF2342C858EEAC00000000")
    iex> BsvRpc.Block.hash(block)
    <<0, 0, 0, 0, 131, 154, 142, 104, 134, 171, 89, 81, 215, 111, 65, 20, 117, 66, 138, 252, 144, 148, 126, 227, 32, 22, 27, 191, 24, 235, 96, 72>>
  """
  @spec hash(__MODULE__.t()) :: binary()
  def hash(transaction) do
    case transaction.hash do
      nil ->
        transaction
        |> to_binary()
        |> BsvRpc.Helpers.double_sha256()
        |> BsvRpc.Helpers.reverse_endianess()

      _ ->
        transaction.hash
    end
  end
end
