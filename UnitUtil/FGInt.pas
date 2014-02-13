{License, info, etc
 ------------------

This implementation is made by me, Walied Othman, to contact me
mail to Walied.Othman@belgacom.net or Triade@ulyssis.org,
always mention wether it 's about the FGInt for Delphi or for
FreePascal, or wether it 's about the 6xs, preferably in the subject line.
If you 're going to use these implementations, at least mention my
name or something and notify me so I may even put a link on my page.
This implementation is freeware and according to the coderpunks'
manifesto it should remain so, so don 't use these implementations
in commercial software.  Encryption, as a tool to ensure privacy
should be free and accessible for anyone.  If you plan to use these
implementations in a commercial application, contact me before
doing so, that way you can license the software to use it in commercial
Software.  If any algorithm is patented in your country, you should
acquire a license before using this software.  Modified versions of this
software must contain an acknowledgement of the original author (=me).
This implementation is available at
http://triade.studentenweb.org

copyright 2000, Walied Othman
This header may not be removed.
}

unit FGInt;

{$H+}

interface

uses SysUtils, Math;

type
  TCompare = (Lt, St, Eq, Er);
  TSign = (negative, positive);
  TFGInt = record
    Sign: TSign;
    Number: array of LongWord;
  end;


procedure FGIntShiftRightX(var FGInt: TFGInt; times: integer); {peta}
procedure FGIntShiftLeftX(var FGInt: TFGInt; times: integer); {add by peta}
procedure FGIntAnd(const FGInt1, FGInt2: TFGInt; var Sum: TFGInt); {add by peta}
function FGIntBitLength(const FGInt: TFGInt): integer;

procedure zeronetochar8(var g: char; const x: string);
procedure zeronetochar6(var g: integer; const x: string);
procedure initialize8(var trans: array of string);
procedure initialize6(var trans: array of string);
procedure initialize6PGP(var trans: array of string);
procedure ConvertBase256to64(const str256: string; var str64: string);
procedure ConvertBase64to256(const str64: string; var str256: string);
procedure ConvertBase256to2(const str256: string; var str2: string);
procedure ConvertBase64to2(const str64: string; var str2: string);
procedure ConvertBase16to2(const str16: string; var str2: string);
procedure ConvertBase2to16(str2: string; var str256: string);
procedure ConvertBase2to64(str2: string; var str64: string);
procedure ConvertBase256to16(Str256: string; var HexStr: string);
procedure ConvertHexStringToBase256String(HexStr: string; var Str256: string);
procedure PGPConvertBase256to64(var str256, str64: string);
procedure PGPConvertBase64to256(str64: string; var str256: string);
procedure PGPConvertBase64to2(str64: string; var str2: string);
procedure FGIntToBase2String(const FGInt: TFGInt; var S: string);
procedure Base2StringToFGInt(S: string; var FGInt: TFGInt);
procedure FGIntToBase16String(const FGInt: TFGInt; var str16: string);
procedure FGIntToBase256String(const FGInt: TFGInt; var str256: string);
procedure Base256StringToFGInt(str256: string; var FGInt: TFGInt);
procedure Base16StringToFGInt(str16: string; var FGInt: TFGInt);
procedure PGPMPIToFGInt(PGPMPI: string; var FGInt: TFGInt);
procedure FGIntToPGPMPI(FGInt: TFGInt; var PGPMPI: string);
procedure Base10StringToFGInt(Base10: string; var FGInt: TFGInt);
procedure FGIntToBase10String(const FGInt: TFGInt; var Base10: string);
procedure FGIntDestroy(var FGInt: TFGInt);
function FGIntCompareAbs(const FGInt1, FGInt2: TFGInt): TCompare;
procedure FGIntAdd(const FGInt1, FGInt2: TFGInt; var Sum: TFGInt);
procedure FGIntChangeSign(var FGInt: TFGInt);
procedure FGIntSub(var FGInt1, FGInt2, dif: TFGInt);
procedure FGIntMulByInt(const FGInt: TFGInt; var res: TFGInt; by: LongWord);
procedure FGIntMulByIntbis(var FGInt: TFGInt; by: LongWord);
procedure FGIntDivByInt(const FGInt: TFGInt; var res: TFGInt; by: LongWord; var modres: LongWord);
procedure FGIntDivByIntBis(var FGInt: TFGInt; by: LongWord; var modres: LongWord);
procedure FGIntModByInt(const FGInt: TFGInt; by: LongWord; var modres: LongWord);
procedure FGIntAbs(var FGInt: TFGInt);
procedure FGIntCopy(const FGInt1: TFGInt; var FGInt2: TFGInt);
procedure FGIntShiftLeft(var FGInt: TFGInt);
procedure FGIntShiftRight(var FGInt: TFGInt);
procedure FGIntShiftRightBy31(var FGInt: TFGInt);
procedure FGIntAddBis(var FGInt1: TFGInt; const FGInt2: TFGInt);
procedure FGIntSubBis(var FGInt1: TFGInt; const FGInt2: TFGInt);
procedure FGIntMul(const FGInt1, FGInt2: TFGInt; var Prod: TFGInt);
procedure FGIntSquare(const FGInt: TFGInt; var Square: TFGInt);
procedure FGIntExp(const FGInt, exp: TFGInt; var res: TFGInt);
procedure FGIntFac(const FGInt: TFGInt; var res: TFGInt);
procedure FGIntShiftLeftBy31(var FGInt: TFGInt);
procedure FGIntDivMod(var FGInt1, FGInt2, QFGInt, MFGInt: TFGInt);
procedure FGIntDiv(var FGInt1, FGInt2, QFGInt: TFGInt);
procedure FGIntMod(var FGInt1, FGInt2, MFGInt: TFGInt);
procedure FGIntSquareMod(var FGInt, Modb, FGIntSM: TFGInt);
procedure FGIntAddMod(var FGInt1, FGInt2, base, FGIntres: TFGInt);
procedure FGIntMulMod(var FGInt1, FGInt2, base, FGIntres: TFGInt);
procedure FGIntModExp(var FGInt, exp, modb, res: TFGInt);
procedure FGIntModBis(const FGInt: TFGInt; var FGIntOut: TFGInt; b, head: LongWord);
procedure FGIntMulModBis(const FGInt1, FGInt2: TFGInt; var Prod: TFGInt; b, head: LongWord);
procedure FGIntMontgomeryMod(const GInt, base, baseInv: TFGInt; var MGInt: TFGInt; b: Longword; head: LongWord);
procedure FGIntMontgomeryModExp(var FGInt, exp, modb, res: TFGInt);
procedure FGIntGCD(const FGInt1, FGInt2: TFGInt; var GCD: TFGInt);
procedure FGIntLCM(const FGInt1, FGInt2: TFGInt; var LCM: TFGInt);
procedure FGIntTrialDiv9999(const FGInt: TFGInt; var ok: boolean);
procedure FGIntRandom1(var Seed, RandomFGInt: TFGInt);
procedure FGIntRabinMiller(var FGIntp: TFGInt; nrtest: Longword; var ok: boolean);
procedure FGIntBezoutBachet(var FGInt1, FGInt2, a, b: TFGInt);
procedure FGIntModInv(const FGInt1, base: TFGInt; var Inverse: TFGInt);
procedure FGIntPrimetest(var FGIntp: TFGInt; nrRMtests: integer; var ok: boolean);
procedure FGIntLegendreSymbol(var a, p: TFGInt; var L: integer);
procedure FGIntSquareRootModP(Square, Prime: TFGInt; var SquareRoot: TFGInt);




implementation

