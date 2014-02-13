unit UPortMap;

interface

uses SysUtils, idhttp, classes, idudpclient, Forms;

type

    // 端口映射
  TPortMapping = class
  private
    IdUdpClient : TIdUDPClient;
  private
    location, server, usn: string;
    st : string;
    routerip: string;
    routerport: integer;
  public
    controlurl: string;
    HasDivice, IsPortMapable : Boolean;  // 是否可以进行端口映射
  public
    constructor Create;
    destructor Destroy; override;
  public   // UPNP 端口映射
    function AddMapping( LocalIp, InternetPort : string ): Boolean;
    procedure RemoveMapping( InternetPort : string );
    function getInternetIp : string;
  private   // UPNP 设备查找
    function FindDivice: Boolean;
    function FindControl: Boolean;
  private  // 信息提取
    function FindDeviceInfo(ResponseStr : string):Boolean;
    function FindControlURL(ResponseStr: string): Boolean;
  end;

  MyLog = class
  public
    class procedure Log( s : string );
    class procedure Logln( s : string );
  end;

implementation

uses UDebugForm, UChangeInfo;

{ TPortMapping }

function TPortMapping.AddMapping( LocalIp, InternetPort : string ): Boolean;
var
  LocalPort : string;
  Protocol : string;
  InternalPort, ExternalPort: Integer;
  InternalClient, RemoteHost: string;
  PortMappingDeion: string;
  LeaseDuration: integer;
  cmd, body{, request} : string;
  IdHttp : TIdHTTP;
  HttpParams : TStringList;
  a: TMemoryStream;
  ResponseStr: string;
begin
  Result := False;

    // 不能进行端口映射
  if not IsPortMapable then
    Exit;

  LocalPort := InternetPort;
  Protocol := 'TCP';
  InternalClient := LocalIp;
  RemoteHost := '';
  InternalPort := StrToIntdef( LocalPort, -1 );
  ExternalPort := StrToIntdef( InternetPort, -1 );
  PortMappingDeion := 'BackupCow_Server';
  LeaseDuration := 0;

    // Port 格式不正确
  if ( InternalPort = -1 ) or ( ExternalPort = -1 ) then
    Exit;

  cmd := 'AddPortMapping';

  body := '<?xml version="1.0"?>'#13#10
    + '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"'#13#10
    + 's:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'#13#10
    + '<s:Body>'#13#10
    + '<u:' + cmd + ' xmlns:u="urn:schemas-upnp-org:service:WANIPConnection:1">'#13#10
    + '<NewRemoteHost>' + RemoteHost + '</NewRemoteHost>'#13#10
    + '<NewExternalPort>' + inttostr(ExternalPort) + '</NewExternalPort>'#13#10
    + '<NewProtocol>' + Protocol + '</NewProtocol>'#13#10
    + '<NewInternalPort>' + inttostr(InternalPort) + '</NewInternalPort>'#13#10
    + '<NewInternalClient>' + InternalClient + '</NewInternalClient>'#13#10
    + '<NewEnabled>1</NewEnabled>'#13#10
    + '<NewPortMappingDescription>' + PortMappingDeion + '</NewPortMappingDescription>'#13#10
    + '<NewLeaseDuration>' + inttostr(LeaseDuration) + '</NewLeaseDuration>'#13#10
    + '</u:' + cmd + '>'#13#10
    + '</s:Body>'#13#10
    + '</s:Envelope>'#13#10;

  IdHttp := TIdHTTP.Create(nil);
  IdHttp.AllowCookies := True;
  IdHttp.ConnectTimeout := 2000;
  IdHttp.ReadTimeout := 2000;
  IdHTTP.Request.CustomHeaders.Text := 'SoapAction: "urn:schemas-upnp-org:service:WANIPConnection:1#' + cmd + '"';
  IdHTTP.Request.ContentType := 'text/xml; charset="utf-8"';

  HttpParams := TStringList.Create;
  HttpParams.Text := body;
  try
    a := TMemoryStream.Create;
    HttpParams.SaveToStream( a );
    a.Position := 0;
    ResponseStr := IdHTTP.Post( controlurl , a);
    Result := True;
  except
  end;
  a.Free;
  HttpParams.Free;

  IdHttp.Free;
