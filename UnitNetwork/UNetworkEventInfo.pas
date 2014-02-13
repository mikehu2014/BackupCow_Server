unit UNetworkEventInfo;

interface

type

    // 父类
  TNetworkPcEventBase = class
  public
    PcID : string;
  public
    constructor Create( _PcID : string );
  end;

    // 添加
  TNetworkPcAddEvent = class( TNetworkPcEventBase )
  public
    procedure Update;
  private
    procedure SetToBackup;
    procedure SetToCloud;
  end;

    // 上线
  TNetworkPcOnlineEvent = class( TNetworkPcEventBase )
  private
    Account : string;
  public
    procedure SetAccount( _Account : string );
    procedure Update;
  private
    procedure SetToBackup;
    procedure SetToRestore;
    procedure SetToCloud;
    procedure SetToRegister;
  end;

    // 离线
  TNetworkPcOfflineEvent = class( TNetworkPcEventBase )
  public
    procedure Update;
  private
    procedure SetToBackup;
    procedure SetToRestore;
    procedure SetToRegister;
  end;

    // 事件调用器
  NetworkPcEvent = class
  public
    class procedure AddPc( PcID : string );
    class procedure PcOnline( PcID, Account : string );
    class procedure PcOffline( PcID : string );
  end;

implementation

uses UMyBackupApiInfo, UMyCloudApiInfo, UMyRestoreApiInfo, UMyRegisterApiInfo, UMyNetPcInfo;

{ NetworkPcEvent }

class procedure NetworkPcEvent.AddPc(PcID: string);
var
  NetworkPcAddEvent : TNetworkPcAddEvent;
begin
  NetworkPcAddEvent := TNetworkPcAddEvent.Create( PcID );
  NetworkPcAddEvent.Update;
  NetworkPcAddEvent.Free;
end;

class procedure NetworkPcEvent.PcOffline(PcID: string);
var
  NetworkPcOfflineEvent : TNetworkPcOfflineEvent;
begin
  NetworkPcOfflineEvent := TNetworkPcOfflineEvent.Create( PcID );
  NetworkPcOfflineEvent.Update;
  NetworkPcOfflineEvent.Free;
end;


class procedure NetworkPcEvent.PcOnline(PcID, Account: string);
var
  NetworkPcOnlineEvent : TNetworkPcOnlineEvent;
begin
  NetworkPcOnlineEvent := TNetworkPcOnlineEvent.Create( PcID );
  NetworkPcOnlineEvent.SetAccount( Account );
  NetworkPcOnlineEvent.Update;
  NetworkPcOnlineEvent.Free;
end;

{ TNetworkPcEventBase }

constructor TNetworkPcEventBase.Create(_PcID: string);
begin
  PcID := _PcID;
end;

{ TNetworkPcAddEvent }

procedure TNetworkPcAddEvent.SetToBackup;
begin
//  DesItemAppApi.AddNetworkItem( PcID );
end;

procedure TNetworkPcAddEvent.SetToCloud;
begin
//  MyCloudAppApi.AddPcItem( PcID );
end;

procedure TNetworkPcAddEvent.Update;
begin
  SetToBackup;
  SetToCloud;
end;

{ TNetworkPcOnlineEvent }

procedure TNetworkPcOnlineEvent.SetAccount(_Account: string);
begin
  Account := _Account;
end;

procedure TNetworkPcOnlineEvent.SetToBackup;
begin
    // 设置备份目标 上线
  DesItemAppApi.SetNetworkPcIsOnline( PcID, True );

    // 上线续传
  BackupItemAppApi.PcOnlineBackup( PcID );

    // 启动本地备份
  if PcID = PcInfo.PcID then
    BackupItemAppApi.LocalOnlineBackup;
end;

procedure TNetworkPcOnlineEvent.SetToCloud;
begin
    // 通知对方我的共享路径
    // 通知对方我的恢复路径
  MyCloudPcPathAppApi.PcOnline( PcID, Account );
end;

procedure TNetworkPcOnlineEvent.SetToRegister;
begin
    // 发送 本机的注册信息
  MyRegisterUserApi.SetRegisterOnline( PcID );

    // 注册信息 Pc 在线
  RegisterShowAppApi.SetIsOnline( PcID, True );

    // 发送激活信息
  RegisterActivatePcApi.PcOnline( PcID );
end;

procedure TNetworkPcOnlineEvent.SetToRestore;
begin
    // 恢复下载 上线
  RestoreDownAppApi.SetPcOnline( PcID, True );

    // 启动恢复 Job
  RestoreDownAppApi.CheckPcOnlineRestore( PcID );
end;

procedure TNetworkPcOnlineEvent.Update;
begin
  SetToBackup;
  SetToRestore;
  SetToCloud;
  SetToRegister;
end;

{ TNetworkPcAOfflineEvent }

procedure TNetworkPcOfflineEvent.SetToBackup;
begin
  DesItemAppApi.SetNetworkPcIsOnline( PcID, False );
end;

procedure TNetworkPcOfflineEvent.SetToRegister;
begin
  RegisterShowAppApi.SetIsOnline( PcID, False );
end;

procedure TNetworkPcOfflineEvent.SetToRestore;
begin
  RestoreDownAppApi.SetPcOnline( PcID, False );
  RestoreDesAppApi.SetPcOffline( PcID );
end;

procedure TNetworkPcOfflineEvent.Update;
begin
  SetToBackup;
  SetToRestore;
  SetToRegister;
end;

end.
