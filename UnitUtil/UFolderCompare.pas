unit UFolderCompare;

interface

uses Generics.Collections, dateUtils, SysUtils, Winapi.Windows, UMyUtil, UModelUtil, UMyTcp, sockets,
     Classes, Math, winapi.winsock, StrUtils, LbCipher,LbProc, uDebug, uDebugLock, Zip, syncobjs, zlib,
     UFileBaseInfo;

type

{$Region ' 文件比较 ' }

     // 搜索的文件信息
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

      // 搜索目录的信息
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

      // 信息 辅助类
  ScanFileInfoUtil = class
  public
    class procedure CopyFile( OldFileHash, NewFileHash : TScanFileHash );
    class procedure CopyFolder( OldFOlderHash, NewFolderHash : TScanFolderHash );
  end;

      // 取消读取器
  TCancelReader = class
  public
    function getIsRun : Boolean;virtual;abstract;
  end;


  {$Region ' 扫描目录 结果信息 ' }

    // 文件比较结果
  TScanResultInfo = class
  public
    SourceFilePath : string;
  public
    constructor Create( _SourceFilePath : string );
  end;
  TScanResultList = class( TObjectList<TScanResultInfo> );


    // 添加 文件
  TScanResultAddFileInfo = class( TScanResultInfo )
  public
    FileSize : Int64;
    FileTime : TDateTime;
  public
    procedure SetFileSize( _FileSize : Int64; _FileTime : TDateTime );
  end;

    // 添加 目录
  TScanResultAddFolderInfo = class( TScanResultInfo )
  end;

    // 删除 文件
  TScanResultRemoveFileInfo = class( TScanResultInfo )
  end;

    // 删除 目录
  TScanResultRemoveFolderInfo = class( TScanResultInfo )
  end;

      // 添加 压缩文件
  TScanResultAddZipInfo = class( TScanResultInfo )
  public
    ZipStream : TMemoryStream;
    TotalSize : Int64;
  public
    procedure SetZipStream( _ZipStream : TMemoryStream );
    procedure SetTotalSize( _TotalSize : Int64 );
  end;

    // 获取 压缩文件
  TScanResultGetZipInfo = class( TScanResultInfo )
  public
    TotalSize : Int64;
  public
    procedure SetTotalSize( _TotalSize : Int64 );
  end;

  {$EndRegion}

  {$Region ' 扫描目录 算法 ' }

  {$Region ' 扫描父类 ' }

     // 搜索目录 父类
  TFolderFindBaseHandle = class
  public
    FolderPath : string;
    ScanFileHash : TScanFileHash;
    ScanFolderHash : TScanFolderHash;
  public
    procedure SetFolderPath( _FolderPath : string );
  end;

    // 主动 搜索目录
  TFolderFindHandle = class( TFolderFindBaseHandle )
  public
    procedure SetScanFile( _ScanFileHash : TScanFileHash );
    procedure SetScanFolder( _ScanFolderHash : TScanFolderHash );
  protected      // 过滤器
    function IsFileFilter( FilePath : string; sch : TSearchRec ): Boolean;virtual;
    function IsFolderFilter( FolderPath : string ): Boolean;virtual;
  end;

    // 被动 搜索目录
  TFolderAccessFindHandle = class( TFolderFindBaseHandle )
  public
    constructor Create;
    destructor Destroy; override;
  end;

  {$EndRegion}

  {$Region ' 本地扫描 ' }

    // 搜索 本地目录
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

    // 搜索 本地目录 过滤
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
  protected      // 过滤器
    function IsFileFilter( FilePath : string; sch : TSearchRec ): Boolean;override;
  protected
    function CreateFolderFindHandle : TLocalFolderFindHandle;override;
  end;

  {$EndRegion}

  {$Region ' 网络扫描 辅助 ' }

      // 搜索辅助数据
  THeatBeatHelper = class
  public
    TcpSocket : TCustomIpClient;
    StartTime : TDateTime;
  public
    constructor Create( _TcpSocket : TCustomIpClient );
    procedure CheckHeartBeat;
  end;

    // 心跳接收器
  HeartBeatReceiver = class
  public
    class function CheckReceive( TcpSocket : TCustomIpClient ): string;
    class procedure CheckSend( TcpSocket : TCustomIpClient; var StartTime : TDateTime );
  end;

    // 心跳搜索
  TLocalFolderFindAdvanceHandle = class( TLocalFolderFindHandle )
  private
    HeatBeatHelper : THeatBeatHelper;
  public
    procedure SetHeatBeatHelper( _HeatBeatHelper : THeatBeatHelper );
  private
    procedure CheckSleep;override;
  end;

    // 心跳搜索
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

  {$Region ' 网络扫描 ' }

    // 主动扫描 网络目录
  TNetworkFolderFindHandle = class( TFolderFindHandle )
  protected
    TcpSocket : TCustomIpClient;
  protected   // 文件类型
    IsDeep : Boolean;
    IsDeleted : Boolean;
  protected   // 过滤信息
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

    // 被动搜索 网络目录
  TNetworkFolderAccessFindHandle = class
  protected   // 目录信息
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
    procedure SearchFolderInfo; // 搜索信息
    procedure SearchFilterFolderInfo; // 搜索过滤信息
    procedure SendFolderInfo;  // 发送结果信息
  end;

  {$EndRegion}

  {$Region ' 网络扫描信息交互 ' }

    // 获取 文件读取信息
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

    // 获取 目录读取信息
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

      // 获取 完整目录读取信息
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


    // 生成 文件列表 字符串
  TGetNetworkFileResultStrHandle = class
  public
    ScanFileHash : TScanFileHash;
  public
    constructor Create( _ScanFileHash : TScanFileHash );
    function get : string;
  end;

        // 生成 目录列表 字符串
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

    // 生成 完整目录 字符串
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

  {$Region ' 扫描文件 算法 ' }

    // 搜索文件信息
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

    // 搜索 本地文件
  TLocalFileFindHandle = class( TFileFindHandle )
  public
    procedure Update;
  end;

    // 搜索 网络文件 父类
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

    // 被动搜索 网络文件
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

  {$Region ' 扫描删除文件 算法 ' }

    // 父类
  TFileDeletedListFindHandle = class
  public
    FilePath : string;
    ScanFileHash : TScanFileHash;
  public
    constructor Create( _FilePath : string );
    procedure SetScanFileHash( _ScanFileHash : TScanFileHash );
  end;

    // 主动搜索 本地
  TLocalFileDeletedListFindHandle = class( TFileDeletedListFindHandle )
  public
    procedure Update;
  end;

    // 主动搜索 网络
  TNetworkFileDeletedListFindHandle = class( TFileDeletedListFindHandle )
  public
    TcpSocket : TCustomIpClient;
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure Update;
  end;

    // 被动搜索
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


    // 目录比较算法
  TFolderCompareHandler = class
  public
    SourceFolderPath : string;
    SleepCount : Integer;
    ScanTime : TDateTime;
  public   // 文件信息
    SourceFileHash : TScanFileHash;
    DesFileHash : TScanFileHash;
  public   // 目录信息
    SourceFolderHash : TScanFolderHash;
    DesFolderHash : TScanFolderHash;
  public   // 空间结果
    FileCount : Integer;
    FileSize, CompletedSize : Int64;
  public   // 文件变化结果
    ScanResultList : TScanResultList;
  public   // 是否删除目标多余文件
    IsSupportDeleted : Boolean;
    IsDesEmpty, IsDesReaded : Boolean;  // 目标目录是否为空
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
  protected      // 是否 停止扫描
    function CheckNextScan : Boolean;virtual;
    procedure DesFolderEmptyHandle; virtual; // 目标目录为空
  private        // 比较结果
    function getChildPath( ChildName : string ): string;
    procedure AddFileResult( FileInfo : TScanFileInfo );
    procedure AddFolderResult( FolderName : string );
    procedure RemoveFileResult( FileName : string );
    procedure RemoveFolderResult( FolderName : string );
  protected        // 比较子目录
    function getDesFileName( SourceFileName : string ): string;virtual;
    function getScanHandle( SourceFolderName : string ) : TFolderCompareHandler;virtual;abstract;
    procedure CompareChildFolder( SourceFolderName : string );
  end;

    // 文件比较算法
  TFileCompareHandler = class
  public
    SourceFilePath : string;
  public
    SourceFileSize : Int64;
    SourceFileTime : TDateTime;
  public
    DesFileSize : Int64;
    DesFileTime : TDateTime;
  public   // 空间结果
    CompletedSize : Int64;
  public   // 文件变化结果
    ScanResultList : TScanResultList;
  public
    procedure SetSourceFilePath( _SourceFilePath : string );
    procedure SetResultList( _ScanResultList : TScanResultList );
    procedure Update;virtual;
  protected     // 文件和路径信息
    function FindSourceFileInfo: Boolean;virtual;abstract;
    function FindDesFileInfo: Boolean;virtual;abstract;
    function getAddFilePath : string;virtual;abstract;
    function getRemoveFilePath : string;virtual;abstract;
  private        // 比较结果
    function IsEqualsDes : Boolean;
    procedure AddFileResult;
    procedure RemoveFileResult;
  end;

