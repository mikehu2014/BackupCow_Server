unit UMyCloudEventInfo;

interface

type

    // 云备份事件
  TMyCloudChangeEvent = class
  public
    CloudPath, PcID, BackupPath : string;
  public
    constructor Create( _CloudPath, _PcID, _BackupPath : string );
  end;

    // 添加
  TMyCloudAddEvent = class( TMyCloudChangeEvent )
  public
    IsFile : Boolean;
    FileCount : Integer;
    FileSpace : Int64;
    LastDateTime : TDateTime;
  public
    IsSaveDeleted : Boolean;
    IsEncrypted : Boolean;
    Password, PasswordHint : string;
  public
    Account : string;
  public
    procedure SetIsFile( _IsFile : Boolean );
    procedure SetSpaceInfo( _FileCount : Integer; _FileSpace : Int64 );
    procedure SetLastDateTime( _LastDateTime : TDateTime );
    procedure SetIsSaveDeleted( _IsSaveDeleted : Boolean );
    procedure SetEncryptInfo( _IsEncrypted : Boolean; _Password, _PasswordHint : string );
    procedure SetAccount( _Account : string );
    procedure Update;
  private
    procedure SendToAllPc;
  end;

    // 删除
  TMyCloudRemoveEvent = class( TMyCloudChangeEvent )
  public
    procedure Update;
  private
    procedure SendToAllPc;
  end;

  TCloudAddEventParam = record
  public
    CloudPath, PcID, BackupPath : string;
    IsFile : Boolean;
  public
    FileCount : Integer;
    FileSpace : Int64;
    LastDateTime : TDateTime;
  public
    IsSaveDeleted : Boolean;
    IsEncrypted : Boolean;
    Password, PasswordHint : string;
  public
    Account : string;
  end;

    // 云路径 事件
  MyCloudPathEvent = class
  public
    class procedure AddItem( CloudPath : string );
    class procedure RemoveItem( CloudPath : string );
  end;

    // 云路径 Pc 备份 事件
  MyCloudPcBackupPathEvent = class
  public
    class procedure AddItem( Params : TCloudAddEventParam );
    class procedure RemoveItem( CloudPath, PcID, BackupPath : string );
  end;

      // 反向连接时间
  CloudBackConnEvent = class
  public
    class procedure BackupConnBusy( DesPcID : string );
    class procedure BackupConnError( DesPcID : string );
  public
    class procedure RestoreConnBusy( DesPcID : string );
    class procedure RestoreConnError( DesPcID : string );
  end;

implementation

uses UMyClient, UMyNetPcInfo, UMyUtil;

{ TMyCloudChangeEvent }

constructor TMyCloudChangeEvent.Create(_CloudPath,_PcID, _BackupPath: string);
begin
  CloudPath := _CloudPath;
  PcID := _PcID;
  BackupPath := _BackupPath;
end;

{ TMyCloudAddEvent }

procedure TMyCloudAddEvent.SendToAllPc;
var
  OwnerName : string;
  CloudBackupAddRestoreMsg : TCloudBackupAddRestoreMsg;
begin
  OwnerName := MyNetPcInfoReadUtil.ReadName( PcID );

  CloudBackupAddRestoreMsg := TCloudBackupAddRestoreMsg.Create;
  CloudBackupAddRestoreMsg.SetPcID( PcInfo.PcID );
  CloudBackupAddRestoreMsg.SetCloudPath( CloudPath );
  CloudBackupAddRestoreMsg.SetBackupPath( BackupPath );
  CloudBackupAddRestoreMsg.SetIsFile( IsFile );
  CloudBackupAddRestoreMsg.SetOwnerInfo( PcID, OwnerName );
  CloudBackupAddRestoreMsg.SetSpaceInfo( FileCount, FileSpace );
  CloudBackupAddRestoreMsg.SetLastBackupTime( LastDateTime );
  CloudBackupAddRestoreMsg.SetIsSaveDeleted( IsSaveDeleted );
  CloudBackupAddRestoreMsg.SetEncryptInfo( IsEncrypted, Password, PasswordHint );
  CloudBackupAddRestoreMsg.SetAccount( Account );
  MyClient.SendMsgToAll( CloudBackupAddRestoreMsg );
end;

procedure TMyCloudAddEvent.SetAccount(_Account: string);
begin
  Account := _Account;
end;

procedure TMyCloudAddEvent.SetEncryptInfo(_IsEncrypted: Boolean; _Password,
  _PasswordHint: string);
begin
  IsEncrypted := _IsEncrypted;
  Password := _Password;
  PasswordHint := _PasswordHint;
end;

procedure TMyCloudAddEvent.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TMyCloudAddEvent.SetIsSaveDeleted(_IsSaveDeleted: Boolean);
begin
  IsSaveDeleted := _IsSaveDeleted;
end;

procedure TMyCloudAddEvent.SetLastDateTime(_LastDateTime: TDateTime);
begin
  LastDateTime := _LastDateTime;
end;

procedure TMyCloudAddEvent.SetSpaceInfo(_FileCount: Integer; _FileSpace: Int64);
begin
  FileCount := _FileCount;
  FileSpace := _FileSpace;
end;

procedure TMyCloudAddEvent.Update;
begin
  SendToAllPc;
end;

{ TMyCloudRemoveEvent }

