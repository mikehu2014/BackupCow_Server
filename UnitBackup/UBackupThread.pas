unit UBackupThread;

interface

uses UModelUtil, Generics.Collections, Classes, SysUtils, SyncObjs, UMyUtil, DateUtils,
     Math, UMainFormFace, Windows, UFileBaseInfo, sockets, UMyTcp, UFolderCompare, UMyDebug, StrUtils,
     uDebugLock, zip, uDebug;

type

{$Region ' ���ݽṹ ' }

    // ����·����Ϣ
  TBackupPathInfo = class
  public
    SourcePath : string; // Դ·��
    DesItemID : string;  // Ŀ����Ϣ
  public
    procedure SetItemInfo( _DesItemID, _SourcePath : string );
  end;
  TLocalBackupPathInfo = class( TBackupPathInfo )end;
  TNetworkBackupPathInfo = class( TBackupPathInfo )end;
  TBackupPathList = class( TObjectList<TBackupPathInfo> )end;

    // ��־��Ϣ
  TLogPathInfo = class( TBackupPathInfo )
  public
    FilePath : string;
    FileTime : TDateTime;
  public
    procedure SetFileInfo( _FilePath : string; _FileTime : TDateTime );
  end;
  TLogPathList = class( TObjectList<TLogPathInfo> )end;

    // Ԥ����Ϣ
  TPreviewLogInfo = class( TLogPathInfo )end;
  TLocalPreviewLogInfo = class( TPreviewLogInfo )end;
  TNetworkPreviewLogInfo = class( TPreviewLogInfo )end;

    // �ָ���Ϣ
  TRestoreLogInfo = class( TLogPathInfo )end;
  TLocalRestoreLogInfo = class( TRestoreLogInfo )end;
  TNetworkRestoreLogInfo = class( TRestoreLogInfo )end;


{$EndRegion}

{$Region ' �ļ����� �������� ' }

    // ��������
  TBackupSpaceInfo = class
  public
    TypeName : string;
    FileCount : Integer;
    FileSize : Int64;
  public
    constructor Create( _TypeName : string );
    procedure AddFileCount( NewFileCount : Integer );
    procedure AddFileSize( NewFileSize : Int64 );
  end;
  TBackupSpaceList = class( TObjectList<TBackupSpaceInfo> )end;

    // ���ݷ���
  TBackupAnalyzer = class
  public
    BackupSpaceList : TBackupSpaceList;
  public
    constructor Create;
    procedure AddSpace( TypeName : string; FileSize : Int64 );
    destructor Destroy; override;
  end;

    // ��ȡ��������
  TAnalyzeReadHandle = class
  public
    SourceFileHash : TScanFileHash;
    BackupAnalyzer : TBackupAnalyzer;
  public
    constructor Create( _SourceFileHash : TScanFileHash );
    procedure SetAnalyzer( _BackupAnalyzer : TBackupAnalyzer );
    procedure Update;
  end;

    // �����������
  TAnalyzeResetHandle = class
  public
    BackupPath : string;
    BackupAnalyzer : TBackupAnalyzer;
  public
    constructor Create( _BackupAnalyzer : TBackupAnalyzer );
    procedure SetBackupPath( _BackupPath : string );
    procedure Update;
  private
    procedure ResetBackupCountInfo;
    procedure ResetBackupSizeInfo;
  end;

{$EndRegion}

{$Region ' �ļ����� ���ݽṹ ' }

  TBackupParamsData = class;

    // �Ƿ�ȡ������
  TBackupCancelReader = class
  private
    DesItemID, SourcePath : string;
  private
    ScanTime : TDateTime;
  public
    constructor Create;
    procedure SetParams( Params : TBackupParamsData );virtual;
    function getIsRun : Boolean;virtual;
  end;

      // ������Ϣ
  TBackupParamsData = class
  public    // ������Ϣ
    DesItemID, SourcePath : string;
    IsFile : Boolean;
  public   // ������Ϣ
    IsEncrypted : Boolean;
    Password, ExtPassword : string;
  public   // ɾ����Ϣ
    IsSaveDeleted : Boolean;
    KeepDeletedCount : Integer;
  public   // ��������Ϣ
    IncludeFilterList : TFileFilterList;  // ����������
    ExcludeFilterList : TFileFilterList;  // �ų�������
  public   // ��Ϣ��ȡ��
    SpeedReader : TSpeedReader;
    BackupCancelReader : TBackupCancelReader;
    BackupAnalyzer : TBackupAnalyzer;
  end;

{$EndRegion}


{$Region ' �ļ����� ' }

    // ��������
  TBackupContinuesHandler = class
  public
    FilePath : string;
    FileSize, Position : Int64;
    FileTime : TDateTime;
  public
    Params : TBackupParamsData;
    DesItemID, SourcePath : string;
    IsEncrypted : Boolean;
    Password, ExtPassword : string;
    TimeReader : TSpeedReader;
  public
    procedure SetFilePath( _FilePath : string );
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
    procedure SetParams( _Params : TBackupParamsData );virtual;
    procedure Update;virtual;
  protected
    function ReadSourceIsChange : Boolean;
    function ReadDestinationPos : Boolean;virtual;abstract;
    function FileCopy: Boolean;virtual;abstract;
    procedure RemoveContinusInfo;
    procedure LogBackupCompleted;
  end;

{$EndRegion}

{$Region ' �ļ��Ƚ� ' }

    // �ļ�Ѱ��
  TBackupFolderFindHandle = class( TLocalFolderFindHandle )
  public
    IncludeFilterList : TFileFilterList;  // ����������
    ExcludeFilterList : TFileFilterList;  // �ų�������
  public
    procedure SetFilterInfo( _IncludeFilterList, _ExcludeFilterList : TFileFilterList );
  protected      // ������
    function IsFileFilter( FilePath : string; sch : TSearchRec ): Boolean;override;
    function IsFolderFilter( FolderPath : string ): Boolean;override;
  end;

    // ����ԴĿ¼ �Ƚ��㷨
  TBackupFolderCompareHandler = class( TFolderCompareHandler )
  public
    Params : TBackupParamsData;
    DesItemID, SourcePath : string;
  public
    IsEncrypted : Boolean;
    PasswordExt : string;
  public
    IncludeFilterList : TFileFilterList;  // ����������
    ExcludeFilterList : TFileFilterList;  // �ų�������
  public
    BackupCancelReader : TBackupCancelReader;
  public
    procedure SetParams( _Params : TBackupParamsData );virtual;
  protected
    procedure FindSourceFileInfo;override;
  protected
    function getDesFileName( SourceFileName : string ): string;override;
  protected
    function CheckNextScan : Boolean;override;
  end;

    // �ı���Դ�� �Ƚ��㷨
  TBackupFileCompareHandler = class( TFileCompareHandler )
  protected
    IsEncrypted : Boolean;
    PasswordExt : string;
  protected
    ParentFileHash : TScanFileHash;
    DesFilePath : string;
  public
    constructor Create;
    procedure SetParams( Params : TBackupParamsData );virtual;
    procedure Update;override;
    destructor Destroy; override;
  protected
    function FindSourceFileInfo: Boolean;override;
    function getAddFilePath : string;override;
    function getRemoveFilePath : string;override;
  private
    procedure FindParentFileHash;virtual;
    procedure RemoveOtherEncDesFile;
  end;

{$EndRegion}

{$Region ' �ļ�ѹ�� ' }

    // �����ļ������
  TBackupPackageHandler = class
  private
    DesItemID, SourcePath : string;
    IsEncrypt : Boolean;
    Password, ExtPassword : string;
  private
    ZipStream : TMemoryStream;
    ZipFile : TZipFile;
  private
    IsZipCreated : Boolean;
    ZipSize, TotalSize : Int64;
    ZipCount : Integer;
  public
    constructor Create;
    procedure SetParams( Params : TBackupParamsData );
    function AddZipFile( ScanResultInfo : TScanResultInfo ): TScanResultInfo;
    function getLastSendFile: TScanResultInfo;
    destructor Destroy; override;
  private
    function CreateZip: Boolean;
    function AddFile( FilePath : string ): Boolean;
    function ReadZipResultInfo : TScanResultAddZipInfo;
    procedure DestoryZip;
  private     // ������Ҫ ����ѹ����
    function ReadFileStream( FilePath : string ) : TStream;
  end;

{$EndRegion}

{$Region ' ������� ' }

    // ����ɨ����
  TBackupResultHandler = class
  public
    ScanResultInfo : TScanResultInfo;
    SourceFilePath : string;
  public   // ������Ϣ
    Params : TBackupParamsData;
    DesItemID, SourcePath : string;
    IsSaveDeleted, IsEncrypted : Boolean;
    KeedEditionCount : Integer;
    Password, ExtPassword : string;
  private
    SpeedReader : TSpeedReader;
  public
    procedure SetScanResultInfo( _ScanResultInfo : TScanResultInfo );
    procedure SetParams( _Params : TBackupParamsData );virtual;
    procedure Update;virtual;
  protected         // ���
    procedure SourceFileAdd;virtual;abstract;
    procedure SourceFolderAdd;virtual;abstract;
    procedure SourceFileAddZip;virtual;abstract;
  protected         // ɾ��
    procedure DesFileRemove;virtual;abstract;
    procedure DesFolderRemove;virtual;abstract;
  protected         // ����
    procedure DesFileRecycle;virtual;abstract;
    procedure DesFolderRecycle;virtual;abstract;
  protected         // д��־
    procedure LogZipStream( ZipStream : TMemoryStream; IsCompleted : Boolean );
    procedure LogZipFile( ZipName : string; IsCompleted : Boolean );
    procedure LogBackupCompleted;
    procedure LogBackupInCompleted;
  end;

      // ����ɨ����
  TFileBackupHandler = class
  protected
    Params : TBackupParamsData;
    DesItemID, SourcePath : string;
    IsFile : Boolean;
  protected
    NewBackupCount : Integer;
    NewBackupFileList : TStringList;
    BackupPackageHandler : TBackupPackageHandler;
  public
    constructor Create;
    procedure SetNewBackupFileList( _NewBackupFileList : TStringList );
    procedure SetParams( _Params : TBackupParamsData );virtual;
    procedure IniHandle;virtual;
    procedure Handle( ScanResultInfo : TScanResultInfo );virtual;
    procedure CompletedHandle;virtual;
    destructor Destroy; override;
  end;

{$EndRegion}

{$Region ' ���ݲ��� ' }

    // �������ð�����
  TBackupFreeLimitReader = class
  private
    DesItemID, SourcePath : string;
  private
    IsFreeLimit : Boolean;
    LastCompletedSpace : Int64;
  public
    constructor Create( _DesItemID, _SourcePath : string );
    procedure IniHandle;
    function AddResult( ScanResultInfo : TScanResultInfo ): Boolean;
  end;

    // ���ݵľ����������
  TBackupOperater = class
  public
    DesItemID, SourcePath : string;
    IsFile : Boolean;
  public
    procedure SetParams( Params : TBackupParamsData );virtual;
  public       // �������Բ���
    function getDesItemIsAvailable: Boolean;virtual;abstract;
    procedure SetBackupCompleted;virtual;abstract;
  public       // �ļ��Ƚ�
    function CreaterFileCompareHandler : TBackupFileCompareHandler;virtual;abstract;
    function CreaterFolderCompareHandler : TBackupFolderCompareHandler;virtual;abstract;
  public       // �ļ�����
    function CreaterContinuesHandler : TBackupContinuesHandler;virtual;abstract;  // ����
    function CreaterFileBackupHandler : TFileBackupHandler;virtual;abstract;  // ����
  end;

    // ���ݲ�������������
  TBackupProcessHandle = class
  public    // ɨ����Ϣ
    BackupParamsData : TBackupParamsData;
    DesItemID, SourcePath : string;
    IsFile : Boolean;
    BackupCancelReader : TBackupCancelReader;
  public    // ���ݲ���
    BackupOperator : TBackupOperater;
  public   // �ļ�ɨ����
    TotalCount : Integer;
    TotalSize, TotalCompleted : Int64;
  public   // �ļ��仯��Ϣ
    ScanResultList : TScanResultList;
  public   // ����������Ϣ
    NewBackupCount : Integer;
    NewBackupFileList : TStringList;
  public
    constructor Create;
    procedure SetBackupParamsData( _BackupParamsData : TBackupParamsData );
    procedure SetBackupOperator( _BackupOperator : TBackupOperater );
    procedure Update;virtual;
    destructor Destroy; override;
  protected       // ����ǰ���
    function ReadDesItemIsAvailable: Boolean; // ����Ŀ���Ƿ����
    function ReadBackupPathIsAvailable : Boolean;  // Դ·���Ƿ����
  protected       // ɨ��
    function ContinuesHandle: Boolean; // ����
    function BackupCompareHandle: Boolean;
    procedure FileCompareHandle;
    procedure FolderCompareHandle;
    procedure ResetBackupSpaceInfo;
  protected       // ����
    function CompareResultHandle: Boolean;
  protected       // �������
    function getIsBackupCompleted : Boolean;
    procedure SetLastSyncTime;
    procedure SetBackupCompleted;
  end;

{$EndRegion}


{$Region ' ���ر��� �ļ��Ƚ� ' }

    // ����Ŀ¼
  TLocalBackupFolderCompareHandler = class( TBackupFolderCompareHandler )
  protected       // Ŀ���ļ���Ϣ
    procedure FindDesFileInfo;override;
  protected        // �Ƚ���Ŀ¼
    function getScanHandle( SourceFolderName : string ) : TFolderCompareHandler;override;
  end;

    // �����ļ�
  TLocalBackupFileCompareHandler = class( TBackupFileCompareHandler )
  public
    DesItemID : string;
  public
    procedure SetParams( Params : TBackupParamsData );override;
  protected
    function FindDesFileInfo: Boolean;override;
  protected
    procedure FindParentFileHash;override;
  end;

{$EndRegion}

{$Region ' ���ر��� �ļ����� ' }

    // �����ļ� ����
  TLocalBackupContinuesHandler = class( TBackupContinuesHandler )
  public
    DesFilePath : string; // Ŀ��·��
  public
    procedure Update;override;
  protected
    function ReadDestinationPos : Boolean;override;
    function FileCopy: Boolean;override;
  end;

{$EndRegion}

{$Region ' ���ر��� ������� ' }

    // �������
  TLocalBackupResultHandle = class( TBackupResultHandler )
  private
    DesFilePath : string;
    RecycleFilePath : string;
  public
    procedure Update;override;
  protected         // ���
    procedure SourceFileAdd;override;
    procedure SourceFolderAdd;override;
    procedure SourceFileAddZip;override;
  protected         // ɾ��
    procedure DesFileRemove;override;
    procedure DesFolderRemove;override;
  protected         // ����
    procedure DesFileRecycle;override;
    procedure DesFolderRecycle;override;
  end;

    // ���ر��� �������
  TLocalFileBackupHandler = class( TFileBackupHandler )
  protected
    procedure Handle( ScanResultInfo : TScanResultInfo );override;
    procedure CompletedHandle;override;
  private
    procedure HandleNow( ScanResultInfo : TScanResultInfo );
  end;

{$EndRegion }

{$Region ' ���ر��� �ļ����� ' }

    // �ļ���ѹ
  TBackupFileUnpackOperator = class( TFileUnpackOperator )
  protected
    DesItemID, SourcePath : string;
    BackupCancelReader : TBackupCancelReader;
    SpeedReader : TSpeedReader;
  public
    procedure SetParams( Params : TBackupParamsData );
  public
    function ReadIsNextCopy : Boolean;override; // ����Ƿ������ѹ
    procedure AddSpeedSpace( SendSize : Integer );override;
    procedure RefreshCompletedSpace;override; // ˢ������ɿռ�
  end;

    // �ļ�����
  TBackupCopyFileOperator = class( TCopyFileOperator )
  protected
    DesItemID, SourcePath : string;
    BackupCancelReader : TBackupCancelReader;
    SpeedReader : TSpeedReader;
  public
    procedure SetParams( Params : TBackupParamsData );
  protected
    function ReadIsNextCopy : Boolean;override; // ����Ƿ��������
    procedure AddSpeedSpace( SendSize : Integer );override; // ����ٶ���Ϣ
    procedure RefreshCompletedSpace;override; // ˢ������ɿռ�
  protected
    procedure MarkContinusCopy;override; // ����ʱ����
    procedure DesWriteSpaceLack;override; // �ռ䲻��
    procedure ReadFileError;override;  // ���ļ�����
    procedure WriteFileError;override; // д�ļ�����
  end;

{$Endregion}

{$Region ' ���ر��� ���� ' }

      // ���ر��ݵľ����������
  TLocalBackupOperater = class( TBackupOperater )
  public       // �������Բ���
    function getDesItemIsAvailable: Boolean;override;
    procedure SetBackupCompleted;override;
  public       // �ļ��Ƚ�
    function CreaterFileCompareHandler : TBackupFileCompareHandler;override;
    function CreaterFolderCompareHandler : TBackupFolderCompareHandler;override;
  public       // �ļ�����
    function CreaterContinuesHandler : TBackupContinuesHandler;override;
    function CreaterFileBackupHandler : TFileBackupHandler;override;
  end;

{$EndRegion}


{$Region ' ���籸�� ���ݽṹ ' }

    // ���籸��ȡ���ж�
  TNetworkBackupCancelReader = class( TBackupCancelReader )
  private
    TcpSocket : TCustomIpClient;
  public
    procedure SetParams( Params : TBackupParamsData );override;
    function getIsRun : Boolean;override;
  end;

    // ���籸�ݲ���
  TNetworkBackupParamsData = class( TBackupParamsData )
  public
    TcpSocket : TCustomIpClient;
    HeartBeatTime : TDateTime;
  public
    procedure CheckHeartBeat;
  end;

{$EndRegion}

