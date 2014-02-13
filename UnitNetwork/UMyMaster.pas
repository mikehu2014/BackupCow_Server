unit UMyMaster;

interface

uses UChangeInfo, UMyUtil, UMyNetPcInfo, UMyTcp, Sockets, SysUtils, uDebug,
     Generics.Collections, classes, SyncObjs, UMyDebug, DateUtils, uDebugLock, IdUDPServer,
     IdSocketHandle, IdGlobal, IdUdpClient;

type

{$Region ' 信息 数据结构 ' }

    // 局域网 广播
  TLanBroadcastMsg = class( TMsgBase )
  private
    iPcID : string;
    iPcName : string;
    iIp, iPort : string;
    iCloudIDNumMD5 : string;
  private
    iBroadcastType : string;
  published
    property PcID : string Read iPcID Write iPcID;
    property PcName : string Read iPcName Write iPcName;
    property LanIp : string Read iIp Write iIp;
    property LanPort : string Read iPort Write iPort;
    property CloudIDNumMD5 : string Read iCloudIDNumMD5 Write iCloudIDNumMD5;
    property BroadcastType : string Read iBroadcastType Write iBroadcastType;
  public
    procedure SetPcID( _PcID : string );
    procedure SetPcName( _PcName : string );
    procedure SetSocketInfo( _LanIp, _LanPort : string );
    procedure SetCloudIDNumMD5( _CloudIDNumMD5 : string );
    procedure SetBroadcastType( _BroadcastType : string );
  end;

    // 移动广播返回
  TMobileBroadcastReturnMsg = class( TMsgBase )
  private
    iIp, iPort : string;
  public
    procedure SetSocketInfo( _Ip, _Port : string );
  published
    property Ip : string Read iIp Write iIp;
    property Port : string Read iPort Write iPort;
  end;

  TPingMsg = class( TMsgBase )
  private
    iPcID, iPcName : string;
    iIp, iPort : string;
    iIsLanConn : Boolean;
    iClientCount : Integer;
    iStartTime : TDateTime;
    iRanNum : Integer;
  public
    procedure SetPcInfo( _PcID, _PcName : string );
    procedure SetSocketInfo( _Ip, _Port : string; _IsLanConn : Boolean );
    procedure SetClientCount( _ClientCount : Integer );
    procedure SetMasterInfo( _StartTime : TDateTime; _RanNum : Integer );
  published
    property PcID : string Read iPcID Write iPcID;
    property PcName : string Read iPcName Write iPcName;
    property Ip : string Read iIp Write iIp;
    property Port : string Read iPort Write iPort;
    property IsLanConn : Boolean Read iIsLanConn Write iIsLanConn;
    property ClientCount : Integer Read iClientCount Write iClientCount;
    property StartTime : TDateTime Read iStartTime Write iStartTime;
    property RanNum : Integer Read iRanNum Write iRanNum;
  end;

  TPingMsg2 = class( TMsgBase )
  private
    iClientCount : Integer;
    iStartTime : TDateTime;
    iRanNum : Integer;
  public
    procedure SetClientCount( _ClientCount : Integer );
    procedure SetMasterInfo( _StartTime : TDateTime; _RanNum : Integer );
  published
    property ClientCount : Integer Read iClientCount Write iClientCount;
    property StartTime : TDateTime Read iStartTime Write iStartTime;
    property RanNum : Integer Read iRanNum Write iRanNum;
  end;

{$EndRegion}


{$Region ' 发送 数据结构 ' }

    // 父类
  TMasterSendInfo = class
  end;
  TMasterSendList = class( TObjectList<TMasterSendInfo> )end;

    // 成为服务器，连接客户端
  TMasterConnClientInfo = class( TMasterSendInfo )
  public
    ClientPcID : string;
  public
    constructor Create( _ClientPcID : string );
  end;

    // 发送连接信息 父类
  TMasterSendConnInfo = class( TMasterSendInfo )
  public
    PcID : string;
    Ip, Port : string;
    SendTime : TDateTime;
  public
    constructor Create( _PcID : string );
    procedure SetSocketInfo( _Ip, _Port : string );
    procedure SetSendTime( _SendTime : TDateTime );
  end;

    // 发送 Lan Ping
  TMasterSendLanPingInfo = class( TMasterSendConnInfo )
  end;

    // 发送 Internet 信息
  TMasterSendInternerInfo = class( TMasterSendConnInfo )
  public
    InternetIp, InternetPort : string;
  public
    procedure SetInternetSocket( _InternetIp, _InternetPort : string );
  end;

    // 发送 Internet Ping
  TMasterSendInternetPingInfo = class( TMasterSendInternerInfo )
  end;

    // 发送 上线确认
  TMasterSendConfirmConnectInfo = class( TMasterSendInternerInfo )
  end;

{$EndRegion}

{$Region ' 发送 命令处理 ' }

    // 连接发送 父类
  TSendMsgBaseHandle = class
  public
    TcpSocket : TCustomIpClient;
  public
    constructor Create( _TcpSocket : TCustomIpClient );
  end;

    // Ping 命令
  TSendPingMsgHandle = class( TSendMsgBaseHandle )
  public
    PcID : string;
    IsLanConn : Boolean;
  public
    procedure SetPcID( _PcID : string );
    procedure SetIsLanConn( _IsLanConn : Boolean );
    function Update: Boolean;  // 端口用作CS则返回 True
  private
    procedure SendMyPcInfo;   // 发送本机信息
    procedure RevRemotePcInfo;  // 接收远程信息
    function ConnectToCS: Boolean; // 是否立刻进行CS连接
  end;

    // 确认连接命令
  TSendConfirmConnectMsgHandle = class( TSendMsgBaseHandle )
  public
    PcID : string;
    IsLanConn : Boolean;
  public
    procedure SetPcID( _PcID : string );
    procedure SetIsLanConn( _IsLanConn : Boolean );
    procedure Update;
  private
    procedure SendMySocketInfo;
  end;

{$EndRegion}

{$Region ' 发送 处理线程 ' }

    // 处理连接
  TMasterSendHandle = class
  public
    MasterSendInfo : TMasterSendConnInfo;
    PcID : string;
  public
    Ip, Port : string;
    IsLanConn : Boolean;
    TcpSocket : TCustomIpClient;
    IsDestorySocket : Boolean;
  public
    constructor Create( _MasterSendInfo : TMasterSendConnInfo );
    function Update: Boolean;
    destructor Destroy; override;
  private      // 连接
    function ConnToSocket : Boolean;
    function ConnToInternetSocket : Boolean;
    function ConnToPc( ConnIp, ConnPort : string ): Boolean;
  private      // 记录连接信息
    procedure MarkNotConnected;
  private      // 处理命令信息
    procedure HandleSend;
    procedure HandlePing;
    procedure HandleConfirmConect;
  end;

    // 发送线程
  TMasterSendThread = class( TDebugThread )
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure HandleConnClient( MasterConnClientInfo : TMasterConnClientInfo );
    function HandleSend( MasterSendConnInfo : TMasterSendConnInfo ): Boolean;
  end;
  TMasterSendThreadList = class( TObjectList<TMasterSendThread> )end;

