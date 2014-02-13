unit UNetworkEventInfo;

interface

type

    // ����
  TNetworkPcEventBase = class
  public
    PcID : string;
  public
    constructor Create( _PcID : string );
  end;

    // ���
  TNetworkPcAddEvent = class( TNetworkPcEventBase )
  public
    procedure Update;
  private
    procedure SetToBackup;
    procedure SetToCloud;
  end;

    // ����
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

    // ����
  TNetworkPcOfflineEvent = class( TNetworkPcEventBase )
  public
    procedure Update;
  private
    procedure SetToBackup;
    procedure SetToRestore;
    procedure SetToRegister;
  end;

    // �¼�������
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
    // ���ñ���Ŀ�� ����
  DesItemAppApi.SetNetworkPcIsOnline( PcID, True );

    // ��������
  BackupItemAppApi.PcOnlineBackup( PcID );

    // �������ر���
  if PcID = PcInfo.PcID then
    BackupItemAppApi.LocalOnlineBackup;
end;

procedure TNetworkPcOnlineEvent.SetToCloud;
begin
    // ֪ͨ�Է��ҵĹ���·��
    // ֪ͨ�Է��ҵĻָ�·��
  MyCloudPcPathAppApi.PcOnline( PcID, Account );
end;

procedure TNetworkPcOnlineEvent.SetToRegister;
begin
    // ���� ������ע����Ϣ
  MyRegisterUserApi.SetRegisterOnline( PcID );

    // ע����Ϣ Pc ����
  RegisterShowAppApi.SetIsOnline( PcID, True );

    // ���ͼ�����Ϣ
  RegisterActivatePcApi.PcOnline( PcID );
end;

procedure TNetworkPcOnlineEvent.SetToRestore;
begin
    // �ָ����� ����
  RestoreDownAppApi.SetPcOnline( PcID, True );

    // �����ָ� Job
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
