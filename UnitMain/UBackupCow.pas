unit UBackupCow;

interface

uses Forms, Windows, SysUtils, Classes, xmldom, XMLIntf, msxmldom, XMLDoc, ActiveX, uDebug, IniFiles;

type

    // 读取 Xml 信息
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

    // BackupCow 创建
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

    // BackupCow 销毁
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

      // 记录程序运行时间
  MyBackupCowAutoApi = class
  public
    class procedure MarkAppRunTime;
    class procedure DownloadRarDllFile;
    class procedure CheckForUpdate;
  end;

    // BackupCow 核心程序
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
      // 移除定时器
  MyTimerHandler.AddTimer( HandleType_CheckForUpdate, 5 );
end;

procedure TBackupCowCreate.CreateBackup;
begin
    // 数据结构
  MyBackupInfo := TMyBackupInfo.Create;

    // 备份线程
  MyBackupHandler := TMyBackupHandler.Create;

    // 日志线程
  MyBackupLogHandler := TMyBackupLogHandler.Create;

    // 备份连接
  MyBackupFileConnectHandler := TMyBackupFileConnectHandler.Create;
end;

procedure TBackupCowCreate.CreateCloud;
begin
    // 数据结构
  MyCloudInfo := TMyCloudInfo.Create;

    // 云备份线程
  MyCloudFileHandler := TMyCloudFileHandler.Create;
end;

procedure TBackupCowCreate.CreateMain;
begin
  MyRefreshSpeedHandler := TMyRefreshSpeedHandler.Create;

  MyTimerHandler := TMyTimerHandler.Create;
end;

procedure TBackupCowCreate.CreateNetwork;
begin
    // 本机的 Pc 信息
  PcInfo := TPcInfo.Create;
  Randomize;
  PcInfo.SetSortInfo( Now, Random( 1000000 ) );
  PcInfo.SetPcHardCode( MyMacAddress.getStr );

    // 网络连接方式
  MyNetworkConnInfo := TMyNetworkConnInfo.Create;

    // Master 信息
  MasterInfo := TMasterInfo.Create;

    // 搜索网络 数据结构
  MyNetPcInfo := TMyNetPcInfo.Create;

    // 帐号信息 数据结构
  MyAccountInfo := TMyAccountInfo.Create;

      // C/S 网络
  MyServer := TMyServer.Create;
  MyClient := TMyClient.Create;

    // 搜索网络 命令控制器
  MyMasterSendHandler := TMyMasterSendHandler.Create;
  MyMasterReceiveHanlder := TMyMasterReceiveHandler.Create;

    // 监听网络
  MyListener := TMyListener.Create;

    // 搜索服务器
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
   // 搜索 Master
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
    // 界面 更新 总控制器
  MyFaceChange := TMyFaceChange.Create;
end;

procedure TBackupCowCreate.CreateWriteXml;
begin
  try   // Xml 根文档 初始化
    MyXmlDoc := frmMainForm.XmlDoc;
    MyXmlDoc.Active := True;
    if FileExists( MyXmlUtil.getXmlPath ) then
      MyXmlDoc.LoadFromFile( MyXmlUtil.getXmlPath );
    MyXmlUtil.IniXml;
  except
  end;

    // Xml 初始化
  MyXmlChange := TMyXmlChange.Create;
end;

procedure TBackupCowCreate.LoadRarDllFile;
begin
  MyTimerHandler.AddTimer( HandleType_DownloadRarDll, 10 );  // 下载 Rar 文件
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
  MyTimerHandler.AddTimer( HandleType_MarkAppRunTime, 30 );  // 记录程序运行信息
end;

procedure TBackupCowCreate.Update;
begin
  CreateSettingInfo;  // Setting 信息
  CreateWriteXml;  // 写 Xml 信息
  CreateWriteFace; // 写 程序界面

  CreateMain;
  CreateRegister;
  CreateBackup;
  CreateCloud;  // 云信息
  CreateRestore;
  CreateNetwork; // 网络信息

  LoadSetting;  // 加载 Setting 设置
  ReadXml;  // 读 Xml 信息
  StartNetwork;
  MarkAppRunTime;
  LoadRarDllFile;
  CheckForUpdate;
  MyAppPiracyAutoApi.CheckIsPiracy; // 检测是否盗版
  MyTimerHandler.StartRun; // 启动定时线程
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
    // 停止 搜索 Mster 线程
  MySearchMasterHandler.Free;

    // 关闭 监听端口
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
    // 保存 所有的 Xml 信息
  MyXmlChange.StopThread;
  MyXmlChange.Free;
end;

procedure TBackupCowDestory.StopWriteThread;
begin
    // 停止 搜索服务器
  MySearchMasterHandler.StopRun;

    // 停止 处理连接
  MyListener.StopRun; // 停止处理连接

      // 停止 搜索服务器连接处理
  MyMasterSendHandler.StopRun;
  MyMasterReceiveHanlder.StopRun;

  MyClient.StopRun;  // 断开客户端
  MyServer.StopRun;  // 断开服务器

  MyFaceChange.StopThread; // 停止界面更新

    // 停止扫描
  MyTimerHandler.StopRun;
  MyRegisterExpiredHandler.StopRun;

    // 停止备份线程
  MyBackupFileConnectHandler.StopRun;
  MyBackupHandler.StopScan;
  MyBackupLogHandler.StopScan;

    // 停止云线程
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
  for i := 1 to 5 do  // 可能网络断开原因，需要多次获取试用码
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
      // 成功激活
    if IsSuccess then
      Break;
  end;
  ParamList.Free;

    // 获取试用码失败
  if not IsSuccess then
    Exit;

    // 设置试用码
  MyRegisterUserApi.SetLicense( LicenseStr );

    // 设置过期时显示过期信息
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

    // 续传
  BackupItemAppApi.LocalOnlineBackup;

    // 立刻检测 自动备份
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

    // 检测本地继续恢复
  RestoreDownAppApi.CheckLocalRestoreOnline;
end;

procedure TMyXmlReadHandle.Update;
begin
    // Xml 文件存在， 则读取 Xml 文件信息
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
  for i := 1 to 5 do  // 可能网络断开原因，需要多次获取试用码
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
      // 成功激活
    if IsSuccess then
      Break;
  end;
  ParamList.Free;

    // 获取试用码失败
  if not IsSuccess then
    Exit;

    // 设置试用码
  MyRegisterUserApi.SetLicense( LicenseStr );

    // 设置过期时显示过期信息
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
    // 移除定时器
  MyTimerHandler.RemoveTimer( HandleType_CheckForUpdate );

    // 检查更新
  frmMainForm.AppUpgrade;
end;

class procedure MyBackupCowAutoApi.DownloadRarDllFile;
var
  DllPath : string;
begin
    // 移除定时器
  MyTimerHandler.RemoveTimer( HandleType_DownloadRarDll );

    // 已存在
  DllPath := MyPreviewUtil.getRarDllPath;
  if FileExists( DllPath ) then
    Exit;

    // 下载 Dll
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

    // 本机信息
  PcID := PcInfo.PcID;
  PcName := PcInfo.PcName;
  LocalBackupItem := DesItemInfoReadUtil.ReadLocalItemCount;
  NetworkBackupItem := DesItemInfoReadUtil.ReadNetworkItemCount;
  NetworkPcCount := MyNetPcInfoReadUtil.ReadPcCount;
  NetworkMode := MyNetworkConnInfo.SelectType;
  AdsShowCount := IntToStr( MyRegisterItem_AdsShowCount );

    // 记录使用信息
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
