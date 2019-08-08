defmodule BsvRpc do
  @moduledoc """
  Documentation for BsvRpc.
  """

  ###
  # Control
  ###

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

  @doc ~S"""
  Stops the node.
  """
  @spec stop :: String.t()
  def stop() do
    GenServer.call(BsvRpc, {:call_endpoint, "stop"})
  end

  ###
  # Wallet
  ###

  @doc ~S"""
  Gets the wallet info.
  """
  @spec get_wallet_info :: map()
  def get_wallet_info() do
    GenServer.call(BsvRpc, {:call_endpoint, "getwalletinfo"})
  end
end
