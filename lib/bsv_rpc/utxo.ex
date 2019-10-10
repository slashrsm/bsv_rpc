defmodule BsvRpc.UTXO do
  # TODO Move to a separate library?
  @moduledoc """
  Functions for Bitcoin unspent transaction outputs manipulation.
  """

  @typedoc """
  A Bitcoin transaction output.
  """
  @enforce_keys [:transaction, :output, :value, :script_pubkey]
  defstruct [:value, :transaction, :output, :script_pubkey]

  @type t :: %__MODULE__{
          value: non_neg_integer(),
          transaction: binary(),
          output: non_neg_integer(),
          script_pubkey: <<>>
        }

  @doc """
  Creates UTXO from a transaction output.

  ## Examples

    iex> tx = "01000000010000000000000000000000000000000000000000000000000000000000000000FFFFFFFF4D04FFFF001D0104455468652054696D65732030332F4A616E2F32303039204368616E63656C6C6F72206F6E206272696E6B206F66207365636F6E64206261696C6F757420666F722062616E6B73FFFFFFFF0100F2052A01000000434104678AFDB0FE5548271967F1A67130B7105CD6A828E03909A67962E0EA1F61DEB649F6BC3F4CEF38C4F35504E51EC112DE5C384DF7BA0B8D578A4C702B6BF11D5FAC00000000"
    iex> t = tx |> Base.decode16!() |> BsvRpc.Transaction.create()
    iex> BsvRpc.UTXO.create(t, 0)
    %BsvRpc.UTXO{
      output: 0,
      transaction: <<74, 94, 30, 75, 170, 184, 159, 58, 50, 81, 138,
        136, 195, 27, 200, 127, 97, 143, 118, 103, 62, 44, 199, 122,
        178, 18, 123, 122, 253, 237, 163, 59>>,
      value: 5000000000,
      script_pubkey: <<65, 4, 103, 138, 253, 176, 254, 85, 72, 39, 25, 103, 241, 166, 113, 48, 183, 16, 92, 214, 168, 40, 224, 57, 9, 166, 121, 98, 224, 234, 31, 97, 222, 182, 73,
              246, 188, 63, 76, 239, 56, 196, 243, 85, 4, 229, 30, 193, 18, 222,
              92, 56, 77, 247, 186, 11, 141, 87, 138, 76, 112, 43, 107, 241, 29,
              95, 172>>,
    }
  """
  @spec create(%BsvRpc.Transaction{}, non_neg_integer) :: %__MODULE__{}
  def create(transaction, output_nr) do
    %__MODULE__{
      value: Enum.at(transaction.outputs, output_nr).value,
      transaction: BsvRpc.Transaction.hash(transaction),
      output: output_nr,
      script_pubkey: Enum.at(transaction.outputs, output_nr).script_pubkey
    }
  end
end
