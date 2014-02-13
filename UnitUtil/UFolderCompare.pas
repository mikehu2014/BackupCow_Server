unit UFolderCompare;

interface

uses Generics.Collections, dateUtils, SysUtils, Winapi.Windows, UMyUtil, UModelUtil, UMyTcp, sockets,
     Classes, Math, winapi.winsock, StrUtils, LbCipher,LbProc, uDebug, uDebugLock, Zip, syncobjs, zlib,
     UFileBaseInfo;

type

{$Region ' �ļ��Ƚ� ' }

     // �������ļ���Ϣ
  TScanFileInfo = class
  public
    FileName : string;
    FileSize : Int64;
    FileTime : TDateTime;
  public
    constructor Create( _FileName : string );
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
  public
    function getEquals( ScanFileInfo : TScanFileInfo ): Boolean;
  end;
  TScanFilePair = TPair< string , TScanFileInfo >;
  TScanFileHash = class( TStringDictionary< TScanFileInfo > );

  TScanFolderHash = class;

      // ����Ŀ¼����Ϣ
  TScanFolderInfo = class
  public
    FolderName : string;
    ScanFileHash : TScanFileHash;
    ScanFolderHash : TScanFolderHash;
  public
    IsReaded : Boolean;
  public
    constructor Create( _FolderName : string );
    destructor Destroy; override;
  end;
  TScanFolderPair = TPair< string , TScanFolderInfo >;
  TScanFolderHash = class( TStringDictionary< TScanFolderInfo > );

      // ��Ϣ ������
  ScanFileInfoUtil = class
  public
    class procedure CopyFile( OldFileHash, NewFileHash : TScanFileHash );
    class procedure CopyFolder( OldFOlderHash, NewFolderHash : TScanFolderHash );
  end;

      // ȡ����ȡ��
  TCancelReader = class
  public
    function getIsRun : Boolean;virtual;abstract;
  end;


  {$Region ' ɨ��Ŀ¼ �����Ϣ ' }

    // �ļ��ȽϽ��
  TScanResultInfo = class
  public
    SourceFilePath : string;
  public
    constructor Create( _SourceFilePath : string );
  end;
  TScanResultList = class( TObjectList<TScanResultInfo> );


    // ��� �ļ�
  TScanResultAddFileInfo = class( TScanResultInfo )
  public
    FileSize : Int64;
    FileTime : TDateTime;
  public
    procedure SetFileSize( _FileSize : Int64; _FileTime : TDateTime );
  end;

    // ��� Ŀ¼
  TScanResultAddFolderInfo = class( TScanResultInfo )
  end;

    // ɾ�� �ļ�
  TScanResultRemoveFileInfo = class( TScanResultInfo )
  end;

    // ɾ�� Ŀ¼
  TScanResultRemoveFolderInfo = class( TScanResultInfo )
  end;

      // ��� ѹ���ļ�
  TScanResultAddZipInfo = class( TScanResultInfo )
  public
    ZipStream : TMemoryStream;
    TotalSize : Int64;
  public
    procedure SetZipStream( _ZipStream : TMemoryStream );
    procedure SetTotalSize( _TotalSize : Int64 );
  end;

    // ��ȡ ѹ���ļ�
  TScanResultGetZipInfo = class( TScanResultInfo )
  public
    TotalSize : Int64;
  public
    procedure SetTotalSize( _TotalSize : Int64 );
  end;

  {$EndRegion}

  {$Region ' ɨ��Ŀ¼ �㷨 ' }

  {$Region ' ɨ�踸�� ' }

     // ����Ŀ¼ ����
  TFolderFindBaseHandle = class
  public
    FolderPath : string;
    ScanFileHash : TScanFileHash;
    ScanFolderHash : TScanFolderHash;
  public
    procedure SetFolderPath( _FolderPath : string );
  end;

    // ���� ����Ŀ¼
  TFolderFindHandle = class( TFolderFindBaseHandle )
  public
    procedure SetScanFile( _ScanFileHash : TScanFileHash );
    procedure SetScanFolder( _ScanFolderHash : TScanFolderHash );
  protected      // ������
    function IsFileFilter( FilePath : string; sch : TSearchRec ): Boolean;virtual;
    function IsFolderFilter( FolderPath : string ): Boolean;virtual;
  end;

    // ���� ����Ŀ¼
  TFolderAccessFindHandle = class( TFolderFindBaseHandle )
  public
    constructor Create;
    destructor Destroy; override;
  end;

  {$EndRegion}

  {$Region ' ����ɨ�� ' }

    // ���� ����Ŀ¼
  TLocalFolderFindHandle = class( TFolderFindHandle )
  public
    SleepCount : Integer;
    DeepCount, DeepMax : Integer;
  public
    constructor Create;
    procedure SetSleepCount( _SleepCount : Integer );
    procedure SetDeepInfo( _DeepCount, _DeepMax : Integer );
    procedure Update;
  private
    procedure SearchLocalFolder;
    procedure SearchChildFolder;
  private
    procedure CheckSleep;virtual;
  protected
    function CreateFolderFindHandle : TLocalFolderFindHandle;virtual;
  end;

    // ���� ����Ŀ¼ ����
  TLocalFolderFilterFindHandle = class( TLocalFolderFindHandle )
  public
    IsEncrypted : Boolean;
    PasswordExt : string;
  public
    IsEdition : Boolean;
    FileEditionHash : TFileEditionHash;
  public
    constructor Create;
    procedure SetEncryptedInfo( _IsEncrypted : Boolean; _PasswordExt : string );
    procedure SetEditionInfo( _IsEdition : Boolean; _FileEditionHash : TFileEditionHash );
  protected      // ������
    function IsFileFilter( FilePath : string; sch : TSearchRec ): Boolean;override;
  protected
    function CreateFolderFindHandle : TLocalFolderFindHandle;override;
  end;

  {$EndRegion}

  {$Region ' ����ɨ�� ���� ' }

      // ������������
  THeatBeatHelper = class
  public
    TcpSocket : TCustomIpClient;
    StartTime : TDateTime;
  public
    constructor Create( _TcpSocket : TCustomIpClient );
    procedure CheckHeartBeat;
  end;

    // ����������
  HeartBeatReceiver = class
  public
    class function CheckReceive( TcpSocket : TCustomIpClient ): string;
    class procedure CheckSend( TcpSocket : TCustomIpClient; var StartTime : TDateTime );
  end;

    // ��������
  TLocalFolderFindAdvanceHandle = class( TLocalFolderFindHandle )
  private
    HeatBeatHelper : THeatBeatHelper;
  public
    procedure SetHeatBeatHelper( _HeatBeatHelper : THeatBeatHelper );
  private
    procedure CheckSleep;override;
  end;

    // ��������
  TLocalFolderFilterFindAdvanceHandle = class( TLocalFolderFilterFindHandle )
  private
    HeatBeatHelper : THeatBeatHelper;
  public
    procedure SetHeatBeatHelper( _HeatBeatHelper : THeatBeatHelper );
  protected
    procedure CheckSleep;override;
    function CreateFolderFindHandle : TLocalFolderFindHandle;override;
  end;

  {$EndRegion}

  {$Region ' ����ɨ�� ' }

    // ����ɨ�� ����Ŀ¼
  TNetworkFolderFindHandle = class( TFolderFindHandle )
  protected
    TcpSocket : TCustomIpClient;
  protected   // �ļ�����
    IsDeep : Boolean;
    IsDeleted : Boolean;
  protected   // ������Ϣ
    IsFilter : Boolean;
    IsEncrypted : Boolean;
    PasswordExt : string;
    IsEdition : Boolean;
  public
    constructor Create;
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure SetIsDeep( _IsDeep : Boolean );
    procedure SetIsDeleted( _IsDeleted : Boolean );
    procedure SetIsFilter( _IsFilter : Boolean );
    procedure SetEnctyptedInfo( _IsEncrypted : Boolean; _PasswordExt : string );
    procedure SetEditionInfo( _IsEdition : Boolean );
    procedure Update;
  end;

    // �������� ����Ŀ¼
  TNetworkFolderAccessFindHandle = class
  protected   // Ŀ¼��Ϣ
    TcpSocket : TCustomIpClient;
    FolderPath : string;
    IsDeep, IsFilter : Boolean;
    FileEditionHash : TFileEditionHash;
  protected
    ScanFileHash : TScanFileHash;
    ScanFolderHash : TScanFolderHash;
  public
    constructor Create( _FolderPath : string );
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure SetIsDeep( _IsDeep : Boolean );
    procedure SetIsFilter( _IsFilter : Boolean );
    procedure SetFileEditionHash( _FileEditionHash : TFileEditionHash );
    procedure Update;
    destructor Destroy; override;
  private
    procedure SearchFolderInfo; // ������Ϣ
    procedure SearchFilterFolderInfo; // ����������Ϣ
    procedure SendFolderInfo;  // ���ͽ����Ϣ
  end;

  {$EndRegion}

  {$Region ' ����ɨ����Ϣ���� ' }

    // ��ȡ �ļ���ȡ��Ϣ
  TFindNetworkFileResultHandle = class
  public
    FileStr : string;
    ScanFileHash : TScanFileHash;
  public
    constructor Create( _FileStr : string );
    procedure SetScanFile( _ScanFileHash : TScanFileHash );
    procedure Update;
  private
    procedure ReadFileInfo( FileInfoStr : string );
  end;

    // ��ȡ Ŀ¼��ȡ��Ϣ
  TFindNetworkFolderResultHandle = class
  public
    FolderStr : string;
    ScanFolderHash : TScanFolderHash;
    FolderLevel : Integer;
  public
    constructor Create( _FolderStr : string );
    procedure SetScanFolder( _ScanFolderHash : TScanFolderHash );
    procedure SetFolderLevel( _FolderLevel : Integer );
    procedure Update;
  private
    procedure ReadFolderInfo( FolderInfoStr : string );
  end;

      // ��ȡ ����Ŀ¼��ȡ��Ϣ
  TFindNetworkFullFolderResultHandle = class
  private
    ReadResultStr : string;
    ScanFileHash : TScanFileHash;
    ScanFolderHash : TScanFolderHash;
  private
    FolderStr, FileStr : string;
  public
    constructor Create( _ReadResultStr : string );
    procedure SetScanFile( _ScanFileHash : TScanFileHash );
    procedure SetScanFolder( _ScanFolderHash : TScanFolderHash );
    procedure Update;
  private
    procedure ReadFolder;
    procedure ReadFile;
  end;


    // ���� �ļ��б� �ַ���
  TGetNetworkFileResultStrHandle = class
  public
    ScanFileHash : TScanFileHash;
  public
    constructor Create( _ScanFileHash : TScanFileHash );
    function get : string;
  end;

        // ���� Ŀ¼�б� �ַ���
  TGetNetworkFolderResultStrHandle = class
  public
    ScanFolderHash : TScanFolderHash;
    FolderLevel : Integer;
  public
    constructor Create( _ScanFolderHash : TScanFolderHash );
    procedure SetFolderLevel( _FolderLevel : Integer );
    function get : string;
  private
    function getChildFileStr( FolderName : string ) : string;
    function getChildFolderStr( FolderName : string ) : string;
  end;

    // ���� ����Ŀ¼ �ַ���
  TGetNetworkFullFolderResultStrHandle = class
  public
    ScanFileHash : TScanFileHash;
    ScanFolderHash : TScanFolderHash;
  public
    procedure SetFileHash( _ScanFileHash : TScanFileHash );
    procedure SetFolderHash( _ScanFolderHash : TScanFolderHash );
    function get : string;
  private
    function getFolderStr : string;
    function getFileStr : string;
  end;

  {$EndRegion}

  {$EndRegion}

  {$Region ' ɨ���ļ� �㷨 ' }

    // �����ļ���Ϣ
  TFileFindHandle = class
  public
    FilePath : string;
  protected
    IsExist : Boolean;
    FileSize : Int64;
    FileTime : TDateTime;
  public
    procedure SetFilePath( _FilePath : string );
  public
    function getIsExist : Boolean;
    function getFileSize : Int64;
    function getFileTime : TDateTime;
  end;

    // ���� �����ļ�
  TLocalFileFindHandle = class( TFileFindHandle )
  public
    procedure Update;
  end;

    // ���� �����ļ� ����
  TNetworkFileFindHandle = class( TFileFindHandle )
  protected
    TcpSocket : TCustomIpClient;
    IsDeleted : Boolean;
  public
    constructor Create;
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure SetIsDeleted( _IsDeleted : Boolean );
    procedure Update;
  end;

    // �������� �����ļ�
  TNetworkFileAccessFindHandle = class
  protected
    FilePath : string;
    TcpSocket : TCustomIpClient;
  public
    constructor Create( _FilePath : string );
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' ɨ��ɾ���ļ� �㷨 ' }

    // ����
  TFileDeletedListFindHandle = class
  public
    FilePath : string;
    ScanFileHash : TScanFileHash;
  public
    constructor Create( _FilePath : string );
    procedure SetScanFileHash( _ScanFileHash : TScanFileHash );
  end;

    // �������� ����
  TLocalFileDeletedListFindHandle = class( TFileDeletedListFindHandle )
  public
    procedure Update;
  end;

    // �������� ����
  TNetworkFileDeletedListFindHandle = class( TFileDeletedListFindHandle )
  public
    TcpSocket : TCustomIpClient;
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure Update;
  end;

    // ��������
  TNetworkFileDeletedListAccessFindHandle = class
  protected
    FilePath : string;
    TcpSocket : TCustomIpClient;
  private
    ScanFileHash : TScanFileHash;
  public
    constructor Create( _FilePath : string );
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure Update;
    destructor Destroy; override;
  private
    procedure FindDeletedFileList;
    procedure SendDeletedFileList;
  end;

  {$EndRegion}


    // Ŀ¼�Ƚ��㷨
  TFolderCompareHandler = class
  public
    SourceFolderPath : string;
    SleepCount : Integer;
    ScanTime : TDateTime;
  public   // �ļ���Ϣ
    SourceFileHash : TScanFileHash;
    DesFileHash : TScanFileHash;
  public   // Ŀ¼��Ϣ
    SourceFolderHash : TScanFolderHash;
    DesFolderHash : TScanFolderHash;
  public   // �ռ���
    FileCount : Integer;
    FileSize, CompletedSize : Int64;
  public   // �ļ��仯���
    ScanResultList : TScanResultList;
  public   // �Ƿ�ɾ��Ŀ������ļ�
    IsSupportDeleted : Boolean;
    IsDesEmpty, IsDesReaded : Boolean;  // Ŀ��Ŀ¼�Ƿ�Ϊ��
  public
    constructor Create;
    procedure SetSourceFolderPath( _SourceFolderPath : string );
    procedure SetResultList( _ScanResultList : TScanResultList );
    procedure SetIsSupportDeleted( _IsSupportDeleted : Boolean );
    procedure SetIsDesEmpty( _IsDesEmpty : Boolean );
    procedure SetIsDesReaded( _IsDesReaded : Boolean );
    procedure Update;virtual;
    destructor Destroy; override;
  protected
    procedure FindSourceFileInfo;virtual;abstract;
    procedure FindDesFileInfo;virtual;abstract;
    procedure FileCompare;
    procedure FolderCompare;
  protected      // �Ƿ� ֹͣɨ��
    function CheckNextScan : Boolean;virtual;
    procedure DesFolderEmptyHandle; virtual; // Ŀ��Ŀ¼Ϊ��
  private        // �ȽϽ��
    function getChildPath( ChildName : string ): string;
    procedure AddFileResult( FileInfo : TScanFileInfo );
    procedure AddFolderResult( FolderName : string );
    procedure RemoveFileResult( FileName : string );
    procedure RemoveFolderResult( FolderName : string );
  protected        // �Ƚ���Ŀ¼
    function getDesFileName( SourceFileName : string ): string;virtual;
    function getScanHandle( SourceFolderName : string ) : TFolderCompareHandler;virtual;abstract;
    procedure CompareChildFolder( SourceFolderName : string );
  end;

    // �ļ��Ƚ��㷨
  TFileCompareHandler = class
  public
    SourceFilePath : string;
  public
    SourceFileSize : Int64;
    SourceFileTime : TDateTime;
  public
    DesFileSize : Int64;
    DesFileTime : TDateTime;
  public   // �ռ���
    CompletedSize : Int64;
  public   // �ļ��仯���
    ScanResultList : TScanResultList;
  public
    procedure SetSourceFilePath( _SourceFilePath : string );
    procedure SetResultList( _ScanResultList : TScanResultList );
    procedure Update;virtual;
  protected     // �ļ���·����Ϣ
    function FindSourceFileInfo: Boolean;virtual;abstract;
    function FindDesFileInfo: Boolean;virtual;abstract;
    function getAddFilePath : string;virtual;abstract;
    function getRemoveFilePath : string;virtual;abstract;
  private        // �ȽϽ��
    function IsEqualsDes : Boolean;
    procedure AddFileResult;
    procedure RemoveFileResult;
  end;

{$EndRegion}

