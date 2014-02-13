unit UBackupThread;

interface

uses UModelUtil, Generics.Collections, Classes, SysUtils, SyncObjs, UMyUtil, DateUtils,
     Math, UMainFormFace, Windows, UFileBaseInfo, sockets, UMyTcp, UFolderCompare, UMyDebug, StrUtils,
     uDebugLock, zip, uDebug;

type

{$Region ' 数据结构 ' }

    // 备份路径信息
  TBackupPathInfo = class
  public
    SourcePath : string; // 源路径
    DesItemID : string;  // 目标信息
  public
    procedure SetItemInfo( _DesItemID, _SourcePath : string );
  end;
  TLocalBackupPathInfo = class( TBackupPathInfo )end;
  TNetworkBackupPathInfo = class( TBackupPathInfo )end;
  TBackupPathList = class( TObjectList<TBackupPathInfo> )end;

    // 日志信息
  TLogPathInfo = class( TBackupPathInfo )
  public
    FilePath : string;
    FileTime : TDateTime;
  public
    procedure SetFileInfo( _FilePath : string; _FileTime : TDateTime );
  end;
  TLogPathList = class( TObjectList<TLogPathInfo> )end;

    // 预览信息
  TPreviewLogInfo = class( TLogPathInfo )end;
  TLocalPreviewLogInfo = class( TPreviewLogInfo )end;
  TNetworkPreviewLogInfo = class( TPreviewLogInfo )end;

    // 恢复信息
  TRestoreLogInfo = class( TLogPathInfo )end;
  TLocalRestoreLogInfo = class( TRestoreLogInfo )end;
  TNetworkRestoreLogInfo = class( TRestoreLogInfo )end;


{$EndRegion}

{$Region ' 文件备份 分析数据 ' }

    // 分析数据
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

    // 备份分析
  TBackupAnalyzer = class
  public
    BackupSpaceList : TBackupSpaceList;
  public
    constructor Create;
    procedure AddSpace( TypeName : string; FileSize : Int64 );
    destructor Destroy; override;
  end;

    // 读取分析数据
  TAnalyzeReadHandle = class
  public
    SourceFileHash : TScanFileHash;
    BackupAnalyzer : TBackupAnalyzer;
  public
    constructor Create( _SourceFileHash : TScanFileHash );
    procedure SetAnalyzer( _BackupAnalyzer : TBackupAnalyzer );
    procedure Update;
  end;

    // 重设分析数据
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

{$Region ' 文件备份 数据结构 ' }

  TBackupParamsData = class;

    // 是否取消备份
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

      // 参数信息
  TBackupParamsData = class
  public    // 基本信息
    DesItemID, SourcePath : string;
    IsFile : Boolean;
  public   // 加密信息
    IsEncrypted : Boolean;
    Password, ExtPassword : string;
  public   // 删除信息
    IsSaveDeleted : Boolean;
    KeepDeletedCount : Integer;
  public   // 过滤器信息
    IncludeFilterList : TFileFilterList;  // 包含过滤器
    ExcludeFilterList : TFileFilterList;  // 排除过滤器
  public   // 信息提取器
    SpeedReader : TSpeedReader;
    BackupCancelReader : TBackupCancelReader;
    BackupAnalyzer : TBackupAnalyzer;
  end;

{$EndRegion}


{$Region ' 文件续传 ' }

    // 续传处理
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

{$Region ' 文件比较 ' }

    // 文件寻找
  TBackupFolderFindHandle = class( TLocalFolderFindHandle )
  public
    IncludeFilterList : TFileFilterList;  // 包含过滤器
    ExcludeFilterList : TFileFilterList;  // 排除过滤器
  public
    procedure SetFilterInfo( _IncludeFilterList, _ExcludeFilterList : TFileFilterList );
  protected      // 过滤器
    function IsFileFilter( FilePath : string; sch : TSearchRec ): Boolean;override;
    function IsFolderFilter( FolderPath : string ): Boolean;override;
  end;

    // 本地源目录 比较算法
  TBackupFolderCompareHandler = class( TFolderCompareHandler )
  public
    Params : TBackupParamsData;
    DesItemID, SourcePath : string;
  public
    IsEncrypted : Boolean;
    PasswordExt : string;
  public
    IncludeFilterList : TFileFilterList;  // 包含过滤器
    ExcludeFilterList : TFileFilterList;  // 排除过滤器
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

    // 文本地源件 比较算法
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

{$Region ' 文件压缩 ' }

    // 备份文件打包器
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
  private     // 可能需要 加密压缩流
    function ReadFileStream( FilePath : string ) : TStream;
  end;

{$EndRegion}

{$Region ' 结果处理 ' }

    // 处理扫描结果
  TBackupResultHandler = class
  public
    ScanResultInfo : TScanResultInfo;
    SourceFilePath : string;
  public   // 属性信息
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
  protected         // 添加
    procedure SourceFileAdd;virtual;abstract;
    procedure SourceFolderAdd;virtual;abstract;
    procedure SourceFileAddZip;virtual;abstract;
  protected         // 删除
    procedure DesFileRemove;virtual;abstract;
    procedure DesFolderRemove;virtual;abstract;
  protected         // 回收
    procedure DesFileRecycle;virtual;abstract;
    procedure DesFolderRecycle;virtual;abstract;
  protected         // 写日志
    procedure LogZipStream( ZipStream : TMemoryStream; IsCompleted : Boolean );
    procedure LogZipFile( ZipName : string; IsCompleted : Boolean );
    procedure LogBackupCompleted;
    procedure LogBackupInCompleted;
  end;

      // 处理扫描结果
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

{$Region ' 备份操作 ' }

    // 备份试用版限制
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

    // 备份的具体操作步骤
  TBackupOperater = class
  public
    DesItemID, SourcePath : string;
    IsFile : Boolean;
  public
    procedure SetParams( Params : TBackupParamsData );virtual;
  public       // 备份属性操作
    function getDesItemIsAvailable: Boolean;virtual;abstract;
    procedure SetBackupCompleted;virtual;abstract;
  public       // 文件比较
    function CreaterFileCompareHandler : TBackupFileCompareHandler;virtual;abstract;
    function CreaterFolderCompareHandler : TBackupFolderCompareHandler;virtual;abstract;
  public       // 文件传输
    function CreaterContinuesHandler : TBackupContinuesHandler;virtual;abstract;  // 续传
    function CreaterFileBackupHandler : TFileBackupHandler;virtual;abstract;  // 备份
  end;

    // 备份操作的完整过程
  TBackupProcessHandle = class
  public    // 扫描信息
    BackupParamsData : TBackupParamsData;
    DesItemID, SourcePath : string;
    IsFile : Boolean;
    BackupCancelReader : TBackupCancelReader;
  public    // 备份操作
    BackupOperator : TBackupOperater;
  public   // 文件扫描结果
    TotalCount : Integer;
    TotalSize, TotalCompleted : Int64;
  public   // 文件变化信息
    ScanResultList : TScanResultList;
  public   // 新增备份信息
    NewBackupCount : Integer;
    NewBackupFileList : TStringList;
  public
    constructor Create;
    procedure SetBackupParamsData( _BackupParamsData : TBackupParamsData );
    procedure SetBackupOperator( _BackupOperator : TBackupOperater );
    procedure Update;virtual;
    destructor Destroy; override;
  protected       // 备份前检测
    function ReadDesItemIsAvailable: Boolean; // 备份目标是否可用
    function ReadBackupPathIsAvailable : Boolean;  // 源路径是否可用
  protected       // 扫描
    function ContinuesHandle: Boolean; // 续传
    function BackupCompareHandle: Boolean;
    procedure FileCompareHandle;
    procedure FolderCompareHandle;
    procedure ResetBackupSpaceInfo;
  protected       // 备份
    function CompareResultHandle: Boolean;
  protected       // 备份完成
    function getIsBackupCompleted : Boolean;
    procedure SetLastSyncTime;
    procedure SetBackupCompleted;
  end;