end;

procedure TPortMapping.RemoveMapping( InternetPort : string );
var
  Protocol: string;
  ExternalPort: Integer;
  cmd, body, request : string;
  IdHttp : TIdHTTP;
  a: TMemoryStream;
  HttpParams : TStringList;
  res: string;
begin
    // 不能进行端口映射
  if not IsPortMapable then
    Exit;

  Protocol := 'TCP';
  ExternalPort := StrToInt( InternetPort );

  cmd := 'DeletePortMapping';

  body := '<?xml version="1.0"?>'#13#10
    + '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'#13#10
    + '<s:Body>'#13#10
    + '<u:' + cmd + ' xmlns:u="urn:schemas-upnp-org:service:WANIPConnection:1">'#13#10
    + '<NewRemoteHost></NewRemoteHost>'#13#10
    + '<NewExternalPort>' + inttostr(ExternalPort) + '</NewExternalPort>'#13#10
    + '<NewProtocol>TCP</NewProtocol>'#13#10
    + '</u:' + cmd + '>'#13#10
    + '</s:Body>'#13#10
    + '</s:Envelope>'#13#10;
  request := 'POST ' + controlurl + ' HTTP/1.0'#13#10
    + 'Host: ' + routerip + ':' + inttostr(routerport) + #13#10
    + 'SoapAction: "urn:schemas-upnp-org:service:WANIPConnection:1#' + cmd + '"'#13#10
    + 'Content-Type: text/xml; charset="utf-8"'#13#10
    + 'Content-Length: ' + inttostr(length(body)) + #13#10#13#10 + body;

  IdHttp := TIdHTTP.Create(nil);
  IdHttp.AllowCookies := True;
  IdHttp.ConnectTimeout := 2000;
  IdHttp.ReadTimeout := 2000;
  IdHTTP.Request.CustomHeaders.Text := 'SoapAction: "urn:schemas-upnp-org:service:WANIPConnection:1#' + cmd + '"';
  IdHTTP.Request.ContentType := 'text/xml; charset="utf-8"';

  HttpParams := TStringList.Create;
  HttpParams.Text := body;

  try
    a := TMemoryStream.Create;
    HttpParams.SaveToStream( a );
    a.Position := 0;

    res := IdHTTP.Post( controlurl, a);
  except
    on e: Exception do begin
    end;
  end;
  a.Free;
  HttpParams.Free;

  IdHttp.Free;
end;

constructor TPortMapping.Create;
var
  i : Integer;
begin
  IdUdpClient := TIdUDPClient.Create(nil);
  IdUdpClient.BroadcastEnabled := True;
  IdUdpClient.Host := '239.255.255.250';
  IdUdpClient.port := 1900;

  IsPortMapable := False;
  HasDivice := False;

    // 尝试 10 次端口映射
  for i := 1 to 10 do
  begin
      // 端口映射成功, 跳出
    if FindDivice and FindControl then
    begin
      IsPortMapable := True;
      Break;
    end;
      // 映射不成功, 且不存在映射设备, 跳出
    if not HasDivice then
      Break;

    Application.ProcessMessages;
    Sleep(50);
  end;
end;

function TPortMapping.FindControl: Boolean;
var
  IdHttp : TIdHTTP;
  ResponseStr: string;
begin
  IdHttp := TIdHTTP.Create(nil);
  IdHttp.AllowCookies := True;
  IdHttp.ConnectTimeout := 2000;
  IdHttp.ReadTimeout := 2000;

  try
    ResponseStr := IdHttp.Get(location);

    Result := FindControlURL(ResponseStr);
  except
    Result := False;
  end;

  IdHttp.Free;
end;

function TPortMapping.FindControlURL(ResponseStr: string): Boolean;
var
  tmpstr, tmp: string;
  j: integer;
  FulllAdress : string;
