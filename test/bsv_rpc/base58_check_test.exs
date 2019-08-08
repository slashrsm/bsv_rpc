defmodule BsvRpc.Base58CheckTest do
  use ExUnit.Case
  doctest BsvRpc.Base58Check

  test "base58check_decode" do
    # Test cases from https://github.com/bitcoin-sv/bitcoin-sv/blob/master/src/test/data/base58_keys_valid.json.
    # First three cases are covered in doctests.
    cases = Poison.decode!(IO.read(File.open!("test/bsv_rpc/base58_keys_valid.json", [:read, :utf8]), :all))
    |> Enum.split(3)
    |> elem(1)

    Enum.each(
      cases,
      fn [str, expected, _options] ->
        assert Base.encode16(BsvRpc.Base58Check.decode(str), case: :lower) == expected
      end
    )
  end
end
