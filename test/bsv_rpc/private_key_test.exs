defmodule BsvRpc.PrivateKeyTest do
  use ExUnit.Case
  doctest BsvRpc.PrivateKey

  # TODO Add more tests.

  test "too short key" do
    assert {:error, "Private key must be 32 bytes."} ==
             BsvRpc.PrivateKey.create(
               <<18, 178, 65, 32, 134, 45, 30, 1, 67, 228, 110, 223, 142, 202, 105, 135>>,
               :mainnet
             )
  end

  test "too long key" do
    assert {:error, "Private key must be 32 bytes."} ==
             BsvRpc.PrivateKey.create(
               <<200, 39, 129, 91, 180, 166, 106, 96, 75, 145, 229, 79, 107, 38, 116, 240, 56, 93,
                 12, 228, 63, 254, 128, 211, 54, 156, 181, 205, 21, 189, 1, 152, 18, 178, 65, 32,
                 134, 45, 30, 1, 67, 228, 110, 223, 142, 202, 105, 135>>,
               :mainnet
             )
  end
end
