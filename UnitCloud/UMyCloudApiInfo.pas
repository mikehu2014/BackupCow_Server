unit UMyCloudApiInfo;

interface

uses SysUtils, classes, UMyUtil, sockets;

type

{$Region ' 数据修改 云路径 ' }

      // 修改
  TCloudPathWriteHandle = class
  public
    CloudPath : string;
  public
    constructor Create( _CloudPath : string );
  end;

    // 读取
  TCloudPathReadHandle = class( TCloudPathWriteHandle )
  public
    procedure Update;virtual;
  private
    procedure AddToInfo;
    procedure AddToFace;
  end;

    // 添加
  TCloudPathAddHandle = class( TCloudPathReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
    procedure AddToEvent;
  end;

    // 删除
  TCloudPathRemoveHandle = class( TCloudPathWriteHandle )
  protected
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromFace;
    procedure RemoveFromXml;
    procedure RemoveFromEvent;
  end;

{$EndRegion}

{$Region ' 数据修改 云备份信息 ' }


    // 修改
  TCloudBackupPathWriteHandle = class( TCloudPathWriteHandle )
  public
    BackupPath, OwnerID : string;
  public
    procedure SetBackupInfo( _BackupPath, _OwnerID : string );
  end;

    // 读取
  TCloudBackupPathReadHandle = class( TCloudBackupPathWriteHandle )
  public
    IsFile : boolean;
  public
    FileCount : integer;
    ItemSize : int64;
    LastBackupTime : TDateTime;
  public
    IsSaveDeleted : boolean;
    IsEncrypted : boolean;
    Password, PasswordHint : string;
  public
    procedure SetIsFile( _IsFile : boolean );
    procedure SetSpaceInfo( _FileCount : integer; _ItemSize : int64 );
    procedure SetLastBackupTime( _LastBackupTime : TDateTime );
    procedure SetIsSaveDeleted( _IsSaveDeleted : boolean );
    procedure SetEncryptInfo( _IsEncrypted : boolean; _Password, _PasswordHint : string );
    procedure Update;virtual;
  private
    procedure AddToInfo;
  end;

    // 添加
  TCloudBackupPathAddHandle = class( TCloudBackupPathReadHandle )
  private
    Account : string;
  public
    procedure SetAccount( _Account : string );
    procedure Update;override;
  private
    procedure AddToXml;
    procedure AddToEvent;
  end;

    // 删除
  TCloudBackupPathRemoveHandle = class( TCloudBackupPathWriteHandle )
  protected
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromXml;
    procedure RemoveFromEvent;
    procedure RemoveFromFile;
  end;


{$EndRegion}

{$Region ' 其他操作 ' }

  TPcOnlineHandle = class
  public
    OnlinePcID : string;
    Account : string;
  public
    constructor Create( _OnlinePcID : string );
    procedure SetAccount( _Account : string );
    procedure Update;
  private
    procedure SendCloudPathToPc;
    procedure SendRestoreToPc( CloudPath : string );
  end;

    // 连接云
  TConnPcCloud = class
  public
    TcpSocket : TCustomIpClient;
    DesItemID : string;
    OwnerID : string;
  public
    DesPcID, CloudPath : string;
  public
    constructor Create( _TcpSocket : TCustomIpClient );
    procedure SetDesItemID( _DesItemID : string );
    procedure SetOwnerID( _OwnerID : string );
    function get : string;
  public
    function ConnToPc : Boolean;
  end;

{$EndRegion}

  TCloudAddBackupParams = record
  public
    CloudPath, BackupPath, OwnerID : string;
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


    // 共享路径
  MyCloudPathUserApi = class
  public
    class procedure AddItem( CloudPath : string );
    class procedure RemoveItem( CloudPath : string );
  end;

    // 共享路径 程序 Api
  MyCloudPathAppApi = class
  public
    class procedure AddBackConnBackup( DesPcID : string );
    class procedure AddBackConnRestore( DesPcID : string );
  end;

    // 共享路径下的Pc
  MyCloudPcPathAppApi = class
  public
    class procedure PcOnline( PcID, Account : string );
  end;

    // 共享路径下的Pc备份路径
  MyCloudPcBackupAppApi = class
  public
    class procedure AddItem( Params : TCloudAddBackupParams );
    class procedure RemoveItem( CloudPath, PcID, BackupPath : string );
  end;

const
  CloudConnResult_OK = 'OK';
  CloudConnResult_Offline = 'Offline';
  CloudConnResult_CannotConn = 'CannotConn';
  CloudConnResult_NotExist = 'NotExit';
  CloudConnResult_CannotWrite = 'CannotWrite';

implementation

uses UMyCloudDataInfo, UMyCloudXmlInfo, UMyCloudEventInfo, UMyClient, UMyNetPcInfo,
     UMyCloudFaceInfo, UMyTcp, UCloudThread;


{ TPcOnlineHandle }

constructor TPcOnlineHandle.Create(_OnlinePcID: string);
begin
  OnlinePcID := _OnlinePcID;
end;

procedure TPcOnlineHandle.SendCloudPathToPc;
var
  CloudPathList : TStringList;
  i: Integer;
  AvailableSpace : Int64;
  CloudPathAddMsg : TCloudPathAddMsg;
begin
  CloudPathList := MyCloudInfoReadUtil.ReadCloudPathList;
  for i := 0 to CloudPathList.Count - 1 do
  begin
      // 可用空间
    AvailableSpace := MyHardDisk.getHardDiskFreeSize( CloudPathList[i] );

      // 发送路径
    CloudPathAddMsg := TCloudPathAddMsg.Create;
    CloudPathAddMsg.SetPcID( PcInfo.PcID );
    CloudPathAddMsg.SetCloudPath( CloudPathList[i] );
    CloudPathAddMsg.SetAvailableSpace( AvailableSpace );
    MyClient.SendMsgToPc( OnlinePcID, CloudPathAddMsg );

      // 发送恢复
    SendRestoreToPc( CloudPathList[i] );
  end;
  CloudPathList.Free;
end;

procedure TPcOnlineHandle.SendRestoreToPc( CloudPath : string );
var
  OwnerList : TStringList;
  CloudBackupPathList : TCloudBackupPathList;
  i, j : Integer;
  OwnerID, OwnerName : string;
  CloudBackupPathInfo : TCloudBackupPathInfo;
  CloudBackupAddRestoreMsg : TCloudBackupAddRestoreMsg;
begin
  OwnerList := MyCloudInfoReadUtil.ReadCloudOwnerList( CloudPath );
  for i := 0 to OwnerList.Count - 1 do
  begin
    OwnerID := OwnerList[i];
    OwnerName := MyNetPcInfoReadUtil.ReadName( OwnerID );
    CloudBackupPathList := MyCloudInfoReadUtil.ReadCloudOwnerBackupPathList( CloudPath, OwnerID );
    for j := 0 to CloudBackupPathList.Count - 1 do
    begin
      CloudBackupPathInfo := CloudBackupPathList[j];
      if not MyAccountReadUtil.ReadAccountPathExist( Account, CloudBackupPathInfo.BackupPath ) then
        Continue;

      CloudBackupAddRestoreMsg := TCloudBackupAddRestoreMsg.Create;
      CloudBackupAddRestoreMsg.SetPcID( PcInfo.PcID );
      CloudBackupAddRestoreMsg.SetCloudPath( CloudPath );
      CloudBackupAddRestoreMsg.SetBackupPath( CloudBackupPathInfo.BackupPath );
      CloudBackupAddRestoreMsg.SetIsFile( CloudBackupPathInfo.IsFile );
      CloudBackupAddRestoreMsg.SetOwnerInfo( OwnerID, OwnerName );
      CloudBackupAddRestoreMsg.SetSpaceInfo( CloudBackupPathInfo.FileCount, CloudBackupPathInfo.ItemSize );
      CloudBackupAddRestoreMsg.SetLastBackupTime( CloudBackupPathInfo.LastBackupTime );
      CloudBackupAddRestoreMsg.SetIsSaveDeleted( CloudBackupPathInfo.IsSaveDeleted );
      CloudBackupAddRestoreMsg.SetEncryptInfo( CloudBackupPathInfo.IsEncrypted, CloudBackupPathInfo.Password, CloudBackupPathInfo.PasswordHint );
      CloudBackupAddRestoreMsg.SetAccount( Account );
      MyClient.SendMsgToPc( OnlinePcID, CloudBackupAddRestoreMsg );
    end;
    CloudBackupPathList.Free;
  end;
  OwnerList.Free;
end;




procedure TPcOnlineHandle.SetAccount(_Account: string);
begin
  Account := _Account;
end;

procedure TPcOnlineHandle.Update;
begin
  SendCloudPathToPc;
end;

constructor TCloudPathWriteHandle.Create( _CloudPath : string );
begin
  CloudPath := _CloudPath;
end;


{ TCloudPathReadHandle }

procedure TCloudPathReadHandle.AddToInfo;
var
  CloudPathAddInfo : TCloudPathAddInfo;
begin
  CloudPathAddInfo := TCloudPathAddInfo.Create( CloudPath );
  CloudPathAddInfo.Update;
  CloudPathAddInfo.Free;
end;

procedure TCloudPathReadHandle.AddToFace;
var
  CloudPathAddFace : TCloudPathAddFace;
begin
  CloudPathAddFace := TCloudPathAddFace.Create( CloudPath );
  CloudPathAddFace.AddChange;
end;

procedure TCloudPathReadHandle.Update;
begin
  AddToInfo;
  AddToFace;
end;

{ TCloudPathAddHandle }

procedure TCloudPathAddHandle.AddToEvent;
begin
  MyCloudPathEvent.AddItem( CloudPath );
end;

procedure TCloudPathAddHandle.AddToXml;
var
  CloudPathAddXml : TCloudPathAddXml;
begin
  CloudPathAddXml := TCloudPathAddXml.Create( CloudPath );
  CloudPathAddXml.AddChange;
end;

procedure TCloudPathAddHandle.Update;
begin
  inherited;
  AddToXml;
  AddToEvent;
end;

{ TCloudPathRemoveHandle }

procedure TCloudPathRemoveHandle.RemoveFromInfo;
var
  CloudPathRemoveInfo : TCloudPathRemoveInfo;
begin
  CloudPathRemoveInfo := TCloudPathRemoveInfo.Create( CloudPath );
  CloudPathRemoveInfo.Update;
  CloudPathRemoveInfo.Free;
end;

procedure TCloudPathRemoveHandle.RemoveFromEvent;
begin
  MyCloudPathEvent.RemoveItem( CloudPath );
end;

procedure TCloudPathRemoveHandle.RemoveFromFace;
var
  CloudPathRemoveFace : TCloudPathRemoveFace;
begin
  CloudPathRemoveFace := TCloudPathRemoveFace.Create( CloudPath );
  CloudPathRemoveFace.AddChange;
end;

procedure TCloudPathRemoveHandle.RemoveFromXml;
var
  CloudPathRemoveXml : TCloudPathRemoveXml;
begin
  CloudPathRemoveXml := TCloudPathRemoveXml.Create( CloudPath );
  CloudPathRemoveXml.AddChange;
end;

procedure TCloudPathRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromFace;
  RemoveFromXml;
  RemoveFromEvent;
end;




{ MyCloudShareUserApi }

class procedure MyCloudPathUserApi.AddItem(CloudPath: string);
var
  CloudPathAddHandle : TCloudPathAddHandle;
begin
  CloudPathAddHandle := TCloudPathAddHandle.Create( CloudPath );
  CloudPathAddHandle.Update;
  CloudPathAddHandle.Free;
end;

class procedure MyCloudPathUserApi.RemoveItem(CloudPath: string);
var
  CloudPathRemoveHandle : TCloudPathRemoveHandle;
begin
  CloudPathRemoveHandle := TCloudPathRemoveHandle.Create( CloudPath );
  CloudPathRemoveHandle.Update;
  CloudPathRemoveHandle.Free;
end;

{ MyCloudPcBackupAppApi }

class procedure MyCloudPcBackupAppApi.AddItem(Params: TCloudAddBackupParams);
var
  CloudPcBackupPathAddHandle : TCloudBackupPathAddHandle;
begin
    // 添加 路径 Item
  CloudPcBackupPathAddHandle := TCloudBackupPathAddHandle.Create( Params.CloudPath );
  CloudPcBackupPathAddHandle.SetBackupInfo( Params.BackupPath, Params.OwnerID );
  CloudPcBackupPathAddHandle.SetIsFile( Params.IsFile );
  CloudPcBackupPathAddHandle.SetSpaceInfo( Params.FileCount, Params.FileSpace );
  CloudPcBackupPathAddHandle.SetLastBackupTime( Params.LastDateTime );
  CloudPcBackupPathAddHandle.SetIsSaveDeleted( Params.IsSaveDeleted );
  CloudPcBackupPathAddHandle.SetEncryptInfo( Params.IsEncrypted, Params.Password, Params.PasswordHint );
  CloudPcBackupPathAddHandle.SetAccount( Params.Account );
  CloudPcBackupPathAddHandle.Update;
  CloudPcBackupPathAddHandle.Free;
end;

class procedure MyCloudPcBackupAppApi.RemoveItem(CloudPath, PcID,
  BackupPath: string);
var
  CloudPcBackupPathRemoveHandle : TCloudBackupPathRemoveHandle;
begin
  CloudPcBackupPathRemoveHandle := TCloudBackupPathRemoveHandle.Create( CloudPath );
  CloudPcBackupPathRemoveHandle.SetBackupInfo( BackupPath, PcID );
  CloudPcBackupPathRemoveHandle.Update;
  CloudPcBackupPathRemoveHandle.Free;
end;


procedure TCloudBackupPathWriteHandle.SetBackupInfo( _BackupPath, _OwnerID : string );
begin
  BackupPath := _BackupPath;
  OwnerID := _OwnerID;
end;

{ TCloudPcBackupPathReadHandle }

procedure TCloudBackupPathReadHandle.SetIsFile( _IsFile : boolean );
begin
  IsFile := _IsFile;
end;

procedure TCloudBackupPathReadHandle.SetSpaceInfo( _FileCount : integer; _ItemSize : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
end;

procedure TCloudBackupPathReadHandle.SetLastBackupTime( _LastBackupTime : TDateTime );
begin
  LastBackupTime := _LastBackupTime;
end;

procedure TCloudBackupPathReadHandle.SetIsSaveDeleted( _IsSaveDeleted : boolean );
begin
  IsSaveDeleted := _IsSaveDeleted;
end;

procedure TCloudBackupPathReadHandle.SetEncryptInfo( _IsEncrypted : boolean; _Password, _PasswordHint : string );
begin
  IsEncrypted := _IsEncrypted;
  Password := _Password;
  PasswordHint := _PasswordHint;
end;

procedure TCloudBackupPathReadHandle.AddToInfo;
var
  CloudPcBackupPathAddInfo : TCloudBackupPathAddInfo;
begin
  CloudPcBackupPathAddInfo := TCloudBackupPathAddInfo.Create( CloudPath );
  CloudPcBackupPathAddInfo.SetBackupPath( BackupPath, OwnerID );
  CloudPcBackupPathAddInfo.SetIsFile( IsFile );
  CloudPcBackupPathAddInfo.SetSpaceInfo( FileCount, ItemSize );
  CloudPcBackupPathAddInfo.SetLastBackupTime( LastBackupTime );
  CloudPcBackupPathAddInfo.SetIsSaveDeleted( IsSaveDeleted );
  CloudPcBackupPathAddInfo.SetEncryptInfo( IsEncrypted, Password, PasswordHint );
  CloudPcBackupPathAddInfo.Update;
  CloudPcBackupPathAddInfo.Free;
end;


procedure TCloudBackupPathReadHandle.Update;
begin
  AddToInfo;
end;

{ TCloudPcBackupPathAddHandle }

procedure TCloudBackupPathAddHandle.AddToEvent;
var
  Params : TCloudAddEventParam;
begin
  Params.CloudPath := CloudPath;
  Params.PcID := OwnerID;
  Params.BackupPath := BackupPath;
  Params.IsFile := IsFile;
  Params.FileCount := FileCount;
  Params.FileSpace := ItemSize;
  Params.LastDateTime := LastBackupTime;
  Params.IsSaveDeleted := IsSaveDeleted;
  Params.IsEncrypted := IsEncrypted;
  Params.Password := Password;
  Params.PasswordHint := PasswordHint;
  Params.Account := Account;

  MyCloudPcBackupPathEvent.AddItem( Params );
end;

procedure TCloudBackupPathAddHandle.AddToXml;
var
  CloudPcBackupPathAddXml : TCloudBackupPathAddXml;
begin
  CloudPcBackupPathAddXml := TCloudBackupPathAddXml.Create( CloudPath );
  CloudPcBackupPathAddXml.SetBackupPath( BackupPath, OwnerID );
  CloudPcBackupPathAddXml.SetIsFile( IsFile );
  CloudPcBackupPathAddXml.SetSpaceInfo( FileCount, ItemSize );
  CloudPcBackupPathAddXml.SetLastBackupTime( LastBackupTime );
  CloudPcBackupPathAddXml.SetIsSaveDeleted( IsSaveDeleted );
  CloudPcBackupPathAddXml.SetEncryptInfo( IsEncrypted, Password, PasswordHint );
  CloudPcBackupPathAddXml.AddChange;
end;

procedure TCloudBackupPathAddHandle.SetAccount(_Account: string);
begin
  Account := _Account;
end;

procedure TCloudBackupPathAddHandle.Update;
begin
  inherited;
  AddToXml;
  AddToEvent;
end;

{ TCloudPcBackupPathRemoveHandle }

procedure TCloudBackupPathRemoveHandle.RemoveFromEvent;
begin
  MyCloudPcBackupPathEvent.RemoveItem( CloudPath, OwnerID, BackupPath );
end;

procedure TCloudBackupPathRemoveHandle.RemoveFromFile;
var
  CloudFilePath, CloudRecyclePath : string;
begin
    // 生成文件路径
  CloudFilePath := MyCloudInfoReadUtil.ReadCloudFilePath( CloudPath, OwnerID, BackupPath );
  CloudRecyclePath := MyCloudInfoReadUtil.ReadCloudRecyclePath( CloudPath, OwnerID, BackupPath );

  MyCloudFileHandler.AddRemovePath( CloudFilePath );
  MyCloudFileHandler.AddRemovePath( CloudRecyclePath );
end;

procedure TCloudBackupPathRemoveHandle.RemoveFromInfo;
var
  CloudPcBackupPathRemoveInfo : TCloudBackupPathRemoveInfo;
begin
  CloudPcBackupPathRemoveInfo := TCloudBackupPathRemoveInfo.Create( CloudPath );
  CloudPcBackupPathRemoveInfo.SetBackupPath( BackupPath, OwnerID );
  CloudPcBackupPathRemoveInfo.Update;
  CloudPcBackupPathRemoveInfo.Free;
end;


procedure TCloudBackupPathRemoveHandle.RemoveFromXml;
var
  CloudPcBackupPathRemoveXml : TCloudBackupPathRemoveXml;
begin
  CloudPcBackupPathRemoveXml := TCloudBackupPathRemoveXml.Create( CloudPath );
  CloudPcBackupPathRemoveXml.SetBackupPath( BackupPath, OwnerID );
  CloudPcBackupPathRemoveXml.AddChange;
end;

procedure TCloudBackupPathRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromXml;
  RemoveFromEvent;
  RemoveFromFile;
end;

{ MyCloudPathAppApi }

class procedure MyCloudPcPathAppApi.PcOnline(PcID, Account: string);
var
  PcOnlineHandle : TPcOnlineHandle;
begin
  PcOnlineHandle := TPcOnlineHandle.Create( PcID );
  PcOnlineHandle.SetAccount( Account );
  PcOnlineHandle.Update;
  PcOnlineHandle.Free;
end;

function TConnPcCloud.ConnToPc: Boolean;
var
  MyTcpConn : TMyTcpConn;
  DesPcIP, DesPcPort : string;
begin
    // 提取 目标 Pc 端口
  DesPcIP := MyNetPcInfoReadUtil.ReadIp( DesPcID );
  DesPcPort := MyNetPcInfoReadUtil.ReadPort( DesPcID );

    // 连接 目标 Pc
  MyTcpConn := TMyTcpConn.Create( TcpSocket );
  MyTcpConn.SetConnType( ConnType_CloudFileRequest );
  MyTcpConn.SetConnSocket( DesPcIP, DesPcPort );
  Result := MyTcpConn.Conn;
  MyTcpConn.Free;
end;

constructor TConnPcCloud.Create(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

function TConnPcCloud.get: string;
begin
    // 提取 Pc 信息
  DesPcID := NetworkDesItemUtil.getPcID( DesItemID );
  CloudPath := NetworkDesItemUtil.getCloudPath( DesItemID );

    // 是否离线
  if not MyNetPcInfoReadUtil.ReadIsOnline( DesPcID ) then
  begin
    Result := CloudConnResult_Offline;
    Exit;
  end;

    // 是否可以连接
  if not ConnToPc then
  begin
    Result := CloudConnResult_CannotConn;
    Exit;
  end;

    // 发送初始化信息
  MySocketUtil.SendString( TcpSocket, CloudPath );
  MySocketUtil.SendString( TcpSocket, OwnerID );

    // 读取访问结果
  Result := MySocketUtil.RevData( TcpSocket );
  if Result = '' then
    Result := CloudConnResult_Offline;
end;

procedure TConnPcCloud.SetDesItemID(_DesItemID: string);
begin
  DesItemID := _DesItemID;
end;

procedure TConnPcCloud.SetOwnerID(_OwnerID: string);
begin
  OwnerID := _OwnerID;
end;

{ MyCloudPathAppApi }

class procedure MyCloudPathAppApi.AddBackConnBackup(DesPcID: string);
begin
  MyCloudFileHandler.ReceiveBackConnBackup( DesPcID );
end;

class procedure MyCloudPathAppApi.AddBackConnRestore(DesPcID: string);
begin
  MyCloudFileHandler.ReceiveBackConnRestore( DesPcID );
end;

end.