var
  primes: array[1..1228] of integer =
  (3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127,
    131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229, 233, 239, 241, 251,
    257, 263, 269, 271, 277, 281, 283, 293, 307, 311, 313, 317, 331, 337, 347, 349, 353, 359, 367, 373, 379, 383, 389,
    397, 401, 409, 419, 421, 431, 433, 439, 443, 449, 457, 461, 463, 467, 479, 487, 491, 499, 503, 509, 521, 523, 541,
    547, 557, 563, 569, 571, 577, 587, 593, 599, 601, 607, 613, 617, 619, 631, 641, 643, 647, 653, 659, 661, 673, 677,
    683, 691, 701, 709, 719, 727, 733, 739, 743, 751, 757, 761, 769, 773, 787, 797, 809, 811, 821, 823, 827, 829, 839,
    853, 857, 859, 863, 877, 881, 883, 887, 907, 911, 919, 929, 937, 941, 947, 953, 967, 971, 977, 983, 991, 997, 1009,
    1013, 1019, 1021, 1031, 1033, 1039, 1049, 1051, 1061, 1063, 1069, 1087, 1091, 1093, 1097, 1103, 1109, 1117, 1123,
    1129, 1151, 1153, 1163, 1171, 1181, 1187, 1193, 1201, 1213, 1217, 1223, 1229, 1231, 1237, 1249, 1259, 1277, 1279,
    1283, 1289, 1291, 1297, 1301, 1303, 1307, 1319, 1321, 1327, 1361, 1367, 1373, 1381, 1399, 1409, 1423, 1427, 1429,
    1433, 1439, 1447, 1451, 1453, 1459, 1471, 1481, 1483, 1487, 1489, 1493, 1499, 1511, 1523, 1531, 1543, 1549, 1553,
    1559, 1567, 1571, 1579, 1583, 1597, 1601, 1607, 1609, 1613, 1619, 1621, 1627, 1637, 1657, 1663, 1667, 1669, 1693,
    1697, 1699, 1709, 1721, 1723, 1733, 1741, 1747, 1753, 1759, 1777, 1783, 1787, 1789, 1801, 1811, 1823, 1831, 1847,
    1861, 1867, 1871, 1873, 1877, 1879, 1889, 1901, 1907, 1913, 1931, 1933, 1949, 1951, 1973, 1979, 1987, 1993, 1997,
    1999, 2003, 2011, 2017, 2027, 2029, 2039, 2053, 2063, 2069, 2081, 2083, 2087, 2089, 2099, 2111, 2113, 2129, 2131,
    2137, 2141, 2143, 2153, 2161, 2179, 2203, 2207, 2213, 2221, 2237, 2239, 2243, 2251, 2267, 2269, 2273, 2281, 2287,
    2293, 2297, 2309, 2311, 2333, 2339, 2341, 2347, 2351, 2357, 2371, 2377, 2381, 2383, 2389, 2393, 2399, 2411, 2417,
    2423, 2437, 2441, 2447, 2459, 2467, 2473, 2477, 2503, 2521, 2531, 2539, 2543, 2549, 2551, 2557, 2579, 2591, 2593,
    2609, 2617, 2621, 2633, 2647, 2657, 2659, 2663, 2671, 2677, 2683, 2687, 2689, 2693, 2699, 2707, 2711, 2713, 2719,
    2729, 2731, 2741, 2749, 2753, 2767, 2777, 2789, 2791, 2797, 2801, 2803, 2819, 2833, 2837, 2843, 2851, 2857, 2861,
    2879, 2887, 2897, 2903, 2909, 2917, 2927, 2939, 2953, 2957, 2963, 2969, 2971, 2999, 3001, 3011, 3019, 3023, 3037,
    3041, 3049, 3061, 3067, 3079, 3083, 3089, 3109, 3119, 3121, 3137, 3163, 3167, 3169, 3181, 3187, 3191, 3203, 3209,
    3217, 3221, 3229, 3251, 3253, 3257, 3259, 3271, 3299, 3301, 3307, 3313, 3319, 3323, 3329, 3331, 3343, 3347, 3359,
    3361, 3371, 3373, 3389, 3391, 3407, 3413, 3433, 3449, 3457, 3461, 3463, 3467, 3469, 3491, 3499, 3511, 3517, 3527,
    3529, 3533, 3539, 3541, 3547, 3557, 3559, 3571, 3581, 3583, 3593, 3607, 3613, 3617, 3623, 3631, 3637, 3643, 3659,
    3671, 3673, 3677, 3691, 3697, 3701, 3709, 3719, 3727, 3733, 3739, 3761, 3767, 3769, 3779, 3793, 3797, 3803, 3821,
    3823, 3833, 3847, 3851, 3853, 3863, 3877, 3881, 3889, 3907, 3911, 3917, 3919, 3923, 3929, 3931, 3943, 3947, 3967,
    3989, 4001, 4003, 4007, 4013, 4019, 4021, 4027, 4049, 4051, 4057, 4073, 4079, 4091, 4093, 4099, 4111, 4127, 4129,
    4133, 4139, 4153, 4157, 4159, 4177, 4201, 4211, 4217, 4219, 4229, 4231, 4241, 4243, 4253, 4259, 4261, 4271, 4273,
    4283, 4289, 4297, 4327, 4337, 4339, 4349, 4357, 4363, 4373, 4391, 4397, 4409, 4421, 4423, 4441, 4447, 4451, 4457,
    4463, 4481, 4483, 4493, 4507, 4513, 4517, 4519, 4523, 4547, 4549, 4561, 4567, 4583, 4591, 4597, 4603, 4621, 4637,
    4639, 4643, 4649, 4651, 4657, 4663, 4673, 4679, 4691, 4703, 4721, 4723, 4729, 4733, 4751, 4759, 4783, 4787, 4789,
    4793, 4799, 4801, 4813, 4817, 4831, 4861, 4871, 4877, 4889, 4903, 4909, 4919, 4931, 4933, 4937, 4943, 4951, 4957,
    4967, 4969, 4973, 4987, 4993, 4999, 5003, 5009, 5011, 5021, 5023, 5039, 5051, 5059, 5077, 5081, 5087, 5099, 5101,
    5107, 5113, 5119, 5147, 5153, 5167, 5171, 5179, 5189, 5197, 5209, 5227, 5231, 5233, 5237, 5261, 5273, 5279, 5281,
    5297, 5303, 5309, 5323, 5333, 5347, 5351, 5381, 5387, 5393, 5399, 5407, 5413, 5417, 5419, 5431, 5437, 5441, 5443,
    5449, 5471, 5477, 5479, 5483, 5501, 5503, 5507, 5519, 5521, 5527, 5531, 5557, 5563, 5569, 5573, 5581, 5591, 5623,
    5639, 5641, 5647, 5651, 5653, 5657, 5659, 5669, 5683, 5689, 5693, 5701, 5711, 5717, 5737, 5741, 5743, 5749, 5779,
    5783, 5791, 5801, 5807, 5813, 5821, 5827, 5839, 5843, 5849, 5851, 5857, 5861, 5867, 5869, 5879, 5881, 5897, 5903,
    5923, 5927, 5939, 5953, 5981, 5987, 6007, 6011, 6029, 6037, 6043, 6047, 6053, 6067, 6073, 6079, 6089, 6091, 6101,
    6113, 6121, 6131, 6133, 6143, 6151, 6163, 6173, 6197, 6199, 6203, 6211, 6217, 6221, 6229, 6247, 6257, 6263, 6269,
    6271, 6277, 6287, 6299, 6301, 6311, 6317, 6323, 6329, 6337, 6343, 6353, 6359, 6361, 6367, 6373, 6379, 6389, 6397,
    6421, 6427, 6449, 6451, 6469, 6473, 6481, 6491, 6521, 6529, 6547, 6551, 6553, 6563, 6569, 6571, 6577, 6581, 6599,
    6607, 6619, 6637, 6653, 6659, 6661, 6673, 6679, 6689, 6691, 6701, 6703, 6709, 6719, 6733, 6737, 6761, 6763, 6779,
    6781, 6791, 6793, 6803, 6823, 6827, 6829, 6833, 6841, 6857, 6863, 6869, 6871, 6883, 6899, 6907, 6911, 6917, 6947,
    6949, 6959, 6961, 6967, 6971, 6977, 6983, 6991, 6997, 7001, 7013, 7019, 7027, 7039, 7043, 7057, 7069, 7079, 7103,
    7109, 7121, 7127, 7129, 7151, 7159, 7177, 7187, 7193, 7207, 7211, 7213, 7219, 7229, 7237, 7243, 7247, 7253, 7283,
    7297, 7307, 7309, 7321, 7331, 7333, 7349, 7351, 7369, 7393, 7411, 7417, 7433, 7451, 7457, 7459, 7477, 7481, 7487,
    7489, 7499, 7507, 7517, 7523, 7529, 7537, 7541, 7547, 7549, 7559, 7561, 7573, 7577, 7583, 7589, 7591, 7603, 7607,
    7621, 7639, 7643, 7649, 7669, 7673, 7681, 7687, 7691, 7699, 7703, 7717, 7723, 7727, 7741, 7753, 7757, 7759, 7789,
    7793, 7817, 7823, 7829, 7841, 7853, 7867, 7873, 7877, 7879, 7883, 7901, 7907, 7919, 7927, 7933, 7937, 7949, 7951,
    7963, 7993, 8009, 8011, 8017, 8039, 8053, 8059, 8069, 8081, 8087, 8089, 8093, 8101, 8111, 8117, 8123, 8147, 8161,
    8167, 8171, 8179, 8191, 8209, 8219, 8221, 8231, 8233, 8237, 8243, 8263, 8269, 8273, 8287, 8291, 8293, 8297, 8311,
    8317, 8329, 8353, 8363, 8369, 8377, 8387, 8389, 8419, 8423, 8429, 8431, 8443, 8447, 8461, 8467, 8501, 8513, 8521,
    8527, 8537, 8539, 8543, 8563, 8573, 8581, 8597, 8599, 8609, 8623, 8627, 8629, 8641, 8647, 8663, 8669, 8677, 8681,
    8689, 8693, 8699, 8707, 8713, 8719, 8731, 8737, 8741, 8747, 8753, 8761, 8779, 8783, 8803, 8807, 8819, 8821, 8831,
    8837, 8839, 8849, 8861, 8863, 8867, 8887, 8893, 8923, 8929, 8933, 8941, 8951, 8963, 8969, 8971, 8999, 9001, 9007,
    9011, 9013, 9029, 9041, 9043, 9049, 9059, 9067, 9091, 9103, 9109, 9127, 9133, 9137, 9151, 9157, 9161, 9173, 9181,
    9187, 9199, 9203, 9209, 9221, 9227, 9239, 9241, 9257, 9277, 9281, 9283, 9293, 9311, 9319, 9323, 9337, 9341, 9343,
    9349, 9371, 9377, 9391, 9397, 9403, 9413, 9419, 9421, 9431, 9433, 9437, 9439, 9461, 9463, 9467, 9473, 9479, 9491,
    9497, 9511, 9521, 9533, 9539, 9547, 9551, 9587, 9601, 9613, 9619, 9623, 9629, 9631, 9643, 9649, 9661, 9677, 9679,
    9689, 9697, 9719, 9721, 9733, 9739, 9743, 9749, 9767, 9769, 9781, 9787, 9791, 9803, 9811, 9817, 9829, 9833, 9839,
    9851, 9857, 9859, 9871, 9883, 9887, 9901, 9907, 9923, 9929, 9931, 9941, 9949, 9967, 9973);
  chr64: array[1..64] of char = ('a', 'A', 'b', 'B', 'c', 'C', 'd', 'D', 'e', 'E', 'f', 'F',
    'g', 'G', 'h', 'H', 'i', 'I', 'j', 'J', 'k', 'K', 'l', 'L', 'm', 'M', 'n', 'N', 'o', 'O', 'p',
    'P', 'q', 'Q', 'r', 'R', 's', 'S', 't', 'T', 'u', 'U', 'v', 'V', 'w', 'W', 'x', 'X', 'y', 'Y',
    'z', 'Z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '=');
  PGPchr64: array[1..64] of char = ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y',
    'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/');

  chr16: array[0..15] of char = ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B',
    'C', 'D', 'E', 'F');



procedure zeronetochar8(var g: char; const x: string);
var
  i: Integer;
  b: byte;
begin
  b := 0;
  for i := 1 to 8 do
  begin
    if copy(x, i, 1) = '1' then
      b := b or (1 shl (8 - I));
  end;
  g := chr(b);
end;


procedure zeronetochar6(var g: integer; const x: string);
var
  I: Integer;
begin
  G := 0;
  for I := 1 to Length(X) do
  begin
    if I > 6 then
      Break;
    if X[I] <> '0' then
      G := G or (1 shl (6 - I));
  end;
  Inc(G);
end;


procedure initialize8(var trans: array of string);
var
  c1, c2, c3, c4, c5, c6, c7, c8: integer;
  x: string;
  g: char;
begin
  for c1 := 0 to 1 do
    for c2 := 0 to 1 do
      for c3 := 0 to 1 do
        for c4 := 0 to 1 do
          for c5 := 0 to 1 do
            for c6 := 0 to 1 do
              for c7 := 0 to 1 do
                for c8 := 0 to 1 do
                begin
                  x := chr(48 + c1) + chr(48 + c2) + chr(48 + c3) + chr(48 + c4) + chr(48 + c5) + chr(48 + c6) + chr(48 + c7) + chr(48 + c8);
                  zeronetochar8(g, x);
                  trans[ord(g)] := x;
                end;
end;


procedure initialize6(var trans: array of string);
var
  c1, c2, c3, c4, c5, c6: integer;
  x: string;
  g: integer;
begin
  for c1 := 0 to 1 do
    for c2 := 0 to 1 do
      for c3 := 0 to 1 do
        for c4 := 0 to 1 do
          for c5 := 0 to 1 do
            for c6 := 0 to 1 do
            begin
              x := chr(48 + c1) + chr(48 + c2) + chr(48 + c3) + chr(48 + c4) + chr(48 + c5) + chr(48 + c6);
              zeronetochar6(g, x);
              trans[ord(chr64[g])] := x;
            end;
end;

procedure initialize6PGP(var trans: array of string);
var
  c1, c2, c3, c4, c5, c6: integer;
  x: string;
  g: integer;
