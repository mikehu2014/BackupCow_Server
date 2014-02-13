unit URestoreThread;

interface

uses Classes, Generics.Collections, SyncObjs, UFolderCompare, UMyUtil,
     SysUtils, DateUtils, sockets, UMyTcp, UModelUtil, UMyDebug, StrUtils, uDebugLock, zip,
     UFileBaseInfo;

type

{$Region ' 数据结构 ' }

    // 恢复路径信息
  TRestorePathInfo = class
  public
    RestorePath, OwnerID, RestoreFrom : string;
  public
    procedure SetItemInfo( _RestorePath, _OwnerID, _RestoreFrom : string );
  end;
  TRestorePathList = class( TObjectList< TRestorePathInfo > );

    // 恢复下载信息
  TRestoreDownloadInfo = class( TRestorePathInfo )end;
  TLocalRestorePathInfo = class( TRestoreDownloadInfo )end;
  TNetworkRestorePathInfo = class( TRestoreDownloadInfo )end;
  TRestoreDownloadList = class( TObjectList< TRestoreDownloadInfo > );

    // 高级路径信息
  TRestoreAdvancePathInfo = class( TRestorePathInfo )
  public
    IsEncrypted : Boolean;
    PasswordExt : string;
  public
    procedure SetEncryptedInfo( _IsEncrypted : Boolean; _PasswordExt : string );
  end;

    // 浏览信息
  TRestoreExplorerInfo = class( TRestoreAdvancePathInfo )
  public
    IsFile, IsDeleted, IsSearch : Boolean;
  public
    procedure SetExplorerInfo( _IsFile, _IsDeleted : Boolean );
    procedure SetIsSearch( _IsSearch : Boolean );
  end;
  TLocalRestoreExplorerInfo = class( TRestoreExplorerInfo )end;
  TNetworkRestoreExplorerInfo = class( TRestoreExplorerInfo )end;
  TRestoreExplorerList = class( TObjectList< TRestoreExplorerInfo > );

    // 搜索信息
  TRestoreSearchInfo = class( TRestoreAdvancePathInfo )
  public
    IsFile, HasDeleted : Boolean;
    SearchName : string;
  public
    procedure SetSearchInfo( _IsFile, _HasDeleted : Boolean );
    procedure SetSearchName( _SearchName : string );
  end;
  TLocalRestoreSearchInfo = class( TRestoreSearchInfo )end;
  TNetworkRestoreSearchInfo = class( TRestoreSearchInfo )end;
  TRestoreSearchList = class( TObjectList< TRestoreSearchInfo > );

    // 预览信息
  TRestorePreviewInfo = class( TRestoreAdvancePathInfo )
  public
    IsDeleted : Boolean;
    EditionNum : Integer;
  public
    Password : string;
  public
    procedure SetDeletedInfo( _IsDeleted : Boolean; _EditionNum : Integer );
    procedure SetPassword( _Password : string );
  end;
  TLocalRestorePreviewInfo = class( TRestorePreviewInfo )end;
  TNetworkRestorePreviewInfo = class( TRestorePreviewInfo )end;
  TRestorePreviewList = class( TObjectList< TRestorePreviewInfo > );

{$EndRegion}

{$Region ' 恢复下载 数据结构 ' }

  TRestoreCancelReader = class;

    // 恢复参数
  TRestoreParamsData = class
  public
    RestorePath, OwnerID, RestoreFrom : string;  // 本地源、本地目标
    IsFile : Boolean;
    SavePath : string;
  public
    IsDeleted : Boolean;
    EditionNum : Integer;
    FileEditionHash : TFileEditionHash;
  public
    IsEncrypt : Boolean; // 是否文件，是否恢复删除, 是否解密
    Password, ExtPassword : string;  // 恢复路径, 加密信息
  public
    SpeedReader : TSpeedReader;
    RestoreCancelReader : TRestoreCancelReader;
  end;

    // 网络恢复参数
  TNetworkRestoreParamsData = class( TRestoreParamsData )
  public
    TcpSocket : TCustomIpClient;
    HeartBeatTime : TDateTime;
  public
    procedure CheckHeartBeat;
  end;

    // 恢复取消
  TRestoreCancelReader = class
  public
    RestorePath, OwnerID, RestoreFrom : string;
    LastReadTime : TDateTime;
  public
    constructor Create;
    procedure SetParams( Params : TRestoreParamsData );virtual;
    function getIsRun : Boolean;virtual;
  end;

    // 网络恢复取消
  TNetworkRestoreCancelReader = class( TRestoreCancelReader )
  public
    TcpSocket : TCustomIpClient;
  public
    procedure SetParams( Params : TRestoreParamsData );override;
    function getIsRun : Boolean;override;
  end;

{$EndRegion}


{$Region ' 文件比较 ' }

    // 恢复目录 比较算法
  TRestoreFolderCompareHandler = class( TFolderCompareHandler )
  protected
    Params : TRestoreParamsData;
    RestorePath, OwnerID, RestoreFrom : string;
    SavePath : string;
  public
    IsEncrypted : Boolean;
    PasswordExt : string;
    IsDeleted : Boolean;
  protected
    RestoreCancelReader : TRestoreCancelReader;
  public
    procedure SetParams( _Params : TRestoreParamsData );virtual;
  protected
    procedure FindDesFileInfo;override;
  protected
    function getDesFileName( SourceFileName : string ): string;override;
  protected      // 是否 停止扫描
    function CheckNextScan : Boolean;override;
  end;

    // 恢复文件 比较算法
  TRestoreFileCompareHandler = class( TFileCompareHandler )
  protected
    RestoreFilePath : string;
    SavePath : string;
  public
    IsEncrypted : Boolean;
    PasswordExt : string;
  public
    IsDeleted : Boolean;
    EditionNum : Integer;
  public
    constructor Create;
    procedure SetParams( Params : TRestoreParamsData );virtual;
    procedure Update;override;
  protected
    function FindDesFileInfo: Boolean;override;
    function getAddFilePath : string;override;
    function getRemoveFilePath : string;override;
  end;

{$EndRegion}

{$Region ' 文件续传 ' }

      // 续传处理
  TRestoreContinuesHandler = class
  public
    FilePath : string;
    FileSize, Position : Int64;
    FileTime : TDateTime;
  public
    Params : TRestoreParamsData;
    RestorePath, OwnerID, RestoreFrom : string;
    IsFile, IsDeleted, IsEncrypted : Boolean;
    SavePath, Password, ExtPassword : string;
    SpeedReader : TSpeedReader;
  public
    SaveFilePath : string;
  public
    procedure SetSourceFilePath( _FilePath : string );
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
    procedure SetParams( _Params : TRestoreParamsData );virtual;
    procedure Update;virtual;
  protected
    function ReadSourceIsChange : Boolean; virtual;abstract;
    function ReadDestinationPos : Boolean;
    function FileCopy: Boolean;virtual;abstract;
    procedure RemoveContinusInfo;
  end;

{$EndRegion}

{$Region ' 结果处理 ' }

    // 恢复结果处理
  TRestoreResultHandler = class
  public
    ScanResultInfo : TScanResultInfo;
    SourceFilePath : string;
  public
    Params : TRestoreParamsData;
    RestorePath, OwnerID, RestoreFrom : string;  // 本地源、本地目标
    IsFile, IsDeleted, IsEncrypt : Boolean;
    SavePath, Password, ExtPassword : string;
    SpeedReader : TSpeedReader;
  public
    SaveFilePath : string;
  public
    procedure SetScanResultInfo( _ScanResultInfo : TScanResultInfo );
    procedure SetParams( _Params : TRestoreParamsData );virtual;
    procedure Update;virtual;
  private         // 添加
    procedure SourceFileAdd;virtual;abstract;
    procedure SourceFolderAdd;virtual;abstract;
  private         // 删除
    procedure DesFileRemove;virtual;abstract;
    procedure DesFolderRemove;virtual;abstract;
  protected         // 获取压缩包
    procedure SourceFileGetZip;virtual;
    procedure SourceFileAddZip;virtual;
  end;

    // 恢复文件处理
  TFileRestoreHandler = class
  public
    Params : TRestoreParamsData;
  public
    procedure SetParams( _Params : TRestoreParamsData );virtual;
    procedure Handle( ScanResultInfo : TScanResultInfo );virtual;abstract;
    procedure IniHandle;virtual;
    procedure LastCompleted;virtual;
  end;

{$EndRegion}

{$Region ' 恢复确认 ' }

    // 恢复确认 Item
  TRestoreConfirmInfo = class
  public
    LocalPath, RestorePath : string;
    LocalSize, RestoreSize : Int64;
    LocalDate, RestoreDate : TDateTime;
  public
    constructor Create( _LocalPath, _RestorePath : string );
    procedure SetSizeInfo( _LocalSize, _RestoreSize : Int64 );
    procedure SetDateInfo( _LocalDate, _RestoreDate : TDateTime );
  end;
  TRestoreConfirmList = class( TObjectList<TRestoreConfirmInfo> )end;

    // 用户确认
  TUserConfirmActionHandle = class
  public
    RestoreConfirmList : TRestoreConfirmList;
    IsConfirm : Boolean;
    CancelList : TStringList;
  public
    constructor Create( _RestoreConfirmList : TRestoreConfirmList );
    function getIsConfirm : Boolean;
    function getCancelList : TStringList;
  private
    procedure FaceUpdate;
    procedure ShowConfirm;
  end;

    // 恢复确认操作
  TRestoreFileConfirmHandle = class
  private
    ScanResultList : TScanResultList;
  private
    RestoreConfirmList : TRestoreConfirmList;
    CancelList : TStringList;
  public
    CancelCount : Integer;
    CancelSize : Int64;
  public
    constructor Create( _ScanResultList : TScanResultList );
    function getIsConfirm : Boolean;
    destructor Destroy; override;
  private
    procedure FindConfirmList;
    function UserConfirm : Boolean;
    procedure HandleCancelList;
  private
    function FindCancelIndex( CancelPath : string ): Integer;
  end;

{$EndRegion}

{$Region ' 恢复处理 ' }

  TRestoreOpterator = class
  protected
    Params : TRestoreParamsData;
    RestorePath, OwnerID, RestoreFrom : string;  // 本地源、本地目标
    IsFile : Boolean;
  protected
    IsDeleted : Boolean;
    EditionNum : Integer;
    FileEditionHash : TFileEditionHash;
  public
    IsEncrypt : Boolean; // 是否文件，是否恢复删除, 是否解密
    Password, ExtPassword : string;  // 恢复路径, 加密信息
  public
    procedure SetParams( _Params : TRestoreParamsData );virtual;
  public
    function ReadRestoreFromIsAvailable: Boolean;virtual;abstract;
  public
    function CreateFileCompareHandler : TRestoreFileCompareHandler;virtual;abstract;
    function CreateFolderCompareHandler : TRestoreFolderCompareHandler;virtual;abstract;
  public
    function CreateContinuesHandler : TRestoreContinuesHandler;virtual;abstract;
    function CreateFileRestoreHandler : TFileRestoreHandler;virtual;abstract;
  end;

    // 恢复文件过程处理
  TRestoreProcessHandle = class
  public
    RestoreParamsData : TRestoreParamsData;
    RestorePath, OwnerID, RestoreFrom : string;  // 本地源、本地目标
    IsFile : Boolean;
    SavePath : string;
    RestoreCancelReader : TRestoreCancelReader; // 取消恢复信息
  public
    RestoreOpterator : TRestoreOpterator;
  public   // 文件扫描结果
    TotalCount : Integer;
    TotalSize, TotalCompleted : Int64;
  public   // 文件变化信息
    ScanResultList : TScanResultList;
  public
    constructor Create;
    procedure SetRestoreParamsData( _RestoreParamsDataParams : TRestoreParamsData );
    procedure SetRestoreOperator( _RestoreOpterator : TRestoreOpterator );
    procedure Update;
    destructor Destroy; override;
  private       // 恢复前检测
    function ReadRestoreFromIsAvailable: Boolean;
    function ReadRestoreToIsAvailable : Boolean;
  private       // 文件续传
    function ContinuesHandle: Boolean;
  private       // 文件比较
    function RestoreCompareHandle: Boolean;
    procedure FileCompareHandle;
    procedure FolderCompareHandle;
    procedure ResetRestorePathSpace;
  private       // 文件恢复
    function UserConfirmRestore : Boolean;
    function CompareResultHandle: Boolean;
  private       // 恢复完成
    function ReadIsRestoreCompleted : Boolean;
    procedure SetRestoreCompleted;
  end;

{$EndRegion}


{$Region ' 本地恢复 文件比较 ' }

    // 扫描目录
  TLocalRestoreFolderCompareHandler = class( TRestoreFolderCompareHandler )
  protected
    FileEditionHash : TFileEditionHash;
  public
    procedure SetParams( _Params : TRestoreParamsData );override;
  protected       // 目标文件信息
    procedure FindSourceFileInfo;override;
  protected
    function getScanHandle( SourceFolderName : string ) : TFolderCompareHandler;override;
  end;

    // 扫描文件
  TLocalRestoreFileCompareHandler = class( TRestoreFileCompareHandler )
  private
    RestoreFrom : string;
  public
    procedure SetParams( Params : TRestoreParamsData );override;
  protected       // 目标文件信息
    function FindSourceFileInfo: Boolean;override;
  end;

{$EndRegion}

{$Region ' 本地恢复 文件续传 ' }

      // 本地文件 续传
  TLocalRestoreContinuesHandler = class( TRestoreContinuesHandler )
  private
    DesFilePath : string;
  public
    procedure Update;override;
  public
    function ReadSourceIsChange : Boolean;override;
    function FileCopy: Boolean;override;
  end;

{$EndRegion}

{$Region ' 本地恢复 文件复制 ' }

      // 文件解压
  TRestoreFileUnpackOperator = class( TFileUnpackOperator )
  protected
    RestorePath, OwnerID, RestoreFrom : string;
    RestoreCancelReader : TRestoreCancelReader;
    SpeedReader : TSpeedReader;
  public
    procedure SetParams( Params : TRestoreParamsData );
  public
    function ReadIsNextCopy : Boolean;override; // 检测是否继续解压
    procedure AddSpeedSpace( SendSize : Integer );override;
    procedure RefreshCompletedSpace;override; // 刷新已完成空间
  end;


    // 文件复制
  TRestoreCopyFileOperator = class( TCopyFileOperator )
  protected
    RestorePath, OwnerID, RestoreFrom : string;
    RestoreCancelReader : TRestoreCancelReader;
    SpeedReader : TSpeedReader;
    RestoreFilePath : string;
  public
    procedure SetParams( Params : TRestoreParamsData );
    procedure SetRestoreFilePath( _RestoreFilePath : string );
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

{$EndRegion}

{$Region ' 本地恢复 文件压缩 ' }

    // 恢复文件打包器
  TRestorePackageHandler = class
  private
    RestorePath, OwnerID, RestoreFrom : string;
    IsDeleted, IsEncrypt : Boolean;
    Password, ExtPassword : string;
  private
    ZipStream : TMemoryStream;
    ZipFile : TZipFile;
  private
    IsZipCreated : Boolean;
    ZipSize : Int64;
    ZipCount : Integer;
  public
    constructor Create;
    procedure SetParams( Params : TRestoreParamsData );
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

{$Region ' 本地恢复 结果处理 ' }

    // 结果处理
  TLocalRestoreResultHandler = class( TRestoreResultHandler )
  private
    DesFilePath : string;
    RecycleFilePath : string;
  public
    procedure Update;override;
  protected         // 添加
    procedure SourceFileAdd;override;
    procedure SourceFolderAdd;override;
  protected         // 删除
    procedure DesFileRemove;override;
    procedure DesFolderRemove;override;
  protected         // 获取压缩包
    procedure SourceFileAddZip;override;
  end;

    // 本地恢复
  TLocalFileRestoreHandler = class( TFileRestoreHandler )
  private
    IsFile : Boolean;
  private
    RestorePackageHandler : TRestorePackageHandler;
  public
    constructor Create;
    procedure SetParams( _Params : TRestoreParamsData );override;
    procedure Handle( ScanResultInfo : TScanResultInfo );override;
    procedure LastCompleted;override;
    destructor Destroy; override;
  private
    procedure HandleNow( ScanResultInfo : TScanResultInfo );
  end;

{$EndRegion}

{$Region ' 本地恢复 操作 ' }

  TLocalRestoreOpterator = class( TRestoreOpterator )
  public
    function ReadRestoreFromIsAvailable: Boolean;override;
  public
    function CreateFileCompareHandler : TRestoreFileCompareHandler;override;
    function CreateFolderCompareHandler : TRestoreFolderCompareHandler;override;
  public
    function CreateContinuesHandler : TRestoreContinuesHandler;override;
    function CreateFileRestoreHandler : TFileRestoreHandler;override;
  end;

{$EndRegion}


{$Region ' 网络恢复 文件比较 ' }

    // 网络目录 恢复  父类
  TNetworkRestoreFolderCompareHandler = class( TRestoreFolderCompareHandler )
  public
    NetworkRestoreParamsData : TNetworkRestoreParamsData;
    TcpSocket : TCustomIpClient;
  public
    procedure SetParams( _Params : TRestoreParamsData );override;
  protected       // 目标文件信息
    procedure FindSourceFileInfo;override;
  protected        // 比较子目录
    function getScanHandle( SourceFolderName : string ) : TFolderCompareHandler;override;
  protected      // 是否 停止扫描
    function CheckNextScan : Boolean;override;
  end;


    // 网络文件 恢复
  TNetworkRestoreFileCompareHandler = class( TRestoreFileCompareHandler )
  public
    TcpSocket : TCustomIpClient;
  public
    procedure SetParams( Params : TRestoreParamsData );override;
  protected       // 目标文件信息
    function FindSourceFileInfo: Boolean;override;
  end;

{$EndRegion}

{$Region ' 网络恢复 文件续传 ' }

    // 续传处理
  TNetworkRestoreContinuesHandler = class( TRestoreContinuesHandler )
  private
    TcpSocket : TCustomIpClient;
  public
    procedure SetParams( _Params : TRestoreParamsData );override;
  protected
    function ReadSourceIsChange : Boolean;override;
    function FileCopy: Boolean;override;
  end;

{$EndRegion}

{$Region ' 网络恢复 文件复制 ' }

      // 接收文件导入器
  TRestoreRecieveFileOperator = class( TReceiveFileOperator )
  private
    RestorePath, OwnerID, RestoreFrom : string;
    SpeedReader : TSpeedReader;
    RestoreCancelReader : TRestoreCancelReader;
    RestoreFilePath : string;
  public
    procedure SetParams( Params : TRestoreParamsData );
    procedure SetRestoreFilePath( _RestoreFilePath : string );
  public
    function ReadIsNextReceive: Boolean;override;
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

      // 解压加密流
  TUncompressEncryptZipStreamHandle = class
  private
    ZipStream : TMemoryStream;
    SavePath : string;
  private
    IsDeleted, IsEncrypted : Boolean;
    Password, PasswordExt : string;
  private
    TcpSocket : TCustomIpClient;
  public
    constructor Create( _ZipStream : TMemoryStream );
    procedure SetSavePath( _SavePath : string );
    procedure SetIsDeleted( _IsDeleted : Boolean );
    procedure SetEncryptedInfo( _IsEncrypted : Boolean; _Password, _PasswordExt : string );
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure Update;
  end;

{$EndRegion}

{$Region ' 网络恢复 多线程 ' }

      // 多线程下载
  TRestoreDownThread = class( TDebugThread )
  private
    IsRun, IsLostConn : Boolean;
  public
    Params : TRestoreParamsData;
    RestoreFrom : string;
    IsDeleted : Boolean;
  private
    TcpSocket : TCustomIpClient;
  private
    SocketLock : TCriticalSection;
    ScanResultInfo : TScanResultInfo;
  public
    constructor Create;
    procedure SetParams( _Params : TRestoreParamsData );
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    destructor Destroy; override;
  public
    procedure AddScanResultInfo( _ScanResultInfo : TScanResultInfo );
    procedure SendZip( FilePath : string );
    procedure getErrorList( ErrorList : TStringList );
  protected
    procedure Execute; override;
  private
    procedure WaitToDown;
    procedure DownloadFile;
  end;
  TRestoreDownThreadList = class( TObjectList<TRestoreDownThread> )end;

{$EndRegion}

{$Region ' 网络恢复 结果处理 ' }

   // 结果处理
  TNetworkRestoreResultHandle = class( TRestoreResultHandler )
  private
    TcpSocket : TCustomIpClient;
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
  protected         // 添加
    procedure SourceFileAdd;override;
    procedure SourceFolderAdd;override;
  protected         // 删除
    procedure DesFileRemove;override;
    procedure DesFolderRemove;override;
  protected         // 获取压缩包
    procedure SourceFileGetZip;override;
  end;


    // 网络恢复
  TNetworkFileRestoreHandler = class( TFileRestoreHandler )
  private
    RestorePath, OwnerID, RestoreFrom : string;
    IsFile, IsDeleted : Boolean;
    TcpSocket : TCustomIpClient;
    HeartTime : TDateTime;
  private
    ZipThreadIndex : Integer;
    ZipCount, ZipSize : Integer;
    ShareDownThreadList : TRestoreDownThreadList;
    IsExistThread : Boolean;
  public
    constructor Create;
    procedure SetParams( _Params : TRestoreParamsData );override;
    procedure IniHandle;override;
    procedure Handle( ScanResultInfo : TScanResultInfo );override;
    procedure LastCompleted;override;
    destructor Destroy; override;
  private
    procedure ZipFile( ScanResultInfo : TScanResultInfo );
    procedure DownloadFile( ScanResultInfo : TScanResultInfo );
    procedure HandleNow( ScanResultInfo : TScanResultInfo );
    procedure DownZipNow;
  private
    function FindZipThread: Boolean;
    procedure DownloadZip;
    function getNewConnect : TCustomIpClient;
    procedure CheckHeartBeat;
    procedure HandleZipError;
  end;


{$EndRegion}

{$Region ' 网络恢复 处理 ' }

  TNetworkRestoreOpterator = class( TRestoreOpterator )
  protected
    TcpSocket : TCustomIpClient;
  public
    procedure SetParams( _Params : TRestoreParamsData );override;
  public
    function ReadRestoreFromIsAvailable: Boolean;override;
  public
    function CreateFileCompareHandler : TRestoreFileCompareHandler;override;
    function CreateFolderCompareHandler : TRestoreFolderCompareHandler;override;
  public
    function CreateContinuesHandler : TRestoreContinuesHandler;override;
    function CreateFileRestoreHandler : TFileRestoreHandler;override;
  end;

{$EndRegion}


{$Region ' 恢复浏览 文件搜索 ' }

    // 参数
  TRestoreExplorerParamsData = class
  public
    RestorePath, OwnerID, RestoreFrom : string;
    IsFile, IsEncrypted, IsDeleted, IsSearch : Boolean;
    PasswordExt : string;
  public
    ScanFileHash : TScanFileHash;
    ScanFolderHash : TScanFolderHash;
  end;

    // 网络参数
  TNetworkRestoreExplorerParamsData = class( TRestoreExplorerParamsData )
  public
    TcpSocket : TCustomIpClient;
  end;

    // 父类
  TRestoreExplorerOperator = class
  public
    RestorePath, OwnerID, RestoreFrom : string;
    IsFile, IsEncrypted, IsDeleted, IsSearch : Boolean;
    PasswordExt : string;
  public
    ScanFileHash : TScanFileHash;
    ScanFolderHash : TScanFolderHash;
  public
    procedure SetParams( Params : TRestoreExplorerParamsData );virtual;
  public
    procedure ReadFolderResult;virtual;abstract;
    procedure ReadFileResult;virtual;abstract;
    procedure ReadDeletedFileResult;virtual;abstract;
  end;

    // 本地搜索
  TLocalRestoreExplorerOperator = class( TRestoreExplorerOperator )
  public
    procedure ReadFolderResult;override;
    procedure ReadFileResult;override;
    procedure ReadDeletedFileResult;override;
  end;

    // 网络搜索
  TNetworkRestoreExplorerOperator = class( TRestoreExplorerOperator )
  private
    TcpSocket : TCustomIpClient;
  public
    procedure SetParams( Params : TRestoreExplorerParamsData );override;
  public
    procedure ReadFolderResult;override;
    procedure ReadFileResult;override;
    procedure ReadDeletedFileResult;override;
  end;

{$EndRegion}

