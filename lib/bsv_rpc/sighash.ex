defmodule BsvRpc.Sighash do
  # TODO Move to a separate library?
  @moduledoc """
  Functions for Bitcoin sighash calculation.
  """
  use Bitwise

  @type t :: [
          :sighash_all | :sighash_none | :sighash_single | :sighash_anyonecanpay | :sighash_forkid
        ]

  @sighash %{
    sighash_all: 0x01,
    sighash_none: 0x02,
    sighash_single: 0x03,
    sighash_anyonecanpay: 0x80,
    sighash_forkid: 0x40
  }

  @doc """
  Creates sighash digest to be signed.

  ## Examples

    iex> {:ok, k} = ExtendedKey.from_string("xprv9s21ZrQH143K42Wyfo4GvDT1QBNSgq5sCBPXr4zaftZr2WKCrgEzdtniz5TvRgXA6V8hi2QrUMG3QTQnqovLp2UBAqsDcaxDUP3YCA61rJV")
    ...>   |> BsvRpc.PrivateKey.create()
    iex> tx = BsvRpc.Transaction.create_from_hex!("0100000001040800A41008F4C353626694DAC1EE5553FBD36B11AC5647528E29C7D6C89BE20000000000FFFFFFFF0200F90295000000001976A9141D7C7B4894BE23A6495B004157F3A1BBA173C52988AC0CF70295000000001976A9141D7C7B4894BE23A6495B004157F3A1BBA173C52988AC00000000")
    iex> [tx_in | _] = tx.inputs
    iex> utxo = %BsvRpc.UTXO{script_pubkey: Base.decode16!("76A9141D7C7B4894BE23A6495B004157F3A1BBA173C52988AC"), value: 5000000000, transaction: <<>>, output: 0}
    iex> Base.encode16(BsvRpc.Sighash.sighash(tx_in, tx, k, utxo, [:sighash_all, :sighash_forkid]))
    "A55AF5F6A521E714AC45BCED0BE08E1A0CCF11E09771D694942BB9C2C9F10FC6"
  """
  @spec sighash(
          BsvRpc.TransactionInput.t(),
          BsvRpc.Transaction.t(),
          BsvRpc.PrivateKey.t(),
          BsvRpc.UTXO.t() | nil,
          __MODULE__.t()
        ) :: binary
  def sighash(
        %BsvRpc.TransactionInput{} = tx_in,
        %BsvRpc.Transaction{} = tx,
        %BsvRpc.PrivateKey{} = _key,
        %BsvRpc.UTXO{} = utxo,
        [:sighash_all, :sighash_forkid] = sighash_type
      ) do
    # TODO In JS there is a bitwise or something. Figure out why it is there.
    payload =
      <<tx.version::little-size(32)>> <>
        get_previous_outputs_hash(tx, sighash_type) <>
        get_sequence_hash(tx, sighash_type) <>
        BsvRpc.Helpers.reverse_endianess(tx_in.previous_transaction) <>
        <<tx_in.previous_output::little-size(32)>> <>
        BsvRpc.Helpers.to_varlen_data(utxo.script_pubkey) <>
        <<utxo.value::little-size(64)>> <>
        <<tx_in.sequence::little-size(32)>> <>
        get_outputs_hash(tx, sighash_type) <>
        <<tx.locktime::little-size(32)>> <>
        <<get_sighash_suffix(sighash_type)::little-size(32)>>

    payload
    |> BsvRpc.Helpers.double_sha256()
  end

  def sighash(%BsvRpc.TransactionInput{}, %BsvRpc.Transaction{}, %BsvRpc.PrivateKey{}, _, _) do
    raise "Only SIGHASH_ALL | SIGHASH_FORKID signatures are supported. For now..."
  end

  @doc """
  Gets sighash type suffix byte.

  ## Examples

    iex> BsvRpc.Sighash.get_sighash_suffix([:sighash_all, :sighash_forkid])
    0x41
  """
  @spec get_sighash_suffix(__MODULE__.t()) :: byte
  def get_sighash_suffix(sighash_type) do
    Enum.reduce(sighash_type, 0x00, fn t, acc -> acc ||| @sighash[t] end)
  end

  @spec get_previous_outputs_hash(BsvRpc.Transaction.t(), __MODULE__.t()) :: binary
  defp get_previous_outputs_hash(%BsvRpc.Transaction{} = tx, sighash_type) do
    # TODO is this correct? Do we need to consider legacy chain (see JS bsv library - sighash.js)
    # Only relevant when we start supporting other sighash types.
    if sighash_type -- [:sighash_anyonecanpay] != sighash_type do
      <<0::size(256)>>
    else
      tx.inputs
      |> Enum.reduce(<<>>, fn tx_in, acc ->
        acc <>
          BsvRpc.Helpers.reverse_endianess(tx_in.previous_transaction) <>
          <<tx_in.previous_output::little-size(32)>>
      end)
      |> BsvRpc.Helpers.double_sha256()
    end
  end

  @spec get_outputs_hash(BsvRpc.Transaction.t(), __MODULE__.t()) :: binary
  defp get_outputs_hash(%BsvRpc.Transaction{} = tx, sighash_type) do
    # TODO is this correct? Do we need to consider legacy chain (see JS bsv library - sighash.js)
    # Only relevant when we start supporting other sighash types.
    if sighash_type -- [:sighash_single, :sighash_none] != sighash_type do
      if sighash_type -- [:sighash_none] != sighash_type do
        <<0::size(256)>>
      else
        raise "SIGHASH_SINGLE not implemented yet."
      end
    else
      tx.outputs
      |> Enum.reduce(<<>>, fn tx_out, acc ->
        acc <>
          <<tx_out.value::little-size(64)>> <> BsvRpc.Helpers.to_varlen_data(tx_out.script_pubkey)
      end)
      |> BsvRpc.Helpers.double_sha256()
    end
  end

  @spec get_sequence_hash(BsvRpc.Transaction.t(), __MODULE__.t()) :: binary
  defp get_sequence_hash(%BsvRpc.Transaction{} = tx, sighash_type) do
    # TODO is this correct? Do we need to consider legacy chain (see JS bsv library - sighash.js)
    # Only relevant when we start supporting other sighash types.
    if sighash_type -- [:sighash_anyonecanpay, :sighash_single, :sighash_none] != sighash_type do
      <<0::size(256)>>
    else
      tx.inputs
      |> Enum.reduce(<<>>, fn tx_in, acc ->
        acc <> <<tx_in.sequence::little-size(32)>>
      end)
      |> BsvRpc.Helpers.double_sha256()
    end
  end
end
