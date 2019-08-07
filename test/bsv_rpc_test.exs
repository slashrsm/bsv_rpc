defmodule BsvRpcTest do
  use ExUnit.Case
  doctest BsvRpc

  test "greets the world" do
    assert BsvRpc.hello() == :world
  end
end