{$Region ' ���籸�� �ļ��Ƚ� ' }

    // ����Ŀ¼
  TNetworkFolderCompareHandler = class( TBackupFolderCompareHandler )
  public
    TcpSocket : TCustomIpClient;
    NetworkBackupParamsData : TNetworkBackupParamsData;
  public
    procedure SetParams( _Params : TBackupParamsData );override;
  protected       // Ŀ���ļ���Ϣ
    procedure FindDesFileInfo;override;
  protected        // �Ƚ���Ŀ¼
    function getScanHandle( SourceFolderName : string ) : TFolderCompareHandler;override;
  protected        // ��ʱ����
    function CheckNextScan : Boolean;override;
  end;

    // �����ļ�
  TNetworkFileCompareHandler = class( TBackupFileCompareHandler )
  public
    TcpSocket : TCustomIpClient;
  public
    procedure SetParams( Params : TBackupParamsData );override;
  protected
    function FindDesFileInfo: Boolean;override;
  protected
    procedure FindParentFileHash;override;
  end;

{$EndRegion}

{$Region ' ���籸�� �ļ����� ' }

      // �����ļ� ����
  TNetworkSendContinuesHandler = class( TBackupContinuesHandler )
  public
    TcpSocket : TCustomIpClient;
    DesFilePath : string;
  public
    procedure SetParams( _Params : TBackupParamsData );override;
    procedure Update;override;
  public
    function ReadDestinationPos : Boolean;override;
    function FileCopy: Boolean;override;
  end;

{$EndRegion}

{$Region ' ���籸�� ���߳� ' }

      // ���̱߳����ļ�
  TBackupFileThread = class( TDebugThread )
  private
    IsRun, IsLostConn : Boolean;
    DesItemID, SourcePath : string;
    TcpSocket : TCustomIpClient;
  private
    Params : TBackupParamsData;
  private
    ScanResultInfo : TScanResultInfo;
  public
    constructor Create;
    procedure SetParams( _Params : TBackupParamsData );
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure AddScanResultInfo( _ScanResultInfo : TScanResultInfo );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure WaitToBackup;
    procedure BackupFile;
  end;
  TBackupFileThreadList = class( TObjectList<TBackupFileThread> )end;

{$EndRegion}

{$Region ' ���籸�� ������� ' }

    // �����ļ��������
  TNetworkBackupResultHandle = class( TBackupResultHandler )
  public
    TcpSocket : TCustomIpClient;
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
  protected         // ���
    procedure SourceFileAdd;override;
    procedure SourceFolderAdd;override;
    procedure SourceFileAddZip;override;
  protected         // ɾ��
    procedure DesFileRemove;override;
    procedure DesFolderRemove;override;
  protected         // ����
    procedure DesFileRecycle;override;
    procedure DesFolderRecycle;override;
  protected         // �ȴ����ļ�����
    procedure WaitCloudCompleted;
  end;

    // ���籸�� �������
  TNetworkBackupFileHandle = class( TFileBackupHandler )
  private
    TcpSocket : TCustomIpClient;
    HeartTime : TDateTime;
  private
    BackupFileThreadList : TBackupFileThreadList;
  public
    constructor Create;
    procedure SetParams( _Params : TBackupParamsData );override;
    procedure IniHandle;override;
    procedure Handle( ScanResultInfo : TScanResultInfo );override;
    procedure CompletedHandle;override;
    destructor Destroy; override;
  private
    function getNewConnect : TCustomIpClient;
    procedure CheckHeartBeat;
  private       // �������
    procedure SendFile( ScanResultInfo : TScanResultInfo );
    procedure HandleNow( ScanResultInfo : TScanResultInfo );
  end;

{$EndRegion}

{$Region ' ���籸�� �ļ����� ' }

    // �����ļ�
  TBackupSendFileOperator = class( TSendFileOperator )
  protected
    DesItemID, SourcePath : string;
    SpeedReader : TSpeedReader;
    BackupCancelReader : TBackupCancelReader;
  public
    procedure SetParams( Params : TBackupParamsData );
  public
    function ReadIsNextSend: Boolean;override;
    function ReadIsLimitSpeed : Boolean;override;
    function ReadLimitSpeed: Int64;override;
    procedure AddSpeedSpace( SendSize : Integer );override;
    procedure RefreshCompletedSpace;override;
  public
    procedure RevFileLackSpaceHandle;override; // ȱ�ٿռ�Ĵ���
    procedure MarkContinusSend;override; // ����ʱ����
    procedure ReadFileError;override;  // ���ļ�����
    procedure WriteFileError;override; // д�ļ�����
    procedure LostConnectError;override; //�Ͽ����ӳ���
    procedure TransferFileError;override; // �����ļ�����
  end;

{$EndRegion}

{$Region ' ���籸�� ���� ' }

      // ���籸�ݵľ����������
  TNetworkBackupOperater = class( TBackupOperater )
  private
    TcpSocket : TCustomIpClient;
  public
    procedure SetParams( Params : TBackupParamsData );override;
  protected       // �������Բ���
    function getDesItemIsAvailable: Boolean;override;
    procedure SetBackupCompleted;override;
  public       // �ļ��Ƚ�
    function CreaterFileCompareHandler : TBackupFileCompareHandler;override;
    function CreaterFolderCompareHandler : TBackupFolderCompareHandler;override;
  public       // �ļ�����
    function CreaterContinuesHandler : TBackupContinuesHandler;override;
    function CreaterFileBackupHandler : TFileBackupHandler;override;
  end;

{$EndRegion}


{$Region ' ��־Ԥ�� ' }

    // ����
  TBackupLogStartHandle = class
  protected
    LogPathInfo : TLogPathInfo;
    DesItemID, SourcePath : string;
    IsEncryted : Boolean;
    Password, PasswordExt : string;
  protected
    FilePath : string;
    FileTime : TDateTime;
  protected
    IsExist, IsDeleted : Boolean;
    EditionNum : Integer;
  private
    ScanFileHash : TScanFileHash;
  public
    constructor Create;
    procedure SetLogPathInfo( _LogPathInfo : TLogPathInfo );
    procedure Update;virtual;
  protected
    procedure ReadItemInfo;
    procedure ReadLog;  // ��ȡ��Ϣ
    procedure HandleLog;virtual;abstract; // ������Ϣ
    procedure LogFileNotExist; // ��־�ļ�������
  protected
    function ReadIsNomal: Boolean;virtual;abstract;
    procedure ReadDeletedFileHash;virtual;abstract;
  private
    function ReadIsDeleted: Boolean;
  end;

    // ���ش���
  TLocalLogHandle = class( TBackupLogStartHandle )
  protected
    function ReadIsNomal: Boolean;override;
    procedure ReadDeletedFileHash;override;
  end;

    // ����Ԥ��
  TLocalPreviewLogHandle = class( TLocalLogHandle )
  protected
    procedure HandleLog;override; // ����
  end;

    // ���ػָ�
  TLocalRestoreLogHandle = class( TLocalLogHandle )
  protected
    procedure HandleLog;override; // ����
  end;

    // ���紦��
  TNetworkLogHandle = class( TBackupLogStartHandle )
  private
    TcpSocket : TCustomIpClient;
  public
    procedure Update;override;
  protected
    function ReadIsNomal: Boolean;override;
    procedure ReadDeletedFileHash;override;
  end;

    // ����Ԥ��
  TNetworkPreviewLogHandle = class( TNetworkLogHandle )
  protected
    procedure HandleLog;override; // ����
  end;

    // ����ָ�
  TNetworkRestoreLogHandle = class( TNetworkLogHandle )
  protected
    procedure HandleLog;override; // ����
  end;

{$EndRegion}


{$Region ' ������Ϣ ' }

    // �����ӵ� Socket
  TBackupFileSocketInfo = class
  public
    DesPcID : string;
    TcpSocket : TCustomIpClient;
    LastTime : TDateTime;
  public
    constructor Create( _DesPcID : string );
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
  public
    procedure CloseSocket;
  end;
  TBackupFileSocketList = class( TObjectList<TBackupFileSocketInfo> )end;

    // ��������
  TMyBackupFileConnectHandler = class
  private
    SocketLock : TCriticalSection;
    BackupFileSocketList : TBackupFileSocketList;
  private
    DesItemID, SourcePath : string;
    DesPcID, BackupConn : string;
  private
    IsConnSuccess, IsConnError, IsConnBusy : Boolean;
    BackConnSocket : TCustomIpClient;
  public       // ��ȡ��������
    constructor Create;
    function getBackupPcConn( _DesItemID, _SourcePath, _BackupConn : string ) : TCustomIpClient;
    procedure AddLastConn( LastDesItemID : string; TcpSocket : TCustomIpClient );
    procedure LastConnRefresh;
    procedure StopRun;
    destructor Destroy; override;
  public       // Զ�̽��
    procedure AddBackConn( TcpSocket : TCustomIpClient );
    procedure BackConnBusy;
    procedure BackConnError;
  private      // �ȴ�
    function getConnect : TCustomIpClient;
    function getLastConnect : TCustomIpClient;
    function getBackConnect : TCustomIpClient;
    procedure WaitBackConn;
  private       // �쳣����
    procedure CanNotConnHandle;
    procedure RemoteBusyHandle;
  end;

{$EndRegion}

{$Region ' �ļ����� ' }

    // ��ʼ����
  TBackupStartHandle = class
  public
    BackupPathInfo : TBackupPathInfo;
    DesItemID, SourcePath : string;
    IsLocalBackup : Boolean;
  private
    TimeReader : TSpeedReader;  // ��ʱ��
    BackupCancelReader : TBackupCancelReader; // ȡ����ʾ��
    BackupParamsData : TBackupParamsData;  // ���ݲ���
    BackupOperator : TBackupOperater;  // ���ݲ���
  public
    constructor Create( _BackupPathInfo : TBackupPathInfo );
    procedure Update;
  private
    function CreateBackupData: Boolean;
    procedure CreateLocalBackupData;
    function CreateNetworkBackupData: Boolean;
  private
    procedure AddToHint;
    procedure BackupHandle;
  private
    procedure DestoryBackupData;
    procedure DestoryNetworkData;
  end;

    // ԴĿ¼ ɨ��
    // Ŀ��Ŀ¼ ����/ɾ��
  TBackupHandleThread = class( TDebugThread )
  private  // �Ƿ��յ��������
    IsShowFreeeLimit : Boolean;
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  public          // ɨ��
    procedure StartBackup( BackupPathInfo : TBackupPathInfo );
    procedure StopBackup( BackupPathInfo : TBackupPathInfo );
  private        // ��Ѱ���������
    procedure ShowFreeLimit;
  end;

    // ���ر��� Դ·�� ɨ��͸���
  TMyBackupHandler = class
  public
    IsBackupRun : Boolean;  // �Ƿ��������
    IsRun : Boolean;  // �Ƿ�������
  private
    ThreadLock : TCriticalSection;
    ScanPathList : TBackupPathList;
    IsCreateThread : Boolean;
    BackupHandleThread : TBackupHandleThread;
  public
    constructor Create;
    procedure StopScan;
    destructor Destroy; override;
  public
    function getIsRun : Boolean;
    procedure ShowFreeLimit;
    procedure AddScanPathInfo( ScanPathInfo : TBackupPathInfo );
    function getScanPathInfo : TBackupPathInfo;
  end;

{$EndRegion}

{$Region ' ��־��Ϣ ' }

    // �����߳�
  TBackupLogHandleThread = class( TDebugThread )
  protected
    procedure Execute; override;
  public          // ɨ��
    procedure StartHandle( LogPathInfo : TLogPathInfo );
  end;

    // ������
  TMyBackupLogHandler = class
  public
    IsRun : Boolean;  // �Ƿ�������
  private
    ThreadLock : TCriticalSection;
    LogPathList : TLogPathList;
    IsCreateThread : Boolean;
    BackupLogHandleThread : TBackupLogHandleThread;
  public
    constructor Create;
    procedure StopScan;
    destructor Destroy; override;
  public
    function getIsRun : Boolean;
    procedure AddLogPathInfo( LogPathInfo : TLogPathInfo );
    function getLogPathInfo : TLogPathInfo;
  end;

{$EndRegion}


const
  BackupConn_Backup = 'Backup';
  BackupConn_Log = 'Log';

const
  Name_TempSendZip = 'ft_send_zip_temp.bczip';

var
  ScanSource_IsCompleted : Boolean = False;

var
    // Դ·�� ɨ���߳�
  MyBackupHandler : TMyBackupHandler;
  MyBackupLogHandler : TMyBackupLogHandler;
  MyBackupFileConnectHandler : TMyBackupFileConnectHandler;

implementation

uses UMyBackupApiInfo, UMyBackupDataInfo, UMyNetPcInfo, UMyBackupEventInfo, UMyCloudApiInfo,
     UMyRegisterDataInfo, UMyRegisterApiInfo, UNetworkControl, UMainFormThread, UMyRestoreApiInfo,
     UUserApiInfo;

{ TLocalBackupSourceScanThread }


procedure TBackupHandleThread.ShowFreeLimit;
begin
    // �����ð�, ����
  if not MyRegisterInfo.IsFreeLimit then
    Exit;

    // ����ʾ
  if not IsShowFreeeLimit then
    Exit;

    // ��ʾ����������Ϣ
  RegisterLimitApi.ShowBackupSpaceError;
end;

constructor TBackupHandleThread.Create;
begin
  inherited Create;
end;

destructor TBackupHandleThread.Destroy;
begin
  inherited;
end;

procedure TBackupHandleThread.Execute;
var
  ScanPathInfo : TBackupPathInfo;
begin
  FreeOnTerminate := True;

    // ��ʼ����
  BackupItemAppApi.BackupStart;
  MyBackupHandler.IsBackupRun := True;
  IsShowFreeeLimit := False;

    // ���ݲ���
  while MyBackupHandler.IsRun do
  begin
    ScanPathInfo := MyBackupHandler.getScanPathInfo;
    if ScanPathInfo = nil then
      Break;

    try
        // ɨ��·��
      StartBackup( ScanPathInfo );
    except
      on  E: Exception do
        MyWebDebug.AddItem( 'Backup File Error', e.Message );
    end;

      // ֹͣɨ��
    StopBackup( ScanPathInfo );
  end;

    // ����Ƿ񳬹���������
  ShowFreeLimit;

    // ��������
  if MyBackupHandler.IsBackupRun then
    BackupItemAppApi.BackupStop
  else  // ��ͣ����
    BackupItemAppApi.BackupPause;

    // ��������������߳̽���
  if not MyBackupHandler.IsRun then
    MyBackupHandler.IsCreateThread := False;

    // ����
  Terminate;
end;

procedure TBackupHandleThread.StartBackup(BackupPathInfo: TBackupPathInfo);
var
  BackupStartHandle : TBackupStartHandle;
begin
  BackupStartHandle := TBackupStartHandle.Create( BackupPathInfo );
  BackupStartHandle.Update;
  BackupStartHandle.Free;
end;

procedure TBackupHandleThread.StopBackup(BackupPathInfo: TBackupPathInfo);
begin
  BackupItemAppApi.SetStopBackup( BackupPathInfo.DesItemID, BackupPathInfo.SourcePath );
  BackupPathInfo.Free;
end;


{ TMyLocalBackupSourceScanner }

procedure TMyBackupHandler.AddScanPathInfo(
  ScanPathInfo: TBackupPathInfo);
begin
  if not IsRun then
    Exit;

  ThreadLock.Enter;

    // ��ӵ�ɨ���б���
  ScanPathList.Add( ScanPathInfo );

    // û�д����̣߳����ȴ����߳�
  if not IsCreateThread then
  begin
    IsCreateThread := True;
    BackupHandleThread := TBackupHandleThread.Create;
    BackupHandleThread.Resume;
  end;
  ThreadLock.Leave;
end;

constructor TMyBackupHandler.Create;
begin
  ThreadLock := TCriticalSection.Create;
  ScanPathList := TBackupPathList.Create;
  ScanPathList.OwnsObjects := False;
  IsCreateThread := False;

  IsBackupRun := True;
  IsRun := True;
end;

destructor TMyBackupHandler.Destroy;
begin
  ScanPathList.OwnsObjects := True;
  ScanPathList.Free;
  ThreadLock.Free;
  inherited;
end;

function TMyBackupHandler.getIsRun: Boolean;
begin
  Result := IsBackupRun and IsRun;
end;

function TMyBackupHandler.getScanPathInfo: TBackupPathInfo;
begin
  ThreadLock.Enter;
  if ScanPathList.Count > 0 then
  begin
    Result := ScanPathList[0];
    ScanPathList.Delete(0);
  end
  else
  begin
    Result := nil;
    IsCreateThread := False;
  end;
  ThreadLock.Leave;
end;

procedure TMyBackupHandler.ShowFreeLimit;
begin
  if not IsRun or not IsCreateThread then
    Exit;

  BackupHandleThread.IsShowFreeeLimit := True;
end;

procedure TMyBackupHandler.StopScan;
begin
  IsRun := False;

  while IsCreateThread do
    Sleep( 100 );
end;

{ TFolderCompareHandle }

function TBackupFolderCompareHandler.CheckNextScan: Boolean;
begin
  Result := inherited and BackupCancelReader.getIsRun;

    // 1 ���� ��ʾɨ���ļ��� һ��
  if SecondsBetween( Now, ScanTime ) >= 1 then
  begin
    BackupItemAppApi.SetScaningCount( DesItemID, SourcePath, FileCount );
    ScanTime := Now;
  end;
end;

procedure TBackupFolderCompareHandler.FindSourceFileInfo;
var
  BackupFolderFindHandle : TBackupFolderFindHandle;
  AnalyzeReadHandle : TAnalyzeReadHandle;
