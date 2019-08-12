defmodule BsvRpc.ClientTest do
  use ExUnit.Case
  import Mock
  doctest BsvRpc.Client

  test "init returns unchanged state" do
    assert BsvRpc.Client.init(%{foo: "bar"}) == {:ok, %{foo: "bar"}}
  end

  test_with_mock "start_link passes on creds", _context, GenServer, [],
    start_link: fn _module, _init_arg, _options ->
      {:ok, self()}
    end do
    assert BsvRpc.Client.start_link("user", "pass", "localhost", 8332) == {:ok, self()}

    assert called(
             GenServer.start_link(
               BsvRpc.Client,
               %{
                 host: "localhost",
                 port: 8332,
                 username: "user",
                 password: "pass"
               },
               name: BsvRpc
             )
           )
  end

  test_with_mock "start_link passes on default host and port", _context, GenServer, [],
    start_link: fn _module, _init_arg, _options ->
      {:ok, self()}
    end do
    assert BsvRpc.Client.start_link("user", "pass") == {:ok, self()}

    assert called(
             GenServer.start_link(
               BsvRpc.Client,
               %{
                 host: "localhost",
                 port: 8332,
                 username: "user",
                 password: "pass"
               },
               name: BsvRpc
             )
           )
  end

  test_with_mock ":call_endpoint call passes on method and params", _context, HTTPoison, [],
    post: fn _endpoint, _body, _header, _options ->
      {:ok,
       %HTTPoison.Response{
         status_code: 200,
         body:
           Poison.encode!(%{
             "error" => nil,
             "id" => "bsv_rpc",
             "result" => %{"foo" => "bar"}
           })
       }}
    end do
    response =
      BsvRpc.Client.handle_call(
        {:call_endpoint, "somemethod", [1, "foo", false, %{"bar" => "baz"}]},
        self(),
        %{
          host: "host",
          port: 12_345,
          username: "username",
          password: "password"
        }
      )

    assert response ==
             {:reply, %{"foo" => "bar"},
              %{host: "host", password: "password", port: 12_345, username: "username"}}

    assert called(
             HTTPoison.post(
               "http://host:12345",
               "{\"params\":[1,\"foo\",false,{\"bar\":\"baz\"}],\"method\":\"somemethod\",\"jsonrpc\":\"1.0\",\"id\":\"bsv_rpc\"}",
               [{"Content-Type", "text/plain"}],
               hackney: [basic_auth: {"username", "password"}]
             )
           )
  end

  test_with_mock ":call_endpoint can be called without parameters", _context, HTTPoison, [],
    post: fn _endpoint, _body, _header, _options ->
      {:ok,
       %HTTPoison.Response{
         status_code: 200,
         body:
           Poison.encode!(%{
             "error" => nil,
             "id" => "bsv_rpc",
             "result" => %{"foo" => "bar"}
           })
       }}
    end do
    response =
      BsvRpc.Client.handle_call(
        {:call_endpoint, "somemethod"},
        self(),
        %{
          host: "host",
          port: 12_345,
          username: "username",
          password: "password"
        }
      )

    assert response ==
             {:reply, %{"foo" => "bar"},
              %{host: "host", password: "password", port: 12_345, username: "username"}}

    assert called(
             HTTPoison.post(
               "http://host:12345",
               "{\"params\":[],\"method\":\"somemethod\",\"jsonrpc\":\"1.0\",\"id\":\"bsv_rpc\"}",
               [{"Content-Type", "text/plain"}],
               hackney: [basic_auth: {"username", "password"}]
             )
           )
  end
end