{$EndRegion}


{$Region ' 本地备份 文件比较 ' }

    // 本地目录
  TLocalBackupFolderCompareHandler = class( TBackupFolderCompareHandler )
  protected       // 目标文件信息
    procedure FindDesFileInfo;override;
  protected        // 比较子目录
    function getScanHandle( SourceFolderName : string ) : TFolderCompareHandler;override;
  end;

    // 本地文件
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

{$Region ' 本地备份 文件续传 ' }

    // 本地文件 续传
  TLocalBackupContinuesHandler = class( TBackupContinuesHandler )
  public
    DesFilePath : string; // 目标路径
  public
    procedure Update;override;
  protected
    function ReadDestinationPos : Boolean;override;
    function FileCopy: Boolean;override;
  end;

{$EndRegion}

{$Region ' 本地备份 结果处理 ' }

    // 结果处理
  TLocalBackupResultHandle = class( TBackupResultHandler )
  private
    DesFilePath : string;
    RecycleFilePath : string;
  public
    procedure Update;override;
  protected         // 添加
    procedure SourceFileAdd;override;
    procedure SourceFolderAdd;override;
    procedure SourceFileAddZip;override;
  protected         // 删除
    procedure DesFileRemove;override;
    procedure DesFolderRemove;override;
  protected         // 回收
    procedure DesFileRecycle;override;
    procedure DesFolderRecycle;override;
  end;

    // 本地备份 结果处理
  TLocalFileBackupHandler = class( TFileBackupHandler )
  protected
    procedure Handle( ScanResultInfo : TScanResultInfo );override;
    procedure CompletedHandle;override;
  private
    procedure HandleNow( ScanResultInfo : TScanResultInfo );
  end;

{$EndRegion }

{$Region ' 本地备份 文件传输 ' }

    // 文件解压
  TBackupFileUnpackOperator = class( TFileUnpackOperator )
  protected
    DesItemID, SourcePath : string;
    BackupCancelReader : TBackupCancelReader;
    SpeedReader : TSpeedReader;
  public
    procedure SetParams( Params : TBackupParamsData );
  public
    function ReadIsNextCopy : Boolean;override; // 检测是否继续解压
    procedure AddSpeedSpace( SendSize : Integer );override;
    procedure RefreshCompletedSpace;override; // 刷新已完成空间
  end;

    // 文件复制
  TBackupCopyFileOperator = class( TCopyFileOperator )
  protected
    DesItemID, SourcePath : string;
    BackupCancelReader : TBackupCancelReader;
    SpeedReader : TSpeedReader;
  public
    procedure SetParams( Params : TBackupParamsData );
  protected
    function ReadIsNextCopy : Boolean;override; // 检测是否继续复制
    procedure AddSpeedSpace( SendSize : Integer );override; // 添加速度信息
    procedure RefreshCompletedSpace;override; // 刷新已完成空间
  protected
    procedure MarkContinusCopy;override; // 续传时调用
    procedure DesWriteSpaceLack;override; // 空间不足
    procedure ReadFileError;override;  // 读文件出错
    procedure WriteFileError;override; // 写文件出错
  end;

{$Endregion}

{$Region ' 本地备份 操作 ' }

      // 本地备份的具体操作步骤
  TLocalBackupOperater = class( TBackupOperater )
  public       // 备份属性操作
    function getDesItemIsAvailable: Boolean;override;
    procedure SetBackupCompleted;override;
  public       // 文件比较
    function CreaterFileCompareHandler : TBackupFileCompareHandler;override;
    function CreaterFolderCompareHandler : TBackupFolderCompareHandler;override;
  public       // 文件传输
    function CreaterContinuesHandler : TBackupContinuesHandler;override;
    function CreaterFileBackupHandler : TFileBackupHandler;override;
  end;

{$EndRegion}


{$Region ' 网络备份 数据结构 ' }

    // 网络备份取消判断
  TNetworkBackupCancelReader = class( TBackupCancelReader )
  private
    TcpSocket : TCustomIpClient;
  public
    procedure SetParams( Params : TBackupParamsData );override;
    function getIsRun : Boolean;override;
  end;

    // 网络备份参数
  TNetworkBackupParamsData = class( TBackupParamsData )
  public
    TcpSocket : TCustomIpClient;
    HeartBeatTime : TDateTime;
  public
    procedure CheckHeartBeat;
  end;

{$EndRegion}

{$Region ' 网络备份 文件比较 ' }

    // 网络目录
  TNetworkFolderCompareHandler = class( TBackupFolderCompareHandler )
  public
    TcpSocket : TCustomIpClient;
    NetworkBackupParamsData : TNetworkBackupParamsData;
  public
    procedure SetParams( _Params : TBackupParamsData );override;
  protected       // 目标文件信息
    procedure FindDesFileInfo;override;
  protected        // 比较子目录
    function getScanHandle( SourceFolderName : string ) : TFolderCompareHandler;override;
  protected        // 定时心跳
    function CheckNextScan : Boolean;override;
  end;

    // 网络文件
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

{$Region ' 网络备份 文件续传 ' }

      // 网络文件 续传
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

{$Region ' 网络备份 多线程 ' }

      // 多线程备份文件
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

{$Region ' 网络备份 结果处理 ' }

    // 备份文件结果处理
  TNetworkBackupResultHandle = class( TBackupResultHandler )
  public
    TcpSocket : TCustomIpClient;
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
  protected         // 添加
    procedure SourceFileAdd;override;
    procedure SourceFolderAdd;override;
    procedure SourceFileAddZip;override;
  protected         // 删除
    procedure DesFileRemove;override;
    procedure DesFolderRemove;override;
  protected         // 回收
    procedure DesFileRecycle;override;
    procedure DesFolderRecycle;override;
  protected         // 等待云文件操作
    procedure WaitCloudCompleted;
  end;

    // 网络备份 结果处理
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
  private       // 结果处理
    procedure SendFile( ScanResultInfo : TScanResultInfo );
    procedure HandleNow( ScanResultInfo : TScanResultInfo );
  end;

