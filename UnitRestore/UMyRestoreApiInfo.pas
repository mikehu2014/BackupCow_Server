unit UMyRestoreApiInfo;

interface

uses SysUtils, classes, Generics.Collections;

type

{$Region ' 恢复文件 显示 ' }

  {$Region ' 数据修改 目标信息 ' }

    // 修改
  TRestoreDesWriteHandle = class
  public
    DesItemID : string;
  public
    constructor Create( _DesItemID : string );
  end;

    // 读取 本地目标
  TRestoreDesReadLocalHandle = class( TRestoreDesWriteHandle )
  public
    procedure Update;virtual;
  private
    procedure AddToFace;
  end;

    // 添加 本地目标
  TRestoreDesAddLocalHandle = class( TRestoreDesReadLocalHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 添加 网络目标
  TRestoreDesAddNetworkHandle = class( TRestoreDesWriteHandle )
  public
    procedure Update;
  private
    procedure AddToFace;
  end;

    // 删除
  TRestoreDesRemoveHandle = class( TRestoreDesWriteHandle )
  public
    procedure Update;virtual;
  private
    procedure RemoveFromFace;
  end;

    // 删除 本地目标
  TRestoreLocalDesRemoveHandle = class( TRestoreDesRemoveHandle )
  public
    procedure Update;override;
  private
    procedure RemoveFromXml;
  end;

    // 删除 网络目标
  TRestoreNetworkDesRemoveHandle = class( TRestoreDesRemoveHandle )
  end;

    // 恢复目标离线处理
  TRestoreDesOfflineHandle = class
  public
    DesPcID : string;
  public
    constructor Create( _DesPcID : string );
    procedure Update;
  private
    procedure SetToFace;
  end;

  {$EndRegion}

  {$Region ' 数据修改 备份信息 ' }

    // 修改
  TRestoreItemWriteHandle = class( TRestoreDesWriteHandle )
  public
    OwnerID : string;
    BackupPath : string;
  public
    procedure SetOwnerID( _OwnerID : string );
    procedure SetBackupPath( _BackupPath : string );
  end;

    // 读取
  TRestoreItemAddHandle = class( TRestoreItemWriteHandle )
  public
    IsFile : boolean;
    OwnerName : string;
    LastBackupTime : TDateTime;
  public
    FileCount : integer;
    FileSize, CompletedSize : int64;
  public
    IsSaveDeleted : Boolean;
    IsEncrypted : Boolean;
    Password, PasswordHint : string;
  public
    procedure SetIsFile( _IsFile : boolean );
    procedure SetOwnerName( _OwnerName : string );
    procedure SetSpaceInfo( _FileCount : integer; _FileSize : int64 );
    procedure SetLastBackupTime( _LastBackupTime : TDateTime );
    procedure SetIsSaveDeleted( _IsSaveDeleted : Boolean );
    procedure SetEncryptedInfo( _IsEncrypted : Boolean; _Password, _PasswordHint : string );
  end;

    // 读取 本地 Item
  TRestoreItemReadLocalHandle = class( TRestoreItemAddHandle )
  public
    procedure Update;virtual;
  private
    procedure AddToFace;
  end;

    // 添加 本地 Item
  TRestoreItemAddLocalHandle = class( TRestoreItemReadLocalHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 添加 网络Item
  TRestoreItemAddNetworkHandle = class( TRestoreItemAddHandle )
  public
    procedure Update;
  private
    procedure AddToFace;
  end;

    // 删除
  TRestoreItemRemoveHandle = class( TRestoreItemWriteHandle )
  public
    procedure Update;virtual;
  private
    procedure RemoveFromFace;
  end;

    // 删除 本地 Item
  TLocalRestoreItemRemoveHandle = class( TRestoreItemRemoveHandle )
  public
    procedure Update;override;
  private
    procedure RemoveFromXml;
    procedure RemoveBackupFile;
  end;

    // 删除 网络 Item
  TNetworkRestoreItemRemoveHandle = class( TRestoreItemRemoveHandle )
  end;

  {$EndRegion}

    // 参数结构
  TRestoreAddParams = record
  public
    DesItemID, BackupPath : string;
    OwnerID, OwnerName : string;
    IsFile : Boolean;
  public
    FileCount : integer;
    ItemSize : int64;
    LastBackupTime : TDateTime;
  public
    IsSaveDeleted : Boolean;
    IsEncrypted : Boolean;
    Password, PasswordHint : string;
  end;

    // 恢复目标 Api
  RestoreDesAppApi = class
  public
    class procedure AddLocalItem( DesPath : string );
    class procedure RemoveLocalItem( DesPath : string );
  public
    class procedure AddNetworkItem( DesItemID : string );
    class procedure RemoveNetworkItem( DesItemID : string );
  public
    class procedure SetPcOffline( DesPcID : string );
  end;

    // 恢复Item Api
  RestoreItemAppApi = class
  public
    class procedure AddLocalItem( Params : TRestoreAddParams );
    class procedure RemoveLocalItem( DesItemID, BackupPath, OwnerID : string );
  public
    class procedure AddNetworkItem( Params : TRestoreAddParams );
    class procedure RemoveNetworkItem( DesItemID, BackupPath, OwnerID : string );
  end;


{$EndRegion}

{$Region ' 恢复文件 Explorer ' }

  TRestoreExplorerParams = record
  public
    RestorePath, OwnerID, RestoreFrom : string;
    IsFile, IsDeleted, IsEncrypted, IsSerach : Boolean;
    PasswordExt : string;
  end;

    // 用户 Api
  RestoreExplorerUserApi = class
  public
    class procedure ReadLocal( Params : TRestoreExplorerParams );
    class procedure ReadNetwork( Params : TRestoreExplorerParams );
  end;

    // 结果参数
  TExplorerResultParams = record
  public
    FilePath : string;
    IsFile : boolean;
  public
    FileSize : int64;
    FileTime : TDateTime;
  public
    EditionNum : Integer;
  end;

    // 程序 Api
  RestoreExplorerAppApi = class
  public
    class procedure StartExplorer;
    class procedure CloudPcNotConn;
    class procedure CloudPcBusy;
    class procedure StopExplorer;
  public
    class procedure ShowResult( Params : TExplorerResultParams );
  end;

    // 删除的文件
  RestoreDeleteExplorerAppApi = class
  public
    class procedure StartExplorer;
    class procedure CloudPcNotConn;
    class procedure CloudPcBusy;
    class procedure StopExplorer;
  public
    class procedure ShowResult( Params : TExplorerResultParams );
  end;

  {$Region ' 浏览历史 ' }

   {$Region ' 浏览历史 ' }

      // 读取
  TShareExplorerHistoryReadHandle = class
  public
    FilePath, OwnerID, RestoreFrom : string;
  public
    constructor Create( _FilePath, _OwnerID, _RestoreFrom : string );
    procedure Update;virtual;
  private
    procedure RemoveExistItem;
    procedure RemoveMaxCount;
    procedure AddToInfo;
    procedure AddToFace;
  private
    procedure RemoveItem( RemoveIndex : Integer );
  end;

    // 添加
  TShareExplorerHistoryAddHandle = class( TShareExplorerHistoryReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 删除
  TShareExplorerHistoryRemoveHandle = class
  private
    RemoveIndex : Integer;
  public
    constructor Create( _RemoveIndex : Integer );
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromFace;
    procedure RemoveFromXml;
  end;

    // 共享历史
  ShareExplorerHistoryApi = class
  public
    class procedure AddItem( FilePath, OwnerID, RestoreFrom : string );
  end;

  {$EndRegion}

  {$EndRegion}

{$EndRegion}

{$Region ' 恢复文件 Search ' }

  TRestoreSearchParams = record
  public
    RestorePath, OwnerID, RestoreFrom : string;
    IsFile, HasDeleted, IsEncrypted : Boolean;
    PasswordExt, SerachName : string;
  end;

    // 用户 Api
  RestoreSearchUserApi = class
  public
    class procedure ReadLocal( Params : TRestoreSearchParams );
    class procedure ReadNetwork( Params : TRestoreSearchParams );
  end;

  TSearchResultParams = record
  public
    FilePath : string;
    IsFile, IsDeleted : boolean;
    EditionNum : Integer;
  public
    FileSize : int64;
    FileTime : TDateTime;
  end;

    // 程序 Api
  RestoreSearchAppApi = class
  public
    class procedure StartExplorer;
    class procedure CloudPcNotConn;
    class procedure CloudPcBusy;
    class procedure StopExplorer;
  public
    class procedure ShowResult( Params : TSearchResultParams );
    class procedure ShowExplorer( Params : TExplorerResultParams );
    class procedure ShowExplorerDeleted( Params : TExplorerResultParams );
  end;

{$EndRegion}

{$Region ' 恢复文件 Preview ' }

    // 预览参数
  TRestorePreviewParams = record
  public
    RestorePath, OwnerID, RestoreFrom : string;
    IsDeleted, IsEncrypted : Boolean;
    PasswordExt, Password : string;
    EditionNum : Integer;
  end;

    // 请求预览
  RestorePreviewUserApi = class
  public
    class procedure PreviewLocal( Params : TRestorePreviewParams );
    class procedure PreviewNetwork( Params : TRestorePreviewParams );
  end;

    // 预览结果
  RestorePreviewAppApi = class
  public
    class procedure StartPreview;
    class procedure CloudPcNotConn;
    class procedure CloudPcBusy;
    class procedure NotPreviewFile;
    class procedure NotPreviewEncrypted;
    class procedure StopPreview;
  end;

{$EndRegion}

{$Region ' 恢复下载 数据修改 ' }

    // 修改
  TRestoreDownWriteHandle = class
  public
    RestorePath, OwnerPcID, RestoreFrom : string;
  public
    constructor Create( _RestorePath, _OwnerPcID, _RestoreFrom : string );
  end;

  {$Region ' 增删修改 ' }

    // 读取
  TRestoreDownReadHandle = class( TRestoreDownWriteHandle )
  public
    IsFile, IsCompleted : Boolean;
    OwnerName : string;
  public
    FileCount : integer;
    FileSize, CompletedSize : int64;
  public
    IsDeleted : Boolean;
    EditionNum : Integer;
  public
    IsEncrypt : Boolean;
    Password : string;
  public
    SavePath : string;
  public
    procedure SetIsFile( _IsFile : Boolean );
    procedure SetIsCompleted( _IsCompleted : Boolean );
    procedure SetOwnerName( _OwnerName : string );
    procedure SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
    procedure SetDeletedInfo( _IsDeleted : Boolean; _EditionNum : Integer );
    procedure SetEncryptInfo( _IsEncrypt : Boolean; _Password : string );
    procedure SetSavePath( _SavePath : string );
  end;

    // 读取 本地恢复下载
  TRestoreDownReadLocalHandle = class( TRestoreDownReadHandle )
  public
    procedure Update;virtual;
  private
    procedure AddToInfo;
    procedure AddToFace;
  end;

    // 添加 本地恢复下载
  TRestoreDownAddLocalHandle = class( TRestoreDownReadLocalHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 读取 网络恢复下载
  TRestoreDownReadNetworkHandle = class( TRestoreDownReadHandle )
  private
    IsOnline : Boolean;
  public
    procedure SetIsOnline( _IsOnline : Boolean );
    procedure Update;virtual;
  private
    procedure AddToInfo;
    procedure AddToFace;
  end;

    // 添加 网络恢复下载
  TRestoreDownAddNetworkHandle = class( TRestoreDownReadNetworkHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 删除
  TRestoreDownRemoveHandle = class( TRestoreDownWriteHandle )
  protected
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromFace;
    procedure RemoveFromXml;
  end;

  {$EndRegion}

  {$Region ' 状态修改 ' }

      // 设置 状态
  TRestoreDownSetStautsHandle = class( TRestoreDownWriteHandle )
  public
    NodeStatus : string;
  public
    procedure SetNodeStatus( _NodeStatus : string );
    procedure Update;
  private
    procedure SetToFace;
  end;

    // 设置 是否缺少空间
  TRestoreDownSetIsLackSpaceHandle = class( TRestoreDownWriteHandle )
  public
    IsLackSpace : Boolean;
  public
    procedure SetIsLackSpace( _IsLackSpace : Boolean );
    procedure Update;
  private
    procedure SetToFace;
  end;

      // 修改
  TRestoreDownSetIsWriteHandle = class( TRestoreDownWriteHandle )
  public
    IsWrite : boolean;
  public
    procedure SetIsWrite( _IsWrite : boolean );
    procedure Update;
  private
     procedure SetToFace;
  end;

    // 设置 是否存在恢复源
  TRestoreDownSetIsExistHandle = class( TRestoreDownWriteHandle )
  public
    IsExist : Boolean;
  public
    procedure SetIsExist( _IsExist : Boolean );
    procedure Update;
  private
    procedure SetToFace;
  end;

    // 修改
  TRestoreDownSetSpeedHandle = class( TRestoreDownWriteHandle )
  public
    Speed : integer;
  public
    procedure SetSpeed( _Speed : integer );
    procedure Update;
  private
     procedure SetToFace;
  end;

    // 修改
  TRestoreDownSetAnalyzeCountHandle = class( TRestoreDownWriteHandle )
  public
    AnalyzeCount : integer;
  public
    procedure SetAnalyzeCount( _AnalyzeCount : integer );
    procedure Update;
  private
     procedure SetToFace;
  end;


    // Pc 上/下线
  TRestoreDownPcIsOnlineHandle = class
  public
    DesPcID : string;
    IsOnline : Boolean;
  public
    constructor Create( _DesPcID : string );
    procedure SetIsOnline( _IsOnline : Boolean );
    procedure Update;
  private
    procedure SetToFace;
  end;

      // 修改
  TRestoreDownSetIsCompletedHandle = class( TRestoreDownWriteHandle )
  public
    IsCompleted : boolean;
  public
    procedure SetIsCompleted( _IsCompleted : boolean );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToFace;
     procedure SetToXml;
  end;

    // 修改
  TRestoreDownSetIsRestoringHandle = class( TRestoreDownWriteHandle )
  public
    IsRestoring : boolean;
  public
    procedure SetIsRestoring( _IsRestoring : boolean );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToFace;
  end;

      // 修改
  TRestoreDownSetIsDesBusyHandle = class( TRestoreDownWriteHandle )
  public
    IsDesBusy : boolean;
  public
    procedure SetIsDesBusy( _IsDesBusy : boolean );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToFace;
  end;

      // 修改
  TRestoreDownSetIsLostConnHandle = class( TRestoreDownWriteHandle )
  public
    IsLostConn : boolean;
  public
    procedure SetIsLostConn( _IsLostConn : boolean );
    procedure Update;
  private
     procedure SetToInfo;
  end;

    // 设置
  TRestoreDownSetIsConnectedHandle = class( TRestoreDownWriteHandle )
  public
    IsConnected : Boolean;
  public
    procedure SetIsConnected( _IsConnected : Boolean );
    procedure Update;
  private
    procedure SetToFace;
  end;

    // 分析
  TRestoreDownAnalyzingHandle = class( TRestoreDownWriteHandle )
  public
    procedure Update;
  private
    procedure AddToHint;
  end;

  {$EndRegion}

  {$Region ' 空间修改 ' }

    // 修改
  TRestoreDownSetSpaceInfoHandle = class( TRestoreDownWriteHandle )
  public
    FileCount : integer;
    FileSize, CompletedSize : int64;
  public
    procedure SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToFace;
     procedure SetToXml;
  end;

      // 修改
  TRestoreDownSetAddCompletedSpaceHandle = class( TRestoreDownWriteHandle )
  public
    AddCompletedSpace : int64;
  public
    procedure SetAddCompletedSpace( _AddCompletedSpace : int64 );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToFace;
     procedure SetToXml;
  end;

    // 修改
  TRestoreDownSetCompletedSizeHandle = class( TRestoreDownWriteHandle )
  public
    CompletedSize : int64;
  public
    procedure SetCompletedSize( _CompletedSize : int64 );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToFace;
     procedure SetToXml;
  end;

  {$EndRegion}

  {$Region ' 续传信息 ' }

      // 修改
  TShareDownContinusWriteHandle = class( TRestoreDownWriteHandle )
  public
    FilePath : string;
  public
    procedure SetFilePath( _FilePath : string );
  end;

      // 读取
  TShareDownContinusReadHandle = class( TShareDownContinusWriteHandle )
  public
    FileSize : int64;
    FileTime : TDateTime;
  public
    procedure SetFileInfo( _FileSize : int64; _FileTime : TDateTime );
    procedure Update;virtual;
  private
    procedure AddToInfo;
  end;

    // 添加
  TShareDownContinusAddHandle = class( TShareDownContinusReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 删除
  TShareDownContinusRemoveHandle = class( TShareDownContinusWriteHandle )
  protected
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromXml;
  end;

  {$EndRegion}

  {$Region ' 恢复文件版本 ' }

    // 清空
  TRestoreFileEditionClearHandle = class( TRestoreDownWriteHandle )
  public
    procedure Update;
  private
    procedure ClearToInfo;
    procedure ClearToXml;
  end;

      // 读取
  TRestoreFileEditionReadHandle = class( TRestoreDownWriteHandle )
  public
    FilePath : string;
    EditionNum : Integer;
  public
    procedure SetFilePath( _FilePath : string );
    procedure SetEditionNum( _EditionNum : Integer );
    procedure Update;virtual;
  private
    procedure AddToInfo;
  end;

    // 添加
  TRestoreFileEditionAddHandle = class( TRestoreFileEditionReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

  {$EndRegion}

  {$Region ' 速度信息 ' }

    // 读取 速度限制
  TRestoreSpeedLimitReadHandle = class
  public
    IsLimit : Boolean;
    LimitType, LimitValue : Integer;
  public
    constructor Create( _IsLimit : Boolean );
    procedure SetLimitInfo( _LimitType, _LimitValue : Integer );
    procedure Update;virtual;
  private
    procedure SetToInfo;
    procedure SetToFace;
  end;

    // 设置 速度限制
  TRestoreSpeedLimitHandle = class( TRestoreSpeedLimitReadHandle )
  public
    procedure Update;override;
  private
    procedure SetToXml;
  end;

  {$EndRegion}

  {$Region ' 错误信息 ' }

        // 添加 错误
  TRestoreDownErrorAddHandle = class( TRestoreDownWriteHandle )
  public
    FilePath : string;
    FileSize, CompletedSpace : Int64;
    ErrorStatus : string;
  public
    procedure SetFilePath( _FilePath : string );
    procedure SetSpaceInfo( _FileSize, _CompletedSpace : Int64 );
    procedure SetErrorStatus( _ErrorStatus : string );
    procedure Update;
  private
    procedure AddToFace;
  end;

    // 清空 错误
  TRestoreDownErrorClearHandle = class( TRestoreDownWriteHandle )
  public
    procedure Update;
  private
    procedure ClearToFace;
  end;

  {$EndRegion}

  {$Region ' 恢复操作 ' }

    // 恢复选中 父类
  TRestoreSelectItemHandle = class( TRestoreDownWriteHandle )
  public
    procedure Update;
  protected
    procedure AddToScan;virtual;abstract;
  end;

    // 恢复 本地
  TRestoreSelectLocalItemHandle = class( TRestoreSelectItemHandle )
  protected
    procedure AddToScan;override;
  end;

    // 恢复 网络
  TRestoreSelectNetworkItemHandle = class( TRestoreSelectItemHandle )
  protected
    procedure AddToScan;override;
  end;

    // 恢复 停止
  TRestoreItemStopHandle = class( TRestoreDownWriteHandle )
  public
    procedure Update;
  end;

    // 恢复 完成
  TRestoreCompletedHandle = class( TRestoreDownWriteHandle )
  public
    procedure Update;
  private
    procedure AddToHint;
  end;

    // Pc 上线，启动恢复
  TCheckPcOnlineRestoreHandle = class
  public
    OnlinePcID : string;
  public
    constructor Create( _DesPcID : string );
    procedure Update;
  end;

    // 程序运行，启动自动恢复
  TCheckLocalOnlineRestoreHandle = class
  public
    procedure Update;
  end;

    // 开始恢复
  TRestoreStartHandle = class
  public
    procedure Update;
  private
    procedure SetToFace;
  end;

    // 结束恢复
  TRestoreStopHandle = class
  public
    procedure Update;
  private
    procedure SetToFace;
  end;

      // 暂停恢复
  TRestorePauseHandle = class
  public
    procedure Update;
  private
    procedure SetToFace;
  end;

    // 继续恢复
  TRestoreContinusHandle = class
  public
    procedure Update;
  private
    procedure StartLocalRestore;
    procedure StartNetworkRestore;
  end;

  {$EndRegion}

  {$Region ' 信息读取 ' }

  RestoreSpeedInfoReadUtil = class
  public
    class function getIsLimit : Boolean;
    class function getLimitType : Integer;
    class function getLimitValue : Integer;
    class function getLimitSpeed : Int64;
  end;

{$EndRegion}

    // 添加 参数
  TRestoreDownAddParams = record
  public
    RestorePath, OwnerPcID, RestoreFrom : string;
    OwnerName : string;
    IsFile : Boolean;
  public
    IsDeleted : Boolean;
    EditionNum : Integer;
  public
    IsEncrypt : Boolean;
    Password : string;
  public
    FileCount : integer;
    FileSize : int64;
  public
    SavePath : string;
  end;

    // 设置空间 参数
  TRestoreDownSetSpaceParams = record
  public
    RestorePath, OwnerPcID, RestoreFrom : string;
  public
    FileCount : integer;
    FileSize, CompletedSize : int64;
  end;

    // APi
  RestoreDownUserApi = class
  public
    class procedure AddLocalItem( Params : TRestoreDownAddParams );
    class procedure AddNetworkItem( Params : TRestoreDownAddParams );
    class procedure RemoveItem( RestorePath, OwnerPcID, RestoreFrom : string );
  public
    class procedure RestoreSelectLocalItem( RestorePath, OwnerPcID, RestoreFrom : string );
    class procedure RestoreSelectNetworkItem( RestorePath, OwnerPcID, RestoreFrom : string );
  end;

  RestoreDownAppApi = class
  public               // 恢复过程状态
    class procedure WaitingRestore( RestorePath, OwnerPcID, RestoreFrom : string );
    class procedure SetAnalyzeRestore( RestorePath, OwnerPcID, RestoreFrom : string );
    class procedure SetScaningCount( RestorePath, OwnerPcID, RestoreFrom : string; FileCount : Integer );
    class procedure SetSpaceInfo( Params : TRestoreDownSetSpaceParams );
    class procedure SetStartRestore( RestorePath, OwnerPcID, RestoreFrom : string );
    class procedure SetSpeed( RestorePath, OwnerPcID, RestoreFrom : string; Speed : Int64 );
    class procedure AddCompletedSpace( RestorePath, OwnerPcID, RestoreFrom : string; CompletedSpace : Int64 );
    class procedure RestoreCompleted( RestorePath, OwnerPcID, RestoreFrom : string );
    class procedure RestoreStop( RestorePath, OwnerPcID, RestoreFrom : string );
  public
    class procedure SetStatus( RestorePath, OwnerPcID, RestoreFrom, NodeStatus : string );
    class procedure SetIsExist( RestorePath, OwnerPcID , RestoreFrom : string; IsExist : Boolean );
    class procedure SetIsWrite( RestorePath, OwnerPcID , RestoreFrom : string; IsWrite : Boolean );
    class procedure SetIsLackSpace( RestorePath, OwnerPcID, RestoreFrom : string; IsLackSpace : Boolean );
    class procedure SetIsDesBusy( RestorePath, OwnerPcID, RestoreFrom : string; IsDesBusy : Boolean );
    class procedure SetIsLostConn( RestorePath, OwnerPcID, RestoreFrom : string; IsLostConn : Boolean );
    class procedure SetIsConnected( RestorePath, OwnerPcID, RestoreFrom : string; IsConnected : Boolean );
    class procedure SetPcOnline( DesPcID : string; IsOnline : Boolean );
    class procedure SetIsRestoring( RestorePath, OwnerPcID, RestoreFrom : string; IsRestoring : Boolean );
    class procedure SetIsCompleted( RestorePath, OwnerPcID, RestoreFrom : string; IsCompleted : Boolean );
    class procedure SetCompletedSpace( RestorePath, OwnerPcID, RestoreFrom : string; CompletedSpace : Int64 );
  public              // 续传
    class procedure CheckLocalRestoreOnline;
    class procedure CheckPcOnlineRestore( DesPcID : string );
  public              // 开始/结束 暂停/继续 恢复
    class procedure StartRestore;
    class procedure StopRestore;
    class procedure PauseRestore;
    class procedure ContinusRestore;
  end;

    // 添加 参数
  TRestoreDownContinusAddParams = record
  public
    RestorePath, OwnerPcID, RestoreFrom : string;
    FilePath : string;
    FileSize, Position : Int64;
    FileTime : TDateTime;
  end;


    // 共享下载 续传
  RestoreDownContinusApi = class
  public
    class procedure AddItem( Params : TRestoreDownContinusAddParams );
    class procedure RemoveItem( RestorePath, OwnerPcID, RestoreFrom, FilePath : string );
  end;

    // 添加 参数
  TRestoreDownErrorAddParams = record
  public
    RestorePath, OwnerPcID, RestoreFrom : string;
    FilePath : string;
    FileSize, CompletedSize : Int64;
    ErrorStatus : string;
  end;

    // 下载的错误信息
  RestoreDownErrorApi = class
  public
    class procedure ReadFileError( Params : TRestoreDownErrorAddParams );
    class procedure WriteFileError( Params : TRestoreDownErrorAddParams );
    class procedure ReceiveFileError( Params : TRestoreDownErrorAddParams );
    class procedure LostConnectFileError( Params : TRestoreDownErrorAddParams );
    class procedure ClearItem( RestorePath, OwnerPcID, RestoreFrom : string );
  private
    class procedure AddItem( Params : TRestoreDownErrorAddParams );
  end;

      // 添加 参数
  TRestoreFileEditionAddParams = record
  public
    RestorePath, OwnerPcID, RestoreFrom : string;
    FilePath : string;
    EditionNum : Integer;
  end;

    // 文件版本
  RestoreFileEditionApi = class
  public
    class procedure AddItem( Params : TRestoreFileEditionAddParams );
    class procedure ClearItems( RestorePath, OwnerPcID, RestoreFrom : string );
  end;

    // 恢复限速
  RestoreSpeedApi = class
  public
    class procedure SetLimit( IsLimit : Boolean; LimitType, LimitValue : Integer );
  end;

{$EndRegion}

const
  OwnerID_MyComputer = 'My Computer';
  OwnerName_MyComputer = 'My Computer';

const
  HistoryCount_Max = 15;

implementation

uses UMyRestoreFaceInfo, UMyNetPcInfo, UMyRestoreDataInfo, UMyRestoreXmlInfo, URestoreThread,
     UFormRestoreExplorer, UFormSelectRestore, UMyUtil, UCloudThread, UMyBackupApiInfo, UMainApi;

constructor TRestoreDesWriteHandle.Create( _DesItemID : string );
begin
  DesItemID := _DesItemID;
end;

{ TRestorePcReadHandle }

procedure TRestoreDesAddNetworkHandle.AddToFace;
var
  DesPcName : string;
  RestoreDesAddNetworkFace : TRestoreDesAddNetworkFace;
begin
  DesPcName := MyNetPcInfoReadUtil.ReadDesItemShow( DesItemID );

  RestoreDesAddNetworkFace := TRestoreDesAddNetworkFace.Create( DesItemID );
  RestoreDesAddNetworkFace.SetPcName( DesPcName );
  RestoreDesAddNetworkFace.AddChange;
end;

procedure TRestoreDesAddNetworkHandle.Update;
begin
  AddToFace;
end;


{ TRestorePcRemoveHandle }

procedure TRestoreDesRemoveHandle.RemoveFromFace;
var
  RestorePcRemoveFace : TNetworkRestoreDesRemoveFace;
begin
  RestorePcRemoveFace := TNetworkRestoreDesRemoveFace.Create( DesItemID );
  RestorePcRemoveFace.AddChange;
end;

procedure TRestoreDesRemoveHandle.Update;
begin
  RemoveFromFace;
end;

procedure TRestoreItemWriteHandle.SetBackupPath( _BackupPath : string );
begin
  BackupPath := _BackupPath;
end;

{ TRestorePcBackupReadHandle }

procedure TRestoreItemAddHandle.SetEncryptedInfo(_IsEncrypted: Boolean;
  _Password, _PasswordHint: string);
begin
  IsEncrypted := _IsEncrypted;
  Password := _Password;
  PasswordHint := _PasswordHint;
end;

procedure TRestoreItemAddHandle.SetIsFile( _IsFile : boolean );
begin
  IsFile := _IsFile;
end;

procedure TRestoreItemAddHandle.SetIsSaveDeleted(_IsSaveDeleted: Boolean);
begin
  IsSaveDeleted := _IsSaveDeleted;
end;

procedure TRestoreItemAddHandle.SetLastBackupTime(_LastBackupTime: TDateTime);
begin
  LastBackupTime := _LastBackupTime;
end;

procedure TRestoreItemAddHandle.SetOwnerName( _OwnerName : string );
begin
  OwnerName := _OwnerName;
end;

procedure TRestoreItemAddHandle.SetSpaceInfo( _FileCount : integer; _FileSize : int64 );
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
end;

{ TRestorePcBackupRemoveHandle }

procedure TRestoreItemRemoveHandle.RemoveFromFace;
var
  RestorePcBackupRemoveFace : TRestoreItemRemoveFace;
begin
  RestorePcBackupRemoveFace := TRestoreItemRemoveFace.Create( DesItemID );
  RestorePcBackupRemoveFace.SetOwnerID( OwnerID );
  RestorePcBackupRemoveFace.SetBackupPath( BackupPath );
  RestorePcBackupRemoveFace.AddChange;
end;


procedure TRestoreItemRemoveHandle.Update;
begin
  RemoveFromFace;
end;

procedure TRestoreItemWriteHandle.SetOwnerID(_OwnerID: string);
begin
  OwnerID := _OwnerID;
end;

{ TRestoreDownReadHandle }

procedure TRestoreDownReadHandle.SetEncryptInfo(_IsEncrypt: Boolean;
  _Password: string);
begin
  IsEncrypt := _IsEncrypt;
  Password := _Password;
end;

procedure TRestoreDownReadHandle.SetIsCompleted(_IsCompleted: Boolean);
begin
  IsCompleted := _IsCompleted;
end;

procedure TRestoreDownReadHandle.SetDeletedInfo(_IsDeleted: Boolean;
  _EditionNum : Integer);
begin
  IsDeleted := _IsDeleted;
  EditionNum := _EditionNum;
end;

procedure TRestoreDownReadHandle.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TRestoreDownReadHandle.SetOwnerName(_OwnerName: string);
begin
  OwnerName := _OwnerName;
end;

procedure TRestoreDownReadHandle.SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TRestoreDownReadHandle.SetSavePath( _SavePath : string );
begin
  SavePath := _SavePath;
end;

{ TRestoreDownRemoveHandle }

procedure TRestoreDownRemoveHandle.RemoveFromInfo;
var
  RestoreDownRemoveInfo : TRestoreDownRemoveInfo;
begin
  RestoreDownRemoveInfo := TRestoreDownRemoveInfo.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownRemoveInfo.Update;
  RestoreDownRemoveInfo.Free;
end;

procedure TRestoreDownRemoveHandle.RemoveFromFace;
var
  RestoreDownRemoveFace : TRestoreDownRemoveFace;
begin
  RestoreDownRemoveFace := TRestoreDownRemoveFace.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownRemoveFace.AddChange;
end;

procedure TRestoreDownRemoveHandle.RemoveFromXml;
var
  RestoreDownRemoveXml : TRestoreDownRemoveXml;
begin
  RestoreDownRemoveXml := TRestoreDownRemoveXml.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownRemoveXml.AddChange;
end;

procedure TRestoreDownRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromFace;
  RemoveFromXml;
end;






{ RestoreDownUserApi }

class procedure RestoreDownUserApi.AddLocalItem(Params: TRestoreDownAddParams);
var
  RestoreDownAddLocalHandle : TRestoreDownAddLocalHandle;
begin
    // 添加
  RestoreDownAddLocalHandle := TRestoreDownAddLocalHandle.Create( Params.RestorePath, Params.OwnerPcID, Params.RestoreFrom );
  RestoreDownAddLocalHandle.SetIsFile( Params.IsFile );
  RestoreDownAddLocalHandle.SetIsCompleted( False );
  RestoreDownAddLocalHandle.SetOwnerName( Params.OwnerName );
  RestoreDownAddLocalHandle.SetSpaceInfo( Params.FileCount, Params.FileSize, 0 );
  RestoreDownAddLocalHandle.SetDeletedInfo( Params.IsDeleted, Params.EditionNum );
  RestoreDownAddLocalHandle.SetEncryptInfo( Params.IsEncrypt, Params.Password );
  RestoreDownAddLocalHandle.SetSavePath( Params.SavePath );
  RestoreDownAddLocalHandle.Update;
  RestoreDownAddLocalHandle.Free;


    // 开始 恢复
  RestoreSelectLocalItem( Params.RestorePath, Params.OwnerPcID, Params.RestoreFrom );
end;

class procedure RestoreDownUserApi.AddNetworkItem(
  Params: TRestoreDownAddParams);
var
  RestoreDownAddNetworkHandle : TRestoreDownAddNetworkHandle;
begin
    // 添加
  RestoreDownAddNetworkHandle := TRestoreDownAddNetworkHandle.Create( Params.RestorePath, Params.OwnerPcID, Params.RestoreFrom );
  RestoreDownAddNetworkHandle.SetIsOnline( True );
  RestoreDownAddNetworkHandle.SetIsFile( Params.IsFile );
  RestoreDownAddNetworkHandle.SetIsCompleted( False );
  RestoreDownAddNetworkHandle.SetOwnerName( Params.OwnerName );
  RestoreDownAddNetworkHandle.SetSpaceInfo( Params.FileCount, Params.FileSize, 0 );
  RestoreDownAddNetworkHandle.SetDeletedInfo( Params.IsDeleted, Params.EditionNum );
  RestoreDownAddNetworkHandle.SetEncryptInfo( Params.IsEncrypt, Params.Password );
  RestoreDownAddNetworkHandle.SetSavePath( Params.SavePath );
  RestoreDownAddNetworkHandle.Update;
  RestoreDownAddNetworkHandle.Free;

    // 开始 恢复
  RestoreSelectNetworkItem( Params.RestorePath, Params.OwnerPcID, Params.RestoreFrom );
end;

class procedure RestoreDownUserApi.RemoveItem(RestorePath,
  OwnerPcID, RestoreFrom: string);
var
  RestoreDownRemoveHandle : TRestoreDownRemoveHandle;
begin
  RestoreDownRemoveHandle := TRestoreDownRemoveHandle.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownRemoveHandle.Update;
  RestoreDownRemoveHandle.Free;
end;

class procedure RestoreDownUserApi.RestoreSelectLocalItem( RestorePath, OwnerPcID,
  RestoreFrom : string );
var
  RestoreSelectLocalItemHandle : TRestoreSelectLocalItemHandle;
begin
  RestoreSelectLocalItemHandle := TRestoreSelectLocalItemHandle.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreSelectLocalItemHandle.Update;
  RestoreSelectLocalItemHandle.Free;
end;

class procedure RestoreDownUserApi.RestoreSelectNetworkItem(RestorePath,
  OwnerPcID, RestoreFrom: string);
var
  RestoreSelectNetworkItemHandle : TRestoreSelectNetworkItemHandle;
begin
  RestoreSelectNetworkItemHandle := TRestoreSelectNetworkItemHandle.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreSelectNetworkItemHandle.Update;
  RestoreSelectNetworkItemHandle.Free;
end;

{ TRestoreDownReadLocalHandle }

procedure TRestoreDownReadLocalHandle.AddToFace;
var
  RestoreDownAddLocalFace : TRestoreDownAddLocalFace;
begin
  RestoreDownAddLocalFace := TRestoreDownAddLocalFace.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownAddLocalFace.SetIsFile( IsFile );
  RestoreDownAddLocalFace.SetIsCompleted( IsCompleted );
  RestoreDownAddLocalFace.SetOwnerPcName( OwnerName );
  RestoreDownAddLocalFace.SetFromPcName( RestoreFrom );
  RestoreDownAddLocalFace.SetSpaceInfo( FileCount, FileSize, CompletedSize );
  RestoreDownAddLocalFace.SetIsDeleted( IsDeleted );
  RestoreDownAddLocalFace.SetIsEncrypt( IsEncrypt );
  RestoreDownAddLocalFace.SetSavePath( SavePath );
  RestoreDownAddLocalFace.AddChange;
end;

procedure TRestoreDownReadLocalHandle.AddToInfo;
var
  RestoreDownAddLocalInfo : TRestoreDownAddLocalInfo;
begin
  RestoreDownAddLocalInfo := TRestoreDownAddLocalInfo.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownAddLocalInfo.SetIsFile( IsFile );
  RestoreDownAddLocalInfo.SetIsCompleted( IsCompleted );
  RestoreDownAddLocalInfo.SetSpaceInfo( FileCount, FileSize, CompletedSize );
  RestoreDownAddLocalInfo.SetDeletedInfo( IsDeleted, EditionNum );
  RestoreDownAddLocalInfo.SetEncryptInfo( IsEncrypt, Password );
  RestoreDownAddLocalInfo.SetSavePath( SavePath );
  RestoreDownAddLocalInfo.Update;
  RestoreDownAddLocalInfo.Free;
end;

procedure TRestoreDownReadLocalHandle.Update;
begin
  AddToInfo;
  AddToFace;
end;

{ TRestoreDownReadNetworkHandle }

procedure TRestoreDownReadNetworkHandle.AddToFace;
var
  FromPcName : string;
  RestoreDownAddNtworkFace : TRestoreDownAddNtworkFace;
begin
  FromPcName := MyNetPcInfoReadUtil.ReadDesItemShow( RestoreFrom );

  RestoreDownAddNtworkFace := TRestoreDownAddNtworkFace.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownAddNtworkFace.SetIsOnline( IsOnline );
  RestoreDownAddNtworkFace.SetIsFile( IsFile );
  RestoreDownAddNtworkFace.SetIsCompleted( IsCompleted );
  RestoreDownAddNtworkFace.SetOwnerPcName( OwnerName );
  RestoreDownAddNtworkFace.SetFromPcName( FromPcName );
  RestoreDownAddNtworkFace.SetIsDeleted( IsDeleted );
  RestoreDownAddNtworkFace.SetIsEncrypt( IsEncrypt );
  RestoreDownAddNtworkFace.SetSpaceInfo( FileCount, FileSize, CompletedSize );
  RestoreDownAddNtworkFace.SetSavePath( SavePath );
  RestoreDownAddNtworkFace.AddChange;
end;

procedure TRestoreDownReadNetworkHandle.AddToInfo;
var
  RestoreDownAddNetworkInfo : TRestoreDownAddNetworkInfo;
begin
  RestoreDownAddNetworkInfo := TRestoreDownAddNetworkInfo.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownAddNetworkInfo.SetIsFile( IsFile );
  RestoreDownAddNetworkInfo.SetIsCompleted( IsCompleted );
  RestoreDownAddNetworkInfo.SetSpaceInfo( FileCount, FileSize, CompletedSize );
  RestoreDownAddNetworkInfo.SetDeletedInfo( IsDeleted, EditionNum );
  RestoreDownAddNetworkInfo.SetEncryptInfo( IsEncrypt, Password );
  RestoreDownAddNetworkInfo.SetSavePath( SavePath );
  RestoreDownAddNetworkInfo.Update;
  RestoreDownAddNetworkInfo.Free;
end;

procedure TRestoreDownReadNetworkHandle.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TRestoreDownReadNetworkHandle.Update;
begin
  AddToInfo;
  AddToFace;
end;

{ TRestoreDownAddLocalHandle }

procedure TRestoreDownAddLocalHandle.AddToXml;
var
  RestoreDownAddLocalXml : TRestoreDownAddLocalXml;
begin
  RestoreDownAddLocalXml := TRestoreDownAddLocalXml.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownAddLocalXml.SetIsFile( IsFile );
  RestoreDownAddLocalXml.SetIsCompleted( IsCompleted );
  RestoreDownAddLocalXml.SetOwnerName( OwnerName );
  RestoreDownAddLocalXml.SetSpaceInfo( FileCount, FileSize, CompletedSize );
  RestoreDownAddLocalXml.SetDeletedInfo( IsDeleted, EditionNum );
  RestoreDownAddLocalXml.SetEncryptInfo( IsEncrypt, Password );
  RestoreDownAddLocalXml.SetSavePath( SavePath );
  RestoreDownAddLocalXml.AddChange;
end;

procedure TRestoreDownAddLocalHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TRestoreDownAddNetworkHandle }

procedure TRestoreDownAddNetworkHandle.AddToXml;
var
  RestoreDownAddNetworkXml : TRestoreDownAddNetworkXml;
begin
  RestoreDownAddNetworkXml := TRestoreDownAddNetworkXml.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownAddNetworkXml.SetIsFile( IsFile );
  RestoreDownAddNetworkXml.SetIsCompleted( IsCompleted );
  RestoreDownAddNetworkXml.SetOwnerName( OwnerName );
  RestoreDownAddNetworkXml.SetSpaceInfo( FileCount, FileSize, CompletedSize );
  RestoreDownAddNetworkXml.SetDeletedInfo( IsDeleted, EditionNum );
  RestoreDownAddNetworkXml.SetEncryptInfo( IsEncrypt, Password );
  RestoreDownAddNetworkXml.SetSavePath( SavePath );
  RestoreDownAddNetworkXml.AddChange;
end;

procedure TRestoreDownAddNetworkHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TRestoreDesAddLocalHandle }

procedure TRestoreDesAddLocalHandle.AddToXml;
var
  RestoreShowAddXml : TRestoreShowAddXml;
begin
  RestoreShowAddXml := TRestoreShowAddXml.Create( DesItemID );
  RestoreShowAddXml.AddChange;
end;

procedure TRestoreDesAddLocalHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TRestoreItemAddNetworkHandle }

procedure TRestoreItemAddNetworkHandle.AddToFace;
var
  RestoreItemAddNetworkFace : TRestoreItemAddNetworkFace;
  FrmRestorePcFilterAdd : TFrmRestorePcFilterAdd;
begin
  RestoreItemAddNetworkFace := TRestoreItemAddNetworkFace.Create( DesItemID );
  RestoreItemAddNetworkFace.SetOwnerID( OwnerID );
  RestoreItemAddNetworkFace.SetOwnerName( OwnerName );
  RestoreItemAddNetworkFace.SetBackupPath( BackupPath );
  RestoreItemAddNetworkFace.SetIsFile( IsFile );
  RestoreItemAddNetworkFace.SetSpaceInfo( FileCount, FileSize );
  RestoreItemAddNetworkFace.SetLastBackupTime( LastBackupTime );
  RestoreItemAddNetworkFace.SetIsSaveDeleted( IsSaveDeleted );
  RestoreItemAddNetworkFace.SetEncryptedInfo( IsEncrypted, Password, PasswordHint );
  RestoreItemAddNetworkFace.AddChange;

  FrmRestorePcFilterAdd := TFrmRestorePcFilterAdd.Create( OwnerID );
  FrmRestorePcFilterAdd.SetPcName( OwnerName );
  FrmRestorePcFilterAdd.AddChange;
end;

procedure TRestoreItemAddNetworkHandle.Update;
begin
  AddToFace;
end;

{ TRestoreItemAddLocalHandle }

procedure TRestoreItemAddLocalHandle.AddToXml;
var
  RestoreShowItemAddXml : TRestoreShowItemAddXml;
begin
  RestoreShowItemAddXml := TRestoreShowItemAddXml.Create( DesItemID );
  RestoreShowItemAddXml.SetBackupPath( BackupPath, OwnerID );
  RestoreShowItemAddXml.SetIsFile( IsFile );
  RestoreShowItemAddXml.SetOwnerName( OwnerName );
  RestoreShowItemAddXml.SetSpaceInfo( FileCount, FileSize );
  RestoreShowItemAddXml.SetLastBackupTime( LastBackupTime );
  RestoreShowItemAddXml.SetIsSaveDeleted( IsSaveDeleted );
  RestoreShowItemAddXml.SetEncryptedInfo( IsEncrypted, Password, PasswordHint );
  RestoreShowItemAddXml.AddChange;
end;

procedure TRestoreItemAddLocalHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ RestoreDesAppApi }

class procedure RestoreDesAppApi.AddLocalItem(DesPath: string);
var
  RestoreDesAddLocalHandle : TRestoreDesAddLocalHandle;
begin
  RestoreDesAddLocalHandle := TRestoreDesAddLocalHandle.Create( DesPath );
  RestoreDesAddLocalHandle.Update;
  RestoreDesAddLocalHandle.Free;
end;

class procedure RestoreDesAppApi.AddNetworkItem(DesItemID: string);
var
  RestoreDesAddNetworkHandle : TRestoreDesAddNetworkHandle;
begin
  RestoreDesAddNetworkHandle := TRestoreDesAddNetworkHandle.Create( DesItemID );
  RestoreDesAddNetworkHandle.Update;
  RestoreDesAddNetworkHandle.Free;
end;

class procedure RestoreDesAppApi.RemoveNetworkItem(DesItemID: string);
var
  RestoreNetworkDesRemoveHandle : TRestoreNetworkDesRemoveHandle;
begin
  RestoreNetworkDesRemoveHandle := TRestoreNetworkDesRemoveHandle.Create( DesItemID );
  RestoreNetworkDesRemoveHandle.Update;
  RestoreNetworkDesRemoveHandle.Free;
end;

class procedure RestoreDesAppApi.RemoveLocalItem(DesPath: string);
var
  RestoreLocalDesRemoveHandle : TRestoreLocalDesRemoveHandle;
begin
  RestoreLocalDesRemoveHandle := TRestoreLocalDesRemoveHandle.Create( DesPath );
  RestoreLocalDesRemoveHandle.Update;
  RestoreLocalDesRemoveHandle.Free;
end;

class procedure RestoreDesAppApi.SetPcOffline(DesPcID: string);
var
  RestoreDesOfflineHandle : TRestoreDesOfflineHandle;
begin
  RestoreDesOfflineHandle := TRestoreDesOfflineHandle.Create( DesPcID );
  RestoreDesOfflineHandle.Update;
  RestoreDesOfflineHandle.Free;
end;

{ RestoreItemAppApi }

class procedure RestoreItemAppApi.AddLocalItem(Params: TRestoreAddParams);
var
  RestoreItemAddLocalHandle : TRestoreItemAddLocalHandle;
begin
  RestoreItemAddLocalHandle := TRestoreItemAddLocalHandle.Create( Params.DesItemID );
  RestoreItemAddLocalHandle.SetOwnerID( Params.OwnerID );
  RestoreItemAddLocalHandle.SetOwnerName( Params.OwnerName );
  RestoreItemAddLocalHandle.SetBackupPath( Params.BackupPath );
  RestoreItemAddLocalHandle.SetIsFile( Params.IsFile );
  RestoreItemAddLocalHandle.SetSpaceInfo( Params.FileCount, Params.ItemSize );
  RestoreItemAddLocalHandle.SetLastBackupTime( Params.LastBackupTime );
  RestoreItemAddLocalHandle.SetIsSaveDeleted( Params.IsSaveDeleted );
  RestoreItemAddLocalHandle.SetEncryptedInfo( Params.IsEncrypted, Params.Password, Params.PasswordHint );
  RestoreItemAddLocalHandle.Update;
  RestoreItemAddLocalHandle.Free;
end;

class procedure RestoreItemAppApi.AddNetworkItem(Params: TRestoreAddParams);
var
  RestoreItemAddNetworkHandle : TRestoreItemAddNetworkHandle;
begin
  RestoreItemAddNetworkHandle := TRestoreItemAddNetworkHandle.Create( Params.DesItemID );
  RestoreItemAddNetworkHandle.SetOwnerID( Params.OwnerID );
  RestoreItemAddNetworkHandle.SetOwnerName( Params.OwnerName );
  RestoreItemAddNetworkHandle.SetBackupPath( Params.BackupPath );
  RestoreItemAddNetworkHandle.SetIsFile( Params.IsFile );
  RestoreItemAddNetworkHandle.SetSpaceInfo( Params.FileCount, Params.ItemSize );
  RestoreItemAddNetworkHandle.SetLastBackupTime( Params.LastBackupTime );
  RestoreItemAddNetworkHandle.SetIsSaveDeleted( Params.IsSaveDeleted );
  RestoreItemAddNetworkHandle.SetEncryptedInfo( Params.IsEncrypted, Params.Password, Params.PasswordHint );
  RestoreItemAddNetworkHandle.Update;
  RestoreItemAddNetworkHandle.Free;
end;

class procedure RestoreItemAppApi.RemoveLocalItem(DesItemID,
  BackupPath, OwnerID: string);
var
  LocalRestoreItemRemoveHandle : TLocalRestoreItemRemoveHandle;
begin
  LocalRestoreItemRemoveHandle := TLocalRestoreItemRemoveHandle.Create( DesItemID );
  LocalRestoreItemRemoveHandle.SetOwnerID( OwnerID );
  LocalRestoreItemRemoveHandle.SetBackupPath( BackupPath );
  LocalRestoreItemRemoveHandle.Update;
  LocalRestoreItemRemoveHandle.Free;
end;

class procedure RestoreItemAppApi.RemoveNetworkItem(DesItemID, BackupPath,
  OwnerID: string);
var
  NetworkRestoreItemRemoveHandle : TNetworkRestoreItemRemoveHandle;
begin
  NetworkRestoreItemRemoveHandle := TNetworkRestoreItemRemoveHandle.Create( DesItemID );
  NetworkRestoreItemRemoveHandle.SetOwnerID( OwnerID );
  NetworkRestoreItemRemoveHandle.SetBackupPath( BackupPath );
  NetworkRestoreItemRemoveHandle.Update;
  NetworkRestoreItemRemoveHandle.Free;
end;

{ TRestoreDownWriteHandle }

constructor TRestoreDownWriteHandle.Create(_RestorePath, _OwnerPcID, _RestoreFrom: string);
begin
  RestorePath := _RestorePath;
  OwnerPcID := _OwnerPcID;
  RestoreFrom := _RestoreFrom;
end;

{ RestoreDownAppApi }

class procedure RestoreDownAppApi.AddCompletedSpace(RestorePath,
  OwnerPcID, RestoreFrom: string; CompletedSpace: Int64);
var
  RestoreDownSetAddCompletedSpaceHandle : TRestoreDownSetAddCompletedSpaceHandle;
begin
  RestoreDownSetAddCompletedSpaceHandle := TRestoreDownSetAddCompletedSpaceHandle.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetAddCompletedSpaceHandle.SetAddCompletedSpace( CompletedSpace );
  RestoreDownSetAddCompletedSpaceHandle.Update;
  RestoreDownSetAddCompletedSpaceHandle.Free;
end;



class procedure RestoreDownAppApi.CheckLocalRestoreOnline;
var
  CheckLocalOnlineRestoreHandle : TCheckLocalOnlineRestoreHandle;
begin
  CheckLocalOnlineRestoreHandle := TCheckLocalOnlineRestoreHandle.Create;
  CheckLocalOnlineRestoreHandle.Update;
  CheckLocalOnlineRestoreHandle.Free;
end;

class procedure RestoreDownAppApi.CheckPcOnlineRestore(DesPcID: string);
var
  CheckPcOnlineRestoreHandle : TCheckPcOnlineRestoreHandle;
begin
  CheckPcOnlineRestoreHandle := TCheckPcOnlineRestoreHandle.Create( DesPcID );
  CheckPcOnlineRestoreHandle.Update;
  CheckPcOnlineRestoreHandle.Free;
end;

class procedure RestoreDownAppApi.ContinusRestore;
var
  RestoreContinusHandle : TRestoreContinusHandle;
begin
  RestoreContinusHandle := TRestoreContinusHandle.Create;
  RestoreContinusHandle.Update;
  RestoreContinusHandle.Free;
end;

class procedure RestoreDownAppApi.PauseRestore;
var
  RestorePauseHandle : TRestorePauseHandle;
begin
  RestorePauseHandle := TRestorePauseHandle.Create;
  RestorePauseHandle.Update;
  RestorePauseHandle.Free;
end;

class procedure RestoreDownAppApi.RestoreCompleted(RestorePath,
  OwnerPcID, RestoreFrom: string);
var
  RestoreCompletedHandle : TRestoreCompletedHandle;
begin
  RestoreCompletedHandle := TRestoreCompletedHandle.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreCompletedHandle.Update;
  RestoreCompletedHandle.Free;
end;

class procedure RestoreDownAppApi.RestoreStop(RestorePath, OwnerPcID,
  RestoreFrom: string);
var
  RestoreStopHandle : TRestoreItemStopHandle;
begin
  RestoreStopHandle := TRestoreItemStopHandle.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreStopHandle.Update;
  RestoreStopHandle.Free;
end;

class procedure RestoreDownAppApi.SetAnalyzeRestore(RestorePath, OwnerPcID,
  RestoreFrom: string);
var
  RestoreDownAnalyzingHandle : TRestoreDownAnalyzingHandle;
begin
  RestoreDownAnalyzingHandle := TRestoreDownAnalyzingHandle.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownAnalyzingHandle.Update;
  RestoreDownAnalyzingHandle.Free;
end;

class procedure RestoreDownAppApi.SetCompletedSpace(RestorePath, OwnerPcID,
  RestoreFrom: string; CompletedSpace: Int64);
var
  RestoreDownSetCompletedSizeHandle : TRestoreDownSetCompletedSizeHandle;
begin
  RestoreDownSetCompletedSizeHandle := TRestoreDownSetCompletedSizeHandle.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetCompletedSizeHandle.SetCompletedSize( CompletedSpace );
  RestoreDownSetCompletedSizeHandle.Update;
  RestoreDownSetCompletedSizeHandle.Free;
end;



class procedure RestoreDownAppApi.SetIsCompleted(RestorePath, OwnerPcID,
  RestoreFrom: string; IsCompleted: Boolean);
var
  RestoreDownSetIsCompletedHandle : TRestoreDownSetIsCompletedHandle;
begin
  RestoreDownSetIsCompletedHandle := TRestoreDownSetIsCompletedHandle.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetIsCompletedHandle.SetIsCompleted( IsCompleted );
  RestoreDownSetIsCompletedHandle.Update;
  RestoreDownSetIsCompletedHandle.Free;
end;


class procedure RestoreDownAppApi.SetIsConnected(RestorePath, OwnerPcID,
  RestoreFrom: string; IsConnected: Boolean);
var
  RestoreDownSetIsConnectedHandle : TRestoreDownSetIsConnectedHandle;
begin
  RestoreDownSetIsConnectedHandle := TRestoreDownSetIsConnectedHandle.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetIsConnectedHandle.SetIsConnected( IsConnected );
  RestoreDownSetIsConnectedHandle.Update;
  RestoreDownSetIsConnectedHandle.Free;
end;

class procedure RestoreDownAppApi.SetIsDesBusy(RestorePath, OwnerPcID,
  RestoreFrom: string; IsDesBusy: Boolean);
var
  RestoreDownSetIsDesBusyHandle : TRestoreDownSetIsDesBusyHandle;
begin
  RestoreDownSetIsDesBusyHandle := TRestoreDownSetIsDesBusyHandle.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetIsDesBusyHandle.SetIsDesBusy( IsDesBusy );
  RestoreDownSetIsDesBusyHandle.Update;
  RestoreDownSetIsDesBusyHandle.Free;
end;

class procedure RestoreDownAppApi.SetIsExist(RestorePath,
  OwnerPcID , RestoreFrom: string; IsExist: Boolean);
var
  RestoreDownSetIsExistHandle : TRestoreDownSetIsExistHandle;
begin
  RestoreDownSetIsExistHandle := TRestoreDownSetIsExistHandle.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetIsExistHandle.SetIsExist( IsExist );
  RestoreDownSetIsExistHandle.Update;
  RestoreDownSetIsExistHandle.Free;
end;

class procedure RestoreDownAppApi.SetIsLackSpace(RestorePath,
  OwnerPcID, RestoreFrom: string; IsLackSpace: Boolean);
var
  RestoreDownSetIsLackSpaceHandle : TRestoreDownSetIsLackSpaceHandle;
begin
  RestoreDownSetIsLackSpaceHandle := TRestoreDownSetIsLackSpaceHandle.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetIsLackSpaceHandle.SetIsLackSpace( IsLackSpace );
  RestoreDownSetIsLackSpaceHandle.Update;
  RestoreDownSetIsLackSpaceHandle.Free;
end;

class procedure RestoreDownAppApi.SetIsLostConn(RestorePath, OwnerPcID,
  RestoreFrom: string; IsLostConn: Boolean);
var
  RestoreDownSetIsLostConnHandle : TRestoreDownSetIsLostConnHandle;
begin
  RestoreDownSetIsLostConnHandle := TRestoreDownSetIsLostConnHandle.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetIsLostConnHandle.SetIsLostConn( IsLostConn );
  RestoreDownSetIsLostConnHandle.Update;
  RestoreDownSetIsLostConnHandle.Free;
end;

class procedure RestoreDownAppApi.SetIsRestoring(RestorePath, OwnerPcID,
  RestoreFrom: string; IsRestoring: Boolean);
var
  RestoreDownSetIsRestoringHandle : TRestoreDownSetIsRestoringHandle;
begin
  RestoreDownSetIsRestoringHandle := TRestoreDownSetIsRestoringHandle.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetIsRestoringHandle.SetIsRestoring( IsRestoring );
  RestoreDownSetIsRestoringHandle.Update;
  RestoreDownSetIsRestoringHandle.Free;
end;



class procedure RestoreDownAppApi.SetIsWrite(RestorePath, OwnerPcID,
  RestoreFrom: string; IsWrite: Boolean);
var
  RestoreDownSetIsWriteHandle : TRestoreDownSetIsWriteHandle;
begin
  RestoreDownSetIsWriteHandle := TRestoreDownSetIsWriteHandle.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetIsWriteHandle.SetIsWrite( IsWrite );
  RestoreDownSetIsWriteHandle.Update;
  RestoreDownSetIsWriteHandle.Free;
end;



class procedure RestoreDownAppApi.SetPcOnline(DesPcID: string;
  IsOnline: Boolean);
var
  RestoreDownPcIsOnlineHandle : TRestoreDownPcIsOnlineHandle;
begin
  RestoreDownPcIsOnlineHandle := TRestoreDownPcIsOnlineHandle.Create( DesPcID );
  RestoreDownPcIsOnlineHandle.SetIsOnline( IsOnline );
  RestoreDownPcIsOnlineHandle.Update;
  RestoreDownPcIsOnlineHandle.Free;
end;

class procedure RestoreDownAppApi.SetStatus(RestorePath, OwnerPcID, RestoreFrom,
  NodeStatus: string);
var
  RestoreDownSetStautsHandle : TRestoreDownSetStautsHandle;
begin
  RestoreDownSetStautsHandle := TRestoreDownSetStautsHandle.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetStautsHandle.SetNodeStatus( NodeStatus );
  RestoreDownSetStautsHandle.Update;
  RestoreDownSetStautsHandle.Free;
end;

class procedure RestoreDownAppApi.SetScaningCount(RestorePath,
  OwnerPcID, RestoreFrom: string; FileCount: Integer);
var
  RestoreDownSetAnalyzeCountHandle : TRestoreDownSetAnalyzeCountHandle;
begin
  RestoreDownSetAnalyzeCountHandle := TRestoreDownSetAnalyzeCountHandle.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetAnalyzeCountHandle.SetAnalyzeCount( FileCount );
  RestoreDownSetAnalyzeCountHandle.Update;
  RestoreDownSetAnalyzeCountHandle.Free;
end;



class procedure RestoreDownAppApi.SetSpaceInfo(
  Params: TRestoreDownSetSpaceParams);
var
  RestoreDownSetSpaceInfoHandle : TRestoreDownSetSpaceInfoHandle;
begin
  RestoreDownSetSpaceInfoHandle := TRestoreDownSetSpaceInfoHandle.Create( Params.RestorePath, Params.OwnerPcID, Params.RestoreFrom );
  RestoreDownSetSpaceInfoHandle.SetSpaceInfo( Params.FileCount, Params.FileSize, Params.CompletedSize );
  RestoreDownSetSpaceInfoHandle.Update;
  RestoreDownSetSpaceInfoHandle.Free;
end;



class procedure RestoreDownAppApi.SetSpeed(RestorePath, OwnerPcID, RestoreFrom: string;
  Speed: Int64);
var
  RestoreDownSetSpeedHandle : TRestoreDownSetSpeedHandle;
begin
  RestoreDownSetSpeedHandle := TRestoreDownSetSpeedHandle.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetSpeedHandle.SetSpeed( Speed );
  RestoreDownSetSpeedHandle.Update;
  RestoreDownSetSpeedHandle.Free;
end;



class procedure RestoreDownAppApi.SetStartRestore(RestorePath, OwnerPcID, RestoreFrom: string);
begin
  SetSpeed( RestorePath, OwnerPcID, RestoreFrom, 0 );
  SetStatus( RestorePath, OwnerPcID, RestoreFrom, RestoreNodeStatus_Restoreing );
end;

class procedure RestoreDownAppApi.WaitingRestore(RestorePath,
  OwnerPcID, RestoreFrom: string);
begin
  SetStatus( RestorePath, OwnerPcID, RestoreFrom, RestoreNodeStatus_WaitingRestore );
end;


class procedure RestoreDownAppApi.StartRestore;
var
  RestoreStartHandle : TRestoreStartHandle;
begin
  RestoreStartHandle := TRestoreStartHandle.Create;
  RestoreStartHandle.Update;
  RestoreStartHandle.Free;
end;

class procedure RestoreDownAppApi.StopRestore;
var
  RestoreStopHandle : TRestoreStopHandle;
begin
  RestoreStopHandle := TRestoreStopHandle.Create;
  RestoreStopHandle.Update;
  RestoreStopHandle.Free;
end;

{ TRestoreDownSetStautsHandle }

procedure TRestoreDownSetStautsHandle.SetNodeStatus(_NodeStatus: string);
begin
  NodeStatus := _NodeStatus;
end;

procedure TRestoreDownSetStautsHandle.SetToFace;
var
  RestoreDownSetStautsFace : TRestoreDownSetStautsFace;
begin
  RestoreDownSetStautsFace := TRestoreDownSetStautsFace.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetStautsFace.SetNodeStatus( NodeStatus );
  RestoreDownSetStautsFace.AddChange;
end;

procedure TRestoreDownSetStautsHandle.Update;
begin
  SetToFace;
end;

{ TRestoreDownSetIsLackSpaceHandle }

procedure TRestoreDownSetIsLackSpaceHandle.SetIsLackSpace(
  _IsLackSpace: Boolean);
begin
  IsLackSpace := _IsLackSpace;
end;

procedure TRestoreDownSetIsLackSpaceHandle.SetToFace;
var
  RestoreDownSetIsLackSpaceFace : TRestoreDownSetIsLackSpaceFace;
begin
  RestoreDownSetIsLackSpaceFace := TRestoreDownSetIsLackSpaceFace.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetIsLackSpaceFace.SetIsLackSpace( IsLackSpace );
  RestoreDownSetIsLackSpaceFace.AddChange;
end;

procedure TRestoreDownSetIsLackSpaceHandle.Update;
begin
  SetToFace;
end;

{ TRestoreDownSetIsHandle }

procedure TRestoreDownSetIsExistHandle.SetIsExist(_IsExist: Boolean);
begin
  IsExist := _IsExist;
end;

procedure TRestoreDownSetIsExistHandle.SetToFace;
var
  RestoreDownSetIsExistFace : TRestoreDownSetIsExistFace;
begin
  RestoreDownSetIsExistFace := TRestoreDownSetIsExistFace.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetIsExistFace.SetIsExist( IsExist );
  RestoreDownSetIsExistFace.AddChange;
end;


procedure TRestoreDownSetIsExistHandle.Update;
begin
  SetToFace;
end;

{ TRestoreDownSetSpaceInfoHandle }

procedure TRestoreDownSetSpaceInfoHandle.SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TRestoreDownSetSpaceInfoHandle.SetToInfo;
var
  RestoreDownSetSpaceInfoInfo : TRestoreDownSetSpaceInfoInfo;
begin
  RestoreDownSetSpaceInfoInfo := TRestoreDownSetSpaceInfoInfo.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetSpaceInfoInfo.SetSpaceInfo( FileCount, FileSize, CompletedSize );
  RestoreDownSetSpaceInfoInfo.Update;
  RestoreDownSetSpaceInfoInfo.Free;
end;

procedure TRestoreDownSetSpaceInfoHandle.SetToXml;
var
  RestoreDownSetSpaceInfoXml : TRestoreDownSetSpaceInfoXml;
begin
  RestoreDownSetSpaceInfoXml := TRestoreDownSetSpaceInfoXml.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetSpaceInfoXml.SetSpaceInfo( FileCount, FileSize, CompletedSize );
  RestoreDownSetSpaceInfoXml.AddChange;
end;

procedure TRestoreDownSetSpaceInfoHandle.SetToFace;
var
  RestoreDownSetSpaceInfoFace : TRestoreDownSetSpaceInfoFace;
begin
  RestoreDownSetSpaceInfoFace := TRestoreDownSetSpaceInfoFace.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetSpaceInfoFace.SetSpaceInfo( FileCount, FileSize, CompletedSize );
  RestoreDownSetSpaceInfoFace.AddChange;
end;

procedure TRestoreDownSetSpaceInfoHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TRestoreDownSetAddCompletedSpaceHandle }

procedure TRestoreDownSetAddCompletedSpaceHandle.SetAddCompletedSpace( _AddCompletedSpace : int64 );
begin
  AddCompletedSpace := _AddCompletedSpace;
end;

procedure TRestoreDownSetAddCompletedSpaceHandle.SetToInfo;
var
  RestoreDownSetAddCompletedSpaceInfo : TRestoreDownSetAddCompletedSpaceInfo;
begin
  RestoreDownSetAddCompletedSpaceInfo := TRestoreDownSetAddCompletedSpaceInfo.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetAddCompletedSpaceInfo.SetAddCompletedSpace( AddCompletedSpace );
  RestoreDownSetAddCompletedSpaceInfo.Update;
  RestoreDownSetAddCompletedSpaceInfo.Free;
end;

procedure TRestoreDownSetAddCompletedSpaceHandle.SetToXml;
var
  RestoreDownSetAddCompletedSpaceXml : TRestoreDownSetAddCompletedSpaceXml;
begin
  RestoreDownSetAddCompletedSpaceXml := TRestoreDownSetAddCompletedSpaceXml.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetAddCompletedSpaceXml.SetAddCompletedSpace( AddCompletedSpace );
  RestoreDownSetAddCompletedSpaceXml.AddChange;
end;

procedure TRestoreDownSetAddCompletedSpaceHandle.SetToFace;
var
  RestoreDownSetAddCompletedSpaceFace : TRestoreDownSetAddCompletedSpaceFace;
begin
  RestoreDownSetAddCompletedSpaceFace := TRestoreDownSetAddCompletedSpaceFace.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetAddCompletedSpaceFace.SetAddCompletedSpace( AddCompletedSpace );
  RestoreDownSetAddCompletedSpaceFace.AddChange;
end;

procedure TRestoreDownSetAddCompletedSpaceHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TRestoreDownSetSpeedHandle }

procedure TRestoreDownSetSpeedHandle.SetSpeed( _Speed : integer );
begin
  Speed := _Speed;
end;

procedure TRestoreDownSetSpeedHandle.SetToFace;
var
  RestoreDownSetSpeedFace : TRestoreDownSetSpeedFace;
begin
  RestoreDownSetSpeedFace := TRestoreDownSetSpeedFace.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetSpeedFace.SetSpeed( Speed );
  RestoreDownSetSpeedFace.AddChange;
end;

procedure TRestoreDownSetSpeedHandle.Update;
begin
  SetToFace;
end;

{ TRestoreSelectLocalItemHandle }

procedure TRestoreSelectLocalItemHandle.AddToScan;
var
  LocalRestorePathInfo : TLocalRestorePathInfo;
begin
  LocalRestorePathInfo := TLocalRestorePathInfo.Create;
  LocalRestorePathInfo.SetItemInfo( RestorePath, OwnerPcID, RestoreFrom );
  MyRestoreHandler.AddRestorePath( LocalRestorePathInfo );
end;

{ TRestoreSelectItemHandle }

procedure TRestoreSelectItemHandle.Update;
begin
    // 正在恢复
  if RestoreDownInfoReadUtil.ReadIsRestoring( RestorePath, OwnerPcID, RestoreFrom ) then
    Exit;

    // 正在恢复
  RestoreDownAppApi.SetIsRestoring( RestorePath, OwnerPcID, RestoreFrom, True );

    // 刷新界面显示
  RestoreDownAppApi.WaitingRestore( RestorePath, OwnerPcID, RestoreFrom );

    // 设置 恢复未完成
  RestoreDownAppApi.SetIsCompleted( RestorePath, OwnerPcID, RestoreFrom, False );

    // 设置 非繁忙
  RestoreDownAppApi.SetIsDesBusy( RestorePath, OwnerPcID, RestoreFrom, False );

    // 设置 非断开连接
  RestoreDownAppApi.SetIsLostConn( RestorePath, OwnerPcID, RestoreFrom, False );

    // 清空之前的错误信息
  RestoreDownErrorApi.ClearItem( RestorePath, OwnerPcID, RestoreFrom );

    // 添加到扫描线程
  AddToScan;
end;

{ TRestoreSelectNetworkItemHandle }

procedure TRestoreSelectNetworkItemHandle.AddToScan;
var
  NetworkRestorePathInfo : TNetworkRestorePathInfo;
begin
  NetworkRestorePathInfo := TNetworkRestorePathInfo.Create;
  NetworkRestorePathInfo.SetItemInfo( RestorePath, OwnerPcID, RestoreFrom );
  MyRestoreHandler.AddRestorePath( NetworkRestorePathInfo );
end;

{ RestoreExplorerUserApi }

class procedure RestoreExplorerUserApi.ReadLocal(Params : TRestoreExplorerParams);
var
  RestoreScanLocalExplorerInfo : TLocalRestoreExplorerInfo;
begin
    // 扫描
  RestoreScanLocalExplorerInfo := TLocalRestoreExplorerInfo.Create;
  RestoreScanLocalExplorerInfo.SetItemInfo( Params.RestorePath, Params.OwnerID, Params.RestoreFrom );
  RestoreScanLocalExplorerInfo.SetExplorerInfo( Params.IsFile, Params.IsDeleted );
  RestoreScanLocalExplorerInfo.SetEncryptedInfo( Params.IsEncrypted, Params.PasswordExt );
  RestoreScanLocalExplorerInfo.SetIsSearch( Params.IsSerach );
  MyRestoreExplorerHandler.AddRestorePath( RestoreScanLocalExplorerInfo );
end;

class procedure RestoreExplorerUserApi.ReadNetwork(Params : TRestoreExplorerParams);
var
  RestoreScanNetworkExplorerInfo : TNetworkRestoreExplorerInfo;
begin
    // 扫描
  RestoreScanNetworkExplorerInfo := TNetworkRestoreExplorerInfo.Create;
  RestoreScanNetworkExplorerInfo.SetItemInfo( Params.RestorePath, Params.OwnerID, Params.RestoreFrom );
  RestoreScanNetworkExplorerInfo.SetExplorerInfo( Params.IsFile, Params.IsDeleted );
  RestoreScanNetworkExplorerInfo.SetEncryptedInfo( Params.IsEncrypted, Params.PasswordExt );
  RestoreScanNetworkExplorerInfo.SetIsSearch( Params.IsSerach );
  MyRestoreExplorerHandler.AddRestorePath( RestoreScanNetworkExplorerInfo );
end;

{ RestoreExplorerAppApi }

class procedure RestoreExplorerAppApi.ShowResult(Params: TExplorerResultParams);
var
  RestoreExplorerAddFace : TRestoreExplorerAddFace;
begin
  RestoreExplorerAddFace := TRestoreExplorerAddFace.Create( Params.FilePath );
  RestoreExplorerAddFace.SetIsFile( Params.IsFile );
  RestoreExplorerAddFace.SetFileInfo( Params.FileSize, Params.FileTime );
  RestoreExplorerAddFace.AddChange;
end;

{ TRestoreDownSetIsWriteHandle }

procedure TRestoreDownSetIsWriteHandle.SetIsWrite( _IsWrite : boolean );
begin
  IsWrite := _IsWrite;
end;

procedure TRestoreDownSetIsWriteHandle.SetToFace;
var
  RestoreDownSetIsWriteFace : TRestoreDownSetIsWriteFace;
begin
  RestoreDownSetIsWriteFace := TRestoreDownSetIsWriteFace.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetIsWriteFace.SetIsWrite( IsWrite );
  RestoreDownSetIsWriteFace.AddChange;
end;

procedure TRestoreDownSetIsWriteHandle.Update;
begin
  SetToFace;
end;

{ TRestoreDownPcIsOnlineHandle }

constructor TRestoreDownPcIsOnlineHandle.Create(_DesPcID: string);
begin
  DesPcID := _DesPcID;
end;

procedure TRestoreDownPcIsOnlineHandle.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TRestoreDownPcIsOnlineHandle.SetToFace;
var
  RestoreDownSetPcIsOnlineFace : TRestoreDownSetPcIsOnlineFace;
begin
  RestoreDownSetPcIsOnlineFace := TRestoreDownSetPcIsOnlineFace.Create( DesPcID );
  RestoreDownSetPcIsOnlineFace.SetIsOnline( IsOnline );
  RestoreDownSetPcIsOnlineFace.AddChange;
end;

procedure TRestoreDownPcIsOnlineHandle.Update;
begin
  SetToFace;
end;

{ TRestoreDesOfflineHandle }

constructor TRestoreDesOfflineHandle.Create(_DesPcID: string);
begin
  DesPcID := _DesPcID;
end;

procedure TRestoreDesOfflineHandle.SetToFace;
var
  RestoreDesFaceOffline : TRestoreDesFaceOffline;
begin
  RestoreDesFaceOffline := TRestoreDesFaceOffline.Create( DesPcID );
  RestoreDesFaceOffline.AddChange;
end;

procedure TRestoreDesOfflineHandle.Update;
begin
  SetToFace;
end;

{ TRestoreDownSetCompletedSizeHandle }

procedure TRestoreDownSetCompletedSizeHandle.SetCompletedSize( _CompletedSize : int64 );
begin
  CompletedSize := _CompletedSize;
end;

procedure TRestoreDownSetCompletedSizeHandle.SetToInfo;
var
  RestoreDownSetCompletedSizeInfo : TRestoreDownSetCompletedSizeInfo;
begin
  RestoreDownSetCompletedSizeInfo := TRestoreDownSetCompletedSizeInfo.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetCompletedSizeInfo.SetCompletedSize( CompletedSize );
  RestoreDownSetCompletedSizeInfo.Update;
  RestoreDownSetCompletedSizeInfo.Free;
end;

procedure TRestoreDownSetCompletedSizeHandle.SetToXml;
var
  RestoreDownSetCompletedSizeXml : TRestoreDownSetCompletedSizeXml;
begin
  RestoreDownSetCompletedSizeXml := TRestoreDownSetCompletedSizeXml.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetCompletedSizeXml.SetCompletedSize( CompletedSize );
  RestoreDownSetCompletedSizeXml.AddChange;
end;

procedure TRestoreDownSetCompletedSizeHandle.SetToFace;
var
  RestoreDownSetCompletedSizeFace : TRestoreDownSetCompletedSizeFace;
begin
  RestoreDownSetCompletedSizeFace := TRestoreDownSetCompletedSizeFace.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetCompletedSizeFace.SetCompletedSize( CompletedSize );
  RestoreDownSetCompletedSizeFace.AddChange;
end;

procedure TRestoreDownSetCompletedSizeHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;




{ TCheckPcOnlineRestoreHandle }

constructor TCheckPcOnlineRestoreHandle.Create(_DesPcID: string);
begin
  OnlinePcID := _DesPcID;
end;

procedure TCheckPcOnlineRestoreHandle.Update;
var
  OnlineRestoreList : TRestoreKeyItemList;
  OnlineRestoreInfo : TRestoreKeyItemInfo;
  i : Integer;
begin
  OnlineRestoreList := RestoreDownInfoReadUtil.ReadOnlineRestore( OnlinePcID );
  for i := 0 to OnlineRestoreList.Count - 1 do
  begin
    OnlineRestoreInfo := OnlineRestoreList[i];
    RestoreDownUserApi.RestoreSelectNetworkItem( OnlineRestoreInfo.RestorePath, OnlineRestoreInfo.OwnerPcID, OnlineRestoreInfo.RestoreFrom );
  end;
  OnlineRestoreList.Free
end;

{ TRestoreDownSetIsCompletedHandle }

procedure TRestoreDownSetIsCompletedHandle.SetIsCompleted( _IsCompleted : boolean );
begin
  IsCompleted := _IsCompleted;
end;

procedure TRestoreDownSetIsCompletedHandle.SetToInfo;
var
  RestoreDownSetIsCompletedInfo : TRestoreDownSetIsCompletedInfo;
begin
  RestoreDownSetIsCompletedInfo := TRestoreDownSetIsCompletedInfo.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetIsCompletedInfo.SetIsCompleted( IsCompleted );
  RestoreDownSetIsCompletedInfo.Update;
  RestoreDownSetIsCompletedInfo.Free;
end;

procedure TRestoreDownSetIsCompletedHandle.SetToXml;
var
  RestoreDownSetIsCompletedXml : TRestoreDownSetIsCompletedXml;
begin
  RestoreDownSetIsCompletedXml := TRestoreDownSetIsCompletedXml.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetIsCompletedXml.SetIsCompleted( IsCompleted );
  RestoreDownSetIsCompletedXml.AddChange;
end;

procedure TRestoreDownSetIsCompletedHandle.SetToFace;
var
  RestoreDownSetIsCompletedFace : TRestoreDownSetIsCompletedFace;
begin
  RestoreDownSetIsCompletedFace := TRestoreDownSetIsCompletedFace.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetIsCompletedFace.SetIsCompleted( IsCompleted );
  RestoreDownSetIsCompletedFace.AddChange;
end;

procedure TRestoreDownSetIsCompletedHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TCheckLocalOnlineRestoreHandle }

