unit UBackupCow;

interface

uses Forms, Windows, SysUtils, Classes, xmldom, XMLIntf, msxmldom, XMLDoc, ActiveX, uDebug, IniFiles;

type

    // ��ȡ Xml ��Ϣ
  TMyXmlReadHandle = class
  public
    procedure Update;
  private
    procedure ReadMyPcXml;
    procedure ReacNetPcXml;
    procedure ReadBackupXml;
    procedure ReadCloudXml;
    procedure ReadLocalRestoreXml;
    procedure ReadRestoreDownXml;
    procedure ReadRegisterXml;
    procedure ReadBackupAnalyzeXml;
  private
    procedure AddDefaultRegisterInfo;
    procedure AddDefaultPcInfo;
    procedure AddDefaultNetworkConnInfo;
    procedure AddDefaultLocalDes;
    procedure AddDefaultCloudPath;
    procedure AddTrialInfoToWeb;
  end;

  TestUtil = class
  public
    class procedure TestTrial;
  end;

    // BackupCow ����
  TBackupCowCreate = class
  public
    procedure Update;
  private
    procedure CreateSettingInfo;
    procedure CreateWriteXml;
    procedure CreateWriteFace;
  private
    procedure CreateMain;
    procedure CreateRegister;
    procedure CreateBackup;
    procedure CreateCloud;
    procedure CreateRestore;
    procedure CreateNetwork;
  private
    procedure LoadSetting;
    procedure ReadXml;
    procedure StartNetwork;
    procedure MarkAppRunTime;
    procedure LoadRarDllFile;
    procedure CheckForUpdate;
  end;

    // BackupCow ����
  TBackupCowDestory = class
  public
    procedure Update;
  private
    procedure StopWriteThread;
  private
    procedure DestoryNetwork;
    procedure DestoryResotre;
    procedure DestoryCloud;
    procedure DestoryBackup;
    procedure DestoryRegister;
    procedure DestoryMain;
  private
    procedure DestoryWriteFace;
    procedure DestoryWriteXml;
    procedure DestorySettingInfo;
  end;

      // ��¼��������ʱ��
  MyBackupCowAutoApi = class
  public
    class procedure MarkAppRunTime;
    class procedure DownloadRarDllFile;
    class procedure CheckForUpdate;
  end;

    // BackupCow ���ĳ���
  TBackupCow = class
  public
    constructor Create;
    destructor Destroy; override;
  end;

const
  HttpMarkApp_HardCode = 'HardCode';
  HttpMarkApp_PcID = 'PcID';
  HttpMarkApp_PcName = 'PcName';
  HttpMarkApp_LocalBackup = 'LocalBackup';
  HttpMarkApp_NetworkBackup = 'NetworkBackup';
  HttpMarkApp_NetworkMode = 'NetworkMode';
  HttpMarkApp_NetworkPc = 'NetworkPc';
  HttpMarkApp_AdsShowCount = 'AdsShowCount';
  HttpMarkApp_BackupAnalyze = 'BackupAnalyze';
  HttpMarkApp_Account = 'Account';

const
  HttpReqTrial_HardCode = 'HardCode';
  HttpReqTrial_PcName = 'PcName';
  HttpReqTrial_PcID = 'PcID';
  HttpReqTrial_Account = 'Account';

var
  BackupCow : TBackupCow;

implementation

uses
     UMyBackupDataInfo, UMyBackupApiInfo, UMyBackupXmlInfo, UBackupThread, UAutoBackupThread,
     UMyCloudDataInfo, UMyCloudXmlInfo, UCloudThread, UMyCloudApiInfo,
     UMyRestoreDataInfo, UMyRestoreXmlInfo, URestoreThread, UMyRestoreApiInfo, UAutoRestoreThread,
     UMyNetPcInfo, UNetworkControl, USearchServer, UNetworkFace, UNetPcInfoXml,
     UMyMaster, UMyServer, UMyClient, UMyTcp, UMainFormThread,
     UPortMap, URegisterThread, UMyRegisterDataInfo, UMyRegisterXmlInfo, UMyRegisterApiInfo, UAppEditionInfo,
     UXmlUtil, UMainForm, uLkJSON, UMyUtil, UChangeInfo, UMyUrl, UAppSplitEdition,
     USettingInfo, UFormSetting, UMainFormFace, IdHTTP, UMyTimerThread, UMyRestoreFaceInfo, UUserApiInfo;

