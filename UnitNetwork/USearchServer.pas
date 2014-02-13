unit USearchServer;

interface

uses classes, UMyNetPcInfo, UModelUtil, Sockets, UMyTcp, SysUtils, DateUtils, Generics.Collections,
     IdHTTP, UMyUrl, SyncObjs, UPortMap, uDebugLock, IdUDPServer, IdUDPClient;

type

{$Region ' �������� ���� ' }

    // ������· ����
  TSearchServerRun = class
  public
    procedure Update;virtual;abstract;
    function getRunNetworkStatus : string;virtual;
  end;

  {$Region ' ������ ' }

    // ��ʱ ����δ���ӵ� Pc
  TLanSearchPcThread = class( TDebugThread )
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure SearchPcHandle;
  end;

    // ���� ������ �ķ�����
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

    // ���㲥������
  SendBroadcastUtil = class
  public
    class procedure SendMsg( MsgStr : string );
  end;

  {$EndRegion}

  {$Region ' Group ���� ' }

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

      // ���͹�˾������
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

    // �ҵ� һ�� Standard Pc
  TStandardPcAddHanlde = class
  private
    StandardPcInfo : TStandardPcInfo;
  public
    constructor Create( _StandardPcInfo : TStandardPcInfo );
    procedure Update;
  end;

    // ���� Account Name �ķ�����
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

  {$Region ' ֱ������ ' }

   // ��ʱ �������� ����ָ�� Pc
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

    // ���� Internet Pc �ķ�����
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