{$EndRegion}

    // 底层命令发送
  TMyMasterSendHandler = class
  public
    IsRun : Boolean;
  public
    DataLock : TCriticalSection;
    MasterSendList : TMasterSendList;
  public
    ThreadLock : TCriticalSection;
    MasterSendThreadList : TMasterSendThreadList;
  public
    constructor Create;
    procedure StopRun;
    destructor Destroy; override;
  public
    function getIsRuning : Boolean; // 是否在发送命令
  public
    procedure AddMasterSend( MasterSendInfo : TMasterSendInfo );
    procedure AddMasterBusySend( MasterSendInfo : TMasterSendConnInfo );
    function getMasterSendInfo : TMasterSendInfo;
    procedure RemoveThread( ThreadID : Cardinal );
  end;

{$Region ' 接收 命令处理 ' }

    // 处理广播命令
  TRevBroadcastMsgHandle = class
  private
    BroadcastStr : string;
    BroadcastIp, BroadcastPort : string;
  private
    LanPcMsgStr : string;
    PcID, PcName : string;
    LanIp, LanPort : string;
    CloudIDNumMD5 : string;
    BroadcastType : string;
  public
    constructor Create( _BroadcastStr : string );
    procedure SetSocketInfo( _BroadcastIp, _BroadcastPort : string );
    procedure Update;
  private
    function CheckBroadcastMsg : Boolean;
    procedure FindBroadcastMsg;
    procedure SendLanPing;
    procedure LanSearchHandle;
    procedure SendMobileReturn;
  private       // 程序版本不兼容
    procedure EditionErrorHandle( IsNewEdition : Boolean );
  end;

    // 接收命令 父类
  TReceiveMsgBaseHandle = class
  public
    TcpSocket : TCustomIpClient;
  public
    constructor Create( _TcpSocket : TCustomIpClient );
  end;

    // 接收 Ping 命令
  TReceivePingMsgHandle = class( TReceiveMsgBaseHandle )
  private
    PcID : string;
  public
    function Update: Boolean;
  private
    procedure RevRemotePcInfo;  // 接收远程信息
    procedure SendMyPcInfo;   // 发送本机信息
    function ConnectToCS: Boolean; // 连接客户端
  end;

    // 确认连接 命令
  TReceiveConfirmConnectMsgHandle = class( TReceiveMsgBaseHandle )
  public
    procedure Update;
  private
    procedure RevRemoteSocketInfo;
  end;

    // Advance 连接
  TReceiveAdvanceMsgHandle = class( TReceiveMsgBaseHandle )
  public
    function Update: Boolean;
  private
    function ConfirmSecurityID : Boolean;
    function getIsConnectServer : Boolean;
    function ConfirmAccount : Boolean;
    procedure RevRemotePcInfo;
    procedure SendServerInfo;
    function getIsConnectToCS: Boolean;
  end;

{$EndRegion}

{$Region ' 接收 处理线程 ' }

    // 处理接收命令线程
  TMasterReceiveThread = class( TDebugThread )
  private
    TcpSocket : TCustomIpClient;
    IsDestorySocket : Boolean;
  public
    constructor Create;
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
  protected
    procedure Execute; override;
  private
    procedure HandleReceive;
    procedure HandlePing;
    procedure HandleConfirmConnect;
    procedure HandleAdvanceConn;
  end;
  TMasterReceiveThreadList = class( TObjectList< TMasterReceiveThread > )end;

    // 处理广播命令 线程
  TMasterReceiveBroadcastThread = class( TDebugThread )
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  public
    procedure HandleMsg( MsgStr, Ip, Port : string );
  end;

{$EndRegion}

    // 广播信息
  TBroadcastInfo = class
  public
    Ip, Port : string;
    MsgStr : string;
  public
    constructor Create( _Ip, _Port : string );
    procedure SetMsgStr( _MsgStr : string );
  end;
  TBroadcastList = class( TObjectList<TBroadcastInfo> )end;

    // 信息接收处理器
  TMyMasterReceiveHandler = class
  public
    IsRun : Boolean;
  private
    ThreadLock : TCriticalSection;
    MasterReceiveThreadList : TMasterReceiveThreadList;
  private
    MsgLock : TCriticalSection;
    BroadcastList : TBroadcastList;
    IsCreateThread : Boolean;
    MasterReceiveBroadcastThread : TMasterReceiveBroadcastThread;
  public
    constructor Create;
    procedure StopRun;
    destructor Destroy; override;
  public
    function getIsRuning : Boolean; // 是否在接收命令
  public
    procedure udpServerUDPRead(AThread: TIdUDPListenerThread; AData: TArray<System.Byte>; ABinding: TIdSocketHandle);
    procedure ReceiveBroadcast( BroadcastMsg, Ip, Port : string );
    function getBroadcast : TBroadcastInfo;
  public
    procedure ReceiveConn( TcpSocket : TCustomIpClient );
    procedure RemoveThread( ThreadID : Cardinal );
  end;

const
  ThreadCount_MasterMsg = 5;

  MasterConn_Ping = 'Ping';
  MasterConn_BeMaster = 'BeMaster';
  MasterConn_CheckReach = 'CheckReach';
  MasterConn_Advance = 'Advance';

var
  MyMasterSendHandler : TMyMasterSendHandler;
  MyMasterReceiveHanlder : TMyMasterReceiveHandler;

implementation

uses  UNetworkFace, UNetPcInfoXml, USettingInfo, USearchServer, UMyClient,
     UNetworkControl, UMyServer, UMyRegisterDataInfo;

{ TLanBroadcastMsg }

procedure TLanBroadcastMsg.SetBroadcastType(_BroadcastType: string);
begin
  BroadcastType := _BroadcastType;
end;

procedure TLanBroadcastMsg.SetCloudIDNumMD5(_CloudIDNumMD5: string);
begin
  CloudIDNumMD5 := _CloudIDNumMD5;
end;