{ TBackupCowCreate }

procedure TBackupCowCreate.CreateRegister;
begin
  MyRegisterInfo := TMyRegisterInfo.Create;

  MyRegisterExpiredHandler := TMyRegisterExpiredHandler.Create;
end;

procedure TBackupCowCreate.CreateRestore;
begin
  MyRestoreDownInfo := TMyRestoreDownInfo.Create;

  MyRestoreHandler := TMyRestoreDownHandler.Create;

  MyRestoreExplorerHandler := TMyRestoreExplorerHandler.Create;

  MyRestoreSearchHandler := TMyRestoreSearchHandler.Create;

  MyRestorePreviewHandler := TMyRestorePreviewHandler.Create;

  MyRestoreDownConnectHandler := TMyRestoreDownConnectHandler.Create;
end;

procedure TBackupCowCreate.CheckForUpdate;
begin
      // �Ƴ���ʱ��
  MyTimerHandler.AddTimer( HandleType_CheckForUpdate, 5 );
end;

procedure TBackupCowCreate.CreateBackup;
begin
    // ���ݽṹ
  MyBackupInfo := TMyBackupInfo.Create;

    // �����߳�
  MyBackupHandler := TMyBackupHandler.Create;

    // ��־�߳�
  MyBackupLogHandler := TMyBackupLogHandler.Create;

    // ��������
  MyBackupFileConnectHandler := TMyBackupFileConnectHandler.Create;
end;

procedure TBackupCowCreate.CreateCloud;
begin
    // ���ݽṹ
  MyCloudInfo := TMyCloudInfo.Create;

    // �Ʊ����߳�
  MyCloudFileHandler := TMyCloudFileHandler.Create;
end;

procedure TBackupCowCreate.CreateMain;
begin
  MyRefreshSpeedHandler := TMyRefreshSpeedHandler.Create;

  MyTimerHandler := TMyTimerHandler.Create;
end;

procedure TBackupCowCreate.CreateNetwork;
begin
    // ������ Pc ��Ϣ
  PcInfo := TPcInfo.Create;
  Randomize;
  PcInfo.SetSortInfo( Now, Random( 1000000 ) );
  PcInfo.SetPcHardCode( MyMacAddress.getStr );

    // �������ӷ�ʽ
  MyNetworkConnInfo := TMyNetworkConnInfo.Create;

    // Master ��Ϣ
  MasterInfo := TMasterInfo.Create;

    // �������� ���ݽṹ
  MyNetPcInfo := TMyNetPcInfo.Create;

    // �ʺ���Ϣ ���ݽṹ
  MyAccountInfo := TMyAccountInfo.Create;

      // C/S ����
  MyServer := TMyServer.Create;
  MyClient := TMyClient.Create;

    // �������� ���������
  MyMasterSendHandler := TMyMasterSendHandler.Create;
  MyMasterReceiveHanlder := TMyMasterReceiveHandler.Create;

    // ��������
  MyListener := TMyListener.Create;

    // ����������
  MySearchMasterHandler := TMySearchMasterHandler.Create;
end;

procedure TBackupCowCreate.ReadXml;
var
  MyXmlReadHandle : TMyXmlReadHandle;
begin
  try
    MyXmlReadHandle := TMyXmlReadHandle.Create;
    MyXmlReadHandle.Update;
    MyXmlReadHandle.Free;
  except
  end;