procedure TCheckLocalOnlineRestoreHandle.Update;
var
  OnlineRestoreList : TRestoreKeyItemList;
  OnlineRestoreInfo : TRestoreKeyItemInfo;
  i : Integer;
begin
  OnlineRestoreList := RestoreDownInfoReadUtil.ReadLocalStartRestore;
  for i := 0 to OnlineRestoreList.Count - 1 do
  begin
    OnlineRestoreInfo := OnlineRestoreList[i];
    RestoreDownUserApi.RestoreSelectLocalItem( OnlineRestoreInfo.RestorePath, OnlineRestoreInfo.OwnerPcID, OnlineRestoreInfo.RestoreFrom );
  end;
  OnlineRestoreList.Free
end;

{ TRestoreDownSetIsRestoringHandle }

procedure TRestoreDownSetIsRestoringHandle.SetIsRestoring( _IsRestoring : boolean );
begin
  IsRestoring := _IsRestoring;
end;

procedure TRestoreDownSetIsRestoringHandle.SetToInfo;
var
  RestoreDownSetIsRestoringInfo : TRestoreDownSetIsRestoringInfo;
begin
  RestoreDownSetIsRestoringInfo := TRestoreDownSetIsRestoringInfo.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetIsRestoringInfo.SetIsRestoring( IsRestoring );
  RestoreDownSetIsRestoringInfo.Update;
  RestoreDownSetIsRestoringInfo.Free;