begin
  result := False;
  tmpstr := ResponseStr;


   // 查找设备urn:schemas-upnp-org:device:InternetGatewayDevice:1的描述段...

  j := pos(uppercase('<deviceType>urn:schemas-upnp-org:device:InternetGatewayDevice:1</deviceType>'), uppercase(tmpstr));
  if j <= 0 then
    exit;
  delete(tmpstr, 1, j + length('<deviceType>urn:schemas-upnp-org:device:InternetGatewayDevice:1</deviceType>') - 1);


   // 再查找urn:schemas-upnp-org:device:WANDevice:1的描述段...

  j := pos(uppercase('<deviceType>urn:schemas-upnp-org:device:WANDevice:1</deviceType>'), uppercase(tmpstr));
  if j <= 0 then
    exit;
  delete(tmpstr, 1, j + length('<deviceType>urn:schemas-upnp-org:device:WANDevice:1</deviceType>') - 1);


   // 再查找urn:schemas-upnp-org:device:WANConnectionDevice:1的描述段...

  j := pos(uppercase('<deviceType>urn:schemas-upnp-org:device:WANConnectionDevice:1</deviceType>'), uppercase(tmpstr));
  if j <= 0 then
    exit;
  delete(tmpstr, 1, j + length('<deviceType>urn:schemas-upnp-org:device:WANConnectionDevice:1</deviceType>') - 1);


   // 最后找到服务urn:schemas-upnp-org:service:WANIPConnection:1的描述段...

  j := pos(uppercase('<serviceType>urn:schemas-upnp-org:service:WANIPConnection:1</serviceType>'), uppercase(tmpstr));
  if j <= 0 then exit;
  delete(tmpstr, 1, j + length('<serviceType>urn:schemas-upnp-org:service:WANIPConnection:1</serviceType>') - 1);


   // 得到ControlURL...

  j := pos(uppercase('<controlURL>'), uppercase(tmpstr));
  if j <= 0 then exit;
  delete(tmpstr, 1, j + length('<controlURL>') - 1);
  j := pos(uppercase('</controlURL>'), uppercase(tmpstr));
  if j <= 0 then exit;

  controlurl := copy(tmpstr, 1, j - 1);

  FulllAdress := 'http://' + routerip + ':' + inttostr(routerport);
  if Pos( FulllAdress, controlurl ) <= 0 then
    controlurl := FulllAdress + controlurl;

  Result := True;
end;


function TPortMapping.FindDivice: Boolean;
var
  RequestStr: string;
  ResponseStr:string;
begin
  RequestStr := 'M-SEARCH * HTTP/1.1'#13#10
    + 'HOST: 239.255.255.250:1900'#13#10
    + 'MAN: "ssdp:discover"'#13#10
    + 'MX: 3'#13#10
    + 'ST: upnp:rootdevice'#13#10#13#10;

  try
    IdUdpClient.Send(RequestStr);
    ResponseStr := IdUdpClient.ReceiveString(2000);
    HasDivice := Trim(ResponseStr) <> '';

    Result := FindDeviceInfo( ResponseStr );
  except
    Result := False;
  end;
end;

function TPortMapping.getInternetIp: string;
var
  cmd, body, request : string;
  IdHttp : TIdHTTP;
  HttpParams : TStringList;
  a: TMemoryStream;
  ResponeStr : string;
  PosIp : Integer;
begin
  Result := '';

      // 不能进行端口映射
  if not IsPortMapable then
    Exit;

  cmd := 'GetExternalIPAddress';

  body := '<?xml version="1.0"?>'#13#10
    + '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'#13#10
    + '<s:Body>'#13#10
    + '<u:' + cmd + ' xmlns:u="urn:schemas-upnp-org:service:WANIPConnection:1">'#13#10
    + '</u:' + cmd + '>'#13#10
    + '</s:Body>'#13#10
    + '</s:Envelope>'#13#10;

  request := 'POST ' + controlurl + ' HTTP/1.0'#13#10
    + 'Host: ' + routerip + ':' + inttostr(routerport) + #13#10
    + 'SoapAction: "urn:schemas-upnp-org:service:WANIPConnection:1#' + cmd + '"'#13#10
    + 'Content-Type: text/xml; charset="utf-8"'#13#10
    + 'Content-Length: ' + inttostr(length(body)) + #13#10#13#10 + body;

  IdHttp := TIdHTTP.Create(nil);
  IdHttp.AllowCookies := True;
  IdHttp.ConnectTimeout := 2000;
  IdHttp.ReadTimeout := 2000;
  IdHTTP.Request.CustomHeaders.Text := 'SoapAction: "urn:schemas-upnp-org:service:WANIPConnection:1#' + cmd + '"';
  IdHTTP.Request.ContentType := 'text/xml; charset="utf-8"';

  HttpParams := TStringList.Create;
  HttpParams.Text := body;

  try
    a := TMemoryStream.Create;
    HttpParams.SaveToStream( a );
    a.Position := 0;
    ResponeStr := IdHTTP.Post( controlurl , a);
  except
    on e: Exception do begin
    end;
  end;
  a.Free;
  HttpParams.Free;

  IdHttp.Free;

    // 从返回信息中提取 Ip
  PosIp := Pos( '<NEWEXTERNALIPADDRESS>', UpperCase( ResponeStr ) );
  if PosIp > 0 then
  begin
    delete( ResponeStr, 1, PosIp + 21 );
    PosIp := pos( '</', ResponeStr );
    ResponeStr := trim( copy( ResponeStr, 1, PosIp - 1 ) );
  end;
  Result := ResponeStr;
