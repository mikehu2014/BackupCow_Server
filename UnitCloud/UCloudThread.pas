unit UCloudThread;

interface

uses classes, Sockets, UBackupThread, UFolderCompare, UModelUtil, SysUtils,
     Winapi.Windows, UmyUtil, UMyTcp, math, DateUtils, Generics.Collections, syncobjs, UMyDebug,
     uDebugLock, UFileBaseInfo,udebug,
     zip;

type

{$Region ' ���� ���ļ� ' }

    // �����ļ�������
  TCloudSendFileOperator = class( TSendFileOperator )
  public
    function ReadIsNextSend: Boolean;override;
    procedure AddSpeedSpace( SendSize : Integer );override;
  end;

{$EndRegion}

{$Region ' ���� ���ļ� ' }

    // �����ļ�������
  TCloudRecieveFileOperator = class( TReceiveFileOperator )
  public
    function ReadIsNextReceive: Boolean;override;
    procedure AddSpeedSpace( SendSize : Integer );override;
  end;

{$EndRegion}

{$Region ' ѹ��/��ѹ ' }

    // ��ѹ�ļ�
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

     // ѹ���ļ�
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

    // ���ļ�����
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
  private       // ��ȡ�ļ���Ϣ
    procedure ReadFile;
    procedure ReadFolder;
    procedure ReadDeletedFileList;
  private       // ��ɾ�ļ�
    procedure AddFile;
    procedure AddFolder;
    procedure RemoveFile;
    procedure RemoveFolder;
  private       // �����ļ�
    procedure RecycleFile;
    procedure RecycleFolder;
  private       // �����ļ�
    procedure GetFile;
  private       // ѹ���ļ�
    procedure ZipFile;
  private       // �����ļ�
    procedure SearchFolder;
  private       // Ԥ���ļ�
    procedure PreviewPicture;
    procedure PreviewWord;
    procedure PreviewExcel;
    procedure PreviewZip;
    procedure PreviewExeDetail;
    procedure PreviewExeIcon;
    procedure PreviewMusic;
    procedure PreviewText;
  private       // �������ļ��������
    procedure SendCloudCompleted;
  end;

    // �����㷨
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
    procedure ReadBaseInfo;  // ��ȡ������Ϣ
    function SendAccessResult: Boolean;  // ���ͷ��ʽ��
    procedure HandleRequest;  // �����������
  private
    function getIsOtherReq( FileReq : string ): Boolean;
    procedure AddZip;
    procedure GetZipFile;
    procedure RevFileEditionList;
  private
    procedure HandleReq( FileReq: string );
    procedure HandleJsonReq;
  end;

    // ���ݸ�
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

    // ���ļ������߳�
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
    function ConnToSendPc : Boolean; // ������Ҫ���͵�Pc
    procedure HandleRequest; // ��������
  end;
  TCloudFileHandleThreadList = class( TObjectList< TCloudFileHandleThread > )end;

{$Region ' ɾ��Ŀ¼��Ϣ ' }

    // ɾ��Ŀ¼��Ϣ
  TRemoveFolderInfo = class
  public
    FilePath : string;
    IsFile : Boolean;
  public
    constructor Create( _FilePath : string; _IsFile : Boolean );
  end;
  TRemoveFolderList = class( TObjectList<TRemoveFolderInfo> )end;

    // ɾ������
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

    // ɾ��Ŀ¼�߳�
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

    // ���ļ�����
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

    // ��ȡ Pc Socket ��Ϣ
  DesPcIP := MyNetPcInfoReadUtil.ReadIp( DesPcID );
  DesPcPort := MyNetPcInfoReadUtil.ReadPort( DesPcID );

    // ���ӵķ�ʽ
  if BackConnType = CloudBackConnType_Backup then
    ConnType := ConnType_Backup
  else
  if BackConnType = CloudBackConnType_Restore then
    ConnType := ConnType_Restore;

    // ���� Ŀ�� Pc
  MyTcpConn := TMyTcpConn.Create( TcpSocket );
  MyTcpConn.SetConnType( ConnType );
  MyTcpConn.SetConnSocket( DesPcIP, DesPcPort );
  Result := MyTcpConn.Conn;
  MyTcpConn.Free;

    // ����ʧ��
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
      // ������ɨ��
    if IsConnnected or ConnToSendPc then
      HandleRequest;
  except
    on  E: Exception do
      MyWebDebug.AddItem( 'Cloud File Error', e.Message );
  end;

    // �Ͽ�����
  TcpSocket.Free;

    // ɾ��������߳�
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

    // δ�����̣߳����ȴ���
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
    // Ѱ�ҹ�����߳�
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
    // Ѱ�ҹ�����߳�
  ThreadLock.Enter;
  Result := False;
  if CloudFileThreadList.Count < ThreadCount_Cloud then
  begin
    CloudThread := TCloudFileHandleThread.Create;
    CloudFileThreadList.Add( CloudThread );

      // �����Ƿ�æ
    MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_IsCloudBusy, False );

    CloudThread.SetTcpSocket( TcpSocket );
    CloudThread.Resume; // �����߳�

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
    // �������
  if not IsRun then
    Exit;

    // ��ӵ��߳���
  IsBusy := not AddToBackConn( CloudBackConnType_Backup, DesPcID );

    // ��æ
  if IsBusy then
    CloudBackConnEvent.BackupConnBusy( DesPcID );
