defmodule BsvRpc.Address do
  # TODO Move to a separate library?
  @moduledoc """
  Logic related to Bitcoin addresses.
  """

  @typedoc """
  A Bitcoin address.
  """
  defstruct [
    :address
  ]

  @type t :: %__MODULE__{
          address: String.t()
        }
end