procedure TMyCloudRemoveEvent.SendToAllPc;
var
  CloudBackupRemoveRestoreMsg : TCloudBackupRemoveRestoreMsg;
begin
  CloudBackupRemoveRestoreMsg := TCloudBackupRemoveRestoreMsg.Create;
  CloudBackupRemoveRestoreMsg.SetPcID( PcInfo.PcID );
  CloudBackupRemoveRestoreMsg.SetCloudPath( CloudPath );
  CloudBackupRemoveRestoreMsg.SetOwnerID( PcID );
  CloudBackupRemoveRestoreMsg.SetBackupPath( BackupPath );
  MyClient.SendMsgToAll( CloudBackupRemoveRestoreMsg );
end;

procedure TMyCloudRemoveEvent.Update;
begin
  SendToAllPc;
end;

{ MyCloudPathEvent }

class procedure MyCloudPathEvent.AddItem(CloudPath: string);
var
  AvailableSpace : Int64;
  CloudPathAddMsg : TCloudPathAddMsg;
begin
    // 可用空间
  AvailableSpace := MyHardDisk.getHardDiskFreeSize( CloudPath );

  CloudPathAddMsg := TCloudPathAddMsg.Create;
  CloudPathAddMsg.SetPcID( PcInfo.PcID );
  CloudPathAddMsg.SetCloudPath( CloudPath );
  CloudPathAddMsg.SetAvailableSpace( AvailableSpace );
  MyClient.SendMsgToAll( CloudPathAddMsg );
end;

class procedure MyCloudPathEvent.RemoveItem(CloudPath: string);
var
  CloudPathRemoveMsg : TCloudPathRemoveMsg;
begin
  CloudPathRemoveMsg := TCloudPathRemoveMsg.Create;
  CloudPathRemoveMsg.SetPcID( PcInfo.PcID );
  CloudPathRemoveMsg.SetCloudPath( CloudPath );
  MyClient.SendMsgToAll( CloudPathRemoveMsg );
end;

{ MyCloudPcBackupPathEvent }

class procedure MyCloudPcBackupPathEvent.AddItem(Params: TCloudAddEventParam);
var
  MyCloudAddEvent : TMyCloudAddEvent;
begin
  MyCloudAddEvent := TMyCloudAddEvent.Create( Params.CloudPath, Params.PcID, Params.BackupPath );
  MyCloudAddEvent.SetIsFile( Params.IsFile );
  MyCloudAddEvent.SetSpaceInfo( Params.FileCount, Params.FileSpace );
  MyCloudAddEvent.SetLastDateTime( Params.LastDateTime );
  MyCloudAddEvent.SetIsSaveDeleted( Params.IsSaveDeleted );
  MyCloudAddEvent.SetEncryptInfo( Params.IsEncrypted, Params.Password, Params.PasswordHint );
  MyCloudAddEvent.SetAccount( Params.Account );
  MyCloudAddEvent.Update;
  MyCloudAddEvent.Free;
end;

class procedure MyCloudPcBackupPathEvent.RemoveItem(CloudPath, PcID,
  BackupPath: string);
var
  MyCloudRemoveEvent : TMyCloudRemoveEvent;
begin
  MyCloudRemoveEvent := TMyCloudRemoveEvent.Create( CloudPath, PcID, BackupPath );
  MyCloudRemoveEvent.Update;
  MyCloudRemoveEvent.Free;
end;

{ CloudBackConnEvent }

class procedure CloudBackConnEvent.BackupConnBusy(DesPcID: string);
var
  BackupItemBackConnBusyMsg : TBackupItemBackConnBusyMsg;
begin
  BackupItemBackConnBusyMsg := TBackupItemBackConnBusyMsg.Create;
  BackupItemBackConnBusyMsg.SetPcID( PcInfo.PcID );
  MyClient.SendMsgToPc( DesPcID, BackupItemBackConnBusyMsg );
end;

class procedure CloudBackConnEvent.BackupConnError(DesPcID: string);
var
  BackupItemBackConnErrorMsg : TBackupItemBackConnErrorMsg;
begin
  BackupItemBackConnErrorMsg := TBackupItemBackConnErrorMsg.Create;
  BackupItemBackConnErrorMsg.SetPcID( PcInfo.PcID );
  MyClient.SendMsgToPc( DesPcID, BackupItemBackConnErrorMsg );
end;

class procedure CloudBackConnEvent.RestoreConnBusy(DesPcID: string);
var
  RestoreItemBackConnBusyMsg : TRestoreItemBackConnBusyMsg;
begin
  RestoreItemBackConnBusyMsg := TRestoreItemBackConnBusyMsg.Create;
  RestoreItemBackConnBusyMsg.SetPcID( PcInfo.PcID );
  MyClient.SendMsgToPc( DesPcID, RestoreItemBackConnBusyMsg );
end;

class procedure CloudBackConnEvent.RestoreConnError(DesPcID: string);
var
  RestoreItemBackConnErrorMsg : TRestoreItemBackConnErrorMsg;
begin
  RestoreItemBackConnErrorMsg := TRestoreItemBackConnErrorMsg.Create;
  RestoreItemBackConnErrorMsg.SetPcID( PcInfo.PcID );
  MyClient.SendMsgToPc( DesPcID, RestoreItemBackConnErrorMsg );
end;

end.