begin
//  DebugLock.Debug( 'Find Source File' );

    // ��ȡ�ļ���Ϣ
  BackupFolderFindHandle := TBackupFolderFindHandle.Create;
  BackupFolderFindHandle.SetFolderPath( SourceFolderPath );
  BackupFolderFindHandle.SetFilterInfo( IncludeFilterList, ExcludeFilterList );
  BackupFolderFindHandle.SetSleepCount( SleepCount );
  BackupFolderFindHandle.SetScanFile( SourceFileHash );
  BackupFolderFindHandle.SetScanFolder( SourceFolderHash );
  BackupFolderFindHandle.Update;
  SleepCount := BackupFolderFindHandle.SleepCount;
  BackupFolderFindHandle.Free;

    // ������ȡ���
  AnalyzeReadHandle := TAnalyzeReadHandle.Create( SourceFileHash );
  AnalyzeReadHandle.SetAnalyzer( Params.BackupAnalyzer );
  AnalyzeReadHandle.Update;
  AnalyzeReadHandle.Free;
end;

function TBackupFolderCompareHandler.getDesFileName(SourceFileName: string): string;
begin
  Result := SourceFileName;
  if IsEncrypted then
    Result := Result + PasswordExt;
end;

procedure TBackupFolderCompareHandler.SetParams(_Params: TBackupParamsData);
begin
  Params := _Params;

  DesItemID := Params.DesItemID;
  SourcePath := Params.SourcePath;

  IsEncrypted := Params.IsEncrypted;
  PasswordExt := Params.ExtPassword;

  IncludeFilterList := Params.IncludeFilterList;
  ExcludeFilterList := Params.ExcludeFilterList;

  BackupCancelReader := Params.BackupCancelReader;
end;

{ TFileScanHandle }

constructor TBackupFileCompareHandler.Create;
begin
  inherited;
  ParentFileHash := TScanFileHash.Create;
end;

destructor TBackupFileCompareHandler.Destroy;
begin
  ParentFileHash.Free;
  inherited;
end;

procedure TBackupFileCompareHandler.FindParentFileHash;
begin

end;

function TBackupFileCompareHandler.FindSourceFileInfo: Boolean;
var
  LocalFileFindHandle : TLocalFileFindHandle;
begin
  LocalFileFindHandle := TLocalFileFindHandle.Create;
  LocalFileFindHandle.SetFilePath( SourceFilePath );
  LocalFileFindHandle.Update;
  Result := LocalFileFindHandle.getIsExist;
  SourceFileSize := LocalFileFindHandle.getFileSize;
  SourceFileTime := LocalFileFindHandle.getFileTime;
  LocalFileFindHandle.Free;
end;


function TBackupFileCompareHandler.getAddFilePath: string;
begin
  Result := SourceFilePath;
end;

function TBackupFileCompareHandler.getRemoveFilePath: string;
begin
  Result := DesFilePath;
end;

{ TLocalFolderScanHandle }

procedure TLocalBackupFolderCompareHandler.FindDesFileInfo;
var
  DesFolderPath : string;
  LocalFolderFindHandle : TLocalFolderFindHandle;
begin
    // �Ѷ�ȡ
  if IsDesReaded then
    Exit;

    // ѭ��Ѱ�� Ŀ¼�ļ���Ϣ
  DesFolderPath := MyFilePath.getLocalBackupPath( DesItemID, SourceFolderPath );

    // Ѱ��Ŀ¼
  LocalFolderFindHandle := TLocalFolderFindHandle.Create;
  LocalFolderFindHandle.SetFolderPath( DesFolderPath );
  LocalFolderFindHandle.SetSleepCount( SleepCount );
  LocalFolderFindHandle.SetScanFile( DesFileHash );
  LocalFolderFindHandle.SetScanFolder( DesFolderHash );
  LocalFolderFindHandle.SetDeepInfo( 0, DeepCount_Max );
  LocalFolderFindHandle.Update;
  SleepCount := LocalFolderFindHandle.SleepCount;
  LocalFolderFindHandle.Free;
end;

function TLocalBackupFolderCompareHandler.getScanHandle( SourceFolderName : string ): TFolderCompareHandler;
var
  ChildFolderInfo : TScanFolderInfo;
  LocalFolderScanHandle : TLocalBackupFolderCompareHandler;
begin
  LocalFolderScanHandle := TLocalBackupFolderCompareHandler.Create;
  LocalFolderScanHandle.SetParams( Params );
  Result := LocalFolderScanHandle;

   // ��������Ŀ¼
  if not DesFolderHash.ContainsKey( SourceFolderName ) then
    Exit;

    // �����Ŀ¼��Ϣ
  ChildFolderInfo := DesFolderHash[ SourceFolderName ];
  LocalFolderScanHandle.SetIsDesReaded( ChildFolderInfo.IsReaded );

    // ��Ŀ¼δ��ȡ
  if not ChildFolderInfo.IsReaded then
    Exit;

    // ��Ŀ¼��Ϣ
  LocalFolderScanHandle.DesFolderHash.Free;
  LocalFolderScanHandle.DesFolderHash := ChildFolderInfo.ScanFolderHash;
  ChildFolderInfo.ScanFolderHash := TScanFolderHash.Create;

    // ���ļ���Ϣ
  LocalFolderScanHandle.DesFileHash.Free;
  LocalFolderScanHandle.DesFileHash := ChildFolderInfo.ScanFileHash;
  ChildFolderInfo.ScanFileHash := TScanFileHash.Create;
end;

{ TLocalFileScanHandle }

function TLocalBackupFileCompareHandler.FindDesFileInfo: Boolean;
var
  LocalDesFilePath : string;
  LocalFileFindHandle : TLocalFileFindHandle;
begin
    // ����Ŀ���ļ�
  LocalDesFilePath := MyFilePath.getLocalBackupPath( DesItemID, DesFilePath );

    // Ѱ�ұ���Ŀ���ļ���Ϣ
  LocalFileFindHandle := TLocalFileFindHandle.Create;
  LocalFileFindHandle.SetFilePath( LocalDesFilePath );
  LocalFileFindHandle.Update;
  Result := LocalFileFindHandle.getIsExist;
  DesFileSize := LocalFileFindHandle.getFileSize;
  DesFileTime := LocalFileFindHandle.getFileTime;
  LocalFileFindHandle.Free;
end;

procedure TLocalBackupFileCompareHandler.FindParentFileHash;
var
  LocalDesFilePath, LocalDesFolderPath : string;
  LocalFolderFindHandle : TLocalFolderFindHandle;
  ParentFolderHash : TScanFolderHash;
begin
    // ����Ŀ��Ŀ¼
  LocalDesFilePath := MyFilePath.getLocalBackupPath( DesItemID, DesFilePath );
  LocalDesFolderPath := ExtractFileDir( LocalDesFilePath );

  ParentFolderHash := TScanFolderHash.Create;

    // ������Ŀ¼�ļ�
  LocalFolderFindHandle := TLocalFolderFindHandle.Create;
  LocalFolderFindHandle.SetFolderPath( LocalDesFolderPath );
  LocalFolderFindHandle.SetScanFile( ParentFileHash );
  LocalFolderFindHandle.SetScanFolder( ParentFolderHash );
  LocalFolderFindHandle.Update;
  LocalFolderFindHandle.Free;

  ParentFolderHash.Free;
end;

procedure TLocalBackupFileCompareHandler.SetParams(Params: TBackupParamsData);
begin
  inherited;
  DesItemID := Params.DesItemID;
end;

procedure TBackupPathInfo.SetItemInfo(_DesItemID, _SourcePath: string);
begin
  DesItemID := _DesItemID;
  SourcePath := _SourcePath;
end;

{ TLocalBackupResultHandle }


procedure TLocalBackupResultHandle.DesFileRecycle;
var
  FileRecycleHandle : TFileRecycleHandle;
begin
    // Ŀ���ļ�����
  FileRecycleHandle := TFileRecycleHandle.Create;
  FileRecycleHandle.SetPathInfo( DesFilePath, RecycleFilePath );
  FileRecycleHandle.SetSaveDeletedEdition( KeedEditionCount );
  FileRecycleHandle.Update;
  FileRecycleHandle.Free;
end;

procedure TLocalBackupResultHandle.DesFileRemove;
begin
    // ɾ���ļ�
  SysUtils.DeleteFile( DesFilePath );
end;

procedure TLocalBackupResultHandle.DesFolderRecycle;
var
  FolderRecycleHandle : TFolderRecycleHandle;
begin
    // ����Ŀ¼
  FolderRecycleHandle := TFolderRecycleHandle.Create;
  FolderRecycleHandle.SetPathInfo( DesFilePath, RecycleFilePath );
  FolderRecycleHandle.SetKeepEditionCount( KeedEditionCount );
  FolderRecycleHandle.Update;
  FolderRecycleHandle.Free;
end;

procedure TLocalBackupResultHandle.DesFolderRemove;
begin
  MyFolderDelete.DeleteDir( DesFilePath );
end;

procedure TLocalBackupResultHandle.SourceFileAdd;
var
  BackupCopyFileOperator : TBackupCopyFileOperator;
  CopyFileHandle : TCopyFileHandle;
  IsBackupCompleted : Boolean;
begin
    // ��������Ӻ�׺
  if IsEncrypted then
    DesFilePath := DesFilePath + ExtPassword;

    // �����ļ�
  BackupCopyFileOperator := TBackupCopyFileOperator.Create;
  BackupCopyFileOperator.SetParams( Params );
  CopyFileHandle := TCopyFileHandle.Create;
  CopyFileHandle.SetPathInfo( SourceFilePath, DesFilePath );
  CopyFileHandle.SetEncryptInfo( IsEncrypted, Password );
  CopyFileHandle.SetCopyFileOperator( BackupCopyFileOperator );
  IsBackupCompleted := CopyFileHandle.Update;
  CopyFileHandle.Free;
  BackupCopyFileOperator.Free;

    // д��־
  if IsBackupCompleted then
    LogBackupCompleted
  else
    LogBackupInCompleted;
end;

procedure TLocalBackupResultHandle.SourceFileAddZip;
var
  SavePath : string;
  ScanResultAddZipInfo : TScanResultAddZipInfo;
  ZipStream : TMemoryStream;
  BackupFileUnpackOperator : TBackupFileUnpackOperator;
  FileUnpackHandle : TFileUnpackHandle;
  IsBackupCompleted : Boolean;
begin
    // ���ݵ�·��
  SavePath := MyFilePath.getLocalBackupPath( DesItemID, SourcePath );

    // ��ȡ��Ϣ
  ScanResultAddZipInfo := ScanResultInfo as TScanResultAddZipInfo;
  ZipStream := ScanResultAddZipInfo.ZipStream;

    // ��ѹ�ļ�
  BackupFileUnpackOperator := TBackupFileUnpackOperator.Create;
  BackupFileUnpackOperator.SetParams( Params );
  FileUnpackHandle := TFileUnpackHandle.Create( ZipStream );
  FileUnpackHandle.SetFileUnpackOperator( BackupFileUnpackOperator );
  FileUnpackHandle.SetSavePath( SavePath );
  IsBackupCompleted := FileUnpackHandle.Update;
  FileUnpackHandle.Free;
  BackupFileUnpackOperator.Free;

    // д log
  LogZipStream( ZipStream, IsBackupCompleted );

    // �ͷ���Դ
  ZipStream.Free;
  ScanResultAddZipInfo.Free;
end;

procedure TLocalBackupResultHandle.SourceFolderAdd;
begin
  ForceDirectories( DesFilePath );
end;

procedure TLocalBackupResultHandle.Update;
begin
    // Դ�ļ��� ���� / ����·��
  DesFilePath := MyFilePath.getLocalBackupPath( DesItemID, SourceFilePath );
  RecycleFilePath := MyFilePath.getLocalRecyclePath( DesItemID, SourceFilePath );

  inherited;
end;

{ TNetworkFolderScanHandle }

function TNetworkFolderCompareHandler.CheckNextScan: Boolean;
begin
  Result := inherited;
  if Result then  // ��ʱ����
    NetworkBackupParamsData.CheckHeartBeat;
end;

procedure TNetworkFolderCompareHandler.FindDesFileInfo;
var
  NetworkFolderFindHandle : TNetworkFolderFindHandle;
begin
    // �Ѷ�ȡ
  if IsDesReaded then
    Exit;

     // ����Ŀ¼��Ϣ
  NetworkFolderFindHandle := TNetworkFolderFindHandle.Create;
  NetworkFolderFindHandle.SetFolderPath( SourceFolderPath );
  NetworkFolderFindHandle.SetScanFile( DesFileHash );
  NetworkFolderFindHandle.SetScanFolder( DesFolderHash );
  NetworkFolderFindHandle.SetTcpSocket( TcpSocket );
  NetworkFolderFindHandle.SetIsDeep( True );
  NetworkFolderFindHandle.Update;
  NetworkFolderFindHandle.Free;
end;

function TNetworkFolderCompareHandler.getScanHandle( SourceFolderName : string ): TFolderCompareHandler;
var
  ChildFolderInfo : TScanFolderInfo;
  NetworkFolderScanHandle : TNetworkFolderCompareHandler;
begin
  NetworkFolderScanHandle := TNetworkFolderCompareHandler.Create;
  NetworkFolderScanHandle.SetParams( Params );
  Result := NetworkFolderScanHandle;

    // ��������Ŀ¼
  if not DesFolderHash.ContainsKey( SourceFolderName ) then
    Exit;

    // �����Ŀ¼��Ϣ
  ChildFolderInfo := DesFolderHash[ SourceFolderName ];
  NetworkFolderScanHandle.SetIsDesReaded( ChildFolderInfo.IsReaded );

    // ��Ŀ¼δ��ȡ
  if not ChildFolderInfo.IsReaded then
    Exit;

    // ��Ŀ¼��Ϣ
  NetworkFolderScanHandle.DesFolderHash.Free;
  NetworkFolderScanHandle.DesFolderHash := ChildFolderInfo.ScanFolderHash;
  ChildFolderInfo.ScanFolderHash := TScanFolderHash.Create;

    // ���ļ���Ϣ
  NetworkFolderScanHandle.DesFileHash.Free;
  NetworkFolderScanHandle.DesFileHash := ChildFolderInfo.ScanFileHash;
  ChildFolderInfo.ScanFileHash := TScanFileHash.Create;
end;

procedure TNetworkFolderCompareHandler.SetParams(_Params: TBackupParamsData);
begin
  inherited;

  NetworkBackupParamsData := Params as TNetworkBackupParamsData;
  TcpSocket := NetworkBackupParamsData.TcpSocket;
end;

{ TNetworkFileScanHandle }

function TNetworkFileCompareHandler.FindDesFileInfo: Boolean;
var
  NetworkFileFindHandle : TNetworkFileFindHandle;
begin
  NetworkFileFindHandle := TNetworkFileFindHandle.Create;
  NetworkFileFindHandle.SetFilePath( DesFilePath );
  NetworkFileFindHandle.SetTcpSocket( TcpSocket );
  NetworkFileFindHandle.Update;
  Result := NetworkFileFindHandle.getIsExist;
  DesFileSize := NetworkFileFindHandle.getFileSize;
  DesFileTime := NetworkFileFindHandle.getFileTime;
  NetworkFileFindHandle.Free;
end;

procedure TNetworkFileCompareHandler.FindParentFileHash;
var
  DesFolderPath : string;
  NetworkFolderFindHandle : TNetworkFolderFindHandle;
  ParentFolderHash : TScanFolderHash;
begin
    // Ŀ��Ŀ¼
  DesFolderPath := ExtractFileDir( DesFilePath );

  ParentFolderHash := TScanFolderHash.Create;

    // ������Ŀ¼�ļ�
  NetworkFolderFindHandle := TNetworkFolderFindHandle.Create;
  NetworkFolderFindHandle.SetFolderPath( DesFolderPath );
  NetworkFolderFindHandle.SetTcpSocket( TcpSocket );
  NetworkFolderFindHandle.SetScanFile( ParentFileHash );
  NetworkFolderFindHandle.SetScanFolder( ParentFolderHash );
  NetworkFolderFindHandle.Update;
  NetworkFolderFindHandle.Free;

  ParentFolderHash.Free;
end;

procedure TNetworkFileCompareHandler.SetParams(Params: TBackupParamsData);
var
  NetworkBackupParamsData : TNetworkBackupParamsData;
begin
  inherited;

  NetworkBackupParamsData := Params as TNetworkBackupParamsData;
  TcpSocket := NetworkBackupParamsData.TcpSocket;
end;

{ TLocalSourceFolderFindHandle }

function TBackupFolderFindHandle.IsFileFilter(FilePath: string;
  sch: TSearchRec): Boolean;
begin
  Result := True;

    // ���ڰ����б���
  if not FileFilterUtil.IsFileInclude( FilePath, sch, IncludeFilterList ) then
    Exit;

    // ���ų��б���
  if FileFilterUtil.IsFileExclude( FilePath, sch, ExcludeFilterList ) then
    Exit;

  Result := False;
end;

function TBackupFolderFindHandle.IsFolderFilter(
  FolderPath: string): Boolean;
begin
  Result := True;

    // ���ڰ����б���
  if not FileFilterUtil.IsFolderInclude( FolderPath, IncludeFilterList ) then
    Exit;

    // ���ų��б���
  if FileFilterUtil.IsFolderExclude( FolderPath, ExcludeFilterList ) then
    Exit;

  Result := False;
end;

procedure TBackupFolderFindHandle.SetFilterInfo(_IncludeFilterList,
  _ExcludeFilterList: TFileFilterList);
begin
  IncludeFilterList := _IncludeFilterList;
  ExcludeFilterList := _ExcludeFilterList;
end;

{ TNetworkBackupResultHandle }

procedure TNetworkBackupResultHandle.DesFileRecycle;
begin
  MySocketUtil.SendData( TcpSocket, FileReq_RecycleFile );
  MySocketUtil.SendData( TcpSocket, SourceFilePath );
  MySocketUtil.SendData( TcpSocket, False );
  MySocketUtil.SendData( TcpSocket, KeedEditionCount );

    // �ȴ�ɾ�����
  WaitCloudCompleted;
