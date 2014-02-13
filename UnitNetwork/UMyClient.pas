unit UMyClient;

interface

uses Classes, Sockets, UChangeInfo, SyncObjs, UMyUtil, SysUtils,UMyNetPcInfo, DateUtils, UModelUtil,
     uDebug, UFileBaseInfo, uDebugLock;

type

{$Region ' Client ������Ϣ ' }

  TPcMsgBase = class( TMsgBase )
  public
    iPcID : string;
  published
    property PcID : string Read iPcID Write iPcID;
  public
    procedure SetPcID( _PcID : string );
  end;

{$EndRegion}

{$Region ' Client ״̬��Ϣ ' }

    // Online ����
  TPcOnlineMsgBase = class( TPcMsgBase )
  public
    iPcName : string;
    iLanIp, iLanPort : string;
    iInternetIp, iInternetPort : string;
    iAccount : string;
  published
    property PcName : string Read iPcName Write iPcName;
    property LanIp : string Read iLanIp Write iLanIp;
    property LanPort : string Read iLanPort Write iLanPort;
    property InternetIp : string Read iInternetIp Write iInternetIp;
    property InternetPort : string Read iInternetPort Write iInternetPort;
    property Account : string Read iAccount Write iAccount;
  public
    procedure SetPcName( _PcName : string );
    procedure SetLanSocket( _LanIp, _LanPort : string );
    procedure SetInternetSocket( _InternetIp, _InternetPort : string );
    procedure SetAccount( _Account : string );
    procedure Update;override;
  private
    procedure SendConfirmConect;
  end;

    // Pc Online ��Ϣ
  TPcOnlineMsg = class( TPcOnlineMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  private
    procedure SendBackPcOnline;
  end;

    // Pc ���� Online ��Ϣ
  TPcBackOnlineMsg = class( TPcOnlineMsgBase )
  public
    procedure Update;override;
  public
    function getMsgType : string;override;
  end;

    // Pc Offline ��Ϣ
  TPcOfflineMsg = class( TPcMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  private
    procedure SetNetPcOffline;
  end;

    // Pc ��Ϣ
  TPcHeartBeatMsg = class( TPcMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

      // ��Ϣ����
  TPcStatusMsgFactory = class( TMsgFactory )
  public
    constructor Create;
    function get: TMsgBase;override;
  end;

{$EndRegion}

{$Region ' Client ���籸����Ϣ ' }

  {$Region ' ��·�� ' }

    // ��·�� ����
  TCloudPathChangeMsg = class( TPcMsgBase )
  public
    iCloudPath : string;
  published
    property CloudPath : string Read iCloudPath Write iCloudPath;
  public
    procedure SetCloudPath( _CloudPath : string );
  end;

    // ���
  TCloudPathAddMsg = class( TCloudPathChangeMsg )
  public
    iAvailableSpace : Int64;
  published
    property AvailableSpace : Int64 Read iAvailableSpace Write iAvailableSpace;
  public
    procedure SetAvailableSpace( _AvailableSpace : Int64 );
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // ���ÿ��ÿռ���Ϣ
  TCloudPathSetAvailableSpaceMsg = class( TCloudPathChangeMsg )
  public
    iAvailableSpace : Int64;
  published
    property AvailableSpace : Int64 Read iAvailableSpace Write iAvailableSpace;
  public
    procedure SetAvailableSpace( _AvailableSpace : Int64 );
    procedure Update;override;
    function getMsgType : string;override;
  end;


    // ɾ��
  TCloudPathRemoveMsg = class( TCloudPathChangeMsg )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

  {$EndRegion}

  {$Region ' ����·�� ' }

    // ����
  TNetworkBackupChangeMsg = class( TCloudPathChangeMsg )
  public
    iBackupPath : string;
  public
    iAccount : string;
  published
    property BackupPath : string Read iBackupPath Write iBackupPath;
    property Account : string Read iAccount Write iAccount;
  public
    procedure SetBackupPath( _BackupPath : string );
    procedure SetAccount( _Account : string );
  end;

    // ��� ����
  TNetworkBackupAddMsg = class( TNetworkBackupChangeMsg )
  public
    iIsFile : Boolean;
    iFileCount : Integer;
    iFileSize : Int64;
    iLastBackupTime : TDateTime;
  public
    iIsSaveDeleted : Boolean;
    iIsEncrypted : Boolean;
    iPassword : string;
    iPasswordHint : string;
  published
    property IsFile : Boolean Read iIsFile Write iIsFile;
    property FileCount : Integer Read iFileCount Write iFileCount;
    property FileSize : Int64 Read iFileSize Write iFileSize;
    property LastBackupTime : TDateTime Read iLastBackupTime Write iLastBackupTime;
    property IsSaveDeleted : Boolean Read iIsSaveDeleted Write iIsSaveDeleted;
    property IsEncrypted : Boolean Read iIsEncrypted Write iIsEncrypted;
    property Password : string Read iPassword Write iPassword;
    property PasswordHint : string Read iPasswordHint Write iPasswordHint;
  public
    procedure SetIsFile( _IsFile : Boolean );
    procedure SetSpaceInfo( _FileCount : Integer; _FileSize : Int64 );
    procedure SetLastBackupTime( _LastBackupTime : TDateTime );
    procedure SetIsSaveDeleted( _IsSaveDeleted : Boolean );
    procedure SetEncryptInfo( _IsEncrypted : Boolean; _Password, _PasswordHint : string );
  end;

    // ��� Backup Item
  TNetworkBackupAddCloudMsg = class( TNetworkBackupAddMsg )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // ɾ�� Backup Item
  TNetworkBackupRemoveCloudMsg = class( TNetworkBackupChangeMsg )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

  {$EndRegion}

  {$Region ' �ָ�·�� ' }

    // ��� Restore Item
  TCloudBackupAddRestoreMsg = class( TNetworkBackupAddMsg )
  private
    iOwnerID, iOwnerName : string;
  published
    property OwnerID : string Read iOwnerID Write iOwnerID;
    property OwnerName : string Read iOwnerName Write iOwnerName;
  public
    procedure SetOwnerInfo( _OwnerID, _OwnerName : string );
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // ɾ�� Restore Item
  TCloudBackupRemoveRestoreMsg = class( TNetworkBackupChangeMsg )
  private
    iOwnerID : string;
  published
    property OwnerID : string Read iOwnerID Write iOwnerID;
  public
    procedure SetOwnerID( _OwnerID : string );
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

  {$EndRegion}

  {$Region ' �������� ���� ' }

    // ����������
  TBackupItemBackConnMsg = class( TPcMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // �������� ��æ
  TBackupItemBackConnBusyMsg = class( TPcMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // �������� ʧ��
  TBackupItemBackConnErrorMsg = class( TPcMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

  {$EndRegion}

  {$Region ' �������� �ָ� ' }

    // ����������
  TRestoreItemBackConnMsg = class( TPcMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // �������� ��æ
  TRestoreItemBackConnBusyMsg = class( TPcMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // �������� ʧ��
  TRestoreItemBackConnErrorMsg = class( TPcMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

  {$EndRegion}

    // Add Pend ����
  TNetworkBackupMsgFactory = class( TMsgFactory )
  public
    constructor Create;
    function get: TMsgBase;override;
  end;

{$EndRegion}

{$Region ' Client ע����Ϣ '}

    // ע����Ϣ
  TActivatePcMsg = class( TPcMsgBase )
  private
    iLicenseStr : string;
  published
    property LicenseStr : string Read iLicenseStr Write iLicenseStr;
  public
    procedure SetLicenseStr( _LicenseStr : string );
    procedure Update;override;
    function getMsgType : string;override;
  private
    procedure FeedBack;
  end;

    // ע�����
  TActivatePcCompletedMsg = class( TPcMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // ��ʾע����Ϣ
  TRegisterShowMsg = class( TPcMsgBase )
  public
    iHardCode : string;
    iRegisterEdition : string;
  published
    property HardCode : string Read iHardCode Write iHardCode;
    property RegisterEdition : string Read iRegisterEdition Write iRegisterEdition;
  public
    procedure SetHardCode( _HardCode : string );
    procedure SetRegisterEdition( _RegisterEdition : string );
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // ����Ϣ����
  TRegisterMsgFactory = class( TMsgFactory )
  public
    constructor Create;
    function get : TMsgBase;override;
  end;

{$EndRegion}

{$Region ' Advance ���� Pc ��Ϣ ' }

  TServerInfoMsg = class( TMsgBase )
  private
    iServerPcID : string;
    iServerLanIp, iServerLanPort : string;
    iServerInternetIp, iServerInternetPort : string;
  public
    procedure SetServerPcID( _ServerPcID : string );
    procedure SetLanInfo( _ServerLanIp, _ServerLanPort : string );
    procedure SetInternetInfo( _ServerInternetIp, _ServerInternetPort : string );
  published
    property ServerPcID : string Read iServerPcID Write iServerPcID;
    property ServerLanIp : string Read iServerLanIp Write iServerLanIp;
    property ServerLanPort : string Read iServerLanPort Write iServerLanPort;
    property ServerInternetIp : string Read iServerInternetIp Write iServerInternetIp;
    property ServerInternetPort : string Read iServerInternetPort Write iServerInternetPort;
  public
    function getMsgType : string; override;
  end;

  TAdvancePcConnMsg = class( TPcMsgBase )
  private
    iConnPcID, iConnPcName : string;
    iLanIp, iLanPort : string;
    iInternetIp, iInternetPort : string;
  published
    property ConnPcID : string Read iConnPcID Write iConnPcID;
    property ConnPcName : string Read iConnPcName Write iConnPcName;
    property LanIp : string Read iLanIp Write iLanIp;
    property LanPort : string Read iLanPort Write iLanPort;
    property InternetIp : string Read iInternetIp Write iInternetIp;
    property InternetPort : string Read iInternetPort Write iInternetPort;
  public
    procedure SetConnPcInfo( _ConnPcID, _ConnPcName : string );
    procedure SetLanSocket( _LanIp, _LanPort : string );
    procedure SetInternetSocket( _InternetIp, _InternetPort : string );
    procedure Update;override;
    function getMsgType : string;override;
  private
    procedure AddNetworkPc;
    procedure AddPingMsg;
  end;

  TAdvanceConnMsgFactory = class( TMsgFactory )
  public
    constructor Create;
    function get : TMsgBase;override;
  end;

{$EndRegion}


{$Region ' Client �����߳� ' }

    // ���� ��������Ϣ ���߳�
  TClientRevMsgThread = class( TDebugThread )
  private
    TcpSocket : TCustomIpClient;
  private
    MsgFactoryList : TMsgFactoryList;
  public
    constructor Create( _TcpSocket : TCustomIpClient );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure IniMsgFactory;
    procedure HandleRevMsg( MsgStr : string );
  end;

{$EndRegion}

{$Region ' Client �����߳� ' }

  TClientSendMsgThread = class( TDebugThread )
  public
    MsgLock : TCriticalSection;
    SendMsgList : TStringList; // �����������
  private
    TcpSocket : TCustomIpClient;
  public
    constructor Create( _TcpSocket : TCustomIpClient );
    procedure AddSendMsg( MsgStr : string );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    function getNextMsg : string;
    procedure SendMsg( MsgStr : string );
  end;

{$EndRegion}

{$Region ' Client �����߳� ' }

    // ����
  TClientHeartBeatHandle = class
  public
    procedure Update;
  private
    procedure SendHeartBeat;
    procedure SendCloudAvailableSpace;
  end;

{$EndRegion}

    // �ͻ��˶�ʱ Api
  MyClientOnTimerApi = class
  public
    class procedure SendHeartBeat;
  end;

    // �ͻ�����Ϣ
  TMyClient = class
  public
    ClientLock : TCriticalSection;
    ClientSocket : TCustomIpClient;
    ClientRevMsgThread : TClientRevMsgThread;  // ���������߳�
    ClientSendMsgThread : TClientSendMsgThread; // ���������߳�
  public
    IsRun, IsConnServer : Boolean;
    ServerPcID : string;
    ServerLanIp, ServerLanPort : string;
    ServerInternetIp, ServerInternetPort : string;
  public
    constructor Create;
    procedure StopRun;
    destructor Destroy; override;
  public
    procedure SendMsgToPc( PcID : string; MsgBase : TMsgBase );
    procedure SendMsgToAll( MsgBase : TMsgBase );
  public
    function ConnectServer( TcpSocket : TCustomIpClient ): Boolean; // ��������
    procedure AcceptServer( TcpSocket : TCustomIpClient ); // ������������
    procedure ClientLostConn;  // ���� ��������
    procedure ServerLostConn; // ���� ��������
  private        // ����
    function getIsAddClient( TcpSocket : TCustomIpClient ): Boolean;
    procedure AddClient( TcpSocket : TCustomIpClient );
  end;

const
  MsgType_PcStatus = 'pst_';
  MsgType_PcStatus_Online = 'pst_ol';
  MsgType_PcStatus_BackOnline = 'pst_bol';
  MsgType_PcStatus_Offline = 'pst_Ofl';
  MsgType_PcStatus_HeartBeat = 'pst_hb';

  MsgType_Register = 'rt_';
  MsgType_Register_ActivatePc = 'rt_ap';
  MsgType_Register_ActivatePcCompeted = 'rt_apc';
  MsgType_Register_RegisterShow = 'rt_rs';

  MsgType_NetworkBackup = 'nb_';
  MsgType_NetworkBackup_AddCloudItem = 'nb_aci';
  MsgType_NetworkBackup_RemoveCloudItem = 'nb_rci';
  MsgType_NetworkBackup_AddBackupItem = 'nb_abi';
  MsgType_NetworkBackup_RemoveBackupItem = 'nb_rbi';
  MsgType_NetworkBackup_AddRestoreItem = 'nb_ari';
  MsgType_NetworkBackup_RemoveRestoreItem = 'nb_rri';
  MsgType_NetworkBackup_SetCloudAvailableSpace = 'nb_sas';
  MsgType_NetworkBackup_BackupBackConn = 'nb_bbc';
  MsgType_NetworkBackup_BackupBackConnBusy = 'nb_bbcb';
  MsgType_NetworkBackup_BackupBackConnError = 'nb_bbce';
  MsgType_NetworkBackup_RestoreBackConn = 'nb_rbc';
  MsgType_NetworkBackup_RestoreBackConnBusy = 'nb_rbcb';
  MsgType_NetworkBackup_RestoreBackConnError = 'nb_rbce';
  MsgType_NetworkBackup_RestoreExplorerBackConn = 'nb_rebc';
  MsgType_NetworkBackup_RestoreExplorerBackConnBusy = 'nb_rebcb';
  MsgType_NetworkBackup_RestoreExplorerBackConnError = 'nb_rebce';
  MsgType_NetworkBackup_RestoreSearchBackConn = 'nb_rsbc';
  MsgType_NetworkBackup_RestoreSearchBackConnBusy = 'nb_rsbcb';
  MsgType_NetworkBackup_RestoreSearchBackConnError = 'nb_rsbce';

  MsgType_AdvancePc = 'ap_';

const
  MsgType_ServerInfo = 'ServerInfo';

var
  MyClient : TMyClient;

implementation

uses UMyServer,  UNetworkFace, UMyMaster, USearchServer, UMyTcp, UMyBackupApiInfo,
     UNetPcInfoXml, USettingInfo, UMyBackupDataInfo, UMyRegisterApiInfo,
     UNetworkControl, UMyRestoreApiInfo, URestoreThread,
     UMyCloudDataInfo, UMyCloudApiInfo, UBackupThread, UMyTimerThread;

{ TRevServerMsgThread }

procedure TClientRevMsgThread.HandleRevMsg(MsgStr: string);
var
  i : Integer;
  MsgInfo : TMsgInfo;
  MsgFactory : TMsgFactory;
  MsgBase : TMsgBase;
begin
  MsgInfo := TMsgInfo.Create;
  MsgInfo.SetMsg( MsgStr );
  for i := 0 to MsgFactoryList.Count - 1 do
  begin
    MsgFactory := MsgFactoryList[i];
    MsgFactory.SetMsg( MsgInfo.MsgType );
    if MsgFactory.CheckType then
    begin
      MsgBase := MsgFactory.get;
      if MsgBase <> nil then
      begin
        MsgBase.SetMsgStr( MsgInfo.MsgStr );
        MsgBase.Update;
        MsgBase.Free;
      end;
      Break;
    end;
  end;
  MsgInfo.Free;
end;

constructor TClientRevMsgThread.Create( _TcpSocket : TCustomIpClient );
begin
  inherited Create;
  TcpSocket := _TcpSocket;

  MsgFactoryList := TMsgFactoryList.Create;
  IniMsgFactory;
end;

destructor TClientRevMsgThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  MsgFactoryList.Free;
  inherited;
end;

procedure TClientRevMsgThread.Execute;
var
  MsgStr : string;
begin
  while not Terminated do
  begin
      // �������������Ϣ
    MsgStr := MySocketUtil.RevData( TcpSocket, WaitTime_RevClient );
    if MsgStr = ''  then  // �Ͽ�����
    begin
      MyClient.ServerLostConn;  // �������Ͽ��¼�
      Break;
    end
    else
    begin
      try
        HandleRevMsg( MsgStr );
      except
      end;
    end;
  end;

  inherited;
end;

procedure TClientRevMsgThread.IniMsgFactory;
var
  MsgFactory : TMsgFactory;
begin
    // Pc ״̬����
  MsgFactory := TPcStatusMsgFactory.Create;
  MsgFactoryList.Add( MsgFactory );

      // ע����Ϣ
  MsgFactory := TRegisterMsgFactory.Create;
  MsgFactoryList.Add( MsgFactory );

    // Advance
  MsgFactory := TAdvanceConnMsgFactory.Create;
  MsgFactoryList.Add( MsgFactory );

    // Network Backup
  MsgFactory := TNetworkBackupMsgFactory.Create;
  MsgFactoryList.Add( MsgFactory );
end;

{ TMyClient }

function TMyClient.ConnectServer(TcpSocket: TCustomIpClient): Boolean;
begin
  ClientLock.Enter;
  Result := getIsAddClient( TcpSocket );
  ClientLock.Leave;
end;

constructor TMyClient.Create;
begin
  IsRun := True;
  IsConnServer := False;
  ClientLock := TCriticalSection.Create;
end;

destructor TMyClient.Destroy;
begin
  ClientLock.Free;
  inherited;
end;

function TMyClient.getIsAddClient(TcpSocket: TCustomIpClient): Boolean;
var
  IsServer, IsExistClient : Boolean;
begin
  Result := False;

    // �ѽ���
  if not IsRun then
    Exit;

    // ��ȡ�Է��Ƿ� Server
  IsServer := MySocketUtil.RevJsonBool( TcpSocket );
  if not IsServer then
    Exit;

    // �����Ƿ������ӷ�����
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_IsConnectToServer, IsConnServer );
  if IsConnServer then
    Exit;

    // �Ƿ���ڿͻ���
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_PcID_Check, PcInfo.PcID );  // ���ͱ�����ʶ
  IsExistClient := StrToBoolDef( MySocketUtil.RevJsonStr( TcpSocket ), True );
  if IsExistClient then // �Ѵ��ڿͻ���
    Exit;

    // ���
  AddClient( TcpSocket );

  Result := True;
end;

procedure TMyClient.AcceptServer(TcpSocket: TCustomIpClient);
begin
  if not ConnectServer( TcpSocket ) then
    TcpSocket.Free;
end;

procedure TMyClient.AddClient(TcpSocket: TCustomIpClient);
var
  ServerInfoMsg : TServerInfoMsg;
  PcOnlineMsg : TPcOnlineMsg;
begin
    // ���ÿͻ��� Socket
  ClientSocket := TcpSocket;

    // ���� Pc ��ʶ
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_PcID_Enter, PcInfo.PcID );
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_PcID_Enter, PcInfo.PcID );

    // ��ȡ Server ������Ϣ
  ServerInfoMsg := TServerInfoMsg.Create;
  ServerInfoMsg.SetMsg( MySocketUtil.RevData( TcpSocket ) );
  ServerPcID := ServerInfoMsg.ServerPcID;
  ServerLanIp := ServerInfoMsg.ServerLanIp;
  ServerLanPort := ServerInfoMsg.ServerLanPort;
  ServerInternetIp := ServerInfoMsg.ServerInternetIp;
  ServerInternetPort := ServerInfoMsg.ServerInternetPort;
  ServerInfoMsg.Free;

    // ������Ϣ �߳�
  ClientSendMsgThread := TClientSendMsgThread.Create( TcpSocket );

    // ������Ϣ �߳�
  ClientRevMsgThread := TClientRevMsgThread.Create( TcpSocket );
  ClientRevMsgThread.Resume;

    // �������� �߳�
  MyTimerHandler.AddTimer( HandleType_ClientHeartBeat, 180 );

    // ���� ��Ϊ Master
  NetworkPcApi.BeServer( ServerPcID );

    // ����Ѿ����� Server
  IsConnServer := True;

    // ����������Ϣ
  PcOnlineMsg := TPcOnlineMsg.Create;
  PcOnlineMsg.SetPcID( PcInfo.PcID );
  PcOnlineMsg.SetPcName( PcInfo.PcName );
  PcOnlineMsg.SetLanSocket( PcInfo.LanIp, PcInfo.LanPort );
  PcOnlineMsg.SetInternetSocket( PcInfo.InternetIp, PcInfo.InternetPort );
  SendMsgToAll( PcOnlineMsg );
end;

procedure TMyClient.ClientLostConn;
begin
  if not IsConnServer then
    Exit;

    // ֹͣ��������
  IsConnServer := False;

    // ������������
  ClientSocket.Disconnect;
  ClientRevMsgThread.Free;
  ClientSendMsgThread.Free;
  MyTimerHandler.RemoveTimer( HandleType_ClientHeartBeat );
  ClientSocket.Free;
end;

procedure TMyClient.SendMsgToAll(MsgBase: TMsgBase);
var
  MsgStr : string;
  SendClientAllMsg : TSendClientAllMsg;
  SendMsgStr : string;
begin
    // �������
  if not IsRun or not IsConnServer then
  begin
    MsgBase.Free;
    Exit;
  end;

  MsgStr := MsgBase.getMsg;

    // ��������� ת������ Pc
  SendClientAllMsg := TSendClientAllMsg.Create;
  SendClientAllMsg.SetSendMsgStr( MsgStr );

  SendMsgStr := SendClientAllMsg.getMsg;
  ClientSendMsgThread.AddSendMsg( SendMsgStr );

  SendClientAllMsg.Free;

  MsgBase.Free;
end;

procedure TMyClient.SendMsgToPc(PcID: string; MsgBase: TMsgBase);
var
  SendClientMsg : TSendClientMsg;
  MsgStr : string;
begin
    // �������
  if not IsRun or not IsConnServer then
  begin
    MsgBase.Free;
    Exit;
  end;

    // ��������� ת�� Pc
  SendClientMsg := TSendClientMsg.Create;
  SendClientMsg.SetTargetPcID( PcID );
  SendClientMsg.SetSendMsgBase( MsgBase );

  MsgStr := SendClientMsg.getMsg;
  ClientSendMsgThread.AddSendMsg( MsgStr );

  SendClientMsg.Free;
  MsgBase.Free;
end;

procedure TMyClient.ServerLostConn;
begin
  if not IsConnServer then
    Exit;

    // ��������
  MySearchMasterHandler.RestartNetwork;
end;


procedure TMyClient.StopRun;
begin
  IsRun := False;
end;

{ TServerTramitMsgFactory }

constructor TPcStatusMsgFactory.Create;
begin
  inherited Create( MsgType_PcStatus );
end;

function TPcStatusMsgFactory.get: TMsgBase;
begin
  if MsgType = MsgType_PcStatus_Online then
    Result := TPcOnlineMsg.Create
  else
  if MsgType = MsgType_PcStatus_BackOnline then
    Result := TPcBackOnlineMsg.Create
  else
  if MsgType = MsgType_PcStatus_Offline then
    Result := TPcOfflineMsg.Create
  else
  if MsgType = MsgType_PcStatus_HeartBeat then
    Result := TPcHeartBeatMsg.Create
  else
    Result := nil;
end;

{ TPcOnlineMsg }

function TPcOnlineMsg.getMsgType: string;
begin
  Result := MsgType_PcStatus_Online;
end;

procedure TPcOnlineMsg.SendBackPcOnline;
var
  PcBackOnlineMsg : TPcBackOnlineMsg;
begin
    // Back Online Msg
  PcBackOnlineMsg := TPcBackOnlineMsg.Create;
  PcBackOnlineMsg.SetPcID( PcInfo.PcID );
  PcBackOnlineMsg.SetPcName( PcInfo.PcName );
  PcBackOnlineMsg.SetLanSocket( PcInfo.LanIp, PcInfo.LanPort );
  PcBackOnlineMsg.SetInternetSocket( PcInfo.InternetIp, PcInfo.InternetPort );

  MyClient.SendMsgToPc( PcID, PcBackOnlineMsg );
end;

procedure TPcOnlineMsg.Update;
begin
  inherited;

  SendBackPcOnline;

    // Pc ���� �¼�
  NetworkPcApi.PcOnline( PcID, Account );
end;

{ TPcBackOnlineMsg }

function TPcBackOnlineMsg.getMsgType: string;
begin
  Result := MsgType_PcStatus_BackOnline;
end;

procedure TPcBackOnlineMsg.Update;
begin
  inherited;

    // Pc ���� �¼�
  NetworkPcApi.PcOnline( PcID, Account );
end;

{ TPcOfflineMsg }

procedure TPcOfflineMsg.SetNetPcOffline;
begin
  NetworkPcApi.PcOffline( PcID );
end;

function TPcOfflineMsg.getMsgType: string;
begin
  Result := MsgType_PcStatus_Offline;
end;

procedure TPcOfflineMsg.Update;
begin
    // ����״̬
  SetNetPcOffline;
end;

{ TPcOnlineMsgBase }

procedure TPcOnlineMsgBase.SendConfirmConect;
var
  MasterSendConfirmConnectInfo : TMasterSendConfirmConnectInfo;
begin
  MasterSendConfirmConnectInfo := TMasterSendConfirmConnectInfo.Create( PcID );
  MasterSendConfirmConnectInfo.SetSocketInfo( LanIp, LanPort );
  MasterSendConfirmConnectInfo.SetInternetSocket( InternetIp, InternetPort );
  MyMasterSendHandler.AddMasterSend( MasterSendConfirmConnectInfo );
end;

procedure TPcOnlineMsgBase.SetAccount(_Account: string);
begin
  Account := _Account;
end;

procedure TPcOnlineMsgBase.SetInternetSocket(_InternetIp,
  _InternetPort: string);
begin
  InternetIp := _InternetIp;
  InternetPort := _InternetPort;
end;

procedure TPcOnlineMsgBase.SetLanSocket(_LanIp, _LanPort: string);
begin
  LanIp := _LanIp;
  LanPort := _LanPort;
end;

procedure TPcOnlineMsgBase.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TPcOnlineMsgBase.Update;
begin
    // ��� Pc ��Ϣ
  NetworkPcApi.AddItem( PcID, PcName );

    // δ������ӣ�����ȷ������
  if not MyNetPcInfoReadUtil.ReadIsConnect( PcID ) then
    SendConfirmConect;
end;

{ TPcMsgBase }

procedure TPcMsgBase.SetPcID(_PcID: string);
begin
  PcID := _PcID;
end;

{ TSendServerMsgThread }

procedure TClientSendMsgThread.AddSendMsg(MsgStr: string);
begin
  MsgLock.Enter;
  SendMsgList.Add( MsgStr );
  MsgLock.Leave;

  Resume;
end;

constructor TClientSendMsgThread.Create( _TcpSocket : TCustomIpClient );
begin
  inherited Create;

  TcpSocket := _TcpSocket;
  MsgLock := TCriticalSection.Create;
  SendMsgList := TStringList.Create;
end;

destructor TClientSendMsgThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  SendMsgList.Free;
  MsgLock.Free;
  inherited;
end;

procedure TClientSendMsgThread.Execute;
var
  MsgStr : string;
begin
  while not Terminated do
  begin
    MsgStr := getNextMsg;
    if MsgStr = '' then
    begin
      if not Terminated then
        Suspend;
      Continue;
    end;
    SendMsg( MsgStr );
  end;

  inherited;
end;

function TClientSendMsgThread.getNextMsg: string;
begin
  MsgLock.Enter;
  if SendMsgList.Count > 0 then
  begin
    Result := SendMsgList[0];
    SendMsgList.Delete(0);
  end
  else
    Result := '';
  MsgLock.Leave;
end;

procedure TClientSendMsgThread.SendMsg(MsgStr: string);
begin
  if MsgStr <> '' then
    MySocketUtil.SendString( TcpSocket, MsgStr );
end;

{ TAdvancePcConnMsg }

procedure TAdvancePcConnMsg.AddNetworkPc;
begin
  NetworkPcApi.AddItem( ConnPcID, ConnPcName );
end;

procedure TAdvancePcConnMsg.AddPingMsg;
var
  MasterSendInternetPingInfo : TMasterSendInternetPingInfo;
begin
    // ���� Ping ����
  MasterSendInternetPingInfo := TMasterSendInternetPingInfo.Create( ConnPcID );
  MasterSendInternetPingInfo.SetSocketInfo( LanIp, LanPort );
  MasterSendInternetPingInfo.SetInternetSocket( InternetIp, InternetPort );
  MyMasterSendHandler.AddMasterSend( MasterSendInternetPingInfo );
end;

function TAdvancePcConnMsg.getMsgType: string;
begin
  Result := MsgType_AdvancePc;
end;

procedure TAdvancePcConnMsg.SetConnPcInfo(_ConnPcID, _ConnPcName: string);
begin
  ConnPcID := _ConnPcID;
  ConnPcName := _ConnPcName;
end;

procedure TAdvancePcConnMsg.SetInternetSocket(_InternetIp,
  _InternetPort: string);
begin
  InternetIp := _InternetIp;
  InternetPort := _InternetPort;
end;

procedure TAdvancePcConnMsg.SetLanSocket(_LanIp, _LanPort: string);
begin
  LanIp := _LanIp;
  LanPort := _LanPort;
end;

procedure TAdvancePcConnMsg.Update;
begin
  AddNetworkPc;
  AddPingMsg;
end;

{ TAdvanceConnMsgFactory }

constructor TAdvanceConnMsgFactory.Create;
begin
  inherited Create( MsgType_AdvancePc );
end;

function TAdvanceConnMsgFactory.get: TMsgBase;
begin
  if MsgType = MsgType_AdvancePc then
    Result := TAdvancePcConnMsg.Create
  else
    Result := nil;
end;

{ TNetworkBackupChangeMsg }

procedure TNetworkBackupChangeMsg.SetAccount(_Account: string);
begin
  Account := _Account;
end;

procedure TNetworkBackupChangeMsg.SetBackupPath(_BackupPath: string);
begin
  BackupPath := _BackupPath;
end;

{ TNetworkBackupAddMsg }

function TNetworkBackupAddCloudMsg.getMsgType: string;
begin
  Result := MsgType_NetworkBackup_AddBackupItem;
end;

procedure TNetworkBackupAddCloudMsg.Update;
var
  Params : TCloudAddBackupParams;
begin
  inherited;

  Params.CloudPath := CloudPath;
  Params.OwnerID := PcID;
  Params.BackupPath := BackupPath;
  Params.IsFile := IsFile;
  Params.FileCount := FileCount;
  Params.FileSpace := FileSize;
  Params.LastDateTime := LastBackupTime;
  Params.IsSaveDeleted := IsSaveDeleted;
  Params.IsEncrypted := IsEncrypted;
  Params.Password := Password;
  Params.PasswordHint := PasswordHint;
  Params.Account := Account;

    // ��ӵ���·��
  MyCloudPcBackupAppApi.AddItem( Params );

    // ��ӵ��ʺŰ�
  NetworkAccountApi.AddAccountPath( Account, BackupPath );
end;

{ TNetworkBackupRemoveMsg }

function TNetworkBackupRemoveCloudMsg.getMsgType: string;
begin
  Result := MsgType_NetworkBackup_RemoveBackupItem;
end;

procedure TNetworkBackupRemoveCloudMsg.Update;
begin
  inherited;

  MyCloudPcBackupAppApi.RemoveItem( CloudPath, PcID, BackupPath );

    // ɾ���ʺŰ�
  NetworkAccountApi.RemoveAccountPath( Account, BackupPath );
end;

{ TNetworkBackupMsgFactory }

constructor TNetworkBackupMsgFactory.Create;
begin
  inherited Create( MsgType_NetworkBackup );
end;

function TNetworkBackupMsgFactory.get: TMsgBase;
begin
  if MsgType = MsgType_NetworkBackup_AddCloudItem then
    Result := TCloudPathAddMsg.Create
  else
  if MsgType = MsgType_NetworkBackup_RemoveCloudItem then
    Result := TCloudPathRemoveMsg.Create
  else
  if MsgType = MsgType_NetworkBackup_AddBackupItem then
    Result := TNetworkBackupAddCloudMsg.Create
  else
  if MsgType = MsgType_NetworkBackup_SetCloudAvailableSpace then
    Result := TCloudPathSetAvailableSpaceMsg.Create
  else
  if MsgType = MsgType_NetworkBackup_RemoveBackupItem then
    Result := TNetworkBackupRemoveCloudMsg.Create
  else
  if MsgType = MsgType_NetworkBackup_AddRestoreItem then
    Result := TCloudBackupAddRestoreMsg.Create
  else
  if MsgType = MsgType_NetworkBackup_RemoveRestoreItem then
    Result := TCloudBackupRemoveRestoreMsg.Create
  else
  if MsgType = MsgType_NetworkBackup_BackupBackConn then
    Result := TBackupItemBackConnMsg.Create
  else
  if MsgType = MsgType_NetworkBackup_BackupBackConnBusy then
    Result := TBackupItemBackConnBusyMsg.Create
  else
  if MsgType = MsgType_NetworkBackup_BackupBackConnError then
    Result := TBackupItemBackConnErrorMsg.Create
  else
  if MsgType = MsgType_NetworkBackup_RestoreBackConn then
    Result := TRestoreItemBackConnMsg.Create
  else
  if MsgType = MsgType_NetworkBackup_RestoreBackConnBusy then
    Result := TRestoreItemBackConnBusyMsg.Create
  else
  if MsgType = MsgType_NetworkBackup_RestoreBackConnError then
    Result := TRestoreItemBackConnErrorMsg.Create
  else
    Result := nil;
end;

{ TNetworkBackupWriteMsg }

procedure TNetworkBackupAddMsg.SetEncryptInfo(_IsEncrypted: Boolean; _Password,
  _PasswordHint: string);
begin
  IsEncrypted := _IsEncrypted;
  Password := _Password;
  PasswordHint := _PasswordHint;
end;

procedure TNetworkBackupAddMsg.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TNetworkBackupAddMsg.SetIsSaveDeleted(_IsSaveDeleted: Boolean);
begin
  IsSaveDeleted := _IsSaveDeleted;
end;

procedure TNetworkBackupAddMsg.SetLastBackupTime(_LastBackupTime: TDateTime);
begin
  LastBackupTime := _LastBackupTime;
end;

procedure TNetworkBackupAddMsg.SetSpaceInfo(_FileCount: Integer;
  _FileSize: Int64);
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
end;

{ TCloudBackupAddRestoreMsg }

function TCloudBackupAddRestoreMsg.getMsgType: string;
begin
  Result := MsgType_NetworkBackup_AddRestoreItem;
end;

procedure TCloudBackupAddRestoreMsg.SetOwnerInfo(_OwnerID, _OwnerName: string);
begin
  OwnerID := _OwnerID;
  OwnerName := _OwnerName;
end;

procedure TCloudBackupAddRestoreMsg.Update;
var
  Params : TRestoreAddParams;
begin
  inherited;

  Params.DesItemID := NetworkDesItemUtil.getDesItemID( PcID, CloudPath );
  Params.BackupPath := BackupPath;
  Params.OwnerID := OwnerID;
  Params.OwnerName := OwnerName;
  Params.IsFile := IsFile;
  Params.FileCount := FileCount;
  Params.ItemSize := FileSize;
  Params.LastBackupTime := LastBackupTime;
  Params.IsSaveDeleted := IsSaveDeleted;
  Params.IsEncrypted := IsEncrypted;
  Params.Password := Password;
  Params.PasswordHint := PasswordHint;

  RestoreItemAppApi.AddNetworkItem( Params );
end;

{ TCloudBackupRemoveRestoreMsg }

function TCloudBackupRemoveRestoreMsg.getMsgType: string;
begin
  Result := MsgType_NetworkBackup_RemoveRestoreItem;
end;

procedure TCloudBackupRemoveRestoreMsg.SetOwnerID(_OwnerID: string);
begin
  OwnerID := _OwnerID;
end;

procedure TCloudBackupRemoveRestoreMsg.Update;
var
  DesItemID : string;
begin
  inherited;

  DesItemID := NetworkDesItemUtil.getDesItemID( PcID, CloudPath );
  RestoreItemAppApi.RemoveNetworkItem( DesItemID, BackupPath, OwnerID );
end;

{ TCloudPathChangeMsg }

procedure TCloudPathChangeMsg.SetCloudPath(_CloudPath: string);
begin
  CloudPath := _CloudPath;
end;

{ TCloudPathAddMsg }

function TCloudPathAddMsg.getMsgType: string;
begin
  Result := MsgType_NetworkBackup_AddCloudItem;
end;

procedure TCloudPathAddMsg.SetAvailableSpace(_AvailableSpace: Int64);
begin
  AvailableSpace := _AvailableSpace;
end;

procedure TCloudPathAddMsg.Update;
var
  DesItemID : string;
begin
  inherited;

  DesItemID :=  NetworkDesItemUtil.getDesItemID( PcID, CloudPath );

  DesItemAppApi.AddNetworkItem( DesItemID, AvailableSpace );

  RestoreDesAppApi.AddNetworkItem( DesItemID );
end;

{ TCloudPathRemoveMsg }

function TCloudPathRemoveMsg.getMsgType: string;
begin
  Result := MsgType_NetworkBackup_RemoveCloudItem;
end;

procedure TCloudPathRemoveMsg.Update;
var
  DesItemID : string;
begin
  inherited;

  DesItemID :=  NetworkDesItemUtil.getDesItemID( PcID, CloudPath );
    // ���û�б��ݣ���ɾ��
  if not BackupItemInfoReadUtil.ReadExistBackup( DesItemID ) then
    DesItemUserApi.RemoveNetworkItem( DesItemID );
  RestoreDesAppApi.RemoveNetworkItem( DesItemID );
end;

{ TPcHeartBeatMsg }

function TPcHeartBeatMsg.getMsgType: string;
begin
  Result := MsgType_PcStatus_HeartBeat;
end;

procedure TPcHeartBeatMsg.Update;
begin
  inherited;

end;

{ TCloudPathSetAvailableSpaceMsg }

function TCloudPathSetAvailableSpaceMsg.getMsgType: string;
begin
  Result := MsgType_NetworkBackup_SetCloudAvailableSpace;
end;

procedure TCloudPathSetAvailableSpaceMsg.SetAvailableSpace(
  _AvailableSpace: Int64);
begin
  AvailableSpace := _AvailableSpace;
end;

procedure TCloudPathSetAvailableSpaceMsg.Update;
var
  DesItemID : string;
begin
  inherited;

  DesItemID :=  NetworkDesItemUtil.getDesItemID( PcID, CloudPath );

    // �Ǳ���
  if PcID <> PcInfo.PcID then
    DesItemAppApi.SetNetworkAvaialbleSpace( DesItemID, AvailableSpace );
end;

{ TPcBatRegisterMsg }

procedure TActivatePcMsg.FeedBack;
var
  ActivatePcCompletedMsg : TActivatePcCompletedMsg;
begin
  ActivatePcCompletedMsg := TActivatePcCompletedMsg.Create;
  ActivatePcCompletedMsg.SetPcID( PcInfo.PcID );
  MyClient.SendMsgToPc( PcID, ActivatePcCompletedMsg );
end;

function TActivatePcMsg.getMsgType: string;
begin
  Result := MsgType_Register_ActivatePc;
end;

procedure TActivatePcMsg.SetLicenseStr(_LicenseStr: string);
begin
  LicenseStr := _LicenseStr;
end;

procedure TActivatePcMsg.Update;
begin
  MyRegisterUserApi.SetLicense( LicenseStr );

  FeedBack;
end;

{ TRegisterShowMsg }

function TRegisterShowMsg.getMsgType: string;
begin
  Result := MsgType_Register_RegisterShow;
end;

procedure TRegisterShowMsg.SetHardCode(_HardCode: string);
begin
  HardCode := _HardCode;
end;

procedure TRegisterShowMsg.SetRegisterEdition(_RegisterEdition: string);
begin
  RegisterEdition := _RegisterEdition;
end;

procedure TRegisterShowMsg.Update;
begin
  RegisterShowAppApi.AddItem( PcID, HardCode, RegisterEdition );
end;

{ TActivatePcCompletedMsg }

function TActivatePcCompletedMsg.getMsgType: string;
begin
  Result := MsgType_Register_ActivatePcCompeted;
end;

procedure TActivatePcCompletedMsg.Update;
begin
  RegisterActivatePcApi.RemoveItem( PcID );
end;

{ TPcHeartBeatMsgFactory }

constructor TRegisterMsgFactory.Create;
begin
  inherited Create( MsgType_Register );
end;

function TRegisterMsgFactory.get: TMsgBase;
begin
  if MsgType = MsgType_Register_ActivatePc then
    Result := TActivatePcMsg.Create
  else
  if MsgType = MsgType_Register_ActivatePcCompeted then
    Result := TActivatePcCompletedMsg.Create
  else
  if MsgType = MsgType_Register_RegisterShow then
    Result := TRegisterShowMsg.Create
  else
    Result := nil;
end;

{ TSendItemBackConnMsg }

function TBackupItemBackConnMsg.getMsgType: string;
begin
  Result := MsgType_NetworkBackup_BackupBackConn;
end;

procedure TBackupItemBackConnMsg.Update;
begin
  MyCloudPathAppApi.AddBackConnBackup( PcID );
end;

{ TSendItemBackConnBusyMsg }

function TBackupItemBackConnBusyMsg.getMsgType: string;
begin
  Result := MsgType_NetworkBackup_BackupBackConnBusy;
end;

procedure TBackupItemBackConnBusyMsg.Update;
begin
  MyBackupFileConnectHandler.BackConnBusy;
end;

{ TSendItemBackConnErrorMsg }

function TBackupItemBackConnErrorMsg.getMsgType: string;
begin
  Result := MsgType_NetworkBackup_BackupBackConnError;
end;

procedure TBackupItemBackConnErrorMsg.Update;
begin
  MyBackupFileConnectHandler.BackConnError;
end;

{ TSendItemBackConnMsg }

function TRestoreItemBackConnMsg.getMsgType: string;
begin
  Result := MsgType_NetworkBackup_RestoreBackConn;
end;

procedure TRestoreItemBackConnMsg.Update;
begin
  MyCloudPathAppApi.AddBackConnRestore( PcID );
end;

{ TSendItemBackConnBusyMsg }

function TRestoreItemBackConnBusyMsg.getMsgType: string;
begin
  Result := MsgType_NetworkBackup_RestoreBackConnBusy;
end;

procedure TRestoreItemBackConnBusyMsg.Update;
begin
  MyRestoreDownConnectHandler.BackConnBusy;
end;

{ TSendItemBackConnErrorMsg }

function TRestoreItemBackConnErrorMsg.getMsgType: string;
begin
  Result := MsgType_NetworkBackup_RestoreBackConnError;
end;

procedure TRestoreItemBackConnErrorMsg.Update;
begin
  MyRestoreDownConnectHandler.BackConnError;
end;

{ MyClientOnTimerAp }

class procedure MyClientOnTimerApi.SendHeartBeat;
var
  ClientHeartBeatHandle : TClientHeartBeatHandle;
begin
    // �ѽ���
  if not MyClient.IsRun then
    Exit;

  ClientHeartBeatHandle := TClientHeartBeatHandle.Create;
  ClientHeartBeatHandle.Update;
  ClientHeartBeatHandle.Free;
end;

{ TClientHeartBeatHandle }

procedure TClientHeartBeatHandle.SendCloudAvailableSpace;
var
  CloudPathList : TStringList;
  i: Integer;
  CloudPath : string;
  AvailableSpace : Int64;
  CloudPathSetAvailableSpaceMsg : TCloudPathSetAvailableSpaceMsg;
begin
  CloudPathList := MyCloudInfoReadUtil.ReadCloudPathList;
  for i := 0 to CloudPathList.Count - 1 do
  begin
    CloudPath := CloudPathList[i];
    AvailableSpace := MyHardDisk.getHardDiskFreeSize( CloudPath );
    CloudPathSetAvailableSpaceMsg := TCloudPathSetAvailableSpaceMsg.Create;
    CloudPathSetAvailableSpaceMsg.SetCloudPath( CloudPath );
    CloudPathSetAvailableSpaceMsg.SetAvailableSpace( AvailableSpace );
    CloudPathSetAvailableSpaceMsg.SetPcID( PcInfo.PcID );
    MyClient.SendMsgToAll( CloudPathSetAvailableSpaceMsg );
  end;
  CloudPathList.Free;
end;

procedure TClientHeartBeatHandle.SendHeartBeat;
var
  PcHeartBeatMsg : TPcHeartBeatMsg;
begin
  PcHeartBeatMsg := TPcHeartBeatMsg.Create;
  PcHeartBeatMsg.SetPcID( PcInfo.PcID );
  MyClient.SendMsgToAll( PcHeartBeatMsg );
end;

procedure TClientHeartBeatHandle.Update;
begin
    // ��������
  SendHeartBeat;

    // ���Ϳ��ÿռ���Ϣ
  SendCloudAvailableSpace;
end;

{ TServerInfoMsg }

function TServerInfoMsg.getMsgType: string;
begin
  Result := MsgType_ServerInfo;
end;

procedure TServerInfoMsg.SetInternetInfo(_ServerInternetIp,
  _ServerInternetPort: string);
begin
  ServerInternetIp := _ServerInternetIp;
  ServerInternetPort := _ServerInternetPort;
end;

procedure TServerInfoMsg.SetLanInfo(_ServerLanIp, _ServerLanPort: string);
begin
  ServerLanIp := _ServerLanIp;
  ServerLanPort := _ServerLanPort;
end;

procedure TServerInfoMsg.SetServerPcID(_ServerPcID: string);
begin
  ServerPcID := _ServerPcID;
end;

end.