end;


procedure TRestoreDownSetIsRestoringHandle.SetToFace;
var
  RestoreDownSetIsRestoringFace : TRestoreDownSetIsRestoringFace;
begin
  RestoreDownSetIsRestoringFace := TRestoreDownSetIsRestoringFace.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetIsRestoringFace.SetIsRestoring( IsRestoring );
  RestoreDownSetIsRestoringFace.AddChange;
end;

procedure TRestoreDownSetIsRestoringHandle.Update;
begin
  SetToInfo;
  SetToFace;
end;




{ TRestoreStopHandle }

procedure TRestoreItemStopHandle.Update;
begin
    // 设置 非正在恢复
  RestoreDownAppApi.SetIsRestoring( RestorePath, OwnerPcID, RestoreFrom, False );

    // 设置 界面状态为空
  RestoreDownAppApi.SetStatus( RestorePath, OwnerPcID, RestoreFrom, RestoreNodeStatus_Empty );
end;

{ TRestoreStopHandle }

procedure TRestoreStopHandle.SetToFace;
var
  RestoreDownStopFace : TRestoreDownStopFace;
begin
  RestoreDownStopFace := TRestoreDownStopFace.Create;
  RestoreDownStopFace.AddChange;
end;

procedure TRestoreStopHandle.Update;
begin
  SetToFace;