end;


procedure TMyCloudFileHandler.ReceiveBackConnRestore(DesPcID: string);
var
  IsBusy : Boolean;
begin
    // �������
  if not IsRun then
    Exit;

    // ��ӵ��߳���
  IsBusy := not AddToBackConn( CloudBackConnType_Restore, DesPcID );

    // ��æ
  if IsBusy then
    CloudBackConnEvent.RestoreConnBusy( DesPcID );
end;

procedure TMyCloudFileHandler.ReceiveConn(TcpSocket: TCustomIpClient);
var
  IsBusy : Boolean;
begin
    // �������
  if not IsRun then
  begin
    TcpSocket.Disconnect;
    TcpSocket.Free;
    Exit;
  end;

    // Ѱ�ҹ�����߳�
  IsBusy := not AddToConn( TcpSocket );

    // ֪ͨ�Է���æ
  if IsBusy then
  begin
    MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_IsCloudBusy, True ); // �����Ƿ�æ
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

    // �ȴ������߳̽���
  while True do
  begin
    ThreadLock.Enter;
    IsExistThread := CloudFileThreadList.Count > 0;
    ThreadLock.Leave;
    if not IsExistThread then
      Break;
    Sleep( 100 );
  end;

    // �ȴ�ɾ���߳̽���
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

    // ����ѹ����
  CloudRecieveFileOperator := TCloudRecieveFileOperator.Create;
  NetworkReceiveStreamHandle := TNetworkReceiveStreamHandle.Create;
  NetworkReceiveStreamHandle.SetRevStream( ZipStream );
  NetworkReceiveStreamHandle.SetTcpSocket( TcpSocket );
  NetworkReceiveStreamHandle.SetRecieveFileOperator( CloudRecieveFileOperator );
  NetworkReceiveStreamHandle.Update;
  NetworkReceiveStreamHandle.Free;
  CloudRecieveFileOperator.Free;

    // ��ѹѹ����
  SavePath := MyCloudInfoReadUtil.ReadCloudFilePath( CloudPath, OwnerPcID, BackupPath );
  UncompressZipStreamHandle := TUncompressZipStreamHandle.Create( ZipStream );
  UncompressZipStreamHandle.SetSavePath( SavePath );
  UncompressZipStreamHandle.SetTcpSocket( TcpSocket );
  UncompressZipStreamHandle.Update;
  UncompressZipStreamHandle.Free;

    // ����ѹ������
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

    // ѹ�������ļ�
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

    // �ȴ���ѹ���
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
      // �ļ���Ϣ
    FileReq := MySocketUtil.RevJsonStr( TcpSocket );
    FilePath := MySocketUtil.RevJsonStr( TcpSocket );
    IsDeleted := MySocketUtil.RevJsonBool( TcpSocket );

      // ����������Ϣ
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
      // �ļ���Ϣ
    FilePath := MySocketUtil.RevData( TcpSocket );
    IsDeleted := MySocketUtil.RevBoolData( TcpSocket );

      // ����������Ϣ
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
    // ѭ������
  while True do
  begin
      // �ѶϿ�����
    if not TcpSocket.Connected then
      Break;

      // ���շ���������
    if not MyCloudFileHandler.getIsRun then
    begin
      TcpSocket.Disconnect;
      Break;
    end;

      // ��ȡ ��������
    FileReq := MySocketUtil.RevData( TcpSocket );
    if FileReq = FileReq_End then   // �������
      Break;

      // �����ѶϿ�
    if FileReq = '' then
    begin
      TcpSocket.Disconnect;
      Break;
    end;

    DebugLock.Debug( 'Handle', FileReq + '  ' + FilePath );

      // �����������
    if getIsOtherReq( FileReq ) then
      Continue;

      // ����������Ϣ
    HandleReq( FileReq );
  end;
