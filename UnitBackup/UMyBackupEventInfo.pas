unit UMyBackupEventInfo;

interface

uses SysUtils, UMyUtil;

type

  TBackupCompletedEventParams = record
  public
    DesItemID, SourcePath : string;
    IsFile : Boolean;
    FileCount : Integer;
    FileSpce : Int64;
  public
    IsSaveDeleted : Boolean;
    IsEncrypted : Boolean;
    Password, PasswordHint : string;
  end;

    // 网络备份 事件
  NetworkBackupEvent = class
  public
    class procedure BackupCompleted( Params : TBackupCompletedEventParams );
    class procedure RemoveBackupItem( DesItemID, SourcePath : string );
  end;


    // 本地备份 事件
  LocalBackupEvent = class
  public
    class procedure AddDesPath( DesPath : string );
    class procedure RemoveDesPath( DesPath : string );
  public
    class procedure BackupCompleted( Params : TBackupCompletedEventParams );
    class procedure RemoveBackupItem( DesPath, SourcePath : string );
  end;

    // 反向连接
  NetworkBackConnEvent = class
  public
    class procedure AddItem( ReceivePcID : string );
  end;

implementation

uses UMyClient, UMyNetPcInfo, UMyRestoreApiInfo, UMyBackupApiInfo;

{ NetworkBackupMsgEvent }

class procedure NetworkBackupEvent.BackupCompleted(Params : TBackupCompletedEventParams);
var
  DesPcID, CloudPath : string;
  NetworkBackupAddMsg : TNetworkBackupAddCloudMsg;
begin
  DesPcID := NetworkDesItemUtil.getPcID( Params.DesItemID );
  CloudPath := NetworkDesItemUtil.getCloudPath( Params.DesItemID );

  NetworkBackupAddMsg := TNetworkBackupAddCloudMsg.Create;
  NetworkBackupAddMsg.SetPcID( PcInfo.PcID );
  NetworkBackupAddMsg.SetCloudPath( CloudPath );
  NetworkBackupAddMsg.SetBackupPath( Params.SourcePath );
  NetworkBackupAddMsg.SetIsFile( Params.IsFile );
  NetworkBackupAddMsg.SetSpaceInfo( Params.FileCount, Params.FileSpce );
  NetworkBackupAddMsg.SetLastBackupTime( Now );
  NetworkBackupAddMsg.SetIsSaveDeleted( Params.IsSaveDeleted );
  NetworkBackupAddMsg.SetEncryptInfo( Params.IsEncrypted, Params.Password, Params.PasswordHint );
  MyClient.SendMsgToPc( DesPcID, NetworkBackupAddMsg );
end;

class procedure NetworkBackupEvent.RemoveBackupItem(DesItemID,
  SourcePath: string);
var
  DesPcID, CloudPath : string;
  NetworkBackupRemoveMsg : TNetworkBackupRemoveCloudMsg;
begin
  DesPcID := NetworkDesItemUtil.getPcID( DesItemID );
  CloudPath := NetworkDesItemUtil.getCloudPath( DesItemID );

  NetworkBackupRemoveMsg := TNetworkBackupRemoveCloudMsg.Create;
  NetworkBackupRemoveMsg.SetPcID( PcInfo.PcID );
  NetworkBackupRemoveMsg.SetCloudPath( CloudPath );
  NetworkBackupRemoveMsg.SetBackupPath( SourcePath );
  MyClient.SendMsgToPc( DesPcID, NetworkBackupRemoveMsg );
end;

{ LocalBackupEventInfo }

class procedure LocalBackupEvent.AddDesPath(DesPath: string);
begin
  RestoreDesAppApi.AddLocalItem( DesPath );
end;

class procedure LocalBackupEvent.BackupCompleted(
  Params: TBackupCompletedEventParams);
var
  RestoreAddParams : TRestoreAddParams;
begin
  RestoreAddParams.DesItemID := Params.DesItemID;
  RestoreAddParams.OwnerID := OwnerID_MyComputer;
  RestoreAddParams.OwnerName := OwnerName_MyComputer;
  RestoreAddParams.BackupPath := Params.SourcePath;
  RestoreAddParams.IsFile := Params.IsFile;
  RestoreAddParams.FileCount := Params.FileCount;
  RestoreAddParams.ItemSize := Params.FileSpce;
  RestoreAddParams.LastBackupTime := Now;
  RestoreAddParams.IsSaveDeleted := Params.IsSaveDeleted;
  RestoreAddParams.IsEncrypted := Params.IsEncrypted;
  RestoreAddParams.Password := Params.Password;
  RestoreAddParams.PasswordHint := Params.PasswordHint;

  RestoreItemAppApi.AddLocalItem( RestoreAddParams );
end;

class procedure LocalBackupEvent.RemoveBackupItem(DesPath,
  SourcePath: string);
begin
  RestoreItemAppApi.RemoveLocalItem( DesPath, SourcePath, OwnerID_MyComputer );
end;

class procedure LocalBackupEvent.RemoveDesPath(DesPath: string);
begin
  RestoreDesAppApi.RemoveLocalItem( DesPath );
end;

{ NetworkBackConnEvent }

class procedure NetworkBackConnEvent.AddItem(ReceivePcID: string);
var
  BackupItemBackConnMsg : TBackupItemBackConnMsg;
begin
  BackupItemBackConnMsg := TBackupItemBackConnMsg.Create;
  BackupItemBackConnMsg.SetPcID( PcInfo.PcID );
  MyClient.SendMsgToPc( ReceivePcID, BackupItemBackConnMsg );
end;

end.
