unit UFileWatcher;

interface

uses Windows, UModelUtil, Generics.Collections, SyncObjs, Classes, UMyUtil, SysUtils, DateUtils;

type

    // 数据结构
  PFileNotifyInformation = ^FILE_NOTIFY_INFORMATION;
  FILE_NOTIFY_INFORMATION = Record
    NextEntryOffset: DWORD;
    Action: DWORD;
    FileNameLength: DWORD;
    FileName: Array[0..MAX_PATH] Of WideChar;
  End;

    // 文件变化 数据结构
  TFileChangeInfo = class
  public
    FilePath1, FilePath2 : string;
    ChangeType : Integer;
    WatchPath : string;
  public
    constructor Create( _FilePath1, _FilePath2 : string );
    procedure SetChangeType( _ChangeType : Integer );
    procedure SetWatchPath( _WatchPath : string );
  end;
  TFileChangeList = class(TObjectList< TFileChangeInfo >);

  TFileChangeHandleThread = class;

    // 文件变化 数据集合
  TFileChangeData = class
  private
    DataLock : TCriticalSection;
    FileChangeList : TFileChangeList;
  private
    FileChangeHandleThread : TFileChangeHandleThread;
  public
    constructor Create;
    procedure SetFileChangeHandleThread( _FileChangeHandleThread : TFileChangeHandleThread );
    destructor Destroy; override;
  public
    procedure addFileChange( FileChangeInfo : TFileChangeInfo );
    function getFileChange : TFileChangeInfo;
  end;


    // 寻找 文件变化 线程
  TFileChangeWatchThread = class( TThread )
  protected
    FullPath : string;
    FileChangeData : TFileChangeData;
  private
    IsWatching : Boolean;
    hDirectory : LongWord;
    CompletionPort : Integer;
  public
    constructor Create( _FullPath : string );
    procedure SetFileChangeData( _FileChangeData : TFileChangeData );
    procedure StopWatch;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure WatcherFolder;
    procedure WaitFolderExist;
  private
    procedure AddNotify( pNotify : PFileNotifyInformation );
    procedure AddChange( FileChangeType : Integer; FilePath1, FilePath2 : string );
  private
    function getFileName( NameLen : Integer; FileName : Array Of WideChar ): string;
    function getFilePath( FileName : string ): string;
  end;
  TFileChangeWatchThreadPair = TPair< string , TFileChangeWatchThread >;
  TFileChangeWatchThreadHash = class(TStringDictionary< TFileChangeWatchThread >);

  TSingleFileWatchInfo = class
  public
    FilePath : string;
    FileSize : Int64;
    FileTime : TDateTime;
  public
    constructor Create( _FilePath : string );
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
  end;
  TSingleFileWatchPair = TPair< string , TSingleFileWatchInfo >;
  TSingleFileWatchHash = class(TStringDictionary< TSingleFileWatchInfo >);


    // 检测 单个文件变化 线程
  TSingleFileChangeWatchThread = class( TThread )
  protected
    WatchLock : TCriticalSection;
    SingleFileWatchHash : TSingleFileWatchHash;
  protected
    FileChangeData : TFileChangeData;
  public
    constructor Create;
    procedure SetFileChangeData( _FileChangeData : TFileChangeData );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  public
    procedure AddWatchFile( SingleFileWatchInfo : TSingleFileWatchInfo );
    procedure RemoveWatchFile( FilePath : string );
  private
    procedure CheckFileChange;
  end;

      // 变化结果处理
  TFileChangeHandle = class
  private
    FileChangeInfo : TFileChangeInfo;
    FileChangeType : Integer;
  protected
    FilePath1, FilePath2 : string;
    WatchPath : string;
  public
    constructor Create( _FileChangeInfo : TFileChangeInfo );
    procedure Update;
  protected
    procedure FileAdd;virtual;abstract;
    procedure FileRemove;virtual;abstract;
    procedure FileModify;virtual;abstract;
    procedure FileRename;virtual;abstract;
  end;

    // 处理 文件变化 线程
  TFileChangeHandleThread = class( TThread )
  private
    FileChangeData : TFileChangeData;
  public
    constructor Create;
    procedure SetFileChangeData( _FileChangeData : TFileChangeData );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  protected
    procedure HandleChange( FileChangeInfo : TFileChangeInfo );virtual;abstract;
  end;

    // 检测 监听路径 存在
  TWatchPathExistThread = class( TThread )
  private
    PathLock : TCriticalSection;
    WatchExistPathHash : TStringHash;
    WatchNotExistPathHash : TStringHash;
  public
    constructor Create;
    destructor Destroy; override;
  public
    procedure AddWatchPath( WatchPath : string; IsExist : Boolean );
    procedure RemoveWatchPath( WatchPath : string );
  protected
    procedure Execute; override;
  private
    function IsExistPath( Path : string ): Boolean;
    procedure CheckExistWatchPath;
    procedure CheckNotExistWatchPath;
  protected
    procedure WatchPathNotEixst( WatchPath : string );virtual;abstract;
    procedure WatchPathExist( WatchPath : string );virtual;abstract;
  end;

