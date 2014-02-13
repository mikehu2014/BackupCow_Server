unit USearchServer;

interface

uses classes, UMyNetPcInfo, UModelUtil, Sockets, UMyTcp, SysUtils, DateUtils, Generics.Collections,
     IdHTTP, UMyUrl, SyncObjs, UPortMap, uDebugLock, IdUDPServer, IdUDPClient;

type

{$Region ' 搜索网络 运行 ' }

    // 搜索网路 父类
  TSearchServerRun = class
  public
    procedure Update;virtual;abstract;
    function getRunNetworkStatus : string;virtual;
  end;

  {$Region ' 局域网 ' }

    // 定时 搜索未连接的 Pc
  TLanSearchPcThread = class( TDebugThread )
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure SearchPcHandle;
  end;

    // 搜索 局域网 的服务器
  TLanSearchServer = class( TSearchServerRun )
  private
    UdpServer : TIdUDPServer;
  private
    BindSocketReuslt : string;
    LanSearchPcThread : TLanSearchPcThread;
  private
    SearchPcID : string;
  public
    constructor Create;
    procedure SetSearchPcID( _SearchPcID : string );
    procedure Update;override;
    destructor Destroy; override;
  private
    procedure SendBroadcast;
    procedure ConnectSearchPc;
  end;

    // 发广播辅助类
  SendBroadcastUtil = class
  public
    class procedure SendMsg( MsgStr : string );
  end;

  {$EndRegion}

  {$Region ' Group 网络 ' }

    // Standard Pc Info
  TStandardPcInfo = class
  public
    PcID, PcName : string;
    LanIp, LanPort : string;
    InternetIp, InternetPort : string;
  public
    constructor Create( _PcID, _PcName : string );
    procedure SetLanSocket( _LanIp, _LanPort : string );
    procedure SetInternetSocket( _InternetIp, _InternetPort : string );
  end;
  TStandardPcPair = TPair< string , TStandardPcInfo >;
  TStandardPcHash = class(TStringDictionary< TStandardPcInfo >);

      // 发送公司网请求
  TFindStandardNetworkHttp = class
  private
    CompanyName, Password : string;
    Cmd : string;
  public
    constructor Create( _CompanyName, _Password : string );
    procedure SetCmd( _Cmd : string );
    function get : string;
  end;

    // HearBeat
  TStandardHearBetThread = class( TDebugThread )
  private
    AccountName, Password : string;
    LastServerNumber : Integer;
  public
    constructor Create;
    procedure SetAccountInfo( _AccountName, _Password : string );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure SendHeartBeat;
    procedure CheckAccountPc;
  end;

    // 找到 一个 Standard Pc
  TStandardPcAddHanlde = class
  private
    StandardPcInfo : TStandardPcInfo;
  public
    constructor Create( _StandardPcInfo : TStandardPcInfo );
    procedure Update;
  end;

    // 搜索 Account Name 的服务器
  TGroupSearchServer = class( TSearchServerRun )
  private
    GroupName, Password : string;
  private
    StandardPcMsg : string;
    StandardPcHash : TStandardPcHash;
  private
    WaitTime : Integer;
  private
    RunNetworkStatus : string;
    StandardHearBetThread : TStandardHearBetThread;
  public
    constructor Create;
    procedure SetGroupInfo( _GroupName, _Password : string );
    procedure Update;override;
    destructor Destroy; override;
  private
    function LoginAccount : Boolean;
    procedure FindStandardPcHash;
    procedure PingStandardPcHash;
    procedure LogoutAccount;
  private
    procedure PasswordError;
    procedure AccountNameNotExit;
  public
    function getRunNetworkStatus : string;override;
  end;

  {$EndRegion}

  {$Region ' 直连网络 ' }

   // 定时 重启网络 连接指定 Pc
  TRestartConnectToPcThread = class( TDebugThread )
  private
    StartTime : TDateTime;
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  public
    procedure RunRestart;
    procedure ShowRemainTime;
  end;

    // 搜索 Internet Pc 的服务器
  TConnToPcSearchServer = class( TSearchServerRun )
  private
    Domain : string;
    Ip, Port : string;
  private
    TcpSocket : TCustomIpClient;
    IsDestorySocket : Boolean;
    RestartConnectToPcThread : TRestartConnectToPcThread;
  private
    ServerPcID, ServerPcName : string;
    ServerLanIp, ServerLanPort : string;
    ServerInternetIp, ServerInternetPort : string;
    CloudIdNumberResult : string;
  private
    RunNetworkStatus : string;
  public
    constructor Create;
    procedure SetConnPcInfo( _Domain, _Port : string );
    procedure Update;override;
    destructor Destroy; override;
  private
    procedure PingMyPc;
    function FindIp: Boolean;
    function ConnTargetPc : Boolean;
    function CheckCloudIDNumber : Boolean;
    function getIsConnectToCS : Boolean;
    procedure NotConnServer;
    procedure RevServerPcInfo;
    procedure SendMyPcInfo;
    procedure WaitServerNotify;
  private
    procedure CloudIDNumberError;
    procedure WaitToConn( WaitTime : Integer );
  public
    function getRunNetworkStatus : string;override;
  end;


  {$EndRegion}

{$EndRegion}

{$Region ' 搜索 Master 线程 ' }

    // 连接服务器操作
  TConnServerHandle = class
  private
    ServerIp, ServerPort : string;
  private
    TcpSocket : TCustomIpClient;
  public
    constructor Create( _ServerIp, _ServerPort : string );
    procedure Update;
  private
    function ConnServer: Boolean;
  end;

    // 获取 Internet 端口信息
  TFindInternetSocket = class
  private
    PortMapping : TPortMapping;
    LanIp, LanPort : string;
    InternetIp, InternetPort : string;
  public
    constructor Create( _PortMapping : TPortMapping );
    procedure SetLanSocket( _LanIp, _LanPort : string );
    procedure Update;
  private
    procedure FindInternetIp;
    procedure FindInternetPort;
  private
    function FindRouterInternetIp: Boolean;
    function FindWebInternetIp: Boolean;
    procedure SetInternetFace;
  end;

      // 确认网络信息没有冲突， 冲突则修改
  TConfirmNetworkInfoHandle = class
  private
    PortMapping : TPortMapping;
  public
    constructor Create( _PortMapping : TPortMapping );
    procedure Upate;
  private
    procedure ConfirmLanIp;
    procedure ConfirmLanPort;
    procedure ConfirmInternetIp;
    procedure ConfirmInternetPort;
    procedure ConfirmInternetPortMap;
  private      // 获取 Internet Ip 的不同情况
    function FindRouterInternetIp: string;
    function FindWebInternetIp: string;
  end;

    // 搜索服务器运行
  TSearchServerRunCreate = class
  public
    function get : TSearchServerRun;
  public
    function getLan : TLanSearchServer;
    function getGroup : TGroupSearchServer;
    function getConnToPc : TConnToPcSearchServer;
  end;

    // 定时器 Api
  MySearchMasterTimerApi = class
  public
    class procedure CheckRestartNetwork;
    class procedure MakePortMapping;
  end;

    // 搜索 服务器
  TMasterThread = class( TDebugThread )
  private
    PortMapping : TPortMapping;
    SearchServerRun : TSearchServerRun; // 运行网络
    RunNetworkStatus : string; // 运行网络状态
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure ResetNetworkPc;
    procedure RunNetwork;
    procedure WaitPingMsg;
    procedure BeServer;
    procedure WaitServerNotify;
    function ConnServer: Boolean;
    procedure StopNetwork;
  private
    procedure WaitMaster( WaitTime : Integer );
  end;

    // 搜索服务器处理
  TMySearchMasterHandler = class
  public
    IsRun, IsConnecting : Boolean;
    MasterThread : TMasterThread;
  public
    constructor Create;
    procedure StartRun;
    procedure StopRun;
  public
    function getIsRun : Boolean;
    procedure RestartNetwork;
  end;