{$EndRegion}

{$Region ' 文件复制 ' }

  TDataBuf = array[0..524287] of Byte; // 512 KB, 磁盘读写单位
  TSendBuf = array[0..1023] of Byte;  // 1 KB, 网络传输单位


    // 发送文件辅助类
  SendFileUtil = class
  public             // 压缩, 解压
    class procedure CompressStream( SourceStream, ComStream : TMemoryStream );
    class procedure DecompressStream( ComStream, DesStream : TMemoryStream );
  public              // 加密、解密
    class procedure Encrypt( var Buf : TDataBuf; BufSize : Integer; Password : string );
    class procedure Deccrypt( var Buf : TDataBuf; BufSize : Integer; Password : string );
  private
    class procedure EncryptData( var Buf : TSendBuf; BufSize : Integer; Key : string; IsEncrypt : Boolean );
  end;

    // 计时器
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
  public       // 速度统计
    function AddCompleted( CompletedSpace : Integer ): Boolean;
    function ReadLastSpeed : Int64;
  public       // 速度限制
    function ReadIsLimited : Boolean;
    function ReadAvailableSpeed : Int64;
  end;

  {$Region ' 复制文件 ' }

    // 复制文件辅助类
  CopyFileUtil = class
  public               // 加密解密
    class procedure Encrypt( var Buf : TDataBuf; BufSize : Integer; Password : string );
    class procedure Deccrypt( var Buf : TDataBuf; BufSize : Integer; Password : string );
    class function DecryptStream( Stream : TMemoryStream; Password : string ): TMemoryStream;
  private
    class procedure EncryptData( var Buf : TDataBuf; BufSize : Integer; Key : string; IsEncrypt : Boolean );
  end;

  TCopyFileHandle = class;

    // 文件复制具体操作
  TCopyFileOperator = class
  private
    CopyFileHandle : TCopyFileHandle;
  public
    procedure SetCopyFileHandle( _CopyFileHandle : TCopyFileHandle );
  public
    function ReadIsNextCopy : Boolean;virtual; // 检测是否继续复制
    procedure AddSpeedSpace( SendSize : Integer );virtual;
    procedure RefreshCompletedSpace;virtual; // 刷新已完成空间
  public
    procedure MarkContinusCopy;virtual; // 续传时调用
    procedure DesWriteSpaceLack;virtual; // 空间不足
    procedure ReadFileError;virtual;  // 读文件出错
    procedure WriteFileError;virtual; // 写文件出错
  protected       // 读取复制文件的信息
    function ReadLastCompletedSize : Int64;
    function ReadFilePath : string;
    function ReadFileSize : Int64;
    function ReadFilePos : Int64;
    function ReadFileTime : TDateTime;
  end;

    // 复制刷新器
  TRefreshCopyReader = class
  public
    SleepCount : Integer;
  public
    LastRefreshTime : TDateTime; // 上一次刷新时间
    LastCompletedSize : Int64;  // 已完成空间
  public
    constructor Create;
    function ReadIsRefresh : Boolean;
    procedure AddCompletedSize( CompletedSize : Int64 );
    function ReadLastCompletedSize : Int64;
  end;

    // 本地文件 复制
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
    ReadStream : TFileStream;  // 读入流
    WriteStream : TFileStream; // 写入流
    BufStream : TMemoryStream; // 内存流
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
    function ReadIsEnoughSpace : Boolean;  // 检查是否有足够的空间
    function ReadIsCreateReadStream : Boolean;  // 创建读入流
    function ReadIsCreateWriteStream : Boolean;  // 创建写入流
    function FileCopyHandle: Boolean;  // 复制流
    function ReadBufStream : Integer;  // 读取流
    function WriteBufStream : Integer; // 写入流
    procedure DestoryStream; // 关闭流
  end;

  {$EndRegion}

  {$Region ' 解压文件 ' }

  TFileUnpackHandle = class;

    // 解压文件操作
  TFileUnpackOperator = class
  private
    FileUnpackHandle : TFileUnpackHandle;
  public
    procedure SetFileUnpackHandle( _FileUnpackHandle : TFileUnpackHandle );
  public
    function ReadIsNextCopy : Boolean;virtual; // 检测是否继续解压
    procedure AddSpeedSpace( SendSize : Integer );virtual;
    procedure RefreshCompletedSpace;virtual; // 刷新已完成空间
  protected
    function ReadLastComletedSize : Int64; // 读取已完成空间信息
  end;

    // 压缩文件解压
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
    destructor Destroy; override;  // 返回解压空间
  end;


  {$EndRegion}

  {$Region ' 发送文件 ' }


  TNetworkSendBaseHandle = class;

    // 发送文件导入器
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
    procedure RevFileLackSpaceHandle;virtual; // 缺少空间的处理
    procedure MarkContinusSend;virtual; // 续传时调用
    procedure ReadFileError;virtual;  // 读文件出错
    procedure WriteFileError;virtual; // 写文件出错
    procedure LostConnectError;virtual; //断开连接出错
    procedure TransferFileError;virtual; // 发送文件出错
  protected      // 读取信息
    function ReadLastCompletedSize : Int64;
    function ReadFilePath : string;
    function ReadFileSize : Int64;
    function ReadFilePos : Int64;
    function ReadFileTime : TDateTime;
  end;

    // 监听接收方状态线程
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

      // 刷新器
  TRefreshSendReader = class
  public
    LastRefreshTime : TDateTime; // 上一次刷新时间
    LastCompletedSize : Int64;  // 已完成空间
  public
    constructor Create;
  public
    function ReadIsRefresh : Boolean;
    procedure AddCompletedSize( CompletedSize : Int64 );
    function ReadLastCompletedSize : Int64;
  end;

    // 网络发送 父类
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
    TotalSendDataBuf, SendDataBuf : TDataBuf;  // 每次发送的数据结构
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
    function ReadIsCreateReadStream: Boolean;  // 创建读入流
    function ReadIsEnoughSpace : Boolean;  // 是否有足够的空间写入
    function ReadIsCreateWriteStrem : Boolean;  // 创建写入流
    function FileSendHandle: Boolean;    // 发送文件
    function ReadBufStream: Integer; // 读取数据
    function SendBufStream: Boolean;  // 发送数据
    function RevWriteSize( ReadSize : Integer ) : Boolean; // 对方写入多少空间
  private
    function ReadIsNextSend( IsSuccessSend : Boolean ) : Boolean; // 是否继续发送
    function ReadIsStopTransfer: Boolean;  // 是否停止传输
    procedure AddSendedSpace( CompletedSpace : Integer );  // 统计已发送的空间
    function ReadSendBlockSize : Int64;  // 读取每次发送的空间信息
  protected
    function CreateReadStream : Boolean; virtual;abstract;
    function ReadSendPath : string;virtual;abstract;
    procedure FileSendIniHandle;virtual;
    function ReadIsZip : Boolean;virtual;
    procedure SendFileIncompleted; virtual;
  end;

    // 网络发送 文件
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

    // 网络发送 流
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

  {$Region ' 接收文件 ' }

      // 刷新器
  TRefreshRevReader = class
  public
    StartRevTime : TDateTime; // 结算接收速率
  public
    LastRefreshTime : TDateTime; // 上一次刷新时间
    LastCompletedSpace : Int64;  // 已完成空间
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

    // 接收文件导入器
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
    procedure RevFileLackSpaceHandle;virtual; // 缺少空间的处理
    procedure MarkContinusSend;virtual; // 续传时调用
    procedure ReadFileError;virtual;  // 读文件出错
    procedure WriteFileError;virtual; // 写文件出错
    procedure LostConnectError;virtual; //断开连接出错
    procedure TransferFileError;virtual; // 发送文件出错
  protected      // 读取信息
    function ReadLastCompletedSize : Int64;
    function ReadFileSize : Int64;
    function ReadFilePos : Int64;
    function ReadFileTime : TDateTime;
  end;

    // 网络接收 父类
  TNetworkReceiveBaseHandle = class
  private
    TcpSocket : TCustomIpClient;
    IsDecrypt : Boolean;
    DecPassword : string;
  protected
    WriteStream : TStream;
    WriteStreamSize, WriteStreamPos : Int64;
    BufStream : TMemoryStream;
    SendDataBuf, TotalSendDataBuf : TDataBuf;  // 每次发送的数据结构
    IsZipFile : Boolean;  // 是否压缩文件
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
    function ReadIsCreateReadStream: Boolean;  // 创建读入流
    function ReadIsEnoughSpace : Boolean;  // 是否有足够的空间写入
    function ReadIsCreateWriteStrem : Boolean;  // 创建写入流
    function FileReceiveHandle : Boolean; // 文件接收
    function ReceiveBufStream( BufSize : Integer ): Boolean; // 接收数据
    function WriteBufStream: Integer;  // 写入数据
    function SendWriteSize( WriteSize, ReadSize : Integer ): Boolean;  // 发送写入的空间
  private
    function ReadIsNextRev( IsSuccessRev : Boolean ) : Boolean;  // 是否继续接收
    procedure AddRecvedSize( RevSize : Integer );
    function ReadIsStopTransfer: Boolean;  // 是否停止传输
    procedure SendRevSpeed( RevSpeed : Int64 ); // 发送接收文件速度
  protected
    function getIsEnouthSpace : Boolean;virtual;abstract;
    procedure FileRevceiveIniHandle;virtual;
    function CreateWriteStream : Boolean;virtual;abstract;
    function ReadReceivePath : string;virtual;abstract;
    function ReadIsZip : Boolean;virtual;abstract;
    procedure ReceiveFileIncompleted;virtual;
    procedure ReceiveFileCompleted;virtual;
  end;

    // 网络接收 文件
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

    // 网络接收 流
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

