defmodule BsvRpc.TransactionTest do
  use ExUnit.Case
  import Mock
  doctest BsvRpc.Transaction

  test "transaction with multiple inputs is converted to binary" do
    tx_hex =
      "010000004A9CDCE8E0A7BE8895354D8B07DA452AF5BBBCB53FF3D1A16E3A426D98FF181531000000008B483045022100AB43E9076AA976FB89AA66F38B261E9A2720CD4BFADC0ED3F4237C88288C597B02205E16E0F2100A6C30CDE079D339B2AC47CE8AE325DEBA1EF759F667728C7CAB580141045B34A80569593950E7E1EA8F88A3AC419DFF208205DADF095C31FE7CA36FC401B004DC7C03610C074584B852BB2B6479E30213CECF4917A10440FDD10DE6B267FFFFFFFFCA64A7E8BCB33C9E505E949F964DD4BD55C42BED6C2D113F210F1C1BEAA4E1F100000000484730440220102BB8F16D5C4137A2CBC17A1168C46D4902753BE8F3174FD7ED7145C362383B02204A730BE3E1CF4BD324268A1F1A7F823EF74F10B0E9FF58E2E7979E0889A684AC01FFFFFFFFCA85DE4CF78BEB83D12F7E00D5C2B6B90113699E2B4BB79C2CACB05D04E3F80C000000004948304502204214361DD4EA508C844AB96B3F0B3C45110BC8B6EB323D8ED6DEF93E187059CB022100C7C5854E4186ACFDA190C6E37EFE6C9D9D99B3FB60B15BD13F3AE3E87BFC60B901FFFFFFFFCB02D13A80B17CB40BB6F29A8EAE9BFBDF394D3F9601B96A683C742179C43534000000004A493046022100F0F7893D97D1A1B2203327F1F2FBB4D60053F6524507794650CB49EFACDD80CF0221008BBC2290342B0C9094BBF09510AB9480ABD890EFCC52D5E9B4FDB8BAB8A70DE701FFFFFFFFCB38858CD3826DBE47B06E70707F4476D862B2CB643BCC4CFE0214C68FA07BA50000000049483045022100F74F151343DC055B58F28C3D574CE95ABF6F0CF1B8B8C76C7DD4AEEDF90078F4022077AD5F7C6433104B2F39D67447D902D621C0CB5C8EA42370895FAA9693463EBE01FFFFFFFFCB853058E84D30B71C7BF4ABECD3AC39C3CDE8C1B5A917A6DE233E8A27FCC834000000004948304502201434B28594B7A54E0375234E326225628FBB0499992C9423A7EF4730B64793A3022100E67579BEDDD0097E727C740B47695D2248FD00F189403F17CE086FD105A3B5DB01FFFFFFFFCCF80D38F734907CD56FCAD175BC9011F5D41AE708EBA73FCFAD5DDF09A75678000000004A493046022100FF72F3BE59F709BECC1FA1FF4514C3C5D61B1867D46CB6D881C4C53928380A1A0221009D7A6F88EEDF871FFCB0FA20F5436840C776CACE5A5EA212283FB3F44D6B3A4D01FFFFFFFFCFAEEF7BDAB985B49E8DD17555AE0CFCCC9DAB643EF57902470217523FB83E48000000004847304402201E67D5161A135F5C2C461813DDEC46D2E1C7BA0F8C1E05574E6E11A4B3A812F50220756E3F7C4F690145B39E5985BDD0FD8C0F0C21C9E0EA4B567689476E1707A7C201FFFFFFFFCFE2DCD028BE157B8604AA9E1F6039BEAC5D2A9F6DF3920BF6457E0F4F6D9806000000004A493046022100CF0549ADECC556455AB5BF61D7A65D1E7D71E44CE0ADF9F2BBED946C61E7EC60022100BCDE91AEE7262DD5EC50D9C5DD82A82DBACA03A29B6D2D197A575DCCBA38E94801FFFFFFFFCFFC7133FF13E3D68DA52C9C171336F8C4DFA4A9A83291556A78B9EBD758E03D000000004A4930460221009A50EE3F526BCF34817A85C202B236C14185EA82F3DC2828FA5F65223680A708022100C9ACBA8620A9D57D88BC7DBFA8A121B5542D92B63E12B197A571F1802EB1530601FFFFFFFFD1C85D6F6C405B869B4C9A9EF55C88798E201BAF738812AB8D84F4731250B1E10000000049483045022100807E9D48150FE08DC518E75155BB3B8F04D2FBD1F59012389AE2B3878B82A8AE022078F9DF6BD876148141B3D7B82B38B4B2CDEF094C8AB162E5FE2DC177BCFCA64D01FFFFFFFFD2873120919BA1B2C78A04E814D96C7D8C1FB3C47FF0E8BD52711273431734DF0000000048473044022018FCB0B12987BBF3FF40DC29E729F9E6A842FF512FCED47E1E95B482B5A2C4ED0220727810E0EE1764A05A9828018B3909C44252E0EDDF5895A9BA22E06FEBBE2AFA01FFFFFFFFD3007277480171504A3A339B828C88A230BD895DF421575267F5A4F5BBB0E511000000008C493046022100EFF124E99FB9D39272F3D47F3D4AC28CDDD2E927C102BD1034FBEA9CD58F42E6022100E45C388D72B58DAD9F1CB5E86787824B37DDF5CFF8701B419C4A9583415B1EAC0141045B34A80569593950E7E1EA8F88A3AC419DFF208205DADF095C31FE7CA36FC401B004DC7C03610C074584B852BB2B6479E30213CECF4917A10440FDD10DE6B267FFFFFFFFD5BB1E6FC345FD545C2FA5CA9C51F49229C566052CA8033FF2F139F0322510EE0000000049483045022100F1EE8E4635471C9BB94557E3A7DB5B7635BCAB47108C7C0EED30500F2EA7CDF80220678B111C852E23FB0C096487098B40EC08BBAF887380042845A2338C7535B92001FFFFFFFFD770AF35002A9723E46F7709A473A51E5A03435FEA4C581B9D26F1A3DCB3EFFC000000004A493046022100F85681BDEE6F0BC373F229964997A3F9461158EE9C9B3D3CA886A893AB7A3A99022100971CAE746339647306AD3E1020E200AC642F56996B634E14A4BBF81E0981127001FFFFFFFFD7975746C1E3062D7762824B02C3F3711D6574CB9C939B7A775DF361FC3955DE0000000049483045022100F06164BAF12930F53E49F3541377502071F40CC6E5F04B7784241C6323A2DA81022008B18F104351F2104DF81023DF651A12C645688226FCD68A7C1A2AD95756D00A01FFFFFFFFD7BD3D009192FEECE5970BEEC1CC9AA93827A9A3C10DBC1F09418E92F610A397000000004847304402201B65434B05E4E654ED25F4FBF852294649EF4DACFF6B07CEE0D40DEAA753E0E502205C7FABD2480449127DCB6A4A25B24E843C3C636EDEF7FD9A05E6D1A2E37EF9B501FFFFFFFFD809725292B979FE00B18D7889A0023CC297759E2A8ACDFA17D1BF1D94B20C6300000000484730440220768519ABE4D029EB1DF8C4A3904299AA1890A52DC65FF17977F617F370E55BEE02202D92FF6CE7DE48DEC50A7904106FB31F33AB1F5D019C7940C5ED1AB0DF8F665101FFFFFFFFD884904C91C93EB210C9DE12F74E59660741D6B3D16ECF41001DFF66A92DB9A7000000004948304502205D55C41059FB7A56828EB2A54285E310E6CC904CA07896D3113764C596EA34EF022100BCDFEEA94EA15CF44FDCB0D824D80F52793C0915F3673E989FC28EA86B414C1401FFFFFFFFD8F1560900B263C89FD64DBED054E743BB834D3C028EA86E3418A17ADD48DFAD000000004A493046022100835AE082E3E1D5D4F3FB1D7F45FE2D27A0706E81BAF2E5BA44D12A2890752B5B022100E05A652770598DCCB3DE04620349A708CC3ACBEC3C83C168ADB02DD7801C28EB01FFFFFFFFDB0B0946CEB1AA08EA180CE891697BFE5A3038645EB46B95E7D784ADF1C61916000000004A493046022100F72374764265658EAB57B6B6B6680CFBC31FDB72930FEC37F41139D01A28955F022100A66549EDC1A75AAC7AFC0EFF6F93A9ECB6497D8F732B536AB71C02584A78C8AF01FFFFFFFFDB198FAA18FDE5D4F30B43D9C14CFF7B840C201D0022E3F805EB5DE7FB6059060000000049483045022017FAB63A25641B6BEB4239BF52BBDA8BE2BA1C090CC075A1332A9458B37EEFDD022100B034601631EF555859FE3A842CCFE59273DAB0494361F35D1CD641A0455F2F6701FFFFFFFFDB30E300E71E1127A999BE13195E6D220357D434669C94B92BA07F96CE65F5200000000049483045022100D384857C752FDA11EC47726CD1D414979991E8F5F6A21DFBBA04BD895F658A3102202D2AC7E22240CC4A94C0EFF3D900C800680EF92AE556499288BE24AAF870518E01FFFFFFFFDC4EDF1736358E38C69C72176B7126CB9A3CF751C7BA3F75E12CBAC508342BE6000000004A493046022100F961A53BCC28ADECACD2B500747A8DF6BDC6864DCFA9E83B18AF19C904D5B5F1022100A477E051EE9B4ABA7A2C23F9AD05CB230C213491FE9129D2A496139D0EFBC49201FFFFFFFFDCD0D03940D177BB3AB7B6F1B859F7469DC4695DCC1A1BB206BE79477B89034A00000000494830450221008ECE9B49580BA4E1F274C8A9E1B11B73B13B51644D49BD02AFDBC95CE157B141022071CA0FEF8A61D26F3C5D64CD2E5A38C8FC62050AA234AEF8F5B120352E80B25101FFFFFFFFDD54D8F06D748AD47E7BEA8ABDACB89708E9F8DD36190B4DE64EC3990D476B2C000000004A493046022100B11D5ED42A83B6BEF7FAB193897AA1104CC656398246FD1548798D9CA6D7D95C0221008DEDC2EE4F9042549734C3D3BB0B745231CDD02D323151FB5EF3C69EB96789B901FFFFFFFFDD621D9E711348E98349EFFE8A9997D4E5BAB45AD99853CDEB48A43A0430AA3900000000494830450220111DB279383219491F648C6A59260F00966E3D2FB84B4E6AC6E85D272DCBFFB5022100E32D9A475371CE94B98B6A5B3FDC4CCA5CC840AB1DC137BFE800C74176C7C40C01FFFFFFFFDD8ECE78AD86D1D368CDEB8C59B09A1E6470CC5ABDF7669E5C2D5DB3C090471D000000004847304402205B3DB2AC3D6A10BED97F3F3EF3C83AD1421009120B456597670B94BF1A4A181702207905C50CDC12A82338781F5B093F0F95A5A495B01035FCEDB414345128DA702401FFFFFFFFDDAF73230B098737CE80CA081D26DA02F25666FD8BB77077616E6F3FCEBD0693000000004A49304602210095EC3BA7088FA8222803B85672ECFEA666A7E851AF49CF420AA19775B8FF331A022100A9139DA820B69498ED7BF083C1A516E24ED780D5AC8EFB6F35332A0B43DACF0301FFFFFFFFDDC11DC17D717F175E1A683EB4B435D1ADB35992EB70244C3646BE80EB8272DD0000000049483045022100FB515756A05E5651A5B2E597158CD2BF0F81A759C15B38FA798F92A197DECB7502202CC50CB2073A1FF448586DED01C3BDAD34B5DBB1A4A9EEE6C02AD80DE047DE6701FFFFFFFFDF34BEC6F13DF98F91EDFBCC8B6E3A6A8A71EF040C6522B2A56030D546D87AF50000000049483045022100B28324E9031C3FE397A505D03C4ADBE6461F5C5AA58E2DE691545551F8B24183022070D565349DF87B34E9CBB628244A278D044162DBFB9C9F8746D1448634BF561401FFFFFFFFDF5AD4D603E79ED672B90B05BCA4C4A326508B743F189889BEEA3EF12C803AE4000000004A49304602210080690306B4C5B37CE3497D71A49334A46184508AEF5F7EC26D1ED2C6A81E94C9022100B7DC2B03C16A1139687795DEB73B257764531D5D60CCDD1FC18ACA54F0909B8D01FFFFFFFFE253F6EFE8D88E39AF4F45BC4D87BE7473AAF2B3BF1634D96BCF6B97554BADA3000000004A493046022100EA97E7C111ACD32D7EE497A227E32985D0482673760A6D9D477F38AB06B0B96F022100AC2B692E4B83ACBD12CC192CBF802A76BC6FE541DDDABB3DE34C38B90CE946ED01FFFFFFFFE2A95E7377B39F2F70BD42A6A5DB0F2A81DA9DD12AC89EE77D7EC2E9B2AFBEE6000000004948304502205A2A6F5F8641B99B64F60E6820B62A0EBB92E715F6735784F3C8F62356133B3502210081788972D45AA1CDF198236BB8C50C0720FFD448029F0FAE769249E184FCA3D701FFFFFFFFE4D252AA5064A79A3D94034E36BA11559634049B5CFEB049BD2E749C863ADF590000000048473044022044EE0785AF4965813DB1C10C7EC553BFA437E8724A62172BECF06C3C6BAE442A0220165D6C9681E9DD711146E1A24982CA0F1A3F7B4F75EED475377BE531F1D08FE701FFFFFFFFE4E6F3E455B6DE2FF41ACF4D38BF020D2985DA0C55F3F393264F1CBEB26038780000000049483045022100F31FA08D9BC223B82E8913425249E42E6A8A319A418F3F4A6173E0E4DA23B30402207B31D68597BF0807A4CBE74781E799BE0598C418F59D4E8C8BD2B8D5279FCB0A01FFFFFFFFE4E79CEDF60F92DD8E2BFF4A212BAE82EC2AB32A19D291F873A52A8404219044000000004847304402200DA8A460A3201ABAC60A7F075C866FAB087EBA23BEA4E0CCACC57B06FC349E4202203F6577F8BD7E1BD551EF86E961D84D46F16A1E0B1D4C4210484DF0CB09F3CC4B01FFFFFFFFE5F3F031E73AE0DE965D8DF6E2F9C0CF810C5B905310945A31DFCA7CA39D23D40000000049483045022100A28C32DE6EC4068592A2B41C05E12FA1BFAAC4D9A646E6512C820BC0A89EB0D402206FFF73AA7D11B65899A63022D44804CECE1A0669E033CF509523731C1CFD6D8C01FFFFFFFFE5F953A0F61F8FAF62D98AB6A6297B6522BAE1CB79BBA3177C8B67342F67E693000000004A493046022100E7BE1D671816A7A444203A35FC7F742F0805EC5D84B206A2276A4988089CE435022100A75A1CFAC94F6C62DA9982913FA1D733C8ED0CB5EEFF1FCA7048240C615E152D01FFFFFFFFE6CC6293CD211A4FE704E9844899EB3E1F600C126901F93170FA0A1B065CA0D200000000484730440220241E6AED01B510D1803B502574B826BCCFED1615A31FE31A287B310A7C234A17022033CE89B10B33C0055892B855DFA4B50A1C6022587794FFF8850B9FF61FC0DB6901FFFFFFFFE6FF18B6AB1F74CF4027121E58EB319CFBB673634BC2B0B4AAA9F8DEC53CFC8400000000484730440220445E33890C552D1D6191B4D686711B32E2316F51E44B210C87B232CD0574689B0220029D92FB60B2710973E097CC7BA52CEBF78635B2A24D3C6DA9BEE9BC24DE649401FFFFFFFFE72FBA813859FAACDE0D1F15DAD3DEE0A8DE3114052EC4DD573D26EB29091DA8000000004A493046022100959A01CE70461F18CC04BD1CF95B8AF540AB2E908C5257B099207308CF0118A2022100E38017660993FDD65AD7CAAC3CBCBCA95359E00B6AB261783E847EFCC1D8B5ED01FFFFFFFFE74EB34B26AB31D8A07C06CBA572BBF14154AE7D68AA5ECC2A981B50F5F3B67100000000494830450221008D7458EFBEC4331253D5357950A180A0BD983DE0B308242111BB148188C027CD022005C8E9012032D68DF232D899768063D0AC6636205A881657A35371917D7D708701FFFFFFFFEA0D6050E3B3743C50931DFAAA57B3B1889AC76975050132FC93727E7D5926650000000049483045022100CBEEABC774479AEBA630A72F334A98D228BBAD919A34D1CD01DF707AFBFB911702204E2D8E0C6BA60580A93B4846A1DFDFF0DC3023E26310672CA85AF4C4641400F401FFFFFFFFEA9D80887C4DBC68EBE4E7AFF3F42E4F641486C0E3B9D06BDAAEED39B9A6D5C90000000049483045022049F0C2B73C239A39EF7153A10B89EFDD343D47810209D83A42756161E8D193D4022100E71CED0887B71BE9FB375692517D31A5BA42547F9C4E883F635E4F132F23208501FFFFFFFFEB97DD4305C3FAA44499AC00FE5C8F335C5F3DC8A5793621AA2FCD15C637404B0000000048473044022078A9FC630E59DA0BBDE83B2B5E60668A68EB23DD12670A4A3A91DD626D98AED802203462875836DF62E038D8DF2DD1560E15979F07D806852CF4B5B2FDC93B42327E01FFFFFFFFEBA9D75F1627E1497C301CB796116AE641D34440237D7DBDA246E74A16DB280A0000000049483045022100FF55D0343060B2875CB34A26DD10621873E56952E3C45769B1B815E785734A2F02205D6E5F6A0309B93F670A32534CCCC9AD4D28BC1005CA8D49712194E59A69E7F701FFFFFFFFEBF07EA14CBA7FB299D7A71212AFB98A84A4FB3FF8DB42CDAAC3C46EE2F7D5A70000000049483045022100E26F18173150BB2BF0E5B2130B84C0BF0FC92706AE979B6F4552D3B1F74D6907022003C3E8AADFB4BD61D9BCD987B8AEF8773038A5112985AAE93786F9BE5149887501FFFFFFFFECDC5B53E2F1D880FD5510DF997323E0FA9A77EEF734DD34F4D2D4471D5E7BAA0000000049483045022054FE96102C590C71ED72BA884D5566DC19D05FD0F4C4B2356A2727CA8F70BC35022100FFB9EC17344AB8658021B9C5D1E9764008D61C5FF5D4F08778A33417F1A2DE8D01FFFFFFFFECE59E7CA8A10FA6C550F0F157B8AE7541A7C46287980B71EBBF32EC9FD86A0F00000000484730440220244B3A33967C8B633C73F8BE5796B27976723C15FB61A5D44D527FD581E7DF3D0220637B4C32434AC41BB7A72CF8CF604B463E55D624B3DACFCB46C20BE2179D3FB701FFFFFFFFED2095875649A6619EFEED6CC2734E0080ACDAF30EA190BF7DEC0724C1BD029E000000004A493046022100FF43C2EF0E270630F6C7FA230FA067C195867C3E13BC7EF825D041C0C8D55B7C022100EDAE02BEA39F69D643805AB8BEE2AF3E84450EDCE29A76F66225C67A2476C4F401FFFFFFFFEDFB27A0473501362827BE21FBB5B7A099F9A775B86EDA5D3FC886583D3539920000000049483045022100BFF29AC87FF41DBCB9CC8264927FB3E6FB075B7F275199EE1461540093A3BF32022066BE4DC056B1DB891A33BFD8F93EF656096CE9A5FF2FBF0E188541C13141EE1D01FFFFFFFFEE57CE53F0FFA6B6FAD84D3A8F482A92B605DBFA7E4BB872DF3D216A933B5A400000000049483045022100A589C67AF00412FC707D332EF654E2181C2ACDBC3C305E1F199B098A25C5A2270220776C1D75E9EBA7ED3D5EB8F4F1DEFA84A6229800AC19B4BB6245D313BED1B26A01FFFFFFFFEFB58708C9596916D1F3F3919D7BFB900EF37092FF4663BF60C471FD3B8FCFA0000000004847304402203A453E89FCBE52A4D5137A6DACCC9880FF160B76844F80BBE5BB7C8EA6472FB7022070FB6A06497F93EF73FCD83C641FB1B18B4343F4A4F91CA039E5FD6C50E33FCD01FFFFFFFFEFF2C490319560A844BB813ED78E82094547393473DD919B3C8EBAA05083337D00000000484730440220769BA8B826BB12C3E321911186F01706D43B4A769FA6BFE1A115D216FE494A890220164C8DA13F48345AFE37E0867975155C83646276C6FAC6B66CE30324F87B087501FFFFFFFFF281FE59D51C0BCC4ABAAC5B19A043F34B722B75D78659CFBF730490083DD9D100000000494830450221009C876B9421E0EA9193DAD73308799F7E958325198E577679CB27FB321D895BC60220571F8BB1773579915DF05991B6BE586FD18763B2CA1437D01CCF2704443F455E01FFFFFFFFF2C6ADB61451A99C4E72C165936E8724BFD403F4F4B24104820FA1D5E7A87B46000000004A493046022100EA78E3D438AE9BFD930D3C7D08D3B9FB5622774983D0D1E927C23EDD251807CB022100ADD43833D586EDA7A2BBE1D8D8CD39170276AAC9EE28A4790F66A36FE5D8690B01FFFFFFFFF4E086390D0340E8073D7C175FC21DE2C6725004C20B2CE144FE5F087CBD26460000000049483045022100DFFB11F832C6BC5CE87CA237E0798A1A990FD69DEA0D91C36987AEDB9E31C9F30220571F8EC38D26A9775273DCCD7CC71B53CB819F8DE538C51EAAA805B16714CAAA01FFFFFFFFF4EA8527EC471A522550C9B94E1441D686A9471421739C2498B3EB40C6685C8A000000004A493046022100CC57AEE9BC1D7EEB9D2BF0648036883816D9A837372F35C15A6AED1D81E353C20221009A0D3C2A242487AA3E81BAEA830C4E401DAA8A293346F0D0E8D0880B4A657AFA01FFFFFFFFF6F4064C44498F2074C98B39A4C3637617688616A03256C389435D5AB9020884000000004948304502206111B04FF00D86769B13A4F1CFCC2BB97F1922967B167DC76C42BF9821759DB7022100EF2B80A7C586A7BF2AED91CD1E57C828F85B9E56C8DA0FDA6C5AFC336F84E3D101FFFFFFFFF71DDF9B8266E537740DCF4EF501402970F44C83D52D36C9918725450FA665EB000000004847304402202F45C00324DF41CFFFC0F72BAF31B97F9F8A5461BB046F9FA41BD3A5D9D5F72D02201CADFA9CFA1D7265793020906E4CB716EC352BD9BED87DF75E7172900A4A13D201FFFFFFFFF772FE491B5B8F9DB3E7ACF989AE3CB6C805CDE1E8B437B6A50A6C7F40B229CE000000004A493046022100E9B2FF943EABAFBA5C4621FAA5E2CDE760FBCD365F58F46F1CFFA3D399FF43C0022100B8D4145E99A97FCBDF604EF6318FC211C8BAB5357697128E3AFB35B86DB5696301FFFFFFFFF7D0EF928F782C6590F1BCF47482CC9A37E32914D1CB195646F98039FBB3D5F8000000004A493046022100ECA9759FBC7BE7806AEC3E7A76786707C9CA9C6233F72D61B36EBCEA6A171C4F022100A8AB735A26A5669E95B3317E3EB055F84B141B936AFA8EC98B8E4CEAA03914C901FFFFFFFFF824BF0D535431386EAEBE2D6B783DAE0C7927656F75EA8072D851ADD140BCC9000000004948304502200A65AE91810E89499D5EDE10F02CE32B17F1BD7A73E8B4598535FFE5755874A4022100969BA2337CC7569AAE0ADD2A4E01386A4F9303388A483E40C669B5961846FDED01FFFFFFFFF86D6A31B28217A5AEF130C6B9B62802A68686A144408DDA51544BF52248515600000000494830450220371FC2A7115D4CB6A565B4E5C9F2ADFEF0D1A86C9E4882D02D633A954632AEBD022100E9E00146B6F11B36835C7AE29549E43570804B59FF5EFBCC637308B045B47BCD01FFFFFFFFF89CD618F2207BE265204D3395192E9A89A07C676424F1658EFD83EAE0655769000000004847304402205C3845FFE0C94BD687BF4D7B1CDA768C8CEC950FFE6A2B490AFC57A222022D9C022025144819035815D9304B95865A21CB272DEF88F6779706CE193A64AEE276AA9C01FFFFFFFFF9C9A09692125225D6F50C47F826DA1FF249CA686EC4796B4F4506F0523DB9DC000000004A493046022100F8E1B186A0DA0A7E6512810CF52209BAA2E52642E749B4A5B366ABD18666B018022100E67621A713064CECA95CB501D00A07E529E9BE469F482FC03828C65A30DE16CB01FFFFFFFFF9D8B76C7643AB980C66A54814BEB84D371F43B94BC76F5CD302D27E067210570000000049483045022100FA42041B5D73C8B299773C5006ADE152ACF2E67C1892A2A53325B442724C42E10220246780CEE7E8D121897E9F09C8222D37C0C26C9B032B41B7386890E526D694CF01FFFFFFFFFA28410FBD5DFD1771B2671E63F1ACD5146C72231D239C737749011FA8AA06EC000000004948304502203F41C1036DC1265A641039AD4914C4FA99D385E8DC8BAD222BC84DCDAFB418AA022100BD9611921120886FE3F2955E0DCFE88CA58934336FB54C70DA678A82775F356F01FFFFFFFFFB7E970C150F457E830480A9ECDC7D52B1F1E089814DD9F3E786DD9B63854CB20000000048473044022054EAE691DAB6EDFAB71583B69375121548EF6E994E0A1D385CA429A5633FA5C9022021CFC06D223864110D119A90DA3B11FEC09881C9255E7D06ED8C9B37A0BB739E01FFFFFFFFFBC596D8594AE6A007DDAA87EF0DB1F820076BC27342944E2DD8C6890B392D130000000049483045022100A7C042DED948E6079B2CC6D98DB02BBC79C2410D80E8CE712C880A7BED1DE71D02207CBC291DAAE75134204A10D8A12BFD4548D97ACCE0EFAB0AD3967AD57BEF87FC01FFFFFFFFFE1E9A8E1B22F0E81BEE126A92BA0B3BE4B16C137B94E6AC83876F488407BE230000000049483045022100EF00E4121F13F8B3D6EDDCC94AE1A9BF1C9AD2AC72D08F599F68D0C36036E1D702207B8FAE05518B7782659C35F9932EA114995E809CC07E39F4B1EC6526AF73D9EF01FFFFFFFFD316084E396DAE4DF68A22D7538E7B623B04602029CD5D7A957F89EE9FA7731C000000004A493046022100ADE700CA5D93559DF5A4986E8D9C43C33D6A4E204ECF785921279BB5419F62C7022100D101A7A5488F955E90EFD41E5293A6C87BB955EDFA94EAFE30796F8D2D95A76601FFFFFFFFB79ABD47EF890602A23E2A7EB8D12B6D448A8EABD907D2A58AE22C900EE2E4920000000049483045022100C7ED449F532F5BD236196C5075092C3C0E7307877AC4E8B446DE17F623412881022002EF45165A8BD0306AD24D080BAB804095C67C91DA2C48F8B3AF9F8E3170A8F801FFFFFFFF01007A5894750000001976A9147AA6DC533BC3D2BA2245643115C77EB3EAC121AB88AC00000000"

    tx = BsvRpc.Transaction.create(Base.decode16!(tx_hex))
    tx_bin = BsvRpc.Transaction.to_binary(tx)
    assert 8617 == byte_size(tx_bin)

    <<start::binary-size(20), _skip1::binary-size(1000), middle::binary-size(20),
      _skip2::binary-size(7557), finish::binary-size(20)>> = tx_bin

    assert <<1, 0, 0, 0, 74, 156, 220, 232, 224, 167, 190, 136, 149, 53, 77, 139, 7, 218, 69, 42>> ==
             start

    assert <<73, 48, 70, 2, 33, 0, 207, 5, 73, 173, 236, 197, 86, 69, 90, 181, 191, 97, 215, 166>> ==
             middle

    assert <<210, 186, 34, 69, 100, 49, 21, 199, 126, 179, 234, 193, 33, 171, 136, 172, 0, 0, 0,
             0>> == finish

    assert "7DFF938918F07619ABD38E4510890396B1CEF4FBECA154FB7AAFBA8843295EA2" ==
             Base.encode16(tx.hash)
  end

  test "transaction with multiple outputs is converted to binary" do
    tx_hex =
      "01000000018C40F3C4B631C09933492E65974A75DD144E8ED68DEF564431CEADA961E796A8010000006B483045022100FF1FCCC31B9E2261196E95DF20C8AA16F5EEE2D732A81789AE8D3AA4E561D6AB0220283508814372BD6121E9401C8D3DF5650A148924F71F2495438A618F6C761F84412103CF770689EB67BFDECDD4CEC105FE537C8D97C8FA4A87C6B5CA2AD2A0012E8B1CFFFFFFFF0260AE0A000000000017A914996CD7093EFB1C9776E238CEB0E4C47C5A36CAF587B4124000000000001976A91487565A68A79DBD3927C219C4F9E36E2864D3D2FA88AC00000000"

    tx = BsvRpc.Transaction.create(Base.decode16!(tx_hex))
    tx_bin = BsvRpc.Transaction.to_binary(tx)
    assert 224 == byte_size(tx_bin)

    <<start::binary-size(20), _skip1::binary-size(82), middle::binary-size(20),
      _skip2::binary-size(82), finish::binary-size(20)>> = tx_bin

    assert <<1, 0, 0, 0, 1, 140, 64, 243, 196, 182, 49, 192, 153, 51, 73, 46, 101, 151, 74, 117>> ==
             start

    assert <<247, 31, 36, 149, 67, 138, 97, 143, 108, 118, 31, 132, 65, 33, 3, 207, 119, 6, 137,
             235>> ==
             middle

    assert <<189, 57, 39, 194, 25, 196, 249, 227, 110, 40, 100, 211, 210, 250, 136, 172, 0, 0, 0,
             0>> == finish

    assert "3F18A5F830BD297F83439992672D7C99E2FF4E54BA7C2199043FD47F8B8D5BF4" ==
             Base.encode16(tx.hash)
  end

  test "create a transaction with change" do
    {:ok, to} = BsvRpc.Address.create("1wBQpttZsiMtrwgjp2NuGNEyBMPdnzCeA")
    {:ok, change} = BsvRpc.Address.create("18v4ZTwZAkk7HKECkfutns1bfGVehaXNkW")

    utxos = [
      %BsvRpc.UTXO{
        transaction:
          Base.decode16!("4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E2CC77AB2127B7AFDEDA33B"),
        output: 0,
        value: 5_000_000_000
      }
    ]

    {:ok, tx} = BsvRpc.Transaction.send_to(to, 4_000_000_000, utxos, change)

    assert 1 == tx.version
    assert 0 == tx.locktime

    [input | rest] = tx.inputs
    assert [] == rest
    assert 0 == input.previous_output

    assert <<74, 94, 30, 75, 170, 184, 159, 58, 50, 81, 138, 136, 195, 27, 200, 127, 97, 143, 118,
             103, 62, 44, 199, 122, 178, 18, 123, 122, 253, 237, 163,
             59>> == input.previous_transaction

    assert "" == input.script_sig
    assert 0xFFFFFFFF == input.sequence

    [output | [change_output | rest]] = tx.outputs
    assert [] == rest
    assert 4_000_000_000 == output.value

    assert <<118, 169, 20, 10, 63, 39, 5, 95, 134, 238, 22, 182, 35, 80, 229, 135, 46, 13, 197, 9,
             176, 72, 193, 136, 172>> == output.script_pubkey

    assert 999_999_772 == change_output.value

    assert <<118, 169, 20, 86, 209, 229, 225, 200, 165, 160, 64, 184, 37, 55, 2, 13, 124, 118,
             184, 15, 15, 111, 242, 136, 172>> == change_output.script_pubkey
  end

  test "create a transaction without change" do
    {:ok, to} = BsvRpc.Address.create("1wBQpttZsiMtrwgjp2NuGNEyBMPdnzCeA")
    {:ok, change} = BsvRpc.Address.create("18v4ZTwZAkk7HKECkfutns1bfGVehaXNkW")

    utxos = [
      %BsvRpc.UTXO{
        transaction:
          Base.decode16!("4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E2CC77AB2127B7AFDEDA33B"),
        output: 0,
        value: 5_000_000_000
      }
    ]

    {:ok, tx} = BsvRpc.Transaction.send_to(to, 4_999_999_770, utxos, change)

    assert 1 == tx.version
    assert 0 == tx.locktime

    [input | rest] = tx.inputs
    assert [] == rest
    assert 0 == input.previous_output

    assert <<74, 94, 30, 75, 170, 184, 159, 58, 50, 81, 138, 136, 195, 27, 200, 127, 97, 143, 118,
             103, 62, 44, 199, 122, 178, 18, 123, 122, 253, 237, 163,
             59>> == input.previous_transaction

    assert "" == input.script_sig
    assert 0xFFFFFFFF == input.sequence

    [output | rest] = tx.outputs
    assert [] == rest
    assert 4_999_999_770 == output.value

    assert <<118, 169, 20, 10, 63, 39, 5, 95, 134, 238, 22, 182, 35, 80, 229, 135, 46, 13, 197, 9,
             176, 72, 193, 136, 172>> == output.script_pubkey
  end

  test "create a transaction with insufficient funds" do
    {:ok, to} = BsvRpc.Address.create("1wBQpttZsiMtrwgjp2NuGNEyBMPdnzCeA")
    {:ok, change} = BsvRpc.Address.create("18v4ZTwZAkk7HKECkfutns1bfGVehaXNkW")

    utxos = [
      %BsvRpc.UTXO{
        transaction:
          Base.decode16!("4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E2CC77AB2127B7AFDEDA33B"),
        output: 0,
        value: 5_000_000_000
      }
    ]

    {:error, "Insufficient funds."} = BsvRpc.Transaction.send_to(to, 5_000_000_000, utxos, change)
  end

  test "create a transaction with custom fee" do
    {:ok, to} = BsvRpc.Address.create("1wBQpttZsiMtrwgjp2NuGNEyBMPdnzCeA")
    {:ok, change} = BsvRpc.Address.create("18v4ZTwZAkk7HKECkfutns1bfGVehaXNkW")

    utxos = [
      %BsvRpc.UTXO{
        transaction:
          Base.decode16!("4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E2CC77AB2127B7AFDEDA33B"),
        output: 0,
        value: 5_000_000_000
      }
    ]

    {:ok, tx} = BsvRpc.Transaction.send_to(to, 4_000_000_000, utxos, change, 2)

    [output | [change_output | rest]] = tx.outputs
    assert [] == rest
    assert 4_000_000_000 == output.value

    assert <<118, 169, 20, 10, 63, 39, 5, 95, 134, 238, 22, 182, 35, 80, 229, 135, 46, 13, 197, 9,
             176, 72, 193, 136, 172>> == output.script_pubkey

    assert 999_999_544 == change_output.value

    assert <<118, 169, 20, 86, 209, 229, 225, 200, 165, 160, 64, 184, 37, 55, 2, 13, 124, 118,
             184, 15, 15, 111, 242, 136, 172>> == change_output.script_pubkey
  end

  test_with_mock "fee is calculated correclty", _context, GenServer, [],
    call: fn _module, _context ->
      "01000000024fc9d5b1142f83a9778c2d0ff054c83d95b68bbb569020dab23dc76223304a0b010000006b483045022100a07d6a99d87b327574c4398248f4890a36dad4011b602b488d14aa2dbdbf2ace02204570a0f4d9075f34acb65c0caf62d7e1daca1d8311e6840778376b8a4c3e5e6f4121035773e636bc13ebe9f49dc077dce4c9c5e18168133123352d7957159f8e3a8d54ffffffff2ef1e20c17130d20660728f89e10ae8fdd4ddb83832034fa16268b3aa83d3ad4010000006b483045022100908e7ccd4ce12419cb3c618bbc7121eea0036aa6c4ac250b15a42eb84fb99d72022032b4ff69fd16007ed8be1299835e4581bfafe59d09e88521481dd718d35c0aee412103b350536efa8a004a50369a02ae1b04ebf5855456d35a18c4115b808057d168beffffffff02c0cf6a000000000017a914690f0f15d469ec9d6e7f4346d76fe94abac2803787f0071c05000000001976a91456198dbb2c1c991443cd6e297d36f93a927ca77f88ac00000000"
    end do
    tx =
      BsvRpc.Transaction.create(
        Base.decode16!(
          "010000000114F6E0A8242018CEFA4236493377023331E5AB4E981729557A8AAC33A58AD372010000006A47304402202C2605D54CA2FCABA8A75456BEA39C2B2D7AE744F562D06990A449E5F5A3FEBE02200BD37B90DA97D0E69ED2B3F91D82E5D4344564CF5B699AD1AD7F232888C815FC4121037328F4FA4F446697A5984F9173928D5AE5A64CCD58576F3C73E4C794CA759ECCFFFFFFFF02E06735000000000017A914690F0F15D469EC9D6E7F4346D76FE94ABAC28037872D9FE604000000001976A914F249783130CC20934267803DB3C037A21FF9E2DD88AC00000000"
        )
      )

    assert 227 == BsvRpc.Transaction.fee(tx)
  end
end