end;

procedure TNetworkBackupResultHandle.DesFileRemove;
begin
  MySocketUtil.SendData( TcpSocket, FileReq_RemoveFile );
  MySocketUtil.SendData( TcpSocket, SourceFilePath );
  MySocketUtil.SendData( TcpSocket, False );

    // �ȴ�ɾ�����
  WaitCloudCompleted;
end;

procedure TNetworkBackupResultHandle.DesFolderRecycle;
begin
  MySocketUtil.SendData( TcpSocket, FileReq_RecycleFolder );
  MySocketUtil.SendData( TcpSocket, SourceFilePath );
  MySocketUtil.SendData( TcpSocket, False );
  MySocketUtil.SendData( TcpSocket, KeedEditionCount );

    // �ȴ�ɾ�����
  WaitCloudCompleted;
end;

procedure TNetworkBackupResultHandle.DesFolderRemove;
begin
  MySocketUtil.SendData( TcpSocket, FileReq_RemoveFolder );
  MySocketUtil.SendData( TcpSocket, SourceFilePath );
  MySocketUtil.SendData( TcpSocket, False );

    // �ȴ�ɾ�����
  WaitCloudCompleted;
end;

procedure TNetworkBackupResultHandle.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TNetworkBackupResultHandle.SourceFileAdd;
var
  DesFilePath : string;
  BackupSendFileOperator : TBackupSendFileOperator;
  NetworkSendFileHandle : TNetworkSendFileHandle;
  FileTime : TDateTime;
  IsBackupCompleted : Boolean;
begin
    // ���ܵ����
  DesFilePath := SourceFilePath;
  if IsEncrypted then
    DesFilePath := DesFilePath + ExtPassword;

    // ����������Ϣ
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_CloudReqType, 'Json' );
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_FileReq, FileReq_AddFile );
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_FilePath, DesFilePath );
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_IsDeleted, False );

    // ����
  BackupSendFileOperator := TBackupSendFileOperator.Create;
  BackupSendFileOperator.SetParams( Params );
  NetworkSendFileHandle := TNetworkSendFileHandle.Create;
  NetworkSendFileHandle.SetSendFilePath( SourceFilePath );
  NetworkSendFileHandle.SetTcpSocket( TcpSocket );
  NetworkSendFileHandle.SetEncryptInfo( IsEncrypted, Password );
  NetworkSendFileHandle.SetSendFileOperator( BackupSendFileOperator );
  IsBackupCompleted := NetworkSendFileHandle.Update;
  NetworkSendFileHandle.Free;
  BackupSendFileOperator.Free;

    // ����ʧ��
  if not IsBackupCompleted then
    LogBackupInCompleted
  else
    LogBackupCompleted;
end;

procedure TNetworkBackupResultHandle.SourceFileAddZip;
var
  ScanResultAddZipInfo : TScanResultAddZipInfo;
  ZipStream : TMemoryStream;
  BackupSendFileOperator : TBackupSendFileOperator;
  NetworkSendStreamHandle : TNetworkSendStreamHandle;
  IsBackupCompleted : Boolean;
  DelZipSize : Int64;
begin
    // ��ȡ��Ϣ
  ScanResultAddZipInfo := ScanResultInfo as TScanResultAddZipInfo;
  ZipStream := ScanResultAddZipInfo.ZipStream;

    // ���͸� Ŀ��Pc ����
  MySocketUtil.SendData( TcpSocket, FileReq_AddZip );

    // ����ѹ����
  BackupSendFileOperator := TBackupSendFileOperator.Create;
  BackupSendFileOperator.SetParams( Params );
  NetworkSendStreamHandle := TNetworkSendStreamHandle.Create;
  NetworkSendStreamHandle.SetTcpSocket( TcpSocket );
  NetworkSendStreamHandle.SetSendStream( ZipStream );
  NetworkSendStreamHandle.SetSendFileOperator( BackupSendFileOperator );
  IsBackupCompleted := NetworkSendStreamHandle.Update;
  NetworkSendStreamHandle.Free;
  BackupSendFileOperator.Free;

    // �ȴ�ѹ������
  if TcpSocket.Connected then
    HeartBeatReceiver.CheckReceive( TcpSocket );

    // д log
  LogZipStream( ZipStream, IsBackupCompleted );

    // ����ʵ�ʿռ�
  if IsBackupCompleted then
  begin
    DelZipSize := ScanResultAddZipInfo.TotalSize - ZipStream.Size;
    BackupItemAppApi.AddBackupCompletedSpace( DesItemID, SourcePath, DelZipSize );
  end;

    // ɾ�� Job
  ZipStream.Free;
  ScanResultAddZipInfo.Free;
end;

procedure TNetworkBackupResultHandle.SourceFolderAdd;
begin
  MySocketUtil.SendData( TcpSocket, FileReq_AddFolder );
  MySocketUtil.SendData( TcpSocket, SourceFilePath );
  MySocketUtil.SendData( TcpSocket, False )
end;

procedure TNetworkBackupResultHandle.WaitCloudCompleted;
begin
    // �ȴ����ս���
  MySocketUtil.RevData( TcpSocket, WaitTime_RecycleFolder );
end;

{ TBackupHandle }

function TBackupProcessHandle.CompareResultHandle: Boolean;
var
  BackupFreeLimitReader : TBackupFreeLimitReader;
  FileBackupHandler : TFileBackupHandler;
  i : Integer;
begin
  Result := True;

    // �� Job
  if ScanResultList.Count = 0 then
    Exit;

  DebugLock.DebugFile( 'Backuping', SourcePath );

    // ���ÿ�ʼ����
  BackupItemAppApi.SetStartBackup( DesItemID, SourcePath );

    // ��Ѱ�����ʱʹ��
  BackupFreeLimitReader := TBackupFreeLimitReader.Create( DesItemID, SourcePath );
  BackupFreeLimitReader.IniHandle;

    // �����ļ��ȽϽ��
  FileBackupHandler := BackupOperator.CreaterFileBackupHandler;
  FileBackupHandler.SetNewBackupFileList( NewBackupFileList );
  FileBackupHandler.SetParams( BackupParamsData );
  FileBackupHandler.IniHandle;
  for i := 0 to ScanResultList.Count - 1 do
  begin
    DebugLock.DebugFile( 'Handle: ' + ScanResultList[i].ClassName, ScanResultList[i].SourceFilePath );
    if not BackupCancelReader.getIsRun then  // ȡ������
      Break;
    if not BackupFreeLimitReader.AddResult( ScanResultList[i] ) then // �յ���Ѱ�����
      Continue;
      // ������
    FileBackupHandler.Handle( ScanResultList[i] );
  end;
  if i = ScanResultList.Count then
    FileBackupHandler.CompletedHandle;
  NewBackupCount := FileBackupHandler.NewBackupCount;
  FileBackupHandler.Free;
  BackupFreeLimitReader.Free;

    // �����Ƿ�������
  Result := BackupCancelReader.getIsRun;
end;

function TBackupProcessHandle.ContinuesHandle: Boolean;
var
  BackupContinuesList : TBackupContinusList;
  i : Integer;
  ContinuesInfo : TBackupContinusInfo;
  BackupContinuesHandler : TBackupContinuesHandler;
begin
  DebugLock.DebugFile( 'Continues', SourcePath );

    // ��ȡ�����ļ��б��������ļ�
  BackupContinuesList := BackupItemInfoReadUtil.ReadContinuesList( DesItemID, SourcePath );
  if BackupContinuesList.Count > 0 then
    BackupItemAppApi.SetStartBackup( DesItemID, SourcePath );
  for i := 0 to BackupContinuesList.Count - 1 do
  begin
    if not BackupCancelReader.getIsRun then  // ȡ������
      Break;
    ContinuesInfo := BackupContinuesList[i];
    BackupContinuesHandler := BackupOperator.CreaterContinuesHandler;
    BackupContinuesHandler.SetFilePath( ContinuesInfo.FilePath );
    BackupContinuesHandler.SetFileInfo( ContinuesInfo.FileSize, ContinuesInfo.FileTime );
    BackupContinuesHandler.SetParams( BackupParamsData );
    BackupContinuesHandler.Update;
    BackupContinuesHandler.Free;
  end;
  BackupContinuesList.Free;

    // �Ƿ��������
  Result := BackupCancelReader.getIsRun;
end;

constructor TBackupProcessHandle.Create;
begin
  ScanResultList := TScanResultList.Create;
  NewBackupFileList := TStringList.Create;
end;

destructor TBackupProcessHandle.Destroy;
begin
  NewBackupFileList.Free;
  ScanResultList.Free;
  inherited;
end;

function TBackupProcessHandle.getIsBackupCompleted: Boolean;
begin
  Result := BackupItemInfoReadUtil.ReadIsCompleted( DesItemID, SourcePath );
end;

function TBackupProcessHandle.ReadBackupPathIsAvailable: Boolean;
begin
    // ����·���Ƿ�ɾ��
  Result := BackupItemInfoReadUtil.ReadIsEnable( DesItemID, SourcePath );
  if not Result then
    Exit;

    // ����·���Ƿ����
  Result := MyFilePath.getIsExist( SourcePath );
  BackupItemAppApi.SetIsExist( DesItemID, SourcePath, Result );
end;

function TBackupProcessHandle.ReadDesItemIsAvailable: Boolean;
begin
  Result := BackupOperator.getDesItemIsAvailable;
end;

procedure TBackupProcessHandle.ResetBackupSpaceInfo;
var
  Params : TBackupSetSpaceParams;
begin
    // ���� Դ·���ռ�
  Params.DesItemID := DesItemID;
  Params.BackupPath := SourcePath;
  Params.FileCount := TotalCount;
  Params.FileSpace := TotalSize;
  Params.CompletedSpce := TotalCompleted;
  BackupItemAppApi.SetSpaceInfo( Params );
end;

procedure TBackupProcessHandle.FileCompareHandle;
var
  BackupFileCompareHandler : TBackupFileCompareHandler;
begin
  BackupFileCompareHandler := BackupOperator.CreaterFileCompareHandler;
  BackupFileCompareHandler.SetSourceFilePath( SourcePath );
  BackupFileCompareHandler.SetParams( BackupParamsData );
  BackupFileCompareHandler.SetResultList( ScanResultList );
  BackupFileCompareHandler.Update;
  TotalSize := BackupFileCompareHandler.SourceFileSize;
  TotalCount := 1;
  TotalCompleted := BackupFileCompareHandler.CompletedSize;
  BackupFileCompareHandler.Free;
end;

procedure TBackupProcessHandle.FolderCompareHandle;
var
  BackupFolderScanHandle : TBackupFolderCompareHandler;
begin
  BackupFolderScanHandle := BackupOperator.CreaterFolderCompareHandler;
  BackupFolderScanHandle.SetParams( BackupParamsData );
  BackupFolderScanHandle.SetSourceFolderPath( SourcePath );
  BackupFolderScanHandle.SetIsDesEmpty( False );
  BackupFolderScanHandle.SetIsDesReaded( False );
  BackupFolderScanHandle.SetResultList( ScanResultList );
  BackupFolderScanHandle.Update;
  TotalSize := BackupFolderScanHandle.FileSize;
  TotalCount := BackupFolderScanHandle.FileCount;
  TotalCompleted := BackupFolderScanHandle.CompletedSize;
  BackupFolderScanHandle.Free;
end;

function TBackupProcessHandle.BackupCompareHandle: Boolean;
begin
  DebugLock.DebugFile( 'Scanning', SourcePath );

    // ���� ����
  BackupItemAppApi.SetAnalyzeBackup( DesItemID, SourcePath );

    // ɨ�� �ļ�/Ŀ¼
  if IsFile then
    FileCompareHandle
  else
    FolderCompareHandle;

    // �����Ƿ����
  Result := BackupCancelReader.getIsRun;
end;

procedure TBackupProcessHandle.SetLastSyncTime;
begin
  BackupItemAppApi.RefreshLastSyncTime( DesItemID, SourcePath );
end;

procedure TBackupProcessHandle.SetBackupCompleted;
var
  Params : TCompletedHintParams;
  BackupTo : string;
  AnalyzeResetHandle : TAnalyzeResetHandle;
begin
    // ���������
  BackupOperator.SetBackupCompleted;

    // ��ʾ����� Hint
  if DesItemInfoReadUtil.ReadIsLocalDes( DesItemID ) then
    BackupTo := DesItemID
  else
  begin
    BackupTo := NetworkDesItemUtil.getPcID( DesItemID );
    BackupTo := MyNetPcInfoReadUtil.ReadName( BackupTo );
  end;
  Params.DesItemID := DesItemID;
  Params.BackupPath := SourcePath;
  Params.BackupTo := BackupTo;
  Params.TotalBackup := NewBackupCount;
  Params.BackupFileList := NewBackupFileList;
  BackupHintAppApi.ShowBackupCompleted( Params );

    // �����������
  AnalyzeResetHandle := TAnalyzeResetHandle.Create( BackupParamsData.BackupAnalyzer );
  AnalyzeResetHandle.SetBackupPath( SourcePath );
  AnalyzeResetHandle.Update;
  AnalyzeResetHandle.Free;
end;

procedure TBackupProcessHandle.SetBackupOperator(
  _BackupOperator: TBackupOperater);
begin
  BackupOperator := _BackupOperator;
end;

procedure TBackupProcessHandle.SetBackupParamsData(
  _BackupParamsData: TBackupParamsData);
begin
  BackupParamsData := _BackupParamsData;
  DesItemID := BackupParamsData.DesItemID;
  SourcePath := BackupParamsData.SourcePath;
  IsFile := BackupParamsData.IsFile;
  BackupCancelReader := BackupParamsData.BackupCancelReader;
end;

procedure TBackupProcessHandle.Update;
begin
  DebugLock.DebugFile( 'Backup Start', SourcePath );

    // ������ȡ��
  if not BackupCancelReader.getIsRun then
    Exit;

    // ��� Ŀ��·��
  if not ReadDesItemIsAvailable then
    Exit;

    // ��� Դ·��
  if not ReadBackupPathIsAvailable then
    Exit;

    // ��������
  if not ContinuesHandle then
    Exit;

    // �����ļ��Ƚ�
  if not BackupCompareHandle then
    Exit;

    // ���ñ��ݿռ���Ϣ
  ResetBackupSpaceInfo;

    // �����ļ��ȽϽ��
  if not CompareResultHandle then
    Exit;

    // ��ȡ�Ƿ񱸷����
  if not getIsBackupCompleted then
    Exit;

    // �����´α�������
  SetLastSyncTime;

    // ���� �������
  SetBackupCompleted;
end;

{ TBackupResultHandle }

procedure TBackupResultHandler.LogBackupCompleted;
var
  Params : TBackupLogAddParams;
begin
  Params.DesItemID := DesItemID;
  Params.SourcePath := SourcePath;
  Params.BackupDate := Date;
  Params.FilePath := SourceFilePath;
  Params.FileTime := MyFileInfo.getFileLastWriteTime( SourceFilePath );
  Params.BackupTime := Now;
  BackupLogApi.AddCompleted( Params );
end;

procedure TBackupResultHandler.LogBackupInCompleted;
begin
  BackupLogApi.AddIncompleted( DesItemID, SourcePath, SourceFilePath );
end;

procedure TBackupResultHandler.LogZipStream(ZipStream: TMemoryStream;
  IsCompleted: Boolean);
var
  FilePathList : TStringList;
  i : Integer;
begin
    // д log
  FilePathList := MyZipUtil.getPathList( ZipStream ); // ��ȡ Stream �ļ��б�
  for i := 0 to FilePathList.Count - 1 do
    LogZipFile( FilePathList[i], IsCompleted );
  FilePathList.Free;
end;

procedure TBackupResultHandler.LogZipFile(ZipName: string;
  IsCompleted: Boolean);
var
  LogFilePath : string;
  Params : TBackupLogAddParams;
begin
    // ���ֽ���
  if IsEncrypted then
    ZipName := MyFilePath.getDecryptName( ZipName, ExtPassword );
  LogFilePath := MyFilePath.getPath( SourcePath ) + ZipName;

  Params.DesItemID := DesItemID;
  Params.SourcePath := SourcePath;
  Params.BackupDate := Date;
  Params.FilePath := LogFilePath;
  Params.FileTime := MyFileInfo.getFileLastWriteTime( LogFilePath );
  Params.BackupTime := Now;
  if IsCompleted then
    BackupLogApi.AddCompleted( Params )
  else
    BackupLogApi.AddIncompleted( DesItemID, SourcePath, LogFilePath );
end;

procedure TBackupResultHandler.SetParams(_Params: TBackupParamsData);
begin
  Params := _Params;

  DesItemID := Params.DesItemID;
  SourcePath := Params.SourcePath;

  IsEncrypted := Params.IsEncrypted;
  Password := Params.Password;
  ExtPassword := Params.ExtPassword;

  IsSaveDeleted := Params.IsSaveDeleted;
  KeedEditionCount := Params.KeepDeletedCount;

  SpeedReader := Params.SpeedReader;
end;

procedure TBackupResultHandler.SetScanResultInfo(
  _ScanResultInfo: TScanResultInfo);
begin
  ScanResultInfo := _ScanResultInfo;
  SourceFilePath := ScanResultInfo.SourceFilePath;
end;

