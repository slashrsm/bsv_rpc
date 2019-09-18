defmodule BsvRpc.PublicKeyTest do
  use ExUnit.Case
  doctest BsvRpc.PublicKey

  # TODO Add more tests.

  test "compressed public key" do
    {:ok, key} =
      BsvRpc.PublicKey.create(
        "02a1633cafcc01ebfb6d78e39f687a1f0995c62fc95f51ead10a02ee0be551b5dc"
      )

    assert %BsvRpc.PublicKey{
             compressed: true,
             key:
               <<161, 99, 60, 175, 204, 1, 235, 251, 109, 120, 227, 159, 104, 122, 31, 9, 149,
                 198, 47, 201, 95, 81, 234, 209, 10, 2, 238, 11, 229, 81, 181, 220>>
           } == key
  end

  test "uncompressed public key" do
    {:ok, key} =
      BsvRpc.PublicKey.create(
        "041ff0fe0f7b15ffaa85ff9f4744d539139c252a49710fb053bb9f2b933173ff9a7baad41d04514751e6851f5304fd243751703bed21b914f6be218c0fa354a341"
      )

    assert %BsvRpc.PublicKey{
             compressed: false,
             key:
               <<31, 240, 254, 15, 123, 21, 255, 170, 133, 255, 159, 71, 68, 213, 57, 19, 156, 37,
                 42, 73, 113, 15, 176, 83, 187, 159, 43, 147, 49, 115, 255, 154, 123, 170, 212,
                 29, 4, 81, 71, 81, 230, 133, 31, 83, 4, 253, 36, 55, 81, 112, 59, 237, 33, 185,
                 20, 246, 190, 33, 140, 15, 163, 84, 163, 65>>
           } == key
  end

  test "unable to decode" do
    assert {:error, "Could not decode public key."} == BsvRpc.PublicKey.create("foobarbaz")
  end

  test "from invalid private key" do
    pk = %BsvRpc.PrivateKey{
      key: <<18, 178, 65, 32, 134, 45, 30, 1, 67, 228, 110, 223, 142, 202, 105, 135>>,
      network: :mainnet
    }

    assert {:error, "Unable to create public key: Private key size not 32 bytes"} ==
             BsvRpc.PublicKey.create(pk)
  end
end