{$Region ' �ļ����� ' }

  TDataBuf = array[0..524287] of Byte; // 512 KB, ���̶�д��λ
  TSendBuf = array[0..1023] of Byte;  // 1 KB, ���紫�䵥λ


    // �����ļ�������
  SendFileUtil = class
  public             // ѹ��, ��ѹ
    class procedure CompressStream( SourceStream, ComStream : TMemoryStream );
    class procedure DecompressStream( ComStream, DesStream : TMemoryStream );
  public              // ���ܡ�����
    class procedure Encrypt( var Buf : TDataBuf; BufSize : Integer; Password : string );
    class procedure Deccrypt( var Buf : TDataBuf; BufSize : Integer; Password : string );
  private
    class procedure EncryptData( var Buf : TSendBuf; BufSize : Integer; Key : string; IsEncrypt : Boolean );
  end;

    // ��ʱ��
  TSpeedReader = class
  private
    SpeedTime : TDateTime;
    Speed, LastSpeed : Int64;
  private
    IsLimited : Boolean;
    LimitSpeed : Int64;
  private
    SpeedLock : TCriticalSection;
  public
    constructor Create;
    procedure SetLimitInfo( _IsLimited : Boolean; _LimitSpeed : Int64 );
    destructor Destroy; override;
  public       // �ٶ�ͳ��
    function AddCompleted( CompletedSpace : Integer ): Boolean;
    function ReadLastSpeed : Int64;
  public       // �ٶ�����
    function ReadIsLimited : Boolean;
    function ReadAvailableSpeed : Int64;
  end;

  {$Region ' �����ļ� ' }

    // �����ļ�������
  CopyFileUtil = class
  public               // ���ܽ���
    class procedure Encrypt( var Buf : TDataBuf; BufSize : Integer; Password : string );
    class procedure Deccrypt( var Buf : TDataBuf; BufSize : Integer; Password : string );
    class function DecryptStream( Stream : TMemoryStream; Password : string ): TMemoryStream;
  private
    class procedure EncryptData( var Buf : TDataBuf; BufSize : Integer; Key : string; IsEncrypt : Boolean );
  end;

  TCopyFileHandle = class;

    // �ļ����ƾ������
  TCopyFileOperator = class
  private
    CopyFileHandle : TCopyFileHandle;
  public
    procedure SetCopyFileHandle( _CopyFileHandle : TCopyFileHandle );
  public
    function ReadIsNextCopy : Boolean;virtual; // ����Ƿ��������
    procedure AddSpeedSpace( SendSize : Integer );virtual;
    procedure RefreshCompletedSpace;virtual; // ˢ������ɿռ�
  public
    procedure MarkContinusCopy;virtual; // ����ʱ����
    procedure DesWriteSpaceLack;virtual; // �ռ䲻��
    procedure ReadFileError;virtual;  // ���ļ�����
    procedure WriteFileError;virtual; // д�ļ�����
  protected       // ��ȡ�����ļ�����Ϣ
    function ReadLastCompletedSize : Int64;
    function ReadFilePath : string;
    function ReadFileSize : Int64;
    function ReadFilePos : Int64;
    function ReadFileTime : TDateTime;
  end;

    // ����ˢ����
  TRefreshCopyReader = class
  public
    SleepCount : Integer;
  public
    LastRefreshTime : TDateTime; // ��һ��ˢ��ʱ��
    LastCompletedSize : Int64;  // ����ɿռ�
  public
    constructor Create;
    function ReadIsRefresh : Boolean;
    procedure AddCompletedSize( CompletedSize : Int64 );
    function ReadLastCompletedSize : Int64;
  end;

    // �����ļ� ����
  TCopyFileHandle = class
  private
    SourceFilePath, DesFilePath : string;
    FileSize, FilePos : Int64;
    FileTime : TDateTime;
  private
    IsEncrypt, IsDecrypt : Boolean;
    EncPassword, DecPassword : string;
  private
    RefreshCopyReader : TRefreshCopyReader;
    CopyFileOperator : TCopyFileOperator;
  private
    ReadStream : TFileStream;  // ������
    WriteStream : TFileStream; // д����
    BufStream : TMemoryStream; // �ڴ���
  public
    constructor Create;
    procedure SetPathInfo( _SourFilePath, _DesFilePath : string );
    procedure SetPosition( _Position : Int64 );
    procedure SetEncryptInfo( _IsEncrypt : Boolean; _EncPassword : string );
    procedure SetDecryptInfo( _IsDecrypt : Boolean; _DecPassword : string );
    procedure SetCopyFileOperator( _CopyFileOperator : TCopyFileOperator );
    function Update: Boolean;
    destructor Destroy; override;
  private
    function ReadIsEnoughSpace : Boolean;  // ����Ƿ����㹻�Ŀռ�
    function ReadIsCreateReadStream : Boolean;  // ����������
    function ReadIsCreateWriteStream : Boolean;  // ����д����
    function FileCopyHandle: Boolean;  // ������
    function ReadBufStream : Integer;  // ��ȡ��
    function WriteBufStream : Integer; // д����
    procedure DestoryStream; // �ر���
  end;

  {$EndRegion}

  {$Region ' ��ѹ�ļ� ' }

  TFileUnpackHandle = class;

    // ��ѹ�ļ�����
  TFileUnpackOperator = class
  private
    FileUnpackHandle : TFileUnpackHandle;
  public
    procedure SetFileUnpackHandle( _FileUnpackHandle : TFileUnpackHandle );
  public
    function ReadIsNextCopy : Boolean;virtual; // ����Ƿ������ѹ
    procedure AddSpeedSpace( SendSize : Integer );virtual;
    procedure RefreshCompletedSpace;virtual; // ˢ������ɿռ�
  protected
    function ReadLastComletedSize : Int64; // ��ȡ����ɿռ���Ϣ
  end;

    // ѹ���ļ���ѹ
  TFileUnpackHandle = class
  private
    ZipStream : TMemoryStream;
    SavePath : string;
  private
    RefreshCopyReader : TRefreshCopyReader;
    FileUnpackOperator : TFileUnpackOperator;
  public
    constructor Create( _ZipStream : TMemoryStream );
    procedure SetFileUnpackOperator( _FileUnpackOperator : TFileUnpackOperator );
    procedure SetSavePath( _SavePath : string );
    function Update: Boolean;
    destructor Destroy; override;  // ���ؽ�ѹ�ռ�
  end;


  {$EndRegion}

  {$Region ' �����ļ� ' }


  TNetworkSendBaseHandle = class;

    // �����ļ�������
  TSendFileOperator = class
  private
    NetworkSendBaseHandle : TNetworkSendBaseHandle;
  public
    procedure SetNetworkSendBaseHandle( _NetworkSendBaseHandle : TNetworkSendBaseHandle );
  public
    function ReadIsNextSend: Boolean;virtual;
    function ReadIsLimitSpeed : Boolean;virtual;
    function ReadLimitSpeed: Int64;virtual;
    procedure AddSpeedSpace( SendSize : Integer );virtual;
    procedure RefreshCompletedSpace;virtual;
  public
    procedure RevFileLackSpaceHandle;virtual; // ȱ�ٿռ�Ĵ���
    procedure MarkContinusSend;virtual; // ����ʱ����
    procedure ReadFileError;virtual;  // ���ļ�����
    procedure WriteFileError;virtual; // д�ļ�����
    procedure LostConnectError;virtual; //�Ͽ����ӳ���
    procedure TransferFileError;virtual; // �����ļ�����
  protected      // ��ȡ��Ϣ
    function ReadLastCompletedSize : Int64;
    function ReadFilePath : string;
    function ReadFileSize : Int64;
    function ReadFilePos : Int64;
    function ReadFileTime : TDateTime;
  end;

    // �������շ�״̬�߳�
  TWatchRevThread = class( TDebugThread )
  public
    TcpSocket : TCustomIpClient;
    SendFileOperator : TSendFileOperator;
  public
    IsRevStop, IsRevLostConn, IsRevCompleted : Boolean;
    RevSpeed : Int64;
  public
    constructor Create;
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure SetSendFileOperator( _SendFileOperator : TSendFileOperator );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  public
    procedure StartWatch;
    procedure StopWatch;
  end;

      // ˢ����
  TRefreshSendReader = class
  public
    LastRefreshTime : TDateTime; // ��һ��ˢ��ʱ��
    LastCompletedSize : Int64;  // ����ɿռ�
  public
    constructor Create;
  public
    function ReadIsRefresh : Boolean;
    procedure AddCompletedSize( CompletedSize : Int64 );
    function ReadLastCompletedSize : Int64;
  end;

    // ���緢�� ����
  TNetworkSendBaseHandle = class
  private
    TcpSocket : TCustomIpClient;
    IsEncrypt : Boolean;
    EncPassword : string;
    IsZip : Boolean;
  private
    ReadStream : TStream;
    ReadStreamSize, ReadStreamPos : Int64;
    BufStream : TMemoryStream;
    TotalSendDataBuf, SendDataBuf : TDataBuf;  // ÿ�η��͵����ݽṹ
  private
    WatchRevThread : TWatchRevThread;
    RefreshSendReader : TRefreshSendReader;
    SendFileOperator : TSendFileOperator;
    IsStopTransfer, IsLostConn : Boolean;
  public
    constructor Create;
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure SetReadStreamPos( _ReadStreamPos : Int64 );
    procedure SetEncryptInfo( _IsEncrypt : Boolean; _EncPassword : string );
    procedure SetIsZip( _IsZip : Boolean );
    procedure SetSendFileOperator( _SendFileOperator : TSendFileOperator );
    function Update: Boolean;
    destructor Destroy; override;
  private
    function ReadIsCreateReadStream: Boolean;  // ����������
    function ReadIsEnoughSpace : Boolean;  // �Ƿ����㹻�Ŀռ�д��
    function ReadIsCreateWriteStrem : Boolean;  // ����д����
    function FileSendHandle: Boolean;    // �����ļ�
    function ReadBufStream: Integer; // ��ȡ����
    function SendBufStream: Boolean;  // ��������
    function RevWriteSize( ReadSize : Integer ) : Boolean; // �Է�д����ٿռ�
  private
    function ReadIsNextSend( IsSuccessSend : Boolean ) : Boolean; // �Ƿ��������
    function ReadIsStopTransfer: Boolean;  // �Ƿ�ֹͣ����
    procedure AddSendedSpace( CompletedSpace : Integer );  // ͳ���ѷ��͵Ŀռ�
    function ReadSendBlockSize : Int64;  // ��ȡÿ�η��͵Ŀռ���Ϣ
  protected
    function CreateReadStream : Boolean; virtual;abstract;
    function ReadSendPath : string;virtual;abstract;
    procedure FileSendIniHandle;virtual;
    function ReadIsZip : Boolean;virtual;
    procedure SendFileIncompleted; virtual;
  end;

    // ���緢�� �ļ�
  TNetworkSendFileHandle = class( TNetworkSendBaseHandle )
  public
    SendFilePath : string;
    SendFileTime : TDateTime;
  public
    procedure SetSendFilePath( _SendFilePath : string );
    destructor Destroy; override;
  protected
    function CreateReadStream : Boolean;override;
    procedure FileSendIniHandle;override;
    function ReadIsZip : Boolean;override;
    function ReadSendPath : string;override;
    procedure SendFileIncompleted;override;
  end;

    // ���緢�� ��
  TNetworkSendStreamHandle = class( TNetworkSendBaseHandle )
  public
    SendStream : TMemoryStream;
  public
    procedure SetSendStream( _SendStream : TMemoryStream );
  protected
    function CreateReadStream : Boolean;override;
    function ReadIsZip : Boolean;override;
    function ReadSendPath : string;override;
  end;

  {$EndRegion}

  {$Region ' �����ļ� ' }

      // ˢ����
  TRefreshRevReader = class
  public
    StartRevTime : TDateTime; // �����������
  public
    LastRefreshTime : TDateTime; // ��һ��ˢ��ʱ��
    LastCompletedSpace : Int64;  // ����ɿռ�
  public
    constructor Create;
    procedure StartRev;
    function StopRev( RevSize : Int64 ) : Int64;
  public
    function ReadIsRefresh : Boolean;
    procedure AddSpace( CompletedSpace : Int64 );
    function ReadCompletedSpace : Int64;
  end;

  TNetworkReceiveBaseHandle = class;

    // �����ļ�������
  TReceiveFileOperator = class
  private
    NetworkReceiveBaseHandle : TNetworkReceiveBaseHandle;
  public
    procedure SetNetworkReceiveBaseHandle( _NetworkReceiveBaseHandle : TNetworkReceiveBaseHandle );
  public
    function ReadIsNextReceive: Boolean;virtual;
    procedure AddSpeedSpace( SendSize : Integer );virtual;
    procedure RefreshCompletedSpace;virtual;
  public
    procedure RevFileLackSpaceHandle;virtual; // ȱ�ٿռ�Ĵ���
    procedure MarkContinusSend;virtual; // ����ʱ����
    procedure ReadFileError;virtual;  // ���ļ�����
    procedure WriteFileError;virtual; // д�ļ�����
    procedure LostConnectError;virtual; //�Ͽ����ӳ���
    procedure TransferFileError;virtual; // �����ļ�����
  protected      // ��ȡ��Ϣ
    function ReadLastCompletedSize : Int64;
    function ReadFileSize : Int64;
    function ReadFilePos : Int64;
    function ReadFileTime : TDateTime;
  end;

    // ������� ����
  TNetworkReceiveBaseHandle = class
  private
    TcpSocket : TCustomIpClient;
    IsDecrypt : Boolean;
    DecPassword : string;
  protected
    WriteStream : TStream;
    WriteStreamSize, WriteStreamPos : Int64;
    BufStream : TMemoryStream;
    SendDataBuf, TotalSendDataBuf : TDataBuf;  // ÿ�η��͵����ݽṹ
    IsZipFile : Boolean;  // �Ƿ�ѹ���ļ�
  private
    RefreshRevReader : TRefreshRevReader;
    RecieveFileOperator : TReceiveFileOperator;
    IsStopTransfer, IsLostConn : Boolean;
  public
    constructor Create;
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure SetRecieveFileOperator( _RecieveFileOperator : TReceiveFileOperator );
    procedure SetDecryptInfo( _IsDecrypt : Boolean; _DecPassword : string );
    function Update: Boolean;
    destructor Destroy; override;
  private
    function ReadIsCreateReadStream: Boolean;  // ����������
    function ReadIsEnoughSpace : Boolean;  // �Ƿ����㹻�Ŀռ�д��
    function ReadIsCreateWriteStrem : Boolean;  // ����д����
    function FileReceiveHandle : Boolean; // �ļ�����
    function ReceiveBufStream( BufSize : Integer ): Boolean; // ��������
    function WriteBufStream: Integer;  // д������
    function SendWriteSize( WriteSize, ReadSize : Integer ): Boolean;  // ����д��Ŀռ�
  private
    function ReadIsNextRev( IsSuccessRev : Boolean ) : Boolean;  // �Ƿ��������
    procedure AddRecvedSize( RevSize : Integer );
    function ReadIsStopTransfer: Boolean;  // �Ƿ�ֹͣ����
    procedure SendRevSpeed( RevSpeed : Int64 ); // ���ͽ����ļ��ٶ�
  protected
    function getIsEnouthSpace : Boolean;virtual;abstract;
    procedure FileRevceiveIniHandle;virtual;
    function CreateWriteStream : Boolean;virtual;abstract;
    function ReadReceivePath : string;virtual;abstract;
    function ReadIsZip : Boolean;virtual;abstract;
    procedure ReceiveFileIncompleted;virtual;
    procedure ReceiveFileCompleted;virtual;
  end;

    // ������� �ļ�
  TNetworkReceiveFileHandle = class( TNetworkReceiveBaseHandle )
  public
    ReceiveFilePath : string;
    ReceiveFileTime : TDateTime;
  public
    procedure SetReceiveFilePath( _ReceiveFilePath : string );
    destructor Destroy; override;
  protected
    function getIsEnouthSpace : Boolean;override;
    function CreateWriteStream : Boolean;override;
    procedure FileRevceiveIniHandle;override;
    function ReadReceivePath : string;override;
    function ReadIsZip : Boolean;override;
    procedure ReceiveFileIncompleted;override;
    procedure ReceiveFileCompleted;override;
  end;

    // ������� ��
  TNetworkReceiveStreamHandle = class( TNetworkReceiveBaseHandle )
  protected
    RevStream : TMemoryStream;
  public
    procedure SetRevStream( _RevStream : TMemoryStream );
  protected
    function getIsEnouthSpace : Boolean;override;
    function CreateWriteStream : Boolean;override;
    function ReadReceivePath : string;override;
    function ReadIsZip : Boolean;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' �ļ����� ' }

  TEditonPathParams = record
  public
    FilePath : string;
    EditionNum : Integer;
  public
    IsEncrypted : Boolean;
    PasswordExt : string;
  end;

    // ������
  FileRecycledUtil = class
  public            // ��ȡ�汾·��
    class function getEditionPath( Params : TEditonPathParams ): string;
  end;

    // Ŀ���ļ� ����
  TFileRecycleHandle = class
  public
    DesFilePath, RecycledFilePath : string;
    SaveDeletedEdition : Integer;
  public
    procedure SetPathInfo( _DesFilePath, _RecycledFilePath : string );
    procedure SetSaveDeletedEdition( _SaveDeletedEdition : Integer );
    procedure Update;
  private
    function getExistRecycleEdition : Integer;
    function getRecycleEditionPath( EditionNum : Integer ): string;
  private
    function getIsExistRecylce : Boolean; // �ļ��Ƿ��Ѿ�����
    procedure ConfirmRecycleEdition;
  private
    function getEquals( FilePath1, FilePath2 : string ): Boolean;
  end;

    // Ŀ��Ŀ¼ ����
  TFolderRecycleHandle = class
  public
    DesFolderPath : string;
    RecycleFolderPath : string;
    KeepEditionCount : Integer;
  public
    procedure SetPathInfo( _DesFolderPath, _RecycleFolderPath : string );
    procedure SetKeepEditionCount( _KeepEditionCount : Integer );
    procedure Update;
  protected
    procedure CreateRecycleFolder;
    procedure SearchFile( FileName : string );
    procedure SearchFolder( FolderName : string );
    procedure RemoveDesFolder;
  end;

{$EndRegion}

{$Region ' �ļ����� ' }

    // �ļ����� ���
  TFolderSearchHandle = class
  private
    FolderPath : string;
    SearchName : string;
    ResultFolderPath : string;
  protected
    IsEncrypted : Boolean;
    PasswordExt : string;
    IsDeleted : Boolean;
  private
    RefreshTime : TDateTime;
    SleepCount : Integer;
  protected
    ResultFileHash : TScanFileHash;
    ResultFolderHash : TScanFolderHash;
  private
    ScanFileHash : TScanFileHash;
    ScanFolderHash : TScanFolderHash;
  public
    constructor Create;
    procedure SetFolderPath( _FolderPath : string );
    procedure SetSerachName( _SearchName : string );
    procedure SetResultFolderPath( _ResultFolderPath : string );
    procedure SetEncryptInfo( _IsEncrypted : Boolean; _PasswordExt : string );
    procedure SetIsDeleted( _IsDeleted : Boolean );
    procedure SetRefreshTime( _RefreshTime : TDateTime );
    procedure SetSleepCount( _SleepCount : Integer );
    procedure SetResultFile( _ResultFileHash : TScanFileHash );
    procedure SetResultFolder( _ResultFolderHash : TScanFolderHash );
    function Update: Boolean;
    procedure LastRefresh;virtual;
    destructor Destroy; override;
  private
    function FindScanHash: Boolean;
    function FindResultHash: Boolean;
    function SearchChildFolder: Boolean;
  protected
    function CheckNextSearch: Boolean;virtual;
    procedure HandleResultHash; virtual;abstract;
    function getIsStop : Boolean; virtual;
    function getFolderSearchHandle : TFolderSearchHandle;virtual;abstract;
  end;

    // ����Ŀ¼ ��������
  TNetworkFolderSearchHandle = class
  public
    TcpSocket : TCustomIpClient;
  protected
    ResultFileHash : TScanFileHash;
    ResultFolderHash : TScanFolderHash;
  public
    constructor Create;
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure Update;
    destructor Destroy; override;
  private
    procedure HandleResult( ResultStr : string );
  protected
    function getIsStop : Boolean;virtual;
    procedure HandleResultHash; virtual;abstract;
  end;

    // ����Ŀ¼ ��������
  TNetworkFolderSearchAccessHandle = class( TFolderSearchHandle )
  public
    TcpSocket : TCustomIpClient;
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure LastRefresh;override;
  protected
    procedure HandleResultHash;override;
    function getIsStop : Boolean; override;
    function getFolderSearchHandle : TFolderSearchHandle;override;
  end;

{$EndRegion}

const
  ScanCount_Sleep = 100;
  CopyCount_Sleep = 2;

    // �ļ�����
  FileReq_End = '-1';
  FileReq_ReadFile = '0';
  FileReq_ReadFolder = '1';
  FileReq_ReadFileDeletedList = '20';

  FileReq_SearchFolder = '21';

  FileReq_HeartBeat = '<23>';
  FileReq_New = '24';

  FileReq_ReadRecycleFolderDeep = '26';

  FileReq_AddZip = '27';

  FileReq_ZipFile = '28';
  FileReq_GetZip = '29';
  FileReq_ReadZipError = '30';

  FileReq_EditionList = '32';

  FileReq_PreviewPicture = '33';
  FileReq_PreviewWord = '34';
  FileReq_PreviewExcel = '35';
  FileReq_PreviewZip = '36';
  FileReq_PreviewText = '37';
  FileReq_PreviewExeDetail = '38';
  FileReq_PreviewExeIcon = '39';
  FileReq_PreviewMusic = '40';

  FileReq_Json = '41';

  FileReq_AddFile = '2';
  FileReq_AddFolder = '3';
  FileReq_RemoveFile = '4';
  FileReq_RemoveFolder = '5';
  FileReq_RecycleFile = '6';
  FileReq_RecycleFolder = '7';
  FileReq_GetFile = '8';

  FileReqBack_Continues = '0';
  FileReqBack_End = '1';

    // Ŀ¼��ȡ���
  FolderReadResult_End = '-1';
  FolderReadResult_File = '0';
  FolderReadResult_Folder = '1';

    // Ŀ¼�������
  FolderSearchResult_End = '-1';

const
  FolderListSplit_Type = '<t>';
  FolderListSplit_File = '<f>';
  FolderListSplit_FileInfo = '<fi>';
  FolderListSplit_Folder = '<fo%s>';
  FolderListSplit_FolderInfo = '<foi%s>';


  Type_Empty = '<Empty>';
  Type_Count = 2;
  Type_Folder = 0;
  Type_File = 1;

  FileInfo_Count = 3;
  Info_FileName = 0;
  Info_FileSize = 1;
  Info_FileTime = 2;

  FolderInfo_Count = 4;
  Info_FolderName = 0;
  Info_IsReaded = 1;
  Info_FolderChildFiles = 2;
  Info_FolderChildFolders = 3;

  ZipErrorSplit_File = '<f>';

const
  DeepCount_Max = 5000;

const
  RecycleSplit_Type = '<Type>';
  RecycleSplit_Count = 3;

  RecycleSplit_KeepEditionCount = 0;
  RecycleSplit_IsEncrypted = 1;
  RecycleSplit_PasswordExt = 2;

const
  Split_Word = '<BackupCow_Word_567>';

const
  ReceiveStatus_Speed = 'Speed';
  ReceiveStatus_Completed = 'Completed';
  ReceiveStatus_Stop = 'Stop';

implementation

{ TScanFileInfo }

constructor TScanFileInfo.Create(_FileName: string);
begin
  FileName := _FileName;
end;

function TScanFileInfo.getEquals(ScanFileInfo: TScanFileInfo): Boolean;
begin
  Result := ( ScanFileInfo.FileSize = FileSize ) and
            ( MyDatetime.Equals( FileTime, ScanFileInfo.FileTime ) );
end;