begin
  for c1 := 0 to 1 do
    for c2 := 0 to 1 do
      for c3 := 0 to 1 do
        for c4 := 0 to 1 do
          for c5 := 0 to 1 do
            for c6 := 0 to 1 do
            begin
              x := chr(48 + c1) + chr(48 + c2) + chr(48 + c3) + chr(48 + c4) + chr(48 + c5) + chr(48 + c6);
              zeronetochar6(g, x);
              trans[ord(PGPchr64[g])] := x;
            end;
end;


// Convert base 8 strings to base 6 strings and visa versa

procedure ConvertBase256to64(const str256: string; var str64: string);
var
  temp: string;
  trans: array[0..255] of string;
  i, len6: longint;
  g: integer;
begin
  initialize8(trans);
  temp := '';
  for i := 1 to length(str256) do temp := temp + trans[ord(str256[i])];
  while (length(temp) mod 6) <> 0 do temp := temp + '0';
  len6 := length(temp) div 6;
  str64 := '';
  for i := 1 to len6 do
  begin
    zeronetochar6(g, copy(temp, 1, 6));
    str64 := str64 + chr64[g];
    delete(temp, 1, 6);
  end;
end;


procedure ConvertBase64to256(const str64: string; var str256: string);
var
  temp: string;
  trans: array[0..255] of string;
  i, len8: longint;
  g: char;
begin
  initialize6(trans);
  temp := '';
  for i := 1 to length(str64) do temp := temp + trans[ord(str64[i])];
  str256 := '';
  len8 := length(temp) div 8;
  for i := 1 to len8 do
  begin
    zeronetochar8(g, copy(temp, 1, 8));
    str256 := str256 + g;
    delete(temp, 1, 8);
  end;
end;


// Convert base 8 & 6 bit strings to base 2 strings and visa versa

procedure ConvertBase256to2(const str256: string; var str2: string);
var
  trans: array[0..255] of string;
  i: longint;
begin
  str2 := '';
  initialize8(trans);
  for i := 1 to length(str256) do str2 := str2 + trans[ord(str256[i])];
end;


procedure ConvertBase16to2(const str16: string; var str2: string);
var
  temp1: string;
  i, j: longint;
  trans: array[0..16] of string;
begin
  temp1 := '';
  trans[0] := '0000';
  trans[1] := '0001';
  trans[2] := '0010';
  trans[3] := '0011';
  trans[4] := '0100';
  trans[5] := '0101';
  trans[6] := '0110';
  trans[7] := '0111';
  trans[8] := '1000';
  trans[9] := '1001';
  trans[10] := '1010';
  trans[11] := '1011';
  trans[12] := '1100';
  trans[13] := '1101';
  trans[14] := '1110';
  trans[15] := '1111';

  for i := 1 to length(str16) do
  begin
    j := 0;
    if (str16[i] >= '0') and (str16[i] <= '9') then j := ord(str16[i]) - ord('0');
    if (str16[i] >= 'A') and (str16[i] <= 'F') then j := ord(str16[i]) - ord('A') + 10;
    temp1 := temp1 + trans[j];
  end;
  while (temp1[1] = '0') and (temp1 <> '0') do delete(temp1, 1, 1);
  str2 := temp1;
end;

procedure ConvertBase64to2(const str64: string; var str2: string);
var
  trans: array[0..255] of string;
  i: longint;
begin
  str2 := '';
  initialize6(trans);
  for i := 1 to length(str64) do str2 := str2 + trans[ord(str64[i])];
end;


procedure ConvertBase2to16(str2: string; var str256: string);
var
  i, len8: longint;
  g: char;
begin
  str256 := '';
  while (length(str2) mod 8) <> 0 do str2 := '0' + str2;
  len8 := length(str2) div 8;
  for i := 1 to len8 do
  begin
    zeronetochar8(g, copy(str2, 1, 8));
    str256 := str256 + g;
    delete(str2, 1, 8);
  end;
end;


procedure ConvertBase2to64(str2: string; var str64: string);
var
  i, len6: longint;
  g: integer;
begin
  str64 := '';
  while (length(str2) mod 6) <> 0 do str2 := '0' + str2;
  len6 := length(str2) div 6;
  for i := 1 to len6 do
  begin
    zeronetochar6(g, copy(str2, 1, 6));
    str64 := str64 + chr64[g];
    delete(str2, 1, 6);
  end;
end;


// Convert base 256 strings to base 16 (HexaDecimal) strings and visa versa

procedure ConvertBase256to16(Str256: string; var HexStr: string);
var
  i: longint;
  b: byte;
begin
  HexStr := '';
  for i := 1 to length(str256) do
  begin
    b := ord(str256[i]);
    if (b shr 4) < 10 then HexStr := HexStr + chr(48 + (b shr 4))
    else HexStr := HexStr + chr(55 + (b shr 4));
    if (b and 15) < 10 then HexStr := HexStr + chr(48 + (b and 15))
    else HexStr := HexStr + chr(55 + (b and 15));
  end;
end;


procedure ConvertHexStringToBase256String(HexStr: string; var Str256: string);
var
  i: longint;
  b, h1, h2: byte;
  temp: string;
begin
  Str256 := '';
  if (length(Hexstr) mod 2) = 1 then temp := '0' + HexStr else temp := HexStr;
  for i := 1 to (length(temp) div 2) do
  begin
    h2 := ord(temp[2 * i]);
    h1 := ord(temp[2 * i - 1]);
    if h1 < 58 then
      b := ((h1 - 48) shl 4)
    else
      b := ((h1 - 55) shl 4);
    if h2 < 58 then
      b := (b or (h2 - 48))
    else
      b := (b or ((h2 - 55) and 15));
    Str256 := Str256 + chr(b);
  end;
end;


// Convert base 256 strings to base 64 strings and visa versa, PGP style

procedure PGPConvertBase256to64(var str256, str64: string);
var
  temp, x, a: string;
  i, len6: longint;
  g: integer;
  trans: array[0..255] of string;
begin
  initialize8(trans);
  temp := '';
  for i := 1 to length(str256) do temp := temp + trans[ord(str256[i])];
  if (length(temp) mod 6) = 0 then a := '' else
    if (length(temp) mod 6) = 4 then
    begin
      temp := temp + '00';
      a := '='
    end
    else
    begin
      temp := temp + '0000';
      a := '=='
    end;
  str64 := '';
  len6 := length(temp) div 6;
  for i := 1 to len6 do
  begin
    x := copy(temp, 1, 6);
    zeronetochar6(g, x);
    str64 := str64 + PGPchr64[g];
    delete(temp, 1, 6);
  end;
  str64 := str64 + a;
end;


procedure PGPConvertBase64to256(str64: string; var str256: string);
var
  temp, x: string;
  i, j, len8: longint;
  g: char;
  trans: array[0..255] of string;
begin
  initialize6PGP(trans);
  temp := '';
  str256 := '';
  if str64[length(str64) - 1] = '=' then j := 2 else
    if str64[length(str64)] = '=' then j := 1 else j := 0;
  for i := 1 to (length(str64) - j) do temp := temp + trans[ord(str64[i])];
  if j <> 0 then delete(temp, length(temp) - 2 * j + 1, 2 * j);
  len8 := length(temp) div 8;
  for i := 1 to len8 do
  begin
    x := copy(temp, 1, 8);
    zeronetochar8(g, x);
    str256 := str256 + g;
    delete(temp, 1, 8);
  end;
end;

// Convert base 64 strings to base 2 strings, PGP style


procedure PGPConvertBase64to2(str64: string; var str2: string);
var
  i, j: longint;
  trans: array[0..255] of string;
begin
  str2 := '';
  initialize6(trans);
  if str64[length(str64) - 1] = '=' then j := 2 else
    if str64[length(str64)] = '=' then j := 1 else j := 0;
  for i := 1 to (length(str64) - j) do str2 := str2 + trans[ord(str64[i])];
  delete(str2, length(str2) - 2 * j + 1, 2 * j);
end;


// Convert a FGInt to a binary string (base 2) & visa versa

procedure FGIntToBase2String(const FGInt: TFGInt; var S: string);
var
  i: LongWord;
  j: integer;
begin
  S := '';
  for i := 1 to FGInt.Number[0] do
  begin
    for j := 0 to 30 do
      if (1 and (FGInt.Number[i] shr j)) = 1 then
        S := '1' + S
      else
        S := '0' + S;
  end;
  while (length(S) > 1) and (S[1] = '0') do
    delete(S, 1, 1);
  if S = '' then S := '0';
end;


procedure Base2StringToFGInt(S: string; var FGInt: TFGInt);
var
  i, j, size: LongWord;
begin
  while (S[1] = '0') and (length(S) > 1) do
    delete(S, 1, 1);
  size := length(S) div 31;
  if (length(S) mod 31) <> 0 then size := size + 1;
  SetLength(FGInt.Number, (size + 1));
  FGInt.Number[0] := size;
  j := 1;
  FGInt.Number[j] := 0;
  i := 0;
  while length(S) > 0 do
  begin
    if S[length(S)] = '1' then
      FGInt.Number[j] := FGInt.Number[j] or (1 shl i);
    i := i + 1;
    if i = 31 then
    begin
      i := 0;
      j := j + 1;
      if j <= size then FGInt.Number[j] := 0;
    end;
    delete(S, length(S), 1);
  end;
  FGInt.Sign := positive;
end;


// Convert a FGInt to an base 256 string & visa versa

procedure FGIntToBase16String(const FGInt: TFGInt; var str16: string);
var
  temp1: string;
  s: string;
  i, len4: LongWord;
  g: integer;
begin
  FGIntToBase2String(FGInt, temp1);
  while (length(temp1) mod 4) <> 0 do temp1 := '0' + temp1;
  len4 := length(temp1) div 4;
  str16 := '';
  for i := 1 to len4 do
  begin
    s := copy(temp1, 1, 4);

    if s = '0000' then g := 0;
    if s = '0001' then g := 1;
    if s = '0010' then g := 2;
    if s = '0011' then g := 3;
    if s = '0100' then g := 4;
    if s = '0101' then g := 5;
    if s = '0110' then g := 6;
    if s = '0111' then g := 7;
    if s = '1000' then g := 8;
    if s = '1001' then g := 9;
    if s = '1010' then g := 10;
    if s = '1011' then g := 11;
    if s = '1100' then g := 12;
    if s = '1101' then g := 13;
    if s = '1110' then g := 14;
    if s = '1111' then g := 15;

    str16 := str16 + chr16[g];
    delete(temp1, 1, 4);
  end;
end;

// Convert a FGInt to an base 256 string & visa versa

procedure FGIntToBase256String(const FGInt: TFGInt; var str256: string);
var
  temp1: string;
  i, len8: LongWord;
  g: char;
begin
  FGIntToBase2String(FGInt, temp1);
  while (length(temp1) mod 8) <> 0 do temp1 := '0' + temp1;
  len8 := length(temp1) div 8;
  str256 := '';
  for i := 1 to len8 do
  begin
    zeronetochar8(g, copy(temp1, 1, 8));
    str256 := str256 + g;
    delete(temp1, 1, 8);
  end;
end;

