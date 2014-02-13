unit UWinApi;

interface

uses Windows, SysUtils;

type

  MyPcName = class
  public
    class function Read : string;
  end;

implementation

{ MyPcName }

class function MyPcName.Read: string;
var
  cnamebuffer: pchar;
  clen: ^dword;
begin
  try
    getmem(cnamebuffer, 255);
    new(clen);
    clen^ := 255;
    getcomputername(cnamebuffer, clen^);
    Result := strpas(cnamebuffer);
    freemem(cnamebuffer, 255);
    dispose(clen);
  except
  end;
end;

end.