{$EndRegion}

{$Region ' 网络备份 文件传输 ' }

    // 备份文件
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
    procedure RevFileLackSpaceHandle;override; // 缺少空间的处理
    procedure MarkContinusSend;override; // 续传时调用
    procedure ReadFileError;override;  // 读文件出错
    procedure WriteFileError;override; // 写文件出错
    procedure LostConnectError;override; //断开连接出错
    procedure TransferFileError;override; // 发送文件出错
  end;

{$EndRegion}

{$Region ' 网络备份 操作 ' }

      // 网络备份的具体操作步骤
  TNetworkBackupOperater = class( TBackupOperater )
  private
    TcpSocket : TCustomIpClient;
  public
    procedure SetParams( Params : TBackupParamsData );override;
  protected       // 备份属性操作
    function getDesItemIsAvailable: Boolean;override;
    procedure SetBackupCompleted;override;
  public       // 文件比较
    function CreaterFileCompareHandler : TBackupFileCompareHandler;override;
    function CreaterFolderCompareHandler : TBackupFolderCompareHandler;override;
  public       // 文件传输
    function CreaterContinuesHandler : TBackupContinuesHandler;override;
    function CreaterFileBackupHandler : TFileBackupHandler;override;
  end;

{$EndRegion}


{$Region ' 日志预览 ' }

    // 父类
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
    procedure ReadLog;  // 读取信息
    procedure HandleLog;virtual;abstract; // 处理信息
    procedure LogFileNotExist; // 日志文件不存在
  protected
    function ReadIsNomal: Boolean;virtual;abstract;
    procedure ReadDeletedFileHash;virtual;abstract;
  private
    function ReadIsDeleted: Boolean;
  end;

    // 本地处理
  TLocalLogHandle = class( TBackupLogStartHandle )
  protected
    function ReadIsNomal: Boolean;override;
    procedure ReadDeletedFileHash;override;
  end;

    // 本地预览
  TLocalPreviewLogHandle = class( TLocalLogHandle )
  protected
    procedure HandleLog;override; // 处理
  end;

    // 本地恢复
  TLocalRestoreLogHandle = class( TLocalLogHandle )
  protected
    procedure HandleLog;override; // 处理
  end;

    // 网络处理
  TNetworkLogHandle = class( TBackupLogStartHandle )
  private
    TcpSocket : TCustomIpClient;
  public
    procedure Update;override;
  protected
    function ReadIsNomal: Boolean;override;
    procedure ReadDeletedFileHash;override;
  end;

    // 网络预览
  TNetworkPreviewLogHandle = class( TNetworkLogHandle )
  protected
    procedure HandleLog;override; // 处理
  end;

    // 网络恢复
  TNetworkRestoreLogHandle = class( TNetworkLogHandle )
  protected
    procedure HandleLog;override; // 处理
  end;

{$EndRegion}


{$Region ' 连接信息 ' }

    // 已连接的 Socket
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

    // 处理连接
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
  public       // 获取反向连接
    constructor Create;
    function getBackupPcConn( _DesItemID, _SourcePath, _BackupConn : string ) : TCustomIpClient;
    procedure AddLastConn( LastDesItemID : string; TcpSocket : TCustomIpClient );
    procedure LastConnRefresh;
    procedure StopRun;
    destructor Destroy; override;
  public       // 远程结果
    procedure AddBackConn( TcpSocket : TCustomIpClient );
    procedure BackConnBusy;
    procedure BackConnError;
  private      // 等待
    function getConnect : TCustomIpClient;
    function getLastConnect : TCustomIpClient;
    function getBackConnect : TCustomIpClient;
    procedure WaitBackConn;
  private       // 异常处理
    procedure CanNotConnHandle;
    procedure RemoteBusyHandle;
  end;

{$EndRegion}

{$Region ' 文件备份 ' }

    // 开始备份
  TBackupStartHandle = class
  public
    BackupPathInfo : TBackupPathInfo;
    DesItemID, SourcePath : string;
    IsLocalBackup : Boolean;
  private
    TimeReader : TSpeedReader;  // 计时器
    BackupCancelReader : TBackupCancelReader; // 取消提示器
    BackupParamsData : TBackupParamsData;  // 备份参数
    BackupOperator : TBackupOperater;  // 备份操作
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

    // 源目录 扫描
    // 目标目录 复制/删除
  TBackupHandleThread = class( TDebugThread )
  private  // 是否收到免费限制
    IsShowFreeeLimit : Boolean;
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  public          // 扫描
    procedure StartBackup( BackupPathInfo : TBackupPathInfo );
    procedure StopBackup( BackupPathInfo : TBackupPathInfo );
  private        // 免费版试用限制
    procedure ShowFreeLimit;
  end;

    // 本地备份 源路径 扫描和复制
  TMyBackupHandler = class
  public
    IsBackupRun : Boolean;  // 是否继续备份
    IsRun : Boolean;  // 是否程序结束
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

