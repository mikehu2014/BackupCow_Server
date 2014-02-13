unit UMyTcp;

interface

uses classes, sockets, UMyUtil, Windows, WinSock, UChangeInfo, SysUtils, DateUtils, uDebug,
     uDebugLock, Generics.Collections, SyncObjs, math;

type

    // ����
  TListenThread = class( TDebugThread )
  private
    ListenSocket : TCustomTcpServer;
  public
    constructor Create( ListenPort : string );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure AcceptSocket( TcpSocket : TCustomIpClient );
  end;

    // Tcp ������Ϣ
  TTcpConnInfo = class( TMsgBase )
  private
    iConnEdiiton : Integer;
    iConnType : string;
  published
    property ConnEdiiton : Integer Read iConnEdiiton Write iConnEdiiton;
    property ConnType : string Read iConnType Write iConnType;
  public
    procedure SetConnInfo( _ConnEdiiton : Integer; _ConnType : string );
  public
    function getMsgType : string;override;
  end;

    // ��� һ��ʱ�������Ӷ˿�ʧ�ܣ���Ͽ�����
  TDisConnThread = class( TDebugThread )
  private
    TcpSocket : TCustomIpClient;
  public
    constructor Create( _TcpSocket : TCustomIpClient );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  end;

    // ����
  TMyTcpConn = class
  private
    TcpSocket : TCustomIpClient;
    ConnTime : Integer;
  private
    ConnEdiiton : Integer;
    ConnType : string;
  public
    constructor Create( _TcpSocket : TCustomIpClient );
    procedure SetConnSocket( Ip, Port : string );
    procedure SetConnType( _ConnType : string );
    function Conn : Boolean;
  private
    function ConnTarget : Boolean;
    function SocketConn : Boolean;
    function CheckConnSuccess : Boolean;
  private
    procedure RemoveEditionError;
    procedure ConnEditionError( IsNewEdition : Boolean );
  end;

{$Region ' �������� ' }

    // ���ݽṹ
  TTcpAcceptInfo = class
  public
    TcpSocket : TCustomIpClient;
  public
    constructor Create( _TcpSocket : TCustomIpClient );
  end;
  TTcpAcceptList = class( TObjectList<TTcpAcceptInfo> )end;

    // ����
  TAcceptSocketHandle = class
  public
    TcpAcceptInfo : TTcpAcceptInfo;
    TcpSocket : TCustomIpClient;
  public
    constructor Create( _TcpAcceptInfo : TTcpAcceptInfo );
    procedure Update;
  private
    function HandleConn( ConnType : string ): Boolean;
  private
    procedure SignupHandle;
    procedure RemoveEditionError;
    procedure ConnEditionError( IsNewEdition : Boolean );
  end;

    // ���������߳�
  THandleListenThread = class( TDebugThread )
  public
    constructor Create;
  protected
    procedure Execute; override;
  private
    procedure Handle( TcpAcceptInfo : TTcpAcceptInfo );
  end;
  THandleListenThreadList = class( TObjectList<THandleListenThread> )end;

{$EndRegion}

{$Region ' C/S ���� ' }