const
  FileChangeType_Add = 1;
  FileChangeType_Remove = 2;
  FileChangeType_Modify = 3;
  FileChangeType_Rename = 4;

  WatchPathType_NetworkBackup = 'NetworkBackup';
  WatchPathType_LocalBackup = 'LocalBackup';

implementation

{ TFileChangeInfo }

constructor TFileChangeInfo.Create(_FilePath1, _FilePath2: string);
begin
  FilePath1 := _FilePath1;
  FilePath2 := _FilePath2;
end;

procedure TFileChangeInfo.SetChangeType(_ChangeType: Integer);
begin
  ChangeType := _ChangeType;
end;

procedure TFileChangeInfo.SetWatchPath(_WatchPath: string);
begin
  WatchPath := _WatchPath;
end;

{ TFileChangeData }

procedure TFileChangeData.addFileChange(FileChangeInfo: TFileChangeInfo);
begin
  DataLock.Enter;
  FileChangeList.Add( FileChangeInfo );
  DataLock.Leave;

  if FileChangeHandleThread <> nil then
    FileChangeHandleThread.Resume;
end;

constructor TFileChangeData.Create;
begin
  DataLock := TCriticalSection.Create;
  FileChangeList := TFileChangeList.Create;
  FileChangeList.OwnsObjects := False;
end;

destructor TFileChangeData.Destroy;
begin
  FileChangeList.OwnsObjects := True;
  FileChangeList.Free;
  DataLock.Free;
  inherited;
end;

function TFileChangeData.getFileChange: TFileChangeInfo;
begin
  DataLock.Enter;
  if FileChangeList.Count > 0 then
  begin
    Result := FileChangeList[0];
    FileChangeList.Delete(0);
  end
  else
    Result := nil;
  DataLock.Leave;
end;

procedure TFileChangeData.SetFileChangeHandleThread(
  _FileChangeHandleThread: TFileChangeHandleThread);
begin
  FileChangeHandleThread := _FileChangeHandleThread;
end;

{ TFileChangeWatchThread }

procedure TFileChangeWatchThread.AddChange(FileChangeType: Integer; FilePath1,
  FilePath2: string);
var
  FileChangeInfo : TFileChangeInfo;
begin
  FileChangeInfo := TFileChangeInfo.Create( FilePath1, FilePath2 );
  FileChangeInfo.SetChangeType( FileChangeType );
  FileChangeInfo.SetWatchPath( FullPath );
  FileChangeData.addFileChange( FileChangeInfo );
end;

procedure TFileChangeWatchThread.AddNotify(pNotify: PFileNotifyInformation);
var
  Offset: Longint;
  FilePath1, FilePath2: string;
  FileChangeType : Integer;
begin
  repeat
    with pNotify^ do
    begin
      Offset := NextEntryOffset;
      FilePath2 := '';
      case Action of
        FILE_ACTION_ADDED..FILE_ACTION_MODIFIED:
        begin
          FilePath1 := getFilePath(getFileName(FileNameLength,FileName));
          FileChangeType := Action;
          AddChange( FileChangeType, FilePath1, FilePath2 );
        end;
        FILE_ACTION_RENAMED_OLD_NAME:
        begin
          FilePath1 := getFilePath(getFileName(FileNameLength,FileName));
          FileChangeType := Action;
        end;
        FILE_ACTION_RENAMED_NEW_NAME:
        begin
          if FileChangeType = FileChangeType_Rename then
          begin
            FilePath2 := getFilePath(getFileName(FileNameLength,FileName));
            AddChange( FileChangeType, FilePath1, FilePath2 );
          end;
        end;
      end;
    end;
    Pointer(pNotify) := Pointer(PansiChar(pNotify) + OffSet);
  until Offset=0;
