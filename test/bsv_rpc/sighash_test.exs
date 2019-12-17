defmodule BsvRpc.SighashTest do
  use ExUnit.Case
  doctest BsvRpc.Sighash

  @cases [
    {[:sighash_all, :sighash_forkid], 0x41},
    {[:sighash_none, :sighash_forkid], 0x42},
    {[:sighash_single, :sighash_forkid], 0x43},
    {[:sighash_all, :sighash_forkid, :sighash_anyonecanpay], 0xC1},
    {[:sighash_none, :sighash_forkid, :sighash_anyonecanpay], 0xC2},
    {[:sighash_single, :sighash_forkid, :sighash_anyonecanpay], 0xC3},
    {[:sighash_all], 0x01},
    {[:sighash_none], 0x02},
    {[:sighash_single], 0x03},
    {[:sighash_all, :sighash_anyonecanpay], 0x81},
    {[:sighash_none, :sighash_anyonecanpay], 0x82},
    {[:sighash_single, :sighash_anyonecanpay], 0x83}
  ]

  test "test get_sighash_suffix/1" do
    Enum.each(
      @cases,
      fn {sighash_type, expected_suffix} ->
        assert expected_suffix == BsvRpc.Sighash.get_sighash_suffix(sighash_type)
      end
    )
  end

  test "currently unsupported sighash types" do
    {:ok, k} =
      ExtendedKey.from_string(
        "xprv9s21ZrQH143K42Wyfo4GvDT1QBNSgq5sCBPXr4zaftZr2WKCrgEzdtniz5TvRgXA6V8hi2QrUMG3QTQnqovLp2UBAqsDcaxDUP3YCA61rJV"
      )
      |> BsvRpc.PrivateKey.create()

    tx =
      BsvRpc.Transaction.create_from_hex!(
        "0100000001040800A41008F4C353626694DAC1EE5553FBD36B11AC5647528E29C7D6C89BE20000000000FFFFFFFF0200F90295000000001976A9141D7C7B4894BE23A6495B004157F3A1BBA173C52988AC0CF70295000000001976A9141D7C7B4894BE23A6495B004157F3A1BBA173C52988AC00000000"
      )

    [tx_in | _] = tx.inputs

    utxo = %BsvRpc.UTXO{
      script_pubkey: Base.decode16!("76A9141D7C7B4894BE23A6495B004157F3A1BBA173C52988AC"),
      value: 5_000_000_000,
      transaction: <<>>,
      output: 0
    }

    [_supported | unsupported] = @cases

    Enum.each(
      unsupported,
      fn sighash_type ->
        assert_raise RuntimeError, fn ->
          BsvRpc.Sighash.sighash(tx_in, tx, k, utxo, sighash_type)
        end
      end
    )
  end
end
