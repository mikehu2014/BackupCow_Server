unit UAutoBackupThread;

interface

uses classes, SysUtils, DateUtils;

type

    // 自动备份
  TAutoBackupHandle = class
  public
    procedure Update;
  private
    procedure CheckLocalBackup;
    procedure CheckNetworkBackup;
    procedure CheckNetworkBackupLostConn;
    procedure RefreshSyncTimeFace;
  end;

    // 自动备份未完成
  TAutoBackupIncompletedHandle = class
  public
    procedure Update;
  private
    procedure CheckLocal;
    procedure CheckNetwork;
  end;

    // 外部接口
  AutoBackupApi = class
  public
    class procedure CheckAuto;
    class procedure CheckBusy;
    class procedure CheckIncompleted;
  end;

implementation

uses UMyBackupDataInfo, UMyBackupApiInfo, UMyUtil, UMyNetPcInfo;

{ TAutoBackupHandle }

procedure TAutoBackupHandle.CheckLocalBackup;
var
  DesItemList, BackupItemList : TStringList;
  i, j : Integer;
  DesItemID : string;
  AvaialeSpace : Int64;
begin
  DesItemList := DesItemInfoReadUtil.ReadLocaDesList;
  for i := 0 to DesItemList.Count - 1 do
  begin
    DesItemID := DesItemList[i];
    AvaialeSpace := MyHardDisk.getHardDiskFreeSize( DesItemID );
    DesItemAppApi.SetLocalAvaialbleSpace( DesItemID, AvaialeSpace );
    BackupItemList := DesItemInfoReadUtil.ReadOnTimeBackupList( DesItemID );
    for j := 0 to BackupItemList.Count - 1 do
      BackupItemUserApi.BackupSelectItem( DesItemID, BackupItemList[j] );
    BackupItemList.Free;
  end;
  DesItemList.Free;
end;

procedure TAutoBackupHandle.CheckNetworkBackup;
var
  DesItemList, BackupItemList : TStringList;
  i, j : Integer;
  DesItemID : string;
begin
  DesItemList := DesItemInfoReadUtil.ReadNetworkDesList;
  for i := 0 to DesItemList.Count - 1 do
  begin
    DesItemID := DesItemList[i];
    BackupItemList := DesItemInfoReadUtil.ReadOnTimeBackupList( DesItemID );
    for j := 0 to BackupItemList.Count - 1 do
      BackupItemUserApi.BackupSelectItem( DesItemID, BackupItemList[j] );
    BackupItemList.Free;
  end;
  DesItemList.Free;
end;

procedure TAutoBackupHandle.CheckNetworkBackupLostConn;
var
  DesItemList, BackupItemList : TStringList;
  i, j : Integer;
  DesItemID : string;
begin
  DesItemList := DesItemInfoReadUtil.ReadNetworkDesList;
  for i := 0 to DesItemList.Count - 1 do
  begin
    DesItemID := DesItemList[i];
    BackupItemList := DesItemInfoReadUtil.ReadLostConnBackupList( DesItemID );
    for j := 0 to BackupItemList.Count - 1 do
       BackupItemUserApi.BackupSelectItem( DesItemID, BackupItemList[j] );
    BackupItemList.Free;
  end;
  DesItemList.Free;
end;

procedure TAutoBackupHandle.RefreshSyncTimeFace;
begin
  BackupItemAppApi.RefresAutoSyncTime;
end;

procedure TAutoBackupHandle.Update;
begin
    // 检测定时备份
  CheckLocalBackup;
  CheckNetworkBackup;
  CheckNetworkBackupLostConn;
  RefreshSyncTimeFace;
end;

{ AutoBackupApi }

class procedure AutoBackupApi.CheckAuto;
var
  AutoBackupHandle : TAutoBackupHandle;
begin
  AutoBackupHandle := TAutoBackupHandle.Create;
  AutoBackupHandle.Update;
  AutoBackupHandle.Free;
end;

class procedure AutoBackupApi.CheckBusy;
var
  DesBusyBackupList : TBackupKeyItemList;
  i: Integer;
  DesItemID, BackupPath : string;
begin
  DesBusyBackupList := BackupItemInfoReadUtil.ReadDesBusyList;
  for i := 0 to DesBusyBackupList.Count - 1 do
  begin
    DesItemID := DesBusyBackupList[i].DesItem;
    BackupPath := DesBusyBackupList[i].BackupPath;
    BackupItemUserApi.BackupSelectItem( DesItemID, BackupPath );
  end;
  DesBusyBackupList.Free;
end;


class procedure AutoBackupApi.CheckIncompleted;
var
  AutoBackupIncompletedHandle : TAutoBackupIncompletedHandle;
begin
    // 用户手动停止备份
  if UserBackup_IsStop then
    Exit;

    // 启动未完成备份
  AutoBackupIncompletedHandle := TAutoBackupIncompletedHandle.Create;
  AutoBackupIncompletedHandle.Update;
  AutoBackupIncompletedHandle.Free;
end;

{ TAutoBackupIncompletedHandle }

procedure TAutoBackupIncompletedHandle.CheckLocal;
var
  DesItemList, BackupItemList : TStringList;
  i, j : Integer;
  DesItemID : string;
begin
    // 启动未完成的备份
  DesItemList := DesItemInfoReadUtil.ReadLocaDesList;
  for i := 0 to DesItemList.Count - 1 do
  begin
    DesItemID := DesItemList[i];
    BackupItemList := DesItemInfoReadUtil.ReadIncompletedList( DesItemID ); // 读取 Incompleted 并启动
    for j := 0 to BackupItemList.Count - 1 do
       BackupItemUserApi.BackupSelectItem( DesItemID, BackupItemList[j] );
    BackupItemList.Free;
  end;
  DesItemList.Free;
end;

procedure TAutoBackupIncompletedHandle.CheckNetwork;
var
  DesItemList, BackupItemList : TStringList;
  i, j : Integer;
  DesItemID, PcID : string;
begin
    // 启动未完成的备份
  DesItemList := DesItemInfoReadUtil.ReadNetworkDesList;
  for i := 0 to DesItemList.Count - 1 do
  begin
    DesItemID := DesItemList[i];
    PcID := NetworkDesItemUtil.getPcID( DesItemID );
    if not MyNetPcInfoReadUtil.ReadIsOnline( PcID ) then  // Pc 离线
      Continue;
    BackupItemList := DesItemInfoReadUtil.ReadIncompletedList( DesItemID ); // 读取 Incompleted 并启动
    for j := 0 to BackupItemList.Count - 1 do
       BackupItemUserApi.BackupSelectItem( DesItemID, BackupItemList[j] );
    BackupItemList.Free;
  end;
  DesItemList.Free;
end;

procedure TAutoBackupIncompletedHandle.Update;
begin
  CheckLocal;

  CheckNetwork;
end;

end.