{$Region ' 文件回收 ' }

  TEditonPathParams = record
  public
    FilePath : string;
    EditionNum : Integer;
  public
    IsEncrypted : Boolean;
    PasswordExt : string;
  end;

    // 辅助类
  FileRecycledUtil = class
  public            // 获取版本路径
    class function getEditionPath( Params : TEditonPathParams ): string;
  end;

    // 目标文件 回收
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
    function getIsExistRecylce : Boolean; // 文件是否已经回收
    procedure ConfirmRecycleEdition;
  private
    function getEquals( FilePath1, FilePath2 : string ): Boolean;
  end;

    // 目标目录 回收
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

{$Region ' 文件搜索 ' }

    // 文件搜索 结果
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

    // 网络目录 主动搜索
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

    // 网络目录 被动搜索
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

    // 文件请求
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

    // 目录读取结果
  FolderReadResult_End = '-1';
  FolderReadResult_File = '0';
  FolderReadResult_Folder = '1';

    // 目录搜索结果
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

    // N 个文件小停一次
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
    // 遍历 源文件
  for p in SourceFileHash do
  begin
      // 检查是否继续扫描
    if not CheckNextScan then
      Break;

      // 添加到统计信息
    FileSize := FileSize + p.Value.FileSize;
    FileCount := FileCount + 1;

      // 文件名
    SourceFileName := p.Value.FileName;
    DesFileName := getDesFileName( SourceFileName );
    if DesFileName = '' then  // 非解密文件
      Continue;

      // 目标文件不存在
    if not DesFileHash.ContainsKey( DesFileName ) then
    begin
      AddFileResult( p.Value );
      Continue;
    end;

      // 目标文件与源文件不一致
    if not p.Value.getEquals( DesFileHash[ DesFileName ] ) then
    begin
      RemoveFileResult( DesFileName ); // 先删除
      AddFileResult( p.Value );  // 后添加
    end
    else  // 目标文件与源文件一致
      CompletedSize := CompletedSize + p.Value.FileSize;

      // 删除目标文件
    DesFileHash.Remove( DesFileName );
  end;

    // 遍历目标文件
  if IsSupportDeleted then
    for p in DesFileHash do
      RemoveFileResult( p.Value.FileName );  // 删除目标文件
end;

procedure TFolderCompareHandler.FolderCompare;
var
  p : TScanFolderPair;
  FolderName : string;
