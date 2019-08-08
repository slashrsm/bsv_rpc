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

  @doc ~S"""
  Returns node memory usage info.
  """
  @spec get_memory_info :: map()
  def get_memory_info() do
    GenServer.call(BsvRpc, {:call_endpoint, "getmemoryinfo"})
  end

  @doc ~S"""
  Returns the node uptime info.
  """
  @spec uptime :: integer
  def uptime() do
    GenServer.call(BsvRpc, {:call_endpoint, "uptime"})
  end
end
