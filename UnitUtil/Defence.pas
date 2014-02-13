unit Defence;

{


}

interface

uses Windows, Messages, SysUtils, Classes;

function MyFileCRC32(FileName: string; var CRC32: LongInt): Boolean; { Return True if ok }


var
  TrueCRC32: longInt;
  FCRC32: longInt;

implementation

uses CRC;

const
  position = $58;

function MyFileCRC32(FileName: string; var CRC32: LongInt): Boolean; { Return True if ok }
var
  p: Pointer;
  FSize: LongInt;
  fs: TFileStream;
begin
{$I+}
  try
    fs := Tfilestream.Create(FileName, fmOpenRead or fmShareDenyNone);
    FSize := fs.Size;
    if FSize <> 0 then
    begin
      GetMem(p, FSize);
      fs.ReadBuffer(p^, fs.Size);
      TrueCRC32 := LongInt(pansichar(p)[position]) shl 8;
      TrueCRC32 := (TrueCRC32 + LongInt(pansichar(p)[position + 1])) shl 8;
      TrueCRC32 := (TrueCRC32 + LongInt(pansichar(p)[position + 2])) shl 8;
      TrueCRC32 := (TrueCRC32 + LongInt(pansichar(p)[position + 3]));

      pansichar(p)[position] := ansichar(CRC32 and $FF);
      pansichar(p)[position + 1] := ansichar((CRC32 shr 8) and $FF);
      pansichar(p)[position + 2] := ansichar((CRC32 shr 16) and $FF);
      pansichar(p)[position + 3] := ansichar((CRC32 shr 24) and $FF);
      CRC32 := UpdateCrc32($FFFFFFFF, p^, FSize); {!}
      FreeMem(p, FSize);
      CRC32 := not CRC32; { Finish 32 bit crc by inverting all bits }
      FCRC32 := CRC32;
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
  FCRC32 := FSize;
{$I-}
end;

end.

 