{$EndRegion}

const
  WaitTime_Ping = 5;
  WaitTime_ServerNofity = 20;
  WaitTime_AdvanceBusy = 5;
  WaitTime_AdvanceNotServer = 5;

const
  RunNetworkStatus_OK = 'OK';
  RunNetworkStatus_GroupNotExist = 'GroupNotExist';
  RunNetworkStatus_GroupPassowrdError = 'GroupPassowrdError';
  RunNetworkStatus_IpError = 'IpError';
  RunNetworkStatus_NotConn = 'NotConn';
  RunNetworkStatus_SecurityError = 'SecurityError';

const
  CloudIdNumber_Empty = '<Empty>';
  CloudIdNumber_Split = '<Split>';
  CloudIdNumber_SplitCount = 3;
  CloudIdNumber_Random = 0;
  CloudIdNumber_SecurityID = 1;
  CloudIdNumber_DateTime = 2;

  CloudIdNumberResult_OK = 'OK';
  CloudIdNumberResult_NotMatch = 'NotMatch';
  CloudIdNumberResult_NotSet = 'NotSet';

const
  MsgType_Ping : string = 'Ping';
  MsgType_BackPing : string = 'BackPing';

    // Standard Network Http 连接类型
  Cmd_Login = 'login';
  Cmd_HeartBeat = 'heartbeat';
  Cmd_ReadLoginNumber = 'readloginnumber';
  Cmd_AddServerNumber = 'addservernumber';
  Cmd_ReadServerNumber = 'readservernumber';
  Cmd_Logout = 'logout';

    // Standard Network Http 参数
  HttpReq_CompanyName = 'CompanyName';
  HttpReq_Password = 'Password';
  HttpReq_PcID = 'PcID';
  HttpReq_PcName = 'PcName';
  HttpReq_LanIp = 'LanIp';
  HttpReq_LanPort = 'LanPort';
  HttpReq_InternetIp = 'InternetIp';
  HttpReq_InternetPort = 'InternetPort';
  HttpReq_CloudIDNumber = 'CloudIDNumber';

    // Login 结果
  LoginResult_ConnError = 'ConnError';
  LoginResult_CompanyNotFind = 'CompanyNotFind';
  LoginResult_PasswordError = 'PasswordError';
  LoginResult_OK = 'OK';

    // Resutl Split
  Split_Result = '<Result/>';
  Split_Pc = '<Pc/>';
  Split_PcPro = '<PcPro/>';

  PcProCount = 6;
  PcPro_PcID = 0;
  PcPro_PcName = 1;
  PcPro_LanIp = 2;
  PcPro_LanPort = 3;
  PcPro_InternetIp = 4;
  PcPro_InternetPort = 5;

  ShowForm_CompanyNameError : string = 'Group name "%s" does not exist.';
  ShowForm_PasswordError : string = 'Password is incorrect.Please input password again.';
  ShowForm_ParseError : string = 'Can not parse "%s" to ip address.';

  WaitTime_LAN : Integer = 5;
  WaitTime_Standard : Integer = 20;
  WaitTime_Advance : Integer = 30;

  WaitTime_MyPc : Integer = 2;

  WaitTime_PortMap = 10; // 分钟

  AdvanceMsg_NotServer = 'NotServer'; // 非服务器

  UdpPort_Broadcast : Integer = 8542;
var
  MySearchMasterHandler : TMySearchMasterHandler;

implementation

uses UNetworkControl, UNetworkFace, UMyUtil, UMyMaster, UMyClient, UMyServer,
     USettingInfo, uDebug, UNetPcInfoXml, UMyBackupDataInfo, UBackupThread, UCloudThread, URestoreThread,
     UChangeInfo, UMyTimerThread, UAppSplitEdition;

{ TSearchServerThread }

procedure TMasterThread.BeServer;
var
  ActivatePcList : TStringList;
  i: Integer;
  MasterConnClientInfo : TMasterConnClientInfo;
begin
  if RunNetworkStatus <> RunNetworkStatus_OK then
    Exit;

    // 程序结束, 重启网络
    // 已连接 Server
    // 其他人 比较值最大
  if not MySearchMasterHandler.getIsRun or
     MyClient.IsConnServer or
     ( MasterInfo.MaxPcID <> PcInfo.PcID )
  then
    Exit;

    // 成为服务器
  MyServer.BeServer;

    // 通知已激活的Pc 我是 Master
  ActivatePcList := MyNetPcInfoReadUtil.ReadActivatePcList;
  for i := 0 to ActivatePcList.Count - 1 do
  begin
    MasterConnClientInfo := TMasterConnClientInfo.Create( ActivatePcList[i] );
    MyMasterSendHandler.AddMasterSend( MasterConnClientInfo );
  end;

    // 只有本机 且 没有本地备份， 则显示没有网络 Pc
  if ( ActivatePcList.Count <= 1 ) and
     not DesItemInfoReadUtil.ReadIsExistLocalBackup
  then
    NetworkErrorStatusApi.ShowNoPc;
  ActivatePcList.Free;
end;

function TMasterThread.ConnServer: Boolean;
var
  ServerPcID, ServerIp, ServerPort : string;
  ConnServerHandle : TConnServerHandle;
begin
  DebugLock.Debug( 'Conn Server' );

  Result := False;

    // 结束
  if not MySearchMasterHandler.getIsRun then
    Exit;

    // 网络非正常运行
  if RunNetworkStatus <> RunNetworkStatus_OK then
  begin
    Result := True;
    NetworkConnStatusShowApi.SetNotConnected;
    Exit;
  end;

    // 如果未连接，则连接
  if not MyClient.IsConnServer then
  begin
      // 提取 Master 信息
    ServerPcID := MasterInfo.MaxPcID;
    ServerIp := MyNetPcInfoReadUtil.ReadIp( ServerPcID );
    ServerPort := MyNetPcInfoReadUtil.ReadPort( ServerPcID );

      // 连接 Master
    ConnServerHandle := TConnServerHandle.Create( ServerIp, ServerPort );
    ConnServerHandle.Update;
    ConnServerHandle.Free;
  end;

    // 连接成功，显示已连接
  if MyClient.IsConnServer then
  begin
    Result := True;
    NetworkConnStatusShowApi.SetConnected;
  end;

    // 连接的过程中断开连接
  if not MySearchMasterHandler.getIsRun then
    Result := False;
end;

constructor TMasterThread.Create;
begin
  inherited Create;
end;

procedure TMasterThread.StopNetwork;
begin
  DebugLock.Debug( 'Stop Network' );

    // 断开客户端连接
  MyClient.ClientLostConn;

    // 断开服务器连接
  MyServer.ServerLostConn;

    // 停止定时重启网络
  MyTimerHandler.RemoveTimer( HandleType_RestartNetwork );

    // 停止网络运行
  SearchServerRun.Free;

    // 停止监听端口
  MyListener.StopListen;

    // 停止端口映射
  MyTimerHandler.RemoveTimer( HandleType_PortMapping );
  PortMapping.RemoveMapping( PcInfo.InternetPort );
  PortMapping.Free;

    // 显示未连接
  NetworkConnStatusShowApi.SetNotConnected;
end;

destructor TMasterThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;
  inherited;
end;

procedure TMasterThread.Execute;
begin
  while not Terminated do
  begin
      // 初始化
    ResetNetworkPc;

      // 运行网络
    RunNetwork;

      // 等待 与其他 Pc 交互信息
    WaitPingMsg;

      // 成为服务器
    BeServer;

      // 等待 Server 通知
    WaitServerNotify;

      // 连接服务器成功, 挂起线程
    if ConnServer then
      Suspend;

      // 停止运行网络
    StopNetwork;
  end;
  inherited;
end;