end;

constructor TFileChangeWatchThread.Create(_FullPath: string);
begin
  inherited Create( True );
  FullPath := _FullPath;
  IsWatching := False;
end;

destructor TFileChangeWatchThread.Destroy;
begin
  Terminate;
  StopWatch;
  Resume;
  WaitFor;

  inherited;
end;

procedure TFileChangeWatchThread.StopWatch;
begin
  if IsWatching then
  begin
    CloseHandle( hDirectory );
    CloseHandle( CompletionPort );
  end;
end;

procedure TFileChangeWatchThread.Execute;
begin
  while not Terminated do
  begin
      // 目录存在, 监听目录
    if DirectoryExists( FullPath ) then
      WatcherFolder;

      // 目录不存在, 等待目录出现
    if not DirectoryExists( FullPath ) then
      WaitFolderExist;
  end;

  inherited;
end;

function TFileChangeWatchThread.getFileName(NameLen: Integer;
  FileName: array of WideChar): string;
var
  i : Integer;
begin
  Result := '';
  i := 0;
  while NameLen > 0 do
  begin
    Result := Result + FileName[i];
    i := i + 1;
    NameLen := NameLen - 2;
  end;
end;

function TFileChangeWatchThread.getFilePath(FileName: string): string;
begin
  Result :=  MyFilePath.getPath( FullPath ) + FileName;
end;


procedure TFileChangeWatchThread.SetFileChangeData(
  _FileChangeData: TFileChangeData);
begin
  FileChangeData := _FileChangeData;
end;

procedure TFileChangeWatchThread.WaitFolderExist;
var
  StartTime : TDateTime;
begin
    // 等待 1秒
  StartTime := Now;
  while not Terminated and ( SecondsBetween( Now, StartTime ) < 1 ) do
    Sleep(100);

    // 目录不存在 则再等
  if not Terminated and not DirectoryExists( FullPath ) then
    WaitFolderExist;
end;

procedure TFileChangeWatchThread.WatcherFolder;
var
  pNotify : PFileNotifyInformation;
  buffer, strDir: Array[0..1024] Of Char;
  dwListBaseLength, BytesReturned: integer;
  ShowStr : string;
  ov : TOverlapped;
  pov : POverlapped;
  numBytes, CompletionKey: DWORD;