procedure TBackupResultHandler.Update;
begin
  try
    DebugLock.Debug( ScanResultInfo.ClassName + ':  ' + ScanResultInfo.SourceFilePath );

    if ScanResultInfo is TScanResultAddFileInfo then
        SourceFileAdd
    else
    if ScanResultInfo is TScanResultAddFolderInfo then
      SourceFolderAdd
    else
    if ScanResultInfo is TScanResultAddZipInfo then
      SourceFileAddZip
    else
    if ScanResultInfo is TScanResultRemoveFileInfo then
    begin
      if IsSaveDeleted then
        DesFileRecycle
      else
        DesFileRemove
    end
    else
    if ScanResultInfo is TScanResultRemoveFolderInfo then
    begin
      if IsSaveDeleted then
        DesFolderRecycle
      else
        DesFolderRemove;
    end;
  except
  end;
end;

{ TBackupContinuesHandle }

procedure TBackupContinuesHandler.LogBackupCompleted;
var
  Params : TBackupLogAddParams;
begin
  Params.DesItemID := DesItemID;
  Params.SourcePath := SourcePath;
  Params.BackupDate := Date;
  Params.FilePath := FilePath;
  Params.FileTime := MyFileInfo.getFileLastWriteTime( FilePath );
  Params.BackupTime := Now;
  BackupLogApi.AddCompleted( Params );
end;


function TBackupContinuesHandler.ReadSourceIsChange: Boolean;
begin
  Result := True;
  if not FileExists( FilePath ) then
    Exit;
  if MyFileInfo.getFileSize( FilePath ) <> FileSize then
    Exit;
  if not MyDatetime.Equals( MyFileInfo.getFileLastWriteTime( FilePath ), FileTime ) then
    Exit;
  Result := False;
end;

procedure TBackupContinuesHandler.RemoveContinusInfo;
begin
  BackupContinusAppApi.RemoveItem( DesItemID, SourcePath, FilePath);
end;

