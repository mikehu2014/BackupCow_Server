unit UCloudThread;

interface

uses classes, Sockets, UBackupThread, UFolderCompare, UModelUtil, SysUtils,
     Winapi.Windows, UmyUtil, UMyTcp, math, DateUtils, Generics.Collections, syncobjs, UMyDebug,
     uDebugLock, UFileBaseInfo,udebug,
     zip;

type

{$Region ' 发送 云文件 ' }

    // 发送文件操作者
  TCloudSendFileOperator = class( TSendFileOperator )
  public
    function ReadIsNextSend: Boolean;override;
    procedure AddSpeedSpace( SendSize : Integer );override;
  end;

{$EndRegion}

{$Region ' 接收 云文件 ' }

    // 接收文件操作者
  TCloudRecieveFileOperator = class( TReceiveFileOperator )
  public
    function ReadIsNextReceive: Boolean;override;
    procedure AddSpeedSpace( SendSize : Integer );override;
  end;

{$EndRegion}

{$Region ' 压缩/解压 ' }

    // 解压文件
  TUncompressZipStreamHandle = class
  private
    ZipStream : TMemoryStream;
    SavePath : string;
  private
    TcpSocket : TCustomIpClient;
  public
    constructor Create( _ZipStream : TMemoryStream );
    procedure SetSavePath( _SavePath : string );
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure Update;
  end;

     // 压缩文件
  TCompressRestoreFileHandle = class
  private
    RestorePath, RecyclePath : string;
    ZipRootPath : string;
  private
    ZipStream : TMemoryStream;
    ZipFile : TZipFile;
  private
    IsCreated : Boolean;
    TotalSize, ZipSize : Int64;
    ZipCount : Integer;
  private
    ZipErrorList : TStringList;
  public
    constructor Create;
    procedure SetRestorePath( _RestorePath, _RecyclePath : string );
    procedure AddZipFile( FilePath : string; IsDeleted : Boolean );
    function getZipStream : TMemoryStream;
    function getErrorStr : string;
    destructor Destroy; override;
  private
    function getIsAddFile( FilePath : string ): Boolean;
    function CreateZip: Boolean;
    function AddFile( FilePath : string ): Boolean;
    procedure DestoryZip;
  end;

{$EndRegion}

    // 云文件处理
  TCloudFileHandle = class
  public
    FileReq, FilePath : string;
    IsDeleted : Boolean;
    CloudPath, OwnerPcID, BackupPath : string;
  public
    TcpSocket : TCustomIpClient;
    RefreshSpeedInfo : TSpeedReader;
  private
    CloudFilePath, CloudRecyclePath : string;
    RequestFilePath : string;
  private
    CompressRestoreFileHandle : TCompressRestoreFileHandle;
    FileEditionHash : TFileEditionHash;
  public
    constructor Create( _FileReq : string );
    procedure SetFileInfo( _FilePath : string; _IsDeleted : Boolean );
    procedure SetItemInfo( _CloudPath, _OwnerPcID, _BackupPath : string );
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure SetRefreshSpeedInfo( _RefreshSpeedInfo : TSpeedReader );
    procedure SetCompress( _CompressRestoreFileHandle : TCompressRestoreFileHandle );
    procedure SetFileEditionHash( _FileEditionHash : TFileEditionHash );
    procedure Update;
  private       // 读取文件信息
    procedure ReadFile;
    procedure ReadFolder;
    procedure ReadDeletedFileList;
  private       // 增删文件
    procedure AddFile;
    procedure AddFolder;
    procedure RemoveFile;
    procedure RemoveFolder;
  private       // 回收文件
    procedure RecycleFile;
    procedure RecycleFolder;
  private       // 下载文件
    procedure GetFile;
  private       // 压缩文件
    procedure ZipFile;
  private       // 搜索文件
    procedure SearchFolder;
  private       // 预览文件
    procedure PreviewPicture;
    procedure PreviewWord;
    procedure PreviewExcel;
    procedure PreviewZip;
    procedure PreviewExeDetail;
    procedure PreviewExeIcon;
    procedure PreviewMusic;
    procedure PreviewText;
  private       // 发送云文件操作完成
    procedure SendCloudCompleted;
  end;

    // 备份算法
  TCloudFileRequestHandle = class
  public
    TcpSocket : TCustomIpClient;
    CloudPath, OwnerPcID, BackupPath : string;
    RefreshSpeedInfo : TSpeedReader;
  public
    CompressRestoreFileHandle : TCompressRestoreFileHandle;
    FileEditionHash : TFileEditionHash;
  public
    constructor Create( _TcpSocket : TCustomIpClient );
    procedure Update;
    destructor Destroy; override;
  private
    procedure ReadBaseInfo;  // 读取请求信息
    function SendAccessResult: Boolean;  // 发送访问结果
    procedure HandleRequest;  // 处理各种请求
  private
    function getIsOtherReq( FileReq : string ): Boolean;
    procedure AddZip;
    procedure GetZipFile;
    procedure RevFileEditionList;
  private
    procedure HandleReq( FileReq: string );
    procedure HandleJsonReq;
  end;

    // 备份根
  TCloudRootRequestHandle = class
  public
    TcpSocket : TCustomIpClient;
  public
    constructor Create( _TcpSocket : TCustomIpClient );
    procedure Update;
  private
    procedure HandleBackupFile;
    function WaitNextBackup: Boolean;
  end;

    // 云文件处理线程
  TCloudFileHandleThread = class( TDebugThread )
  private
    TcpSocket : TCustomIpClient;
  private
    DesPcID : string;
    BackConnType : string;
    IsConnnected : Boolean;
  public
    constructor Create;
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure SetBackConn( _BackConnType, _DesPcID : string );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    function ConnToSendPc : Boolean; // 连接需要发送的Pc
    procedure HandleRequest; // 处理请求
  end;
  TCloudFileHandleThreadList = class( TObjectList< TCloudFileHandleThread > )end;

{$Region ' 删除目录信息 ' }

    // 删除目录信息
  TRemoveFolderInfo = class
  public
    FilePath : string;
    IsFile : Boolean;
  public
    constructor Create( _FilePath : string; _IsFile : Boolean );
  end;
  TRemoveFolderList = class( TObjectList<TRemoveFolderInfo> )end;

    // 删除处理
  TRemoveFolderHandle = class
  public
    RemoveFolderInfo : TRemoveFolderInfo;
    FilePath : string;
  public
    constructor Create( _RemoveFolderInfo : TRemoveFolderInfo );
    procedure Update;
  private
    procedure FileHandle;
    procedure FolderHandle;
  end;

    // 删除目录线程
  TRemoveFolderThread = class( TDebugThread )
  public
    DataLock : TCriticalSection;
    RemoveFolderList : TRemoveFolderList;
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  public
    procedure AddRemovePath( FolderPath : string );
    function getRemoveInfo : TRemoveFolderInfo;
    procedure HandleRemoveInfo( RemoveFolderInfo : TRemoveFolderInfo );
  end;