begin
    // 遍历源目录
  for p in SourceFolderHash do
  begin
    FolderName := p.Value.FolderName;

      // 不存在目标目录，则创建
    if not DesFolderHash.ContainsKey( FolderName ) then
      AddFolderResult( FolderName );

      // 比较子目录
    CompareChildFolder( FolderName );

          // 移除记录
    if DesFolderHash.ContainsKey( FolderName ) then
      DesFolderHash.Remove( FolderName );
  end;

    // 遍历目标目录
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
    // 找源文件信息
  FindSourceFileInfo;

    // 如果目标不为空，则扫描
  if not IsDesEmpty then
  begin
      // 找目标文件信息
    FindDesFileInfo;

      // 目标目录是否为空
    IsDesEmpty := ( DesFileHash.Count = 0 ) and ( DesFolderHash.Count = 0 );
  end
  else   // 目标为空的处理
    DesFolderEmptyHandle;

    // 文件比较
  FileCompare;

    // 目录比较
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

    // 源文件不存在
  if not FindSourceFileInfo then
    Exit;

    // 目标文件不存在
  if not FindDesFileInfo then
    AddFileResult
  else   // 目标文件与源文件不一致
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
    // N 个文件小停一次
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
        // 超出范围，结束
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
    // 循环寻找 目录文件信息
  SearcFullPath := MyFilePath.getPath( FolderPath );
  if FindFirst( SearcFullPath + '*', faAnyfile, sch ) = 0 then
  begin
    repeat

        // 限 Cpu 速度
      CheckSleep;

      FileName := sch.Name;

      if ( FileName = '.' ) or ( FileName = '..') then
        Continue;

        // 检测文件过滤
      ChildPath := SearcFullPath + FileName;
      IsFolder := DirectoryExists( ChildPath );
      if IsFolder then
        IsFillter := IsFolderFilter( ChildPath )
      else
        IsFillter := IsFileFilter( ChildPath, sch );
      if IsFillter then  // 文件被过滤
        Continue;

        // 添加到目录结果
      if IsFolder then
      begin
        DesScanFolderInfo := TScanFolderInfo.Create( FileName );
        ScanFolderHash.AddOrSetValue( FileName, DesScanFolderInfo );
      end
      else
      begin
          // 获取 文件大小
        FileSize := sch.Size;

          // 获取 修改时间
        FileTimeToSystemTime( sch.FindData.ftLastWriteTime, LastWriteTimeSystem );
        LastWriteTimeSystem.wMilliseconds := 0;
        FileTime := SystemTimeToDateTime( LastWriteTimeSystem );

          // 添加到文件结果集合中
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
    // 搜索当前目录
  SearchLocalFolder;

    // 增加
  DeepCount := DeepCount + ScanFileHash.Count;
  DeepCount := DeepCount + ScanFolderHash.Count;

    // 搜索子目录
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
    // 过滤信息
  IsEncrypted := MySocketUtil.RevBoolData( TcpSocket );
  PasswordExt := MySocketUtil.RevData( TcpSocket );
  IsEdition := MySocketUtil.RevBoolData( TcpSocket );

    // 定时心跳
  HeatBeatHelper := THeatBeatHelper.Create( TcpSocket );

    // 使用过滤搜索
  LocalFolderFilterFindAdvanceHandle := TLocalFolderFilterFindAdvanceHandle.Create;
  if IsDeep then  // 深层搜索
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
  if IsDeep then  // 深层搜索
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
    // 把搜索结果转化为字符串
  GetNetworkFullFolderResultStrHandle := TGetNetworkFullFolderResultStrHandle.Create;
  GetNetworkFullFolderResultStrHandle.SetFileHash( ScanFileHash );
  GetNetworkFullFolderResultStrHandle.SetFolderHash( ScanFolderHash );
  ReadResultStr := GetNetworkFullFolderResultStrHandle.get;
  GetNetworkFullFolderResultStrHandle.Free;

    // 发送读取结果
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
    // 搜索目录信息
  if not IsFilter then
    SearchFolderInfo
  else
    SearchFilterFolderInfo;

    // 发送搜索结果
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
      // 目标文件
    if FilePos > 0 then  // 续传
    begin
      WriteStream := TFileStream.Create( DesFilePath, fmOpenWrite or fmShareDenyNone );
      WriteStream.Position := FilePos;
    end
    else
    begin  // 第一次传
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

  try    // 复制文件
    RemainSize := FileSize - FilePos;
    while RemainSize > 0 do
    begin
        // 取消复制
      if not CopyFileOperator.ReadIsNextCopy then
        Break;

        // 定时刷新
      if RefreshCopyReader.ReadIsRefresh then
        CopyFileOperator.RefreshCompletedSpace;

        // 读文件
      TotalReadSize := ReadBufStream; // 读取 8MB 文件

        // 读文件出错
      if TotalReadSize <= 0 then
      begin
        CopyFileOperator.ReadFileError;
        Break;
      end;

        // 写文件
      TotalWriteSize := WriteBufStream;

        // 写文件出错 或 空间 不足
      if TotalWriteSize <> TotalReadSize then
      begin
        CopyFileOperator.WriteFileError;
        Break;
      end;

        // 刷新状态
      RemainSize := RemainSize - TotalReadSize;
      FilePos := FilePos + TotalReadSize;
      RefreshCopyReader.AddCompletedSize( TotalReadSize );
      CopyFileOperator.AddSpeedSpace( TotalReadSize );
    end;
  except
  end;

    // 添加已完成空间
  CopyFileOperator.RefreshCompletedSpace;

    // 返回是否已完成
  Result := RemainSize <= 0;
end;


function TCopyFileHandle.ReadIsEnoughSpace: Boolean;
var
  FreeSize : Int64;
begin
  FreeSize := MyHardDisk.getHardDiskFreeSize( ExtractFileDir( DesFilePath ) );

    // 是否有足够的空间
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
    for i := 0 to 15 do  // 读取 8MB 文件
    begin
      ReadSize := Min( FullBufSize, RemainSize - TotalReadSize );
      ReadSize := ReadStream.Read( Buf, ReadSize );

        // 加密文件
      if IsEncrypt then
        CopyFileUtil.Encrypt( Buf, ReadSize, EncPassword )
      else
      if IsDecrypt then
        CopyFileUtil.Deccrypt( Buf, ReadSize, DecPassword );

        // 添加到缓冲区
      WriteSize := BufStream.Write( Buf, ReadSize );
      if ReadSize <> WriteSize then  // 没有完全写入
        Exit;

        // 统计读取总数
      TotalReadSize := TotalReadSize + ReadSize;

        // 读取 完成
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

    // 续传文件不存在
  if ( FilePos > 0 ) and not FileExists( DesFilePath ) then
    Exit;

    // 源文件不存在
  if not FileExists( SourceFilePath ) then
  begin
    CopyFileOperator.ReadFileError;
    Exit;
  end;

    // 获取 源文件信息
  FileSize := MyFileInfo.getFileSize( SourceFilePath );
  FileTime := MyFileInfo.getFileLastWriteTime( SourceFilePath );

    // 目标路径没有足够的空间
  if not ReadIsEnoughSpace then
  begin
    CopyFileOperator.DesWriteSpaceLack; // 空间不足
    Exit;
  end;

    // 无法创建读入流
  if not ReadIsCreateReadStream then
  begin
    CopyFileOperator.ReadFileError;
    Exit;
  end;

    // 无法创建写入流
  if not ReadIsCreateWriteStream then
  begin
    CopyFileOperator.WriteFileError;
    Exit;
  end;

    // 文件 复制失败
  if not FileCopyHandle then
  begin
    CopyFileOperator.MarkContinusCopy; // 添加续传信息
    Exit;
  end;

    // 释放流
  DestoryStream;

      // 设置修改时间
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

    // 写文件
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
      if WriteSize <> ReadSize then // 没有完全写入
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

      // 速度限制
    if IsLimited and ( Speed >= LimitSpeed ) and not Result then
    begin
      LastTime := IncSecond( SpeedTime, 1 );
      SleepMisecond := MilliSecondsBetween( LastTime, Now );
      Sleep( SleepMisecond );
      Result := True;
    end;

      // 重新计算速度
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
    // 提取文件信息
  LocalFileFindHandle := TLocalFileFindHandle.Create;
  LocalFileFindHandle.SetFilePath( FilePath );
  LocalFileFindHandle.Update;
  IsExist := LocalFileFindHandle.getIsExist;
  FileSize := LocalFileFindHandle.getFileSize;
  FileTime := LocalFileFindHandle.getFileTime;
  LocalFileFindHandle.Free;

    // 发送文件信息
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
    // 获取现存的版本数
  ExistRecycleEdition := getExistRecycleEdition;

    // 存在版本数大于等于预设值
  if ExistRecycleEdition >= SaveDeletedEdition then
  begin
    for i := SaveDeletedEdition to ExistRecycleEdition do  // 先删除最旧的版本
    begin
      FilePath1 := getRecycleEditionPath( i );
      SysUtils.DeleteFile( FilePath1 );
    end;
    ExistRecycleEdition := SaveDeletedEdition - 1;
  end;

    // 版本下移
  if ExistRecycleEdition > 0 then
    for i := ExistRecycleEdition downto 1 do
    begin
      FilePath1 := getRecycleEditionPath( i );
      FilePath2 := getRecycleEditionPath( i + 1 );
      RenameFile( FilePath1, FilePath2 );
    end;

    // 排到第一
  RecycledFilePath := getRecycleEditionPath( 1 );

    // 创建父目录
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
    // 文件已存在
  if getIsExistRecylce then
  begin
    SysUtils.DeleteFile( DesFilePath ); // 删除文件
    Exit;
  end;

    // 检查保存的版本数，如果超过要保存的版本，则删除
  ConfirmRecycleEdition;

    // 移动文件
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

    // 如果是加密路径，则解密获取源路径
  if IsEncrypted then
    FilePath := MyFilePath.getDesFilePath( FilePath, PasswordExt, False );

    // 生成版本路径
  AfterStr := ExtractFileExt( FilePath );
  BeforeStr := MyString.CutStopStr( AfterStr, FilePath );
  FilePath := BeforeStr + '.(' + IntToStr( Params.EditionNum ) + ')' + AfterStr;

    // 如果是加密路径，则加密源路径
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
    // 文件路径
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
    // 文件路径
  DesChildFolderPath := MyFilePath.getPath( DesFolderPath ) + FolderName;
  RecycleChildFolderPath := MyFilePath.getPath( RecycleFolderPath ) + FolderName;

    // 回收子目录
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
    // 创建回收目录
  CreateRecycleFolder;

    // 循环寻找 目录文件信息
  SearcFullPath := MyFilePath.getPath( DesFolderPath );
  if FindFirst( SearcFullPath + '*', faAnyfile, sch ) = 0 then
  begin
    repeat
      FileName := sch.Name;

      if ( FileName = '.' ) or ( FileName = '..') then
        Continue;

        // 检测文件过滤
      ChildPath := SearcFullPath + FileName;
      if DirectoryExists( ChildPath ) then
        SearchFolder( FileName )
      else
        SearchFile( FileName );

    until FindNext(sch) <> 0;
  end;
  SysUtils.FindClose(sch);

    // 删除目标目录
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
    // 发送请求信息
  MySocketUtil.SendData( TcpSocket, FileReq_ReadFile );
  MySocketUtil.SendData( TcpSocket, FilePath );
  MySocketUtil.SendData( TcpSocket, IsDeleted );

    // 读取文件信息
  IsExist := MySocketUtil.RevJsonBool( TcpSocket );
  if not IsExist then // 目标文件不存在
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
    // 发送请求信息
  MySocketUtil.SendData( TcpSocket, FileReq_ReadFolder );
  MySocketUtil.SendData( TcpSocket, FolderPath );
  MySocketUtil.SendData( TcpSocket, IsDeleted );

    // 过滤信息
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_IsDeep, IsDeep );
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_IsFilter, IsFilter );
  if IsFilter then
  begin
    MySocketUtil.SendData( TcpSocket, IsEncrypted );
    MySocketUtil.SendData( TcpSocket, PasswordExt );
    MySocketUtil.SendData( TcpSocket, IsEdition );
  end;

    // 接收结果信息
  FolderReadResult := HeartBeatReceiver.CheckReceive( TcpSocket );
  if FolderReadResult = '' then // 对方断开连接
  begin
    TcpSocket.Disconnect;
    Exit;
  end;
  FolderReadResult := MySocketUtil.ReadMsgToMsgStr( FolderReadResult );

    // 提取信息
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
    // 发送请求信息
  MySocketUtil.SendData( TcpSocket, FileReq_ReadFileDeletedList );
  MySocketUtil.SendData( TcpSocket, FilePath );
  MySocketUtil.SendData( TcpSocket, True );

    // 获取 搜索结果
  FileStr := MySocketUtil.RevData( TcpSocket );

    // 没有文件
  if FileStr = Type_Empty then
    Exit;

    // 获取文件列表信息
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
    // 获取信息列表
  GetNetworkFileResultStrHandle := TGetNetworkFileResultStrHandle.Create( ScanFileHash );
  FileStr := GetNetworkFileResultStrHandle.get;
  GetNetworkFileResultStrHandle.Free;

    // 没有文件
  if FileStr = '' then
    FileStr := Type_Empty;

    // 发送结果
  MySocketUtil.SendData( TcpSocket, FileStr )