end;

procedure TCloudFileRequestHandle.ReadBaseInfo;
var
  CloudPcPath : string;
  RootPath, RecyclePath : string;
begin
    // ���� ˭�����ļ�
  CloudPath := MySocketUtil.RevJsonStr( TcpSocket );
  OwnerPcID := MySocketUtil.RevJsonStr( TcpSocket );
  BackupPath := MySocketUtil.RevJsonStr( TcpSocket );

    // ����Ŀ¼
  CloudPcPath := MyFilePath.getPath( CloudPath ) + OwnerPcID;
  ForceDirectories( CloudPcPath );

    // �ļ�ѹ����
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

    // ·���л�
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
    // ���ͷ��ʽ��
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

    // �Ƿ���ʳɹ�
  Result := AccessResult = CloudConnResult_OK;
end;

procedure TCloudFileRequestHandle.Update;
begin
  DebugLock.Debug( 'Handle Request' );

    // ��ȡ Ҫ�������Ϣ
  ReadBaseInfo;

    // ���ͷ��ʽ��, ���ʳ����쳣�����
  if not SendAccessResult then
    Exit;

    // ����������
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
    // ��ȡ Ԥ����
  PreviewStream := MyPreviewUtil.getExeIconStream( RequestFilePath );
  IsExist := Assigned( PreviewStream );

    // �����Ƿ����
  MySocketUtil.SendData( TcpSocket, IsExist );

    // ������
  if not IsExist then
    Exit;

    // ���� Ԥ����
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
    // ��ȡ Ԥ����
  PreviewStream := MyPictureUtil.getPreviewStream( RequestFilePath );
  IsExist := Assigned( PreviewStream );

    // �����Ƿ����ͼƬ
  MySocketUtil.SendData( TcpSocket, IsExist );

    // �����ڣ������
  if not IsExist then
    Exit;

    // ���� Ԥ����
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
    // �Ƿ�����ı���ʽԤ��
  IsPreview := MyPreviewUtil.getIsTextPreview( RequestFilePath );

    // �Ƿ��ȡԤ����
  if IsPreview then
  begin
    SendStream := MyPreviewUtil.getTextPreview( RequestFilePath );
    IsPreview := Assigned( SendStream );
  end;

    // �����Ƿ����Ԥ��
  MySocketUtil.SendData( TcpSocket, IsPreview );

    // ����Ԥ��
  if not IsPreview then
    Exit;

    // ���� Ԥ����
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
    // Dll �ļ������ڣ� ��������
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
    // ���ն�ȡ��Ϣ
  IsDeep := MySocketUtil.RevJsonBool( TcpSocket );
  IsFilter := MySocketUtil.RevJsonBool( TcpSocket );

    // ��ȡĿ¼����
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
    // ��ȡ�����汾��
  KeepEditionCount := MySocketUtil.RevIntData( TcpSocket );

    // �ļ�����
  FileRecycleHandle := TFileRecycleHandle.Create;
  FileRecycleHandle.SetPathInfo( CloudFilePath, CloudRecyclePath );
  FileRecycleHandle.SetSaveDeletedEdition( KeepEditionCount );
  FileRecycleHandle.Update;
  FileRecycleHandle.Free;

    // �����Ʋ������
  SendCloudCompleted;
end;

procedure TCloudFileHandle.RecycleFolder;
var
  KeepEditionCount : Integer;
  FolderRecycleHandle : TFolderRecycleHandle;