{$EndRegion}

    // 云文件处理
  TMyCloudFileHandler = class
  public
    IsRun : Boolean;
  public
    ThreadLock : TCriticalSection;
    CloudFileThreadList : TCloudFileHandleThreadList;
  public
    IsCreateThread : Boolean;
    RemoveFolderThread : TRemoveFolderThread;
  public
    constructor Create;
    procedure StopRun;
    function getIsRun : Boolean;
    destructor Destroy; override;
  public
    procedure AddRemovePath( FolderPath : string );
    procedure RemoveCreateThread;
  public
    procedure ReceiveConn( TcpSocket : TCustomIpClient );
    procedure ReceiveBackConnBackup( DesPcID : string );
    procedure ReceiveBackConnRestore( DesPcID : string );
    procedure RemoveThread( ThreadID : Cardinal );
  private
    function AddToConn( TcpSocket : TCustomIpClient ): Boolean;
    function AddToBackConn( BackConnType, DesPcID : string ): Boolean;
  end;

const
  ThreadCount_Cloud = 30;
  FileReqBackup_Time = 10;

const
  CloudBackConnType_Backup = 'Backup';
  CloudBackConnType_Restore = 'Restore';
  CloudBackConnType_RestoreExplorer = 'RestoreExplorer';
  CloudBackConnType_RestoreSearch = 'RestoreSearch';

var
  MyCloudFileHandler : TMyCloudFileHandler;

implementation

uses UMyCloudDataInfo, UMyCloudApiInfo, UMyNetPcInfo, UMyCloudEventInfo, UMainFormThread, UMyUrl;

{ TCloudBackupThread }

procedure TCloudFileHandleThread.HandleRequest;
var
  CloudRootRequestHandle : TCloudRootRequestHandle;
begin
  CloudRootRequestHandle := TCloudRootRequestHandle.Create( TcpSocket );
  CloudRootRequestHandle.Update;
  CloudRootRequestHandle.Free;
end;

function TCloudFileHandleThread.ConnToSendPc: Boolean;
var
  MyTcpConn : TMyTcpConn;
  DesPcIP, DesPcPort, ConnType : string;
begin
  DebugLock.Debug( 'Back Conn Pc', DesPcID );

  Result := False;

  TcpSocket := TCustomIpClient.Create( nil );

    // 提取 Pc Socket 信息
  DesPcIP := MyNetPcInfoReadUtil.ReadIp( DesPcID );
  DesPcPort := MyNetPcInfoReadUtil.ReadPort( DesPcID );

    // 连接的方式
  if BackConnType = CloudBackConnType_Backup then
    ConnType := ConnType_Backup
  else
  if BackConnType = CloudBackConnType_Restore then
    ConnType := ConnType_Restore;

    // 连接 目标 Pc
  MyTcpConn := TMyTcpConn.Create( TcpSocket );
  MyTcpConn.SetConnType( ConnType );
  MyTcpConn.SetConnSocket( DesPcIP, DesPcPort );
  Result := MyTcpConn.Conn;
  MyTcpConn.Free;

    // 连接失败
  if not Result then
  begin
    if BackConnType = CloudBackConnType_Backup then
      CloudBackConnEvent.BackupConnError( DesPcID )
    else
     if BackConnType = CloudBackConnType_Restore then
      CloudBackConnEvent.RestoreConnError( DesPcID );
  end;
end;

constructor TCloudFileHandleThread.Create;
begin
  inherited Create;
end;

destructor TCloudFileHandleThread.Destroy;
begin
  inherited;
end;

procedure TCloudFileHandleThread.Execute;
begin
  FreeOnTerminate := True;

  try
      // 处理备份扫描
    if IsConnnected or ConnToSendPc then
      HandleRequest;
  except
    on  E: Exception do
      MyWebDebug.AddItem( 'Cloud File Error', e.Message );
  end;

    // 断开连接
  TcpSocket.Free;

    // 删除处理的线程
  MyCloudFileHandler.RemoveThread( Self.ThreadID );

  Terminate;
end;

procedure TCloudFileHandleThread.SetBackConn(_BackConnType,
  _DesPcID : string);
begin
  BackConnType := _BackConnType;
  DesPcID := _DesPcID;
  IsConnnected := False;
end;

procedure TCloudFileHandleThread.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
  IsConnnected := True;
end;

{ TMyCloudBackupHandler }

procedure TMyCloudFileHandler.AddRemovePath(FolderPath: string);
begin
  if not IsRun then
    Exit;

    // 未创建线程，则先创建
  ThreadLock.Enter;
  if not IsCreateThread then
  begin
    RemoveFolderThread := TRemoveFolderThread.Create;
    IsCreateThread := True;
  end;
  RemoveFolderThread.AddRemovePath( FolderPath );
  ThreadLock.Leave;
end;

function TMyCloudFileHandler.AddToBackConn(BackConnType, DesPcID: string): Boolean;
var
  CloudThread : TCloudFileHandleThread;
begin
    // 寻找挂起的线程
  ThreadLock.Enter;
  Result := False;
  if CloudFileThreadList.Count < ThreadCount_Cloud then
  begin
    CloudThread := TCloudFileHandleThread.Create;
    CloudFileThreadList.Add( CloudThread );

    CloudThread.SetBackConn( BackConnType, DesPcID );
    CloudThread.Resume;

    Result := True;
  end;
  ThreadLock.Leave;
end;

function TMyCloudFileHandler.AddToConn(TcpSocket: TCustomIpClient): Boolean;
var
  CloudThread : TCloudFileHandleThread;
begin
    // 寻找挂起的线程
  ThreadLock.Enter;
  Result := False;
  if CloudFileThreadList.Count < ThreadCount_Cloud then
  begin
    CloudThread := TCloudFileHandleThread.Create;
    CloudFileThreadList.Add( CloudThread );

      // 发送是否繁忙
    MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_IsCloudBusy, False );

    CloudThread.SetTcpSocket( TcpSocket );
    CloudThread.Resume; // 运行线程

    Result := True;
  end;
  ThreadLock.Leave;
end;

constructor TMyCloudFileHandler.Create;
begin
  ThreadLock := TCriticalSection.Create;
  CloudFileThreadList := TCloudFileHandleThreadList.Create;
  CloudFileThreadList.OwnsObjects := False;

  IsCreateThread := False;
  IsRun := True;
end;

destructor TMyCloudFileHandler.Destroy;
begin
  CloudFileThreadList.Free;
  ThreadLock.Free;
  inherited;
end;

