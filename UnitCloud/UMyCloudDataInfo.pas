unit UMyCloudDataInfo;

interface

uses Generics.Collections, UDataSetInfo, UMyUtil, classes;

type

{$Region ' 数据结构 ' }

    // 云路径 保存的Pc路径
  TCloudBackupPathInfo = class
  public
    BackupPath, OwnerID : string;
    IsFile : boolean;
  public
    FileCount : integer;
    ItemSize : int64;
    LastBackupTime : TDateTime;
  public
    IsSaveDeleted : Boolean;
    IsEncrypted : Boolean;
    Password, PasswordHint : string;
  public
    constructor Create( _BackupPath, _OwnerID : string );
    procedure SetIsFile( _IsFile : boolean );
    procedure SetSpaceInfo( _FileCount : integer; _ItemSize : int64 );
    procedure SetLastBackupTime( _LastBackupTime : TDateTime );
    procedure SetIsSaveDeleted( _IsSaveDeleted : Boolean );
    procedure SetEncryptInfo( _IsEncrypted : Boolean; _Password, _PasswordHint : string );
  end;
  TCloudBackupPathList = class( TObjectList<TCloudBackupPathInfo> );

    // 云路径
  TCloudPathInfo = class
  public
    CloudPath : string;
    CloudBackupPathList : TCloudBackupPathList;
  public
    constructor Create( _CloudPath : string );
    destructor Destroy; override;
  end;
  TCloudPathList = class( TObjectList< TCloudPathInfo > )end;


    // 云Pc信息
  TMyCloudInfo = class( TMyDataInfo )
  public
    CloudPathList : TCloudPathList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

{$EndRegion}

{$Region ' 数据接口 ' }

    // 访问 数据 List 接口
  TCloudPathListAccessInfo = class
  protected
    CloudPathList : TCloudPathList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // 访问 数据接口
  TCloudPathAccessInfo = class( TCloudPathListAccessInfo )
  public
    CloudPath : string;
  protected
    CloudPathIndex : Integer;
    CloudPathInfo : TCloudPathInfo;
  public
    constructor Create( _CloudPath : string );
  protected
    function FindCloudPathInfo: Boolean;
  end;

    // 访问 数据 List 接口
  TCloudBackupPathListAccessInfo = class( TCloudPathAccessInfo )
  protected
    CloudBackupPathList : TCloudBackupPathList;
  protected
    function FindCloudBackupPathList : Boolean;
  end;

    // 访问 数据接口
  TCloudBackupPathAccessInfo = class( TCloudBackupPathListAccessInfo )
  public
    BackupPath, OwnerID : string;
  protected
    CloudBackupPathIndex : Integer;
    CloudBackupPathInfo : TCloudBackupPathInfo;
  public
    procedure SetBackupPath( _BackupPath, _OwnerID : string );
  protected
    function FindCloudPcBackupPathInfo: Boolean;
  end;

{$EndRegion}

{$Region ' 数据修改 云路径信息 ' }

    // 修改父类
  TCloudPathWriteInfo = class( TCloudPathAccessInfo )
  end;

    // 添加
  TCloudPathAddInfo = class( TCloudPathWriteInfo )
  public
    procedure Update;
  end;

    // 删除
  TCloudPathRemoveInfo = class( TCloudPathWriteInfo )
  public
    procedure Update;
  end;


{$EndRegion}

{$Region ' 数据修改 备份路径 ' }

    // 修改父类
  TCloudBackupPathWriteInfo = class( TCloudBackupPathAccessInfo )
  end;

      // 添加
  TCloudBackupPathAddInfo = class( TCloudBackupPathWriteInfo )
  public
    IsFile : boolean;
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
    procedure Update;
  end;

    // 删除
  TCloudBackupPathRemoveInfo = class( TCloudBackupPathWriteInfo )
  public
    procedure Update;
  end;

{$EndRegion}