end;

procedure TBackupCowCreate.StartNetwork;
begin
   // ���� Master
  MySearchMasterHandler.StartRun;
end;

procedure TBackupCowCreate.CreateSettingInfo;
begin
  CloudSafeSettingInfo := TCloudSafeSettingInfo.Create;
  ApplicationSettingInfo := TApplicationSettingInfo.Create;
  HintSettingInfo := THintSettingInfo.Create;
end;

procedure TBackupCowCreate.CreateWriteFace;
begin
    // ���� ���� �ܿ�����
  MyFaceChange := TMyFaceChange.Create;
end;

procedure TBackupCowCreate.CreateWriteXml;
begin
  try   // Xml ���ĵ� ��ʼ��
    MyXmlDoc := frmMainForm.XmlDoc;
    MyXmlDoc.Active := True;
    if FileExists( MyXmlUtil.getXmlPath ) then
      MyXmlDoc.LoadFromFile( MyXmlUtil.getXmlPath );
    MyXmlUtil.IniXml;
  except
  end;

    // Xml ��ʼ��
  MyXmlChange := TMyXmlChange.Create;
end;

procedure TBackupCowCreate.LoadRarDllFile;
begin
  MyTimerHandler.AddTimer( HandleType_DownloadRarDll, 10 );  // ���� Rar �ļ�
end;

procedure TBackupCowCreate.LoadSetting;
begin
  try
    frmSetting.LoadIni;
    frmSetting.SetFirstApplySettings;
  except
  end;
end;

procedure TBackupCowCreate.MarkAppRunTime;
begin
  MyTimerHandler.AddTimer( HandleType_MarkAppRunTime, 30 );  // ��¼����������Ϣ
end;

procedure TBackupCowCreate.Update;
begin
  CreateSettingInfo;  // Setting ��Ϣ
  CreateWriteXml;  // д Xml ��Ϣ
  CreateWriteFace; // д �������

  CreateMain;
  CreateRegister;
  CreateBackup;
  CreateCloud;  // ����Ϣ
  CreateRestore;
  CreateNetwork; // ������Ϣ

  LoadSetting;  // ���� Setting ����
  ReadXml;  // �� Xml ��Ϣ
  StartNetwork;
  MarkAppRunTime;
  LoadRarDllFile;
  CheckForUpdate;
  MyAppPiracyAutoApi.CheckIsPiracy; // ����Ƿ����
  MyTimerHandler.StartRun; // ������ʱ�߳�
end;

{ TBackupCowDestory }

procedure TBackupCowDestory.DestoryBackup;
begin
  MyBackupFileConnectHandler.Free;
  MyBackupLogHandler.Free;
  MyBackupHandler.Free;
  MyBackupInfo.Free;
end;

procedure TBackupCowDestory.DestoryCloud;
begin
  MyCloudFileHandler.Free;
  MyCloudInfo.Free;
end;

procedure TBackupCowDestory.DestoryMain;
begin
  MyTimerHandler.Free;
  MyRefreshSpeedHandler.Free;
end;

procedure TBackupCowDestory.DestoryNetwork;
begin
    // ֹͣ ���� Mster �߳�
  MySearchMasterHandler.Free;

    // �ر� �����˿�
  MyListener.Free;

  MyMasterReceiveHanlder.Free;
  MyMasterSendHandler.Free;

  MyClient.Free;
  MyServer.Free;

  MyAccountInfo.Free;
  MyNetPcInfo.Free;
  MasterInfo.Free;
  MyNetworkConnInfo.Free;
  PcInfo.Free;
end;

procedure TBackupCowDestory.DestoryRegister;
begin
  MyRegisterExpiredHandler.Free;
  MyRegisterInfo.Free;
end;

procedure TBackupCowDestory.DestoryResotre;
begin
  MyRestoreDownConnectHandler.Free;
  MyRestorePreviewHandler.Free;
  MyRestoreExplorerHandler.Free;
  MyRestoreSearchHandler.Free;
  MyRestoreHandler.Free;
  MyRestoreDownInfo.Free;
