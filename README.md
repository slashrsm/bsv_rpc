# Bitcoin SV JSON-RPC client

[![Build Status](https://travis-ci.org/slashrsm/bsv_rpc.svg?branch=master)](https://travis-ci.org/slashrsm/bsv_rpc)
[![Coverage Status](https://coveralls.io/repos/slashrsm/bsv_rpc/badge.svg?branch=master)](https://coveralls.io/r/slashrsm/bsv_rpc?branch=master)
[![Inline docs](http://inch-ci.org/github/slashrsm/bsv_rpc.svg)](http://hexdocs.pm/bsv_rpc/)
[![Hex Version](http://img.shields.io/hexpm/v/bsv_rpc.svg?style=flat)](https://hex.pm/packages/bsv_rpc)

A client library to talk to the JSON-RPC endpoint on a Bitcoin node (and much more! - check the ever expanding list of features below). The long term plan is to develop library into a fully-fledged Bitcoin library and split it into multiple libraries. It will stay in a single project for easier early stage development.

**Warning:** Library is under active development and will most likely keep changing in the foreseeable future. 

## Features

* API to work with basic Bitcoin structures
  * Transactions
  * Transaction inputs
  * Transaction outputs
  * Addresses
  * Unspent transation outputs (UTXOs)
  * Blocks (TODO)
  * Scripts (TODO)
* Base58Check API
* Various helper functions 
  * P2PKH transaction generation
  * [Variable length integer](https://en.bitcoin.it/wiki/Protocol_documentation#Variable_length_integer) operations
* JSON-RPC client API (not complete, support for new methods added regularly)
* MetaNet operations

## Usage

In order to use the JSON-RPC client feature add `:bsv_rpc` to your applications:

```elixir
def application do
  [applications: [:bsv_rpc]]
end
```

and add Bitcoin node connection configuration:

```elixir
config :bsv_rpc, :node,
  hostname: "localhost",
  port: 8332,
  username: "someusername",
  password: "somepassword"

```

Alternatively you can run the client's `GenServer` process manually:

```elixir
{:ok, pid} = BsvRpc.Client.start_link("someusername", "somepass", "localhost", 8332)
```

## License

Copyright © 2019 Janez Urevc

This work is free. You can redistribute it and/or modify it under the
terms of the MIT License. See the LICENSE file for more details.