end;

procedure TNetworkFileDeletedListAccessFindHandle.SetTcpSocket(
  _TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TNetworkFileDeletedListAccessFindHandle.Update;
begin
    // 寻找信息
  FindDeletedFileList;

    // 发送信息
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
    // 发文件信息
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

    // 没有文件的标志
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

    // 搜索目录信息
  LocalFolderFindHandle := TLocalFolderFindHandle.Create;
  LocalFolderFindHandle.SetFolderPath( FolderPath );
  LocalFolderFindHandle.SetScanFile( ChildFileHash );
  LocalFolderFindHandle.SetScanFolder( ChildFolderHash );
  LocalFolderFindHandle.Update;
  LocalFolderFindHandle.Free;

    // 寻找回收的文件
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
  cs: TCompressionStream; {定义压缩流}
  num: Integer;           {原始文件大小}
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
    // 读取源流的空间信息
  ComStream.Position := 0;
  ComStream.ReadBuffer(num,SizeOf(num));
  DesStream.SetSize(num);

    // 解压
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

    // 加密块
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

    // 加密不足块的部分
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
      // 读出
    Stream.ReadBuffer( Buf, ReadSize );
      // 解密
    Deccrypt( Buf, ReadSize, Password );
      // 写进
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

    // 加密块
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

    // 加密不足块的部分
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

    // N 个文件小停一次
  Inc( SleepCount );
  if SleepCount >= ScanCount_Sleep then
  begin
    Sleep(1);
    SleepCount := 0;

      // 1 秒钟 刷新一次 搜索结果
    if SecondsBetween( now , RefreshTime ) >= 1 then
    begin
      HandleResultHash; // 处理结果
      ResultFileHash.Clear;
      ResultFolderHash.Clear;

      if getIsStop then // 处理结果后断开连接
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

    // 搜索文件
  for p in ScanFileHash do
  begin
      // 结束搜索
    if not CheckNextSearch then
    begin
      Result := False;
      Break;
    end;

      // 获取原始的文件名
    FileName := MyFilePath.getOrinalName( IsEncrypted, IsDeleted, p.Value.FileName, PasswordExt );

      // 不符合搜索条件
    if not MyMatchMask.Check( FileName, SearchName ) then
      Continue;

      // 添加到搜索结果中
    ChildPath := ParentPath + p.Value.FileName;
    ResultFileInfo := TScanFileInfo.Create( ChildPath );
    ResultFileInfo.SetFileInfo( p.Value.FileSize, p.Value.FileTime );
    ResultFileHash.AddOrSetValue( ChildPath, ResultFileInfo );
  end;
  ScanFileHash.Clear; // 释放内存

    // 结束搜索
  if not Result then
    Exit;

    // 搜索目录
  for pf in ScanFolderHash do
  begin
      // 结束搜索
    if not CheckNextSearch then
    begin
      Result := False;
      Break;
    end;

      // 不符合搜索条件
    if not MyMatchMask.Check( pf.Value.FolderName, SearchName ) then
      Continue;

      // 添加到搜索结果中
    ChildPath := ParentPath + pf.Value.FolderName;
    ResultFolderInfo := TScanFolderInfo.Create( ChildPath );
    ResultFolderHash.AddOrSetValue( ChildPath, ResultFolderInfo );
  end;
end;

function TFolderSearchHandle.FindScanHash: Boolean;
var
  LocalFolderFindHandle : TLocalFolderFindHandle;
begin
    // 搜索目录信息
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

    // 搜索目录
  for pf in ScanFolderHash do
  begin
      // 结束搜索
    if not CheckNextSearch then
    begin
      Result := False;
      Break;
    end;

      // 添加到搜索结果中
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

      // 结束搜索
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
    // 搜索文件信息
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
    // 提取信息
  FindNetworkFolderResultHandle := TFindNetworkFullFolderResultHandle.Create( ResultStr );
  FindNetworkFolderResultHandle.SetScanFile( ResultFileHash );
  FindNetworkFolderResultHandle.SetScanFolder( ResultFolderHash );
  FindNetworkFolderResultHandle.Update;
  FindNetworkFolderResultHandle.Free;

    // 处理结果信息
  HandleResultHash;

    // 清空已处理信息
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
    if ResultStr = FolderSearchResult_End then // 结束搜索
      Break;
    if ResultStr = '' then  // 断开了连接
    begin
      TcpSocket.Disconnect;
      Break;
    end;

      // 处理搜索结果
    HandleResult( ResultStr );

      // 判断是否停止搜索
    IsStop := getIsStop;
    MySocketUtil.SendData( TcpSocket, IsStop );

      // 结束搜索
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
    // 把搜索结果转化为字符串
  GetNetworkFullFolderResultStrHandle := TGetNetworkFullFolderResultStrHandle.Create;
  GetNetworkFullFolderResultStrHandle.SetFileHash( ResultFileHash );
  GetNetworkFullFolderResultStrHandle.SetFolderHash( ResultFolderHash );
  ReadResultStr := GetNetworkFullFolderResultStrHandle.get;
  GetNetworkFullFolderResultStrHandle.Free;

    // 发送读取结果
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
    // 目录信息列表
  FolderStr := getFolderStr;
  if FolderStr = '' then  // 没有目录
    FolderStr := Type_Empty;

    // 文件信息列表
  FileStr := getFileStr;
  if FileStr = '' then   // 没有文件
    FileStr := Type_Empty;

    // 组合
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
    // 不同目录层的不同分隔符
  FolderInfoSplit := Format( FolderListSplit_FolderInfo, [ IntToStr( FolderLevel ) ] );

    // 提取目录信息
  FolderInfoList := MySplitStr.getList( FolderInfoStr, FolderInfoSplit );
  if FolderInfoList.Count = FolderInfo_Count then
  begin
      // 提取信息
    FolderName := FolderInfoList[ Info_FolderName ];
    IsReaded := StrToBoolDef( FolderInfoList[ Info_IsReaded ], False );
    ChildFiles := FolderInfoList[ Info_FolderChildFiles ];
    ChildFolders := FolderInfoList[ Info_FolderChildFolders ];

      // 创建目录
    ScanFolderInfo := TScanFolderInfo.Create( FolderName );
    ScanFolderInfo.IsReaded := IsReaded;
    ScanFolderHash.AddOrSetValue( FolderName, ScanFolderInfo );

      // 目录信息已经读取
    if IsReaded then
    begin
        // 提取子文件
      FindNetworkFileResultHandle := TFindNetworkFileResultHandle.Create( ChildFiles );
      FindNetworkFileResultHandle.SetScanFile( ScanFolderInfo.ScanFileHash );
      FindNetworkFileResultHandle.Update;
      FindNetworkFileResultHandle.Free;

        // 提取子目录
      FindNetworkFolderResultHandle := TFindNetworkFolderResultHandle.Create( ChildFolders );
      FindNetworkFolderResultHandle.SetScanFolder( ScanFolderInfo.ScanFolderHash );
      FindNetworkFolderResultHandle.SetFolderLevel( FolderLevel + 1 ); // 下一层
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

      // 读取 目录信息
    if FolderStr <> Type_Empty then
      ReadFolder;

      // 读取 文件信息
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
    // 每一层目录的分隔符都不一样
  FolderSplit := Format( FolderListSplit_Folder, [IntToStr( FolderLevel )] );
  FolderInfoSplit := Format( FolderListSplit_FolderInfo, [IntToStr( FolderLevel )] );

    // 目录信息
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

    // 没有目录的标志
  if FolderStr = '' then
    FolderStr := Type_Empty;

    // 加密
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
  GetNetworkFolderResultStrHandle.SetFolderLevel( FolderLevel + 1 ); // 下一层
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

    // 解压文件
  ZipFile := TZipFile.Create;
  try
    ZipStream.Position := 0;
    ZipFile.Open( ZipStream, zmRead );
    try
      Result := True;
      for i := 0 to ZipFile.FileCount - 1 do
      begin
          // 结束
        if not FileUnpackOperator.ReadIsNextCopy then
          Break;

        // 定时刷新
        if RefreshCopyReader.ReadIsRefresh then
          FileUnpackOperator.RefreshCompletedSpace;

        try
            // 提取一个 压缩Buf
          ZipFile.Read( i, TempStream, ZipHeader );
          ReadSize := TempStream.Read( DataBuf, ZipHeader.UncompressedSize );
          TempStream.Free;

            // 获取文件路径
          FileName := ZipHeader.FileName;
          FileName := StringReplace( FileName, '/', '\', [rfReplaceAll] );
          FilePath := MyFilePath.getPath( SavePath ) + FileName;

            // 保存文件
          FileStream := TFileStream.Create( FilePath, fmCreate or fmShareDenyNone );
          FileStream.Write( DataBuf, ReadSize );
          FileStream.Free;

            // 设置文件修改时间
          FileDate := FileDateToDateTime( ZipHeader.ModifiedDateTime );
          MyFileSetTime.SetTime( FilePath, FileDate );

            // 刷新空间和速度信息
          RefreshCopyReader.AddCompletedSize( ZipHeader.UncompressedSize );
          FileUnpackOperator.AddSpeedSpace( ZipHeader.UncompressedSize );
        except
          Result := False; // 解压出错
        end;
      end;
      Result := Result and ( i = ZipFile.FileCount ); // 返回是否全部解压

      FileUnpackOperator.RefreshCompletedSpace; // 最后的刷新
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
  if IsEdition then  // 是否需要指定版本
  begin
    OriginalPath := MyFilePath.getOrinalName( IsEncrypted, True, FilePath, PasswordExt );
    if Assigned( FileEditionHash ) and FileEditionHash.ContainsKey( OriginalPath ) then  // 需要恢复指定版本
    begin
      EditionNum := MyFilePath.getDeletedEdition( FilePath );
      if EditionNum <> FileEditionHash[ OriginalPath ].EditionNum then
        Exit;
    end
    else   // 恢复最新版本
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
  Result := SecondsBetween( Now, LastRefreshTime ) >= 1;  // 1 秒钟 刷新一次界面
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

    // 是否压缩
  ActivateStream := BufStream;
  if ReadIsZip and IsZip then
    ActivateStream := TempStream;

  try
      // 读取 8M 数据
    HeartBeatTime := Now;
    FullBufSize := SizeOf( Buf );
    TotalReadSize := 0;
    RemainSize := ReadStream.Size - ReadStream.Position;
    for i := 0 to 15 do
    begin
      if RemainSize <= 0 then // 读取完成
        Break;

        // 预设读取空间
      BufSize := Min( FullBufSize, RemainSize );

        // 读取文件
      ReadSize := ReadStream.Read( Buf, BufSize );
      if ( ReadSize <= 0 ) and ( ReadSize <> BufSize ) then // 读取出错
        Exit;

        // 加密
      if IsEncrypt then
        SendFileUtil.Encrypt( Buf, ReadSize, EncPassword );

        // 写入内存
      ActivateStream.WriteBuffer( Buf, ReadSize );

        // 添加统计
      TotalReadSize := TotalReadSize + ReadSize;
      RemainSize := RemainSize - ReadSize;

        // 定时发送心跳
      HeartBeatReceiver.CheckSend( TcpSocket, HeartBeatTime );
    end;

      // 是否压缩
    if ReadIsZip and IsZip then
      SendFileUtil.CompressStream( TempStream, BufStream );

      // 返回
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

    // 发送读入流信息
  ReadStream.Position := ReadStreamPos;
  ReadStreamSize := ReadStream.Size;
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_ReadFileSize, ReadStreamSize );
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_ReadFilePos, ReadStreamPos );

    // 获取是否有足够的空间
  IsEnouthSpaceStr := MySocketUtil.RevJsonStr( TcpSocket );
  if IsEnouthSpaceStr = '' then  // 断开连接
  begin
    TcpSocket.Disconnect;
    SendFileOperator.LostConnectError;
    Exit;
  end;

    // 是否有足够的空间
  Result := StrToBoolDef( IsEnouthSpaceStr, False );
  if not Result then
    SendFileOperator.RevFileLackSpaceHandle;