end;

procedure TBackupCowDestory.DestorySettingInfo;
begin
  HintSettingInfo.Free;
  CloudSafeSettingInfo.Free;
  ApplicationSettingInfo.Free;
end;

procedure TBackupCowDestory.DestoryWriteFace;
begin
  MyFaceChange.Free;
end;

procedure TBackupCowDestory.DestoryWriteXml;
begin
    // ���� ���е� Xml ��Ϣ
  MyXmlChange.StopThread;
  MyXmlChange.Free;
end;

procedure TBackupCowDestory.StopWriteThread;
begin
    // ֹͣ ����������
  MySearchMasterHandler.StopRun;

    // ֹͣ ��������
  MyListener.StopRun; // ֹͣ��������

      // ֹͣ �������������Ӵ���
  MyMasterSendHandler.StopRun;
  MyMasterReceiveHanlder.StopRun;

  MyClient.StopRun;  // �Ͽ��ͻ���
  MyServer.StopRun;  // �Ͽ�������

  MyFaceChange.StopThread; // ֹͣ�������

    // ֹͣɨ��
  MyTimerHandler.StopRun;
  MyRegisterExpiredHandler.StopRun;

    // ֹͣ�����߳�
  MyBackupFileConnectHandler.StopRun;
  MyBackupHandler.StopScan;
  MyBackupLogHandler.StopScan;

    // ֹͣ���߳�
  MyCloudFileHandler.StopRun;

  MyRestoreDownConnectHandler.StopRun;
  MyRestoreExplorerHandler.StopRun;
  MyRestoreSearchHandler.StopRun;
  MyRestoreHandler.StopRun;
  MyRefreshSpeedHandler.StopRun;
end;

procedure TBackupCowDestory.Update;
begin
  StopWriteThread;

  DestoryNetwork;
  DestoryResotre;
  DestoryCloud;
  DestoryBackup;
  DestoryRegister;
  DestoryMain;

  DestoryWriteFace;
  DestoryWriteXml;
  DestorySettingInfo;
end;

{ TBackupCow }

constructor TBackupCow.Create;
var
  BackupCowCreate : TBackupCowCreate;
begin
  try
    BackupCowCreate := TBackupCowCreate.Create;
    BackupCowCreate.Update;
    BackupCowCreate.Free;
  except
  end;
end;

destructor TBackupCow.Destroy;
var
  BackupCowDestory : TBackupCowDestory;
begin
  try
    BackupCowDestory := TBackupCowDestory.Create;
    BackupCowDestory.Update;
    BackupCowDestory.Free;
  except
  end;

  inherited;
end;

{ TMyXmlReadHandle }

procedure TMyXmlReadHandle.AddDefaultCloudPath;
var
  CloudPath : string;
begin
  CloudPath := MyHardDisk.getBiggestHardDIsk + 'BackupCow.Backup';
  MyCloudPathUserApi.AddItem( CloudPath );
end;

procedure TMyXmlReadHandle.AddDefaultLocalDes;
var
  LocalDesPath : string;
begin
  LocalDesPath := MyHardDisk.getBiggestHardDIsk + 'BackupCow.LocalBackup';
//  DesItemUserApi.AddLocalItem( LocalDesPath );
end;

procedure TMyXmlReadHandle.AddDefaultNetworkConnInfo;
begin
  NetworkModeApi.SelectLocalNetwork;
end;

procedure TMyXmlReadHandle.AddDefaultPcInfo;
var
  PcID, PcName : string;
  LanIp, LanPort, InternetPort : string;
  MyPcInfoFirstSetHandle : TMyPcInfoFirstSetHandle;