end;

{ TRestoreCompletedHandle }

procedure TRestoreCompletedHandle.AddToHint;
var
  Destination : string;
  IsFile : Boolean;
begin
  if OwnerPcID = OwnerID_MyComputer then
    Destination := RestoreFrom
  else
  begin
    Destination := NetworkDesItemUtil.getPcID( RestoreFrom );
    Destination := MyNetPcInfoReadUtil.ReadName( Destination );
  end;

  IsFile := RestoreDownInfoReadUtil.ReadIsFile( RestorePath, OwnerPcID, RestoreFrom );
  MyHintAppApi.ShowRestoreCompelted( RestorePath, Destination, IsFile );
end;


procedure TRestoreCompletedHandle.Update;
begin
    // 设置 备份完成
  RestoreDownAppApi.SetIsCompleted( RestorePath, OwnerPcID, RestoreFrom, True );

    // 添加到 Hint
  AddToHint;
end;

{ TRestoreStartHandle }

procedure TRestoreStartHandle.SetToFace;
var
  RestoreDownStartFace : TRestoreDownStartFace;
begin
  RestoreDownStartFace := TRestoreDownStartFace.Create;
  RestoreDownStartFace.AddChange;
end;

procedure TRestoreStartHandle.Update;
begin
  SetToFace;
