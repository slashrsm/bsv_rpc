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
        "protocolversion" => 70_015,
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
          "used" => 64_128
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
    call: fn _module, _context -> "1AGNa15ZQXAZUgFiqJ2i7Z2DPU2J6hW62i" end do
    assert %BsvRpc.Address{
             address: "1AGNa15ZQXAZUgFiqJ2i7Z2DPU2J6hW62i",
             network: :mainnet,
             type: :pubkey
           } == BsvRpc.get_new_address("foo")

    assert called(GenServer.call(BsvRpc, {:call_endpoint, "getnewaddress", ["foo"]}))
  end

  test_with_mock "default params for get_new_address", _context, GenServer, [],
    call: fn _module, _context -> "1AGNa15ZQXAZUgFiqJ2i7Z2DPU2J6hW62i" end do
    assert %BsvRpc.Address{
             address: "1AGNa15ZQXAZUgFiqJ2i7Z2DPU2J6hW62i",
             network: :mainnet,
             type: :pubkey
           } == BsvRpc.get_new_address()

    assert called(GenServer.call(BsvRpc, {:call_endpoint, "getnewaddress"}))
  end

  test_with_mock "genserver is called for get_addresses_by_account", _context, GenServer, [],
    call: fn _module, _context ->
      ["1AGNa15ZQXAZUgFiqJ2i7Z2DPU2J6hW62i", "1Ax4gZtb7gAit2TivwejZHYtNNLT18PUXJ"]
    end do
    assert [
             %BsvRpc.Address{
               address: "1AGNa15ZQXAZUgFiqJ2i7Z2DPU2J6hW62i",
               network: :mainnet,
               type: :pubkey
             },
             %BsvRpc.Address{
               address: "1Ax4gZtb7gAit2TivwejZHYtNNLT18PUXJ",
               network: :mainnet,
               type: :pubkey
             }
           ] == BsvRpc.get_addresses_by_account("foo")

    assert called(GenServer.call(BsvRpc, {:call_endpoint, "getaddressesbyaccount", ["foo"]}))
  end

  test_with_mock "genserver is called for get_addresses", _context, GenServer, [],
    call: fn _module, _context ->
      ["1AGNa15ZQXAZUgFiqJ2i7Z2DPU2J6hW62i", "1Ax4gZtb7gAit2TivwejZHYtNNLT18PUXJ"]
    end do
    assert [
             %BsvRpc.Address{
               address: "1AGNa15ZQXAZUgFiqJ2i7Z2DPU2J6hW62i",
               network: :mainnet,
               type: :pubkey
             },
             %BsvRpc.Address{
               address: "1Ax4gZtb7gAit2TivwejZHYtNNLT18PUXJ",
               network: :mainnet,
               type: :pubkey
             }
           ] == BsvRpc.get_addresses()

    assert called(GenServer.call(BsvRpc, {:call_endpoint, "getaddressesbyaccount", [""]}))
  end

  test_with_mock "genserver is called for get_transaction", _context, GenServer, [],
    call: fn _module, _context ->
      "010000000114f6e0a8242018cefa4236493377023331e5ab4e981729557a8aac33a58ad372010000006a47304402202c2605d54ca2fcaba8a75456bea39c2b2d7ae744f562d06990a449e5f5a3febe02200bd37b90da97d0e69ed2b3f91d82e5d4344564cf5b699ad1ad7f232888c815fc4121037328f4fa4f446697a5984f9173928d5ae5a64ccd58576f3c73e4c794ca759eccffffffff02e06735000000000017a914690f0f15d469ec9d6e7f4346d76fe94abac28037872d9fe604000000001976a914f249783130cc20934267803db3c037a21ff9e2dd88ac00000000"
    end do
    t = BsvRpc.get_transaction("2de56313f760c3a81cfbac22e7cc34958c2a7a8d6c739aa8861f65e42692669d")
    assert 223 == t.size
    assert 1 == t.version
    assert 0 == t.locktime
    assert 1 == length(t.inputs)
    assert 2 == length(t.outputs)

    assert "2DE56313F760C3A81CFBAC22E7CC34958C2A7A8D6C739AA8861F65E42692669D" ==
             Base.encode16(t.hash)

    assert called(
             GenServer.call(
               BsvRpc,
               {:call_endpoint, "getrawtransaction",
                ["2de56313f760c3a81cfbac22e7cc34958c2a7a8d6c739aa8861f65e42692669d"]}
             )
           )
  end

  test_with_mock "genserver is called for list_unspent", _context, GenServer, [],
    call: fn _module, _context ->
      [
        %{
          "account" => "",
          "address" => "1LNEsmx2nr4jtsZqWSpuGBUXngadosczf7",
          "amount" => 0.00156566,
          "confirmations" => 4,
          "safe" => true,
          "scriptPubKey" => "76a914d46eb52cd93941988969f86cb6fcef8b99db103888ac",
          "solvable" => true,
          "spendable" => true,
          "txid" => "b2e068edb272ebfee3306e45f2d2a941e720a3ae884914e3cf5edc49542cdc30",
          "vout" => 1
        }
      ]
    end do
    [utxo | rest] =
      BsvRpc.list_unspent(
        [BsvRpc.Address.create!("1LNEsmx2nr4jtsZqWSpuGBUXngadosczf7")],
        1,
        50,
        false
      )

    assert [] == rest

    assert %BsvRpc.UTXO{
             value: 156_566,
             transaction:
               Base.decode16!("B2E068EDB272EBFEE3306E45F2D2A941E720A3AE884914E3CF5EDC49542CDC30"),
             output: 1,
             script_pubkey:
               <<118, 169, 20, 212, 110, 181, 44, 217, 57, 65, 152, 137, 105, 248, 108, 182, 252,
                 239, 139, 153, 219, 16, 56, 136, 172>>
           } == utxo

    assert called(
             GenServer.call(
               BsvRpc,
               {:call_endpoint, "listunspent",
                [1, 50, ["1LNEsmx2nr4jtsZqWSpuGBUXngadosczf7"], false]}
             )
           )
  end

  test_with_mock "default params for list_unspent", _context, GenServer, [],
    call: fn _module, _context ->
      [
        %{
          "account" => "",
          "address" => "1LNEsmx2nr4jtsZqWSpuGBUXngadosczf7",
          "amount" => 0.00156566,
          "confirmations" => 4,
          "safe" => true,
          "scriptPubKey" => "76a914d46eb52cd93941988969f86cb6fcef8b99db103888ac",
          "solvable" => true,
          "spendable" => true,
          "txid" => "b2e068edb272ebfee3306e45f2d2a941e720a3ae884914e3cf5edc49542cdc30",
          "vout" => 1
        }
      ]
    end do
    [utxo | rest] =
      BsvRpc.list_unspent([BsvRpc.Address.create!("1LNEsmx2nr4jtsZqWSpuGBUXngadosczf7")])

    assert [] == rest

    assert %BsvRpc.UTXO{
             value: 156_566,
             transaction:
               Base.decode16!("B2E068EDB272EBFEE3306E45F2D2A941E720A3AE884914E3CF5EDC49542CDC30"),
             output: 1,
             script_pubkey:
               <<118, 169, 20, 212, 110, 181, 44, 217, 57, 65, 152, 137, 105, 248, 108, 182, 252,
                 239, 139, 153, 219, 16, 56, 136, 172>>
           } == utxo

    assert called(
             GenServer.call(
               BsvRpc,
               {:call_endpoint, "listunspent",
                [1, 9_999_999, ["1LNEsmx2nr4jtsZqWSpuGBUXngadosczf7"], true]}
             )
           )
  end

  test_with_mock "genserver is called for sign_transaction", _context, GenServer, [],
    call: fn _module, _context ->
      %{
        "complete" => true,
        "hex" =>
          "01000000010000000000000000000000000000000000000000000000000000000000000000FFFFFFFF4D04FFFF001D0104455468652054696D65732030332F4A616E2F32303039204368616E63656C6C6F72206F6E206272696E6B206F66207365636F6E64206261696C6F757420666F722062616E6B73FFFFFFFF0100F2052A01000000434104678AFDB0FE5548271967F1A67130B7105CD6A828E03909A67962E0EA1F61DEB649F6BC3F4CEF38C4F35504E51EC112DE5C384DF7BA0B8D578A4C702B6BF11D5FAC00000000"
      }
    end do
    tx =
      Base.decode16!(
        "01000000010000000000000000000000000000000000000000000000000000000000000000FFFFFFFF4D04FFFF001D0104455468652054696D65732030332F4A616E2F32303039204368616E63656C6C6F72206F6E206272696E6B206F66207365636F6E64206261696C6F757420666F722062616E6B73FFFFFFFF0100F2052A01000000434104678AFDB0FE5548271967F1A67130B7105CD6A828E03909A67962E0EA1F61DEB649F6BC3F4CEF38C4F35504E51EC112DE5C384DF7BA0B8D578A4C702B6BF11D5FAC00000000"
      )
      |> BsvRpc.Transaction.create()
      |> BsvRpc.sign_transaction()

    assert "4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E2CC77AB2127B7AFDEDA33B" =
             BsvRpc.Transaction.id(tx)

    assert called(
             GenServer.call(
               BsvRpc,
               {:call_endpoint, "signrawtransaction",
                [
                  "01000000010000000000000000000000000000000000000000000000000000000000000000FFFFFFFF4D04FFFF001D0104455468652054696D65732030332F4A616E2F32303039204368616E63656C6C6F72206F6E206272696E6B206F66207365636F6E64206261696C6F757420666F722062616E6B73FFFFFFFF0100F2052A01000000434104678AFDB0FE5548271967F1A67130B7105CD6A828E03909A67962E0EA1F61DEB649F6BC3F4CEF38C4F35504E51EC112DE5C384DF7BA0B8D578A4C702B6BF11D5FAC00000000"
                ]}
             )
           )
  end

  test_with_mock "genserver is called for broadcast_transaction", _context, GenServer, [],
    call: fn _module, _context ->
      "4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E2CC77AB2127B7AFDEDA33B"
    end do
    tx_hash =
      Base.decode16!(
        "01000000010000000000000000000000000000000000000000000000000000000000000000FFFFFFFF4D04FFFF001D0104455468652054696D65732030332F4A616E2F32303039204368616E63656C6C6F72206F6E206272696E6B206F66207365636F6E64206261696C6F757420666F722062616E6B73FFFFFFFF0100F2052A01000000434104678AFDB0FE5548271967F1A67130B7105CD6A828E03909A67962E0EA1F61DEB649F6BC3F4CEF38C4F35504E51EC112DE5C384DF7BA0B8D578A4C702B6BF11D5FAC00000000"
      )
      |> BsvRpc.Transaction.create()
      |> BsvRpc.broadcast_transaction()

    assert "4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E2CC77AB2127B7AFDEDA33B" = tx_hash

    assert called(
             GenServer.call(
               BsvRpc,
               {:call_endpoint, "sendrawtransaction",
                [
                  "01000000010000000000000000000000000000000000000000000000000000000000000000FFFFFFFF4D04FFFF001D0104455468652054696D65732030332F4A616E2F32303039204368616E63656C6C6F72206F6E206272696E6B206F66207365636F6E64206261696C6F757420666F722062616E6B73FFFFFFFF0100F2052A01000000434104678AFDB0FE5548271967F1A67130B7105CD6A828E03909A67962E0EA1F61DEB649F6BC3F4CEF38C4F35504E51EC112DE5C384DF7BA0B8D578A4C702B6BF11D5FAC00000000"
                ]}
             )
           )
  end
end