procedure TMasterThread.RunNetwork;
var
  ConfirmNetworkInfoHandle : TConfirmNetworkInfoHandle;
  SearchServerRunCreate : TSearchServerRunCreate;
begin
  DebugLock.Debug( 'Run Network' );

    // 正在连接
  MySearchMasterHandler.IsConnecting := True;

    // 显示正在连接
  NetworkConnStatusShowApi.SetConnecting;

    // 可以改变网络状态
  NetworkConnStatusShowApi.SetCanChangeNetwork;

    // 端口映射
  PortMapping := TPortMapping.Create;
  ConfirmNetworkInfoHandle := TConfirmNetworkInfoHandle.Create( PortMapping );
  ConfirmNetworkInfoHandle.Upate;
  ConfirmNetworkInfoHandle.Free;
  PortMapping.AddMapping( PcInfo.LanIp, PcInfo.InternetPort );
  MyTimerHandler.AddTimer( HandleType_PortMapping, 600 );

    // 设置服务器信息
  NetworkAccountApi.SetIpInfo( PcInfo.LanIp, PcInfo.LanPort, PcInfo.InternetIp, PcInfo.InternetPort );

    // 开始监听
  MyListener.StartListenLan( PcInfo.LanPort );
  MyListener.StartListenInternet( PcInfo.InternetPort );

    // 显示信息到我的状态
  MyNetworkStatusApi.SetLanSocket( PcInfo.LanIp, PcInfo.LanPort );
  MyNetworkStatusApi.SetInternetSocket( PcInfo.InternetIp, PcInfo.InternetPort );

    // 启动网络
  SearchServerRunCreate := TSearchServerRunCreate.Create;
  SearchServerRun := SearchServerRunCreate.get;
  SearchServerRunCreate.Free;
  SearchServerRun.Update;
  RunNetworkStatus := SearchServerRun.getRunNetworkStatus;

    // 定时重启无法连接的网络, 十分钟
  MyTimerHandler.AddTimer( HandleType_RestartNetwork, 600 );
end;

procedure TMasterThread.ResetNetworkPc;
var
  NetworkPcResetHandle : TNetworkPcResetHandle;
begin
    // 重置 Pc 信息
  NetworkPcResetHandle := TNetworkPcResetHandle.Create;
  NetworkPcResetHandle.Update;
  NetworkPcResetHandle.Free;

    // 重置 Master 信息
  MasterInfo.ResetMasterPc;
end;

procedure TMasterThread.WaitMaster(WaitTime: Integer);
var
  Count, WaitSecond : Integer;
  SbMyStatusConningInfo : TSbMyStatusConningInfo;
begin
  if RunNetworkStatus <> RunNetworkStatus_OK then
    Exit;

  Count := 0;
  WaitSecond := 0;
  while MySearchMasterHandler.getIsRun and not MyClient.IsConnServer do
  begin
      // 等待时间结束，且 没有发送 或 接收命令
    if ( WaitSecond >= WaitTime ) and
       not MyMasterSendHandler.getIsRuning and
       not MyMasterReceiveHanlder.getIsRuning
    then
      Break;

    Sleep( 100 );
    inc( Count );
    if Count = 10 then
    begin
      NetworkConnStatusShowApi.SetConnecting; // 显示正在连接
      Count := 0;
      inc( WaitSecond );
    end;
  end;
end;

procedure TMasterThread.WaitPingMsg;
begin
    // 等待 与其他网络 Pc 交换信息
  WaitMaster( WaitTime_Ping );
end;

procedure TMasterThread.WaitServerNotify;
begin
    // 等待 Master 出现
  WaitMaster( WaitTime_ServerNofity );
end;


{ TLanSearchServer }

constructor TLanSearchServer.Create;
begin
    // 创建 udp Server
  UdpServer := TIdUDPServer.Create( nil );
  with UdpServer.Bindings.Add do
  begin
    IP := '0.0.0.0';
    Port := UdpPort_Broadcast;
  end;
  UdpServer.OnUDPRead := MyMasterReceiveHanlder.udpServerUDPRead;
  UdpServer.Active := True;

    // 定时搜索线程
  LanSearchPcThread := TLanSearchPcThread.Create;
  LanSearchPcThread.Resume;
end;

destructor TLanSearchServer.Destroy;
begin
  LanSearchPcThread.Free;
  UdpServer.Free;
  inherited;
end;

procedure TLanSearchServer.Update;
begin
  DebugLock.Debug( 'Lan Search Server' );

    // 显示到 我的网络状态
  MyNetworkStatusApi.LanConnections;
  MyNetworkStatusApi.SetBroadcastPort( IntToStr( UdpPort_Broadcast ), BindSocketReuslt );

    // 发送广播信息
  SendBroadcast;

    // 连接特殊的 Pc
  ConnectSearchPc;
end;

{ TStandSearchServer }

procedure TGroupSearchServer.AccountNameNotExit;
var
  ErrorStr : string;
begin
    // 显示错误提示框
  ErrorStr := Format( ShowForm_CompanyNameError, [GroupName] );
  MyMessageBox.ShowError( ErrorStr );

    // 重新输入信息
  NetworkModeApi.AccountNotExist( GroupName, Password );

    // 主界面提示
  NetworkErrorStatusApi.ShowGroupNotExist( GroupName );
end;

constructor TGroupSearchServer.Create;
begin
  StandardPcHash := TStandardPcHash.Create;
  StandardHearBetThread := TStandardHearBetThread.Create;
end;

destructor TGroupSearchServer.Destroy;
begin
  StandardHearBetThread.Free;
  StandardPcHash.Free;
  LogoutAccount; // Logout
  inherited;
end;

procedure TGroupSearchServer.FindStandardPcHash;
var
  PcStrList : TStringList;
  PcProStrList : TStringList;
  i : Integer;
  PcID, PcName : string;
  LanIp, LanPort : string;
  InternetIp, InternetPort : string;
  StandardPcInfo : TStandardPcInfo;
begin
  PcStrList := MySplitStr.getList( StandardPcMsg, Split_Pc );
  for i := 0 to PcStrList.Count - 1 do
  begin
    PcProStrList := MySplitStr.getList( PcStrList[i], Split_PcPro );
    if PcProStrList.Count = PcProCount then
    begin
      PcID := PcProStrList[ PcPro_PcID ];
      PcName := PcProStrList[ PcPro_PcName ];
      LanIp := PcProStrList[ PcPro_LanIp ];
      LanPort := PcProStrList[ PcPro_LanPort ];
      InternetIp := PcProStrList[ PcPro_InternetIp ];
      InternetPort := PcProStrList[ PcPro_InternetPort ];

      StandardPcInfo := TStandardPcInfo.Create( PcID, PcName );
      StandardPcInfo.SetLanSocket( LanIp, LanPort );
      StandardPcInfo.SetInternetSocket( InternetIp, InternetPort );

      StandardPcHash.AddOrSetValue( PcID, StandardPcInfo );
    end;
    PcProStrList.Free;
  end;
  PcStrList.Free;
end;

function TGroupSearchServer.getRunNetworkStatus: string;
begin
  Result := RunNetworkStatus;
end;

function TGroupSearchServer.LoginAccount: Boolean;
var
  FindStandardNetworkHttp : TFindStandardNetworkHttp;
  HttpStr, HttpResult : string;
  HttpStrList : TStringList;