procedure TLanBroadcastMsg.SetPcID(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TLanBroadcastMsg.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TLanBroadcastMsg.SetSocketInfo(_LanIp, _LanPort: string);
begin
  LanIp := _LanIp;
  LanPort := _LanPort;
end;

{ TMasterConnClientInfo }

constructor TMasterConnClientInfo.Create(_ClientPcID: string);
begin
  ClientPcID := _ClientPcID;
end;

{ TMasterSendInfo }

constructor TMasterSendConnInfo.Create(_PcID: string);
begin
  PcID := _PcID;
  SendTime := Now;
end;

procedure TMasterSendConnInfo.SetSendTime(_SendTime: TDateTime);
begin
  SendTime := _SendTime;
end;

procedure TMasterSendConnInfo.SetSocketInfo(_Ip, _Port: string);
begin
  Ip := _Ip;
  Port := _Port;
end;

{ TMasterSendInternerInfo }

procedure TMasterSendInternerInfo.SetInternetSocket(_InternetIp,
  _InternetPort: string);
begin
  InternetIp := _InternetIp;
  InternetPort := _InternetPort;
end;

{ TMasterSendHandleThread }

constructor TMasterSendThread.Create;
begin
  inherited Create;
end;

destructor TMasterSendThread.Destroy;
begin
  inherited;
end;

procedure TMasterSendThread.Execute;
var
  MasterSendInfo : TMasterSendInfo;
  MasterSendConnInfo : TMasterSendConnInfo;
begin
  FreeOnTerminate := True;

  while not Terminated and MyMasterSendHandler.IsRun do
  begin
    MasterSendInfo := MyMasterSendHandler.getMasterSendInfo;
    if MasterSendInfo = nil then
      Break;

    try
          // 连接客户端信息
      if MasterSendInfo is TMasterConnClientInfo then
        HandleConnClient( MasterSendInfo as TMasterConnClientInfo )
      else  // 连接发送信息
      if MasterSendInfo is TMasterSendConnInfo then
      begin
        MasterSendConnInfo := MasterSendInfo as TMasterSendConnInfo;
        if not HandleSend( MasterSendConnInfo ) then // 未处理完成
          Continue;
      end;
    except
      on  E: Exception do
        MyWebDebug.AddItem( 'Master Send Msg', e.Message );
    end;

    MasterSendInfo.Free;
  end;

    // 从记录中删除
  MyMasterSendHandler.RemoveThread( Self.ThreadID );

  Terminate;
end;

procedure TMasterSendThread.HandleConnClient(
  MasterConnClientInfo: TMasterConnClientInfo);
var
  ClientPcID : string;
  TcpSocket : TCustomIpClient;
  ClientIp, ClientPort : string;
  MyTcpConn : TMyTcpConn;
  IsSuccessConn : Boolean;
begin
  DebugLock.Debug( 'ConnectClientHandle: ' + MasterConnClientInfo.ClientPcID);

  TcpSocket := TCustomIpClient.Create( nil );

  ClientPcID := MasterConnClientInfo.ClientPcID;
  ClientIp := MyNetPcInfoReadUtil.ReadIp( ClientPcID );
  ClientPort := MyNetPcInfoReadUtil.ReadPort( ClientPcID );

    // 连接对方
  MyTcpConn := TMyTcpConn.Create( TcpSocket );
  MyTcpConn.SetConnSocket( ClientIp, ClientPort );
  MyTcpConn.SetConnType( ConnType_Client );
  IsSuccessConn := MyTcpConn.Conn and MyServer.ConnectClient( TcpSocket );
  MyTcpConn.Free;

    // 未连接
  if not IsSuccessConn then
    TcpSocket.Free;
end;


function TMasterSendThread.HandleSend(MasterSendConnInfo: TMasterSendConnInfo): Boolean;
var
  MasterSendHandle : TMasterSendHandle;
begin
  DebugLock.Debug( 'HandleSend: ' + MasterSendConnInfo.ClassName );

  Result := False;

    // 繁忙的发送命令
  if MasterSendConnInfo.SendTime > Now then
  begin
    Sleep(100);
    MyMasterSendHandler.AddMasterSend( MasterSendConnInfo );
    Exit;
  end;

    // 处理发送
  MasterSendHandle := TMasterSendHandle.Create( MasterSendConnInfo );
  Result := MasterSendHandle.Update;
  MasterSendHandle.Free;

    // 接收方繁忙
  if not Result then
    MyMasterSendHandler.AddMasterBusySend( MasterSendConnInfo );
end;

{ TMyMasterSendHandler }

procedure TMyMasterSendHandler.AddMasterBusySend(
  MasterSendInfo: TMasterSendConnInfo);
begin
  if not IsRun then
    Exit;

    // 1 秒后再连接
  MasterSendInfo.SetSendTime( IncSecond( Now, 1 ) );

    // 添加到列表中
  AddMasterSend( MasterSendInfo );
end;

procedure TMyMasterSendHandler.AddMasterSend(MasterSendInfo: TMasterSendInfo);
var
  RunThread : TMasterSendThread;
begin
  if not IsRun then
    Exit;

  DataLock.Enter;
  MasterSendList.Add( MasterSendInfo );
  DataLock.Leave;

  ThreadLock.Enter;
  if MasterSendThreadList.Count < ThreadCount_MasterMsg then
  begin
    RunThread := TMasterSendThread.Create;
    MasterSendThreadList.Add( RunThread );
    RunThread.Resume;
  end;
  ThreadLock.Leave;
end;

constructor TMyMasterSendHandler.Create;
begin
  DataLock := TCriticalSection.Create;
  MasterSendList := TMasterSendList.Create;
  MasterSendList.OwnsObjects := False;

  ThreadLock := TCriticalSection.Create;
  MasterSendThreadList := TMasterSendThreadList.Create;
  MasterSendThreadList.OwnsObjects := False;
  IsRun := True;
end;

destructor TMyMasterSendHandler.Destroy;
begin
  MasterSendThreadList.Free;
  ThreadLock.Free;

  MasterSendList.OwnsObjects := True;
  MasterSendList.Free;
  DataLock.Free;
  inherited;
end;

function TMyMasterSendHandler.getIsRuning: Boolean;
begin
  Result := False;
  if not IsRun then
    Exit;

  ThreadLock.Enter;
  Result := MasterSendThreadList.Count > 0;
  ThreadLock.Leave;
end;

function TMyMasterSendHandler.getMasterSendInfo: TMasterSendInfo;
begin
  DataLock.Enter;
  if MasterSendList.Count > 0 then
  begin
    Result := MasterSendList[0];
    MasterSendList.Delete( 0 );
  end
  else
    Result := nil;
  DataLock.Leave;
end;

procedure TMyMasterSendHandler.RemoveThread(ThreadID: Cardinal);
var
  i : Integer;
begin
  ThreadLock.Enter;
  for i := 0 to MasterSendThreadList.Count - 1 do
    if MasterSendThreadList[i].ThreadID = ThreadID then
    begin
      MasterSendThreadList.Delete( i );
      Break;
    end;
  ThreadLock.Leave;
end;

procedure TMyMasterSendHandler.StopRun;
var
  IsExistThread : Boolean;
begin
  IsRun := False;

  while True do
  begin
    ThreadLock.Enter;
    IsExistThread := MasterSendThreadList.Count > 0;
    ThreadLock.Leave;
    if not IsExistThread then
      Break;
    Sleep( 100 );
  end;
end;

{ TSendMsgBaseHandle }

constructor TSendMsgBaseHandle.Create(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;


{ TSendOnlineConfirmMsgHandle }

procedure TSendConfirmConnectMsgHandle.SendMySocketInfo;
var
  SendIp, SendPort : string;
begin
    // 提取信息
  if IsLanConn then
  begin
    SendIp := PcInfo.LanIp;
    SendPort := PcInfo.LanPort;
  end
  else
  begin
    SendIp := PcInfo.InternetIp;
    SendPort := PcInfo.InternetPort;
  end;

    // 发送信息
  MySocketUtil.SendData( TcpSocket, PcInfo.PcID );
  MySocketUtil.SendData( TcpSocket, PcInfo.PcName );
  MySocketUtil.SendData( TcpSocket, SendIp );
  MySocketUtil.SendData( TcpSocket, SendPort );
  MySocketUtil.SendData( TcpSocket, IsLanConn );
end;

procedure TSendConfirmConnectMsgHandle.SetIsLanConn(_IsLanConn: Boolean);
begin
  IsLanConn := _IsLanConn;
end;

procedure TSendConfirmConnectMsgHandle.SetPcID(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TSendConfirmConnectMsgHandle.Update;
begin
  SendMySocketInfo;
end;

{ TPingMsgHandle }

function TSendPingMsgHandle.ConnectToCS: Boolean;
var
  LocalIsServer, LocalIsClient : Boolean;
  RemoteIsServer, RemoteIsClient : Boolean;
  IsConnected : Boolean;
begin
    // 发送 本地C/S信息
  LocalIsServer := MyServer.IsBeServer;
  LocalIsClient := MyClient.IsConnServer;
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_SendPing_IsServer, LocalIsServer );
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_SendPing_IsClient, LocalIsClient );

    // 接收 远程C/S信息
  RemoteIsServer := MySocketUtil.RevJsonBool( TcpSocket );
  RemoteIsClient := MySocketUtil.RevJsonBool( TcpSocket );

    // 本机是服务器
  Result := False;
  if LocalIsServer and not RemoteIsServer and not RemoteIsClient then
    Result := MyServer.ConnectClient( TcpSocket )
  else
  if RemoteIsServer and not LocalIsServer and not LocalIsClient then
    Result := MyClient.ConnectServer( TcpSocket );
end;

procedure TSendPingMsgHandle.RevRemotePcInfo;
var
  MstStr : string;
  PingMsg2 : TPingMsg2;
  TimeStr : string;
  StartTime : TDateTime;
  RanNum : Integer;
  ClientCount : Integer;
  Params : TMasterInfoAddParams;
begin
    // 接收信息
  MstStr := MySocketUtil.RevData( TcpSocket );
  PingMsg2 := TPingMsg2.Create;
  PingMsg2.SetMsgStr( MstStr );
  ClientCount := PingMsg2.ClientCount;
  StartTime := PingMsg2.StartTime;
  RanNum := PingMsg2.iRanNum;
  PingMsg2.Free;

    // 设置 Master 信息
  Params.PcID := PcID;
  Params.ClientCount := ClientCount;
  Params.StartTime := StartTime;
  Params.RanNum := RanNum;
  MasterInfo.AddItem( Params );
end;

procedure TSendPingMsgHandle.SendMyPcInfo;
var
  SendIp, SendPort : string;
  PingMsg : TPingMsg;
  MsgStr : string;
begin
    // 提取信息
  if IsLanConn then
  begin
    SendIp := PcInfo.LanIp;
    SendPort := PcInfo.LanPort;
  end
  else
  begin
    SendIp := PcInfo.InternetIp;
    SendPort := PcInfo.InternetPort;
  end;

    // 发送信息
  PingMsg := TPingMsg.Create;
  PingMsg.SetPcInfo( PcInfo.PcID, PcInfo.PcName );
  PingMsg.SetSocketInfo( SendIp, SendPort, IsLanConn );
  PingMsg.SetClientCount( MyServer.ClientCount );
  PingMsg.SetMasterInfo( PcInfo.StartTime, PcInfo.RanNum );
  MsgStr := PingMsg.getMsgStr;
  PingMsg.Free;

    // 发送 Ping 信息
  MySocketUtil.SendData( TcpSocket, MsgStr );
end;

procedure TSendPingMsgHandle.SetIsLanConn(_IsLanConn: Boolean);
begin
  IsLanConn := _IsLanConn;
end;

procedure TSendPingMsgHandle.SetPcID(_PcID: string);
begin
  PcID := _PcID;
end;

function TSendPingMsgHandle.Update: Boolean;
begin
  SendMyPcInfo;
  RevRemotePcInfo;
  Result := False;
//  Result := ConnectToCS;
end;

{ TMasterSendHandle }

function TMasterSendHandle.ConnToInternetSocket: Boolean;
var
  MasterSendInternerInfo : TMasterSendInternerInfo;
begin
  Result := False;

  if not ( MasterSendInfo is TMasterSendInternerInfo ) then
    Exit;

  IsLanConn := False;
  MasterSendInternerInfo := MasterSendInfo as TMasterSendInternerInfo;
  Result := ConnToPc( MasterSendInternerInfo.InternetIp, MasterSendInternerInfo.InternetPort );
end;

function TMasterSendHandle.ConnToPc(ConnIp, ConnPort: string): Boolean;
var
  MyTcpConn : TMyTcpConn;
begin
    // 连接对方
  MyTcpConn := TMyTcpConn.Create( TcpSocket );
  MyTcpConn.SetConnSocket( ConnIp, ConnPort );
  MyTcpConn.SetConnType( ConnType_SearchServer );
  if MyTcpConn.Conn then
  begin
    Result := MySocketUtil.RevJsonStr( TcpSocket ) = MasterSendInfo.PcID;
    MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_PcIDConfirm, Result );
    if not Result then
      TcpSocket.Disconnect; // 连接错误
  end
  else
    Result := False;
  MyTcpConn.Free;

    // 连接成功
  if Result then
  begin
    Ip := ConnIp;
    Port := ConnPort;
  end;
