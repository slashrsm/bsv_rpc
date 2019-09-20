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
end