{$Region ' 恢复浏览 结果处理 ' }

      // 浏览结果 参数
  TShowExplorerParams = record
  public
    FilePath : string;
    IsFile : boolean;
  public
    FileSize : int64;
    FileTime : TDateTime;
  public
    EditionNum : Integer;
  end;

    // Explorer 流程
  TRestoreExplorerProcessHandle = class
  public
    RestorePath, OwnerID, RestoreFrom : string;
    IsDeleted, IsFile, IsEncrypted, IsSearch : Boolean;
    PasswordExt : string;
  public
    ScanFileHash : TScanFileHash;
    ScanFolderHash : TScanFolderHash;
  public
    RestoreExplorerOperator : TRestoreExplorerOperator;
  public
    procedure SetParams( Params : TRestoreExplorerParamsData );
    procedure SetRestoreExplorerOperator( _RestoreExplorerOperator : TRestoreExplorerOperator );
    procedure Update;
  protected      // 寻找结果
    procedure FindExplorerResult;
  private        // 显示结果
    procedure ShowExplorerResult;
    function ReadRestoreEdition( FileName : string ): Integer;
    procedure ShowResult( Params : TShowExplorerParams );
  end;

{$EndREgion}


{$Region ' 恢复搜索 文件搜索 ' }

    // 目录搜索
  TRestoreFolderSearchHandle = class( TFolderSearchHandle )
  public
    RestorePath : string;
  public
    procedure SetRestorePath( _RestorePath : string );
  protected
    function CheckNextSearch: Boolean;override;
    procedure HandleResultHash; override;
    function getFolderSearchHandle : TFolderSearchHandle;override;
  end;

      // 网络搜索结果处理
  TNetworkRestoreFolderSearchHandle = class( TNetworkFolderSearchHandle )
  public
    RestorePath : string;
    IsEncrypted : Boolean;
    PasswordExt : string;
    IsDeleted : Boolean;
  public
    procedure SetRestorePath( _RestorePath : string );
    procedure SetEncryptInfo( _IsEncrypted : Boolean; _PasswordExt : string );
    procedure SetIsDeleted( _IsDeleted : Boolean );
  protected
    procedure HandleResultHash;override;
    function getIsStop : Boolean; override;
  end;


{$EndRegion}

{$Region ' 恢复搜索 结果处理 ' }

    // 显示搜索结果
  TRestoreSearchResultShowHandle = class
  public
    RestorePath : string;
    IsEncrypted : Boolean;
    PasswordExt : string;
    IsDeleted : Boolean;
  public
    ResultFileHash : TScanFileHash;
    ResultFolderHash : TScanFolderHash;
  public
    procedure SetRestorePath( _RestorePath : string );
    procedure SetEncryptInfo( _IsEncrypted : Boolean; _PasswordExt : string );
    procedure SetIsDeleted( _IsDeleted : Boolean );
    procedure SetFileResult( _ResultFileHash : TScanFileHash );
    procedure SetFolderResult( _ResultFolderHash : TScanFolderHash );
    procedure Update;
  end;


{$EndRegion}

{$Region ' 恢复搜索 处理 ' }

    // 恢复搜索 父类
  TRestoreSearchHandle = class
  public
    RestoreSearchInfo : TRestoreSearchInfo;
    RestorePath, OwnerID, RestoreFrom : string;
    HasDeleted, IsFile, IsEncrypted : Boolean;
    PasswordExt, SearchName : string;
  public
    procedure SetRestoreScanInfo( _RestoreSearchInfo : TRestoreSearchInfo );
    procedure Update;virtual;abstract;
  end;

    // 本地恢复搜索
  TLocalRestoreSearchHandle = class( TRestoreSearchHandle )
  public
    procedure Update;override;
  protected
    procedure SearchExplorer;
    procedure SearchDeleted;
  end;

      // 网络恢复搜索
  TNetworkRestoreSearchHandle = class( TRestoreSearchHandle )
  protected
    TcpSocket : TCustomIpClient;
  public
    procedure Update;override;
  private
    procedure SearchExplorer;
    procedure SearchDeleted;
  end;


{$EndRegion}


{$Region ' 预览信息 提取 ' }

    // 预览 父类
  TPreviewReader = class
  protected
    RestorePreviewInfo : TRestorePreviewInfo;
    RestorePath, OwnerID, RestoreFrom : string;
    IsDeleted, IsEncrypted : Boolean;
    PasswordExt, Password : string;
    EditionNum : Integer;
  public
    procedure SetRestorePreviewInfo( _RestorePreviewInfo : TRestorePreviewInfo );
  public
    function ReadPicturePreview : TMemoryStream;virtual;abstract;
    function ReadWordPreview : string;virtual;abstract;
    function ReadExcelPreview : string;virtual;abstract;
    function ReadZipOrRarPreview : string;virtual;abstract;
    function ReadExeDetailsPreview : string; virtual;abstract;
    function ReadExeIconPreview : TMemoryStream; virtual;abstract;
    function ReadMusicPreview : string;virtual;abstract;
    function ReadTextPreview : TMemoryStream;virtual;abstract;
  end;

    // 本地预览
  TLocalPreviewReader = class( TPreviewReader )
  public
    function ReadPicturePreview : TMemoryStream;override;
    function ReadWordPreview : string;override;
    function ReadExcelPreview : string;override;
    function ReadZipOrRarPreview : string;override;
    function ReadExeDetailsPreview : string; override;
    function ReadExeIconPreview : TMemoryStream; override;
    function ReadMusicPreview : string;override;
    function ReadTextPreview : TMemoryStream;override;
  private
    function ReadFilePath : string;
  end;

    // 网络预览
  TNetworkPreviewReader = class( TPreviewReader )
  private
    TcpSocket : TCustomIpClient;
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
  public
    function ReadPicturePreview : TMemoryStream;override;
    function ReadWordPreview : string;override;
    function ReadExcelPreview : string;override;
    function ReadZipOrRarPreview : string;override;
    function ReadExeDetailsPreview : string; override;
    function ReadExeIconPreview : TMemoryStream; override;
    function ReadMusicPreview : string;override;
    function ReadTextPreview : TMemoryStream;override;
  private
    procedure SendPreviewReq( FileReq : string );
  end;

{$EndRegion}

{$Region ' 预览文件 操作 ' }

  TPreviewFileHandle = class
  public
    RestorePreviewInfo : TRestorePreviewInfo;
    RestorePath: string;
    IsEncrypted : Boolean;
  protected
    PreviewReader : TPreviewReader;
  public
    procedure SetRestorePreviewInfo( _RestorePreviewInfo : TRestorePreviewInfo );
    procedure SetPreviewReader( _PreviewReader : TPreviewReader );
    procedure Update;virtual;abstract;
  private
    procedure ShowNotPreview;
    procedure ShowEncrytped;
  end;

    // 预览图片
  TPreviewPictureHandle = class( TPreviewFileHandle )
  public
    PictureStream : TMemoryStream;
  public
    procedure Update;override;
  protected
    function FindPictureStream : Boolean;
    procedure ShowPictureStream;
  end;

    // 预览 Word
  TPreviewWordHandle = class( TPreviewFileHandle )
  public
    WordText : string;
  public
    procedure Update;override;
  protected
    procedure FindWordText;
    procedure ShowWordText;
  end;

    // 预览 Excel
  TPreviewExcelHandle = class( TPreviewFileHandle )
  public
    ExcelText : string;
  public
    procedure Update;override;
  protected
    procedure FindExcelText;
    procedure ShowExcelText;
  end;

    // 预览 Zip
  TPreviewZipHandle = class( TPreviewFileHandle )
  public
    ZipText : string;
  public
    procedure Update;override;
  protected
    procedure FindZipText;
    procedure ShowZipText;
  end;

    // 预览 Exe
  TPreviewExeHandle = class( TPreviewFileHandle )
  public
    ExeText : string;
    IconStream : TStream;
  public
    procedure Update;override;
  protected
    procedure FindExeText;
    procedure ShowExeText;
  protected
    function FindIconStream : Boolean;
    procedure ShowIconStream;
  end;

    // 预览 Music
  TPreviewMusicHandle = class( TPreviewFileHandle )
  public
    MusicText : string;
  public
    procedure Update;override;
  protected
    procedure FindMusicText;
    procedure ShowMusicText;
  end;

    // 预览 Text
  TPreviewTextHandle = class( TPreviewFileHandle )
  public
    TextStream : TMemoryStream;
  public
    procedure Update;override;
  protected
    function FindTextStream : Boolean;
    procedure ShowTextStream;
  end;

{$EndRegion}

{$Region ' 恢复预览 处理 ' }

    // 预览处理
  TRestorePreviewHandle = class
  public
    RestorePreviewInfo : TRestorePreviewInfo;
    RestorePath : string;
  public
    PreviewReader : TPreviewReader;
  public
    procedure SetRestorePreviewInfo( _RestorePreviewInfo : TRestorePreviewInfo );
    procedure SetPreviewReader( _PreviewReader : TPreviewReader );
    procedure Update;virtual;
  private
    function CreatePreviewFileHandle : TPreviewFileHandle;
  end;

{$EndRegion}


{$Region ' 恢复 网络连接 ' }

      // 保存已连接的 Socket
  TRestoreDownSocketInfo = class
  public
    RestoreFromPcID : string;
    TcpSocket : TCustomIpClient;
    LastTime : TDateTime;
  public
    constructor Create( _RestoreFromPcID : string );
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
  public
    procedure CloseSocket;
  end;
  TRestoreDownSocketList = class( TObjectList<TRestoreDownSocketInfo> )end;


    // 处理连接
  TMyRestoreDownConnectHandler = class
  private
    ConnectLock : TCriticalSection;
    RestoreDownSocketList : TRestoreDownSocketList; // 保存历史连接
  private
    RestorePath, OwnerID, RestoreFrom : string;
    RestoreConn, RestoreFromPcID : string;
  private
    IsConnSuccess, IsConnError, IsConnBusy : Boolean;
    BackConnSocket : TCustomIpClient;
  public       // 获取反向连接
    constructor Create;
    function getRestoreConn( _RestorePath, _OwnerID, _RestoreFrom, _RestoreConn : string ) : TCustomIpClient;
    procedure AddLastConn( LastRestoreFrom : string; TcpSocket : TCustomIpClient );
    procedure LastConnRefresh; // 心跳
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
  private
    procedure HandleBusy;
    procedure HandleNotConn;
    function getIsHandlerRun : Boolean;
  end;

{$EndRegion}

{$Region ' 恢复 父类 ' }

  TMyRestoreHandler = class;

  TRestoreFileOperator = class
  private
    MyRestoreHandler : TMyRestoreHandler;
  public
    procedure SetMyRestoreHandler( _MyRestoreHandler : TMyRestoreHandler );
  public
    procedure StartRestoreHandle;virtual;
    function ReadIsRun : Boolean;
    function ReastoreHandle : Boolean;
    procedure StopRestoreHandle;virtual;
  protected
    procedure HandlePath( RestorePathInfo : TRestorePathInfo );virtual;abstract;
  end;

    // 处理 恢复线程 父类
  TRestoreHandleThread = class( TDebugThread )
  private
    RestoreFileOperator : TRestoreFileOperator;
  public
    constructor Create( _RestoreFileOperator : TRestoreFileOperator );
  protected
    procedure Execute; override;
  end;

    // 父类
  TMyRestoreHandler = class
  public
    IsRun, IsRestoreRun : Boolean;
  protected
    ThreadLock : TCriticalSection;
    RestorePathList : TRestorePathList;
  protected
    IsCreateThread : Boolean;
    RestoreFileOperator : TRestoreFileOperator;
    RestoreHandleThread : TRestoreHandleThread;
  public
    constructor Create;
    function getIsRun : Boolean;
    procedure StopRun;
    destructor Destroy; override;
  protected
    function CreateOperator : TRestoreFileOperator;virtual;abstract;
  public
    procedure AddRestorePath( RestorePathInfo : TRestorePathInfo );
    function getRestorePath : TRestorePathInfo;
  end;

{$EndRegion}

{$Region ' 恢复 下载 ' }

    // 处理恢复路径
  TRestoreStartHandle = class
  private
    RestorePathInfo : TRestorePathInfo;
    RestorePath, OwnerID, RestoreFrom : string;
    IsLocalRestore : Boolean;
  private
    SpeedReader : TSpeedReader;
    RestoreCancelReader : TRestoreCancelReader;
    RestoreParamsData : TRestoreParamsData;
    RestoreOperator : TRestoreOpterator;
  public
    constructor Create( _RestorePathInfo : TRestorePathInfo );
    procedure Update;
  private
    function ReadIsRestoreEnable : Boolean;
    function CreateRestoreData: Boolean;
    procedure CreateLocalRestoreData;
    function CreateNetworkRestoreData: Boolean;
  private
    procedure RestoreHandle;
  private
    procedure DestoryRestoreData;
    procedure DestoryNetworkData;
  end;

    // 恢复下载
  TRestoreDownFileOperator = class( TRestoreFileOperator )
  public
    procedure StartRestoreHandle;override;
    procedure StopRestoreHandle;override;
  protected
    procedure HandlePath( RestorePathInfo : TRestorePathInfo );override;
  end;


    // 文件恢复控制器
  TMyRestoreDownHandler = class( TMyRestoreHandler )
  protected
    function CreateOperator : TRestoreFileOperator;override;
  end;

{$EndRegion}

{$Region ' 恢复 浏览 ' }

    // 开始 Explorer
  TRestoreExplorerStartHandle = class
  protected
    RestoreExplorerInfo : TRestoreExplorerInfo;
    RestorePath, OwnerID, RestoreFrom : string;
    IsFile, IsEncrypted, IsDeleted, IsSearch : Boolean;
    PasswordExt : string;
    IsLocalRestore : Boolean;
  protected
    RestoreExplorerParamsData : TRestoreExplorerParamsData;
    RestoreExplorerOperator : TRestoreExplorerOperator;
  public
    constructor Create( _RestoreExplorerInfo : TRestoreExplorerInfo );
    procedure Update;
  private
    function CreateRestoreData: Boolean;
    procedure CreateLocalRestoreData;
    function CreateNetworkRestoreData: Boolean;
  private
    procedure ExplorerHandle;
  private
    procedure DestoryRestoreData;
    procedure DestoryNetworkData;
  end;

      // 浏览处理
  TRestoreExplorerFileOperator = class( TRestoreFileOperator )
  public
    procedure StartRestoreHandle;override;
    procedure StopRestoreHandle;override;
  protected
    procedure HandlePath( RestorePathInfo : TRestorePathInfo );override;
  end;

      // 共享文件浏览 控制器
  TMyRestoreExplorerHandler = class( TMyRestoreHandler )
  protected
    function CreateOperator : TRestoreFileOperator;override;
  end;

{$EndRegion}

{$Region ' 恢复 搜索 ' }

        // 浏览处理
  TRestoreSearchFileOperator = class( TRestoreFileOperator )
  public
    procedure StartRestoreHandle;override;
    procedure StopRestoreHandle;override;
  protected
    procedure HandlePath( RestorePathInfo : TRestorePathInfo );override;
  end;

      // 共享文件浏览 控制器
  TMyRestoreSearchHandler = class( TMyRestoreHandler )
  protected
    function CreateOperator : TRestoreFileOperator;override;
  end;

{$EndRegion}

{$Region ' 恢复 预览 ' }

    // 开始预览
  TRestorePreviewStartHandle = class
  public
    RestorePreviewInfo : TRestorePreviewInfo;
    RestorePath, OwnerID, RestoreFrom : string;
    IsLocalPreview : Boolean;
  public
    PreviewReader : TPreviewReader;
  public
    procedure SetRestorePreviewInfo( _RestorePreviewInfo : TRestorePreviewInfo );
    procedure Update;
  private
    function CreateRestoreData: Boolean;
    procedure CreateLocalData;
    function CreateNetworkData: Boolean;
  private
    procedure PreviewHandle;
  private
    procedure DestoryNetworkData;
    procedure DestoryData;
  end;

    // 预览处理
  TRestorePreviewFileOperator = class( TRestoreFileOperator )
  public
    procedure StartRestoreHandle;override;
    procedure StopRestoreHandle;override;
  protected
    procedure HandlePath( RestorePathInfo : TRestorePathInfo );override;
  end;

    // 文件预览 控制器
  TMyRestorePreviewHandler = class( TMyRestoreHandler )
  protected
    function CreateOperator : TRestoreFileOperator;override;
  end;

{$EndRegion}

const
  Name_TempRestoreDownZip = 'ft_restoredown_zip_temp.bczip';

const
  RestoreConnect_Down = 'Down';
  RestoreConnect_Explorer = 'Explorer';
  RestoreConnect_Preview = 'Preview';
  RestoreConnect_Search = 'Search';

var
  MyRestoreHandler : TMyRestoreDownHandler;
  MyRestoreExplorerHandler : TMyRestoreExplorerHandler;
  MyRestoreSearchHandler : TMyRestoreSearchHandler;
  MyRestorePreviewHandler : TMyRestorePreviewHandler;
  MyRestoreDownConnectHandler : TMyRestoreDownConnectHandler;

implementation

uses UMyRestoreApiInfo, UMyNetPcInfo, UMyBackupApiInfo, UMyCloudApiInfo, UMyRestoreDataInfo,
     UNetworkControl, UMyRestoreEventInfo, UMainFormThread, UFormRestoreConfirm, UMyRestoreFaceInfo;

{ TRestoreHandleThread }

constructor TRestoreHandleThread.Create(
  _RestoreFileOperator: TRestoreFileOperator);
begin
  inherited Create;
  RestoreFileOperator := _RestoreFileOperator;
end;

procedure TRestoreHandleThread.Execute;
begin
  FreeOnTerminate := True;

    // 开始恢复
  RestoreFileOperator.StartRestoreHandle;

    // 恢复处理
  while RestoreFileOperator.ReadIsRun and RestoreFileOperator.ReastoreHandle do;

    // 停止恢复
  RestoreFileOperator.StopRestoreHandle;

    // 结束
  Terminate;
end;

{ TLocalSourceFolderScanHandle }

function TRestoreFolderCompareHandler.CheckNextScan: Boolean;
begin
  Result := inherited and RestoreCancelReader.getIsRun;

    // 1 秒钟 检测一次
  if SecondsBetween( Now, ScanTime ) >= 1 then
  begin
    ScanTime := Now;

      // 显示扫描文件数
    RestoreDownAppApi.SetScaningCount( RestorePath, OwnerID, RestoreFrom, FileCount );
  end;
end;

procedure TRestoreFolderCompareHandler.FindDesFileInfo;
var
  DesFolderPath : string;
  LocalFolderFindHandle : TLocalFolderFindHandle;
begin
    // 提取目标文件路径
  if SourceFolderPath = RestorePath then
    DesFolderPath := SavePath
  else
  begin
    DesFolderPath := MyString.CutStartStr( MyFilePath.getPath( RestorePath ), SourceFolderPath );
    DesFolderPath := MyFilePath.getPath( SavePath ) + DesFolderPath;
  end;

    // 扫描目标文件
  LocalFolderFindHandle := TLocalFolderFindHandle.Create;
  LocalFolderFindHandle.SetFolderPath( DesFolderPath );
  LocalFolderFindHandle.SetSleepCount( SleepCount );
  LocalFolderFindHandle.SetScanFile( DesFileHash );
  LocalFolderFindHandle.SetScanFolder( DesFolderHash );
  LocalFolderFindHandle.Update;
  SleepCount := LocalFolderFindHandle.SleepCount;
  LocalFolderFindHandle.Free;
end;

function TRestoreFolderCompareHandler.getDesFileName(
  SourceFileName: string): string;
begin
  Result := MyFilePath.getOrinalName( IsEncrypted, IsDeleted, SourceFileName, PasswordExt );
end;

{ TLocalSourceFileScanHandle }

constructor TRestoreFileCompareHandler.Create;
begin
  inherited;
  IsDeleted := False;
end;

function TRestoreFileCompareHandler.FindDesFileInfo: Boolean;
var
  LocalFileFindHandle : TLocalFileFindHandle;
begin
  LocalFileFindHandle := TLocalFileFindHandle.Create;
  LocalFileFindHandle.SetFilePath( SavePath );
  LocalFileFindHandle.Update;
  Result := LocalFileFindHandle.getIsExist;
  DesFileSize := LocalFileFindHandle.getFileSize;
  DesFileTime := LocalFileFindHandle.getFileTime;
  LocalFileFindHandle.Free;
end;


procedure TRestoreFolderCompareHandler.SetParams(_Params: TRestoreParamsData);
begin
  Params := _Params;

  RestorePath := Params.RestorePath;
  OwnerID := Params.OwnerID;
  RestoreFrom := Params.RestoreFrom;
  SavePath := Params.SavePath;

  IsEncrypted := Params.IsEncrypt;
  PasswordExt := Params.ExtPassword;
  IsDeleted := Params.IsDeleted;

  RestoreCancelReader := Params.RestoreCancelReader;
end;

function TRestoreFileCompareHandler.getAddFilePath: string;
begin
  Result := RestoreFilePath;
end;

function TRestoreFileCompareHandler.getRemoveFilePath: string;
begin
  Result := SavePath;
end;

procedure TRestoreFileCompareHandler.SetParams(Params: TRestoreParamsData);
begin
  SavePath := Params.SavePath;

  IsEncrypted := Params.IsEncrypt;
  PasswordExt := Params.ExtPassword;

  IsDeleted := Params.IsDeleted;
  EditionNum := Params.EditionNum;
end;

procedure TRestoreFileCompareHandler.Update;
begin
  RestoreFilePath := MyFilePath.getAdvanceName( IsEncrypted, IsDeleted, SourceFilePath, PasswordExt, EditionNum );

  inherited;
end;

{ TLocalRestoreResultHandle }

procedure TLocalRestoreResultHandler.DesFileRemove;
begin
  SysUtils.DeleteFile( SaveFilePath );
end;

procedure TLocalRestoreResultHandler.DesFolderRemove;
begin
  MyFolderDelete.DeleteDir( SaveFilePath );
end;

procedure TLocalRestoreResultHandler.SourceFileAdd;
var
  FilePath : string;
  RestoreCopyFileOperator : TRestoreCopyFileOperator;
  CopyFileHandle : TCopyFileHandle;
begin
  SaveFilePath := MyFilePath.getOrinalName( IsEncrypt, IsDeleted, SaveFilePath, ExtPassword );

    // 目标路径
  if not IsDeleted then
    FilePath := DesFilePath
  else
    FilePath := RecycleFilePath;

    // 文件恢复
  RestoreCopyFileOperator := TRestoreCopyFileOperator.Create;
  RestoreCopyFileOperator.SetParams( Params );
  RestoreCopyFileOperator.SetRestoreFilePath( SourceFilePath );
  CopyFileHandle := TCopyFileHandle.Create;
  CopyFileHandle.SetPathInfo( FilePath, SaveFilePath );
  CopyFileHandle.SetDecryptInfo( IsEncrypt, Password );
  CopyFileHandle.SetCopyFileOperator( RestoreCopyFileOperator );
  CopyFileHandle.Update;
  CopyFileHandle.Free;
  RestoreCopyFileOperator.Free;
end;

procedure TLocalRestoreResultHandler.SourceFileAddZip;
var
  ScanResultAddZipInfo : TScanResultAddZipInfo;
  ZipStream : TMemoryStream;
  RestoreFileUnpackOperator : TRestoreFileUnpackOperator;
  FileUnpackHandle : TFileUnpackHandle;
begin
    // 提取信息
  ScanResultAddZipInfo := ScanResultInfo as TScanResultAddZipInfo;
  ZipStream := ScanResultAddZipInfo.ZipStream;

    // 解压文件
  RestoreFileUnpackOperator := TRestoreFileUnpackOperator.Create;
  RestoreFileUnpackOperator.SetParams( Params );
  FileUnpackHandle := TFileUnpackHandle.Create( ZipStream );
  FileUnpackHandle.SetFileUnpackOperator( RestoreFileUnpackOperator );
  FileUnpackHandle.SetSavePath( SavePath );
  FileUnpackHandle.Update;
  FileUnpackHandle.Free;
  RestoreFileUnpackOperator.Free;

    // 释放资源
  ZipStream.Free;
  ScanResultAddZipInfo.Free;
end;

procedure TLocalRestoreResultHandler.SourceFolderAdd;
begin
  ForceDirectories( SaveFilePath );
end;

procedure TLocalRestoreResultHandler.Update;
begin
  DesFilePath := MyFilePath.getLocalBackupPath( RestoreFrom, SourceFilePath );
  RecycleFilePath := MyFilePath.getLocalRecyclePath( RestoreFrom, SourceFilePath );

  inherited;
end;


{ TNetworkFolderRestoreScanHandle }

function TNetworkRestoreFolderCompareHandler.CheckNextScan: Boolean;
begin
  Result := inherited;
  if Result then  // 定时发送心跳
    NetworkRestoreParamsData.CheckHeartBeat;
