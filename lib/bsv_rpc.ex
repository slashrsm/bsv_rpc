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

  @doc ~S"""
  Lists wallet accounts.

  Args:
    * `minconf` - (Optional) Only include transactions with at least this many transactions.
    * `include_watchonly` - (Optional) Include watch-only addreses.
  """
  @spec list_accounts(integer, boolean) :: map()
  def list_accounts(minconf \\ 1, include_watchonly \\ false) do
    GenServer.call(BsvRpc, {:call_endpoint, "listaccounts", [minconf, include_watchonly]})
  end

  @doc ~S"""
  Gets wallet balance.

  Args:
    * `account` - (Deprecated, Optional) The account name to get balance for.
    * `minconf` - (Optional) Only include transactions with at least this many transactions.
    * `include_watchonly` - (Optional) Also include balance in watch-only addresses.
  """
  @spec get_balance(String.t(), integer, boolean) :: float
  def get_balance(account, minconf, include_watchonly) do
    GenServer.call(BsvRpc, {:call_endpoint, "getbalance", [account, minconf, include_watchonly]})
  end

  @spec get_balance() :: float
  def get_balance() do
    GenServer.call(BsvRpc, {:call_endpoint, "getbalance"})
  end

  @doc ~S"""
  Gets wallet unconfirmed balance.
  """
  @spec get_unconfirmed_balance() :: float
  def get_unconfirmed_balance() do
    GenServer.call(BsvRpc, {:call_endpoint, "getunconfirmedbalance"})
  end
end
