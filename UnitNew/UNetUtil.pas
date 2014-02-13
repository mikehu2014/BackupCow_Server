unit UNetUtil;

interface

uses classes, SysUtils;

const
  MAX_ADAPTER_NAME_LENGTH        = 256;
  MAX_ADAPTER_DESCRIPTION_LENGTH = 128;
  MAX_ADAPTER_ADDRESS_LENGTH     = 8;

Type
  TIPAddressString = Array[0..4*4-1] of AnsiChar;

  PIPAddrString = ^TIPAddrString;
    TIPAddrString = Record
    Next      : PIPAddrString;
    IPAddress : TIPAddressString;
    IPMask    : TIPAddressString;
    Context   : Integer;
  End;

  PIPAdapterInfo = ^TIPAdapterInfo;
    TIPAdapterInfo = Record { IP_ADAPTER_INFO }
    Next                : PIPAdapterInfo;
    ComboIndex          : Integer;
    AdapterName         : Array[0..MAX_ADAPTER_NAME_LENGTH+3] of ansiChar;
    Description         : Array[0..MAX_ADAPTER_DESCRIPTION_LENGTH+3] of ansiChar;
    AddressLength       : Integer;
    Address             : Array[1..MAX_ADAPTER_ADDRESS_LENGTH] of Byte;
    Index               : Integer;
    _Type               : Integer;
    DHCPEnabled         : Integer;
    CurrentIPAddress    : PIPAddrString;
    IPAddressList       : TIPAddrString;
    GatewayList         : TIPAddrString;
  End;

  MyIpUtil = class
  public
    class function ReadSameLanIp( LanIp : string ): string;
  private
    class function ReadBroadcastIp( IpStr, MaskStr: string ): string;
  end;



implementation

Function GetAdaptersInfo(AI : PIPAdapterInfo; Var BufLen : Integer) : Integer;
StdCall; External 'iphlpapi.dll' Name 'GetAdaptersInfo';

{ MyIpUtil }

class function MyIpUtil.ReadBroadcastIp(IpStr, MaskStr: string): string;
var
  IpList, MaskList : TStringList;
  i : Integer;
  MaskNum, IpNum, BroNum : Byte;
begin
  Result := '';

  IpList := TStringList.Create;
  IpList.Delimiter := '.';
  IpList.DelimitedText := IpStr;

  MaskList := TStringList.Create;
  MaskList.Delimiter := '.';
  MaskList.DelimitedText := MaskStr;
  if ( MaskList.Count = 4 ) and ( IpList.Count = 4 ) then
  begin
    for i := 0 to MaskList.Count - 1 do
    begin
      MaskNum := StrToIntDef( MaskList[i], 0 );
      MaskNum := not MaskNum;
      IpNum := StrToIntDef( IpList[i], 0 );
      BroNum := IpNum or MaskNum;
      if Result <> '' then
        Result := Result + '.';
      Result := Result + IntToStr( BroNum );
    end;
  end;
  MaskList.Free;

  IpList.Free;
end;

class function MyIpUtil.ReadSameLanIp(LanIp: string): string;
var
  AI,Work : PIPAdapterInfo;
  Size    : Integer;
  Res     : Integer;
  IpStr, MaskStr : string;
  BroadcastIp, LanBroadcastIp : string;
begin
  Result := '';

  Size := 5120;
  GetMem(AI,Size);
  try
    work:=ai;
    Res := GetAdaptersInfo(AI,Size);
    If (Res <> 0) Then
    Begin
      SetLastError(Res);
      RaiseLastWin32Error;
      exit;
    End;
    repeat
      IpStr := work.IPAddressList.IPAddress;
      MaskStr := work.IPAddressList.IPMask;
      BroadcastIp := ReadBroadcastIp( IpStr, MaskStr );
      LanBroadcastIp := ReadBroadcastIp( LanIp, MaskStr );
      if BroadcastIp = LanBroadcastIp then // ур╣╫ак
      begin
        Result := IpStr;
        Break;
      end;
      work:=work^.Next ;
    until (work=nil);
  except
  end;
  FreeMem(AI, Size);
end;

end.