end;

{ TRestoreDownSetAnalyzeCountHandle }

procedure TRestoreDownSetAnalyzeCountHandle.SetAnalyzeCount( _AnalyzeCount : integer );
begin
  AnalyzeCount := _AnalyzeCount;
end;

procedure TRestoreDownSetAnalyzeCountHandle.SetToFace;
var
  RestoreDownSetAnalyzeCountFace : TRestoreDownSetAnalyzeCountFace;
begin
  RestoreDownSetAnalyzeCountFace := TRestoreDownSetAnalyzeCountFace.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetAnalyzeCountFace.SetAnalyzeCount( AnalyzeCount );
  RestoreDownSetAnalyzeCountFace.AddChange;
end;

procedure TRestoreDownSetAnalyzeCountHandle.Update;
begin
  SetToFace;
end;

procedure TShareDownContinusWriteHandle.SetFilePath( _FilePath : string );
begin
  FilePath := _FilePath;
end;

{ TShareDownContinusReadHandle }

procedure TShareDownContinusReadHandle.SetFileInfo( _FileSize : int64;
  _FileTime : TDateTime );
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TShareDownContinusReadHandle.AddToInfo;
var
  ShareDownContinusAddInfo : TRestoreDownContinusAddInfo;
begin
  ShareDownContinusAddInfo := TRestoreDownContinusAddInfo.Create( RestorePath, OwnerPcID, RestoreFrom );
  ShareDownContinusAddInfo.SetFilePath( FilePath );
  ShareDownContinusAddInfo.SetFileInfo( FileSize, FileTime );
  ShareDownContinusAddInfo.Update;
  ShareDownContinusAddInfo.Free;