end;

procedure TNetworkRestoreFolderCompareHandler.FindSourceFileInfo;
var
  NetworkFolderFindHandle : TNetworkFolderFindHandle;
begin
    // 已读取
  if IsDesReaded then
    Exit;

     // 搜索目录信息
  NetworkFolderFindHandle := TNetworkFolderFindHandle.Create;
  NetworkFolderFindHandle.SetFolderPath( SourceFolderPath );
  NetworkFolderFindHandle.SetScanFile( SourceFileHash );
  NetworkFolderFindHandle.SetScanFolder( SourceFolderHash );
  NetworkFolderFindHandle.SetTcpSocket( TcpSocket );
  NetworkFolderFindHandle.SetIsDeep( True );
  NetworkFolderFindHandle.SetIsDeleted( IsDeleted );
  NetworkFolderFindHandle.SetIsFilter( True );
  NetworkFolderFindHandle.SetEnctyptedInfo( IsEncrypted, PasswordExt );
  NetworkFolderFindHandle.SetEditionInfo( IsDeleted );
  NetworkFolderFindHandle.Update;
  NetworkFolderFindHandle.Free;
end;

function TNetworkRestoreFolderCompareHandler.getScanHandle(
  SourceFolderName: string): TFolderCompareHandler;
var
  NetworkFolderRestoreScanHandle : TNetworkRestoreFolderCompareHandler;
  ChildFolderInfo : TScanFolderInfo;
begin
  NetworkFolderRestoreScanHandle := TNetworkRestoreFolderCompareHandler.Create;
  NetworkFolderRestoreScanHandle.SetParams( Params );
  Result := NetworkFolderRestoreScanHandle;

    // 添加子目录信息
  ChildFolderInfo := SourceFolderHash[ SourceFolderName ];
  NetworkFolderRestoreScanHandle.SetIsDesReaded( ChildFolderInfo.IsReaded );

    // 子目录未读取
  if not ChildFolderInfo.IsReaded then
    Exit;

    // 子目录信息
  NetworkFolderRestoreScanHandle.SourceFolderHash.Free;
  NetworkFolderRestoreScanHandle.SourceFolderHash := ChildFolderInfo.ScanFolderHash;
  ChildFolderInfo.ScanFolderHash := TScanFolderHash.Create;

    // 子文件信息
  NetworkFolderRestoreScanHandle.SourceFileHash.Free;
  NetworkFolderRestoreScanHandle.SourceFileHash := ChildFolderInfo.ScanFileHash;
  ChildFolderInfo.ScanFileHash := TScanFileHash.Create;
end;

procedure TNetworkRestoreFolderCompareHandler.SetParams(
  _Params: TRestoreParamsData);
begin
  inherited;

  NetworkRestoreParamsData := Params as TNetworkRestoreParamsData;
  TcpSocket := NetworkRestoreParamsData.TcpSocket;
end;

{ TNetworkRestoreResultHandle }

procedure TNetworkRestoreResultHandle.DesFileRemove;
begin
  SysUtils.DeleteFile( SaveFilePath );
end;

procedure TNetworkRestoreResultHandle.DesFolderRemove;
begin
  MyFolderDelete.DeleteDir( SaveFilePath );
end;

procedure TNetworkRestoreResultHandle.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TNetworkRestoreResultHandle.SourceFileAdd;
var
  RestoreRecieveFileOperator : TRestoreRecieveFileOperator;
  NetworkReceiveFileHandle : TNetworkReceiveFileHandle;
begin
    // 发送请求文件
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_CloudReqType, 'Json' );
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_FileReq, FileReq_GetFile );
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_FilePath, SourceFilePath );
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_IsDeleted, IsDeleted );
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_FilePosition, 0 );
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_IsZipFile, BoolToStr( True ) );

    // 把加密文件后缀 转为正常文件
  SaveFilePath := MyFilePath.getOrinalName( IsEncrypt, IsDeleted, SaveFilePath, ExtPassword );

    // 接收文件
  RestoreRecieveFileOperator := TRestoreRecieveFileOperator.Create;
  RestoreRecieveFileOperator.SetParams( Params );
  RestoreRecieveFileOperator.SetRestoreFilePath( SourceFilePath );
  NetworkReceiveFileHandle := TNetworkReceiveFileHandle.Create;
  NetworkReceiveFileHandle.SetReceiveFilePath( SaveFilePath );
  NetworkReceiveFileHandle.SetTcpSocket( TcpSocket );
  NetworkReceiveFileHandle.SetDecryptInfo( IsEncrypt, Password );
  NetworkReceiveFileHandle.SetRecieveFileOperator( RestoreRecieveFileOperator );
  NetworkReceiveFileHandle.Update;
  NetworkReceiveFileHandle.Free;
  RestoreRecieveFileOperator.Free;
end;

procedure TNetworkRestoreResultHandle.SourceFileGetZip;
var
  ZipStream : TMemoryStream;
  RestoreRecieveFileOperator : TRestoreRecieveFileOperator;
  NetworkReceiveStreamHandle : TNetworkReceiveStreamHandle;
  UncompressEncryptZipStreamHandle : TUncompressEncryptZipStreamHandle;
  TotalSize, DelZipSize : Int64;
begin
    // 发送请求文件
  MySocketUtil.SendData( TcpSocket, FileReq_GetZip );

    // 创建文件流
  ZipStream := TMemoryStream.Create;

    // 接收文件流
  RestoreRecieveFileOperator := TRestoreRecieveFileOperator.Create;
  RestoreRecieveFileOperator.SetParams( Params );
  NetworkReceiveStreamHandle := TNetworkReceiveStreamHandle.Create;
  NetworkReceiveStreamHandle.SetRevStream( ZipStream );
  NetworkReceiveStreamHandle.SetTcpSocket( TcpSocket );
  NetworkReceiveStreamHandle.SetRecieveFileOperator( RestoreRecieveFileOperator );
  NetworkReceiveStreamHandle.Update;
  NetworkReceiveStreamHandle.Free;
  RestoreRecieveFileOperator.Free;

    // 解压文件流
  UncompressEncryptZipStreamHandle := TUncompressEncryptZipStreamHandle.Create( ZipStream );
  UncompressEncryptZipStreamHandle.SetSavePath( SavePath );
  UncompressEncryptZipStreamHandle.SetIsDeleted( IsDeleted );
  UncompressEncryptZipStreamHandle.SetEncryptedInfo( IsEncrypt, Password, ExtPassword );
  UncompressEncryptZipStreamHandle.SetTcpSocket( TcpSocket );
  UncompressEncryptZipStreamHandle.Update;
  UncompressEncryptZipStreamHandle.Free;

    // 发送解压成功
  if TcpSocket.Connected then
    MySocketUtil.SendData( TcpSocket, FileReq_New );

    // 刷新压缩空间信息
  if ScanResultInfo is TScanResultGetZipInfo then
  begin
    TotalSize := ( ScanResultInfo as TScanResultGetZipInfo ).TotalSize;
    DelZipSize := TotalSize - ZipStream.Size;
    RestoreDownAppApi.AddCompletedSpace( RestorePath, OwnerID, RestoreFrom, DelZipSize );
  end;

  ZipStream.Free;
  ScanResultInfo.Free;
end;

procedure TNetworkRestoreResultHandle.SourceFolderAdd;
begin
  ForceDirectories( SaveFilePath );
end;

{ TNetworkFileRestoreScanBaseHandle }

function TNetworkRestoreFileCompareHandler.FindSourceFileInfo: Boolean;
var
  NetworkFileFindHandle : TNetworkFileFindHandle;
begin
  NetworkFileFindHandle := TNetworkFileFindHandle.Create;
  NetworkFileFindHandle.SetFilePath( RestoreFilePath );
  NetworkFileFindHandle.SetIsDeleted( IsDeleted );
  NetworkFileFindHandle.SetTcpSocket( TcpSocket );
  NetworkFileFindHandle.Update;
  Result := NetworkFileFindHandle.getIsExist;
  SourceFileSize := NetworkFileFindHandle.getFileSize;
  SourceFileTime := NetworkFileFindHandle.getFileTime;
  NetworkFileFindHandle.Update;
  NetworkFileFindHandle.Free;
end;

procedure TNetworkRestoreFileCompareHandler.SetParams(Params: TRestoreParamsData);
var
  NetworkRestoreParamsData : TNetworkRestoreParamsData;
begin
  inherited;

  NetworkRestoreParamsData := Params as TNetworkRestoreParamsData;
  TcpSocket := NetworkRestoreParamsData.TcpSocket;
end;


{ TRestoreHandle }

function TRestoreProcessHandle.ContinuesHandle: Boolean;
var
  RestoreDownContinusList : TRestoreDownContinusList;
  i : Integer;
  RestoreDownContinusInfo : TRestoreDownContinusInfo;
  RestoreContinuesHandler : TRestoreContinuesHandler;
begin
  DebugLock.DebugFile( 'Continues', RestorePath );

  RestoreDownContinusList := RestoreDownInfoReadUtil.ReadContinuesList( RestorePath, OwnerID, RestoreFrom );
  if RestoreDownContinusList.Count > 0 then
    RestoreDownAppApi.SetStartRestore( RestorePath, OwnerID, RestoreFrom );
  for i := 0 to RestoreDownContinusList.Count - 1 do
  begin
    if not RestoreCancelReader.getIsRun then  // 恢复结束
      Break;

    RestoreDownContinusInfo := RestoreDownContinusList[i];
    RestoreContinuesHandler := RestoreOpterator.CreateContinuesHandler;
    RestoreContinuesHandler.SetSourceFilePath( RestoreDownContinusInfo.FilePath );
    RestoreContinuesHandler.SetFileInfo( RestoreDownContinusInfo.FileSize, RestoreDownContinusInfo.FileTime );
    RestoreContinuesHandler.SetParams( RestoreParamsData );
    RestoreContinuesHandler.Update;
    RestoreContinuesHandler.Free;
  end;
  RestoreDownContinusList.Free;

  Result := RestoreCancelReader.getIsRun;
end;

constructor TRestoreProcessHandle.Create;
begin
  ScanResultList := TScanResultList.Create;
end;

destructor TRestoreProcessHandle.Destroy;
begin
  ScanResultList.Free;
  inherited;
end;

function TRestoreProcessHandle.ReadIsRestoreCompleted: Boolean;
begin
  Result := RestoreDownInfoReadUtil.ReadIsCompleted( RestorePath, OwnerID, RestoreFrom );
end;

function TRestoreProcessHandle.ReadRestoreToIsAvailable: Boolean;
var
  ParentPath : string;
  IsWrite : Boolean;
begin
  Result := False;

    // 已取消
  if not RestoreDownInfoReadUtil.ReadIsEnable( RestorePath, OwnerID, RestoreFrom ) then
    Exit;

    // 读取 下载路径 失败
  if SavePath = '' then
    Exit;

    // 下载路径 是否可写
  if IsFile then
    ParentPath := ExtractFileDir( SavePath )
  else
    ParentPath := SavePath;
  ForceDirectories( ParentPath );
  IsWrite := MyFilePath.getIsModify( ParentPath );

    // 设置 非缺小空间
  RestoreDownAppApi.SetIsLackSpace( RestorePath, OwnerID, RestoreFrom, False );

    // 设置 路径是否可写
  RestoreDownAppApi.SetIsWrite( RestorePath, OwnerID, RestoreFrom, IsWrite );

  Result := IsWrite;
end;

function TRestoreProcessHandle.ReadRestoreFromIsAvailable: Boolean;
begin
  Result := RestoreOpterator.ReadRestoreFromIsAvailable;
end;

procedure TRestoreProcessHandle.ResetRestorePathSpace;
var
  Params : TRestoreDownSetSpaceParams;
begin
  Params.RestorePath := RestorePath;
  Params.OwnerPcID := OwnerID;
  Params.RestoreFrom := RestoreFrom;
  Params.FileCount := TotalCount;
  Params.FileSize := TotalSize;
  Params.CompletedSize := TotalCompleted;
  RestoreDownAppApi.SetSpaceInfo( Params );
end;

function TRestoreProcessHandle.CompareResultHandle: Boolean;
var
  FileRestoreHandler : TFileRestoreHandler;
  i : Integer;
begin
  Result := True;

    // 无 Job
  if ScanResultList.Count = 0 then
    Exit;

  DebugLock.DebugFile( 'Restoring', RestorePath );

    // 设置正在恢复
  RestoreDownAppApi.SetStartRestore( RestorePath, OwnerID, RestoreFrom );

    // 恢复文件
  FileRestoreHandler := RestoreOpterator.CreateFileRestoreHandler;
  FileRestoreHandler.SetParams( RestoreParamsData );
  FileRestoreHandler.IniHandle;
  for i := 0 to ScanResultList.Count - 1 do
  begin
    if not RestoreCancelReader.getIsRun then
      Break;
    FileRestoreHandler.Handle( ScanResultList[i] );
  end;
  if i = ScanResultList.Count then
    FileRestoreHandler.LastCompleted;
  FileRestoreHandler.Free;

  Result := RestoreCancelReader.getIsRun;
end;

procedure TRestoreProcessHandle.FileCompareHandle;
var
  RestoreFileCompareHandler : TRestoreFileCompareHandler;
begin
  RestoreFileCompareHandler := RestoreOpterator.CreateFileCompareHandler;
  RestoreFileCompareHandler.SetSourceFilePath( RestorePath );
  RestoreFileCompareHandler.SetParams( RestoreParamsData );
  RestoreFileCompareHandler.SetResultList( ScanResultList );
  RestoreFileCompareHandler.Update;
  TotalCount := 1;
  TotalSize := RestoreFileCompareHandler.SourceFileSize;
  TotalCompleted := RestoreFileCompareHandler.CompletedSize;
  RestoreFileCompareHandler.Free;
end;

procedure TRestoreProcessHandle.FolderCompareHandle;
var
  RestoreFolderCompareHandler : TRestoreFolderCompareHandler;
begin
  RestoreFolderCompareHandler := RestoreOpterator.CreateFolderCompareHandler;
  RestoreFolderCompareHandler.SetSourceFolderPath( RestorePath );
  RestoreFolderCompareHandler.SetIsSupportDeleted( False );
  RestoreFolderCompareHandler.SetParams( RestoreParamsData );
  RestoreFolderCompareHandler.SetResultList( ScanResultList );
  RestoreFolderCompareHandler.Update;
  TotalCount := RestoreFolderCompareHandler.FileCount;
  TotalSize := RestoreFolderCompareHandler.FileSize;
  TotalCompleted := RestoreFolderCompareHandler.CompletedSize;
  RestoreFolderCompareHandler.Free;
end;


function TRestoreProcessHandle.RestoreCompareHandle: Boolean;
begin
  DebugLock.DebugFile( 'Scanning', RestorePath );

    // 正在分析
  RestoreDownAppApi.SetAnalyzeRestore( RestorePath, OwnerID, RestoreFrom );

  if IsFile then
    FileCompareHandle
  else
    FolderCompareHandle;

  Result := RestoreCancelReader.getIsRun;
end;

procedure TRestoreProcessHandle.SetRestoreCompleted;
begin
  RestoreDownAppApi.RestoreCompleted( RestorePath, OwnerID, RestoreFrom );
end;

procedure TRestoreProcessHandle.SetRestoreOperator(
  _RestoreOpterator: TRestoreOpterator);
begin
  RestoreOpterator := _RestoreOpterator;
end;

procedure TRestoreProcessHandle.SetRestoreParamsData(
  _RestoreParamsDataParams: TRestoreParamsData);
begin
  RestoreParamsData := _RestoreParamsDataParams;
  RestorePath := RestoreParamsData.RestorePath;
  OwnerID := RestoreParamsData.OwnerID;
  RestoreFrom := RestoreParamsData.RestoreFrom;
  IsFile := RestoreParamsData.IsFile;
  SavePath := RestoreParamsData.SavePath;

  RestoreCancelReader := RestoreParamsData.RestoreCancelReader;
end;

procedure TRestoreProcessHandle.Update;
begin
  DebugLock.Debug( 'Restore Start' );

    // 恢复路径出错
  if not ReadRestoreFromIsAvailable then
    Exit;

    // 保存路径出错
  if not ReadRestoreToIsAvailable then
    Exit;

    // 文件续传
  if not ContinuesHandle then
    Exit;

    // 文件比较
  if not RestoreCompareHandle then
    Exit;

    // 用户确认恢复文件
  if not UserConfirmRestore then
    Exit;

    // 重设恢复空间信息
  ResetRestorePathSpace;

    // 处理文件比较结果
  if not CompareResultHandle then
    Exit;

    // 是否恢复完成
  if not ReadIsRestoreCompleted then
    Exit;

    // 设置恢复完成
  SetRestoreCompleted;
end;

function TRestoreProcessHandle.UserConfirmRestore: Boolean;
var
  RestoreFileConfirmHandle : TRestoreFileConfirmHandle;
begin
  RestoreFileConfirmHandle := TRestoreFileConfirmHandle.Create( ScanResultList );
  Result := RestoreFileConfirmHandle.getIsConfirm;
  if Result then
  begin
    TotalCount := TotalCount - RestoreFileConfirmHandle.CancelCount;
    TotalSize := TotalSize - RestoreFileConfirmHandle.CancelSize;
  end;
  RestoreFileConfirmHandle.Free;
end;

{ TRestoreResultHandle }

procedure TRestoreResultHandler.SetParams(_Params: TRestoreParamsData);
begin
  Params := _Params;

  RestorePath := Params.RestorePath;
  OwnerID := Params.OwnerID;
  RestoreFrom := Params.RestoreFrom;
  IsFile := Params.IsFile;
  SavePath := Params.SavePath;

  IsEncrypt := Params.IsEncrypt;
  Password := Params.Password;
  ExtPassword := Params.ExtPassword;
  IsDeleted := Params.IsDeleted;

  SpeedReader := Params.SpeedReader;
end;

procedure TRestoreResultHandler.SetScanResultInfo(
  _ScanResultInfo: TScanResultInfo);
begin
  ScanResultInfo := _ScanResultInfo;
  SourceFilePath := ScanResultInfo.SourceFilePath;
end;

procedure TRestoreResultHandler.SourceFileAddZip;
begin

end;

procedure TRestoreResultHandler.SourceFileGetZip;
begin

end;

procedure TRestoreResultHandler.Update;
begin
  try
    DebugLock.Debug( ScanResultInfo.ClassName + ':  ' + ScanResultInfo.SourceFilePath );

      // 保存的路径信息
    if IsFile then
      SaveFilePath := SavePath
    else
    begin
      SaveFilePath := MyString.CutStartStr( MyFilePath.getPath( RestorePath ), SourceFilePath );
      SaveFilePath := MyFilePath.getPath( SavePath ) + SaveFilePath;
    end;

      // 备份结果操作
    if ScanResultInfo is TScanResultAddFileInfo then
      SourceFileAdd
    else
    if ScanResultInfo is TScanResultAddFolderInfo then
      SourceFolderAdd
    else
    if ScanResultInfo is TScanResultRemoveFileInfo then
      DesFileRemove
    else
    if ScanResultInfo is TScanResultRemoveFolderInfo then
      DesFolderRemove
    else
    if ScanResultInfo is TScanResultGetZipInfo then
      SourceFileGetZip
    else
    if ScanResultInfo is TScanResultAddZipInfo then
      SourceFileAddZip
  except
  end;
end;

{ TRestoreExplorerHandle }

procedure TRestoreExplorerProcessHandle.FindExplorerResult;
begin
  if not IsFile then  // 搜索目录
    RestoreExplorerOperator.ReadFolderResult
  else
  if IsDeleted then  // 搜索删除的文件
    RestoreExplorerOperator.ReadDeletedFileResult
  else               // 搜索文件
    RestoreExplorerOperator.ReadFileResult;
end;

function TRestoreExplorerProcessHandle.ReadRestoreEdition(FileName: string): Integer;
begin
  Result := 0;
  if not IsDeleted then
    Exit;
  Result := MyFilePath.getDeletedEdition(FileName);
end;

procedure TRestoreExplorerProcessHandle.SetParams(Params: TRestoreExplorerParamsData);
begin
  RestorePath := Params.RestorePath;
  OwnerID := Params.OwnerID;
  RestoreFrom := Params.RestoreFrom;
  IsFile := Params.IsFile;

  IsEncrypted := Params.IsEncrypted;
  PasswordExt := Params.PasswordExt;
  IsDeleted := Params.IsDeleted;
  IsSearch := Params.IsSearch;

  ScanFileHash := Params.ScanFileHash;
  ScanFolderHash := Params.ScanFolderHash;
end;

procedure TRestoreExplorerProcessHandle.SetRestoreExplorerOperator(
  _RestoreExplorerOperator: TRestoreExplorerOperator);
begin
  RestoreExplorerOperator := _RestoreExplorerOperator;
end;

procedure TRestoreExplorerProcessHandle.ShowResult(Params: TShowExplorerParams);
var
  ResultParams : TExplorerResultParams;
begin
  ResultParams.FilePath := Params.FilePath;
  ResultParams.IsFile := Params.IsFile;
  ResultParams.FileSize := Params.FileSize;
  ResultParams.FileTime := Params.FileTime;
  ResultParams.EditionNum := Params.EditionNum;

    // 处理结果
  if IsSearch then  // 搜索文件的 Explorer
  begin
    if IsDeleted then
      RestoreSearchAppApi.ShowExplorerDeleted( ResultParams )
    else
      RestoreSearchAppApi.ShowExplorer( ResultParams );
  end
  else      // 回收文件的 Explorer
  if IsDeleted then
    RestoreDeleteExplorerAppApi.ShowResult( ResultParams )
  else      // 普通 Explorer
    RestoreExplorerAppApi.ShowResult( ResultParams );
end;

procedure TRestoreExplorerProcessHandle.ShowExplorerResult;
var
  p : TScanFilePair;
  pf : TScanFolderPair;
  ParentPath, FolderPath, FileName : string;
  Params : TShowExplorerParams;
begin
  if IsFile then
    ParentPath := MyFilePath.getPath( ExtractFileDir( RestorePath ) )
  else
    ParentPath := MyFilePath.getPath( RestorePath );

  Params.IsFile := False;
  for pf in ScanFolderHash do
  begin
    Params.FilePath := ParentPath + pf.Value.FolderName;
    ShowResult( Params );
  end;

  Params.IsFile := True;
  for p in ScanFileHash do
  begin
    FileName := MyFilePath.getOrinalName( IsEncrypted, IsDeleted, p.Value.FileName, PasswordExt );
    Params.FilePath := ParentPath + FileName;
    Params.FileSize := p.Value.FileSize;
    Params.FileTime := p.Value.FileTime;
    Params.EditionNum := ReadRestoreEdition( p.Value.FileName );
    ShowResult( Params );
  end;
end;

procedure TRestoreExplorerProcessHandle.Update;
begin
    // 搜索
  DebugLock.Debug( 'Find Result' );
  FindExplorerResult;

    // 显示
  DebugLock.Debug( 'Show Result' );
  ShowExplorerResult;
end;

{ TShareDownContinuesHandle }

function TRestoreContinuesHandler.ReadDestinationPos: Boolean;
begin
  Result := FileExists( SaveFilePath );
  if Result then
  begin
    Position := MyFileInfo.getFileSize( SaveFilePath );
    Result := Position <= FileSize;
  end;
end;

procedure TRestoreContinuesHandler.RemoveContinusInfo;
begin
  RestoreDownContinusApi.RemoveItem( RestorePath, OwnerID, RestoreFrom, FilePath );
end;