begin
  DebugLock.Debug( 'Login Group' );

  Result := False;

    // 登录
  FindStandardNetworkHttp := TFindStandardNetworkHttp.Create( GroupName, Password );
  FindStandardNetworkHttp.SetCmd( Cmd_Login );
  HttpStr := FindStandardNetworkHttp.get;
  FindStandardNetworkHttp.Free;

    // 网络连接 断开
  RunNetworkStatus := RunNetworkStatus_OK;
  if HttpStr = LoginResult_ConnError then
  else  // 帐号不存在
  if HttpStr = LoginResult_CompanyNotFind then
  begin
    RunNetworkStatus := RunNetworkStatus_GroupNotExist;
    AccountNameNotExit;
  end
  else   // 密码错误
  if HttpStr = LoginResult_PasswordError then
  begin
    RunNetworkStatus := RunNetworkStatus_GroupPassowrdError;
    PasswordError;
  end
  else
  begin   // 登录成功
    HttpStrList := MySplitStr.getList( HttpStr, Split_Result );
    if HttpStrList.Count > 0 then
      HttpResult := HttpStrList[0];
    if HttpResult = LoginResult_OK then
    begin
      if HttpStrList.Count > 1 then
        StandardPcMsg := HttpStrList[1];
      Result := True;
    end;
    HttpStrList.Free;
  end;
end;

procedure TGroupSearchServer.LogoutAccount;
var
  FindStandardNetworkHttp : TFindStandardNetworkHttp;
begin
    // Logout
  FindStandardNetworkHttp := TFindStandardNetworkHttp.Create( GroupName, Password );
  FindStandardNetworkHttp.SetCmd( Cmd_Logout );
  FindStandardNetworkHttp.get;
  FindStandardNetworkHttp.Free;
end;

procedure TGroupSearchServer.PasswordError;
var
  StandardPasswordError : TStandardPasswordError;
begin
    // 显示提示框
  MyMessageBox.ShowError( ShowForm_PasswordError );

    // 重新填写 Group 信息
  NetworkModeApi.PasswordError( GroupName );

    // 主界面显示
  NetworkErrorStatusApi.ShowGroupPasswordError( GroupName );
end;

procedure TGroupSearchServer.PingStandardPcHash;
var
  p : TStandardPcPair;
  StandardPcAddHanlde : TStandardPcAddHanlde;
begin
  DebugLock.Debug( 'Ping Group Pc' );

  for p in StandardPcHash do
  begin
    StandardPcAddHanlde := TStandardPcAddHanlde.Create( p.Value );
    StandardPcAddHanlde.Update;
    StandardPcAddHanlde.Free;
  end;

  if StandardPcHash.Count <= 1 then
    WaitTime := WaitTime_MyPc
  else
    WaitTime := WaitTime_Standard;
end;

procedure TGroupSearchServer.SetGroupInfo(_GroupName, _Password: string);
begin
  GroupName := _GroupName;
  Password := _Password;
end;

procedure TGroupSearchServer.Update;
begin
  DebugLock.Debug( 'Group Search Server' );

    // 显示到 我的网络状态
  MyNetworkStatusApi.GroupConnections( GroupName );
  MyNetworkStatusApi.SetBroadcastDisable;

    // 登录 Group 是否成功
  if LoginAccount then
  begin
    FindStandardPcHash;
    PingStandardPcHash;
    StandardHearBetThread.SetAccountInfo( GroupName, Password );
    StandardHearBetThread.Resume;
  end;
end;

{ TAdvanceSearchServer }

function TConnToPcSearchServer.CheckCloudIDNumber: Boolean;
var
  RandomNumber : string;
  CloudIdStr : string;
begin
    // 获取对方发送的随机数
  RandomNumber := MySocketUtil.RevJsonStr( TcpSocket );

    // 获取本机的 Security ID
  CloudIdStr := CloudSafeSettingInfo.getCloudIDNumMD5;
  if CloudIdStr = '' then  // 空值则用特殊字符代替
    CloudIdStr := CloudIdNumber_Empty;

    // 组合和加密
  CloudIdStr := RandomNumber + CloudIdNumber_Split + CloudIdStr;
  CloudIdStr := CloudIdStr + CloudIdNumber_Split + MyRegionUtil.ReadRemoteTimeStr( Now );
  CloudIdStr := MyEncrypt.EncodeStr( CloudIdStr );

    // 发送 ID
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_SecurityID, CloudIdStr );

    // 获取返回结果
  CloudIdNumberResult := MySocketUtil.RevJsonStr( TcpSocket );

    // 是否成功匹配
  Result := CloudIdNumberResult = CloudIdNumberResult_OK;
end;

procedure TConnToPcSearchServer.CloudIDNumberError;
var
  ErrorType, ErrorStr, ShowError : string;
begin
    // 对方没有设置 Security ID，本机设置了
  if CloudIdNumberResult = CloudIdNumberResult_NotSet then
  begin
    ErrorType := SecurityIDError_MySet;
    ErrorStr := SecurityIDErrorShowStr_MySet;
  end
  else  // 对方设置了 Security ID，本机没有设置
  if CloudSafeSettingInfo.getCloudIDNumMD5 = '' then
  begin
    ErrorType := SecurityIDError_OtherSet;
    ErrorStr := SecurityIDErrorShowStr_OtherSet;
  end
  else
  begin
    ErrorType := SecurityIDError_NotMatch;
    ErrorStr := SecurityIDErrorShowStr_NotMatch;
  end;

    // 提示出错
  ShowError := Format( ErrorStr, [Domain + ':' + Port] );
  MyMessageBox.ShowWarnning( ShowError );

    // 重新输入 Cloud ID
  NetworkModeApi.CloudIDError;

    // 主界面显示
  NetworkErrorStatusApi.ShowSecurityError( Domain, Port, ErrorType );
end;

function TConnToPcSearchServer.ConnTargetPc: Boolean;
var
  MyTcpConn : TMyTcpConn;
  ConnPcID : string;
  IsBusy : Boolean;
  i: Integer;
begin
  DebugLock.Debug( 'Connect to Target Pc' );

  Result := False;
  IsBusy := False;

    // 连接 Pc
  MyTcpConn := TMyTcpConn.Create( TcpSocket );
  MyTcpConn.SetConnSocket( Ip, Port );
  MyTcpConn.SetConnType( ConnType_SearchServer );
  if MyTcpConn.Conn then
  begin
    ConnPcID := MySocketUtil.RevJsonStr( TcpSocket );
    MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_PcIDConfirm, True );
    IsBusy := MySocketUtil.RevJsonBool( TcpSocket );
    if not IsBusy then
    begin
      MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_SearchServerType, MsgType_SearchServer_ConnectToPc );
      Result := True;
    end;
  end;
  MyTcpConn.Free;

    // 远程繁忙, 1 秒后再连接
  if IsBusy then
  begin
    WaitToConn( WaitTime_AdvanceBusy );
    if MySearchMasterHandler.getIsRun then
      Result := ConnTargetPc;
  end;

    // 目标 Pc 离线
  if not Result then
  begin
    NetworkErrorStatusApi.ShowCannotConn( Domain, Port );  // 显示 无法连接
    RestartConnectToPcThread.RunRestart;  // 启动定时重启
  end;
end;

constructor TConnToPcSearchServer.Create;
begin
  TcpSocket := TCustomIpClient.Create(nil);
  RestartConnectToPcThread := TRestartConnectToPcThread.Create;
  IsDestorySocket := True;
end;

destructor TConnToPcSearchServer.Destroy;
begin
  RestartConnectToPcThread.Free;
  if IsDestorySocket then
    TcpSocket.Free;
  inherited;
end;

function TConnToPcSearchServer.FindIp: Boolean;
var
  ErrorStr : string;
begin
  Result := True;

    // 输入的是Ip
  if MyParseHost.IsIpStr( Domain ) then
  begin
    Ip := Domain;
    Exit;
  end;

    // 域名解释成功
  if MyParseHost.HostToIP( Domain, Ip ) then
    Exit;

    // 域名解释失败
  NetworkErrorStatusApi.ShowIpError( Domain, Port ); // 显示失败信息
  RestartConnectToPcThread.RunRestart;  // 定时重启程序
  Result := False;
end;

function TConnToPcSearchServer.getIsConnectToCS: Boolean;
var
  RemoteIsServer : Boolean;