{$Region ' 日志信息 ' }

    // 操作线程
  TBackupLogHandleThread = class( TDebugThread )
  protected
    procedure Execute; override;
  public          // 扫描
    procedure StartHandle( LogPathInfo : TLogPathInfo );
  end;

    // 控制器
  TMyBackupLogHandler = class
  public
    IsRun : Boolean;  // 是否程序结束
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
    // 源路径 扫描线程
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
    // 非试用版, 跳过
  if not MyRegisterInfo.IsFreeLimit then
    Exit;

    // 不显示
  if not IsShowFreeeLimit then
    Exit;

    // 显示备份限制信息
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

    // 开始备份
  BackupItemAppApi.BackupStart;
  MyBackupHandler.IsBackupRun := True;
  IsShowFreeeLimit := False;

    // 备份操作
  while MyBackupHandler.IsRun do
  begin
    ScanPathInfo := MyBackupHandler.getScanPathInfo;
    if ScanPathInfo = nil then
      Break;

    try
        // 扫描路径
      StartBackup( ScanPathInfo );
    except
      on  E: Exception do
        MyWebDebug.AddItem( 'Backup File Error', e.Message );
    end;

      // 停止扫描
    StopBackup( ScanPathInfo );
  end;

    // 检查是否超过试用限制
  ShowFreeLimit;

    // 结束备份
  if MyBackupHandler.IsBackupRun then
    BackupItemAppApi.BackupStop
  else  // 暂停备份
    BackupItemAppApi.BackupPause;

    // 程序结束，设置线程结束
  if not MyBackupHandler.IsRun then
    MyBackupHandler.IsCreateThread := False;

    // 结束
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

    // 添加到扫描列表中
  ScanPathList.Add( ScanPathInfo );

    // 没有创建线程，则先创建线程
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

    // 1 秒钟 显示扫描文件数 一次
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

    // 读取文件信息
  BackupFolderFindHandle := TBackupFolderFindHandle.Create;
  BackupFolderFindHandle.SetFolderPath( SourceFolderPath );
  BackupFolderFindHandle.SetFilterInfo( IncludeFilterList, ExcludeFilterList );
  BackupFolderFindHandle.SetSleepCount( SleepCount );
  BackupFolderFindHandle.SetScanFile( SourceFileHash );
  BackupFolderFindHandle.SetScanFolder( SourceFolderHash );
  BackupFolderFindHandle.Update;
  SleepCount := BackupFolderFindHandle.SleepCount;
  BackupFolderFindHandle.Free;

    // 分析读取结果
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
    // 已读取
  if IsDesReaded then
    Exit;

    // 循环寻找 目录文件信息
  DesFolderPath := MyFilePath.getLocalBackupPath( DesItemID, SourceFolderPath );

    // 寻找目录
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

   // 不存在子目录
  if not DesFolderHash.ContainsKey( SourceFolderName ) then
    Exit;

    // 添加子目录信息
  ChildFolderInfo := DesFolderHash[ SourceFolderName ];
  LocalFolderScanHandle.SetIsDesReaded( ChildFolderInfo.IsReaded );

    // 子目录未读取
  if not ChildFolderInfo.IsReaded then
    Exit;

    // 子目录信息
  LocalFolderScanHandle.DesFolderHash.Free;
  LocalFolderScanHandle.DesFolderHash := ChildFolderInfo.ScanFolderHash;
  ChildFolderInfo.ScanFolderHash := TScanFolderHash.Create;

    // 子文件信息
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
    // 本地目标文件
  LocalDesFilePath := MyFilePath.getLocalBackupPath( DesItemID, DesFilePath );

    // 寻找本地目标文件信息
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
    // 本地目标目录
  LocalDesFilePath := MyFilePath.getLocalBackupPath( DesItemID, DesFilePath );
  LocalDesFolderPath := ExtractFileDir( LocalDesFilePath );

  ParentFolderHash := TScanFolderHash.Create;

    // 搜索父目录文件
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
    // 目标文件回收
  FileRecycleHandle := TFileRecycleHandle.Create;
  FileRecycleHandle.SetPathInfo( DesFilePath, RecycleFilePath );
  FileRecycleHandle.SetSaveDeletedEdition( KeedEditionCount );
  FileRecycleHandle.Update;
  FileRecycleHandle.Free;
end;

procedure TLocalBackupResultHandle.DesFileRemove;
begin
    // 删除文件
  SysUtils.DeleteFile( DesFilePath );
end;

procedure TLocalBackupResultHandle.DesFolderRecycle;
var
  FolderRecycleHandle : TFolderRecycleHandle;
begin
    // 回收目录
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
    // 加密需添加后缀
  if IsEncrypted then
    DesFilePath := DesFilePath + ExtPassword;

    // 复制文件
  BackupCopyFileOperator := TBackupCopyFileOperator.Create;
  BackupCopyFileOperator.SetParams( Params );
  CopyFileHandle := TCopyFileHandle.Create;
  CopyFileHandle.SetPathInfo( SourceFilePath, DesFilePath );
  CopyFileHandle.SetEncryptInfo( IsEncrypted, Password );
  CopyFileHandle.SetCopyFileOperator( BackupCopyFileOperator );
  IsBackupCompleted := CopyFileHandle.Update;
  CopyFileHandle.Free;
  BackupCopyFileOperator.Free;

    // 写日志
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
    // 备份的路径
  SavePath := MyFilePath.getLocalBackupPath( DesItemID, SourcePath );

    // 提取信息
  ScanResultAddZipInfo := ScanResultInfo as TScanResultAddZipInfo;
  ZipStream := ScanResultAddZipInfo.ZipStream;

    // 解压文件
  BackupFileUnpackOperator := TBackupFileUnpackOperator.Create;
  BackupFileUnpackOperator.SetParams( Params );
  FileUnpackHandle := TFileUnpackHandle.Create( ZipStream );
  FileUnpackHandle.SetFileUnpackOperator( BackupFileUnpackOperator );
  FileUnpackHandle.SetSavePath( SavePath );
  IsBackupCompleted := FileUnpackHandle.Update;
  FileUnpackHandle.Free;
  BackupFileUnpackOperator.Free;

    // 写 log
  LogZipStream( ZipStream, IsBackupCompleted );

    // 释放资源
  ZipStream.Free;
  ScanResultAddZipInfo.Free;
end;

procedure TLocalBackupResultHandle.SourceFolderAdd;
begin
  ForceDirectories( DesFilePath );
end;

procedure TLocalBackupResultHandle.Update;
begin
    // 源文件的 备份 / 回收路径
  DesFilePath := MyFilePath.getLocalBackupPath( DesItemID, SourceFilePath );
  RecycleFilePath := MyFilePath.getLocalRecyclePath( DesItemID, SourceFilePath );

  inherited;
end;

{ TNetworkFolderScanHandle }

function TNetworkFolderCompareHandler.CheckNextScan: Boolean;
begin
  Result := inherited;
  if Result then  // 定时心跳
    NetworkBackupParamsData.CheckHeartBeat;
end;

procedure TNetworkFolderCompareHandler.FindDesFileInfo;
var
  NetworkFolderFindHandle : TNetworkFolderFindHandle;
begin
    // 已读取
  if IsDesReaded then
    Exit;

     // 搜索目录信息
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

    // 不存在子目录
  if not DesFolderHash.ContainsKey( SourceFolderName ) then
    Exit;

    // 添加子目录信息
  ChildFolderInfo := DesFolderHash[ SourceFolderName ];
  NetworkFolderScanHandle.SetIsDesReaded( ChildFolderInfo.IsReaded );

    // 子目录未读取
  if not ChildFolderInfo.IsReaded then
    Exit;

    // 子目录信息
  NetworkFolderScanHandle.DesFolderHash.Free;
  NetworkFolderScanHandle.DesFolderHash := ChildFolderInfo.ScanFolderHash;
  ChildFolderInfo.ScanFolderHash := TScanFolderHash.Create;

    // 子文件信息
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
    // 目标目录
  DesFolderPath := ExtractFileDir( DesFilePath );

  ParentFolderHash := TScanFolderHash.Create;

    // 搜索父目录文件
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

    // 不在包含列表中
  if not FileFilterUtil.IsFileInclude( FilePath, sch, IncludeFilterList ) then
    Exit;

    // 在排除列表中
  if FileFilterUtil.IsFileExclude( FilePath, sch, ExcludeFilterList ) then
    Exit;

  Result := False;
end;

function TBackupFolderFindHandle.IsFolderFilter(
  FolderPath: string): Boolean;
