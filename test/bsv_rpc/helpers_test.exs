defmodule BsvRpc.HelpersTest do
  use ExUnit.Case
  doctest BsvRpc.Helpers

  # TODO
  # - Test to_varlen_data() with longer payloads

  test "to_pushdata/1 with longer payloads" do
    <<0x4C, 0x4F, rest::binary>> = BsvRpc.Helpers.to_pushdata(:crypto.strong_rand_bytes(0x4F))
    assert 0x4F == byte_size(rest)

    <<0x4D, 0x01, 0xFF, rest::binary>> =
      BsvRpc.Helpers.to_pushdata(:crypto.strong_rand_bytes(0xFF01))

    assert 0xFF01 == byte_size(rest)

    <<0x4E, 0x01, 0xFF, 0xFF, 0x00, rest::binary>> =
      BsvRpc.Helpers.to_pushdata(:crypto.strong_rand_bytes(0xFFFF01))

    assert 0xFFFF01 == byte_size(rest)
  end
end