begin
  PcID := MyComputerID.get;
  PcName := MyComputerName.get;
  LanIp := MyIp.get;
  LanPort := '9494';
  InternetPort := MyUpnpUtil.getUpnpPort( LanIp );

  MyPcInfoFirstSetHandle := TMyPcInfoFirstSetHandle.Create( PcID, PcName );
  MyPcInfoFirstSetHandle.SetSocketInfo( LanIp, LanPort, InternetPort );
  MyPcInfoFirstSetHandle.Update;
  MyPcInfoFirstSetHandle.Free;
end;

procedure TMyXmlReadHandle.AddDefaultRegisterInfo;
begin
  MyRegisterUserApi.SetLicense( '' );
end;

procedure TMyXmlReadHandle.AddTrialInfoToWeb;
var
  Url, HardCode, PcName, PcID, LicenseStr : string;
  IdHttp : TIdHTTP;
  ParamList : TStringList;
  TrialToFreeSetXml : TTrialToFreeSetXml;
  i: Integer;
  IsSuccess : Boolean;
begin
  Url := MyUrl.getTrialKey;
  HardCode := MyMacAddress.getStr;
  PcName := MyComputerName.get;
  PcID := MyComputerID.get;

  ParamList := TStringList.Create;
  ParamList.Add( HttpReqTrial_HardCode + '=' + HardCode );
  ParamList.Add( HttpReqTrial_PcID + '=' + PcID );
  ParamList.Add( HttpReqTrial_PcName + '=' + PcName );
  ParamList.Add( HttpReqTrial_Account + '=Server' );
  for i := 1 to 5 do  // ��������Ͽ�ԭ����Ҫ��λ�ȡ������
  begin
    IdHttp := TIdHTTP.Create(nil);
    IdHttp.ConnectTimeout := 30000;
    idhttp.ReadTimeout := 30000;
    try
      LicenseStr := IdHttp.Post( Url, ParamList );
      IsSuccess := True;
    except
      IsSuccess := False;
    end;
    IdHttp.Free;
      // �ɹ�����
    if IsSuccess then
      Break;
  end;
  ParamList.Free;

    // ��ȡ������ʧ��
  if not IsSuccess then
    Exit;

    // ����������
  MyRegisterUserApi.SetLicense( LicenseStr );

    // ���ù���ʱ��ʾ������Ϣ
  try
    TrialToFreeSetXml := TTrialToFreeSetXml.Create;
    TrialToFreeSetXml.SetIsShow( True );
    TrialToFreeSetXml.AddChange;
  except
  end;
end;

procedure TMyXmlReadHandle.ReacNetPcXml;
var
  NetPcXmlRead : TNetPcXmlRead;
  AccountXmlRead : TAccountXmlRead;
  NetworkModeXmlRead : TNetworkModeXmlRead;
begin
  try
    NetPcXmlRead := TNetPcXmlRead.Create;
    NetPcXmlRead.Update;
    NetPcXmlRead.Free;
  except
  end;

  try
    AccountXmlRead := TAccountXmlRead.Create;
    AccountXmlRead.Update;
    AccountXmlRead.Free;
  except
  end;

  try
    NetworkModeXmlRead := TNetworkModeXmlRead.Create;
    NetworkModeXmlRead.Update;
    NetworkModeXmlRead.Free;
  except
  end;
end;

procedure TMyXmlReadHandle.ReadBackupAnalyzeXml;
var
  BackupMaxAnalyzeReadXml : TBackupMaxAnalyzeReadXml;
begin
  try
    BackupMaxAnalyzeReadXml := TBackupMaxAnalyzeReadXml.Create;
    BackupAnalyze_LastTime := BackupMaxAnalyzeReadXml.get;
    BackupMaxAnalyzeReadXml.Free;
  except
  end;
end;

procedure TMyXmlReadHandle.ReadBackupXml;
var
  BackupReadXmlHandle : TBackupReadXmlHandle;