procedure TScanFileInfo.SetFileInfo(_FileSize: Int64; _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

{ TScanResultInfo }

constructor TScanResultInfo.Create(_SourceFilePath: string);
begin
  SourceFilePath := _SourceFilePath;
end;

{ TFolderCompareHandle }

procedure TFolderCompareHandler.AddFileResult(FileInfo : TScanFileInfo);
var
  ScanResultAddFileInfo : TScanResultAddFileInfo;
begin
  ScanResultAddFileInfo := TScanResultAddFileInfo.Create( getChildPath( FileInfo.FileName ) );
  ScanResultAddFileInfo.SetFileSize( FileInfo.FileSize, FileInfo.FileTime );
  ScanResultList.Add( ScanResultAddFileInfo );
end;

procedure TFolderCompareHandler.AddFolderResult(FolderName: string);
var
  ScanResultAddFolderInfo : TScanResultAddFolderInfo;
begin
  ScanResultAddFolderInfo := TScanResultAddFolderInfo.Create( getChildPath( FolderName ) );
  ScanResultList.Add( ScanResultAddFolderInfo );
end;

function TFolderCompareHandler.CheckNextScan: Boolean;
begin
  Result := True;

    // N ���ļ�Сͣһ��
  Inc( SleepCount );
  if SleepCount >= ScanCount_Sleep then
  begin
    Sleep(1);
    SleepCount := 0;
  end;
end;

procedure TFolderCompareHandler.CompareChildFolder(SourceFolderName: string);
var
  ChildFolderPath : string;
  FolderScanHandle : TFolderCompareHandler;
begin
  ChildFolderPath := MyFilePath.getPath( SourceFolderPath ) + SourceFolderName;
  FolderScanHandle := getScanHandle( SourceFolderName );
  FolderScanHandle.SetSourceFolderPath( ChildFolderPath );
  FolderScanHandle.SetResultList( ScanResultList );
  FolderScanHandle.SetIsSupportDeleted( IsSupportDeleted );
  FolderScanHandle.SetIsDesEmpty( IsDesEmpty );
  FolderScanHandle.FileCount := FileCount;
  FolderScanHandle.FileSize := FileSize;
  FolderScanHandle.CompletedSize := CompletedSize;
  FolderScanHandle.SleepCount := SleepCount;
  FolderScanHandle.ScanTime := ScanTime;
  FolderScanHandle.Update;
  FileCount := FolderScanHandle.FileCount;
  FileSize := FolderScanHandle.FileSize;
  CompletedSize := FolderScanHandle.CompletedSize;
  SleepCount := FolderScanHandle.SleepCount;
  ScanTime := FolderScanHandle.ScanTime;
  FolderScanHandle.Free;
end;

constructor TFolderCompareHandler.Create;
begin
  SourceFileHash := TScanFileHash.Create;
  DesFileHash := TScanFileHash.Create;
  SourceFolderHash := TScanFolderHash.Create;
  DesFolderHash := TScanFolderHash.Create;
  FileCount := 0;
  FileSize := 0;
  CompletedSize := 0;
  SleepCount := 0;
  ScanTime := Now;
  IsSupportDeleted := True;
  IsDesReaded := False;
  IsDesEmpty := False;
end;

procedure TFolderCompareHandler.DesFolderEmptyHandle;
begin

end;

destructor TFolderCompareHandler.Destroy;
begin
  SourceFileHash.Free;
  DesFileHash.Free;
  SourceFolderHash.Free;
  DesFolderHash.Free;
  inherited;
end;

procedure TFolderCompareHandler.FileCompare;
var
  p : TScanFilePair;
  SourceFileName, DesFileName : string;
begin
    // ���� Դ�ļ�
  for p in SourceFileHash do
  begin
      // ����Ƿ����ɨ��
    if not CheckNextScan then
      Break;

      // ��ӵ�ͳ����Ϣ
    FileSize := FileSize + p.Value.FileSize;
    FileCount := FileCount + 1;

      // �ļ���
    SourceFileName := p.Value.FileName;
    DesFileName := getDesFileName( SourceFileName );
    if DesFileName = '' then  // �ǽ����ļ�
      Continue;

      // Ŀ���ļ�������
    if not DesFileHash.ContainsKey( DesFileName ) then
    begin
      AddFileResult( p.Value );
      Continue;
    end;

      // Ŀ���ļ���Դ�ļ���һ��
    if not p.Value.getEquals( DesFileHash[ DesFileName ] ) then
    begin
      RemoveFileResult( DesFileName ); // ��ɾ��
      AddFileResult( p.Value );  // �����
    end
    else  // Ŀ���ļ���Դ�ļ�һ��
      CompletedSize := CompletedSize + p.Value.FileSize;

      // ɾ��Ŀ���ļ�
    DesFileHash.Remove( DesFileName );
  end;

    // ����Ŀ���ļ�
  if IsSupportDeleted then
    for p in DesFileHash do
      RemoveFileResult( p.Value.FileName );  // ɾ��Ŀ���ļ�
end;

procedure TFolderCompareHandler.FolderCompare;
var
  p : TScanFolderPair;
  FolderName : string;
begin
    // ����ԴĿ¼
  for p in SourceFolderHash do
  begin
    FolderName := p.Value.FolderName;

      // ������Ŀ��Ŀ¼���򴴽�
    if not DesFolderHash.ContainsKey( FolderName ) then
      AddFolderResult( FolderName );

      // �Ƚ���Ŀ¼
    CompareChildFolder( FolderName );

          // �Ƴ���¼
    if DesFolderHash.ContainsKey( FolderName ) then
      DesFolderHash.Remove( FolderName );
  end;

    // ����Ŀ��Ŀ¼
  if IsSupportDeleted then
    for p in DesFolderHash do
      RemoveFolderResult( p.Value.FolderName );
end;

function TFolderCompareHandler.getChildPath(ChildName: string): string;
begin
  Result := MyFilePath.getPath( SourceFolderPath ) + ChildName;
end;

function TFolderCompareHandler.getDesFileName(SourceFileName: string): string;
begin
  Result := SourceFileName;
end;

procedure TFolderCompareHandler.RemoveFileResult(FileName : string);
var
  ScanResultRemoveFileInfo : TScanResultRemoveFileInfo;
begin
  ScanResultRemoveFileInfo := TScanResultRemoveFileInfo.Create( getChildPath( FileName ) );
  ScanResultList.Add( ScanResultRemoveFileInfo );
end;

procedure TFolderCompareHandler.RemoveFolderResult(FolderName: string);
var
  ScanResultRemoveFolderInfo : TScanResultRemoveFolderInfo;
begin
  ScanResultRemoveFolderInfo := TScanResultRemoveFolderInfo.Create( getChildPath( FolderName ) );
  ScanResultList.Add( ScanResultRemoveFolderInfo );
end;

procedure TFolderCompareHandler.SetIsDesEmpty(_IsDesEmpty: Boolean);
begin
  IsDesEmpty := _IsDesEmpty;
end;

procedure TFolderCompareHandler.SetIsDesReaded(_IsDesReaded: Boolean);
begin
  IsDesReaded := _IsDesReaded;
end;

procedure TFolderCompareHandler.SetIsSupportDeleted(_IsSupportDeleted: Boolean);
begin
  IsSupportDeleted := _IsSupportDeleted;
end;

procedure TFolderCompareHandler.SetResultList(_ScanResultList: TScanResultList);
begin
  ScanResultList := _ScanResultList;
end;

procedure TFolderCompareHandler.SetSourceFolderPath(_SourceFolderPath: string);
begin
  SourceFolderPath := _SourceFolderPath;
end;

procedure TFolderCompareHandler.Update;
begin
    // ��Դ�ļ���Ϣ
  FindSourceFileInfo;

    // ���Ŀ�겻Ϊ�գ���ɨ��
  if not IsDesEmpty then
  begin
      // ��Ŀ���ļ���Ϣ
    FindDesFileInfo;

      // Ŀ��Ŀ¼�Ƿ�Ϊ��
    IsDesEmpty := ( DesFileHash.Count = 0 ) and ( DesFolderHash.Count = 0 );
  end
  else   // Ŀ��Ϊ�յĴ���
    DesFolderEmptyHandle;

    // �ļ��Ƚ�
  FileCompare;

    // Ŀ¼�Ƚ�
  FolderCompare;
end;

{ TFileScanHandle }

procedure TFileCompareHandler.AddFileResult;
var
  ScanResultAddFileInfo : TScanResultAddFileInfo;
begin
  ScanResultAddFileInfo := TScanResultAddFileInfo.Create( getAddFilePath );
  ScanResultAddFileInfo.SetFileSize( SourceFileSize, SourceFileTime );
  ScanResultList.Add( ScanResultAddFileInfo );
end;

function TFileCompareHandler.IsEqualsDes: Boolean;
begin
  Result := ( SourceFileSize = DesFileSize ) and
            ( MyDatetime.Equals( SourceFileTime, DesFileTime ) );
end;

procedure TFileCompareHandler.RemoveFileResult;
var
  ScanResultRemoveFileInfo : TScanResultRemoveFileInfo;
begin
  ScanResultRemoveFileInfo := TScanResultRemoveFileInfo.Create( getRemoveFilePath );
  ScanResultList.Add( ScanResultRemoveFileInfo );
end;

procedure TFileCompareHandler.SetResultList(_ScanResultList: TScanResultList);
begin
  ScanResultList := _ScanResultList;
end;

procedure TFileCompareHandler.SetSourceFilePath(_SourceFilePath: string);
begin
  SourceFilePath := _SourceFilePath;
end;

procedure TFileCompareHandler.Update;
begin
  CompletedSize := 0;

    // Դ�ļ�������
  if not FindSourceFileInfo then
    Exit;

    // Ŀ���ļ�������
  if not FindDesFileInfo then
    AddFileResult
  else   // Ŀ���ļ���Դ�ļ���һ��
  if not IsEqualsDes then
  begin
    RemoveFileResult;
    AddFileResult;
  end
  else
    CompletedSize := SourceFileSize;
end;


{ TLocalFolderFindHandle }

procedure TLocalFolderFindHandle.CheckSleep;
begin
    // N ���ļ�Сͣһ��
  Inc( SleepCount );
  if SleepCount >= ScanCount_Sleep then
  begin
    Sleep(1);
    SleepCount := 0;
  end;
end;

constructor TLocalFolderFindHandle.Create;
begin
  SleepCount := 0;
  DeepCount := 0;
  DeepMax := 0;
end;

function TLocalFolderFindHandle.CreateFolderFindHandle: TLocalFolderFindHandle;
begin
  Result := TLocalFolderFindHandle.Create;
end;

procedure TLocalFolderFindHandle.SearchChildFolder;
var
  p : TScanFolderPair;
  ChildFolderPath : string;
  LocalFolderFindHandle : TLocalFolderFindHandle;
begin
  for p in ScanFolderHash do
  begin
        // ������Χ������
    if DeepCount >= DeepMax then
      Break;

    ChildFolderPath := MyFilePath.getPath( FolderPath ) + p.Value.FolderName;

    LocalFolderFindHandle := CreateFolderFindHandle;
    LocalFolderFindHandle.SetFolderPath( ChildFolderPath );
    LocalFolderFindHandle.SetScanFile( p.Value.ScanFileHash );
    LocalFolderFindHandle.SetScanFolder( p.Value.ScanFolderHash );
    LocalFolderFindHandle.SetDeepInfo( DeepCount, DeepMax );
    LocalFolderFindHandle.SetSleepCount( SleepCount );
    LocalFolderFindHandle.Update;
    DeepCount := LocalFolderFindHandle.DeepCount;
    SleepCount := LocalFolderFindHandle.SleepCount;
    LocalFolderFindHandle.Free;

    p.Value.IsReaded := True;
  end;
end;

procedure TLocalFolderFindHandle.SearchLocalFolder;
var
  sch : TSearchRec;
  SearcFullPath, FileName, ChildPath : string;
  IsFolder, IsFillter : Boolean;
  FileSize : Int64;
  FileTime : TDateTime;
  LastWriteTimeSystem: TSystemTime;
  DesScanFileInfo : TScanFileInfo;
  DesScanFolderInfo : TScanFolderInfo;
begin
    // ѭ��Ѱ�� Ŀ¼�ļ���Ϣ
  SearcFullPath := MyFilePath.getPath( FolderPath );
  if FindFirst( SearcFullPath + '*', faAnyfile, sch ) = 0 then
  begin
    repeat

        // �� Cpu �ٶ�
      CheckSleep;

      FileName := sch.Name;

      if ( FileName = '.' ) or ( FileName = '..') then
        Continue;

        // ����ļ�����
      ChildPath := SearcFullPath + FileName;
      IsFolder := DirectoryExists( ChildPath );
      if IsFolder then
        IsFillter := IsFolderFilter( ChildPath )
      else
        IsFillter := IsFileFilter( ChildPath, sch );
      if IsFillter then  // �ļ�������
        Continue;

        // ��ӵ�Ŀ¼���
      if IsFolder then
      begin
        DesScanFolderInfo := TScanFolderInfo.Create( FileName );
        ScanFolderHash.AddOrSetValue( FileName, DesScanFolderInfo );
      end
      else
      begin
          // ��ȡ �ļ���С
        FileSize := sch.Size;

          // ��ȡ �޸�ʱ��
        FileTimeToSystemTime( sch.FindData.ftLastWriteTime, LastWriteTimeSystem );
        LastWriteTimeSystem.wMilliseconds := 0;
        FileTime := SystemTimeToDateTime( LastWriteTimeSystem );

          // ��ӵ��ļ����������
        DesScanFileInfo := TScanFileInfo.Create( FileName );
        DesScanFileInfo.SetFileInfo( FileSize, FileTime );
        ScanFileHash.Add( FileName, DesScanFileInfo );
      end;

    until FindNext(sch) <> 0;
  end;

  SysUtils.FindClose(sch);
end;

procedure TLocalFolderFindHandle.SetDeepInfo(_DeepCount, _DeepMax : Integer);
begin
  DeepCount := _DeepCount;
  DeepMax := _DeepMax;
end;

procedure TLocalFolderFindHandle.SetSleepCount(_SleepCount: Integer);
begin
  SleepCount := _SleepCount;
end;

procedure TLocalFolderFindHandle.Update;
begin
    // ������ǰĿ¼
  SearchLocalFolder;

    // ����
  DeepCount := DeepCount + ScanFileHash.Count;
  DeepCount := DeepCount + ScanFolderHash.Count;

    // ������Ŀ¼
  SearchChildFolder;
end;

{ TFolderFindHandle }

function TFolderFindHandle.IsFileFilter(FilePath: string;
  sch: TSearchRec): Boolean;
begin
  Result := False;
end;

function TFolderFindHandle.IsFolderFilter(FolderPath: string): Boolean;
begin
  Result := False;
end;

procedure TFolderFindHandle.SetScanFile(_ScanFileHash: TScanFileHash);
begin
  ScanFileHash := _ScanFileHash
end;

procedure TFolderFindHandle.SetScanFolder(_ScanFolderHash: TScanFolderHash);
begin
  ScanFolderHash := _ScanFolderHash;
end;

{ TNetworkFolderAccessFindHandle }

constructor TNetworkFolderAccessFindHandle.Create(_FolderPath: string);
begin
  FolderPath := _FolderPath;
  ScanFileHash := TScanFileHash.Create;
  ScanFolderHash := TScanFolderHash.Create;
  IsDeep := False;
  IsFilter := False;
end;

destructor TNetworkFolderAccessFindHandle.Destroy;
begin
  ScanFileHash.Free;
  ScanFolderHash.Free;
  inherited;
end;

procedure TNetworkFolderAccessFindHandle.SearchFilterFolderInfo;
var
  IsEncrypted : Boolean;
  PasswordExt : string;
  IsEdition : Boolean;
  FileEditionStr : string;
  LocalFolderFilterFindAdvanceHandle : TLocalFolderFilterFindAdvanceHandle;
  p : TFileEditionPair;
  FileEditionInfo : TFileEditionInfo;
  EditionPath : string;
  HeatBeatHelper : THeatBeatHelper;
begin
    // ������Ϣ
  IsEncrypted := MySocketUtil.RevBoolData( TcpSocket );
  PasswordExt := MySocketUtil.RevData( TcpSocket );
  IsEdition := MySocketUtil.RevBoolData( TcpSocket );

    // ��ʱ����
  HeatBeatHelper := THeatBeatHelper.Create( TcpSocket );

    // ʹ�ù�������
  LocalFolderFilterFindAdvanceHandle := TLocalFolderFilterFindAdvanceHandle.Create;
  if IsDeep then  // �������
    LocalFolderFilterFindAdvanceHandle.SetDeepInfo( 0, DeepCount_Max );
  LocalFolderFilterFindAdvanceHandle.SetFolderPath( FolderPath );
  LocalFolderFilterFindAdvanceHandle.SetScanFile( ScanFileHash );
  LocalFolderFilterFindAdvanceHandle.SetScanFolder( ScanFolderHash );
  LocalFolderFilterFindAdvanceHandle.SetEncryptedInfo( IsEncrypted, PasswordExt );
  LocalFolderFilterFindAdvanceHandle.SetEditionInfo( IsEdition, FileEditionHash );
  LocalFolderFilterFindAdvanceHandle.SetHeatBeatHelper( HeatBeatHelper );
  LocalFolderFilterFindAdvanceHandle.Update;
  LocalFolderFilterFindAdvanceHandle.Free;

  HeatBeatHelper.Free;
end;

procedure TNetworkFolderAccessFindHandle.SearchFolderInfo;
var
  HeatBeatHelper : THeatBeatHelper;
  LocalFolderFindAdvanceHandle : TLocalFolderFindAdvanceHandle;
begin
  HeatBeatHelper := THeatBeatHelper.Create( TcpSocket );

  LocalFolderFindAdvanceHandle := TLocalFolderFindAdvanceHandle.Create;
  if IsDeep then  // �������
    LocalFolderFindAdvanceHandle.SetDeepInfo( 0, DeepCount_Max );
  LocalFolderFindAdvanceHandle.SetFolderPath( FolderPath );
  LocalFolderFindAdvanceHandle.SetScanFile( ScanFileHash );
  LocalFolderFindAdvanceHandle.SetScanFolder( ScanFolderHash );
  LocalFolderFindAdvanceHandle.SetHeatBeatHelper( HeatBeatHelper );
  LocalFolderFindAdvanceHandle.Update;
  LocalFolderFindAdvanceHandle.Free;

  HeatBeatHelper.Free;
end;

procedure TNetworkFolderAccessFindHandle.SendFolderInfo;
var
  GetNetworkFullFolderResultStrHandle : TGetNetworkFullFolderResultStrHandle;
  ReadResultStr : string;
begin
    // ���������ת��Ϊ�ַ���
  GetNetworkFullFolderResultStrHandle := TGetNetworkFullFolderResultStrHandle.Create;
  GetNetworkFullFolderResultStrHandle.SetFileHash( ScanFileHash );
  GetNetworkFullFolderResultStrHandle.SetFolderHash( ScanFolderHash );
  ReadResultStr := GetNetworkFullFolderResultStrHandle.get;
  GetNetworkFullFolderResultStrHandle.Free;

    // ���Ͷ�ȡ���
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_FolderResponse, ReadResultStr );
end;

procedure TNetworkFolderAccessFindHandle.SetFileEditionHash(
  _FileEditionHash: TFileEditionHash);
begin
  FileEditionHash := _FileEditionHash;
end;

procedure TNetworkFolderAccessFindHandle.SetIsDeep(_IsDeep: Boolean);
begin
  IsDeep := _IsDeep;
end;

procedure TNetworkFolderAccessFindHandle.SetIsFilter(_IsFilter: Boolean);
begin
  IsFilter := _IsFilter;
end;