procedure Base16StringToFGInt(str16: string; var FGInt: TFGInt);
var
  temp1: string;
begin
  ConvertBase16to2(str16, temp1);
  Base2StringToFGInt(temp1, FGInt);
end;

procedure Base256StringToFGInt(str256: string; var FGInt: TFGInt);
var
  temp1: string;
  i: longint;
  trans: array[0..255] of string;
begin
  temp1 := '';
  initialize8(trans);
  for i := 1 to length(str256) do temp1 := temp1 + trans[ord(str256[i])];
  while (temp1[1] = '0') and (temp1 <> '0') do delete(temp1, 1, 1);
  Base2StringToFGInt(temp1, FGInt);
end;

// Convert an MPI (Multiple Precision Integer, PGP style) to an FGInt &
// visa versa

procedure PGPMPIToFGInt(PGPMPI: string; var FGInt: TFGInt);
var
  temp: string;
begin
  temp := PGPMPI;
  delete(temp, 1, 2);
  Base256StringToFGInt(temp, FGInt);
end;


procedure FGIntToPGPMPI(FGInt: TFGInt; var PGPMPI: string);
var
  len, i: word;
  c: char;
  b: byte;
begin
  FGIntToBase256String(FGInt, PGPMPI);
  len := length(PGPMPI) * 8;
  c := PGPMPI[1];
  for i := 7 downto 0 do if (ord(c) shr i) = 0 then len := len - 1 else break;
  b := len mod 256;
  PGPMPI := chr(b) + PGPMPI;
  b := len div 256;
  PGPMPI := chr(b) + PGPMPI;
end;


// Convert a base 10 string to a FGInt

procedure Base10StringToFGInt(Base10: string; var FGInt: TFGInt);
var
  i, size: LongWord;
  j: word;
  S, x: string;
  sign: TSign;

  procedure GIntDivByIntBis1(var GInt: TFGInt; by: LongWord; var modres: word);
  var
    i, size, rest, temp: LongWord;
  begin
    size := GInt.Number[0];
    temp := 0;
    for i := size downto 1 do
    begin
      temp := temp * 10000;
      rest := temp + GInt.Number[i];
      GInt.Number[i] := rest div by;
      temp := rest mod by;
    end;
    modres := temp;
    while (GInt.Number[size] = 0) and (size > 1) do
      size := size - 1;
    if size <> GInt.Number[0] then
    begin
      SetLength(GInt.Number, size + 1);
      GInt.Number[0] := size;
    end;
  end;

begin
  while (not (Base10[1] in ['-', '0'..'9'])) and (length(Base10) > 1) do
    delete(Base10, 1, 1);
  if copy(Base10, 1, 1) = '-' then
  begin
    Sign := negative;
    delete(Base10, 1, 1);
  end
  else
    Sign := positive;
  while (length(Base10) > 1) and (copy(Base10, 1, 1) = '0') do
    delete(Base10, 1, 1);
  size := length(Base10) div 4;
  if (length(Base10) mod 4) <> 0 then size := size + 1;
  SetLength(FGInt.Number, size + 1);
  FGInt.Number[0] := size;
  for i := 1 to (size - 1) do
  begin
    x := copy(Base10, length(Base10) - 3, 4);
    FGInt.Number[i] := StrToInt(x);
    delete(Base10, length(Base10) - 3, 4);
  end;
  FGInt.Number[size] := StrToInt(Base10);

  S := '';
  while (FGInt.Number[0] <> 1) or (FGInt.Number[1] <> 0) do
  begin
    GIntDivByIntBis1(FGInt, 2, j);
    S := inttostr(j) + S;
  end;
  if S = '' then S := '0';
  FGIntDestroy(FGInt);
  Base2StringToFGInt(S, FGInt);
  FGInt.Sign := sign;
end;


// Convert a FGInt to a base 10 string

procedure FGIntToBase10String(const FGInt: TFGInt; var Base10: string);
var
  S: string;
  j: LongWord;
  temp: TFGInt;
begin
  FGIntCopy(FGInt, temp);
  Base10 := '';
  while (temp.Number[0] > 1) or (temp.Number[1] > 0) do
  begin
    FGIntDivByIntBis(temp, 10000, j);
    S := IntToStr(j);
    while Length(S) < 4 do
      S := '0' + S;
    Base10 := S + Base10;
  end;
  Base10 := '0' + Base10;
  while (length(Base10) > 1) and (Base10[1] = '0') do
    delete(Base10, 1, 1);
  if FGInt.Sign = negative then Base10 := '-' + Base10;
end;


// Destroy a FGInt to free memory

procedure FGIntDestroy(var FGInt: TFGInt);
begin
  FGInt.Number := nil;
end;


// Compare 2 FGInts in absolute value, returns
// Lt if FGInt1 > FGInt2, St if FGInt1 < FGInt2, Eq if FGInt1 = FGInt2,
// Er otherwise

function FGIntCompareAbs(const FGInt1, FGInt2: TFGInt): TCompare;
var
  size1, size2, i: LongWord;
begin
  FGIntCompareAbs := Er;
  size1 := FGInt1.Number[0];
  size2 := FGInt2.Number[0];
  if size1 > size2 then FGIntCompareAbs := Lt else
    if size1 < size2 then FGIntCompareAbs := St else
    begin
      i := size2;
      while (FGInt1.Number[i] = FGInt2.Number[i]) and (i > 1) do i := i - 1;
      if FGInt1.Number[i] = FGInt2.Number[i] then FGIntCompareAbs := Eq else
        if FGInt1.Number[i] < FGInt2.Number[i] then FGIntCompareAbs := St else
          if FGInt1.Number[i] > FGInt2.Number[i] then FGIntCompareAbs := Lt;
    end;
end;


// Add 2 FGInts, FGInt1 + FGInt2 = Sum

procedure FGIntAdd(const FGInt1, FGInt2: TFGInt; var Sum: TFGInt);
var
  i, size1, size2, size, rest, Trest: LongWord;
begin
  size1 := FGInt1.Number[0];
  size2 := FGInt2.Number[0];
  if size1 < size2 then
    FGIntAdd(FGInt2, FGInt1, Sum)
  else
  begin
    if FGInt1.Sign = FGInt2.Sign then
    begin
      Sum.Sign := FGInt1.Sign;
      setlength(Sum.Number, (size1 + 2));
      rest := 0;
      for i := 1 to size2 do
      begin
        Trest := FGInt1.Number[i];
        Trest := Trest + FGInt2.Number[i];
        Trest := Trest + rest;
        Sum.Number[i] := Trest and $7FFFFFFF;
        rest := Trest shr 31;
      end;
      for i := (size2 + 1) to size1 do
      begin
        Trest := FGInt1.Number[i] + rest;
        Sum.Number[i] := Trest and $7FFFFFFF;
        rest := Trest shr 31;
      end;
      size := size1 + 1;
      Sum.Number[0] := size;
      Sum.Number[size] := rest;
      while (Sum.Number[size] = 0) and (size > 1) do
        size := size - 1;
      if Sum.Number[0] <> size then SetLength(Sum.Number, size + 1);
      Sum.Number[0] := size;
    end
    else
    begin
      if FGIntCompareAbs(FGInt2, FGInt1) = Lt then
        FGIntAdd(FGInt2, FGInt1, Sum)
      else
      begin
        SetLength(Sum.Number, (size1 + 1));
        rest := 0;
        for i := 1 to size2 do
        begin
          Trest := 2147483648;
          TRest := Trest + FGInt1.Number[i];
          TRest := Trest - FGInt2.Number[i];
          TRest := Trest - rest;
          Sum.Number[i] := Trest and $7FFFFFFF;
          if (Trest > $7FFFFFFF) then
            rest := 0
          else
            rest := 1;
        end;
        for i := (size2 + 1) to size1 do
        begin
          Trest := 2147483648;
          TRest := Trest + FGInt1.Number[i];
          TRest := Trest - rest;
          Sum.Number[i] := Trest and $7FFFFFFF;
          if (Trest > $7FFFFFFF) then
            rest := 0
          else
            rest := 1;
        end;
        size := size1;
        while (Sum.Number[size] = 0) and (size > 1) do
          size := size - 1;
        if size <> size1 then SetLength(Sum.Number, size + 1);
        Sum.Number[0] := size;
        Sum.Sign := FGInt1.Sign;
      end;
    end;
  end;
end;




procedure FGIntChangeSign(var FGInt: TFGInt);
begin
  if FGInt.Sign = negative then FGInt.Sign := positive else FGInt.Sign := negative;
end;


// Substract 2 FGInts, FGInt1 - FGInt2 = dif

procedure FGIntSub(var FGInt1, FGInt2, dif: TFGInt);
begin
  FGIntChangeSign(FGInt2);
  FGIntAdd(FGInt1, FGInt2, dif);
  FGIntChangeSign(FGInt2);
end;


// multiply a FGInt by an integer, FGInt * by = res, by < 2147483648

procedure FGIntMulByInt(const FGInt: TFGInt; var res: TFGInt; by: LongWord);
var
  i, size, rest: LongWord;
  Trest: int64;
begin
  size := FGInt.Number[0];
  setlength(res.Number, (size + 2));
  rest := 0;
  for i := 1 to size do
  begin
    Trest := FGInt.Number[i];
    TRest := Trest * by;
    TRest := Trest + rest;
    res.Number[i] := Trest and $7FFFFFFF;
    rest := Trest shr 31;
  end;
  if rest <> 0 then
  begin
    size := size + 1;
    Res.Number[size] := rest;
  end
  else
    SetLength(Res.Number, size + 1);
  Res.Number[0] := size;
  Res.Sign := FGInt.Sign;
end;


// multiply a FGInt by an integer, FGInt * by = res, by < 1000000000

procedure FGIntMulByIntbis(var FGInt: TFGInt; by: LongWord);
var
  i, size, rest: LongWord;
  Trest: int64;
begin
  size := FGInt.Number[0];
  Setlength(FGInt.Number, size + 2);
  rest := 0;
  for i := 1 to size do
  begin
    Trest := FGInt.Number[i];
    TRest := Trest * by;
    TRest := Trest + rest;
    FGInt.Number[i] := Trest and $7FFFFFFF;
    rest := Trest shr 31;
  end;
  if rest <> 0 then
  begin
    size := size + 1;
    FGInt.Number[size] := rest;
  end
  else
    SetLength(FGInt.Number, size + 1);
  FGInt.Number[0] := size;
end;


// divide a FGInt by an integer, FGInt = res * by + modres

procedure FGIntDivByInt(const FGInt: TFGInt; var res: TFGInt; by: LongWord; var modres: LongWord);
var
  i, size: LongWord;
  rest: int64;
begin
  size := FGInt.Number[0];
  setlength(res.Number, (size + 1));
  modres := 0;
  for i := size downto 1 do
  begin
    rest := modres;
    rest := rest shl 31;
    rest := rest or FGInt.Number[i];
    res.Number[i] := rest div by;
    modres := rest mod by;
  end;
  while (res.Number[size] = 0) and (size > 1) do
    size := size - 1;
  if size <> FGInt.Number[0] then SetLength(res.Number, size + 1);
  res.Number[0] := size;
  Res.Sign := FGInt.Sign;
  if FGInt.sign = negative then modres := by - modres;