begin
  try
    BackupReadXmlHandle := TBackupReadXmlHandle.Create;
    BackupReadXmlHandle.Update;
    BackupReadXmlHandle.Free;
  except
  end;

    // ����
  BackupItemAppApi.LocalOnlineBackup;

    // ���̼�� �Զ�����
  BackupItemAppApi.AutoBackupNowCheck;
end;

procedure TMyXmlReadHandle.ReadCloudXml;
var
  MyCloudInfoReadXml : TMyCloudInfoReadXml;
begin
  try
    MyCloudInfoReadXml := TMyCloudInfoReadXml.Create;
    MyCloudInfoReadXml.Update;
    MyCloudInfoReadXml.Free;
  except
  end;
end;

procedure TMyXmlReadHandle.ReadLocalRestoreXml;
var
  RestoreShowXmlReadHandle : TRestoreShowXmlReadHandle;
begin
  try
    RestoreShowXmlReadHandle := TRestoreShowXmlReadHandle.Create;
    RestoreShowXmlReadHandle.Update;
    RestoreShowXmlReadHandle.Free;
  except
  end;
end;

procedure TMyXmlReadHandle.ReadMyPcXml;
var
  MyPcXmlReadHandle : TMyPcXmlReadHandle;
begin
  try
    MyPcXmlReadHandle := TMyPcXmlReadHandle.Create;
    MyPcXmlReadHandle.Update;
    MyPcXmlReadHandle.Free;
  except
  end;
end;

procedure TMyXmlReadHandle.ReadRegisterXml;
var
  MyRegisterXmlRead : TMyRegisterXmlRead;
begin
  try
    MyRegisterXmlRead := TMyRegisterXmlRead.Create;
    MyRegisterXmlRead.Update;
    MyRegisterXmlRead.Free;
  except
  end;
end;

procedure TMyXmlReadHandle.ReadRestoreDownXml;
var
  MyRestoreDownReadXml : TMyRestoreDownReadXml;
begin
  try
    MyRestoreDownReadXml := TMyRestoreDownReadXml.Create;
    MyRestoreDownReadXml.Update;
    MyRestoreDownReadXml.Free;
  except

  end;

    // ��Ȿ�ؼ����ָ�
  RestoreDownAppApi.CheckLocalRestoreOnline;
end;

procedure TMyXmlReadHandle.Update;
begin
    // Xml �ļ����ڣ� ���ȡ Xml �ļ���Ϣ
  if FileExists( MyXmlUtil.getXmlPath ) then
  begin
    ReadMyPcXml;
    ReacNetPcXml;
    ReadRegisterXml;
    ReadBackupXml;
    ReadCloudXml;
    ReadLocalRestoreXml;
    ReadRestoreDownXml;
    ReadBackupAnalyzeXml;
  end
  else
  begin
    AddDefaultRegisterInfo;
    AddDefaultPcInfo;
    AddDefaultNetworkConnInfo;
    AddDefaultCloudPath;
    AddDefaultLocalDes;
    AddTrialInfoToWeb;
  end;
end;

{ TestUtil }

class procedure TestUtil.TestTrial;
var
  Url, HardCode, PcName, PcID, LicenseStr : string;
  IdHttp : TIdHTTP;
  ParamList : TStringList;
  TrialToFreeSetXml : TTrialToFreeSetXml;
  i: Integer;
  IsSuccess : Boolean;