procedure TNetworkFolderAccessFindHandle.SetTcpSocket(
  _TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TNetworkFolderAccessFindHandle.Update;
begin
    // ����Ŀ¼��Ϣ
  if not IsFilter then
    SearchFolderInfo
  else
    SearchFilterFolderInfo;

    // �����������
  SendFolderInfo;
end;

{ TFileCopyHandle }

constructor TCopyFileHandle.Create;
begin
  FilePos := 0;
  IsEncrypt := False;
  IsDecrypt := False;
  RefreshCopyReader := TRefreshCopyReader.Create;
  BufStream := TMemoryStream.Create;
  ReadStream := nil;
  WriteStream := nil;
end;

function TCopyFileHandle.ReadIsCreateReadStream: Boolean;
begin
  try
    ReadStream := TFileStream.Create( SourceFilePath, fmOpenRead or fmShareDenyNone );

    if ReadStream.Size = FileSize then
    begin
      ReadStream.Position := FilePos;
      Result := True;
    end
    else
    begin
      ReadStream.Free;
      ReadStream := nil;
      Result := False
    end;
  except
    ReadStream := nil;
    Result := False;
  end;
end;

function TCopyFileHandle.ReadIsCreateWriteStream: Boolean;
begin
  try
      // Ŀ���ļ�
    if FilePos > 0 then  // ����
    begin
      WriteStream := TFileStream.Create( DesFilePath, fmOpenWrite or fmShareDenyNone );
      WriteStream.Position := FilePos;
    end
    else
    begin  // ��һ�δ�
      ForceDirectories( ExtractFileDir( DesFilePath ) );
      WriteStream := TFileStream.Create( DesFilePath, fmCreate or fmShareDenyNone );
    end;
    Result := True;
  except
    WriteStream := nil;
    Result := False;
  end;
end;

procedure TCopyFileHandle.DestoryStream;
begin
  try
    if Assigned( ReadStream ) then
    begin
      ReadStream.Free;
      ReadStream := nil;
    end;
    if Assigned( WriteStream ) then
    begin
      WriteStream.Free;
      WriteStream := nil;
    end;
  except
  end;
end;

destructor TCopyFileHandle.Destroy;
begin
  RefreshCopyReader.Free;
  BufStream.Free;
  DestoryStream;
  inherited;
end;

function TCopyFileHandle.FileCopyHandle: Boolean;
var
  TotalReadSize, TotalWriteSize: Integer;
  RemainSize : Int64;
begin
  Result := False;

  try    // �����ļ�
    RemainSize := FileSize - FilePos;
    while RemainSize > 0 do
    begin
        // ȡ������
      if not CopyFileOperator.ReadIsNextCopy then
        Break;

        // ��ʱˢ��
      if RefreshCopyReader.ReadIsRefresh then
        CopyFileOperator.RefreshCompletedSpace;

        // ���ļ�
      TotalReadSize := ReadBufStream; // ��ȡ 8MB �ļ�

        // ���ļ�����
      if TotalReadSize <= 0 then
      begin
        CopyFileOperator.ReadFileError;
        Break;
      end;

        // д�ļ�
      TotalWriteSize := WriteBufStream;

        // д�ļ����� �� �ռ� ����
      if TotalWriteSize <> TotalReadSize then
      begin
        CopyFileOperator.WriteFileError;
        Break;
      end;

        // ˢ��״̬
      RemainSize := RemainSize - TotalReadSize;
      FilePos := FilePos + TotalReadSize;
      RefreshCopyReader.AddCompletedSize( TotalReadSize );
      CopyFileOperator.AddSpeedSpace( TotalReadSize );
    end;
  except
  end;

    // �������ɿռ�
  CopyFileOperator.RefreshCompletedSpace;

    // �����Ƿ������
  Result := RemainSize <= 0;
end;


function TCopyFileHandle.ReadIsEnoughSpace: Boolean;
var
  FreeSize : Int64;
begin
  FreeSize := MyHardDisk.getHardDiskFreeSize( ExtractFileDir( DesFilePath ) );

    // �Ƿ����㹻�Ŀռ�
  Result := FreeSize >= ( FileSize - FilePos ) ;
end;

function TCopyFileHandle.ReadBufStream: Integer;
var
  RemainSize : Int64;
  i, ReadSize, WriteSize : Integer;
  FullBufSize, TotalReadSize : Integer;
  Buf : TDataBuf;
begin
  DebugLock.DebugFile( 'Read Stream Data', SourceFilePath );
  Result := -1;

  try
    FullBufSize := SizeOf( Buf );
    RemainSize := ReadStream.Size - FilePos;
    BufStream.Clear;
    TotalReadSize := 0;
    for i := 0 to 15 do  // ��ȡ 8MB �ļ�
    begin
      ReadSize := Min( FullBufSize, RemainSize - TotalReadSize );
      ReadSize := ReadStream.Read( Buf, ReadSize );

        // �����ļ�
      if IsEncrypt then
        CopyFileUtil.Encrypt( Buf, ReadSize, EncPassword )
      else
      if IsDecrypt then
        CopyFileUtil.Deccrypt( Buf, ReadSize, DecPassword );

        // ��ӵ�������
      WriteSize := BufStream.Write( Buf, ReadSize );
      if ReadSize <> WriteSize then  // û����ȫд��
        Exit;

        // ͳ�ƶ�ȡ����
      TotalReadSize := TotalReadSize + ReadSize;

        // ��ȡ ���
      if ( RemainSize - TotalReadSize ) <= 0 then
        Break;
    end;
    Result := TotalReadSize;
  except
  end;
end;

procedure TCopyFileHandle.SetCopyFileOperator(
  _CopyFileOperator: TCopyFileOperator);
begin
  CopyFileOperator := _CopyFileOperator;
  CopyFileOperator.SetCopyFileHandle( Self );
end;

procedure TCopyFileHandle.SetDecryptInfo(_IsDecrypt : Boolean;_DecPassword: string);
begin
  IsDecrypt := _IsDecrypt;
  DecPassword := _DecPassword;
end;

procedure TCopyFileHandle.SetEncryptInfo(_IsEncrypt : Boolean;_EncPassword: string);
begin
  IsEncrypt := _IsEncrypt;
  EncPassword := _EncPassword;
end;

procedure TCopyFileHandle.SetPathInfo(_SourFilePath, _DesFilePath: string);
begin
  SourceFilePath := _SourFilePath;
  DesFilePath := _DesFilePath;
end;

procedure TCopyFileHandle.SetPosition(_Position: Int64);
begin
  FilePos := _Position;
end;

function TCopyFileHandle.Update: Boolean;
begin
  DebugLock.DebugFile( 'Copy File', SourceFilePath );

  Result := False;

    // �����ļ�������
  if ( FilePos > 0 ) and not FileExists( DesFilePath ) then
    Exit;

    // Դ�ļ�������
  if not FileExists( SourceFilePath ) then
  begin
    CopyFileOperator.ReadFileError;
    Exit;
  end;

    // ��ȡ Դ�ļ���Ϣ
  FileSize := MyFileInfo.getFileSize( SourceFilePath );
  FileTime := MyFileInfo.getFileLastWriteTime( SourceFilePath );

    // Ŀ��·��û���㹻�Ŀռ�
  if not ReadIsEnoughSpace then
  begin
    CopyFileOperator.DesWriteSpaceLack; // �ռ䲻��
    Exit;
  end;

    // �޷�����������
  if not ReadIsCreateReadStream then
  begin
    CopyFileOperator.ReadFileError;
    Exit;
  end;

    // �޷�����д����
  if not ReadIsCreateWriteStream then
  begin
    CopyFileOperator.WriteFileError;
    Exit;
  end;

    // �ļ� ����ʧ��
  if not FileCopyHandle then
  begin
    CopyFileOperator.MarkContinusCopy; // ���������Ϣ
    Exit;
  end;

    // �ͷ���
  DestoryStream;

      // �����޸�ʱ��
  MyFileSetTime.SetTime( DesFilePath, FileTime );
  Result := True;
end;

function TCopyFileHandle.WriteBufStream: Integer;
var
  RemainSize : Int64;
  i, ReadSize, WriteSize : Integer;
  FullBufSize, TotalWriteSize : Integer;
  Buf : TDataBuf;
begin
  DebugLock.DebugFile( 'Write Stream Data', SourceFilePath );
  Result := -1;

    // д�ļ�
  try
    RemainSize := BufStream.Size;
    BufStream.Position := 0;
    FullBufSize := SizeOf( Buf );
    TotalWriteSize := 0;
    while RemainSize > 0 do
    begin
      ReadSize := Min( FullBufSize, RemainSize );
      ReadSize := BufStream.Read( Buf, ReadSize );
      WriteSize := WriteStream.Write( Buf, ReadSize );
      if WriteSize <> ReadSize then // û����ȫд��
        Exit;
      RemainSize := RemainSize - WriteSize;
      TotalWriteSize := TotalWriteSize + WriteSize;
    end;
    Result := TotalWriteSize;
  except
  end;
end;

{ TRefreshSpeedInfo }

function TSpeedReader.AddCompleted(CompletedSpace: Integer): Boolean;
var
  SleepMisecond, SendMisecond : Integer;
  LastTime : TDateTime;
begin
  SpeedLock.Enter;
  try
    Speed := Speed + CompletedSpace;
    Result := SecondsBetween( Now, SpeedTime ) >= 1;

      // �ٶ�����
    if IsLimited and ( Speed >= LimitSpeed ) and not Result then
    begin
      LastTime := IncSecond( SpeedTime, 1 );
      SleepMisecond := MilliSecondsBetween( LastTime, Now );
      Sleep( SleepMisecond );
      Result := True;
    end;

      // ���¼����ٶ�
    if Result then
    begin
      SendMisecond := MilliSecondsBetween( Now, SpeedTime );
      Speed := ( Speed * 1000 ) div SendMisecond;
      LastSpeed := Speed;
      SpeedTime := Now;
      Speed := 0;
    end;
  except
  end;
  SpeedLock.Leave;
end;

constructor TSpeedReader.Create;
begin
  Speed := 0;
  LastSpeed := 0;
  SpeedTime := Now;
  IsLimited := False;
  SpeedLock := TCriticalSection.Create;
end;

destructor TSpeedReader.Destroy;
begin
  SpeedLock.Free;
  inherited;
end;

function TSpeedReader.ReadAvailableSpeed: Int64;
begin
  SpeedLock.Enter;
  Result := LimitSpeed - Speed;
  SpeedLock.Leave;
end;

function TSpeedReader.ReadIsLimited: Boolean;
begin
  Result := IsLimited;
end;

function TSpeedReader.ReadLastSpeed: Int64;
begin
  SpeedLock.Enter;
  Result := LastSpeed;
  SpeedLock.Leave;
end;

procedure TSpeedReader.SetLimitInfo(_IsLimited: Boolean;
  _LimitSpeed: Int64);
begin
  IsLimited := _IsLimited;
  LimitSpeed := _LimitSpeed;
end;

{ TFileFindHandle }

function TFileFindHandle.getFileSize: Int64;
begin
  Result := FileSize;
end;

function TFileFindHandle.getFileTime: TDateTime;
begin
  Result := FileTime;
end;

function TFileFindHandle.getIsExist: Boolean;
begin
  Result := IsExist;
end;

procedure TFileFindHandle.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

{ TLocalFileFindHandle }

procedure TLocalFileFindHandle.Update;
begin
  IsExist := FileExists( FilePath );
  if not IsExist then
    Exit;
  FileSize := MyFileInfo.getFileSize( FilePath );
  FileTime := MyFileInfo.getFileLastWriteTime( FilePath );
end;

{ TNetworkFileAccessFindHandle }

constructor TNetworkFileAccessFindHandle.Create(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TNetworkFileAccessFindHandle.SetTcpSocket(
  _TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TNetworkFileAccessFindHandle.Update;
var
  LocalFileFindHandle : TLocalFileFindHandle;
  IsExist : Boolean;
  FileSize : Int64;
  FileTime : TDateTime;
begin
    // ��ȡ�ļ���Ϣ
  LocalFileFindHandle := TLocalFileFindHandle.Create;
  LocalFileFindHandle.SetFilePath( FilePath );
  LocalFileFindHandle.Update;
  IsExist := LocalFileFindHandle.getIsExist;
  FileSize := LocalFileFindHandle.getFileSize;
  FileTime := LocalFileFindHandle.getFileTime;
  LocalFileFindHandle.Free;

    // �����ļ���Ϣ
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_IsExistFile, BoolToStr( IsExist ) );
  if not IsExist then
    Exit;
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_FileSize, IntToStr( FileSize ) );
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_FileTime, MyRegionUtil.ReadRemoteTimeStr( FileTime ) );
end;

{ TDesFileRecycleHandle }

procedure TFileRecycleHandle.ConfirmRecycleEdition;
var
  ExistRecycleEdition, RemoveEdition : Integer;
  i : Integer;
  FilePath1, FilePath2 : string;
begin
    // ��ȡ�ִ�İ汾��
  ExistRecycleEdition := getExistRecycleEdition;

    // ���ڰ汾�����ڵ���Ԥ��ֵ
  if ExistRecycleEdition >= SaveDeletedEdition then
  begin
    for i := SaveDeletedEdition to ExistRecycleEdition do  // ��ɾ����ɵİ汾
    begin
      FilePath1 := getRecycleEditionPath( i );
      SysUtils.DeleteFile( FilePath1 );
    end;
    ExistRecycleEdition := SaveDeletedEdition - 1;
  end;

    // �汾����
  if ExistRecycleEdition > 0 then
    for i := ExistRecycleEdition downto 1 do
    begin
      FilePath1 := getRecycleEditionPath( i );
      FilePath2 := getRecycleEditionPath( i + 1 );
      RenameFile( FilePath1, FilePath2 );
    end;

    // �ŵ���һ
  RecycledFilePath := getRecycleEditionPath( 1 );

    // ������Ŀ¼
  ForceDirectories( ExtractFileDir( RecycledFilePath ) );
end;

function TFileRecycleHandle.getRecycleEditionPath(EditionNum: Integer): string;
begin
  Result := RecycledFilePath + Sign_Deleted + IntToStr(EditionNum);
end;

function TFileRecycleHandle.getEquals(FilePath1, FilePath2: string): Boolean;
var
  FileSize1, FileSize2 : Int64;
  FileDate1, FileDate2 : TDateTime;
begin
  FileSize1 := MyFileInfo.getFileSize( FilePath1 );
  FileSize2 := MyFileInfo.getFileSize( FilePath2 );
  FileDate1 := MyFileInfo.getFileLastWriteTime( FilePath1 );
  FileDate2 := MyFileInfo.getFileLastWriteTime( FilePath2 );
  Result := ( FileSize1 = FileSize2 ) and MyDatetime.Equals( FileDate1, FileDate2 );
end;

function TFileRecycleHandle.getExistRecycleEdition: Integer;
var
  EditionNum : Integer;
begin
  Result := 0;
  EditionNum := 1;
  while FileExists( getRecycleEditionPath( EditionNum ) ) do
  begin
    Inc( EditionNum );
    Inc( Result );
  end;
end;

function TFileRecycleHandle.getIsExistRecylce: Boolean;
var
  ExistEditionCount : Integer;
  i: Integer;
begin
  Result := False;
  ExistEditionCount := getExistRecycleEdition;
  for i := 1 to ExistEditionCount do
    if getEquals( DesFilePath, getRecycleEditionPath( i ) ) then
    begin
      Result := True;
      Break;
    end;    
end;

procedure TFileRecycleHandle.SetPathInfo(_DesFilePath,
  _RecycledFilePath: string);
begin
  DesFilePath := _DesFilePath;
  RecycledFilePath := _RecycledFilePath;
end;

procedure TFileRecycleHandle.SetSaveDeletedEdition(
  _SaveDeletedEdition: Integer);
begin
  SaveDeletedEdition := _SaveDeletedEdition;
end;

procedure TFileRecycleHandle.Update;
begin
    // �ļ��Ѵ���
  if getIsExistRecylce then
  begin
    SysUtils.DeleteFile( DesFilePath ); // ɾ���ļ�
    Exit;
  end;

    // ��鱣��İ汾�����������Ҫ����İ汾����ɾ��
  ConfirmRecycleEdition;

    // �ƶ��ļ�
  MoveFile( PChar( DesFilePath ), PChar( RecycledFilePath ) );
end;

{ FileRecycledUtil }

class function FileRecycledUtil.getEditionPath(Params : TEditonPathParams): string;
var
  IsEncrypted : Boolean;
  PasswordExt : string;
  FilePath : string;
  AfterStr : string;
  BeforeStr : string;
begin
  IsEncrypted := Params.IsEncrypted;
  PasswordExt := Params.PasswordExt;
  FilePath := Params.FilePath;

    // ����Ǽ���·��������ܻ�ȡԴ·��
  if IsEncrypted then
    FilePath := MyFilePath.getDesFilePath( FilePath, PasswordExt, False );

    // ���ɰ汾·��
  AfterStr := ExtractFileExt( FilePath );
  BeforeStr := MyString.CutStopStr( AfterStr, FilePath );
  FilePath := BeforeStr + '.(' + IntToStr( Params.EditionNum ) + ')' + AfterStr;

    // ����Ǽ���·���������Դ·��
  if IsEncrypted then
    FilePath := MyFilePath.getDesFilePath( FilePath, PasswordExt, True );

  Result := FilePath;
end;

{ TFolderRecycleHandle }

procedure TFolderRecycleHandle.CreateRecycleFolder;
begin
  ForceDirectories( RecycleFolderPath );
end;

procedure TFolderRecycleHandle.RemoveDesFolder;
begin
  MyFolderDelete.DeleteDir( DesFolderPath );
end;

procedure TFolderRecycleHandle.SearchFile(FileName: string);
var
  DesFilePath, RecycleFilePath : string;
  FileRecycleHandle : TFileRecycleHandle;
begin
    // �ļ�·��
  DesFilePath := MyFilePath.getPath( DesFolderPath ) + FileName;
  RecycleFilePath := MyFilePath.getPath( RecycleFolderPath ) + FileName;

  FileRecycleHandle := TFileRecycleHandle.Create;
  FileRecycleHandle.SetPathInfo( DesFilePath, RecycleFilePath );
  FileRecycleHandle.SetSaveDeletedEdition( KeepEditionCount );
  FileRecycleHandle.Update;
  FileRecycleHandle.Free;
end;

procedure TFolderRecycleHandle.SearchFolder(FolderName: string);
var
  DesChildFolderPath, RecycleChildFolderPath : string;
  FolderRecycleHandle : TFolderRecycleHandle;
begin
    // �ļ�·��
  DesChildFolderPath := MyFilePath.getPath( DesFolderPath ) + FolderName;
  RecycleChildFolderPath := MyFilePath.getPath( RecycleFolderPath ) + FolderName;

    // ������Ŀ¼
  FolderRecycleHandle := TFolderRecycleHandle.Create;
  FolderRecycleHandle.SetPathInfo( DesChildFolderPath, RecycleChildFolderPath );
  FolderRecycleHandle.SetKeepEditionCount( KeepEditionCount );
  FolderRecycleHandle.Update;
  FolderRecycleHandle.Free;
end;

procedure TFolderRecycleHandle.SetKeepEditionCount(_KeepEditionCount: Integer);
begin
  KeepEditionCount := _KeepEditionCount;
end;

procedure TFolderRecycleHandle.SetPathInfo(_DesFolderPath, _RecycleFolderPath: string);
begin
  DesFolderPath := _DesFolderPath;
  RecycleFolderPath := _RecycleFolderPath;
end;

procedure TFolderRecycleHandle.Update;
var
  sch : TSearchRec;
  SearcFullPath, FileName, ChildPath : string;
begin
    // ��������Ŀ¼
  CreateRecycleFolder;

    // ѭ��Ѱ�� Ŀ¼�ļ���Ϣ
  SearcFullPath := MyFilePath.getPath( DesFolderPath );
  if FindFirst( SearcFullPath + '*', faAnyfile, sch ) = 0 then
  begin
    repeat
      FileName := sch.Name;

      if ( FileName = '.' ) or ( FileName = '..') then
        Continue;

        // ����ļ�����
      ChildPath := SearcFullPath + FileName;
      if DirectoryExists( ChildPath ) then
        SearchFolder( FileName )
      else
        SearchFile( FileName );

    until FindNext(sch) <> 0;
  end;
  SysUtils.FindClose(sch);

    // ɾ��Ŀ��Ŀ¼
  RemoveDesFolder;
end;

{ TNetworkFileFindBaseHandle }

constructor TNetworkFileFindHandle.Create;
begin
  IsDeleted := False;
end;

procedure TNetworkFileFindHandle.SetIsDeleted(_IsDeleted: Boolean);
begin
  IsDeleted := _IsDeleted;
end;

procedure TNetworkFileFindHandle.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TNetworkFileFindHandle.Update;
var
  TimeStr : string;
begin
    // ����������Ϣ
  MySocketUtil.SendData( TcpSocket, FileReq_ReadFile );
  MySocketUtil.SendData( TcpSocket, FilePath );
  MySocketUtil.SendData( TcpSocket, IsDeleted );

    // ��ȡ�ļ���Ϣ
  IsExist := MySocketUtil.RevJsonBool( TcpSocket );
  if not IsExist then // Ŀ���ļ�������
    Exit;
  FileSize := MySocketUtil.RevJsonInt64( TcpSocket );
  TimeStr := MySocketUtil.RevJsonStr( TcpSocket );
  FileTime := MyRegionUtil.ReadLocalTime( TimeStr );
end;

{ TNetworkFolderFindBaseHandle }

constructor TNetworkFolderFindHandle.Create;
begin
  IsDeep := False;
  IsDeleted := False;

  IsFilter := False;
  IsEncrypted := False;
  IsEdition := False;
end;

procedure TNetworkFolderFindHandle.SetEditionInfo(
  _IsEdition : Boolean);
begin
  IsEdition := _IsEdition;
end;

procedure TNetworkFolderFindHandle.SetIsDeep(_IsDeep: Boolean);
begin
  IsDeep := _IsDeep;
end;

procedure TNetworkFolderFindHandle.SetIsDeleted(_IsDeleted: Boolean);
begin
  IsDeleted := _IsDeleted;
end;

procedure TNetworkFolderFindHandle.SetIsFilter(_IsFilter: Boolean);
begin
  IsFilter := _IsFilter;
end;

procedure TNetworkFolderFindHandle.SetEnctyptedInfo(_IsEncrypted : Boolean; _PasswordExt: string);
begin
  IsEncrypted := _IsEncrypted;
  PasswordExt := _PasswordExt;
end;

procedure TNetworkFolderFindHandle.SetTcpSocket(
  _TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TNetworkFolderFindHandle.Update;
var
  FolderReadResult : string;
  FindNetworkFullFolderResultHandle : TFindNetworkFullFolderResultHandle;
begin
    // ����������Ϣ
  MySocketUtil.SendData( TcpSocket, FileReq_ReadFolder );
  MySocketUtil.SendData( TcpSocket, FolderPath );
  MySocketUtil.SendData( TcpSocket, IsDeleted );

    // ������Ϣ
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_IsDeep, IsDeep );
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_IsFilter, IsFilter );
  if IsFilter then
  begin
    MySocketUtil.SendData( TcpSocket, IsEncrypted );
    MySocketUtil.SendData( TcpSocket, PasswordExt );
    MySocketUtil.SendData( TcpSocket, IsEdition );
  end;

    // ���ս����Ϣ
  FolderReadResult := HeartBeatReceiver.CheckReceive( TcpSocket );
  if FolderReadResult = '' then // �Է��Ͽ�����
  begin
    TcpSocket.Disconnect;
    Exit;
  end;
  FolderReadResult := MySocketUtil.ReadMsgToMsgStr( FolderReadResult );

    // ��ȡ��Ϣ
  FindNetworkFullFolderResultHandle := TFindNetworkFullFolderResultHandle.Create( FolderReadResult );
  FindNetworkFullFolderResultHandle.SetScanFile( ScanFileHash );
  FindNetworkFullFolderResultHandle.SetScanFolder( ScanFolderHash );
  FindNetworkFullFolderResultHandle.Update;
  FindNetworkFullFolderResultHandle.Free;
end;

{ TScanFolderInfo }

constructor TScanFolderInfo.Create(_FolderName: string);
begin
  FolderName := _FolderName;
  ScanFileHash := TScanFileHash.Create;
  ScanFolderHash := TScanFolderHash.Create;
  IsReaded := False;
end;

destructor TScanFolderInfo.Destroy;
begin
  ScanFileHash.Free;
  ScanFolderHash.Free;
  inherited;
end;

{ ScanFileInfoUtil }

class procedure ScanFileInfoUtil.CopyFile(OldFileHash,
  NewFileHash: TScanFileHash);
var
  p: TScanFilePair;
  ScanFileInfo : TScanFileInfo;
begin
  for p in NewFileHash do
  begin
    ScanFileInfo := TScanFileInfo.Create( p.Value.FileName );
    ScanFileInfo.SetFileInfo( p.Value.FileSize, p.Value.FileTime );
    OldFileHash.Add( p.Value.FileName, ScanFileInfo );
  end;
end;

class procedure ScanFileInfoUtil.CopyFolder(OldFOlderHash,
  NewFolderHash: TScanFolderHash);