{$EndRegion}

  MySocketUtil = class
  public
    class function RevBuf( TcpSocket : TCustomIpClient; var Buf; BufSize: Integer ) : Integer;
    class function RevData( TcpSocket : TCustomIpClient; WaitTime : Integer ): string;overload;
    class function RevData( TcpSocket : TCustomIpClient ): string;overload;
    class function RevIntData( TcpSocket : TCustomIpClient ): Integer;
    class function RevInt64Data( TcpSocket : TCustomIpClient ): Int64;
    class function RevBoolData( TcpSocket : TCustomIpClient ): Boolean;
  public
    class function SendData( TcpSocket : TCustomIpClient; MsgStr : string ): Boolean;overload;
    class function SendData( TcpSocket : TCustomIpClient; MsgStr : Integer ): Boolean;overload;
    class function SendData( TcpSocket : TCustomIpClient; MsgStr : Int64 ): Boolean;overload;
    class function SendData( TcpSocket : TCustomIpClient; MsgStr : Boolean ): Boolean;overload;
  public
    class function RevString( TcpSocket : TCustomIpClient ): string;
    class function SendString( TcpSocket : TCustomIpClient; MsgStr : string ): Integer;
  private
    class function RevBigStr( TcpSocket : TCustomIpClient ): string;
    class function SendBigStr( TcpSocket : TCustomIpClient; MsgStr : string ): Integer;
  public
    class function SendJsonStr( TcpSocket : TCustomIpClient; MsgType, MsgStr : string ): Boolean;overload;
    class function SendJsonStr( TcpSocket : TCustomIpClient; MsgType : string; MsgStr : Boolean ): Boolean;overload;
    class function SendJsonStr( TcpSocket : TCustomIpClient; MsgType : string; MsgStr : Int64 ): Boolean;overload;
    class function SendJsonStr( TcpSocket : TCustomIpClient; MsgType : string; MsgStr : Integer ): Boolean;overload;
  public
    class function RevJsonStr( TcpSocket : TCustomIpClient ) : string;
    class function RevJsonBool( TcpSocket : TCustomIpClient ) : Boolean;
    class function RevJsonInt64( TcpSocket : TCustomIpClient ) : Int64;
    class function RevJsonInt( TcpSocket : TCustomIpClient ) : Integer;
  public
    class function ReadMsgToMsgStr( Msg : string ): string;
  end;

    // ���ӳ�
  TMyListener = class
  private
    IsRun : Boolean;
  private  // �����߳�
    ListenLanThread : TListenThread;
    ListenInternetThread : TListenThread;
  private  // �������
    DataLock : TCriticalSection;
    TcpAcceptList : TTcpAcceptList;
  private  // ����������
    ThreadLock : TCriticalSection;
    HandleListenThreadList : THandleListenThreadList;
  public
    constructor Create;
    procedure StopRun;
    destructor Destroy; override;
  public
    procedure StartListenLan( Port : string );
    procedure StartListenInternet( Port : string );
    procedure StopListen;
  public
    procedure AddTcpAccept( TcpAcceptInfo : TTcpAcceptInfo );
    function getTcpAccept : TTcpAcceptInfo;
    procedure RemoveThread( ThreadID : Cardinal );
  end;

  MyTcpUtil = class
  public
    class function getPortAvaialble( Port : Integer ): Boolean;
    class function TestConnect( Ip, Port : string ): Boolean;
  end;

const
  ConnResult_OK = 'OK';
  ConnResult_Error = 'Error';
  ConnResult_NewEiditon = 'NewEditiion';

  ConnEdition_Now = 25;
  ConnType_SearchServer = 'SearchServer';
  ConnType_Server = 'Server';
  ConnType_Client = 'Client';
  ConnType_CloudFileRequest = 'CloudFileRequest';
  ConnType_Backup = 'Backup';
  ConnType_Restore = 'Restore';
  ConnType_TestConn = 'TestConn';
  ConnType_AccountSignup = 'AccountSignup';

  WaitTime_Accept = 5;   // 5 ���� Accept
  WaitTime_RevData = 60; // 1 ����
  WaitTime_RevClient = 600; // 10 ����
  WaitTime_RecycleFolder = 600;

  ThreadCount_Conn : Integer = 10;
  ConnTime_Client : Integer = 20;

  BigMarkStart_RevStr = '</FolderTransfer_Big_Mark_RevStr_Start>';
  BigMarkStop_RevStr = '</FolderTransfer_Big_Mark_RevStr_Stop>';

const
  MsgType_TcpConnect = 'TcpConnect';

const    // Connect to computer
  JsonMsgType_ConnResult = 'ConnResult';
  JsonMsgType_ConnEdition = 'ConnEdition';
  JsonMsgType_PcID_Enter = 'PcID_Enter';
  JsonMsgTYpe_PcID_Connect = 'PcID_Connect';
  JsonMsgType_PcID_Check = 'PcID_Check';
  JsonMsgType_PcIDConfirm = 'PcIDConfirm';
  JsonMsgType_IsBusy = 'IsBusy';
  JsonMsgType_SearchServerType = 'SearchServerType';
  JsonMsgType_RandomNumStr = 'RandomNumStr';
  JsonMsgType_SecurityID = 'SecurityID';
  JsonMsgType_SecurityIDResult = 'SecurityIDResult';
  JsonMsgType_IsConnectToServer = 'IsConnectToServer';
  JsonMsgType_IsConnectToServer_Confirm = 'IsConnectToServer_Confirm';
  JsonMsgType_IsServer = 'IsServer';
  JsonMsgType_IsServer_Confirm = 'IsServer_Confirm';
  JsonMsgType_IsExistClient = 'IsExistClient';