begin
  Result := False;

    // 接收对方是否服务器
  RemoteIsServer := MySocketUtil.RevJsonBool( TcpSocket );
  if not RemoteIsServer then
    Exit;

    // 连接
  Result := MyClient.ConnectServer( TcpSocket );
end;

function TConnToPcSearchServer.getRunNetworkStatus: string;
begin
  Result := RunNetworkStatus;
end;

procedure TConnToPcSearchServer.NotConnServer;
var
  ConnToPcSearchServer : TConnToPcSearchServer;
begin
  DebugLock.Debug( 'Wait Conn Server' );

    // 5 秒后再连接
  WaitToConn( WaitTime_AdvanceNotServer );

    // 程序结束
  if not MySearchMasterHandler.getIsRun then
    Exit;

    // 再连接一次
  ConnToPcSearchServer := TConnToPcSearchServer.Create;
  ConnToPcSearchServer.SetConnPcInfo( Domain, Port );
  ConnToPcSearchServer.Update;
  ConnToPcSearchServer.Free;
end;

procedure TConnToPcSearchServer.PingMyPc;
var
  MasterSendLanPingInfo : TMasterSendLanPingInfo;
begin
  MasterSendLanPingInfo := TMasterSendLanPingInfo.Create( PcInfo.PcID );
  MasterSendLanPingInfo.SetSocketInfo( PcInfo.LanIp, PcInfo.LanPort );
  MyMasterSendHandler.AddMasterSend( MasterSendLanPingInfo );
end;

procedure TConnToPcSearchServer.RevServerPcInfo;
begin
    // 获取信息
  ServerPcID := MySocketUtil.RevData( TcpSocket );
  ServerPcName := MySocketUtil.RevData( TcpSocket );
  ServerLanIp := MySocketUtil.RevData( TcpSocket );
  ServerLanPort := MySocketUtil.RevData( TcpSocket );
  ServerInternetIp := MySocketUtil.RevData( TcpSocket );
  ServerInternetPort := MySocketUtil.RevData( TcpSocket );

    // 添加服务器信息
  NetworkPcApi.AddItem( ServerPcID, ServerPcName );
end;

procedure TConnToPcSearchServer.SendMyPcInfo;
begin
    // 发送信息
  MySocketUtil.SendData( TcpSocket, PcInfo.PcID );
  MySocketUtil.SendData( TcpSocket, PcInfo.PcName );
  MySocketUtil.SendData( TcpSocket, PcInfo.LanIp );
  MySocketUtil.SendData( TcpSocket, PcInfo.LanPort );
  MySocketUtil.SendData( TcpSocket, PcInfo.InternetIp );
  MySocketUtil.SendData( TcpSocket, PcInfo.InternetPort );
end;

procedure TConnToPcSearchServer.SetConnPcInfo(_Domain, _Port: string);
begin
  Domain := _Domain;
  Port := _Port;
end;

procedure TConnToPcSearchServer.Update;
var
  IsConnectServer : Boolean;
begin
  DebugLock.Debug( 'Connect to pc Search Server' );

    // 显示到 我的网络状态
  MyNetworkStatusApi.ConnToPcConnections( Domain + ':' + Port );
  MyNetworkStatusApi.SetBroadcastDisable;

    // 默认成功
  RunNetworkStatus := RunNetworkStatus_OK;

    // Ip 解释错误
  if not FindIp then
  begin
    RunNetworkStatus := RunNetworkStatus_IpError;
    Exit;
  end;

    // 连接本机
  PingMyPc;

    // 无法连接远程 Pc
  if not ConnTargetPc then
  begin
    RunNetworkStatus := RunNetworkStatus_NotConn;
    Exit;
  end;

    // 检测是否同一子网
  if not CheckCloudIDNumber then
  begin
    RunNetworkStatus := RunNetworkStatus_SecurityError;
    CloudIDNumberError; // 不是相同的子网
    Exit;
  end;

    // 目标是否已连接服务器
  IsConnectServer := MySocketUtil.RevBoolData( TcpSocket );
  if not IsConnectServer then
  begin
    NotConnServer;  // 等待 5 秒后重连
    Exit;
  end;

    // 直接连接到服务器
  if getIsConnectToCS then
  begin
    IsDestorySocket := False; // 端口已用作 CS
    Exit;
  end;

    // 接收服务器信息
  RevServerPcInfo;

    // 发送本机信息，邀请服务器连接
  SendMyPcInfo;

    // 等待服务器连接，如果服务器没有连接，则主动连接服务器
  WaitServerNotify;
end;

procedure TConnToPcSearchServer.WaitServerNotify;
var
  MasterSendInternetPingInfo : TMasterSendInternetPingInfo;
  Count, WaitSecond : Integer;
begin
  Count := 0;
  WaitSecond := 0;
  while MySearchMasterHandler.getIsRun and not MyClient.IsConnServer do
  begin
      // 等待时间结束
    if WaitSecond >= WaitTime_ServerNofity then
      Break;

    Sleep( 100 );
    inc( Count );
    if Count = 10 then
    begin
      NetworkConnStatusShowApi.SetConnecting; // 显示正在连接
      Count := 0;
      inc( WaitSecond );
    end;
  end;

    // 程序结束 或 已连接服务器
  if not MySearchMasterHandler.getIsRun or MyClient.IsConnServer then
    Exit;

    // 发送 Ping 命令
  MasterSendInternetPingInfo := TMasterSendInternetPingInfo.Create( ServerPcID );
  MasterSendInternetPingInfo.SetSocketInfo( ServerLanIp, ServerLanPort );
  MasterSendInternetPingInfo.SetInternetSocket( ServerInternetIp, ServerInternetPort );
  MyMasterSendHandler.AddMasterSend( MasterSendInternetPingInfo );
end;

procedure TConnToPcSearchServer.WaitToConn(WaitTime: Integer);
var
  Count, WaitSecond : Integer;
begin
  Count := 0;
  WaitSecond := 0;
  while MySearchMasterHandler.getIsRun do
  begin
      // 等待时间结束
    if WaitSecond >= WaitTime then
      Break;

    Sleep( 100 );
    inc( Count );
    if Count = 10 then
    begin
      NetworkConnStatusShowApi.SetConnecting; // 显示正在连接
      Count := 0;
      inc( WaitSecond );
    end;
  end;
end;

{ TFindInternetSocket }

constructor TFindInternetSocket.Create(_PortMapping: TPortMapping);
begin
  PortMapping := _PortMapping;
end;

procedure TFindInternetSocket.FindInternetIp;
var
  IsFindIp : Boolean;
begin
    // 从 路由/网站 获取 Internet IP
  if PortMapping.IsPortMapable then
    IsFindIp := FindRouterInternetIp
  else
    IsFindIp := FindWebInternetIp;

    // 没有找到 InternetIp, 则由 LanIp 代替
  if not IsFindIp then
    InternetIp := LanIp;
end;

procedure TFindInternetSocket.FindInternetPort;
begin
  if not PortMapping.IsPortMapable then
    InternetPort := LanPort
  else
    InternetPort := MyUpnpUtil.getUpnpPort( LanIp );
end;

function TFindInternetSocket.FindRouterInternetIp: Boolean;
begin
  InternetIp := PortMapping.getInternetIp;
  Result := InternetIp <> '';
end;

function TFindInternetSocket.FindWebInternetIp: Boolean;
var
  getIpHttp : TIdHTTP;
  httpStr : string;
  HttpList : TStringList;
begin
  getIpHttp := TIdHTTP.Create(nil);
  getIpHttp.ConnectTimeout := 10000;
  getIpHttp.ReadTimeout := 10000;
  try
    httpStr := getIpHttp.Get( MyUrl.getIp );

    HttpList := TStringList.Create;
    HttpList.Text := httpStr;
    InternetIp := HttpList[0];
    HttpList.Free;

    Result := True;
  except
    Result := False;
  end;
  getIpHttp.Free;
end;