procedure TRestoreContinuesHandler.SetFileInfo(_FileSize : Int64;
  _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TRestoreContinuesHandler.SetParams(_Params: TRestoreParamsData);
begin
  Params := _Params;

  RestorePath := Params.RestorePath;
  OwnerID := Params.OwnerID;
  RestoreFrom := Params.RestoreFrom;
  IsFile := Params.IsFile;
  SavePath := Params.SavePath;

  IsEncrypted := Params.IsEncrypt;
  Password := Params.Password;
  ExtPassword := Params.ExtPassword;
  IsDeleted := Params.IsDeleted;

  SpeedReader := Params.SpeedReader;
end;

procedure TRestoreContinuesHandler.SetSourceFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TRestoreContinuesHandler.Update;
begin
     // 保存的路径信息
  if IsFile then
    SaveFilePath := SavePath
  else
  begin
    SaveFilePath := MyString.CutStartStr( MyFilePath.getPath( RestorePath ), FilePath );
    SaveFilePath := MyFilePath.getPath( SavePath ) + SaveFilePath;
  end;

    // 把加密文件后缀 转为正常文件
  SaveFilePath := MyFilePath.getOrinalName( IsEncrypted, IsDeleted, SaveFilePath, ExtPassword );

    // 源文件发生变化, 目标文件发生变化
  if ReadSourceIsChange or not ReadDestinationPos or FileCopy then
    RemoveContinusInfo; // 删除续传记录
end;


{ TLocalShareDownContinuesHandle }

function TLocalRestoreContinuesHandler.FileCopy: Boolean;
var
  RestoreCopyFileOperator : TRestoreCopyFileOperator;
  CopyFileHandle : TCopyFileHandle;
begin
  RestoreCopyFileOperator := TRestoreCopyFileOperator.Create;
  RestoreCopyFileOperator.SetParams( Params );
  RestoreCopyFileOperator.SetRestoreFilePath( FilePath );
  CopyFileHandle := TCopyFileHandle.Create;
  CopyFileHandle.SetPathInfo( DesFilePath, SaveFilePath );
  CopyFileHandle.SetPosition( Position );
  CopyFileHandle.SetDecryptInfo( IsEncrypted, Password );
  CopyFileHandle.SetCopyFileOperator( RestoreCopyFileOperator );
  Result := CopyFileHandle.Update;
  CopyFileHandle.Free;
  RestoreCopyFileOperator.Free;
end;

function TLocalRestoreContinuesHandler.ReadSourceIsChange: Boolean;
begin
  Result := True;
  if not FileExists( DesFilePath ) then
    Exit;
  if MyFileInfo.getFileSize( DesFilePath ) <> FileSize then
    Exit;
  if not MyDatetime.Equals( MyFileInfo.getFileLastWriteTime( DesFilePath ), FileTime ) then
    Exit;
  Result := False;
end;

procedure TLocalRestoreContinuesHandler.Update;
begin
    // 恢复的路径信息
  if not IsDeleted then
    DesFilePath := MyFilePath.getLocalBackupPath( RestoreFrom, FilePath )
  else
    DesFilePath := MyFilePath.getLocalRecyclePath( RestoreFrom, FilePath );

  inherited;
end;

{ TNetworkShareDownContinuesHandle }

function TNetworkRestoreContinuesHandler.FileCopy: Boolean;
var
  RestoreRecieveFileOperator : TRestoreRecieveFileOperator;
  NetworkReceiveFileHandle : TNetworkReceiveFileHandle;
begin
    // 发送请求信息
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_CloudReqType, 'Json' );
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_FileReq, FileReq_GetFile );
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_FilePath, FilePath );
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_IsDeleted, IsDeleted );
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_FilePosition, IntToStr( Position ) );
  MySocketUtil.SendJsonStr( TcpSocket, JsonMsgType_IsZipFile, BoolToStr( True ) );

    // 接收文件
  RestoreRecieveFileOperator := TRestoreRecieveFileOperator.Create;
  RestoreRecieveFileOperator.SetParams( Params );
  RestoreRecieveFileOperator.SetRestoreFilePath( FilePath );
  NetworkReceiveFileHandle := TNetworkReceiveFileHandle.Create;
  NetworkReceiveFileHandle.SetReceiveFilePath( SaveFilePath );
  NetworkReceiveFileHandle.SetTcpSocket( TcpSocket );
  NetworkReceiveFileHandle.SetDecryptInfo( IsEncrypted, Password );
  NetworkReceiveFileHandle.SetRecieveFileOperator( RestoreRecieveFileOperator );
  Result := NetworkReceiveFileHandle.Update;
  NetworkReceiveFileHandle.Free;
  RestoreRecieveFileOperator.Free;
end;

function TNetworkRestoreContinuesHandler.ReadSourceIsChange: Boolean;
var
  SourceIsExist : Boolean;
  SourceFileSize : Int64;
  SourceFileTime : TDateTime;
  NetworkFileFindHandle : TNetworkFileFindHandle;
begin
  Result := True;

  NetworkFileFindHandle := TNetworkFileFindHandle.Create;
  NetworkFileFindHandle.SetFilePath( FilePath );
  NetworkFileFindHandle.SetTcpSocket( TcpSocket );
  NetworkFileFindHandle.SetIsDeleted( IsDeleted );
  NetworkFileFindHandle.Update;
  SourceIsExist := NetworkFileFindHandle.getIsExist;
  SourceFileSize := NetworkFileFindHandle.getFileSize;
  SourceFileTime := NetworkFileFindHandle.getFileTime;
  NetworkFileFindHandle.Free;

  if not SourceIsExist then
    Exit;

  if SourceFileSize <> FileSize then
    Exit;

  if not MyDatetime.Equals( FileTime, SourceFileTime )  then
    Exit;

  Result := False;
end;

procedure TNetworkRestoreContinuesHandler.SetParams(
  _Params: TRestoreParamsData);
var
  NetworkRestoreParamsData : TNetworkRestoreParamsData;
begin
  inherited;

  NetworkRestoreParamsData := Params as TNetworkRestoreParamsData;
  TcpSocket := NetworkRestoreParamsData.TcpSocket;
end;

{ TRestoreScanExplorerInfo }

procedure TRestoreExplorerInfo.SetExplorerInfo(_IsFile,
  _IsDeleted: Boolean);
begin
  IsFile := _IsFile;
  IsDeleted := _IsDeleted;
end;

procedure TRestoreExplorerInfo.SetIsSearch(_IsSearch: Boolean);
begin
  IsSearch := _IsSearch;
end;

{ TRestoreScanSearchInfo }

procedure TRestoreSearchInfo.SetSearchInfo(_IsFile, _HasDeleted: Boolean);
begin
  IsFile := _IsFile;
  HasDeleted := _HasDeleted;
end;

procedure TRestoreSearchInfo.SetSearchName(_SearchName: string);
begin
  SearchName := _SearchName;
end;

{ TRestoreSearchHandle }

procedure TRestoreSearchHandle.SetRestoreScanInfo(
  _RestoreSearchInfo: TRestoreSearchInfo);
begin
  RestoreSearchInfo := _RestoreSearchInfo;
  RestorePath := RestoreSearchInfo.RestorePath;
  OwnerID := RestoreSearchInfo.OwnerID;
  RestoreFrom := RestoreSearchInfo.RestoreFrom;
  IsFile := RestoreSearchInfo.IsFile;
  HasDeleted := RestoreSearchInfo.HasDeleted;
  IsEncrypted := RestoreSearchInfo.IsEncrypted;
  PasswordExt := RestoreSearchInfo.PasswordExt;
  SearchName := RestoreSearchInfo.SearchName;
end;

{ TRestoreFolderSearchHandle }

function TRestoreFolderSearchHandle.CheckNextSearch: Boolean;
begin
  Result := inherited and MyRestoreSearchHandler.getIsRun;
end;

function TRestoreFolderSearchHandle.getFolderSearchHandle: TFolderSearchHandle;
var
  RestoreFolderSearchHandle : TRestoreFolderSearchHandle;
begin
  RestoreFolderSearchHandle := TRestoreFolderSearchHandle.Create;
  RestoreFolderSearchHandle.SetRestorePath( RestorePath );
  Result := RestoreFolderSearchHandle;
end;

procedure TRestoreFolderSearchHandle.HandleResultHash;
var
  RestoreSearchResultShowHandle : TRestoreSearchResultShowHandle;
begin
  RestoreSearchResultShowHandle := TRestoreSearchResultShowHandle.Create;
  RestoreSearchResultShowHandle.SetRestorePath( RestorePath );
  RestoreSearchResultShowHandle.SetEncryptInfo( IsEncrypted, PasswordExt );
  RestoreSearchResultShowHandle.SetIsDeleted( IsDeleted );
  RestoreSearchResultShowHandle.SetFileResult( ResultFileHash );
  RestoreSearchResultShowHandle.SetFolderResult( ResultFolderHash );
  RestoreSearchResultShowHandle.Update;
  RestoreSearchResultShowHandle.Free;
end;

procedure TRestoreFolderSearchHandle.SetRestorePath(_RestorePath: string);
begin
  RestorePath := _RestorePath;
end;

{ TRestoreSearchResultShowHandle }

procedure TRestoreSearchResultShowHandle.SetEncryptInfo(_IsEncrypted: Boolean;
  _PasswordExt: string);
begin
  IsEncrypted := _IsEncrypted;
  PasswordExt := _PasswordExt;
end;

procedure TRestoreSearchResultShowHandle.SetFileResult(
  _ResultFileHash: TScanFileHash);
begin
  ResultFileHash := _ResultFileHash;
end;

procedure TRestoreSearchResultShowHandle.SetFolderResult(
  _ResultFolderHash: TScanFolderHash);
begin
  ResultFolderHash := _ResultFolderHash;
end;

procedure TRestoreSearchResultShowHandle.SetIsDeleted(_IsDeleted: Boolean);
begin
  IsDeleted := _IsDeleted;
end;

procedure TRestoreSearchResultShowHandle.SetRestorePath(_RestorePath: string);
begin
  RestorePath := _RestorePath;
end;

procedure TRestoreSearchResultShowHandle.Update;
var
  Params : TSearchResultParams;
  p : TScanFilePair;
  pf : TScanFolderPair;
  ParentPath, FileName : string;
begin
  Params.IsDeleted := IsDeleted;

  ParentPath := MyFilePath.getPath( RestorePath );

    // 显示文件搜索结果
  Params.IsFile := True;
  for p in ResultFileHash do
  begin
    FileName := MyFilePath.getOrinalName( IsEncrypted, IsDeleted, p.Value.FileName, PasswordExt );
    Params.FilePath :=  ParentPath + FileName;
    Params.FileSize := p.Value.FileSize;
    Params.FileTime := p.Value.FileTime;
    Params.EditionNum := MyFilePath.getDeletedEdition( p.Value.FileName );
    RestoreSearchAppApi.ShowResult( Params );
  end;

    // 显示目录搜索结果
  Params.IsFile := False;
  for pf in ResultFolderHash do
  begin
    Params.FilePath := ParentPath + pf.Value.FolderName;
    RestoreSearchAppApi.ShowResult( Params );
  end;
end;

{ TLocalRestoreSearchHandle }

procedure TLocalRestoreSearchHandle.SearchDeleted;
var
  ResultFileHash : TScanFileHash;
  ResultFolderHash : TScanFolderHash;
  ScanPath : string;
  RestoreFolderSearchHandle : TRestoreFolderSearchHandle;
begin
  ResultFileHash := TScanFileHash.Create;
  ResultFolderHash := TScanFolderHash.Create;

  ScanPath := MyFilePath.getLocalRecyclePath( RestoreFrom, RestorePath );

  RestoreFolderSearchHandle := TRestoreFolderSearchHandle.Create;
  RestoreFolderSearchHandle.SetRestorePath( RestorePath );
  RestoreFolderSearchHandle.SetIsDeleted( True );
  RestoreFolderSearchHandle.SetFolderPath( ScanPath );
  RestoreFolderSearchHandle.SetSerachName( SearchName );
  RestoreFolderSearchHandle.SetResultFolderPath( '' );
  RestoreFolderSearchHandle.SetResultFile( ResultFileHash );
  RestoreFolderSearchHandle.SetResultFolder( ResultFolderHash );
  RestoreFolderSearchHandle.SetEncryptInfo( IsEncrypted, PasswordExt );
  RestoreFolderSearchHandle.SetIsDeleted( True );
  RestoreFolderSearchHandle.Update;
  RestoreFolderSearchHandle.LastRefresh;
  RestoreFolderSearchHandle.Free;

  ResultFileHash.Free;
  ResultFolderHash.Free;
end;

procedure TLocalRestoreSearchHandle.SearchExplorer;
var
  ResultFileHash : TScanFileHash;
  ResultFolderHash : TScanFolderHash;
  ScanPath : string;
  RestoreFolderSearchHandle : TRestoreFolderSearchHandle;
begin
  ResultFileHash := TScanFileHash.Create;
  ResultFolderHash := TScanFolderHash.Create;

  ScanPath := MyFilePath.getLocalBackupPath( RestoreFrom, RestorePath );

  RestoreFolderSearchHandle := TRestoreFolderSearchHandle.Create;
  RestoreFolderSearchHandle.SetRestorePath( RestorePath );
  RestoreFolderSearchHandle.SetIsDeleted( False );
  RestoreFolderSearchHandle.SetFolderPath( ScanPath );
  RestoreFolderSearchHandle.SetSerachName( SearchName );
  RestoreFolderSearchHandle.SetResultFolderPath( '' );
  RestoreFolderSearchHandle.SetResultFile( ResultFileHash );
  RestoreFolderSearchHandle.SetResultFolder( ResultFolderHash );
  RestoreFolderSearchHandle.SetEncryptInfo( IsEncrypted, PasswordExt );
  RestoreFolderSearchHandle.SetIsDeleted( False );
  RestoreFolderSearchHandle.Update;
  RestoreFolderSearchHandle.LastRefresh;
  RestoreFolderSearchHandle.Free;

  ResultFileHash.Free;
  ResultFolderHash.Free;
end;

procedure TLocalRestoreSearchHandle.Update;
begin
  SearchExplorer;
  if HasDeleted then
    SearchDeleted;
end;

{ TNetworkRestoreSearchBaseHandle }

procedure TNetworkRestoreSearchHandle.SearchDeleted;
var
  NetworkRestoreSearchHandle : TNetworkRestoreFolderSearchHandle;
begin
  MySocketUtil.SendData( TcpSocket, FileReq_SearchFolder );
  MySocketUtil.SendData( TcpSocket, RestorePath );
  MySocketUtil.SendData( TcpSocket, True );
  MySocketUtil.SendData( TcpSocket, SearchName );
  MySocketUtil.SendData( TcpSocket, IsEncrypted );
  MySocketUtil.SendData( TcpSocket, PasswordExt );

  NetworkRestoreSearchHandle := TNetworkRestoreFolderSearchHandle.Create;
  NetworkRestoreSearchHandle.SetTcpSocket( TcpSocket );
  NetworkRestoreSearchHandle.SetRestorePath( RestorePath );
  NetworkRestoreSearchHandle.SetEncryptInfo( IsEncrypted, PasswordExt );
  NetworkRestoreSearchHandle.SetIsDeleted( True );
  NetworkRestoreSearchHandle.Update;
  NetworkRestoreSearchHandle.Free;
end;

procedure TNetworkRestoreSearchHandle.SearchExplorer;
var
  NetworkRestoreSearchHandle : TNetworkRestoreFolderSearchHandle;
begin
  MySocketUtil.SendData( TcpSocket, FileReq_SearchFolder );
  MySocketUtil.SendData( TcpSocket, RestorePath );
  MySocketUtil.SendData( TcpSocket, False );
  MySocketUtil.SendData( TcpSocket, SearchName );
  MySocketUtil.SendData( TcpSocket, IsEncrypted );
  MySocketUtil.SendData( TcpSocket, PasswordExt );

  NetworkRestoreSearchHandle := TNetworkRestoreFolderSearchHandle.Create;
  NetworkRestoreSearchHandle.SetTcpSocket( TcpSocket );
  NetworkRestoreSearchHandle.SetRestorePath( RestorePath );
  NetworkRestoreSearchHandle.SetEncryptInfo( IsEncrypted, PasswordExt );
  NetworkRestoreSearchHandle.SetIsDeleted( False );
  NetworkRestoreSearchHandle.Update;
  NetworkRestoreSearchHandle.Free;
end;

procedure TNetworkRestoreSearchHandle.Update;
var
  CloudConnResult : string;
  IsSuccessConn : Boolean;
begin
  DebugLock.Debug( 'Start Search' );

  TcpSocket := MyRestoreDownConnectHandler.getRestoreConn( RestorePath, OwnerID, RestoreFrom, RestoreConnect_Search );
  if not Assigned( TcpSocket ) then
    Exit;

    // 获取访问结果
  CloudConnResult := MySocketUtil.RevData( TcpSocket );

    // 是否连接成功
  IsSuccessConn := CloudConnResult = CloudConnResult_OK;

    // 连接成功, 发送搜索信息
  if IsSuccessConn then
  begin
    SearchExplorer;
    if HasDeleted then
      SearchDeleted;
  end;

    // 返回连接
  MyRestoreDownConnectHandler.AddLastConn( RestoreFrom, TcpSocket );
end;

{ TNetworkRestoreSearchHandle }

function TNetworkRestoreFolderSearchHandle.getIsStop: Boolean;
begin
  Result := not MyRestoreSearchHandler.getIsRun;
end;

procedure TNetworkRestoreFolderSearchHandle.HandleResultHash;
var
  RestoreSearchResultShowHandle : TRestoreSearchResultShowHandle;
begin
  RestoreSearchResultShowHandle := TRestoreSearchResultShowHandle.Create;
  RestoreSearchResultShowHandle.SetRestorePath( RestorePath );
  RestoreSearchResultShowHandle.SetEncryptInfo( IsEncrypted, PasswordExt );
  RestoreSearchResultShowHandle.SetIsDeleted( IsDeleted );
  RestoreSearchResultShowHandle.SetFileResult( ResultFileHash );
  RestoreSearchResultShowHandle.SetFolderResult( ResultFolderHash );
  RestoreSearchResultShowHandle.Update;
  RestoreSearchResultShowHandle.Free;
end;

procedure TNetworkRestoreFolderSearchHandle.SetEncryptInfo(
  _IsEncrypted: Boolean; _PasswordExt: string);
begin
  IsEncrypted := _IsEncrypted;
  PasswordExt := _PasswordExt;
end;

procedure TNetworkRestoreFolderSearchHandle.SetIsDeleted(_IsDeleted: Boolean);
begin
  IsDeleted := _IsDeleted;
end;

procedure TNetworkRestoreFolderSearchHandle.SetRestorePath(_RestorePath: string);
begin
  RestorePath := _RestorePath;
end;

{ TShareDownSocketInfo }

procedure TRestoreDownSocketInfo.CloseSocket;
begin
    // 关闭端口
  try
    MySocketUtil.SendData( TcpSocket, FileReq_End );
    TcpSocket.Free;
    TcpSocket := nil;
  except
  end;
end;

constructor TRestoreDownSocketInfo.Create(_RestoreFromPcID: string);
begin
  RestoreFromPcID := _RestoreFromPcID;
  LastTime := Now;
end;

procedure TRestoreDownSocketInfo.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

{ TMyShareDownConnectHandler }

procedure TMyRestoreDownConnectHandler.AddBackConn(TcpSocket: TCustomIpClient);
begin
  BackConnSocket := TcpSocket;
  IsConnSuccess := True;
end;

procedure TMyRestoreDownConnectHandler.AddLastConn(LastRestoreFrom : string;
  TcpSocket: TCustomIpClient);
var
  ShareDownSocketInfo : TRestoreDownSocketInfo;
  LastRestoreFromPcID : string;
begin
  if not Assigned( TcpSocket ) then
    Exit;

    // 连接已断开
  if not TcpSocket.Connected then
  begin
    TcpSocket.Free;
    Exit;
  end;

    // 结束这一次请求
  MySocketUtil.SendData( TcpSocket, FileReq_End );

    // 返回连接池
  ConnectLock.Enter;
  try
      // 最大保存连接数为 10
    if RestoreDownSocketList.Count >= 10 then
    begin
      RestoreDownSocketList[0].CloseSocket;
      RestoreDownSocketList.Delete( 0 );
    end;
    LastRestoreFromPcID := NetworkDesItemUtil.getPcID( LastRestoreFrom );
    ShareDownSocketInfo := TRestoreDownSocketInfo.Create( LastRestoreFromPcID );
    ShareDownSocketInfo.SetTcpSocket( TcpSocket );
    RestoreDownSocketList.Add( ShareDownSocketInfo );
  except
  end;
  ConnectLock.Leave;
end;

procedure TMyRestoreDownConnectHandler.BackConnBusy;
begin
  IsConnBusy := True;
end;

procedure TMyRestoreDownConnectHandler.BackConnError;
begin
  IsConnError := True;
end;

constructor TMyRestoreDownConnectHandler.Create;
begin
  ConnectLock := TCriticalSection.Create;
  RestoreDownSocketList := TRestoreDownSocketList.Create;
end;

destructor TMyRestoreDownConnectHandler.Destroy;
begin
  RestoreDownSocketList.Free;
  ConnectLock.Free;
  inherited;
end;

function TMyRestoreDownConnectHandler.getBackConnect: TCustomIpClient;
begin
    // 等待结果
  WaitBackConn;

    // 返回结果
  if IsConnSuccess then
    Result := BackConnSocket
  else
    Result := nil;
end;

function TMyRestoreDownConnectHandler.getConnect: TCustomIpClient;
var
  TcpSocket : TCustomIpClient;
  MyTcpConn : TMyTcpConn;
  DesPcIP, DesPcPort : string;
  IsConnected, IsDesBusy : Boolean;
begin
  Result := nil;

    // 连接已存在
  TcpSocket := getLastConnect;
  if Assigned( TcpSocket ) then
  begin
    Result := TcpSocket;
    Exit;
  end;

    // 提取 Pc 信息
  DesPcIP := MyNetPcInfoReadUtil.ReadIp( RestoreFromPcID );
  DesPcPort := MyNetPcInfoReadUtil.ReadPort( RestoreFromPcID );

    // Pc 离线
  if not MyNetPcInfoReadUtil.ReadIsOnline( RestoreFromPcID ) then
    Exit;

    // 无法连接
  if not MyNetPcInfoReadUtil.ReadIsCanConnectTo( RestoreFromPcID ) then
  begin
    Result := getBackConnect; // 使用反向连接
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
    NetworkPcApi.SetCanConnectTo( RestoreFromPcID, False );  // 设置无法连接
    Result := getBackConnect;
    Exit;
  end;

    // 是否接收繁忙
  IsDesBusy := StrToBoolDef( MySocketUtil.RevJsonStr( TcpSocket ), True );
  if IsDesBusy then
  begin
    TcpSocket.Free;
    HandleBusy;
    Exit;
  end;

  Result := TcpSocket;
end;

function TMyRestoreDownConnectHandler.getIsHandlerRun: Boolean;
begin
  if RestoreConn = RestoreConnect_Down then
    Result := MyRestoreHandler.getIsRun
  else
  if RestoreConn = RestoreConnect_Explorer then
    Result :=MyRestoreExplorerHandler.IsRun
  else
  if RestoreConn = RestoreConnect_Search then
    Result := MyRestoreSearchHandler.getIsRun
//  else
//  if ShareConn = ShareConnect_Preview then
//    Result :=MySharePreviewHandler.IsRun
  else
    Result := True;
end;

function TMyRestoreDownConnectHandler.getLastConnect: TCustomIpClient;
var
  i: Integer;
  ShareDownSocketInfo : TRestoreDownSocketInfo;
  LastSocket : TCustomIpClient;
  FileReq : string;
begin
  Result := nil;

    // 寻找上次端口
  LastSocket := nil;
  for i := 0 to RestoreDownSocketList.Count - 1 do
  begin
    ShareDownSocketInfo := RestoreDownSocketList[i];
    if ShareDownSocketInfo.RestoreFromPcID = RestoreFromPcID then
    begin
      LastSocket := ShareDownSocketInfo.TcpSocket;
      RestoreDownSocketList.Delete( i );
      Break;
    end;
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

function TMyRestoreDownConnectHandler.getRestoreConn(_RestorePath,
  _OwnerID,_RestoreFrom, _RestoreConn: string ): TCustomIpClient;
var
  CloudPath : string;
begin
  ConnectLock.Enter;

  RestorePath := _RestorePath;
  OwnerID := _OwnerID;
  RestoreFrom := _RestoreFrom;
  RestoreConn := _RestoreConn;
  RestoreFromPcID := NetworkDesItemUtil.getPcID( RestoreFrom );

    // 获取连接
  try
    Result := getConnect;

      // 发送初始化信息
    if Assigned( Result ) then
    begin
      CloudPath := NetworkDesItemUtil.getCloudPath( RestoreFrom );
      MySocketUtil.SendJsonStr( Result, JsonMsgType_CloudPath, CloudPath );
      MySocketUtil.SendJsonStr( Result, JsonMsgType_PcID_Cloud, OwnerID );
      MySocketUtil.SendJsonStr( Result, JsonMsgType_SourcePath, RestorePath );
    end;

  except
    Result := nil;
  end;

  ConnectLock.Leave;
end;

procedure TMyRestoreDownConnectHandler.HandleBusy;
var
  IsRecycle : Boolean;
