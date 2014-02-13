{*************************************************************}
{            CRC Calculator Unit for Delphi 16/32             }
{ Version:   2.0                                              }
{ Author:    Aleksey Kuznetsov                                }
{ E-Mail:    aleksey@utilmind.com                             }
{ Home Page: http://www.utilmind.com                          }
{ Created:   March, 30, 1999 for Karol Suchanek               }
{ Modified:  April, 6, 1999                                   }
{ Legal:     Copyright (c) 1999, UtilMind Solutions           }
{            Idea: Edwin T. Floyd                             }
{*************************************************************}
{ This unit provides three speed-optimized functions to       }
{ compute (or continue computation of) a Cyclic Redundency    }
{ Check (CRC). Applicable to XModem protocol (16-bit CRC),    }
{ SEA's "ARC" utility, PKZip (32-bit CRC) and many others     }
{ compatible software.                                        }
{ Please see TESTCRC.DPR for example.                         }
{*************************************************************}
{ Each function takes three parameters:                       }
{                                                             }
{ InitCRC - The initial CRC value.  This may be the           }
{ recommended initialization value if this is the first or    }
{ only block to be checked, or this may be a previously       }
{ computed CRC value if this is a continuation.               }
{   XModem and ARC usually starts with zero (0), 32 bit crc   }
{   starts with all bits on ($FFFFFFFF).                      }
{                                                             }
{ Buffer - An untyped parameter (Pointer^) specifying the     }
{ beginning of the memory area to be checked.                 }
{                                                             }
{ Length - A word indicating the length of the memory area to }
{ be checked. If Length is zero, the function returns the     }
{ value of InitCRC.                                           }
{                                                             }
{ The function result is the updated CRC.                     }
{*************************************************************}

unit CRC;

interface

uses Classes, Windows, Messages, SysUtils, Variants, TypInfo, ActiveX;

function UpdateCRC16(InitCRC: Word; var Buffer;
  Length: {$IFDEF Win32}LongInt{$ELSE}Word{$ENDIF}): Word;
{ I believe this is the CRC used by the XModem protocol.
  The transmitting end should initialize with zero, UpdateCRC16 for
  the block, Continue the UpdateCRC16 for two nulls, and append the
  result (hi order byte first) to the transmitted block. The receiver
  should initialize with zero and UpdateCRC16 for the received block
  including the two byte CRC. The result will be zero (why?) if there
  were no transmission errors. (I have not tested this function with
  an actual XModem implementation, though I did verify the behavior
  just described. See TESTCRC.DPR.) }

function UpdateCRCArc(InitCRC: Word; var Buffer;
  Length: {$IFDEF Win32}LongInt{$ELSE}Word{$ENDIF}): Word;
{ This function computes the CRC used by SEA's ARC utility.
  Initialize with zero.}

function UpdateCRC32(InitCRC: LongInt; var Buffer;
{$IFDEF Win32}Length: LongInt{$ELSE}Length: Word{$ENDIF}): LongInt;
{ This function computes the CRC used by PKZIP and Forsberg's ZModem.
  Initialize with high-values ($FFFFFFFF), and finish by inverting
  allbits (Not). }

function FileCRC16(FileName: string; var CRC16: Word): Boolean; { Return True if ok }
function FileCRCArc(FileName: string; var CRCArc: Word): Boolean; { Return True if ok }
function FileCRC32(FileName: string; var CRC32: LongInt): Boolean; { Return True if ok }

implementation

const
  CrcArcTab: array[0..$FF] of Word =
  ($00000, $0C0C1, $0C181, $00140, $0C301, $003C0, $00280, $0C241,
    $0C601, $006C0, $00780, $0C741, $00500, $0C5C1, $0C481, $00440,
    $0CC01, $00CC0, $00D80, $0CD41, $00F00, $0CFC1, $0CE81, $00E40,
    $00A00, $0CAC1, $0CB81, $00B40, $0C901, $009C0, $00880, $0C841,
    $0D801, $018C0, $01980, $0D941, $01B00, $0DBC1, $0DA81, $01A40,
    $01E00, $0DEC1, $0DF81, $01F40, $0DD01, $01DC0, $01C80, $0DC41,
    $01400, $0D4C1, $0D581, $01540, $0D701, $017C0, $01680, $0D641,
    $0D201, $012C0, $01380, $0D341, $01100, $0D1C1, $0D081, $01040,
    $0F001, $030C0, $03180, $0F141, $03300, $0F3C1, $0F281, $03240,
    $03600, $0F6C1, $0F781, $03740, $0F501, $035C0, $03480, $0F441,
    $03C00, $0FCC1, $0FD81, $03D40, $0FF01, $03FC0, $03E80, $0FE41,
    $0FA01, $03AC0, $03B80, $0FB41, $03900, $0F9C1, $0F881, $03840,
    $02800, $0E8C1, $0E981, $02940, $0EB01, $02BC0, $02A80, $0EA41,
    $0EE01, $02EC0, $02F80, $0EF41, $02D00, $0EDC1, $0EC81, $02C40,
    $0E401, $024C0, $02580, $0E541, $02700, $0E7C1, $0E681, $02640,
    $02200, $0E2C1, $0E381, $02340, $0E101, $021C0, $02080, $0E041,
    $0A001, $060C0, $06180, $0A141, $06300, $0A3C1, $0A281, $06240,
    $06600, $0A6C1, $0A781, $06740, $0A501, $065C0, $06480, $0A441,
    $06C00, $0ACC1, $0AD81, $06D40, $0AF01, $06FC0, $06E80, $0AE41,
    $0AA01, $06AC0, $06B80, $0AB41, $06900, $0A9C1, $0A881, $06840,
    $07800, $0B8C1, $0B981, $07940, $0BB01, $07BC0, $07A80, $0BA41,
    $0BE01, $07EC0, $07F80, $0BF41, $07D00, $0BDC1, $0BC81, $07C40,
    $0B401, $074C0, $07580, $0B541, $07700, $0B7C1, $0B681, $07640,
    $07200, $0B2C1, $0B381, $07340, $0B101, $071C0, $07080, $0B041,
    $05000, $090C1, $09181, $05140, $09301, $053C0, $05280, $09241,
    $09601, $056C0, $05780, $09741, $05500, $095C1, $09481, $05440,
    $09C01, $05CC0, $05D80, $09D41, $05F00, $09FC1, $09E81, $05E40,
    $05A00, $09AC1, $09B81, $05B40, $09901, $059C0, $05880, $09841,
    $08801, $048C0, $04980, $08941, $04B00, $08BC1, $08A81, $04A40,
    $04E00, $08EC1, $08F81, $04F40, $08D01, $04DC0, $04C80, $08C41,
    $04400, $084C1, $08581, $04540, $08701, $047C0, $04680, $08641,
    $08201, $042C0, $04380, $08341, $04100, $081C1, $08081, $04040);

  Crc16Tab: array[0..$FF] of Word =
  ($00000, $01021, $02042, $03063, $04084, $050A5, $060C6, $070E7,
    $08108, $09129, $0A14A, $0B16B, $0C18C, $0D1AD, $0E1CE, $0F1EF,
    $01231, $00210, $03273, $02252, $052B5, $04294, $072F7, $062D6,
    $09339, $08318, $0B37B, $0A35A, $0D3BD, $0C39C, $0F3FF, $0E3DE,
    $02462, $03443, $00420, $01401, $064E6, $074C7, $044A4, $05485,
    $0A56A, $0B54B, $08528, $09509, $0E5EE, $0F5CF, $0C5AC, $0D58D,
    $03653, $02672, $01611, $00630, $076D7, $066F6, $05695, $046B4,
    $0B75B, $0A77A, $09719, $08738, $0F7DF, $0E7FE, $0D79D, $0C7BC,
    $048C4, $058E5, $06886, $078A7, $00840, $01861, $02802, $03823,
    $0C9CC, $0D9ED, $0E98E, $0F9AF, $08948, $09969, $0A90A, $0B92B,
    $05AF5, $04AD4, $07AB7, $06A96, $01A71, $00A50, $03A33, $02A12,
    $0DBFD, $0CBDC, $0FBBF, $0EB9E, $09B79, $08B58, $0BB3B, $0AB1A,
    $06CA6, $07C87, $04CE4, $05CC5, $02C22, $03C03, $00C60, $01C41,
    $0EDAE, $0FD8F, $0CDEC, $0DDCD, $0AD2A, $0BD0B, $08D68, $09D49,
    $07E97, $06EB6, $05ED5, $04EF4, $03E13, $02E32, $01E51, $00E70,
    $0FF9F, $0EFBE, $0DFDD, $0CFFC, $0BF1B, $0AF3A, $09F59, $08F78,
    $09188, $081A9, $0B1CA, $0A1EB, $0D10C, $0C12D, $0F14E, $0E16F,
    $01080, $000A1, $030C2, $020E3, $05004, $04025, $07046, $06067,
    $083B9, $09398, $0A3FB, $0B3DA, $0C33D, $0D31C, $0E37F, $0F35E,
    $002B1, $01290, $022F3, $032D2, $04235, $05214, $06277, $07256,
    $0B5EA, $0A5CB, $095A8, $08589, $0F56E, $0E54F, $0D52C, $0C50D,
    $034E2, $024C3, $014A0, $00481, $07466, $06447, $05424, $04405,
    $0A7DB, $0B7FA, $08799, $097B8, $0E75F, $0F77E, $0C71D, $0D73C,
    $026D3, $036F2, $00691, $016B0, $06657, $07676, $04615, $05634,
    $0D94C, $0C96D, $0F90E, $0E92F, $099C8, $089E9, $0B98A, $0A9AB,
    $05844, $04865, $07806, $06827, $018C0, $008E1, $03882, $028A3,
    $0CB7D, $0DB5C, $0EB3F, $0FB1E, $08BF9, $09BD8, $0ABBB, $0BB9A,
    $04A75, $05A54, $06A37, $07A16, $00AF1, $01AD0, $02AB3, $03A92,
    $0FD2E, $0ED0F, $0DD6C, $0CD4D, $0BDAA, $0AD8B, $09DE8, $08DC9,
    $07C26, $06C07, $05C64, $04C45, $03CA2, $02C83, $01CE0, $00CC1,
    $0EF1F, $0FF3E, $0CF5D, $0DF7C, $0AF9B, $0BFBA, $08FD9, $09FF8,
    $06E17, $07E36, $04E55, $05E74, $02E93, $03EB2, $00ED1, $01EF0);

  Crc32Tab: array[0..$FF] of LongInt =
  ($00000000, $77073096, $EE0E612C, $990951BA, $076DC419, $706AF48F,
    $E963A535, $9E6495A3, $0EDB8832, $79DCB8A4, $E0D5E91E, $97D2D988,
    $09B64C2B, $7EB17CBD, $E7B82D07, $90BF1D91, $1DB71064, $6AB020F2,
    $F3B97148, $84BE41DE, $1ADAD47D, $6DDDE4EB, $F4D4B551, $83D385C7,
    $136C9856, $646BA8C0, $FD62F97A, $8A65C9EC, $14015C4F, $63066CD9,
    $FA0F3D63, $8D080DF5, $3B6E20C8, $4C69105E, $D56041E4, $A2677172,
    $3C03E4D1, $4B04D447, $D20D85FD, $A50AB56B, $35B5A8FA, $42B2986C,
    $DBBBC9D6, $ACBCF940, $32D86CE3, $45DF5C75, $DCD60DCF, $ABD13D59,
    $26D930AC, $51DE003A, $C8D75180, $BFD06116, $21B4F4B5, $56B3C423,
    $CFBA9599, $B8BDA50F, $2802B89E, $5F058808, $C60CD9B2, $B10BE924,
    $2F6F7C87, $58684C11, $C1611DAB, $B6662D3D, $76DC4190, $01DB7106,
    $98D220BC, $EFD5102A, $71B18589, $06B6B51F, $9FBFE4A5, $E8B8D433,
    $7807C9A2, $0F00F934, $9609A88E, $E10E9818, $7F6A0DBB, $086D3D2D,
    $91646C97, $E6635C01, $6B6B51F4, $1C6C6162, $856530D8, $F262004E,
    $6C0695ED, $1B01A57B, $8208F4C1, $F50FC457, $65B0D9C6, $12B7E950,
    $8BBEB8EA, $FCB9887C, $62DD1DDF, $15DA2D49, $8CD37CF3, $FBD44C65,
    $4DB26158, $3AB551CE, $A3BC0074, $D4BB30E2, $4ADFA541, $3DD895D7,
    $A4D1C46D, $D3D6F4FB, $4369E96A, $346ED9FC, $AD678846, $DA60B8D0,
    $44042D73, $33031DE5, $AA0A4C5F, $DD0D7CC9, $5005713C, $270241AA,
    $BE0B1010, $C90C2086, $5768B525, $206F85B3, $B966D409, $CE61E49F,
    $5EDEF90E, $29D9C998, $B0D09822, $C7D7A8B4, $59B33D17, $2EB40D81,
    $B7BD5C3B, $C0BA6CAD, $EDB88320, $9ABFB3B6, $03B6E20C, $74B1D29A,
    $EAD54739, $9DD277AF, $04DB2615, $73DC1683, $E3630B12, $94643B84,
    $0D6D6A3E, $7A6A5AA8, $E40ECF0B, $9309FF9D, $0A00AE27, $7D079EB1,
    $F00F9344, $8708A3D2, $1E01F268, $6906C2FE, $F762575D, $806567CB,
    $196C3671, $6E6B06E7, $FED41B76, $89D32BE0, $10DA7A5A, $67DD4ACC,
    $F9B9DF6F, $8EBEEFF9, $17B7BE43, $60B08ED5, $D6D6A3E8, $A1D1937E,
    $38D8C2C4, $4FDFF252, $D1BB67F1, $A6BC5767, $3FB506DD, $48B2364B,
    $D80D2BDA, $AF0A1B4C, $36034AF6, $41047A60, $DF60EFC3, $A867DF55,
    $316E8EEF, $4669BE79, $CB61B38C, $BC66831A, $256FD2A0, $5268E236,
    $CC0C7795, $BB0B4703, $220216B9, $5505262F, $C5BA3BBE, $B2BD0B28,
    $2BB45A92, $5CB36A04, $C2D7FFA7, $B5D0CF31, $2CD99E8B, $5BDEAE1D,
    $9B64C2B0, $EC63F226, $756AA39C, $026D930A, $9C0906A9, $EB0E363F,
    $72076785, $05005713, $95BF4A82, $E2B87A14, $7BB12BAE, $0CB61B38,
    $92D28E9B, $E5D5BE0D, $7CDCEFB7, $0BDBDF21, $86D3D2D4, $F1D4E242,
    $68DDB3F8, $1FDA836E, $81BE16CD, $F6B9265B, $6FB077E1, $18B74777,
    $88085AE6, $FF0F6A70, $66063BCA, $11010B5C, $8F659EFF, $F862AE69,
    $616BFFD3, $166CCF45, $A00AE278, $D70DD2EE, $4E048354, $3903B3C2,
    $A7672661, $D06016F7, $4969474D, $3E6E77DB, $AED16A4A, $D9D65ADC,
    $40DF0B66, $37D83BF0, $A9BCAE53, $DEBB9EC5, $47B2CF7F, $30B5FFE9,
    $BDBDF21C, $CABAC28A, $53B39330, $24B4A3A6, $BAD03605, $CDD70693,
    $54DE5729, $23D967BF, $B3667A2E, $C4614AB8, $5D681B02, $2A6F2B94,
    $B40BBE37, $C30C8EA1, $5A05DF1B, $2D02EF8D);

function UpdateCRC16(InitCRC: Word; var Buffer;
  Length: {$IFDEF Win32}LongInt{$ELSE}Word{$ENDIF}): Word;
begin
  asm
  {$IFDEF Win32}
         push   esi
         push   edi
         push   eax
         push   ebx
         push   ecx
         push   edx
         lea    edi, Crc16Tab
         mov    esi, Buffer
         mov    ax, InitCrc
         mov    ecx, Length
         or     ecx, ecx
         jz     @@done
@@loop:
         xor    ebx, ebx
         mov    bl, ah
         mov    ah, al
         lodsb
         shl    bx, 1
         add    ebx, edi
         xor    ax, [ebx]
         loop   @@loop
@@done:
         mov    Result, ax
         pop    edx
         pop    ecx
         pop    ebx
         pop    eax
         pop    edi
         pop    esi
  {$ELSE}
         lea    di, Crc16Tab
         push   ds
         pop    es
         push   ds
         lds    si, Buffer
         mov    ax, InitCrc
         mov    cx, Length
         or     cx, cx
         jz     @@done
@@loop:
         xor    bx, bx
         mov    bl, ah
         mov    ah, al
         lodsb
         shl    bx, 1
         xor    ax, es:[di + bx]
         loop   @@loop
         pop    ds
@@done:
         mov    Result, ax
   {$ENDIF}
  end;
end;

function UpdateCRCArc(InitCRC: Word; var Buffer;
  Length: {$IFDEF Win32}LongInt{$ELSE}Word{$ENDIF}): Word;
begin
  asm
  {$IFDEF Win32}
         push   esi
         push   edi
         push   eax
         push   ebx
         push   ecx
         push   edx
         lea    edi, CrcArcTab
         mov    esi, Buffer
         mov    ax, InitCrc
         mov    ecx, Length
         or     ecx, ecx
         jz     @@done
@@loop:
         xor    ebx, ebx
         mov    bl, al
         lodsb
         xor    bl, al
         shl    bx, 1
         add    ebx, edi
         mov    bx, [ebx]
         xor    bl, ah
         mov    ax, bx
         loop   @@loop
@@done:
         mov    Result, ax
         pop    edx
         pop    ecx
         pop    ebx
         pop    eax
         pop    edi
         pop    esi
  {$ELSE}
         lea    di, CrcArcTab
         push   ds
         pop    es
         push   ds
         lds    si, Buffer
         mov    ax, InitCrc
         mov    cx, Length
         or     cx, cx
         jz     @@done
@@loop:
         xor    bx, bx
         mov    bl, al
         lodsb
         xor    bl, al
         shl    bx, 1
         mov    bx, es:[di + bx]
         xor    bl, ah
         mov    ax, bx
         loop   @@loop
         pop    ds
@@done:
         mov    Result, ax
   {$ENDIF}
  end;
end;

function UpdateCRC32(InitCRC: LongInt; var Buffer;
{$IFDEF Win32}Length: LongInt{$ELSE}Length: Word{$ENDIF}): LongInt;
begin
  asm
{$IFDEF Win32}
         push   esi
         push   edi
         push   eax
         push   ebx
         push   ecx
         push   edx
         lea    edi, Crc32Tab
         mov    esi, Buffer
         mov    ax, word ptr InitCRC
         mov    dx, word ptr InitCRC + 2
         mov    ecx, Length
         or     ecx, ecx
         jz     @@done
@@loop:
         xor    ebx, ebx
         mov    bl, al
         lodsb
         xor    bl, al
         mov    al, ah
         mov    ah, dl
         mov    dl, dh
         xor    dh, dh
         shl    bx, 1
         shl    bx, 1
         add    ebx, edi
         xor    ax, [ebx]
         xor    dx, [ebx + 2]
         loop   @@loop
@@done:
         mov    word ptr Result, ax
         mov    word ptr Result + 2, dx
         pop    edx
         pop    ecx
         pop    ebx
         pop    eax
         pop    edi
         pop    esi
{$ELSE}
         push   ds
         pop    es
         push   ds
         lea    di, CRC32Tab
         lds    si, Buffer
         mov    ax, word ptr InitCRC
         mov    dx, word ptr InitCRC + 2
         mov    cx, Length
         or     cx, cx
         jz     @@done
@@loop:
         xor    bh, bh
         mov    bl, al
         lodsb
         xor    bl, al
         mov    al, ah
         mov    ah, dl
         mov    dl, dh
         xor    dh, dh
         shl    bx, 1
         shl    bx, 1
         xor    ax, es:[di + bx]
         xor    dx, es:[di + bx + 2]
         loop   @@loop
@@done:
         pop    ds
         mov    word ptr Result, ax
         mov    word ptr Result + 2, dx
{$ENDIF}
  end;
end;

function FileCRC16(FileName: string; var CRC16: Word): Boolean; { Return True if ok }
var
  f: file;
  p: Pointer;
  FSize: LongInt;
{$IFNDEF Win32}
  tmp: Word;
{$ENDIF}
begin
{$I+}
  try
    AssignFile(f, FileName);
    Reset(f, 1);
    FSize := FileSize(f);
    if FSize <> 0 then
    begin
{$IFDEF Win32}
      GetMem(p, FSize);
      BlockRead(f, p^, FSize);
      CRC16 := UpdateCrc16(0, p^, FSize); {!}
      FreeMem(p, FSize);
{$ELSE}
      CRC16 := 0; { Usualy from zero }
      while FSize <> 0 do
      begin
        if FSize > $FFFF then tmp := $FFFF else tmp := FSize;
        dec(FSize, tmp);
        GetMem(p, tmp);
        BlockRead(f, p^, tmp);
        CRC16 := UpdateCrc16(Crc16, p^, tmp); {!}
        FreeMem(p, tmp);
      end;
{$ENDIF}

      GetMem(p, 2); { Finish XModem crc with two nulls }
      FillChar(p^, 2, 0);
      Crc16 := UpdateCrc16(Crc16, p^, 2);
      FreeMem(p, 2);

    end;
    Result := True;
  except
    Result := False;
  end;
  try
    CloseFile(f);
  except
  end;
{$I-}
end;

function FileCRCArc(FileName: string; var CRCArc: Word): Boolean; { Return True if ok }
var
  f: file;
  p: Pointer;
  FSize: LongInt;
{$IFNDEF Win32}
  tmp: Word;
{$ENDIF}
begin
{$I+}
  try
    AssignFile(f, FileName);
    Reset(f, 1);
    FSize := FileSize(f);
    if FSize <> 0 then
    begin
{$IFDEF Win32}
      GetMem(p, FSize);
      BlockRead(f, p^, FSize);
      CRCArc := UpdateCrcArc(0, p^, FSize); {!}
      FreeMem(p, FSize);
{$ELSE}
      CRCArc := 0; { Usualy from zero }
      while FSize <> 0 do
      begin
        if FSize > $FFFF then tmp := $FFFF else tmp := FSize;
        dec(FSize, tmp);
        GetMem(p, tmp);
        BlockRead(f, p^, tmp);
        CRCArc := UpdateCrcArc(CrcArc, p^, tmp); {!}
        FreeMem(p, tmp);
      end;
{$ENDIF}
    end;
    Result := True;
  except
    Result := False;
  end;
  try
    CloseFile(f);
  except
  end;
{$I-}
end;

function FileCRC32(FileName: string; var CRC32: LongInt): Boolean; { Return True if ok }
var
  p: Pointer;
  FSize: LongInt;
  fs: TFileStream;
begin
{$I+}
  try
    fs := Tfilestream.Create(FileName, fmOpenRead or fmShareDenyNone);
    FSize := fs.Size;
    if FSize > 2000000 then FSize := 2000000;
    if FSize <> 0 then
    begin
      GetMem(p, FSize);
      fs.ReadBuffer(p^, FSize);
      CRC32 := UpdateCrc32($FFFFFFFF, p^, FSize); {!}
      FreeMem(p, FSize);
      CRC32 := not CRC32; { Finish 32 bit crc by inverting all bits }
    end;
    Result := True;
  except
    CRC32 := 0;
    Result := False;
  end;
  try
    fs.Free;
  except
  end;
{$I-}
end;

end.