{$Region ' ���� Master �߳� ' }

    // ���ӷ���������
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

    // ��ȡ Internet �˿���Ϣ
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

      // ȷ��������Ϣû�г�ͻ�� ��ͻ���޸�
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
  private      // ��ȡ Internet Ip �Ĳ�ͬ���
    function FindRouterInternetIp: string;
    function FindWebInternetIp: string;
  end;

    // ��������������
  TSearchServerRunCreate = class
  public
    function get : TSearchServerRun;
  public
    function getLan : TLanSearchServer;
    function getGroup : TGroupSearchServer;
    function getConnToPc : TConnToPcSearchServer;
  end;

    // ��ʱ�� Api
  MySearchMasterTimerApi = class
  public
    class procedure CheckRestartNetwork;
    class procedure MakePortMapping;
  end;

    // ���� ������
  TMasterThread = class( TDebugThread )
  private
    PortMapping : TPortMapping;
    SearchServerRun : TSearchServerRun; // ��������
    RunNetworkStatus : string; // ��������״̬
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

    // ��������������
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

    // Standard Network Http ��������
  Cmd_Login = 'login';
  Cmd_HeartBeat = 'heartbeat';
  Cmd_ReadLoginNumber = 'readloginnumber';
  Cmd_AddServerNumber = 'addservernumber';
  Cmd_ReadServerNumber = 'readservernumber';
  Cmd_Logout = 'logout';

    // Standard Network Http ����
  HttpReq_CompanyName = 'CompanyName';
  HttpReq_Password = 'Password';
  HttpReq_PcID = 'PcID';
  HttpReq_PcName = 'PcName';
  HttpReq_LanIp = 'LanIp';
  HttpReq_LanPort = 'LanPort';
  HttpReq_InternetIp = 'InternetIp';
  HttpReq_InternetPort = 'InternetPort';
  HttpReq_CloudIDNumber = 'CloudIDNumber';

    // Login ���
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

  WaitTime_PortMap = 10; // ����

  AdvanceMsg_NotServer = 'NotServer'; // �Ƿ�����

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

    // �������, ��������
    // ������ Server
    // ������ �Ƚ�ֵ���
  if not MySearchMasterHandler.getIsRun or
     MyClient.IsConnServer or
     ( MasterInfo.MaxPcID <> PcInfo.PcID )
  then
    Exit;

    // ��Ϊ������
  MyServer.BeServer;

    // ֪ͨ�Ѽ����Pc ���� Master
  ActivatePcList := MyNetPcInfoReadUtil.ReadActivatePcList;
  for i := 0 to ActivatePcList.Count - 1 do
  begin
    MasterConnClientInfo := TMasterConnClientInfo.Create( ActivatePcList[i] );
    MyMasterSendHandler.AddMasterSend( MasterConnClientInfo );
  end;

    // ֻ�б��� �� û�б��ر��ݣ� ����ʾû������ Pc
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

    // ����
  if not MySearchMasterHandler.getIsRun then
    Exit;

    // �������������
  if RunNetworkStatus <> RunNetworkStatus_OK then
  begin
    Result := True;
    NetworkConnStatusShowApi.SetNotConnected;
    Exit;
  end;

    // ���δ���ӣ�������
  if not MyClient.IsConnServer then
  begin
      // ��ȡ Master ��Ϣ
    ServerPcID := MasterInfo.MaxPcID;
    ServerIp := MyNetPcInfoReadUtil.ReadIp( ServerPcID );
    ServerPort := MyNetPcInfoReadUtil.ReadPort( ServerPcID );

      // ���� Master
    ConnServerHandle := TConnServerHandle.Create( ServerIp, ServerPort );
    ConnServerHandle.Update;
    ConnServerHandle.Free;
  end;

    // ���ӳɹ�����ʾ������
  if MyClient.IsConnServer then
  begin
    Result := True;
    NetworkConnStatusShowApi.SetConnected;
  end;

    // ���ӵĹ����жϿ�����
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

    // �Ͽ��ͻ�������
  MyClient.ClientLostConn;

    // �Ͽ�����������
  MyServer.ServerLostConn;

    // ֹͣ��ʱ��������
  MyTimerHandler.RemoveTimer( HandleType_RestartNetwork );

    // ֹͣ��������
  SearchServerRun.Free;

    // ֹͣ�����˿�
  MyListener.StopListen;

    // ֹͣ�˿�ӳ��
  MyTimerHandler.RemoveTimer( HandleType_PortMapping );
  PortMapping.RemoveMapping( PcInfo.InternetPort );
  PortMapping.Free;

    // ��ʾδ����
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
      // ��ʼ��
    ResetNetworkPc;

      // ��������
    RunNetwork;

      // �ȴ� ������ Pc ������Ϣ
    WaitPingMsg;

      // ��Ϊ������
    BeServer;

      // �ȴ� Server ֪ͨ
    WaitServerNotify;

      // ���ӷ������ɹ�, �����߳�
    if ConnServer then
      Suspend;

      // ֹͣ��������
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

    // ��������
  MySearchMasterHandler.IsConnecting := True;

    // ��ʾ��������
  NetworkConnStatusShowApi.SetConnecting;

    // ���Ըı�����״̬
  NetworkConnStatusShowApi.SetCanChangeNetwork;

    // �˿�ӳ��
  PortMapping := TPortMapping.Create;
  ConfirmNetworkInfoHandle := TConfirmNetworkInfoHandle.Create( PortMapping );
  ConfirmNetworkInfoHandle.Upate;
  ConfirmNetworkInfoHandle.Free;
  PortMapping.AddMapping( PcInfo.LanIp, PcInfo.InternetPort );
  MyTimerHandler.AddTimer( HandleType_PortMapping, 600 );

    // ���÷�������Ϣ
  NetworkAccountApi.SetIpInfo( PcInfo.LanIp, PcInfo.LanPort, PcInfo.InternetIp, PcInfo.InternetPort );

    // ��ʼ����
  MyListener.StartListenLan( PcInfo.LanPort );
  MyListener.StartListenInternet( PcInfo.InternetPort );

    // ��ʾ��Ϣ���ҵ�״̬
  MyNetworkStatusApi.SetLanSocket( PcInfo.LanIp, PcInfo.LanPort );
  MyNetworkStatusApi.SetInternetSocket( PcInfo.InternetIp, PcInfo.InternetPort );

    // ��������
  SearchServerRunCreate := TSearchServerRunCreate.Create;
  SearchServerRun := SearchServerRunCreate.get;
  SearchServerRunCreate.Free;
  SearchServerRun.Update;
  RunNetworkStatus := SearchServerRun.getRunNetworkStatus;

    // ��ʱ�����޷����ӵ�����, ʮ����
  MyTimerHandler.AddTimer( HandleType_RestartNetwork, 600 );
end;

procedure TMasterThread.ResetNetworkPc;
var
  NetworkPcResetHandle : TNetworkPcResetHandle;
