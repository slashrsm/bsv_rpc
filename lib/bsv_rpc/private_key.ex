defmodule BsvRpc.PrivateKey do
  # TODO Move to a separate library?
  @moduledoc """
  Function for Bitcoin private key manipulation.

  A private key struct can be created using `BsvRpc.PrivateKey.create/2`:

    iex> BsvRpc.PrivateKey.create(<<200, 39, 129, 91, 180, 166, 106, 96, 75, 145, 229, 79, 107, 38, 116, 240, 56, 93, 12, 228, 63, 254, 128, 211, 54, 156, 181, 205, 21, 189, 1, 152>>, :mainnet)
    {:ok,
      %BsvRpc.PrivateKey{
        key: <<200, 39, 129, 91, 180, 166, 106, 96, 75, 145, 229, 79, 107, 38, 116, 240, 56,
          93, 12, 228, 63, 254, 128, 211, 54, 156, 181, 205, 21, 189, 1, 152>>,
        network: :mainnet,
      }
    }

  or from a HD extended key using `BsvRpc.PrivateKey.create/1`:

    iex> words = "battle reunion keep inflict pair speed parade piece chimney leisure fiber miracle survey parade drift grocery lumber pumpkin pretty utility help party board turkey"
    iex> seed = Mnemonic.to_seed(words, "", :english)
    iex> master = ExtendedKey.master(seed)
    iex> BsvRpc.PrivateKey.create(master)
    {:ok,
      %BsvRpc.PrivateKey{
        key: <<200, 39, 129, 91, 180, 166, 106, 96, 75, 145, 229, 79, 107, 38, 116, 240, 56, 93, 12,
          228, 63, 254, 128, 211, 54, 156, 181, 205, 21, 189, 1, 152>>,
        network: :mainnet,
      }
    }
  """

  @enforce_keys [:key, :network]

  @typedoc """
  A private key.
  """
  defstruct [:key, :network]

  @type t :: %__MODULE__{
          key: binary,
          network: :mainnet | :testnet
        }

  @doc """
  Creates a private key.

  ## Examples
    iex> BsvRpc.PrivateKey.create(<<200, 39, 129, 91, 180, 166, 106, 96, 75, 145, 229, 79, 107, 38, 116, 240, 56, 93, 12, 228, 63, 254, 128, 211, 54, 156, 181, 205, 21, 189, 1, 152>>, :mainnet)
    {:ok,
      %BsvRpc.PrivateKey{
        key: <<200, 39, 129, 91, 180, 166, 106, 96, 75, 145, 229, 79, 107, 38, 116, 240, 56,
          93, 12, 228, 63, 254, 128, 211, 54, 156, 181, 205, 21, 189, 1, 152>>,
        network: :mainnet,
      }
    }

    iex> BsvRpc.PrivateKey.create("C827815BB4A66A604B91E54F6B2674F0385D0CE43FFE80D3369CB5CD15BD0198", :mainnet)
    {:ok,
      %BsvRpc.PrivateKey{
        key: <<200, 39, 129, 91, 180, 166, 106, 96, 75, 145, 229, 79, 107, 38, 116, 240, 56,
          93, 12, 228, 63, 254, 128, 211, 54, 156, 181, 205, 21, 189, 1, 152>>,
        network: :mainnet,
      }
    }
  """
  @spec create(binary, :mainnet | :testnet) :: {:ok, __MODULE__.t()} | {:error, String.t()}
  def create(key, network) when is_binary(key) do
    key =
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

    if byte_size(key.key) == 32 do
      {:ok, key}
    else
      {:error, "Private key must be 32 bytes."}
    end
  end

  @doc """
  Creates a private key.

  Works similar to `create/2` with the exception being thrown in case of an error.

  ## Examples
    iex> BsvRpc.PrivateKey.create!(<<200, 39, 129, 91, 180, 166, 106, 96, 75, 145, 229, 79, 107, 38, 116, 240, 56, 93, 12, 228, 63, 254, 128, 211, 54, 156, 181, 205, 21, 189, 1, 152>>, :mainnet)
    %BsvRpc.PrivateKey{
      key: <<200, 39, 129, 91, 180, 166, 106, 96, 75, 145, 229, 79, 107, 38, 116, 240, 56,
        93, 12, 228, 63, 254, 128, 211, 54, 156, 181, 205, 21, 189, 1, 152>>,
      network: :mainnet,
    }

    iex> BsvRpc.PrivateKey.create!("C827815BB4A66A604B91E54F6B2674F0385D0CE43FFE80D3369CB5CD15BD0198", :mainnet)
    %BsvRpc.PrivateKey{
      key: <<200, 39, 129, 91, 180, 166, 106, 96, 75, 145, 229, 79, 107, 38, 116, 240, 56,
        93, 12, 228, 63, 254, 128, 211, 54, 156, 181, 205, 21, 189, 1, 152>>,
      network: :mainnet,
    }
  """
  @spec create!(binary, :mainnet | :testnet) :: __MODULE__.t()
  def create!(key, network) when is_binary(key) do
    case create(key, network) do
      {:ok, private_key} -> private_key
      {:error, reason} -> raise reason
    end
  end

  @doc """
  Creates a private key from a HD extended key.

  ## Examples
    iex> words = "battle reunion keep inflict pair speed parade piece chimney leisure fiber miracle survey parade drift grocery lumber pumpkin pretty utility help party board turkey"
    iex> seed = Mnemonic.to_seed(words, "", :english)
    iex> master = ExtendedKey.master(seed)
    iex> BsvRpc.PrivateKey.create(master)
    {:ok,
      %BsvRpc.PrivateKey{
        key: <<200, 39, 129, 91, 180, 166, 106, 96, 75, 145, 229, 79, 107, 38, 116, 240, 56, 93, 12,
          228, 63, 254, 128, 211, 54, 156, 181, 205, 21, 189, 1, 152>>,
        network: :mainnet,
      }
    }
  """
  @spec create(ExtendedKey.key()) :: {:ok, __MODULE__.t()}
  def create(%ExtendedKey{} = key) do
    {:ok,
     %__MODULE__{
       key: key.key,
       network: ExtendedKey.network(key)
     }}
  end

  @doc """
  Creates a private key from a HD extended key.

  Works similar to `create/1` with the exception being thrown in case of an error.

  ## Examples
    iex> words = "battle reunion keep inflict pair speed parade piece chimney leisure fiber miracle survey parade drift grocery lumber pumpkin pretty utility help party board turkey"
    iex> seed = Mnemonic.to_seed(words, "", :english)
    iex> master = ExtendedKey.master(seed)
    iex> BsvRpc.PrivateKey.create!(master)
    %BsvRpc.PrivateKey{
      key: <<200, 39, 129, 91, 180, 166, 106, 96, 75, 145, 229, 79, 107, 38, 116, 240, 56, 93, 12,
        228, 63, 254, 128, 211, 54, 156, 181, 205, 21, 189, 1, 152>>,
      network: :mainnet,
    }
  """
  @spec create!(ExtendedKey.key()) :: __MODULE__.t()
  def create!(key) do
    create(key) |> elem(1)
  end
end