var
  p: TScanFolderPair;
  ScanFolderInfo : TScanFolderInfo;
begin
  for p in NewFolderHash do
  begin
    ScanFolderInfo := TScanFolderInfo.Create( p.Value.FolderName );
    OldFOlderHash.AddOrSetValue( p.Value.FolderName, ScanFolderInfo );
  end;
end;


{ TNetworkFileDeletedListFindHandle }

procedure TNetworkFileDeletedListFindHandle.SetTcpSocket(
  _TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TNetworkFileDeletedListFindHandle.Update;
var
  FileStr : string;
  FindNetworkFileResultHandle : TFindNetworkFileResultHandle;
begin
    // ����������Ϣ
  MySocketUtil.SendData( TcpSocket, FileReq_ReadFileDeletedList );
  MySocketUtil.SendData( TcpSocket, FilePath );
  MySocketUtil.SendData( TcpSocket, True );

    // ��ȡ �������
  FileStr := MySocketUtil.RevData( TcpSocket );

    // û���ļ�
  if FileStr = Type_Empty then
    Exit;

    // ��ȡ�ļ��б���Ϣ
  FindNetworkFileResultHandle := TFindNetworkFileResultHandle.Create( FileStr );
  FindNetworkFileResultHandle.SetScanFile( ScanFileHash );
  FindNetworkFileResultHandle.Update;
  FindNetworkFileResultHandle.Free
end;

{ TFindNetworkFileResultHandle }

constructor TFindNetworkFileResultHandle.Create(_FileStr: string);
begin
  FileStr := _FileStr;
end;

procedure TFindNetworkFileResultHandle.ReadFileInfo(FileInfoStr: string);
var
  FileInfoList : TStringList;
  FileName : string;
  FileSize : Int64;
  TimeStr : string;
  FileTime : TDateTime;
  ScanFileInfo : TScanFileInfo;
begin
  FileInfoList := MySplitStr.getList( FileInfoStr, FolderListSplit_FileInfo );
  if FileInfoList.Count = FileInfo_Count then
  begin
    FileName := FileInfoList[ Info_FileName ];
    FileSize := StrToInt64Def( FileInfoList[ Info_FileSize ], 0 );
    TimeStr := FileInfoList[ Info_FileTime ];
    FileTime := MyRegionUtil.ReadLocalTime( TimeStr );
    ScanFileInfo := TScanFileInfo.Create( FileName );
    ScanFileInfo.SetFileInfo( FileSize, FileTime );
    ScanFileHash.AddOrSetValue( FileName, ScanFileInfo );
  end;
  FileInfoList.Free;
end;

procedure TFindNetworkFileResultHandle.SetScanFile(
  _ScanFileHash: TScanFileHash);
begin
  ScanFileHash := _ScanFileHash;
end;

procedure TFindNetworkFileResultHandle.Update;
var
  FileList : TStringList;
  i: Integer;
begin
  FileList := MySplitStr.getList( FileStr, FolderListSplit_File );
  for i := 0 to FileList.Count - 1 do
    ReadFileInfo( FileList[i] );
  FileList.Free;
end;

{ TNetworkFileDeletedListAccessFindHandle }

constructor TNetworkFileDeletedListAccessFindHandle.Create(_FilePath: string);
begin
  FilePath := _FilePath;
  ScanFileHash := TScanFileHash.Create;
end;

destructor TNetworkFileDeletedListAccessFindHandle.Destroy;
begin
  ScanFileHash.Free;
  inherited;
end;

procedure TNetworkFileDeletedListAccessFindHandle.FindDeletedFileList;
var
  DeleteFileListGetHandle : TLocalFileDeletedListFindHandle;
begin
  DeleteFileListGetHandle := TLocalFileDeletedListFindHandle.Create( FilePath );
  DeleteFileListGetHandle.SetScanFileHash( ScanFileHash );
  DeleteFileListGetHandle.Update;
  DeleteFileListGetHandle.Free;
end;

procedure TNetworkFileDeletedListAccessFindHandle.SendDeletedFileList;
var
  FileStr : string;
  GetNetworkFileResultStrHandle : TGetNetworkFileResultStrHandle;
begin
    // ��ȡ��Ϣ�б�
  GetNetworkFileResultStrHandle := TGetNetworkFileResultStrHandle.Create( ScanFileHash );
  FileStr := GetNetworkFileResultStrHandle.get;
  GetNetworkFileResultStrHandle.Free;

    // û���ļ�
  if FileStr = '' then
    FileStr := Type_Empty;

    // ���ͽ��
  MySocketUtil.SendData( TcpSocket, FileStr )
end;

procedure TNetworkFileDeletedListAccessFindHandle.SetTcpSocket(
  _TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TNetworkFileDeletedListAccessFindHandle.Update;
begin
    // Ѱ����Ϣ
  FindDeletedFileList;

    // ������Ϣ
  SendDeletedFileList;
end;

{ TGetNetworkFileResultStrHandle }

constructor TGetNetworkFileResultStrHandle.Create(_ScanFileHash: TScanFileHash);
begin
  ScanFileHash := _ScanFileHash;
end;

function TGetNetworkFileResultStrHandle.get: string;
var
  FileStr, FileInfoStr : string;
  p : TScanFilePair;
begin
    // ���ļ���Ϣ
  FileStr := '';
  for p in ScanFileHash do
  begin
    if FileStr <> '' then
      FileStr := FileStr + FolderListSplit_File;
    FileInfoStr := p.Value.FileName + FolderListSplit_FileInfo;
    FileInfoStr := FileInfoStr + IntToStr( p.Value.FileSize ) + FolderListSplit_FileInfo ;
    FileInfoStr := FileInfoStr + MyRegionUtil.ReadRemoteTimeStr( p.Value.FileTime );
    FileStr := FileStr + FileInfoStr;
  end;

    // û���ļ��ı�־
  if FileStr = '' then
    FileStr := Type_Empty;

  Result := FileStr;
end;

{ TFileDeletedListFindHandle }

constructor TFileDeletedListFindHandle.Create(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TFileDeletedListFindHandle.SetScanFileHash(
  _ScanFileHash: TScanFileHash);
begin
  ScanFileHash := _ScanFileHash;
end;

{ TDeleteFileListGetHandle }

procedure TLocalFileDeletedListFindHandle.Update;
var
  FolderPath, SearchName : string;
  ChildFileHash : TScanFileHash;
  ChildFolderHash : TScanFolderHash;
  LocalFolderFindHandle : TLocalFolderFindHandle;
  p : TScanFilePair;
  FileName, RecycleNameBefore, RecycleNameAfter : string;
  ScanFileInfo : TScanFileInfo;
begin
  FolderPath := ExtractFileDir( FilePath );
  SearchName := ExtractFileName( FilePath );
  ChildFolderHash := TScanFolderHash.Create;
  ChildFileHash := TScanFileHash.Create;

    // ����Ŀ¼��Ϣ
  LocalFolderFindHandle := TLocalFolderFindHandle.Create;
  LocalFolderFindHandle.SetFolderPath( FolderPath );
  LocalFolderFindHandle.SetScanFile( ChildFileHash );
  LocalFolderFindHandle.SetScanFolder( ChildFolderHash );
  LocalFolderFindHandle.Update;
  LocalFolderFindHandle.Free;

    // Ѱ�һ��յ��ļ�
  for p in ChildFileHash do
  begin
    FileName := p.Value.FileName;
    if not MyFilePath.getIsEquals( SearchName, FileName ) then
      Continue;
    ScanFileInfo := TScanFileInfo.Create( FileName );
    ScanFileInfo.SetFileInfo( p.Value.FileSize, p.Value.FileTime );
    ScanFileHash.AddOrSetValue( FileName, ScanFileInfo );
  end;

  ChildFolderHash.Free;
  ChildFileHash.Free;
end;

{ CopyFileUtil }

class procedure SendFileUtil.CompressStream(SourceStream,
  ComStream: TMemoryStream);
var
  cs: TCompressionStream; {����ѹ����}
  num: Integer;           {ԭʼ�ļ���С}
begin
  num := SourceStream.Size;
  ComStream.Write(num, SizeOf(num));

  cs := TCompressionStream.Create(ComStream);
  SourceStream.SaveToStream(cs);
  cs.Free;
end;

class procedure SendFileUtil.Deccrypt(var Buf: TDataBuf; BufSize: Integer;
  Password: string);
var
  RemainSize, FullEncSize, StartPos : Integer;
  EncSize : Integer;
  SendData : TSendBuf;
  i: Integer;
begin
  FullEncSize := Sizeof( SendData );
  StartPos := 0;
  RemainSize := BufSize;
  while RemainSize > 0 do
  begin
    EncSize := Min( FullEncSize, RemainSize );
    CopyMemory( @SendData, @Buf[StartPos], EncSize );
    EncryptData( SendData, EncSize, Password, False );
    CopyMemory( @Buf[StartPos], @SendData, EncSize );
    RemainSize := RemainSize - EncSize;
    StartPos := StartPos + EncSize;
  end;
end;

class procedure SendFileUtil.DecompressStream(ComStream,
  DesStream: TMemoryStream);
var
  ds: TDecompressionStream;
  num: Integer;
begin
    // ��ȡԴ���Ŀռ���Ϣ
  ComStream.Position := 0;
  ComStream.ReadBuffer(num,SizeOf(num));
  DesStream.SetSize(num);

    // ��ѹ
  ds := TDecompressionStream.Create(ComStream);
  ds.Read(DesStream.Memory^, num);
  ds.Free;
end;

class procedure SendFileUtil.Encrypt(var Buf: TDataBuf; BufSize: Integer;
  Password: string);
var
  RemainSize, FullEncSize, StartPos : Integer;
  EncSize : Integer;
  SendData : TSendBuf;
  i: Integer;
begin
  FullEncSize := Sizeof( SendData );
  StartPos := 0;
  RemainSize := BufSize;
  while RemainSize > 0 do
  begin
    EncSize := Min( FullEncSize, RemainSize );
    CopyMemory( @SendData, @Buf[StartPos], EncSize );
    EncryptData( SendData, EncSize, Password, True );
    CopyMemory( @Buf[StartPos], @SendData, EncSize );
    RemainSize := RemainSize - EncSize;
    StartPos := StartPos + EncSize;
  end;
end;

class procedure SendFileUtil.EncryptData(var Buf: TSendBuf; BufSize: Integer;
  Key: string; IsEncrypt: Boolean);
var
  Key64 : TKey64;
  Context    : TDESContext;
  EncryptChar : Char;
  BlockCount, BlockSize, RemainSize : Integer;
  i, j, StartPos : Integer;
  Block : TDESBlock;
begin
  GenerateLMDKey( Key64, SizeOf(Key64), Key );
  InitEncryptDES( Key64, Context, IsEncrypt );

    // ���ܿ�
  BlockSize := SizeOf( Block );
  BlockCount := ( BufSize div BlockSize );
  for i := 0 to BlockCount - 1 do
  begin
    StartPos := i * BlockSize;
    for j := 0 to BlockSize - 1 do
      Block[j] := Buf[ StartPos + j ];
    EncryptDES(Context, Block);
    for j := 0 to BlockSize - 1 do
      Buf[ StartPos + j ] := Block[j];
  end;

    // ���ܲ����Ĳ���
  StartPos := BlockCount * BlockSize;
  RemainSize := BufSize mod BlockSize;
  for i := 0 to RemainSize - 1 do
  begin
    j := ( i mod Length( Key ) ) + 1;
    EncryptChar := Key[j];
    if IsEncrypt then
      Buf[ StartPos + i ] := ( Buf[ StartPos + i ] + Integer( EncryptChar ) ) mod 256
    else
      Buf[ StartPos + i ] := ( Buf[ StartPos + i ] - Integer( EncryptChar ) ) mod 256
  end;
end;

{ SendFileUtil }

class procedure CopyFileUtil.Deccrypt(var Buf: TDataBuf; BufSize: Integer;
  Password: string);
begin
  EncryptData( Buf, BufSize, Password, False );
end;

class function CopyFileUtil.DecryptStream(Stream: TMemoryStream;
  Password: string): TMemoryStream;
var
  RemainSize : Int64;
  Buf : TDataBuf;
  BufSize, ReadSize : Integer;
begin
  Result := TMemoryStream.Create;
  BufSize := SizeOf( Buf );
  Stream.Position := 0;
  RemainSize := Stream.Size;
  while RemainSize > 0 do
  begin
    ReadSize := Min( RemainSize, BufSize );
      // ����
    Stream.ReadBuffer( Buf, ReadSize );
      // ����
    Deccrypt( Buf, ReadSize, Password );
      // д��
    Result.WriteBuffer( Buf, ReadSize );
    RemainSize := RemainSize - ReadSize;
  end;
  Stream.Free;
end;

class procedure CopyFileUtil.Encrypt(var Buf: TDataBuf; BufSize: Integer;
  Password: string);
begin
  EncryptData( Buf, BufSize, Password, True );
end;

class procedure CopyFileUtil.EncryptData(var Buf: TDataBuf; BufSize: Integer;
  Key: string; IsEncrypt: Boolean);
var
  Key64 : TKey64;
  Context    : TDESContext;
  EncryptChar : Char;
  BlockCount, BlockSize, RemainSize : Integer;
  i, j, StartPos : Integer;
  Block : TDESBlock;
begin
  GenerateLMDKey( Key64, SizeOf(Key64), Key );
  InitEncryptDES( Key64, Context, IsEncrypt );

    // ���ܿ�
  BlockSize := SizeOf( Block );
  BlockCount := ( BufSize div BlockSize );
  for i := 0 to BlockCount - 1 do
  begin
    StartPos := i * BlockSize;
    for j := 0 to BlockSize - 1 do
      Block[j] := Buf[ StartPos + j ];
    EncryptDES(Context, Block);
    for j := 0 to BlockSize - 1 do
      Buf[ StartPos + j ] := Block[j];
  end;

    // ���ܲ����Ĳ���
  StartPos := BlockCount * BlockSize;
  RemainSize := BufSize mod BlockSize;
  for i := 0 to RemainSize - 1 do
  begin
    j := ( i mod Length( Key ) ) + 1;
    EncryptChar := Key[j];
    if IsEncrypt then
      Buf[ StartPos + i ] := ( Buf[ StartPos + i ] + Integer( EncryptChar ) ) mod 256
    else
      Buf[ StartPos + i ] := ( Buf[ StartPos + i ] - Integer( EncryptChar ) ) mod 256
  end;
end;

{ TFolderSearchHandle }

function TFolderSearchHandle.CheckNextSearch: Boolean;
begin
  Result := True;

    // N ���ļ�Сͣһ��
  Inc( SleepCount );
  if SleepCount >= ScanCount_Sleep then
  begin
    Sleep(1);
    SleepCount := 0;

      // 1 ���� ˢ��һ�� �������
    if SecondsBetween( now , RefreshTime ) >= 1 then
    begin
      HandleResultHash; // ������
      ResultFileHash.Clear;
      ResultFolderHash.Clear;

      if getIsStop then // ��������Ͽ�����
        Result := False;
      RefreshTime := Now;
    end;
  end;
end;

constructor TFolderSearchHandle.Create;
begin
  ScanFileHash := TScanFileHash.Create;
  ScanFolderHash := TScanFolderHash.Create;
  RefreshTime := Now;
  SleepCount := 0;
  IsEncrypted := False;
  IsDeleted := False;
end;

destructor TFolderSearchHandle.Destroy;
begin
  ScanFileHash.Free;
  ScanFolderHash.Free;
  inherited;
end;

function TFolderSearchHandle.FindResultHash: Boolean;
var
  p : TScanFilePair;
  ResultFileInfo : TScanFileInfo;
  ParentPath, ChildPath : string;
  FileName : string;
  pf : TScanFolderPair;
  ResultFolderInfo : TScanFolderInfo;
begin
  Result := True;

  ParentPath := MyFilePath.getPath( ResultFolderPath );

    // �����ļ�
  for p in ScanFileHash do
  begin
      // ��������
    if not CheckNextSearch then
    begin
      Result := False;
      Break;
    end;

      // ��ȡԭʼ���ļ���
    FileName := MyFilePath.getOrinalName( IsEncrypted, IsDeleted, p.Value.FileName, PasswordExt );

      // ��������������
    if not MyMatchMask.Check( FileName, SearchName ) then
      Continue;

      // ��ӵ����������
    ChildPath := ParentPath + p.Value.FileName;
    ResultFileInfo := TScanFileInfo.Create( ChildPath );
    ResultFileInfo.SetFileInfo( p.Value.FileSize, p.Value.FileTime );
    ResultFileHash.AddOrSetValue( ChildPath, ResultFileInfo );
  end;
  ScanFileHash.Clear; // �ͷ��ڴ�

    // ��������
  if not Result then
    Exit;

    // ����Ŀ¼
  for pf in ScanFolderHash do
  begin
      // ��������
    if not CheckNextSearch then
    begin
      Result := False;
      Break;
    end;

      // ��������������
    if not MyMatchMask.Check( pf.Value.FolderName, SearchName ) then
      Continue;

      // ��ӵ����������
    ChildPath := ParentPath + pf.Value.FolderName;
    ResultFolderInfo := TScanFolderInfo.Create( ChildPath );
    ResultFolderHash.AddOrSetValue( ChildPath, ResultFolderInfo );
  end;
end;

function TFolderSearchHandle.FindScanHash: Boolean;
var
  LocalFolderFindHandle : TLocalFolderFindHandle;
begin
    // ����Ŀ¼��Ϣ
  LocalFolderFindHandle := TLocalFolderFindHandle.Create;
  LocalFolderFindHandle.SetFolderPath( FolderPath );
  LocalFolderFindHandle.SetSleepCount( SleepCount );
  LocalFolderFindHandle.SetScanFile( ScanFileHash );
  LocalFolderFindHandle.SetScanFolder( ScanFolderHash );
  LocalFolderFindHandle.Update;
  SleepCount := LocalFolderFindHandle.SleepCount;
  LocalFolderFindHandle.Free;

  Result := CheckNextSearch;
end;

function TFolderSearchHandle.getIsStop: Boolean;
begin
  Result := False;
end;

procedure TFolderSearchHandle.LastRefresh;
begin
  HandleResultHash;
end;

function TFolderSearchHandle.SearchChildFolder: Boolean;
var
  ParentPath, ParentResultFolderPath, ChildPath, ChildResultFolderPath : string;
  pf : TScanFolderPair;
  FolderSearchHandle : TFolderSearchHandle;
begin
  Result := True;

  ParentPath := MyFilePath.getPath( FolderPath );
  ParentResultFolderPath := MyFilePath.getPath( ResultFolderPath );

    // ����Ŀ¼
  for pf in ScanFolderHash do
  begin
      // ��������
    if not CheckNextSearch then
    begin
      Result := False;
      Break;
    end;

      // ��ӵ����������
    ChildPath := ParentPath + pf.Value.FolderName;
    ChildResultFolderPath := ParentResultFolderPath + pf.Value.FolderName;
    FolderSearchHandle := getFolderSearchHandle;
    FolderSearchHandle.SetFolderPath( ChildPath );
    FolderSearchHandle.SetSerachName( SearchName );
    FolderSearchHandle.SetResultFolderPath( ChildResultFolderPath );
    FolderSearchHandle.SetEncryptInfo( IsEncrypted, PasswordExt );
    FolderSearchHandle.SetIsDeleted( IsDeleted );
    FolderSearchHandle.SetRefreshTime( RefreshTime );
    FolderSearchHandle.SetSleepCount( SleepCount );
    FolderSearchHandle.SetResultFile( ResultFileHash );
    FolderSearchHandle.SetResultFolder( ResultFolderHash );
    Result := FolderSearchHandle.Update;
    RefreshTime := FolderSearchHandle.RefreshTime;
    SleepCount := FolderSearchHandle.SleepCount;
    FolderSearchHandle.Free;

      // ��������
    if not Result then
      Break;
  end;
end;

procedure TFolderSearchHandle.SetEncryptInfo(_IsEncrypted: Boolean;
  _PasswordExt: string);
begin
  IsEncrypted := _IsEncrypted;
  PasswordExt := _PasswordExt;
end;

procedure TFolderSearchHandle.SetFolderPath(_FolderPath: string);
begin
  FolderPath := _FolderPath;
end;

procedure TFolderSearchHandle.SetIsDeleted(_IsDeleted: Boolean);
begin
  IsDeleted := _IsDeleted;
end;

procedure TFolderSearchHandle.SetRefreshTime(_RefreshTime: TDateTime);
begin
  RefreshTime := _RefreshTime;
end;

procedure TFolderSearchHandle.SetResultFile(_ResultFileHash: TScanFileHash);
begin
  ResultFileHash := _ResultFileHash;
end;

procedure TFolderSearchHandle.SetResultFolder(
  _ResultFolderHash: TScanFolderHash);
begin
  ResultFolderHash := _ResultFolderHash;
end;

procedure TFolderSearchHandle.SetResultFolderPath(_ResultFolderPath: string);
begin
  ResultFolderPath := _ResultFolderPath;
end;

procedure TFolderSearchHandle.SetSerachName(_SearchName: string);
begin
  SearchName := _SearchName;
end;

procedure TFolderSearchHandle.SetSleepCount(_SleepCount: Integer);
begin
  SleepCount := _SleepCount;
end;

function TFolderSearchHandle.Update: Boolean;
begin
    // �����ļ���Ϣ
  Result := FindScanHash and FindResultHash and SearchChildFolder;
end;

{ TNetworkFolderSearchHandle }

constructor TNetworkFolderSearchHandle.Create;
begin
  ResultFileHash := TScanFileHash.Create;
  ResultFolderHash := TScanFolderHash.Create;
end;

destructor TNetworkFolderSearchHandle.Destroy;
begin
  ResultFileHash.Free;
  ResultFolderHash.Free;
  inherited;
end;

function TNetworkFolderSearchHandle.getIsStop: Boolean;
begin
  Result := False;
end;

procedure TNetworkFolderSearchHandle.HandleResult(ResultStr: string);
var
  FindNetworkFolderResultHandle : TFindNetworkFullFolderResultHandle;
begin
    // ��ȡ��Ϣ
  FindNetworkFolderResultHandle := TFindNetworkFullFolderResultHandle.Create( ResultStr );
  FindNetworkFolderResultHandle.SetScanFile( ResultFileHash );
  FindNetworkFolderResultHandle.SetScanFolder( ResultFolderHash );
  FindNetworkFolderResultHandle.Update;
  FindNetworkFolderResultHandle.Free;

    // ��������Ϣ
  HandleResultHash;

    // ����Ѵ�����Ϣ
  ResultFileHash.Clear;
  ResultFolderHash.Clear;
end;

procedure TNetworkFolderSearchHandle.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TNetworkFolderSearchHandle.Update;
var
  ResultStr : string;
  IsStop : Boolean;
begin
  while True do
  begin
    DebugLock.Debug( 'Wait Search Result' );
    ResultStr := MySocketUtil.RevData( TcpSocket );
    if ResultStr = FolderSearchResult_End then // ��������
      Break;
    if ResultStr = '' then  // �Ͽ�������
    begin
      TcpSocket.Disconnect;
      Break;
    end;

      // �����������
    HandleResult( ResultStr );

      // �ж��Ƿ�ֹͣ����
    IsStop := getIsStop;
    MySocketUtil.SendData( TcpSocket, IsStop );

      // ��������
    if IsStop then
      Break;
  end;
end;

{ TNetworkFolderSearchAccessHandle }

function TNetworkFolderSearchAccessHandle.getFolderSearchHandle: TFolderSearchHandle;
var
  NetworkFolderSearchAccessHandle : TNetworkFolderSearchAccessHandle;
begin
  NetworkFolderSearchAccessHandle := TNetworkFolderSearchAccessHandle.Create;
  NetworkFolderSearchAccessHandle.SetTcpSocket( TcpSocket );
  Result := NetworkFolderSearchAccessHandle;
end;

function TNetworkFolderSearchAccessHandle.getIsStop: Boolean;
begin
  Result := StrToBoolDef( MySocketUtil.RevData( TcpSocket ), True );
end;

procedure TNetworkFolderSearchAccessHandle.HandleResultHash;
var
  GetNetworkFullFolderResultStrHandle : TGetNetworkFullFolderResultStrHandle;
  ReadResultStr : string;
begin
    // ���������ת��Ϊ�ַ���
  GetNetworkFullFolderResultStrHandle := TGetNetworkFullFolderResultStrHandle.Create;
  GetNetworkFullFolderResultStrHandle.SetFileHash( ResultFileHash );
  GetNetworkFullFolderResultStrHandle.SetFolderHash( ResultFolderHash );
  ReadResultStr := GetNetworkFullFolderResultStrHandle.get;
  GetNetworkFullFolderResultStrHandle.Free;

    // ���Ͷ�ȡ���
  MySocketUtil.SendData( TcpSocket, ReadResultStr );
end;

procedure TNetworkFolderSearchAccessHandle.LastRefresh;
var
  IsStop : Boolean;
begin
  inherited;

  IsStop := MySocketUtil.RevBoolData( TcpSocket );

  MySocketUtil.SendData( TcpSocket, FolderSearchResult_End );
end;

procedure TNetworkFolderSearchAccessHandle.SetTcpSocket(
  _TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

{ TGetNetworkFullFolderResultStrHandle }

function TGetNetworkFullFolderResultStrHandle.get: string;
var
  FolderStr, FileStr : string;
begin
    // Ŀ¼��Ϣ�б�
  FolderStr := getFolderStr;
  if FolderStr = '' then  // û��Ŀ¼
    FolderStr := Type_Empty;

    // �ļ���Ϣ�б�
  FileStr := getFileStr;
  if FileStr = '' then   // û���ļ�
    FileStr := Type_Empty;

    // ���
  Result := FolderStr + FolderListSplit_Type + FileStr;
end;

function TGetNetworkFullFolderResultStrHandle.getFileStr: string;
var
  GetNetworkFileResultStrHandle : TGetNetworkFileResultStrHandle;
begin
  GetNetworkFileResultStrHandle := TGetNetworkFileResultStrHandle.Create( ScanFileHash );
  Result := GetNetworkFileResultStrHandle.get;
  GetNetworkFileResultStrHandle.Free;
end;

function TGetNetworkFullFolderResultStrHandle.getFolderStr: string;
var
  GetNetworkFolderResultStrHandle : TGetNetworkFolderResultStrHandle;
begin
  GetNetworkFolderResultStrHandle := TGetNetworkFolderResultStrHandle.Create( ScanFolderHash );
  GetNetworkFolderResultStrHandle.SetFolderLevel( 1 );
  Result := GetNetworkFolderResultStrHandle.get;
  GetNetworkFolderResultStrHandle.Free;
end;

procedure TGetNetworkFullFolderResultStrHandle.SetFileHash(
  _ScanFileHash: TScanFileHash);
begin
  ScanFileHash := _ScanFileHash;
end;

procedure TGetNetworkFullFolderResultStrHandle.SetFolderHash(
  _ScanFolderHash: TScanFolderHash);
begin
  ScanFolderHash := _ScanFolderHash;
end;

{ TFolderFindBaseHandle }

procedure TFolderFindBaseHandle.SetFolderPath(_FolderPath: string);
begin
  FolderPath := _FolderPath;
end;

{ TFolderAccessFindHandle }

constructor TFolderAccessFindHandle.Create;
begin
  inherited;
  ScanFileHash := TScanFileHash.Create;
  ScanFolderHash := TScanFolderHash.Create;
end;

destructor TFolderAccessFindHandle.Destroy;
begin
  ScanFileHash.Free;
  ScanFolderHash.Free;
  inherited;
end;

{ TFindNetworkFolderResultHandle }

constructor TFindNetworkFolderResultHandle.Create(_FolderStr: string);
begin
  FolderStr := _FolderStr;
  FolderLevel := 1;
end;

procedure TFindNetworkFolderResultHandle.ReadFolderInfo(FolderInfoStr: string);
var
  FolderInfoSplit : string;
  FolderInfoList : TStringList;
  ScanFolderInfo : TScanFolderInfo;
  FolderName : string;
  IsReaded : Boolean;
  ChildFiles, ChildFolders : string;
  FindNetworkFileResultHandle : TFindNetworkFileResultHandle;
  FindNetworkFolderResultHandle : TFindNetworkFolderResultHandle;
begin
    // ��ͬĿ¼��Ĳ�ͬ�ָ���
  FolderInfoSplit := Format( FolderListSplit_FolderInfo, [ IntToStr( FolderLevel ) ] );

    // ��ȡĿ¼��Ϣ
  FolderInfoList := MySplitStr.getList( FolderInfoStr, FolderInfoSplit );
  if FolderInfoList.Count = FolderInfo_Count then
  begin
      // ��ȡ��Ϣ
    FolderName := FolderInfoList[ Info_FolderName ];
    IsReaded := StrToBoolDef( FolderInfoList[ Info_IsReaded ], False );
    ChildFiles := FolderInfoList[ Info_FolderChildFiles ];
    ChildFolders := FolderInfoList[ Info_FolderChildFolders ];

      // ����Ŀ¼
    ScanFolderInfo := TScanFolderInfo.Create( FolderName );
    ScanFolderInfo.IsReaded := IsReaded;
    ScanFolderHash.AddOrSetValue( FolderName, ScanFolderInfo );

      // Ŀ¼��Ϣ�Ѿ���ȡ
    if IsReaded then
    begin
        // ��ȡ���ļ�
      FindNetworkFileResultHandle := TFindNetworkFileResultHandle.Create( ChildFiles );
      FindNetworkFileResultHandle.SetScanFile( ScanFolderInfo.ScanFileHash );
      FindNetworkFileResultHandle.Update;
      FindNetworkFileResultHandle.Free;

        // ��ȡ��Ŀ¼
      FindNetworkFolderResultHandle := TFindNetworkFolderResultHandle.Create( ChildFolders );
      FindNetworkFolderResultHandle.SetScanFolder( ScanFolderInfo.ScanFolderHash );
      FindNetworkFolderResultHandle.SetFolderLevel( FolderLevel + 1 ); // ��һ��
      FindNetworkFolderResultHandle.Update;
      FindNetworkFolderResultHandle.Free;
    end;
  end;
  FolderInfoList.Free;
end;

procedure TFindNetworkFolderResultHandle.SetFolderLevel(_FolderLevel: Integer);
begin
  FolderLevel := _FolderLevel;
end;

procedure TFindNetworkFolderResultHandle.SetScanFolder(
  _ScanFolderHash: TScanFolderHash);
begin
  ScanFolderHash := _ScanFolderHash;
end;

procedure TFindNetworkFolderResultHandle.Update;
var
  FolderSplit : string;
  FolderList : TStringList;
  i: Integer;
begin
  FolderSplit := Format( FolderListSplit_Folder, [IntToStr( FolderLevel )] );

  FolderList := MySplitStr.getList( FolderStr, FolderSplit );
  for i := 0 to FolderList.Count - 1 do
    ReadFolderInfo( FolderList[i] );
  FolderList.Free;
end;

{ TFindNetworkFolderResultHandle }

constructor TFindNetworkFullFolderResultHandle.Create(_ReadResultStr: string);
begin
  ReadResultStr := _ReadResultStr;
end;

procedure TFindNetworkFullFolderResultHandle.ReadFile;
var
  FindNetworkFileResultHandle : TFindNetworkFileResultHandle;
begin
  FindNetworkFileResultHandle := TFindNetworkFileResultHandle.Create( FileStr );
  FindNetworkFileResultHandle.SetScanFile( ScanFileHash );
  FindNetworkFileResultHandle.Update;
  FindNetworkFileResultHandle.Free;
end;

procedure TFindNetworkFullFolderResultHandle.ReadFolder;
var
  FindNetworkFolderResultHandle : TFindNetworkFolderResultHandle;
begin
  FindNetworkFolderResultHandle := TFindNetworkFolderResultHandle.Create( FolderStr );
  FindNetworkFolderResultHandle.SetScanFolder( ScanFolderHash );
  FindNetworkFolderResultHandle.SetFolderLevel( 1 );
  FindNetworkFolderResultHandle.Update;
  FindNetworkFolderResultHandle.Free;
end;

procedure TFindNetworkFullFolderResultHandle.SetScanFile(
  _ScanFileHash: TScanFileHash);
begin
  ScanFileHash := _ScanFileHash;
end;

procedure TFindNetworkFullFolderResultHandle.SetScanFolder(
  _ScanFolderHash: TScanFolderHash);
begin
  ScanFolderHash := _ScanFolderHash;
end;

procedure TFindNetworkFullFolderResultHandle.Update;
var
  TypeList : TStringList;
begin
  TypeList := MySplitStr.getList( ReadResultStr, FolderListSplit_Type );
  if TypeList.Count = Type_Count then
  begin
    FolderStr := TypeList[ Type_Folder ];
    FileStr := TypeList[ Type_File ];

      // ��ȡ Ŀ¼��Ϣ
    if FolderStr <> Type_Empty then
      ReadFolder;

      // ��ȡ �ļ���Ϣ
    if FileStr <> Type_Empty then
      ReadFile;
  end;
  TypeList.Free;
end;

{ TGetNetworkFolderResultStrHandle }

constructor TGetNetworkFolderResultStrHandle.Create(
  _ScanFolderHash: TScanFolderHash);
begin
  ScanFolderHash := _ScanFolderHash;
  FolderLevel := 1;
end;

function TGetNetworkFolderResultStrHandle.get: string;
var
  FolderStr, FolderInfoStr: string;
  ps : TScanFolderPair;
  FolderSplit, FolderInfoSplit : string;
begin
    // ÿһ��Ŀ¼�ķָ�������һ��
  FolderSplit := Format( FolderListSplit_Folder, [IntToStr( FolderLevel )] );
  FolderInfoSplit := Format( FolderListSplit_FolderInfo, [IntToStr( FolderLevel )] );

    // Ŀ¼��Ϣ
  FolderStr := '';
  for ps in ScanFolderHash do
  begin
    if FolderStr <> '' then
      FolderStr := FolderStr + FolderSplit;
    FolderInfoStr := ps.Value.FolderName + FolderInfoSplit;
    FolderInfoStr := FolderInfoStr + BoolToStr( ps.Value.IsReaded ) + FolderInfoSplit;
    FolderInfoStr := FolderInfoStr + getChildFileStr( ps.Value.FolderName ) + FolderInfoSplit;
    FolderInfoStr := FolderInfoStr + getChildFolderStr( ps.Value.FolderName );
    FolderStr := FolderStr + FolderInfoStr;
  end;

    // û��Ŀ¼�ı�־
  if FolderStr = '' then
    FolderStr := Type_Empty;

    // ����
  Result := FolderStr;
end;

function TGetNetworkFolderResultStrHandle.getChildFileStr(
  FolderName: string): string;
var
  GetNetworkFileResultStrHandle : TGetNetworkFileResultStrHandle;
begin
  GetNetworkFileResultStrHandle := TGetNetworkFileResultStrHandle.Create( ScanFolderHash[ FolderName ].ScanFileHash );
  Result := GetNetworkFileResultStrHandle.get;
  GetNetworkFileResultStrHandle.Free;
end;

function TGetNetworkFolderResultStrHandle.getChildFolderStr(
  FolderName: string): string;
var
  GetNetworkFolderResultStrHandle : TGetNetworkFolderResultStrHandle;
begin
  GetNetworkFolderResultStrHandle := TGetNetworkFolderResultStrHandle.Create( ScanFolderHash[ FolderName ].ScanFolderHash );
  GetNetworkFolderResultStrHandle.SetFolderLevel( FolderLevel + 1 ); // ��һ��
  Result := GetNetworkFolderResultStrHandle.get;
  GetNetworkFolderResultStrHandle.Free;
end;

procedure TGetNetworkFolderResultStrHandle.SetFolderLevel(
  _FolderLevel: Integer);
begin
  FolderLevel := _FolderLevel;
end;

{ TScanResultAddZipInfo }

procedure TScanResultAddZipInfo.SetTotalSize(_TotalSize: Int64);
begin
  TotalSize := _TotalSize;
end;

procedure TScanResultAddZipInfo.SetZipStream(_ZipStream: TMemoryStream);
begin
  ZipStream := _ZipStream;
end;

{ TFileUnpackHandle }

constructor TFileUnpackHandle.Create(_ZipStream: TMemoryStream);
begin
  ZipStream := _ZipStream;
  RefreshCopyReader := TRefreshCopyReader.Create;
end;

destructor TFileUnpackHandle.Destroy;
begin
  RefreshCopyReader.Free;
  inherited;
end;

procedure TFileUnpackHandle.SetFileUnpackOperator(
  _FileUnpackOperator: TFileUnpackOperator);
begin
  FileUnpackOperator := _FileUnpackOperator;
  FileUnpackOperator.SetFileUnpackHandle( Self );
end;

procedure TFileUnpackHandle.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

function TFileUnpackHandle.Update: Boolean;
var
  ZipFile : TZipFile;
  FileName, FilePath : string;
  FileDate : TDateTime;
  i: Integer;
  TempStream : TStream;
  ZipHeader : TZipHeader;
  DataBuf : TDataBuf;
  ReadSize : Integer;
  FileStream : TFileStream;
begin
  Result := False;

    // ��ѹ�ļ�
  ZipFile := TZipFile.Create;
  try
    ZipStream.Position := 0;
    ZipFile.Open( ZipStream, zmRead );
    try
      Result := True;
      for i := 0 to ZipFile.FileCount - 1 do
      begin
          // ����
        if not FileUnpackOperator.ReadIsNextCopy then
          Break;

        // ��ʱˢ��
        if RefreshCopyReader.ReadIsRefresh then
          FileUnpackOperator.RefreshCompletedSpace;

        try
            // ��ȡһ�� ѹ��Buf
          ZipFile.Read( i, TempStream, ZipHeader );
          ReadSize := TempStream.Read( DataBuf, ZipHeader.UncompressedSize );
          TempStream.Free;

            // ��ȡ�ļ�·��
          FileName := ZipHeader.FileName;
          FileName := StringReplace( FileName, '/', '\', [rfReplaceAll] );
          FilePath := MyFilePath.getPath( SavePath ) + FileName;

            // �����ļ�
          FileStream := TFileStream.Create( FilePath, fmCreate or fmShareDenyNone );
          FileStream.Write( DataBuf, ReadSize );
          FileStream.Free;

            // �����ļ��޸�ʱ��
          FileDate := FileDateToDateTime( ZipHeader.ModifiedDateTime );
          MyFileSetTime.SetTime( FilePath, FileDate );

            // ˢ�¿ռ���ٶ���Ϣ
          RefreshCopyReader.AddCompletedSize( ZipHeader.UncompressedSize );
          FileUnpackOperator.AddSpeedSpace( ZipHeader.UncompressedSize );
        except
          Result := False; // ��ѹ����
        end;
      end;
      Result := Result and ( i = ZipFile.FileCount ); // �����Ƿ�ȫ����ѹ

      FileUnpackOperator.RefreshCompletedSpace; // ����ˢ��
    except
    end;
    ZipFile.Close;
  except
  end;
  ZipFile.Free;
end;

{ TScanResultAddFileInfo }

procedure TScanResultAddFileInfo.SetFileSize(_FileSize: Int64;
  _FileTime : TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

{ TLocaleletedFolderFindDHandle }

constructor TLocalFolderFilterFindHandle.Create;
begin
  inherited;
  IsEncrypted := False;
  IsEdition := False;
  FileEditionHash := nil;
end;

function TLocalFolderFilterFindHandle.CreateFolderFindHandle: TLocalFolderFindHandle;
var
  LocalFolderAdvanceFindHandle : TLocalFolderFilterFindHandle;
begin
  LocalFolderAdvanceFindHandle := TLocalFolderFilterFindHandle.Create;
  LocalFolderAdvanceFindHandle.SetEncryptedInfo( IsEncrypted, PasswordExt );
  LocalFolderAdvanceFindHandle.SetEditionInfo( IsEdition, FileEditionHash );
  Result := LocalFolderAdvanceFindHandle;
end;

function TLocalFolderFilterFindHandle.IsFileFilter(FilePath: string;
  sch: TSearchRec): Boolean;
var
  OriginalPath : string;
  EditionNum : Integer;
begin
  Result := True;
  if IsEncrypted and ( Pos( PasswordExt, FilePath ) <= 0 ) then
    Exit;
  if IsEdition then  // �Ƿ���Ҫָ���汾
  begin
    OriginalPath := MyFilePath.getOrinalName( IsEncrypted, True, FilePath, PasswordExt );
    if Assigned( FileEditionHash ) and FileEditionHash.ContainsKey( OriginalPath ) then  // ��Ҫ�ָ�ָ���汾
    begin
      EditionNum := MyFilePath.getDeletedEdition( FilePath );
      if EditionNum <> FileEditionHash[ OriginalPath ].EditionNum then
        Exit;
    end
    else   // �ָ����°汾
    if Pos( Sign_Deleted + '1', FilePath ) <= 0 then
      Exit;
  end;
  Result := False;
end;

procedure TLocalFolderFilterFindHandle.SetEncryptedInfo(_IsEncrypted: Boolean;
  _PasswordExt: string);
begin
  IsEncrypted := _IsEncrypted;
  PasswordExt := _PasswordExt;
end;

procedure TLocalFolderFilterFindHandle.SetEditionInfo(
  _IsEdition : Boolean; _FileEditionHash: TFileEditionHash);
begin
  IsEdition := _IsEdition;
  FileEditionHash := _FileEditionHash;
end;


{ TSpeedLimiter }


procedure TRefreshSendReader.AddCompletedSize(CompletedSize: Int64);
begin
  LastCompletedSize := LastCompletedSize + CompletedSize;
end;

constructor TRefreshSendReader.Create;
begin
  LastRefreshTime := Now;
  LastCompletedSize := 0;
end;

function TRefreshSendReader.ReadLastCompletedSize: Int64;
begin
  Result := LastCompletedSize;
  LastCompletedSize := 0;
end;

function TRefreshSendReader.ReadIsRefresh: Boolean;
begin
  Result := SecondsBetween( Now, LastRefreshTime ) >= 1;  // 1 ���� ˢ��һ�ν���
  if Result then
    LastRefreshTime := Now;
end;

{ TNetworkFileSendBaseHandle }

procedure TNetworkSendBaseHandle.AddSendedSpace(CompletedSpace: Integer);
begin
  RefreshSendReader.AddCompletedSize( CompletedSpace );
  SendFileOperator.AddSpeedSpace( CompletedSpace );
end;

constructor TNetworkSendBaseHandle.Create;
begin
  ReadStreamPos := 0;
  IsEncrypt := False;
  IsStopTransfer := False;
  IsLostConn := False;
  IsZip := True;
  BufStream := TMemoryStream.Create;
  RefreshSendReader := TRefreshSendReader.Create;
  WatchRevThread := TWatchRevThread.Create;
end;

destructor TNetworkSendBaseHandle.Destroy;
begin
  WatchRevThread.Free;
  RefreshSendReader.Free;
  BufStream.Free;
  inherited;
end;

function TNetworkSendBaseHandle.ReadBufStream: Integer;
var
  HeartBeatTime : TDateTime;
  RemainSize : Int64;
  TempStream, ActivateStream : TMemoryStream;
  i, BufSize, ReadSize : Integer;
  FullBufSize, TotalReadSize : Integer;
  Buf : TDataBuf;
begin
  Result := 0;

  TempStream := TMemoryStream.Create;
  BufStream.Clear;

    // �Ƿ�ѹ��
  ActivateStream := BufStream;
  if ReadIsZip and IsZip then
    ActivateStream := TempStream;

  try
      // ��ȡ 8M ����
    HeartBeatTime := Now;
    FullBufSize := SizeOf( Buf );
    TotalReadSize := 0;
    RemainSize := ReadStream.Size - ReadStream.Position;
    for i := 0 to 15 do
    begin
      if RemainSize <= 0 then // ��ȡ���
        Break;

        // Ԥ���ȡ�ռ�
      BufSize := Min( FullBufSize, RemainSize );

        // ��ȡ�ļ�
      ReadSize := ReadStream.Read( Buf, BufSize );
      if ( ReadSize <= 0 ) and ( ReadSize <> BufSize ) then // ��ȡ����
        Exit;

        // ����
      if IsEncrypt then
        SendFileUtil.Encrypt( Buf, ReadSize, EncPassword );

        // д���ڴ�
      ActivateStream.WriteBuffer( Buf, ReadSize );

        // ���ͳ��
      TotalReadSize := TotalReadSize + ReadSize;
      RemainSize := RemainSize - ReadSize;

        // ��ʱ��������
      HeartBeatReceiver.CheckSend( TcpSocket, HeartBeatTime );
    end;

      // �Ƿ�ѹ��
    if ReadIsZip and IsZip then
      SendFileUtil.CompressStream( TempStream, BufStream );

      // ����
    Result := TotalReadSize;
  except
    Result := 0;
  end;

  TempStream.Free;
end;

function TNetworkSendBaseHandle.ReadIsCreateReadStream: Boolean;
begin
  Result := CreateReadStream;
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_IsCreateReadSuccess, Result );
end;

function TNetworkSendBaseHandle.ReadIsCreateWriteStrem: Boolean;
begin
  Result := MySocketUtil.RevJsonBool( TcpSocket );
end;

function TNetworkSendBaseHandle.ReadIsEnoughSpace: Boolean;
var
  IsEnouthSpaceStr : string;
  IsEnouthSpace : Boolean;
begin
  Result := False;

    // ���Ͷ�������Ϣ
  ReadStream.Position := ReadStreamPos;
  ReadStreamSize := ReadStream.Size;
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_ReadFileSize, ReadStreamSize );
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_ReadFilePos, ReadStreamPos );

    // ��ȡ�Ƿ����㹻�Ŀռ�
  IsEnouthSpaceStr := MySocketUtil.RevJsonStr( TcpSocket );
  if IsEnouthSpaceStr = '' then  // �Ͽ�����
  begin
    TcpSocket.Disconnect;
    SendFileOperator.LostConnectError;
    Exit;
  end;

    // �Ƿ����㹻�Ŀռ�
  Result := StrToBoolDef( IsEnouthSpaceStr, False );
  if not Result then
    SendFileOperator.RevFileLackSpaceHandle;
end;

function TNetworkSendBaseHandle.ReadIsNextSend( IsSuccessSend : Boolean ): Boolean;
begin
  Result := False;

    // ֹͣ����
  if IsStopTransfer or WatchRevThread.IsRevStop then
  begin
    TcpSocket.Disconnect;
    Exit;
  end;

    // ʧȥ����
  if IsLostConn or WatchRevThread.IsRevLostConn then
  begin
    TcpSocket.Disconnect;
    SendFileOperator.LostConnectError;
    Exit;
  end;

    // δ֪�Ĵ���, δ�����ط����ļ�
  if not IsSuccessSend then
  begin
    TcpSocket.Disconnect;
    SendFileOperator.TransferFileError;
    Exit;
  end;

    // �Ƿ��������
  Result := True;
end;

function TNetworkSendBaseHandle.ReadIsStopTransfer: Boolean;
var
  IsStopSend, IsStopRev : Boolean;
begin
    // ��ȡ�Ƿ�ֹͣ����
  IsStopSend := not SendFileOperator.ReadIsNextSend;

    // �����Ƿ�ֹͣ���Է�
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_SendFileCompletedNow, IsStopSend );

    // �����Ƿ�ֹͣ����
  IsStopRev := WatchRevThread.IsRevStop;

  Result := IsStopSend or IsStopRev;
end;

function TNetworkSendBaseHandle.ReadIsZip: Boolean;
begin
  Result := True;
end;

function TNetworkSendBaseHandle.ReadSendBlockSize: Int64;
begin
  Result := WatchRevThread.RevSpeed;
  if SendFileOperator.ReadIsLimitSpeed then
    Result := Min( Result, SendFileOperator.ReadLimitSpeed );
  Result := Max( Result, 1 * Size_KB ); // ���� 1 KB
end;

function TNetworkSendBaseHandle.RevWriteSize(ReadSize: Integer): Boolean;
var
  WriteSizeStr : string;
  WriteSize : Integer;
  IsEnouthSpace : Boolean;
begin
  Result := True;

    // ��ȡ �Է�д��Ŀռ���Ϣ
  WriteSizeStr := HeartBeatReceiver.CheckReceive( TcpSocket );
  if WriteSizeStr = '' then // ����
  begin
    SendFileOperator.LostConnectError;
    Result := False;
    Exit;
  end;
  WriteSizeStr := MySocketUtil.ReadMsgToMsgStr( WriteSizeStr );

    // ��Ҫ���͵Ŀռ�һ��
  WriteSize := StrToInt( WriteSizeStr );
  if WriteSize = ReadSize then
    Exit;

    // ��ȡ�Ƿ���Ϊ�ռ䲻��
  IsEnouthSpace := MySocketUtil.RevBoolData( TcpSocket );
  if not IsEnouthSpace then
    SendFileOperator.RevFileLackSpaceHandle  // �ռ䲻��
  else
    SendFileOperator.WriteFileError; // д������

  Result := False;
end;

function TNetworkSendBaseHandle.SendBufStream: Boolean;
var
  RemainSize, TotalSendSize, SendRemainSize : Int64;
  SendSize, SendPos : Integer;
begin
  try
      // ��ʼ����Ϣ
    BufStream.Position := 0;
    RemainSize := BufStream.Size;
    while RemainSize > 0 do
    begin
        // ��ʱˢ������ɿռ���Ϣ
      if RefreshSendReader.ReadIsRefresh then
        SendFileOperator.RefreshCompletedSpace;

        // ��ȡ �������ݵĴ�С
      TotalSendSize := Min( ReadSendBlockSize, RemainSize );
      TotalSendSize := Min( TotalSendSize, SIzeOf( TotalSendDataBuf ) );
      MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_SendFileSizeNow, TotalSendSize );

        // �Ͽ�����
      if TotalSendSize <= 0 then
        IsLostConn := True;

        // ��ȡ Ҫ���͵�����
      BufStream.ReadBuffer( TotalSendDataBuf, TotalSendSize );

        // ��������
      DebugLock.DebugFile( 'Send Data Buf Start', ReadSendPath );
      SendRemainSize := TotalSendSize;
      SendPos := 0;
      while SendRemainSize > 0 do
      begin
          // ���Ʒ��͵�����
        CopyMemory( @SendDataBuf, @TotalSendDataBuf[SendPos], SendRemainSize );

          // ��������
        SendSize := TcpSocket.SendBuf( SendDataBuf, SendRemainSize );
        if ( SendSize = SOCKET_ERROR ) or ( ( SendSize <= 0 ) and ( SendRemainSize <> 0 ) ) then // Ŀ��Ͽ�����
        begin
          IsLostConn := True;
          Break;
        end;
        SendRemainSize := SendRemainSize - SendSize;
        SendPos := SendPos + SendSize;
      end;
      TotalSendSize := TotalSendSize - SendRemainSize;
      DebugLock.DebugFile( 'Send Data Buf Stop', IntToStr( TotalSendSize ) );

        // ����ʣ���λ��
      RemainSize := RemainSize - TotalSendSize;
      AddSendedSpace( TotalSendSize );  // ͳ�Ʒ�����Ϣ

        // �ѶϿ�����
      if IsLostConn or WatchRevThread.IsRevLostConn then
        Break;

        //��ֹͣ����
      if ReadIsStopTransfer then
      begin
        IsStopTransfer := True;
        Break;
      end;
    end;

      // ���� ���͵Ŀռ���Ϣ
    Result := RemainSize = 0;
  except
    Result := False;
  end;
end;

procedure TNetworkSendBaseHandle.SendFileIncompleted;
begin

end;

procedure TNetworkSendBaseHandle.FileSendIniHandle;
begin

end;

function TNetworkSendBaseHandle.FileSendHandle: Boolean;
var
  RemainSize : Int64;
  ReadSize, BufSize, ZipSize : Integer;
  IsReadOK, IsSendSuccess, IsWriteSuccess : Boolean;
begin
  Result := False;

  try
      // ʣ��ռ�
    RemainSize := ReadStreamSize - ReadStreamPos;
    while RemainSize > 0 do
    begin
        // ͳ��Ҫ���͵Ŀռ�
      DebugLock.DebugFile( 'Read Stream Data', ReadSendPath );
      ReadSize := ReadBufStream;  // ��ȡ 8M ���ݣ�����ʵ�ʶ�ȡ�Ŀռ���Ϣ

        // ��ȡ�ļ� �Ƿ�ɹ�
      IsReadOK := ReadSize > 0;
      MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_FileReadStatus, IsReadOK );
      if not IsReadOK then // ��ȡ����
      begin
        SendFileOperator.ReadFileError; // ��������
        Break;
      end;

        // ���� �ļ���ȡ�ռ�
      MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_FileReadSize, ReadSize );

        // ���� �ļ����Ϳռ�
      BufSize := BufStream.Size;
      MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_FileSendSize, BufSize );

        // ���� 8M ����
      DebugLock.DebugFile( 'Send Stream Data', ReadSendPath );
      WatchRevThread.StartWatch;
      IsSendSuccess := SendBufStream;
      WatchRevThread.StopWatch;

        // �Ƿ�����Ͽ� �� �Ƿ��������
      if not ReadIsNextSend( IsSendSuccess ) then
        Break;

        // д��ʧ��
      DebugLock.DebugFile( 'Rev Write Size', ReadSendPath );
      IsWriteSuccess := RevWriteSize( ReadSize );
      if not IsWriteSuccess then
        Break;

        // ��� ѹ���ռ�
      ZipSize := ReadSize - BufSize;
      if ZipSize <> 0 then
        AddSendedSpace( ZipSize );

        // �����ѷ��͵��ļ�λ��
      RemainSize := RemainSize - ReadSize;
      ReadStreamPos := ReadStreamPos + ReadSize;
    end;

      // ����ˢ��
    SendFileOperator.RefreshCompletedSpace;

      // �Ƿ������
    Result := RemainSize <= 0;
  except
  end;