end;

function TMasterSendHandle.ConnToSocket: Boolean;
begin
  IsLanConn := True;
  Result := ConnToPc( MasterSendInfo.Ip, MasterSendInfo.Port );
end;

constructor TMasterSendHandle.Create(_MasterSendInfo: TMasterSendConnInfo);
begin
  MasterSendInfo := _MasterSendInfo;
  PcID := MasterSendInfo.PcID;
  TcpSocket := TCustomIpClient.Create( nil );
  IsDestorySocket := True;
end;

destructor TMasterSendHandle.Destroy;
begin
  if IsDestorySocket then
    TcpSocket.Free;
  inherited;
end;

procedure TMasterSendHandle.HandlePing;
var
  SendPingMsgHandle : TSendPingMsgHandle;
  IsConnectCS : Boolean;
begin
    // 设置 端口信息
  NetworkPcApi.SetSocketInfo( PcID, Ip, Port, IsLanConn );

    // 发送 请求命令
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_SearchServerType, MsgType_SearchServer_Ping );

    // Ping 命令
  SendPingMsgHandle := TSendPingMsgHandle.Create( TcpSocket );
  SendPingMsgHandle.SetPcID( PcID );
  SendPingMsgHandle.SetIsLanConn( IsLanConn );
  IsConnectCS := SendPingMsgHandle.Update;
  SendPingMsgHandle.Free;

     // 端口已用作 CS，不用释放
  if IsConnectCS then
    IsDestorySocket := False;
end;

procedure TMasterSendHandle.HandleConfirmConect;
var
  SendConfirmConnectMsgHandle : TSendConfirmConnectMsgHandle;
begin
    // 设置 端口信息
  NetworkPcApi.SetSocketInfo( PcID, Ip, Port, IsLanConn );

    // 发送请求命令
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_SearchServerType, MsgType_SearchServer_ConfirmConnect );

    // 网络信息 确认
  SendConfirmConnectMsgHandle := TSendConfirmConnectMsgHandle.Create( TcpSocket );
  SendConfirmConnectMsgHandle.SetPcID( PcID );
  SendConfirmConnectMsgHandle.SetIsLanConn( IsLanConn );
  SendConfirmConnectMsgHandle.Update;
  SendConfirmConnectMsgHandle.Free;