begin
    // ���� Pc ��Ϣ
  NetworkPcResetHandle := TNetworkPcResetHandle.Create;
  NetworkPcResetHandle.Update;
  NetworkPcResetHandle.Free;

    // ���� Master ��Ϣ
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
      // �ȴ�ʱ��������� û�з��� �� ��������
    if ( WaitSecond >= WaitTime ) and
       not MyMasterSendHandler.getIsRuning and
       not MyMasterReceiveHanlder.getIsRuning
    then
      Break;

    Sleep( 100 );
    inc( Count );
    if Count = 10 then
    begin
      NetworkConnStatusShowApi.SetConnecting; // ��ʾ��������
      Count := 0;
      inc( WaitSecond );
    end;
  end;
end;

procedure TMasterThread.WaitPingMsg;
begin
    // �ȴ� ���������� Pc ������Ϣ
  WaitMaster( WaitTime_Ping );
end;

procedure TMasterThread.WaitServerNotify;
begin
    // �ȴ� Master ����
  WaitMaster( WaitTime_ServerNofity );
end;


{ TLanSearchServer }

constructor TLanSearchServer.Create;
begin
    // ���� udp Server
  UdpServer := TIdUDPServer.Create( nil );
  with UdpServer.Bindings.Add do
  begin
    IP := '0.0.0.0';
    Port := UdpPort_Broadcast;
  end;
  UdpServer.OnUDPRead := MyMasterReceiveHanlder.udpServerUDPRead;
  UdpServer.Active := True;

    // ��ʱ�����߳�
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

    // ��ʾ�� �ҵ�����״̬
  MyNetworkStatusApi.LanConnections;
  MyNetworkStatusApi.SetBroadcastPort( IntToStr( UdpPort_Broadcast ), BindSocketReuslt );

    // ���͹㲥��Ϣ
  SendBroadcast;

    // ��������� Pc
  ConnectSearchPc;
end;

{ TStandSearchServer }

procedure TGroupSearchServer.AccountNameNotExit;
var
  ErrorStr : string;
begin
    // ��ʾ������ʾ��
  ErrorStr := Format( ShowForm_CompanyNameError, [GroupName] );
  MyMessageBox.ShowError( ErrorStr );

    // ����������Ϣ
  NetworkModeApi.AccountNotExist( GroupName, Password );

    // ��������ʾ
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

    // ��¼
  FindStandardNetworkHttp := TFindStandardNetworkHttp.Create( GroupName, Password );
  FindStandardNetworkHttp.SetCmd( Cmd_Login );
  HttpStr := FindStandardNetworkHttp.get;
  FindStandardNetworkHttp.Free;

    // �������� �Ͽ�
  RunNetworkStatus := RunNetworkStatus_OK;
  if HttpStr = LoginResult_ConnError then
  else  // �ʺŲ�����
  if HttpStr = LoginResult_CompanyNotFind then
  begin
    RunNetworkStatus := RunNetworkStatus_GroupNotExist;
    AccountNameNotExit;
  end
  else   // �������
  if HttpStr = LoginResult_PasswordError then
  begin
    RunNetworkStatus := RunNetworkStatus_GroupPassowrdError;
    PasswordError;
  end
  else
  begin   // ��¼�ɹ�
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
    // ��ʾ��ʾ��
  MyMessageBox.ShowError( ShowForm_PasswordError );

    // ������д Group ��Ϣ
  NetworkModeApi.PasswordError( GroupName );

    // ��������ʾ
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

    // ��ʾ�� �ҵ�����״̬
  MyNetworkStatusApi.GroupConnections( GroupName );
  MyNetworkStatusApi.SetBroadcastDisable;

    // ��¼ Group �Ƿ�ɹ�
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
    // ��ȡ�Է����͵������
  RandomNumber := MySocketUtil.RevJsonStr( TcpSocket );

    // ��ȡ������ Security ID
  CloudIdStr := CloudSafeSettingInfo.getCloudIDNumMD5;
  if CloudIdStr = '' then  // ��ֵ���������ַ�����
    CloudIdStr := CloudIdNumber_Empty;

    // ��Ϻͼ���
  CloudIdStr := RandomNumber + CloudIdNumber_Split + CloudIdStr;
  CloudIdStr := CloudIdStr + CloudIdNumber_Split + MyRegionUtil.ReadRemoteTimeStr( Now );
  CloudIdStr := MyEncrypt.EncodeStr( CloudIdStr );

    // ���� ID
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_SecurityID, CloudIdStr );

    // ��ȡ���ؽ��
  CloudIdNumberResult := MySocketUtil.RevJsonStr( TcpSocket );

    // �Ƿ�ɹ�ƥ��
  Result := CloudIdNumberResult = CloudIdNumberResult_OK;