end;


// divide a FGInt by an integer, FGInt = FGInt * by + modres

procedure FGIntDivByIntBis(var FGInt: TFGInt; by: LongWord; var modres: LongWord);
var
  i, size: LongWord;
  temp, rest: int64;
begin
  size := FGInt.Number[0];
  temp := 0;
  for i := size downto 1 do
  begin
    temp := temp shl 31;
    rest := temp or FGInt.Number[i];
    FGInt.Number[i] := rest div by;
    temp := rest mod by;
  end;
  modres := temp;
  while (FGInt.Number[size] = 0) and (size > 1) do
    size := size - 1;
  if size <> FGInt.Number[0] then
  begin
    SetLength(FGInt.Number, size + 1);
    FGInt.Number[0] := size;
  end;
end;


// Reduce a FGInt modulo by (=an integer), FGInt mod by = modres

procedure FGIntModByInt(const FGInt: TFGInt; by: LongWord; var modres: LongWord);
var
  i, size: LongWord;
  temp, rest: int64;
begin
  size := FGInt.Number[0];
  temp := 0;
  for i := size downto 1 do
  begin
    temp := temp shl 31;
    rest := temp or FGInt.Number[i];
    temp := rest mod by;
  end;
  modres := temp;
  if FGInt.sign = negative then modres := by - modres;
end;


// Returns the FGInt in absolute value

procedure FGIntAbs(var FGInt: TFGInt);
begin
  FGInt.Sign := positive;
end;


// Copy a FGInt1 into FGInt2

procedure FGIntCopy(const FGInt1: TFGInt; var FGInt2: TFGInt);
begin
  FGInt2.Sign := FGInt1.Sign;
  FGInt2.Number := nil;
  FGInt2.Number := Copy(FGInt1.Number, 0, FGInt1.Number[0] + 1);
end;


// Shift the FGInt to the left in base 2 notation, ie FGInt = FGInt * 2



procedure FGIntShiftLeft(var FGInt: TFGInt);
var
  l, m, i, size: LongWord;
begin
  size := FGInt.Number[0];
  l := 0;
  for i := 1 to Size do
  begin
    m := FGInt.Number[i] shr 30;
    FGInt.Number[i] := ((FGInt.Number[i] shl 1) or l) and $7FFFFFFF;
    l := m;
  end;
  if l <> 0 then
  begin
    setlength(FGInt.Number, size + 2);
    FGInt.Number[size + 1] := l;
    FGInt.Number[0] := size + 1;
  end;
end;


// Shift the FGInt to the right in base 2 notation, ie FGInt = FGInt div 2


procedure FGIntShiftRight(var FGInt: TFGInt);
var
  l, m, i, size: LongWord;
begin
  size := FGInt.Number[0];
  l := 0;
  for i := size downto 1 do
  begin
    m := FGInt.Number[i] and 1;
    FGInt.Number[i] := (FGInt.Number[i] shr 1) or l;
    l := m shl 30;
  end;
  if (FGInt.Number[size] = 0) and (size > 1) then
  begin
    setlength(FGInt.Number, size);
    FGInt.Number[0] := size - 1;
  end;
end;


// FGInt = FGInt / 2147483648

procedure FGIntShiftRightBy31(var FGInt: TFGInt);
var
  size, i: LongWord;
begin
  size := FGInt.Number[0];
  if size > 1 then
  begin
    for i := 1 to size - 1 do
    begin
      FGInt.Number[i] := FGInt.Number[i + 1];
    end;
    SetLength(FGInt.Number, Size);
    FGInt.Number[0] := size - 1;
  end
  else
    FGInt.Number[1] := 0;
end;


// FGInt1 = FGInt1 + FGInt2, FGInt1 > FGInt2

procedure FGIntAddBis(var FGInt1: TFGInt; const FGInt2: TFGInt);
var
  i, size1, size2, Trest, rest: LongWord;
begin
  size1 := FGInt1.Number[0];
  size2 := FGInt2.Number[0];
  rest := 0;
  for i := 1 to size2 do
  begin
    Trest := FGInt1.Number[i] + FGInt2.Number[i] + rest;
    rest := Trest shr 31;
    FGInt1.Number[i] := Trest and $7FFFFFFF;
  end;
  for i := size2 + 1 to size1 do
  begin
    Trest := FGInt1.Number[i] + rest;
    rest := Trest shr 31;
    FGInt1.Number[i] := Trest and $7FFFFFFF;
  end;
  if rest <> 0 then
  begin
    SetLength(FGInt1.Number, size1 + 2);
    FGInt1.Number[0] := size1 + 1;
    FGInt1.Number[size1 + 1] := rest;
  end;
end;


// FGInt1 = FGInt1 - FGInt2, use only when 0 < FGInt2 < FGInt1

procedure FGIntSubBis(var FGInt1: TFGInt; const FGInt2: TFGInt);
var
  i, size1, size2, rest, Trest: LongWord;
begin
  size1 := FGInt1.Number[0];
  size2 := FGInt2.Number[0];
  rest := 0;
  for i := 1 to size2 do
  begin
    Trest := (2147483648 or FGInt1.Number[i]) - FGInt2.Number[i] - rest;
    if (Trest > $7FFFFFFF) then
      rest := 0
    else
      rest := 1;
    FGInt1.Number[i] := Trest and $7FFFFFFF;
  end;
  for i := size2 + 1 to size1 do
  begin
    Trest := (2147483648 or FGInt1.Number[i]) - rest;
    if (Trest > $7FFFFFFF) then
      rest := 0
    else
      rest := 1;
    FGInt1.Number[i] := Trest and $7FFFFFFF;
  end;
  i := size1;
  while (FGInt1.Number[i] = 0) and (i > 1) do
    i := i - 1;
  if i <> size1 then
  begin
    SetLength(FGInt1.Number, i + 1);
    FGInt1.Number[0] := i;
  end;
end;


// Multiply 2 FGInts, FGInt1 * FGInt2 = Prod

procedure FGIntMul(const FGInt1, FGInt2: TFGInt; var Prod: TFGInt);
var
  i, j, size, size1, size2, rest: LongWord;
  Trest: int64;
begin
  size1 := FGInt1.Number[0];
  size2 := FGInt2.Number[0];
  size := size1 + size2;
  SetLength(Prod.Number, (size + 1));
  for i := 1 to size do
    Prod.Number[i] := 0;

  for i := 1 to size2 do
  begin
    rest := 0;
    for j := 1 to size1 do
    begin
      Trest := FGInt1.Number[j];
      Trest := Trest * FGInt2.Number[i];
      Trest := Trest + Prod.Number[j + i - 1];
      Trest := Trest + rest;
      Prod.Number[j + i - 1] := Trest and $7FFFFFFF;
      rest := Trest shr 31;
    end;
    Prod.Number[i + size1] := rest;
  end;

  Prod.Number[0] := size;
  while (Prod.Number[size] = 0) and (size > 1) do
    size := size - 1;
  if size <> Prod.Number[0] then
  begin
    SetLength(Prod.Number, size + 1);
    Prod.Number[0] := size;
  end;
  if FGInt1.Sign = FGInt2.Sign then
    Prod.Sign := Positive
  else
    prod.Sign := negative;
end;


// Square a FGInt, FGInt� = Square

procedure FGIntSquare(const FGInt: TFGInt; var Square: TFGInt);
var
  size, size1, i, j, rest: LongWord;
  Trest: int64;
begin
  size1 := FGInt.Number[0];
  size := 2 * size1;
  SetLength(Square.Number, (size + 1));
  Square.Number[0] := size;
  for i := 1 to size do
    Square.Number[i] := 0;
  for i := 1 to size1 do
  begin
    Trest := FGInt.Number[i];
    Trest := Trest * FGInt.Number[i];
    Trest := Trest + Square.Number[2 * i - 1];
    Square.Number[2 * i - 1] := Trest and $7FFFFFFF;
    rest := Trest shr 31;
    for j := i + 1 to size1 do
    begin
      Trest := FGInt.Number[i] shl 1;
      Trest := Trest * FGInt.Number[j];
      Trest := Trest + Square.Number[i + j - 1];
      Trest := Trest + rest;
      Square.Number[i + j - 1] := Trest and $7FFFFFFF;
      rest := Trest shr 31;
    end;
    Square.Number[i + size1] := rest;
  end;
  Square.Sign := positive;
  while (Square.Number[size] = 0) and (size > 1) do
    size := size - 1;
  if size <> (2 * size1) then
  begin
    SetLength(Square.Number, size + 1);
    Square.Number[0] := size;
  end;
end;


// Exponentiate a FGInt, FGInt^exp = res

procedure FGIntExp(const FGInt, exp: TFGInt; var res: TFGInt);
var
  temp2, temp3: TFGInt;
  S: string;
  i: LongWord;
begin
  FGIntToBase2String(exp, S);
  if S[length(S)] = '0' then Base10StringToFGInt('1', res) else FGIntCopy(FGInt, res);
  FGIntCopy(FGInt, temp2);
  if length(S) > 1 then
    for i := (length(S) - 1) downto 1 do
    begin
      FGIntSquare(temp2, temp3);
      FGIntCopy(temp3, temp2);
      if S[i] = '1' then
      begin
        FGIntMul(res, temp2, temp3);
        FGIntCopy(temp3, res);
      end;
    end;
end;


// Compute FGInt! = FGInt * (FGInt - 1) * (FGInt - 2) * ... * 3 * 2 * 1

procedure FGIntFac(const FGInt: TFGInt; var res: TFGInt);
var
  one, temp, temp1: TFGInt;
begin
  FGIntCopy(FGInt, temp);
  Base10StringToFGInt('1', res);
  Base10StringToFGInt('1', one);

  while not (FGIntCompareAbs(temp, one) = Eq) do
  begin
    FGIntMul(temp, res, temp1);
    FGIntCopy(temp1, res);
    FGIntSubBis(temp, one);
  end;

  FGIntDestroy(one);
  FGIntDestroy(temp);
end;


// FGInt = FGInt * 2147483648

procedure FGIntShiftLeftBy31(var FGInt: TFGInt);
var
  f1, f2: LongWord;
  i, size: longint;
begin
  size := FGInt.Number[0];
  SetLength(FGInt.Number, size + 2);
  f1 := 0;
  for i := 1 to (size + 1) do
  begin
    f2 := FGInt.Number[i];
    FGInt.Number[i] := f1;
    f1 := f2;
  end;
  FGInt.Number[0] := size + 1;
end;


// Divide 2 FGInts, FGInt1 = FGInt2 * QFGInt + MFGInt, MFGInt is always positive

procedure FGIntDivMod(var FGInt1, FGInt2, QFGInt, MFGInt: TFGInt);
var
  one, zero, temp1, temp2: TFGInt;
  s1, s2: TSign;
  j, s, t: LongWord;
  i: int64;
