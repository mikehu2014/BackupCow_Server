{This implementation is made by Walied Othman
Improved by Song Zhenwei

http://triade.studentenweb.org

copyright 2000, Walied Othman}


unit FGIntRSA;

interface

{$H+}

uses SysUtils, FGInt, dialogs;


function RemoveZeroHead(s: string): string;
function RSAEncryptEx(p: string; var exp, modb: TFGInt; var E: string): string;
function RSADecryptEx(E: string; var exp, modb: TFGInt; var D: string): string;
procedure RSAEncrypt(P: string; var exp, modb: TFGInt; var E: string);
procedure RSADecrypt(E: string; var exp, modb, d_p, d_q, p, q: TFGInt; var D: string);

procedure RSASign(M: string; var d, n, dp, dq, p, q: TFGInt; var S: string);
procedure RSAVerify(M, S: string; var e, n: TFGInt; var valid: boolean);


implementation



// Encrypt a string with the RSA algorithm, P^exp mod modb = E

procedure RSAEncrypt(P: string; var exp, modb: TFGInt; var E: string);
var
  i, j, modbits: longint;
  PGInt, temp, zero: TFGInt;
  tempstr1, tempstr2, tempstr3: string;
begin
  Base2StringToFGInt('0', zero);
  FGIntToBase2String(modb, tempstr1);
  modbits := length(tempstr1);
  convertBase256to2(P, tempstr1);

  //  tempstr1 := '101' + tempstr1;
  //---Head--- tempstr1 := '1' + tempstr1;

  j := modbits - 1;
  while (length(tempstr1) mod j) <> 0 do tempstr1 := '0' + tempstr1;

  j := length(tempstr1) div (modbits - 1);
  tempstr2 := '';
  for i := 1 to j do
  begin
    tempstr3 := copy(tempstr1, 1, modbits - 1);
    while (copy(tempstr3, 1, 1) = '0') and (length(tempstr3) > 1) do delete(tempstr3, 1, 1);
    Base2StringToFGInt(tempstr3, PGInt);
    delete(tempstr1, 1, modbits - 1);
    if tempstr3 = '0' then FGIntCopy(zero, temp) else FGIntMontgomeryModExp(PGInt, exp, modb, temp);
    FGIntDestroy(PGInt);
    tempstr3 := '';
    FGIntToBase2String(temp, tempstr3);
    while (length(tempstr3) mod modbits) <> 0 do tempstr3 := '0' + tempstr3;
    tempstr2 := tempstr2 + tempstr3;
    FGIntdestroy(temp);
  end;

  while (tempstr2[1] = '0') and (length(tempstr2) > 1) do delete(tempstr2, 1, 1);
  ConvertBase2To16(tempstr2, E);
  FGIntDestroy(zero);
end;

function RSAEncryptEx( p: string; var exp, modb: TFGInt; var E: string): string;
var
  i, encbits, times, keybits, databits: longint;
  PGInt, temp, zero, mask, one, data, spitd, spitd2, bl_enc: TFGInt;
  tempstr1, AddUpStr, tempstr3, s: string;
  strLog: string;