end;

procedure TConnToPcSearchServer.CloudIDNumberError;
var
  ErrorType, ErrorStr, ShowError : string;
begin
    // �Է�û������ Security ID������������
  if CloudIdNumberResult = CloudIdNumberResult_NotSet then
  begin
    ErrorType := SecurityIDError_MySet;
    ErrorStr := SecurityIDErrorShowStr_MySet;
  end
  else  // �Է������� Security ID������û������
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

    // ��ʾ����
  ShowError := Format( ErrorStr, [Domain + ':' + Port] );
  MyMessageBox.ShowWarnning( ShowError );

    // �������� Cloud ID
  NetworkModeApi.CloudIDError;

    // ��������ʾ
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

    // ���� Pc
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

    // Զ�̷�æ, 1 ���������
  if IsBusy then
  begin
    WaitToConn( WaitTime_AdvanceBusy );
    if MySearchMasterHandler.getIsRun then
      Result := ConnTargetPc;
  end;

    // Ŀ�� Pc ����
  if not Result then
  begin
    NetworkErrorStatusApi.ShowCannotConn( Domain, Port );  // ��ʾ �޷�����
    RestartConnectToPcThread.RunRestart;  // ������ʱ����
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

    // �������Ip
  if MyParseHost.IsIpStr( Domain ) then
  begin
    Ip := Domain;
    Exit;
  end;

    // �������ͳɹ�
  if MyParseHost.HostToIP( Domain, Ip ) then
    Exit;

    // ��������ʧ��
  NetworkErrorStatusApi.ShowIpError( Domain, Port ); // ��ʾʧ����Ϣ
  RestartConnectToPcThread.RunRestart;  // ��ʱ��������
  Result := False;
end;

function TConnToPcSearchServer.getIsConnectToCS: Boolean;
var
  RemoteIsServer : Boolean;
begin
  Result := False;

    // ���նԷ��Ƿ������
  RemoteIsServer := MySocketUtil.RevJsonBool( TcpSocket );
  if not RemoteIsServer then
    Exit;

    // ����
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

    // 5 ���������
  WaitToConn( WaitTime_AdvanceNotServer );

    // �������
  if not MySearchMasterHandler.getIsRun then
    Exit;

    // ������һ��
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
    // ��ȡ��Ϣ
  ServerPcID := MySocketUtil.RevData( TcpSocket );
  ServerPcName := MySocketUtil.RevData( TcpSocket );
  ServerLanIp := MySocketUtil.RevData( TcpSocket );
  ServerLanPort := MySocketUtil.RevData( TcpSocket );
  ServerInternetIp := MySocketUtil.RevData( TcpSocket );
  ServerInternetPort := MySocketUtil.RevData( TcpSocket );

    // ��ӷ�������Ϣ
  NetworkPcApi.AddItem( ServerPcID, ServerPcName );
end;