end;

procedure TMasterSendHandle.HandleSend;
begin
  if ( MasterSendInfo is TMasterSendLanPingInfo ) or
     ( MasterSendInfo is TMasterSendInternetPingInfo )
  then
    HandlePing
  else
  if MasterSendInfo is TMasterSendConfirmConnectInfo then
    HandleConfirmConect;
end;

procedure TMasterSendHandle.MarkNotConnected;
var
  IsMark : Boolean;
  MasterSendInterInfo : TMasterSendInternerInfo;
begin
  IsMark := ( MasterSendInfo is TMasterSendLanPingInfo ) or
            ( MasterSendInfo is TMasterSendInternetPingInfo ) or
            ( MasterSendInfo is TMasterSendConfirmConnectInfo );

  if not IsMark then
    Exit;

    // 局域网 不能连接
  NetworkStatusApi.SetConnInfo( PcID, MasterSendInfo.Ip, MasterSendInfo.Port, False, True );

    // 非 Internet
  if not ( MasterSendInfo is TMasterSendInternerInfo ) then
    Exit;

    // Internet 不能连接
  MasterSendInterInfo := MasterSendInfo as TMasterSendInternerInfo;
  NetworkStatusApi.SetConnInfo( PcID, MasterSendInterInfo.InternetIp, MasterSendInterInfo.InternetPort, False, False );
end;

function TMasterSendHandle.Update: Boolean;
var
  IsBusy : Boolean;
begin
  Result := True;

    // 无法连接
  DebugLock.Debug( 'Conn Pc', PcID );
  if not ConnToSocket and not ConnToInternetSocket then
  begin
    MarkNotConnected; // 记录不能连接
    Exit;
  end;

    // 是否接收繁忙
  IsBusy := MySocketUtil.RevJsonBool( TcpSocket );
  if IsBusy then
  begin
    Result := False; // 繁忙
    Exit;
  end;

    // 连接后的处理
  DebugLock.Debug( 'Handle', MasterSendInfo.ClassName );
  HandleSend;
end;

{ TRevBroadcastMsgHandle }

function TRevBroadcastMsgHandle.CheckBroadcastMsg: Boolean;
var
  MsgInfo : TMsgInfo;
  MsgType, MsgStr : string;
  BroadcastEdition : Integer;
begin
    // 分解广播信息
  MsgInfo := TMsgInfo.Create;
  MsgInfo.SetMsg( BroadcastStr );
  MsgType := MsgInfo.MsgType;
  MsgStr := MsgInfo.MsgStr;
  MsgInfo.Free;

  BroadcastEdition := StrToIntDef( MsgType, 0 );
  LanPcMsgStr := MsgStr;

    // 返回 广播信息 版本号是否正确
  Result := BroadcastEdition = ConnEdition_Now;

    // 程序版本不兼容
  if not Result and ( BroadcastEdition > 0 ) then
    EditionErrorHandle( BroadcastEdition > ConnEdition_Now );
end;

constructor TRevBroadcastMsgHandle.Create(_BroadcastStr: string);
begin
  BroadcastStr := _BroadcastStr;
end;

procedure TRevBroadcastMsgHandle.FindBroadcastMsg;
var
  LanBroadcastMsg : TLanBroadcastMsg;
begin
  LanBroadcastMsg := TLanBroadcastMsg.Create;
  LanBroadcastMsg.SetMsgStr( LanPcMsgStr );
  PcID := LanBroadcastMsg.PcID;
  PcName := LanBroadcastMsg.PcName;
  LanIp := LanBroadcastMsg.LanIp;
  LanPort := LanBroadcastMsg.LanPort;
  CloudIDNumMD5 := LanBroadcastMsg.CloudIDNumMD5;
  BroadcastType := LanBroadcastMsg.BroadcastType;
  LanBroadcastMsg.Free;
end;

procedure TRevBroadcastMsgHandle.LanSearchHandle;
begin
    // 本机
  if PcInfo.PcID = PcID then
    Exit;

    // 非服务器
  if not MyServer.IsBeServer then
    Exit;

    // 多个客户端
  if MyServer.ClientCount > 1 then
    Exit;

    // 非本地网络
  if MyNetworkConnInfo.SelectType <> SelectConnType_Local then
    Exit;

    // 局域网 不能连接
  if not MyTcpUtil.TestConnect( LanIp, LanPort ) then
  begin
    NetworkStatusApi.SetConnInfo( PcID, LanIp, LanPort, False, True );
    Exit;
  end;

    // 设置局域网信息
  NetworkPcApi.SetSocketInfo( PcID, LanIp, LanPort, True );
  NetworkModeApi.SelectLocalConn( PcID );
  MySearchMasterHandler.RestartNetwork; // 重启网络
end;

procedure TRevBroadcastMsgHandle.SendLanPing;
var
  MasterSendLanPingInfo : TMasterSendLanPingInfo;
begin
  MasterSendLanPingInfo := TMasterSendLanPingInfo.Create( PcID );
  MasterSendLanPingInfo.SetSocketInfo( LanIp, LanPort );
  MyMasterSendHandler.AddMasterSend( MasterSendLanPingInfo );
end;

procedure TRevBroadcastMsgHandle.SendMobileReturn;
var
  MobileBroadcastReturnMsg : TMobileBroadcastReturnMsg;
  MsgStr : string;
  UdpClient : TIdUDPClient;
begin
    // 本机不是服务器
  if not MyServer.IsBeServer then
    Exit;

    // 生成命令
  MobileBroadcastReturnMsg := TMobileBroadcastReturnMsg.Create;
  MobileBroadcastReturnMsg.SetSocketInfo( PcInfo.LanIp, PcInfo.LanPort );
  MsgStr := MobileBroadcastReturnMsg.getMsgStr;
  MobileBroadcastReturnMsg.Free;

    // 返回 Udp
  UdpClient := TIdUDPClient.Create( nil );
  try
    UdpClient.Host := BroadcastIp;
    UdpClient.Port := StrToIntDef( BroadcastPort, 0 );
    UdpClient.Send( MsgStr );
  except
  end;
  UdpClient.Free;
end;

procedure TRevBroadcastMsgHandle.SetSocketInfo(_BroadcastIp,
  _BroadcastPort: string);
begin
  BroadcastIp := _BroadcastIp;
  BroadcastPort := _BroadcastPort;
end;

procedure TRevBroadcastMsgHandle.Update;
begin
    // 广播信息 不合法
  if not CheckBroadcastMsg then
    Exit;

    // 解释 广播信息
  FindBroadcastMsg;

    // 子网 不同
  if CloudIDNumMD5 <> CloudSafeSettingInfo.getCloudIDNumMD5 then
    Exit;

  DebugLock.Debug( BroadcastType );

    // 添加 Pc 信息
  NetworkPcApi.AddItem( PcID, PcName );

    // 新机上线广播， 发 Ping 信息
  if BroadcastType = BroadcastType_StartLan then
    SendLanPing
  else  // 搜索未连接的服务器
  if BroadcastType = BroadcastType_SearchPc then
    LanSearchHandle
  else  // 移动设备的情况
  if BroadcastType = BroadcastType_MobileSearch then
    SendMobileReturn;
