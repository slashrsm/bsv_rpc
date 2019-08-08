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
end
