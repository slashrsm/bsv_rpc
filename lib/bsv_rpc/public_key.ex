defmodule BsvRpc.PublicKey do
  # TODO Move to a separate library?
  @moduledoc """
  Function for Bitcoin public key manipulation.

  A public key struct can be created using `BsvRpc.PrivateKey.create/1`:

    iex> BsvRpc.PublicKey.create(<<3, 56, 201, 189, 255, 96, 60, 207, 74, 104, 151, 220, 159, 3, 155, 27, 1, 50, 33, 253, 125, 240, 201, 9, 55, 77, 5, 200, 44, 30, 112, 6, 104>>)
    {:ok,
      %BsvRpc.PublicKey{
        key: <<56, 201, 189, 255, 96, 60, 207, 74, 104, 151,
          220, 159, 3, 155, 27, 1, 50, 33, 253, 125, 240, 201, 9,
          55, 77, 5, 200, 44, 30, 112, 6, 104>>,
        compressed: true,
      }
    }

  or from a HD extended key:

    iex> key = ExtendedKey.from_string("xpub6934X9tFysrrNCTyWyFPkXPJRRY6r32gBYxAdaXCqqMhoPTEiwU9dxx4Hyc3PURqGE2sZBVq5m6gAYdr9cJoqZfB4vxZ4iFAtDNmacdccDn")
    iex> BsvRpc.PublicKey.create(key)
    {:ok,
      %BsvRpc.PublicKey{
        key: <<56, 201, 189, 255, 96, 60, 207, 74, 104, 151,
          220, 159, 3, 155, 27, 1, 50, 33, 253, 125, 240, 201, 9,
          55, 77, 5, 200, 44, 30, 112, 6, 104>>,
        compressed: true,
      }
    }

  """

  @enforce_keys [:key, :compressed]

  @typedoc """
  A public key.
  """
  defstruct [:key, :compressed]

  @type t :: %__MODULE__{
          key: binary,
          compressed: boolean
        }

  @doc """
  Creates a public key.

  ## Examples
    iex> BsvRpc.PublicKey.create(<<3, 56, 201, 189, 255, 96, 60, 207, 74, 104, 151, 220, 159, 3, 155, 27, 1, 50, 33, 253, 125, 240, 201, 9, 55, 77, 5, 200, 44, 30, 112, 6, 104>>)
    {:ok,
      %BsvRpc.PublicKey{
        key: <<56, 201, 189, 255, 96, 60, 207, 74, 104, 151,
          220, 159, 3, 155, 27, 1, 50, 33, 253, 125, 240, 201, 9,
          55, 77, 5, 200, 44, 30, 112, 6, 104>>,
        compressed: true,
      }
    }

    iex> BsvRpc.PublicKey.create("0338C9BDFF603CCF4A6897DC9F039B1B013221FD7DF0C909374D05C82C1E700668")
    {:ok,
      %BsvRpc.PublicKey{
        key: <<56, 201, 189, 255, 96, 60, 207, 74, 104, 151,
          220, 159, 3, 155, 27, 1, 50, 33, 253, 125, 240, 201, 9,
          55, 77, 5, 200, 44, 30, 112, 6, 104>>,
        compressed: true,
      }
    }

    iex> key = ExtendedKey.from_string("xpub6934X9tFysrrNCTyWyFPkXPJRRY6r32gBYxAdaXCqqMhoPTEiwU9dxx4Hyc3PURqGE2sZBVq5m6gAYdr9cJoqZfB4vxZ4iFAtDNmacdccDn")
    iex> BsvRpc.PublicKey.create(key)
    {:ok,
      %BsvRpc.PublicKey{
        key: <<56, 201, 189, 255, 96, 60, 207, 74, 104, 151,
          220, 159, 3, 155, 27, 1, 50, 33, 253, 125, 240, 201, 9,
          55, 77, 5, 200, 44, 30, 112, 6, 104>>,
        compressed: true,
      }
    }

    iex> private_key = BsvRpc.PrivateKey.create(<<200, 39, 129, 91, 180, 166, 106, 96, 75, 145, 229, 79, 107, 38, 116, 240, 56, 93, 12, 228, 63, 254, 128, 211, 54, 156, 181, 205, 21, 189, 1, 152>>, :mainnet)
    iex> BsvRpc.PublicKey.create(private_key)
    {:ok,
      %BsvRpc.PublicKey{
        compressed: true,
        key: <<183, 111, 145, 38, 78, 222, 62, 195, 48, 106, 251, 83, 155, 93, 59,
          103, 42, 238, 116, 82, 249, 208, 96, 17, 197, 143, 28, 113, 73, 47, 108,
          33>>
      }
    }
  """
  @spec create(binary | ExtendedKey.key()) :: {:ok, __MODULE__.t()} | {:error, String.t()}
  def create(%BsvRpc.PrivateKey{key: key}) do
    case :libsecp256k1.ec_pubkey_create(key, :compressed) do
      {:error, reason} ->
        {:error, "Unable to create public key: " <> to_string(reason)}

      {:ok, public_key} ->
        create(public_key)
    end
  end

  def create(%ExtendedKey{} = key) do
    create(key.key)
  end

  def create(<<0x03, key::binary>>) do
    {:ok,
     %__MODULE__{
       compressed: true,
       key: key
     }}
  end

  def create(<<0x02, key::binary>>) do
    {:ok,
     %__MODULE__{
       compressed: true,
       key: key
     }}
  end

  def create(<<0x04, key::binary>>) do
    {:ok,
     %__MODULE__{
       compressed: false,
       key: key
     }}
  end

  def create(key) do
    case Base.decode16(key, case: :mixed) do
      {:ok, decoded_key} ->
        create(decoded_key)

      :error ->
        {:error, "Could not decode private key."}
    end
  end
end