{$Region ' 数据读取 ' }

    // 读取 所有云路径
  TCloudPathReadList = class( TCloudPathListAccessInfo )
  public
    function get : TStringList;
  end;

  TCloudPathReadExist = class( TCloudPathAccessInfo )
  public
    function get : Boolean;
  end;

  TCloudOnwerReadList = class( TCloudBackupPathListAccessInfo )
  public
    function get : TStringList;
  end;

  TCloudBackupPathReadList = class( TCloudBackupPathListAccessInfo )
  public
    OwnerID : string;
  public
    procedure SetOwnerID( _OwnerID : string );
    function get : TCloudBackupPathList;
  end;

  MyCloudInfoReadUtil = class
  public
    class function ReadCloudPathList : TStringList;
    class function ReadCloudPathExist( CloudPath : string ): Boolean;
    class function ReadCloudOwnerList( CloudPath : string ) : TStringList;
    class function ReadCloudOwnerBackupPathList( CloudPath, OwnerID : string ) : TCloudBackupPathList;
  public
    class function ReadCloudPcPath( CloudPath, PcID : string ): string;
    class function ReadCloudFilePath( CloudPath, PcID, FilePath : string ): string;
    class function ReadCloudRecyclePath( CloudPath, PcID, FilePath : string ): string;
  end;

{$EndRegion}

const
  NetworkBackup_RecycledFolder = 'Recycled';

var
  MyCloudInfo : TMyCloudInfo;

implementation

{ TCloudPcBackupInfo }

constructor TCloudBackupPathInfo.Create( _BackupPath, _OwnerID : string );
begin
  BackupPath := _BackupPath;
  OwnerID := _OwnerID;
end;

procedure TCloudBackupPathInfo.SetEncryptInfo(_IsEncrypted: Boolean; _Password,
  _PasswordHint: string);
begin
  IsEncrypted := _IsEncrypted;
  Password := _Password;
  PasswordHint := _PasswordHint;
end;

procedure TCloudBackupPathInfo.SetIsFile( _IsFile : boolean );
begin
  IsFile := _IsFile;
end;

procedure TCloudBackupPathInfo.SetIsSaveDeleted(_IsSaveDeleted: Boolean);
begin
  IsSaveDeleted := _IsSaveDeleted;
end;

procedure TCloudBackupPathInfo.SetLastBackupTime(_LastBackupTime: TDateTime);
begin
  LastBackupTime := _LastBackupTime;
end;

