defmodule BsvRpc.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    creds = Application.get_env(:bsv_rpc, :node)
    Supervisor.start_link(
      [%{
        id: Client,
        start: {BsvRpc.Client, :start_link, [creds.username, creds.password, creds.hostname, creds.port]}
      }],
      [strategy: :one_for_one, name: BsvRpc.Supervisor]
    )
  end
end