begin
  Result := True;

    // 不在包含列表中
  if not FileFilterUtil.IsFolderInclude( FolderPath, IncludeFilterList ) then
    Exit;

    // 在排除列表中
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

    // 等待删除完成
  WaitCloudCompleted;
end;

procedure TNetworkBackupResultHandle.DesFileRemove;
begin
  MySocketUtil.SendData( TcpSocket, FileReq_RemoveFile );
  MySocketUtil.SendData( TcpSocket, SourceFilePath );
  MySocketUtil.SendData( TcpSocket, False );

    // 等待删除完成
  WaitCloudCompleted;
end;

procedure TNetworkBackupResultHandle.DesFolderRecycle;
begin
  MySocketUtil.SendData( TcpSocket, FileReq_RecycleFolder );
  MySocketUtil.SendData( TcpSocket, SourceFilePath );
  MySocketUtil.SendData( TcpSocket, False );
  MySocketUtil.SendData( TcpSocket, KeedEditionCount );

    // 等待删除完成
  WaitCloudCompleted;
end;

procedure TNetworkBackupResultHandle.DesFolderRemove;
begin
  MySocketUtil.SendData( TcpSocket, FileReq_RemoveFolder );
  MySocketUtil.SendData( TcpSocket, SourceFilePath );
  MySocketUtil.SendData( TcpSocket, False );

    // 等待删除完成
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
    // 加密的情况
  DesFilePath := SourceFilePath;
  if IsEncrypted then
    DesFilePath := DesFilePath + ExtPassword;

    // 发送请求信息
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_CloudReqType, 'Json' );
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_FileReq, FileReq_AddFile );
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_FilePath, DesFilePath );
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_IsDeleted, False );

    // 发送
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

    // 备份失败
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
    // 提取信息
  ScanResultAddZipInfo := ScanResultInfo as TScanResultAddZipInfo;
  ZipStream := ScanResultAddZipInfo.ZipStream;

    // 发送给 目标Pc 处理
  MySocketUtil.SendData( TcpSocket, FileReq_AddZip );

    // 发送压缩流
  BackupSendFileOperator := TBackupSendFileOperator.Create;
  BackupSendFileOperator.SetParams( Params );
  NetworkSendStreamHandle := TNetworkSendStreamHandle.Create;
  NetworkSendStreamHandle.SetTcpSocket( TcpSocket );
  NetworkSendStreamHandle.SetSendStream( ZipStream );
  NetworkSendStreamHandle.SetSendFileOperator( BackupSendFileOperator );
  IsBackupCompleted := NetworkSendStreamHandle.Update;
  NetworkSendStreamHandle.Free;
  BackupSendFileOperator.Free;

    // 等待压缩结束
  if TcpSocket.Connected then
    HeartBeatReceiver.CheckReceive( TcpSocket );

    // 写 log
  LogZipStream( ZipStream, IsBackupCompleted );

    // 计算实际空间
  if IsBackupCompleted then
  begin
    DelZipSize := ScanResultAddZipInfo.TotalSize - ZipStream.Size;
    BackupItemAppApi.AddBackupCompletedSpace( DesItemID, SourcePath, DelZipSize );
  end;

    // 删除 Job
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
    // 等待回收结束
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

    // 无 Job
  if ScanResultList.Count = 0 then
    Exit;

  DebugLock.DebugFile( 'Backuping', SourcePath );

    // 设置开始备份
  BackupItemAppApi.SetStartBackup( DesItemID, SourcePath );

    // 免费版限制时使用
  BackupFreeLimitReader := TBackupFreeLimitReader.Create( DesItemID, SourcePath );
  BackupFreeLimitReader.IniHandle;

    // 处理文件比较结果
  FileBackupHandler := BackupOperator.CreaterFileBackupHandler;
  FileBackupHandler.SetNewBackupFileList( NewBackupFileList );
  FileBackupHandler.SetParams( BackupParamsData );
  FileBackupHandler.IniHandle;
  for i := 0 to ScanResultList.Count - 1 do
  begin
    DebugLock.DebugFile( 'Handle: ' + ScanResultList[i].ClassName, ScanResultList[i].SourceFilePath );
    if not BackupCancelReader.getIsRun then  // 取消发送
      Break;
    if not BackupFreeLimitReader.AddResult( ScanResultList[i] ) then // 收到免费版限制
      Continue;
      // 处理结果
    FileBackupHandler.Handle( ScanResultList[i] );
  end;
  if i = ScanResultList.Count then
    FileBackupHandler.CompletedHandle;
  NewBackupCount := FileBackupHandler.NewBackupCount;
  FileBackupHandler.Free;
  BackupFreeLimitReader.Free;

    // 返回是否还在运行
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

    // 读取续传文件列表，并续传文件
  BackupContinuesList := BackupItemInfoReadUtil.ReadContinuesList( DesItemID, SourcePath );
  if BackupContinuesList.Count > 0 then
    BackupItemAppApi.SetStartBackup( DesItemID, SourcePath );
  for i := 0 to BackupContinuesList.Count - 1 do
  begin
    if not BackupCancelReader.getIsRun then  // 取消备份
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

    // 是否继续备份
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
    // 备份路径是否被删除
  Result := BackupItemInfoReadUtil.ReadIsEnable( DesItemID, SourcePath );
  if not Result then
    Exit;

    // 磁盘路径是否存在
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
    // 重设 源路径空间
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

    // 设置 正在
  BackupItemAppApi.SetAnalyzeBackup( DesItemID, SourcePath );

    // 扫描 文件/目录
  if IsFile then
    FileCompareHandle
  else
    FolderCompareHandle;

    // 程序是否结束
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
    // 设置已完成
  BackupOperator.SetBackupCompleted;

    // 显示已完成 Hint
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

    // 重设分析数据
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

    // 备份已取消
  if not BackupCancelReader.getIsRun then
    Exit;

    // 检测 目标路径
  if not ReadDesItemIsAvailable then
    Exit;

    // 检测 源路径
  if not ReadBackupPathIsAvailable then
    Exit;

    // 处理续传
  if not ContinuesHandle then
    Exit;

    // 处理文件比较
  if not BackupCompareHandle then
    Exit;

    // 设置备份空间信息
  ResetBackupSpaceInfo;

    // 处理文件比较结果
  if not CompareResultHandle then
    Exit;

    // 读取是否备份完成
  if not getIsBackupCompleted then
    Exit;

    // 重设下次备份周期
  SetLastSyncTime;

    // 设置 备份完成
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
    // 写 log
  FilePathList := MyZipUtil.getPathList( ZipStream ); // 获取 Stream 文件列表
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
    // 名字解密
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
    // 源文件 或 目标文件 发生变化
  if ReadSourceIsChange or not ReadDestinationPos then
  begin
    RemoveContinusInfo; // 清空续传记录
    Exit;
  end;

    // 文件续传
  if FileCopy then
  begin
    RemoveContinusInfo; // 清空续传记录
    LogBackupCompleted; // 写 Log
  end;
