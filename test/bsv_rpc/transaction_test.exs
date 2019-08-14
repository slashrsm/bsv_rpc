defmodule BsvRpc.TransactionTest do
  use ExUnit.Case
  import Mock
  doctest BsvRpc.Transaction

  test "create a transaction with change" do
    {:ok, to} = BsvRpc.Address.create("1wBQpttZsiMtrwgjp2NuGNEyBMPdnzCeA")
    {:ok, change} = BsvRpc.Address.create("18v4ZTwZAkk7HKECkfutns1bfGVehaXNkW")

    utxos = [
      %BsvRpc.UTXO{
        transaction:
          Base.decode16!("4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E2CC77AB2127B7AFDEDA33B"),
        output: 0,
        value: 5_000_000_000
      }
    ]

    {:ok, tx} = BsvRpc.Transaction.send_to(to, 4_000_000_000, utxos, change)

    assert 1 == tx.version
    assert 0 == tx.locktime

    [input | rest] = tx.inputs
    assert [] == rest
    assert 0 == input.previous_output

    assert <<74, 94, 30, 75, 170, 184, 159, 58, 50, 81, 138, 136, 195, 27, 200, 127, 97, 143, 118,
             103, 62, 44, 199, 122, 178, 18, 123, 122, 253, 237, 163,
             59>> == input.previous_transaction

    assert "" == input.script_sig
    assert 0xFFFFFFFF == input.sequence

    [output | [change_output | rest]] = tx.outputs
    assert [] == rest
    assert 4_000_000_000 == output.value

    assert <<118, 169, 20, 10, 63, 39, 5, 95, 134, 238, 22, 182, 35, 80, 229, 135, 46, 13, 197, 9,
             176, 72, 193, 136, 172>> == output.script_pubkey

    assert 999_999_772 == change_output.value

    assert <<118, 169, 20, 86, 209, 229, 225, 200, 165, 160, 64, 184, 37, 55, 2, 13, 124, 118,
             184, 15, 15, 111, 242, 136, 172>> == change_output.script_pubkey
  end

  test "create a transaction without change" do
    {:ok, to} = BsvRpc.Address.create("1wBQpttZsiMtrwgjp2NuGNEyBMPdnzCeA")
    {:ok, change} = BsvRpc.Address.create("18v4ZTwZAkk7HKECkfutns1bfGVehaXNkW")

    utxos = [
      %BsvRpc.UTXO{
        transaction:
          Base.decode16!("4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E2CC77AB2127B7AFDEDA33B"),
        output: 0,
        value: 5_000_000_000
      }
    ]

    {:ok, tx} = BsvRpc.Transaction.send_to(to, 4_999_999_770, utxos, change)

    assert 1 == tx.version
    assert 0 == tx.locktime

    [input | rest] = tx.inputs
    assert [] == rest
    assert 0 == input.previous_output

    assert <<74, 94, 30, 75, 170, 184, 159, 58, 50, 81, 138, 136, 195, 27, 200, 127, 97, 143, 118,
             103, 62, 44, 199, 122, 178, 18, 123, 122, 253, 237, 163,
             59>> == input.previous_transaction

    assert "" == input.script_sig
    assert 0xFFFFFFFF == input.sequence

    [output | rest] = tx.outputs
    assert [] == rest
    assert 4_999_999_770 == output.value

    assert <<118, 169, 20, 10, 63, 39, 5, 95, 134, 238, 22, 182, 35, 80, 229, 135, 46, 13, 197, 9,
             176, 72, 193, 136, 172>> == output.script_pubkey
  end

  test "create a transaction with insufficient funds" do
    {:ok, to} = BsvRpc.Address.create("1wBQpttZsiMtrwgjp2NuGNEyBMPdnzCeA")
    {:ok, change} = BsvRpc.Address.create("18v4ZTwZAkk7HKECkfutns1bfGVehaXNkW")

    utxos = [
      %BsvRpc.UTXO{
        transaction:
          Base.decode16!("4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E2CC77AB2127B7AFDEDA33B"),
        output: 0,
        value: 5_000_000_000
      }
    ]

    {:error, "Insufficient funds."} = BsvRpc.Transaction.send_to(to, 5_000_000_000, utxos, change)
  end

  test "create a transaction with custom fee" do
    {:ok, to} = BsvRpc.Address.create("1wBQpttZsiMtrwgjp2NuGNEyBMPdnzCeA")
    {:ok, change} = BsvRpc.Address.create("18v4ZTwZAkk7HKECkfutns1bfGVehaXNkW")

    utxos = [
      %BsvRpc.UTXO{
        transaction:
          Base.decode16!("4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E2CC77AB2127B7AFDEDA33B"),
        output: 0,
        value: 5_000_000_000
      }
    ]

    {:ok, tx} = BsvRpc.Transaction.send_to(to, 4_000_000_000, utxos, change, 2)

    [output | [change_output | rest]] = tx.outputs
    assert [] == rest
    assert 4_000_000_000 == output.value

    assert <<118, 169, 20, 10, 63, 39, 5, 95, 134, 238, 22, 182, 35, 80, 229, 135, 46, 13, 197, 9,
             176, 72, 193, 136, 172>> == output.script_pubkey

    assert 999_999_544 == change_output.value

    assert <<118, 169, 20, 86, 209, 229, 225, 200, 165, 160, 64, 184, 37, 55, 2, 13, 124, 118,
             184, 15, 15, 111, 242, 136, 172>> == change_output.script_pubkey
  end

  test_with_mock "fee is calculated correclty", _context, GenServer, [],
    call: fn _module, _context ->
      "01000000024fc9d5b1142f83a9778c2d0ff054c83d95b68bbb569020dab23dc76223304a0b010000006b483045022100a07d6a99d87b327574c4398248f4890a36dad4011b602b488d14aa2dbdbf2ace02204570a0f4d9075f34acb65c0caf62d7e1daca1d8311e6840778376b8a4c3e5e6f4121035773e636bc13ebe9f49dc077dce4c9c5e18168133123352d7957159f8e3a8d54ffffffff2ef1e20c17130d20660728f89e10ae8fdd4ddb83832034fa16268b3aa83d3ad4010000006b483045022100908e7ccd4ce12419cb3c618bbc7121eea0036aa6c4ac250b15a42eb84fb99d72022032b4ff69fd16007ed8be1299835e4581bfafe59d09e88521481dd718d35c0aee412103b350536efa8a004a50369a02ae1b04ebf5855456d35a18c4115b808057d168beffffffff02c0cf6a000000000017a914690f0f15d469ec9d6e7f4346d76fe94abac2803787f0071c05000000001976a91456198dbb2c1c991443cd6e297d36f93a927ca77f88ac00000000"
    end do
    tx =
      BsvRpc.Transaction.create(
        Base.decode16!(
          "010000000114F6E0A8242018CEFA4236493377023331E5AB4E981729557A8AAC33A58AD372010000006A47304402202C2605D54CA2FCABA8A75456BEA39C2B2D7AE744F562D06990A449E5F5A3FEBE02200BD37B90DA97D0E69ED2B3F91D82E5D4344564CF5B699AD1AD7F232888C815FC4121037328F4FA4F446697A5984F9173928D5AE5A64CCD58576F3C73E4C794CA759ECCFFFFFFFF02E06735000000000017A914690F0F15D469EC9D6E7F4346D76FE94ABAC28037872D9FE604000000001976A914F249783130CC20934267803DB3C037A21FF9E2DD88AC00000000"
        )
      )

    assert 227 == BsvRpc.Transaction.fee(tx)
  end
end
