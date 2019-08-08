defmodule BsvRpc do
  @moduledoc """
  Documentation for BsvRpc.
  """

  @doc ~S"""
  Returns node state info.
  """
  @spec get_info :: map()
  def get_info() do
    GenServer.call(BsvRpc, {:call_endpoint, "getinfo"})
  end
end
