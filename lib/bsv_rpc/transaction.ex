defmodule BsvRpc.Transaction do
  # TODO Move to a separate library?
  @moduledoc """
  Functions for Bitcoin transaction manipulation.
  """
  use Bitwise

  @enforce_keys [:inputs, :outputs, :version, :locktime]

  @typedoc """
  A Bitcoin transaction.
  """
  defstruct [:hash, :version, :size, :locktime, :inputs, :outputs, :block, :confirmations, :time]

  @type t :: %__MODULE__{
          hash: binary() | nil,
          inputs: [BsvRpc.TransactionInput.t()],
          outputs: [BsvRpc.TransactionOutput.t()],
          version: non_neg_integer(),
          locktime: non_neg_integer(),
          # Optional block hash.
          block: binary() | nil,
          confirmations: non_neg_integer() | nil,
          time: DateTime.t() | nil,
          size: non_neg_integer() | nil
        }

  @doc """
  Creates a transaction from a binary blob.

  This function raises an exception in case of an error.

  ## Examples

    iex> tx = "01000000010000000000000000000000000000000000000000000000000000000000000000FFFFFFFF4D04FFFF001D0104455468652054696D65732030332F4A616E2F32303039204368616E63656C6C6F72206F6E206272696E6B206F66207365636F6E64206261696C6F757420666F722062616E6B73FFFFFFFF0100F2052A01000000434104678AFDB0FE5548271967F1A67130B7105CD6A828E03909A67962E0EA1F61DEB649F6BC3F4CEF38C4F35504E51EC112DE5C384DF7BA0B8D578A4C702B6BF11D5FAC00000000"
    iex> t = tx |> Base.decode16!() |> BsvRpc.Transaction.create!()
    iex> t.size
    204
    iex> Base.encode16(t.hash)
    "4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E2CC77AB2127B7AFDEDA33B"
  """
  @spec create!(binary) :: __MODULE__.t()
  def create!(tx_blob) do
    <<version::little-size(32), rest::binary>> = tx_blob

    {num_inputs, rest} = BsvRpc.Helpers.get_varint(rest)
    {inputs, rest} = BsvRpc.TransactionInput.create(rest, num_inputs)

    {num_outputs, rest} = BsvRpc.Helpers.get_varint(rest)
    {outputs, <<locktime::little-size(32)>>} = BsvRpc.TransactionOutput.create(rest, num_outputs)

    <<hash_big::size(256)>> = BsvRpc.Helpers.double_sha256(tx_blob)
    hash_little = <<hash_big::integer-little-size(256)>>

    %__MODULE__{
      hash: hash_little,
      inputs: inputs,
      outputs: outputs,
      version: version,
      locktime: locktime,
      size: byte_size(tx_blob)
    }
  end

  @doc """
  Creates a transaction from a binary blob.

  ## Examples

    iex> tx = "01000000010000000000000000000000000000000000000000000000000000000000000000FFFFFFFF4D04FFFF001D0104455468652054696D65732030332F4A616E2F32303039204368616E63656C6C6F72206F6E206272696E6B206F66207365636F6E64206261696C6F757420666F722062616E6B73FFFFFFFF0100F2052A01000000434104678AFDB0FE5548271967F1A67130B7105CD6A828E03909A67962E0EA1F61DEB649F6BC3F4CEF38C4F35504E51EC112DE5C384DF7BA0B8D578A4C702B6BF11D5FAC00000000"
    iex> {:ok, t} = tx |> Base.decode16!() |> BsvRpc.Transaction.create()
    iex> t.size
    204
    iex> Base.encode16(t.hash)
    "4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E2CC77AB2127B7AFDEDA33B"
  """
  @spec create(binary) :: {:ok, __MODULE__.t()} | {:error, String.t()}
  def create(tx_blob) do
    {:ok, create!(tx_blob)}
  rescue
    MatchError -> {:error, "Invalid transaction structure."}
    _ -> {:error, "Unable to create the transaction."}
  end

  @doc """
  Creates a transaction from a hex blob.

  This function raises an exception in case of an error.

  ## Examples

    iex> t = BsvRpc.Transaction.create_from_hex!("01000000010000000000000000000000000000000000000000000000000000000000000000FFFFFFFF4D04FFFF001D0104455468652054696D65732030332F4A616E2F32303039204368616E63656C6C6F72206F6E206272696E6B206F66207365636F6E64206261696C6F757420666F722062616E6B73FFFFFFFF0100F2052A01000000434104678AFDB0FE5548271967F1A67130B7105CD6A828E03909A67962E0EA1F61DEB649F6BC3F4CEF38C4F35504E51EC112DE5C384DF7BA0B8D578A4C702B6BF11D5FAC00000000")
    iex> t.size
    204
    iex> Base.encode16(t.hash)
    "4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E2CC77AB2127B7AFDEDA33B"

  """
  @spec create_from_hex!(String.t()) :: __MODULE__.t()
  def create_from_hex!(hex) do
    hex |> Base.decode16!(case: :mixed) |> BsvRpc.Transaction.create!()
  end

  @doc """
  Creates a transaction from a hex blob.

  ## Examples

    iex> {:ok, t} = BsvRpc.Transaction.create_from_hex("01000000010000000000000000000000000000000000000000000000000000000000000000FFFFFFFF4D04FFFF001D0104455468652054696D65732030332F4A616E2F32303039204368616E63656C6C6F72206F6E206272696E6B206F66207365636F6E64206261696C6F757420666F722062616E6B73FFFFFFFF0100F2052A01000000434104678AFDB0FE5548271967F1A67130B7105CD6A828E03909A67962E0EA1F61DEB649F6BC3F4CEF38C4F35504E51EC112DE5C384DF7BA0B8D578A4C702B6BF11D5FAC00000000")
    iex> t.size
    204
    iex> Base.encode16(t.hash)
    "4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E2CC77AB2127B7AFDEDA33B"

  """
  @spec create_from_hex(String.t()) :: {:ok, __MODULE__.t()} | {:error, String.t()}
  def create_from_hex(hex) do
    {:ok, create_from_hex!(hex)}
  rescue
    MatchError -> {:error, "Invalid transaction structure."}
    _ -> {:error, "Unable to create the transaction."}
  end

  @doc """
  Gets binary representation of the transaction.
  """
  @spec to_binary(__MODULE__.t()) :: binary
  def to_binary(transaction) do
    inputs =
      transaction.inputs
      |> Enum.map(fn input -> BsvRpc.TransactionInput.to_binary(input) end)
      |> Enum.reduce(fn input, acc -> acc <> input end)

    outputs =
      transaction.outputs
      |> Enum.map(fn output -> BsvRpc.TransactionOutput.to_binary(output) end)
      |> Enum.reduce(fn output, acc -> acc <> output end)

    <<transaction.version::little-size(32)>> <>
      BsvRpc.Helpers.to_varint(length(transaction.inputs)) <>
      inputs <>
      BsvRpc.Helpers.to_varint(length(transaction.outputs)) <>
      outputs <>
      <<transaction.locktime::little-size(32)>>
  end

  @doc """
  Gets hex representation of the transaction.

  ## Examples

    iex> tx = "01000000010000000000000000000000000000000000000000000000000000000000000000FFFFFFFF4D04FFFF001D0104455468652054696D65732030332F4A616E2F32303039204368616E63656C6C6F72206F6E206272696E6B206F66207365636F6E64206261696C6F757420666F722062616E6B73FFFFFFFF0100F2052A01000000434104678AFDB0FE5548271967F1A67130B7105CD6A828E03909A67962E0EA1F61DEB649F6BC3F4CEF38C4F35504E51EC112DE5C384DF7BA0B8D578A4C702B6BF11D5FAC00000000"
    iex> t = tx |> Base.decode16!() |> BsvRpc.Transaction.create!()
    iex> BsvRpc.Transaction.to_hex(t)
    "01000000010000000000000000000000000000000000000000000000000000000000000000FFFFFFFF4D04FFFF001D0104455468652054696D65732030332F4A616E2F32303039204368616E63656C6C6F72206F6E206272696E6B206F66207365636F6E64206261696C6F757420666F722062616E6B73FFFFFFFF0100F2052A01000000434104678AFDB0FE5548271967F1A67130B7105CD6A828E03909A67962E0EA1F61DEB649F6BC3F4CEF38C4F35504E51EC112DE5C384DF7BA0B8D578A4C702B6BF11D5FAC00000000"
  """
  @spec to_hex(__MODULE__.t()) :: String.t()
  def to_hex(transaction), do: Base.encode16(to_binary(transaction))

  @doc """
  Gets the transaction id (hash in the hex form).

  ## Examples

    iex> t = BsvRpc.Transaction.create_from_hex!("01000000010000000000000000000000000000000000000000000000000000000000000000FFFFFFFF4D04FFFF001D0104455468652054696D65732030332F4A616E2F32303039204368616E63656C6C6F72206F6E206272696E6B206F66207365636F6E64206261696C6F757420666F722062616E6B73FFFFFFFF0100F2052A01000000434104678AFDB0FE5548271967F1A67130B7105CD6A828E03909A67962E0EA1F61DEB649F6BC3F4CEF38C4F35504E51EC112DE5C384DF7BA0B8D578A4C702B6BF11D5FAC00000000")
    iex> BsvRpc.Transaction.id(t)
    "4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E2CC77AB2127B7AFDEDA33B"
  """
  @spec id(__MODULE__.t()) :: String.t()
  def id(transaction) do
    case transaction.hash do
      nil ->
        transaction
        |> to_binary()
        |> BsvRpc.Helpers.double_sha256()
        |> BsvRpc.Helpers.reverse_endianess()
        |> Base.encode16()

      _ ->
        Base.encode16(transaction.hash)
    end
  end

  @doc """
  Gets the transaction hash.

  ## Examples

    iex> t = BsvRpc.Transaction.create_from_hex!("01000000010000000000000000000000000000000000000000000000000000000000000000FFFFFFFF4D04FFFF001D0104455468652054696D65732030332F4A616E2F32303039204368616E63656C6C6F72206F6E206272696E6B206F66207365636F6E64206261696C6F757420666F722062616E6B73FFFFFFFF0100F2052A01000000434104678AFDB0FE5548271967F1A67130B7105CD6A828E03909A67962E0EA1F61DEB649F6BC3F4CEF38C4F35504E51EC112DE5C384DF7BA0B8D578A4C702B6BF11D5FAC00000000")
    iex> BsvRpc.Transaction.hash(t)
    <<74, 94, 30, 75, 170, 184, 159, 58, 50, 81, 138, 136, 195, 27, 200, 127, 97, 143, 118, 103, 62, 44, 199, 122, 178, 18, 123, 122, 253, 237, 163, 59>>
  """
  @spec hash(__MODULE__.t()) :: binary()
  def hash(transaction) do
    case transaction.hash do
      nil ->
        transaction
        |> to_binary()
        |> BsvRpc.Helpers.double_sha256()
        |> BsvRpc.Helpers.reverse_endianess()

      _ ->
        transaction.hash
    end
  end

  @doc """
  Gets the id of the block that transaction belongs to (hash in the hex form).

  ## Examples

    iex> t = BsvRpc.Transaction.create_from_hex!("01000000010000000000000000000000000000000000000000000000000000000000000000FFFFFFFF4D04FFFF001D0104455468652054696D65732030332F4A616E2F32303039204368616E63656C6C6F72206F6E206272696E6B206F66207365636F6E64206261696C6F757420666F722062616E6B73FFFFFFFF0100F2052A01000000434104678AFDB0FE5548271967F1A67130B7105CD6A828E03909A67962E0EA1F61DEB649F6BC3F4CEF38C4F35504E51EC112DE5C384DF7BA0B8D578A4C702B6BF11D5FAC00000000")
    iex> BsvRpc.Transaction.block_id(t)
    nil
    iex> t = Map.put(t, :block, Base.decode16!("000000000019D6689C085AE165831E934FF763AE46A2A6C172B3F1B60A8CE26F"))
    iex> BsvRpc.Transaction.block_id(t)
    "000000000019D6689C085AE165831E934FF763AE46A2A6C172B3F1B60A8CE26F"
  """
  @spec block_id(__MODULE__.t()) :: String.t()
  def block_id(transaction) do
    case transaction.block do
      nil ->
        nil

      _ ->
        Base.encode16(transaction.block)
    end
  end

  @doc """
  Gets the hash of the block that transaction belongs to.

  ## Examples

    iex> t = BsvRpc.Transaction.create_from_hex!("01000000010000000000000000000000000000000000000000000000000000000000000000FFFFFFFF4D04FFFF001D0104455468652054696D65732030332F4A616E2F32303039204368616E63656C6C6F72206F6E206272696E6B206F66207365636F6E64206261696C6F757420666F722062616E6B73FFFFFFFF0100F2052A01000000434104678AFDB0FE5548271967F1A67130B7105CD6A828E03909A67962E0EA1F61DEB649F6BC3F4CEF38C4F35504E51EC112DE5C384DF7BA0B8D578A4C702B6BF11D5FAC00000000")
    iex> BsvRpc.Transaction.block_hash(t)
    nil
    iex> t = Map.put(t, :block, Base.decode16!("000000000019D6689C085AE165831E934FF763AE46A2A6C172B3F1B60A8CE26F"))
    iex> BsvRpc.Transaction.block_hash(t)
    <<0, 0, 0, 0, 0, 25, 214, 104, 156, 8, 90, 225, 101, 131, 30, 147, 79, 247, 99, 174, 70, 162, 166, 193, 114, 179, 241, 182, 10, 140, 226, 111>>
  """
  @spec block_hash(__MODULE__.t()) :: binary()
  def block_hash(transaction) do
    case transaction.hash do
      nil ->
        nil

      _ ->
        transaction.block
    end
  end

  @doc """
  Generates a P2PKH transaction to send funds to a single address.

  ## Arguments

    - `to_address` - Address to send funds to.
    - `amount` - Amount in satoshis.
    - `utxos` - List of unspent transaction outputs to consume.
    - `change_address` - Address to send change to.
    - `sat_per_byte` - (Optional) fee in satoshi per byte (dafault: 1).

  ## Examples

    iex> {:ok, to} = BsvRpc.Address.create("1wBQpttZsiMtrwgjp2NuGNEyBMPdnzCeA")
    iex> {:ok, change} = BsvRpc.Address.create("18v4ZTwZAkk7HKECkfutns1bfGVehaXNkW")
    iex> utxos = [%BsvRpc.UTXO{transaction: Base.decode16!("4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E2CC77AB2127B7AFDEDA33B"), output: 0, value: 5_000_000_000, script_pubkey: <<>>}]
    iex> BsvRpc.Transaction.send_to(to, 4_000_000_000, utxos, change)
    {:ok, %BsvRpc.Transaction{
      block: nil,
      confirmations: nil,
      hash: nil,
      inputs: [
        %BsvRpc.TransactionInput{
          previous_output: 0,
          previous_transaction: <<74, 94, 30, 75, 170, 184, 159, 58, 50, 81, 138,
            136, 195, 27, 200, 127, 97, 143, 118, 103, 62, 44, 199, 122, 178, 18,
            123, 122, 253, 237, 163, 59>>,
          script_sig: "",
          sequence: 4294967295
        }
      ],
      locktime: 0,
      outputs: [
        %BsvRpc.TransactionOutput{
          script_pubkey: <<118, 169, 20, 10, 63, 39, 5, 95, 134, 238, 22, 182, 35,
            80, 229, 135, 46, 13, 197, 9, 176, 72, 193, 136, 172>>,
          value: 4000000000
        },
        %BsvRpc.TransactionOutput{
          script_pubkey: <<118, 169, 20, 86, 209, 229, 225, 200, 165, 160, 64, 184,
            37, 55, 2, 13, 124, 118, 184, 15, 15, 111, 242, 136, 172>>,
          value: 999999772
        }
      ],
      size: nil,
      time: nil,
      version: 1
    }}
    iex> BsvRpc.Transaction.send_to(to, 5_000_000_000, utxos, change)
    {:error, "Insufficient funds."}
  """
  @spec send_to(
          %BsvRpc.Address{},
          non_neg_integer(),
          [%BsvRpc.UTXO{}],
          %BsvRpc.Address{}
        ) :: {:ok, __MODULE__.t()} | {:error, String.t()}
  def send_to(to_address, amount, utxos, change_address, sat_per_byte \\ 1) do
    total_value = Enum.reduce(utxos, 0, fn utxo, acc -> acc + utxo.value end)
    # TX out is about 35 bytes and TX in is about 150.
    # Make this smarter at some point...
    fee = (8 + 2 * 35 + Enum.count(utxos) * 150) * sat_per_byte
    change = total_value - amount - fee

    inputs =
      Enum.map(utxos, fn utxo ->
        %BsvRpc.TransactionInput{
          previous_transaction: utxo.transaction,
          previous_output: utxo.output,
          script_sig: <<>>,
          sequence: 0xFFFFFFFF
        }
      end)

    cond do
      change < 0 ->
        {:error, "Insufficient funds."}

      change < 100 ->
        {:ok,
         %__MODULE__{
           version: 1,
           locktime: 0,
           inputs: inputs,
           outputs: [
             %BsvRpc.TransactionOutput{
               value: amount,
               script_pubkey: BsvRpc.TransactionOutput.p2pkh_script_pubkey(to_address)
             }
           ]
         }}

      true ->
        {:ok,
         %__MODULE__{
           version: 1,
           locktime: 0,
           inputs: inputs,
           outputs: [
             %BsvRpc.TransactionOutput{
               value: amount,
               script_pubkey: BsvRpc.TransactionOutput.p2pkh_script_pubkey(to_address)
             },
             %BsvRpc.TransactionOutput{
               value: total_value - amount - fee,
               script_pubkey: BsvRpc.TransactionOutput.p2pkh_script_pubkey(change_address)
             }
           ]
         }}
    end
  end

  @doc """
  Gets the network fee of the transaction.
  """
  @spec fee(__MODULE__.t()) :: non_neg_integer
  def fee(transaction) do
    out_value = Enum.reduce(transaction.outputs, 0, fn out, acc -> out.value + acc end)

    in_value =
      transaction.inputs
      |> Enum.map(fn input ->
        {:ok, tx} = BsvRpc.get_transaction(Base.encode16(input.previous_transaction))
        Enum.at(tx.outputs, input.previous_output)
      end)
      |> Enum.reduce(0, fn output, acc -> acc + output.value end)

    in_value - out_value
  end

  @doc """
  Signs a transaction using the private key.

  ## Examples
    iex> {:ok, k} = ExtendedKey.from_string("xprv9s21ZrQH143K42Wyfo4GvDT1QBNSgq5sCBPXr4zaftZr2WKCrgEzdtniz5TvRgXA6V8hi2QrUMG3QTQnqovLp2UBAqsDcaxDUP3YCA61rJV")
    ...>   |> BsvRpc.PrivateKey.create()
    iex> tx = BsvRpc.Transaction.create_from_hex!("0100000001040800A41008F4C353626694DAC1EE5553FBD36B11AC5647528E29C7D6C89BE20000000000FFFFFFFF0200F90295000000001976A9141D7C7B4894BE23A6495B004157F3A1BBA173C52988AC0CF70295000000001976A9141D7C7B4894BE23A6495B004157F3A1BBA173C52988AC00000000")
    iex> utxo = %BsvRpc.UTXO{script_pubkey: Base.decode16!("76A9141D7C7B4894BE23A6495B004157F3A1BBA173C52988AC"), value: 5000000000, transaction: <<>>, output: 0}
    iex> signed_tx = BsvRpc.Transaction.sign(tx, [k], [utxo])
    iex> [input | []] = signed_tx.inputs
    iex> Base.encode16(input.script_sig)
    "4730440220758CB5A38A45687AC87F2637287D8F0214BB3F4455FA55CC66F37A8BD88BD62A022019B8AE768FC3ADAD1B99779E20CF747A9AD9EA339A8FAD24CB8DDFB196457E2741210342E0EB80C57799F22624264E5F7541400B996D3B38CFFFFC12EBDA7AC921DF2F"
  """
  @spec sign(
          __MODULE__.t(),
          [BsvRpc.PrivateKey.t()] | BsvRpc.PrivateKey.t(),
          [BsvRpc.UTXO.t() | nil] | BsvRpc.UTXO.t() | nil,
          BsvRpc.Sighash.t()
        ) :: {:ok, __MODULE__.t()} | {:error, String.t()}
  def sign(tx, keys, utxos, sigtype \\ [:sighash_all, :sighash_forkid])

  def sign(
        %__MODULE__{} = tx,
        [%BsvRpc.PrivateKey{} | _] = keys,
        [_h | _] = utxos,
        sigtype
      ) do
    cond do
      Enum.count(tx.inputs) != Enum.count(keys) ->
        {:error, "Number of keys must match number of transaction inputs."}

      Enum.count(tx.inputs) != Enum.count(utxos) ->
        {:error, "Number of utxos must match number of transaction inputs."}

      true ->
        signed_inputs =
          Enum.zip([tx.inputs, keys, utxos])
          |> Enum.map(fn {tx_in, key, utxo} ->
            {:ok, signed_tx_in} = BsvRpc.TransactionInput.sign(tx_in, tx, key, utxo, sigtype)
            signed_tx_in
          end)

        {:ok, Map.put(tx, :inputs, signed_inputs)}
    end
  end

  @doc """
  Signs a transaction using the private key.

  ## Examples
    iex> {:ok, k} = ExtendedKey.from_string("xprv9s21ZrQH143K42Wyfo4GvDT1QBNSgq5sCBPXr4zaftZr2WKCrgEzdtniz5TvRgXA6V8hi2QrUMG3QTQnqovLp2UBAqsDcaxDUP3YCA61rJV")
    ...>   |> BsvRpc.PrivateKey.create()
    iex> tx = BsvRpc.Transaction.create_from_hex!("0100000001040800A41008F4C353626694DAC1EE5553FBD36B11AC5647528E29C7D6C89BE20000000000FFFFFFFF0200F90295000000001976A9141D7C7B4894BE23A6495B004157F3A1BBA173C52988AC0CF70295000000001976A9141D7C7B4894BE23A6495B004157F3A1BBA173C52988AC00000000")
    iex> utxo = %BsvRpc.UTXO{script_pubkey: Base.decode16!("76A9141D7C7B4894BE23A6495B004157F3A1BBA173C52988AC"), value: 5000000000, transaction: <<>>, output: 0}
    iex> {:ok, signed_tx} = BsvRpc.Transaction.sign(tx, k, utxo)
    iex> [input | []] = signed_tx.inputs
    iex> Base.encode16(input.script_sig)
    "4730440220758CB5A38A45687AC87F2637287D8F0214BB3F4455FA55CC66F37A8BD88BD62A022019B8AE768FC3ADAD1B99779E20CF747A9AD9EA339A8FAD24CB8DDFB196457E2741210342E0EB80C57799F22624264E5F7541400B996D3B38CFFFFC12EBDA7AC921DF2F"
  """
  def sign(
        %__MODULE__{} = tx,
        %BsvRpc.PrivateKey{} = key,
        utxo,
        sigtype
      ) do
    sign(tx, [key], [utxo], sigtype)
  end

  @doc """
  Signs a transaction using the private key.

  Raises an exception in case of an error.

  ## Examples
    iex> {:ok, k} = ExtendedKey.from_string("xprv9s21ZrQH143K42Wyfo4GvDT1QBNSgq5sCBPXr4zaftZr2WKCrgEzdtniz5TvRgXA6V8hi2QrUMG3QTQnqovLp2UBAqsDcaxDUP3YCA61rJV")
    ...>   |> BsvRpc.PrivateKey.create()
    iex> tx = BsvRpc.Transaction.create_from_hex!("0100000001040800A41008F4C353626694DAC1EE5553FBD36B11AC5647528E29C7D6C89BE20000000000FFFFFFFF0200F90295000000001976A9141D7C7B4894BE23A6495B004157F3A1BBA173C52988AC0CF70295000000001976A9141D7C7B4894BE23A6495B004157F3A1BBA173C52988AC00000000")
    iex> utxo = %BsvRpc.UTXO{script_pubkey: Base.decode16!("76A9141D7C7B4894BE23A6495B004157F3A1BBA173C52988AC"), value: 5000000000, transaction: <<>>, output: 0}
    iex> signed_tx = BsvRpc.Transaction.sign!(tx, k, utxo)
    iex> [input | []] = signed_tx.inputs
    iex> Base.encode16(input.script_sig)
    "4730440220758CB5A38A45687AC87F2637287D8F0214BB3F4455FA55CC66F37A8BD88BD62A022019B8AE768FC3ADAD1B99779E20CF747A9AD9EA339A8FAD24CB8DDFB196457E2741210342E0EB80C57799F22624264E5F7541400B996D3B38CFFFFC12EBDA7AC921DF2F"
  """
  @spec sign!(
          __MODULE__.t(),
          [BsvRpc.PrivateKey.t()] | BsvRpc.PrivateKey.t(),
          [BsvRpc.UTXO.t() | nil] | BsvRpc.UTXO.t() | nil,
          BsvRpc.Sighash.t()
        ) :: __MODULE__.t()
  def sign!(tx, keys, utxos \\ nil, sigtype \\ [:sighash_all, :sighash_forkid]) do
    case sign(tx, keys, utxos, sigtype) do
      {:ok, tx} -> tx
      {:error, reason} -> raise reason
    end
  end

  @doc """
  Adds a transaction output to the transaction.

  ## Examples

    iex> t = BsvRpc.Transaction.create_from_hex!("01000000010000000000000000000000000000000000000000000000000000000000000000FFFFFFFF4D04FFFF001D0104455468652054696D65732030332F4A616E2F32303039204368616E63656C6C6F72206F6E206272696E6B206F66207365636F6E64206261696C6F757420666F722062616E6B73FFFFFFFF0100F2052A01000000434104678AFDB0FE5548271967F1A67130B7105CD6A828E03909A67962E0EA1F61DEB649F6BC3F4CEF38C4F35504E51EC112DE5C384DF7BA0B8D578A4C702B6BF11D5FAC00000000")
    iex> t = t |> BsvRpc.Transaction.add_output(%BsvRpc.TransactionOutput{value: 0, script_pubkey: <<0x00, 0x6A>>})
    iex> [_original | [added]] = t.outputs
    iex> added
    %BsvRpc.TransactionOutput{script_pubkey: <<0x00, 0x6A>>, value: 0}
  """
  @spec add_output(__MODULE__.t(), BsvRpc.TransactionOutput.t()) :: __MODULE__.t()
  def add_output(
        %BsvRpc.Transaction{} = transaction,
        %BsvRpc.TransactionOutput{} = transaction_output
      ) do
    %{transaction | :outputs => Map.get(transaction, :outputs, []) ++ [transaction_output]}
  end

  @doc """
  Adds a transaction input to the transaction.

  ## Examples

    iex> t = BsvRpc.Transaction.create_from_hex!("01000000010000000000000000000000000000000000000000000000000000000000000000FFFFFFFF4D04FFFF001D0104455468652054696D65732030332F4A616E2F32303039204368616E63656C6C6F72206F6E206272696E6B206F66207365636F6E64206261696C6F757420666F722062616E6B73FFFFFFFF0100F2052A01000000434104678AFDB0FE5548271967F1A67130B7105CD6A828E03909A67962E0EA1F61DEB649F6BC3F4CEF38C4F35504E51EC112DE5C384DF7BA0B8D578A4C702B6BF11D5FAC00000000")
    iex> t = t |> BsvRpc.Transaction.add_input(%BsvRpc.TransactionInput{
    ...>   previous_transaction: Base.decode16!("4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E2CC77AB2127B7AFDEDA33B"),
    ...>   previous_output: 0,
    ...>   script_sig: <<>>,
    ...>   sequence: 0xFFFFFFFF
    ...>  })
    iex> [_original | [added]] = t.inputs
    iex> added
    %BsvRpc.TransactionInput{
      previous_transaction: <<74, 94, 30, 75, 170, 184, 159, 58, 50, 81, 138, 136, 195, 27, 200, 127, 97, 143, 118, 103, 62, 44, 199, 122, 178, 18, 123, 122, 253, 237, 163, 59>>,
      previous_output: 0,
      script_sig: <<>>,
      sequence: 0xFFFFFFFF
    }
  """
  @spec add_input(__MODULE__.t(), BsvRpc.TransactionInput.t()) :: __MODULE__.t()
  def add_input(
        %BsvRpc.Transaction{} = transaction,
        %BsvRpc.TransactionInput{} = transaction_input
      ) do
    %{transaction | :inputs => Map.get(transaction, :inputs, []) ++ [transaction_input]}
  end
end