const
  JsonMsgType_IsCloudBusy = 'IsCloudBusy';
  JsonMsgType_CloudPath = 'CloudPath';
  JsonMsgType_PcID_Cloud = 'PcID_Cloud';
  JsonMsgType_SourcePath = 'SourcePath';
  JsonMstType_CloudAccessResult = 'CloudAccessResult';
  JsonMsgType_CloudReqType = 'CloudReqType';
  JsonMsgType_FileReq = 'FileReq';
  JsonMsgType_FilePath = 'FilePath';
  JsonMsgType_IsDeleted = 'IsDeleted';
  JsonMsgType_FilePosition = 'FilePosition';
  JsonMsgType_FileSize = 'FileSize';

const
  JsonMsgType_IsExistFile = 'IsExistFile';

const
  JsonMsgType_IsCreateReadSuccess = 'IsCreateReadSuccess';
  JsonMsgType_ReadFileSize = 'ReadFileSize';
  JsonMsgType_ReadFilePos = 'ReadFilePos';
  JsonMsgType_IsEnouthSpace = 'IsEnouthSpace';
  JsonMsgType_IsWriteSuccess = 'IsCreateWriteSuccess';
  JsonMsgType_FileTime = 'FileTime';
  JsonMsgType_IsZipFile = 'IsZipFile';

const
  JsonMsgType_FileReadStatus = 'FileReadStatus';
  JsonMsgType_FileReadSize = 'FileReadSize';
  JsonMsgType_FileSendSize = 'FileSendSize';
  JsonMsgType_SendFileSizeNow = 'SendFileSizeNow';
  JsonMsgType_SendFileCompletedNow = 'SendFileCompletedNow';
  JsonMsgType_ReceiveStatus = 'ReceiveStatus';
  JsonMsgType_ReceiveSpeed = 'ReceiveSpeed';
  JsonMsgType_FileWriteSize = 'FileWriteSize';
  JsonMsgType_IsDeep = 'IsDeep';
  JsonMsgType_IsFilter = 'IsFilter';

const
  JsonMsgType_SendPing_IsServer = 'SendPing_IsServer';
  JsonMsgType_SendPing_IsClient = 'SendPing_IsClient';
  JsonMsgType_RevPing_IsServer = 'RevPing_IsServer';
  JsonMsgType_RevPing_IsClient = 'RevPing_IsClient';

const
  JsonMsgType_FolderResponse = 'FolderResponse';

const
  JsonMsgType_SignupResult = 'SignupResult';
  SignupResult_AccountExist = 'AccountExist';
  SignupResult_AccountNotEnough = 'AccountNotEnough';
  SignupResult_Completed = 'Completed';

const
  JsonMsgType_LoginResult = 'LoginResult';
  AccountLoginResult_AccountNotExist = 'AccountNotExist';
  AccountLoginResult_PasswordError = 'PasswordError';
  AccountLoginResult_Completed = 'Completed';

const
  JsonMsgType_IsFreeLimit = 'IsFreeLimit';

const
  MsgType_SearchServer_Ping = 'Ping';
  MsgType_SearchServer_ConfirmConnect = 'ConfirmConnect';
  MsgType_SearchServer_ConnectToPc = 'ConnectToPc';

  MsgType_PcInfo = 'PcInfo';

var
  MyListener : TMyListener;
  ListenPort_Tcp : Integer = 9494;

var
  IsMark_Receive : Boolean = False;

implementation

uses UMyMaster, UMyServer, UMyNetPcInfo,
     UCloudThread, UMyClient, UBackupThread, URestoreThread, UNetworkControl, UMainFormFace, ulkJson;

{ TListenThread }

procedure TListenThread.AcceptSocket(TcpSocket: TCustomIpClient);
var
  TcpAcceptInfo : TTcpAcceptInfo;
begin
  TcpAcceptInfo := TTcpAcceptInfo.Create( TcpSocket );
  MyListener.AddTcpAccept( TcpAcceptInfo );
end;

constructor TListenThread.Create( ListenPort : string );
begin
  inherited Create;

  ListenSocket := TCustomTcpServer.Create(nil);
  ListenSocket.LocalHost := '0.0.0.0';
  ListenSocket.LocalPort := ListenPort;
  ListenSocket.Active := True;
end;

destructor TListenThread.Destroy;
begin
  Terminate;
  ListenSocket.Close;
  Resume;
  WaitFor;

  ListenSocket.Free;
  inherited;
end;

procedure TListenThread.Execute;
var
  TcpSocket : TCustomIpClient;
