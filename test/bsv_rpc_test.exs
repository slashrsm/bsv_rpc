defmodule BsvRpcTest do
  use ExUnit.Case
  import Mock
  doctest BsvRpc

  test_with_mock "genserver is called for get_info", _context, GenServer, [],
    call: fn _module, _context ->
      %{
        "balance" => 0.0,
        "blocks" => 595_000,
        "connections" => 10,
        "difficulty" => 156_495_202_461.7814,
        "errors" => "",
        "keypoololdest" => 0,
        "keypoolsize" => 2000,
        "maxblocksize" => 2_000_000_000,
        "maxminedblocksize" => 128_000_000,
        "paytxfee" => 0.0,
        "protocolversion" => 70015,
        "proxy" => "",
        "relayfee" => 1.0e-5,
        "stn" => false,
        "testnet" => false,
        "timeoffset" => 0,
        "version" => 100_020_100,
        "walletversion" => 160_300
      }
    end do
    info = BsvRpc.get_info()
    assert info["balance"] == 0.0

    assert called(GenServer.call(BsvRpc, {:call_endpoint, "getinfo"}))
  end

  test_with_mock "genserver is called for get_memory_info", _context, GenServer, [],
    call: fn _module, _context ->
      %{
        "locked" => %{
          "chunks_free" => 8,
          "chunks_used" => 2004,
          "free" => 263_552,
          "locked" => 327_680,
          "total" => 327_680,
          "used" => 64128
        },
        "preloading" => %{"chainStateCached" => 100}
      }
    end do
    info = BsvRpc.get_memory_info()
    assert info["preloading"]["chainStateCached"] == 100
    assert info["locked"]["free"] == 263_552

    assert called(GenServer.call(BsvRpc, {:call_endpoint, "getmemoryinfo"}))
  end

  test_with_mock "genserver is called for uptime", _context, GenServer, [],
    call: fn _module, _context -> 158_535 end do
    assert BsvRpc.uptime() == 158_535
    assert called(GenServer.call(BsvRpc, {:call_endpoint, "uptime"}))
  end

  test_with_mock "genserver is called for stop", _context, GenServer, [],
    call: fn _module, _context -> "Bitcoin server stopping" end do
    assert BsvRpc.stop() == "Bitcoin server stopping"
    assert called(GenServer.call(BsvRpc, {:call_endpoint, "stop"}))
  end

  test_with_mock "genserver is called for get_wallet_info", _context, GenServer, [],
    call: fn _module, _context ->
      %{
        "balance" => 0.0,
        "hdmasterkeyid" => "somekey",
        "immature_balance" => 0.0,
        "keypoololdest" => 1_565_036_155,
        "keypoolsize" => 1000,
        "keypoolsize_hd_internal" => 1000,
        "paytxfee" => 0.0,
        "txcount" => 245,
        "unconfirmed_balance" => 0.0,
        "walletname" => "wallet.dat",
        "walletversion" => 160_300
      }
    end do
    info = BsvRpc.get_wallet_info()
    assert info["balance"] == 0.0
    assert info["hdmasterkeyid"] == "somekey"

    assert called(GenServer.call(BsvRpc, {:call_endpoint, "getwalletinfo"}))
  end

  test_with_mock "genserver is called for list_accounts", _context, GenServer, [],
    call: fn _module, _context -> %{"account_1" => 0.0} end do
    assert BsvRpc.list_accounts(3, true)["account_1"] == 0.0
    assert called(GenServer.call(BsvRpc, {:call_endpoint, "listaccounts", [3, true]}))
  end

  test_with_mock "default params for list_accounts", _context, GenServer, [],
    call: fn _module, _context -> %{"account_1" => 0.0} end do
    assert BsvRpc.list_accounts()["account_1"] == 0.0
    assert called(GenServer.call(BsvRpc, {:call_endpoint, "listaccounts", [1, false]}))
  end

  test_with_mock "genserver is called for get_balance", _context, GenServer, [],
    call: fn _module, _context -> 123.456 end do
    assert BsvRpc.get_balance("foo", 5, true) == 123.456
    assert called(GenServer.call(BsvRpc, {:call_endpoint, "getbalance", ["foo", 5, true]}))
  end

  test_with_mock "default params for get_balance", _context, GenServer, [],
    call: fn _module, _context -> 123.456 end do
    assert BsvRpc.get_balance() == 123.456
    assert called(GenServer.call(BsvRpc, {:call_endpoint, "getbalance"}))
  end

  test_with_mock "genserver is called for get_unconfirmed_balance", _context, GenServer, [],
    call: fn _module, _context -> 123.456 end do
    assert BsvRpc.get_unconfirmed_balance() == 123.456
    assert called(GenServer.call(BsvRpc, {:call_endpoint, "getunconfirmedbalance"}))
  end

  test_with_mock "genserver is called for get_new_address", _context, GenServer, [],
    call: fn _module, _context -> "someaddress" end do
    assert BsvRpc.get_new_address("foo") == "someaddress"
    assert called(GenServer.call(BsvRpc, {:call_endpoint, "getnewaddress", ["foo"]}))
  end

  test_with_mock "default params for get_new_address", _context, GenServer, [],
    call: fn _module, _context -> "someaddress" end do
    assert BsvRpc.get_new_address() == "someaddress"
    assert called(GenServer.call(BsvRpc, {:call_endpoint, "getnewaddress"}))
  end

  test_with_mock "genserver is called for get_addresses_by_account", _context, GenServer, [],
    call: fn _module, _context -> ["someaddress"] end do
    assert BsvRpc.get_addresses_by_account("foo") == ["someaddress"]
    assert called(GenServer.call(BsvRpc, {:call_endpoint, "getaddressesbyaccount", ["foo"]}))
  end

  test_with_mock "genserver is called for get_addresses", _context, GenServer, [],
    call: fn _module, _context -> ["someaddress"] end do
    assert BsvRpc.get_addresses() == ["someaddress"]
    assert called(GenServer.call(BsvRpc, {:call_endpoint, "getaddressesbyaccount", [""]}))
  end
end