end;

function TNetworkSendBaseHandle.ReadIsNextSend( IsSuccessSend : Boolean ): Boolean;
begin
  Result := False;

    // 停止传输
  if IsStopTransfer or WatchRevThread.IsRevStop then
  begin
    TcpSocket.Disconnect;
    Exit;
  end;

    // 失去连接
  if IsLostConn or WatchRevThread.IsRevLostConn then
  begin
    TcpSocket.Disconnect;
    SendFileOperator.LostConnectError;
    Exit;
  end;

    // 未知的错误, 未完整地发送文件
  if not IsSuccessSend then
  begin
    TcpSocket.Disconnect;
    SendFileOperator.TransferFileError;
    Exit;
  end;

    // 是否继续传输
  Result := True;
end;

function TNetworkSendBaseHandle.ReadIsStopTransfer: Boolean;
var
  IsStopSend, IsStopRev : Boolean;
begin
    // 读取是否停止发送
  IsStopSend := not SendFileOperator.ReadIsNextSend;

    // 发送是否停止到对方
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_SendFileCompletedNow, IsStopSend );

    // 接收是否停止接收
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
  Result := Max( Result, 1 * Size_KB ); // 至少 1 KB
end;

function TNetworkSendBaseHandle.RevWriteSize(ReadSize: Integer): Boolean;
var
  WriteSizeStr : string;
  WriteSize : Integer;
  IsEnouthSpace : Boolean;
