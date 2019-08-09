defmodule BsvRpc.Address do
  # TODO Move to a separate library?
  @moduledoc """
  Function for Bitcoin address manipulation.

  An address struct can be created using `BsvRpc.Address.create/1` or `BsvRpc.Address.create!/1`:

      iex> BsvRpc.Address.create("1AGNa15ZQXAZUgFiqJ2i7Z2DPU2J6hW62i")
      {:ok, %BsvRpc.Address{
        address: "1AGNa15ZQXAZUgFiqJ2i7Z2DPU2J6hW62i",
        network: :mainnet,
        type: :pubkey
      }}

      iex> BsvRpc.Address.create!("1AGNa15ZQXAZUgFiqJ2i7Z2DPU2J6hW62i")
      %BsvRpc.Address{
        address: "1AGNa15ZQXAZUgFiqJ2i7Z2DPU2J6hW62i",
        network: :mainnet,
        type: :pubkey
      }

  """

  @enforce_keys [:address, :type, :network]
  @preifxes_for_types %{
    script: %{mainnet: 0x05, testnet: 0xC4},
    pubkey: %{mainnet: 0x00, testnet: 0x6F}
  }

  @types_for_prefixes %{
    0x00 => {:mainnet, :pubkey},
    0x6F => {:testnet, :pubkey},
    0x05 => {:mainnet, :script},
    0xC4 => {:testnet, :script}
  }

  @typedoc """
  A Bitcoin address.
  """
  defstruct [:address, :type, :network]

  @type t :: %__MODULE__{
          address: String.t(),
          type: :pubkey | :script,
          network: :mainnet | :testnet
        }

  @doc """
  Creates an address.

  Exception is raised if the address does not validate correctly.

  ## Examples
    iex> BsvRpc.Address.create!("1AGNa15ZQXAZUgFiqJ2i7Z2DPU2J6hW62i")
    %BsvRpc.Address{
      address: "1AGNa15ZQXAZUgFiqJ2i7Z2DPU2J6hW62i",
      network: :mainnet,
      type: :pubkey
    }
  """
  @spec create!(String.t()) :: BsvRpc.Address.t()
  def create!(address) do
    {:ok, decoded} = BsvRpc.Base58Check.decode(address)
    <<prefix::size(8), _hash160::binary>> = decoded
    address_type = @types_for_prefixes[prefix]

    %__MODULE__{
      address: address,
      type: elem(address_type, 1),
      network: elem(address_type, 0)
    }
  end

  @doc """
  Creates an address.

  Exception is raised if the address does not validate correctly.

  ## Examples
    iex> BsvRpc.Address.create("1AGNa15ZQXAZUgFiqJ2i7Z2DPU2J6hW62i")
    {:ok, %BsvRpc.Address{
      address: "1AGNa15ZQXAZUgFiqJ2i7Z2DPU2J6hW62i",
      network: :mainnet,
      type: :pubkey
    }}
  """
  @spec create(String.t()) :: {:error, String.t()} | {:ok, BsvRpc.Address.t()}
  def create(address) do
    {:ok, create!(address)}
  rescue
    _ -> {:error, "Invalid address."}
  end

  @doc """
  Gets gets hash160 for the address.

  ## Examples
    iex> {:ok, address} = BsvRpc.Address.create("1AGNa15ZQXAZUgFiqJ2i7Z2DPU2J6hW62i")
    iex> BsvRpc.Address.hash160(address)
    <<101, 161, 96, 89, 134, 74, 47, 219, 199, 201, 154, 71, 35, 168, 57, 91, 198, 241, 136, 235>>
  """
  @spec hash160(BsvRpc.Address.t()) :: binary
  def hash160(address) do
    prefix = @preifxes_for_types[address.type][address.network]
    {:ok, <<^prefix::size(8), hash160::binary>>} = BsvRpc.Base58Check.decode(address.address)
    hash160
  end
end