begin
  while not Terminated do
  begin
    TcpSocket := TCustomIpClient.Create(nil);
    if ListenSocket.Accept( TcpSocket ) then
      AcceptSocket( TcpSocket )
    else
      TcpSocket.Free;
  end;
  inherited;
end;

{ MyTcpConn }

function TMyTcpConn.CheckConnSuccess: Boolean;
var
  TcpConnInfo : TTcpConnInfo;
  MsgStr, ConnResult : string;
begin
  TcpConnInfo := TTcpConnInfo.Create;
  TcpConnInfo.SetConnInfo( ConnEdiiton, ConnType );
  MsgStr := TcpConnInfo.getMsg;
  TcpConnInfo.Free;

  MySocketUtil.SendData( TcpSocket, MsgStr );

  ConnResult := MySocketUtil.RevJsonStr( TcpSocket );

  Result := ConnResult = ConnResult_OK;

    // �汾�ò���ȷ
  if not Result then
    ConnEditionError( ConnResult = ConnResult_NewEiditon )
  else
    RemoveEditionError;
end;

function TMyTcpConn.Conn: Boolean;
begin
  Result := ConnTarget and CheckConnSuccess;
end;

function TMyTcpConn.ConnTarget: Boolean;
begin
    // ������
  if not SocketConn then
  begin
    Result := False;
    Exit;
  end;

    // ��γ��ֿ����ӣ� ���ܶ˿ڱ���������ռ��
  if ConnTime >= ConnTime_Client then
  begin
    Result := False;
    Exit;
  end;

    // ������ ������ ���Ӵ���
  if MySocketUtil.RevJsonStr( TcpSocket ) <> ConnResult_OK then
  begin
    TcpSocket.Disconnect;  // �ر�����
    Sleep( 100 );  // �ȴ�ʱ��
    Inc( ConnTime );
    Result := ConnTarget;  //������һ��
  end
  else
    Result := true;  // ���ӳɹ�
end;