begin
  Base2StringToFGInt('0', zero);

  keybits := FGIntBitLength(modb);


  {if a = 16 then convertBase16to2(P, tempstr1);
  if a = 64 then convertBase64to2(P, tempstr1);
  if a = 256 then}
  convertBase256to2(P, tempstr1);

  Base2StringToFGInt(tempstr1, data);
  databits := FGIntBitLength(data);


  encbits := keybits - 1;

  Base10StringToFGInt('0', mask);
  Base10StringToFGInt('1', one);
  for i := 1 to keybits - 1 do
  begin
    FGIntShiftLeft(mask);
    FGIntAdd(mask, one, mask);
  end;
  FGInttoBase16String(mask, s);
  strLog := strLog + format('keybits=%d;databits=%d', [keybits, databits]);
  strLog := strLog + format('mask=%s', [s]);

  //while (length(tempstr1) mod encbits) <> 0 do tempstr1 := '0' + tempstr1;

  times := databits div encbits;
  inc(times);

  AddUpStr := '';
  Base10StringToFGInt('0', bl_enc);

  for i := 1 to times do
  begin
    FGIntCopy(data, spitd);
    FGIntShiftRightX(spitd, (times - i) * (keybits - 1));
    FGIntCopy(spitd, spitd2);
    {//}FGIntToBase16String(spitd2, s); strLog := strLog + #13#10 + inttostr(i) + ' unmask:' + s;

    FGIntAnd(spitd2, mask, spitd);
    {//}FGIntToBase16String(spitd2, s); strLog := strLog + #13#10 + inttostr(i) + ' mask:' + s;


    FGIntCopy(spitd, PGInt);
    FGIntToBase16String(PGInt, tempstr3); strLog := strLog + #13#10 + inttostr(i) + ' Before:' + tempstr3;

    if tempstr3 = '0' then
      FGIntCopy(zero, temp)
    else
      FGIntMontgomeryModExp(PGInt, exp, modb, temp);

    //bl_enc:=bl_enc+temp<<(keybits*(times-i)));

    {//}FGIntToBase16String(temp, s); strLog := strLog + #13#10 + inttostr(i) + ' result:' + s;

    FGIntShiftLeftX(temp, (keybits * (times - i)));
    FGIntAdd(bl_enc, temp, bl_enc);

    {//}FGIntToBase16String(bl_enc, s); strLog := strLog + #13#10 + inttostr(i) + ' sumup:' + s;

    FGIntDestroy(PGInt);

    FGIntdestroy(temp);
  end;

{ if b = 256 then FGIntToBase256String(bl_enc, e);
  if b = 16 then }FGIntToBase16String(bl_enc, e);



  result := strLog;
  FGIntDestroy(zero);
end;

// Decrypt a string with the RSA algorithm, E^exp mod modb = D
// provide nil for exp.Number if you want a speedup by using the chinese
// remainder theorem, modb = p*q, d_p*e mod (p-1) = 1 and
// d_q*e mod (q-1) where e is the encryption exponent used

function RSADecryptEx(E: string; var exp, modb: TFGInt; var D: string): string;
var
  i, times, keybits, dataBits: longint;
  bl_dec, spit_enc, spit_enc_tmp, encData, mask, one, temp, zero: TFGInt;
  strLog, s: string;
begin
  Base2StringToFGInt('0', zero);
  keybits := FGIntBitLength(modb);

  Base16StringToFGInt(e, encData);

  dataBits := FGIntBitLength(encData);

  Base10StringToFGInt('0', mask);
  Base10StringToFGInt('1', one);
  for i := 1 to keybits do
  begin
    FGIntShiftLeft(mask);
    FGIntAdd(mask, one, mask);
  end;

  FGIntToBase16String(mask, s);
  strLog := strLog + #13#10 + format('keybits=%d ; databits=%d', [keybits, databits]);
  strLog := strLog + #13#10 + format('mask=%s', [s]);

  times := (dataBits - 1) div keybits;
  inc(times);


  Base10StringToFGInt('0', bl_dec);

  for i := 1 to times do
  begin

    FGIntCopy(encData, spit_enc_tmp); //spit_enc:= encData;
    FGIntToBase16String(spit_enc_tmp, s); strLog := strLog + #13#10 + inttostr(i) + ' All:' + s;

    FGIntShiftRIghtX(spit_enc_tmp, (keybits * (times - i))); //spit_enc
    FGIntToBase16String(spit_enc_tmp, s); strLog := strLog + #13#10 + inttostr(i) + ' After>>:' + s;
    FGIntAnd(spit_enc_tmp, mask, spit_enc); //spit_enc:=spit_enc and mask;

    FGIntToBase16String(spit_enc, s); strLog := strLog + #13#10 + inttostr(i) + ' src:' + s;
    if s = '0' then
      FGIntCopy(zero, temp)
    else
      FGIntMontgomeryModExp(spit_enc, exp, modb, temp);

    FGIntShiftLeftX(temp, (keybits - 1) * (times - i));
    FGIntAdd(bl_dec, temp, bl_dec);
  end;

  FGIntToBase256String(bl_dec, d);

  FGIntDestroy(zero);
  result := strLog;

end;


procedure RSADecrypt(E: string; var exp, modb, d_p, d_q, p, q: TFGInt; var D: string);
var
  i, j, modbits: longint;
  EGInt, temp, temp1, temp2, temp3, ppinvq, qqinvp, zero: TFGInt;
  tempstr1, tempstr2, tempstr3: string;
begin
  Base2StringToFGInt('0', zero);
  FGIntToBase2String(modb, tempstr1);
  modbits := length(tempstr1);
  convertBase256to2(E, tempstr1);

  while copy(tempstr1, 1, 1) = '0' do delete(tempstr1, 1, 1);


  while (length(tempstr1) mod modbits) <> 0 do tempstr1 := '0' + tempstr1;
  if exp.Number = nil then
  begin
    FGIntModInv(q, p, temp1);
    FGIntMul(q, temp1, qqinvp);
    FGIntDestroy(temp1);
    FGIntModInv(p, q, temp1);
    FGIntMul(p, temp1, ppinvq);
    FGIntDestroy(temp1);
  end;

  j := length(tempstr1) div modbits;
  tempstr2 := '';
  for i := 1 to j do
  begin
    tempstr3 := copy(tempstr1, 1, modbits);
    while (copy(tempstr3, 1, 1) = '0') and (length(tempstr3) > 1) do delete(tempstr3, 1, 1);
    Base2StringToFGInt(tempstr3, EGInt);
    delete(tempstr1, 1, modbits);
    if tempstr3 = '0' then FGIntCopy(zero, temp) else
    begin
      if exp.Number <> nil then FGIntMontgomeryModExp(EGInt, exp, modb, temp) else
      begin
        FGIntMontgomeryModExp(EGInt, d_p, p, temp1);
        FGIntMul(temp1, qqinvp, temp3);
        FGIntCopy(temp3, temp1);
        FGIntMontgomeryModExp(EGInt, d_q, q, temp2);
        FGIntMul(temp2, ppinvq, temp3);
        FGIntCopy(temp3, temp2);
        FGIntAddMod(temp1, temp2, modb, temp);
        FGIntDestroy(temp1);
        FGIntDestroy(temp2);
      end;
    end;
    FGIntDestroy(EGInt);
    tempstr3 := '';
    FGIntToBase2String(temp, tempstr3);
    while (length(tempstr3) mod (modbits - 1)) <> 0 do tempstr3 := '0' + tempstr3;
    tempstr2 := tempstr2 + tempstr3;
    FGIntdestroy(temp);
  end;

  if exp.Number = nil then
  begin
    FGIntDestroy(ppinvq);
    FGIntDestroy(qqinvp);
  end;

  {while (not (copy(tempstr2, 1, 3) = '101')) and (length(tempstr2) > 3) do delete(tempstr2, 1, 1);
  delete(tempstr2, 1, 3);}
  //---Head--- tempstr2:=copy(tempstr2,pos('1',tempstr2)+1,length(tempstr2));
  tempstr2 := copy(tempstr2, pos('1', tempstr2), length(tempstr2));
  while (length(tempstr2) mod 8) <> 0 do tempstr2 := '0' + tempstr2;


  ConvertBase2To16(tempstr2, D);
  FGIntDestroy(zero);
end;


// Sign strings with the RSA algorithm, M^d mod n = S
// provide nil for exp.Number if you want a speedup by using the chinese
// remainder theorem, n = p*q, dp*e mod (p-1) = 1 and
// dq*e mod (q-1) where e is the encryption exponent used


procedure RSASign(M: string; var d, n, dp, dq, p, q: TFGInt; var S: string);
var
  MGInt, SGInt, temp, temp1, temp2, temp3, ppinvq, qqinvp: TFGInt;
begin
  Base256StringToFGInt(M, MGInt);
  if d.Number <> nil then FGIntMontgomeryModExp(MGInt, d, n, SGInt) else
  begin
    FGIntModInv(p, q, temp);
    FGIntMul(p, temp, ppinvq);
    FGIntDestroy(temp);
    FGIntModInv(q, p, temp);
    FGIntMul(q, temp, qqinvp);
    FGIntDestroy(temp);
    FGIntMontgomeryModExp(MGInt, dp, p, temp1);
    FGIntMul(temp1, qqinvp, temp2);
    FGIntCopy(temp2, temp1);
    FGIntMontgomeryModExp(MGInt, dq, q, temp2);
    FGIntMul(temp2, ppinvq, temp3);
    FGIntCopy(temp3, temp2);
    FGIntAddMod(temp1, temp2, n, SGInt);
    FGIntDestroy(temp1);
    FGIntDestroy(temp2);
    FGIntDestroy(ppinvq);
    FGIntDestroy(qqinvp);
  end;
  FGIntToBase256String(SGInt, S);
  FGIntDestroy(MGInt);
  FGIntDestroy(SGInt);
end;


// Verify digitally signed strings with the RSA algorihthm,
// If M = S^e mod n then ok:=true else ok:=false

procedure RSAVerify(M, S: string; var e, n: TFGInt; var valid: boolean);
var
  MGInt, SGInt, temp: TFGInt;
begin
  Base256StringToFGInt(S, SGInt);
  Base256StringToFGInt(M, MGInt);
  FGIntMod(MGInt, n, temp);
  FGIntCopy(temp, MGInt);
  FGIntMontgomeryModExp(SGInt, e, n, temp);
  FGIntCopy(temp, SGInt);
  valid := (FGIntCompareAbs(SGInt, MGInt) = Eq);
  FGIntDestroy(SGInt);
  FGIntDestroy(MGInt);
end;

{add by peta}

function RemoveZeroHead(s: string): string;
var
  i: integer;
begin
  result := '0';

  for i := 1 to length(s) do
  begin
    if s[i] <> '0' then
    begin
      result := copy(s, i, length(s));
      break;
    end;
  end;
end;
{add by peta}

end.