begin
      // ��ȡ�����汾��
  KeepEditionCount := MySocketUtil.RevIntData( TcpSocket );

    // ����Ŀ¼
  FolderRecycleHandle := TFolderRecycleHandle.Create;
  FolderRecycleHandle.SetPathInfo( CloudFilePath, CloudRecyclePath );
  FolderRecycleHandle.SetKeepEditionCount( KeepEditionCount );
  FolderRecycleHandle.Update;
  FolderRecycleHandle.Free;

    // �����Ʋ������
  SendCloudCompleted;
end;

procedure TCloudFileHandle.RemoveFile;
begin
  SysUtils.DeleteFile( RequestFilePath );

    // �����Ʋ������
  SendCloudCompleted;
end;

procedure TCloudFileHandle.RemoveFolder;
begin
  MyCloudFileHandler.AddRemovePath( RequestFilePath );

    // �����Ʋ������
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
    // ���ͻ��ս�����Ϣ
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
    // ���շ��ʵ��ļ�·��
  CloudFilePath := MyCloudInfoReadUtil.ReadCloudFilePath( CloudPath, OwnerPcID, FilePath );
  CloudRecyclePath := MyCloudInfoReadUtil.ReadCloudRecyclePath( CloudPath, OwnerPcID, FilePath );

    // ����ļ��Ƿ��Ѿ�ɾ��
  if not IsDeleted then
    RequestFilePath := CloudFilePath
  else
    RequestFilePath := CloudRecyclePath;

    // ����
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
      // ��ȡ��һ��ɾ����Ϣ
    RemoveFolderInfo := getRemoveInfo;
    if RemoveFolderInfo = nil then  // �Ѿ�û����һ����
      Break;

      // ����ɾ����Ϣ
    HandleRemoveInfo( RemoveFolderInfo );

      // �Ƿ���Դ
    RemoveFolderInfo.Free;
  end;

    // ɾ���̼߳�¼
  MyCloudFileHandler.RemoveCreateThread;

    // �����߳�
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

    // �ȴ���һ�ε�����
  Num := 0;
  while TcpSocket.Connected and MyCloudFileHandler.getIsRun do
  begin
      // ��ȡ �������ͣ��ȴ�һ��
    FileReq := MySocketUtil.RevData( TcpSocket, 1 );

      // ����
    if FileReq = FileReq_HeartBeat then
    begin
      Num := 0;
      Continue;
    end;

      // ֻ����ʼ���
    if FileReq = FileReq_New then
    begin
      MySocketUtil.SendData( TcpSocket, FileReq_New );  // ���ؿ�ʼ���
      Result := True;
      Break;
    end;

      // ����
    if FileReq = FileReq_End then
      Break;

      // 60��û������, ����
    if Num > 60 then
      Break;

      // ����
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

  try    // ���ļ�
    fs := TFileStream.Create( FilePath, fmOpenRead or fmShareDenyNone );
  except
    Exit;  // ��ʧ�ܣ�����
  end;

  try   // ���ѹ���ļ�
    ZipName := ExtractRelativePath( MyFilePath.getPath( ZipRootPath ), FilePath );
    NewZipInfo := MyZipUtil.getZipHeader( ZipName, FilePath, zcStored );
    ZipFile.Add( fs, NewZipInfo );
    fs.Free;

        // ͳ��ѹ����Ϣ
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

    // �Ƿ�ɹ����ѹ���ļ�
  if getIsAddFile( FilePath ) then
    Exit;

    // ���ʧ��
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

    // ����ѹ���ļ�
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
    // �ر�ѹ���ļ�
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

    // ֻѹ��С�� 128 KB ���ļ�
  SourceFileSize := MyFileInfo.getFileSize( FilePath );
  if ( SourceFileSize = 0 ) or ( SourceFileSize > 128 * Size_KB ) then
    Exit;

    // �ȴ���ѹ���ļ�
  if not IsCreated then
  begin
    if not CreateZip then  // �����ļ�ʧ��
      Exit;
  end;

    // ���ѹ���ļ�ʧ��
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

    // Ѱ����Ҫɾ�����ļ�
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
    // �����ѶϿ�
  if not TcpSocket.Connected then
    Exit;

    // ��ѹ�ļ�
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
        HeartBeatReceiver.CheckSend( TcpSocket, HeartBeatTime ); // ��ʱ��������
      end;
    except
    end;
    ZipFile.Close;
  except
  end;
  ZipFile.Free;
end;


end.