constructor TMyTcpConn.Create(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
  ConnEdiiton := ConnEdition_Now;
  ConnTime := 0;
end;

procedure TMyTcpConn.RemoveEditionError;
begin
  NetworkConnEditionErrorApi.RemoveItem( TcpSocket.RemoteHost );
end;

procedure TMyTcpConn.SetConnSocket(Ip, Port: string);
begin
  TcpSocket.RemoteHost := Ip;
  TcpSocket.RemotePort := Port;
end;

procedure TMyTcpConn.SetConnType(_ConnType: string);
begin
  ConnType := _ConnType;
end;

function TMyTcpConn.SocketConn: Boolean;
var
  DisConnThread : TDisConnThread;
begin
  DisConnThread := TDisConnThread.Create( TcpSocket );
  DisConnThread.Resume;
  Result := TcpSocket.Connect;
  DisConnThread.Free;
end;

{ TTcpConnInfo }

function TTcpConnInfo.getMsgType: string;
begin
  Result := MsgType_TcpConnect;
end;

procedure TTcpConnInfo.SetConnInfo(_ConnEdiiton: Integer; _ConnType: string);
begin
  ConnEdiiton := _ConnEdiiton;
  ConnType := _ConnType;
end;

{ TMyListener }

procedure TMyListener.AddTcpAccept(TcpAcceptInfo: TTcpAcceptInfo);
var
  HandleListenThread : THandleListenThread;
begin
  if not IsRun then
    Exit;

    // ��ӵ������
  DataLock.Enter;
  TcpAcceptList.Add( TcpAcceptInfo );
  DataLock.Leave;

    // �����̲߳����򴴽�
  ThreadLock.Enter;
  if HandleListenThreadList.Count < ThreadCount_Conn then
  begin
    HandleListenThread := THandleListenThread.Create;
    HandleListenThreadList.Add( HandleListenThread );
    HandleListenThread.Resume;
  end;
  ThreadLock.Leave;
end;

constructor TMyListener.Create;
begin
  DataLock := TCriticalSection.Create;
  TcpAcceptList := TTcpAcceptList.Create;
  TcpAcceptList.OwnsObjects := False;

  ThreadLock := TCriticalSection.Create;
  HandleListenThreadList := THandleListenThreadList.Create;
  HandleListenThreadList.OwnsObjects := False;

  IsRun := True;
end;

destructor TMyListener.Destroy;
begin
  HandleListenThreadList.Free;
  ThreadLock.Free;

  TcpAcceptList.OwnsObjects := True;
  TcpAcceptList.Free;
  DataLock.Free;

  inherited;
end;

function TMyListener.getTcpAccept: TTcpAcceptInfo;
begin
  DataLock.Enter;
  if TcpAcceptList.Count > 0 then
  begin
    Result := TcpAcceptList[0];
    TcpAcceptList.Delete(0);
  end
  else
    Result := nil;
  DataLock.Leave;
end;

procedure TMyListener.RemoveThread(ThreadID: Cardinal);
var
  i: Integer;
begin
  ThreadLock.Enter;
  for i := 0 to HandleListenThreadList.Count - 1 do
    if HandleListenThreadList[i].ThreadID = ThreadID then
    begin
      HandleListenThreadList.Delete( i );
      Break;
    end;
  ThreadLock.Leave;
end;

procedure TMyListener.StartListenInternet(Port: string);
begin
  ListenInternetThread := TListenThread.Create( Port );
  ListenInternetThread.Resume;
end;

procedure TMyListener.StartListenLan(Port: string);
begin
  ListenLanThread := TListenThread.Create( Port );
  ListenLanThread.Resume;
end;

procedure TMyListener.StopRun;
var
  IsExitThread : Boolean;
begin
  IsRun := False;

    // �ȴ��߳�ȫ������
  while True do
  begin
    ThreadLock.Enter;
    IsExitThread := HandleListenThreadList.Count > 0;
    ThreadLock.Leave;

    if not IsExitThread then
      Break;

    Sleep(100);
  end;
end;

procedure TMyListener.StopListen;
begin
  ListenInternetThread.Free;
  ListenLanThread.Free;
end;

{ MySocketUtil }

class function MySocketUtil.RevBuf(TcpSocket: TCustomIpClient; var Buf;
  BufSize: Integer): Integer;
var
  StartTime, WaitDataStart : TDateTime;
begin
  Result := SOCKET_ERROR;

  StartTime := Now;
  while ( SecondsBetween( Now, StartTime ) < WaitTime_RevData ) do
  begin
    WaitDataStart := Now;
    if TcpSocket.WaitForData( 100 ) then // �ȴ�����
    begin
      Result := TcpSocket.ReceiveBuf( Buf, BufSize );
      Break;
    end
    else
    if MilliSecondsBetween( Now, WaitDataStart ) < 90 then
      Break;
  end;
end;

class function MySocketUtil.RevData(TcpSocket: TCustomIpClient): string;
var
  FormLogAddFace : TFormLogAddFace;
begin
  Result := MySocketUtil.RevData( TcpSocket, WaitTime_RevData );

    // �Ƿ��¼������Ϣ
  if not IsMark_Receive then
    Exit;

    // д log
  FormLogAddFace := TFormLogAddFace.Create( Result );
  FormLogAddFace.AddChange;
end;

class function MySocketUtil.RevData(TcpSocket: TCustomIpClient;
  WaitTime: Integer): string;
var
  StartTime, WaitDataStart : TDateTime;
begin
  Result := '';

  StartTime := Now;
  while ( SecondsBetween( Now, StartTime ) < WaitTime ) do
  begin
    WaitDataStart := Now;
    if TcpSocket.WaitForData( 100 ) then // �ȴ�����
    begin
      Result := RevString( TcpSocket );
      Break;
    end
    else
    if MilliSecondsBetween( Now, WaitDataStart ) < 90 then
      Break;
  end;
end;


class function MySocketUtil.RevString(TcpSocket: TCustomIpClient): string;
begin
  Result := TcpSocket.Receiveln;
  if Result = BigMarkStart_RevStr then
    Result := RevBigStr( TcpSocket );
end;

class function MySocketUtil.SendString(TcpSocket: TCustomIpClient;
  MsgStr: string): Integer;
begin
    // ���ʹ��ַ�����Ҫ��η���
//  if Length( AnsiString( MsgStr ) ) > 500 then
//    Result := SendBigStr( TcpSocket, MsgStr )
//  else
    Result := TcpSocket.Sendln( MsgStr );
end;


class function MySocketUtil.SendJsonStr(TcpSocket: TCustomIpClient;
  MsgType: string; MsgStr: Integer): Boolean;
begin
  Result := SendJsonStr( TcpSocket, MsgType, IntToStr( MsgStr ) );
end;

{ TDisConnThread }

constructor TDisConnThread.Create(_TcpSocket: TCustomIpClient);
begin
  inherited Create;
  TcpSocket := _TcpSocket;
end;

destructor TDisConnThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  inherited;
end;

procedure TDisConnThread.Execute;
var
  StartTime : TDateTime;
  IsConn : Boolean;
begin
    // 12 ����û�������� ��Ͽ�����
  IsConn := False;
  StartTime := Now;
  while ( SecondsBetween( Now, StartTime ) < 12 ) do
    if not Terminated then
      Sleep(100)
    else
    begin
      IsConn := True;
      Break;
    end;

    // ��ʱ�Ͽ�����
  if not IsConn then
    TcpSocket.Disconnect;

  inherited;
end;

{ THandleListenThread }

constructor THandleListenThread.Create;
begin
  inherited Create;
end;

procedure THandleListenThread.Execute;
var
  TcpAcceptInfo : TTcpAcceptInfo;
begin
  FreeOnTerminate := True;

  while not Terminated and MyListener.IsRun do
  begin
    TcpAcceptInfo := MyListener.getTcpAccept;

    if TcpAcceptInfo = nil then
      Break;

    Handle( TcpAcceptInfo );

    TcpAcceptInfo.Free;
  end;

    // ɾ���̼߳�¼
  MyListener.RemoveThread( Self.ThreadID );

    // �����߳�
  Terminate;
end;

procedure THandleListenThread.Handle(TcpAcceptInfo: TTcpAcceptInfo);
var
  AcceptSocketHandle : TAcceptSocketHandle;
begin
  AcceptSocketHandle := TAcceptSocketHandle.Create( TcpAcceptInfo );
  AcceptSocketHandle.Update;
  AcceptSocketHandle.Free;
end;

{ TTcpAcceptInfo }

constructor TTcpAcceptInfo.Create(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

{ TAcceptSocketHandle }

constructor TAcceptSocketHandle.Create(_TcpAcceptInfo: TTcpAcceptInfo);
begin
  TcpAcceptInfo := _TcpAcceptInfo;
  TcpSocket := TcpAcceptInfo.TcpSocket;
end;

function TAcceptSocketHandle.HandleConn(ConnType: string): Boolean;
begin
  Result := True;

  if ConnType = ConnType_SearchServer then
    MyMasterReceiveHanlder.ReceiveConn( TcpSocket )
  else
  if ConnType = ConnType_Client then
    MyClient.AcceptServer( TcpSocket )
  else
  if ConnType = ConnType_Server then
    MyServer.AcceptClient( TcpSocket )
  else
  if ConnType = ConnType_CloudFileRequest then
    MyCloudFileHandler.ReceiveConn( TcpSocket )
  else
  if ConnType = ConnType_Backup then
    MyBackupFileConnectHandler.AddBackConn( TcpSocket )
  else
  if ConnType = ConnType_Restore then
    MyRestoreDownConnectHandler.AddBackConn( TcpSocket )
  else
  if ConnType = ConnType_AccountSignup then
    SignupHandle
  else
    Result := False;
end;


procedure TAcceptSocketHandle.RemoveEditionError;
begin
  NetworkConnEditionErrorApi.RemoveItem( TcpSocket.RemoteHost );
end;

procedure TAcceptSocketHandle.SignupHandle;
var
  Account, Password : string;
  SignupResult : string;
begin
    // ��ȡ�ʺ���Ϣ
  Account := MySocketUtil.RevJsonStr( TcpSocket );
  Password := MySocketUtil.RevJsonStr( TcpSocket );

    // ����ʺ�
  if MyAccountReadUtil.ReadIsExist( Account ) then
    SignupResult := SignupResult_AccountExist
  else
  if PcInfo.ClientCount <= MyAccountReadUtil.ReadAccountCount then
    SignupResult := SignupResult_AccountNotEnough
  else
  begin
    NetworkAccountApi.AddAccount( Account, Password );
    SignupResult := SignupResult_Completed;
  end;

    // ����ע����
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_SignupResult, SignupResult );

    // �Ͽ�����
  TcpSocket.Free;
end;

procedure TAcceptSocketHandle.Update;
var
  MsgStr : string;
  TcpConnInfo : TTcpConnInfo;
  ConnResult, ConnType : string;
  SocketConnEdition : Integer;
begin
    // �������ӳɹ���־
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_ConnResult, ConnResult_OK );

    // ���� Tcp ������Ϣ
  MsgStr := MySocketUtil.RevData( TcpSocket, WaitTime_Accept );
  if MsgStr = '' then
  begin
    TcpSocket.Free;
    Exit;
  end;

    // ���� ������Ϣ
  TcpConnInfo := TTcpConnInfo.Create;
  TcpConnInfo.SetMsg( MsgStr );
  SocketConnEdition := TcpConnInfo.ConnEdiiton;
  if SocketConnEdition = ConnEdition_Now then
    ConnResult := ConnResult_OK
  else
  if SocketConnEdition < ConnEdition_Now then  // �������°汾
    ConnResult := ConnResult_NewEiditon
  else
    ConnResult := ConnResult_Error;
  ConnType := TcpConnInfo.ConnType;
  TcpConnInfo.Free;

    // ���� ���ӽ��
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_ConnEdition, ConnResult );

    // ���� ���ӽ��
  if ConnResult = ConnResult_OK then
  begin
    RemoveEditionError;
    HandleConn( ConnType );
  end
  else
  begin
    ConnEditionError( SocketConnEdition > ConnEdition_Now );
    TcpSocket.Free;
  end;
