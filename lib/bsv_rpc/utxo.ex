defmodule BsvRpc.UTXO do
  # TODO Move to a separate library?
  @moduledoc """
  Functions for Bitcoin unspent transaction outputs manipulation.
  """

  @typedoc """
  A Bitcoin transaction output.
  """
  @enforce_keys [:transaction, :output]
  defstruct [:value, :transaction, :output]

  @type t :: %__MODULE__{
          value: non_neg_integer(),
          transaction: binary(),
          output: non_neg_integer()
        }
end