procedure TCloudBackupPathInfo.SetSpaceInfo( _FileCount : integer; _ItemSize : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
end;

{ TMyCloudInfo }

constructor TMyCloudInfo.Create;
begin
  inherited;
  CloudPathList := TCloudPathList.Create;
end;

destructor TMyCloudInfo.Destroy;
begin
  CloudPathList.Free;
  inherited;
end;

{ MyCloudInfoReadUtil }

class function MyCloudInfoReadUtil.ReadCloudOwnerBackupPathList(
  CloudPath, OwnerID : string ): TCloudBackupPathList;
var
  CloudBackupPathReadList : TCloudBackupPathReadList;
begin
  CloudBackupPathReadList := TCloudBackupPathReadList.Create( CloudPath );
  CloudBackupPathReadList.SetOwnerID( OwnerID );
  Result := CloudBackupPathReadList.get;
  CloudBackupPathReadList.Free;
end;

class function MyCloudInfoReadUtil.ReadCloudFilePath(CloudPath, PcID,
  FilePath: string): string;
begin
  Result := MyFilePath.getPath( ReadCloudPcPath( CloudPath, PcID ) );
  Result := Result + MyFilePath.getDownloadPath( FilePath );
end;

class function MyCloudInfoReadUtil.ReadCloudOwnerList(
  CloudPath: string): TStringList;
var
  CloudOnwerReadList : TCloudOnwerReadList;
begin
  CloudOnwerReadList := TCloudOnwerReadList.Create( CloudPath );
  Result := CloudOnwerReadList.get;
  CloudOnwerReadList.Free;
end;

class function MyCloudInfoReadUtil.ReadCloudPathExist(
  CloudPath: string): Boolean;
var
  CloudPathReadExist : TCloudPathReadExist;
begin
  CloudPathReadExist := TCloudPathReadExist.Create( CloudPath );
  Result := CloudPathReadExist.get;
  CloudPathReadExist.Free;
end;

class function MyCloudInfoReadUtil.ReadCloudPathList: TStringList;
var
  CloudPathReadList : TCloudPathReadList;
begin
  CloudPathReadList := TCloudPathReadList.Create;
  Result := CloudPathReadList.get;
  CloudPathReadList.Free;
end;


class function MyCloudInfoReadUtil.ReadCloudPcPath(CloudPath, PcID: string): string;
begin
  Result := MyFilePath.getPath( CloudPath ) + PcID;
end;

class function MyCloudInfoReadUtil.ReadCloudRecyclePath(CloudPath, PcID,
  FilePath: string): string;
begin
  Result := MyFilePath.getPath( ReadCloudPcPath( CloudPath, PcID ) );
  Result := Result + MyFilePath.getPath( NetworkBackup_RecycledFolder );
  Result := Result + MyFilePath.getDownloadPath( FilePath );
end;

{ TCloudPathInfo }

constructor TCloudPathInfo.Create(_CloudPath: string);
begin
  CloudPath := _CloudPath;
  CloudBackupPathList := TCloudBackupPathList.Create;
end;

destructor TCloudPathInfo.Destroy;
begin
  CloudBackupPathList.Free;
  inherited;
end;

{ TCloudPathListAccessInfo }

constructor TCloudPathListAccessInfo.Create;
begin
  MyCloudInfo.EnterData;
  CloudPathList := MyCloudInfo.CloudPathList;
end;

destructor TCloudPathListAccessInfo.Destroy;
begin
  MyCloudInfo.LeaveData;
  inherited;
end;

{ TCloudPathAccessInfo }

constructor TCloudPathAccessInfo.Create( _CloudPath : string );
begin
  inherited Create;
  CloudPath := _CloudPath;
end;

function TCloudPathAccessInfo.FindCloudPathInfo: Boolean;
var
  i : Integer;
begin
  Result := False;
  for i := 0 to CloudPathList.Count - 1 do
    if ( CloudPathList[i].CloudPath = CloudPath ) then
    begin
      Result := True;
      CloudPathIndex := i;
      CloudPathInfo := CloudPathList[i];
      break;
    end;
end;

{ TCloudPathAddInfo }

procedure TCloudPathAddInfo.Update;
begin
  if FindCloudPathInfo then
    Exit;

  CloudPathInfo := TCloudPathInfo.Create( CloudPath );
  CloudPathList.Add( CloudPathInfo );
end;

{ TCloudPathRemoveInfo }

procedure TCloudPathRemoveInfo.Update;
begin
  if not FindCloudPathInfo then
    Exit;

  CloudPathList.Delete( CloudPathIndex );
end;

{ TCloudPcBackupPathListAccessInfo }

function TCloudBackupPathListAccessInfo.FindCloudBackupPathList : Boolean;
begin
  Result := FindCloudPathInfo;
  if Result then
    CloudBackupPathList := CloudPathInfo.CloudBackupPathList
  else
    CloudBackupPathList := nil;
end;

{ TCloudPcBackupPathAccessInfo }

procedure TCloudBackupPathAccessInfo.SetBackupPath( _BackupPath, _OwnerID : string );
begin
  BackupPath := _BackupPath;
  OwnerID := _OwnerID;
end;


function TCloudBackupPathAccessInfo.FindCloudPcBackupPathInfo: Boolean;
var
  i : Integer;
begin
  Result := False;
  if not FindCloudBackupPathList then
    Exit;
  for i := 0 to CloudBackupPathList.Count - 1 do
    if ( CloudBackupPathList[i].BackupPath = BackupPath ) and
       ( CloudBackupPathList[i].OwnerID = OwnerID )
    then
    begin
      Result := True;
      CloudBackupPathIndex := i;
      CloudBackupPathInfo := CloudBackupPathList[i];
      break;
    end;
end;

{ TCloudPcBackupPathAddInfo }

procedure TCloudBackupPathAddInfo.SetIsFile( _IsFile : boolean );
begin
  IsFile := _IsFile;
end;

procedure TCloudBackupPathAddInfo.SetSpaceInfo( _FileCount : integer; _ItemSize : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
end;

procedure TCloudBackupPathAddInfo.SetLastBackupTime( _LastBackupTime : TDateTime );
begin
  LastBackupTime := _LastBackupTime;
end;

procedure TCloudBackupPathAddInfo.SetIsSaveDeleted( _IsSaveDeleted : boolean );
begin
  IsSaveDeleted := _IsSaveDeleted;
end;

procedure TCloudBackupPathAddInfo.SetEncryptInfo( _IsEncrypted : boolean; _Password, _PasswordHint : string );
begin
  IsEncrypted := _IsEncrypted;
  Password := _Password;
  PasswordHint := _PasswordHint;
end;

procedure TCloudBackupPathAddInfo.Update;
begin
    // 不存在 则创建
  if not FindCloudPcBackupPathInfo then
  begin
    if CloudBackupPathList = nil then
      Exit;
    CloudBackupPathInfo := TCloudBackupPathInfo.Create( BackupPath, OwnerID );
    CloudBackupPathList.Add( CloudBackupPathInfo );
  end;

  CloudBackupPathInfo.SetIsFile( IsFile );
  CloudBackupPathInfo.SetSpaceInfo( FileCount, ItemSize );
  CloudBackupPathInfo.SetLastBackupTime( LastBackupTime );
  CloudBackupPathInfo.SetIsSaveDeleted( IsSaveDeleted );
  CloudBackupPathInfo.SetEncryptInfo( IsEncrypted, Password, PasswordHint );
end;

{ TCloudPcBackupPathRemoveInfo }

procedure TCloudBackupPathRemoveInfo.Update;
begin
  if not FindCloudPcBackupPathInfo then
    Exit;

  CloudBackupPathList.Delete( CloudBackupPathIndex );
end;




{ TCloudPathReadList }

function TCloudPathReadList.get: TStringList;
var
  i: Integer;
begin
  Result := TStringList.Create;
  for i := 0 to CloudPathList.Count - 1 do
    Result.Add( CloudPathList[i].CloudPath );
end;

{ TCloudPathReadExist }

function TCloudPathReadExist.get: Boolean;
begin
  Result := FindCloudPathInfo;
end;

{ TCloudBackupPathReadList }

function TCloudBackupPathReadList.get: TCloudBackupPathList;
var
  i : Integer;
  OldCloudBackup, NewCloudBackup : TCloudBackupPathInfo;
begin
  Result := TCloudBackupPathList.Create;
  if not FindCloudBackupPathList then
    Exit;

  for i := 0 to CloudBackupPathList.Count - 1 do
  begin
    OldCloudBackup := CloudBackupPathList[i];
    if OldCloudBackup.OwnerID <> OwnerID then
      Continue;

    NewCloudBackup := TCloudBackupPathInfo.Create( OldCloudBackup.BackupPath, OldCloudBackup.OwnerID );
    NewCloudBackup.SetIsFile( OldCloudBackup.IsFile );
    NewCloudBackup.SetSpaceInfo( OldCloudBackup.FileCount, OldCloudBackup.ItemSize );
    NewCloudBackup.SetLastBackupTime( OldCloudBackup.LastBackupTime );
    NewCloudBackup.SetIsSaveDeleted( OldCloudBackup.IsSaveDeleted );
    NewCloudBackup.SetEncryptInfo( OldCloudBackup.IsEncrypted, OldCloudBackup.Password, OldCloudBackup.PasswordHint );
    Result.Add( NewCloudBackup );
  end;
end;

{ TCloudPcReadList }

function TCloudOnwerReadList.get: TStringList;
var
  i : Integer;
  OwnerID : string;
begin
  Result := TStringList.Create;
  if not FindCloudBackupPathList then
    Exit;
  for i := 0 to CloudBackupPathList.Count - 1 do
  begin
    OwnerID := CloudBackupPathList[i].OwnerID;
    if Result.IndexOf( OwnerID ) < 0 then
      Result.Add( OwnerID );
  end;
end;

procedure TCloudBackupPathReadList.SetOwnerID(_OwnerID: string);
begin
  OwnerID := _OwnerID;
end;

end.