end;

{ THandleListenThreadList }

class function MySocketUtil.SendData(TcpSocket: TCustomIpClient;
  MsgStr: Integer): Boolean;
begin
  Result := SendData( TcpSocket, IntToStr( MsgStr ) );
end;

class function MySocketUtil.SendData(TcpSocket: TCustomIpClient;
  MsgStr: string): Boolean;
begin
  try
    Result := SendString( TcpSocket, MsgStr ) <> SOCKET_ERROR;
    Sleep(1);
  except
  end;
end;

class function MySocketUtil.SendData(TcpSocket: TCustomIpClient;
  MsgStr: Int64): Boolean;
begin
  Result := SendData( TcpSocket, IntToStr( MsgStr ) );
end;

class function MySocketUtil.SendBigStr(TcpSocket: TCustomIpClient;
  MsgStr: string): Integer;
var
  StrPos, CopyCount : Integer;
  CopyStr, SendStr : string;
begin
  Result := 0;

    // ���Ϳ�ʼ���
  TcpSocket.Sendln( BigMarkStart_RevStr );
    // ����ַ�����Ȼ���ͣ�500���ַ�һ��
  CopyStr := MsgStr;
  while Length( CopyStr ) > 0 do
  begin
    CopyCount := Min( 500, length( CopyStr ) );
    SendStr := Copy( CopyStr, 1, CopyCount );
    if Length( AnsiString( SendStr ) ) = 510 then
      SendStr := Copy( SendStr, 1, length( SendStr ) - 1 );
    StrPos := length( SendStr );
    CopyStr := Copy( CopyStr, StrPos + 1, length( CopyStr ) - StrPos );

      // ���� 500 ���ַ�
    Result := Result + TcpSocket.Sendln( SendStr );
  end;
    // ���ͽ������
  TcpSocket.Sendln( BigMarkStop_RevStr );

  Result := Max( -1, Result );