end;

{ TLocalBackupContinuesHandle }

function TLocalBackupContinuesHandler.FileCopy: Boolean;
var
  BackupCopyFileOperator : TBackupCopyFileOperator;
  CopyFileHandle : TCopyFileHandle;
begin
    // 复制文件
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
    // 续传的目标路径
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
    // 初始化 发送
  MySocketUtil.SendData( TcpSocket, FileReq_AddFile );
  MySocketUtil.SendData( TcpSocket, DesFilePath );
  MySocketUtil.SendData( TcpSocket, False );

    // 发送文件
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

    // 返回是否存在目标文件
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

    // 连接已断开
  if not TcpSocket.Connected then
  begin
    TcpSocket.Free;
    Exit;
  end;

    // 发送结束标记
  MySocketUtil.SendData( TcpSocket, FileReq_End );

  SocketLock.Enter;
  try
      // 不允许超过10个连接
    if BackupFileSocketList.Count >= 10 then
    begin
      BackupFileSocketList[0].CloseSocket;
      BackupFileSocketList.Delete( 0 );
    end;
      // 添加旧连接
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
    // 可能存在多个反向连接，所以加锁
  SocketLock.Enter;

  DesItemID := _DesItemID;
  SourcePath := _SourcePath;
  DesPcID := NetworkDesItemUtil.getPcID( DesItemID );
  BackupConn := _BackupConn;

  try
    Result := getConnect;  // 获取连接

      // 发送初始化信息
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
        // 超过三分钟，删除
      if MinutesBetween( Now, BackupFileSocketList[i].LastTime ) >= 3 then
      begin
          // 关闭端口
        BackupFileSocketList[i].CloseSocket;
          // 删除
        BackupFileSocketList.Delete( i );
        Continue;
      end;
        // 发送心跳
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
    // 等待结果
  WaitBackConn;

    // 返回结果
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

    // 获取以前已连接的端口
  TcpSocket := getLastConnect;
  if Assigned( TcpSocket ) then
  begin
    Result := TcpSocket;
    Exit;
  end;

    // 提取 Pc 信息
  DesPcIP := MyNetPcInfoReadUtil.ReadIp( DesPcID );
  DesPcPort := MyNetPcInfoReadUtil.ReadPort( DesPcID );

    // Pc 离线
  if not MyNetPcInfoReadUtil.ReadIsOnline( DesPcID ) then
    Exit;

    // 本机无法连接对方
  if not MyNetPcInfoReadUtil.ReadIsCanConnectTo( DesPcID ) then
  begin
    Result := getBackConnect; // 反向连接
    Exit;
  end;

    // 连接 目标 Pc
  TcpSocket := TCustomIpClient.Create( nil );
  MyTcpConn := TMyTcpConn.Create( TcpSocket );
  MyTcpConn.SetConnType( ConnType_CloudFileRequest );
  MyTcpConn.SetConnSocket( DesPcIP, DesPcPort );
  IsConnected := MyTcpConn.Conn;
  MyTcpConn.Free;


    // 使用反向连接
  if not IsConnected then
  begin
    TcpSocket.Free;
    NetworkPcApi.SetCanConnectTo( DesPcID, False ); // 设置无法连接
    Result := getBackConnect; // 反向连接
    Exit;
  end;

    // 是否接收繁忙
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
      // 寻找上次端口
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

    // 不存在
  if not Assigned( LastSocket ) then
    Exit;

    // 判断端口是否正常
  MySocketUtil.SendData( LastSocket, FileReq_New );
  FileReq := MySocketUtil.RevData( LastSocket );
  if FileReq <> FileReq_New then  // 端口异常
  begin
    LastSocket.Free;
    Result := getLastConnect; // 再拿一次
    Exit;
  end;

    // 返回上次端口
  Result := LastSocket;
end;

procedure TMyBackupFileConnectHandler.WaitBackConn;
var
  StartTime : TDateTime;
begin
  DebugLock.Debug( 'BackConnHandle' );

    // 对方不能连接本机
  if not MyNetPcInfoReadUtil.ReadIsCanConnectFrom( DesPcID ) then
  begin
    CanNotConnHandle;
    Exit;
  end;

      // 初始化结果信息
  IsConnSuccess := False;
  IsConnError := False;
  IsConnBusy := False;

    // 请求反向连接
  NetworkBackConnEvent.AddItem( DesPcID );

    // 等待接收方连接
  StartTime := Now;
  while MyBackupHandler.getIsRun and
        ( MinutesBetween( Now, StartTime ) < 1 ) and
        not IsConnBusy and not IsConnError and not IsConnSuccess
  do
    Sleep(100);

    // 目标 Pc 繁忙
  if IsConnBusy then
  begin
    RemoteBusyHandle;
    Exit;
  end;

    // 无法连接
  if IsConnError then
  begin
    NetworkPcApi.SetCanConnectFrom( DesPcID, False ); // 设置无法连接
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
    // 删除加密信息不一致的文件
  ParentPath := ExtractFilePath( SourceFilePath );
  SourceFileName := ExtractFileName( SourceFilePath );

    // 搜索文件
  for p in ParentFileHash do
  begin
    FileName := p.Value.FileName;
      // 无关的文件
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
    // 目标文件
  DesFilePath := SourceFilePath;
  if IsEncrypted then
    DesFilePath := DesFilePath + PasswordExt;

  inherited;

    // 移除加密信息不同的版本
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

    // 初始化压缩信息
  ZipName := ExtractRelativePath( MyFilePath.getPath( SourcePath ), FilePath );
  if IsEncrypt then
    ZipName := ZipName + ExtPassword;
  NewZipInfo := MyZipUtil.getZipHeader( ZipName, FilePath, zcStored );

  try
    fs := ReadFileStream( FilePath );  // 读取压缩流
    if not Assigned( fs ) then // 读取失败
      Exit;
    ZipFile.Add( fs, NewZipInfo );  // 添加压缩文件
    fs.Free;

      // 最后一个
    NewZipInfo := ZipFile.FileInfo[ ZipFile.FileCount - 1 ];

      // 刷新统计信息
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

    // 非发送文件
  if not ( ScanResultInfo is TScanResultAddFileInfo ) then
    Exit;

    // 只压缩小于 128 KB 的文件
  SourceFileSize := MyFileInfo.getFileSize( ScanResultInfo.SourceFilePath );
  if ( SourceFileSize = 0 ) or ( SourceFileSize > 128 * Size_KB ) then
    Exit;

    // 先创建压缩文件
  if not IsZipCreated then
  begin
    if not CreateZip then  // 创建文件失败
      Exit;
  end;

    // 添加压缩文件失败
  if not AddFile( ScanResultInfo.SourceFilePath ) then
    Exit;

    // 超过 1000 个文件 或者 10MB ，立刻发送压缩文件
  if ( ZipCount >= 1000 ) or ( ZipSize >= 10 * Size_MB ) then
  begin
    Result := ReadZipResultInfo;
    Exit;
  end;

    // 返回空
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
      // 创建压缩流
    ZipStream := TMemoryStream.Create;

      // 创建压缩器
    ZipFile := TZipFile.Create;
    ZipFile.Open( ZipStream, zmWrite );

      // 返回创建成功
    Result := True;

      // 初始化压缩状态
    IsZipCreated := True;
    ZipSize := 0;
    ZipCount := 0;
    TotalSize := 0;
  except
  end;
