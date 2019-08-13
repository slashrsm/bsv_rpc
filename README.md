# Bitcoin SV JSON-RPC client

A client library to talk to the JSON-RPC endpoint on a Bitcoin node. 

**Warning:** Library is under active development and will most likely keep changing in the foreseeable future. 

Most of the things should work with any Bitcoin flavour (Bitcoin Core, Bitcoin Cash), but I do currently not test
with any other implementation than Bitcoin SV.

## Features

* API to work with basic Bitcoin structures
  * Transactions
  * Transaction inputs
  * Transaction outputs
  * Addresses
  * Blocks (TODO)
  * Scripts
* Base58Check API
* Various helper functions 
  * P2PKH transaction generation
  * [Variable length integer](https://en.bitcoin.it/wiki/Protocol_documentation#Variable_length_integer) operations
* JSON-RPC client API (not complete, support for new methods added regularly)

## Usage

In order to use the JSON-RPC client feature add `:bsv_rpc` to your applications:

```
def application do
  [applications: [:bsv_rpc]]
end
```

and add Bitcoin node connection configuration:

```
config :bsv_rpc, :node,
  hostname: "localhost",
  port: 8332,
  username: "someusername",
  password: "somepassword"

```

Alternatively you can run the client's `GenServer` process manually:

```
{:ok, pid} = BsvRpc.Client.start_link("someusername", "somepass", "localhost", 8332)
```

## License

Copyright © 2019 Janez Urevc

This work is free. You can redistribute it and/or modify it under the
terms of the MIT License. See the LICENSE file for more details.