end;

class function MySocketUtil.SendData(TcpSocket: TCustomIpClient;
  MsgStr: Boolean): Boolean;
begin
  Result := SendData( TcpSocket, BoolToStr( MsgStr ) );
end;

class function MySocketUtil.SendJsonStr(TcpSocket: TCustomIpClient;
  MsgType: string; MsgStr: Int64): Boolean;
begin
  Result := SendJsonStr( TcpSocket, MsgType, IntToStr( MsgStr ) );
end;

class function MySocketUtil.SendJsonStr(TcpSocket: TCustomIpClient;
  MsgType: string; MsgStr: Boolean): Boolean;
begin
  Result := SendJsonStr( TcpSocket, MsgType, BoolToStr( MsgStr ) );
end;

class function MySocketUtil.SendJsonStr(TcpSocket : TCustomIpClient; MsgType, MsgStr: string): Boolean;
var
  MsgInfo : TMsgInfo;
begin
  try
    MsgInfo := TMsgInfo.Create;
    MsgInfo.SetMsgInfo( MsgType, MsgStr );
    Result := SendData( TcpSocket, MsgInfo.getMsg );
    MsgInfo.Free;
  except
  end;
end;

class function MySocketUtil.RevInt64Data(TcpSocket: TCustomIpClient): Int64;
begin
  Result := StrToInt64Def( RevData( TcpSocket ), 0 );
end;