begin
  s1 := FGInt1.Sign;
  s2 := FGInt2.Sign;
  FGIntAbs(FGInt1);
  FGIntAbs(FGInt2);
  FGIntCopy(FGInt1, MFGInt);
  FGIntCopy(FGInt2, temp1);

  if FGIntCompareAbs(FGInt1, FGInt2) <> St then
  begin
    s := FGInt1.Number[0] - FGInt2.Number[0];
    SetLength(QFGInt.Number, (s + 2));
    QFGInt.Number[0] := s + 1;
    for t := 1 to s do
    begin
      FGIntShiftLeftBy31(temp1);
      QFGInt.Number[t] := 0;
    end;
    j := s + 1;
    QFGInt.Number[j] := 0;
    while FGIntCompareAbs(MFGInt, FGInt2) <> St do
    begin
      while FGIntCompareAbs(MFGInt, temp1) <> St do
      begin
        if MFGInt.Number[0] > temp1.Number[0] then
        begin
          i := MFGInt.Number[MFGInt.Number[0]];
          i := i shl 31;
          i := i + MFGInt.Number[MFGInt.Number[0] - 1];
          i := i div (temp1.Number[temp1.Number[0]] + 1);
        end
        else
          i := MFGInt.Number[MFGInt.Number[0]] div (temp1.Number[temp1.Number[0]] + 1);
        if (i <> 0) then
        begin
          FGIntCopy(temp1, temp2);
          FGIntMulByIntBis(temp2, i);
          FGIntSubBis(MFGInt, temp2);
          QFGInt.Number[j] := QFGInt.Number[j] + i;
          if FGIntCompareAbs(MFGInt, temp2) <> St then
          begin
            QFGInt.Number[j] := QFGInt.Number[j] + i;
            FGIntSubBis(MFGInt, temp2);
          end;
          FGIntDestroy(temp2);
        end
        else
        begin
          QFGInt.Number[j] := QFGInt.Number[j] + 1;
          FGIntSubBis(MFGInt, temp1);
        end;
      end;
      if MFGInt.Number[0] <= temp1.Number[0] then
        if FGIntCompareAbs(temp1, FGInt2) <> Eq then
        begin
          FGIntShiftRightBy31(temp1);
          j := j - 1;
        end;
    end;
  end
  else
    Base10StringToFGInt('0', QFGInt);
  s := QFGInt.Number[0];
  while (s > 1) and (QFGInt.Number[s] = 0) do
    s := s - 1;
  if s < QFGInt.Number[0] then
  begin
    setlength(QFGInt.Number, s + 1);
    QFGInt.Number[0] := s;
  end;
  QFGInt.Sign := positive;

  FGIntDestroy(temp1);
  Base10StringToFGInt('0', zero);
  Base10StringToFGInt('1', one);
  if s1 = negative then
  begin
    if FGIntCompareAbs(MFGInt, zero) <> Eq then
    begin
      FGIntadd(QFGInt, one, temp1);
      FGIntDestroy(QFGInt);
      FGIntCopy(temp1, QFGInt);
      FGIntDestroy(temp1);
      FGIntsub(FGInt2, MFGInt, temp1);
      FGIntDestroy(MFGInt);
      FGIntCopy(temp1, MFGInt);
      FGIntDestroy(temp1);
    end;
    if s2 = positive then QFGInt.Sign := negative;
  end
  else
    QFGInt.Sign := s2;
  FGIntDestroy(one);
  FGIntDestroy(zero);

  FGInt1.Sign := s1;
  FGInt2.Sign := s2;
end;


// Same as above but doesn 't compute MFGInt

procedure FGIntDiv(var FGInt1, FGInt2, QFGInt: TFGInt);
var
  one, zero, temp1, temp2, MFGInt: TFGInt;
  s1, s2: TSign;
  j, s, t: LongWord;
  i: int64;
begin
  s1 := FGInt1.Sign;
  s2 := FGInt2.Sign;
  FGIntAbs(FGInt1);
  FGIntAbs(FGInt2);
  FGIntCopy(FGInt1, MFGInt);
  FGIntCopy(FGInt2, temp1);

  if FGIntCompareAbs(FGInt1, FGInt2) <> St then
  begin
    s := FGInt1.Number[0] - FGInt2.Number[0];
    SetLength(QFGInt.Number, (s + 2));
    QFGInt.Number[0] := s + 1;
    for t := 1 to s do
    begin
      FGIntShiftLeftBy31(temp1);
      QFGInt.Number[t] := 0;
    end;
    j := s + 1;
    QFGInt.Number[j] := 0;
    while FGIntCompareAbs(MFGInt, FGInt2) <> St do
    begin
      while FGIntCompareAbs(MFGInt, temp1) <> St do
      begin
        if MFGInt.Number[0] > temp1.Number[0] then
        begin
          i := MFGInt.Number[MFGInt.Number[0]];
          i := i shl 31;
          i := i + MFGInt.Number[MFGInt.Number[0] - 1];
          i := i div (temp1.Number[temp1.Number[0]] + 1);
        end
        else
          i := MFGInt.Number[MFGInt.Number[0]] div (temp1.Number[temp1.Number[0]] + 1);
        if (i <> 0) then
        begin
          FGIntCopy(temp1, temp2);
          FGIntMulByIntBis(temp2, i);
          FGIntSubBis(MFGInt, temp2);
          QFGInt.Number[j] := QFGInt.Number[j] + i;
          if FGIntCompareAbs(MFGInt, temp2) <> St then
          begin
            QFGInt.Number[j] := QFGInt.Number[j] + i;
            FGIntSubBis(MFGInt, temp2);
          end;
          FGIntDestroy(temp2);
        end
        else
        begin
          QFGInt.Number[j] := QFGInt.Number[j] + 1;
          FGIntSubBis(MFGInt, temp1);
        end;
      end;
      if MFGInt.Number[0] <= temp1.Number[0] then
        if FGIntCompareAbs(temp1, FGInt2) <> Eq then
        begin
          FGIntShiftRightBy31(temp1);
          j := j - 1;
        end;
    end;
  end
  else
    Base10StringToFGInt('0', QFGInt);
  s := QFGInt.Number[0];
  while (s > 1) and (QFGInt.Number[s] = 0) do
    s := s - 1;
  if s < QFGInt.Number[0] then
  begin
    setlength(QFGInt.Number, s + 1);
    QFGInt.Number[0] := s;
  end;
  QFGInt.Sign := positive;

  FGIntDestroy(temp1);
  Base10StringToFGInt('0', zero);
  Base10StringToFGInt('1', one);
  if s1 = negative then
  begin
    if FGIntCompareAbs(MFGInt, zero) <> Eq then
    begin
      FGIntadd(QFGInt, one, temp1);
      FGIntDestroy(QFGInt);
      FGIntCopy(temp1, QFGInt);
      FGIntDestroy(temp1);
      FGIntsub(FGInt2, MFGInt, temp1);
      FGIntDestroy(MFGInt);
      FGIntCopy(temp1, MFGInt);
      FGIntDestroy(temp1);
    end;
    if s2 = positive then QFGInt.Sign := negative;
  end
  else
    QFGInt.Sign := s2;
  FGIntDestroy(one);
  FGIntDestroy(zero);
  FGIntDestroy(MFGInt);

  FGInt1.Sign := s1;
  FGInt2.Sign := s2;
end;



// Same as above but this computes MFGInt in stead of QFGInt
// MFGInt = FGInt1 mod FGInt2

procedure FGIntMod(var FGInt1, FGInt2, MFGInt: TFGInt);
var
  one, zero, temp1, temp2: TFGInt;
  s1, s2: TSign;
  s, t: LongWord;
  i: int64;
begin
  s1 := FGInt1.Sign;
  s2 := FGInt2.Sign;
  FGIntAbs(FGInt1);
  FGIntAbs(FGInt2);
  FGIntCopy(FGInt1, MFGInt);
  FGIntCopy(FGInt2, temp1);

  if FGIntCompareAbs(FGInt1, FGInt2) <> St then
  begin
    s := FGInt1.Number[0] - FGInt2.Number[0];
    for t := 1 to s do
      FGIntShiftLeftBy31(temp1);
    while FGIntCompareAbs(MFGInt, FGInt2) <> St do
    begin
      while FGIntCompareAbs(MFGInt, temp1) <> St do
      begin
        if MFGInt.Number[0] > temp1.Number[0] then
        begin
          i := MFGInt.Number[MFGInt.Number[0]];
          i := i shl 31;
          i := i + MFGInt.Number[MFGInt.Number[0] - 1];
          i := i div (temp1.Number[temp1.Number[0]] + 1);
        end
        else
          i := MFGInt.Number[MFGInt.Number[0]] div (temp1.Number[temp1.Number[0]] + 1);
        if (i <> 0) then
        begin
          FGIntCopy(temp1, temp2);
          FGIntMulByIntBis(temp2, i);
          FGIntSubBis(MFGInt, temp2);
          if FGIntCompareAbs(MFGInt, temp2) <> St then FGIntSubBis(MFGInt, temp2);
          FGIntDestroy(temp2);
        end
        else
          FGIntSubBis(MFGInt, temp1);
//         If FGIntCompareAbs(MFGInt, temp1) <> St Then FGIntSubBis(MFGInt,temp1);
      end;
      if MFGInt.Number[0] <= temp1.Number[0] then
        if FGIntCompareAbs(temp1, FGInt2) <> Eq then FGIntShiftRightBy31(temp1);
    end;
  end;

  FGIntDestroy(temp1);
  Base10StringToFGInt('0', zero);
  Base10StringToFGInt('1', one);
  if s1 = negative then
  begin
    if FGIntCompareAbs(MFGInt, zero) <> Eq then
    begin
      FGIntSub(FGInt2, MFGInt, temp1);
      FGIntDestroy(MFGInt);
      FGIntCopy(temp1, MFGInt);
      FGIntDestroy(temp1);
    end;
  end;
  FGIntDestroy(one);
  FGIntDestroy(zero);

  FGInt1.Sign := s1;
  FGInt2.Sign := s2;
end;


// Square a FGInt modulo Modb, FGInt^2 mod Modb = FGIntSM

procedure FGIntSquareMod(var FGInt, Modb, FGIntSM: TFGInt);
var
  temp: TFGInt;
begin
  FGIntSquare(FGInt, temp);
  FGIntMod(temp, Modb, FGIntSM);
  FGIntDestroy(temp);
end;


// Add 2 FGInts modulo base, (FGInt1 + FGInt2) mod base = FGIntres

procedure FGIntAddMod(var FGInt1, FGInt2, base, FGIntres: TFGInt);
var
  temp: TFGInt;
begin
  FGIntadd(FGInt1, FGInt2, temp);
  FGIntMod(temp, base, FGIntres);
  FGIntDestroy(temp);
end;


// Multiply 2 FGInts modulo base, (FGInt1 * FGInt2) mod base = FGIntres

procedure FGIntMulMod(var FGInt1, FGInt2, base, FGIntres: TFGInt);
var
  temp: TFGInt;