begin
  Url := MyUrl.getTrialKey;
  HardCode := MyMacAddress.getStr;
  PcName := MyComputerName.get;
  PcID := MyComputerID.get;

  ParamList := TStringList.Create;
  ParamList.Add( HttpReqTrial_HardCode + '=' + HardCode );
  ParamList.Add( HttpReqTrial_PcID + '=' + PcID );
  ParamList.Add( HttpReqTrial_PcName + '=' + PcName );
  ParamList.Add( HttpReqTrial_Account + '=' + AppSplitEditionUtl.ReadAccount );
  for i := 1 to 5 do  // ��������Ͽ�ԭ����Ҫ��λ�ȡ������
  begin
    IdHttp := TIdHTTP.Create(nil);
    IdHttp.ConnectTimeout := 30000;
    idhttp.ReadTimeout := 30000;
    try
      LicenseStr := IdHttp.Post( Url, ParamList );
      IsSuccess := True;
    except
      IsSuccess := False;
    end;
    IdHttp.Free;
      // �ɹ�����
    if IsSuccess then
      Break;
  end;
  ParamList.Free;

    // ��ȡ������ʧ��
  if not IsSuccess then
    Exit;

    // ����������
  MyRegisterUserApi.SetLicense( LicenseStr );

    // ���ù���ʱ��ʾ������Ϣ
  try
    TrialToFreeSetXml := TTrialToFreeSetXml.Create;
    TrialToFreeSetXml.SetIsShow( True );
    TrialToFreeSetXml.AddChange;
  except
  end;
end;

{ MyBackupCowAutoApi }

class procedure MyBackupCowAutoApi.CheckForUpdate;
begin
    // �Ƴ���ʱ��
  MyTimerHandler.RemoveTimer( HandleType_CheckForUpdate );

    // ������
  frmMainForm.AppUpgrade;
end;

class procedure MyBackupCowAutoApi.DownloadRarDllFile;
var
  DllPath : string;
begin
    // �Ƴ���ʱ��
  MyTimerHandler.RemoveTimer( HandleType_DownloadRarDll );

    // �Ѵ���
  DllPath := MyPreviewUtil.getRarDllPath;
  if FileExists( DllPath ) then
    Exit;

    // ���� Dll
  try
    MyPreviewUtil.DownloadRarDll( MyUrl.getRarDllPath );
  except
  end;
end;

class procedure MyBackupCowAutoApi.MarkAppRunTime;
var
  PcID, PcName, NetworkMode, AdsShowCount : string;
  LocalBackupItem, NetworkBackupItem, NetworkPcCount : Integer;
  params : TStringlist;
  idhttp : TIdHTTP;
begin
  MyTimerHandler.RemoveTimer( HandleType_MarkAppRunTime );

    // ������Ϣ
  PcID := PcInfo.PcID;
  PcName := PcInfo.PcName;
  LocalBackupItem := DesItemInfoReadUtil.ReadLocalItemCount;
  NetworkBackupItem := DesItemInfoReadUtil.ReadNetworkItemCount;
  NetworkPcCount := MyNetPcInfoReadUtil.ReadPcCount;
  NetworkMode := MyNetworkConnInfo.SelectType;
  AdsShowCount := IntToStr( MyRegisterItem_AdsShowCount );

    // ��¼ʹ����Ϣ
  params := TStringList.Create;
  params.Add( HttpMarkApp_PcID + '=' + PcID );
  params.Add( HttpMarkApp_PcName + '=' + PcName );
  params.Add( HttpMarkApp_NetworkMode + '=' + NetworkMode );
  params.Add( HttpMarkApp_NetworkPc + '=' + IntToStr( NetworkPcCount ) );
  params.Add( HttpMarkApp_LocalBackup + '=' + IntToStr( LocalBackupItem ) );
  params.Add( HttpMarkApp_NetworkBackup + '=' + IntToStr( NetworkBackupItem ) );
  params.Add( HttpMarkApp_AdsShowCount + '=' + AdsShowCount );
  params.Add( HttpMarkApp_BackupAnalyze + '=' + BackupAnalyze_LastTime );
  params.Add( HttpMarkApp_Account + '=Server' );

  idhttp := TIdHTTP.Create(nil);
  idhttp.ReadTimeout := 10000;
  idhttp.ConnectTimeout := 10000;
  try
    idhttp.Post( MyUrl.getAppRunMark , params );
  except
  end;
  idhttp.Free;

  params.free;
end;

end.