begin
  if RestoreConn = RestoreConnect_Down then
    RestoreDownAppApi.SetIsDesBusy( RestorePath, OwnerID, RestoreFrom, True )
  else
  if RestoreConn = RestoreConnect_Explorer then
  begin
    if RestoreDownInfoReadUtil.ReadIsDeleted( RestorePath, OwnerID, RestoreFrom ) then
      RestoreDeleteExplorerAppApi.CloudPcBusy
    else
      RestoreExplorerAppApi.CloudPcBusy;
  end
  else
  if RestoreConn = RestoreConnect_Search then
    RestoreSearchAppApi.CloudPcBusy
  else
  if RestoreConn = RestoreConnect_Preview then
    RestorePreviewAppApi.CloudPcBusy;
end;

procedure TMyRestoreDownConnectHandler.HandleNotConn;
begin
  if RestoreConn = RestoreConnect_Down then
    RestoreDownAppApi.SetIsConnected( RestorePath, OwnerID, RestoreFrom, False )
  else
  if RestoreConn = RestoreConnect_Explorer then
  begin
    if RestoreDownInfoReadUtil.ReadIsDeleted( RestorePath, OwnerID, RestoreFrom ) then
      RestoreDeleteExplorerAppApi.CloudPcNotConn
    else
      RestoreExplorerAppApi.CloudPcNotConn;
  end
  else
  if RestoreConn = RestoreConnect_Search then
    RestoreSearchAppApi.CloudPcNotConn
  else
  if RestoreConn = RestoreConnect_Preview then
    RestorePreviewAppApi.CloudPcNotConn;
end;

procedure TMyRestoreDownConnectHandler.LastConnRefresh;
var
  i: Integer;
begin
  ConnectLock.Enter;
  try
    for i := RestoreDownSocketList.Count - 1 downto 0 do
    begin
        // 超过三分钟，删除
      if MinutesBetween( Now, RestoreDownSocketList[i].LastTime ) >= 3 then
      begin
          // 关闭端口
        RestoreDownSocketList[i].CloseSocket;
          // 删除
        RestoreDownSocketList.Delete( i );
        Continue;
      end;
        // 发送心跳
      MySocketUtil.SendData( RestoreDownSocketList[i].TcpSocket, FileReq_HeartBeat );
    end;
  except
  end;
  ConnectLock.Leave;
end;

procedure TMyRestoreDownConnectHandler.StopRun;
var
  i: Integer;
begin
  ConnectLock.Enter;
  try
    for i := 0 to RestoreDownSocketList.Count - 1 do
      RestoreDownSocketList[i].CloseSocket;
  except
  end;
  ConnectLock.Leave;
end;

procedure TMyRestoreDownConnectHandler.WaitBackConn;
var
  StartTime : TDateTime;
begin
  DebugLock.Debug( 'BackConnHandle' );

    // 对方无法连接本机
  if not MyNetPcInfoReadUtil.ReadIsCanConnectFrom( RestoreFromPcID ) then
  begin
    HandleNotConn;
    Exit;
  end;

    // 初始化结果信息
  IsConnSuccess := False;
  IsConnError := False;
  IsConnBusy := False;

    // 发送请求
  RestoreDownBackConnEvent.AddDown( RestoreFromPcID );

    // 等待接收方连接
  StartTime := Now;
  while getIsHandlerRun and ( MinutesBetween( Now, StartTime ) < 1 ) and
        not IsConnBusy and not IsConnError and not IsConnSuccess
  do
    Sleep(100);

    // 目标 Pc 繁忙
  if IsConnBusy then
  begin
    HandleBusy;
    Exit;
  end;

    // 无法连接
  if IsConnError then
  begin
    NetworkPcApi.SetCanConnectFrom( RestoreFromPcID, False ); // 设置对方无法连接
    HandleNotConn;
    Exit;
  end;
end;


{ TLocalRestoreFolderScanHandle }

procedure TLocalRestoreFolderCompareHandler.FindSourceFileInfo;
var
  RestoreFolderPath : string;
  LocalFolderAdvanceFindHandle : TLocalFolderFilterFindHandle;
begin
    // 已读取
  if IsDesReaded then
    Exit;

    // 恢复目录路径
  if IsDeleted then
    RestoreFolderPath := MyFilePath.getLocalRecyclePath( RestoreFrom, SourceFolderPath )
  else
    RestoreFolderPath := MyFilePath.getLocalBackupPath( RestoreFrom, SourceFolderPath );

    // 过滤搜索
  LocalFolderAdvanceFindHandle := TLocalFolderFilterFindHandle.Create;
  LocalFolderAdvanceFindHandle.SetFolderPath( RestoreFolderPath );
  LocalFolderAdvanceFindHandle.SetSleepCount( SleepCount );
  LocalFolderAdvanceFindHandle.SetScanFile( SourceFileHash );
  LocalFolderAdvanceFindHandle.SetScanFolder( SourceFolderHash );
  LocalFolderAdvanceFindHandle.SetDeepInfo( 0, DeepCount_Max );
  LocalFolderAdvanceFindHandle.SetEncryptedInfo( IsEncrypted, PasswordExt );
  LocalFolderAdvanceFindHandle.SetEditionInfo( IsDeleted, FileEditionHash );
  LocalFolderAdvanceFindHandle.Update;
  SleepCount := LocalFolderAdvanceFindHandle.SleepCount;
  LocalFolderAdvanceFindHandle.Free;
end;

function TLocalRestoreFolderCompareHandler.getScanHandle(
  SourceFolderName: string): TFolderCompareHandler;
var
  LocalRestoreFolderScanHandle : TLocalRestoreFolderCompareHandler;
  ChildFolderInfo : TScanFolderInfo;
begin
  LocalRestoreFolderScanHandle := TLocalRestoreFolderCompareHandler.Create;
  LocalRestoreFolderScanHandle.SetParams( Params );
  Result := LocalRestoreFolderScanHandle;

   // 不存在子目录
  if not SourceFolderHash.ContainsKey( SourceFolderName ) then
    Exit;

    // 添加子目录信息
  ChildFolderInfo := SourceFolderHash[ SourceFolderName ];
  LocalRestoreFolderScanHandle.SetIsDesReaded( ChildFolderInfo.IsReaded );

    // 子目录未读取
  if not ChildFolderInfo.IsReaded then
    Exit;

    // 子目录信息
  LocalRestoreFolderScanHandle.SourceFolderHash.Free;
  LocalRestoreFolderScanHandle.SourceFolderHash := ChildFolderInfo.ScanFolderHash;
  ChildFolderInfo.ScanFolderHash := TScanFolderHash.Create;

    // 子文件信息
  LocalRestoreFolderScanHandle.SourceFileHash.Free;
  LocalRestoreFolderScanHandle.SourceFileHash := ChildFolderInfo.ScanFileHash;
  ChildFolderInfo.ScanFileHash := TScanFileHash.Create;
end;

procedure TLocalRestoreFolderCompareHandler.SetParams(_Params: TRestoreParamsData);
begin
  inherited;

  FileEditionHash := Params.FileEditionHash;
end;

{ TLocalRestoreFileScanHandle }

function TLocalRestoreFileCompareHandler.FindSourceFileInfo: Boolean;
var
  LocalRestoreFilePath : string;
  LocalFileFindHandle : TLocalFileFindHandle;
begin
    // 是否回收路径
  if IsDeleted then
    LocalRestoreFilePath := MyFilePath.getLocalRecyclePath( RestoreFrom, RestoreFilePath )
  else
    LocalRestoreFilePath := MyFilePath.getLocalBackupPath( RestoreFrom, RestoreFilePath );

  LocalFileFindHandle := TLocalFileFindHandle.Create;
  LocalFileFindHandle.SetFilePath( LocalRestoreFilePath );
  LocalFileFindHandle.Update;
  Result := LocalFileFindHandle.getIsExist;
  SourceFileSize := LocalFileFindHandle.getFileSize;
  SourceFileTime := LocalFileFindHandle.getFileTime;
  LocalFileFindHandle.Free;
end;

procedure TLocalRestoreFileCompareHandler.SetParams(Params: TRestoreParamsData);
begin
  inherited;

  RestoreFrom := Params.RestoreFrom;
end;

{ TRestoreFileHandle }

procedure TFileRestoreHandler.IniHandle;
begin

end;

procedure TFileRestoreHandler.LastCompleted;
begin

end;

procedure TFileRestoreHandler.SetParams(_Params: TRestoreParamsData);
begin
  Params := _Params;
end;

{ TLocalRestoreFileHandle }

constructor TLocalFileRestoreHandler.Create;
begin
  inherited;
  RestorePackageHandler := TRestorePackageHandler.Create;
end;

destructor TLocalFileRestoreHandler.Destroy;
begin
  RestorePackageHandler.Free;
  inherited;
end;

procedure TLocalFileRestoreHandler.Handle(ScanResultInfo: TScanResultInfo);
begin
    // 是否进行文件压缩
  if not IsFile then
    ScanResultInfo := RestorePackageHandler.AddZipFile( ScanResultInfo );

    // 本地压缩文件，跳过这个 Job
  if ScanResultInfo = nil then
    Exit;

    // 立刻处理
  HandleNow( ScanResultInfo );
end;

procedure TLocalFileRestoreHandler.HandleNow(ScanResultInfo: TScanResultInfo);
var
  RestoreResultHandle : TLocalRestoreResultHandler;
begin
  RestoreResultHandle := TLocalRestoreResultHandler.Create;
  RestoreResultHandle.SetScanResultInfo( ScanResultInfo );
  RestoreResultHandle.SetParams( Params );
  RestoreResultHandle.Update;
  RestoreResultHandle.Free;
end;

procedure TLocalFileRestoreHandler.LastCompleted;
var
  ScanResultInfo : TScanResultInfo;
begin
    // 发送最后的压缩文件
  ScanResultInfo := RestorePackageHandler.getLastSendFile;
  if Assigned( ScanResultInfo ) then
    HandleNow( ScanResultInfo );
end;

procedure TLocalFileRestoreHandler.SetParams(_Params: TRestoreParamsData);
begin
  inherited;
  IsFile := Params.IsFile;
  RestorePackageHandler.SetParams( Params );
end;

{ TShareDownThread }

procedure TRestoreDownThread.AddScanResultInfo(_ScanResultInfo: TScanResultInfo);
begin
  ScanResultInfo := _ScanResultInfo;
  IsRun := True;
end;

constructor TRestoreDownThread.Create;
begin
  inherited Create;
  SocketLock := TCriticalSection.Create;
  IsRun := False;
  IsLostConn := False;
end;

destructor TRestoreDownThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;
  SocketLock.Free;
  inherited;
end;

procedure TRestoreDownThread.Execute;
begin
  while not Terminated and not IsLostConn do
  begin
    WaitToDown;
    if Terminated or not IsRun then
      Break;
    DownloadFile;
    if not IsLostConn then
      IsRun := False;
  end;

    // 回收端口
  MyRestoreDownConnectHandler.AddLastConn( RestoreFrom, TcpSocket );
end;

procedure TRestoreDownThread.getErrorList(ErrorList: TStringList);
var
  ErrorStr : string;
  StrList : TStringList;
  i: Integer;
begin
    // 请求错误列表
  MySocketUtil.SendData( TcpSocket, FileReq_ReadZipError );
  ErrorStr := MySocketUtil.RevData( TcpSocket );

    // 添加到统计中
  StrList := MySplitStr.getList( ErrorStr, ZipErrorSplit_File );
  for i := 0 to StrList.Count - 1 do
    ErrorList.Add( StrList[i] );
  StrList.Free;
end;

procedure TRestoreDownThread.DownloadFile;
var
  NetworkRestoreResultHandle : TNetworkRestoreResultHandle;
begin
  NetworkRestoreResultHandle := TNetworkRestoreResultHandle.Create;
  NetworkRestoreResultHandle.SetTcpSocket( TcpSocket );
  NetworkRestoreResultHandle.SetParams( Params );
  NetworkRestoreResultHandle.SetScanResultInfo(  ScanResultInfo );
  NetworkRestoreResultHandle.Update;
  NetworkRestoreResultHandle.Free;

  IsLostConn := not TcpSocket.Connected;
end;

procedure TRestoreDownThread.SendZip(FilePath: string);
begin
  SocketLock.Enter;
  MySocketUtil.SendData( TcpSocket, FileReq_ZipFile );
  MySocketUtil.SendData( TcpSocket, FilePath );
  MySocketUtil.SendData( TcpSocket, IsDeleted );
  SocketLock.Leave;
end;

procedure TRestoreDownThread.SetParams(_Params: TRestoreParamsData);
begin
  Params := _Params;
  RestoreFrom := Params.RestoreFrom;
  IsDeleted := Params.IsDeleted;
end;

procedure TRestoreDownThread.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TRestoreDownThread.WaitToDown;
var
  StartTime : TDateTime;
begin
  StartTime := Now;
  while not IsRun and not IsLostConn and not Terminated and MyRestoreHandler.getIsRun do
  begin
    Sleep( 100 );
    if SecondsBetween( Now, StartTime ) < 10 then  // 10 秒发送一次心跳
      Continue;

    SocketLock.Enter;
    if not MySocketUtil.SendData( TcpSocket, FileReq_HeartBeat ) then  // 对方已断开连接
    begin
      TcpSocket.Disconnect;
      IsLostConn := True;
    end;
    SocketLock.Leave;

    StartTime := Now;
  end;
end;

{ TNetworkRestoreDownFileHandle }

procedure TNetworkFileRestoreHandler.CheckHeartBeat;
begin
  if SecondsBetween( Now, HeartTime ) < 10 then
    Exit;

  MySocketUtil.SendData( TcpSocket, FileReq_HeartBeat );

  HeartTime := Now;
end;

constructor TNetworkFileRestoreHandler.Create;
begin
  ShareDownThreadList := TRestoreDownThreadList.Create;
  ZipThreadIndex := -1;
  ZipCount := 0;
  ZipSize := 0;
  HeartTime := Now;
end;

destructor TNetworkFileRestoreHandler.Destroy;
begin
  ShareDownThreadList.Free;
  inherited;
end;

procedure TNetworkFileRestoreHandler.DownloadFile(
  ScanResultInfo: TScanResultInfo);
var
  IsFindThread : Boolean;
  i : Integer;
begin
    // 寻找空闲的线程
  IsFindThread := False;
  for i := 0 to ShareDownThreadList.Count - 1 do
    if not ShareDownThreadList[i].IsRun and not ShareDownThreadList[i].IsLostConn and
       ( i <> ZipThreadIndex )
    then
    begin
      ShareDownThreadList[i].AddScanResultInfo( ScanResultInfo );
      IsFindThread := True;
      Break;
    end;

    // 没有找到线程，当前线程处理
  if not IsFindThread then
    HandleNow( ScanResultInfo );
end;


procedure TNetworkFileRestoreHandler.DownloadZip;
var
  TempPath : string;
  ScanResultGetZipInfo : TScanResultGetZipInfo;
begin
    // 没有压缩
  if ZipThreadIndex = -1 then
    Exit;

    // 下载压缩文件
  TempPath := MyFilePath.getPath( RestorePath ) + Name_TempRestoreDownZip;
  ScanResultGetZipInfo := TScanResultGetZipInfo.Create( TempPath );
  ScanResultGetZipInfo.SetTotalSize( ZipSize );
  ShareDownThreadList[ ZipThreadIndex ].AddScanResultInfo( ScanResultGetZipInfo );

  ZipThreadIndex := -1;
  ZipCount := 0;
  ZipSize := 0;
end;

procedure TNetworkFileRestoreHandler.DownZipNow;
var
  TempPath : string;
  ScanResultGetZipInfo : TScanResultGetZipInfo;
begin
    // 没有压缩文件
  if ZipCount = 0 then
    Exit;

    // 下载压缩文件
  TempPath := MyFilePath.getPath( RestorePath ) + Name_TempRestoreDownZip;
  ScanResultGetZipInfo := TScanResultGetZipInfo.Create( TempPath );
  ScanResultGetZipInfo.SetTotalSize( ZipSize );
  HandleNow( ScanResultGetZipInfo );

  ZipCount := 0;
  ZipSize := 0;
end;

function TNetworkFileRestoreHandler.FindZipThread: Boolean;
var
  IsFindThread, IsExistConnectedThread : Boolean;
  i: Integer;
begin
  Result := True;

    // 已存在
  if ZipThreadIndex <> -1 then
    Exit;

    // 还没有指定压缩线程，则寻找
  while MyRestoreHandler.getIsRun do
  begin
    IsExistConnectedThread := False;
    IsFindThread := False;
    for i := 0 to ShareDownThreadList.Count - 1 do
    begin
      IsExistConnectedThread := IsExistConnectedThread or not ShareDownThreadList[i].IsLostConn;
      if not ShareDownThreadList[i].IsRun then
      begin
        IsFindThread := True;
        ZipThreadIndex := i;
        Break;
      end;
    end;

      // 已经找到线程
    if IsFindThread then
      Break;

      // 所有线程都断开了连接
    if not IsExistConnectedThread then
    begin
      Result := False;
      Break;
    end;

      // 没有找到，则再次寻找
    Sleep( 100 );

    CheckHeartBeat; // 定时心跳
  end;
end;

function TNetworkFileRestoreHandler.getNewConnect: TCustomIpClient;
var
  NewTcpSocket : TCustomIpClient;
  ShareConnResult : string;
begin
  Result := nil;

  NewTcpSocket := MyRestoreDownConnectHandler.getRestoreConn( RestorePath, OwnerID, RestoreFrom, RestoreConnect_Down );
  if not Assigned( NewTcpSocket ) then
    Exit;

    // 读取访问结果
  ShareConnResult := MySocketUtil.RevData( NewTcpSocket );

    // 访问失败
  if ShareConnResult <> CloudConnResult_OK then
    Exit;

  Result := NewTcpSocket;
end;

procedure TNetworkFileRestoreHandler.Handle(ScanResultInfo: TScanResultInfo);
var
  ScanResultAddFileInfo : TScanResultAddFileInfo;
  FileSize : Int64;
begin
      // 不是下载文件，当前线程处理
  if not ( ScanResultInfo is TScanResultAddFileInfo ) then
  begin
    HandleNow( ScanResultInfo );
    Exit;
  end;

    // 发送文件的情况
  ScanResultAddFileInfo := ScanResultInfo as TScanResultAddFileInfo;
  FileSize := ScanResultAddFileInfo.FileSize;

    // 直接下载或者压缩文件
  if IsFile or ( FileSize = 0 ) or ( FileSize > 128 * Size_KB ) then
    DownloadFile( ScanResultInfo )
  else
    ZipFile( ScanResultInfo );

    // 定时发送心跳
  CheckHeartBeat;
end;

procedure TNetworkFileRestoreHandler.HandleNow(
  ScanResultInfo: TScanResultInfo);
var
  NetworkRestoreResultHandle : TNetworkRestoreResultHandle;
begin
  NetworkRestoreResultHandle := TNetworkRestoreResultHandle.Create;
  NetworkRestoreResultHandle.SetTcpSocket( TcpSocket );
  NetworkRestoreResultHandle.SetParams( Params );
  NetworkRestoreResultHandle.SetScanResultInfo(  ScanResultInfo );
  NetworkRestoreResultHandle.Update;
  NetworkRestoreResultHandle.Free;
end;

procedure TNetworkFileRestoreHandler.HandleZipError;
var
  ZipErrorList : TStringList;
  i: Integer;
  ScanResultInfo : TScanResultInfo;
begin
  ZipErrorList := TStringList.Create;

    // 获取所有线程的压缩错误
  for i := 0 to ShareDownThreadList.Count - 1 do
    ShareDownThreadList[i].getErrorList( ZipErrorList );

    // 处理压缩错误
  for i := 0 to ZipErrorList.Count - 1 do
  begin
    ScanResultInfo := TScanResultAddFileInfo.Create( ZipErrorList[i] );
    HandleNow( ScanResultInfo );
    ScanResultInfo.Free;
  end;

  ZipErrorList.Free;
end;

procedure TNetworkFileRestoreHandler.IniHandle;
var
  DesPcID : string;
  i: Integer;
  NewDownFileThread : TRestoreDownThread;
  NewTcpSocket : TCustomIpClient;
begin
  IsExistThread := False;

    // 文件 不创建线程
  if IsFile then
    Exit;

    // 互联网 Pc, 不创建多线程
  DesPcID := NetworkDesItemUtil.getPcID( RestoreFrom );
  if not MyNetPcInfoReadUtil.ReadIsLanPc( DesPcID ) then
    Exit;

    // 多线程下载
  for i := 1 to 3 do
  begin
    NewTcpSocket := getNewConnect;
    if not Assigned( NewTcpSocket ) then
      Continue;
    NewDownFileThread := TRestoreDownThread.Create;
    NewDownFileThread.SetParams( Params );
    NewDownFileThread.SetTcpSocket( NewTcpSocket );
    NewDownFileThread.Resume;
    ShareDownThreadList.Add( NewDownFileThread );
  end;

    // 创建多线程成功
  IsExistThread := ShareDownThreadList.Count > 0;
end;

procedure TNetworkFileRestoreHandler.LastCompleted;
var
  IsFind : Boolean;
  i : Integer;
begin
    // 下载最后的 Zip
  if IsExistThread then
    DownloadZip
  else
    DownZipNow;

    // 等待线程结束
  while MyRestoreHandler.getIsRun do
  begin
    IsFind := False;
    for i := 0 to ShareDownThreadList.Count - 1 do
      if ShareDownThreadList[i].IsRun and not ShareDownThreadList[i].IsLostConn then
      begin
        IsFind := True;
        Break;
      end;
    if not IsFind then
      Break;
    Sleep( 100 );
    CheckHeartBeat;
  end;

    // 处理 Zip Error
  HandleZipError;
end;

procedure TNetworkFileRestoreHandler.SetParams(_Params: TRestoreParamsData);
var
  NetworkRestoreParamsData : TNetworkRestoreParamsData;
begin
  inherited;

  RestorePath := Params.RestorePath;
  OwnerID := Params.OwnerID;
  RestoreFrom := Params.RestoreFrom;
  IsFile := Params.IsFile;
  IsDeleted := Params.IsDeleted;

  NetworkRestoreParamsData := Params as TNetworkRestoreParamsData;
  TcpSocket := NetworkRestoreParamsData.TcpSocket;
end;

procedure TNetworkFileRestoreHandler.ZipFile(ScanResultInfo: TScanResultInfo);
var
  ScanResultAddFileInfo : TScanResultAddFileInfo;
  FilePath : string;
begin
  FilePath := ScanResultInfo.SourceFilePath;

    // 存在其他线程
  if IsExistThread then
  begin
    if not FindZipThread then  // 还没有指定压缩线程，则寻找
    begin
      IsExistThread := False; // 所有线程都断开了连接
      ZipFile( ScanResultInfo ); // 进入单线程模式
      Exit;
    end;
    ShareDownThreadList[ ZipThreadIndex ].SendZip( FilePath ); // 发送压缩命令
  end
  else
  begin  // 当前线程处理
    MySocketUtil.SendData( TcpSocket, FileReq_ZipFile );
    MySocketUtil.SendData( TcpSocket, FilePath );
    MySocketUtil.SendData( TcpSocket, IsDeleted );
  end;

    // 压缩信息
  ScanResultAddFileInfo := ScanResultInfo as TScanResultAddFileInfo;
  ZipSize := ZipSize + ScanResultAddFileInfo.FileSize;
  ZipCount := ZipCount + 1;

    // 未达到伐值
  if ( ZipCount < 1000 ) and ( ZipSize < 10 * Size_MB ) then
    Exit;

    // 下载压缩文件
  if IsExistThread then
    DownloadZip
  else
    DownZipNow;
end;

{ TRestoreCancelReader }

constructor TRestoreCancelReader.Create;
begin
  LastReadTime := Now;
end;

function TRestoreCancelReader.getIsRun: Boolean;
begin
  Result := MyRestoreHandler.getIsRun;
  if SecondsBetween( Now, LastReadTime ) >= 1 then  // 检测 BackupItem 删除
  begin
    Result := Result and RestoreDownInfoReadUtil.ReadIsEnable( RestorePath, OwnerID, RestoreFrom );
    if Result then
      LastReadTime := Now;
  end;
end;

procedure TRestoreCancelReader.SetParams(Params: TRestoreParamsData);
begin
  RestorePath := Params.RestorePath;
  OwnerID := Params.OwnerID;
  RestoreFrom := Params.RestoreFrom;
end;

{ TRestoreFileConfirmHandle }

constructor TRestoreFileConfirmHandle.Create(_ScanResultList: TScanResultList);
begin
  ScanResultList := _ScanResultList;
  RestoreConfirmList := TRestoreConfirmList.Create;
  CancelSize := 0;
  CancelCount := 0;
end;

destructor TRestoreFileConfirmHandle.Destroy;
begin
  RestoreConfirmList.Free;
  inherited;
end;