begin
  FGIntMul(FGInt1, FGInt2, temp);
  FGIntMod(temp, base, FGIntres);
  FGIntDestroy(temp);
end;


// Exponentiate 2 FGInts modulo base, (FGInt1 ^ FGInt2) mod modb = res

procedure FGIntModExp(var FGInt, exp, modb, res: TFGInt);
var
  temp2, temp3: TFGInt;
  i: LongWord;
  S: string;
begin
  if (Modb.Number[1] mod 2) = 1 then
  begin
    FGIntMontgomeryModExp(FGInt, exp, modb, res);
    exit;
  end;
  FGIntToBase2String(exp, S);
  Base10StringToFGInt('1', res);
  FGIntcopy(FGInt, temp2);

  for i := length(S) downto 1 do
  begin
    if S[i] = '1' then
    begin
      FGIntmulMod(res, temp2, modb, temp3);
      FGIntCopy(temp3, res);
    end;
    FGIntSquareMod(temp2, Modb, temp3);
    FGIntCopy(temp3, temp2);
  end;
  FGIntDestroy(temp2);
end;


// Procedures for Montgomery Exponentiation

procedure FGIntModBis(const FGInt: TFGInt; var FGIntOut: TFGInt; b, head: LongWord);
var
  i: LongWord;
begin
  if b <= FGInt.Number[0] then
  begin
    SetLength(FGIntOut.Number, (b + 1));
    for i := 0 to b do
      FGIntOut.Number[i] := FGInt.Number[i];
    FGIntOut.Number[b] := FGIntOut.Number[b] and head;
    i := b;
    while (FGIntOut.Number[i] = 0) and (i > 1) do
      i := i - 1;
    if i < b then SetLength(FGIntOut.Number, i + 1);
    FGIntOut.Number[0] := i;
    FGIntOut.Sign := positive;
  end
  else
    FGIntCopy(FGInt, FGIntOut);
end;


procedure FGIntMulModBis(const FGInt1, FGInt2: TFGInt; var Prod: TFGInt; b, head: LongWord);
var
  i, j, size, size1, size2, t, rest: LongWord;
  Trest: int64;
begin
  size1 := FGInt1.Number[0];
  size2 := FGInt2.Number[0];
  size := min(b, size1 + size2);
  SetLength(Prod.Number, (size + 1));
  for i := 1 to size do
    Prod.Number[i] := 0;

  for i := 1 to size2 do
  begin
    rest := 0;
    t := min(size1, b - i + 1);
    for j := 1 to t do
    begin
      Trest := FGInt1.Number[j];
      Trest := Trest * FGInt2.Number[i];
      Trest := Trest + Prod.Number[j + i - 1];
      Trest := Trest + rest;
      Prod.Number[j + i - 1] := Trest and $7FFFFFFF;
      rest := Trest shr 31;
    end;
    if (i + size1) <= b then Prod.Number[i + size1] := rest;
  end;

  Prod.Number[0] := size;
  if size = b then Prod.Number[b] := Prod.Number[b] and head;
  while (Prod.Number[size] = 0) and (size > 1) do
    size := size - 1;
  if size < Prod.Number[0] then
  begin
    SetLength(Prod.Number, size + 1);
    Prod.Number[0] := size;
  end;
  if FGInt1.Sign = FGInt2.Sign then
    Prod.Sign := Positive
  else
    prod.Sign := negative;
end;


procedure FGIntMontgomeryMod(const GInt, base, baseInv: TFGInt; var MGInt: TFGInt; b: Longword; head: LongWord);
var
  m, temp, temp1: TFGInt;
  r: LongWord;
begin
  FGIntModBis(GInt, temp, b, head);
  FGIntMulModBis(temp, baseInv, m, b, head);
  FGIntMul(m, base, temp1);
  FGIntDestroy(temp);
  FGIntAdd(temp1, GInt, temp);
  FGIntDestroy(temp1);
  MGInt.Number := copy(temp.Number, b - 1, temp.Number[0] - b + 2);
  MGInt.Sign := positive;
  MGInt.Number[0] := temp.Number[0] - b + 1;
  FGIntDestroy(temp);
  if (head shr 30) = 0 then FGIntDivByIntBis(MGInt, head + 1, r)
  else FGIntShiftRightBy31(MGInt);
  if FGIntCompareAbs(MGInt, base) <> St then FGIntSubBis(MGInt, base);
  FGIntDestroy(temp);
  FGIntDestroy(m);
end;


procedure FGIntMontgomeryModExp(var FGInt, exp, modb, res: TFGInt);
var
  temp2, temp3, baseInv, r, zero: TFGInt;
  i, j, t, b, head: LongWord;
  S: string;
begin
  Base2StringToFGInt('0', zero);
  FGIntMod(FGInt, modb, res);
  if FGIntCompareAbs(res, zero) = Eq then
  begin
    FGIntDestroy(zero);
    Exit;
  end else FGIntDestroy(res);
  FGIntDestroy(zero);

  FGIntToBase2String(exp, S);
  t := modb.Number[0];
  b := t;

  if (modb.Number[t] shr 30) = 1 then t := t + 1;
  SetLength(r.Number, (t + 1));
  r.Number[0] := t;
  r.Sign := positive;
  for i := 1 to t do
    r.Number[i] := 0;
  if t = modb.Number[0] then
  begin
    head := $7FFFFFFF;
    for j := 29 downto 0 do
    begin
      head := head shr 1;
      if (modb.Number[t] shr j) = 1 then
      begin
        r.Number[t] := 1 shl (j + 1);
        break;
      end;
    end;
  end
  else
  begin
    r.Number[t] := 1;
    head := $7FFFFFFF;
  end;

  FGIntModInv(modb, r, temp2);
  if temp2.Sign = negative then
    FGIntCopy(temp2, BaseInv)
  else
  begin
    FGIntCopy(r, BaseInv);
    FGIntSubBis(BaseInv, temp2);
  end;
//   FGIntBezoutBachet(r, modb, temp2, BaseInv);
  FGIntAbs(BaseInv);
  FGIntDestroy(temp2);
  FGIntMod(r, modb, res);
  FGIntMulMod(FGInt, res, modb, temp2);
  FGIntDestroy(r);

  for i := length(S) downto 1 do
  begin
    if S[i] = '1' then
    begin
      FGIntmul(res, temp2, temp3);
      FGIntDestroy(res);
      FGIntMontgomeryMod(temp3, modb, baseinv, res, b, head);
      FGIntDestroy(temp3);
    end;
    FGIntSquare(temp2, temp3);
    FGIntDestroy(temp2);
    FGIntMontgomeryMod(temp3, modb, baseinv, temp2, b, head);
    FGIntDestroy(temp3);
  end;
  FGIntDestroy(temp2);
  FGIntMontgomeryMod(res, modb, baseinv, temp3, b, head);
  FGIntCopy(temp3, res);
  FGIntDestroy(temp3);
  FGIntDestroy(baseinv);
end;


// Compute the Greatest Common Divisor of 2 FGInts

procedure FGIntGCD(const FGInt1, FGInt2: TFGInt; var GCD: TFGInt);
var
  k: TCompare;
  zero, temp1, temp2, temp3: TFGInt;
begin
  k := FGIntCompareAbs(FGInt1, FGInt2);
  if (k = Eq) then FGIntCopy(FGInt1, GCD) else
    if (k = St) then FGIntGCD(FGInt2, FGInt1, GCD) else
    begin
      Base10StringToFGInt('0', zero);
      FGIntCopy(FGInt1, temp1);
      FGIntCopy(FGInt2, temp2);
      while (temp2.Number[0] <> 1) or (temp2.Number[1] <> 0) do
      begin
        FGIntMod(temp1, temp2, temp3);
        FGIntCopy(temp2, temp1);
        FGIntCopy(temp3, temp2);
        FGIntDestroy(temp3);
      end;
      FGIntCopy(temp1, GCD);
      FGIntDestroy(temp2);
      FGIntDestroy(zero);
    end;
end;


// Compute the Least Common Multiple of 2 FGInts

procedure FGIntLCM(const FGInt1, FGInt2: TFGInt; var LCM: TFGInt);
var
  temp1, temp2: TFGInt;
begin
  FGIntGCD(FGInt1, FGInt2, temp1);
  FGIntmul(FGInt1, FGInt2, temp2);
  FGIntdiv(temp2, temp1, LCM);
  FGIntDestroy(temp1);
  FGIntDestroy(temp2);
end;


// Trialdivision of a FGInt upto 9999 and stopping when a divisor is found, returning ok=false

procedure FGIntTrialDiv9999(const FGInt: TFGInt; var ok: boolean);
var
  j: LongWord;
  i: integer;
begin
  if ((FGInt.Number[1] mod 2) = 0) then ok := false
  else
  begin
    i := 0;
    ok := true;
    while ok and (i < 1228) do
    begin
      i := i + 1;
      FGIntmodbyint(FGInt, primes[i], j);
      if j = 0 then ok := false;
    end;
  end;
end;


// A prng

procedure FGIntRandom1(var Seed, RandomFGInt: TFGInt);
var
  temp, base: TFGInt;
begin
  Base10StringToFGInt('281474976710656', base);
  Base10StringToFGInt('44485709377909', temp);
  FGIntMulMod(seed, temp, base, RandomFGInt);
  FGIntDestroy(temp);
  FGIntDestroy(base);
end;


// Perform a Rabin Miller Primality Test nrtest times on FGIntp, returns ok=true when FGIntp passes the test

procedure FGIntRabinMiller(var FGIntp: TFGInt; nrtest: Longword; var ok: boolean);
var
  j, b, i: LongWord;
  m, z, temp1, temp2, temp3, zero, one, two, pmin1: TFGInt;
  ok1, ok2: boolean;
begin
  randomize;
  j := 0;
  Base10StringToFGInt('0', zero);
  Base10StringToFGInt('1', one);
  Base10StringToFGInt('2', two);
  FGIntsub(FGIntp, one, temp1);
  FGIntsub(FGIntp, one, pmin1);

  b := 0;
  while (temp1.Number[1] mod 2) = 0 do
  begin
    b := b + 1;
    FGIntShiftRight(temp1);
  end;
  m := temp1;

  i := 0;
  ok := true;
  Randomize;
  while (i < nrtest) and ok do
  begin
    i := i + 1;
    Base10StringToFGInt(inttostr(Primes[Random(1227) + 1]), temp2);
    FGIntMontGomeryModExp(temp2, m, FGIntp, z);
    FGIntDestroy(temp2);
    ok1 := (FGIntCompareAbs(z, one) = Eq);
    ok2 := (FGIntCompareAbs(z, pmin1) = Eq);
    if not (ok1 or ok2) then
    begin

      while (ok and (j < b)) do
      begin
        if (j > 0) and ok1 then ok := false
        else
        begin
          j := j + 1;
          if (j < b) and (not ok2) then
          begin
            FGIntSquaremod(z, FGIntp, temp3);
            FGIntCopy(temp3, z);
            ok1 := (FGIntCompareAbs(z, one) = Eq);
            ok2 := (FGIntCompareAbs(z, pmin1) = Eq);
            if ok2 then j := b;
          end
          else if (not ok2) and (j >= b) then ok := false;
        end;
      end;

    end
  end;

  FGIntDestroy(zero);
  FGIntDestroy(one);
  FGIntDestroy(two);
  FGIntDestroy(m);
  FGIntDestroy(z);
  FGIntDestroy(pmin1);