end;

procedure TShareDownContinusReadHandle.Update;
begin
  AddToInfo;
end;

{ TShareDownContinusAddHandle }

procedure TShareDownContinusAddHandle.AddToXml;
var
  ShareDownContinusAddXml : TRestoreDownContinusAddXml;
begin
  ShareDownContinusAddXml := TRestoreDownContinusAddXml.Create( RestorePath, OwnerPcID, RestoreFrom );
  ShareDownContinusAddXml.SetFilePath( FilePath );
  ShareDownContinusAddXml.SetFileInfo( FileSize, FileTime );
  ShareDownContinusAddXml.AddChange;
end;

procedure TShareDownContinusAddHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TShareDownContinusRemoveHandle }

procedure TShareDownContinusRemoveHandle.RemoveFromInfo;
var
  ShareDownContinusRemoveInfo : TRestoreDownContinusRemoveInfo;
begin
  ShareDownContinusRemoveInfo := TRestoreDownContinusRemoveInfo.Create( RestorePath, OwnerPcID, RestoreFrom );;
  ShareDownContinusRemoveInfo.SetFilePath( FilePath );
  ShareDownContinusRemoveInfo.Update;
  ShareDownContinusRemoveInfo.Free;
end;

procedure TShareDownContinusRemoveHandle.RemoveFromXml;
var
  ShareDownContinusRemoveXml : TRestoreDownContinusRemoveXml;
begin
  ShareDownContinusRemoveXml := TRestoreDownContinusRemoveXml.Create( RestorePath, OwnerPcID, RestoreFrom );
  ShareDownContinusRemoveXml.SetFilePath( FilePath );
  ShareDownContinusRemoveXml.AddChange;
end;

procedure TShareDownContinusRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromXml;
end;

class procedure RestoreDownContinusApi.AddItem(
  Params: TRestoreDownContinusAddParams);
var
  ShareDownContinusAddHandle : TShareDownContinusAddHandle;
begin
  ShareDownContinusAddHandle := TShareDownContinusAddHandle.Create( Params.RestorePath, Params.OwnerPcID, Params.RestoreFrom );
  ShareDownContinusAddHandle.SetFilePath( Params.FilePath );
  ShareDownContinusAddHandle.SetFileInfo( Params.FileSize, Params.FileTime );
  ShareDownContinusAddHandle.Update;
  ShareDownContinusAddHandle.Free;
end;


class procedure RestoreDownContinusApi.RemoveItem(RestorePath, OwnerPcID, RestoreFrom, FilePath: string);
var
  ShareDownContinusRemoveHandle : TShareDownContinusRemoveHandle;
begin
  ShareDownContinusRemoveHandle := TShareDownContinusRemoveHandle.Create( RestorePath, OwnerPcID, RestoreFrom );
  ShareDownContinusRemoveHandle.SetFilePath( FilePath );
  ShareDownContinusRemoveHandle.Update;
  ShareDownContinusRemoveHandle.Free;
end;

{ ShareDownErrorApi }

class procedure RestoreDownErrorApi.AddItem(Params: TRestoreDownErrorAddParams);
var
  ShareDownErrorAddHandle : TRestoreDownErrorAddHandle;
begin
  ShareDownErrorAddHandle := TRestoreDownErrorAddHandle.Create( Params.RestorePath, Params.OwnerPcID, Params.RestoreFrom );
  ShareDownErrorAddHandle.SetFilePath( Params.FilePath );
  ShareDownErrorAddHandle.SetSpaceInfo( Params.FileSize, Params.CompletedSize );
  ShareDownErrorAddHandle.SetErrorStatus( Params.ErrorStatus );
  ShareDownErrorAddHandle.Update;
  ShareDownErrorAddHandle.Free;
end;

class procedure RestoreDownErrorApi.ClearItem(RestorePath, OwnerPcID, RestoreFrom: string);
var
  ShareDownErrorClearHandle : TRestoreDownErrorClearHandle;
begin
  ShareDownErrorClearHandle := TRestoreDownErrorClearHandle.Create( RestorePath, OwnerPcID, RestoreFrom );
  ShareDownErrorClearHandle.Update;
  ShareDownErrorClearHandle.Free;
end;

class procedure RestoreDownErrorApi.LostConnectFileError(
  Params: TRestoreDownErrorAddParams);
begin
  Params.ErrorStatus := RestoreNodeStatus_LostConnectFileError;
  AddItem( Params );
end;

class procedure RestoreDownErrorApi.ReadFileError(
  Params: TRestoreDownErrorAddParams);
begin
  Params.ErrorStatus := RestoreNodeStatus_ReadFileError;
  AddItem( Params );
end;

class procedure RestoreDownErrorApi.ReceiveFileError(
  Params: TRestoreDownErrorAddParams);
begin
  Params.ErrorStatus := RestoreNodeStatus_ReceiveFileError;
  AddItem( Params );
end;

class procedure RestoreDownErrorApi.WriteFileError(
  Params: TRestoreDownErrorAddParams);
begin
  Params.ErrorStatus := RestoreNodeStatus_WriteFileError;
  AddItem( Params );
end;

{ TShareDownErrorAddHandle }

procedure TRestoreDownErrorAddHandle.AddToFace;
var
  SendItemErrorAddFace : TRestoreDownErrorAddFace;
begin
  SendItemErrorAddFace := TRestoreDownErrorAddFace.Create( RestorePath, OwnerPcID, RestoreFrom );
  SendItemErrorAddFace.SetFilePath( FilePath );
  SendItemErrorAddFace.SetSpaceInfo( FileSize, CompletedSpace );
  SendItemErrorAddFace.SetErrorStatus( ErrorStatus );
  SendItemErrorAddFace.AddChange;
end;

procedure TRestoreDownErrorAddHandle.SetErrorStatus(_ErrorStatus: string);
begin
  ErrorStatus := _ErrorStatus;
end;

procedure TRestoreDownErrorAddHandle.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TRestoreDownErrorAddHandle.SetSpaceInfo(_FileSize,
  _CompletedSpace: Int64);
begin
  FileSize := _FileSize;
  CompletedSpace := _CompletedSpace;
end;

procedure TRestoreDownErrorAddHandle.Update;
begin
  AddToFace;
end;

{ TShareDownErrorClearHandle }

procedure TRestoreDownErrorClearHandle.ClearToFace;
var
  SendItemErrorClearFace : TRestoreDownErrorClearFace;
begin
  SendItemErrorClearFace := TRestoreDownErrorClearFace.Create( RestorePath, OwnerPcID, RestoreFrom );
  SendItemErrorClearFace.AddChange;
end;

procedure TRestoreDownErrorClearHandle.Update;
begin
  ClearToFace;
end;


{ TRestoreDownSetIsDesBusyHandle }

procedure TRestoreDownSetIsDesBusyHandle.SetIsDesBusy(_IsDesBusy: boolean);
begin
  IsDesBusy := _IsDesBusy;
end;

procedure TRestoreDownSetIsDesBusyHandle.SetToFace;
var
  RestoreDownSetIsDesBusyFace : TRestoreDownSetIsDesBusyFace;
begin
  RestoreDownSetIsDesBusyFace := TRestoreDownSetIsDesBusyFace.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetIsDesBusyFace.SetIsDesBusy( IsDesBusy );
  RestoreDownSetIsDesBusyFace.AddChange;
end;

procedure TRestoreDownSetIsDesBusyHandle.SetToInfo;
var
  RestoreDownSetIsDesBusyInfo : TRestoreDownSetIsDesBusyInfo;
begin
  RestoreDownSetIsDesBusyInfo := TRestoreDownSetIsDesBusyInfo.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetIsDesBusyInfo.SetIsDesBusy( IsDesBusy );
  RestoreDownSetIsDesBusyInfo.Update;
  RestoreDownSetIsDesBusyInfo.Free;
end;

procedure TRestoreDownSetIsDesBusyHandle.Update;
begin
  SetToInfo;
  SetToFace;
