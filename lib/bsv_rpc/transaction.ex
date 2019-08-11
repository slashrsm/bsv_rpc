defmodule BsvRpc.Transaction do
  # TODO Move to a separate library?
  @moduledoc """
  Functions for Bitcoin transaction manipulation.
  """

  @enforce_keys [:hash, :inputs, :outputs, :version, :locktime]

  @typedoc """
  A Bitcoin transaction.
  """
  defstruct [:hash, :version, :size, :locktime, :inputs, :outputs, :block, :confirmations, :time]

  @type t :: %__MODULE__{
          hash: binary(),
          inputs: [BsvRpc.TransactionInput.t()],
          outputs: [BsvRpc.TransactionOutput.t()],
          version: non_neg_integer(),
          locktime: non_neg_integer(),
          # Optional block hash.
          block: binary(),
          confirmations: non_neg_integer(),
          time: DateTime.t(),
          size: non_neg_integer()
        }

  @spec create(binary) :: __MODULE__.t()
  def create(tx_blob) do
    hash = BsvRpc.Helpers.double_sha256(tx_blob)
    size = byte_size(tx_blob)
    <<version::little-size(32), rest::binary>> = tx_blob

    {num_inputs, rest} = BsvRpc.Helpers.get_varint(rest)
    {inputs, rest} = BsvRpc.TransactionInput.create(rest, num_inputs)

    {num_outputs, rest} = BsvRpc.Helpers.get_varint(rest)
    {outputs, <<locktime::little-size(32)>>} = BsvRpc.TransactionOutput.create(rest, num_outputs)

    %__MODULE__{
      hash: hash,
      inputs: inputs,
      outputs: outputs,
      version: version,
      locktime: locktime,
      size: size
    }
  end
end
