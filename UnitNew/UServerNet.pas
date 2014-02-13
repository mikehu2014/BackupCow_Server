unit UServerNet;

interface

uses IdUdpServer, IdTcpServer, System.SysUtils, IdSocketHandle, IdGlobal, IdContext, SyncObjs,
     idudpclient, Generics.Collections;

type

    // 事件
  TServerUdpMsgEvent = procedure( Ip, Port, Msg : string )of object;
  TServerTcpMsgEvent = procedure( ClientID : Int64; Msg : string )of object;


    // Udp 处理器
  TServerUdpHandler = class
  private
    UdpPort : Integer;
    UdpServer : TIdUDPServer;
  private
    ServerUdpMsgEvent : TServerUdpMsgEvent;
  public
    constructor Create( _UdpPort : Integer );
    procedure Start;
    procedure Stop;
    destructor Destroy; override;
  private
    procedure RevUdpMsg(AThread: TIdUDPListenerThread; AData: TIdBytes; ABinding: TIdSocketHandle);
  published
    property OnUdpMsg: TServerUdpMsgEvent read ServerUdpMsgEvent write ServerUdpMsgEvent;
  public
    procedure SendMsgTo( Ip, Port, Msg : string );
  end;

    // Indy 上下文 数据
  TContextData = class
  public
    ClientID : Int64;
  public
    constructor Create( _ClientID : Int64 );
  end;

    // 客户端数据
  TClientData = class
  public
    ClientID : Int64;
    AContext: TIdContext;
  public
    constructor Create( _ClientID : Int64; _AContext: TIdContext );
  end;
  TClientDataList = class( TObjectList<TClientData> );

    // Tcp 处理器
  TServerTcpHandler = class
  private
    TcpPort : Integer;
    TcpServer : TIdTCPServer;
  private
    ClientLock : TCriticalSection;
    ClientIDNow : Int64;
    ClientDataList : TClientDataList;
  private
    ServerTcpMsgEvent : TServerTcpMsgEvent;
  public
    constructor Create( _TcpPort : Integer );
    procedure Start;
    procedure Stop;
    destructor Destroy; override;
  private
    procedure PcConnect(AContext: TIdContext);
    procedure PcRevMsg(AContext: TIdContext);
    procedure PcDicConnect(AContext: TIdContext);
  published
    property OnTcpMsg: TServerTcpMsgEvent read ServerTcpMsgEvent write ServerTcpMsgEvent;
  public
    procedure SendMsg( ClientID : Int64; Msg : string );
  end;

implementation

{ TServerUdpHandler }

constructor TServerUdpHandler.Create( _UdpPort : Integer );
begin
  UdpPort := _UdpPort;
  UdpServer := TIdUDPServer.Create(nil);
end;

destructor TServerUdpHandler.Destroy;
begin
  UdpServer.Free;
  inherited;
end;

procedure TServerUdpHandler.RevUdpMsg(AThread: TIdUDPListenerThread;
  AData: TIdBytes; ABinding: TIdSocketHandle);
var
  RevStr : string;
begin
  RevStr := BytesToString( AData );

  if Assigned( ServerUdpMsgEvent ) then
    ServerUdpMsgEvent( ABinding.PeerIP, IntToStr( ABinding.PeerPort ), RevStr );
end;

procedure TServerUdpHandler.SendMsgTo(Ip, Port, Msg: string);
var
  UdpClient : TIdUDPClient;
begin
  UdpClient := TIdUDPClient.Create( nil );
  try
    UdpClient.Host := Ip;
    UdpClient.Port := StrToIntDef( Port, 0 );
    UdpClient.Send( Msg );
  except
  end;
  UdpClient.Free;
end;

procedure TServerUdpHandler.Start;
begin
    // 注意: 端口可能被占用
  UdpServer.Bindings.Clear;
  with UdpServer.Bindings.Add do
  begin
    IP := '0.0.0.0';
    Port := UdpPort;
  end;
  UdpServer.OnUDPRead := RevUdpMsg;
  UdpServer.Active := True;
end;

procedure TServerUdpHandler.Stop;
begin
  UdpServer.Active := False;
end;

{ TServerTcpHandler }

constructor TServerTcpHandler.Create( _TcpPort : Integer );
begin
  TcpPort := _TcpPort;
  TcpServer := TIdTCPServer.Create(nil);

  ClientLock := TCriticalSection.Create;
  ClientDataList := TClientDataList.Create;
end;

destructor TServerTcpHandler.Destroy;
begin
  ClientDataList.Free;
  ClientLock.Free;
  TcpServer.Free;
  inherited;
end;

procedure TServerTcpHandler.PcConnect(AContext: TIdContext);
begin
  ClientLock.Enter;
  AContext.Data := TContextData.Create( ClientIDNow );
  ClientDataList.Add( TClientData.Create( ClientIDNow, AContext ) );
  Inc( ClientIDNow );
  ClientLock.Leave;
end;

procedure TServerTcpHandler.PcDicConnect(AContext: TIdContext);
var
  ConTextData : TContextData;
  ClientID : Int64;
  i: Integer;
begin
  ConTextData := AConText.Data as TContextData;
  ClientID := ConTextData.ClientID;
  ConTextData.Free;

  ClientLock.Enter;
  for i := 0 to ClientDataList.Count - 1 do
    if ClientDataList[i].ClientID = ClientID then
    begin
      ClientDataList.Delete( i );
      Break;
    end;
  ClientLock.Leave;
end;

procedure TServerTcpHandler.PcRevMsg(AContext: TIdContext);
var
  ContextData : TContextData;
  ClientID : Int64;
  RevStr : string;
begin
  ContextData := AContext.Data as TContextData;
  ClientID := ContextData.ClientID;

  RevStr := AContext.Connection.IOHandler.ReadLn;
  if Assigned( ServerTcpMsgEvent ) then
    ServerTcpMsgEvent( ClientID, RevStr );
end;

procedure TServerTcpHandler.SendMsg(ClientID : Int64; Msg: string);
var
  i : Integer;
begin
  ClientLock.Enter;
  for i := 0 to ClientDataList.Count - 1 do
    if ClientDataList[i].ClientID = ClientID then
    begin
      ClientDataList[i].AContext.Connection.IOHandler.WriteLn( Msg );
      Break;
    end;
  ClientLock.Leave;
end;

procedure TServerTcpHandler.Start;
begin
  ClientIDNow := 0;

    // 注意: 端口可能被占用
  TcpServer.Bindings.Clear;
  with TcpServer.Bindings.Add do
  begin
    IP := '0.0.0.0';
    Port := TcpPort;
  end;
  TcpServer.OnConnect := PcConnect;
  TcpServer.OnDisconnect := PcDicConnect;
  TcpServer.OnExecute := PcRevMsg;
  TcpServer.Active := True;
end;

procedure TServerTcpHandler.Stop;
begin
  TcpServer.Active := False;
end;

{ TTcpClientData }

constructor TContextData.Create(_ClientID: Int64);
begin
  ClientID := _ClientID;
end;

{ TClientData }

constructor TClientData.Create(_ClientID: Int64; _AContext: TIdContext);
begin
  ClientID := _ClientID;
  AContext := _AContext;
end;

end.
