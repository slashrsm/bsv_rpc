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
end
