defmodule BsvRpc.BlockTest do
  use ExUnit.Case
  doctest BsvRpc.Block

  test "block headers without transactions is parsed" do
    block =
      BsvRpc.Block.create_from_hex!(
        "010000006FE28C0AB6F1B372C1A6A246AE63F74F931E8365E15A089C68D6190000000000982051FD1E4BA744BBBE680E1FEE14677BA1A3C3540BF7B1CDB606E857233E0E61BC6649FFFF001D01E36299"
      )

    assert Base.encode16(block.hash) ==
             "00000000839A8E6886AB5951D76F411475428AFC90947EE320161BBF18EB6048"
  end

  test "to_binary()" do
    binary_block =
      Base.decode16!(
        "010000006FE28C0AB6F1B372C1A6A246AE63F74F931E8365E15A089C68D6190000000000982051FD1E4BA744BBBE680E1FEE14677BA1A3C3540BF7B1CDB606E857233E0E61BC6649FFFF001D01E36299"
      )

    assert binary_block ==
             BsvRpc.Block.to_binary(%BsvRpc.Block{
               bits: <<255, 255, 0, 29>>,
               hash:
                 <<0, 0, 0, 0, 131, 154, 142, 104, 134, 171, 89, 81, 215, 111, 65, 20, 117, 66,
                   138, 252, 144, 148, 126, 227, 32, 22, 27, 191, 24, 235, 96, 72>>,
               merkle_root:
                 <<152, 32, 81, 253, 30, 75, 167, 68, 187, 190, 104, 14, 31, 238, 20, 103, 123,
                   161, 163, 195, 84, 11, 247, 177, 205, 182, 6, 232, 87, 35, 62, 14>>,
               nonce: <<1, 227, 98, 153>>,
               previous_block:
                 <<111, 226, 140, 10, 182, 241, 179, 114, 193, 166, 162, 70, 174, 99, 247, 79,
                   147, 30, 131, 101, 225, 90, 8, 156, 104, 214, 25, 0, 0, 0, 0, 0>>,
               timestamp: ~U[2009-01-09 02:54:25Z],
               transactions: [],
               version: 1
             })
  end

  test "hash() without the pre-computed hash" do
    hash =
      BsvRpc.Block.hash(%BsvRpc.Block{
        bits: <<255, 255, 0, 29>>,
        hash: nil,
        merkle_root:
          <<152, 32, 81, 253, 30, 75, 167, 68, 187, 190, 104, 14, 31, 238, 20, 103, 123, 161, 163,
            195, 84, 11, 247, 177, 205, 182, 6, 232, 87, 35, 62, 14>>,
        nonce: <<1, 227, 98, 153>>,
        previous_block:
          <<111, 226, 140, 10, 182, 241, 179, 114, 193, 166, 162, 70, 174, 99, 247, 79, 147, 30,
            131, 101, 225, 90, 8, 156, 104, 214, 25, 0, 0, 0, 0, 0>>,
        timestamp: ~U[2009-01-09 02:54:25Z],
        transactions: [],
        version: 1
      })

    assert hash ==
             <<0, 0, 0, 0, 131, 154, 142, 104, 134, 171, 89, 81, 215, 111, 65, 20, 117, 66, 138,
               252, 144, 148, 126, 227, 32, 22, 27, 191, 24, 235, 96, 72>>
  end

  test "id() without the pre-computed hash" do
    id =
      BsvRpc.Block.id(%BsvRpc.Block{
        bits: <<255, 255, 0, 29>>,
        hash: nil,
        merkle_root:
          <<152, 32, 81, 253, 30, 75, 167, 68, 187, 190, 104, 14, 31, 238, 20, 103, 123, 161, 163,
            195, 84, 11, 247, 177, 205, 182, 6, 232, 87, 35, 62, 14>>,
        nonce: <<1, 227, 98, 153>>,
        previous_block:
          <<111, 226, 140, 10, 182, 241, 179, 114, 193, 166, 162, 70, 174, 99, 247, 79, 147, 30,
            131, 101, 225, 90, 8, 156, 104, 214, 25, 0, 0, 0, 0, 0>>,
        timestamp: ~U[2009-01-09 02:54:25Z],
        transactions: [],
        version: 1
      })

    assert id == "00000000839A8E6886AB5951D76F411475428AFC90947EE320161BBF18EB6048"
  end
end