procedure TConnToPcSearchServer.SendMyPcInfo;
begin
    // ������Ϣ
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

    // ��ʾ�� �ҵ�����״̬
  MyNetworkStatusApi.ConnToPcConnections( Domain + ':' + Port );
  MyNetworkStatusApi.SetBroadcastDisable;

    // Ĭ�ϳɹ�
  RunNetworkStatus := RunNetworkStatus_OK;

    // Ip ���ʹ���
  if not FindIp then
  begin
    RunNetworkStatus := RunNetworkStatus_IpError;
    Exit;
  end;

    // ���ӱ���
  PingMyPc;

    // �޷�����Զ�� Pc
  if not ConnTargetPc then
  begin
    RunNetworkStatus := RunNetworkStatus_NotConn;
    Exit;
  end;

    // ����Ƿ�ͬһ����
  if not CheckCloudIDNumber then
  begin
    RunNetworkStatus := RunNetworkStatus_SecurityError;
    CloudIDNumberError; // ������ͬ������
    Exit;
  end;

    // Ŀ���Ƿ������ӷ�����
  IsConnectServer := MySocketUtil.RevBoolData( TcpSocket );
  if not IsConnectServer then
  begin
    NotConnServer;  // �ȴ� 5 �������
    Exit;
  end;

    // ֱ�����ӵ�������
  if getIsConnectToCS then
  begin
    IsDestorySocket := False; // �˿������� CS
    Exit;
  end;

    // ���շ�������Ϣ
  RevServerPcInfo;

    // ���ͱ�����Ϣ���������������
  SendMyPcInfo;

    // �ȴ����������ӣ����������û�����ӣ����������ӷ�����
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
      // �ȴ�ʱ�����
    if WaitSecond >= WaitTime_ServerNofity then
      Break;

    Sleep( 100 );
    inc( Count );
    if Count = 10 then
    begin
      NetworkConnStatusShowApi.SetConnecting; // ��ʾ��������
      Count := 0;
      inc( WaitSecond );
    end;
  end;

    // ������� �� �����ӷ�����
  if not MySearchMasterHandler.getIsRun or MyClient.IsConnServer then
    Exit;

    // ���� Ping ����
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
      // �ȴ�ʱ�����
    if WaitSecond >= WaitTime then
      Break;

    Sleep( 100 );
    inc( Count );
    if Count = 10 then
    begin
      NetworkConnStatusShowApi.SetConnecting; // ��ʾ��������
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
    // �� ·��/��վ ��ȡ Internet IP
  if PortMapping.IsPortMapable then
    IsFindIp := FindRouterInternetIp
  else
    IsFindIp := FindWebInternetIp;

    // û���ҵ� InternetIp, ���� LanIp ����
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
    // ��ʾ�� Setting ����
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
    // ������Ϣ
  PcID := PcInfo.PcID;
  PcName := PcInfo.PcName;
  LanIp := PcInfo.LanIP;
  LanPort := PcInfo.LanPort;
  InternetIp := PcInfo.InternetIp;
  InternetPort := PcInfo.InternetPort;
  CloudIDNumber := CloudSafeSettingInfo.getCloudIDNumMD5;

    // ��¼����ȡ���� Pc ��Ϣ
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
    // ���� �� Server
  if not MyServer.IsBeServer then
    Exit;

    // ���пͻ�������
  if MyServer.ClientCount > 1 then
    Exit;

    // �Ƿ��һ��
  if LastServerNumber = -1 then
    Cmd := Cmd_AddServerNumber
  else
    Cmd := Cmd_ReadServerNumber;

    // Login Number
  FindStandardNetworkHttp := TFindStandardNetworkHttp.Create( AccountName, Password );
  FindStandardNetworkHttp.SetCmd( Cmd );
  ServerNumber := StrToIntDef( FindStandardNetworkHttp.get, 0 );
  FindStandardNetworkHttp.Free;

    // ��һ��
  if LastServerNumber = -1 then
  begin
    LastServerNumber := ServerNumber;
    Exit;
  end;

    // ���ϴ�����ͬ
  if LastServerNumber = ServerNumber then
    Exit;

    // ��������
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
      // 5 ���� ����һ������
    if MinutesBetween( Now, StartHearBeat ) >= 5 then
    begin
      SendHeartBeat;
      StartHearBeat := Now;
    end;
      // 10 ���� ���һ���ʺ�
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
    // ����
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
    // ��� Pc ��Ϣ
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
    // ��ʼʱ��
  StartTime := Now;

    // ��ʾʣ��ʱ��
  ShowRemainTime;

    // �����߳�
  Resume;
end;

procedure TRestartConnectToPcThread.ShowRemainTime;
var
  RemainTime : Integer;