procedure TFindInternetSocket.SetInternetFace;
var
  InternetSocketChangeInfo : TInternetSocketChangeInfo;
begin
    // 显示到 Setting 界面
  InternetSocketChangeInfo := TInternetSocketChangeInfo.Create( InternetIp );
  InternetSocketChangeInfo.AddChange;
end;

procedure TFindInternetSocket.SetLanSocket(_LanIp, _LanPort: string);
begin
  LanIp := _LanIp;
  LanPort := _LanPort;
end;

procedure TFindInternetSocket.Update;
begin
  FindInternetIp;
  FindInternetPort;

  PcInfo.SetInternetInfo( InternetIp, InternetPort );
  SetInternetFace;
end;

{ TStandardPcInfo }

constructor TStandardPcInfo.Create(_PcID, _PcName: string);
begin
  PcID := _PcID;
  PcName := _PcName;
end;

procedure TStandardPcInfo.SetInternetSocket(_InternetIp, _InternetPort: string);
begin
  InternetIp := _InternetIp;
  InternetPort := _InternetPort;
end;

procedure TStandardPcInfo.SetLanSocket(_LanIp, _LanPort: string);
begin
  LanIp := _LanIp;
  LanPort := _LanPort;
end;

{ TFindStandardNetworkHttp }

constructor TFindStandardNetworkHttp.Create(_CompanyName, _Password: string);
begin
  CompanyName := _CompanyName;
  Password := _Password;
end;

function TFindStandardNetworkHttp.get: string;
var
  PcID, PcName : string;
  LanIp, LanPort : string;
  InternetIp, InternetPort : string;
  CloudIDNumber : string;
  params : TStringlist;
  idhttp : TIdHTTP;
begin
    // 本机信息
  PcID := PcInfo.PcID;
  PcName := PcInfo.PcName;
  LanIp := PcInfo.LanIP;
  LanPort := PcInfo.LanPort;
  InternetIp := PcInfo.InternetIp;
  InternetPort := PcInfo.InternetPort;
  CloudIDNumber := CloudSafeSettingInfo.getCloudIDNumMD5;

    // 登录并获取在线 Pc 信息
  params := TStringList.Create;
  params.Add( HttpReq_CompanyName + '=' + CompanyName );
  params.Add( HttpReq_Password + '=' + Password );
  params.Add( HttpReq_PcID + '=' + PcID );
  params.Add( HttpReq_PcName + '=' + PcName );
  params.Add( HttpReq_LanIp + '=' + LanIp );
  params.Add( HttpReq_LanPort + '=' + LanPort );
  params.Add( HttpReq_InternetIp + '=' + InternetIp );
  params.Add( HttpReq_InternetPort + '=' + InternetPort );
  params.Add( HttpReq_CloudIDNumber + '=' + CloudIDNumber );

  idhttp := TIdHTTP.Create(nil);
  idhttp.ReadTimeout := 30000;
  idhttp.ConnectTimeout := 30000;
  try
    Result := idhttp.Post( MyUrl.getGroupPcList + '?cmd=' + Cmd, params );
  except
    Result := LoginResult_ConnError;
  end;
  idhttp.Free;

  params.free;
end;

procedure TFindStandardNetworkHttp.SetCmd(_Cmd: string);
begin
  Cmd := _Cmd;
end;

{ TStandardHearBetThread }

procedure TStandardHearBetThread.CheckAccountPc;
var
  Cmd : string;
  ServerNumber : Integer;
  FindStandardNetworkHttp : TFindStandardNetworkHttp;
begin
    // 本机 非 Server
  if not MyServer.IsBeServer then
    Exit;

    // 已有客户端连接
  if MyServer.ClientCount > 1 then
    Exit;

    // 是否第一次
  if LastServerNumber = -1 then
    Cmd := Cmd_AddServerNumber
  else
    Cmd := Cmd_ReadServerNumber;

    // Login Number
  FindStandardNetworkHttp := TFindStandardNetworkHttp.Create( AccountName, Password );
  FindStandardNetworkHttp.SetCmd( Cmd );
  ServerNumber := StrToIntDef( FindStandardNetworkHttp.get, 0 );
  FindStandardNetworkHttp.Free;

    // 第一次
  if LastServerNumber = -1 then
  begin
    LastServerNumber := ServerNumber;
    Exit;
  end;

    // 与上次想相同
  if LastServerNumber = ServerNumber then
    Exit;

    // 重启网络
  MySearchMasterHandler.RestartNetwork;
end;

constructor TStandardHearBetThread.Create;
begin
  inherited Create;
  LastServerNumber := -1;
end;

destructor TStandardHearBetThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  inherited;
end;

procedure TStandardHearBetThread.Execute;
var
  StartHearBeat, StartCheckAccount : TDateTime;
begin
  StartHearBeat := Now;
  StartCheckAccount := 0;
  while not Terminated do
  begin
      // 5 分钟 发送一次心跳
    if MinutesBetween( Now, StartHearBeat ) >= 5 then
    begin
      SendHeartBeat;
      StartHearBeat := Now;
    end;
      // 10 秒钟 检测一次帐号
    if ( SecondsBetween( Now, StartCheckAccount ) >= 20 ) or
       ( LastServerNumber = -1 ) then
    begin
      CheckAccountPc;
      StartCheckAccount := Now;
    end;
    if Terminated then
      Break;
    Sleep(100);
  end;
  inherited;
end;

procedure TStandardHearBetThread.SendHeartBeat;
var
  FindStandardNetworkHttp : TFindStandardNetworkHttp;
begin
    // 心跳
  FindStandardNetworkHttp := TFindStandardNetworkHttp.Create( AccountName, Password );
  FindStandardNetworkHttp.SetCmd( Cmd_HeartBeat );
  FindStandardNetworkHttp.get;
  FindStandardNetworkHttp.Free;
end;

procedure TStandardHearBetThread.SetAccountInfo(_AccountName,
  _Password: string);
begin
  AccountName := _AccountName;
  Password := _Password;
end;

{ TStandardPcAddHanlde }

constructor TStandardPcAddHanlde.Create(_StandardPcInfo: TStandardPcInfo);
begin
  StandardPcInfo := _StandardPcInfo;
end;

procedure TStandardPcAddHanlde.Update;
var
  MasterSendInternetPingInfo : TMasterSendInternetPingInfo;
begin
    // 添加 Pc 信息
  NetworkPcApi.AddItem( StandardPcInfo.PcID, StandardPcInfo.PcName );

    // Ping Pc
  MasterSendInternetPingInfo := TMasterSendInternetPingInfo.Create( StandardPcInfo.PcID );
  MasterSendInternetPingInfo.SetSocketInfo( StandardPcInfo.LanIp, StandardPcInfo.LanPort );
  MasterSendInternetPingInfo.SetInternetSocket( StandardPcInfo.InternetIp, StandardPcInfo.InternetPort );
  MyMasterSendHandler.AddMasterSend( MasterSendInternetPingInfo );
end;

{ TRestartNetworkThread }

constructor TRestartConnectToPcThread.Create;
begin
  inherited Create;
end;

destructor TRestartConnectToPcThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  inherited;
end;

procedure TRestartConnectToPcThread.Execute;
var
  LastShowTime : TDateTime;
begin
  while not Terminated do
  begin
    LastShowTime := Now;
    while ( not Terminated ) and ( SecondsBetween( Now, LastShowTime ) < 1 ) do
      Sleep(100);
    if Terminated then
      Break;
    ShowRemainTime;
  end;

  inherited;
end;

procedure TRestartConnectToPcThread.RunRestart;
begin
    // 开始时间
  StartTime := Now;

    // 显示剩余时间
  ShowRemainTime;

    // 启动线程
  Resume;
end;

procedure TRestartConnectToPcThread.ShowRemainTime;
var
  RemainTime : Integer;
