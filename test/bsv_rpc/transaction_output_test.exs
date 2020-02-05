defmodule BsvRpc.TransactionOutputTest do
  use ExUnit.Case
  doctest BsvRpc.TransactionOutput

  test "find_data_output!/1 finds legacy data outputs" do
    assert 1 ==
             BsvRpc.TransactionOutput.find_data_output!([
               %BsvRpc.TransactionOutput{
                 value: 456,
                 script_pubkey: <<0xFF>>
               },
               %BsvRpc.TransactionOutput{
                 value: 123,
                 script_pubkey: <<0x6A, 0xFF>>
               }
             ])
  end

  test "find_data_output/1 finds legacy data outputs" do
    assert {:ok, 1} ==
             BsvRpc.TransactionOutput.find_data_output([
               %BsvRpc.TransactionOutput{
                 value: 456,
                 script_pubkey: <<0xFF>>
               },
               %BsvRpc.TransactionOutput{
                 value: 123,
                 script_pubkey: <<0x6A, 0xFF>>
               }
             ])
  end
end