end;


{ TReceiveAdvanceMsgHandle }

function TReceiveAdvanceMsgHandle.ConfirmAccount: Boolean;
var
  Account, Password : string;
  LoginResult : string;
begin
    // 接收帐号信息
  Account := MySocketUtil.RevJsonStr( TcpSocket );
  Password := MySocketUtil.RevJsonStr( TcpSocket );

    // 获取登录结果
  if not MyAccountReadUtil.ReadIsExist( Account ) then
    LoginResult := AccountLoginResult_AccountNotExist
  else
  if MyAccountReadUtil.ReadPassword( Account ) <> Password then
    LoginResult := AccountLoginResult_PasswordError
  else
    LoginResult := AccountLoginResult_Completed;

    // 发送登录结果
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_LoginResult, LoginResult );

    // 是否登录成功
  Result := LoginResult = AccountLoginResult_Completed;

    // 发送是否免费版
  if Result then
    MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_IsFreeLimit, MyRegisterInfo.IsFreeLimit );
end;

function TReceiveAdvanceMsgHandle.ConfirmSecurityID: Boolean;
var
  RandomNumber : string;
  CloudIDStr, CloudIDNumMD5, MyCloudIDNumberMD5, CloudIDNumberResult : string;
  CloudIDList : TStringList;
begin
    // 检测子网信息
  Randomize;
  RandomNumber := IntToStr( Random( 1000000000 ) );
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_RandomNumStr, RandomNumber ); // 产生随机数并发送

    // 检测
  CloudIDStr := MySocketUtil.RevJsonStr( TcpSocket ); // 检测 SecurityID
  CloudIDStr := MyEncrypt.DecodeStr( CloudIDStr );
  CloudIDList := MySplitStr.getList( CloudIDStr, CloudIdNumber_Split );
  CloudIDNumberResult := CloudIdNumberResult_NotMatch;
  if ( CloudIDList.Count = CloudIdNumber_SplitCount ) and
     ( CloudIDList[ CloudIdNumber_Random ] = RandomNumber ) then
  begin
    CloudIDNumMD5 := CloudIDList[ CloudIdNumber_SecurityID ];
    if CloudIDNumMD5 = CloudIdNumber_Empty then
      CloudIDNumMD5 := '';
    MyCloudIDNumberMD5 := CloudSafeSettingInfo.getCloudIDNumMD5;
    if CloudIDNumMD5 = MyCloudIDNumberMD5 then
      CloudIDNumberResult := CloudIdNumberResult_OK
    else
    if MyCloudIDNumberMD5 = '' then
      CloudIDNumberResult := CloudIdNumberResult_NotSet
    else
      CloudIDNumberResult := CloudIdNumberResult_NotMatch;
  end;
  CloudIDList.Free;

    // 发送检测结果
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_SecurityIDResult, CloudIDNumberResult );

    // SecurityID 是否正确
  Result := CloudIDNumberResult = CloudIdNumberResult_OK
end;

function TReceiveAdvanceMsgHandle.getIsConnectServer: Boolean;
begin
  Result := MyClient.IsConnServer;
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_IsConnectToServer_Confirm, Result );
end;

function TReceiveAdvanceMsgHandle.getIsConnectToCS: Boolean;
begin
  Result := False;

    // 发送本机是否服务器
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_IsServer_Confirm, MyServer.IsBeServer );
  if not MyServer.IsBeServer then
    Exit;

    // 加入到 Client
  Result := MyServer.ConnectClient( TcpSocket );
end;

procedure TReceiveAdvanceMsgHandle.RevRemotePcInfo;
var
  PcID, PcName : string;
  LanIp, LanPort : string;
  InternetIp, InternetPort : string;
  AdvancePcConnMsg : TAdvancePcConnMsg;
begin
    // 获取信息
  PcID := MySocketUtil.RevData( TcpSocket );
  PcName := MySocketUtil.RevData( TcpSocket );
  LanIp := MySocketUtil.RevData( TcpSocket );
  LanPort := MySocketUtil.RevData( TcpSocket );
  InternetIp := MySocketUtil.RevData( TcpSocket );
  InternetPort := MySocketUtil.RevData( TcpSocket );

    // 发送给Server
  AdvancePcConnMsg := TAdvancePcConnMsg.Create;
  AdvancePcConnMsg.SetPcID( PcInfo.PcID );
  AdvancePcConnMsg.SetConnPcInfo( PcID, PcName );
  AdvancePcConnMsg.SetLanSocket( LanIp, LanPort );
  AdvancePcConnMsg.SetInternetSocket( InternetIp, InternetPort );
  MyClient.SendMsgToPc( MyClient.ServerPcID, AdvancePcConnMsg );
end;

procedure TReceiveAdvanceMsgHandle.SendServerInfo;
var
  MasterName : string;
begin
  MasterName := MyNetPcInfoReadUtil.ReadName( MyClient.ServerPcID );

    // 发送信息
  MySocketUtil.SendData( TcpSocket, MyClient.ServerPcID );
  MySocketUtil.SendData( TcpSocket, MasterName );
  MySocketUtil.SendData( TcpSocket, MyClient.ServerLanIp );
  MySocketUtil.SendData( TcpSocket, MyClient.ServerLanPort );
  MySocketUtil.SendData( TcpSocket, MyClient.ServerInternetIp );
  MySocketUtil.SendData( TcpSocket, MyClient.ServerInternetPort );
end;

function TReceiveAdvanceMsgHandle.Update: Boolean;
begin
  Result := False;

    // SecurityID 检测
  if not ConfirmSecurityID then
    Exit;

    // 是否已经连接 Server
  if not getIsConnectServer then
    Exit;

    // Account 检测
  if not ConfirmAccount then
    Exit;

    // 本机是服务器 连接到 CS
  if getIsConnectToCS then
  begin
    Result := True;
    Exit;
  end;

    // 发送 Server 的信息
  SendServerInfo;

    // 接收 Pc 信息，转发给 Server
  RevRemotePcInfo;
end;

{ TReceiveMsgBaseHandle }

constructor TReceiveMsgBaseHandle.Create(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

{ TReceiveOnlineConfirmMsgHandle }

procedure TReceiveConfirmConnectMsgHandle.RevRemoteSocketInfo;
var
  PcID, PcName : string;
  Ip, Port : string;
  IsLanConn : Boolean;
begin
    // 获取信息
  PcID := MySocketUtil.RevData( TcpSocket );
  PcName := MySocketUtil.RevData( TcpSocket );
  Ip := MySocketUtil.RevData( TcpSocket );
  Port := MySocketUtil.RevData( TcpSocket );
  IsLanConn := MySocketUtil.RevBoolData( TcpSocket );

    // 设置 Pc 端口信息
  NetworkPcApi.AddItem( PcID, PcName );
  NetworkPcApi.SetSocketInfo( PcID, Ip, Port, IsLanConn );

    // 设置被连接的状态
  if PcID <> PcInfo.PcID then
  begin
    if IsLanConn then
      MyNetworkStatusApi.SetLanSocketSuccess
    else
      MyNetworkStatusApi.SetInternetSocketSuccess;
  end;
end;

procedure TReceiveConfirmConnectMsgHandle.Update;
begin
  RevRemoteSocketInfo;
end;

{ TReceivePingMsgHandle }

function TReceivePingMsgHandle.ConnectToCS: Boolean;
var
  LocalIsServer, LocalIsClient : Boolean;
  RemoteIsServer, RemoteIsClient : Boolean;
  IsConnected : Boolean;
begin
    // 接收 远程C/S信息
  RemoteIsServer := MySocketUtil.RevJsonBool( TcpSocket );
  RemoteIsClient := MySocketUtil.RevJsonBool( TcpSocket );

      // 发送 本地C/S信息
  LocalIsServer := MyServer.IsBeServer;
  LocalIsClient := MyClient.IsConnServer;
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_RevPing_IsServer, LocalIsServer );
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_RevPing_IsClient, LocalIsClient );

    // 本机是服务器
  Result := False;
  if LocalIsServer and not RemoteIsServer and not RemoteIsClient then
    Result := MyServer.ConnectClient( TcpSocket )
  else
  if RemoteIsServer and not LocalIsServer and not LocalIsClient then
    Result := MyClient.ConnectServer( TcpSocket );