function TMyCloudFileHandler.getIsRun: Boolean;
begin
  Result := IsRun;
end;

procedure TMyCloudFileHandler.ReceiveBackConnBackup(DesPcID: string);
var
  IsBusy : Boolean;
begin
    // 程序结束
  if not IsRun then
    Exit;

    // 添加到线程中
  IsBusy := not AddToBackConn( CloudBackConnType_Backup, DesPcID );

    // 繁忙
  if IsBusy then
    CloudBackConnEvent.BackupConnBusy( DesPcID );
end;


procedure TMyCloudFileHandler.ReceiveBackConnRestore(DesPcID: string);
var
  IsBusy : Boolean;
begin
    // 程序结束
  if not IsRun then
    Exit;

    // 添加到线程中
  IsBusy := not AddToBackConn( CloudBackConnType_Restore, DesPcID );

    // 繁忙
  if IsBusy then
    CloudBackConnEvent.RestoreConnBusy( DesPcID );
end;

procedure TMyCloudFileHandler.ReceiveConn(TcpSocket: TCustomIpClient);
var
  IsBusy : Boolean;
begin
    // 程序结束
  if not IsRun then
  begin
    TcpSocket.Disconnect;
    TcpSocket.Free;
    Exit;
  end;

    // 寻找挂起的线程
  IsBusy := not AddToConn( TcpSocket );

    // 通知对方繁忙
  if IsBusy then
  begin
    MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_IsCloudBusy, True ); // 发送是否繁忙
    TcpSocket.Free;
  end;
end;

procedure TMyCloudFileHandler.RemoveCreateThread;
begin
  ThreadLock.Enter;
  IsCreateThread := False;
  ThreadLock.Leave;
end;

procedure TMyCloudFileHandler.RemoveThread(ThreadID: Cardinal);
var
  i: Integer;
begin
  ThreadLock.Enter;
  for i := 0 to CloudFileThreadList.Count - 1 do
    if CloudFileThreadList[i].ThreadID = ThreadID then
    begin
      CloudFileThreadList.Delete( i );
      Break;
    end;
  ThreadLock.Leave;
end;

procedure TMyCloudFileHandler.StopRun;
var
  IsExistThread : Boolean;
begin
  IsRun := False;

    // 等待所有线程结束
  while True do
  begin
    ThreadLock.Enter;
    IsExistThread := CloudFileThreadList.Count > 0;
    ThreadLock.Leave;
    if not IsExistThread then
      Break;
    Sleep( 100 );
  end;

    // 等待删除线程结束
  while IsCreateThread do
    Sleep( 100 );
end;

{ TCloudBackupHandle }

procedure TCloudFileRequestHandle.AddZip;
var
  ZipStream : TMemoryStream;
  SavePath : string;
  CloudRecieveFileOperator : TCloudRecieveFileOperator;
  NetworkReceiveStreamHandle : TNetworkReceiveStreamHandle;
  UncompressZipStreamHandle : TUncompressZipStreamHandle;
begin
  ZipStream := TMemoryStream.Create;

    // 接收压缩流
  CloudRecieveFileOperator := TCloudRecieveFileOperator.Create;
  NetworkReceiveStreamHandle := TNetworkReceiveStreamHandle.Create;
  NetworkReceiveStreamHandle.SetRevStream( ZipStream );
  NetworkReceiveStreamHandle.SetTcpSocket( TcpSocket );
  NetworkReceiveStreamHandle.SetRecieveFileOperator( CloudRecieveFileOperator );
  NetworkReceiveStreamHandle.Update;
  NetworkReceiveStreamHandle.Free;
  CloudRecieveFileOperator.Free;

    // 解压压缩流
  SavePath := MyCloudInfoReadUtil.ReadCloudFilePath( CloudPath, OwnerPcID, BackupPath );
  UncompressZipStreamHandle := TUncompressZipStreamHandle.Create( ZipStream );
  UncompressZipStreamHandle.SetSavePath( SavePath );
  UncompressZipStreamHandle.SetTcpSocket( TcpSocket );
  UncompressZipStreamHandle.Update;
  UncompressZipStreamHandle.Free;

    // 发送压缩结束
  if TcpSocket.Connected then
    MySocketUtil.SendData( TcpSocket, FileReq_New );

  ZipStream.Free;
end;

