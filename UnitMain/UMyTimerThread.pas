unit UMyTimerThread;

interface

uses SysUtils, Generics.Collections, classes, SyncObjs, DateUtils, udebuglock;

type

    // 数据结构
  TTimerDataInfo = class
  public
    HandleType : string;
    SecondInterval : Integer;
  public
    IsNowCheck : Boolean;
    LastTime : TDateTime;
  public
    constructor Create( _HandleType : string );
    procedure SetSecondInterval( _SecondInterval : Integer );
  end;
  TTimerDataList = class( TObjectList<TTimerDataInfo> )end;

    // 处理线程
  TTimerHandleThread = class( TDebugThread )
  public
    DataLock : TCriticalSection;
    TimerDataList : TTimerDataList;
  public
    constructor Create;
    procedure IniTimerData;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  public
    procedure AddTimer( HandleType : string; SecondInterval : Integer );
    procedure RemoveTimer( HandleType : string );
    procedure NowCheck( HandleType : string );
  private
    procedure HandleCheck;
    procedure HandleTimer( HandleType : string );
  end;

    // 操作对象
  TMyTimerHandler = class
  public
    IsRun : Boolean;
    TimerHandleThread : TTimerHandleThread;
  public
    constructor Create;
    procedure StartRun;
    procedure StopRun;
  public
    procedure AddTimer( HandleType : string; SecondInterval : Integer );
    procedure RemoveTimer( HandleType : string );
    procedure NowCheck( HandleType : string );
  end;

const
  HandleType_RefreshSpeed = 'RefreshSpeed';
  HandleType_AutoBackup = 'AotuBackup';
  HandleType_BackupBusy = 'BackupBusy';
  HandleType_BackupIncompleted = 'BackupIncompleted';
  HandleType_RestoreBusy = 'RestoreBusy';
  HandleType_RestoreLostConn = 'RestoreLostConn';
  HandleType_RestoreIncompleted = 'RestoreIncompleted';

  HandleType_RestartNetwork = 'RestartNetwork';
  HandleType_PortMapping = 'PortMapping';
  HandleType_ClientHeartBeat = 'ClientHeartBeat';
  HandleType_DownloadRarDll = 'DownloadRarDll';
  HandleType_MarkAppRunTime = 'MarkAppRunTime';
  HandleType_MakePiracyError = 'MakePiracyError';
  HandleType_SaveXml = 'SaveXml';
  HandleType_CheckForUpdate = 'CheckForUpdate';

var
  MyTimerHandler : TMyTimerHandler;

implementation

uses UAutoBackupThread, UAutoRestoreThread, UMainFormThread, USearchServer, UMyClient,
     UBackupCow, UAppEditionInfo, UXmlUtil;

{ TTimerDataInfo }

constructor TTimerDataInfo.Create(_HandleType: string);
begin
  HandleType := _HandleType;
  LastTime := Now;
  IsNowCheck := False;
end;

procedure TTimerDataInfo.SetSecondInterval(_SecondInterval: Integer);
begin
  SecondInterval := _SecondInterval;
end;

{ TTimerHandleThread }

procedure TTimerHandleThread.AddTimer(HandleType: string;
  SecondInterval: Integer);
var
  TimerData : TTimerDataInfo;
begin
    // 添加
  DataLock.Enter;
  TimerData := TTimerDataInfo.Create( HandleType );
  TimerData.SetSecondInterval( SecondInterval );
  TimerDataList.Add( TimerData );
  DataLock.Leave;
end;

constructor TTimerHandleThread.Create;
begin
  inherited Create;
  DataLock := TCriticalSection.Create;
  TimerDataList := TTimerDataList.Create;
  IniTimerData;
end;

destructor TTimerHandleThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  TimerDataList.Free;
  DataLock.Free;
  inherited;
end;

procedure TTimerHandleThread.Execute;
var
  i: Integer;
begin
  while not Terminated do
  begin
      // 1秒钟检测一次
    for i := 1 to 10 do
      if not Terminated then
        Sleep( 100 );

      // 结束程序
    if Terminated then
      Break;

      // 检测需要执行的操作
    try
      HandleCheck;
    except
    end;
  end;
  inherited;
end;

procedure TTimerHandleThread.HandleCheck;
var
  i: Integer;
  TimerData : TTimerDataInfo;
begin
  DataLock.Enter;
  try
    for i := TimerDataList.Count - 1 downto 0 do
    begin
      TimerData := TimerDataList[i];
      if TimerData.IsNowCheck or ( SecondsBetween( Now, TimerData.LastTime ) >= TimerData.SecondInterval ) then
      begin
        HandleTimer( TimerData.HandleType );
        TimerData.IsNowCheck := False;
        TimerData.LastTime := Now;
      end;
    end;
  except
  end;
  DataLock.Leave;
end;

