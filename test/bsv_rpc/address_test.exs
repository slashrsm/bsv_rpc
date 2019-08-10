defmodule BsvRpc.AddressTest do
  use ExUnit.Case
  doctest BsvRpc.Address

  test "mainnet pubkey address" do
    {:ok, %BsvRpc.Address{address: a, type: t, network: n}} =
      BsvRpc.Address.create("1AGNa15ZQXAZUgFiqJ2i7Z2DPU2J6hW62i")

    assert "1AGNa15ZQXAZUgFiqJ2i7Z2DPU2J6hW62i" == a
    assert :pubkey == t
    assert :mainnet == n

    %BsvRpc.Address{address: a, type: t, network: n} =
      BsvRpc.Address.create!("1AGNa15ZQXAZUgFiqJ2i7Z2DPU2J6hW62i")

    assert "1AGNa15ZQXAZUgFiqJ2i7Z2DPU2J6hW62i" == a
    assert :pubkey == t
    assert :mainnet == n
  end

  test "testnet pubkey address" do
    {:ok, %BsvRpc.Address{address: a, type: t, network: n}} =
      BsvRpc.Address.create("mo9ncXisMeAoXwqcV5EWuyncbmCcQN4rVs")

    assert "mo9ncXisMeAoXwqcV5EWuyncbmCcQN4rVs" == a
    assert :pubkey == t
    assert :testnet == n

    %BsvRpc.Address{address: a, type: t, network: n} =
      BsvRpc.Address.create!("mo9ncXisMeAoXwqcV5EWuyncbmCcQN4rVs")

    assert "mo9ncXisMeAoXwqcV5EWuyncbmCcQN4rVs" == a
    assert :pubkey == t
    assert :testnet == n
  end

  test "mainnet script address" do
    {:ok, %BsvRpc.Address{address: a, type: t, network: n}} =
      BsvRpc.Address.create("3CMNFxN1oHBc4R1EpboAL5yzHGgE611Xou")

    assert "3CMNFxN1oHBc4R1EpboAL5yzHGgE611Xou" == a
    assert :script == t
    assert :mainnet == n

    %BsvRpc.Address{address: a, type: t, network: n} =
      BsvRpc.Address.create!("3CMNFxN1oHBc4R1EpboAL5yzHGgE611Xou")

    assert "3CMNFxN1oHBc4R1EpboAL5yzHGgE611Xou" == a
    assert :script == t
    assert :mainnet == n
  end

  test "testnet script address" do
    {:ok, %BsvRpc.Address{address: a, type: t, network: n}} =
      BsvRpc.Address.create("2N2JD6wb56AfK4tfmM6PwdVmoYk2dCKf4Br")

    assert "2N2JD6wb56AfK4tfmM6PwdVmoYk2dCKf4Br" == a
    assert :script == t
    assert :testnet == n

    %BsvRpc.Address{address: a, type: t, network: n} =
      BsvRpc.Address.create!("2N2JD6wb56AfK4tfmM6PwdVmoYk2dCKf4Br")

    assert "2N2JD6wb56AfK4tfmM6PwdVmoYk2dCKf4Br" == a
    assert :script == t
    assert :testnet == n
  end

  test "invalid address" do
    assert {:error, "Invalid address."} ==
             BsvRpc.Address.create("1AGNa15ZQXAZUgFiqJ2i7Z2DPU2J6HW62i")

    assert_raise MatchError, fn ->
      BsvRpc.Address.create!("1AGNa15ZQXAZUgFiqJ2i7Z2DPU2J6HW62i")
    end
  end
end