end;

procedure TNetworkSendBaseHandle.SetEncryptInfo(_IsEncrypt: Boolean;
  _EncPassword: string);
begin
  IsEncrypt := _IsEncrypt;
  EncPassword := _EncPassword;
end;

procedure TNetworkSendBaseHandle.SetIsZip(_IsZip: Boolean);
begin
  IsZip := _IsZip;
end;

procedure TNetworkSendBaseHandle.SetReadStreamPos(_ReadStreamPos: Int64);
begin
  ReadStreamPos := _ReadStreamPos;
end;

procedure TNetworkSendBaseHandle.SetSendFileOperator(
  _SendFileOperator: TSendFileOperator);
begin
  SendFileOperator := _SendFileOperator;
  SendFileOperator.SetNetworkSendBaseHandle( Self );
  WatchRevThread.SetSendFileOperator( SendFileOperator );
end;

procedure TNetworkSendBaseHandle.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
  WatchRevThread.SetTcpSocket( TcpSocket );
end;

function TNetworkSendBaseHandle.Update: Boolean;
begin
  Result := False;

    // ����������
  if not ReadIsCreateReadStream then
  begin
    SendFileOperator.ReadFileError;
    Exit;
  end;

      // �Ƿ����㹻�Ŀռ� �� �ѶϿ�����
  if not ReadIsEnoughSpace then
    Exit;

    // ����д����
  if not ReadIsCreateWriteStrem then
  begin
    SendFileOperator.WriteFileError;
    Exit;
  end;

    // ��ʼ���ļ�����
  FileSendIniHandle;

    // �Ƿ�ѹ���ļ�
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_IsZipFile, IsZip );

    // �����ļ�
  if not FileSendHandle then
  begin
    SendFileIncompleted;
    Exit;
  end;

  Result := True;