class function MySocketUtil.RevIntData(TcpSocket: TCustomIpClient): Integer;
begin
  Result := StrToIntDef( RevData( TcpSocket ), 0 );
end;

class function MySocketUtil.RevJsonBool(TcpSocket: TCustomIpClient): Boolean;
begin
  Result := StrToBoolDef( RevJsonStr( TcpSocket ), False );
end;

class function MySocketUtil.RevJsonInt(TcpSocket: TCustomIpClient): Integer;
begin
  Result := StrToIntDef( RevJsonStr( TcpSocket ), 0 );
end;

class function MySocketUtil.RevJsonInt64(TcpSocket: TCustomIpClient): Int64;
begin
  Result := StrToInt64Def( RevJsonStr( TcpSocket ), 0 );
end;

class function MySocketUtil.RevJsonStr( TcpSocket : TCustomIpClient ): string;
var
  MsgInfo : TMsgInfo;
begin
  try
    MsgInfo := TMsgInfo.Create;
    Result := RevData( TcpSocket );
    MsgInfo.SetMsg( Result );
    Result := MsgInfo.MsgStr;
    MsgInfo.Free;
  except
  end;
end;

class function MySocketUtil.ReadMsgToMsgStr(Msg: string): string;
var
  MsgInfo : TMsgInfo;
begin
  if Msg = '' then
  begin
    Result := '';
    Exit;
  end;

  try
    MsgInfo := TMsgInfo.Create;
    MsgInfo.SetMsg( Msg );
    Result := MsgInfo.MsgStr;
    MsgInfo.Free;
  except
  end;
end;

class function MySocketUtil.RevBigStr(TcpSocket: TCustomIpClient): string;
var
  RevStr : string;
begin
  Result := '';
  while True do
  begin
    RevStr := MySocketUtil.RevData( TcpSocket, WaitTime_RevData );
    if RevStr = '' then
    begin
      Result := '';
      Break;
    end;
    if RevStr = BigMarkStop_RevStr then
      Break;
    Result := Result + RevStr;
  end;
end;

class function MySocketUtil.RevBoolData(TcpSocket: TCustomIpClient): Boolean;
begin
  Result := StrToBoolDef( RevData( TcpSocket ), False );
end;

{ MyTcpUtil }

class function MyTcpUtil.getPortAvaialble(Port: Integer): Boolean;
var
  err:   Integer;
  sockHandle   :   WinSock.TSocket;
  WData:   TWSAData;
  Addr:   TSockAddr;
begin
  try
    err := WSAStartup(MakeWord(2,2),   WData);
    if err <> 0 then
    begin
      result   :=   false;
      exit;
    end;

    sockHandle := socket(PF_INET,   SOCK_STREAM,   IPPROTO_TCP);
    if sockHandle  =  INVALID_SOCKET   then
     begin
        //winsock����ʧ��
        result   :=   false;
        exit;
    end;

    Addr.sin_family   :=   AF_INET;
    Addr.sin_port   :=   htons(port);   //�˿ںŲ���
    Addr.sin_addr.s_addr   :=   INADDR_ANY;
    if   bind(sockHandle   ,   Addr,   SizeOf(Addr))   =   SOCKET_ERROR   then
     begin
        //winsock��ʧ�ܣ������Ƕ˿ڱ�ռ��
        result   :=   false;
        exit;
    end;

    result   :=   true;//���سɹ�
    CloseSocket(sockHandle);
  except
    Result := False;
  end;
end;


class function MyTcpUtil.TestConnect(Ip, Port: string): Boolean;
var
  TcpSocket : TCustomIpClient;
  MyTcpConn : TMyTcpConn;
begin
  TcpSocket := TCustomIpClient.Create( nil );

      // ���ӶԷ�
  MyTcpConn := TMyTcpConn.Create( TcpSocket );
  MyTcpConn.SetConnSocket( Ip, Port );
  MyTcpConn.SetConnType( ConnType_TestConn );
  Result := MyTcpConn.Conn;
  MyTcpConn.Free;

  TcpSocket.Free;
end;

procedure TMyTcpConn.ConnEditionError( IsNewEdition : Boolean );
begin
  NetworkErrorStatusApi.ShowExistOldEdition( TcpSocket.RemoteHost, IsNewEdition );
end;

procedure TAcceptSocketHandle.ConnEditionError( IsNewEdition : Boolean );
begin
  NetworkErrorStatusApi.ShowExistOldEdition( TcpSocket.RemoteHost, IsNewEdition );
end;

end.