begin
    // 计算剩余时间
  RemainTime := 300 - SecondsBetween( Now, StartTime );

    // 显示剩余时间
  NetworkErrorStatusApi.ShowConnAgainRemain( RemainTime );

    // 重启网络
  if RemainTime <= 0 then
    MySearchMasterHandler.RestartNetwork;
end;

{ TMySearchMasterHandler }

constructor TMySearchMasterHandler.Create;
begin
  MasterThread := TMasterThread.Create;
  IsRun := True;
end;

function TMySearchMasterHandler.getIsRun: Boolean;
begin
  Result := IsRun and IsConnecting;
end;

procedure TMySearchMasterHandler.RestartNetwork;
begin
  if not IsRun then
    Exit;

    // 隐藏连接错误信息
  NetworkErrorStatusApi.HideError;

    // 暂时不能改变网络
  NetworkConnStatusShowApi.SetNotChangeNetwork;

    // 重启网络
  IsConnecting := False;
  MasterThread.Resume;
end;

procedure TMySearchMasterHandler.StartRun;
begin
  MasterThread.Resume;
end;

procedure TMySearchMasterHandler.StopRun;
begin
  IsRun := False;
  MasterThread.Free;
end;

{ TSearchServerRunCreate }

function TSearchServerRunCreate.get: TSearchServerRun;
var
  SelectType : string;
begin
  SelectType := MyNetworkConnInfo.SelectType;

    // 返回是否连接成功
  if SelectType = SelectConnType_Group then
    Result := getGroup
  else
  if SelectType = SelectConnType_ConnPC then
    Result := getConnToPc
  else
    Result := getLan;
end;

function TSearchServerRunCreate.getConnToPc: TConnToPcSearchServer;
var
  Domain, Port : string;
begin
  Domain := MyNetworkConnInfo.SelectValue1;
  Port := MyNetworkConnInfo.SelectValue2;

  Result := TConnToPcSearchServer.Create;
  Result.SetConnPcInfo( Domain, Port );
end;

function TSearchServerRunCreate.getGroup: TGroupSearchServer;
var
  GroupName, Password : string;
begin
  GroupName := MyNetworkConnInfo.SelectValue1;
  Password := NetworkGroupInfoReadUtil.ReadPassword( GroupName );

  Result := TGroupSearchServer.Create;
  Result.SetGroupInfo( GroupName, Password );
end;

function TSearchServerRunCreate.getLan: TLanSearchServer;
begin
  Result := TLanSearchServer.Create;
end;

{ TLanSearchPcThread }

constructor TLanSearchPcThread.Create;
begin
  inherited Create;
end;

destructor TLanSearchPcThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;
  inherited;
end;

procedure TLanSearchPcThread.Execute;
var
  StartTime : TDateTime;
begin
  while not Terminated do
  begin
      // 20 秒钟 检测一次网络
    StartTime := Now;
    while not Terminated and ( SecondsBetween( Now, StartTime ) < 20 ) do
      Sleep(100);
    if Terminated then
      Break;
    SearchPcHandle;
  end;
  inherited;
end;

procedure TLanSearchPcThread.SearchPcHandle;
var
  CloudIDNumMD5 : string;
  LanBroadcastMsg : TLanBroadcastMsg;
  MsgInfo : TMsgInfo;
  MsgType, MsgStr, Msg : string;
begin
    // 不是服务器
  if not MyServer.IsBeServer then
    Exit;

  CloudIDNumMD5 := CloudSafeSettingInfo.getCloudIDNumMD5;

      // 获取 广播信息
  LanBroadcastMsg := TLanBroadcastMsg.Create;
  LanBroadcastMsg.SetPcID( PcInfo.PcID );
  LanBroadcastMsg.SetPcName( PcInfo.PcName );
  LanBroadcastMsg.SetSocketInfo( PcInfo.LanIp, PcInfo.LanPort );
  LanBroadcastMsg.SetCloudIDNumMD5( CloudIDNumMD5 );
  LanBroadcastMsg.SetBroadcastType( BroadcastType_SearchPc );
  MsgStr := LanBroadcastMsg.getMsgStr;
  LanBroadcastMsg.Free;

    // 广播信息的版本
  MsgType := IntToStr( ConnEdition_Now );

    // 包装 广播信息
  MsgInfo := TMsgInfo.Create;
  MsgInfo.SetMsgInfo( MsgType, MsgStr );
  Msg := MsgInfo.getMsg;
  MsgInfo.Free;

    // 发送 广播信息
  SendBroadcastUtil.SendMsg( Msg );
end;

procedure TLanSearchServer.SendBroadcast;
var
  CloudIDNumMD5 : string;
  LanBroadcastMsg : TLanBroadcastMsg;
  MsgInfo : TMsgInfo;
  MsgType, MsgStr, Msg : string;
  UdpClient : TIdUDPClient;
  IpList : TStringList;
  i : Integer;
begin
  CloudIDNumMD5 := CloudSafeSettingInfo.getCloudIDNumMD5;

      // 获取 广播信息
  LanBroadcastMsg := TLanBroadcastMsg.Create;
  LanBroadcastMsg.SetPcID( PcInfo.PcID );
  LanBroadcastMsg.SetPcName( PcInfo.PcName );
  LanBroadcastMsg.SetSocketInfo( PcInfo.LanIp, PcInfo.LanPort );
  LanBroadcastMsg.SetCloudIDNumMD5( CloudIDNumMD5 );
  LanBroadcastMsg.SetBroadcastType( BroadcastType_StartLan );
  MsgStr := LanBroadcastMsg.getMsgStr;
  LanBroadcastMsg.Free;

    // 广播信息的版本
  MsgType := IntToStr( ConnEdition_Now );

    // 包装 广播信息
  MsgInfo := TMsgInfo.Create;
  MsgInfo.SetMsgInfo( MsgType, MsgStr );
  Msg := MsgInfo.getMsg;
  MsgInfo.Free;

    // 发送广播
  SendBroadcastUtil.SendMsg( Msg );
end;

procedure TLanSearchServer.ConnectSearchPc;
var
  SearchPcName, SearchIp, SearchPort : string;
  MasterSendLanPingInfo : TMasterSendLanPingInfo;
begin
  if SearchPcID = '' then
    Exit;

   // 提取 Pc 信息
  SearchPcName := MyNetPcInfoReadUtil.ReadName( SearchPcID );
  SearchIp := MyNetPcInfoReadUtil.ReadIp( SearchPcID );
  SearchPort := MyNetPcInfoReadUtil.ReadPort( SearchPcID );

  if ( SearchIp = '' ) or ( SearchPort = '' ) then
    Exit;

    // 添加 Pc 信息
  NetworkPcApi.AddItem( SearchPcID, SearchPcName );

    // 发送 Ping
  MasterSendLanPingInfo := TMasterSendLanPingInfo.Create( SearchPcID );
  MasterSendLanPingInfo.SetSocketInfo( SearchIp, SearchPort );
  MyMasterSendHandler.AddMasterSend( MasterSendLanPingInfo );
end;

procedure TLanSearchServer.SetSearchPcID(_SearchPcID: string);
begin
  SearchPcID := _SearchPcID;
end;

{ TConfirmNetworkInfoHandle }

procedure TConfirmNetworkInfoHandle.ConfirmInternetIp;
var
  InternetIp : string;
  InternetSocketChangeInfo : TInternetSocketChangeInfo;
begin
  InternetIp := '';

     // 从路由 获取 Internet IP
  if PortMapping.IsPortMapable then
    InternetIp := FindRouterInternetIp;

    // 从网站 获取 Internet Ip
  if InternetIp = '' then
    InternetIp := FindWebInternetIp;

    // 没有找到 InternetIp, 则由 LanIp 代替
  if InternetIp = '' then
    InternetIp := PcInfo.LanIp;

    // 设置 Internet Ip 信息
  MyPcInfoApi.SetInternetIp( InternetIp );
end;