end;

procedure TReceivePingMsgHandle.RevRemotePcInfo;
var
  MsgStr : string;
  PingMsg : TPingMsg;
  PcName : string;
  Ip, Port : string;
  IsLanConn : Boolean;
  ClientCount : Integer;
  TimeStr : string;
  StartTime : TDateTime;
  RanNum : Integer;
  Params : TMasterInfoAddParams;
begin
    // 接收命令
  MsgStr := MySocketUtil.RevData( TcpSocket );

    // 提取信息
  PingMsg := TPingMsg.Create;
  PingMsg.SetMsgStr( MsgStr );
  PcID := PingMsg.PcID;
  PcName := PingMsg.PcName;
  Ip := PingMsg.Ip;
  Port := PingMsg.Port;
  IsLanConn := PingMsg.IsLanConn;
  ClientCount := PingMsg.ClientCount;
  StartTime := PingMsg.StartTime;
  RanNum := PingMsg.RanNum;
  PingMsg.Free;

    // 添加 Pc
  NetworkPcApi.AddItem( PcID, PcName );
  NetworkPcApi.SetSocketInfo( PcID, Ip, Port, IsLanConn );

   // 设置 Master 信息
  Params.PcID := PcID;
  Params.ClientCount := ClientCount;
  Params.StartTime := StartTime;
  Params.RanNum := RanNum;
  MasterInfo.AddItem( Params );

    // 设置被连接的状态
  if PcID <> PcInfo.PcID then
  begin
    if IsLanConn then
      MyNetworkStatusApi.SetLanSocketSuccess
    else
      MyNetworkStatusApi.SetInternetSocketSuccess;
  end;
end;

procedure TReceivePingMsgHandle.SendMyPcInfo;
var
  PingMsg2 : TPingMsg2;
  MsgStr : string;
begin
  PingMsg2 := TPingMsg2.Create;
  PingMsg2.SetClientCount( MyServer.ClientCount );
  PingMsg2.SetMasterInfo( PcInfo.StartTime, PcInfo.RanNum );
  MsgStr := PingMsg2.getMsgStr;
  PingMsg2.Free;

  MySocketUtil.SendData( TcpSocket, MsgStr );
end;

function TReceivePingMsgHandle.Update: Boolean;
begin
  RevRemotePcInfo;
  SendMyPcInfo;
  Result := ConnectToCS;
end;

{ TMasterReceiveThread }

constructor TMasterReceiveThread.Create;
begin
  inherited Create;
end;

procedure TMasterReceiveThread.Execute;
begin
  FreeOnTerminate := True;

    // 处理命令
  try
    HandleReceive;
  except
    on  E: Exception do
      MyWebDebug.AddItem( 'Master Receive Msg', e.Message );
  end;

    // 是否断开连接
  if IsDestorySocket then
    TcpSocket.Free;

    // 删除线程记录
  MyMasterReceiveHanlder.RemoveThread( Self.ThreadID );

  Terminate;
end;

procedure TMasterReceiveThread.HandleAdvanceConn;
var
  ReceiveAdvanceMsgHandle : TReceiveAdvanceMsgHandle;
  IsConnectCS : Boolean;
begin
  ReceiveAdvanceMsgHandle := TReceiveAdvanceMsgHandle.Create( TcpSocket );
  IsConnectCS := ReceiveAdvanceMsgHandle.Update;
  ReceiveAdvanceMsgHandle.Free;

    // 已连接到 CS
  if IsConnectCS then
    IsDestorySocket := False;
end;

procedure TMasterReceiveThread.HandleConfirmConnect;
var
  ReceiveConfirmConnectMsgHandle : TReceiveConfirmConnectMsgHandle;
begin
  ReceiveConfirmConnectMsgHandle := TReceiveConfirmConnectMsgHandle.Create( TcpSocket );
  ReceiveConfirmConnectMsgHandle.Update;
  ReceiveConfirmConnectMsgHandle.Free;
end;


procedure TMasterReceiveThread.HandlePing;
var
  ReceivePingMsgHandle : TReceivePingMsgHandle;
  IsConnectCS : Boolean;
begin
  ReceivePingMsgHandle := TReceivePingMsgHandle.Create( TcpSocket );
  IsConnectCS := ReceivePingMsgHandle.Update;
  ReceivePingMsgHandle.Free;

    // 已连接到 CS
  if IsConnectCS then
    IsDestorySocket := False;
end;

procedure TMasterReceiveThread.HandleReceive;
var
  MsgType : string;
begin
  MsgType := MySocketUtil.RevJsonStr( TcpSocket );
  DebugLock.Debug( 'Handle', MsgType );
  if MsgType = MsgType_SearchServer_Ping then
    HandlePing
  else
  if MsgType = MsgType_SearchServer_ConfirmConnect then
    HandleConfirmConnect
  else
  if MsgType = MsgType_SearchServer_ConnectToPc then
    HandleAdvanceConn;
end;

procedure TMasterReceiveThread.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
  IsDestorySocket := True;
end;

{ TMyMasterReceiveHandle }

constructor TMyMasterReceiveHandler.Create;
begin
  IsRun := True;

  ThreadLock := TCriticalSection.Create;
  MasterReceiveThreadList := TMasterReceiveThreadList.Create;
  MasterReceiveThreadList.OwnsObjects := False;

  MsgLock := TCriticalSection.Create;
  BroadcastList := TBroadcastList.Create;
  BroadcastList.OwnsObjects := False;
  IsCreateThread := False;
end;

destructor TMyMasterReceiveHandler.Destroy;
begin
  BroadcastList.OwnsObjects := True;
  BroadcastList.Free;
  MsgLock.Free;

  MasterReceiveThreadList.Free;
  ThreadLock.Free;
  inherited;
end;

function TMyMasterReceiveHandler.getBroadcast: TBroadcastInfo;
begin
  MsgLock.Enter;
  if BroadcastList.Count > 0 then
  begin
    Result := BroadcastList[0];
    BroadcastList.Delete( 0 );
  end
  else
  begin
    IsCreateThread := False;
    Result := nil;
  end;
  MsgLock.Leave;
end;