end;

{ TRestoreDownSetIsConnectedHandle }

procedure TRestoreDownSetIsConnectedHandle.SetIsConnected(
  _IsConnected: Boolean);
begin
  IsConnected := _IsConnected;
end;

procedure TRestoreDownSetIsConnectedHandle.SetToFace;
var
  RestoreDownSetIsConnectedFace : TRestoreDownSetIsConnectedFace;
begin
  RestoreDownSetIsConnectedFace := TRestoreDownSetIsConnectedFace.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetIsConnectedFace.SetIsConnected( IsConnected );
  RestoreDownSetIsConnectedFace.AddChange;
end;

procedure TRestoreDownSetIsConnectedHandle.Update;
begin
  SetToFace;
end;

{ TRestorePauseHandle }

procedure TRestorePauseHandle.SetToFace;
var
  RestoreDownPauseFace : TRestoreDownPauseFace;
begin
  RestoreDownPauseFace := TRestoreDownPauseFace.Create;
  RestoreDownPauseFace.AddChange;
end;

procedure TRestorePauseHandle.Update;
begin
  SetToFace;
end;

{ TRestoreContinusHandle }

procedure TRestoreContinusHandle.StartLocalRestore;
begin
  RestoreDownAppApi.CheckLocalRestoreOnline;
end;

procedure TRestoreContinusHandle.StartNetworkRestore;
var
  OnlineRestoreList : TRestoreKeyItemList;
  OnlineRestoreInfo : TRestoreKeyItemInfo;
  i : Integer;
  DesPcID : string;
begin
  OnlineRestoreList := RestoreDownInfoReadUtil.ReadNetworkStartRestore;
  for i := 0 to OnlineRestoreList.Count - 1 do
  begin
    OnlineRestoreInfo := OnlineRestoreList[i];
    DesPcID := NetworkDesItemUtil.getPcID( OnlineRestoreInfo.RestoreFrom );
    if not MyNetPcInfoReadUtil.ReadIsOnline( DesPcID ) then // Pc 离线，跳过
      Continue;
    RestoreDownUserApi.RestoreSelectNetworkItem( OnlineRestoreInfo.RestorePath, OnlineRestoreInfo.OwnerPcID, OnlineRestoreInfo.RestoreFrom );
  end;
  OnlineRestoreList.Free
end;

procedure TRestoreContinusHandle.Update;
begin
  StartLocalRestore;
  StartNetworkRestore;
end;

class procedure RestoreExplorerAppApi.StartExplorer;
var
  ShareExplorerStartFace : TRestoreExplorerStartFace;
begin
  ShareExplorerStartFace := TRestoreExplorerStartFace.Create;
  ShareExplorerStartFace.AddChange;
end;

class procedure RestoreExplorerAppApi.StopExplorer;
var
  ShareExplorerStopFace : TRestoreExplorerStopFace;
begin
  ShareExplorerStopFace := TRestoreExplorerStopFace.Create;
  ShareExplorerStopFace.AddChange;
end;

class procedure RestoreExplorerAppApi.CloudPcBusy;
var
  ShareExplorerBusyFace : TRestoreExplorerBusyFace;
begin
  ShareExplorerBusyFace := TRestoreExplorerBusyFace.Create;
  ShareExplorerBusyFace.AddChange;
end;

class procedure RestoreExplorerAppApi.CloudPcNotConn;
var
  ShareExplorerNotConnFace : TRestoreExplorerNotConnFace;
begin
  ShareExplorerNotConnFace := TRestoreExplorerNotConnFace.Create;
  ShareExplorerNotConnFace.AddChange;
end;

{ TRestoreDesReadLocalHandle }

procedure TRestoreDesReadLocalHandle.AddToFace;
var
  RestoreDesAddLocalFace : TRestoreDesAddLocalFace;
begin
  RestoreDesAddLocalFace := TRestoreDesAddLocalFace.Create( DesItemID );
  RestoreDesAddLocalFace.AddChange;
end;

procedure TRestoreDesReadLocalHandle.Update;
begin
  AddToFace;
end;

{ TRestoreLocalDesRemoveHandle }

procedure TRestoreLocalDesRemoveHandle.RemoveFromXml;
var
  RestoreShowRemoveXml : TRestoreShowRemoveXml;
begin
  RestoreShowRemoveXml := TRestoreShowRemoveXml.Create( DesItemID );
  RestoreShowRemoveXml.AddChange;
end;

procedure TRestoreLocalDesRemoveHandle.Update;
begin
  inherited;
  RemoveFromXml;
end;

{ TRestoreItemReadLocalHandle }

procedure TRestoreItemReadLocalHandle.AddToFace;
var
  RestoreItemAddLocalFace : TRestoreItemAddLocalFace;
begin
  RestoreItemAddLocalFace := TRestoreItemAddLocalFace.Create( DesItemID );
  RestoreItemAddLocalFace.SetOwnerID( OwnerID );
  RestoreItemAddLocalFace.SetOwnerName( OwnerName );
  RestoreItemAddLocalFace.SetBackupPath( BackupPath );
  RestoreItemAddLocalFace.SetIsFile( IsFile );
  RestoreItemAddLocalFace.SetSpaceInfo( FileCount, FileSize );
  RestoreItemAddLocalFace.SetLastBackupTime( LastBackupTime );
  RestoreItemAddLocalFace.SetIsSaveDeleted( IsSaveDeleted );
  RestoreItemAddLocalFace.SetEncryptedInfo( IsEncrypted, Password, PasswordHint );
  RestoreItemAddLocalFace.AddChange;
end;

procedure TRestoreItemReadLocalHandle.Update;
begin
  AddToFace;
end;

{ TLocalRestoreItemRemoveHandle }

procedure TLocalRestoreItemRemoveHandle.RemoveBackupFile;
var
  FilePath, RecycleFilePath : string;
begin
  FilePath := MyFilePath.getLocalBackupPath( DesItemID, BackupPath );
  RecycleFilePath := MyFilePath.getLocalRecyclePath( DesItemID, BackupPath );

  MyCloudFileHandler.AddRemovePath( FilePath );
  MyCloudFileHandler.AddRemovePath( RecycleFilePath );
end;

procedure TLocalRestoreItemRemoveHandle.RemoveFromXml;
var
  RestoreShowItemRemoveXml : TRestoreShowItemRemoveXml;
begin
  RestoreShowItemRemoveXml := TRestoreShowItemRemoveXml.Create( DesItemID );
  RestoreShowItemRemoveXml.SetBackupPath( BackupPath, OwnerID );
  RestoreShowItemRemoveXml.AddChange;
end;

procedure TLocalRestoreItemRemoveHandle.Update;
begin
  inherited;
  RemoveFromXml;

    // 删除已备份的文件
  RemoveBackupFile;
end;

{ TBackupSpeedLimitHandle }

procedure TRestoreSpeedLimitHandle.SetToXml;
var
  RestoreSpeedLimitXml : TRestoreSpeedLimitXml;
begin
  RestoreSpeedLimitXml := TRestoreSpeedLimitXml.Create;
  RestoreSpeedLimitXml.SetIsLimit( IsLimit );
  RestoreSpeedLimitXml.SetLimitXml( LimitValue, LimitType );
  RestoreSpeedLimitXml.AddChange;
end;

procedure TRestoreSpeedLimitHandle.Update;
begin
  inherited;
  SetToXml;
end;

{ TBackupSpeedLimitReadHandle }


constructor TRestoreSpeedLimitReadHandle.Create(_IsLimit: Boolean);
begin
  IsLimit := _IsLimit;
end;

procedure TRestoreSpeedLimitReadHandle.SetLimitInfo(_LimitType,
  _LimitValue: Integer);
begin
  LimitType := _LimitType;
  LimitValue := _LimitValue;
end;

procedure TRestoreSpeedLimitReadHandle.SetToFace;
var
  RestoreSpeedLimitFace : TRestoreSpeedLimitFace;
  LimitSpeed : Int64;
begin
  LimitSpeed := RestoreSpeedInfoReadUtil.getLimitSpeed;

  RestoreSpeedLimitFace := TRestoreSpeedLimitFace.Create;
  RestoreSpeedLimitFace.SetIsLimit( IsLimit );
  RestoreSpeedLimitFace.SetLimitSpeed( LimitSpeed );
  RestoreSpeedLimitFace.AddChange;
end;

procedure TRestoreSpeedLimitReadHandle.SetToInfo;
var
  RestoreSpeedLimitInfo : TRestoreSpeedLimitInfo;
begin
  RestoreSpeedLimitInfo := TRestoreSpeedLimitInfo.Create;
  RestoreSpeedLimitInfo.SetIsLimit( IsLimit );
  RestoreSpeedLimitInfo.SetLimitInfo( LimitValue, LimitType );
  RestoreSpeedLimitInfo.Update;
  RestoreSpeedLimitInfo.Free;
end;

procedure TRestoreSpeedLimitReadHandle.Update;
begin
  SetToInfo;
  SetToFace;
end;

{ RestoreSpeedApi }

class procedure RestoreSpeedApi.SetLimit(IsLimit: Boolean; LimitType,
  LimitValue: Integer);
var
  RestoreSpeedLimitHandle : TRestoreSpeedLimitHandle;
begin
  RestoreSpeedLimitHandle := TRestoreSpeedLimitHandle.Create( IsLimit );
  RestoreSpeedLimitHandle.SetLimitInfo( LimitType, LimitValue );
  RestoreSpeedLimitHandle.Update;
  RestoreSpeedLimitHandle.Free;
end;

{ RestoreSpeedInfoReadUtil }

class function RestoreSpeedInfoReadUtil.getIsLimit: Boolean;
begin
  Result := MyRestoreDownInfo.RestoreSpeedInfo.IsLimit;
end;

class function RestoreSpeedInfoReadUtil.getLimitSpeed: Int64;
var
  LimitType, LimitValue : Integer;
  SizeBase : Int64;
begin
  LimitType := getLimitType;
  LimitValue := getLimitValue;

  SizeBase := Size_KB;
  if LimitType = LimitType_KB then
    SizeBase := Size_KB
  else
  if LimitType = LimitType_MB then
    SizeBase := Size_MB
  else
    SizeBase := Size_KB;

  Result := LimitValue * SizeBase;
end;

class function RestoreSpeedInfoReadUtil.getLimitType: Integer;
begin
  Result := MyRestoreDownInfo.RestoreSpeedInfo.LimitType;
end;

class function RestoreSpeedInfoReadUtil.getLimitValue: Integer;
begin
  Result := MyRestoreDownInfo.RestoreSpeedInfo.LimitValue;
end;

{ TRestoreDownAnalyzingHandle }

procedure TRestoreDownAnalyzingHandle.AddToHint;
var
  Destination : string;
  IsFile : Boolean;
begin
  if OwnerPcID = OwnerID_MyComputer then
    Destination := RestoreFrom
  else
  begin
    Destination := NetworkDesItemUtil.getPcID( RestoreFrom );
    Destination := MyNetPcInfoReadUtil.ReadName( Destination );
  end;

  IsFile := RestoreDownInfoReadUtil.ReadIsFile( RestorePath, OwnerPcID, RestoreFrom );
  MyHintAppApi.ShowRestoring( RestorePath, Destination, IsFile );
end;

procedure TRestoreDownAnalyzingHandle.Update;
begin
    // 重设分析数
  RestoreDownAppApi.SetScaningCount( RestorePath, OwnerPcID, RestoreFrom, 0 );

    // 设置状态
  RestoreDownAppApi.SetStatus( RestorePath, OwnerPcID, RestoreFrom, RestoreNodeStatus_Analyizing );

    // 添加到 Hint
  AddToHint;
end;

{ RestoreDeleteExplorerAppApi }

class procedure RestoreDeleteExplorerAppApi.ShowResult(
  Params: TExplorerResultParams);
var
  RestoreDeleteExplorerAddFace : TRestoreDeleteExplorerAddFace;
begin
  RestoreDeleteExplorerAddFace := TRestoreDeleteExplorerAddFace.Create( Params.FilePath );
  RestoreDeleteExplorerAddFace.SetIsFile( Params.IsFile );
  RestoreDeleteExplorerAddFace.SetFileInfo( Params.FileSize, Params.FileTime );
  RestoreDeleteExplorerAddFace.SetEditionNum( Params.EditionNum );
  RestoreDeleteExplorerAddFace.AddChange;
end;

class procedure RestoreDeleteExplorerAppApi.StartExplorer;
var
  ShareExplorerStartFace : TRestoreDeleteExplorerStartFace;
begin
  ShareExplorerStartFace := TRestoreDeleteExplorerStartFace.Create;
  ShareExplorerStartFace.AddChange;
end;

class procedure RestoreDeleteExplorerAppApi.StopExplorer;
var
  ShareExplorerStopFace : TRestoreDeleteExplorerStopFace;
begin
  ShareExplorerStopFace := TRestoreDeleteExplorerStopFace.Create;
  ShareExplorerStopFace.AddChange;
end;

class procedure RestoreDeleteExplorerAppApi.CloudPcBusy;
var
  ShareExplorerBusyFace : TRestoreDeleteExplorerBusyFace;
begin
  ShareExplorerBusyFace := TRestoreDeleteExplorerBusyFace.Create;
  ShareExplorerBusyFace.AddChange;
end;

class procedure RestoreDeleteExplorerAppApi.CloudPcNotConn;
var
  ShareExplorerNotConnFace : TRestoreDeleteExplorerNotConnFace;
begin
  ShareExplorerNotConnFace := TRestoreDeleteExplorerNotConnFace.Create;
  ShareExplorerNotConnFace.AddChange;
end;

{ RestoreSearchUserApi }

class procedure RestoreSearchUserApi.ReadLocal(Params : TRestoreSearchParams);
var
  RestoreScanLocalSearchInfo : TLocalRestoreSearchInfo;
begin
    // 扫描
  RestoreScanLocalSearchInfo := TLocalRestoreSearchInfo.Create;
  RestoreScanLocalSearchInfo.SetItemInfo( Params.RestorePath, Params.OwnerID, Params.RestoreFrom );
  RestoreScanLocalSearchInfo.SetSearchInfo( Params.IsFile, Params.HasDeleted );
  RestoreScanLocalSearchInfo.SetEncryptedInfo( Params.IsEncrypted, Params.PasswordExt );
  RestoreScanLocalSearchInfo.SetSearchName( Params.SerachName );
  MyRestoreSearchHandler.AddRestorePath( RestoreScanLocalSearchInfo );
end;

class procedure RestoreSearchUserApi.ReadNetwork(Params : TRestoreSearchParams);
var
  RestoreScanNetworkSearchInfo : TNetworkRestoreSearchInfo;
begin
    // 扫描
  RestoreScanNetworkSearchInfo := TNetworkRestoreSearchInfo.Create;
  RestoreScanNetworkSearchInfo.SetItemInfo( Params.RestorePath, Params.OwnerID, Params.RestoreFrom );
  RestoreScanNetworkSearchInfo.SetSearchInfo( Params.IsFile, Params.HasDeleted );
  RestoreScanNetworkSearchInfo.SetEncryptedInfo( Params.IsEncrypted, Params.PasswordExt );
  RestoreScanNetworkSearchInfo.SetSearchName( Params.SerachName );
  MyRestoreSearchHandler.AddRestorePath( RestoreScanNetworkSearchInfo );
end;

{ RestoreSearchAppApi }

class procedure RestoreSearchAppApi.ShowExplorer(Params : TExplorerResultParams);
var
  RestoreSearchExplorerAddFace : TRestoreSearchExplorerAddFace;
