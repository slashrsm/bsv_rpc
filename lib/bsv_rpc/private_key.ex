defmodule BsvRpc.PrivateKey do
  # TODO Move to a separate library?
  @moduledoc """
  Function for Bitcoin private key manipulation.

  A private key struct can be created using `BsvRpc.PrivateKey.create/2`:

    iex> BsvRpc.PrivateKey.create(<<18, 178, 65, 32, 134, 45, 30, 1, 67, 228, 110, 223, 142, 202, 105, 135>>, :mainnet)
    %BsvRpc.PrivateKey{
      key: <<18, 178, 65, 32, 134, 45, 30, 1, 67, 228, 110, 223, 142, 202, 105, 135>>,
      network: :mainnet,
    }

  or from a HD extended key using `BsvRpc.PrivateKey.create/1`:

    iex> words = "battle reunion keep inflict pair speed parade piece chimney leisure fiber miracle survey parade drift grocery lumber pumpkin pretty utility help party board turkey"
    iex> seed = Mnemonic.to_seed(words, "", :english)
    iex> master = ExtendedKey.master(seed)
    iex> BsvRpc.PrivateKey.create(master)
    %BsvRpc.PrivateKey{
      key: <<200, 39, 129, 91, 180, 166, 106, 96, 75, 145, 229, 79, 107, 38, 116, 240, 56, 93, 12,
        228, 63, 254, 128, 211, 54, 156, 181, 205, 21, 189, 1, 152>>,
      network: :mainnet,
    }
  """

  @enforce_keys [:key, :network]

  @typedoc """
  A private key.
  """
  defstruct [:key, :network]

  @type t :: %__MODULE__{
          key: <<>>,
          network: :mainnet | :testnet
        }

  @doc """
  Creates a private key.

  ## Examples
    iex> BsvRpc.PrivateKey.create(<<18, 178, 65, 32, 134, 45, 30, 1, 67, 228, 110, 223, 142, 202, 105, 135>>, :mainnet)
    %BsvRpc.PrivateKey{
      key: <<18, 178, 65, 32, 134, 45, 30, 1, 67, 228, 110, 223, 142, 202, 105, 135>>,
      network: :mainnet,
    }

    iex> BsvRpc.PrivateKey.create("12B24120862D1E0143E46EDF8ECA6987", :mainnet)
    %BsvRpc.PrivateKey{
      key: <<18, 178, 65, 32, 134, 45, 30, 1, 67, 228, 110, 223, 142, 202, 105, 135>>,
      network: :mainnet,
    }
  """
  @spec create(binary, :mainnet | :testnet) :: __MODULE__.t()
  def create(key, network) when is_binary(key) do
    case Base.decode16(key, case: :mixed) do
      {:ok, decoded_key} ->
        %__MODULE__{
          key: decoded_key,
          network: network
        }

      :error ->
        %__MODULE__{
          key: key,
          network: network
        }
    end
  end

  @doc """
  Creates a private key from a HD extended key.

  ## Examples
    iex> words = "battle reunion keep inflict pair speed parade piece chimney leisure fiber miracle survey parade drift grocery lumber pumpkin pretty utility help party board turkey"
    iex> seed = Mnemonic.to_seed(words, "", :english)
    iex> master = ExtendedKey.master(seed)
    iex> BsvRpc.PrivateKey.create(master)
    %BsvRpc.PrivateKey{
      key: <<200, 39, 129, 91, 180, 166, 106, 96, 75, 145, 229, 79, 107, 38, 116, 240, 56, 93, 12,
        228, 63, 254, 128, 211, 54, 156, 181, 205, 21, 189, 1, 152>>,
      network: :mainnet,
    }
  """
  def create(%ExtendedKey{} = key) do
    %__MODULE__{
      key: key.key,
      network: ExtendedKey.network(key)
    }
  end
end