begin
  lstrcpy( strDir, PWideChar( FullPath ) );
  hDirectory := CreateFile( strDir, GENERIC_READ or GENERIC_WRITE,
                            FILE_SHARE_READ or FILE_SHARE_WRITE or FILE_SHARE_DELETE,
                            nil, OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS or FILE_FLAG_OVERLAPPED , 0
                          );
  dwListBaseLength := sizeof( FILE_NOTIFY_INFORMATION ) + MAX_PATH;
  CompletionPort := CreateIoCompletionPort( hDirectory, 0, Handle, 0);

  New(pNotify);
  Fillchar( buffer ,SizeOf( buffer ), #0 );
  StrMove( buffer, @pNotify , sizeof( pNotify ) );
  Fillchar( pNotify.FileName , MAX_PATH, #0 );
  ReadDirectoryChangesW( hDirectory, pNotify, dwListBaseLength,
                         true, FILE_NOTIFY_CHANGE_FILE_NAME + FILE_NOTIFY_CHANGE_DIR_NAME
                         + FILE_NOTIFY_CHANGE_LAST_WRITE, @BytesReturned, @ov, nil );
  pov := @Ov;

    // 监听 文件夹 变化
  IsWatching := True;
  while not Terminated do
  begin
      // 目录已删除, 结束监听
    try
      if not GetQueuedCompletionStatus( CompletionPort, numBytes, CompletionKey, Pov, INFINITE) then
        Break;

        // 没有变化, 结束监听
      if not ReadDirectoryChangesW( hDirectory, pNotify, dwListBaseLength, true,
                              FILE_NOTIFY_CHANGE_FILE_NAME + FILE_NOTIFY_CHANGE_DIR_NAME
                              + FILE_NOTIFY_CHANGE_LAST_WRITE , @BytesReturned, @ov, nil )
      then
        Break;

        // 添加 文件变化
      AddNotify( pNotify );
    except
    end;
  end;
  IsWatching := False;
  try
    PostQueuedCompletionStatus(CompletionPort, 0, 0, nil);
  except
  end;
end;

{ TFileChangeHandleThread }

constructor TFileChangeHandleThread.Create;
begin
  inherited Create( True );
end;

destructor TFileChangeHandleThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  inherited;
end;

procedure TFileChangeHandleThread.Execute;
var
  FileChangeInfo : TFileChangeInfo;
begin
  while not Terminated do
  begin
      // 获取 下一个变化
    FileChangeInfo := FileChangeData.getFileChange;

      // 没有 下一个变化 挂起线程
    if FileChangeInfo = nil then
    begin
      Suspend;
      Continue;
    end;

      // 处理变化
    HandleChange( FileChangeInfo );

      // 释放资源
    FileChangeInfo.Free;

      // 暂停 Cpu
    Sleep(1);
  end;

  inherited;
end;

procedure TFileChangeHandleThread.SetFileChangeData(
  _FileChangeData: TFileChangeData);
begin
  FileChangeData := _FileChangeData;
end;

{ TFileChangeHandle }

constructor TFileChangeHandle.Create(_FileChangeInfo: TFileChangeInfo);
begin
  FileChangeInfo := _FileChangeInfo;

  FilePath1 := FileChangeInfo.FilePath1;
  FilePath2 := FileChangeInfo.FilePath2;
  FileChangeType := FileChangeInfo.ChangeType;
  WatchPath := FileChangeInfo.WatchPath;
end;

procedure TFileChangeHandle.Update;
begin
  if FileChangeType = FileChangeType_Add then
    FileAdd
  else
  if FileChangeType = FileChangeType_Remove then
    FileRemove
  else
  if FileChangeType = FileChangeType_Modify then
    FileModify
  else
  if FileChangeType = FileChangeType_Rename then
    FileRename;
end;

{ TOneFileChangeWatchThread }

procedure TSingleFileChangeWatchThread.AddWatchFile(
  SingleFileWatchInfo: TSingleFileWatchInfo);
begin
  WatchLock.Enter;
  SingleFileWatchHash.AddOrSetValue( SingleFileWatchInfo.FilePath, SingleFileWatchInfo );
  WatchLock.Leave;
end;

procedure TSingleFileChangeWatchThread.CheckFileChange;
var
  p : TSingleFileWatchPair;
  FilePath : string;
  NewFileSize : Int64;
  NewFileTime : TDateTime;
  FileChangeInfo : TFileChangeInfo;
begin
  WatchLock.Enter;
  for p in SingleFileWatchHash do
  begin
    FilePath := p.Value.FilePath;
    if not FileExists( FilePath ) then
      Continue;
    NewFileSize := MyFileInfo.getFileSize( FilePath );
    NewFileTime := MyFileInfo.getFileLastWriteTime( FilePath );

    if ( NewFileSize <> p.Value.FileSize ) or
       not MyDatetime.Equals( NewFileTime, p.Value.FileTime )
    then
    begin
        // 调用 变化
      FileChangeInfo := TFileChangeInfo.Create( FilePath, '' );
      FileChangeInfo.SetChangeType( FileChangeType_Modify );
      FileChangeInfo.SetWatchPath( FilePath );
      FileChangeData.addFileChange( FileChangeInfo );

        // 重置 监听值
      p.Value.FileSize := NewFileSize;
      p.Value.FileTime := NewFileTime;
    end;
  end;
  WatchLock.Leave;
end;

constructor TSingleFileChangeWatchThread.Create;
begin
  inherited Create( True );
  WatchLock := TCriticalSection.Create;
  SingleFileWatchHash := TSingleFileWatchHash.Create;
end;

destructor TSingleFileChangeWatchThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;
  SingleFileWatchHash.Free;
  WatchLock.Free;
  inherited;
end;

procedure TSingleFileChangeWatchThread.Execute;
var
  StartTime : TDateTime;
begin
  while not Terminated do
  begin
    StartTime := Now;
    while not Terminated and ( SecondsBetween( Now, StartTime ) < 1 ) do
      Sleep(100);

    if Terminated then
      Break;

      // 检测文件是否变化
    CheckFileChange;
  end;

  inherited;
end;

procedure TSingleFileChangeWatchThread.RemoveWatchFile(FilePath: string);
begin
  WatchLock.Enter;
  SingleFileWatchHash.Remove( FilePath );
  WatchLock.Leave;
end;

procedure TSingleFileChangeWatchThread.SetFileChangeData(
  _FileChangeData: TFileChangeData);
begin
  FileChangeData := _FileChangeData;
end;

{ TFileWatchInfo }

constructor TSingleFileWatchInfo.Create(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TSingleFileWatchInfo.SetFileInfo(_FileSize: Int64; _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

{ TWatchPathExistThread }

procedure TWatchPathExistThread.AddWatchPath(WatchPath: string;
  IsExist: Boolean);
begin
  PathLock.Enter;
  if IsExist then
    WatchExistPathHash.AddString( WatchPath )
  else
    WatchNotExistPathHash.AddString( WatchPath );
  PathLock.Leave;
end;

procedure TWatchPathExistThread.CheckExistWatchPath;
var
  p : TStringPart;
  ExistPath : string;
  RemoveList : TStringList;
  i : Integer;
begin
  PathLock.Enter;
  RemoveList := TStringList.Create;

    // 找出 不存在的
  for p in WatchExistPathHash do
  begin
    ExistPath := p.Value;
    if not IsExistPath( ExistPath ) then
    begin
      WatchPathNotEixst( ExistPath );
      RemoveList.Add( ExistPath );
    end;
  end;

    // 处理删除
  for i := 0 to RemoveList.Count - 1 do
  begin
    ExistPath := RemoveList[i];
    WatchExistPathHash.Remove( ExistPath );
    WatchNotExistPathHash.AddString( ExistPath );
  end;

  RemoveList.Free;
  PathLock.Leave;
end;

procedure TWatchPathExistThread.CheckNotExistWatchPath;
var
  p : TStringPart;
  NotExistPath : string;
  RemoveList : TStringList;
  i : Integer;
begin
  PathLock.Enter;
  RemoveList := TStringList.Create;

    // 找出 存在的
  for p in WatchNotExistPathHash do
  begin
    NotExistPath := p.Value;
    if IsExistPath( NotExistPath ) then
    begin
      WatchPathExist( NotExistPath );
      RemoveList.Add( NotExistPath );
    end;
  end;

    // 处理删除
  for i := 0 to RemoveList.Count - 1 do
  begin
    NotExistPath := RemoveList[i];
    WatchNotExistPathHash.Remove( NotExistPath );
    WatchExistPathHash.AddString( NotExistPath );
  end;

  RemoveList.Free;
  PathLock.Leave;
end;

constructor TWatchPathExistThread.Create;
begin
  inherited Create( True );
  PathLock := TCriticalSection.Create;
  WatchExistPathHash := TStringHash.Create;
  WatchNotExistPathHash := TStringHash.Create;
end;

destructor TWatchPathExistThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  WatchNotExistPathHash.Free;
  WatchExistPathHash.Free;
  PathLock.Free;
  inherited;
end;

procedure TWatchPathExistThread.Execute;
var
  StartTime : TDateTime;
begin
  while not Terminated do
  begin
    StartTime := Now;
    while not Terminated and ( SecondsBetween( Now, StartTime ) < 1 ) do
      Sleep(100);

    if Terminated then
      Break;

      // 检测 存在的路径
    CheckExistWatchPath;

      // 检测 不存在的路径
    CheckNotExistWatchPath;
  end;

  inherited;
end;

function TWatchPathExistThread.IsExistPath(Path: string): Boolean;
begin
  if FileExists( Path ) then
    Result := True
  else
  if MyNetworkFolderUtil.IsNetworkFolder( Path ) then
    Result := MyNetworkFolderUtil.NetworkFolderExist( Path )
  else
    Result := DirectoryExists( Path );
end;

procedure TWatchPathExistThread.RemoveWatchPath(WatchPath: string);
begin
  PathLock.Enter;
  WatchExistPathHash.Remove( WatchPath );
  WatchNotExistPathHash.Remove( WatchPath );
  PathLock.Leave;
end;

end.