constructor TCloudFileRequestHandle.Create(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
  RefreshSpeedInfo := TSpeedReader.Create;
  CompressRestoreFileHandle := TCompressRestoreFileHandle.Create;
  FileEditionHash := TFileEditionHash.Create;
end;

destructor TCloudFileRequestHandle.Destroy;
begin
  FileEditionHash.Free;
  CompressRestoreFileHandle.Free;
  RefreshSpeedInfo.Free;
  inherited;
end;

function TCloudFileRequestHandle.getIsOtherReq(FileReq: string): Boolean;
begin
  Result := True;

    // 压缩出错文件
  if FileReq = FileReq_AddZip then
    AddZip
  else
  if FileReq = FileReq_GetZip then
    GetZipFile
  else
  if FileReq = FileReq_EditionList then
    RevFileEditionList
  else
  if FileReq = FileReq_ReadZipError then
    MySocketUtil.SendData( TcpSocket, CompressRestoreFileHandle.getErrorStr )
  else
  if FileReq = FileReq_HeartBeat then
  else
  if Pos( JsonMsgType_CloudReqType, FileReq ) > 0 then
    HandleJsonReq
  else
    Result := False;
end;

procedure TCloudFileRequestHandle.GetZipFile;
var
  ZipStream : TMemoryStream;
  CloudSendFileOperator : TCloudSendFileOperator;
  NetworkSendStreamHandle : TNetworkSendStreamHandle;
begin
  ZipStream := CompressRestoreFileHandle.getZipStream;

  CloudSendFileOperator := TCloudSendFileOperator.Create;
  NetworkSendStreamHandle := TNetworkSendStreamHandle.Create;
  NetworkSendStreamHandle.SetSendStream( ZipStream );
  NetworkSendStreamHandle.SetTcpSocket( TcpSocket );
  NetworkSendStreamHandle.SetSendFileOperator( CloudSendFileOperator );
  NetworkSendStreamHandle.Update;
  NetworkSendStreamHandle.Free;
  CloudSendFileOperator.Free;

    // 等待解压完成
  if TcpSocket.Connected then
    HeartBeatReceiver.CheckReceive( TcpSocket );

  ZipStream.Free;
end;

procedure TCloudFileRequestHandle.HandleJsonReq;
var
  FileReq, FilePath : string;
  IsDeleted : Boolean;
  CloudFileHandle : TCloudFileHandle;
begin
  try
      // 文件信息
    FileReq := MySocketUtil.RevJsonStr( TcpSocket );
    FilePath := MySocketUtil.RevJsonStr( TcpSocket );
    IsDeleted := MySocketUtil.RevJsonBool( TcpSocket );

      // 处理请求信息
    CloudFileHandle := TCloudFileHandle.Create( FileReq );
    CloudFileHandle.SetFileInfo( FilePath, IsDeleted );
    CloudFileHandle.SetItemInfo( CloudPath, OwnerPcID, BackupPath );
    CloudFileHandle.SetTcpSocket( TcpSocket );
    CloudFileHandle.SetRefreshSpeedInfo( RefreshSpeedInfo );
    CloudFileHandle.SetCompress( CompressRestoreFileHandle );
    CloudFileHandle.SetFileEditionHash( FileEditionHash );
    CloudFileHandle.Update;
    CloudFileHandle.Free;
  except
  end;
end;

procedure TCloudFileRequestHandle.HandleReq(FileReq: string);
var
  CloudFileHandle : TCloudFileHandle;
  FilePath : string;
  IsDeleted : Boolean;
begin
  try
      // 文件信息
    FilePath := MySocketUtil.RevData( TcpSocket );
    IsDeleted := MySocketUtil.RevBoolData( TcpSocket );

      // 处理请求信息
    CloudFileHandle := TCloudFileHandle.Create( FileReq );
    CloudFileHandle.SetFileInfo( FilePath, IsDeleted );
    CloudFileHandle.SetItemInfo( CloudPath, OwnerPcID, BackupPath );
    CloudFileHandle.SetTcpSocket( TcpSocket );
    CloudFileHandle.SetRefreshSpeedInfo( RefreshSpeedInfo );
    CloudFileHandle.SetCompress( CompressRestoreFileHandle );
    CloudFileHandle.SetFileEditionHash( FileEditionHash );
    CloudFileHandle.Update;
    CloudFileHandle.Free;
  except
  end;
end;

procedure TCloudFileRequestHandle.HandleRequest;
var
  FileReq, FilePath : string;
begin
    // 循环访问
  while True do
  begin
      // 已断开连接
    if not TcpSocket.Connected then
      Break;

      // 接收方结束程序
    if not MyCloudFileHandler.getIsRun then
    begin
      TcpSocket.Disconnect;
      Break;
    end;

      // 读取 请求类型
    FileReq := MySocketUtil.RevData( TcpSocket );
    if FileReq = FileReq_End then   // 结束标记
      Break;

      // 连接已断开
    if FileReq = '' then
    begin
      TcpSocket.Disconnect;
      Break;
    end;

    DebugLock.Debug( 'Handle', FileReq + '  ' + FilePath );

      // 特殊情况处理
    if getIsOtherReq( FileReq ) then
      Continue;

      // 处理请求信息
    HandleReq( FileReq );
  end;
end;

procedure TCloudFileRequestHandle.ReadBaseInfo;
var
  CloudPcPath : string;
  RootPath, RecyclePath : string;
begin
    // 访问 谁的云文件
  CloudPath := MySocketUtil.RevJsonStr( TcpSocket );
  OwnerPcID := MySocketUtil.RevJsonStr( TcpSocket );
  BackupPath := MySocketUtil.RevJsonStr( TcpSocket );

    // 创建目录
  CloudPcPath := MyFilePath.getPath( CloudPath ) + OwnerPcID;
  ForceDirectories( CloudPcPath );

    // 文件压缩器
  RootPath := MyCloudInfoReadUtil.ReadCloudFilePath( CloudPath, OwnerPcID, BackupPath );
  RecyclePath := MyCloudInfoReadUtil.ReadCloudRecyclePath( CloudPath, OwnerPcID, BackupPath );
  CompressRestoreFileHandle.SetRestorePath( RootPath, RecyclePath );
end;

procedure TCloudFileRequestHandle.RevFileEditionList;
var
  EditionStr : string;
  NewFileEdtionHash : TFileEditionHash;
  p : TFileEditionPair;
  FilePath : string;
  FileEditionInfo : TFileEditionInfo;
begin
  EditionStr := MySocketUtil.RevData( TcpSocket );
  FileEditionUtil.SetStr( EditionStr, FileEditionHash );

    // 路径切换
  NewFileEdtionHash := TFileEditionHash.Create;
  for p in FileEditionHash do
  begin
    FilePath := MyCloudInfoReadUtil.ReadCloudRecyclePath( CloudPath, OwnerPcID, p.Value.FilePath );
    FileEditionInfo := TFileEditionInfo.Create( FilePath, p.Value.EditionNum );
    NewFileEdtionHash.AddOrSetValue( FilePath, FileEditionInfo );
  end;
  FileEditionHash.Free;
  FileEditionHash := NewFileEdtionHash;
end;

function TCloudFileRequestHandle.SendAccessResult: Boolean;
var
  AccessResult : string;
begin
    // 发送访问结果
  if not MyCloudInfoReadUtil.ReadCloudPathExist( CloudPath ) or
     not MyHardDisk.getPathDriverExist( CloudPath )
  then
    AccessResult := CloudConnResult_NotExist
  else
  if not MyFilePath.getIsModify( CloudPath ) then
    AccessResult := CloudConnResult_CannotWrite
  else
    AccessResult := CloudConnResult_OK;

  MySocketUtil.SendJsonStr( TcpSocket, JsonMstType_CloudAccessResult, AccessResult );

    // 是否访问成功
  Result := AccessResult = CloudConnResult_OK;
end;

procedure TCloudFileRequestHandle.Update;
begin
  DebugLock.Debug( 'Handle Request' );

    // 获取 要处理的信息
  ReadBaseInfo;

    // 发送访问结果, 访问出现异常则结束
  if not SendAccessResult then
    Exit;

    // 处理请求结果
  HandleRequest;
end;

{ TCloudFileHandle }

procedure TCloudFileHandle.AddFile;
var
  CloudRecieveFileOperator : TCloudRecieveFileOperator;
  NetworkReceiveFileHandle : TNetworkReceiveFileHandle;
begin
  CloudRecieveFileOperator := TCloudRecieveFileOperator.Create;
  NetworkReceiveFileHandle := TNetworkReceiveFileHandle.Create;
  NetworkReceiveFileHandle.SetReceiveFilePath( RequestFilePath );
  NetworkReceiveFileHandle.SetTcpSocket( TcpSocket );
  NetworkReceiveFileHandle.SetRecieveFileOperator( CloudRecieveFileOperator );
  NetworkReceiveFileHandle.Update;
  NetworkReceiveFileHandle.Free;
  CloudRecieveFileOperator.Free;
end;

procedure TCloudFileHandle.AddFolder;
begin
  ForceDirectories( RequestFilePath );
end;

constructor TCloudFileHandle.Create(_FileReq: string);
begin
  FileReq := _FileReq;
end;

procedure TCloudFileHandle.GetFile;
var
  Position : Int64;
  IsZip : Boolean;
  CloudSendFileOperator : TCloudSendFileOperator;
  NetworkSendFileHandle : TNetworkSendFileHandle;
begin
  Position := MySocketUtil.RevJsonInt64( TcpSocket );
  IsZip := MySocketUtil.RevJsonBool( TcpSocket );

  CloudSendFileOperator := TCloudSendFileOperator.Create;
  NetworkSendFileHandle := TNetworkSendFileHandle.Create;
  NetworkSendFileHandle.SetSendFilePath( RequestFilePath );
  NetworkSendFileHandle.SetReadStreamPos( Position );
  NetworkSendFileHandle.SetIsZip( IsZip );
  NetworkSendFileHandle.SetTcpSocket( TcpSocket );
  NetworkSendFileHandle.SetSendFileOperator( CloudSendFileOperator );
  NetworkSendFileHandle.Update;
  NetworkSendFileHandle.Free;
  CloudSendFileOperator.Free;
end;

procedure TCloudFileHandle.PreviewExcel;
var
  ExcelText : string;
begin
  ExcelText := MyPreviewUtil.getExcelText( RequestFilePath );
  MySocketUtil.SendData( TcpSocket, ExcelText );
end;

procedure TCloudFileHandle.PreviewExeIcon;
var
  PreviewStream : TMemoryStream;
  IsExist : Boolean;
  CloudSendFileOperator : TCloudSendFileOperator;
  NetworkSendStreamHandle : TNetworkSendStreamHandle;
begin
    // 读取 预览流
  PreviewStream := MyPreviewUtil.getExeIconStream( RequestFilePath );
  IsExist := Assigned( PreviewStream );

    // 发送是否存在
  MySocketUtil.SendData( TcpSocket, IsExist );

    // 不存在
  if not IsExist then
    Exit;

    // 发送 预览流
  CloudSendFileOperator := TCloudSendFileOperator.Create;
  NetworkSendStreamHandle := TNetworkSendStreamHandle.Create;
  NetworkSendStreamHandle.SetSendStream( PreviewStream );
  NetworkSendStreamHandle.SetTcpSocket( TcpSocket );
  NetworkSendStreamHandle.SetSendFileOperator( CloudSendFileOperator );
  NetworkSendStreamHandle.Update;
  NetworkSendStreamHandle.Free;
  CloudSendFileOperator.Free;

  PreviewStream.Free;
end;

procedure TCloudFileHandle.PreviewExeDetail;
var
  ExeText : string;
begin
  ExeText := MyPreviewUtil.getExeText( RequestFilePath );
  MySocketUtil.SendData( TcpSocket, ExeText );
end;

procedure TCloudFileHandle.PreviewMusic;
var
  MusicText : string;
begin
  MusicText := MyPreviewUtil.getMusicText( RequestFilePath );
  MySocketUtil.SendData( TcpSocket, MusicText );
end;

procedure TCloudFileHandle.PreviewPicture;
var
  PreviewStream : TMemoryStream;
  IsExist : Boolean;
  CloudSendFileOperator : TCloudSendFileOperator;
  NetworkSendStreamHandle : TNetworkSendStreamHandle;
begin
    // 读取 预览流
  PreviewStream := MyPictureUtil.getPreviewStream( RequestFilePath );
  IsExist := Assigned( PreviewStream );

    // 发送是否存在图片
  MySocketUtil.SendData( TcpSocket, IsExist );

    // 不存在，则结束
  if not IsExist then
    Exit;

    // 发送 预览流
  CloudSendFileOperator := TCloudSendFileOperator.Create;
  NetworkSendStreamHandle := TNetworkSendStreamHandle.Create;
  NetworkSendStreamHandle.SetSendStream( PreviewStream );
  NetworkSendStreamHandle.SetTcpSocket( TcpSocket );
  NetworkSendStreamHandle.SetSendFileOperator( CloudSendFileOperator );
  NetworkSendStreamHandle.Update;
  NetworkSendStreamHandle.Free;
  CloudSendFileOperator.Free;

  PreviewStream.Free;
end;

procedure TCloudFileHandle.PreviewText;
var
  IsPreview : Boolean;
  SendStream : TMemoryStream;
  CloudSendFileOperator : TCloudSendFileOperator;
  NetworkSendStreamHandle : TNetworkSendStreamHandle;
begin
    // 是否可以文本方式预览
  IsPreview := MyPreviewUtil.getIsTextPreview( RequestFilePath );

    // 是否读取预览流
  if IsPreview then
  begin
    SendStream := MyPreviewUtil.getTextPreview( RequestFilePath );
    IsPreview := Assigned( SendStream );
  end;

    // 发送是否可以预览
  MySocketUtil.SendData( TcpSocket, IsPreview );

    // 不能预览
  if not IsPreview then
    Exit;

    // 发送 预览流
  CloudSendFileOperator := TCloudSendFileOperator.Create;
  NetworkSendStreamHandle := TNetworkSendStreamHandle.Create;
  NetworkSendStreamHandle.SetSendStream( SendStream );
  NetworkSendStreamHandle.SetTcpSocket( TcpSocket );
  NetworkSendStreamHandle.SetSendFileOperator( CloudSendFileOperator );
  NetworkSendStreamHandle.Update;
  NetworkSendStreamHandle.Free;
  CloudSendFileOperator.Free;

  SendStream.Free;
end;

procedure TCloudFileHandle.PreviewWord;
var
  DocText : string;
begin
  DocText := MyPreviewUtil.getWordText( RequestFilePath );
  MySocketUtil.SendData( TcpSocket, DocText );
  MySocketUtil.SendData( TcpSocket, Split_Word );
end;

procedure TCloudFileHandle.PreviewZip;
var
  ZipText : string;
begin
    // Dll 文件不存在， 则先下载
  if MyPreviewUtil.getIsRarFile( RequestFilePath ) and not FileExists( MyPreviewUtil.getRarDllPath ) then
    MyPreviewUtil.DownloadRarDll( MyUrl.getRarDllPath );

  ZipText := MyPreviewUtil.getCompressText( RequestFilePath );
  MySocketUtil.SendData( TcpSocket, ZipText );
end;

procedure TCloudFileHandle.ReadFile;
var
  NetworkFileAccessFindHandle : TNetworkFileAccessFindHandle;
begin
  NetworkFileAccessFindHandle := TNetworkFileAccessFindHandle.Create( RequestFilePath );
  NetworkFileAccessFindHandle.SetTcpSocket( TcpSocket );
  NetworkFileAccessFindHandle.Update;
  NetworkFileAccessFindHandle.Free;
end;

procedure TCloudFileHandle.ReadFolder;
var
  IsDeep, IsFilter : Boolean;
  NetworkFolderAccessFindHandle : TNetworkFolderAccessFindHandle;
begin
    // 接收读取信息
  IsDeep := MySocketUtil.RevJsonBool( TcpSocket );
  IsFilter := MySocketUtil.RevJsonBool( TcpSocket );

    // 读取目录请求
  NetworkFolderAccessFindHandle := TNetworkFolderAccessFindHandle.Create( RequestFilePath );
  NetworkFolderAccessFindHandle.SetTcpSocket( TcpSocket );
  NetworkFolderAccessFindHandle.SetIsDeep( IsDeep );
  NetworkFolderAccessFindHandle.SetIsFilter( IsFilter );
  NetworkFolderAccessFindHandle.SetFileEditionHash( FileEditionHash );
  NetworkFolderAccessFindHandle.Update;
  NetworkFolderAccessFindHandle.Free;
end;


procedure TCloudFileHandle.ReadDeletedFileList;
var
  NetworkFileDeletedListAccessFindHandle : TNetworkFileDeletedListAccessFindHandle;
begin
  NetworkFileDeletedListAccessFindHandle := TNetworkFileDeletedListAccessFindHandle.Create( RequestFilePath );
  NetworkFileDeletedListAccessFindHandle.SetTcpSocket( TcpSocket );
  NetworkFileDeletedListAccessFindHandle.Update;
  NetworkFileDeletedListAccessFindHandle.Free;
end;

procedure TCloudFileHandle.RecycleFile;
var
  KeepEditionCount : Integer;
  FileRecycleHandle : TFileRecycleHandle;
begin
    // 读取保留版本数
  KeepEditionCount := MySocketUtil.RevIntData( TcpSocket );

    // 文件回收
  FileRecycleHandle := TFileRecycleHandle.Create;
  FileRecycleHandle.SetPathInfo( CloudFilePath, CloudRecyclePath );
  FileRecycleHandle.SetSaveDeletedEdition( KeepEditionCount );
  FileRecycleHandle.Update;
  FileRecycleHandle.Free;

    // 发送云操作完成
  SendCloudCompleted;
end;

procedure TCloudFileHandle.RecycleFolder;
var
  KeepEditionCount : Integer;
  FolderRecycleHandle : TFolderRecycleHandle;
begin
      // 读取保留版本数
  KeepEditionCount := MySocketUtil.RevIntData( TcpSocket );

    // 回收目录
  FolderRecycleHandle := TFolderRecycleHandle.Create;
  FolderRecycleHandle.SetPathInfo( CloudFilePath, CloudRecyclePath );
  FolderRecycleHandle.SetKeepEditionCount( KeepEditionCount );
  FolderRecycleHandle.Update;
  FolderRecycleHandle.Free;

    // 发送云操作完成
  SendCloudCompleted;
end;

procedure TCloudFileHandle.RemoveFile;
begin
  SysUtils.DeleteFile( RequestFilePath );

    // 发送云操作完成
  SendCloudCompleted;
end;

procedure TCloudFileHandle.RemoveFolder;
begin
  MyCloudFileHandler.AddRemovePath( RequestFilePath );

    // 发送云操作完成
  SendCloudCompleted;
end;

procedure TCloudFileHandle.SearchFolder;
var
  SearchName : string;
  IsSearchEncrypted : Boolean;
  SearchPasswordExt : string;
  ResultFileHash : TScanFileHash;
  ResultFolderHash : TScanFolderHash;
  NetworkFolderSearchAccessHandle : TNetworkFolderSearchAccessHandle;
begin
  SearchName := MySocketUtil.RevData( TcpSocket );
  IsSearchEncrypted := MySocketUtil.RevBoolData( TcpSocket );
  SearchPasswordExt := MySocketUtil.RevData( TcpSocket );

  ResultFileHash := TScanFileHash.Create;
  ResultFolderHash := TScanFolderHash.Create;

  NetworkFolderSearchAccessHandle := TNetworkFolderSearchAccessHandle.Create;
  NetworkFolderSearchAccessHandle.SetTcpSocket( TcpSocket );
  NetworkFolderSearchAccessHandle.SetFolderPath( RequestFilePath );
  NetworkFolderSearchAccessHandle.SetSerachName( SearchName );
  NetworkFolderSearchAccessHandle.SetResultFolderPath( '' );
  NetworkFolderSearchAccessHandle.SetResultFile( ResultFileHash );
  NetworkFolderSearchAccessHandle.SetResultFolder( ResultFolderHash );
  NetworkFolderSearchAccessHandle.SetEncryptInfo( IsSearchEncrypted, SearchPasswordExt );
  NetworkFolderSearchAccessHandle.SetIsDeleted( False );
  NetworkFolderSearchAccessHandle.Update;
  NetworkFolderSearchAccessHandle.LastRefresh;
  NetworkFolderSearchAccessHandle.Free;

  ResultFileHash.Free;
  ResultFolderHash.Free;
end;

procedure TCloudFileHandle.SendCloudCompleted;
begin
    // 发送回收结束信息
  MySocketUtil.SendData( TcpSocket, FileReqBack_End );
end;

procedure TCloudFileHandle.SetCompress(
  _CompressRestoreFileHandle: TCompressRestoreFileHandle);
begin
  CompressRestoreFileHandle := _CompressRestoreFileHandle;
end;

procedure TCloudFileHandle.SetFileEditionHash(
  _FileEditionHash: TFileEditionHash);
begin
  FileEditionHash := _FileEditionHash;
end;

procedure TCloudFileHandle.SetFileInfo(_FilePath: string; _IsDeleted: Boolean);
begin
  FilePath := _FilePath;
  IsDeleted := _IsDeleted;
end;

procedure TCloudFileHandle.SetItemInfo(_CloudPath, _OwnerPcID, _BackupPath: string);
begin
  CloudPath := _CloudPath;
  OwnerPcID := _OwnerPcID;
  BackupPath := _BackupPath;
end;

procedure TCloudFileHandle.SetRefreshSpeedInfo(
  _RefreshSpeedInfo: TSpeedReader);
begin
  RefreshSpeedInfo := _RefreshSpeedInfo;
end;

procedure TCloudFileHandle.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TCloudFileHandle.Update;
begin
    // 接收访问的文件路径
  CloudFilePath := MyCloudInfoReadUtil.ReadCloudFilePath( CloudPath, OwnerPcID, FilePath );
  CloudRecyclePath := MyCloudInfoReadUtil.ReadCloudRecyclePath( CloudPath, OwnerPcID, FilePath );

    // 这个文件是否已经删除
  if not IsDeleted then
    RequestFilePath := CloudFilePath
  else
    RequestFilePath := CloudRecyclePath;

    // 处理
  if FileReq = FileReq_ReadFile then
    ReadFile
  else
  if FileReq = FileReq_ReadFolder then
    ReadFolder
  else
  if FileReq = FileReq_ReadFileDeletedList then
    ReadDeletedFileList
  else
  if FileReq = FileReq_AddFile then
    AddFile
  else
  if FileReq = FileReq_AddFolder then
    AddFolder
  else
  if FileReq = FileReq_RemoveFile then
    RemoveFile
  else
  if FileReq = FileReq_RemoveFolder then
    RemoveFolder
  else
  if FileReq = FileReq_RecycleFile then
    RecycleFile
  else
  if FileReq = FileReq_RecycleFolder then
    RecycleFolder
  else
  if FileReq = FileReq_GetFile then
    GetFile
  else
  if FileReq = FileReq_SearchFolder then
    SearchFolder
  else
  if FileReq = FileReq_ZipFile then
    ZipFile
  else
  if FileReq = FileReq_PreviewPicture then
    PreviewPicture
  else
  if FileReq = FileReq_PreviewWord then
    PreviewWord
  else
  if FileReq = FileReq_PreviewExcel then
    PreviewExcel
  else
  if FileReq = FileReq_PreviewZip then
    PreviewZip
  else
  if FileReq = FileReq_PreviewExeDetail then
    PreviewExeDetail
  else
  if FileReq = FileReq_PreviewExeIcon then
    PreviewExeIcon
  else
  if FileReq = FileReq_PreviewText then
    PreviewText
  else
  if FileReq = FileReq_PreviewMusic then
    PreviewMusic
end;

procedure TCloudFileHandle.ZipFile;
begin
  CompressRestoreFileHandle.AddZipFile( RequestFilePath, IsDeleted );
end;

{ TRemoveFolderThread }

procedure TRemoveFolderThread.AddRemovePath(
  FolderPath : string);
var
  RemoveFolderInfo : TRemoveFolderInfo;
  IsFile : Boolean;
begin
  IsFile := not DirectoryExists( FolderPath );

  DataLock.Enter;
  RemoveFolderInfo := TRemoveFolderInfo.Create( FolderPath, IsFile );
  RemoveFolderList.Add( RemoveFolderInfo );
  DataLock.Leave;

  Resume;
end;

constructor TRemoveFolderThread.Create;
begin
  inherited Create;
  DataLock := TCriticalSection.Create;
  RemoveFolderList := TRemoveFolderList.Create;
  RemoveFolderList.OwnsObjects := False;
end;

destructor TRemoveFolderThread.Destroy;
begin
  RemoveFolderList.OwnsObjects := True;
  RemoveFolderList.Free;
  DataLock.Free;
  inherited;
end;

procedure TRemoveFolderThread.Execute;
var
  RemoveFolderInfo : TRemoveFolderInfo;
begin
  FreeOnTerminate := True;

  while not Terminated and MyCloudFileHandler.IsRun do
  begin
      // 获取下一个删除信息
    RemoveFolderInfo := getRemoveInfo;
    if RemoveFolderInfo = nil then  // 已经没有下一个了
      Break;

      // 处理删除信息
    HandleRemoveInfo( RemoveFolderInfo );

      // 是否资源
    RemoveFolderInfo.Free;
  end;

    // 删除线程记录
  MyCloudFileHandler.RemoveCreateThread;

    // 结束线程
  Terminate;
end;

function TRemoveFolderThread.getRemoveInfo: TRemoveFolderInfo;
begin
  DataLock.Enter;
  if RemoveFolderList.Count > 0 then
  begin
    Result := RemoveFolderList[0];
    RemoveFolderList.Delete(0);
  end
  else
    Result := nil;
  DataLock.Leave;
end;

procedure TRemoveFolderThread.HandleRemoveInfo(
  RemoveFolderInfo: TRemoveFolderInfo);
var
  RemoveFolderHandle : TRemoveFolderHandle;
begin
  RemoveFolderHandle := TRemoveFolderHandle.Create( RemoveFolderInfo );
  RemoveFolderHandle.Update;
  RemoveFolderHandle.Free;
end;

{ TCloudRootRequestHandle }

constructor TCloudRootRequestHandle.Create(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TCloudRootRequestHandle.HandleBackupFile;
var
  CloudBackupHandle : TCloudFileRequestHandle;
begin
  CloudBackupHandle := TCloudFileRequestHandle.Create( TcpSocket );
  CloudBackupHandle.Update;
  CloudBackupHandle.Free;
end;

procedure TCloudRootRequestHandle.Update;
begin
  while True do
  begin
    HandleBackupFile;

    if not WaitNextBackup then
      Break;
  end;
end;

function TCloudRootRequestHandle.WaitNextBackup: Boolean;
var
  FileReq : string;
  StartTime : TDateTime;
  Num : Integer;
begin
  Result := False;

    // 等待下一次的连接
  Num := 0;
  while TcpSocket.Connected and MyCloudFileHandler.getIsRun do
  begin
      // 读取 请求类型，等待一秒
    FileReq := MySocketUtil.RevData( TcpSocket, 1 );

      // 心跳
    if FileReq = FileReq_HeartBeat then
    begin
      Num := 0;
      Continue;
    end;

      // 只允许开始标记
    if FileReq = FileReq_New then
    begin
      MySocketUtil.SendData( TcpSocket, FileReq_New );  // 返回开始标记
      Result := True;
      Break;
    end;

      // 结束
    if FileReq = FileReq_End then
      Break;

      // 60秒没有心跳, 结束
    if Num > 60 then
      Break;

      // 增加
    inc( Num );
  end;
end;

{ TCompressShareFileHandle }

function TCompressRestoreFileHandle.AddFile(FilePath: string): Boolean;
var
  ZipName : string;
  NewZipInfo : TZipHeader;
  fs : TFileStream;
begin
  Result := False;

  try    // 打开文件
    fs := TFileStream.Create( FilePath, fmOpenRead or fmShareDenyNone );
  except
    Exit;  // 打开失败，结束
  end;

  try   // 添加压缩文件
    ZipName := ExtractRelativePath( MyFilePath.getPath( ZipRootPath ), FilePath );
    NewZipInfo := MyZipUtil.getZipHeader( ZipName, FilePath, zcStored );
    ZipFile.Add( fs, NewZipInfo );
    fs.Free;

        // 统计压缩信息
    TotalSize := TotalSize + NewZipInfo.UncompressedSize;
    ZipSize := ZipSize + NewZipInfo.CompressedSize;
    Inc( ZipCount );
    Result := True;
  except
  end;
end;

procedure TCompressRestoreFileHandle.AddZipFile(FilePath: string;
  IsDeleted : Boolean);
begin
  if IsDeleted then
    ZipRootPath := RecyclePath
  else
    ZipRootPath := RestorePath;

    // 是否成功添加压缩文件
  if getIsAddFile( FilePath ) then
    Exit;

    // 添加失败
  ZipErrorList.Add( FilePath );
end;

constructor TCompressRestoreFileHandle.Create;
begin
  IsCreated := False;
  ZipErrorList := TStringList.Create;
end;

function TCompressRestoreFileHandle.CreateZip: Boolean;
begin
  Result := False;

    // 创建压缩文件
  try
    ZipStream := TMemoryStream.Create;
    ZipFile := TZipFile.Create;
    ZipFile.Open( ZipStream, zmWrite );
    IsCreated := True;
    TotalSize := 0;
    ZipSize := 0;
    ZipCount := 0;
    Result := True;
  except
  end;
end;

procedure TCompressRestoreFileHandle.DestoryZip;
begin
    // 关闭压缩文件
  try
    IsCreated := False;
    ZipFile.Close;
    ZipFile.Free;
  except
  end;
end;

destructor TCompressRestoreFileHandle.Destroy;
begin
  ZipErrorList.Free;
  inherited;
end;

function TCompressRestoreFileHandle.getErrorStr: string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to ZipErrorList.Count - 1 do
  begin
    if Result <> '' then
      Result := Result + ZipErrorSplit_File;
    Result := Result + ZipErrorList[i];
  end;
end;

function TCompressRestoreFileHandle.getIsAddFile(FilePath: string): Boolean;
var
  SourceFileSize : Int64;
begin
  Result := False;

    // 只压缩小于 128 KB 的文件
  SourceFileSize := MyFileInfo.getFileSize( FilePath );
  if ( SourceFileSize = 0 ) or ( SourceFileSize > 128 * Size_KB ) then
    Exit;

    // 先创建压缩文件
  if not IsCreated then
  begin
    if not CreateZip then  // 创建文件失败
      Exit;
  end;

    // 添加压缩文件失败
  if not AddFile( FilePath ) then
    Exit;

  Result := True;
end;

function TCompressRestoreFileHandle.getZipStream : TMemoryStream;
begin
  if IsCreated then
  begin
    DestoryZip;
    Result := ZipStream;
  end
  else
    Result := TMemoryStream.Create;
end;

procedure TCompressRestoreFileHandle.SetRestorePath(_RestorePath, _RecyclePath: string);
begin
  RestorePath := _RestorePath;
  RecyclePath := _RecyclePath;
end;


{ TRemoveFolderInfo }

constructor TRemoveFolderInfo.Create(_FilePath: string; _IsFile: Boolean);
begin
  FilePath := _FilePath;
  IsFile := _IsFile;
end;

{ TRemoveFolderHandle }

constructor TRemoveFolderHandle.Create(_RemoveFolderInfo: TRemoveFolderInfo);
begin
  RemoveFolderInfo := _RemoveFolderInfo;
  FilePath := RemoveFolderInfo.FilePath;
end;

procedure TRemoveFolderHandle.FileHandle;
var
  ParentPath : string;
  FileName : string;
  FileHash : TScanFileHash;
  FolderHash : TScanFolderHash;
  LocalFolderFindHandle : TLocalFolderFindHandle;
  p : TScanFilePair;
  SelectName : string;
begin
  ParentPath := ExtractFileDir( FilePath );
  FileName := ExtractFileName( FilePath );

  FileHash := TScanFileHash.Create;
  FolderHash := TScanFolderHash.Create;

  LocalFolderFindHandle := TLocalFolderFindHandle.Create;
  LocalFolderFindHandle.SetFolderPath( ParentPath );
  LocalFolderFindHandle.SetScanFile( FileHash );
  LocalFolderFindHandle.SetScanFolder( FolderHash );
  LocalFolderFindHandle.Update;
  LocalFolderFindHandle.Free;

    // 寻找需要删除的文件
  for p in FileHash do
  begin
    SelectName := p.Value.FileName;
    if not MyFilePath.getIsEquals( FileName, SelectName ) then
      Continue;
    SysUtils.DeleteFile( MyFilePath.getPath( ParentPath ) + SelectName );
  end;

  FileHash.Free;
  FolderHash.Free;
end;

procedure TRemoveFolderHandle.FolderHandle;
var
  FolderDeleteHandle : TFolderDeleteHandle;
begin
  FolderDeleteHandle := TFolderDeleteHandle.Create( FilePath );
  FolderDeleteHandle.Update;
  FolderDeleteHandle.Free;
end;

procedure TRemoveFolderHandle.Update;
begin
  if RemoveFolderInfo.IsFile then
    FileHandle
  else
    FolderHandle;
end;

{ TCloudRecieveFileOperator }

procedure TCloudRecieveFileOperator.AddSpeedSpace(SendSize: Integer);
begin
  MyRefreshSpeedHandler.AddDownload( SendSize );
end;

function TCloudRecieveFileOperator.ReadIsNextReceive: Boolean;
begin
  Result := inherited and MyCloudFileHandler.getIsRun;
end;

{ TCloudSendFileOperator }

procedure TCloudSendFileOperator.AddSpeedSpace(SendSize: Integer);
begin
  MyRefreshSpeedHandler.AddDownload( SendSize );
end;

function TCloudSendFileOperator.ReadIsNextSend: Boolean;
begin
  Result := inherited and MyCloudFileHandler.getIsRun;
end;

{ TUncompressZipStreamHanlde }

constructor TUncompressZipStreamHandle.Create(_ZipStream: TMemoryStream);
begin
  ZipStream := _ZipStream;
end;

procedure TUncompressZipStreamHandle.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

procedure TUncompressZipStreamHandle.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TUncompressZipStreamHandle.Update;
var
  HeartBeatTime : TDateTime;
  ZipFile : TZipFile;
  FileName, FilePath : string;
  FileDate : TDateTime;
  i: Integer;
begin
    // 连接已断开
  if not TcpSocket.Connected then
    Exit;

    // 解压文件
  ZipFile := TZipFile.Create;
  try
    ZipStream.Position := 0;
    ZipFile.Open( ZipStream, zmRead );
    try
      HeartBeatTime := Now;
      for i := 0 to ZipFile.FileCount - 1 do
      begin
        try
          ZipFile.Extract( i, SavePath );
          FileName := ZipFile.FileInfo[i].FileName;
          FileName := StringReplace( FileName, '/', '\', [rfReplaceAll] );
          FilePath := MyFilePath.getPath( SavePath ) + FileName;
          FileDate := FileDateToDateTime( ZipFile.FileInfo[i].ModifiedDateTime );
          MyFileSetTime.SetTime( FilePath, FileDate );
        except
        end;
        HeartBeatReceiver.CheckSend( TcpSocket, HeartBeatTime ); // 定时发送心跳
      end;
    except
    end;
    ZipFile.Close;
  except
  end;
  ZipFile.Free;
end;


end.