end;

{ TTransferErrorHandler }

procedure TSendFileOperator.AddSpeedSpace(SendSize: Integer);
begin

end;

procedure TSendFileOperator.LostConnectError;
begin

end;

procedure TSendFileOperator.MarkContinusSend;
begin

end;

procedure TSendFileOperator.ReadFileError;
begin

end;

function TSendFileOperator.ReadFilePath: string;
begin
  Result := NetworkSendBaseHandle.ReadSendPath;
end;

function TSendFileOperator.ReadFilePos: Int64;
begin
  Result := NetworkSendBaseHandle.ReadStreamPos;
end;

function TSendFileOperator.ReadFileSize: Int64;
begin
  Result := NetworkSendBaseHandle.ReadStreamSize;
end;

function TSendFileOperator.ReadFileTime: TDateTime;
begin
  Result := Now;
  if not ( NetworkSendBaseHandle is TNetworkSendFileHandle ) then
    Exit;

  Result := ( NetworkSendBaseHandle as TNetworkSendFileHandle ).SendFileTime;
end;

function TSendFileOperator.ReadIsLimitSpeed: Boolean;
begin
  Result := False;
end;

function TSendFileOperator.ReadIsNextSend: Boolean;
begin
  Result := True;
end;

function TSendFileOperator.ReadLastCompletedSize: Int64;
begin
  Result := NetworkSendBaseHandle.RefreshSendReader.ReadLastCompletedSize;
end;

function TSendFileOperator.ReadLimitSpeed: Int64;
begin
  Result := 0;
end;

procedure TSendFileOperator.RefreshCompletedSpace;
begin

end;

procedure TSendFileOperator.RevFileLackSpaceHandle;
begin

end;

procedure TSendFileOperator.SetNetworkSendBaseHandle(
  _NetworkSendBaseHandle: TNetworkSendBaseHandle);
begin
  NetworkSendBaseHandle := _NetworkSendBaseHandle;
end;

procedure TSendFileOperator.TransferFileError;
begin

end;

procedure TSendFileOperator.WriteFileError;
begin

end;

{ TNetworkFileSendHandle1 }

procedure TNetworkSendFileHandle.SendFileIncompleted;
begin
  SendFileOperator.MarkContinusSend;
end;

function TNetworkSendFileHandle.CreateReadStream: Boolean;
begin
    // �������ļ���
  try
    ReadStream := TFileStream.Create( SendFilePath, fmOpenRead or fmShareDenyNone );
    Result := ReadStream.Size = MyFileInfo.getFileSize( SendFilePath );
  except
    ReadStream := nil;
    Result := False;
  end;
end;

destructor TNetworkSendFileHandle.Destroy;
begin
  try   // �ͷŶ�����
    if Assigned( ReadStream ) then
      ReadStream.Free;
  except
  end;
  inherited;
end;

procedure TNetworkSendFileHandle.FileSendIniHandle;
begin
  SendFileTime := MyFileInfo.getFileLastWriteTime( SendFilePath );
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_FileTime, MyRegionUtil.ReadRemoteTimeStr( SendFileTime ) );
end;

function TNetworkSendFileHandle.ReadIsZip: Boolean;
begin
  Result := not MyFilePath.getIsZip( SendFilePath );
end;

function TNetworkSendFileHandle.ReadSendPath: string;
begin
  Result := SendFilePath;
end;

procedure TNetworkSendFileHandle.SetSendFilePath(_SendFilePath: string);
begin
  SendFilePath := _SendFilePath;
end;

{ TNetworkSendStreamHandle }

function TNetworkSendStreamHandle.CreateReadStream: Boolean;
begin
  ReadStream := SendStream;
  Result := True;
end;

function TNetworkSendStreamHandle.ReadIsZip: Boolean;
begin
  Result := True;
end;

function TNetworkSendStreamHandle.ReadSendPath: string;
begin
  Result := 'bc_send_zip';
end;

procedure TNetworkSendStreamHandle.SetSendStream(_SendStream: TMemoryStream);
begin
  SendStream := _SendStream;
end;

{ TNetworkReceiveBaseHandle }

procedure TNetworkReceiveBaseHandle.AddRecvedSize(RevSize: Integer);
begin
  RefreshRevReader.AddSpace( RevSize );
  RecieveFileOperator.AddSpeedSpace( RevSize );
end;

constructor TNetworkReceiveBaseHandle.Create;
begin
  IsDecrypt := False;
  IsStopTransfer := False;
  IsLostConn := False;
  BufStream := TMemoryStream.Create;
  RefreshRevReader := TRefreshRevReader.Create;
end;

destructor TNetworkReceiveBaseHandle.Destroy;
begin
  BufStream.Free;
  RefreshRevReader.Free;
  inherited;
end;

function TNetworkReceiveBaseHandle.FileReceiveHandle: Boolean;
var
  RevStr : string;
  IsReadOK, IsSuccessRev, IsSuccessWrite : Boolean;
  ReaminSize : Int64;
  ReadSize, BufSize, ReceiveSize, WriteSize, ZipSize : Integer;
begin
  Result := False;

  try
    ReaminSize := WriteStreamSize - WriteStreamPos;
    while ReaminSize > 0 do
    begin
        // ��ȡ ʧ��
      RevStr := HeartBeatReceiver.CheckReceive( TcpSocket );
      RevStr := MySocketUtil.ReadMsgToMsgStr( RevStr );
      IsReadOK := StrToBoolDef( RevStr, False );
      if not IsReadOK then
      begin
        RecieveFileOperator.ReadFileError; // ���ļ�����
        Break;
      end;

        // ��ȡ ��ȡ�ļ��ռ�
      ReadSize := MySocketUtil.RevJsonInt( TcpSocket );

        // ��ȡ �����ļ��ռ�
      BufSize := MySocketUtil.RevJsonInt( TcpSocket );

        // ���� �ļ�
      DebugLock.DebugFile( 'Rev Stream Data', ReadReceivePath );
      BufStream.Clear;
      IsSuccessRev := ReceiveBufStream( BufSize );

        // �Ƿ�����Ͽ� ,  �Ƿ��������
      if not ReadIsNextRev( IsSuccessRev ) then
        Break;

        // д��
      DebugLock.DebugFile( 'Write Stream Data', ReadReceivePath );
      WriteSize := WriteBufStream;

        // ����д��ռ�
      IsSuccessWrite := SendWriteSize( WriteSize, ReadSize );
      if not IsSuccessWrite then
        Break;

        // ˢ��ѹ���ռ�
      ZipSize := WriteSize - BufSize;
      if ZipSize <> 0 then
        AddRecvedSize( ZipSize );

        // �ƶ��ļ�λ��
      ReaminSize := ReaminSize - WriteSize;
      WriteStreamPos := WriteStreamPos + WriteSize;
    end;

       // ����ˢ�� ��ɿռ���Ϣ
    RecieveFileOperator.RefreshCompletedSpace;

      // �Ƿ�ȫ������
    Result := ReaminSize <= 0;
  except
  end;
end;

procedure TNetworkReceiveBaseHandle.FileRevceiveIniHandle;
begin

end;

function TNetworkReceiveBaseHandle.ReadIsCreateReadStream: Boolean;
var
  IsCreaterStr : string;
begin
  Result := False;

  IsCreaterStr := MySocketUtil.RevJsonStr( TcpSocket );
  if IsCreaterStr = '' then  // �����ѶϿ�
  begin
    TcpSocket.Disconnect;
    RecieveFileOperator.LostConnectError;
    Exit;
  end;

    // �������Ƿ�ɹ�
  Result := StrToBoolDef( IsCreaterStr, False );
  if not Result then
    RecieveFileOperator.ReadFileError;
end;

function TNetworkReceiveBaseHandle.ReadIsCreateWriteStrem: Boolean;
begin
  Result := CreateWriteStream;
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_IsWriteSuccess, Result );
end;

function TNetworkReceiveBaseHandle.ReadIsEnoughSpace: Boolean;
begin
    // ��ȡд������Ϣ
  WriteStreamSize := MySocketUtil.RevJsonInt64( TcpSocket );
  WriteStreamPos := MySocketUtil.RevJsonInt64( TcpSocket );

    // �ж��Ƿ����㹻�Ŀռ�
  Result := getIsEnouthSpace;
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_IsEnouthSpace, Result );
end;

function TNetworkReceiveBaseHandle.ReadIsNextRev( IsSuccessRev : Boolean ): Boolean;
begin
  Result := False;

    // ֹͣ����
  if IsStopTransfer then
  begin
    TcpSocket.Disconnect;
    Exit;
  end;

    // ʧȥ����
  if IsLostConn then
  begin
    TcpSocket.Disconnect;
    RecieveFileOperator.LostConnectError;
    Exit;
  end;

    // δ֪�Ĵ��� û�����������ļ�
  if not IsSuccessRev then
  begin
    TcpSocket.Disconnect;
    RecieveFileOperator.TransferFileError;
    Exit;
  end;

  Result := True;