end;


// Compute the coefficients from the Bezout Bachet theorem, FGInt1 * a + FGInt2 * b = GCD(FGInt1, FGInt2)

procedure FGIntBezoutBachet(var FGInt1, FGInt2, a, b: TFGInt);
var
  zero, r1, r2, r3, ta, gcd, temp, temp1, temp2: TFGInt;
begin
  if FGIntCompareAbs(FGInt1, FGInt2) <> St then
  begin
    FGIntcopy(FGInt1, r1);
    FGIntcopy(FGInt2, r2);
    Base10StringToFGInt('0', zero);
    Base10StringToFGInt('1', a);
    Base10StringToFGInt('0', ta);

    repeat
      FGIntdivmod(r1, r2, temp, r3);
      FGIntDestroy(r1);
      r1 := r2;
      r2 := r3;

      FGIntmul(ta, temp, temp1);
      FGIntsub(a, temp1, temp2);
      FGIntCopy(ta, a);
      FGIntCopy(temp2, ta);
      FGIntDestroy(temp1);

      FGIntDestroy(temp);
    until FGIntCompareAbs(r3, zero) = Eq;

    FGIntGCD(FGInt1, FGInt2, gcd);
    FGIntmul(a, FGInt1, temp1);
    FGIntsub(gcd, temp1, temp2);
    FGIntDestroy(temp1);
    FGIntdiv(temp2, FGInt2, b);
    FGIntDestroy(temp2);

    FGIntDestroy(ta);
    FGIntDestroy(r1);
    FGIntDestroy(r2);
    FGIntDestroy(gcd);
  end
  else FGIntBezoutBachet(FGInt2, FGInt1, b, a);
end;


// Find the (multiplicative) Modular inverse of a FGInt in a finite ring
// of additive order base

procedure FGIntModInv(const FGInt1, base: TFGInt; var Inverse: TFGInt);
var
  zero, one, r1, r2, r3, tb, gcd, temp, temp1, temp2: TFGInt;
begin
  Base10StringToFGInt('1', one);
  FGIntGCD(FGInt1, base, gcd);
  if FGIntCompareAbs(one, gcd) = Eq then
  begin
    FGIntcopy(base, r1);
    FGIntcopy(FGInt1, r2);
    Base10StringToFGInt('0', zero);
    Base10StringToFGInt('0', inverse);
    Base10StringToFGInt('1', tb);

    repeat
      FGIntDestroy(r3);
      FGIntdivmod(r1, r2, temp, r3);
      FGIntCopy(r2, r1);
      FGIntCopy(r3, r2);

      FGIntmul(tb, temp, temp1);
      FGIntsub(inverse, temp1, temp2);
      FGIntDestroy(inverse);
      FGIntDestroy(temp1);
      FGIntCopy(tb, inverse);
      FGIntCopy(temp2, tb);

      FGIntDestroy(temp);
    until FGIntCompareAbs(r3, zero) = Eq;

    if inverse.Sign = negative then
    begin
      FGIntadd(base, inverse, temp);
      FGIntCopy(temp, inverse);
    end;

    FGIntDestroy(tb);
    FGIntDestroy(r1);
    FGIntDestroy(r2);
  end;
  FGIntDestroy(gcd);
  FGIntDestroy(one);
end;


// Perform a (combined) primality test on FGIntp consisting of a trialdivision upto 8192,
// if the FGInt passes perform nrRMtests Rabin Miller primality tests, returns ok when a
// FGInt is probably prime

procedure FGIntPrimetest(var FGIntp: TFGInt; nrRMtests: integer; var ok: boolean);
begin
  FGIntTrialdiv9999(FGIntp, ok);
  if ok then FGIntRabinMiller(FGIntp, nrRMtests, ok);
end;


// Computes the Legendre symbol for a any number and
// p a prime, returns 0 if p divides a, 1 if a is a
// quadratic residu mod p, -1 if a is a quadratic
// nonresidu mod p

procedure FGIntLegendreSymbol(var a, p: TFGInt; var L: integer);
var
  temp1, temp2, temp3, temp4, temp5, zero, one: TFGInt;
  i: LongWord;
  ok1, ok2: boolean;
begin
  Base10StringToFGInt('0', zero);
  Base10StringToFGInt('1', one);
  FGIntMod(a, p, temp1);
  if FGIntCompareAbs(zero, temp1) = Eq then
  begin
    FGIntDestroy(temp1);
    L := 0;
  end
  else
  begin
    FGIntDestroy(temp1);
    FGIntCopy(p, temp1);
    FGIntCopy(a, temp2);
    L := 1;
    while FGIntCompareAbs(temp2, one) <> Eq do
    begin
      if (temp2.Number[1] mod 2) = 0 then
      begin
        FGIntSquare(temp1, temp3);
        FGIntSub(temp3, one, temp4);
        FGIntDestroy(temp3);
        FGIntDivByInt(temp4, temp3, 8, i);
        if (temp3.Number[1] mod 2) = 0 then ok1 := false else ok1 := true;
        FGIntDestroy(temp3);
        FGIntDestroy(temp4);
        if ok1 = true then L := L * (-1);
        FGIntDivByIntBis(temp2, 2, i);
      end
      else
      begin
        FGIntSub(temp1, one, temp3);
        FGIntSub(temp2, one, temp4);
        FGIntMul(temp3, temp4, temp5);
        FGIntDestroy(temp3);
        FGIntDestroy(temp4);
        FGIntDivByInt(temp5, temp3, 4, i);
        if (temp3.Number[1] mod 2) = 0 then ok2 := false else ok2 := true;
        FGIntDestroy(temp5);
        FGIntDestroy(temp3);
        if ok2 = true then L := L * (-1);
        FGIntMod(temp1, temp2, temp3);
        FGIntCopy(temp2, temp1);
        FGIntCopy(temp3, temp2);
      end;
    end;
    FGIntDestroy(temp1);
    FGIntDestroy(temp2);
  end;
  FGIntDestroy(zero);
  FGIntDestroy(one);
end;


// Compute a square root modulo a prime number
// SquareRoot^2 mod Prime = Square

procedure FGIntSquareRootModP(Square, Prime: TFGInt; var SquareRoot: TFGInt);
var
  one, n, b, s, r, temp, temp1, temp2, temp3: TFGInt;
  a, i, j: longint;
  L: Integer;
begin
  Base2StringToFGInt('1', one);
  Base2StringToFGInt('10', n);
  a := 0;
  FGIntLegendreSymbol(n, Prime, L);
  while L <> -1 do
  begin
    FGIntAddBis(n, one);
    FGIntLegendreSymbol(n, Prime, L);
  end;
  FGIntCopy(Prime, s);
  s.Number[1] := s.Number[1] - 1;
  while (s.Number[1] mod 2) = 0 do
  begin
    FGIntShiftRight(s);
    a := a + 1;
  end;
  FGIntMontgomeryModExp(n, s, Prime, b);
  FGIntAdd(s, one, temp);
  FGIntShiftRight(temp);
  FGIntMontgomeryModExp(Square, temp, Prime, r);
  FGIntDestroy(temp);
  FGIntModInv(Square, Prime, temp1);

  for i := 0 to (a - 2) do
  begin
    FGIntSquareMod(r, Prime, temp2);
    FGIntMulMod(temp1, temp2, Prime, temp);
    FGIntDestroy(temp2);
    for j := 1 to (a - i - 2) do
    begin
      FGIntSquareMod(temp, Prime, temp2);
      FGIntDestroy(temp);
      FGIntCopy(temp2, temp);
      FGIntDestroy(temp2);
    end;
    if FGIntCompareAbs(temp, one) <> Eq then
    begin
      FGIntMulMod(r, b, Prime, temp3);
      FGIntDestroy(r);
      FGIntCopy(temp3, r);
      FGIntDestroy(temp3);
    end;
    FGIntDestroy(temp);
    FGIntDestroy(temp2);
    if i = (a - 2) then break;
    FGIntSquareMod(b, Prime, temp3);
    FGIntDestroy(b);
    FGIntCopy(temp3, b);
    FGIntDestroy(temp3);
  end;

  FGIntCopy(r, SquareRoot);
  FGIntDestroy(r);
  FGIntDestroy(s);
  FGIntDestroy(b);
  FGIntDestroy(temp1);
  FGIntDestroy(one);
  FGIntDestroy(n);
end;


{add by peta}

function FGIntBitLength(const FGInt: TFGInt): integer;
var
  S, X: string;
  i: LongWord;
  j: integer;
  number: integer;
begin
  S := '';
  X := '';


  for i := FGInt.Number[0] downto 1 do if FGInt.Number[i] <> 0 then break;
  if i = 0 then i := 1;
  for j := 31 downto 0 do if (1 and (FGInt.Number[i] shr j)) = 1 then break;

  result := (i - 1) * 31 + j + 1;

  ///////////////////////

  {s := s + format('[%d %d Size=%d]', [i, j, (i - 1) * 31 + j + 1]);
  for i := FGInt.Number[0] downto 1 do
  begin
    s := s + ' ' + inttohex(FGInt.Number[i], 8);
    if (FGInt.Number[i] <> 0) and (X = '') then
    begin


      for j := 0 to 30 do
        if (1 and (FGInt.Number[i] shr j)) = 1 then
          X := '1' +X
        else
          X := '0' + X;

      X := X + #13#10;
      for j := 30 downto 0 do
        if (1 and (FGInt.Number[i] shr j)) = 1 then
          X := X + '1'
        else
          X := X + '0';
    end;
  end;
  showmessage(s+#13#10+X); }

end;
{add by peta}

{add by peta}

procedure FGIntAnd(const FGInt1, FGInt2: TFGInt; var Sum: TFGInt); {add by peta}
var
  i, size1, size2, size, rest, Trest: LongWord;
begin
  size1 := FGInt1.Number[0];
  size2 := FGInt2.Number[0];
  if size1 < size2 then FGIntAnd(FGInt2, FGInt1, Sum)
  else
  begin
    FGIntCopy(FGInt2, sum);
    for i := 1 to size2 do
    begin
      Sum.Number[i] := FGInt1.Number[i] and FGInt2.Number[i];
    end;
  end;
end;
{add by peta}
{peta}

procedure FGIntShiftLeftX(var FGInt: TFGInt; times: integer);
var
  i: integer;
begin
  for i := 1 to times do FGIntShiftLeft(FGInt);
end;
{peta}

{peta}

procedure FGIntShiftRightX(var FGInt: TFGInt; times: integer); {peta}
var
  i: integer;
begin
  for i := 1 to times do FGIntShiftRight(FGInt);
end;
{peta}

end.