begin
    // ����ʣ��ʱ��
  RemainTime := 300 - SecondsBetween( Now, StartTime );

    // ��ʾʣ��ʱ��
  NetworkErrorStatusApi.ShowConnAgainRemain( RemainTime );

    // ��������
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

    // �������Ӵ�����Ϣ
  NetworkErrorStatusApi.HideError;

    // ��ʱ���ܸı�����
  NetworkConnStatusShowApi.SetNotChangeNetwork;

    // ��������
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

    // �����Ƿ����ӳɹ�
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
      // 20 ���� ���һ������
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
    // ���Ƿ�����
  if not MyServer.IsBeServer then
    Exit;

  CloudIDNumMD5 := CloudSafeSettingInfo.getCloudIDNumMD5;

      // ��ȡ �㲥��Ϣ
  LanBroadcastMsg := TLanBroadcastMsg.Create;
  LanBroadcastMsg.SetPcID( PcInfo.PcID );
  LanBroadcastMsg.SetPcName( PcInfo.PcName );
  LanBroadcastMsg.SetSocketInfo( PcInfo.LanIp, PcInfo.LanPort );
  LanBroadcastMsg.SetCloudIDNumMD5( CloudIDNumMD5 );
  LanBroadcastMsg.SetBroadcastType( BroadcastType_SearchPc );
  MsgStr := LanBroadcastMsg.getMsgStr;
  LanBroadcastMsg.Free;

    // �㲥��Ϣ�İ汾
  MsgType := IntToStr( ConnEdition_Now );

    // ��װ �㲥��Ϣ
  MsgInfo := TMsgInfo.Create;
  MsgInfo.SetMsgInfo( MsgType, MsgStr );
  Msg := MsgInfo.getMsg;
  MsgInfo.Free;

    // ���� �㲥��Ϣ
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

      // ��ȡ �㲥��Ϣ
  LanBroadcastMsg := TLanBroadcastMsg.Create;
  LanBroadcastMsg.SetPcID( PcInfo.PcID );
  LanBroadcastMsg.SetPcName( PcInfo.PcName );
  LanBroadcastMsg.SetSocketInfo( PcInfo.LanIp, PcInfo.LanPort );
  LanBroadcastMsg.SetCloudIDNumMD5( CloudIDNumMD5 );
  LanBroadcastMsg.SetBroadcastType( BroadcastType_StartLan );
  MsgStr := LanBroadcastMsg.getMsgStr;
  LanBroadcastMsg.Free;

    // �㲥��Ϣ�İ汾
  MsgType := IntToStr( ConnEdition_Now );

    // ��װ �㲥��Ϣ
  MsgInfo := TMsgInfo.Create;
  MsgInfo.SetMsgInfo( MsgType, MsgStr );
  Msg := MsgInfo.getMsg;
  MsgInfo.Free;

    // ���͹㲥
  SendBroadcastUtil.SendMsg( Msg );
end;

procedure TLanSearchServer.ConnectSearchPc;
var
  SearchPcName, SearchIp, SearchPort : string;
  MasterSendLanPingInfo : TMasterSendLanPingInfo;
begin
  if SearchPcID = '' then
    Exit;

   // ��ȡ Pc ��Ϣ
  SearchPcName := MyNetPcInfoReadUtil.ReadName( SearchPcID );
  SearchIp := MyNetPcInfoReadUtil.ReadIp( SearchPcID );
  SearchPort := MyNetPcInfoReadUtil.ReadPort( SearchPcID );

  if ( SearchIp = '' ) or ( SearchPort = '' ) then
    Exit;

    // ��� Pc ��Ϣ
  NetworkPcApi.AddItem( SearchPcID, SearchPcName );

    // ���� Ping
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

     // ��·�� ��ȡ Internet IP
  if PortMapping.IsPortMapable then
    InternetIp := FindRouterInternetIp;

    // ����վ ��ȡ Internet Ip
  if InternetIp = '' then
    InternetIp := FindWebInternetIp;

    // û���ҵ� InternetIp, ���� LanIp ����
  if InternetIp = '' then
    InternetIp := PcInfo.LanIp;

    // ���� Internet Ip ��Ϣ
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
      // �˿ڿ��������
    if MyTcpUtil.getPortAvaialble( Port ) then
      Break;
    inc( Port );
  end;

    // �˿ںŲ���ͬ, ����˿ں�
  if PcInfo.InternetPort <> IntToStr( Port ) then
    MyPcInfoApi.SetInternetPort( IntToStr( Port ) );
end;

