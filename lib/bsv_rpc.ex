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
  def get_info do
    GenServer.call(BsvRpc, {:call_endpoint, "getinfo"})
  end

  @doc ~S"""
  Returns node memory usage info.
  """
  @spec get_memory_info :: map()
  def get_memory_info do
    GenServer.call(BsvRpc, {:call_endpoint, "getmemoryinfo"})
  end

  @doc ~S"""
  Returns the node uptime info.
  """
  @spec uptime :: integer
  def uptime do
    GenServer.call(BsvRpc, {:call_endpoint, "uptime"})
  end

  @doc ~S"""
  Stops the node.
  """
  @spec stop :: String.t()
  def stop do
    GenServer.call(BsvRpc, {:call_endpoint, "stop"})
  end

  ###
  # Wallet
  ###

  @doc ~S"""
  Gets the wallet info.
  """
  @spec get_wallet_info :: map()
  def get_wallet_info do
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
    * `account` - The account name to get balance for.
    * `minconf` - Only include transactions with at least this many transactions.
    * `include_watchonly` - Also include balance in watch-only addresses.
  """
  @spec get_balance(String.t(), integer, boolean) :: float
  def get_balance(account, minconf, include_watchonly) do
    GenServer.call(BsvRpc, {:call_endpoint, "getbalance", [account, minconf, include_watchonly]})
  end

  @doc ~S"""
  Gets server's total balance.
  """
  @spec get_balance :: float
  def get_balance do
    GenServer.call(BsvRpc, {:call_endpoint, "getbalance"})
  end

  @doc ~S"""
  Gets wallet unconfirmed balance.
  """
  @spec get_unconfirmed_balance :: float
  def get_unconfirmed_balance do
    GenServer.call(BsvRpc, {:call_endpoint, "getunconfirmedbalance"})
  end

  @doc ~S"""
  Gets new address.

  Args:
    * `account` - (Deprecated, Optional) The account name to get address for.
  """
  @spec get_new_address(String.t()) :: String.t()
  def get_new_address(account) do
    GenServer.call(BsvRpc, {:call_endpoint, "getnewaddress", [account]})
  end

  @doc ~S"""
  Gets new address for the default account.
  """
  @spec get_new_address :: float
  def get_new_address do
    GenServer.call(BsvRpc, {:call_endpoint, "getnewaddress"})
  end

  @doc ~S"""
  Gets addresses for the account.

  Args:
    * `account` - The account name to get addresses for.
  """
  @spec get_addresses_by_account(String.t()) :: list()
  def get_addresses_by_account(account) do
    GenServer.call(BsvRpc, {:call_endpoint, "getaddressesbyaccount", [account]})
  end

  @doc ~S"""
  Gets addresses for the default account.
  """
  @spec get_addresses :: float
  def get_addresses do
    GenServer.call(BsvRpc, {:call_endpoint, "getaddressesbyaccount", [""]})
  end
end