procedure TConfirmNetworkInfoHandle.ConfirmInternetPort;
var
  Port : Integer;
  i: Integer;
begin
  Port := StrToIntDef( PcInfo.InternetPort, 16954 );
  for i := 0 to 10000 do
  begin
      // 端口可用则结束
    if MyTcpUtil.getPortAvaialble( Port ) then
      Break;
    inc( Port );
  end;

    // 端口号不相同, 重设端口号
  if PcInfo.InternetPort <> IntToStr( Port ) then
    MyPcInfoApi.SetInternetPort( IntToStr( Port ) );
end;

procedure TConfirmNetworkInfoHandle.ConfirmInternetPortMap;
var
  InternetPort, i : Integer;
  IsPortMap : Boolean;
begin
    // 界面显示映射情况
  MyNetworkStatusApi.SetIsExistUpnp( PortMapping.IsPortMapable, PortMapping.controlurl );

    // 不可端口映射
  if not PortMapping.IsPortMapable then
    Exit;

    // 检测映射端口是否被占用
  IsPortMap := False;
  InternetPort := StrToIntDef( PcInfo.InternetPort, 26954 );
  for i := 0 to 100 do
  begin
      // 端口映射成功
    if PortMapping.AddMapping( PcInfo.LanIp, IntToStr( InternetPort ) ) then
    begin
      IsPortMap := True;
      Break;
    end;

      // 如果端口被占用则使用下一个端口
    inc( InternetPort );
  end;

    // 是否映射成功
  MyNetworkStatusApi.SetIsPortMapCompleted( IsPortMap );

    // 采用了新的端口
  if PcInfo.InternetPort <> IntToStr( InternetPort ) then
    MyPcInfoApi.SetInternetPort( IntToStr( InternetPort ) );
end;

procedure TConfirmNetworkInfoHandle.ConfirmLanIp;
var
  IpList : TStringList;
  TempLanIp : string;
begin
  IpList := MyIpList.get;
  if IpList.IndexOf( PcInfo.RealLanIp ) < 0 then // 指定的 Ip 不存在
  begin
    if IpList.Count > 0 then
    begin
      TempLanIp := IpList[0];
      MyPcInfoApi.SetTempLanIp( TempLanIp ); // 设置 临时 Ip
    end;
  end
  else
  if PcInfo.RealLanIp <> PcInfo.LanIp then   // 重置 Ip
    MyPcInfoApi.SetTempLanIp( PcInfo.RealLanIp );
  IpList.Free;
end;

procedure TConfirmNetworkInfoHandle.ConfirmLanPort;
var
  Port : Integer;
  i: Integer;
begin
  Port := StrToIntDef( PcInfo.LanPort, 9494 );
  for i := 0 to 10000 do
  begin
      // 端口可用则结束
    if MyTcpUtil.getPortAvaialble( Port ) then
      Break;
    inc( Port );
  end;

    // 端口号不相同, 重设端口号
  if PcInfo.LanPort <> IntToStr( Port ) then
    MyPcInfoApi.SetLanPort( IntToStr( Port ) );
end;

constructor TConfirmNetworkInfoHandle.Create(_PortMapping: TPortMapping);
begin
  PortMapping := _PortMapping;
end;

function TConfirmNetworkInfoHandle.FindRouterInternetIp: string;
var
  i: Integer;
begin
    // 可能获取失败，获取 5 次
  for i := 1 to 5 do
  begin
    Result := PortMapping.getInternetIp;
    if Result <> '' then
      Break;
    Sleep(100);
  end;
end;

function TConfirmNetworkInfoHandle.FindWebInternetIp: string;
var
  getIpHttp : TIdHTTP;
  httpStr : string;
  HttpList : TStringList;
  i: Integer;
  IsFind : Boolean;
begin
  Result := '';

    // 可能因为网络原因获取失败， 获取 5 次
  for i := 1 to 5 do
  begin
    getIpHttp := TIdHTTP.Create(nil);
    getIpHttp.ConnectTimeout := 5000;
    getIpHttp.ReadTimeout := 5000;
    try
      httpStr := getIpHttp.Get( MyUrl.getIp );

      HttpList := TStringList.Create;
      HttpList.Text := httpStr;
      Result := HttpList[0];
      HttpList.Free;

      IsFind := True;
    except
      IsFind := False;
    end;
    getIpHttp.Free;

      // 成功获取 Ip
    if IsFind then
      Break;

    Sleep(100);
  end;
end;

procedure TConfirmNetworkInfoHandle.Upate;
begin
  DebugLock.Debug( 'Confirm Network' );

    // 局域网端口信息
  ConfirmLanIp;
  ConfirmLanPort;

    // 互联网端口信息
  ConfirmInternetIp;
  ConfirmInternetPort;
  ConfirmInternetPortMap;
end;

{ TConnServerHandle }

function TConnServerHandle.ConnServer: Boolean;
var
  MyTcpConn : TMyTcpConn;
  IsServer, IsConnectServer, IsExistClient : Boolean;
begin
  Result := False;

    // 连接 目标 Pc
  MyTcpConn := TMyTcpConn.Create( TcpSocket );
  MyTcpConn.SetConnSocket( ServerIp, ServerPort );
  MyTcpConn.SetConnType( ConnType_Server );
  IsConnectServer := MyTcpConn.Conn;
  MyTcpConn.Free;

    // 连接失败
  if not IsConnectServer then
    Exit;

    // 获取对方是否 Pc
  IsServer := MySocketUtil.RevBoolData( TcpSocket );
  if not IsServer then
    Exit;

    // 发送本机标识
  MySocketUtil.SendData( TcpSocket, PcInfo.PcID );

    // 是否存在客户端
  IsExistClient := StrToBoolDef( MySocketUtil.RevData( TcpSocket ), False );
  if IsExistClient then // 已存在客户端
    Exit;

  Result := True;
end;

constructor TConnServerHandle.Create(_ServerIp, _ServerPort: string);
begin
  ServerIp := _ServerIp;
  ServerPort := _ServerPort;
end;

procedure TConnServerHandle.Update;
begin
  TcpSocket := TCustomIpClient.Create( nil );

    // 连接服务器
  if ConnServer then
    MyClient.ConnectServer( TcpSocket )
  else  // 连接失败
    TcpSocket.Free;
end;

{ MySearchMasterTimerApi }

class procedure MySearchMasterTimerApi.CheckRestartNetwork;
begin
  if not MySearchMasterHandler.IsRun then
    Exit;

    // 非服务器
  if not MyServer.IsBeServer then
    Exit;

    // 有多个客户端
  if MyServer.ClientCount > 1 then
    Exit;

    // 存在本机备份
  if DesItemInfoReadUtil.ReadIsExistLocalBackup then
    Exit;

    // 重启网络
  MySearchMasterHandler.RestartNetwork;
end;

class procedure MySearchMasterTimerApi.MakePortMapping;
begin
  if not MySearchMasterHandler.IsRun then
    Exit;

  try
    MySearchMasterHandler.MasterThread.PortMapping.AddMapping( PcInfo.LanIp, PcInfo.InternetPort );
  except
  end;
end;

function TSearchServerRun.getRunNetworkStatus: string;
begin
  Result := RunNetworkStatus_OK;
end;

{ SendBroadcastUtil }

class procedure SendBroadcastUtil.SendMsg(MsgStr: string);
var
  UdpClient : TIdUDPClient;
  IpList : TStringList;
  i : Integer;
begin
    // 发送广播
  IpList := MyIpList.get;
  for i := 0 to IpList.Count - 1 do
  begin
    UdpClient := TIdUDPClient.Create( nil );
    try
      UdpClient.Active := True;
      UdpClient.Host := IpList[i];
      UdpClient.Port := UdpPort_Broadcast;
      UdpClient.Send( MsgStr );
    except
    end;
    UdpClient.Free;
  end;
  IpList.Free;
end;

end.