procedure TBackupContinuesHandler.SetFileInfo(_FileSize : Int64;
_FileTime : TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TBackupContinuesHandler.SetParams(_Params: TBackupParamsData);
begin
  Params := _Params;

  DesItemID := Params.DesItemID;
  SourcePath := Params.SourcePath;

  IsEncrypted := Params.IsEncrypted;
  Password := Params.Password;
  ExtPassword := Params.ExtPassword;

  TimeReader := Params.SpeedReader;
end;

procedure TBackupContinuesHandler.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TBackupContinuesHandler.Update;
begin
    // Դ�ļ� �� Ŀ���ļ� �����仯
  if ReadSourceIsChange or not ReadDestinationPos then
  begin
    RemoveContinusInfo; // ���������¼
    Exit;
  end;

    // �ļ�����
  if FileCopy then
  begin
    RemoveContinusInfo; // ���������¼
    LogBackupCompleted; // д Log
  end;
end;

{ TLocalBackupContinuesHandle }

function TLocalBackupContinuesHandler.FileCopy: Boolean;
var
  BackupCopyFileOperator : TBackupCopyFileOperator;
  CopyFileHandle : TCopyFileHandle;
begin
    // �����ļ�
  BackupCopyFileOperator := TBackupCopyFileOperator.Create;
  BackupCopyFileOperator.SetParams( Params );
  CopyFileHandle := TCopyFileHandle.Create;
  CopyFileHandle.SetPathInfo( FilePath, DesFilePath );
  CopyFileHandle.SetPosition( Position );
  CopyFileHandle.SetEncryptInfo( IsEncrypted, Password );
  CopyFileHandle.SetCopyFileOperator( BackupCopyFileOperator );
  Result := CopyFileHandle.Update;
  CopyFileHandle.Free;
  BackupCopyFileOperator.Free;
end;

function TLocalBackupContinuesHandler.ReadDestinationPos: Boolean;
begin
  Result := FileExists( DesFilePath );
  if Result then
  begin
    Position := MyFileInfo.getFileSize( DesFilePath );
    Result := Position <= FileSize;
  end;
end;

procedure TLocalBackupContinuesHandler.Update;
begin
    // ������Ŀ��·��
  DesFilePath := MyFilePath.getLocalBackupPath( DesItemID, FilePath );
  if IsEncrypted then
    DesFilePath := DesFilePath + ExtPassword;

  inherited;
end;

{ TNetworkBackupContinuesHandle }

function TNetworkSendContinuesHandler.FileCopy: Boolean;
var
  BackupSendFileOperator : TBackupSendFileOperator;
  NetworkSendFileHandle : TNetworkSendFileHandle;
begin
    // ��ʼ�� ����
  MySocketUtil.SendData( TcpSocket, FileReq_AddFile );
  MySocketUtil.SendData( TcpSocket, DesFilePath );
  MySocketUtil.SendData( TcpSocket, False );

    // �����ļ�
  BackupSendFileOperator := TBackupSendFileOperator.Create;
  BackupSendFileOperator.SetParams( Params );
  NetworkSendFileHandle := TNetworkSendFileHandle.Create;
  NetworkSendFileHandle.SetSendFilePath( FilePath );
  NetworkSendFileHandle.SetReadStreamPos( Position );
  NetworkSendFileHandle.SetTcpSocket( TcpSocket );
  NetworkSendFileHandle.SetEncryptInfo( IsEncrypted, Password );
  NetworkSendFileHandle.SetSendFileOperator( BackupSendFileOperator );
  Result := NetworkSendFileHandle.Update;
  NetworkSendFileHandle.Free;
  BackupSendFileOperator.Free;
end;

function TNetworkSendContinuesHandler.ReadDestinationPos: Boolean;
var
  DesIsExist : Boolean;
  DesFileSize : Int64;
  NetworkFileFindHandle : TNetworkFileFindHandle;
begin
  NetworkFileFindHandle := TNetworkFileFindHandle.Create;
  NetworkFileFindHandle.SetFilePath( DesFilePath );
  NetworkFileFindHandle.SetTcpSocket( TcpSocket );
  NetworkFileFindHandle.Update;
  DesIsExist := NetworkFileFindHandle.getIsExist;
  DesFileSize := NetworkFileFindHandle.getFileSize;
  NetworkFileFindHandle.Free;

    // �����Ƿ����Ŀ���ļ�
  Result := DesIsExist;
  if Result then
  begin
    Position := DesFileSize;
    Result := Position <= FileSize;
  end;
end;

procedure TNetworkSendContinuesHandler.SetParams(_Params: TBackupParamsData);
var
  NetworkBackupParamsData : TNetworkBackupParamsData;
begin
  inherited;

  NetworkBackupParamsData := Params as TNetworkBackupParamsData;
  TcpSocket := NetworkBackupParamsData.TcpSocket;
end;

procedure TNetworkSendContinuesHandler.Update;
begin
  DesFilePath := FilePath;
  if IsEncrypted then
    DesFilePath := DesFilePath + ExtPassword;

  inherited;
end;

{ TSendFileSocketInfo }

procedure TBackupFileSocketInfo.CloseSocket;
begin
  try
    MySocketUtil.SendData( TcpSocket, FileReq_End );
    TcpSocket.Free;
    TcpSocket := nil;
  except
  end;
end;

constructor TBackupFileSocketInfo.Create(_DesPcID: string);
begin
  DesPcID := _DesPcID;
  LastTime := Now;
end;

procedure TBackupFileSocketInfo.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

{ TMyFileSendBackConnHandler }

procedure TMyBackupFileConnectHandler.AddBackConn(TcpSocket: TCustomIpClient);
begin
  BackConnSocket := TcpSocket;
  IsConnSuccess := True;
end;

procedure TMyBackupFileConnectHandler.AddLastConn(LastDesItemID: string;
  TcpSocket: TCustomIpClient);
var
  SendFileSocketInfo : TBackupFileSocketInfo;
  LastDesPcID : string;
begin
  if not Assigned( TcpSocket ) then
    Exit;

    // �����ѶϿ�
  if not TcpSocket.Connected then
  begin
    TcpSocket.Free;
    Exit;
  end;

    // ���ͽ������
  MySocketUtil.SendData( TcpSocket, FileReq_End );

  SocketLock.Enter;
  try
      // ��������10������
    if BackupFileSocketList.Count >= 10 then
    begin
      BackupFileSocketList[0].CloseSocket;
      BackupFileSocketList.Delete( 0 );
    end;
      // ��Ӿ�����
    LastDesPcID := NetworkDesItemUtil.getPcID( LastDesItemID );
    SendFileSocketInfo := TBackupFileSocketInfo.Create( LastDesPcID );
    SendFileSocketInfo.SetTcpSocket( TcpSocket );
    BackupFileSocketList.Add( SendFileSocketInfo );
  except
  end;
  SocketLock.Leave;
end;

procedure TMyBackupFileConnectHandler.BackConnBusy;
begin
  IsConnBusy := True;
end;

procedure TMyBackupFileConnectHandler.BackConnError;
begin
  IsConnError := True;
end;

procedure TMyBackupFileConnectHandler.CanNotConnHandle;
begin
  if BackupConn = BackupConn_Backup then
    DesItemAppApi.SetIsConnected( DesItemID, False )
  else
  if BackupConn = BackupConn_Log then
    BackupLogAppApi.CloudPcNotConn;
end;

constructor TMyBackupFileConnectHandler.Create;
begin
  SocketLock := TCriticalSection.Create;
  BackupFileSocketList := TBackupFileSocketList.Create;
end;

destructor TMyBackupFileConnectHandler.Destroy;
begin
  BackupFileSocketList.Free;
  SocketLock.Free;
  inherited;
end;

function TMyBackupFileConnectHandler.getBackupPcConn( _DesItemID, _SourcePath,
  _BackupConn : string ): TCustomIpClient;
var
  CloudPath : string;
begin
    // ���ܴ��ڶ���������ӣ����Լ���
  SocketLock.Enter;

  DesItemID := _DesItemID;
  SourcePath := _SourcePath;
  DesPcID := NetworkDesItemUtil.getPcID( DesItemID );
  BackupConn := _BackupConn;

  try
    Result := getConnect;  // ��ȡ����

      // ���ͳ�ʼ����Ϣ
    if Assigned( Result ) then
    begin
      CloudPath := NetworkDesItemUtil.getCloudPath( DesItemID );
      MySocketUtil.SendJsonStr( Result, JsonMsgType_CloudPath, CloudPath );
      MySocketUtil.SendJsonStr( Result, JsonMsgType_PcID_Cloud, PcInfo.PcID );
      MySocketUtil.SendJsonStr( Result, JsonMsgType_SourcePath, SourcePath );
    end;
  except
    Result := nil;
  end;

  SocketLock.Leave;
end;

procedure TMyBackupFileConnectHandler.LastConnRefresh;
var
  i: Integer;
begin
  SocketLock.Enter;
  try
    for i := BackupFileSocketList.Count - 1 downto 0 do
    begin
        // ���������ӣ�ɾ��
      if MinutesBetween( Now, BackupFileSocketList[i].LastTime ) >= 3 then
      begin
          // �رն˿�
        BackupFileSocketList[i].CloseSocket;
          // ɾ��
        BackupFileSocketList.Delete( i );
        Continue;
      end;
        // ��������
      MySocketUtil.SendData( BackupFileSocketList[i].TcpSocket, FileReq_HeartBeat );
    end;
  except
  end;
  SocketLock.Leave;
end;


procedure TMyBackupFileConnectHandler.RemoteBusyHandle;
begin
  if BackupConn = BackupConn_Backup then
    BackupItemAppApi.SetIsDesBusy( DesItemID, SourcePath, True )
  else
  if BackupConn = BackupConn_Log then
    BackupLogAppApi.CloudPcBusy;
end;

procedure TMyBackupFileConnectHandler.StopRun;
var
  i: Integer;
begin
  SocketLock.Enter;
  try
    for i := 0 to BackupFileSocketList.Count - 1 do
      BackupFileSocketList[i].CloseSocket;
  except
  end;
  SocketLock.Leave;
end;

function TMyBackupFileConnectHandler.getBackConnect: TCustomIpClient;
begin
    // �ȴ����
  WaitBackConn;

    // ���ؽ��
  if IsConnSuccess then
    Result := BackConnSocket
  else
    Result := nil;
end;

function TMyBackupFileConnectHandler.getConnect: TCustomIpClient;
var
  ReceiveRootPath : string;
  MyTcpConn : TMyTcpConn;
  DesPcIP, DesPcPort : string;
  IsConnected, IsDesBusy : Boolean;
  TcpSocket : TCustomIpClient;
begin
  Result := nil;

    // ��ȡ��ǰ�����ӵĶ˿�
  TcpSocket := getLastConnect;
  if Assigned( TcpSocket ) then
  begin
    Result := TcpSocket;
    Exit;
  end;

    // ��ȡ Pc ��Ϣ
  DesPcIP := MyNetPcInfoReadUtil.ReadIp( DesPcID );
  DesPcPort := MyNetPcInfoReadUtil.ReadPort( DesPcID );

    // Pc ����
  if not MyNetPcInfoReadUtil.ReadIsOnline( DesPcID ) then
    Exit;

    // �����޷����ӶԷ�
  if not MyNetPcInfoReadUtil.ReadIsCanConnectTo( DesPcID ) then
  begin
    Result := getBackConnect; // ��������
    Exit;
  end;

    // ���� Ŀ�� Pc
  TcpSocket := TCustomIpClient.Create( nil );
  MyTcpConn := TMyTcpConn.Create( TcpSocket );
  MyTcpConn.SetConnType( ConnType_CloudFileRequest );
  MyTcpConn.SetConnSocket( DesPcIP, DesPcPort );
  IsConnected := MyTcpConn.Conn;
  MyTcpConn.Free;


    // ʹ�÷�������
  if not IsConnected then
  begin
    TcpSocket.Free;
    NetworkPcApi.SetCanConnectTo( DesPcID, False ); // �����޷�����
    Result := getBackConnect; // ��������
    Exit;
  end;

    // �Ƿ���շ�æ
  IsDesBusy := StrToBoolDef( MySocketUtil.RevJsonStr( TcpSocket ), True );
  if IsDesBusy then
  begin
    TcpSocket.Free;
    RemoteBusyHandle;
    Exit;
  end;

  Result := TcpSocket;
end;

function TMyBackupFileConnectHandler.getLastConnect: TCustomIpClient;
var
  i: Integer;
  SendFileSocketInfo : TBackupFileSocketInfo;
  LastSocket : TCustomIpClient;
  FileReq : string;
begin
  Result := nil;

  try
      // Ѱ���ϴζ˿�
    LastSocket := nil;
    for i := 0 to BackupFileSocketList.Count - 1 do
    begin
      SendFileSocketInfo := BackupFileSocketList[i];
      if SendFileSocketInfo.DesPcID = DesPcID then
      begin
        LastSocket := SendFileSocketInfo.TcpSocket;
        BackupFileSocketList.Delete( i );
        Break;
      end;
    end;
  except
    LastSocket := nil;
  end;

    // ������
  if not Assigned( LastSocket ) then
    Exit;

    // �ж϶˿��Ƿ�����
  MySocketUtil.SendData( LastSocket, FileReq_New );
  FileReq := MySocketUtil.RevData( LastSocket );
  if FileReq <> FileReq_New then  // �˿��쳣
  begin
    LastSocket.Free;
    Result := getLastConnect; // ����һ��
    Exit;
  end;

    // �����ϴζ˿�
  Result := LastSocket;
end;

procedure TMyBackupFileConnectHandler.WaitBackConn;
var
  StartTime : TDateTime;
begin
  DebugLock.Debug( 'BackConnHandle' );

    // �Է��������ӱ���
  if not MyNetPcInfoReadUtil.ReadIsCanConnectFrom( DesPcID ) then
  begin
    CanNotConnHandle;
    Exit;
  end;

      // ��ʼ�������Ϣ
  IsConnSuccess := False;
  IsConnError := False;
  IsConnBusy := False;

    // ����������
  NetworkBackConnEvent.AddItem( DesPcID );

    // �ȴ����շ�����
  StartTime := Now;
  while MyBackupHandler.getIsRun and
        ( MinutesBetween( Now, StartTime ) < 1 ) and
        not IsConnBusy and not IsConnError and not IsConnSuccess
  do
    Sleep(100);

    // Ŀ�� Pc ��æ
  if IsConnBusy then
  begin
    RemoteBusyHandle;
    Exit;
  end;

    // �޷�����
  if IsConnError then
  begin
    NetworkPcApi.SetCanConnectFrom( DesPcID, False ); // �����޷�����
    CanNotConnHandle;
    Exit;
  end;
end;


procedure TBackupFileCompareHandler.RemoveOtherEncDesFile;
var
  p : TScanFilePair;
  FileName, SourceFileName : string;
  ParentPath, RemovePath : string;
  ScanResultRemoveFileInfo : TScanResultRemoveFileInfo;
begin
    // ɾ��������Ϣ��һ�µ��ļ�
  ParentPath := ExtractFilePath( SourceFilePath );
  SourceFileName := ExtractFileName( SourceFilePath );

    // �����ļ�
  for p in ParentFileHash do
  begin
    FileName := p.Value.FileName;
      // �޹ص��ļ�
    if ( FileName <> SourceFileName ) and ( pos( SourceFileName + Sign_Encrypt, FileName ) <= 0 ) then
      Continue;
    if not IsEncrypted and ( FileName = SourceFileName ) then
      Continue;
    if IsEncrypted and ( FileName = SourceFileName + PasswordExt ) then
      Continue;

    RemovePath := MyFilePath.getPath( ParentPath ) + FileName;
    ScanResultRemoveFileInfo := TScanResultRemoveFileInfo.Create( RemovePath );
    ScanResultList.Add( ScanResultRemoveFileInfo );
  end;
end;

procedure TBackupFileCompareHandler.SetParams(Params: TBackupParamsData);
begin
  IsEncrypted := Params.IsEncrypted;
  PasswordExt := Params.ExtPassword;
end;

procedure TBackupFileCompareHandler.Update;
begin
    // Ŀ���ļ�
  DesFilePath := SourceFilePath;
  if IsEncrypted then
    DesFilePath := DesFilePath + PasswordExt;

  inherited;

    // �Ƴ�������Ϣ��ͬ�İ汾
  FindParentFileHash;
  RemoveOtherEncDesFile;
end;

{ TBackupFileHandle }

procedure TFileBackupHandler.CompletedHandle;
begin

end;

constructor TFileBackupHandler.Create;
begin
  NewBackupCount := 0;
  BackupPackageHandler := TBackupPackageHandler.Create;
end;

destructor TFileBackupHandler.Destroy;
begin
  BackupPackageHandler.Free;
  inherited;
end;

procedure TFileBackupHandler.Handle(ScanResultInfo: TScanResultInfo);
begin
  if ScanResultInfo is TScanResultAddFileInfo then
  begin
    Inc( NewBackupCount );
    if NewBackupFileList.Count < 10 then
      NewBackupFileList.Add( ScanResultInfo.SourceFilePath );
  end;
end;

procedure TFileBackupHandler.IniHandle;
begin
end;

procedure TFileBackupHandler.SetNewBackupFileList(
  _NewBackupFileList: TStringList);
begin
  NewBackupFileList := _NewBackupFileList;
end;

procedure TFileBackupHandler.SetParams(_Params: TBackupParamsData);
begin
  Params := _Params;

  DesItemID := Params.DesItemID;
  SourcePath := Params.SourcePath;
  IsFile := Params.IsFile;

  BackupPackageHandler.SetParams( Params );
end;

{ TCompressFileHandle }

function TBackupPackageHandler.AddFile(FilePath: string): Boolean;
var
  ZipName : string;
  NewZipInfo : TZipHeader;
  fs : TStream;
begin
  Result := False;

    // ��ʼ��ѹ����Ϣ
  ZipName := ExtractRelativePath( MyFilePath.getPath( SourcePath ), FilePath );
  if IsEncrypt then
    ZipName := ZipName + ExtPassword;
  NewZipInfo := MyZipUtil.getZipHeader( ZipName, FilePath, zcStored );

  try
    fs := ReadFileStream( FilePath );  // ��ȡѹ����
    if not Assigned( fs ) then // ��ȡʧ��
      Exit;
    ZipFile.Add( fs, NewZipInfo );  // ���ѹ���ļ�
    fs.Free;

      // ���һ��
    NewZipInfo := ZipFile.FileInfo[ ZipFile.FileCount - 1 ];

      // ˢ��ͳ����Ϣ
    ZipSize := ZipSize + NewZipInfo.CompressedSize;
    Inc( ZipCount );
    TotalSize := TotalSize + NewZipInfo.UncompressedSize;
    Result := True;
  except
  end;
end;

function TBackupPackageHandler.AddZipFile(ScanResultInfo : TScanResultInfo): TScanResultInfo;
var
  SourceFileSize : Int64;
begin
  Result := ScanResultInfo;

    // �Ƿ����ļ�
  if not ( ScanResultInfo is TScanResultAddFileInfo ) then
    Exit;

    // ֻѹ��С�� 128 KB ���ļ�
  SourceFileSize := MyFileInfo.getFileSize( ScanResultInfo.SourceFilePath );
  if ( SourceFileSize = 0 ) or ( SourceFileSize > 128 * Size_KB ) then
    Exit;

    // �ȴ���ѹ���ļ�
  if not IsZipCreated then
  begin
    if not CreateZip then  // �����ļ�ʧ��
      Exit;
  end;

    // ���ѹ���ļ�ʧ��
  if not AddFile( ScanResultInfo.SourceFilePath ) then
    Exit;

    // ���� 1000 ���ļ� ���� 10MB �����̷���ѹ���ļ�
  if ( ZipCount >= 1000 ) or ( ZipSize >= 10 * Size_MB ) then
  begin
    Result := ReadZipResultInfo;
    Exit;
  end;

    // ���ؿ�
  Result := nil;
end;

constructor TBackupPackageHandler.Create;
begin
  IsZipCreated := False;
end;

function TBackupPackageHandler.CreateZip: Boolean;
begin
  Result := False;

  try
      // ����ѹ����
    ZipStream := TMemoryStream.Create;

      // ����ѹ����
    ZipFile := TZipFile.Create;
    ZipFile.Open( ZipStream, zmWrite );

      // ���ش����ɹ�
    Result := True;

      // ��ʼ��ѹ��״̬
    IsZipCreated := True;
    ZipSize := 0;
    ZipCount := 0;
    TotalSize := 0;
  except
  end;
end;

procedure TBackupPackageHandler.DestoryZip;
begin
    // δ����ѹ���ļ�
  if not IsZipCreated then
    Exit;

    // �ر�ѹ���ļ�
  try
    IsZipCreated := False;
    ZipFile.Close;
    ZipFile.Free;
  except
  end;
end;

destructor TBackupPackageHandler.Destroy;
begin
  if IsZipCreated then
  begin
    DestoryZip;
    ZipStream.Free;
  end;
  inherited;
end;

function TBackupPackageHandler.ReadZipResultInfo: TScanResultAddZipInfo;
begin
  Result := nil;

    // δ����ѹ���ļ�
  if not IsZipCreated then
    Exit;

    // �ر�ѹ���ļ�
  DestoryZip;

    // ����ѹ����
  Result := TScanResultAddZipInfo.Create( SourcePath );
  Result.SetZipStream( ZipStream );
  Result.SetTotalSize( TotalSize );
end;

function TBackupPackageHandler.ReadFileStream(FilePath: string): TStream;
var
  DataBuf : TDataBuf;
  fs : TFileStream;
  FileSize : Int64;
begin
  try
      // ��ͨ�ļ�
    if not IsEncrypt then
    begin
      Result := TFileStream.Create( FilePath, fmOpenRead or fmShareDenyNone );
      Exit;
    end;

      // ��ȡ�ļ���Ϣ
    fs := TFileStream.Create( FilePath, fmOpenRead or fmShareDenyNone );
    FileSize := fs.Size;
    fs.ReadBuffer( DataBuf, FileSize );
    fs.Free;

      // ����
    SendFileUtil.Encrypt( DataBuf, FileSize, Password );

      // д�������
    Result := TMemoryStream.Create;
    Result.WriteBuffer( DataBuf, FileSize );
    Result.Position := 0;
  except
    Result := nil;
  end;
end;

function TBackupPackageHandler.getLastSendFile: TScanResultInfo;
begin
  Result := ReadZipResultInfo;
end;

procedure TBackupPackageHandler.SetParams(Params: TBackupParamsData);
begin
  DesItemID := Params.DesItemID;
  SourcePath := Params.SourcePath;

  IsEncrypt := Params.IsEncrypted;
  Password := Params.Password;
  ExtPassword := Params.ExtPassword;
end;

{ TSendFileThread }

procedure TBackupFileThread.AddScanResultInfo(_ScanResultInfo: TScanResultInfo);
begin
  IsRun := True;
  ScanResultInfo := _ScanResultInfo;
end;

procedure TBackupFileThread.BackupFile;
var
  BackupResultHandle : TNetworkBackupResultHandle;
begin
    // ������
  BackupResultHandle := TNetworkBackupResultHandle.Create;
  BackupResultHandle.SetScanResultInfo( ScanResultInfo );
  BackupResultHandle.SetParams( Params );
  BackupResultHandle.SetTcpSocket( TcpSocket );
  BackupResultHandle.Update;
  BackupResultHandle.Free;

    // �Ƿ��ڱ��ݹ��̶Ͽ�����
  IsLostConn := not TcpSocket.Connected;
end;

constructor TBackupFileThread.Create;
begin
  inherited Create;
  IsRun := False;
  IsLostConn := False;
end;

destructor TBackupFileThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;
  inherited;
end;

procedure TBackupFileThread.Execute;
begin
  while not Terminated and not IsLostConn do
  begin
    WaitToBackup;
    if Terminated or not IsRun then
      Break;
    BackupFile;
    if not IsLostConn then
      IsRun := False;
  end;

    // ���ն˿�
  MyBackupFileConnectHandler.AddLastConn( DesItemID, TcpSocket );
end;

procedure TBackupFileThread.SetParams(_Params: TBackupParamsData);
begin
  Params := _Params;
  DesItemID := Params.DesItemID;
  SourcePath := Params.SourcePath;
end;

procedure TBackupFileThread.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TBackupFileThread.WaitToBackup;
var
  StartTime : TDateTime;
begin
  StartTime := Now;
  while not IsRun and not Terminated and MyBackupHandler.getIsRun do
  begin
    Sleep( 100 );
    if SecondsBetween( Now, StartTime ) < 10 then  // 10 �뷢��һ������
      Continue;
    if not MySocketUtil.SendData( TcpSocket, FileReq_HeartBeat ) then // ��������
    begin
      TcpSocket.Disconnect;
      IsLostConn := True;  // �Է��Ͽ�������
      Break;
    end;
    StartTime := Now;
  end;
end;

{ TNetworkBackupFileHandle }

procedure TNetworkBackupFileHandle.CheckHeartBeat;
begin
    // 10 �뷢��һ������
  if SecondsBetween( Now, HeartTime ) < 10 then
    Exit;

  MySocketUtil.SendData( TcpSocket, FileReq_HeartBeat );

  HeartTime := Now;
end;

procedure TNetworkBackupFileHandle.CompletedHandle;
var
  ScanResultInfo : TScanResultInfo;
  i: Integer;
  IsFind : Boolean;
begin
    // ��������ѹ���ļ�
  ScanResultInfo := BackupPackageHandler.getLastSendFile;
  if Assigned( ScanResultInfo ) then
    SendFile( ScanResultInfo );

    // �ȴ��߳̽���
  while MyBackupHandler.getIsRun do
  begin
    IsFind := False;
    for i := 0 to BackupFileThreadList.Count - 1 do
      if BackupFileThreadList[i].IsRun and not BackupFileThreadList[i].IsLostConn then
      begin
        IsFind := True;
        Break;
      end;
    if not IsFind then
      Break;
    Sleep( 100 );
    CheckHeartBeat;
  end;
end;

constructor TNetworkBackupFileHandle.Create;
begin
  inherited;
  BackupFileThreadList := TBackupFileThreadList.Create;
  HeartTime := Now;
end;

destructor TNetworkBackupFileHandle.Destroy;
begin
  BackupFileThreadList.Free;
  inherited;
end;

function TNetworkBackupFileHandle.getNewConnect: TCustomIpClient;
var
  NewSocket : TCustomIpClient;
  CloudConnResult : string;
begin
  Result := nil;

  NewSocket := MyBackupFileConnectHandler.getBackupPcConn( DesItemID, SourcePath, BackupConn_Backup );
  if not Assigned( NewSocket ) then
    Exit;

    // ��ȡ���ʽ��
  CloudConnResult := MySocketUtil.RevData( NewSocket );

  if CloudConnResult = CloudConnResult_OK then
    Result := NewSocket
  else
    NewSocket.Free;
end;

procedure TNetworkBackupFileHandle.Handle(ScanResultInfo: TScanResultInfo);
begin
  inherited;

    // ��ʱ������
  CheckHeartBeat;

    // �Ƿ�����ļ�ѹ��
  if not IsFile then
    ScanResultInfo := BackupPackageHandler.AddZipFile( ScanResultInfo );

    // ����ѹ���ļ���������� Job
  if ScanResultInfo = nil then
    Exit;

    // ������ͨ�ļ� �� ����ѹ���ļ�
  if ( ScanResultInfo is TScanResultAddFileInfo ) or
     ( ScanResultInfo is TScanResultAddZipInfo )
  then
    SendFile( ScanResultInfo )  // Ѱ���̷߳���
  else
    HandleNow( ScanResultInfo ); // ���̴���
end;

procedure TNetworkBackupFileHandle.HandleNow(ScanResultInfo: TScanResultInfo);
var
  BackupResultHandle : TNetworkBackupResultHandle;
begin
    // ������
  BackupResultHandle := TNetworkBackupResultHandle.Create;
  BackupResultHandle.SetScanResultInfo( ScanResultInfo );
  BackupResultHandle.SetParams( Params );
  BackupResultHandle.SetTcpSocket( TcpSocket );
  BackupResultHandle.Update;
  BackupResultHandle.Free;
end;

procedure TNetworkBackupFileHandle.IniHandle;
var
  DesPcID : string;
  i: Integer;
  NewSocket : TCustomIpClient;
  BackupFileThread : TBackupFileThread;
begin
    // �����ļ������ٴ����߳�
  if IsFile then
    Exit;

    // ������ Pc ���ö��߳�
  DesPcID := NetworkDesItemUtil.getPcID( DesItemID );
  if not MyNetPcInfoReadUtil.ReadIsLanPc( DesPcID ) then
    Exit;

    // 3�̷߳���
  for i := 1 to 3 do
  begin
    NewSocket := getNewConnect;
    if not Assigned( NewSocket ) then
      Continue;
    BackupFileThread := TBackupFileThread.Create;
    BackupFileThread.SetParams( Params );
    BackupFileThread.SetTcpSocket( NewSocket );
    BackupFileThread.Resume;
    BackupFileThreadList.Add( BackupFileThread );
  end;
end;

procedure TNetworkBackupFileHandle.SendFile(ScanResultInfo: TScanResultInfo);
var
  IsFindThread : Boolean;
  i : Integer;
begin
    // Ѱ�ҿ��е��߳�
  IsFindThread := False;
  for i := 0 to BackupFileThreadList.Count - 1 do
    if not BackupFileThreadList[i].IsRun and not BackupFileThreadList[i].IsLostConn then
    begin
      BackupFileThreadList[i].AddScanResultInfo( ScanResultInfo );
      IsFindThread := True;
      Break;
    end;

    // �Ҳ��������̣߳���ǰ�̴߳���
  if not IsFindThread then
    HandleNow( ScanResultInfo );
end;

procedure TNetworkBackupFileHandle.SetParams(_Params: TBackupParamsData);
var
  NetworkBackupParamsData : TNetworkBackupParamsData;
begin
  inherited;

  NetworkBackupParamsData := Params as TNetworkBackupParamsData;
  TcpSocket := NetworkBackupParamsData.TcpSocket;
end;


{ TLocalBackupFileHandle }

procedure TLocalFileBackupHandler.CompletedHandle;
var
  ScanResultInfo : TScanResultInfo;
begin
    // ��������ѹ���ļ�
  ScanResultInfo := BackupPackageHandler.getLastSendFile;
  if Assigned( ScanResultInfo ) then
    HandleNow( ScanResultInfo );
end;

procedure TLocalFileBackupHandler.Handle(ScanResultInfo: TScanResultInfo);
begin
  inherited;

    // �Ƿ�����ļ�ѹ��
  if not IsFile then
    ScanResultInfo := BackupPackageHandler.AddZipFile( ScanResultInfo );

    // ����ѹ���ļ���������� Job
  if ScanResultInfo = nil then
    Exit;

    // ���̴���
  HandleNow( ScanResultInfo );
end;

{ TBackupFreeLimitHandle }

function TBackupFreeLimitReader.AddResult(ScanResultInfo: TScanResultInfo): Boolean;
var
  BackupFileSize : Int64;
begin
  Result := True;
  if not ( ScanResultInfo is TScanResultAddFileInfo ) then
    Exit;

  if not IsFreeLimit then
    Exit;
  BackupFileSize := MyFileInfo.getFileSize( ScanResultInfo.SourceFilePath );
  if ( LastCompletedSpace + BackupFileSize ) < RegisterLimitApi.ReadFeeBackupSpace then
  begin
    LastCompletedSpace := LastCompletedSpace + BackupFileSize;
    Exit;
  end;

  MyBackupHandler.ShowFreeLimit;
  Result := False;
end;

constructor TBackupFreeLimitReader.Create(_DesItemID, _SourcePath: string);
begin
  DesItemID := _DesItemID;
  SourcePath := _SourcePath;
end;

procedure TBackupFreeLimitReader.IniHandle;
begin
  IsFreeLimit := MyRegisterInfo.IsFreeLimit;
  if not IsFreeLimit then
    Exit;

      // ��ȡ�ϴ�����ɿռ���Ϣ����������ʱʹ��
  LastCompletedSpace := DesItemInfoReadUtil.ReadTotalCompletedSpace;
end;

{ TBackupCancelReader }

constructor TBackupCancelReader.Create;
begin
  ScanTime := Now;
end;

function TBackupCancelReader.getIsRun: Boolean;
begin
  Result := MyBackupHandler.getIsRun;

    // �Ƿ��Ѿ�����
  if SecondsBetween( Now, ScanTime ) >= 1 then  // ��� BackupItem ɾ��
  begin
    Result := Result and BackupItemInfoReadUtil.ReadIsEnable( DesItemID, SourcePath );
    if Result then  // Enable
      ScanTime := Now;
  end;
end;

procedure TBackupCancelReader.SetParams(Params: TBackupParamsData);
begin
  DesItemID := Params.DesItemID;
  SourcePath := Params.SourcePath;
end;

{ TNetworkBackupCancelReader }

function TNetworkBackupCancelReader.getIsRun: Boolean;
begin
  Result := inherited and TcpSocket.Connected;
end;

procedure TNetworkBackupCancelReader.SetParams(Params: TBackupParamsData);
var
  NetworkBackupParamsData : TNetworkBackupParamsData;
begin
  inherited;

  NetworkBackupParamsData := Params as TNetworkBackupParamsData;
  TcpSocket := NetworkBackupParamsData.TcpSocket;
end;

{ TLocalBackupOperateHandle }

function TLocalBackupOperater.CreaterFileBackupHandler: TFileBackupHandler;
begin
  Result := TLocalFileBackupHandler.Create;
end;

function TLocalBackupOperater.CreaterContinuesHandler: TBackupContinuesHandler;
begin
  Result := TLocalBackupContinuesHandler.Create;
end;

function TLocalBackupOperater.CreaterFileCompareHandler: TBackupFileCompareHandler;
var
  LocalFileScanHandle : TLocalBackupFileCompareHandler;
begin
  LocalFileScanHandle := TLocalBackupFileCompareHandler.Create;
  Result := LocalFileScanHandle;
end;

function TLocalBackupOperater.CreaterFolderCompareHandler: TBackupFolderCompareHandler;
begin
  Result := TLocalBackupFolderCompareHandler.Create;
end;

function TLocalBackupOperater.getDesItemIsAvailable: Boolean;
var
  DesFolderPath : string;
begin
    // ���ò�ȱС�ռ�
  DesItemAppApi.SetIsLackSpace( DesItemID, False );

    // �Ƿ���ڴ���
  Result := MyHardDisk.getPathDriverExist( DesItemID );
  DesItemAppApi.SetIsExist( DesItemID, Result );
  if not Result then
    Exit;

    // ����Ŀ¼
  DesFolderPath := MyFilePath.getLocalBackupPath( DesItemID, SourcePath );
  if IsFile then
    DesFolderPath := ExtractFileDir( DesFolderPath );
  ForceDirectories( DesFolderPath );

    // �Ƿ��д
  Result := MyFilePath.getIsModify( DesItemID );
  DesItemAppApi.SetIsWrite( DesItemID, Result );
  if not Result then
    Exit;
end;


procedure TLocalBackupOperater.SetBackupCompleted;
begin
  BackupItemAppApi.SetLocalBackupCompleted( DesItemID, SourcePath );
end;

{ TNetworkBackupOperater }

function TNetworkBackupOperater.CreaterContinuesHandler: TBackupContinuesHandler;
begin
  Result := TNetworkSendContinuesHandler.Create;
end;

function TNetworkBackupOperater.CreaterFileBackupHandler: TFileBackupHandler;
begin
  Result := TNetworkBackupFileHandle.Create;
end;

function TNetworkBackupOperater.CreaterFileCompareHandler: TBackupFileCompareHandler;
begin
  Result := TNetworkFileCompareHandler.Create;
end;

function TNetworkBackupOperater.CreaterFolderCompareHandler: TBackupFolderCompareHandler;
begin
  Result := TNetworkFolderCompareHandler.Create;
end;

function TNetworkBackupOperater.getDesItemIsAvailable: Boolean;
var
  CloudConnResult : string;
  IsDesExist, IsDesWrite : Boolean;
begin
  Result := False;

    // ��ȡ���ʽ��
  CloudConnResult := MySocketUtil.RevJsonStr( TcpSocket );

      // ���� ������
  DesItemAppApi.SetIsConnected( DesItemID, True );

    // ���� ��ȱ�ٿռ�
  DesItemAppApi.SetIsLackSpace( DesItemID, False );

    // �Ƿ������·��
  IsDesExist := CloudConnResult <> CloudConnResult_NotExist;
  DesItemAppApi.SetIsExist( DesItemID, IsDesExist );

    // ��·���Ƿ��д
  IsDesWrite := CloudConnResult <> CloudConnResult_CannotWrite;
  DesItemAppApi.SetIsWrite( DesItemID, IsDesWrite );

    // �Ƿ񷵻�����
  Result := CloudConnResult = CloudConnResult_OK;
end;

procedure TNetworkBackupOperater.SetBackupCompleted;
begin
  BackupItemAppApi.SetNetworkBackupCompleted( DesItemID, SourcePath );
end;

procedure TNetworkBackupOperater.SetParams(Params: TBackupParamsData);
var
  NetworkBackupParamsData : TNetworkBackupParamsData;
begin
  inherited;

  NetworkBackupParamsData := Params as TNetworkBackupParamsData;
  TcpSocket := NetworkBackupParamsData.TcpSocket;
end;

{ TBackupOperater }

procedure TBackupOperater.SetParams(Params: TBackupParamsData);
begin
  DesItemID := Params.DesItemID;
  SourcePath := Params.SourcePath;
  IsFile := Params.IsFile;
end;

{ TBackupStartHandle }

procedure TBackupStartHandle.AddToHint;
var
  BackupTo : string;
begin
  if IsLocalBackup then
    BackupTo := DesItemID
  else
  begin
    BackupTo := NetworkDesItemUtil.getPcID( DesItemID );
    BackupTo := MyNetPcInfoReadUtil.ReadName( BackupTo );
  end;

  BackupHintAppApi.ShowBackuping( SourcePath, BackupTo );
end;

procedure TBackupStartHandle.BackupHandle;
var
  BackupProcessHandle : TBackupProcessHandle;
begin
  BackupProcessHandle := TBackupProcessHandle.Create;
  BackupProcessHandle.SetBackupParamsData( BackupParamsData );
  BackupProcessHandle.SetBackupOperator( BackupOperator );
  BackupProcessHandle.Update;
  BackupProcessHandle.Free;
end;

constructor TBackupStartHandle.Create(_BackupPathInfo: TBackupPathInfo);
begin
  BackupPathInfo := _BackupPathInfo;
  DesItemID := BackupPathInfo.DesItemID;
  SourcePath := BackupPathInfo.SourcePath;
  IsLocalBackup := BackupPathInfo is TLocalBackupPathInfo;
end;

function TBackupStartHandle.CreateBackupData: Boolean;
begin
  Result := True;
  if IsLocalBackup then
    CreateLocalBackupData
  else
    Result := CreateNetworkBackupData;

    // ����ʧ��
  if not Result then
    Exit;

    // ������Ϣ
  BackupParamsData.DesItemID := DesItemID;
  BackupParamsData.SourcePath := SourcePath;
  BackupParamsData.IsFile := BackupItemInfoReadUtil.ReadIsFile( DesItemID, SourcePath );

    // ����ɾ���ļ���Ϣ
  BackupParamsData.IsSaveDeleted := BackupItemInfoReadUtil.ReadIsKeepDeleted( DesItemID, SourcePath );
  BackupParamsData.KeepDeletedCount := BackupItemInfoReadUtil.ReadIsKeepEditionCount( DesItemID, SourcePath );

    // ������Ϣ
  BackupParamsData.IsEncrypted := BackupItemInfoReadUtil.ReadIsEncrypted( DesItemID, SourcePath );
  BackupParamsData.Password := BackupItemInfoReadUtil.ReadPassword( DesItemID, SourcePath );
  BackupParamsData.ExtPassword := MyEncrypt.getPasswordExt( BackupParamsData.Password );

    // ��������Ϣ
  BackupParamsData.IncludeFilterList := BackupItemInfoReadUtil.ReadIncludeFilter( DesItemID, SourcePath );
  BackupParamsData.ExcludeFilterList := BackupItemInfoReadUtil.ReadExcludeFilter( DesItemID, SourcePath );

    // �ļ����ͷ�����
  BackupParamsData.BackupAnalyzer := TBackupAnalyzer.Create;

    // ��������
  BackupParamsData.SpeedReader := TimeReader;
  BackupParamsData.BackupCancelReader := BackupCancelReader;

    // ��������
  BackupOperator.SetParams( BackupParamsData );
  BackupCancelReader.SetParams( BackupParamsData );
end;

procedure TBackupStartHandle.CreateLocalBackupData;
begin
  TimeReader := TSpeedReader.Create;
  BackupCancelReader := TBackupCancelReader.Create;
  BackupParamsData := TBackupParamsData.Create;
  BackupOperator := TLocalBackupOperater.Create;
end;

function TBackupStartHandle.CreateNetworkBackupData: Boolean;
var
  TcpSocket : TCustomIpClient;
  IsLimited : Boolean;
  LimitSpeed : Int64;
begin
  Result := False;

    // ����һ������
  TcpSocket := MyBackupFileConnectHandler.getBackupPcConn( DesItemID, SourcePath, BackupConn_Backup );
  if not Assigned( TcpSocket ) then  // ��ȡ����ʧ��
    Exit;

    // ����
  IsLimited := BackupSpeedInfoReadUtil.getIsLimit;
  LimitSpeed := BackupSpeedInfoReadUtil.getLimitSpeed;
  TimeReader := TSpeedReader.Create;
  TimeReader.SetLimitInfo( IsLimited, LimitSpeed );

    // ����Ƿ�ȡ��
  BackupCancelReader := TNetworkBackupCancelReader.Create;

    // ����
  BackupParamsData := TNetworkBackupParamsData.Create;
  ( BackupParamsData as TNetworkBackupParamsData ).TcpSocket := TcpSocket;
  ( BackupParamsData as TNetworkBackupParamsData ).HeartBeatTime := Now;

    // ���ݲ���
  BackupOperator := TNetworkBackupOperater.Create;

  Result := True;
end;

procedure TBackupStartHandle.DestoryBackupData;
begin
    // ��ر��ض���Ϣ
  if not IsLocalBackup then
    DestoryNetworkData;

  TimeReader.Free;
  BackupCancelReader.Free;
  BackupParamsData.BackupAnalyzer.Free;
  BackupParamsData.IncludeFilterList.Free;
  BackupParamsData.ExcludeFilterList.Free;
  BackupParamsData.Free;
  BackupOperator.Free;
end;

procedure TBackupStartHandle.DestoryNetworkData;
var
  TcpSocket : TCustomIpClient;
begin
  TcpSocket := ( BackupParamsData as TNetworkBackupParamsData ).TcpSocket;

    // ���������б�
  MyBackupFileConnectHandler.AddLastConn( DesItemID, TcpSocket );
end;

procedure TBackupStartHandle.Update;
begin
    // ��ʾ��ʼ����
  AddToHint;

    // �������ݽṹ
  if not CreateBackupData then
    Exit;

    // ���ݴ���
  BackupHandle;

    // �ͷ����ݽṹ
  DestoryBackupData;
end;

{ TBackupSendFileOperator }

procedure TBackupSendFileOperator.AddSpeedSpace(SendSize: Integer);
var
  IsLimited : Boolean;
  LimitSpeed : Int64;
begin
    // ��ӵ����ٶ�
  MyRefreshSpeedHandler.AddUpload( SendSize );

    // ˢ���ٶȣ� 1����ˢ��һ��
  if SpeedReader.AddCompleted( SendSize ) then
  begin
      // ���� ˢ�±����ٶ�
    BackupItemAppApi.SetSpeed( DesItemID, SourcePath, SpeedReader.ReadLastSpeed );

      // ���»�ȡ���ƿռ���Ϣ
    IsLimited := BackupSpeedInfoReadUtil.getIsLimit;
    LimitSpeed := BackupSpeedInfoReadUtil.getLimitSpeed;
    SpeedReader.SetLimitInfo( IsLimited, LimitSpeed );
  end;
end;

procedure TBackupSendFileOperator.LostConnectError;
var
  Params : TBackupErrorAddParams;
begin
  Params.SendRootItemID := DesItemID;
  Params.SourcePath := SourcePath;
  Params.FilePath := ReadFilePath;
  Params.FileSize := ReadFileSize;
  Params.CompletedSize := ReadFilePos;
  BackupErrorAppApi.LostConnectError( Params );

    // ���öϿ����ӣ���ʱ���ݽ�������
  BackupItemAppApi.SetIsLostConn( DesItemID, SourcePath, True );
end;

procedure TBackupSendFileOperator.MarkContinusSend;
var
  Params : TBackupContinusAddParams;
begin
    // ������ȡ��
  if not BackupItemInfoReadUtil.ReadIsEnable( DesItemID, SourcePath ) then
    Exit;

  Params.DesItemID := DesItemID;
  Params.SourcePath := SourcePath;
  Params.FilePath := ReadFilePath;
  Params.FileSize := ReadFileSize;
  Params.FileTime := ReadFileTime;
  BackupContinusAppApi.AddItem( Params );
end;

procedure TBackupSendFileOperator.ReadFileError;
var
  Params : TBackupErrorAddParams;
begin
  Params.SendRootItemID := DesItemID;
  Params.SourcePath := SourcePath;
  Params.FilePath := ReadFilePath;
  Params.FileSize := ReadFileSize;
  Params.CompletedSize := ReadFilePos;
  BackupErrorAppApi.ReadFileError( Params );
end;

function TBackupSendFileOperator.ReadIsLimitSpeed: Boolean;
begin
  Result := SpeedReader.ReadIsLimited;
end;

function TBackupSendFileOperator.ReadIsNextSend: Boolean;
begin
  Result := inherited and BackupCancelReader.getIsRun;
end;

function TBackupSendFileOperator.ReadLimitSpeed: Int64;
begin
  Result := SpeedReader.ReadAvailableSpeed;
end;

procedure TBackupSendFileOperator.RefreshCompletedSpace;
var
  LastCompletedSpace : Int64;
begin
    // ˢ������ɿռ䣬���ݰٷֱ�
  LastCompletedSpace := ReadLastCompletedSize;
  BackupItemAppApi.AddBackupCompletedSpace( DesItemID, SourcePath,  LastCompletedSpace );
end;

procedure TBackupSendFileOperator.RevFileLackSpaceHandle;
begin
  DesItemAppApi.SetIsLackSpace( DesItemID, True );
end;

procedure TBackupSendFileOperator.SetParams(Params: TBackupParamsData);
begin
  DesItemID := Params.DesItemID;
  SourcePath := Params.SourcePath;

  SpeedReader := Params.SpeedReader;
  BackupCancelReader := Params.BackupCancelReader;
end;

procedure TBackupSendFileOperator.TransferFileError;
var
  Params : TBackupErrorAddParams;
begin
  Params.SendRootItemID := DesItemID;
  Params.SourcePath := SourcePath;
  Params.FilePath := ReadFilePath;
  Params.FileSize := ReadFileSize;
  Params.CompletedSize := ReadFilePos;
  BackupErrorAppApi.SendFileError( Params );

    // ���öϿ����ӣ���ʱ���ݽ�������
  BackupItemAppApi.SetIsLostConn( DesItemID, SourcePath, True );
end;

procedure TBackupSendFileOperator.WriteFileError;
var
  Params : TBackupErrorAddParams;
begin
  Params.SendRootItemID := DesItemID;
  Params.SourcePath := SourcePath;
  Params.FilePath := ReadFilePath;
  Params.FileSize := ReadFileSize;
  Params.CompletedSize := ReadFilePos;
  BackupErrorAppApi.WriteFileError( Params );
end;

{ TBackupCopyFileOperator }

procedure TBackupCopyFileOperator.AddSpeedSpace(SendSize: Integer);
begin
    // ˢ���ٶ�
  if SpeedReader.AddCompleted( SendSize ) then
    BackupItemAppApi.SetSpeed( DesItemID, SourcePath, SpeedReader.ReadLastSpeed );
end;

procedure TBackupCopyFileOperator.DesWriteSpaceLack;
begin
  DesItemAppApi.setIsLackSpace( DesItemID, True );
end;

procedure TBackupCopyFileOperator.MarkContinusCopy;
var
  Params : TBackupContinusAddParams;
begin
    // ������ȡ��
  if not BackupItemInfoReadUtil.ReadIsEnable( DesItemID, SourcePath ) then
    Exit;

  Params.DesItemID := DesItemID;
  Params.SourcePath := SourcePath;
  Params.FilePath := ReadFilePath;
  Params.FileSize := ReadFileSize;
  Params.FileTime := ReadFileTime;
  BackupContinusAppApi.AddItem( Params );
end;

procedure TBackupCopyFileOperator.ReadFileError;
var
  Params : TBackupErrorAddParams;
begin
  Params.SendRootItemID := DesItemID;
  Params.SourcePath := SourcePath;
  Params.FilePath := ReadFilePath;
  Params.FileSize := ReadFileSize;
  Params.CompletedSize := ReadFilePos;
  BackupErrorAppApi.ReadFileError( Params );
end;

function TBackupCopyFileOperator.ReadIsNextCopy: Boolean;
begin
  Result := inherited and BackupCancelReader.getIsRun;
end;

procedure TBackupCopyFileOperator.RefreshCompletedSpace;
var
  LastCompletedSpace : Int64;
begin
  LastCompletedSpace := ReadLastCompletedSize;

    // ��� ����ɿռ�
  BackupItemAppApi.AddBackupCompletedSpace( DesItemID, SourcePath, LastCompletedSpace );
end;

procedure TBackupCopyFileOperator.SetParams(Params: TBackupParamsData);
begin
  DesItemID := Params.DesItemID;
  SourcePath := Params.SourcePath;
  BackupCancelReader := Params.BackupCancelReader;
  SpeedReader := Params.SpeedReader;
end;

procedure TBackupCopyFileOperator.WriteFileError;
var
  Params : TBackupErrorAddParams;
begin
  Params.SendRootItemID := DesItemID;
  Params.SourcePath := SourcePath;
  Params.FilePath := ReadFilePath;
  Params.FileSize := ReadFileSize;
  Params.CompletedSize := ReadFilePos;
  BackupErrorAppApi.WriteFileError( Params );
end;

{ TBackupFileUnpackOperator }

procedure TBackupFileUnpackOperator.AddSpeedSpace(SendSize: Integer);
begin
    // ˢ���ٶ�
  if SpeedReader.AddCompleted( SendSize ) then
    BackupItemAppApi.SetSpeed( DesItemID, SourcePath, SpeedReader.ReadLastSpeed );
end;

function TBackupFileUnpackOperator.ReadIsNextCopy: Boolean;
begin
  Result := inherited and BackupCancelReader.getIsRun;
end;

procedure TBackupFileUnpackOperator.RefreshCompletedSpace;
var
  LastCompletedSpace : Int64;
begin
  LastCompletedSpace := ReadLastComletedSize;

    // ��� ����ɿռ�
  BackupItemAppApi.AddBackupCompletedSpace( DesItemID, SourcePath, LastCompletedSpace );
end;

procedure TBackupFileUnpackOperator.SetParams(Params: TBackupParamsData);
begin
  DesItemID := Params.DesItemID;
  SourcePath := Params.SourcePath;
  BackupCancelReader := Params.BackupCancelReader;
  SpeedReader := Params.SpeedReader;
end;

procedure TLocalFileBackupHandler.HandleNow(ScanResultInfo: TScanResultInfo);
var
  LocalBackupResultHandle : TLocalBackupResultHandle;
begin
    // ������
  LocalBackupResultHandle := TLocalBackupResultHandle.Create;
  LocalBackupResultHandle.SetScanResultInfo( ScanResultInfo );
  LocalBackupResultHandle.SetParams( Params );
  LocalBackupResultHandle.Update;
  LocalBackupResultHandle.Free;
end;

{ TLogPathInfo }

procedure TLogPathInfo.SetFileInfo(_FilePath: string; _FileTime: TDateTime);
begin
  FilePath := _FilePath;
  FileTime := _FileTime;
end;

{ TBackupLogHandleThread }

procedure TBackupLogHandleThread.Execute;
var
  LogPathInfo : TLogPathInfo;
begin
  FreeOnTerminate := True;

    // ���ݲ���
  while MyBackupHandler.IsRun do
  begin
    LogPathInfo := MyBackupLogHandler.getLogPathInfo;
    if LogPathInfo = nil then
      Break;

    try
        // ɨ��·��
      StartHandle( LogPathInfo );
    except
    end;

      // ֹͣɨ��
    LogPathInfo.Free;
  end;

    // ��������������߳̽���
  if not MyBackupLogHandler.IsRun then
    MyBackupLogHandler.IsCreateThread := False;

    // ����
  Terminate;
end;

procedure TBackupLogHandleThread.StartHandle(LogPathInfo : TLogPathInfo);
var
  BackupLogStartHandle : TBackupLogStartHandle;
begin
  if LogPathInfo is TLocalPreviewLogInfo then
    BackupLogStartHandle := TLocalPreviewLogHandle.Create
  else
  if LogPathInfo is TNetworkPreviewLogInfo then
    BackupLogStartHandle := TNetworkPreviewLogHandle.Create
  else
  if LogPathInfo is TLocalRestoreLogInfo then
    BackupLogStartHandle := TLocalRestoreLogHandle.Create
  else
  if LogPathInfo is TNetworkRestoreLogInfo then
    BackupLogStartHandle := TNetworkRestoreLogHandle.Create;
  BackupLogStartHandle.SetLogPathInfo( LogPathInfo );
  BackupLogStartHandle.Update;
  BackupLogStartHandle.Free;
end;

{ TMyBackupLogHandler }

procedure TMyBackupLogHandler.AddLogPathInfo(LogPathInfo: TLogPathInfo);
begin
  if not IsRun then
    Exit;

  ThreadLock.Enter;

    // ��ӵ�ɨ���б���
  LogPathList.Add( LogPathInfo );

    // û�д����̣߳����ȴ����߳�
  if not IsCreateThread then
  begin
    IsCreateThread := True;
    BackupLogHandleThread := TBackupLogHandleThread.Create;
    BackupLogHandleThread.Resume;
  end;
  ThreadLock.Leave;
end;

constructor TMyBackupLogHandler.Create;
begin
  ThreadLock := TCriticalSection.Create;
  LogPathList := TLogPathList.Create;
  LogPathList.OwnsObjects := False;
  IsCreateThread := False;

  IsRun := True;
end;

destructor TMyBackupLogHandler.Destroy;
begin
  LogPathList.OwnsObjects := True;
  LogPathList.Free;
  ThreadLock.Free;
  inherited;
end;

function TMyBackupLogHandler.getIsRun: Boolean;
begin
  Result := IsRun;
end;

function TMyBackupLogHandler.getLogPathInfo: TLogPathInfo;
begin
  ThreadLock.Enter;
  if LogPathList.Count > 0 then
  begin
    Result := LogPathList[0];
    LogPathList.Delete(0);
  end
  else
  begin
    Result := nil;
    IsCreateThread := False;
  end;
  ThreadLock.Leave;
end;

procedure TMyBackupLogHandler.StopScan;
begin
  IsRun := False;

  while IsCreateThread do
    Sleep( 100 );
end;

{ TBackupLogStartHandle }

constructor TBackupLogStartHandle.Create;
begin
  IsExist := False;
  IsDeleted := False;
  EditionNum := 0;
end;

procedure TBackupLogStartHandle.LogFileNotExist;
begin
  BackupLogAppApi.FileNotExist;
end;

function TBackupLogStartHandle.ReadIsDeleted: Boolean;
var
  p : TScanFilePair;
begin
  Result := False;

  ScanFileHash := TScanFileHash.Create;

    // ��ȡɾ���ļ��б�
  ReadDeletedFileHash;

    // �Ƚ��ļ��޸�ʱ��
  for p in ScanFileHash do
    if MyDatetime.Equals( p.Value.FileTime, FileTime ) then
    begin
      Result := True;
      IsDeleted := True;
      EditionNum := MyFilePath.getDeletedEdition(p.Value.FileName);
      Break;
    end;

  ScanFileHash.Free;
end;

procedure TBackupLogStartHandle.ReadItemInfo;
begin
  IsEncryted := BackupItemInfoReadUtil.ReadIsEncrypted( DesItemID, SourcePath );
  if IsEncryted then
  begin
    Password := BackupItemInfoReadUtil.ReadPassword( DesItemID, SourcePath );
    PasswordExt := MyEncrypt.getPasswordExt( Password );
  end;
end;

procedure TBackupLogStartHandle.ReadLog;
begin
  IsExist := ReadIsNomal;
  if not IsExist then
    IsExist := ReadIsDeleted;
end;

procedure TBackupLogStartHandle.SetLogPathInfo(_LogPathInfo: TLogPathInfo);
begin
  LogPathInfo := _LogPathInfo;
  DesItemID := LogPathInfo.DesItemID;
  SourcePath := LogPathInfo.SourcePath;
  FilePath := LogPathInfo.FilePath;
  FileTime := LogPathInfo.FileTime;
end;

procedure TBackupLogStartHandle.Update;
begin
  BackupLogAppApi.StartLoading;

    // ��ȡ Item ��Ϣ
  ReadItemInfo;

    // ��ȡ �ļ���Ϣ
  ReadLog;

    // �����ļ���Ϣ
  if IsExist then
    HandleLog
  else
    LogFileNotExist; // �ļ�������

  BackupLogAppApi.StopLoading;
end;

{ TLocalPreviewLogHandle }

procedure TLocalLogHandle.ReadDeletedFileHash;
var
  RecycledFilePath : string;
  LocalFileDeletedListFindHandle : TLocalFileDeletedListFindHandle;
begin
  RecycledFilePath := MyFilePath.getLocalRecyclePath( DesItemID, FilePath );

  LocalFileDeletedListFindHandle := TLocalFileDeletedListFindHandle.Create( RecycledFilePath );
  LocalFileDeletedListFindHandle.SetScanFileHash( ScanFileHash );
  LocalFileDeletedListFindHandle.Update;
  LocalFileDeletedListFindHandle.Free;
end;

function TLocalLogHandle.ReadIsNomal: Boolean;
var
  DesFilePath : string;
begin
  Result := False;

    // Ŀ��·��
  DesFilePath := MyFilePath.getLocalBackupPath( DesItemID, FilePath );
  if IsEncryted then
    DesFilePath := MyFilePath.getEncryptName( DesFilePath, PasswordExt );

    // �Ƿ����
  if FileExists( DesFilePath ) then
    Result := MyDatetime.Equals( FileTime, MyFileInfo.getFileLastWriteTime( DesFilePath ) );
end;

{ TLocalPreviewLogHandle }

procedure TLocalPreviewLogHandle.HandleLog;
var
  Params : TRestorePreviewParams;
begin
  Params.RestorePath := FilePath;
  Params.OwnerID := PcInfo.PcID;
  Params.RestoreFrom := DesItemID;
  Params.IsDeleted := IsDeleted;
  Params.EditionNum := EditionNum;
  Params.IsEncrypted := IsEncryted;
  Params.Password := Password;
  Params.PasswordExt := PasswordExt;
  RestorePreviewUserApi.PreviewLocal( Params )
end;

{ TNetworkPreviewLogHandle }

procedure TNetworkLogHandle.ReadDeletedFileHash;
var
  NetworkFileDeletedListFindHandle : TNetworkFileDeletedListFindHandle;
begin
  NetworkFileDeletedListFindHandle := TNetworkFileDeletedListFindHandle.Create( FilePath );
  NetworkFileDeletedListFindHandle.SetScanFileHash( ScanFileHash );
  NetworkFileDeletedListFindHandle.SetTcpSocket( TcpSocket );
  NetworkFileDeletedListFindHandle.Update;
  NetworkFileDeletedListFindHandle.Free;
end;

function TNetworkLogHandle.ReadIsNomal: Boolean;
var
  NetworkFileFindHandle : TNetworkFileFindHandle;
  PreviewPath : string;
begin
  Result := False;

  PreviewPath := FilePath;
  if IsEncryted then
    PreviewPath := MyFilePath.getEncryptName( PreviewPath, PasswordExt );

  NetworkFileFindHandle := TNetworkFileFindHandle.Create;
  NetworkFileFindHandle.SetFilePath( PreviewPath );
  NetworkFileFindHandle.SetIsDeleted( False );
  NetworkFileFindHandle.SetTcpSocket( TcpSocket );
  NetworkFileFindHandle.Update;
  if NetworkFileFindHandle.getIsExist then
    Result := MyDatetime.Equals( FileTime, NetworkFileFindHandle.getFileTime );
  NetworkFileFindHandle.Free;
end;

procedure TNetworkLogHandle.Update;
var
  CloudConnResult : string;
  IsSuccessConn : Boolean;
begin
    // ����һ������
  TcpSocket := MyBackupFileConnectHandler.getBackupPcConn( DesItemID, SourcePath, BackupConn_Log );
  if not Assigned( TcpSocket ) then  // ��ȡ����ʧ��
    Exit;

    // ��ȡ���ʽ��
  CloudConnResult := MySocketUtil.RevData( TcpSocket );

    // �Ƿ����ӳɹ�
  IsSuccessConn := CloudConnResult = CloudConnResult_OK;

    // ���ʳɹ�
  if IsSuccessConn then
    inherited;

    // ���������б�
  MyBackupFileConnectHandler.AddLastConn( DesItemID, TcpSocket );
end;

{ TNetworkPreviewLogHandle }

procedure TNetworkPreviewLogHandle.HandleLog;
var
  Params : TRestorePreviewParams;
begin
  Params.RestorePath := FilePath;
  Params.OwnerID := PcInfo.PcID;
  Params.RestoreFrom := DesItemID;
  Params.IsDeleted := IsDeleted;
  Params.EditionNum := EditionNum;
  Params.IsEncrypted := IsEncryted;
  Params.Password := Password;
  Params.PasswordExt := PasswordExt;
  RestorePreviewUserApi.PreviewNetwork( Params );
end;

{ TLocalRestoreLogHandle }

procedure TLocalRestoreLogHandle.HandleLog;
var
  Params : TRestoreDownAddParams;
begin
  BackupLogAppApi.StartRestore;

  Params.RestorePath := FilePath;
  Params.OwnerPcID := PcInfo.PcID;
  Params.RestoreFrom := DesItemID;
  Params.OwnerName := PcInfo.PcName;
  Params.IsFile := True;
  Params.IsDeleted := IsDeleted;
  Params.EditionNum := EditionNum;
  Params.IsEncrypt := IsEncryted;
  Params.Password := Password;
  Params.FileCount := -1;
  Params.FileSize := 0;
  Params.SavePath := FilePath;
  RestoreDownUserApi.AddLocalItem( Params );
end;

{ TNetworkRestoreLogHandle }

procedure TNetworkRestoreLogHandle.HandleLog;
var
  Params : TRestoreDownAddParams;
begin
  BackupLogAppApi.StartRestore;

  Params.RestorePath := FilePath;
  Params.OwnerPcID := PcInfo.PcID;
  Params.RestoreFrom := DesItemID;
  Params.OwnerName := PcInfo.PcName;
  Params.IsFile := True;
  Params.IsDeleted := IsDeleted;
  Params.EditionNum := EditionNum;
  Params.IsEncrypt := IsEncryted;
  Params.Password := Password;
  Params.FileCount := -1;
  Params.FileSize := 0;
  Params.SavePath := FilePath;
  RestoreDownUserApi.AddNetworkItem( Params );
end;

{ TBackupCountInfo }

procedure TBackupSpaceInfo.AddFileCount(NewFileCount: Integer);
begin
  FileCount := FileCount + NewFileCount;
end;

procedure TBackupSpaceInfo.AddFileSize(NewFileSize: Int64);
begin
  FileSize := FileSize + NewFileSize;
end;

constructor TBackupSpaceInfo.Create(_TypeName: string);
begin
  TypeName := _TypeName;
  FileCount := 0;
  FileSize := 0;
end;

{ TBackupAnalyzer }

procedure TBackupAnalyzer.AddSpace(TypeName: string; FileSize : Int64);
var
  i: Integer;
  IsFind : Boolean;
  BackupSpaceInfo : TBackupSpaceInfo;
begin
    // �Ƿ��Ѵ���
  IsFind := False;
  for i := 0 to BackupSpaceList.Count - 1 do
    if BackupSpaceList[i].TypeName = TypeName then
    begin
      IsFind := True;
      BackupSpaceInfo := BackupSpaceList[i];
      Break;
    end;

    // �������򴴽�
  if not IsFind then
  begin
    BackupSpaceInfo := TBackupSpaceInfo.Create( TypeName );
    BackupSpaceList.Add( BackupSpaceInfo );
  end;

    // ���ͳ��
  BackupSpaceInfo.AddFileCount( 1 );
  BackupSpaceInfo.AddFileSize( FileSize );
end;

constructor TBackupAnalyzer.Create;
begin
  BackupSpaceList := TBackupSpaceList.Create;
end;

destructor TBackupAnalyzer.Destroy;
begin
  BackupSpaceList.Free;
  inherited;
end;

{ TAnalyzeReadHandle }

constructor TAnalyzeReadHandle.Create(_SourceFileHash: TScanFileHash);
begin
  SourceFileHash := _SourceFileHash;
end;

procedure TAnalyzeReadHandle.SetAnalyzer(_BackupAnalyzer: TBackupAnalyzer);
begin
  BackupAnalyzer := _BackupAnalyzer;
end;

procedure TAnalyzeReadHandle.Update;
var
  p : TScanFilePair;
  ExtStr : string;
begin
  for p in SourceFileHash do
  begin
    ExtStr := ExtractFileExt( p.Value.FileName );
    BackupAnalyzer.AddSpace( ExtStr, p.Value.FileSize );
  end;
end;

{ TAnalyzeResetHandle }

constructor TAnalyzeResetHandle.Create(_BackupAnalyzer: TBackupAnalyzer);
begin
  BackupAnalyzer := _BackupAnalyzer;
end;

procedure TAnalyzeResetHandle.ResetBackupCountInfo;
var
  i, j: Integer;
  BackupSpaceList : TBackupSpaceList;
  TempSpaceInfo : TBackupSpaceInfo;
  ReadCount : Integer;
begin
    // �ļ�������
  BackupSpaceList := BackupAnalyzer.BackupSpaceList;
  BackupSpaceList.OwnsObjects := False;
  for i := 0 to BackupSpaceList.Count - 2 do
    for j := 0 to BackupSpaceList.Count - i - 2 do
      if BackupSpaceList[j].FileCount < BackupSpaceList[j+1].FileCount then
      begin
        TempSpaceInfo := BackupSpaceList[j];
        BackupSpaceList[j] := BackupSpaceList[j+1];
        BackupSpaceList[j+1] := TempSpaceInfo;
      end;
  BackupSpaceList.OwnsObjects := True;

    // ֻд��ǰ����
  ReadCount := Min( 3, BackupSpaceList.Count );
  for i := 0 to ReadCount - 1 do
    MaxBackupPathApi.AddCount( BackupPath, BackupSpaceList[i].TypeName, BackupSpaceList[i].FileCount );
end;

procedure TAnalyzeResetHandle.ResetBackupSizeInfo;
var
  i, j: Integer;
  BackupSpaceList : TBackupSpaceList;
  TempSpaceInfo : TBackupSpaceInfo;
  ReadCount : Integer;
begin
    // �ļ�������
  BackupSpaceList := BackupAnalyzer.BackupSpaceList;
  BackupSpaceList.OwnsObjects := False;
  for i := 0 to BackupSpaceList.Count - 2 do
    for j := 0 to BackupSpaceList.Count - i - 2 do
      if BackupSpaceList[j].FileSize < BackupSpaceList[j+1].FileSize then
      begin
        TempSpaceInfo := BackupSpaceList[j];
        BackupSpaceList[j] := BackupSpaceList[j+1];
        BackupSpaceList[j+1] := TempSpaceInfo;
      end;
  BackupSpaceList.OwnsObjects := True;

    // ֻд��ǰ����
  ReadCount := Min( 3, BackupSpaceList.Count );
  for i := 0 to ReadCount - 1 do
    MaxBackupPathApi.AddSize( BackupPath, BackupSpaceList[i].TypeName, BackupSpaceList[i].FileSize );
end;


procedure TAnalyzeResetHandle.SetBackupPath(_BackupPath: string);
begin
  BackupPath := _BackupPath;
end;

procedure TAnalyzeResetHandle.Update;
begin
    // ˢ��·����Ϣ
  MaxBackupPathApi.RemovePath( BackupPath );
  MaxBackupPathApi.AddPath( BackupPath );

    // ����ļ�����Ϣ
  ResetBackupCountInfo;

    // ����ļ��ռ���Ϣ
  ResetBackupSizeInfo;
end;

{ TNetworkBackupParamsData }

procedure TNetworkBackupParamsData.CheckHeartBeat;
begin
  HeartBeatReceiver.CheckSend( TcpSocket, HeartBeatTime );
end;

end.