end;

procedure TBackupPackageHandler.DestoryZip;
begin
    // 未创建压缩文件
  if not IsZipCreated then
    Exit;

    // 关闭压缩文件
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

    // 未创建压缩文件
  if not IsZipCreated then
    Exit;

    // 关闭压缩文件
  DestoryZip;

    // 返回压缩流
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
      // 普通文件
    if not IsEncrypt then
    begin
      Result := TFileStream.Create( FilePath, fmOpenRead or fmShareDenyNone );
      Exit;
    end;

      // 读取文件信息
    fs := TFileStream.Create( FilePath, fmOpenRead or fmShareDenyNone );
    FileSize := fs.Size;
    fs.ReadBuffer( DataBuf, FileSize );
    fs.Free;

      // 加密
    SendFileUtil.Encrypt( DataBuf, FileSize, Password );

      // 写入加密流
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
    // 处理结果
  BackupResultHandle := TNetworkBackupResultHandle.Create;
  BackupResultHandle.SetScanResultInfo( ScanResultInfo );
  BackupResultHandle.SetParams( Params );
  BackupResultHandle.SetTcpSocket( TcpSocket );
  BackupResultHandle.Update;
  BackupResultHandle.Free;

    // 是否在备份过程断开连接
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

    // 回收端口
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
    if SecondsBetween( Now, StartTime ) < 10 then  // 10 秒发送一次心跳
      Continue;
    if not MySocketUtil.SendData( TcpSocket, FileReq_HeartBeat ) then // 心跳处理
    begin
      TcpSocket.Disconnect;
      IsLostConn := True;  // 对方断开了连接
      Break;
    end;
    StartTime := Now;
  end;
end;

{ TNetworkBackupFileHandle }

procedure TNetworkBackupFileHandle.CheckHeartBeat;
begin
    // 10 秒发送一次心跳
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
    // 发送最后的压缩文件
  ScanResultInfo := BackupPackageHandler.getLastSendFile;
  if Assigned( ScanResultInfo ) then
    SendFile( ScanResultInfo );

    // 等待线程结束
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

    // 读取访问结果
  CloudConnResult := MySocketUtil.RevData( NewSocket );

  if CloudConnResult = CloudConnResult_OK then
    Result := NewSocket
  else
    NewSocket.Free;
end;

procedure TNetworkBackupFileHandle.Handle(ScanResultInfo: TScanResultInfo);
begin
  inherited;

    // 定时发心跳
  CheckHeartBeat;

    // 是否进行文件压缩
  if not IsFile then
    ScanResultInfo := BackupPackageHandler.AddZipFile( ScanResultInfo );

    // 本地压缩文件，跳过这个 Job
  if ScanResultInfo = nil then
    Exit;

    // 发送普通文件 或 发送压缩文件
  if ( ScanResultInfo is TScanResultAddFileInfo ) or
     ( ScanResultInfo is TScanResultAddZipInfo )
  then
    SendFile( ScanResultInfo )  // 寻找线程发送
  else
    HandleNow( ScanResultInfo ); // 立刻处理
end;

procedure TNetworkBackupFileHandle.HandleNow(ScanResultInfo: TScanResultInfo);
var
  BackupResultHandle : TNetworkBackupResultHandle;
begin
    // 处理结果
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
    // 单个文件则不用再创建线程
  if IsFile then
    Exit;

    // 互联网 Pc 不用多线程
  DesPcID := NetworkDesItemUtil.getPcID( DesItemID );
  if not MyNetPcInfoReadUtil.ReadIsLanPc( DesPcID ) then
    Exit;

    // 3线程发送
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
    // 寻找空闲的线程
  IsFindThread := False;
  for i := 0 to BackupFileThreadList.Count - 1 do
    if not BackupFileThreadList[i].IsRun and not BackupFileThreadList[i].IsLostConn then
    begin
      BackupFileThreadList[i].AddScanResultInfo( ScanResultInfo );
      IsFindThread := True;
      Break;
    end;

    // 找不到空闲线程，当前线程处理
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
    // 发送最后的压缩文件
  ScanResultInfo := BackupPackageHandler.getLastSendFile;
  if Assigned( ScanResultInfo ) then
    HandleNow( ScanResultInfo );
end;