procedure TTimerHandleThread.HandleTimer(HandleType: string);
begin
  if HandleType = HandleType_MarkAppRunTime then
    MyBackupCowAutoApi.MarkAppRunTime
  else
  if HandleType = HandleType_DownloadRarDll then
    MyBackupCowAutoApi.DownloadRarDllFile
  else
  if HandleType = HandleType_AutoBackup then
    AutoBackupApi.CheckAuto
  else
  if HandleType = HandleType_BackupBusy then
    AutoBackupApi.CheckBusy
  else
  if HandleType = HandleType_BackupIncompleted then
    AutoBackupApi.CheckIncompleted
  else
  if HandleType = HandleType_RestoreBusy then
    AutoRestoreApi.CheckBusy
  else
  if HandleType = HandleType_RestoreLostConn then
    AutoRestoreApi.CheckLostConn
  else
  if HandleType = HandleType_RestoreIncompleted then
    AutoRestoreApi.CheckIncompleted
  else
  if HandleType = HandleType_RefreshSpeed then
    MyRefreshSpeedHandler.RefreshSpeed
  else
  if HandleType = HandleType_RestartNetwork then
    MySearchMasterTimerApi.CheckRestartNetwork
  else
  if HandleType = HandleType_PortMapping then
    MySearchMasterTimerApi.MakePortMapping
  else
  if HandleType = HandleType_ClientHeartBeat then
    MyClientOnTimerApi.SendHeartBeat
  else
  if HandleType = HandleType_MakePiracyError then
    MyAppPiracyAutoApi.MakeAppError
  else
  if HandleType = HandleType_SaveXml then
    MyXmlSaveAutoApi.SaveNow
  else
  if HandleType = HandleType_CheckForUpdate then
    MyBackupCowAutoApi.CheckForUpdate;
end;

procedure TTimerHandleThread.IniTimerData;
var
  TimerData : TTimerDataInfo;
begin
    // 定时检测 自动刷新速度
  TimerData := TTimerDataInfo.Create( HandleType_RefreshSpeed );
  TimerData.SetSecondInterval( 1 );
  TimerDataList.Add( TimerData );

    // 定时检测 自动备份
  TimerData := TTimerDataInfo.Create( HandleType_AutoBackup );
  TimerData.SetSecondInterval( 60 );
  TimerDataList.Add( TimerData );

    // 定时检测 备份 Busy
  TimerData := TTimerDataInfo.Create( HandleType_BackupBusy );
  TimerData.SetSecondInterval( 300 );
  TimerDataList.Add( TimerData );

    // 定时检测 备份 Incompleted
  TimerData := TTimerDataInfo.Create( HandleType_BackupIncompleted );
  TimerData.SetSecondInterval( 300 );
  TimerDataList.Add( TimerData );

    // 定时检测 恢复 Busy
  TimerData := TTimerDataInfo.Create( HandleType_RestoreBusy );
  TimerData.SetSecondInterval( 300 );
  TimerDataList.Add( TimerData );

    // 定时检测 恢复 断开连接
  TimerData := TTimerDataInfo.Create( HandleType_RestoreLostConn );
  TimerData.SetSecondInterval( 60 );
  TimerDataList.Add( TimerData );

      // 定时检测 恢复 Incompleted
  TimerData := TTimerDataInfo.Create( HandleType_RestoreIncompleted );
  TimerData.SetSecondInterval( 300 );
  TimerDataList.Add( TimerData );

    // 定时 保存 Xml
  TimerData := TTimerDataInfo.Create( HandleType_SaveXml );
  TimerData.SetSecondInterval( 600 );
  TimerDataList.Add( TimerData );
end;

procedure TTimerHandleThread.NowCheck(HandleType: string);
var
  i: Integer;
begin
  DataLock.Enter;
  for i := 0 to TimerDataList.Count - 1 do
    if TimerDataList[i].HandleType = HandleType then
    begin
      TimerDataList[i].IsNowCheck := True;
      Break;
    end;
  DataLock.Leave;
end;

procedure TTimerHandleThread.RemoveTimer(HandleType: string);
var
  i: Integer;
begin
    // 删除
  DataLock.Enter;
  for i := 0 to TimerDataList.Count - 1 do
    if TimerDataList[i].HandleType = HandleType then
    begin
      TimerDataList.Delete( i );
      Break;
    end;
  DataLock.Leave;
end;

{ TMyTimerHandler }

procedure TMyTimerHandler.AddTimer(HandleType: string; SecondInterval: Integer);
begin
  if not IsRun then
    Exit;

  TimerHandleThread.AddTimer( HandleType, SecondInterval );
end;

constructor TMyTimerHandler.Create;
begin
  IsRun := True;
  TimerHandleThread := TTimerHandleThread.Create;
end;

procedure TMyTimerHandler.NowCheck(HandleType: string);
begin
  if not IsRun then
    Exit;

  TimerHandleThread.NowCheck( HandleType );
end;

procedure TMyTimerHandler.RemoveTimer(HandleType: string);
begin
  if not IsRun then
    Exit;

  TimerHandleThread.RemoveTimer( HandleType );
end;

procedure TMyTimerHandler.StartRun;
begin
  TimerHandleThread.Resume;
end;

procedure TMyTimerHandler.StopRun;
begin
  IsRun := False;

  TimerHandleThread.Free;
end;

end.
