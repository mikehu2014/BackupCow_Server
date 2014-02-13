unit UNetworkApi;

interface

uses IdHTTPServer, IdHTTP;

type

  TNetworkHandler = class
  public
    PcID, PcName : string;
    LanIp, LanPort : string;
    SecurityID : string;
  public
    HttpServer : TIdHTTPServer;
    HttpClient : TIdHTTP;
  public
    constructor Create;
    procedure SetPcInfo( _PcID, _PcName : string );
    procedure SetLanSocketInfo( _LanIp, _LanPort : string );
    destructor Destroy; override;
  public
    procedure RunLan( UdpPort : string );
    procedure RunGroup( WebUrl, Account, Password : string );
    procedure RunConnToPc( Ip, Port : string );
  end;

implementation

{ TTcpNetwork }

constructor TNetworkHandler.Create;
begin
  HttpServer := TIdHTTPServer.Create( nil );
  HttpClient := TIdHTTP.Create( nil );
end;

destructor TNetworkHandler.Destroy;
begin
  HttpClient.Free;
  HttpServer.Free;
  inherited;
end;

procedure TNetworkHandler.RunConnToPc(Ip, Port: string);
begin

end;

procedure TNetworkHandler.RunGroup(WebUrl, Account, Password: string);
begin

end;

procedure TNetworkHandler.RunLan(UdpPort: string);
begin

end;

procedure TNetworkHandler.SetLanSocketInfo(_LanIp, _LanPort: string);
begin
  LanIp := _LanIp;
  LanPort := _LanPort;
end;

procedure TNetworkHandler.SetPcInfo(_PcID, _PcName: string);
begin
  PcID := _PcID;
  PcName := _PcName;
end;

end.
