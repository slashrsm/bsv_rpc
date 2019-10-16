defmodule BsvRpc.Client do
  @moduledoc """
  Client that communicates with the Bitcoin node.
  """
  import HTTPoison
  use GenServer
  require Logger

  ###
  # GenServer API
  ###
  @spec start_link(String.t(), String.t(), String.t(), non_neg_integer()) ::
          :ignore | {:error, any} | {:ok, pid}
  def start_link(username, password, host \\ "localhost", port \\ 8332) do
    GenServer.start_link(
      __MODULE__,
      %{
        host: host,
        port: port,
        username: username,
        password: password
      },
      name: BsvRpc
    )
  end

  def init(state) do
    {:ok, state}
  end

  @doc """
  Calls a Bitcoin's JSON-RPC endpoint.
  """
  def handle_call({:call_endpoint, method, params}, _from, state) do
    response =
      post(
        "http://#{state.host}:#{state.port}",
        Poison.encode!(%{
          "jsonrpc" => "1.0",
          "id" => "bsv_rpc",
          "method" => method,
          "params" => params
        }),
        [{"Content-Type", "text/plain"}],
        hackney: [basic_auth: {state.username, state.password}]
      )

    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, %{"error" => nil, "id" => "bsv_rpc", "result" => result}} = Poison.decode(body)
        {:reply, {:ok, result}, state}

      {:ok, %HTTPoison.Response{body: body}} ->
        case Poison.decode(body) do
          {:ok, %{"error" => %{"message" => message}, "id" => "bsv_rpc", "result" => nil}} ->
            {:reply, {:error, message}, state}

          _ ->
            {:reply, {:error, "Unknown error."}, state}
        end

      _ ->
        {:reply, {:error, "Unknown error."}, state}
    end
  end

  @doc """
  Calls a Bitcoin's JSON-RPC endpoint.
  """
  def handle_call({:call_endpoint, method}, from, state) do
    BsvRpc.Client.handle_call({:call_endpoint, method, []}, from, state)
  end
end