begin
  RestoreSearchExplorerAddFace := TRestoreSearchExplorerAddFace.Create( Params.FilePath );
  RestoreSearchExplorerAddFace.SetIsFile( Params.IsFile );
  RestoreSearchExplorerAddFace.SetFileInfo( Params.FileSize, Params.FileTime );
  RestoreSearchExplorerAddFace.SetDeletedInfo( False, Params.EditionNum );
  RestoreSearchExplorerAddFace.AddChange;
end;

class procedure RestoreSearchAppApi.ShowExplorerDeleted(
  Params: TExplorerResultParams);
var
  RestoreSearchExplorerAddFace : TRestoreSearchExplorerAddFace;
begin
  RestoreSearchExplorerAddFace := TRestoreSearchExplorerAddFace.Create( Params.FilePath );
  RestoreSearchExplorerAddFace.SetIsFile( Params.IsFile );
  RestoreSearchExplorerAddFace.SetFileInfo( Params.FileSize, Params.FileTime );
  RestoreSearchExplorerAddFace.SetDeletedInfo( True, Params.EditionNum );
  RestoreSearchExplorerAddFace.AddChange;
end;

class procedure RestoreSearchAppApi.ShowResult(Params: TSearchResultParams);
var
  RestoreSearchAddFace : TRestoreSearchAddFace;
begin
  RestoreSearchAddFace := TRestoreSearchAddFace.Create( Params.FilePath );
  RestoreSearchAddFace.SetIsFile( Params.IsFile );
  RestoreSearchAddFace.SetDeletedInfo( Params.IsDeleted, Params.EditionNum );
  RestoreSearchAddFace.SetFileInfo( Params.FileSize, Params.FileTime );
  RestoreSearchAddFace.AddChange;
end;

class procedure RestoreSearchAppApi.StartExplorer;
var
  ShareExplorerStartFace : TRestoreSearchStartFace;
begin
  ShareExplorerStartFace := TRestoreSearchStartFace.Create;
  ShareExplorerStartFace.AddChange;
end;

class procedure RestoreSearchAppApi.StopExplorer;
var
  ShareExplorerStopFace : TRestoreSearchStopFace;
begin
  ShareExplorerStopFace := TRestoreSearchStopFace.Create;
  ShareExplorerStopFace.AddChange;
end;

class procedure RestoreSearchAppApi.CloudPcBusy;
var
  ShareExplorerBusyFace : TRestoreSearchBusyFace;
begin
  ShareExplorerBusyFace := TRestoreSearchBusyFace.Create;
  ShareExplorerBusyFace.AddChange;
end;

class procedure RestoreSearchAppApi.CloudPcNotConn;
var
  ShareExplorerNotConnFace : TRestoreSearchNotConnFace;
begin
  ShareExplorerNotConnFace := TRestoreSearchNotConnFace.Create;
  ShareExplorerNotConnFace.AddChange;
end;

{ TRestoreFileEditionAddHandle }

procedure TRestoreFileEditionReadHandle.AddToInfo;
var
  RestoreFileEditionAddInfo : TRestoreFileEditionAddInfo;
begin
  RestoreFileEditionAddInfo := TRestoreFileEditionAddInfo.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreFileEditionAddInfo.SetFilePath( FilePath );
  RestoreFileEditionAddInfo.SetEditionNum( EditionNum );
  RestoreFileEditionAddInfo.Update;
  RestoreFileEditionAddInfo.Free;
end;

procedure TRestoreFileEditionReadHandle.SetEditionNum(_EditionNum: Integer);
begin
  EditionNum := _EditionNum;
end;

procedure TRestoreFileEditionReadHandle.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TRestoreFileEditionReadHandle.Update;
begin
  AddToInfo;
end;

{ TRestoreFileEditionAddHandle }

procedure TRestoreFileEditionAddHandle.AddToXml;
var
  RestoreFileEditionAddXml : TRestoreFileEditionAddXml;
begin
  RestoreFileEditionAddXml := TRestoreFileEditionAddXml.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreFileEditionAddXml.SetFilePath( FilePath );
  RestoreFileEditionAddXml.SetEditionNum( EditionNum );
  RestoreFileEditionAddXml.AddChange;
end;

procedure TRestoreFileEditionAddHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ RestoreFileEditionApi }

class procedure RestoreFileEditionApi.AddItem(
  Params: TRestoreFileEditionAddParams);
var
  RestoreFileEditionAddHandle : TRestoreFileEditionAddHandle;
begin
  RestoreFileEditionAddHandle := TRestoreFileEditionAddHandle.Create( Params.RestorePath, Params.OwnerPcID, Params.RestoreFrom );
  RestoreFileEditionAddHandle.SetFilePath( Params.FilePath );
  RestoreFileEditionAddHandle.SetEditionNum( Params.EditionNum );
  RestoreFileEditionAddHandle.Update;
  RestoreFileEditionAddHandle.Free;
end;

class procedure RestoreFileEditionApi.ClearItems(RestorePath, OwnerPcID,
  RestoreFrom: string);
var
  RestoreFileEditionClearHandle : TRestoreFileEditionClearHandle;
begin
  RestoreFileEditionClearHandle := TRestoreFileEditionClearHandle.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreFileEditionClearHandle.Update;
  RestoreFileEditionClearHandle.Free;
end;

{ TRestoreFileEditionClearHandle }

procedure TRestoreFileEditionClearHandle.ClearToInfo;
var
  RestoreFileEditionClearInfo : TRestoreFileEditionClearInfo;
begin
  RestoreFileEditionClearInfo := TRestoreFileEditionClearInfo.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreFileEditionClearInfo.Update;
  RestoreFileEditionClearInfo.Free;
end;

procedure TRestoreFileEditionClearHandle.ClearToXml;
var
  RestoreFileEditonClearXml : TRestoreFileEditonClearXml;
begin
  RestoreFileEditonClearXml := TRestoreFileEditonClearXml.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreFileEditonClearXml.AddChange;
end;

procedure TRestoreFileEditionClearHandle.Update;
begin
  ClearToInfo;
  ClearToXml;
end;

{ TRestoreDownSetIsLostConnHandle }

procedure TRestoreDownSetIsLostConnHandle.SetIsLostConn(_IsLostConn: boolean);
begin
  IsLostConn := _IsLostConn;
end;

procedure TRestoreDownSetIsLostConnHandle.SetToInfo;
var
  RestoreDownSetIsLostConnInfo : TRestoreDownSetIsLostConnInfo;
begin
  RestoreDownSetIsLostConnInfo := TRestoreDownSetIsLostConnInfo.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreDownSetIsLostConnInfo.SetIsLostConn( IsLostConn );
  RestoreDownSetIsLostConnInfo.Update;
  RestoreDownSetIsLostConnInfo.Free
end;

procedure TRestoreDownSetIsLostConnHandle.Update;
begin
  SetToInfo;
end;

{ TRestorePreviewUserApi }

class procedure RestorePreviewUserApi.PreviewLocal(
  Params: TRestorePreviewParams);
var
  LocalRestorePreviewInfo : TLocalRestorePreviewInfo;
begin
  LocalRestorePreviewInfo := TLocalRestorePreviewInfo.Create;
  LocalRestorePreviewInfo.SetItemInfo( Params.RestorePath, Params.OwnerID, Params.RestoreFrom );
  LocalRestorePreviewInfo.SetDeletedInfo( Params.IsDeleted, Params.EditionNum );
  LocalRestorePreviewInfo.SetEncryptedInfo( Params.IsEncrypted, Params.PasswordExt );
  LocalRestorePreviewInfo.SetPassword( Params.Password );
  MyRestorePreviewHandler.AddRestorePath( LocalRestorePreviewInfo );
end;

class procedure RestorePreviewUserApi.PreviewNetwork(
  Params: TRestorePreviewParams);
var
  NetworkRestorePreviewInfo : TNetworkRestorePreviewInfo;
begin
  NetworkRestorePreviewInfo := TNetworkRestorePreviewInfo.Create;
  NetworkRestorePreviewInfo.SetItemInfo( Params.RestorePath, Params.OwnerID, Params.RestoreFrom );
  NetworkRestorePreviewInfo.SetDeletedInfo( Params.IsDeleted, Params.EditionNum );
  NetworkRestorePreviewInfo.SetEncryptedInfo( Params.IsEncrypted, Params.PasswordExt );
  NetworkRestorePreviewInfo.SetPassword( Params.Password );
  MyRestorePreviewHandler.AddRestorePath( NetworkRestorePreviewInfo );
end;

{ RestorePreviewAppApi }

class procedure RestorePreviewAppApi.CloudPcBusy;
var
  SharePreivewBusyFace : TSharePreivewBusyFace;
begin
  SharePreivewBusyFace := TSharePreivewBusyFace.Create;
  SharePreivewBusyFace.AddChange;
end;

class procedure RestorePreviewAppApi.CloudPcNotConn;
var
  SharePreivewNotConnFace : TSharePreivewNotConnFace;
begin
  SharePreivewNotConnFace := TSharePreivewNotConnFace.Create;
  SharePreivewNotConnFace.AddChange;
end;

class procedure RestorePreviewAppApi.NotPreviewEncrypted;
var
  SharePreivewNotPreviewEncryptedFace : TSharePreivewNotPreviewEncryptedFace;
begin
  SharePreivewNotPreviewEncryptedFace := TSharePreivewNotPreviewEncryptedFace.Create;
  SharePreivewNotPreviewEncryptedFace.AddChange;
end;

class procedure RestorePreviewAppApi.NotPreviewFile;
var
  SharePreivewNotPreviewFace : TSharePreivewNotPreviewFace;
begin
  SharePreivewNotPreviewFace := TSharePreivewNotPreviewFace.Create;
  SharePreivewNotPreviewFace.AddChange;
end;

class procedure RestorePreviewAppApi.StartPreview;
var
  RestoreFilePreviewStartFace : TRestoreFilePreviewStartFace;
begin
  RestoreFilePreviewStartFace := TRestoreFilePreviewStartFace.Create;
  RestoreFilePreviewStartFace.AddChange;
end;

class procedure RestorePreviewAppApi.StopPreview;
var
  RestoreFilePreviewStopFace : TRestoreFilePreviewStopFace;
begin
  RestoreFilePreviewStopFace := TRestoreFilePreviewStopFace.Create;
  RestoreFilePreviewStopFace.AddChange;
end;

{ TShareExplorerHistoryReadHandle }

constructor TShareExplorerHistoryReadHandle.Create(_FilePath, _OwnerID, _RestoreFrom : string);
begin
  FilePath := _FilePath;
  OwnerID := _OwnerID;
  RestoreFrom := _RestoreFrom;
end;


procedure TShareExplorerHistoryReadHandle.RemoveExistItem;
var
  ExistIndex : Integer;
begin
  ExistIndex := ShareExplorerHistoryInfoReadUtil.ReadExistIndex( FilePath, OwnerID, RestoreFrom );
  if ExistIndex < 0 then
    Exit;

     // 先删除已存在的
  RemoveItem( ExistIndex );
end;

procedure TShareExplorerHistoryReadHandle.RemoveItem(RemoveIndex: Integer);
var
  ShareExplorerHistoryRemoveHandle : TShareExplorerHistoryRemoveHandle;
begin
  ShareExplorerHistoryRemoveHandle := TShareExplorerHistoryRemoveHandle.Create( RemoveIndex );
  ShareExplorerHistoryRemoveHandle.Update;
  ShareExplorerHistoryRemoveHandle.Free;
end;

procedure TShareExplorerHistoryReadHandle.RemoveMaxCount;
var
  HistoryCount, RemoveIndex : Integer;
begin
  HistoryCount := ShareExplorerHistoryInfoReadUtil.ReadHistoryCount;
  if HistoryCount < HistoryCount_Max then
    Exit;

    // 删除最后一个
  RemoveIndex := HistoryCount - 1;
  RemoveItem( RemoveIndex );
end;

procedure TShareExplorerHistoryReadHandle.AddToInfo;
var
  RestoreExplorerHistoryAddInfo : TRestoreExplorerHistoryAddInfo;
begin
  RestoreExplorerHistoryAddInfo := TRestoreExplorerHistoryAddInfo.Create( FilePath, OwnerID, RestoreFrom );
  RestoreExplorerHistoryAddInfo.Update;
  RestoreExplorerHistoryAddInfo.Free;
end;

procedure TShareExplorerHistoryReadHandle.AddToFace;
var
  OwnerName : string;
  ShareExplorerHistoryAddFace : TRestoreExplorerHistoryAddFace;
begin
  OwnerName := MyNetPcInfoReadUtil.ReadName( OwnerID );

  ShareExplorerHistoryAddFace := TRestoreExplorerHistoryAddFace.Create( OwnerName, FilePath );
  ShareExplorerHistoryAddFace.AddChange;
end;

procedure TShareExplorerHistoryReadHandle.Update;
begin
  RemoveExistItem;
  RemoveMaxCount;
  AddToInfo;
  AddToFace;
end;

{ TShareExplorerHistoryAddHandle }

procedure TShareExplorerHistoryAddHandle.AddToXml;
var
  ShareExplorerHistoryAddXml : TRestoreExplorerHistoryAddXml;
begin
  ShareExplorerHistoryAddXml := TRestoreExplorerHistoryAddXml.Create( FilePath, OwnerID, RestoreFrom );
  ShareExplorerHistoryAddXml.AddChange;
end;

procedure TShareExplorerHistoryAddHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TShareExplorerHistoryRemoveHandle }

procedure TShareExplorerHistoryRemoveHandle.RemoveFromInfo;
var
  ShareExplorerHistoryRemoveInfo : TRestoreExplorerHistoryRemoveInfo;
begin
  ShareExplorerHistoryRemoveInfo := TRestoreExplorerHistoryRemoveInfo.Create( RemoveIndex );
  ShareExplorerHistoryRemoveInfo.Update;
  ShareExplorerHistoryRemoveInfo.Free;
end;

constructor TShareExplorerHistoryRemoveHandle.Create(_RemoveIndex: Integer);
begin
  RemoveIndex := _RemoveIndex;
end;

procedure TShareExplorerHistoryRemoveHandle.RemoveFromFace;
var
  ShareExplorerHistoryRemoveFace : TRestoreExplorerHistoryRemoveFace;
begin
  ShareExplorerHistoryRemoveFace := TRestoreExplorerHistoryRemoveFace.Create( RemoveIndex );
  ShareExplorerHistoryRemoveFace.AddChange;
end;

procedure TShareExplorerHistoryRemoveHandle.RemoveFromXml;
var
  ShareExplorerHistoryRemoveXml : TRestoreExplorerHistoryRemoveXml;
begin
  ShareExplorerHistoryRemoveXml := TRestoreExplorerHistoryRemoveXml.Create( RemoveIndex );
  ShareExplorerHistoryRemoveXml.AddChange;
end;

procedure TShareExplorerHistoryRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromFace;
  RemoveFromXml;
end;


{ ShareExplorerHistoryApi }

class procedure ShareExplorerHistoryApi.AddItem(FilePath, OwnerID, RestoreFrom : string);
var
  ShareExplorerHistoryAddHandle : TShareExplorerHistoryAddHandle;
begin
  ShareExplorerHistoryAddHandle := TShareExplorerHistoryAddHandle.Create( FilePath, OwnerID, RestoreFrom );
  ShareExplorerHistoryAddHandle.Update;
  ShareExplorerHistoryAddHandle.Free;
end;

end.