function TRestoreFileConfirmHandle.FindCancelIndex(CancelPath: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to ScanResultList.Count - 1 do
  begin
    if not ( ScanResultList[i] is TScanResultRemoveFileInfo ) then
      Continue;
    if ScanResultList[i].SourceFilePath = CancelPath then
    begin
      Result := i;
      Break;
    end;
  end;
end;

procedure TRestoreFileConfirmHandle.FindConfirmList;
var
  i: Integer;
  ScanResultInfo : TScanResultInfo;
  AddResultInfo : TScanResultAddFileInfo;
  LocalPath, RestorePath : string;
  LocalSize, RestoreSize : Int64;
  LocalDate, RestoreDate : TDateTime;
  RestoreConFirmInfo : TRestoreConfirmInfo;
begin
  for i := 0 to ScanResultList.Count - 1 do
  begin
    ScanResultInfo := ScanResultList[i];
    if not ( ScanResultInfo is TScanResultRemoveFileInfo ) then
      Continue;
    if i >= ScanResultList.Count - 1 then
      Continue;
    if not ( ScanResultList[i + 1] is TScanResultAddFileInfo ) then
      Continue;
    AddResultInfo := ScanResultList[i + 1] as TScanResultAddFileInfo;

    LocalPath := ScanResultInfo.SourceFilePath;
    LocalSize := MyFileInfo.getFileSize( LocalPath );
    LocalDate := MyFileInfo.getFileLastWriteTime( LocalPath );
    RestorePath := AddResultInfo.SourceFilePath;
    RestoreSize := AddResultInfo.FileSize;
    RestoreDate := AddResultInfo.FileTime;

    RestoreConFirmInfo := TRestoreConFirmInfo.Create( LocalPath, RestorePath );
    RestoreConFirmInfo.SetSizeInfo( LocalSize, RestoreSize );
    RestoreConFirmInfo.SetDateInfo( LocalDate, RestoreDate );
    RestoreConfirmList.Add( RestoreConFirmInfo );
  end;
end;

function TRestoreFileConfirmHandle.getIsConfirm: Boolean;
begin
  Result := true;

    // 寻找需要确认的 Item
  FindConfirmList;

    // 没有冲突的文件
  if RestoreConfirmList.Count = 0 then
    Exit;

    // 等待用户确认
  Result := UserConfirm;
  if not Result then
    Exit;

    // 处理用户取消的确认
  HandleCancelList;
end;

procedure TRestoreFileConfirmHandle.HandleCancelList;
var
  i : Integer;
  CancelPath : string;
  CancelIndex: Integer;
begin
  for i := 0 to CancelList.Count - 1 do
  begin
    CancelPath := CancelList[i];
    CancelIndex := FindCancelIndex( CancelPath );
    if CancelIndex = -1 then
      Continue;
    if CancelIndex >= ScanResultList.Count - 1 then
      Continue;
    if not ( ScanResultList[CancelIndex + 1] is TScanResultAddFileInfo ) then
      Continue;
    CancelSize := CancelSize + ( ScanResultList[ CancelIndex + 1 ] as TScanResultAddFileInfo ).FileSize;
    Inc( CancelCount );
    ScanResultList.Delete( CancelIndex );
    ScanResultList.Delete( CancelIndex );
  end;
  CancelList.Free;
end;

function TRestoreFileConfirmHandle.UserConfirm: Boolean;
var
  UserConfirmActionHandle : TUserConfirmActionHandle;
begin
  UserConfirmActionHandle := TUserConfirmActionHandle.Create( RestoreConfirmList );
  Result := UserConfirmActionHandle.getIsConfirm;
  if Result then
    CancelList := UserConfirmActionHandle.getCancelList;
  UserConfirmActionHandle.Free;
end;

{ TRestoreConfirmInfo }

constructor TRestoreConfirmInfo.Create(_LocalPath, _RestorePath: string);
begin
  LocalPath := _LocalPath;
  RestorePath := _RestorePath;
end;

procedure TRestoreConfirmInfo.SetDateInfo(_LocalDate, _RestoreDate: TDateTime);
begin
  LocalDate := _LocalDate;
  RestoreDate := _RestoreDate;
end;

procedure TRestoreConfirmInfo.SetSizeInfo(_LocalSize, _RestoreSize: Int64);
begin
  LocalSize := _LocalSize;
  RestoreSize := _RestoreSize;
end;

{ TUserConfirmActionHandle }

constructor TUserConfirmActionHandle.Create(
  _RestoreConfirmList: TRestoreConfirmList);
begin
  RestoreConfirmList := _RestoreConfirmList;
end;

function TUserConfirmActionHandle.getCancelList: TStringList;
begin
  Result := CancelList;
end;

function TUserConfirmActionHandle.getIsConfirm: Boolean;
begin
  try
    MyRestoreHandler.RestoreHandleThread.Synchronize( FaceUpdate );
    Result := IsConfirm;
  except
    Result := False;
  end;
end;

procedure TUserConfirmActionHandle.ShowConfirm;
var
  i: Integer;
  RestoreConfirmInfo : TRestoreConfirmInfo;
  RestoreConfirmItemAdd : TRestoreConfirmItemAdd;
begin
  frmUserConfirm.ClearItems;
  for i := 0 to RestoreConfirmList.Count - 1 do
  begin
    RestoreConfirmInfo := RestoreConfirmList[i];
    RestoreConfirmItemAdd := TRestoreConfirmItemAdd.Create( RestoreConfirmInfo.LocalPath, RestoreConfirmInfo.RestorePath );
    RestoreConfirmItemAdd.SetSizeInfo( RestoreConfirmInfo.LocalSize, RestoreConfirmInfo.RestoreSize );
    RestoreConfirmItemAdd.SetDateInfo( RestoreConfirmInfo.LocalDate, RestoreConfirmInfo.RestoreDate );
    RestoreConfirmItemAdd.Update;
    RestoreConfirmItemAdd.Free;
  end;
end;

procedure TUserConfirmActionHandle.FaceUpdate;
begin
  ShowConfirm;
  IsConfirm := frmUserConfirm.getIsConfirm;
  if not IsConfirm then
    Exit;
  CancelList := frmUserConfirm.getCancelList;
end;

{ TRestoreRecieveFileOperator }

procedure TRestoreRecieveFileOperator.AddSpeedSpace(SendSize: Integer);
begin
    // 刷新总下载速度
  MyRefreshSpeedHandler.AddDownload( SendSize );

    // 刷新速度
  if SpeedReader.AddCompleted( SendSize ) then
  begin
        // 设置 刷新备份速度
    RestoreDownAppApi.SetSpeed( RestorePath, OwnerID, RestoreFrom, SpeedReader.ReadLastSpeed );
  end;
end;

procedure TRestoreRecieveFileOperator.LostConnectError;
var
  Params : TRestoreDownErrorAddParams;
begin
      // 显示发送失败信息
  Params.RestorePath := RestorePath;
  Params.OwnerPcID := OwnerID;
  Params.RestoreFrom := RestoreFrom;
  Params.FilePath := RestoreFilePath;
  Params.FileSize := ReadFileSize;
  Params.CompletedSize := ReadFilePos;
  RestoreDownErrorApi.LostConnectFileError( Params );

    // 设置无法连接，定时重连
  RestoreDownAppApi.SetIsLostConn( RestorePath, OwnerID, RestoreFrom, True );
end;

procedure TRestoreRecieveFileOperator.MarkContinusSend;
var
  Params : TRestoreDownContinusAddParams;
begin
    // 已经取消恢复
  if not RestoreDownInfoReadUtil.ReadIsEnable( RestorePath, OwnerID, RestoreFrom )  then
    Exit;

  Params.RestorePath := RestorePath;
  Params.OwnerPcID := OwnerID;
  Params.RestoreFrom := RestoreFrom;
  Params.FilePath := RestoreFilePath;
  Params.FileSize := ReadFileSize;
  Params.FileTime := ReadFileTime;
  RestoreDownContinusApi.AddItem( Params );
end;

procedure TRestoreRecieveFileOperator.ReadFileError;
var
  Params : TRestoreDownErrorAddParams;
begin
      // 显示发送失败信息
  Params.RestorePath := RestorePath;
  Params.OwnerPcID := OwnerID;
  Params.RestoreFrom := RestoreFrom;
  Params.FilePath := RestoreFilePath;
  Params.FileSize := ReadFileSize;
  Params.CompletedSize := ReadFilePos;
  RestoreDownErrorApi.ReadFileError( Params );
end;

function TRestoreRecieveFileOperator.ReadIsNextReceive: Boolean;
begin
  Result := inherited and RestoreCancelReader.getIsRun;
end;

procedure TRestoreRecieveFileOperator.RefreshCompletedSpace;
var
  LastCompletedSpace : Int64;
begin
  LastCompletedSpace := ReadLastCompletedSize;
  RestoreDownAppApi.AddCompletedSpace( RestorePath, OwnerID, RestoreFrom, LastCompletedSpace );
end;

procedure TRestoreRecieveFileOperator.RevFileLackSpaceHandle;
begin
  RestoreDownAppApi.SetIsLackSpace( RestorePath, OwnerID, RestoreFrom, True );
end;

procedure TRestoreRecieveFileOperator.SetParams(Params: TRestoreParamsData);
begin
  RestorePath := Params.RestorePath;
  OwnerID := Params.OwnerID;
  RestoreFrom := Params.RestoreFrom;

  SpeedReader := Params.SpeedReader;
  RestoreCancelReader := Params.RestoreCancelReader;
end;

procedure TRestoreRecieveFileOperator.SetRestoreFilePath(
  _RestoreFilePath: string);
begin
  RestoreFilePath := _RestoreFilePath;
end;

procedure TRestoreRecieveFileOperator.TransferFileError;
var
  Params : TRestoreDownErrorAddParams;
begin
      // 显示发送失败信息
  Params.RestorePath := RestorePath;
  Params.OwnerPcID := OwnerID;
  Params.RestoreFrom := RestoreFrom;
  Params.FilePath := RestoreFilePath;
  Params.FileSize := ReadFileSize;
  Params.CompletedSize := ReadFilePos;
  RestoreDownErrorApi.ReceiveFileError( Params );

    // 设置无法连接，定时重连
  RestoreDownAppApi.SetIsLostConn( RestorePath, OwnerID, RestoreFrom, True );
end;

procedure TRestoreRecieveFileOperator.WriteFileError;
var
  Params : TRestoreDownErrorAddParams;
begin
      // 显示发送失败信息
  Params.RestorePath := RestorePath;
  Params.OwnerPcID := OwnerID;
  Params.RestoreFrom := RestoreFrom;
  Params.FilePath := RestoreFilePath;
  Params.FileSize := ReadFileSize;
  Params.CompletedSize := ReadFilePos;
  RestoreDownErrorApi.WriteFileError( Params );
end;

{ TLocalRestoreOpterator }

function TLocalRestoreOpterator.CreateContinuesHandler: TRestoreContinuesHandler;
begin
  Result := TLocalRestoreContinuesHandler.Create;
end;

function TLocalRestoreOpterator.CreateFileCompareHandler: TRestoreFileCompareHandler;
begin
  Result := TLocalRestoreFileCompareHandler.Create;
end;

function TLocalRestoreOpterator.CreateFileRestoreHandler: TFileRestoreHandler;
begin
  Result := TLocalFileRestoreHandler.Create;
end;

function TLocalRestoreOpterator.CreateFolderCompareHandler: TRestoreFolderCompareHandler;
var
  NewFileEdtionHash : TFileEditionHash;
  p : TFileEditionPair;
  FilePath : string;
  FileEditionInfo : TFileEditionInfo;
  LocalRestoreFolderScanHandle : TLocalRestoreFolderCompareHandler;
begin
    // 路径切换
  NewFileEdtionHash := TFileEditionHash.Create;
  for p in FileEditionHash do
  begin
    FilePath := MyFilePath.getLocalRecyclePath( RestoreFrom, p.Value.FilePath );
    FileEditionInfo := TFileEditionInfo.Create( FilePath, p.Value.EditionNum );
    NewFileEdtionHash.AddOrSetValue( FilePath, FileEditionInfo );
  end;
  FileEditionHash.Free;
  FileEditionHash := NewFileEdtionHash;
  Params.FileEditionHash := FileEditionHash;

  Result := TLocalRestoreFolderCompareHandler.Create;
end;

function TLocalRestoreOpterator.ReadRestoreFromIsAvailable: Boolean;
var
  RestoreDesPath : string;
begin
    // 备份目标路径是否存在
  if IsDeleted then
    RestoreDesPath := MyFilePath.getLocalRecyclePath( RestoreFrom, RestorePath )
  else
    RestoreDesPath := MyFilePath.getLocalBackupPath( RestoreFrom, RestorePath );

    // 加密的文件
  if IsFile then
    RestoreDesPath := MyFilePath.getAdvanceName( IsEncrypt, IsDeleted, RestoreDesPath, ExtPassword, EditionNum );

    // 是否存在路径
  Result := MyFilePath.getIsExist( RestoreDesPath );

    // 设置显示
  RestoreDownAppApi.SetIsExist( RestorePath, OwnerID, RestoreFrom, Result );
end;

{ TRestoreOpterator }

procedure TRestoreOpterator.SetParams(_Params: TRestoreParamsData);
begin
  Params := _Params;

  RestorePath := Params.RestorePath;
  OwnerID := Params.OwnerID;
  RestoreFrom := Params.RestoreFrom;
  IsFile := Params.IsFile;

  IsEncrypt := Params.IsEncrypt;
  Password := Params.Password;
  ExtPassword := Params.ExtPassword;

  IsDeleted := Params.IsDeleted;
  EditionNum := Params.EditionNum;
  FileEditionHash := Params.FileEditionHash;
end;

{ TNetworkRestoreOpterator }

function TNetworkRestoreOpterator.CreateContinuesHandler: TRestoreContinuesHandler;
begin
  Result := TNetworkRestoreContinuesHandler.Create;
end;

function TNetworkRestoreOpterator.CreateFileCompareHandler: TRestoreFileCompareHandler;
begin
  Result := TNetworkRestoreFileCompareHandler.Create;
end;

function TNetworkRestoreOpterator.CreateFileRestoreHandler: TFileRestoreHandler;
begin
  Result := TNetworkFileRestoreHandler.Create;
end;

function TNetworkRestoreOpterator.CreateFolderCompareHandler: TRestoreFolderCompareHandler;
begin
  MySocketUtil.SendData( TcpSocket, FileReq_EditionList );
  MySocketUtil.SendData( TcpSocket, FileEditionUtil.getStr( FileEditionHash ) );

  Result := TNetworkRestoreFolderCompareHandler.Create;
end;

function TNetworkRestoreOpterator.ReadRestoreFromIsAvailable: Boolean;
var
  CloudConnResult : string;
  IsRestoreExist : Boolean;
begin
    // 获取访问结果
  CloudConnResult := MySocketUtil.RevJsonStr( TcpSocket );

    // 设置 可以连接
  RestoreDownAppApi.SetIsConnected( RestorePath, OwnerID, RestoreFrom, True );

    // 设置 是否 存在云路径
  IsRestoreExist := CloudConnResult <> CloudConnResult_NotExist;
  RestoreDownAppApi.SetIsExist( RestorePath, OwnerID, RestoreFrom, IsRestoreExist );

    // 是否返回正常
  Result := CloudConnResult = CloudConnResult_OK;
end;

procedure TNetworkRestoreOpterator.SetParams(_Params: TRestoreParamsData);
var
  NetworkRestoreParamsData : TNetworkRestoreParamsData;
begin
  inherited;

  NetworkRestoreParamsData := Params as TNetworkRestoreParamsData;
  TcpSocket := NetworkRestoreParamsData.TcpSocket;
end;

{ TRestorePathHandle }

constructor TRestoreStartHandle.Create(_RestorePathInfo: TRestorePathInfo);
begin
  RestorePathInfo := _RestorePathInfo;
  RestorePath := RestorePathInfo.RestorePath;
  OwnerID := RestorePathInfo.OwnerID;
  RestoreFrom := RestorePathInfo.RestoreFrom;
  IsLocalRestore := RestorePathInfo is TLocalRestorePathInfo;
end;

procedure TRestoreStartHandle.CreateLocalRestoreData;
begin
  SpeedReader := TSpeedReader.Create;
  RestoreCancelReader := TRestoreCancelReader.Create;
  RestoreParamsData := TRestoreParamsData.Create;
  RestoreOperator := TLocalRestoreOpterator.Create;
end;

function TRestoreStartHandle.CreateNetworkRestoreData: Boolean;
var
  TcpSocket : TCustomIpClient;
begin
  Result := False;

    // 申请一个连接
  TcpSocket := MyRestoreDownConnectHandler.getRestoreConn( RestorePath, OwnerID, RestoreFrom, RestoreConnect_Down );
  if not Assigned( TcpSocket ) then
    Exit;

  SpeedReader := TSpeedReader.Create;
  RestoreCancelReader := TNetworkRestoreCancelReader.Create;
  RestoreParamsData := TNetworkRestoreParamsData.Create;
  ( RestoreParamsData as TNetworkRestoreParamsData ).TcpSocket := TcpSocket;
  ( RestoreParamsData as TNetworkRestoreParamsData ).HeartBeatTime := Now;
  RestoreOperator := TNetworkRestoreOpterator.Create;

  Result := True;
end;

function TRestoreStartHandle.CreateRestoreData: Boolean;
begin
  Result := True;
  if IsLocalRestore then
    CreateLocalRestoreData
  else
    Result := CreateNetworkRestoreData;

    // 创建失败
  if not Result then
    Exit;

    // 基本信息
  RestoreParamsData.RestorePath := RestorePath;
  RestoreParamsData.OwnerID := OwnerID;
  RestoreParamsData.RestoreFrom := RestoreFrom;
  RestoreParamsData.IsFile := RestoreDownInfoReadUtil.ReadIsFile( RestorePath, OwnerID, RestoreFrom );
  RestoreParamsData.SavePath := RestoreDownInfoReadUtil.ReadSavePath( RestorePath, OwnerID, RestoreFrom );

    // 加密信息
  RestoreParamsData.IsEncrypt := RestoreDownInfoReadUtil.ReadIsEncrypt( RestorePath, OwnerID, RestoreFrom );
  RestoreParamsData.Password := RestoreDownInfoReadUtil.ReadPassword( RestorePath, OwnerID, RestoreFrom );
  RestoreParamsData.ExtPassword := MyEncrypt.getPasswordExt( RestoreParamsData.Password );

    // 删除信息
  RestoreParamsData.IsDeleted := RestoreDownInfoReadUtil.ReadIsDeleted( RestorePath, OwnerID, RestoreFrom );
  RestoreParamsData.EditionNum := RestoreDownInfoReadUtil.ReadIsEditionNum( RestorePath, OwnerID, RestoreFrom );
  RestoreParamsData.FileEditionHash := RestoreDownInfoReadUtil.ReadFileEditionHash( RestorePath, OwnerID, RestoreFrom );

    // 设置工具
  RestoreParamsData.SpeedReader := SpeedReader;
  RestoreParamsData.RestoreCancelReader := RestoreCancelReader;

    // 互相绑定
  RestoreCancelReader.SetParams( RestoreParamsData );
  RestoreOperator.SetParams( RestoreParamsData );
end;

procedure TRestoreStartHandle.DestoryNetworkData;
var
  TcpSocket : TCustomIpClient;
begin
  TcpSocket := ( RestoreParamsData as TNetworkRestoreParamsData ).TcpSocket;

  MyRestoreDownConnectHandler.AddLastConn( RestoreFrom, TcpSocket );
end;

procedure TRestoreStartHandle.DestoryRestoreData;
begin
    // 删除网络数据
  if not IsLocalRestore then
    DestoryNetworkData;

  SpeedReader.Free;
  RestoreCancelReader.Free;
  RestoreParamsData.FileEditionHash.Free;
  RestoreParamsData.Free;
  RestoreOperator.Free;
end;

function TRestoreStartHandle.ReadIsRestoreEnable: Boolean;
begin
  Result := False;

    // 恢复路径出错
  if not ( RestorePathInfo is TLocalRestorePathInfo ) and
     not ( RestorePathInfo is TNetworkRestorePathInfo )
  then
    Exit;

  Result := RestoreDownInfoReadUtil.ReadIsEnable( RestorePath, OwnerID, RestoreFrom );
end;

procedure TRestoreStartHandle.RestoreHandle;
var
  RestoreProcessHandle : TRestoreProcessHandle;
begin
  RestoreProcessHandle := TRestoreProcessHandle.Create;
  RestoreProcessHandle.SetRestoreParamsData( RestoreParamsData );
  RestoreProcessHandle.SetRestoreOperator( RestoreOperator );
  RestoreProcessHandle.Update;
  RestoreProcessHandle.Free;
end;

procedure TRestoreStartHandle.Update;
begin
    // 检测 Restore Item 是否存在
  if not ReadIsRestoreEnable then
    Exit;

    // 创建数据结构
  if not CreateRestoreData then
    Exit;

    // 备份处理
  RestoreHandle;

    // 释放数据结构
  DestoryRestoreData;
end;

{ TNetworkRestoreCancelReader }

function TNetworkRestoreCancelReader.getIsRun: Boolean;
begin
  Result := inherited and TcpSocket.Connected;
end;

procedure TNetworkRestoreCancelReader.SetParams(Params: TRestoreParamsData);
var
  NetworkRestoreParamsData : TNetworkRestoreParamsData;
begin
  inherited;

  NetworkRestoreParamsData := Params as TNetworkRestoreParamsData;
  TcpSocket := NetworkRestoreParamsData.TcpSocket;
end;

{ TRestoreExplorerStartHandle }

constructor TRestoreExplorerStartHandle.Create(
  _RestoreExplorerInfo : TRestoreExplorerInfo);
begin
  RestoreExplorerInfo := _RestoreExplorerInfo;
  RestorePath := RestoreExplorerInfo.RestorePath;
  OwnerID := RestoreExplorerInfo.OwnerID;
  RestoreFrom := RestoreExplorerInfo.RestoreFrom;
  IsFile := RestoreExplorerInfo.IsFile;
  IsEncrypted := RestoreExplorerInfo.IsEncrypted;
  PasswordExt := RestoreExplorerInfo.PasswordExt;
  IsDeleted := RestoreExplorerInfo.IsDeleted;
  IsSearch := RestoreExplorerInfo.IsSearch;
  IsLocalRestore := RestoreExplorerInfo is TLocalRestoreExplorerInfo;
end;

procedure TRestoreExplorerStartHandle.CreateLocalRestoreData;
begin
  RestoreExplorerParamsData := TRestoreExplorerParamsData.Create;
  RestoreExplorerOperator := TLocalRestoreExplorerOperator.Create;
end;

function TRestoreExplorerStartHandle.CreateNetworkRestoreData: Boolean;
var
  TcpSocket : TCustomIpClient;
  CloudConnResult : string;
  IsSuccessConn : Boolean;
begin
  Result := False;

    // 获取一个连接
  TcpSocket := MyRestoreDownConnectHandler.getRestoreConn( RestorePath, OwnerID, RestoreFrom, RestoreConnect_Explorer );
  if not Assigned( TcpSocket ) then
    Exit;

    // 获取访问结果
  CloudConnResult := MySocketUtil.RevData( TcpSocket );

    // 是否连接成功
  IsSuccessConn := CloudConnResult = CloudConnResult_OK;

    // 连接失败
  if not IsSuccessConn then
  begin
    TcpSocket.Free;
    Exit;
  end;

    // 创建数据结构
  RestoreExplorerParamsData := TNetworkRestoreExplorerParamsData.Create;
  ( RestoreExplorerParamsData as TNetworkRestoreExplorerParamsData ).TcpSocket := TcpSocket;
  RestoreExplorerOperator := TNetworkRestoreExplorerOperator.Create;

  Result := True;
end;

function TRestoreExplorerStartHandle.CreateRestoreData: Boolean;
begin
  Result := True;
  if IsLocalRestore then
    CreateLocalRestoreData
  else
    Result := CreateNetworkRestoreData;

  if not Result then
    Exit;

    // 设置基本信息
  RestoreExplorerParamsData.RestorePath := RestorePath;
  RestoreExplorerParamsData.OwnerID := OwnerID;
  RestoreExplorerParamsData.RestoreFrom := RestoreFrom;
  RestoreExplorerParamsData.IsFile := IsFile;
  RestoreExplorerParamsData.IsEncrypted := IsEncrypted;
  RestoreExplorerParamsData.PasswordExt := PasswordExt;
  RestoreExplorerParamsData.IsDeleted := IsDeleted;
  RestoreExplorerParamsData.IsSearch := IsSearch;

    // 创建结果集
  RestoreExplorerParamsData.ScanFileHash := TScanFileHash.Create;
  RestoreExplorerParamsData.ScanFolderHash := TScanFolderHash.Create;

    // 放到 operator
  RestoreExplorerOperator.SetParams( RestoreExplorerParamsData );
end;

procedure TRestoreExplorerStartHandle.DestoryNetworkData;
var
  TcpSocket : TCustomIpClient;
begin
  TcpSocket := ( RestoreExplorerParamsData as TNetworkRestoreExplorerParamsData ).TcpSocket;

    // 返回列表
  MyRestoreDownConnectHandler.AddLastConn( RestoreFrom, TcpSocket );
end;

procedure TRestoreExplorerStartHandle.DestoryRestoreData;
begin
    // 删除网络信息
  if not IsLocalRestore then
    DestoryNetworkData;

  RestoreExplorerParamsData.ScanFileHash.Free;
  RestoreExplorerParamsData.ScanFolderHash.Free;
  RestoreExplorerParamsData.Free;
  RestoreExplorerOperator.Free;
end;

procedure TRestoreExplorerStartHandle.ExplorerHandle;
var
  RestoreExplorerProcessHandle : TRestoreExplorerProcessHandle;
begin
  RestoreExplorerProcessHandle := TRestoreExplorerProcessHandle.Create;
  RestoreExplorerProcessHandle.SetParams( RestoreExplorerParamsData );
  RestoreExplorerProcessHandle.SetRestoreExplorerOperator( RestoreExplorerOperator );
  RestoreExplorerProcessHandle.Update;
  RestoreExplorerProcessHandle.Free;
end;

procedure TRestoreExplorerStartHandle.Update;
begin
    // 创建数据
  if not CreateRestoreData then
    Exit;

    // 处理数据
  ExplorerHandle;

    // 删除数据
  DestoryRestoreData;
end;

{ TLocalRestoreExplorerOperator }

procedure TLocalRestoreExplorerOperator.ReadDeletedFileResult;
var
  ExplorerPath : string;
  LocalFileDeletedListFindHandle : TLocalFileDeletedListFindHandle;
begin
  ExplorerPath := MyFilePath.getLocalRecyclePath( RestoreFrom, RestorePath );

  LocalFileDeletedListFindHandle := TLocalFileDeletedListFindHandle.Create( ExplorerPath );
  LocalFileDeletedListFindHandle.SetScanFileHash( ScanFileHash );
  LocalFileDeletedListFindHandle.Update;
  LocalFileDeletedListFindHandle.Free;
end;

procedure TLocalRestoreExplorerOperator.ReadFileResult;
var
  ExplorerPath : string;
  FileName : string;
  FileSize : Int64;
  FileTime : TDateTime;
  ScanFileInfo : TScanFileInfo;
begin
  ExplorerPath := MyFilePath.getLocalBackupPath( RestoreFrom, RestorePath );
  if IsEncrypted then
    ExplorerPath := MyFilePath.getEncryptName( ExplorerPath, PasswordExt );

  if not FileExists( ExplorerPath ) then
    Exit;

  FileName := ExtractFileName( ExplorerPath );
  FileSize := MyFileInfo.getFileSize( ExplorerPath );
  FileTime := MyFileInfo.getFileLastWriteTime( ExplorerPath );
  ScanFileInfo := TScanFileInfo.Create( FileName );
  ScanFileInfo.SetFileInfo( FileSize, FileTime );
  ScanFileHash.AddOrSetValue( FileName, ScanFileInfo );
end;

procedure TLocalRestoreExplorerOperator.ReadFolderResult;
var
  ExplorerPath : string;
  LocalFolderAdvanceFindHandle : TLocalFolderFilterFindHandle;
begin
  if IsDeleted then
    ExplorerPath := MyFilePath.getLocalRecyclePath( RestoreFrom, RestorePath )
  else
    ExplorerPath := MyFilePath.getLocalBackupPath( RestoreFrom, RestorePath );

    // 含过滤的搜索
  LocalFolderAdvanceFindHandle := TLocalFolderFilterFindHandle.Create;
  LocalFolderAdvanceFindHandle.SetFolderPath( ExplorerPath );
  LocalFolderAdvanceFindHandle.SetSleepCount( 0 );
  LocalFolderAdvanceFindHandle.SetScanFile( ScanFileHash );
  LocalFolderAdvanceFindHandle.SetScanFolder( ScanFolderHash );
  LocalFolderAdvanceFindHandle.SetEncryptedInfo( IsEncrypted, PasswordExt );
  LocalFolderAdvanceFindHandle.Update;
  LocalFolderAdvanceFindHandle.Free;
end;

{ TRestoreExplorerOperator }

procedure TRestoreExplorerOperator.SetParams(
  Params: TRestoreExplorerParamsData);
begin
  RestorePath := Params.RestorePath;
  OwnerID := Params.OwnerID;
  RestoreFrom := Params.RestoreFrom;
  IsFile := Params.IsFile;

  IsEncrypted := Params.IsEncrypted;
  PasswordExt := Params.PasswordExt;
  IsDeleted := Params.IsDeleted;
  IsSearch := Params.IsSearch;

  ScanFileHash := Params.ScanFileHash;
  ScanFolderHash := Params.ScanFolderHash;
end;

{ TNetworkRestoreExplorerOperator }

procedure TNetworkRestoreExplorerOperator.ReadDeletedFileResult;
var
  NetworkFileDeletedListFindHandle : TNetworkFileDeletedListFindHandle;
begin
  NetworkFileDeletedListFindHandle := TNetworkFileDeletedListFindHandle.Create( RestorePath );
  NetworkFileDeletedListFindHandle.SetTcpSocket( TcpSocket );
  NetworkFileDeletedListFindHandle.SetScanFileHash( ScanFileHash );
  NetworkFileDeletedListFindHandle.Update;
  NetworkFileDeletedListFindHandle.Free;
end;

procedure TNetworkRestoreExplorerOperator.ReadFileResult;
var
  ScanPath : string;
  IsExist : Boolean;
  FileName : string;
  FileSize : Int64;
  FileTime : TDateTime;
  ScanFileInfo : TScanFileInfo;
  NetworkFileFindHandle : TNetworkFileFindHandle;
begin
  ScanPath := RestorePath;
  if IsEncrypted then
    ScanPath := MyFilePath.getEncryptName( ScanPath, PasswordExt );

  NetworkFileFindHandle := TNetworkFileFindHandle.Create;
  NetworkFileFindHandle.SetFilePath( ScanPath );
  NetworkFileFindHandle.SetTcpSocket( TcpSocket );
  NetworkFileFindHandle.Update;
  IsExist := NetworkFileFindHandle.getIsExist;
  FileSize := NetworkFileFindHandle.getFileSize;
  FileTime := NetworkFileFindHandle.getFileTime;
  NetworkFileFindHandle.Free;

  if not IsExist then
    Exit;

  FileName := ExtractFileName( ScanPath );
  ScanFileInfo := TScanFileInfo.Create( FileName );
  ScanFileInfo.SetFileInfo( FileSize, FileTime );
  ScanFileHash.AddOrSetValue( FileName, ScanFileInfo );
end;


procedure TNetworkRestoreExplorerOperator.ReadFolderResult;
var
  NetworkFolderFindHandle : TNetworkFolderFindHandle;
begin
  NetworkFolderFindHandle := TNetworkFolderFindHandle.Create;
  NetworkFolderFindHandle.SetFolderPath( RestorePath );
  NetworkFolderFindHandle.SetTcpSocket( TcpSocket );
  NetworkFolderFindHandle.SetIsDeleted( IsDeleted );
  NetworkFolderFindHandle.SetScanFile( ScanFileHash );
  NetworkFolderFindHandle.SetScanFolder( ScanFolderHash );
  NetworkFolderFindHandle.SetIsFilter( True );
  NetworkFolderFindHandle.SetEnctyptedInfo( IsEncrypted, PasswordExt );
  NetworkFolderFindHandle.Update;
  NetworkFolderFindHandle.Free;
end;

procedure TNetworkRestoreExplorerOperator.SetParams(
  Params: TRestoreExplorerParamsData);
var
  NetworkRestoreExplorerParamsData : TNetworkRestoreExplorerParamsData;
begin
  inherited;

  NetworkRestoreExplorerParamsData := Params as TNetworkRestoreExplorerParamsData;
  TcpSocket := NetworkRestoreExplorerParamsData.TcpSocket;
end;

{ TRestoreCopyFileOperator }

procedure TRestoreCopyFileOperator.AddSpeedSpace(SendSize: Integer);
begin
  if SpeedReader.AddCompleted( SendSize ) then
    RestoreDownAppApi.SetSpeed( RestorePath, OwnerID, RestoreFrom, SpeedReader.ReadLastSpeed );
end;

procedure TRestoreCopyFileOperator.DesWriteSpaceLack;
begin
  RestoreDownAppApi.SetIsLackSpace( RestorePath, OwnerID, RestoreFrom, True );
end;

procedure TRestoreCopyFileOperator.MarkContinusCopy;
var
  Params : TRestoreDownContinusAddParams;
begin
    // 已经取消恢复
  if not RestoreDownInfoReadUtil.ReadIsEnable( RestorePath, OwnerID, RestoreFrom )  then
    Exit;

  Params.RestorePath := RestorePath;
  Params.OwnerPcID := OwnerID;
  Params.RestoreFrom := RestoreFrom;
  Params.FilePath := RestoreFilePath;
  Params.FileSize := ReadFileSize;
  Params.FileTime := ReadFileTime;
  RestoreDownContinusApi.AddItem( Params );
end;


procedure TRestoreCopyFileOperator.ReadFileError;
var
  Params : TRestoreDownErrorAddParams;
begin
      // 显示发送失败信息
  Params.RestorePath := RestorePath;
  Params.OwnerPcID := OwnerID;
  Params.RestoreFrom := RestoreFrom;
  Params.FilePath := RestoreFilePath;
  Params.FileSize := ReadFileSize;
  Params.CompletedSize := ReadFilePos;
  RestoreDownErrorApi.ReadFileError( Params );
end;

function TRestoreCopyFileOperator.ReadIsNextCopy: Boolean;
begin
  Result := inherited and RestoreCancelReader.getIsRun;
end;

procedure TRestoreCopyFileOperator.RefreshCompletedSpace;
var
  LastCompletedSize : Int64;
begin
  LastCompletedSize := ReadLastCompletedSize;

    // 设置 已完成空间
  RestoreDownAppApi.AddCompletedSpace( RestorePath, OwnerID, RestoreFrom, LastCompletedSize );
end;

procedure TRestoreCopyFileOperator.SetParams(Params: TRestoreParamsData);
begin
  RestorePath := Params.RestorePath;
  OwnerID := Params.OwnerID;
  RestoreFrom := Params.RestoreFrom;

  RestoreCancelReader := Params.RestoreCancelReader;
  SpeedReader := Params.SpeedReader;
end;

procedure TRestoreCopyFileOperator.SetRestoreFilePath(_RestoreFilePath: string);
begin
  RestoreFilePath := _RestoreFilePath;
end;

procedure TRestoreCopyFileOperator.WriteFileError;
var
  Params : TRestoreDownErrorAddParams;
begin
      // 显示发送失败信息
  Params.RestorePath := RestorePath;
  Params.OwnerPcID := OwnerID;
  Params.RestoreFrom := RestoreFrom;
  Params.FilePath := RestoreFilePath;
  Params.FileSize := ReadFileSize;
  Params.CompletedSize := ReadFilePos;
  RestoreDownErrorApi.WriteFileError( Params );
end;

{ TRestorePreviewInfo }

procedure TRestorePreviewInfo.SetDeletedInfo(_IsDeleted: Boolean;
  _EditionNum : Integer);
begin
  IsDeleted := _IsDeleted;
  EditionNum := _EditionNum;
end;

procedure TRestorePreviewInfo.SetPassword(_Password: string);
begin
  Password := _Password;
end;

{ TRestorePreviewHandle }

function TRestorePreviewHandle.CreatePreviewFileHandle: TPreviewFileHandle;
begin
  if MyPictureUtil.getIsPictureFile( RestorePath ) then
    Result := TPreviewPictureHandle.Create
  else
  if MyPreviewUtil.getIsDocFile( RestorePath ) then
    Result := TPreviewWordHandle.Create
  else
  if MyPreviewUtil.getIsExcelFile( RestorePath ) then
    Result := TPreviewExcelHandle.Create
  else
  if MyPreviewUtil.getIsCompressFile( RestorePath ) then
    Result := TPreviewZipHandle.Create
  else
  if MyPreviewUtil.getIsExeFile( RestorePath ) then
    Result := TPreviewExeHandle.Create
  else
  if MyPreviewUtil.getIsMusicFile( RestorePath ) then
    Result := TPreviewMusicHandle.Create
  else
    Result := TPreviewTextHandle.Create
end;

procedure TRestorePreviewHandle.SetPreviewReader(
  _PreviewReader: TPreviewReader);
begin
  PreviewReader := _PreviewReader;
end;

procedure TRestorePreviewHandle.SetRestorePreviewInfo(
  _RestorePreviewInfo: TRestorePreviewInfo);
begin
  RestorePreviewInfo := _RestorePreviewInfo;
  RestorePath := RestorePreviewInfo.RestorePath;
end;

procedure TRestorePreviewHandle.Update;
var
  PreviewFileHandle : TPreviewFileHandle;
begin
  PreviewFileHandle := CreatePreviewFileHandle;
  PreviewFileHandle.SetRestorePreviewInfo( RestorePreviewInfo );
  PreviewFileHandle.SetPreviewReader( PreviewReader );
  PreviewFileHandle.Update;
  PreviewFileHandle.Free;
end;

{ TPreviewPictureHandle }

function TPreviewPictureHandle.FindPictureStream: Boolean;
begin
  PictureStream := PreviewReader.ReadPicturePreview;
  Result := Assigned( PictureStream );
end;

procedure TPreviewPictureHandle.ShowPictureStream;
var
  RestorePreviewPictureFace : TRestorePreviewPictureFace;
begin
  RestorePreviewPictureFace := TRestorePreviewPictureFace.Create;
  RestorePreviewPictureFace.SetFilePath( RestorePath );
  RestorePreviewPictureFace.SetPreviewStream( PictureStream );
  RestorePreviewPictureFace.AddChange;
end;

procedure TPreviewPictureHandle.Update;
begin
    // 暂时不处理加密
  if IsEncrypted then
  begin
    ShowEncrytped;
    Exit;
  end;

  if FindPictureStream then
    ShowPictureStream
  else
    ShowNotPreview;
end;

{ TPreviewWordHandle }

procedure TPreviewWordHandle.FindWordText;
begin
  WordText := PreviewReader.ReadWordPreview;
end;

procedure TPreviewWordHandle.ShowWordText;
var
  RestorePreviewWordFace : TRestorePreviewWordFace;
begin
    // 显示
  RestorePreviewWordFace := TRestorePreviewWordFace.Create;
  RestorePreviewWordFace.SetFilePath( RestorePath );
  RestorePreviewWordFace.SetWordText( WordText );
  RestorePreviewWordFace.AddChange;
end;

procedure TPreviewWordHandle.Update;
begin
    // 暂时不处理加密
  if IsEncrypted then
  begin
    ShowEncrytped;
    Exit;
  end;

  FindWordText;

  ShowWordText;
end;

{ TPreviewExcelHandle }

procedure TPreviewExcelHandle.FindExcelText;
begin
  ExcelText := PreviewReader.ReadExcelPreview;
end;

procedure TPreviewExcelHandle.ShowExcelText;
var
  RestorePreviewExcelFace : TRestorePreviewExcelFace;
begin
    // 显示
  RestorePreviewExcelFace := TRestorePreviewExcelFace.Create;
  RestorePreviewExcelFace.SetFilePath( RestorePath );
  RestorePreviewExcelFace.SetExcelText( ExcelText );
  RestorePreviewExcelFace.AddChange;
end;

procedure TPreviewExcelHandle.Update;
begin
    // 暂时不处理加密
  if IsEncrypted then
  begin
    ShowEncrytped;
    Exit;
  end;

  FindExcelText;

  ShowExcelText;
end;

{ TPreviewZipHandle }

procedure TPreviewZipHandle.FindZipText;
begin
  ZipText := PreviewReader.ReadZipOrRarPreview;
end;

procedure TPreviewZipHandle.ShowZipText;
var
  RestorePreviewZipFace : TRestorePreviewZipFace;
begin
    // 显示
  RestorePreviewZipFace := TRestorePreviewZipFace.Create;
  RestorePreviewZipFace.SetFilePath( RestorePath );
  RestorePreviewZipFace.SetZipText( ZipText );
  RestorePreviewZipFace.AddChange;
end;

procedure TPreviewZipHandle.Update;
begin
    // 暂时不处理加密
  if IsEncrypted then
  begin
    ShowEncrytped;
    Exit;
  end;

  FindZipText;

  ShowZipText;
end;

{ TPreviewExeHandle }

procedure TPreviewExeHandle.FindExeText;
begin
  ExeText := PreviewReader.ReadExeDetailsPreview;
end;

function TPreviewExeHandle.FindIconStream: Boolean;
begin
  IconStream := PreviewReader.ReadExeIconPreview;
  Result := Assigned( IconStream );
end;

procedure TPreviewExeHandle.ShowExeText;
var
  RestorePreviewExeDetailFace : TRestorePreviewExeDetailFace;
begin
  RestorePreviewExeDetailFace := TRestorePreviewExeDetailFace.Create;
  RestorePreviewExeDetailFace.SetFilePath( RestorePath );
  RestorePreviewExeDetailFace.SetExeText( ExeText );
  RestorePreviewExeDetailFace.AddChange;
end;

procedure TPreviewExeHandle.ShowIconStream;
var
  RestorePreviewExeIconFace : TRestorePreviewExeIconFace;
begin
  RestorePreviewExeIconFace := TRestorePreviewExeIconFace.Create;
  RestorePreviewExeIconFace.SetFilePath( RestorePath );
  RestorePreviewExeIconFace.SetPreviewStream( IconStream );
  RestorePreviewExeIconFace.AddChange;
end;

procedure TPreviewExeHandle.Update;
begin
    // 暂时不处理加密
  if IsEncrypted then
  begin
    ShowEncrytped;
    Exit;
  end;

  FindExeText;
  ShowExeText;

  if FindIconStream then
    ShowIconStream;
end;

{ TPreviewMusicHandle }

procedure TPreviewMusicHandle.FindMusicText;
begin
  MusicText := PreviewReader.ReadMusicPreview;
end;

procedure TPreviewMusicHandle.ShowMusicText;
var
  RestoreFilePreviewMusicFace : TRestorePreviewMusicFace;
begin
  RestoreFilePreviewMusicFace := TRestorePreviewMusicFace.Create;
  RestoreFilePreviewMusicFace.SetMusicText( MusicText );
  RestoreFilePreviewMusicFace.SetFilePath( RestorePath );
  RestoreFilePreviewMusicFace.AddChange;
end;

procedure TPreviewMusicHandle.Update;
begin
    // 暂时不处理加密
  if IsEncrypted then
  begin
    ShowEncrytped;
    Exit;
  end;

  FindMusicText;

  ShowMusicText;
end;

{ TPreviewTextHandle }

function TPreviewTextHandle.FindTextStream: Boolean;
begin
  TextStream := PreviewReader.ReadTextPreview;
  Result := Assigned( TextStream );
end;

procedure TPreviewTextHandle.ShowTextStream;
var
  RestorePreviewTextFace : TRestorePreviewTextFace;
begin
  RestorePreviewTextFace := TRestorePreviewTextFace.Create;
  RestorePreviewTextFace.SetFilePath( RestorePath );
  RestorePreviewTextFace.SetPreviewStream( TextStream );
  RestorePreviewTextFace.AddChange;
end;

procedure TPreviewTextHandle.Update;
begin
  if FindTextStream then
    ShowTextStream
  else
    ShowNotPreview;
end;

{ TPreviewBaseHandle }

procedure TPreviewFileHandle.SetPreviewReader(_PreviewReader: TPreviewReader);
begin
  PreviewReader := _PreviewReader;
end;

procedure TPreviewFileHandle.SetRestorePreviewInfo(
  _RestorePreviewInfo: TRestorePreviewInfo);
begin
  RestorePreviewInfo := _RestorePreviewInfo;
  RestorePath := RestorePreviewInfo.RestorePath;
  IsEncrypted := RestorePreviewInfo.IsEncrypted;
end;

procedure TPreviewFileHandle.ShowEncrytped;
begin
  RestorePreviewAppApi.NotPreviewEncrypted;
end;

procedure TPreviewFileHandle.ShowNotPreview;
begin
  RestorePreviewAppApi.NotPreviewFile;
end;

{ TUncompressEncryptZipStreamHandle }

constructor TUncompressEncryptZipStreamHandle.Create(_ZipStream: TMemoryStream);
begin
  ZipStream := _ZipStream;
end;

procedure TUncompressEncryptZipStreamHandle.SetIsDeleted(_IsDeleted: Boolean);
begin
  IsDeleted := _IsDeleted;
end;

procedure TUncompressEncryptZipStreamHandle.SetEncryptedInfo(
  _IsEncrypted: Boolean; _Password, _PasswordExt : string );
begin
  IsEncrypted := _IsEncrypted;
  Password := _Password;
  PasswordExt := _PasswordExt;
end;

procedure TUncompressEncryptZipStreamHandle.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

procedure TUncompressEncryptZipStreamHandle.SetTcpSocket(
  _TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TUncompressEncryptZipStreamHandle.Update;
var
  HeartBeatTime : TDateTime;
  ZipFile : TZipFile;
  i: Integer;
  TempStream : TStream;
  ZipHeader : TZipHeader;
  FilePath : string;
  FileDate : TDateTime;
  DataBuf : TDataBuf;
  ReadSize : Integer;
  FileStream : TFileStream;
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
            // 获取解压文件数据
          ZipFile.Read( i, TempStream, ZipHeader );
          ReadSize := TempStream.Read( DataBuf, ZipHeader.UncompressedSize );
          TempStream.Free;

            // 文件信息
          FilePath := MyFilePath.getPath( SavePath ) + ZipHeader.FileName;
          FilePath := StringReplace( FilePath, '/', '\', [rfReplaceAll] );
          FilePath := MyFilePath.getOrinalName( IsEncrypted, IsDeleted, FilePath, PasswordExt );
          if IsEncrypted then // 解密
            SendFileUtil.Deccrypt( DataBuf, ReadSize, Password );

            // 保存文件
          FileStream := TFileStream.Create( FilePath, fmCreate or fmShareDenyNone );
          FileStream.Write( DataBuf, ReadSize );
          FileStream.Free;

            // 重设文件修改时间
          FileDate := FileDateToDateTime( ZipHeader.ModifiedDateTime );
          MyFileSetTime.SetTime( FilePath, FileDate );
        except
        end;
        HeartBeatReceiver.CheckSend( TcpSocket, HeartBeatTime );  // 定时发送心跳
      end;
    except
    end;
    ZipFile.Close;
  except
  end;
  ZipFile.Free;
end;

{ TPreviewHandleBase }

procedure TPreviewReader.SetRestorePreviewInfo(
  _RestorePreviewInfo: TRestorePreviewInfo);
begin
  RestorePreviewInfo := _RestorePreviewInfo;
  RestorePath := RestorePreviewInfo.RestorePath;
  OwnerID := RestorePreviewInfo.OwnerID;
  RestoreFrom := RestorePreviewInfo.RestoreFrom;
  IsDeleted := RestorePreviewInfo.IsDeleted;
  EditionNum := RestorePreviewInfo.EditionNum;
  IsEncrypted := RestorePreviewInfo.IsEncrypted;
  PasswordExt := RestorePreviewInfo.PasswordExt;
  Password := RestorePreviewInfo.Password;
end;

{ TLocalPreviewHandle }

function TLocalPreviewReader.ReadExcelPreview: string;
begin
  Result := MyPreviewUtil.getExcelText( ReadFilePath );
end;

function TLocalPreviewReader.ReadExeDetailsPreview: string;
begin
  Result := MyPreviewUtil.getExeText( ReadFilePath );
end;

function TLocalPreviewReader.ReadExeIconPreview: TMemoryStream;
begin
  Result := MyPreviewUtil.getExeIconStream( ReadFilePath );
end;

function TLocalPreviewReader.ReadFilePath: string;
begin
    // 确定文件路径
  if IsDeleted then
    Result := MyFilePath.getLocalRecyclePath( RestoreFrom, RestorePath )
  else
    Result := MyFilePath.getLocalBackupPath( RestoreFrom, RestorePath );
  Result := MyFilePath.getAdvanceName( IsEncrypted, IsDeleted, Result, PasswordExt, EditionNum );
end;

function TLocalPreviewReader.ReadMusicPreview: string;
begin
  Result := MyPreviewUtil.getMusicText( ReadFilePath );
end;

function TLocalPreviewReader.ReadPicturePreview: TMemoryStream;
begin
  Result := MyPictureUtil.getPreviewStream( ReadFilePath );
end;

function TLocalPreviewReader.ReadTextPreview: TMemoryStream;
begin
    // 文件是否可预览
  if MyPreviewUtil.getIsTextPreview( ReadFilePath ) then
  begin
    Result := MyPreviewUtil.getTextPreview( ReadFilePath );
    if Assigned( Result ) and IsEncrypted then  // 解密
      Result := CopyFileUtil.DecryptStream( Result, Password );
  end
  else
    Result := nil;
end;

function TLocalPreviewReader.ReadWordPreview: string;
begin
  Result := MyPreviewUtil.getWordText( ReadFilePath );
end;

function TLocalPreviewReader.ReadZipOrRarPreview: string;
begin
  Result := MyPreviewUtil.getCompressText( ReadFilePath );
end;

{ TNetworkPreviewHandle }

function TNetworkPreviewReader.ReadExcelPreview: string;
begin
      // 发送请求信息
  SendPreviewReq( FileReq_PreviewExcel );

  Result := MySocketUtil.RevData( TcpSocket );
end;

function TNetworkPreviewReader.ReadExeDetailsPreview: string;
begin
      // 发送请求信息
  SendPreviewReq( FileReq_PreviewExeDetail );

  Result := MySocketUtil.RevData( TcpSocket );
end;

function TNetworkPreviewReader.ReadExeIconPreview: TMemoryStream;
var
  IsExist, IsSuccess : Boolean;
  ms : TMemoryStream;
  ReceiveFileOperator : TReceiveFileOperator;
  NetworkReceiveStreamHandle : TNetworkReceiveStreamHandle;
begin
  Result := nil;

      // 发送请求信息
  SendPreviewReq( FileReq_PreviewExeIcon );

    // 是否存在流
  IsExist := MySocketUtil.RevBoolData( TcpSocket );
  if not IsExist then // 文件不存在
    Exit;

    // 创建接收流
  ms := TMemoryStream.Create;

    // 接收文件流
  try
    ReceiveFileOperator := TReceiveFileOperator.Create;
    NetworkReceiveStreamHandle := TNetworkReceiveStreamHandle.Create;
    NetworkReceiveStreamHandle.SetRevStream( ms );
    NetworkReceiveStreamHandle.SetTcpSocket( TcpSocket );
    NetworkReceiveStreamHandle.SetRecieveFileOperator( ReceiveFileOperator );
    IsSuccess := NetworkReceiveStreamHandle.Update;
    NetworkReceiveStreamHandle.Free;
    ReceiveFileOperator.Free;
  except
    IsSuccess := False;
  end;

    // 成功接收
  if IsSuccess then
  begin
    Result := ms;
    Exit;
  end;

  try    // 关闭流
    ms.Free;
  except
  end;
end;

function TNetworkPreviewReader.ReadMusicPreview: string;
begin
      // 发送请求信息
  SendPreviewReq( FileReq_PreviewMusic );

  Result := MySocketUtil.RevData( TcpSocket );
end;

function TNetworkPreviewReader.ReadPicturePreview: TMemoryStream;
var
  IsExist, IsSuccess : Boolean;
  ms : TMemoryStream;
  ReceiveFileOperator : TReceiveFileOperator;
  NetworkReceiveStreamHandle : TNetworkReceiveStreamHandle;
begin
  Result := nil;

    // 发送请求信息
  SendPreviewReq( FileReq_PreviewPicture );

    // 是否存在流
  IsExist := MySocketUtil.RevBoolData( TcpSocket );
  if not IsExist then // 文件不存在
    Exit;

    // 创建接收流
  ms := TMemoryStream.Create;

    // 接收文件流
  try
    ReceiveFileOperator := TReceiveFileOperator.Create;
    NetworkReceiveStreamHandle := TNetworkReceiveStreamHandle.Create;
    NetworkReceiveStreamHandle.SetRevStream( ms );
    NetworkReceiveStreamHandle.SetTcpSocket( TcpSocket );
    NetworkReceiveStreamHandle.SetRecieveFileOperator( ReceiveFileOperator );
    NetworkReceiveStreamHandle.SetDecryptInfo( IsEncrypted, Password );
    IsSuccess := NetworkReceiveStreamHandle.Update;
    NetworkReceiveStreamHandle.Free;
    ReceiveFileOperator.Free;
  except
    IsSuccess := False;
  end;

    // 成功接收
  if IsSuccess then
  begin
    Result := ms;
    Exit;
  end;

  try    // 关闭流
    ms.Free;
  except
  end;
end;

function TNetworkPreviewReader.ReadTextPreview: TMemoryStream;
var
  IsExist, IsSuccess : Boolean;
  ms : TMemoryStream;
  ReceiveFileOperator : TReceiveFileOperator;
  NetworkReceiveStreamHandle : TNetworkReceiveStreamHandle;
begin
  Result := nil;

      // 发送请求信息
  SendPreviewReq( FileReq_PreviewText );

    // 是否存在流
  IsExist := MySocketUtil.RevBoolData( TcpSocket );
  if not IsExist then // 文件不存在
    Exit;

    // 创建接收流
  ms := TMemoryStream.Create;

    // 接收文件流
  try
    ReceiveFileOperator := TReceiveFileOperator.Create;
    NetworkReceiveStreamHandle := TNetworkReceiveStreamHandle.Create;
    NetworkReceiveStreamHandle.SetRevStream( ms );
    NetworkReceiveStreamHandle.SetTcpSocket( TcpSocket );
    NetworkReceiveStreamHandle.SetRecieveFileOperator( ReceiveFileOperator );
    NetworkReceiveStreamHandle.SetDecryptInfo( IsEncrypted, Password );
    IsSuccess := NetworkReceiveStreamHandle.Update;
    NetworkReceiveStreamHandle.Free;
    ReceiveFileOperator.Free;
  except
    IsSuccess := False;
  end;

    // 成功接收
  if IsSuccess then
  begin
    Result := ms;
    Exit;
  end;

  try    // 关闭流
    ms.Free;
  except
  end;
end;

function TNetworkPreviewReader.ReadWordPreview: string;
var
  RevStr : string;
begin

    // 发送请求信息
  SendPreviewReq( FileReq_PreviewWord );

    // 接收word文本
  Result := '';
  while True do
  begin
    RevStr := MySocketUtil.RevData( TcpSocket );
    if ( RevStr = '' ) or ( RevStr = Split_Word ) then
      Break;
    Result := Result + RevStr;
  end;
end;

function TNetworkPreviewReader.ReadZipOrRarPreview: string;
begin
      // 发送请求信息
  SendPreviewReq( FileReq_PreviewZip );

  Result := MySocketUtil.RevData( TcpSocket );
end;

procedure TNetworkPreviewReader.SendPreviewReq(FileReq: string);
var
  FilePath : string;
begin
    // 文件路径
  FilePath := MyFilePath.getAdvanceName( IsEncrypted, IsDeleted, RestorePath, PasswordExt, EditionNum );

    // 预览请求信息
  MySocketUtil.SendData( TcpSocket, FileReq );
  MySocketUtil.SendData( TcpSocket, FilePath );
  MySocketUtil.SendData( TcpSocket, IsDeleted );
end;

procedure TNetworkPreviewReader.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

{ TRestorePreviewStartHandle }

procedure TRestorePreviewStartHandle.CreateLocalData;
begin
  PreviewReader := TLocalPreviewReader.Create;
end;

function TRestorePreviewStartHandle.CreateNetworkData: Boolean;
var
  TcpSocket : TCustomIpClient;
  CloudConnResult : string;
  IsSuccessConn : Boolean;
begin
  Result := False;

    // 申请一个连接
  TcpSocket := MyRestoreDownConnectHandler.getRestoreConn( RestorePath, OwnerID, RestoreFrom, RestoreConnect_Preview );
  if not Assigned( TcpSocket ) then
    Exit;

      // 获取访问结果
  CloudConnResult := MySocketUtil.RevData( TcpSocket );

    // 是否连接成功
  IsSuccessConn := CloudConnResult = CloudConnResult_OK;

    // 连接失败
  if not IsSuccessConn then
  begin
    TcpSocket.Free;
    Exit;
  end;

    // 设置 Socket
  PreviewReader := TNetworkPreviewReader.Create;
  ( PreviewReader as TNetworkPreviewReader ).SetTcpSocket( TcpSocket );

  Result := True;
end;

function TRestorePreviewStartHandle.CreateRestoreData: Boolean;
begin
  Result := True;
  if IsLocalPreview then
    CreateLocalData
  else
    Result := CreateNetworkData;

    // 创建失败
  if not Result then
    Exit;

    // 设置信息
  PreviewReader.SetRestorePreviewInfo( RestorePreviewInfo );
end;

procedure TRestorePreviewStartHandle.DestoryData;
begin
  if not IsLocalPreview then
    DestoryNetworkData;
  PreviewReader.Free;
end;

procedure TRestorePreviewStartHandle.DestoryNetworkData;
var
  TcpSocket : TCustomIpClient;
begin
  TcpSocket := ( PreviewReader as TNetworkPreviewReader ).TcpSocket;

    // 返回列表
  MyRestoreDownConnectHandler.AddLastConn( RestoreFrom, TcpSocket );
end;

procedure TRestorePreviewStartHandle.PreviewHandle;
var
  RestorePreviewHandle : TRestorePreviewHandle;
begin
  RestorePreviewHandle := TRestorePreviewHandle.Create;
  RestorePreviewHandle.SetRestorePreviewInfo( RestorePreviewInfo );
  RestorePreviewHandle.SetPreviewReader( PreviewReader );
  RestorePreviewHandle.Update;
  RestorePreviewHandle.Free;
end;

procedure TRestorePreviewStartHandle.SetRestorePreviewInfo(
  _RestorePreviewInfo: TRestorePreviewInfo);
begin
  RestorePreviewInfo := _RestorePreviewInfo;
  RestorePath := RestorePreviewInfo.RestorePath;
  OwnerID := RestorePreviewInfo.OwnerID;
  RestoreFrom := RestorePreviewInfo.RestoreFrom;
  IsLocalPreview := RestorePreviewInfo is TLocalRestorePreviewInfo;
end;

procedure TRestorePreviewStartHandle.Update;
begin
    // 创建数据结构
  if not CreateRestoreData then
    Exit;

    // 开始预览
  PreviewHandle;

    // 释放数据
  DestoryData;
end;

{ TRestorePathInfo }

procedure TRestorePathInfo.SetItemInfo(_RestorePath, _OwnerID,
  _RestoreFrom: string);
begin
  RestorePath := _RestorePath;
  OwnerID := _OwnerID;
  RestoreFrom := _RestoreFrom;
end;

{ TRestoreAdvancePathInfo }

procedure TRestoreAdvancePathInfo.SetEncryptedInfo(_IsEncrypted: Boolean;
  _PasswordExt: string);
begin
  IsEncrypted := _IsEncrypted;
  PasswordExt := _PasswordExt;
end;

{ TRestoreDownloadOperator }

procedure TRestoreDownFileOperator.HandlePath(
  RestorePathInfo: TRestorePathInfo);
var
  RestoreDownloadInfo : TRestoreDownloadInfo;
  RestoreStartHandle : TRestoreStartHandle;
begin
    // 不是恢复下载
  if not ( RestorePathInfo is TRestoreDownloadInfo ) then
    Exit;

    // 路径转换
  RestoreDownloadInfo := RestorePathInfo as TRestoreDownloadInfo;

    // 处理
  RestoreStartHandle := TRestoreStartHandle.Create( RestoreDownloadInfo );
  RestoreStartHandle.Update;
  RestoreStartHandle.Free;

    // 恢复停止
  RestoreDownAppApi.RestoreStop( RestoreDownloadInfo.RestorePath, RestoreDownloadInfo.OwnerID, RestoreDownloadInfo.RestoreFrom );
end;

procedure TRestoreDownFileOperator.StartRestoreHandle;
begin
  RestoreDownAppApi.StartRestore;
  MyRestoreHandler.IsRestoreRun := True;
end;

procedure TRestoreDownFileOperator.StopRestoreHandle;
begin
  inherited;

    // 停止恢复
  if MyRestoreHandler.IsRestoreRun then
    RestoreDownAppApi.StopRestore
  else  // 暂停恢复
    RestoreDownAppApi.PauseRestore;
end;

{ TRestoreOperator }

function TRestoreFileOperator.ReadIsRun: Boolean;
begin
  Result := MyRestoreHandler.getIsRun;
end;

function TRestoreFileOperator.ReastoreHandle: Boolean;
var
  RestorePathInfo : TRestorePathInfo;
begin
    // 读取 下一个恢复
  RestorePathInfo := MyRestoreHandler.getRestorePath;

    // 是否存在
  Result := Assigned( RestorePathInfo );
  if not Result then // 不存在则结束
    Exit;

    // 处理路径信息
  HandlePath( RestorePathInfo );

    // 释放资源
  RestorePathInfo.Free;
end;

procedure TRestoreFileOperator.SetMyRestoreHandler(
  _MyRestoreHandler: TMyRestoreHandler);
begin
  MyRestoreHandler := _MyRestoreHandler;
end;

procedure TRestoreFileOperator.StartRestoreHandle;
begin

end;

procedure TRestoreFileOperator.StopRestoreHandle;
begin
  if not ReadIsRun then
    MyRestoreHandler.IsCreateThread := False;
end;

{ TRestoreExplorerFileOperator }

procedure TRestoreExplorerFileOperator.HandlePath(
  RestorePathInfo: TRestorePathInfo);
var
  RestoreExplorerInfo : TRestoreExplorerInfo;
  RestoreExplorerStartHandle : TRestoreExplorerStartHandle;
begin
    // 非 Explorer
  if not ( RestorePathInfo is TRestoreExplorerInfo ) then
    Exit;

    // 转化为 Explorer
  RestoreExplorerInfo := RestorePathInfo as TRestoreExplorerInfo;

    // 处理
  RestoreExplorerStartHandle := TRestoreExplorerStartHandle.Create( RestoreExplorerInfo );
  RestoreExplorerStartHandle.Update;
  RestoreExplorerStartHandle.Free;
end;

procedure TRestoreExplorerFileOperator.StartRestoreHandle;
begin
  RestoreExplorerAppApi.StartExplorer;
  RestoreDeleteExplorerAppApi.StartExplorer;
end;

procedure TRestoreExplorerFileOperator.StopRestoreHandle;
begin
  inherited;

  RestoreExplorerAppApi.StopExplorer;
  RestoreDeleteExplorerAppApi.StopExplorer;
end;

{ TRestoreSearchFileOperator }

procedure TRestoreSearchFileOperator.HandlePath(
  RestorePathInfo: TRestorePathInfo);
var
  RestoreSearchInfo : TRestoreSearchInfo;
  RestoreSearchHandle : TRestoreSearchHandle;
begin
    // 是否搜索 Job
  if not ( RestorePathInfo is TRestoreSearchInfo ) then
    Exit;

    // 转为搜索 Job
  RestoreSearchInfo := RestorePathInfo as TRestoreSearchInfo;

  if RestoreSearchInfo is TLocalRestoreSearchInfo then
    RestoreSearchHandle := TLocalRestoreSearchHandle.Create
  else
    RestoreSearchHandle := TNetworkRestoreSearchHandle.Create;
  RestoreSearchHandle.SetRestoreScanInfo( RestoreSearchInfo );
  RestoreSearchHandle.Update;
  RestoreSearchHandle.Free;
end;

procedure TRestoreSearchFileOperator.StartRestoreHandle;
begin
  RestoreSearchAppApi.StartExplorer;
  MyRestoreSearchHandler.IsRestoreRun := True;
end;

procedure TRestoreSearchFileOperator.StopRestoreHandle;
begin
  inherited;

  RestoreSearchAppApi.StopExplorer;
end;

{ TMyRestoreBaseHandler }

procedure TMyRestoreHandler.AddRestorePath(
  RestorePathInfo: TRestorePathInfo);
begin
  if not IsRun then
    Exit;

  ThreadLock.Enter;

    // 添加到列表中
  RestorePathList.Add( RestorePathInfo );

    // 未创建则先创建
  if not IsCreateThread then
  begin
    IsCreateThread := True;
    RestoreHandleThread := TRestoreHandleThread.Create( RestoreFileOperator );
    RestoreHandleThread.Resume;
  end;

  ThreadLock.Leave;
end;

constructor TMyRestoreHandler.Create;
begin
  ThreadLock := TCriticalSection.Create;
  RestorePathList := TRestorePathList.Create;
  RestorePathList.OwnsObjects := False;
  RestoreFileOperator := CreateOperator;
  RestoreFileOperator.SetMyRestoreHandler( Self );
  IsCreateThread := False;

  IsRun := True;
  IsRestoreRun := True;
end;

destructor TMyRestoreHandler.Destroy;
begin
  RestoreFileOperator.Free;
  RestorePathList.OwnsObjects := True;
  RestorePathList.Free;
  ThreadLock.Free;
  inherited;
end;

function TMyRestoreHandler.getIsRun: Boolean;
begin
  Result := IsRun and IsRestoreRun;
end;

function TMyRestoreHandler.getRestorePath: TRestorePathInfo;
begin
  ThreadLock.Enter;
  if RestorePathList.Count > 0 then
  begin
    Result := RestorePathList[ 0 ];
    RestorePathList.Delete( 0 );
  end
  else
  begin
    IsCreateThread := False;
    Result := nil;
  end;
  ThreadLock.Leave;
end;

procedure TMyRestoreHandler.StopRun;
begin
  IsRun := False;

  while IsCreateThread do
    Sleep( 100 );
end;

{ TMyRestoreHandler }

function TMyRestoreDownHandler.CreateOperator: TRestoreFileOperator;
begin
  Result := TRestoreDownFileOperator.Create;
end;

{ TMyRestoreExplorerHandler }

function TMyRestoreExplorerHandler.CreateOperator: TRestoreFileOperator;
begin
  Result := TRestoreExplorerFileOperator.Create;
end;

{ TMyRestoreSearchHandler }

function TMyRestoreSearchHandler.CreateOperator: TRestoreFileOperator;
begin
  Result := TRestoreSearchFileOperator.Create;
end;

{ TRestorePreviewFileOperator }

procedure TRestorePreviewFileOperator.HandlePath(
  RestorePathInfo: TRestorePathInfo);
var
  RestorePreviewInfo : TRestorePreviewInfo;
  RestorePreviewStartHandle : TRestorePreviewStartHandle;
begin
    // 非 Explorer
  if not ( RestorePathInfo is TRestorePreviewInfo ) then
    Exit;

    // 转化为 Explorer
  RestorePreviewInfo := RestorePathInfo as TRestorePreviewInfo;

    // 处理预览
  RestorePreviewStartHandle := TRestorePreviewStartHandle.Create;
  RestorePreviewStartHandle.SetRestorePreviewInfo( RestorePreviewInfo );
  RestorePreviewStartHandle.Update;
  RestorePreviewStartHandle.Free;
end;

procedure TRestorePreviewFileOperator.StartRestoreHandle;
begin
  RestorePreviewAppApi.StartPreview;
end;

procedure TRestorePreviewFileOperator.StopRestoreHandle;
begin
  inherited;

  RestorePreviewAppApi.StopPreview;
end;

{ TMyRestorePreviewHandler }

function TMyRestorePreviewHandler.CreateOperator: TRestoreFileOperator;
begin
  Result := TRestorePreviewFileOperator.Create;
end;


{ TCompressFileHandle }

function TRestorePackageHandler.AddFile(FilePath: string): Boolean;
var
  RestoreFilePath, ZipName : string;
  NewZipInfo : TZipHeader;
  fs : TStream;
begin
  Result := False;

    // 恢复文件的路径
  if IsDeleted then
    RestoreFilePath := MyFilePath.getLocalRecyclePath( RestoreFrom, FilePath )
  else
    RestoreFilePath := MyFilePath.getLocalBackupPath( RestoreFrom, FilePath );

    // 初始化压缩信息
  ZipName := ExtractRelativePath( MyFilePath.getPath( RestorePath ), FilePath );
  ZipName := MyFilePath.getOrinalName( IsEncrypt, IsDeleted, ZipName, ExtPassword );
  NewZipInfo := MyZipUtil.getZipHeader( ZipName, RestoreFilePath, zcStored );

  try
    fs := ReadFileStream( RestoreFilePath );  // 读取压缩流
    if not Assigned( fs ) then // 读取失败
      Exit;
    ZipFile.Add( fs, NewZipInfo );  // 添加压缩文件
    fs.Free;

      // 刷新统计信息
    ZipSize := ZipSize + NewZipInfo.CompressedSize;
    Inc( ZipCount );
    Result := True;
  except
  end;
end;

function TRestorePackageHandler.AddZipFile(ScanResultInfo : TScanResultInfo): TScanResultInfo;
var
  ScanResultAddFileInfo : TScanResultAddFileInfo;
  SourceFileSize : Int64;
begin
  Result := ScanResultInfo;

    // 非发送文件
  if not ( ScanResultInfo is TScanResultAddFileInfo ) then
    Exit;

    // 只压缩小于 128 KB 的文件
  ScanResultAddFileInfo := ScanResultInfo as TScanResultAddFileInfo;
  SourceFileSize := ScanResultAddFileInfo.FileSize;
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

constructor TRestorePackageHandler.Create;
begin
  IsZipCreated := False;
end;

function TRestorePackageHandler.CreateZip: Boolean;
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
  except
  end;
end;

procedure TRestorePackageHandler.DestoryZip;
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

destructor TRestorePackageHandler.Destroy;
begin
  if IsZipCreated then
  begin
    DestoryZip;
    ZipStream.Free;
  end;
  inherited;
end;

function TRestorePackageHandler.ReadZipResultInfo: TScanResultAddZipInfo;
begin
  Result := nil;

    // 未创建压缩文件
  if not IsZipCreated then
    Exit;

    // 关闭压缩文件
  DestoryZip;

    // 返回压缩流
  Result := TScanResultAddZipInfo.Create( RestorePath );
  Result.SetZipStream( ZipStream );
end;

function TRestorePackageHandler.ReadFileStream(FilePath: string): TStream;
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

      // 解密密
    CopyFileUtil.Deccrypt( DataBuf, FileSize, Password );

      // 写入加密流
    Result := TMemoryStream.Create;
    Result.WriteBuffer( DataBuf, FileSize );
    Result.Position := 0;
  except
    Result := nil;
  end;
end;

function TRestorePackageHandler.getLastSendFile: TScanResultInfo;
begin
  Result := ReadZipResultInfo;
end;

procedure TRestorePackageHandler.SetParams(Params: TRestoreParamsData);
begin
  RestorePath := Params.RestorePath;
  OwnerID := Params.OwnerID;
  RestoreFrom := Params.RestoreFrom;

  IsDeleted := Params.IsDeleted;
  IsEncrypt := Params.IsEncrypt;
  Password := Params.Password;
  ExtPassword := Params.ExtPassword;
end;


{ TRestoreFileUnpackOperator }

procedure TRestoreFileUnpackOperator.AddSpeedSpace(SendSize: Integer);
begin
  if SpeedReader.AddCompleted( SendSize ) then
    RestoreDownAppApi.SetSpeed( RestorePath, OwnerID, RestoreFrom, SpeedReader.ReadLastSpeed );
end;

function TRestoreFileUnpackOperator.ReadIsNextCopy: Boolean;
begin
  Result := inherited and RestoreCancelReader.getIsRun;
end;

procedure TRestoreFileUnpackOperator.RefreshCompletedSpace;
var
  LastCompletedSize : Int64;
begin
  LastCompletedSize := ReadLastComletedSize;

    // 设置 已完成空间
  RestoreDownAppApi.AddCompletedSpace( RestorePath, OwnerID, RestoreFrom, LastCompletedSize );
end;

procedure TRestoreFileUnpackOperator.SetParams(Params: TRestoreParamsData);
begin
  RestorePath := Params.RestorePath;
  OwnerID := Params.OwnerID;
  RestoreFrom := Params.RestoreFrom;

  RestoreCancelReader := Params.RestoreCancelReader;
  SpeedReader := Params.SpeedReader;
end;

{ TNetworkRestoreParamsData }

procedure TNetworkRestoreParamsData.CheckHeartBeat;
begin
  HeartBeatReceiver.CheckSend( TcpSocket, HeartBeatTime );
end;

end.
