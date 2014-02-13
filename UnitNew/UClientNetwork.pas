unit UClientNetwork;

interface

uses classes, idudpclient;

type

    // 发现 Server 事件
  TUdpServerEvent = procedure( Ip, Port : string ) of object;

    // 客户端 Udp 处理器
  TClientUdpHandler = class
  private
    UdpServerEvent : TUdpServerEvent;
  public
    procedure SearchServer;
  private
    function ReadBroadcastIpList: TStringList;
    procedure SendBroadcast( Ip : string );
  published
    property OnUdpServer : TUdpServerEvent read UdpServerEvent Write UdpServerEvent;
  end;

  TClientNetworkHandler = class
  end;

implementation

uses UNetworkUtil;

{ TClientUdpHandler }

function TClientUdpHandler.ReadBroadcastIpList: TStringList;
begin
  Result := TStringList.Create;
end;

procedure TClientUdpHandler.SearchServer;
begin
  TThread.CreateAnonymousThread(
  procedure
  var
    i : Integer;
    IpList : TStringList;
  begin
    IpList := ReadBroadcastIpList;
    for i := 0 to IpList.Count - 1 do
      SendBroadcast( IpList[i] );
    IpList.Free;
  end).Start;
end;

procedure TClientUdpHandler.SendBroadcast(Ip: string);
var
  UdpClient : TIdUDPClient;
begin
  UdpClient := TIdUDPClient.Create( nil );
  UdpClient.Host := Ip;
  UdpClient.Port := ServerPort_Udp;
//  UdpClient.Send();
  UdpClient.Free;
end;

end.