end;

function TPortMapping.FindDeviceInfo(ResponseStr: string):Boolean;
var
  tmpstr: string;
  buffer: array[0..4096] of char;
  j: integer;
begin
  Result := False;

  tmpstr := ResponseStr;

    // 收到的信息不是设备搜寻结果，忽略！
  if uppercase(copy(tmpstr, 1, 5)) <> 'HTTP/' then
    exit;

    // 找出 ST
  st := tmpstr;
  j := Pos( 'ST:', UpperCase( st ) );
  if j < 0 then
    Exit
  else
  begin
    delete(ST, 1, j + 2);
    j := pos(#13#10, ST);
    ST := trim(copy(ST, 1, j - 1));
    if LowerCase(ST) <> 'upnp:rootdevice' then
      Exit;
  end;

  // 找出 Location
  location := tmpstr;
  j := pos('LOCATION:', uppercase(location));
  if j < 0 then
    Exit
  else
  begin
    delete(location, 1, j + 8);
    j := pos(#13#10, location);
    location := trim(copy(location, 1, j - 1));
  end;

   // 找出 Server
  server := tmpstr;
  j := pos('SERVER:', uppercase(server));
  if j < 0 then
    Exit
  else
  begin
    delete(server, 1, j + 6);
    j := pos(#13#10, server);
    server := trim(copy(server, 1, j - 1));
  end;

   // 找出 USN
  usn := tmpstr;
  j := pos('USN:', uppercase(usn));
  if j < 0 then
    Exit
  else
  begin
    delete(usn, 1, j + 3);
    j := pos(#13#10, usn);
    usn := trim(copy(usn, 1, j - 1));
  end;


    // 找出 Ip
  tmpstr := location;
  if copy(uppercase(tmpstr), 1, 7) = 'HTTP://' then
    delete(tmpstr, 1, 7);
  j := pos(':', tmpstr);
  if j <= 0 then
    exit;
  routerip := copy(tmpstr, 1, j - 1);
  delete(tmpstr, 1, j);

   // 找出 Port
  j := pos('/', tmpstr);
  if j > 1 then
  begin
    routerport := StrToIntDef(copy(tmpstr, 1, j - 1), -1);
    delete(tmpstr, 1, j - 1);
  end
  else
  begin
    j := pos(#13#10, tmpstr);
    if j <= 1 then
      exit;
    routerport := strtointdef(copy(tmpstr, 1, j - 1), -1);
  end;

    // 出错的情况
  if ( location = '' )  or ( server = '' ) or ( usn = '' ) or
     ( routerip = '' ) or ( routerport < 0 )
  then
    Exit;

  Result := True;
end;



destructor TPortMapping.Destroy;
begin
  IdUdpClient.Free;
  inherited;
end;



{ MyLog }

class procedure MyLog.Log(s: string);
var
  WriteLog : TWriteLog;
begin
//  WriteLog := TWriteLog.Create( s );
//  MyFaceChange.AddChange( WriteLog );
end;

class procedure MyLog.Logln(s: string);
begin
  Log( s );
  Log( '' );
end;

end.