end;

function TNetworkReceiveBaseHandle.ReadIsStopTransfer: Boolean;
var
  IsStopSend, IsStopRev : Boolean;
begin
    // ���շ��ͷ��Ƿ�ֹͣ
  IsStopSend := MySocketUtil.RevJsonBool( TcpSocket );

    // ��ȡ�Ƿ�ֹͣ����
  IsStopRev := not RecieveFileOperator.ReadIsNextReceive;
  if IsStopRev then  // ֹͣ��������֪ͨ
    MySocketUtil.SendData( TcpSocket, ReceiveStatus_Stop );

    // �����Ƿ�ֹͣ����
  Result := IsStopSend or IsStopRev;
end;

function TNetworkReceiveBaseHandle.ReceiveBufStream(BufSize: Integer): Boolean;
var
  RemainSize, RevSizeTotal, RevRemainSize : Int64;
  RevSize, RevPos : Integer;
  RevBlockSize : Int64;
begin
  try
      // ��ʼ����Ϣ
    RemainSize := BufSize;
    while RemainSize > 0 do
    begin
      RefreshRevReader.StartRev; // ��������ٶ�

        // ��ʱˢ������ɿռ�
      if RefreshRevReader.ReadIsRefresh then
        RecieveFileOperator.RefreshCompletedSpace;

        // �������ݵ��ܿռ�
      RevSizeTotal := MySocketUtil.RevJsonInt64( TcpSocket );
      if RevSizeTotal <= 0 then // �ѶϿ�
        IsLostConn := True;

        // ��ʼ��������
      DebugLock.DebugFile( 'Start Rev Data Buf ' + IntToStr( RevSizeTotal ), ReadReceivePath );
      RevRemainSize := RevSizeTotal;
      RevPos := 0;
      while RevRemainSize > 0 do
      begin
        RevSize := MySocketUtil.RevBuf( TcpSocket, SendDataBuf, RevRemainSize );
        if ( RevSize = SOCKET_ERROR ) or ( ( RevSize = 0 ) and ( RevRemainSize <> 0 ) ) then // Ŀ��Ͽ�����
        begin
          IsLostConn := True;
          Break;
        end;
        CopyMemory( @TotalSendDataBuf[RevPos], @SendDataBuf, RevSize );
        RevRemainSize := RevRemainSize - RevSize;
        RevPos := RevPos + RevSize;
      end;
      RevSizeTotal := RevSizeTotal - RevRemainSize;
      DebugLock.DebugFile( 'Stop Rev Data Buf ' + IntToStr( RevSizeTotal ), ReadReceivePath );

        // ���ý��յ�����
      BufStream.WriteBuffer( TotalSendDataBuf, RevSizeTotal );

        // ����ʣ���λ��
      RemainSize := RemainSize - RevSizeTotal;
      AddRecvedSize( RevSizeTotal );

        // �����ѶϿ�
      if IsLostConn then
        Break;

        // ��ֹͣ����
      if ReadIsStopTransfer then
      begin
        IsStopTransfer := True;
        Break;
      end;

        // ˢ�½����ٶ�
      SendRevSpeed( RefreshRevReader.StopRev( RevSizeTotal ) );
    end;

      // ���ؽ��յĿռ���Ϣ
    Result := RemainSize = 0;
  except
    Result := False;
  end;

    // ���������
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_ReceiveStatus, ReceiveStatus_Completed );
end;

procedure TNetworkReceiveBaseHandle.ReceiveFileCompleted;
begin

end;

procedure TNetworkReceiveBaseHandle.ReceiveFileIncompleted;
begin

end;

procedure TNetworkReceiveBaseHandle.SendRevSpeed( RevSpeed : Int64 );
begin
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_ReceiveStatus, ReceiveStatus_Speed );
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_ReceiveSpeed, RevSpeed );
end;

function TNetworkReceiveBaseHandle.SendWriteSize(WriteSize,
  ReadSize: Integer): Boolean;
var
  IsEnoughSpace : Boolean;
begin
  Result := True;

  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_FileWriteSize, WriteSize );
  if WriteSize = ReadSize then  // д��ɹ�
    Exit;

      // �Ƿ����㹻�Ŀռ�
  IsEnoughSpace :=  getIsEnouthSpace;
  MySocketUtil.SendData( TcpSocket, IsEnoughSpace );
  if not IsEnoughSpace then
    RecieveFileOperator.RevFileLackSpaceHandle  // �ռ䲻��
  else
    RecieveFileOperator.WriteFileError; // д�ļ�����

  Result := False;
end;

procedure TNetworkReceiveBaseHandle.SetDecryptInfo(_IsDecrypt: Boolean;
  _DecPassword: string);
begin
  IsDecrypt := _IsDecrypt;
  DecPassword := _DecPassword;
end;

procedure TNetworkReceiveBaseHandle.SetRecieveFileOperator(
  _RecieveFileOperator: TReceiveFileOperator);
begin
  RecieveFileOperator := _RecieveFileOperator;
  RecieveFileOperator.SetNetworkReceiveBaseHandle( Self );
end;

procedure TNetworkReceiveBaseHandle.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

function TNetworkReceiveBaseHandle.Update: Boolean;
begin
  Result := False;

    // ��ȡ������
  if not ReadIsCreateReadStream then
    Exit;

    // �Ƿ����㹻��д��ռ�
  if not ReadIsEnoughSpace then
  begin
    RecieveFileOperator.RevFileLackSpaceHandle;
    Exit;
  end;

    // д��������
  if not ReadIsCreateWriteStrem then
  begin
    RecieveFileOperator.WriteFileError;
    Exit;
  end;

    // �����ļ���ʼ��
  FileRevceiveIniHandle;

    // �Ƿ�ѹ���ļ�
  IsZipFile := MySocketUtil.RevJsonBool( TcpSocket );

    // �ļ�����
  if not FileReceiveHandle then
  begin
    ReceiveFileIncompleted;
    Exit;
  end;

    // �����ļ��ɹ�
  ReceiveFileCompleted;

  Result := True;
end;

function TNetworkReceiveBaseHandle.WriteBufStream: Integer;
var
  HeartBeatTime : TDateTime;
  TempStream, ActivateStream : TMemoryStream;
  WriteSize, RemainSize : Integer;
  FullBufSize, WriteDataSize : Integer;
  DataBuf : TDataBuf;
begin
  TempStream := TMemoryStream.Create;

  try
      // ��ѹ���ļ������ѹ
    ActivateStream := BufStream;
    if ReadIsZip and IsZipFile then
    begin
      ActivateStream := TempStream;
      SendFileUtil.DecompressStream( BufStream, TempStream );
    end;

      // д�ļ�
    HeartBeatTime := Now;
    WriteSize := 0;
    RemainSize := ActivateStream.Size;
    ActivateStream.Position := 0;
    FullBufSize := SizeOf( DataBuf );
    while RemainSize > 0 do
    begin
      WriteDataSize := Min( FullBufSize, RemainSize );
      ActivateStream.ReadBuffer( DataBuf, WriteDataSize );

        // ����
      if IsDecrypt then
        SendFileUtil.Deccrypt( DataBuf, WriteDataSize, DecPassword );

      WriteDataSize := WriteStream.Write( DataBuf, WriteDataSize );
      if WriteDataSize <= 0 then
        Break;
      WriteSize := WriteSize + WriteDataSize;
      RemainSize := RemainSize - WriteDataSize;

        // ��ʱ��������
      HeartBeatReceiver.CheckSend( TcpSocket, HeartBeatTime );
    end;
  except
  end;
  Result := WriteSize;

  TempStream.Free;
end;

{ TRefreshRevReader }

procedure TRefreshRevReader.AddSpace(CompletedSpace: Int64);
begin
  LastCompletedSpace := LastCompletedSpace + CompletedSpace;
end;

constructor TRefreshRevReader.Create;
begin
  LastRefreshTime := Now;
  LastCompletedSpace := 0;
end;

function TRefreshRevReader.ReadCompletedSpace: Int64;
begin
  Result := LastCompletedSpace;
  LastCompletedSpace := 0;
end;

function TRefreshRevReader.ReadIsRefresh: Boolean;
begin
  Result := SecondsBetween( Now, LastRefreshTime ) >= 1;  // 1 ���� ˢ��һ�ν���
  if Result then
    LastRefreshTime := Now;
end;

procedure TRefreshRevReader.StartRev;
begin
  StartRevTime := Now;
end;

function TRefreshRevReader.StopRev( RevSize : Int64 ): Int64;
var
  RevTime : Int64;
begin
    // ��������λ
  RevSize := RevSize * 1000;

    // ���˶��ٺ���
  RevTime := MilliSecondsBetween( Now, StartRevTime );
  RevTime := Max( 1, RevTime );

    // ��λ�Ǽ䴫��Ŀռ�
  Result := RevSize div RevTime;

    // ���ٷ��� 2KB
  Result := Max( 2 * Size_KB, Result );
end;

{ TRecieveFileOperator }

procedure TReceiveFileOperator.AddSpeedSpace(SendSize: Integer);
begin

end;

procedure TReceiveFileOperator.LostConnectError;
begin

end;

procedure TReceiveFileOperator.MarkContinusSend;
begin

end;

procedure TReceiveFileOperator.ReadFileError;
begin

end;

function TReceiveFileOperator.ReadFilePos: Int64;
begin
  Result := NetworkReceiveBaseHandle.WriteStreamPos;
end;

function TReceiveFileOperator.ReadFileSize: Int64;
begin
  Result := NetworkReceiveBaseHandle.WriteStreamSize;
end;

function TReceiveFileOperator.ReadFileTime: TDateTime;
begin
  Result := Now;
  if not ( NetworkReceiveBaseHandle is TNetworkReceiveFileHandle ) then
    Exit;
  Result := ( NetworkReceiveBaseHandle as TNetworkReceiveFileHandle ).ReceiveFileTime;
end;

function TReceiveFileOperator.ReadIsNextReceive: Boolean;
begin
  Result := True;
end;

function TReceiveFileOperator.ReadLastCompletedSize: Int64;
begin
  Result := NetworkReceiveBaseHandle.RefreshRevReader.ReadCompletedSpace;
end;

procedure TReceiveFileOperator.RefreshCompletedSpace;
begin

end;

procedure TReceiveFileOperator.RevFileLackSpaceHandle;
begin

end;

procedure TReceiveFileOperator.SetNetworkReceiveBaseHandle(
  _NetworkReceiveBaseHandle: TNetworkReceiveBaseHandle);
begin
  NetworkReceiveBaseHandle := _NetworkReceiveBaseHandle;
end;

procedure TReceiveFileOperator.TransferFileError;
begin

end;

procedure TReceiveFileOperator.WriteFileError;
begin

end;

{ TNetworkReceiveFileHandle }

procedure TNetworkReceiveFileHandle.ReceiveFileCompleted;
begin
  try    // �ȹر��ļ�
    if Assigned( WriteStream ) then
    begin
      WriteStream.Free;
      WriteStream := nil;
    end;
  except
  end;

    // �����ļ��޸�ʱ��
  MyFileSetTime.SetTime( ReceiveFilePath, ReceiveFileTime );
end;

procedure TNetworkReceiveFileHandle.ReceiveFileIncompleted;
begin
  RecieveFileOperator.MarkContinusSend;
end;

function TNetworkReceiveFileHandle.CreateWriteStream: Boolean;
begin
  try       // ����д����
    if WriteStreamPos > 0 then
    begin
      WriteStream := TFileStream.Create( ReceiveFilePath, fmOpenWrite or fmShareDenyNone );
      WriteStream.Position := WriteStreamPos;
    end
    else
    begin
      ForceDirectories( ExtractFileDir( ReceiveFilePath ) );
      WriteStream := TFileStream.Create( ReceiveFilePath, fmCreate or fmShareDenyNone );
    end;
    Result := True;
  except
    WriteStream := nil;
    Result := False;
  end;
end;

destructor TNetworkReceiveFileHandle.Destroy;
begin
  try    // �ͷ�д����
    if Assigned( WriteStream ) then
      WriteStream.Free;
  except
  end;
  inherited;
end;

procedure TNetworkReceiveFileHandle.FileRevceiveIniHandle;
var
  TimeStr : string;
begin
  TimeStr := MySocketUtil.RevJsonStr( TcpSocket );
  ReceiveFileTime := MyRegionUtil.ReadLocalTime( TimeStr );
end;

function TNetworkReceiveFileHandle.getIsEnouthSpace: Boolean;
var
  RemainSize : Int64;
  ReceiveFolderPath : string;
begin
    // �����Ƿ����㹻�Ŀռ䣬 �����ͽ��
  RemainSize := WriteStreamSize - WriteStreamPos;
  ReceiveFolderPath := ExtractFileDir( ReceiveFilePath );
  ForceDirectories( ReceiveFolderPath );
  Result := MyHardDisk.getHardDiskFreeSize( ReceiveFolderPath ) >= RemainSize;
end;

function TNetworkReceiveFileHandle.ReadIsZip: Boolean;
begin
  Result := not MyFilePath.getIsZip( ReceiveFilePath );
end;

function TNetworkReceiveFileHandle.ReadReceivePath: string;
begin
  Result := ReceiveFilePath;
end;

procedure TNetworkReceiveFileHandle.SetReceiveFilePath(
  _ReceiveFilePath: string);
begin
  ReceiveFilePath := _ReceiveFilePath;
end;

{ TNetworkReceiveStreamHandle }

function TNetworkReceiveStreamHandle.CreateWriteStream: Boolean;
begin
  WriteStream := RevStream;
  Result := True;
end;

function TNetworkReceiveStreamHandle.getIsEnouthSpace: Boolean;
begin
  Result := True;
end;

function TNetworkReceiveStreamHandle.ReadIsZip: Boolean;
begin
  Result := True;
end;

function TNetworkReceiveStreamHandle.ReadReceivePath: string;
begin
  Result := 'bc_receive_zip';
end;

procedure TNetworkReceiveStreamHandle.SetRevStream(_RevStream: TMemoryStream);
begin
  RevStream := _RevStream;
end;

{ TCopyFileOperator }

procedure TCopyFileOperator.AddSpeedSpace(SendSize: Integer);
begin

end;

procedure TCopyFileOperator.DesWriteSpaceLack;
begin

end;

procedure TCopyFileOperator.MarkContinusCopy;
begin

end;

procedure TCopyFileOperator.ReadFileError;
begin

end;

function TCopyFileOperator.ReadFilePath: string;
begin
  Result := CopyFileHandle.SourceFilePath;
end;

function TCopyFileOperator.ReadFilePos: Int64;
begin
  Result := CopyFileHandle.FilePos;
end;

function TCopyFileOperator.ReadFileSize: Int64;
begin
  Result := CopyFileHandle.FileSize;
end;

function TCopyFileOperator.ReadFileTime: TDateTime;
begin
  Result := CopyFileHandle.FileTime;
end;

function TCopyFileOperator.ReadIsNextCopy: Boolean;
begin
  Result := True;
end;

function TCopyFileOperator.ReadLastCompletedSize: Int64;
begin
  Result := CopyFileHandle.RefreshCopyReader.ReadLastCompletedSize;
end;

procedure TCopyFileOperator.RefreshCompletedSpace;
begin

end;

procedure TCopyFileOperator.SetCopyFileHandle(_CopyFileHandle: TCopyFileHandle);
begin
  CopyFileHandle := _CopyFileHandle;
end;

procedure TCopyFileOperator.WriteFileError;
begin

end;

{ TRefreshCopyReader }

procedure TRefreshCopyReader.AddCompletedSize(CompletedSize: Int64);
begin
  LastCompletedSize := LastCompletedSize + CompletedSize;
end;

constructor TRefreshCopyReader.Create;
begin
  SleepCount := 0;

  LastRefreshTime := Now;
  LastCompletedSize := 0;
end;

function TRefreshCopyReader.ReadIsRefresh: Boolean;
begin
      // sleep
  Inc( SleepCount );
  if SleepCount >= CopyCount_Sleep then
  begin
    Sleep(1);
    SleepCount := 0;
  end;


  Result := SecondsBetween( Now, LastRefreshTime ) >= 1;  // 1 ���� ˢ��һ�ν���
  if Result then
    LastRefreshTime := Now;
end;

function TRefreshCopyReader.ReadLastCompletedSize: Int64;
begin
  Result := LastCompletedSize;
  LastCompletedSize := 0;
end;

{ TWatchReceiveStatusThread }

constructor TWatchRevThread.Create;
begin
  inherited Create;
  RevSpeed := 2 * Size_KB;
  IsRevStop := False;
  IsRevLostConn := False;
  IsRevCompleted := False;
end;

destructor TWatchRevThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;
  inherited;
end;

procedure TWatchRevThread.Execute;
var
  RevStr : string;
begin
  while not Terminated do
  begin
    RevStr := MySocketUtil.RevJsonStr( TcpSocket );
    if RevStr = ReceiveStatus_Speed then  // ���ý����ٶ�
      RevSpeed := MySocketUtil.RevJsonInt64( TcpSocket )
    else
    if RevStr = ReceiveStatus_Stop then  // ֹͣ����
      IsRevStop := True
    else
    begin
      if RevStr = ReceiveStatus_Completed then // �������
        IsRevCompleted := True
      else                                // ���նϿ�
        IsRevLostConn := True;

      if not Terminated then
        Suspend;
    end;
  end;
end;

procedure TWatchRevThread.SetSendFileOperator(
  _SendFileOperator: TSendFileOperator);
begin
  SendFileOperator := _SendFileOperator;
end;

procedure TWatchRevThread.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TWatchRevThread.StartWatch;
begin
  IsRevStop := False;
  IsRevCompleted := False;
  IsRevLostConn := False;
  Resume;
end;

procedure TWatchRevThread.StopWatch;
begin
    // ������� �� �Ѿ��Ͽ�����
  while not IsRevCompleted and not IsRevLostConn do
    Sleep( 100 );
end;

{ TFileUnpackOperator }

procedure TFileUnpackOperator.AddSpeedSpace(SendSize: Integer);
begin

end;

function TFileUnpackOperator.ReadLastComletedSize: Int64;
begin
  Result := FileUnpackHandle.RefreshCopyReader.ReadLastCompletedSize;
end;

function TFileUnpackOperator.ReadIsNextCopy: Boolean;
begin
  Result := True;
end;

procedure TFileUnpackOperator.RefreshCompletedSpace;
begin

end;

procedure TFileUnpackOperator.SetFileUnpackHandle(
  _FileUnpackHandle: TFileUnpackHandle);
begin
  FileUnpackHandle := _FileUnpackHandle;
end;


{ TFindAdvaceObj }

procedure THeatBeatHelper.CheckHeartBeat;
begin
    // ��ʱ��������
  HeartBeatReceiver.CheckSend( TcpSocket, StartTime );
end;

constructor THeatBeatHelper.Create(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
  StartTime := Now;
end;

{ HeartBeatReader }

class procedure HeartBeatReceiver.CheckSend(TcpSocket: TCustomIpClient;
  var StartTime: TDateTime);
begin
    // ��ʱ��������
  if SecondsBetween( Now, StartTime ) > 10 then
  begin
    StartTime := Now;
    MySocketUtil.SendData( TcpSocket, FileReq_HeartBeat );
  end;
end;

class function HeartBeatReceiver.CheckReceive(TcpSocket: TCustomIpClient): string;
begin
  while True do
  begin
    Result := MySocketUtil.RevData( TcpSocket );
    if Result <> FileReq_HeartBeat then  // ����������ȴ�����
      Break;
  end;
end;

{ TLocalFolderFindAdvanceHandle }

procedure TLocalFolderFindAdvanceHandle.CheckSleep;
begin
  inherited;
  HeatBeatHelper.CheckHeartBeat;
end;

procedure TLocalFolderFindAdvanceHandle.SetHeatBeatHelper(
  _HeatBeatHelper: THeatBeatHelper);
begin
  HeatBeatHelper := _HeatBeatHelper;
end;

{ TLocalFolderFilterFindAdvanceHandle }

procedure TLocalFolderFilterFindAdvanceHandle.CheckSleep;
begin
  inherited;
  HeatBeatHelper.CheckHeartBeat;
end;

function TLocalFolderFilterFindAdvanceHandle.CreateFolderFindHandle: TLocalFolderFindHandle;
var
  LocalFolderFilterFindAdvanceHandle : TLocalFolderFilterFindAdvanceHandle;
begin
  LocalFolderFilterFindAdvanceHandle := TLocalFolderFilterFindAdvanceHandle.Create;
  LocalFolderFilterFindAdvanceHandle.SetEncryptedInfo( IsEncrypted, PasswordExt );
  LocalFolderFilterFindAdvanceHandle.SetEditionInfo( IsEdition, FileEditionHash );
  LocalFolderFilterFindAdvanceHandle.SetHeatBeatHelper( HeatBeatHelper );
  Result := LocalFolderFilterFindAdvanceHandle;
end;

procedure TLocalFolderFilterFindAdvanceHandle.SetHeatBeatHelper(
  _HeatBeatHelper: THeatBeatHelper);
begin
  HeatBeatHelper := _HeatBeatHelper;
end;

{ TScanResultGetZipInfo }

procedure TScanResultGetZipInfo.SetTotalSize(_TotalSize: Int64);
begin
  TotalSize := _TotalSize;
end;

end.