begin
  Result := True;

    // 获取 对方写入的空间信息
  WriteSizeStr := HeartBeatReceiver.CheckReceive( TcpSocket );
  if WriteSizeStr = '' then // 断线
  begin
    SendFileOperator.LostConnectError;
    Result := False;
    Exit;
  end;
  WriteSizeStr := MySocketUtil.ReadMsgToMsgStr( WriteSizeStr );

    // 与要发送的空间一致
  WriteSize := StrToInt( WriteSizeStr );
  if WriteSize = ReadSize then
    Exit;

    // 读取是否因为空间不足
  IsEnouthSpace := MySocketUtil.RevBoolData( TcpSocket );
  if not IsEnouthSpace then
    SendFileOperator.RevFileLackSpaceHandle  // 空间不足
  else
    SendFileOperator.WriteFileError; // 写错误处理

  Result := False;
end;

function TNetworkSendBaseHandle.SendBufStream: Boolean;
var
  RemainSize, TotalSendSize, SendRemainSize : Int64;
  SendSize, SendPos : Integer;
begin
  try
      // 初始化信息
    BufStream.Position := 0;
    RemainSize := BufStream.Size;
    while RemainSize > 0 do
    begin
        // 定时刷新已完成空间信息
      if RefreshSendReader.ReadIsRefresh then
        SendFileOperator.RefreshCompletedSpace;

        // 获取 发送数据的大小
      TotalSendSize := Min( ReadSendBlockSize, RemainSize );
      TotalSendSize := Min( TotalSendSize, SIzeOf( TotalSendDataBuf ) );
      MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_SendFileSizeNow, TotalSendSize );

        // 断开连接
      if TotalSendSize <= 0 then
        IsLostConn := True;

        // 获取 要发送的数据
      BufStream.ReadBuffer( TotalSendDataBuf, TotalSendSize );

        // 发送数据
      DebugLock.DebugFile( 'Send Data Buf Start', ReadSendPath );
      SendRemainSize := TotalSendSize;
      SendPos := 0;
      while SendRemainSize > 0 do
      begin
          // 复制发送的数据
        CopyMemory( @SendDataBuf, @TotalSendDataBuf[SendPos], SendRemainSize );

          // 发送数据
        SendSize := TcpSocket.SendBuf( SendDataBuf, SendRemainSize );
        if ( SendSize = SOCKET_ERROR ) or ( ( SendSize <= 0 ) and ( SendRemainSize <> 0 ) ) then // 目标断开连接
        begin
          IsLostConn := True;
          Break;
        end;
        SendRemainSize := SendRemainSize - SendSize;
        SendPos := SendPos + SendSize;
      end;
      TotalSendSize := TotalSendSize - SendRemainSize;
      DebugLock.DebugFile( 'Send Data Buf Stop', IntToStr( TotalSendSize ) );

        // 计算剩余和位置
      RemainSize := RemainSize - TotalSendSize;
      AddSendedSpace( TotalSendSize );  // 统计发送信息

        // 已断开连接
      if IsLostConn or WatchRevThread.IsRevLostConn then
        Break;

        //已停止传输
      if ReadIsStopTransfer then
      begin
        IsStopTransfer := True;
        Break;
      end;
    end;

      // 返回 发送的空间信息
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
      // 剩余空间
    RemainSize := ReadStreamSize - ReadStreamPos;
    while RemainSize > 0 do
    begin
        // 统计要发送的空间
      DebugLock.DebugFile( 'Read Stream Data', ReadSendPath );
      ReadSize := ReadBufStream;  // 读取 8M 数据，返回实际读取的空间信息

        // 读取文件 是否成功
      IsReadOK := ReadSize > 0;
      MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_FileReadStatus, IsReadOK );
      if not IsReadOK then // 读取出错
      begin
        SendFileOperator.ReadFileError; // 读错误处理
        Break;
      end;

        // 发送 文件读取空间
      MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_FileReadSize, ReadSize );

        // 发送 文件发送空间
      BufSize := BufStream.Size;
      MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_FileSendSize, BufSize );

        // 发送 8M 数据
      DebugLock.DebugFile( 'Send Stream Data', ReadSendPath );
      WatchRevThread.StartWatch;
      IsSendSuccess := SendBufStream;
      WatchRevThread.StopWatch;

        // 是否网络断开 ， 是否继续发送
      if not ReadIsNextSend( IsSendSuccess ) then
        Break;

        // 写入失败
      DebugLock.DebugFile( 'Rev Write Size', ReadSendPath );
      IsWriteSuccess := RevWriteSize( ReadSize );
      if not IsWriteSuccess then
        Break;

        // 添加 压缩空间
      ZipSize := ReadSize - BufSize;
      if ZipSize <> 0 then
        AddSendedSpace( ZipSize );

        // 设置已发送的文件位置
      RemainSize := RemainSize - ReadSize;
      ReadStreamPos := ReadStreamPos + ReadSize;
    end;

      // 最后的刷新
    SendFileOperator.RefreshCompletedSpace;

      // 是否发送完成
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

    // 创建读出流
  if not ReadIsCreateReadStream then
  begin
    SendFileOperator.ReadFileError;
    Exit;
  end;

      // 是否有足够的空间 或 已断开连接
  if not ReadIsEnoughSpace then
    Exit;

    // 创建写入流
  if not ReadIsCreateWriteStrem then
  begin
    SendFileOperator.WriteFileError;
    Exit;
  end;

    // 初始化文件发送
  FileSendIniHandle;

    // 是否压缩文件
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_IsZipFile, IsZip );

    // 发送文件
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
    // 创建读文件流
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
  try   // 释放读入流
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
        // 读取 失败
      RevStr := HeartBeatReceiver.CheckReceive( TcpSocket );
      RevStr := MySocketUtil.ReadMsgToMsgStr( RevStr );
      IsReadOK := StrToBoolDef( RevStr, False );
      if not IsReadOK then
      begin
        RecieveFileOperator.ReadFileError; // 读文件出错
        Break;
      end;

        // 获取 读取文件空间
      ReadSize := MySocketUtil.RevJsonInt( TcpSocket );

        // 获取 接收文件空间
      BufSize := MySocketUtil.RevJsonInt( TcpSocket );

        // 接收 文件
      DebugLock.DebugFile( 'Rev Stream Data', ReadReceivePath );
      BufStream.Clear;
      IsSuccessRev := ReceiveBufStream( BufSize );

        // 是否网络断开 ,  是否继续接收
      if not ReadIsNextRev( IsSuccessRev ) then
        Break;

        // 写入
      DebugLock.DebugFile( 'Write Stream Data', ReadReceivePath );
      WriteSize := WriteBufStream;

        // 发送写入空间
      IsSuccessWrite := SendWriteSize( WriteSize, ReadSize );
      if not IsSuccessWrite then
        Break;

        // 刷新压缩空间
      ZipSize := WriteSize - BufSize;
      if ZipSize <> 0 then
        AddRecvedSize( ZipSize );

        // 移动文件位置
      ReaminSize := ReaminSize - WriteSize;
      WriteStreamPos := WriteStreamPos + WriteSize;
    end;

       // 立刻刷新 完成空间信息
    RecieveFileOperator.RefreshCompletedSpace;

      // 是否全部发送
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
  if IsCreaterStr = '' then  // 连接已断开
  begin
    TcpSocket.Disconnect;
    RecieveFileOperator.LostConnectError;
    Exit;
  end;

    // 创建流是否成功
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
    // 获取写入流信息
  WriteStreamSize := MySocketUtil.RevJsonInt64( TcpSocket );
  WriteStreamPos := MySocketUtil.RevJsonInt64( TcpSocket );

    // 判断是否有足够的空间
  Result := getIsEnouthSpace;
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_IsEnouthSpace, Result );
end;

