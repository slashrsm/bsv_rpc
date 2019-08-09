defmodule BsvRpc.Base58CheckTest do
  use ExUnit.Case
  doctest BsvRpc.Base58Check

  @prefixes %{
    "private_key" => %{
      "mainnet" => 0x80,
      "testnet" => 0xEF
    },
    "pubkey" => %{
      "mainnet" => 0x00,
      "testnet" => 0x6F
    },
    "script" => %{
      "mainnet" => 0x05,
      "testnet" => 0xC4
    }
  }

  @invalid [
    {"", ArgumentError},
    {"x", MatchError},
    {"4Uc3FmN6NQ6zLBK5QQBXRBUREaaHwCZYsGCueHauuDmJpZKn6jkEskMB2Zi2CNgtb5r6epWEFfUJq", MatchError},
    {"cTivdBmq7bay3RFGEBBuNfMh2P1pDCgRYN2Wbxmgwr4ki3jNUL2va", MatchError},
    {"7USRzBXAnmck8fX9HmW7RAb4qt92VFX6soCnts9s74wxm4gguVhtG5of8fZGbNPJA83irHVY6bCos", MatchError},
    {"461QQ2sYWxU7H2PV4oBwJGNch8XVTYYbZxU", MatchError},
    {"cSNjAsnhgtiFMi6MtfvgscMB2Cbhn2v1FUYfviJ1CdjfidvmeW6mn", MatchError},
    {"gmsow2Y6EWAFDFE1CE4Hd3Tpu2BvfmBfG1SXsuRARbnt1WjkZnFh1qGTiptWWbjsq2Q6qvpgJVj", MatchError},
    {"nbuzhfwMoNzA3PaFnyLcRxE9bTJPDkjZ6Rf6Y6o2ckXZfzZzXBT", ArgumentError},
    {"Ky1YjoZNgQ196HJV3HpdkecfhRBmRZdMJk89Hi5KGfpfPwS2bUbfd", MatchError}
  ]

  @valid [
    {"37qgekLpCCHrQuSjvX3fs496FWTGsHFHizjJAs6NPcR47aefnnCWECAhHV6E3g4YN7u7Yuwod5Y",
     "05f392694d78dd10355033d75226552a273c409b0023d57335aac827ff9b8a6f0a9509aeb5aa8c649b94dba9dab3a7075061b0"},
    {"dzb7VV1Ui55BARxv7ATxAtCUeJsANKovDGWFVgpTbhq9gvPqP3yv",
     "fa12c39fd4be74458a401f538c9bdf73f3700938f1d8bca02d4f43ed0b7ead58658b"},
    {"MuNu7ZAEDFiHthiunm7dPjwKqrVNCM3mAz6rP9zFveQu14YA8CxExSJTHcVP9DErn6u84E6Ej7S",
     "3abd123ea076b5d0f5e986eb6e5dc6f5a1c84bc80bcf6cd8899b499a37fd71537692e68fec0b004e80d9ee49cb1fbcbe6c91d8"},
    {"rPpQpYknyNQ5AEHuY6H8ijJJrYc2nDKKk9jjmKEXsWzyAQcFGpDLU2Zvsmoi8JLR7hAwoy3RQWf",
     "8acc37d0492a0be2579f4e558ba0a2e9e26746b744de1b34990b590a0ab73a3bc18c4f472c7a64719c37ee3405d61c364e438c"},
    {"7aQgR5DFQ25vyXmqZAWmnVCjL3PkBcdVkBUpjrjMTcghHx3E8wb",
     "c435facc01a0c7388d04d39d9e086d0556d1b59d3e85d4d727331200cb3871f8d0"},
    {"17QpPprjeg69fW1DV8DcYYCKvWjYhXvWkov6MJ1iTTvMFj6weAqW7wybZeH57WTNxXVCRH4veVs",
     "004f82cb8a6fb8108f41661e6479829a8c431e3d7ab7b4bbb1bed1872abc1fa02ce83a72efcebaafda7d8002f4905704e9deb3"},
    {"KxuACDviz8Xvpn1xAh9MfopySZNuyajYMZWz16Dv2mHHryznWUp3",
     "803221945e8bdc48290c4ea99321a8fc9b5792a1666780ec21c6c1525e09da4b145c"},
    {"7nK3GSmqdXJQtdohvGfJ7KsSmn3TmGqExug49583bDAL91pVSGq5xS9SHoAYL3Wv3ijKTit65th",
     "130e389b158fcf2ac53a7eadd16dc2da2d4d096f7b8d8c6ee5e5c75b36d3bfc302477b94d5515088c9ad764f31dad505a8375d"},
    {"gjMV4vjNjyMrna4fsAr8bWxAbwtmMUBXJS3zL4NJt5qjozpbQLmAfK1uA3CquSqsZQMpoD1g2nk",
     "6fa4cd4849f0a013aecc4e61ee1ee4e9b313d871c8c760ab0475752e1e3d64abce2e0e021ccd7de102351c288b7818bf0569c5"},
    {"emXm1naBMoVzPjbk7xpeTVMFy4oDEe25UmoyGgKEB1gGWsK8kRGs",
     "ff4fb8d91b79bbe55e13cd947929da48ebaed0add49b4da0a428425eeb53f65e3a01"},
    {"7VThQnNRj1o3Zyvc7XHPRrjDf8j2oivPTeDXnRPYWeYGE4pXeRJDZgf28ppti5hsHWXS2GSobdqyo",
     "efac7f630271f92c61a017d5f4c29392b19474d54e1ce59a1e72f35675b2f32b650b747ac275e1531e9d44da85724d05c534bb01"},
    {"1G9u6oCVCPh2o8m3t55ACiYvG1y5BHewUkDSdiQarDcYXXhFHYdzMdYfUAhfxn5vNZBwpgUNpso",
     "00bbf27f4cac6e3da47b8e9ed1dbfdd0e02407d8aaf812d4e9555e68f0c19ac5cf54135df3573e55e70f3cc7bfed0247b360aa"},
    {"31QQ7ZMLkScDiB4VyZjuptr7AEc9j1SjstF7pRoLhHTGkW4Q2y9XELobQmhhWxeRvqcukGd1XCq",
     "05a3bf40704b33a3a5646a7a60aa124b188db3f4b21c261c8e69b0876cd3b4a286bb4026621f0b105ed10d97dada4a5b88f63b"},
    {"DHqKSnpxa8ZdQyH8keAhvLTrfkyBMQxqngcQA5N8LQ9KVt25kmGN",
     "5315153ee01437de25841ad8e9c698b03e7ee731d3ff658e0b6f55e15c9c2a812701"},
    {"2LUHcJPbwLCy9GLH1qXmfmAwvadWw4bp4PCpDfduLqV17s6iDcy1imUwhQJhAoNoN1XNmweiJP4i",
     "d9b20de0645f597fb1af37ffd26f22ea32c67f837a60d9569584376d3a4492288fe04fc6584ea396980014e76c4a898f56ac19"},
    {"1DGezo7BfVebZxAbNT3XGujdeHyNNBF3vnficYoTSp4PfK2QaML9bHzAMxke3wdKdHYWmsMTJVu",
     "00982eeb9e2853e54a92480d2b7106890e70d79a0419f7069adfdb71459439ee73260cc62be598968dad0e1cbf8a0ea6c3bb2d"},
    {"2D12DqDZKwCxxkzs1ZATJWvgJGhQ4cFi3WrizQ5zLAyhN5HxuAJ1yMYaJp8GuYsTLLxTAz6otCfb",
     "c4b4481df697b27563b90782370af27755f81508412271a1435e0b730a7e93941c4eac63ab5c24d306745f5bab0b33725e52d7"},
    {"8AFJzuTujXjw1Z6M3fWhQ1ujDW7zsV4ePeVjVo7D1egERqSW9nZ",
     "d59e5f7516cc9d80c8955e978631c96b9cb97f1e75d6566fe97014cd4f9821b0a8"},
    {"163Q17qLbTCue8YY3AvjpUhotuaodLm2uqMhpYirsKjVqnxJRWTEoywMVY3NbBAHuhAJ2cF9GAZ",
     "003e86fd1ce2ee7e5a951f9ab688ee80f583509b65e73a9fa72fce42773717cdada536e6e5b8dfceb600de406006ab3a7c5de3"},
    {"2MnmgiRH4eGLyLc9eAqStzk7dFgBjFtUCtu", "c3ceea28fa68010b6e8518f13f1af2a2ee33519c05"},
    {"2UCtv53VttmQYkVU4VMtXB31REvQg4ABzs41AEKZ8UcB7DAfVzdkV9JDErwGwyj5AUHLkmgZeobs",
     "ef6e2173d1101f1e8cca1f55e26bdd668ef53ab6f553855848ff20de178df2b51be2ba100ecbea4ca9a32b4da588d15b47152a"},
    {"nksUKSkzS76v8EsSgozXGMoQFiCoCHzCVajFKAXqzK5on9ZJYVHMD5CKwgmX3S3c7M1U3xabUny",
     "8093d90566b4be3ecc0883b46ceaba89c8fcb4a5ef5625b8d6d85825780af2b30e69fa45a5ac27a30b88e2b19a46a2b2e11c82"},
    {"L3favK1UzFGgdzYBF2oBT5tbayCo4vtVBLJhg2iYuMeePxWG8SQc",
     "80c055d8302abd6b898bdab52e69c2e5dfef2f84bd661c92aaf9c73d2eacc646f6ff"},
    {"7VxLxGGtYT6N99GdEfi6xz56xdQ8nP2dG1CavuXx7Rf2PrvNMTBNevjkfgs9JmkcGm6EXpj8ipyPZ",
     "effcff6fc37a25ce6d0929560c887b461161a15cde953dd467fe98284e678c0198fc94552e6b1d16d05b04b58a77fb182a9cf63e"},
    {"2mbZwFXF6cxShaCo2czTRB62WTx9LxhTtpP", "fef937029b493c2cf8b16268cfd29882fde9f68ce4"},
    {"dB7cwYdcPSgiyAwKWL3JwCVwSk6epU2txw", "59e6b864469bd0f960ed5563570d7b7c5589b3e09d"},
    {"HPhFUhUAh8ZQQisH8QQWafAxtQYju3SFTX", "28bc6437e3089918c9cb7e3d3ddd7ca83969b1e0bc"},
    {"4ctAH6AkHzq5ioiM1m9T3E2hiYEev5mTsB", "08fe3f3f4b4fbaee5720913ca287382fc89b6336fc"},
    {"Hn1uFi4dNexWrqARpjMqgT6cX1UsNPuV3cHdGg9ExyXw8HTKadbktRDtdeVmY3M1BxJStiL4vjJ",
     "2f2446008383bcf5bc05b9b2bde8539564d3ba291674ceca88fd2f438aca78470bcf67a0c356d742c544295613b57700e02757"},
    {"Sq3fDbvutABmnAHHExJDgPLQn44KnNC7UsXuT7KZecpaYDMU9Txs",
     "ae99c9b6f3e5dc57acca5e4ee8469a95468ae0caddd2d78207c4674703620f53e501"},
    {"6TqWyrqdgUEYDQU1aChMuFMMEimHX44qHFzCUgGfqxGgZNMUVWJ",
     "a2fe2132d38fd2f9fd39272f62262a6b483f078fe7b40d0038671543f06664b1e3"},
    {"giqJo7oWqFxNKWyrgcBxAVHXnjJ1t6cGoEffce5Y1y7u649Noj5wJ4mmiUAKEVVrYAGg2KPB3Y4",
     "6f9e59436dcff471f10f77b472e04b32146739f57cdcc511cb1301a90d4a5db7533f189cc34618b3f7dd451f27ceb12a7089ea"},
    {"cNzHY5e8vcmM3QVJUcjCyiKMYfeYvyueq5qCMV3kqcySoLyGLYUK",
     "ef29f854acf9adadbec297d659f083ef09c3c55e888aeea5745002ee9f8475bee318"},
    {"37uTe568EYc9WLoHEd9jXEvUiWbq5LFLscNyqvAzLU5vBArUJA6eydkLmnMwJDjkL5kXc2VK7ig",
     "05f4611b43e962c4657f17db5a7946f31ca6a57770b034606ecb614bb78a38d7437ce76d5a17a51a79dbe7642b16f8f91bee4d"},
    {"EsYbG4tWWWY45G31nox838qNdzksbPySWc", "22793e9fa3d8ef2611675b8d45f33f493b44b3ab1d"},
    {"cQN9PoxZeCWK1x56xnz6QYAsvR11XAce3Ehp3gMUdfSQ53Y2mPzx",
     "ef530d879642c6768eb0318d3f592b938d51cf4dc945a97333f7928193430fd48e76"},
    {"1Gm3N3rkef6iMbx4voBzaxtXcmmiMTqZPhcuAepRzYUJQW4qRpEnHvMojzof42hjFRf8PE2jPde",
     "00c3765708d62e4734205e280a0031266939978ad6d25c08bea658e54381aee2e203619f60b9d2f82b2ab056a6107638ec0c9f"},
    {"2TAq2tuN6x6m233bpT7yqdYQPELdTDJn1eU", "d12df37fa0cf4d189834ea86d04cfd18bf140bd1c9"},
    {"ntEtnnGhqPii4joABvBtSEJG6BxjT2tUZqE8PcVYgk3RHpgxgHDCQxNbLJf7ardf1dDk2oCQ7Cf",
     "80ef3fd9b835e5f6f4de7b0eee719b4c57f46f6df140bf95ff704118fdaff0664b82972eca3df3cec08a1a3e139e450ebc5a79"},
    {"2A1q1YsMZowabbvta7kTy2Fd6qN4r5ZCeG3qLpvZBMzCixMUdkN2Y4dHB1wPsZAeVXUGD83MfRED",
     "bc502c03c9cbda89524ee6fcb182d784ba0142d6f2cf1a6f3a1bf5c373cc3320139d16482c50a8619ca30821ce5715e8794977"}
  ]

  test "base58check_decode" do
    # Test cases from https://github.com/bitcoin-sv/bitcoin-sv/blob/master/src/test/data/base58_keys_valid.json.
    # First three cases are also in doctests.
    Enum.each(
      Poison.decode!(
        IO.read(File.open!("test/bsv_rpc/base58_keys_valid.json", [:read, :utf8]), :all)
      ),
      fn [str, expected, options] ->
        <<_prefix::size(8), decoded::binary>> = BsvRpc.Base58Check.decode!(str)

        decoded =
          if options["isPrivkey"] and options["isCompressed"] do
            size = byte_size(decoded) - 1
            <<decoded::binary-size(size), 0x01>> = decoded
            decoded
          else
            decoded
          end

        assert Base.encode16(decoded, case: :lower) == expected
      end
    )
  end

  test "base58check_encode" do
    # Test cases from https://github.com/bitcoin-sv/bitcoin-sv/blob/master/src/test/data/base58_keys_valid.json.
    # First three cases are also in doctests.
    Enum.each(
      Poison.decode!(
        IO.read(File.open!("test/bsv_rpc/base58_keys_valid.json", [:read, :utf8]), :all)
      ),
      fn [expected, data, options] ->
        data = Base.decode16!(data, case: :lower)

        {prefix, suffix} =
          if options["isPrivkey"] do
            {
              <<@prefixes["private_key"][if(options["isTestnet"], do: "testnet", else: "mainnet")]>>,
              if(options["isCompressed"], do: <<0x01>>, else: <<>>)
            }
          else
            {
              <<@prefixes[options["addrType"]][
                  if(options["isTestnet"], do: "testnet", else: "mainnet")
                ]>>,
              <<>>
            }
          end

        assert BsvRpc.Base58Check.encode(prefix <> data <> suffix) == expected
      end
    )
  end

  test "valid encodes with decode!/1" do
    Enum.each(
      @valid,
      fn {encoded, expected} ->
        assert Base.encode16(BsvRpc.Base58Check.decode!(encoded), case: :lower) == expected
      end
    )
  end

  test "invalid encodes decode!/1" do
    Enum.each(
      @invalid,
      fn {encoded, error} ->
        assert_raise error, fn -> BsvRpc.Base58Check.decode!(encoded) end
      end
    )
  end

  test "valid encodes with decode/1" do
    Enum.each(
      @valid,
      fn {encoded, expected} ->
        result = BsvRpc.Base58Check.decode(encoded)
        assert {:ok, _decoded} = result
        assert Base.encode16(elem(result, 1), case: :lower) == expected
      end
    )
  end

  test "invalid encodes with decode/1" do
    Enum.each(
      @invalid,
      fn {encoded, error} ->
        message =
          case error do
            MatchError -> "Checksum validation failed."
            ArgumentError -> "Input invalid."
          end

        assert BsvRpc.Base58Check.decode(encoded) == {:error, message}
      end
    )
  end
end
