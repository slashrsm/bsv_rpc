defmodule BsvRpc.Client do
  import HTTPoison
  use GenServer
  require Logger

  def set_webhook(url, allowed_updates \\ ["message"]) do
    GenServer.cast(Telegram, {:webhook, url, allowed_updates})
  end

  ###
  # GenServer API
  ###

  def start_link(username, password, host \\ "localhost", port \\ 8332) do
    GenServer.start_link(
      __MODULE__,
      %{
        host: host,
        port: port,
        username: username,
        password: password,
      },
      name: BsvRpc)
  end

  def init(state) do
    {:ok, state}
  end

  @doc """
  Sends JSON-RPC message.
  """
  def handle_call({:call_endpoint, method, params}, _from, state) do
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} =
      post(
        "http://#{state.host}:#{state.port}",
        Poison.encode!(%{
          "jsonrpc" => "1.0",
          "id" => "bsv_rpc",
          "method" => method,
          "params" => params,
        }),
        [{"Content-Type", "text/plain"}],
        hackney: [basic_auth: {state.username, state.password}]
      )

    {:ok, %{"error" => nil, "id" => "bsv_rpc", "result" => result}} = Poison.decode(body)

    {:reply, result, state}
  end

end