function TNetworkReceiveBaseHandle.ReadIsNextRev( IsSuccessRev : Boolean ): Boolean;
begin
  Result := False;

    // 停止传输
  if IsStopTransfer then
  begin
    TcpSocket.Disconnect;
    Exit;
  end;

    // 失去连接
  if IsLostConn then
  begin
    TcpSocket.Disconnect;
    RecieveFileOperator.LostConnectError;
    Exit;
  end;

    // 未知的错误， 没有完整接收文件
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
    // 接收发送方是否停止
  IsStopSend := MySocketUtil.RevJsonBool( TcpSocket );

    // 获取是否停止接收
  IsStopRev := not RecieveFileOperator.ReadIsNextReceive;
  if IsStopRev then  // 停止接收则发送通知
    MySocketUtil.SendData( TcpSocket, ReceiveStatus_Stop );

    // 返回是否停止接收
  Result := IsStopSend or IsStopRev;
end;

function TNetworkReceiveBaseHandle.ReceiveBufStream(BufSize: Integer): Boolean;
var
  RemainSize, RevSizeTotal, RevRemainSize : Int64;
  RevSize, RevPos : Integer;
  RevBlockSize : Int64;
begin
  try
      // 初始化信息
    RemainSize := BufSize;
    while RemainSize > 0 do
    begin
      RefreshRevReader.StartRev; // 计算接收速度

        // 定时刷新已完成空间
      if RefreshRevReader.ReadIsRefresh then
        RecieveFileOperator.RefreshCompletedSpace;

        // 接收数据的总空间
      RevSizeTotal := MySocketUtil.RevJsonInt64( TcpSocket );
      if RevSizeTotal <= 0 then // 已断开
        IsLostConn := True;

        // 开始接收数据
      DebugLock.DebugFile( 'Start Rev Data Buf ' + IntToStr( RevSizeTotal ), ReadReceivePath );
      RevRemainSize := RevSizeTotal;
      RevPos := 0;
      while RevRemainSize > 0 do
      begin
        RevSize := MySocketUtil.RevBuf( TcpSocket, SendDataBuf, RevRemainSize );
        if ( RevSize = SOCKET_ERROR ) or ( ( RevSize = 0 ) and ( RevRemainSize <> 0 ) ) then // 目标断开连接
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

        // 设置接收的数据
      BufStream.WriteBuffer( TotalSendDataBuf, RevSizeTotal );

        // 计算剩余和位置
      RemainSize := RemainSize - RevSizeTotal;
      AddRecvedSize( RevSizeTotal );

        // 连接已断开
      if IsLostConn then
        Break;

        // 已停止传输
      if ReadIsStopTransfer then
      begin
        IsStopTransfer := True;
        Break;
      end;

        // 刷新接收速度
      SendRevSpeed( RefreshRevReader.StopRev( RevSizeTotal ) );
    end;

      // 返回接收的空间信息
    Result := RemainSize = 0;
  except
    Result := False;
  end;

    // 发送已完成
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
  if WriteSize = ReadSize then  // 写入成功
    Exit;

      // 是否有足够的空间
  IsEnoughSpace :=  getIsEnouthSpace;
  MySocketUtil.SendData( TcpSocket, IsEnoughSpace );
  if not IsEnoughSpace then
    RecieveFileOperator.RevFileLackSpaceHandle  // 空间不足
  else
    RecieveFileOperator.WriteFileError; // 写文件出错

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

    // 读取流创建
  if not ReadIsCreateReadStream then
    Exit;

    // 是否有足够的写入空间
  if not ReadIsEnoughSpace then
  begin
    RecieveFileOperator.RevFileLackSpaceHandle;
    Exit;
  end;

    // 写入流创建
  if not ReadIsCreateWriteStrem then
  begin
    RecieveFileOperator.WriteFileError;
    Exit;
  end;

    // 接收文件初始化
  FileRevceiveIniHandle;

    // 是否压缩文件
  IsZipFile := MySocketUtil.RevJsonBool( TcpSocket );

    // 文件接收
  if not FileReceiveHandle then
  begin
    ReceiveFileIncompleted;
    Exit;
  end;

    // 接收文件成功
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
      // 非压缩文件，则解压
    ActivateStream := BufStream;
    if ReadIsZip and IsZipFile then
    begin
      ActivateStream := TempStream;
      SendFileUtil.DecompressStream( BufStream, TempStream );
    end;

      // 写文件
    HeartBeatTime := Now;
    WriteSize := 0;
    RemainSize := ActivateStream.Size;
    ActivateStream.Position := 0;
    FullBufSize := SizeOf( DataBuf );
    while RemainSize > 0 do
    begin
      WriteDataSize := Min( FullBufSize, RemainSize );
      ActivateStream.ReadBuffer( DataBuf, WriteDataSize );

        // 解密
      if IsDecrypt then
        SendFileUtil.Deccrypt( DataBuf, WriteDataSize, DecPassword );

      WriteDataSize := WriteStream.Write( DataBuf, WriteDataSize );
      if WriteDataSize <= 0 then
        Break;
      WriteSize := WriteSize + WriteDataSize;
      RemainSize := RemainSize - WriteDataSize;

        // 定时发送心跳
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
  Result := SecondsBetween( Now, LastRefreshTime ) >= 1;  // 1 秒钟 刷新一次界面
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
    // 用秒做单位
  RevSize := RevSize * 1000;

    // 用了多少毫秒
  RevTime := MilliSecondsBetween( Now, StartRevTime );
  RevTime := Max( 1, RevTime );

    // 单位是间传输的空间
  Result := RevSize div RevTime;

    // 至少发送 2KB
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
  try    // 先关闭文件
    if Assigned( WriteStream ) then
    begin
      WriteStream.Free;
      WriteStream := nil;
    end;
  except
  end;

    // 设置文件修改时间
  MyFileSetTime.SetTime( ReceiveFilePath, ReceiveFileTime );
end;

procedure TNetworkReceiveFileHandle.ReceiveFileIncompleted;
begin
  RecieveFileOperator.MarkContinusSend;
end;

function TNetworkReceiveFileHandle.CreateWriteStream: Boolean;
begin
  try       // 创建写入流
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
  try    // 释放写入流
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
    // 计算是否有足够的空间， 并发送结果
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


  Result := SecondsBetween( Now, LastRefreshTime ) >= 1;  // 1 秒钟 刷新一次界面
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
    if RevStr = ReceiveStatus_Speed then  // 设置接收速度
      RevSpeed := MySocketUtil.RevJsonInt64( TcpSocket )
    else
    if RevStr = ReceiveStatus_Stop then  // 停止接收
      IsRevStop := True
    else
    begin
      if RevStr = ReceiveStatus_Completed then // 接收完成
        IsRevCompleted := True
      else                                // 接收断开
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
    // 接收完成 或 已经断开连接
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
    // 定时发送心跳
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
    // 定时发送心跳
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
    if Result <> FileReq_HeartBeat then  // 心跳则继续等待接收
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

