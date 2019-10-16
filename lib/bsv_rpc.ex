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
  @spec get_info :: {:ok, map()} | {:error, String.t()}
  def get_info do
    GenServer.call(BsvRpc, {:call_endpoint, "getinfo"})
  end

  @doc ~S"""
  Returns node memory usage info.
  """
  @spec get_memory_info :: {:ok, map()} | {:error, String.t()}
  def get_memory_info do
    GenServer.call(BsvRpc, {:call_endpoint, "getmemoryinfo"})
  end

  @doc ~S"""
  Returns the node uptime info.
  """
  @spec uptime :: {:ok, integer} | {:error, String.t()}
  def uptime do
    GenServer.call(BsvRpc, {:call_endpoint, "uptime"})
  end

  @doc ~S"""
  Stops the node.
  """
  @spec stop :: {:ok, String.t()} | {:error, String.t()}
  def stop do
    GenServer.call(BsvRpc, {:call_endpoint, "stop"})
  end

  ###
  # Wallet
  ###

  @doc ~S"""
  Gets the wallet info.
  """
  @spec get_wallet_info :: {:ok, map()} | {:error, String.t()}
  def get_wallet_info do
    GenServer.call(BsvRpc, {:call_endpoint, "getwalletinfo"})
  end

  @doc ~S"""
  Lists wallet accounts.

  Args:
    * `minconf` - (Optional) Only include transactions with at least this many transactions.
    * `include_watchonly` - (Optional) Include watch-only addreses.
  """
  @spec list_accounts(integer, boolean) :: {:ok, map()} | {:error, String.t()}
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
  @spec get_balance(String.t(), integer, boolean) :: {:ok, float} | {:error, String.t()}
  def get_balance(account, minconf, include_watchonly) do
    GenServer.call(BsvRpc, {:call_endpoint, "getbalance", [account, minconf, include_watchonly]})
  end

  @doc ~S"""
  Gets server's total balance.
  """
  @spec get_balance :: {:ok, float} | {:error, String.t()}
  def get_balance do
    GenServer.call(BsvRpc, {:call_endpoint, "getbalance"})
  end

  @doc ~S"""
  Gets wallet unconfirmed balance.
  """
  @spec get_unconfirmed_balance :: {:ok, float} | {:error, String.t()}
  def get_unconfirmed_balance do
    GenServer.call(BsvRpc, {:call_endpoint, "getunconfirmedbalance"})
  end

  @doc ~S"""
  Gets new address.

  Args:
    * `account` - (Deprecated, Optional) The account name to get address for.
  """
  @spec get_new_address(String.t()) :: {:ok, BsvRpc.Address.t()} | {:error, String.t()}
  def get_new_address(account) do
    case GenServer.call(BsvRpc, {:call_endpoint, "getnewaddress", [account]}) do
      {:ok, address} ->
        BsvRpc.Address.create(address)

      error_response ->
        error_response
    end
  end

  @doc ~S"""
  Gets new address for the default account.
  """
  @spec get_new_address :: {:ok, BsvRpc.Address.t()} | {:error, String.t()}
  def get_new_address do
    case GenServer.call(BsvRpc, {:call_endpoint, "getnewaddress"}) do
      {:ok, address} ->
        BsvRpc.Address.create(address)

      error_response ->
        error_response
    end
  end

  @doc ~S"""
  Gets addresses for the account.

  Args:
    * `account` - The account name to get addresses for.
  """
  @spec get_addresses_by_account(String.t()) :: {:ok, [BsvRpc.Address.t()]} | {:error, String.t()}
  def get_addresses_by_account(account) do
    case GenServer.call(BsvRpc, {:call_endpoint, "getaddressesbyaccount", [account]}) do
      {:ok, addresses} ->
        {:ok, Enum.map(addresses, fn address -> BsvRpc.Address.create!(address) end)}

      error_response ->
        error_response
    end
  end

  @doc ~S"""
  Gets addresses for the default account.
  """
  @spec get_addresses :: {:ok, [BsvRpc.Address.t()]} | {:error, String.t()}
  def get_addresses do
    case GenServer.call(BsvRpc, {:call_endpoint, "getaddressesbyaccount", [""]}) do
      {:ok, addresses} ->
        {:ok, Enum.map(addresses, fn address -> BsvRpc.Address.create!(address) end)}

      error_response ->
        error_response
    end
  end

  @doc ~S"""
  Gets a transaction.
  """
  @spec get_transaction(String.t()) :: {:ok, %BsvRpc.Transaction{}} | {:error, String.t()}
  def get_transaction(hash) do
    case GenServer.call(BsvRpc, {:call_endpoint, "getrawtransaction", [hash]}) do
      {:ok, transaction_hex} ->
        {:ok, BsvRpc.Transaction.create_from_hex(transaction_hex)}

      error_response ->
        error_response
    end
  end

  @doc """
  Lists unspent transaction outputs (UTXOs) for addresses.

  ## Arguments

    - `addresses` - List of addresses to get UTXOs for.
    - `min_confirmations` - Optional number of minimum confirmations (default: 1).
    - `max_confirmations` - Optional number of maximum confirmations (default: 9_999_999).
    - `include_unsafe` - Optional flag to include/exclude unsafe UTXOs (default: true).
  """
  @spec list_unspent([%BsvRpc.Address{}], non_neg_integer, non_neg_integer, bool) ::
          {:ok,
           [
             %BsvRpc.UTXO{}
           ]}
          | {:error, String.t()}
  def list_unspent(
        addresses,
        min_confirmations \\ 1,
        max_confirmations \\ 9_999_999,
        include_unsafe \\ true
      ) do
    response =
      GenServer.call(
        BsvRpc,
        {:call_endpoint, "listunspent",
         [min_confirmations, max_confirmations, Enum.map(addresses, & &1.address), include_unsafe]}
      )

    case response do
      {:ok, utxos} ->
        {:ok,
         Enum.map(utxos, fn utxo ->
           %BsvRpc.UTXO{
             value: round(utxo["amount"] * 100_000_000),
             transaction: Base.decode16!(utxo["txid"], case: :mixed),
             output: utxo["vout"],
             script_pubkey: Base.decode16!(utxo["scriptPubKey"], case: :mixed)
           }
         end)}

      error_response ->
        error_response
    end
  end

  @doc """
  Signs a transaction and returns the signed transaction.
  """
  @spec sign_transaction(%BsvRpc.Transaction{}) ::
          {:ok, %BsvRpc.Transaction{}} | {:error, String.t()}
  def sign_transaction(transaction) do
    response =
      GenServer.call(
        BsvRpc,
        {:call_endpoint, "signrawtransaction", [BsvRpc.Transaction.to_hex(transaction)]}
      )

    case response do
      {:ok, %{"hex" => signed_tx, "complete" => true}} ->
        {:ok, BsvRpc.Transaction.create_from_hex(signed_tx)}

      error_response ->
        error_response
    end
  end

  @doc """
  Broadcasts a signed transaction to the network.
  """
  @spec broadcast_transaction(BsvRpc.Transaction.t()) :: {:ok, String.t()} | {:error, String.t()}
  def broadcast_transaction(transaction) do
    GenServer.call(
      BsvRpc,
      {:call_endpoint, "sendrawtransaction", [BsvRpc.Transaction.to_hex(transaction)]}
    )
  end
end