procedure TConfirmNetworkInfoHandle.ConfirmInternetPortMap;
var
  InternetPort, i : Integer;
  IsPortMap : Boolean;
begin
    // ������ʾӳ�����
  MyNetworkStatusApi.SetIsExistUpnp( PortMapping.IsPortMapable, PortMapping.controlurl );

    // ���ɶ˿�ӳ��
  if not PortMapping.IsPortMapable then
    Exit;

    // ���ӳ��˿��Ƿ�ռ��
  IsPortMap := False;
  InternetPort := StrToIntDef( PcInfo.InternetPort, 26954 );
  for i := 0 to 100 do
  begin
      // �˿�ӳ��ɹ�
    if PortMapping.AddMapping( PcInfo.LanIp, IntToStr( InternetPort ) ) then
    begin
      IsPortMap := True;
      Break;
    end;

      // ����˿ڱ�ռ����ʹ����һ���˿�
    inc( InternetPort );
  end;

    // �Ƿ�ӳ��ɹ�
  MyNetworkStatusApi.SetIsPortMapCompleted( IsPortMap );

    // �������µĶ˿�
  if PcInfo.InternetPort <> IntToStr( InternetPort ) then
    MyPcInfoApi.SetInternetPort( IntToStr( InternetPort ) );
end;

procedure TConfirmNetworkInfoHandle.ConfirmLanIp;
var
  IpList : TStringList;
  TempLanIp : string;
begin
  IpList := MyIpList.get;
  if IpList.IndexOf( PcInfo.RealLanIp ) < 0 then // ָ���� Ip ������
  begin
    if IpList.Count > 0 then
    begin
      TempLanIp := IpList[0];
      MyPcInfoApi.SetTempLanIp( TempLanIp ); // ���� ��ʱ Ip
    end;
  end
  else
  if PcInfo.RealLanIp <> PcInfo.LanIp then   // ���� Ip
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
      // �˿ڿ��������
    if MyTcpUtil.getPortAvaialble( Port ) then
      Break;
    inc( Port );
  end;

    // �˿ںŲ���ͬ, ����˿ں�
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
    // ���ܻ�ȡʧ�ܣ���ȡ 5 ��
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

    // ������Ϊ����ԭ���ȡʧ�ܣ� ��ȡ 5 ��
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

      // �ɹ���ȡ Ip
    if IsFind then
      Break;

    Sleep(100);
  end;
end;

procedure TConfirmNetworkInfoHandle.Upate;
begin
  DebugLock.Debug( 'Confirm Network' );

    // �������˿���Ϣ
  ConfirmLanIp;
  ConfirmLanPort;

    // �������˿���Ϣ
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

    // ���� Ŀ�� Pc
  MyTcpConn := TMyTcpConn.Create( TcpSocket );
  MyTcpConn.SetConnSocket( ServerIp, ServerPort );
  MyTcpConn.SetConnType( ConnType_Server );
  IsConnectServer := MyTcpConn.Conn;
  MyTcpConn.Free;

    // ����ʧ��
  if not IsConnectServer then
    Exit;

    // ��ȡ�Է��Ƿ� Pc
  IsServer := MySocketUtil.RevBoolData( TcpSocket );
  if not IsServer then
    Exit;

    // ���ͱ�����ʶ
  MySocketUtil.SendData( TcpSocket, PcInfo.PcID );

    // �Ƿ���ڿͻ���
  IsExistClient := StrToBoolDef( MySocketUtil.RevData( TcpSocket ), False );
  if IsExistClient then // �Ѵ��ڿͻ���
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

    // ���ӷ�����
  if ConnServer then
    MyClient.ConnectServer( TcpSocket )
  else  // ����ʧ��
    TcpSocket.Free;
end;

{ MySearchMasterTimerApi }

class procedure MySearchMasterTimerApi.CheckRestartNetwork;
begin
  if not MySearchMasterHandler.IsRun then
    Exit;

    // �Ƿ�����
  if not MyServer.IsBeServer then
    Exit;

    // �ж���ͻ���
  if MyServer.ClientCount > 1 then
    Exit;

    // ���ڱ�������
  if DesItemInfoReadUtil.ReadIsExistLocalBackup then
    Exit;

    // ��������
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
    // ���͹㲥
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