function TMyMasterReceiveHandler.getIsRuning: Boolean;
begin
  Result := False;
  if not IsRun then
    Exit;

    // 正在处理链接命令 或 正在处理广播
  ThreadLock.Enter;
  Result := MasterReceiveThreadList.Count > 0;
  Result := Result or IsCreateThread;
  ThreadLock.Leave;
end;

procedure TMyMasterReceiveHandler.ReceiveBroadcast(BroadcastMsg, Ip, Port: string);
var
  BroadcastInfo : TBroadcastInfo;
begin
  if not IsRun then
    Exit;

  MsgLock.Enter;

  BroadcastInfo := TBroadcastInfo.Create( Ip, Port );
  BroadcastInfo.SetMsgStr( BroadcastMsg );
  BroadcastList.Add( BroadcastInfo );

  if not IsCreateThread then
  begin
    IsCreateThread := True;
    MasterReceiveBroadcastThread := TMasterReceiveBroadcastThread.Create;
    MasterReceiveBroadcastThread.Resume;
  end;
  MsgLock.Leave;
end;

procedure TMyMasterReceiveHandler.ReceiveConn(TcpSocket: TCustomIpClient);
var
  IsSuccess, IsBusy : Boolean;
  NewThread : TMasterReceiveThread;
begin
    // 程序结束
  if not IsRun then
  begin
    TcpSocket.Disconnect;
    TcpSocket.Free;
    Exit;
  end;

    // 判断连接是否正确
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_PcID_Connect, PcInfo.PcID );
  IsSuccess := MySocketUtil.RevJsonBool( TcpSocket );
  if not IsSuccess then  // 连接错误
  begin
    TcpSocket.Free;
    Exit;
  end;

    // 获取非繁忙线程处理连接
  ThreadLock.Enter;
  IsBusy := True;
  if MasterReceiveThreadList.Count < ThreadCount_MasterMsg then
  begin
    NewThread := TMasterReceiveThread.Create;
    NewThread.SetTcpSocket( TcpSocket );
    MasterReceiveThreadList.Add( NewThread );

      // 发送非繁忙
    MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_IsBusy, False );
    NewThread.Resume;

    IsBusy := False;
  end;
  ThreadLock.Leave;

    // 繁忙则结束
  if IsBusy then
  begin
    MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_IsBusy, True ); // 发送繁忙
    TcpSocket.Free;
  end;
end;

procedure TMyMasterReceiveHandler.RemoveThread(ThreadID: Cardinal);
var
  i: Integer;
begin
  ThreadLock.Enter;
  for i := 0 to MasterReceiveThreadList.Count - 1 do
    if MasterReceiveThreadList[i].ThreadID = ThreadID then
    begin
      MasterReceiveThreadList.Delete( i );
      Break;
    end;
  ThreadLock.Leave;
end;

procedure TMyMasterReceiveHandler.StopRun;
var
  IsExistThread : Boolean;
begin
  IsRun := False;

    // 等待连接线程结束
  while true do
  begin
    ThreadLock.Enter;
    IsExistThread := MasterReceiveThreadList.Count > 0;
    ThreadLock.Leave;
    if not IsExistThread then
      Break;
    Sleep(100);
  end;

    // 等待广播线程结束
  while IsCreateThread do
    Sleep( 100 );
end;

procedure TMyMasterReceiveHandler.udpServerUDPRead(
  AThread: TIdUDPListenerThread; AData: TArray<System.Byte>;
  ABinding: TIdSocketHandle);
var
  RevStr : string;
begin
  RevStr := BytesToString( AData );
  ReceiveBroadcast( RevStr, ABinding.PeerIP, IntToStr( ABinding.PeerPort ) );
end;

{ TMasterReceiveBroadcastThread }

constructor TMasterReceiveBroadcastThread.Create;
begin
  inherited Create;
end;

destructor TMasterReceiveBroadcastThread.Destroy;
begin
  inherited;
end;

procedure TMasterReceiveBroadcastThread.Execute;
var
  BroadcastInfo : TBroadcastInfo;
begin
  FreeOnTerminate := True;

  while MyMasterReceiveHanlder.IsRun do
  begin
    BroadcastInfo := MyMasterReceiveHanlder.getBroadcast;
    if not Assigned( BroadcastInfo ) then
      Break;

    try
      HandleMsg( BroadcastInfo.MsgStr, BroadcastInfo.Ip, BroadcastInfo.Port );
    except
    end;

    BroadcastInfo.Free;
  end;

    // 清空创建记录
  if not MyMasterReceiveHanlder.IsRun then
    MyMasterReceiveHanlder.IsCreateThread := False;

    // 结束线程
  Terminate;
end;

procedure TMasterReceiveBroadcastThread.HandleMsg(MsgStr, Ip, Port: string);
var
  RevBroadcastMsgHandle : TRevBroadcastMsgHandle;
begin
  RevBroadcastMsgHandle := TRevBroadcastMsgHandle.Create( MsgStr );
  RevBroadcastMsgHandle.SetSocketInfo( Ip, Port );
  RevBroadcastMsgHandle.Update;
  RevBroadcastMsgHandle.Free;
end;

procedure TRevBroadcastMsgHandle.EditionErrorHandle( IsNewEdition : Boolean );
var
  LanBroadcastMsg : TLanBroadcastMsg;
begin
  LanBroadcastMsg := TLanBroadcastMsg.Create;
  LanBroadcastMsg.SetMsgStr( LanPcMsgStr );
  LanIp := LanBroadcastMsg.LanIp;
  NetworkErrorStatusApi.ShowExistOldEdition( LanIp, IsNewEdition );
  LanBroadcastMsg.Free;
end;


{ TPingMsg }

procedure TPingMsg.SetClientCount(_ClientCount: Integer);
begin
  ClientCount := _ClientCount;
end;

procedure TPingMsg.SetMasterInfo(_StartTime: TDateTime; _RanNum: Integer);
begin
  StartTime := _StartTime;
  RanNum := _RanNum;
end;

procedure TPingMsg.SetPcInfo(_PcID, _PcName: string);
begin
  PcID := _PcID;
  PcName := _PcName;
end;

procedure TPingMsg.SetSocketInfo(_Ip, _Port: string; _IsLanConn: Boolean);
begin
  Ip := _Ip;
  Port := _Port;
  IsLanConn := _IsLanConn;
end;

{ TPingMsg2 }

procedure TPingMsg2.SetClientCount(_ClientCount: Integer);
begin
  ClientCount := _ClientCount;
end;

procedure TPingMsg2.SetMasterInfo(_StartTime: TDateTime; _RanNum: Integer);
begin
  StartTime := _StartTime;
  RanNum := _RanNum;
end;

{ TMobileBroadcastReturnMsg }

procedure TMobileBroadcastReturnMsg.SetSocketInfo(_Ip, _Port: string);
begin
  Ip := _Ip;
  Port := _Port;
end;

{ TBroadcastInfo }

constructor TBroadcastInfo.Create(_Ip, _Port: string);
begin
  Ip := _Ip;
  Port := _Port;
end;

procedure TBroadcastInfo.SetMsgStr(_MsgStr: string);
begin
  MsgStr := _MsgStr;
end;

end.