procedure TLocalFileBackupHandler.Handle(ScanResultInfo: TScanResultInfo);
begin
  inherited;

    // 是否进行文件压缩
  if not IsFile then
    ScanResultInfo := BackupPackageHandler.AddZipFile( ScanResultInfo );

    // 本地压缩文件，跳过这个 Job
  if ScanResultInfo = nil then
    Exit;

    // 立刻处理
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

      // 读取上次已完成空间信息，试用限制时使用
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

    // 是否已经结束
  if SecondsBetween( Now, ScanTime ) >= 1 then  // 检测 BackupItem 删除
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
    // 设置不缺小空间
  DesItemAppApi.SetIsLackSpace( DesItemID, False );

    // 是否存在磁盘
  Result := MyHardDisk.getPathDriverExist( DesItemID );
  DesItemAppApi.SetIsExist( DesItemID, Result );
  if not Result then
    Exit;

    // 创建目录
  DesFolderPath := MyFilePath.getLocalBackupPath( DesItemID, SourcePath );
  if IsFile then
    DesFolderPath := ExtractFileDir( DesFolderPath );
  ForceDirectories( DesFolderPath );

    // 是否可写
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

    // 获取访问结果
  CloudConnResult := MySocketUtil.RevJsonStr( TcpSocket );

      // 设置 可连接
  DesItemAppApi.SetIsConnected( DesItemID, True );

    // 设置 非缺少空间
  DesItemAppApi.SetIsLackSpace( DesItemID, False );

    // 是否存在云路径
  IsDesExist := CloudConnResult <> CloudConnResult_NotExist;
  DesItemAppApi.SetIsExist( DesItemID, IsDesExist );

    // 云路径是否可写
  IsDesWrite := CloudConnResult <> CloudConnResult_CannotWrite;
  DesItemAppApi.SetIsWrite( DesItemID, IsDesWrite );

    // 是否返回正常
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

    // 创建失败
  if not Result then
    Exit;

    // 基本信息
  BackupParamsData.DesItemID := DesItemID;
  BackupParamsData.SourcePath := SourcePath;
  BackupParamsData.IsFile := BackupItemInfoReadUtil.ReadIsFile( DesItemID, SourcePath );

    // 保存删除文件信息
  BackupParamsData.IsSaveDeleted := BackupItemInfoReadUtil.ReadIsKeepDeleted( DesItemID, SourcePath );
  BackupParamsData.KeepDeletedCount := BackupItemInfoReadUtil.ReadIsKeepEditionCount( DesItemID, SourcePath );

    // 加密信息
  BackupParamsData.IsEncrypted := BackupItemInfoReadUtil.ReadIsEncrypted( DesItemID, SourcePath );
  BackupParamsData.Password := BackupItemInfoReadUtil.ReadPassword( DesItemID, SourcePath );
  BackupParamsData.ExtPassword := MyEncrypt.getPasswordExt( BackupParamsData.Password );

    // 过滤器信息
  BackupParamsData.IncludeFilterList := BackupItemInfoReadUtil.ReadIncludeFilter( DesItemID, SourcePath );
  BackupParamsData.ExcludeFilterList := BackupItemInfoReadUtil.ReadExcludeFilter( DesItemID, SourcePath );

    // 文件类型分析器
  BackupParamsData.BackupAnalyzer := TBackupAnalyzer.Create;

    // 其他工具
  BackupParamsData.SpeedReader := TimeReader;
  BackupParamsData.BackupCancelReader := BackupCancelReader;

    // 设置数据
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

    // 申请一个连接
  TcpSocket := MyBackupFileConnectHandler.getBackupPcConn( DesItemID, SourcePath, BackupConn_Backup );
  if not Assigned( TcpSocket ) then  // 获取连接失败
    Exit;

    // 限速
  IsLimited := BackupSpeedInfoReadUtil.getIsLimit;
  LimitSpeed := BackupSpeedInfoReadUtil.getLimitSpeed;
  TimeReader := TSpeedReader.Create;
  TimeReader.SetLimitInfo( IsLimited, LimitSpeed );

    // 检测是否取消
  BackupCancelReader := TNetworkBackupCancelReader.Create;

    // 参数
  BackupParamsData := TNetworkBackupParamsData.Create;
  ( BackupParamsData as TNetworkBackupParamsData ).TcpSocket := TcpSocket;
  ( BackupParamsData as TNetworkBackupParamsData ).HeartBeatTime := Now;

    // 备份操作
  BackupOperator := TNetworkBackupOperater.Create;

  Result := True;
end;

procedure TBackupStartHandle.DestoryBackupData;
begin
    // 需关闭特定信息
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

    // 返回连接列表
  MyBackupFileConnectHandler.AddLastConn( DesItemID, TcpSocket );
end;

procedure TBackupStartHandle.Update;
begin
    // 提示开始备份
  AddToHint;

    // 创建数据结构
  if not CreateBackupData then
    Exit;

    // 备份处理
  BackupHandle;

    // 释放数据结构
  DestoryBackupData;
end;

{ TBackupSendFileOperator }

procedure TBackupSendFileOperator.AddSpeedSpace(SendSize: Integer);
var
  IsLimited : Boolean;
  LimitSpeed : Int64;
begin
    // 添加到总速度
  MyRefreshSpeedHandler.AddUpload( SendSize );

    // 刷新速度， 1秒钟刷新一次
  if SpeedReader.AddCompleted( SendSize ) then
  begin
      // 设置 刷新备份速度
    BackupItemAppApi.SetSpeed( DesItemID, SourcePath, SpeedReader.ReadLastSpeed );

      // 重新获取限制空间信息
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

    // 设置断开连接，定时备份将会重连
  BackupItemAppApi.SetIsLostConn( DesItemID, SourcePath, True );
end;

procedure TBackupSendFileOperator.MarkContinusSend;
var
  Params : TBackupContinusAddParams;
begin
    // 备份已取消
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
    // 刷新已完成空间，备份百分比
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

    // 设置断开连接，定时备份将会重连
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
    // 刷新速度
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
    // 备份已取消
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

    // 添加 已完成空间
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
    // 刷新速度
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

    // 添加 已完成空间
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
    // 处理结果
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

    // 备份操作
  while MyBackupHandler.IsRun do
  begin
    LogPathInfo := MyBackupLogHandler.getLogPathInfo;
    if LogPathInfo = nil then
      Break;

    try
        // 扫描路径
      StartHandle( LogPathInfo );
    except
    end;

      // 停止扫描
    LogPathInfo.Free;
  end;

    // 程序结束，设置线程结束
  if not MyBackupLogHandler.IsRun then
    MyBackupLogHandler.IsCreateThread := False;

    // 结束
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

    // 添加到扫描列表中
  LogPathList.Add( LogPathInfo );

    // 没有创建线程，则先创建线程
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

    // 读取删除文件列表
  ReadDeletedFileHash;

    // 比较文件修改时间
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

    // 提取 Item 信息
  ReadItemInfo;

    // 读取 文件信息
  ReadLog;

    // 处理文件信息
  if IsExist then
    HandleLog
  else
    LogFileNotExist; // 文件不存在

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

    // 目标路径
  DesFilePath := MyFilePath.getLocalBackupPath( DesItemID, FilePath );
  if IsEncryted then
    DesFilePath := MyFilePath.getEncryptName( DesFilePath, PasswordExt );

    // 是否存在
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
    // 申请一个连接
  TcpSocket := MyBackupFileConnectHandler.getBackupPcConn( DesItemID, SourcePath, BackupConn_Log );
  if not Assigned( TcpSocket ) then  // 获取连接失败
    Exit;

    // 获取访问结果
  CloudConnResult := MySocketUtil.RevData( TcpSocket );

    // 是否连接成功
  IsSuccessConn := CloudConnResult = CloudConnResult_OK;

    // 访问成功
  if IsSuccessConn then
    inherited;

    // 返回连接列表
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
    // 是否已存在
  IsFind := False;
  for i := 0 to BackupSpaceList.Count - 1 do
    if BackupSpaceList[i].TypeName = TypeName then
    begin
      IsFind := True;
      BackupSpaceInfo := BackupSpaceList[i];
      Break;
    end;

    // 不存在则创建
  if not IsFind then
  begin
    BackupSpaceInfo := TBackupSpaceInfo.Create( TypeName );
    BackupSpaceList.Add( BackupSpaceInfo );
  end;

    // 添加统计
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
    // 文件数排序
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

    // 只写入前三个
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
    // 文件数排序
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

    // 只写入前三个
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
    // 刷新路径信息
  MaxBackupPathApi.RemovePath( BackupPath );
  MaxBackupPathApi.AddPath( BackupPath );

    // 添加文件数信息
  ResetBackupCountInfo;

    // 添加文件空间信息
  ResetBackupSizeInfo;
end;

{ TNetworkBackupParamsData }

procedure TNetworkBackupParamsData.CheckHeartBeat;
begin
  HeartBeatReceiver.CheckSend( TcpSocket, HeartBeatTime );
end;

end.

