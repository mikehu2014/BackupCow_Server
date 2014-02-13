unit UMyBackupApiInfo;

interface

uses SysUtils, UFileBaseInfo, classes, Generics.Collections;

type

{$Region ' 目标路径 增删 ' }

    // 父类
  TDesItemWriteHandle = class
  public
    DesItemID : string;
  public
    constructor Create( _DesItemID : string );
  end;

    // 读取 本地 Des
  TDesItemReadLocalHandle = class( TDesItemWriteHandle )
  public
    procedure Update;virtual;
  protected
    procedure AddToInfo;
    procedure AddToFace;virtual;
  protected
    function getIsAdd : Boolean;virtual;
  end;

    // 添加 本地 Des
  TDesItemAddLocalHandle = class( TDesItemReadLocalHandle )
  public
    procedure Update;override;
  protected
    procedure AddToXml;
    procedure AddToEvent;
  protected
    function getIsAdd : Boolean;override;
  end;

    // 读取 网络 Des
  TDesItemReadNetworkHandle = class( TDesItemWriteHandle )
  private
    IsOnline : Boolean;
    AvailableSpace : Int64;
  public
    procedure SetIsOnline( _IsOnline : Boolean );
    procedure SetAvailableSpace( _AvailableSpace : Int64 );
    procedure Update;virtual;
  private
    procedure AddToInfo;
    procedure AddToFace;
  end;

    // 添加 网络 Des
  TDesItemAddNetworkHandle = class( TDesItemReadNetworkHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 修改  可用空间
  TDesItemSetAvailableSpaceHandle = class( TDesItemWriteHandle )
  public
    AvailableSpace : int64;
  public
    procedure SetAvailableSpace( _AvailableSpace : int64 );
    procedure Update;
  private
    procedure SetToFace;virtual;
  end;

    // 修改  本地 可用空间
  TDesItemSetLocalAvailableSpaceHandle = class( TDesItemSetAvailableSpaceHandle )
  private
    procedure SetToFace;override;
  end;

    // 修改  网络 可用空间
  TDesItemSetNetworkAvailableSpaceHandle = class( TDesItemSetAvailableSpaceHandle )
  private
    procedure SetToFace;override;
  end;

    // 删除
  TDesItemRemoveHandle = class( TDesItemWriteHandle )
  public
    procedure Update;virtual;
  protected
    procedure RemoveFromInfo;
    procedure RemoveFromFace;virtual;
    procedure RemoveFromXml;
  end;


    // 删除 本地 Des
  TDesItemRemoveLocalHandle = class( TDesItemRemoveHandle )
  public
    procedure Update;override;
  protected
    procedure RemoveFromFace;override;
    procedure RemoveFromEvent;
  end;

    // 删除 网络 Des
  TDesItemRemoveNetworkHandle = class( TDesItemRemoveHandle )
  protected
    procedure RemoveFromFace;override;
  end;

{$EndRegion}

{$Region ' 目标路径 状态 ' }

      // 修改 是否存在路径
  TDesItemSetIsExistHandle = class( TDesItemWriteHandle )
  public
    IsExist : boolean;
  public
    procedure SetIsExist( _IsExist : boolean );
    procedure Update;
  private
     procedure SetToFace;
  end;

    // 修改 是否可写
  TLocalDesItemSetIsWriteHandle = class( TDesItemWriteHandle )
  public
    IsWrite : boolean;
  public
    procedure SetIsWrite( _IsWrite : boolean );
    procedure Update;
  private
     procedure SetToFace;
  end;

    // 修改 是否缺少空间
  TDesItemSetIsLackSpaceHandle = class( TDesItemWriteHandle )
  public
    IsLackSpace : boolean;
  public
    procedure SetIsLackSpace( _IsLackSpace : boolean );
    procedure Update;
  private
     procedure SetToFace;
  end;

      // 修改 是否可连接
  TDesItemSetIsConnectedHandle = class( TDesItemWriteHandle )
  public
    IsConnected : boolean;
  public
    procedure SetIsConnected( _IsConnected : boolean );
    procedure Update;
  private
     procedure SetToFace;
  end;

{$EndRegion}

{$Region ' 目标路径 其他操作 ' }

    // 备份本地目标
  TBackupDesSelectItemHandle = class( TDesItemWriteHandle )
  public
    procedure Update;
  end;

    // Pc 上/下线
  TNetworkDesPcSetIsOnline = class
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

{$EndRegion}


{$Region ' 源路径 增删 ' }

    // 添加
  TBackupItemWriteHandle = class( TDesItemWriteHandle )
  public
    BackupPath : string;
  public
    procedure SetBackupPath( _BackupPath : string );
  end;

    // 读取
  TBackupItemReadHandle = class( TBackupItemWriteHandle )
  public  // 路径信息
    IsFile, IsCompleted : Boolean;
  public  // 自动同步
    IsBackupNow, IsAutoSync : Boolean; // 是否自动同步
    SyncTimeType, SyncTimeValue : Integer; // 同步间隔
    LastSyncTime : TDateTime;  // 上一次同步时间
  public  // 加密设置
    IsEncrypt : boolean;
    Password, PasswordHint : string;
  public  // 删除保留信息
    IsKeepDeleted : Boolean;
    KeepEditionCount : Integer;
  public  // 空间信息
    FileCount : Integer;
    ItemSize, CompletedSize : Int64; // 空间信息
  public
    procedure SetIsFile( _IsFile : Boolean );
    procedure SetIsCompleted( _IsCompleted : Boolean );
    procedure SetIsBackupNow( _IsBackupNow : Boolean );
    procedure SetAutoSyncInfo( _IsAutoSync : Boolean; _LasSyncTime : TDateTime );
    procedure SetSyncTimeInfo( _SyncTimeType, _SyncTimeValue : Integer );
    procedure SetEncryptInfo( _IsEncrypt : boolean; _Password, _PasswordHint : string );
    procedure SetDeleteInfo( _IsKeepDeleted : Boolean; _KeepEditionCount : Integer );
    procedure SetSpaceInfo( _FileCount : Integer; _ItemSize, _CompletedSize : Int64 );
    procedure Update;virtual;
  private
    procedure AddToInfo;
    procedure AddToFace;
  end;

    // 添加
  TBackupItemAddHandle = class( TBackupItemReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  private
    procedure HideNotPcHint;
  end;

    // 删除
  TBackupItemRemoveHandle = class( TBackupItemWriteHandle )
  private
    IsDelete : Boolean;
  public
    procedure SetIsDelete( _IsDelete : Boolean );
    procedure Update;virtual;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromFace;
    procedure RemoveFromXml;
  end;

    // 删除 本地备份
  TBackupItemRemoveLocalHandle = class( TBackupItemRemoveHandle )
  public
    procedure Update;override;
  private
    procedure RemoveFromEvent;
  end;

    // 删除 网络备份
  TBackupItemRemoveNetworkHandle = class( TBackupItemRemoveHandle )
  public
    procedure Update;override;
  private
    procedure RemoveFromEvent;
  end;

{$EndRegion}

{$Region ' 源路径 状态 ' }

    // 是否 Backup Now 备份
  TBackupItemSetIsBackupNowHandle = class( TBackupItemWriteHandle )
  public
    IsBackupNow : Boolean;
  public
    procedure SetIsBackupNow( _IsBackupNow : Boolean );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToFace;
    procedure SetToXml;
  end;

    // 修改 是否存在
  TBackupItemSetIsExistHandle = class( TBackupItemWriteHandle )
  public
    IsExist : boolean;
  public
    procedure SetIsExist( _IsExist : boolean );
    procedure Update;
  private
     procedure SetToFace;
  end;

    // 修改 状态
  TBackupItemSetBackupItemStatusHandle = class( TBackupItemWriteHandle )
  public
    BackupItemStatus : string;
  public
    procedure SetBackupItemStatus( _BackupItemStatus : string );
    procedure Update;
  private
     procedure SetToFace;
  end;

    // 修改
  TBackupItemSetSpeedHandle = class( TBackupItemWriteHandle )
  public
    Speed : int64;
  public
    procedure SetSpeed( _Speed : int64 );
    procedure Update;
  private
     procedure SetToFace;
  end;

    // 修改
  TBackupItemSetAnalyizeCountHandle = class( TBackupItemWriteHandle )
  public
    AnalyizeCount : integer;
  public
    procedure SetAnalyizeCount( _AnalyizeCount : integer );
    procedure Update;
  private
     procedure SetToFace;
  end;

    // 修改
  TBackupItemSetIsCompletedHandle = class( TBackupItemWriteHandle )
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
  TBackupItemSetIsDesBusyHandle = class( TBackupItemWriteHandle )
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
  TBackupItemSetIsLostConnHandle = class( TBackupItemWriteHandle )
  public
    IsLostConn : boolean;
  public
    procedure SetIsLostConn( _IsLostConn : boolean );
    procedure Update;
  private
     procedure SetToInfo;
  end;

    // 分析
  TBackupItemAnalyzingHandle = class( TBackupItemWriteHandle )
  public
    procedure Update;
  end;

{$EndRegion}

{$Region ' 源路径 空间信息 ' }

    // 修改 统计空间信息
  TBackupItemSetSpaceInfoHandle = class( TBackupItemWriteHandle )
  public
    FileCount : integer;
    ItemSize, CompletedSize : int64;
  public
    procedure SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSize : int64 );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToFace;
     procedure SetToXml;
  end;

    // 修改
  TBackupItemAddCompletedSpaceHandle = class( TBackupItemWriteHandle )
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

{$EndRegion}

{$Region ' 源路径 同步信息 ' }

    // 修改
  TBackupItemSetLastSyncTimeHandle = class( TBackupItemWriteHandle )
  public
    LastSyncTime : TDateTime;
  public
    procedure SetLastSyncTime( _LastSyncTime : TDateTime );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToFace;
     procedure SetToXml;
  end;

    // 修改
  TBackupItemSetAutoSyncHandle = class( TBackupItemWriteHandle )
  public
    IsAutoSync : boolean;
    SyncTimeType, SyncTimeValue : integer;
  public
    procedure SetAutoSyncInfo( _IsAutoSync : boolean );
    procedure SetSyncTimeInfo( _SyncTimeType, _SyncTimeValue : integer );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToFace;
     procedure SetToXml;
  end;

    // 修改
  TBackupItemSetIsBackupingHandle = class( TBackupItemWriteHandle )
  public
    IsBackuping : boolean;
  public
    procedure SetIsBackuping( _IsBackuping : boolean );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToFace;
  end;

    // 刷新显示的同步时间
  TBackupItemRefreshAutoSyncHandle = class
  public
    procedure Update;
  private
    procedure SetToFace;
  end;

{$EndRegion}

{$Region ' 源路径 加密信息 ' }

    // 修改
  TBackupItemSetEncryptInfoHandle = class( TBackupItemWriteHandle )
  public
    IsEncrypt : boolean;
    Password, PasswordHint : string;
  public
    procedure SetEncryptInfo( _IsEncrypt : boolean; _Password, _PasswordHint : string );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToFace;
     procedure SetToXml;
  end;


{$EndRegion}

{$Region ' 源路径 保存删除信息 ' }

    // 修改
  TBackupItemSetDeletedInfoHandle = class( TBackupItemWriteHandle )
  public
    IsKeepDeleted : boolean;
    KeepEditionCount : integer;
  public
    procedure SetDeletedInfo( _IsKeepDeleted : boolean; _KeepEditionCount : integer );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToFace;
     procedure SetToXml;
  end;

{$EndRegion}

{$Region ' 源路径 过滤信息 ' }

    // 读取 包含过滤
  TBackupItemIncludeFilterReadHandle = class( TBackupItemWriteHandle )
  public
    IncludeFilterList : TFileFilterList;
  public
    procedure SetIncludeFilterList( _IncludeFilterList : TFileFilterList );
    procedure Update;virtual;
  private
    procedure SetToInfo;
    procedure SetToFace;
  end;

    // 设置 包含过滤
  TBackupItemIncludeFilterSetHandle = class( TBackupItemIncludeFilterReadHandle )
  public
    procedure Update;override;
  private
    procedure SetToXml;
  end;

    // 读取 排除过滤
  TBackupItemExcludeFilterReadHandle = class( TBackupItemWriteHandle )
  public
    ExcludeFilterList : TFileFilterList;
  public
    procedure SetExcludeFilterList( _ExcludeFilterList : TFileFilterList );
    procedure Update;virtual;
  private
    procedure SetToInfo;
    procedure SetToFace;
  end;

    // 设置 排除过滤
  TBackupItemExcludeFilterSetHandle = class( TBackupItemExcludeFilterReadHandle )
  public
    procedure Update;override;
  private
    procedure SetToXml;
  end;

{$EndRegion}

{$Region ' 源路径 续传信息 ' }

    // 修改
  TBackupContinusWriteHandle = class( TBackupItemWriteHandle )
  public
    FilePath : string;
  public
    procedure SetFilePath( _FilePath : string );
  end;

    // 读取
  TBackupContinusReadHandle = class( TBackupContinusWriteHandle )
  public
    FileTime : TDateTime;
    FileSize : int64;
  public
    procedure SetFileInfo( _FileSize: int64; _FileTime : TDateTime );
    procedure Update;virtual;
  private
    procedure AddToInfo;
  end;

    // 添加
  TBackupContinusAddHandle = class( TBackupContinusReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 删除
  TBackupContinusRemoveHandle = class( TBackupContinusWriteHandle )
  protected
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromXml;
  end;



{$EndRegion}

{$Region ' 源路径 日志信息 ' }

    // 修改
  TBackupLogWriteHandle = class( TBackupItemWriteHandle )
  public
    FilePath : string;
  public
    procedure SetFilePath( _FilePath : string );
  end;

    // 添加
  TBackupLogCompletedAddHandle = class( TBackupLogWriteHandle )
  public
    BackupDate : TDate;
    FileTime, BackupTime : TDateTime;
  public
    procedure SetBackupDate( _BackupDate : TDate );
    procedure SetBackupTime( _FileTime, _BackupTime : TDateTime );
    procedure Update;
  private
    procedure AddToXml;
  end;

    // 添加
  TBackupLogIncompletedAddHandle = class( TBackupLogWriteHandle )
  public
    procedure Update;
  private
    procedure AddToXml;
  end;

    // 清空已完成
  TBackupLogClearCompletedHandle = class( TBackupItemWriteHandle )
  public
    procedure Update;
  private
    procedure ClearXml;
  end;

    // 清空未完成
  TBackupLogClearIncompletedHandle = class( TBackupItemWriteHandle )
  public
    procedure Update;
  private
    procedure ClearXml;
  end;

{$EndRegion}

{$Region ' 源路径 错误信息 ' }

      // 添加 错误
  TBackupItemErrorAddHandle = class( TBackupItemWriteHandle )
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
  TBackupItemErrorClearHandle = class( TBackupItemWriteHandle )
  public
    procedure Update;
  private
    procedure ClearToFace;
  end;

{$EndRegion}

{$Region ' 源路径 其他操作 ' }

    // 父类
  TBackupSelectedItemHandle = class( TBackupItemWriteHandle )
  public
    procedure Update;
  protected
    procedure AddToScan;
  end;


    // 备份停止
  TBackupItemStopHandle = class( TBackupItemWriteHandle )
  public
    procedure Update;
  end;


    // 备份完成
  TBackupItemCompletedHandle = class( TBackupItemWriteHandle )
  public
    procedure Update;
  protected
    procedure AddToEvent;virtual;abstract;
  end;

    // 本地 备份完成
  TBackupItemLocalCompletedHandle = class( TBackupItemCompletedHandle )
  protected
    procedure AddToEvent;override;
  end;

    // 网络 备份完成
  TBackupItemNetworkCompletedHandle = class( TBackupItemCompletedHandle )
  protected
    procedure AddToEvent;override;
  end;

    // 本地续传
  TBackupItemLocalOnlineBackup = class
  public
    procedure Update;
  end;

    // 网络续传
  TBackupItemNetworkOnlineBackup = class
  public
    OnlinePcID : string;
  public
    constructor Create( _OnlinePcID : string );
    procedure Update;
  end;


    // 备份所有 Item
  TBackupAllItemsHandle = class
  public
    procedure Update;
  private
    procedure BackupLocalItem;
    procedure BackupNetworkItem;
  end;

    // 启动备份
  TBackupStartHandle = class
  public
    procedure Update;
  private
    procedure SetToFace;
  end;

    // 停止备份
  TBackupStopHandle = class
  public
    procedure Update;
  private
    procedure SetToFace;
  end;

      // 暂停备份
  TBackupPauseHandle = class
  public
    procedure Update;
  private
    procedure SetToFace;
  end;

    // 继续备份
  TBackupContinusHandle = class
  public
    procedure Update;
  private
    procedure StartLocalBackup;
    procedure StartNetworkBackup;
    procedure SetToFace;
  end;

{$EndRegion}

{$Region ' 备份速度信息 ' }

    // 读取 速度限制
  TBackupSpeedLimitReadHandle = class
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
  TBackupSpeedLimitHandle = class( TBackupSpeedLimitReadHandle )
  public
    procedure Update;override;
  private
    procedure SetToXml;
  end;

{$EndRegion}

{$Region ' 信息读取 ' }

  BackupSpeedInfoReadUtil = class
  public
    class function getIsLimit : Boolean;
    class function getLimitType : Integer;
    class function getLimitValue : Integer;
    class function getLimitSpeed : Int64;
  end;

{$EndRegion}

{$Region ' 读取日志信息 ' }

    // 文件日志
  TBackupFileLogInfo = class
  public
    FilePath : string;
    FileTime, BackupTime : TDateTime;
  public
    procedure SetFilePath( _FilePath : string );
    procedure SetBackupTime( _FileTime, _BackupTime : TDateTime );
  end;
  TBackupFileLogList = class( TObjectList< TBackupFileLogInfo > )end;

    // 日期日志
  TBackupDateLogInfo = class
  public
    BackupDate : TDate;
    FileCount : Integer;
    BackupFileLogList : TBackupFileLogList;
  public
    constructor Create( _BackupDate : TDate );
    procedure SetFileCount( _FileCount : Integer );
    destructor Destroy; override;
  end;
  TBackupDateLogList = class( TObjectList< TBackupDateLogInfo > )end;

      // 刷新日志信息
  TRefreshBackupLogHandle = class
  private
    DesItemID, BackupPath : string;
  private
    BackupCompletedDateLogList : TBackupDateLogList;
    BackupIncompletedList : TStringList;
  public
    constructor Create( _DesItemID, _BackupPath : string );
    procedure Update;
    destructor Destroy; override;
  private
    procedure ReadCompletedLogInfo;
    procedure ReadIncompletedLogInfo;
    procedure ShowLogInfo;
  end;

{$EndRegion}


    // 目标路径 用户接口
  DesItemUserApi = class
  public
    class procedure AddLocalItem( DesItemID : string );
    class procedure RemoveLocalItem( DesItemID : string );
    class procedure RemoveNetworkItem( DesItemID : string );
  public
    class procedure BackupSelectItem( DesItemID : string );
  end;

    // 目标路径 程序接口
  DesItemAppApi = class
  public
    class procedure AddNetworkItem( DesItemID : string; AvailableSpace : Int64 );
    class procedure SetNetworkPcIsOnline( DesPcID : string; IsOnline : Boolean );
  public
    class procedure SetLocalAvaialbleSpace( DesItemID : string; AvailableSpace : Int64 );
    class procedure SetNetworkAvaialbleSpace( DesItemID : string; AvailableSpace : Int64 );
  public
    class procedure SetIsExist( DesItemID : string; IsExist : Boolean );
    class procedure SetIsWrite( DesItemID : string; IsWrite : Boolean );
    class procedure SetIsLackSpace( DesItemID : string; IsLackSpace : Boolean );
    class procedure SetIsConnected( DesItemID : string; IsConnected : Boolean );
  end;

    // 自动备份参数
  TBackupAutoSynParams = record
  public
    DesItemID, BackupPath : string;
    IsAutoSync : Boolean;
    SyncTimeType, SyncTimeValue : Integer;
  end;

    // 加密参数
  TBackupEncryptParams = record
  public
    DesItemID, BackupPath : string;
    IsEncrypt : Boolean;
    Password, PasswordHint : string;
  end;

    // 保存删除参数
  TBackupSaveDeletedParams = record
  public
    DesItemID, BackupPath : string;
    IsSaveDeleted : Boolean;
    SaveDeletedEdition : Integer;
  end;

    // 设置空间信息参数
  TBackupSetSpaceParams = record
  public
    DesItemID, BackupPath : string;
    FileCount : Integer;
    FileSpace, CompletedSpce : Int64;
  end;

    // 备份路径 用户接口
  BackupItemUserApi = class
  public              // 增删 备份路径
    class procedure AddItem( DesItemID, BackupPath : string; BackupConfigInfo : TBackupConfigInfo );
    class procedure RemoveLocalItem( DesItemID, BackupPath : string; IsDelete : Boolean );
    class procedure RemoveNetworkItem( DesItemID, BackupPath : string; IsDelete : Boolean );
  public             // 修改 配置
    class procedure SetIsBackupNow( DesItemID, BackupPath : string; IsBackupNow : Boolean );
    class procedure SetAutoSyncInfo( Params : TBackupAutoSynParams );
    class procedure SetEncryptInfo( Params : TBackupEncryptParams );
    class procedure SetSaveDeletedInfo( Params : TBackupSaveDeletedParams );
  public              // 修改 过滤器
    class procedure SetIncludeFilterList( DesItemID, BackupPath : string; IncludeFilterList : TFileFilterList );
    class procedure SetExcludeFilterList( DesItemID, BackupPath : string; ExcludeFilterList : TFileFilterList );
  public              // 备份操作
    class procedure BackupAllItem;
    class procedure BackupSelectItem( DesItemID, BackupPath : string );
  end;

    // 备份路径 程序接口
  BackupItemAppApi = class
  public              // 备份路径
    class procedure SetIsExist( DesItemID, BackupPath : string; IsExist : Boolean );
    class procedure SetIsCompleted( DesItemID, BackupPath : string; IsCompleted : Boolean );
    class procedure SetIsDesBusy( DesItemID, BackupPath : string; IsDesBusy : Boolean );
    class procedure SetIsLostConn( DesItemID, BackupPath : string; IsLostConn : Boolean );
    class procedure SetSpaceInfo( Params : TBackupSetSpaceParams );
  public              // 备份路径 备份过程
    class procedure SetWaitingBackup( DesItemID, BackupPath : string );
    class procedure SetAnalyzeBackup( DesItemID, BackupPath : string );
    class procedure SetScaningCount( DesItemID, BackupPath : string; FileCount : Integer );
    class procedure SetStartBackup( DesItemID, BackupPath : string );
    class procedure SetSpeed( DesItemID, BackupPath : string; Speed : Int64 );
    class procedure AddBackupCompletedSpace( DesItemID, BackupPath : string; CompletedSpace : Int64 );
    class procedure SetStopBackup( DesItemID, BackupPath : string );
  public              // 备份完成
    class procedure SetLocalBackupCompleted( DesItemID, BackupPath : string );
    class procedure SetNetworkBackupCompleted( DesItemID, BackupPath : string );
  public              // 自动同步
    class procedure AutoBackupNowCheck;
    class procedure RefresAutoSyncTime;
    class procedure RefreshLastSyncTime( DesItemID, BackupPath : string );
  public              // 备份状态
    class procedure SetBackupItemStatus( DesItemID, BackupPath, ItemStatus : string );
    class procedure SetIsBackuping( DesItemID, BackupPath : string; IsBackuping : Boolean );
    class procedure BackupStart;
    class procedure BackupStop;
    class procedure BackupPause;
    class procedure BackupContinus;
  public              // 续传
    class procedure LocalOnlineBackup;
    class procedure PcOnlineBackup( OnlinePcID : string );
  end;

    // 添加 参数
  TBackupContinusAddParams = record
  public
    DesItemID, SourcePath : string;
    FilePath : string;
    FileSize : Int64;
    FileTime : TDateTime;
  end;

    // 续传Api
  BackupContinusAppApi = class
  public
    class procedure AddItem( Params : TBackupContinusAddParams );
    class procedure RemoveItem( DesItemID, SourcePath, SourceFilePath : string );
  end;


    // 添加 参数
  TBackupErrorAddParams = record
  public
    SendRootItemID : string;
    SourcePath : string;
    FilePath : string;
    FileSize, CompletedSize : Int64;
    ErrorStatus : string;
  end;

    // 错误 Api
  BackupErrorAppApi = class
  public
    class procedure ReadFileError( Params : TBackupErrorAddParams );
    class procedure WriteFileError( Params : TBackupErrorAddParams );
    class procedure SendFileError( Params : TBackupErrorAddParams );
    class procedure LostConnectError( Params : TBackupErrorAddParams );
    class procedure ClearItem( DesItemID, SourcePath : string );
  private
    class procedure AddItem( Params : TBackupErrorAddParams );
  end;

    // 添加参数
  TBackupLogAddParams = record
  public
    DesItemID, SourcePath : string;
    FilePath : string;
  public
    BackupDate : TDate;
    FileTime, BackupTime : TDateTime;
    ErrorStr : string;
  end;

    // 备份 Log Api
  BackupLogApi = class
  public
    class procedure AddCompleted( Prams : TBackupLogAddParams );
    class procedure ClearCompleted( DesItemID, BackupPath : string );
  public
    class procedure AddIncompleted( DesItemID, BackupPath, FilePath : string );
    class procedure ClearIncompleted( DesItemID, BackupPath : string );
  public
    class procedure RefreshLogFace( DesItemID, SourcePath : string );
  end;

    // 备份限速
  BackupSpeedApi = class
  public
    class procedure SetLimit( IsLimit : Boolean; LimitType, LimitValue : Integer );
  end;

    // 读取日志信息
  TBackupLogReadParams = record
  public
    DesItemID, SourcePath : string;
    FilePath : string;
    FileTime : TDateTime;
  end;

    // 日志信息读取
  BackupLogReadApi = class
  public
    class procedure LocalPreview( Params : TBackupLogReadParams );
    class procedure NetworkPreview( Params : TBackupLogReadParams );
  public
    class procedure LocalRestore( Params : TBackupLogReadParams );
    class procedure NetworkRestore( Params : TBackupLogReadParams );
  end;

      // 预览结果
  BackupLogAppApi = class
  public
    class procedure StartLoading;
    class procedure FileNotExist;
    class procedure StartRestore;
    class procedure StopLoading;
  public
    class procedure CloudPcNotConn;
    class procedure CloudPcBusy;
  end;

    // 已完成参数
  TCompletedHintParams = record
  public
    DesItemID, BackupPath : string;
    BackupTo : string;
  public
    TotalBackup : Integer;
    BackupFileList : TStringList;
  end;

    // Hint
  BackupHintAppApi = class
  public
    class procedure ShowBackuping( BackupPath, BackupTo : string );
    class procedure ShowBackupCompleted( Params : TCompletedHintParams );
  end;

const
  ActionType_AddFile = 'Back Up File';
  ActionType_RemoveFile = 'Remove Backup File';
  ActionType_ModifyFile = 'Modify Backup File';
  ActionType_AddFolder = 'Back Up Folder';
  ActionType_RemoveFolder = 'Remove Backup Folder';
  ActionType_RecycleFile = 'Save Deleted File';
  ActionType_RecycleFolder = 'Save Deleted Folder';

const
  LogType_Completed = 'Completed';
  LogType_InCompleted = 'InCompleted';

const
  LimitType_KB = 0;
  LimitType_MB = 1;

var
  UserBackup_IsStop : Boolean = False; // 用户手动停止备份

implementation

uses UMyBackupDataInfo, UMyBackupFaceInfo, UMyBackupXmlInfo, UMyNetPcInfo, UMyUtil, UBackupThread,
     UMyBackupEventInfo, UMyRestoreApiInfo, UAutoBackupThread, UNetworkControl, UMainApi, UMyTimerThread,
     UFormBackupLog, UXmlUtil, XMLIntf, UChangeInfo, UMainFormFace;

{ LocalBackupUserApi }

class procedure BackupItemUserApi.AddItem(DesItemID, BackupPath: string;
  BackupConfigInfo: TBackupConfigInfo);
var
  IsFile : Boolean;
  BackupItemAddHandle : TBackupItemAddHandle;
begin
  IsFile := FileExists( BackupPath );

    // 添加路径
  BackupItemAddHandle := TBackupItemAddHandle.Create( DesItemID );
  BackupItemAddHandle.SetBackupPath( BackupPath );
  BackupItemAddHandle.SetIsFile( IsFile );
  BackupItemAddHandle.SetIsCompleted( False );
  BackupItemAddHandle.SetIsBackupNow( BackupConfigInfo.IsBackupupNow );
  BackupItemAddHandle.SetAutoSyncInfo( BackupConfigInfo.IsAuctoSync, Now );
  BackupItemAddHandle.SetSyncTimeInfo( BackupConfigInfo.SyncTimeType, BackupConfigInfo.SyncTimeValue );
  BackupItemAddHandle.SetSpaceInfo( -1, 0, 0 );
  BackupItemAddHandle.SetDeleteInfo( BackupConfigInfo.IsKeepDeleted, BackupConfigInfo.KeepEditionCount );
  BackupItemAddHandle.SetEncryptInfo( BackupConfigInfo.IsEncrypt, BackupConfigInfo.Password, BackupConfigInfo.PasswordHint );
  BackupItemAddHandle.Update;
  BackupItemAddHandle.Free;

    // 添加 过滤器
  SetIncludeFilterList( DesItemID, BackupPath, BackupConfigInfo.IncludeFilterList );
  SetExcludeFilterList( DesItemID, BackupPath, BackupConfigInfo.ExcludeFilterList );
end;


class procedure BackupItemUserApi.BackupAllItem;
var
  BackupAllItemsHandle : TBackupAllItemsHandle;
begin
  BackupAllItemsHandle := TBackupAllItemsHandle.Create;
  BackupAllItemsHandle.Update;
  BackupAllItemsHandle.Free;
end;

class procedure BackupItemUserApi.BackupSelectItem(DesItemID,
  BackupPath: string);
var
  BackupSelectedItemHandle : TBackupSelectedItemHandle;
begin
  BackupSelectedItemHandle := TBackupSelectedItemHandle.Create( DesItemID );
  BackupSelectedItemHandle.SetBackupPath( BackupPath );
  BackupSelectedItemHandle.Update;
  BackupSelectedItemHandle.Free;
end;

class procedure BackupItemUserApi.RemoveLocalItem(DesItemID,
  BackupPath: string; IsDelete : Boolean);
var
  BackupItemRemoveLocalHandle : TBackupItemRemoveLocalHandle;
begin
  BackupItemRemoveLocalHandle := TBackupItemRemoveLocalHandle.Create( DesItemID );
  BackupItemRemoveLocalHandle.SetBackupPath( BackupPath );
  BackupItemRemoveLocalHandle.SetIsDelete( IsDelete );
  BackupItemRemoveLocalHandle.Update;
  BackupItemRemoveLocalHandle.Free;
end;

class procedure BackupItemUserApi.RemoveNetworkItem(DesItemID,
  BackupPath: string; IsDelete : Boolean);
var
  BackupItemRemoveNetworkHandle : TBackupItemRemoveNetworkHandle;
begin
  BackupItemRemoveNetworkHandle := TBackupItemRemoveNetworkHandle.Create( DesItemID );
  BackupItemRemoveNetworkHandle.SetBackupPath( BackupPath );
  BackupItemRemoveNetworkHandle.SetIsDelete( IsDelete );
  BackupItemRemoveNetworkHandle.Update;
  BackupItemRemoveNetworkHandle.Free;
end;

class procedure BackupItemUserApi.SetAutoSyncInfo(Params: TBackupAutoSynParams);
var
  BackupItemSetAutoSyncHandle : TBackupItemSetAutoSyncHandle;
begin
  BackupItemSetAutoSyncHandle := TBackupItemSetAutoSyncHandle.Create( Params.DesItemID );
  BackupItemSetAutoSyncHandle.SetBackupPath( Params.BackupPath );
  BackupItemSetAutoSyncHandle.SetAutoSyncInfo( Params.IsAutoSync );
  BackupItemSetAutoSyncHandle.SetSyncTimeInfo( Params.SyncTimeType, Params.SyncTimeValue );
  BackupItemSetAutoSyncHandle.Update;
  BackupItemSetAutoSyncHandle.Free;
end;



class procedure BackupItemUserApi.SetEncryptInfo(Params: TBackupEncryptParams);
var
  BackupItemSetEncryptInfoHandle : TBackupItemSetEncryptInfoHandle;
begin
  BackupItemSetEncryptInfoHandle := TBackupItemSetEncryptInfoHandle.Create( Params.DesItemID );
  BackupItemSetEncryptInfoHandle.SetBackupPath( Params.BackupPath );
  BackupItemSetEncryptInfoHandle.SetEncryptInfo( Params.IsEncrypt, Params.Password, Params.PasswordHint );
  BackupItemSetEncryptInfoHandle.Update;
  BackupItemSetEncryptInfoHandle.Free;
end;



class procedure BackupItemUserApi.SetExcludeFilterList(DesItemID,
  BackupPath: string; ExcludeFilterList: TFileFilterList);
var
  BackupItemExcludeFilterSetHandle : TBackupItemExcludeFilterSetHandle;
begin
  BackupItemExcludeFilterSetHandle := TBackupItemExcludeFilterSetHandle.Create( DesItemID );
  BackupItemExcludeFilterSetHandle.SetBackupPath( BackupPath );
  BackupItemExcludeFilterSetHandle.SetExcludeFilterList( ExcludeFilterList );
  BackupItemExcludeFilterSetHandle.Update;
  BackupItemExcludeFilterSetHandle.Free;
end;

class procedure BackupItemUserApi.SetIncludeFilterList(DesItemID,
  BackupPath: string; IncludeFilterList: TFileFilterList);
var
  BackupItemIncludeFilterSetHandle : TBackupItemIncludeFilterSetHandle;
begin
  BackupItemIncludeFilterSetHandle := TBackupItemIncludeFilterSetHandle.Create( DesItemID );
  BackupItemIncludeFilterSetHandle.SetBackupPath( BackupPath );
  BackupItemIncludeFilterSetHandle.SetIncludeFilterList( IncludeFilterList );
  BackupItemIncludeFilterSetHandle.Update;
  BackupItemIncludeFilterSetHandle.Free;
end;

class procedure BackupItemUserApi.SetIsBackupNow(DesItemID, BackupPath: string;
  IsBackupNow: Boolean);
var
  BackupItemSetIsBackupNowHandle : TBackupItemSetIsBackupNowHandle;
begin
  BackupItemSetIsBackupNowHandle := TBackupItemSetIsBackupNowHandle.Create( DesItemID );
  BackupItemSetIsBackupNowHandle.SetBackupPath( BackupPath );
  BackupItemSetIsBackupNowHandle.SetIsBackupNow( IsBackupNow );
  BackupItemSetIsBackupNowHandle.Update;
  BackupItemSetIsBackupNowHandle.Free;
end;

class procedure BackupItemUserApi.SetSaveDeletedInfo(
  Params: TBackupSaveDeletedParams);
var
  BackupItemSetDeletedInfoHandle : TBackupItemSetDeletedInfoHandle;
begin
  BackupItemSetDeletedInfoHandle := TBackupItemSetDeletedInfoHandle.Create( Params.DesItemID );
  BackupItemSetDeletedInfoHandle.SetBackupPath( Params.BackupPath );
  BackupItemSetDeletedInfoHandle.SetDeletedInfo( Params.IsSaveDeleted, Params.SaveDeletedEdition );
  BackupItemSetDeletedInfoHandle.Update;
  BackupItemSetDeletedInfoHandle.Free;
end;



{ TLocalBackupDesItemWriteHandle }

constructor TDesItemWriteHandle.Create(_DesItemID: string);
begin
  DesItemID := _DesItemID;
end;


{ TlocalBackupDeItemRemoveHandle }

procedure TDesItemRemoveHandle.RemoveFromFace;
var
  DesItemRemoveFace : TDesItemRemoveFace;
begin
  DesItemRemoveFace := TDesItemRemoveFace.Create( DesItemID );
  DesItemRemoveFace.AddChange;
end;

procedure TDesItemRemoveHandle.RemoveFromInfo;
var
  LocalDesItemRemoveInfo : TDesItemRemoveInfo;
begin
  LocalDesItemRemoveInfo := TDesItemRemoveInfo.Create( DesItemID );
  LocalDesItemRemoveInfo.Update;
  LocalDesItemRemoveInfo.Free;
end;

procedure TDesItemRemoveHandle.RemoveFromXml;
var
  LocalDesItemRemoveXml : TDesItemRemoveXml;
begin
  LocalDesItemRemoveXml := TDesItemRemoveXml.Create( DesItemID );
  LocalDesItemRemoveXml.AddChange;
end;

procedure TDesItemRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromFace;
  RemoveFromXml;
end;

procedure TBackupItemWriteHandle.SetBackupPath( _BackupPath : string );
begin
  BackupPath := _BackupPath;
end;

procedure TBackupItemReadHandle.SetIsFile( _IsFile : Boolean );
begin
  IsFile := _IsFile;
end;

procedure TBackupItemReadHandle.SetIsBackupNow(  _IsBackupNow : Boolean );
begin
  IsBackupNow := _IsBackupNow;
end;

procedure TBackupItemReadHandle.SetIsCompleted(_IsCompleted: Boolean);
begin
  IsCompleted := _IsCompleted;
end;

procedure TBackupItemReadHandle.AddToFace;
var
  BackupItemAddFace : TBackupItemAddFace;
begin
  BackupItemAddFace := TBackupItemAddFace.Create( DesItemID );
  BackupItemAddFace.SetBackupPath( BackupPath );
  BackupItemAddFace.SetIsFile( IsFile );
  BackupItemAddFace.SetIsCompleted( IsCompleted );
  BackupItemAddFace.SetAutoSyncInfo( IsAutoSync, LastSyncTime );
  BackupItemAddFace.SetSyncTimeInfo( SyncTimeType, SyncTimeValue );
  BackupItemAddFace.SetIsBackupNow( IsBackupNow );
  BackupItemAddFace.SetSaveDeletedInfo( IsKeepDeleted, KeepEditionCount );
  BackupItemAddFace.SetEncryptInfo( IsEncrypt, PasswordHint );
  BackupItemAddFace.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
  BackupItemAddFace.AddChange;
end;

procedure TBackupItemReadHandle.AddToInfo;
var
  LocalBackupItemAddInfo : TBackupItemAddInfo;
begin
  LocalBackupItemAddInfo := TBackupItemAddInfo.Create( DesItemID );
  LocalBackupItemAddInfo.SetBackupPath( BackupPath );
  LocalBackupItemAddInfo.SetIsFile( IsFile );
  LocalBackupItemAddInfo.SetIsCompleted( IsCompleted );
  LocalBackupItemAddInfo.SetIsBackupNow( IsBackupNow );
  LocalBackupItemAddInfo.SetAutoSyncInfo( IsAutoSync, LastSyncTime );
  LocalBackupItemAddInfo.SetSyncTimeInfo( SyncTimeType, SyncTimeValue );
  LocalBackupItemAddInfo.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
  LocalBackupItemAddInfo.SetDeletedInfo( IsKeepDeleted, KeepEditionCount );
  LocalBackupItemAddInfo.SetEncryptInfo( IsEncrypt, Password, PasswordHint );
  LocalBackupItemAddInfo.Update;
  LocalBackupItemAddInfo.Free;
end;

procedure TBackupItemReadHandle.SetAutoSyncInfo( _IsAutoSync : Boolean; _LasSyncTime : TDateTime );
begin
  IsAutoSync := _IsAutoSync;
  LastSyncTime := _LasSyncTime;
end;

procedure TBackupItemReadHandle.SetSyncTimeInfo( _SyncTimeType, _SyncTimeValue : Integer );
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TBackupItemReadHandle.Update;
begin
  AddToInfo;
  AddToFace;
end;

procedure TBackupItemReadHandle.SetDeleteInfo( _IsKeepDeleted : Boolean; _KeepEditionCount : Integer );
begin
  IsKeepDeleted := _IsKeepDeleted;
  KeepEditionCount := _KeepEditionCount;
end;

procedure TBackupItemReadHandle.SetEncryptInfo(_IsEncrypt: boolean;
  _Password, _PasswordHint: string);
begin
  IsEncrypt := _IsEncrypt;
  Password := _Password;
  PasswordHint := _PasswordHint;
end;

procedure TBackupItemReadHandle.SetSpaceInfo( _FileCount : Integer; _ItemSize, _CompletedSize : Int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;



{ TLocalBackupItemAddHandle }

procedure TBackupItemAddHandle.AddToXml;
var
  LocalBackupItemAddXml : TBackupItemAddXml;
begin
  LocalBackupItemAddXml := TBackupItemAddXml.Create( DesItemID );
  LocalBackupItemAddXml.SetBackupPath( BackupPath );
  LocalBackupItemAddXml.SetIsFile( IsFile );
  LocalBackupItemAddXml.SetIsCompleted( IsCompleted );
  LocalBackupItemAddXml.SetIsBackupNow( IsBackupNow );
  LocalBackupItemAddXml.SetAutoSyncInfo( IsAutoSync, LastSyncTime );
  LocalBackupItemAddXml.SetSyncTimeInfo( SyncTimeType, SyncTimeValue );
  LocalBackupItemAddXml.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
  LocalBackupItemAddXml.SetDeleteInfo( IsKeepDeleted, KeepEditionCount );
  LocalBackupItemAddXml.SetEncryptInfo( IsEncrypt, Password, PasswordHint );
  LocalBackupItemAddXml.AddChange;
end;

procedure TBackupItemAddHandle.HideNotPcHint;
begin
  if not DesItemInfoReadUtil.ReadIsLocalDes( DesItemID ) then
    Exit;

    // 隐藏
  NetworkErrorStatusApi.HideError;
end;

procedure TBackupItemAddHandle.Update;
begin
    // 隐藏没有 Pc 的提示
  HideNotPcHint;

  inherited;
  AddToXml;
end;

{ TLocalBackupItemRemoveHandle }

procedure TBackupItemRemoveHandle.RemoveFromFace;
var
  BackupItemRemoveFace : TBackupItemRemoveFace;
begin
  BackupItemRemoveFace := TBackupItemRemoveFace.Create( DesItemID );
  BackupItemRemoveFace.SetBackupPath( BackupPath );
  BackupItemRemoveFace.AddChange;
end;

procedure TBackupItemRemoveHandle.RemoveFromInfo;
var
  LocalBackupItemRemoveInfo : TBackupItemRemoveInfo;
begin
  LocalBackupItemRemoveInfo := TBackupItemRemoveInfo.Create( DesItemID );
  LocalBackupItemRemoveInfo.SetBackupPath( BackupPath );
  LocalBackupItemRemoveInfo.Update;
  LocalBackupItemRemoveInfo.Free;
end;

procedure TBackupItemRemoveHandle.RemoveFromXml;
var
  LocalBackupItemRemoveXml : TBackupItemRemoveXml;
begin
  LocalBackupItemRemoveXml := TBackupItemRemoveXml.Create( DesItemID );
  LocalBackupItemRemoveXml.SetBackupPath( BackupPath );
  LocalBackupItemRemoveXml.AddChange;
end;

procedure TBackupItemRemoveHandle.SetIsDelete(_IsDelete: Boolean);
begin
  IsDelete := _IsDelete;
end;

procedure TBackupItemRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromFace;
  RemoveFromXml;
end;

{ TLocalBackupItemSetIsBackupNowHandle }

procedure TBackupItemSetIsBackupNowHandle.SetIsBackupNow(
  _IsBackupNow: Boolean);
begin
  IsBackupNow := _IsBackupNow;
end;

procedure TBackupItemSetIsBackupNowHandle.SetToFace;
var
  BackupItemSetIsBackupNowFace : TBackupItemSetIsBackupNowFace;
begin
  BackupItemSetIsBackupNowFace := TBackupItemSetIsBackupNowFace.Create( DesItemID );
  BackupItemSetIsBackupNowFace.SetBackupPath( BackupPath );
  BackupItemSetIsBackupNowFace.SetIsBackupNow( IsBackupNow );
  BackupItemSetIsBackupNowFace.AddChange;
end;

procedure TBackupItemSetIsBackupNowHandle.SetToInfo;
var
  LocalBackupItemSetIsBackupNowInfo : TBackupItemSetIsBackupNowInfo;
begin
  LocalBackupItemSetIsBackupNowInfo := TBackupItemSetIsBackupNowInfo.Create( DesItemID );
  LocalBackupItemSetIsBackupNowInfo.SetBackupPath( BackupPath );
  LocalBackupItemSetIsBackupNowInfo.SetIsBackupNow( IsBackupNow );
  LocalBackupItemSetIsBackupNowInfo.Update;
  LocalBackupItemSetIsBackupNowInfo.Free;
end;

procedure TBackupItemSetIsBackupNowHandle.SetToXml;
var
  LocalBackupItemSetIsBackupNowXml : TBackupItemSetIsBackupNowXml;
begin
  LocalBackupItemSetIsBackupNowXml := TBackupItemSetIsBackupNowXml.Create( DesItemID );
  LocalBackupItemSetIsBackupNowXml.SetBackupPath( BackupPath );
  LocalBackupItemSetIsBackupNowXml.SetIsBackupNow( IsBackupNow );
  LocalBackupItemSetIsBackupNowXml.AddChange;
end;

procedure TBackupItemSetIsBackupNowHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ LocalBackupAppApi }

class procedure BackupItemAppApi.AutoBackupNowCheck;
begin
  MyTimerHandler.NowCheck( HandleType_AutoBackup );
end;

class procedure BackupItemAppApi.BackupContinus;
var
  BackupContinusHandle : TBackupContinusHandle;
begin
  BackupContinusHandle := TBackupContinusHandle.Create;
  BackupContinusHandle.Update;
  BackupContinusHandle.Free;
end;

class procedure BackupItemAppApi.BackupPause;
var
  BackupPauseHandle : TBackupPauseHandle;
begin
  BackupPauseHandle := TBackupPauseHandle.Create;
  BackupPauseHandle.Update;
  BackupPauseHandle.Free;
end;

class procedure BackupItemAppApi.BackupStart;
var
  BackupStartHandle : TBackupStartHandle;
begin
  BackupStartHandle := TBackupStartHandle.Create;
  BackupStartHandle.Update;
  BackupStartHandle.Free;
end;

class procedure BackupItemAppApi.BackupStop;
var
  BackupStopHandle : TBackupStopHandle;
begin
  BackupStopHandle := TBackupStopHandle.Create;
  BackupStopHandle.Update;
  BackupStopHandle.Free;
end;

class procedure BackupItemAppApi.LocalOnlineBackup;
var
  BackupItemLocalOnlineBackup : TBackupItemLocalOnlineBackup;
begin
  BackupItemLocalOnlineBackup := TBackupItemLocalOnlineBackup.Create;
  BackupItemLocalOnlineBackup.Update;
  BackupItemLocalOnlineBackup.Free;
end;

class procedure BackupItemAppApi.PcOnlineBackup(OnlinePcID: string);
var
  BackupItemNetworkOnlineBackup : TBackupItemNetworkOnlineBackup;
begin
  BackupItemNetworkOnlineBackup := TBackupItemNetworkOnlineBackup.Create( OnlinePcID );
  BackupItemNetworkOnlineBackup.Update;
  BackupItemNetworkOnlineBackup.Free;
end;

class procedure BackupItemAppApi.RefresAutoSyncTime;
var
  BackupItemRefreshAutoSyncHandle : TBackupItemRefreshAutoSyncHandle;
begin
  BackupItemRefreshAutoSyncHandle := TBackupItemRefreshAutoSyncHandle.Create;
  BackupItemRefreshAutoSyncHandle.Update;
  BackupItemRefreshAutoSyncHandle.Free;
end;

class procedure BackupItemAppApi.RefreshLastSyncTime(DesItemID,
  BackupPath: string);
var
  LocalBackupItemSetLastSyncTimeHandle : TBackupItemSetLastSyncTimeHandle;
begin
    // 刷新 上次同步时间
  LocalBackupItemSetLastSyncTimeHandle := TBackupItemSetLastSyncTimeHandle.Create( DesItemID );
  LocalBackupItemSetLastSyncTimeHandle.SetBackupPath( BackupPath );
  LocalBackupItemSetLastSyncTimeHandle.SetLastSyncTime( Now );
  LocalBackupItemSetLastSyncTimeHandle.Update;
  LocalBackupItemSetLastSyncTimeHandle.Free;
end;

class procedure BackupItemAppApi.AddBackupCompletedSpace(DesItemID,
  BackupPath: string; CompletedSpace: Int64);
var
  BackupItemAddCompletedSpaceHandle : TBackupItemAddCompletedSpaceHandle;
begin
  BackupItemAddCompletedSpaceHandle := TBackupItemAddCompletedSpaceHandle.Create( DesItemID );
  BackupItemAddCompletedSpaceHandle.SetBackupPath( BackupPath );
  BackupItemAddCompletedSpaceHandle.SetAddCompletedSpace( CompletedSpace );
  BackupItemAddCompletedSpaceHandle.Update;
  BackupItemAddCompletedSpaceHandle.Free;
end;

class procedure BackupItemAppApi.SetAnalyzeBackup(DesItemID,
  BackupPath: string);
var
  BackupItemAnalyzingHandle : TBackupItemAnalyzingHandle;
begin
  BackupItemAnalyzingHandle := TBackupItemAnalyzingHandle.Create( DesItemID );
  BackupItemAnalyzingHandle.SetBackupPath( BackupPath );
  BackupItemAnalyzingHandle.Update;
  BackupItemAnalyzingHandle.Free;
end;

class procedure BackupItemAppApi.SetBackupItemStatus(DesItemID, BackupPath,
  ItemStatus: string);
var
  BackupItemSetBackupItemStatusHandle : TBackupItemSetBackupItemStatusHandle;
begin
  BackupItemSetBackupItemStatusHandle := TBackupItemSetBackupItemStatusHandle.Create( DesItemID );
  BackupItemSetBackupItemStatusHandle.SetBackupPath( BackupPath );
  BackupItemSetBackupItemStatusHandle.SetBackupItemStatus( ItemStatus );
  BackupItemSetBackupItemStatusHandle.Update;
  BackupItemSetBackupItemStatusHandle.Free;
end;

class procedure BackupItemAppApi.SetIsBackuping(DesItemID, BackupPath: string;
  IsBackuping: Boolean);
var
  BackupItemSetIsBackupingHandle : TBackupItemSetIsBackupingHandle;
begin
  BackupItemSetIsBackupingHandle := TBackupItemSetIsBackupingHandle.Create( DesItemID );
  BackupItemSetIsBackupingHandle.SetBackupPath( BackupPath );
  BackupItemSetIsBackupingHandle.SetIsBackuping( IsBackuping );
  BackupItemSetIsBackupingHandle.Update;
  BackupItemSetIsBackupingHandle.Free;
end;



class procedure BackupItemAppApi.SetIsCompleted(DesItemID, BackupPath: string;
  IsCompleted: Boolean);
var
  BackupItemSetIsCompletedHandle : TBackupItemSetIsCompletedHandle;
begin
  BackupItemSetIsCompletedHandle := TBackupItemSetIsCompletedHandle.Create( DesItemID );
  BackupItemSetIsCompletedHandle.SetBackupPath( BackupPath );
  BackupItemSetIsCompletedHandle.SetIsCompleted( IsCompleted );
  BackupItemSetIsCompletedHandle.Update;
  BackupItemSetIsCompletedHandle.Free;
end;

class procedure BackupItemAppApi.SetIsDesBusy(DesItemID, BackupPath: string;
  IsDesBusy: Boolean);
var
  BackupItemSetIsDesBusyHandle : TBackupItemSetIsDesBusyHandle;
begin
  BackupItemSetIsDesBusyHandle := TBackupItemSetIsDesBusyHandle.Create( DesItemID );
  BackupItemSetIsDesBusyHandle.SetBackupPath( BackupPath );
  BackupItemSetIsDesBusyHandle.SetIsDesBusy( IsDesBusy );
  BackupItemSetIsDesBusyHandle.Update;
  BackupItemSetIsDesBusyHandle.Free;
end;

class procedure BackupItemAppApi.SetIsExist(DesItemID,
  BackupPath: string; IsExist: Boolean);
var
  BackupItemSetIsExistHandle : TBackupItemSetIsExistHandle;
begin
  BackupItemSetIsExistHandle := TBackupItemSetIsExistHandle.Create( DesItemID );
  BackupItemSetIsExistHandle.SetBackupPath( BackupPath );
  BackupItemSetIsExistHandle.SetIsExist( IsExist );
  BackupItemSetIsExistHandle.Update;
  BackupItemSetIsExistHandle.Free;
end;

class procedure BackupItemAppApi.SetIsLostConn(DesItemID, BackupPath: string;
  IsLostConn: Boolean);
var
  BackupItemSetIsLostConnHandle : TBackupItemSetIsLostConnHandle;
begin
  BackupItemSetIsLostConnHandle := TBackupItemSetIsLostConnHandle.Create( DesItemID );
  BackupItemSetIsLostConnHandle.SetBackupPath( BackupPath );
  BackupItemSetIsLostConnHandle.SetIsLostConn( IsLostConn );
  BackupItemSetIsLostConnHandle.Update;
  BackupItemSetIsLostConnHandle.Free;
end;

class procedure BackupItemAppApi.SetLocalBackupCompleted(
  DesItemID, BackupPath : string);
var
  BackupItemLocalCompletedHandle : TBackupItemLocalCompletedHandle;
begin
  BackupItemLocalCompletedHandle := TBackupItemLocalCompletedHandle.Create( DesItemID );
  BackupItemLocalCompletedHandle.SetBackupPath( BackupPath );
  BackupItemLocalCompletedHandle.Update;
  BackupItemLocalCompletedHandle.Free;
end;

class procedure BackupItemAppApi.SetNetworkBackupCompleted(
  DesItemID, BackupPath : string);
var
  BackupItemNetworkCompletedHandle : TBackupItemNetworkCompletedHandle;
begin
  BackupItemNetworkCompletedHandle := TBackupItemNetworkCompletedHandle.Create( DesItemID );
  BackupItemNetworkCompletedHandle.SetBackupPath( BackupPath );
  BackupItemNetworkCompletedHandle.Update;
  BackupItemNetworkCompletedHandle.Free;
end;

class procedure BackupItemAppApi.SetScaningCount(DesItemID,
  BackupPath: string; FileCount: Integer);
var
  BackupItemSetAnalyizeCountHandle : TBackupItemSetAnalyizeCountHandle;
begin
  BackupItemSetAnalyizeCountHandle := TBackupItemSetAnalyizeCountHandle.Create( DesItemID );
  BackupItemSetAnalyizeCountHandle.SetBackupPath( BackupPath );
  BackupItemSetAnalyizeCountHandle.SetAnalyizeCount( FileCount );
  BackupItemSetAnalyizeCountHandle.Update;
  BackupItemSetAnalyizeCountHandle.Free;
end;



class procedure BackupItemAppApi.SetSpaceInfo(Params : TBackupSetSpaceParams);
var
  BackupItemSetSpaceInfoHandle : TBackupItemSetSpaceInfoHandle;
begin
  BackupItemSetSpaceInfoHandle := TBackupItemSetSpaceInfoHandle.Create( Params.DesItemID );
  BackupItemSetSpaceInfoHandle.SetBackupPath( Params.BackupPath );
  BackupItemSetSpaceInfoHandle.SetSpaceInfo( Params.FileCount, Params.FileSpace, Params.CompletedSpce );
  BackupItemSetSpaceInfoHandle.Update;
  BackupItemSetSpaceInfoHandle.Free;
end;

class procedure BackupItemAppApi.SetSpeed(DesItemID,
  BackupPath: string; Speed: Int64);
var
  BackupItemSetSpeedHandle : TBackupItemSetSpeedHandle;
begin
  BackupItemSetSpeedHandle := TBackupItemSetSpeedHandle.Create( DesItemID );
  BackupItemSetSpeedHandle.SetBackupPath( BackupPath );
  BackupItemSetSpeedHandle.SetSpeed( Speed );
  BackupItemSetSpeedHandle.Update;
  BackupItemSetSpeedHandle.Free;
end;



class procedure BackupItemAppApi.SetStartBackup(DesItemID,
  BackupPath: string);
begin
  SetSpeed( DesItemID, BackupPath, 0 );
  SetBackupItemStatus( DesItemID, BackupPath, BackupNodeStatus_Backuping );
end;

class procedure BackupItemAppApi.SetStopBackup(DesItemID, BackupPath: string);
var
  BackupItemStopHandle : TBackupItemStopHandle;
begin
  BackupItemStopHandle := TBackupItemStopHandle.Create( DesItemID );
  BackupItemStopHandle.SetBackupPath( BackupPath );
  BackupItemStopHandle.Update;
  BackupItemStopHandle.Free;
end;

class procedure BackupItemAppApi.SetWaitingBackup(DesItemID,
  BackupPath: string);
begin
  SetBackupItemStatus( DesItemID, BackupPath, BackupNodeStatus_WaitingBackup );
end;

{ TLocalDesItemSetIsExistHandle }

procedure TDesItemSetIsExistHandle.SetIsExist( _IsExist : boolean );
begin
  IsExist := _IsExist;
end;

procedure TDesItemSetIsExistHandle.SetToFace;
var
  DesItemSetIsExistFace : TDesItemSetIsExistFace;
begin
  DesItemSetIsExistFace := TDesItemSetIsExistFace.Create( DesItemID );
  DesItemSetIsExistFace.SetIsExist( IsExist );
  DesItemSetIsExistFace.AddChange;
end;

procedure TDesItemSetIsExistHandle.Update;
begin
  SetToFace;
end;

{ TLocalDesItemSetIsWriteHandle }

procedure TLocalDesItemSetIsWriteHandle.SetIsWrite( _IsWrite : boolean );
begin
  IsWrite := _IsWrite;
end;

procedure TLocalDesItemSetIsWriteHandle.SetToFace;
var
  DesItemSetIsWriteFace : TDesItemSetIsWriteFace;
begin
  DesItemSetIsWriteFace := TDesItemSetIsWriteFace.Create( DesItemID );
  DesItemSetIsWriteFace.SetIsWrite( IsWrite );
  DesItemSetIsWriteFace.AddChange;
end;

procedure TLocalDesItemSetIsWriteHandle.Update;
begin
  SetToFace;
end;

{ TLocalDesItemSetIsLackSpaceHandle }

procedure TDesItemSetIsLackSpaceHandle.SetIsLackSpace( _IsLackSpace : boolean );
begin
  IsLackSpace := _IsLackSpace;
end;

procedure TDesItemSetIsLackSpaceHandle.SetToFace;
var
  DesItemSetIsLackSpaceFace : TDesItemSetIsLackSpaceFace;
begin
  DesItemSetIsLackSpaceFace := TDesItemSetIsLackSpaceFace.Create( DesItemID );
  DesItemSetIsLackSpaceFace.SetIsLackSpace( IsLackSpace );
  DesItemSetIsLackSpaceFace.AddChange;
end;

procedure TDesItemSetIsLackSpaceHandle.Update;
begin
  SetToFace;
end;

{ TLocalBackupItemSetIsExistHandle }

procedure TBackupItemSetIsExistHandle.SetIsExist( _IsExist : boolean );
begin
  IsExist := _IsExist;
end;

procedure TBackupItemSetIsExistHandle.SetToFace;
var
  LocalBackupItemSetIsExistFace : TBackupItemSetIsExistFace;
begin
  LocalBackupItemSetIsExistFace := TBackupItemSetIsExistFace.Create( DesItemID );
  LocalBackupItemSetIsExistFace.SetBackupPath( BackupPath );
  LocalBackupItemSetIsExistFace.SetIsExist( IsExist );
  LocalBackupItemSetIsExistFace.AddChange;
end;

procedure TBackupItemSetIsExistHandle.Update;
begin
  SetToFace;
end;

{ TLocalBackupItemSetSpaceInfoHandle }

procedure TBackupItemSetSpaceInfoHandle.SetSpaceInfo( _FileCount : integer;
  _ItemSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TBackupItemSetSpaceInfoHandle.SetToInfo;
var
  LocalBackupItemSetSpaceInfoInfo : TBackupItemSetSpaceInfoInfo;
begin
  LocalBackupItemSetSpaceInfoInfo := TBackupItemSetSpaceInfoInfo.Create( DesItemID );
  LocalBackupItemSetSpaceInfoInfo.SetBackupPath( BackupPath );
  LocalBackupItemSetSpaceInfoInfo.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
  LocalBackupItemSetSpaceInfoInfo.Update;
  LocalBackupItemSetSpaceInfoInfo.Free;
end;

procedure TBackupItemSetSpaceInfoHandle.SetToXml;
var
  LocalBackupItemSetSpaceInfoXml : TBackupItemSetSpaceInfoXml;
begin
  LocalBackupItemSetSpaceInfoXml := TBackupItemSetSpaceInfoXml.Create( DesItemID );
  LocalBackupItemSetSpaceInfoXml.SetBackupPath( BackupPath );
  LocalBackupItemSetSpaceInfoXml.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
  LocalBackupItemSetSpaceInfoXml.AddChange;
end;

procedure TBackupItemSetSpaceInfoHandle.SetToFace;
var
  LocalBackupItemSetSpaceInfoFace : TBackupItemSetSpaceInfoFace;
begin
  LocalBackupItemSetSpaceInfoFace := TBackupItemSetSpaceInfoFace.Create( DesItemID );
  LocalBackupItemSetSpaceInfoFace.SetBackupPath( BackupPath );
  LocalBackupItemSetSpaceInfoFace.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
  LocalBackupItemSetSpaceInfoFace.AddChange;
end;

procedure TBackupItemSetSpaceInfoHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TLocalBackupItemSetBackupItemStatusHandle }

procedure TBackupItemSetBackupItemStatusHandle.SetBackupItemStatus( _BackupItemStatus : string );
begin
  BackupItemStatus := _BackupItemStatus;
end;

procedure TBackupItemSetBackupItemStatusHandle.SetToFace;
var
  LocalBackupItemSetBackupItemStatusFace : TBackupItemSetStatusFace;
begin
  LocalBackupItemSetBackupItemStatusFace := TBackupItemSetStatusFace.Create( DesItemID );
  LocalBackupItemSetBackupItemStatusFace.SetBackupPath( BackupPath );
  LocalBackupItemSetBackupItemStatusFace.SetBackupItemStatus( BackupItemStatus );
  LocalBackupItemSetBackupItemStatusFace.AddChange;
end;

procedure TBackupItemSetBackupItemStatusHandle.Update;
begin
  SetToFace;
end;

{ TLocalBackupItemSetAddCompletedSpaceHandle }

procedure TBackupItemAddCompletedSpaceHandle.SetAddCompletedSpace( _AddCompletedSpace : int64 );
begin
  AddCompletedSpace := _AddCompletedSpace;
end;

procedure TBackupItemAddCompletedSpaceHandle.SetToInfo;
var
  LocalBackupItemSetAddCompletedSpaceInfo : TBackupItemSetAddCompletedSpaceInfo;
begin
  LocalBackupItemSetAddCompletedSpaceInfo := TBackupItemSetAddCompletedSpaceInfo.Create( DesItemID );
  LocalBackupItemSetAddCompletedSpaceInfo.SetBackupPath( BackupPath );
  LocalBackupItemSetAddCompletedSpaceInfo.SetAddCompletedSpace( AddCompletedSpace );
  LocalBackupItemSetAddCompletedSpaceInfo.Update;
  LocalBackupItemSetAddCompletedSpaceInfo.Free;
end;

procedure TBackupItemAddCompletedSpaceHandle.SetToXml;
var
  LocalBackupItemSetAddCompletedSpaceXml : TBackupItemSetAddCompletedSpaceXml;
begin
  LocalBackupItemSetAddCompletedSpaceXml := TBackupItemSetAddCompletedSpaceXml.Create( DesItemID );
  LocalBackupItemSetAddCompletedSpaceXml.SetBackupPath( BackupPath );
  LocalBackupItemSetAddCompletedSpaceXml.SetAddCompletedSpace( AddCompletedSpace );
  LocalBackupItemSetAddCompletedSpaceXml.AddChange;
end;

procedure TBackupItemAddCompletedSpaceHandle.SetToFace;
var
  LocalBackupItemSetAddCompletedSpaceFace : TBackupItemSetAddCompletedSpaceFace;
begin
  LocalBackupItemSetAddCompletedSpaceFace := TBackupItemSetAddCompletedSpaceFace.Create( DesItemID );
  LocalBackupItemSetAddCompletedSpaceFace.SetBackupPath( BackupPath );
  LocalBackupItemSetAddCompletedSpaceFace.SetAddCompletedSpace( AddCompletedSpace );
  LocalBackupItemSetAddCompletedSpaceFace.AddChange;
end;

procedure TBackupItemAddCompletedSpaceHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TLocalBackupItemSetLastSyncTimeHandle }

procedure TBackupItemSetLastSyncTimeHandle.SetLastSyncTime( _LastSyncTime : TDateTime );
begin
  LastSyncTime := _LastSyncTime;
end;

procedure TBackupItemSetLastSyncTimeHandle.SetToInfo;
var
  LocalBackupItemSetLastSyncTimeInfo : TBackupItemSetLastSyncTimeInfo;
begin
  LocalBackupItemSetLastSyncTimeInfo := TBackupItemSetLastSyncTimeInfo.Create( DesItemID );
  LocalBackupItemSetLastSyncTimeInfo.SetBackupPath( BackupPath );
  LocalBackupItemSetLastSyncTimeInfo.SetLastSyncTime( LastSyncTime );
  LocalBackupItemSetLastSyncTimeInfo.Update;
  LocalBackupItemSetLastSyncTimeInfo.Free;
end;

procedure TBackupItemSetLastSyncTimeHandle.SetToXml;
var
  LocalBackupItemSetLastSyncTimeXml : TBackupItemSetLastSyncTimeXml;
begin
  LocalBackupItemSetLastSyncTimeXml := TBackupItemSetLastSyncTimeXml.Create( DesItemID );
  LocalBackupItemSetLastSyncTimeXml.SetBackupPath( BackupPath );
  LocalBackupItemSetLastSyncTimeXml.SetLastSyncTime( LastSyncTime );
  LocalBackupItemSetLastSyncTimeXml.AddChange;
end;

procedure TBackupItemSetLastSyncTimeHandle.SetToFace;
var
  LocalBackupItemSetLastSyncTimeFace : TBackupItemSetLastSyncTimeFace;
begin
  LocalBackupItemSetLastSyncTimeFace := TBackupItemSetLastSyncTimeFace.Create( DesItemID );
  LocalBackupItemSetLastSyncTimeFace.SetBackupPath( BackupPath );
  LocalBackupItemSetLastSyncTimeFace.SetLastSyncTime( LastSyncTime );
  LocalBackupItemSetLastSyncTimeFace.AddChange;
end;

procedure TBackupItemSetLastSyncTimeHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TLocalBackupItemSetSpeedHandle }

procedure TBackupItemSetSpeedHandle.SetSpeed( _Speed : int64 );
begin
  Speed := _Speed;
end;

procedure TBackupItemSetSpeedHandle.SetToFace;
var
  LocalBackupItemSetSpeedFace : TBackupItemSetSpeedFace;
begin
  LocalBackupItemSetSpeedFace := TBackupItemSetSpeedFace.Create( DesItemID );
  LocalBackupItemSetSpeedFace.SetBackupPath( BackupPath );
  LocalBackupItemSetSpeedFace.SetSpeed( Speed );
  LocalBackupItemSetSpeedFace.AddChange;
end;

procedure TBackupItemSetSpeedHandle.Update;
begin
  SetToFace;
end;

{ TBackupSelectedItemHandle }

procedure TBackupSelectedItemHandle.AddToScan;
var
  BackupPathInfo : TBackupPathInfo;
begin
  if DesItemInfoReadUtil.ReadIsLocalDes( DesItemID ) then
    BackupPathInfo := TLocalBackupPathInfo.Create
  else
    BackupPathInfo := TNetworkBackupPathInfo.Create;
  BackupPathInfo.SetItemInfo( DesItemID, BackupPath );
  MyBackupHandler.AddScanPathInfo( BackupPathInfo );
end;

procedure TBackupSelectedItemHandle.Update;
begin
    // 正在备份，跳过
  if BackupItemInfoReadUtil.ReadIsBackuping( DesItemID, BackupPath ) then
    Exit;

    // 先清空上一次的错误
  BackupErrorAppApi.ClearItem( DesItemID, BackupPath );

    // 设置等待备份
  BackupItemAppApi.SetWaitingBackup( DesItemID, BackupPath );

    // 正在备份
  BackupItemAppApi.SetIsBackuping( DesItemID, BackupPath, True );

    // 并未备份完成
  BackupItemAppApi.SetIsCompleted( DesItemID, BackupPath, False );

    // 设置 非繁忙
  BackupItemAppApi.SetIsDesBusy( DesItemID, BackupPath, False );

    // 设置 非连接失败
  BackupItemAppApi.SetIsLostConn( DesItemID, BackupPath, False );

    // 清空未完成
  BackupLogApi.ClearIncompleted( DesItemID, BackupPath );

    // 添加到扫描
  AddToScan;
end;

{ DesItemUserApi }

class procedure DesItemUserApi.AddLocalItem(DesItemID: string);
var
  DesItemAddLocalHandle : TDesItemAddLocalHandle;
begin
  DesItemAddLocalHandle := TDesItemAddLocalHandle.Create( DesItemID );
  DesItemAddLocalHandle.Update;
  DesItemAddLocalHandle.Free;
end;

class procedure DesItemUserApi.BackupSelectItem(DesItemID: string);
var
  BackupDesSelectItemHandle : TBackupDesSelectItemHandle;
begin
  BackupDesSelectItemHandle := TBackupDesSelectItemHandle.Create( DesItemID );
  BackupDesSelectItemHandle.Update;
  BackupDesSelectItemHandle.Free;
end;

class procedure DesItemUserApi.RemoveLocalItem(DesItemID: string);
var
  DesItemRemoveLocalHandle : TDesItemRemoveLocalHandle;
begin
  DesItemRemoveLocalHandle := TDesItemRemoveLocalHandle.Create( DesItemID );
  DesItemRemoveLocalHandle.Update;
  DesItemRemoveLocalHandle.Free;
end;

class procedure DesItemUserApi.RemoveNetworkItem(DesItemID: string);
var
  DesItemRemoveNetworkHandle : TDesItemRemoveNetworkHandle;
begin
  DesItemRemoveNetworkHandle := TDesItemRemoveNetworkHandle.Create( DesItemID );
  DesItemRemoveNetworkHandle.Update;
  DesItemRemoveNetworkHandle.Free;
end;


{ DesItemAppApi }

class procedure DesItemAppApi.AddNetworkItem(DesItemID: string;
  AvailableSpace : Int64);
var
  DesItemAddNetworkHandle : TDesItemAddNetworkHandle;
begin
  DesItemAddNetworkHandle := TDesItemAddNetworkHandle.Create( DesItemID );
  DesItemAddNetworkHandle.SetIsOnline( True );
  DesItemAddNetworkHandle.SetAvailableSpace( AvailableSpace );
  DesItemAddNetworkHandle.Update;
  DesItemAddNetworkHandle.Free;
end;

class procedure DesItemAppApi.SetIsConnected(DesItemID: string;
  IsConnected: Boolean);
var
  DesItemSetIsConnectedHandle : TDesItemSetIsConnectedHandle;
begin
  DesItemSetIsConnectedHandle := TDesItemSetIsConnectedHandle.Create( DesItemID );
  DesItemSetIsConnectedHandle.SetIsConnected( IsConnected );
  DesItemSetIsConnectedHandle.Update;
  DesItemSetIsConnectedHandle.Free;
end;

class procedure DesItemAppApi.SetIsExist(DesItemID: string; IsExist: Boolean);
var
  DesItemSetIsExistHandle : TDesItemSetIsExistHandle;
begin
  DesItemSetIsExistHandle := TDesItemSetIsExistHandle.Create( DesItemID );
  DesItemSetIsExistHandle.SetIsExist( IsExist );
  DesItemSetIsExistHandle.Update;
  DesItemSetIsExistHandle.Free;
end;


class procedure DesItemAppApi.SetNetworkAvaialbleSpace(DesItemID: string;
  AvailableSpace: Int64);
var
  DesItemSetNetworkAvailableSpaceHandle : TDesItemSetNetworkAvailableSpaceHandle;
begin
  DesItemSetNetworkAvailableSpaceHandle := TDesItemSetNetworkAvailableSpaceHandle.Create( DesItemID );
  DesItemSetNetworkAvailableSpaceHandle.SetAvailableSpace( AvailableSpace );
  DesItemSetNetworkAvailableSpaceHandle.Update;
  DesItemSetNetworkAvailableSpaceHandle.Free;
end;

class procedure DesItemAppApi.SetNetworkPcIsOnline(DesPcID: string;
  IsOnline: Boolean);
var
  NetworkDesPcSetIsOnline : TNetworkDesPcSetIsOnline;
begin
  NetworkDesPcSetIsOnline := TNetworkDesPcSetIsOnline.Create( DesPcID );
  NetworkDesPcSetIsOnline.SetIsOnline( IsOnline );
  NetworkDesPcSetIsOnline.Update;
  NetworkDesPcSetIsOnline.Free;
end;

class procedure DesItemAppApi.SetIsLackSpace(DesItemID: string;
  IsLackSpace: Boolean);
var
  DesItemSetIsLackSpaceHandle : TDesItemSetIsLackSpaceHandle;
begin
  DesItemSetIsLackSpaceHandle := TDesItemSetIsLackSpaceHandle.Create( DesItemID );
  DesItemSetIsLackSpaceHandle.SetIsLackSpace( IsLackSpace );
  DesItemSetIsLackSpaceHandle.Update;
  DesItemSetIsLackSpaceHandle.Free;
end;

class procedure DesItemAppApi.SetIsWrite(DesItemID: string; IsWrite: Boolean);
var
  DesItemSetIsWriteHandle : TLocalDesItemSetIsWriteHandle;
begin
  DesItemSetIsWriteHandle := TLocalDesItemSetIsWriteHandle.Create( DesItemID );
  DesItemSetIsWriteHandle.SetIsWrite( IsWrite );
  DesItemSetIsWriteHandle.Update;
  DesItemSetIsWriteHandle.Free;
end;

class procedure DesItemAppApi.SetLocalAvaialbleSpace(DesItemID: string;
  AvailableSpace: Int64);
var
  DesItemSetLocalAvailableSpaceHandle : TDesItemSetLocalAvailableSpaceHandle;
begin
  DesItemSetLocalAvailableSpaceHandle := TDesItemSetLocalAvailableSpaceHandle.Create( DesItemID );
  DesItemSetLocalAvailableSpaceHandle.SetAvailableSpace( AvailableSpace );
  DesItemSetLocalAvailableSpaceHandle.Update;
  DesItemSetLocalAvailableSpaceHandle.Free;
end;


{ TDesItemReadLocalHandle }

procedure TDesItemReadLocalHandle.AddToFace;
var
  AvailableSpace : Int64;
  DesItemAddLocalFace : TDesItemAddLocalFace;
  FrmLocalDesAdd : TFrmLocalDesAdd;
begin
  AvailableSpace := MyHardDisk.getHardDiskFreeSize( DesItemID );

  DesItemAddLocalFace := TDesItemAddLocalFace.Create( DesItemID );
  DesItemAddLocalFace.SetAvailableSpace( AvailableSpace );
  DesItemAddLocalFace.AddChange;

  FrmLocalDesAdd := TFrmLocalDesAdd.Create( DesItemID );
  FrmLocalDesAdd.SetAvailableSpace( AvailableSpace );
  FrmLocalDesAdd.SetIsSelect( getIsAdd );
  FrmLocalDesAdd.AddChange;
end;

procedure TDesItemReadLocalHandle.AddToInfo;
var
  DesItemAddLocalInfo : TDesItemAddLocalInfo;
begin
  DesItemAddLocalInfo := TDesItemAddLocalInfo.Create( DesItemID );
  DesItemAddLocalInfo.Update;
  DesItemAddLocalInfo.Free;
end;

function TDesItemReadLocalHandle.getIsAdd: Boolean;
begin
  Result := False;
end;

procedure TDesItemReadLocalHandle.Update;
begin
  AddToInfo;
  AddToFace;
end;

{ TDesItemAddLocalHandle }

procedure TDesItemAddLocalHandle.AddToEvent;
begin
  LocalBackupEvent.AddDesPath( DesItemID );
end;

procedure TDesItemAddLocalHandle.AddToXml;
var
  DesItemAddLocalXml : TDesItemAddLocalXml;
begin
  DesItemAddLocalXml := TDesItemAddLocalXml.Create( DesItemID );
  DesItemAddLocalXml.AddChange;
end;

function TDesItemAddLocalHandle.getIsAdd: Boolean;
begin
  Result := True;
end;

procedure TDesItemAddLocalHandle.Update;
begin
  inherited;
  AddToXml;
  AddToEvent;
end;

{ TDesItemReadNetworkHandle }

procedure TDesItemReadNetworkHandle.AddToFace;
var
  DesPcName : string;
  DesItemAddNetworkFace : TDesItemAddNetworkFace;
  FrmNetworkDesAdd : TFrmNetworkDesAdd;
  FrmBackupPcFilterAdd : TFrmBackupPcFilterAdd;
  PcID, PcName, Directory : string;
begin
  PcID := NetworkDesItemUtil.getPcID( DesItemID );
  if PcID = PcInfo.PcID then // 不添加本机
    Exit;

  DesPcName := MyNetPcInfoReadUtil.ReadDesItemShow( DesItemID );

  DesItemAddNetworkFace := TDesItemAddNetworkFace.Create( DesItemID );
  DesItemAddNetworkFace.SetPcName( DesPcName );
  DesItemAddNetworkFace.SetIsOnline( IsOnline );
  DesItemAddNetworkFace.SetAvailableSpace( AvailableSpace );
  DesItemAddNetworkFace.AddChange;

  FrmNetworkDesAdd := TFrmNetworkDesAdd.Create( DesItemID );
  FrmNetworkDesAdd.SetPcName( DesPcName );
  FrmNetworkDesAdd.SetIsOnline( IsOnline );
  FrmNetworkDesAdd.SetAvailableSpace( AvailableSpace );
  FrmNetworkDesAdd.AddChange;

  PcName := MyNetPcInfoReadUtil.ReadName( PcID );
  Directory := NetworkDesItemUtil.getCloudPath( DesItemID );
  FrmBackupPcFilterAdd := TFrmBackupPcFilterAdd.Create( DesItemID );
  FrmBackupPcFilterAdd.SetPcName( PcName );
  FrmBackupPcFilterAdd.SetDirectory( Directory );
  FrmBackupPcFilterAdd.SetIsOnline( IsOnline );
  FrmBackupPcFilterAdd.AddChange;
end;

procedure TDesItemReadNetworkHandle.AddToInfo;
var
  DesItemAddNetworkInfo : TDesItemAddNetworkInfo;
begin
  DesItemAddNetworkInfo := TDesItemAddNetworkInfo.Create( DesItemID );
  DesItemAddNetworkInfo.Update;
  DesItemAddNetworkInfo.Free;
end;

procedure TDesItemReadNetworkHandle.SetAvailableSpace(_AvailableSpace: Int64);
begin
  AvailableSpace := _AvailableSpace;
end;

procedure TDesItemReadNetworkHandle.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TDesItemReadNetworkHandle.Update;
begin
  AddToInfo;
  AddToFace;
end;

{ TDesItemAddNetworkHandle }

procedure TDesItemAddNetworkHandle.AddToXml;
var
  DesItemAddNetworkXml : TDesItemAddNetworkXml;
begin
  DesItemAddNetworkXml := TDesItemAddNetworkXml.Create( DesItemID );
  DesItemAddNetworkXml.AddChange;
end;

procedure TDesItemAddNetworkHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TBackupItemCompletedHandle }

procedure TBackupItemStopHandle.Update;
begin
    // 设置 非正在备份
  BackupItemAppApi.SetIsBackuping( DesItemID, BackupPath, False );

    // 设置 状态为空
  BackupItemAppApi.SetBackupItemStatus( DesItemID, BackupPath, BackupNodeStatus_Empty );
end;

{ TBackupItemCompletedHandle }

procedure TBackupItemCompletedHandle.Update;
begin
    // 设置 备份完成标记
  BackupItemAppApi.SetIsCompleted( DesItemID, BackupPath, True );

    // 设置 上一次 自动备份 完成时间
  BackupItemAppApi.RefreshLastSyncTime( DesItemID, BackupPath );

    // 触发事件
  AddToEvent;
end;

{ TBackupItemRemoveNetworkHandle }

procedure TBackupItemRemoveNetworkHandle.RemoveFromEvent;
begin
  NetworkBackupEvent.RemoveBackupItem( DesItemID, BackupPath );
end;

procedure TBackupItemRemoveNetworkHandle.Update;
begin
  inherited;

  if IsDelete then
    RemoveFromEvent;
end;

{ TBackupItemRemoveLocalHandle }

procedure TBackupItemRemoveLocalHandle.RemoveFromEvent;
begin
  LocalBackupEvent.RemoveBackupItem( DesItemID, BackupPath );
end;

procedure TBackupItemRemoveLocalHandle.Update;
begin
  inherited;

  if IsDelete then
    RemoveFromEvent;
end;

{ TBackupStartHandle }

procedure TBackupStartHandle.SetToFace;
var
  StartBackupFace : TStartBackupFace;
  StartBackupTrayFace : TStartBackupTrayFace;
begin
  StartBackupFace := TStartBackupFace.Create;
  StartBackupFace.AddChange;

  StartBackupTrayFace := TStartBackupTrayFace.Create;
  StartBackupTrayFace.AddChange;
end;

procedure TBackupStartHandle.Update;
begin
  UserBackup_IsStop := False;

  SetToFace;
end;

{ TBackupStopHandle }

procedure TBackupStopHandle.SetToFace;
var
  StopBackupFace : TStopBackupFace;
  StopBackupTrayFace : TStopBackupTrayFace;
begin
  StopBackupFace := TStopBackupFace.Create;
  StopBackupFace.AddChange;

  StopBackupTrayFace := TStopBackupTrayFace.Create;
  StopBackupTrayFace.AddChange;
end;

procedure TBackupStopHandle.Update;
begin
  SetToFace;
end;

{ TBackupItemSetIsBackupingHandle }

procedure TBackupItemSetIsBackupingHandle.SetIsBackuping( _IsBackuping : boolean );
begin
  IsBackuping := _IsBackuping;
end;

procedure TBackupItemSetIsBackupingHandle.SetToInfo;
var
  BackupItemSetIsBackupingInfo : TBackupItemSetIsBackupingInfo;
begin
  BackupItemSetIsBackupingInfo := TBackupItemSetIsBackupingInfo.Create( DesItemID );
  BackupItemSetIsBackupingInfo.SetBackupPath( BackupPath );
  BackupItemSetIsBackupingInfo.SetIsBackuping( IsBackuping );
  BackupItemSetIsBackupingInfo.Update;
  BackupItemSetIsBackupingInfo.Free;
end;

procedure TBackupItemSetIsBackupingHandle.SetToFace;
var
  BackupItemSetIsBackupingFace : TBackupItemSetIsBackupingFace;
begin
  BackupItemSetIsBackupingFace := TBackupItemSetIsBackupingFace.Create( DesItemID );
  BackupItemSetIsBackupingFace.SetBackupPath( BackupPath );
  BackupItemSetIsBackupingFace.SetIsBackuping( IsBackuping );
  BackupItemSetIsBackupingFace.AddChange;
end;

procedure TBackupItemSetIsBackupingHandle.Update;
begin
  SetToInfo;
  SetToFace;
end;



{ TBackupItemIncludeFilterSetHandle }

procedure TBackupItemIncludeFilterReadHandle.SetIncludeFilterList(
  _IncludeFilterList: TFileFilterList);
begin
  IncludeFilterList := _IncludeFilterList;
end;

procedure TBackupItemIncludeFilterReadHandle.SetToFace;
var
  IncludeFilterStr : string;
  BackupItemSetIncludeFilterFace : TBackupItemSetIncludeFilterFace;
begin
  IncludeFilterStr := FileFilterUtil.getFilterStr( IncludeFilterList );

  BackupItemSetIncludeFilterFace := TBackupItemSetIncludeFilterFace.Create( DesItemID );
  BackupItemSetIncludeFilterFace.SetBackupPath( BackupPath );
  BackupItemSetIncludeFilterFace.SetIncludeFilterStr( IncludeFilterStr );
  BackupItemSetIncludeFilterFace.AddChange;
end;

procedure TBackupItemIncludeFilterReadHandle.SetToInfo;
var
  BackupItemIncludeFilterClearInfo : TBackupItemIncludeFilterClearInfo;
  BackupItemIncludeFilterAddInfo : TBackupItemIncludeFilterAddInfo;
  i : Integer;
begin
    // 清空旧的
  BackupItemIncludeFilterClearInfo := TBackupItemIncludeFilterClearInfo.Create( DesItemID );
  BackupItemIncludeFilterClearInfo.SetBackupPath( BackupPath );
  BackupItemIncludeFilterClearInfo.Update;
  BackupItemIncludeFilterClearInfo.Free;

    // 添加新的
  for i := 0 to IncludeFilterList.Count - 1 do
  begin
    BackupItemIncludeFilterAddInfo := TBackupItemIncludeFilterAddInfo.Create( DesItemID );
    BackupItemIncludeFilterAddInfo.SetBackupPath( BackupPath );
    BackupItemIncludeFilterAddInfo.SetFilterInfo( IncludeFilterList[i].FilterType, IncludeFilterList[i].FilterStr );
    BackupItemIncludeFilterAddInfo.Update;
    BackupItemIncludeFilterAddInfo.Free;
  end;
end;

procedure TBackupItemIncludeFilterReadHandle.Update;
begin
  SetToInfo;
  SetToFace;
end;

{ TBackupItemIncludeFilterSetHandle }

procedure TBackupItemIncludeFilterSetHandle.SetToXml;
var
  BackupItemIncludeFilterClearXml : TBackupItemIncludeFilterClearXml;
  BackupItemIncludeFilterAddXml : TBackupItemIncludeFilterAddXml;
  i : Integer;
begin
    // 清空旧的
  BackupItemIncludeFilterClearXml := TBackupItemIncludeFilterClearXml.Create( DesItemID );
  BackupItemIncludeFilterClearXml.SetBackupPath( BackupPath );
  BackupItemIncludeFilterClearXml.AddChange;

    // 添加新的
  for i := 0 to IncludeFilterList.Count - 1 do
  begin
    BackupItemIncludeFilterAddXml := TBackupItemIncludeFilterAddXml.Create( DesItemID );
    BackupItemIncludeFilterAddXml.SetBackupPath( BackupPath );
    BackupItemIncludeFilterAddXml.SetFilterXml( IncludeFilterList[i].FilterType, IncludeFilterList[i].FilterStr );
    BackupItemIncludeFilterAddXml.AddChange;
  end;
end;


procedure TBackupItemIncludeFilterSetHandle.Update;
begin
  inherited;
  SetToXml;
end;

{ TBackupItemExcludeFilterReadHandle }

procedure TBackupItemExcludeFilterReadHandle.SetExcludeFilterList(
  _ExcludeFilterList: TFileFilterList);
begin
  ExcludeFilterList := _ExcludeFilterList;
end;

procedure TBackupItemExcludeFilterReadHandle.SetToFace;
var
  ExcludeFilterStr : string;
  BackupItemSetExcludeFilterFace : TBackupItemSetExcludeFilterFace;
begin
  ExcludeFilterStr := FileFilterUtil.getFilterStr( ExcludeFilterList );

  BackupItemSetExcludeFilterFace := TBackupItemSetExcludeFilterFace.Create( DesItemID );
  BackupItemSetExcludeFilterFace.SetBackupPath( BackupPath );
  BackupItemSetExcludeFilterFace.SetExcludeFilterStr( ExcludeFilterStr );
  BackupItemSetExcludeFilterFace.AddChange;
end;

procedure TBackupItemExcludeFilterReadHandle.SetToInfo;
var
  BackupItemExcludeFilterClearInfo : TBackupItemExcludeFilterClearInfo;
  BackupItemExcludeFilterAddInfo : TBackupItemExcludeFilterAddInfo;
  i : Integer;
begin
    // 清空旧的
  BackupItemExcludeFilterClearInfo := TBackupItemExcludeFilterClearInfo.Create( DesItemID );
  BackupItemExcludeFilterClearInfo.SetBackupPath( BackupPath );
  BackupItemExcludeFilterClearInfo.Update;
  BackupItemExcludeFilterClearInfo.Free;

    // 添加新的
  for i := 0 to ExcludeFilterList.Count - 1 do
  begin
    BackupItemExcludeFilterAddInfo := TBackupItemExcludeFilterAddInfo.Create( DesItemID );
    BackupItemExcludeFilterAddInfo.SetBackupPath( BackupPath );
    BackupItemExcludeFilterAddInfo.SetFilterInfo( ExcludeFilterList[i].FilterType, ExcludeFilterList[i].FilterStr );
    BackupItemExcludeFilterAddInfo.Update;
    BackupItemExcludeFilterAddInfo.Free;
  end;
end;


procedure TBackupItemExcludeFilterReadHandle.Update;
begin
  SetToInfo;
  SetToFace;
end;

{ TBackupItemExcludeFilterSetHandle }

procedure TBackupItemExcludeFilterSetHandle.SetToXml;
var
  BackupItemExcludeFilterClearXml : TBackupItemExcludeFilterClearXml;
  BackupItemExcludeFilterAddXml : TBackupItemExcludeFilterAddXml;
  i : Integer;
begin
    // 清空旧的
  BackupItemExcludeFilterClearXml := TBackupItemExcludeFilterClearXml.Create( DesItemID );
  BackupItemExcludeFilterClearXml.SetBackupPath( BackupPath );
  BackupItemExcludeFilterClearXml.AddChange;

    // 添加新的
  for i := 0 to ExcludeFilterList.Count - 1 do
  begin
    BackupItemExcludeFilterAddXml := TBackupItemExcludeFilterAddXml.Create( DesItemID );
    BackupItemExcludeFilterAddXml.SetBackupPath( BackupPath );
    BackupItemExcludeFilterAddXml.SetFilterXml( ExcludeFilterList[i].FilterType, ExcludeFilterList[i].FilterStr );
    BackupItemExcludeFilterAddXml.AddChange;
  end;
end;


procedure TBackupItemExcludeFilterSetHandle.Update;
begin
  inherited;
  SetToXml;
end;

{ TBackupItemSetAutoSyncHandle }

procedure TBackupItemSetAutoSyncHandle.SetAutoSyncInfo( _IsAutoSync : boolean );
begin
  IsAutoSync := _IsAutoSync;
end;

procedure TBackupItemSetAutoSyncHandle.SetSyncTimeInfo( _SyncTimeType, _SyncTimeValue : integer );
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TBackupItemSetAutoSyncHandle.SetToInfo;
var
  BackupItemSetAutoSyncInfo : TBackupItemSetAutoSyncInfo;
begin
  BackupItemSetAutoSyncInfo := TBackupItemSetAutoSyncInfo.Create( DesItemID );
  BackupItemSetAutoSyncInfo.SetBackupPath( BackupPath );
  BackupItemSetAutoSyncInfo.SetIsAutoSync( IsAutoSync );
  BackupItemSetAutoSyncInfo.SetSyncInterval( SyncTimeType, SyncTimeValue );
  BackupItemSetAutoSyncInfo.Update;
  BackupItemSetAutoSyncInfo.Free;
end;

procedure TBackupItemSetAutoSyncHandle.SetToXml;
var
  BackupItemSetAutoSyncXml : TBackupItemSetAutoSyncXml;
begin
  BackupItemSetAutoSyncXml := TBackupItemSetAutoSyncXml.Create( DesItemID );
  BackupItemSetAutoSyncXml.SetBackupPath( BackupPath );
  BackupItemSetAutoSyncXml.SetIsAutoSync( IsAutoSync );
  BackupItemSetAutoSyncXml.SetSyncInterval( SyncTimeType, SyncTimeValue );
  BackupItemSetAutoSyncXml.AddChange;
end;

procedure TBackupItemSetAutoSyncHandle.SetToFace;
var
  BackupItemSetAutoSyncFace : TBackupItemSetAutoSyncFace;
begin
  BackupItemSetAutoSyncFace := TBackupItemSetAutoSyncFace.Create( DesItemID );
  BackupItemSetAutoSyncFace.SetBackupPath( BackupPath );
  BackupItemSetAutoSyncFace.SetIsAutoSync( IsAutoSync );
  BackupItemSetAutoSyncFace.SetSyncTime( SyncTimeType, SyncTimeValue );
  BackupItemSetAutoSyncFace.AddChange;
end;

procedure TBackupItemSetAutoSyncHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TBackupItemSetEncryptInfoHandle }

procedure TBackupItemSetEncryptInfoHandle.SetEncryptInfo( _IsEncrypt : boolean; _Password, _PasswordHint : string );
begin
  IsEncrypt := _IsEncrypt;
  Password := _Password;
  PasswordHint := _PasswordHint;
end;

procedure TBackupItemSetEncryptInfoHandle.SetToInfo;
var
  BackupItemSetEncryptInfoInfo : TBackupItemSetEncryptInfoInfo;
begin
  BackupItemSetEncryptInfoInfo := TBackupItemSetEncryptInfoInfo.Create( DesItemID );
  BackupItemSetEncryptInfoInfo.SetBackupPath( BackupPath );
  BackupItemSetEncryptInfoInfo.SetEncryptInfo( IsEncrypt, Password, PasswordHint );
  BackupItemSetEncryptInfoInfo.Update;
  BackupItemSetEncryptInfoInfo.Free;
end;

procedure TBackupItemSetEncryptInfoHandle.SetToXml;
var
  BackupItemSetEncryptInfoXml : TBackupItemSetEncryptInfoXml;
begin
  BackupItemSetEncryptInfoXml := TBackupItemSetEncryptInfoXml.Create( DesItemID );
  BackupItemSetEncryptInfoXml.SetBackupPath( BackupPath );
  BackupItemSetEncryptInfoXml.SetEncryptInfo( IsEncrypt, Password, PasswordHint );
  BackupItemSetEncryptInfoXml.AddChange;
end;

procedure TBackupItemSetEncryptInfoHandle.SetToFace;
var
  BackupItemSetEncryptInfoFace : TBackupItemSetEncryptInfoFace;
begin
  BackupItemSetEncryptInfoFace := TBackupItemSetEncryptInfoFace.Create( DesItemID );
  BackupItemSetEncryptInfoFace.SetBackupPath( BackupPath );
  BackupItemSetEncryptInfoFace.SetEncryptInfo( IsEncrypt, PasswordHint );
  BackupItemSetEncryptInfoFace.AddChange;
end;

procedure TBackupItemSetEncryptInfoHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TBackupItemSetDeletedInfoHandle }

procedure TBackupItemSetDeletedInfoHandle.SetDeletedInfo( _IsKeepDeleted : boolean; _KeepEditionCount : integer );
begin
  IsKeepDeleted := _IsKeepDeleted;
  KeepEditionCount := _KeepEditionCount;
end;

procedure TBackupItemSetDeletedInfoHandle.SetToFace;
var
  BackupItemSetRecycleFace : TBackupItemSetRecycleFace;
begin
  BackupItemSetRecycleFace := TBackupItemSetRecycleFace.Create( DesItemID );
  BackupItemSetRecycleFace.SetBackupPath( BackupPath );
  BackupItemSetRecycleFace.SetDeleteInfo( IsKeepDeleted, KeepEditionCount );
  BackupItemSetRecycleFace.AddChange;
end;

procedure TBackupItemSetDeletedInfoHandle.SetToInfo;
var
  BackupItemSetDeletedInfoInfo : TBackupItemSetRecycleInfo;
begin
  BackupItemSetDeletedInfoInfo := TBackupItemSetRecycleInfo.Create( DesItemID );
  BackupItemSetDeletedInfoInfo.SetBackupPath( BackupPath );
  BackupItemSetDeletedInfoInfo.SetDeleteInfo( IsKeepDeleted, KeepEditionCount );
  BackupItemSetDeletedInfoInfo.Update;
  BackupItemSetDeletedInfoInfo.Free;
end;

procedure TBackupItemSetDeletedInfoHandle.SetToXml;
var
  BackupItemSetDeletedInfoXml : TBackupItemSetDeletedInfoXml;
begin
  BackupItemSetDeletedInfoXml := TBackupItemSetDeletedInfoXml.Create( DesItemID );
  BackupItemSetDeletedInfoXml.SetBackupPath( BackupPath );
  BackupItemSetDeletedInfoXml.SetDeletedInfo( IsKeepDeleted, KeepEditionCount );
  BackupItemSetDeletedInfoXml.AddChange;
end;

procedure TBackupItemSetDeletedInfoHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;


{ TBackupItemRefreshAutoSyncHandle }

procedure TBackupItemRefreshAutoSyncHandle.SetToFace;
var
  DesItemRefreshSyncFace : TDesItemRefreshSyncFace;
begin
  DesItemRefreshSyncFace := TDesItemRefreshSyncFace.Create;
  DesItemRefreshSyncFace.AddChange;
end;

procedure TBackupItemRefreshAutoSyncHandle.Update;
begin
  SetToFace;
end;

{ TBackupAllItemsHandle }

procedure TBackupAllItemsHandle.BackupLocalItem;
var
  DesItemList, BackupItemList : TStringList;
  i, j : Integer;
  DesItemID : string;
begin
  DesItemList := DesItemInfoReadUtil.ReadLocaDesList;
  for i := 0 to DesItemList.Count - 1 do
  begin
    DesItemID := DesItemList[i];
    BackupItemList := DesItemInfoReadUtil.ReadBackupAllList( DesItemID );
    for j := 0 to BackupItemList.Count - 1 do
      BackupItemUserApi.BackupSelectItem( DesItemID, BackupItemList[j] );
    BackupItemList.Free;
  end;
  DesItemList.Free;
end;

procedure TBackupAllItemsHandle.BackupNetworkItem;
var
  DesItemList, BackupItemList : TStringList;
  i, j : Integer;
  DesItemID : string;
begin
  DesItemList := DesItemInfoReadUtil.ReadNetworkDesList;
  for i := 0 to DesItemList.Count - 1 do
  begin
    DesItemID := DesItemList[i];
    BackupItemList := DesItemInfoReadUtil.ReadBackupAllList( DesItemID );
    for j := 0 to BackupItemList.Count - 1 do
      BackupItemUserApi.BackupSelectItem( DesItemID, BackupItemList[j] );
    BackupItemList.Free;
  end;
  DesItemList.Free;
end;


procedure TBackupAllItemsHandle.Update;
begin
  BackupLocalItem;
  BackupNetworkItem;
end;

{ BackupLogApi }

class procedure BackupLogApi.AddCompleted(Prams: TBackupLogAddParams);
var
  BackupLogCompletedAddHandle : TBackupLogCompletedAddHandle;
begin
  BackupLogCompletedAddHandle := TBackupLogCompletedAddHandle.Create( Prams.DesItemID );
  BackupLogCompletedAddHandle.SetBackupPath( Prams.SourcePath );
  BackupLogCompletedAddHandle.SetBackupDate( Prams.BackupDate );
  BackupLogCompletedAddHandle.SetFilePath( Prams.FilePath );
  BackupLogCompletedAddHandle.SetBackupTime( Prams.FileTime, Prams.BackupTime );
  BackupLogCompletedAddHandle.Update;
  BackupLogCompletedAddHandle.Free;
end;

class procedure BackupLogApi.AddIncompleted(DesItemID, BackupPath, FilePath : string);
var
  BackupLogIncompletedAddHandle : TBackupLogIncompletedAddHandle;
begin
  BackupLogIncompletedAddHandle := TBackupLogIncompletedAddHandle.Create( DesItemID );
  BackupLogIncompletedAddHandle.SetBackupPath( BackupPath );
  BackupLogIncompletedAddHandle.SetFilePath( FilePath );
  BackupLogIncompletedAddHandle.Update;
  BackupLogIncompletedAddHandle.Free;
end;



class procedure BackupLogApi.ClearCompleted( DesItemID, BackupPath : string );
var
  BackupLogClearCompletedHandle : TBackupLogClearCompletedHandle;
begin
  BackupLogClearCompletedHandle := TBackupLogClearCompletedHandle.Create( DesItemID );
  BackupLogClearCompletedHandle.SetBackupPath( BackupPath );
  BackupLogClearCompletedHandle.Update;
  BackupLogClearCompletedHandle.Free;
end;

class procedure BackupLogApi.ClearIncompleted( DesItemID, BackupPath : string );
var
  BackupLogClearIncompletedHandle : TBackupLogClearIncompletedHandle;
begin
  BackupLogClearIncompletedHandle := TBackupLogClearIncompletedHandle.Create( DesItemID );
  BackupLogClearIncompletedHandle.SetBackupPath( BackupPath );
  BackupLogClearIncompletedHandle.Update;
  BackupLogClearIncompletedHandle.Free;
end;

class procedure BackupLogApi.RefreshLogFace(DesItemID, SourcePath: string);
var
  RefreshBackupLogHandle : TRefreshBackupLogHandle;
begin
  RefreshBackupLogHandle := TRefreshBackupLogHandle.Create( DesItemID, SourcePath );
  RefreshBackupLogHandle.Update;
  RefreshBackupLogHandle.Free;
end;

{ TNetworkDesPcSetIsOnline }

constructor TNetworkDesPcSetIsOnline.Create(_DesPcID: string);
begin
  DesPcID := _DesPcID;
end;

procedure TNetworkDesPcSetIsOnline.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TNetworkDesPcSetIsOnline.SetToFace;
var
  DesItemSetPcIsOnlineFace : TDesItemSetPcIsOnlineFace;
  FrmNetworkDesIsOnline : TFrmNetworkDesIsOnline;
  FrmBackupPcFilterIsOnline : TFrmBackupPcFilterIsOnline;
begin
  DesItemSetPcIsOnlineFace := TDesItemSetPcIsOnlineFace.Create( DesPcID );
  DesItemSetPcIsOnlineFace.SetIsOnline( IsOnline );
  DesItemSetPcIsOnlineFace.AddChange;

  FrmNetworkDesIsOnline := TFrmNetworkDesIsOnline.Create( DesPcID );
  FrmNetworkDesIsOnline.SetIsOnline( IsOnline );
  FrmNetworkDesIsOnline.AddChange;

  FrmBackupPcFilterIsOnline := TFrmBackupPcFilterIsOnline.Create( DesPcID );
  FrmBackupPcFilterIsOnline.SetIsOnline( IsOnline );
  FrmBackupPcFilterIsOnline.AddChange;
end;

procedure TNetworkDesPcSetIsOnline.Update;
begin
  SetToFace;
end;

{ TBackupItemSetIsCompletedHandle }

procedure TBackupItemSetIsCompletedHandle.SetIsCompleted( _IsCompleted : boolean );
begin
  IsCompleted := _IsCompleted;
end;

procedure TBackupItemSetIsCompletedHandle.SetToInfo;
var
  BackupItemSetIsCompletedInfo : TBackupItemSetIsCompletedInfo;
begin
  BackupItemSetIsCompletedInfo := TBackupItemSetIsCompletedInfo.Create( DesItemID );
  BackupItemSetIsCompletedInfo.SetBackupPath( BackupPath );
  BackupItemSetIsCompletedInfo.SetIsCompleted( IsCompleted );
  BackupItemSetIsCompletedInfo.Update;
  BackupItemSetIsCompletedInfo.Free;
end;

procedure TBackupItemSetIsCompletedHandle.SetToXml;
var
  BackupItemSetIsCompletedXml : TBackupItemSetIsCompletedXml;
begin
  BackupItemSetIsCompletedXml := TBackupItemSetIsCompletedXml.Create( DesItemID );
  BackupItemSetIsCompletedXml.SetBackupPath( BackupPath );
  BackupItemSetIsCompletedXml.SetIsCompleted( IsCompleted );
  BackupItemSetIsCompletedXml.AddChange;
end;

procedure TBackupItemSetIsCompletedHandle.SetToFace;
var
  BackupItemSetIsCompletedFace : TBackupItemSetIsCompletedFace;
begin
  BackupItemSetIsCompletedFace := TBackupItemSetIsCompletedFace.Create( DesItemID );
  BackupItemSetIsCompletedFace.SetBackupPath( BackupPath );
  BackupItemSetIsCompletedFace.SetIsCompleted( IsCompleted );
  BackupItemSetIsCompletedFace.AddChange;
end;

procedure TBackupItemSetIsCompletedHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;




{ TBackupItemLocalCompletedHandle }

procedure TBackupItemLocalCompletedHandle.AddToEvent;
var
  RestoreSourceInfo : TRestoreSourceInfo;
  EventParams : TBackupCompletedEventParams;
begin
    // 恢复恢复信息
  RestoreSourceInfo := BackupItemInfoReadUtil.ReadRestoreSourceInfo( DesItemID, BackupPath );

      // 触发事件
  EventParams.DesItemID := RestoreSourceInfo.DesItemID;
  EventParams.SourcePath := RestoreSourceInfo.SourcePath;
  EventParams.IsFile := FileExists( RestoreSourceInfo.SourcePath );
  EventParams.FileCount := RestoreSourceInfo.FileCount;
  EventParams.FileSpce := RestoreSourceInfo.ItemSpace;
  EventParams.IsSaveDeleted := RestoreSourceInfo.IsSaveDeleted;
  EventParams.IsEncrypted := RestoreSourceInfo.IsEncrypted;
  EventParams.Password := RestoreSourceInfo.Password;
  EventParams.PasswordHint := RestoreSourceInfo.PasswordHint;
  LocalBackupEvent.BackupCompleted( EventParams );

  RestoreSourceInfo.Free;
end;

{ TBackupItemNetworkCompletedHandle }

procedure TBackupItemNetworkCompletedHandle.AddToEvent;
var
  RestoreSourceInfo : TRestoreSourceInfo;
  EventParams : TBackupCompletedEventParams;
begin
    // 恢复恢复信息
  RestoreSourceInfo := BackupItemInfoReadUtil.ReadRestoreSourceInfo( DesItemID, BackupPath );

      // 触发事件
  EventParams.DesItemID := RestoreSourceInfo.DesItemID;
  EventParams.SourcePath := RestoreSourceInfo.SourcePath;
  EventParams.IsFile := FileExists( RestoreSourceInfo.SourcePath );
  EventParams.FileCount := RestoreSourceInfo.FileCount;
  EventParams.FileSpce := RestoreSourceInfo.ItemSpace;
  EventParams.IsSaveDeleted := RestoreSourceInfo.IsSaveDeleted;
  EventParams.IsEncrypted := RestoreSourceInfo.IsEncrypted;
  EventParams.Password := RestoreSourceInfo.Password;
  EventParams.PasswordHint := RestoreSourceInfo.PasswordHint;
  NetworkBackupEvent.BackupCompleted( EventParams );

  RestoreSourceInfo.Free;
end;

{ TBackupItemLocalOnlineBackup }

procedure TBackupItemLocalOnlineBackup.Update;
var
  OnlineBackupList : TBackupKeyItemList;
  i: Integer;
begin
  OnlineBackupList := BackupItemInfoReadUtil.ReadLocalIncompletedList;
  for i := 0 to OnlineBackupList.Count - 1 do
    BackupItemUserApi.BackupSelectItem( OnlineBackupList[i].DesItem, OnlineBackupList[i].BackupPath );
  OnlineBackupList.Free;
end;

{ TBackupItemNetworkOnlineBackup }

constructor TBackupItemNetworkOnlineBackup.Create(_OnlinePcID: string);
begin
  OnlinePcID := _OnlinePcID;
end;

procedure TBackupItemNetworkOnlineBackup.Update;
var
  OnlineBackupList : TBackupKeyItemList;
  i: Integer;
begin
  OnlineBackupList := BackupItemInfoReadUtil.ReadPcOnline( OnlinePcID );
  for i := 0 to OnlineBackupList.Count - 1 do
    BackupItemUserApi.BackupSelectItem( OnlineBackupList[i].DesItem, OnlineBackupList[i].BackupPath );
  OnlineBackupList.Free;
end;

{ TBackupItemSetAnalyizeCountHandle }

procedure TBackupItemSetAnalyizeCountHandle.SetAnalyizeCount( _AnalyizeCount : integer );
begin
  AnalyizeCount := _AnalyizeCount;
end;


procedure TBackupItemSetAnalyizeCountHandle.SetToFace;
var
  BackupItemSetAnalyizeCountFace : TBackupItemSetAnalyizeCountFace;
begin
  BackupItemSetAnalyizeCountFace := TBackupItemSetAnalyizeCountFace.Create( DesItemID );
  BackupItemSetAnalyizeCountFace.SetBackupPath( BackupPath );
  BackupItemSetAnalyizeCountFace.SetAnalyizeCount( AnalyizeCount );
  BackupItemSetAnalyizeCountFace.AddChange;
end;

procedure TBackupItemSetAnalyizeCountHandle.Update;
begin
  SetToFace;
end;


{ TDesItemSetAvailableSpaceHandle }

procedure TDesItemSetAvailableSpaceHandle.SetAvailableSpace( _AvailableSpace : int64 );
begin
  AvailableSpace := _AvailableSpace;
end;

procedure TDesItemSetAvailableSpaceHandle.SetToFace;
var
  DesItemSetAvailableSpaceFace : TDesItemSetAvailableSpaceFace;
begin
    // 主界面空间信息
  DesItemSetAvailableSpaceFace := TDesItemSetAvailableSpaceFace.Create( DesItemID );
  DesItemSetAvailableSpaceFace.SetAvailableSpace( AvailableSpace );
  DesItemSetAvailableSpaceFace.AddChange;
end;

procedure TDesItemSetAvailableSpaceHandle.Update;
begin
  SetToFace;
end;

{ BackupContinusAppApi }

class procedure BackupContinusAppApi.AddItem(Params: TBackupContinusAddParams);
var
  BackupContinusAddHandle : TBackupContinusAddHandle;
begin
  BackupContinusAddHandle := TBackupContinusAddHandle.Create( Params.DesItemID );
  BackupContinusAddHandle.SetBackupPath( Params.SourcePath );
  BackupContinusAddHandle.SetFilePath( Params.FilePath );
  BackupContinusAddHandle.SetFileInfo( Params.FileSize, Params.FileTime );
  BackupContinusAddHandle.Update;
  BackupContinusAddHandle.Free;
end;



class procedure BackupContinusAppApi.RemoveItem(DesItemID, SourcePath,
  SourceFilePath: string);
var
  BackupContinusRemoveHandle : TBackupContinusRemoveHandle;
begin
  BackupContinusRemoveHandle := TBackupContinusRemoveHandle.Create( DesItemID );
  BackupContinusRemoveHandle.SetBackupPath( SourcePath );
  BackupContinusRemoveHandle.SetFilePath( SourceFilePath );
  BackupContinusRemoveHandle.Update;
  BackupContinusRemoveHandle.Free;
end;



procedure TBackupContinusWriteHandle.SetFilePath( _FilePath : string );
begin
  FilePath := _FilePath;
end;

{ TBackupContinusReadHandle }

procedure TBackupContinusReadHandle.SetFileInfo( _FileSize: int64;
  _FileTime : TDateTime );
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TBackupContinusReadHandle.AddToInfo;
var
  BackupContinusAddInfo : TBackupContinusAddInfo;
begin
  BackupContinusAddInfo := TBackupContinusAddInfo.Create( DesItemID );
  BackupContinusAddInfo.SetBackupPath( BackupPath );
  BackupContinusAddInfo.SetFilePath( FilePath );
  BackupContinusAddInfo.SetFileInfo( FileSize, FileTime );
  BackupContinusAddInfo.Update;
  BackupContinusAddInfo.Free;
end;

procedure TBackupContinusReadHandle.Update;
begin
  AddToInfo;
end;

{ TBackupContinusAddHandle }

procedure TBackupContinusAddHandle.AddToXml;
var
  BackupContinusAddXml : TBackupContinusAddXml;
begin
  BackupContinusAddXml := TBackupContinusAddXml.Create( DesItemID );
  BackupContinusAddXml.SetBackupPath( BackupPath );
  BackupContinusAddXml.SetFilePath( FilePath );
  BackupContinusAddXml.SetFileInfo( FileSize, FileTime );
  BackupContinusAddXml.AddChange;
end;

procedure TBackupContinusAddHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TBackupContinusRemoveHandle }

procedure TBackupContinusRemoveHandle.RemoveFromInfo;
var
  BackupContinusRemoveInfo : TBackupContinusRemoveInfo;
begin
  BackupContinusRemoveInfo := TBackupContinusRemoveInfo.Create( DesItemID );
  BackupContinusRemoveInfo.SetBackupPath( BackupPath );
  BackupContinusRemoveInfo.SetFilePath( FilePath );
  BackupContinusRemoveInfo.Update;
  BackupContinusRemoveInfo.Free;
end;

procedure TBackupContinusRemoveHandle.RemoveFromXml;
var
  BackupContinusRemoveXml : TBackupContinusRemoveXml;
begin
  BackupContinusRemoveXml := TBackupContinusRemoveXml.Create( DesItemID );
  BackupContinusRemoveXml.SetBackupPath( BackupPath );
  BackupContinusRemoveXml.SetFilePath( FilePath );
  BackupContinusRemoveXml.AddChange;
end;

procedure TBackupContinusRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromXml;
end;


{ TBackupPauseHandle }

procedure TBackupPauseHandle.SetToFace;
var
  PauseBackupFace : TPauseBackupFace;
  StopBackupTrayFace : TStopBackupTrayFace;
begin
  PauseBackupFace := TPauseBackupFace.Create;
  PauseBackupFace.AddChange;

  StopBackupTrayFace := TStopBackupTrayFace.Create;
  StopBackupTrayFace.AddChange;
end;

procedure TBackupPauseHandle.Update;
begin
  UserBackup_IsStop := True;

  SetToFace;
end;

{ TBackupContinusHandle }

procedure TBackupContinusHandle.SetToFace;
var
  StartBackupTrayFace : TStartBackupTrayFace;
begin
  StartBackupTrayFace := TStartBackupTrayFace.Create;
  StartBackupTrayFace.AddChange;
end;

procedure TBackupContinusHandle.StartLocalBackup;
begin
  BackupItemAppApi.LocalOnlineBackup;
end;

procedure TBackupContinusHandle.StartNetworkBackup;
var
  OnlineBackupList : TBackupKeyItemList;
  i: Integer;
  DesPcID : string;
begin
  OnlineBackupList := BackupItemInfoReadUtil.ReadNetworkIncompletedList;
  for i := 0 to OnlineBackupList.Count - 1 do
  begin
    DesPcID := NetworkDesItemUtil.getPcID( OnlineBackupList[i].DesItem );
    if not MyNetPcInfoReadUtil.ReadIsOnline( DesPcID ) then // Pc 离线
      Continue;
    BackupItemUserApi.BackupSelectItem( OnlineBackupList[i].DesItem, OnlineBackupList[i].BackupPath );
  end;
  OnlineBackupList.Free;
end;

procedure TBackupContinusHandle.Update;
begin
  StartLocalBackup;
  StartNetworkBackup;
  SetToFace;
end;

{ TSendItemErrorAddHandle }

procedure TBackupItemErrorAddHandle.SetErrorStatus(_ErrorStatus: string);
begin
  ErrorStatus := _ErrorStatus;
end;

procedure TBackupItemErrorAddHandle.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TBackupItemErrorAddHandle.SetSpaceInfo(_FileSize,
  _CompletedSpace: Int64);
begin
  FileSize := _FileSize;
  CompletedSpace := _CompletedSpace;
end;

procedure TBackupItemErrorAddHandle.AddToFace;
var
  SendItemErrorAddFace : TBackupItemErrorAddFace;
begin
  SendItemErrorAddFace := TBackupItemErrorAddFace.Create( DesItemID );
  SendItemErrorAddFace.SetBackupPath( BackupPath );
  SendItemErrorAddFace.SetFilePath( FilePath );
  SendItemErrorAddFace.SetSpaceInfo( FileSize, CompletedSpace );
  SendItemErrorAddFace.SetErrorStatus( ErrorStatus );
  SendItemErrorAddFace.AddChange;
end;

procedure TBackupItemErrorAddHandle.Update;
begin
  AddToFace;
end;

{ TSendItemErrorClearHandle }

procedure TBackupItemErrorClearHandle.ClearToFace;
var
  SendItemErrorClearFace : TBackupItemErrorClearFace;
begin
  SendItemErrorClearFace := TBackupItemErrorClearFace.Create( DesItemID );
  SendItemErrorClearFace.SetBackupPath( BackupPath );
  SendItemErrorClearFace.AddChange;
end;

procedure TBackupItemErrorClearHandle.Update;
begin
  ClearToFace;
end;

{ SendErrorAppApi }

class procedure BackupErrorAppApi.AddItem(Params: TBackupErrorAddParams);
var
  SendItemErrorAddHandle : TBackupItemErrorAddHandle;
begin
  SendItemErrorAddHandle := TBackupItemErrorAddHandle.Create( Params.SendRootItemID );
  SendItemErrorAddHandle.SetBackupPath( Params.SourcePath );
  SendItemErrorAddHandle.SetFilePath( Params.FilePath );
  SendItemErrorAddHandle.SetSpaceInfo( Params.FileSize, Params.CompletedSize );
  SendItemErrorAddHandle.SetErrorStatus( Params.ErrorStatus );
  SendItemErrorAddHandle.Update;
  SendItemErrorAddHandle.Free;
end;

class procedure BackupErrorAppApi.ClearItem(DesItemID, SourcePath: string);
var
  SendItemErrorClearHandle : TBackupItemErrorClearHandle;
begin
  SendItemErrorClearHandle := TBackupItemErrorClearHandle.Create( DesItemID );
  SendItemErrorClearHandle.SetBackupPath( SourcePath );
  SendItemErrorClearHandle.Update;
  SendItemErrorClearHandle.Free;
end;

class procedure BackupErrorAppApi.LostConnectError(
  Params: TBackupErrorAddParams);
begin
  Params.ErrorStatus := BackupNodeStatus_LostConnectError;
  AddItem( Params );
end;

class procedure BackupErrorAppApi.ReadFileError(Params: TBackupErrorAddParams);
begin
  Params.ErrorStatus := BackupNodeStatus_ReadFileError;
  AddItem( Params );
end;

class procedure BackupErrorAppApi.SendFileError(Params: TBackupErrorAddParams);
begin
  Params.ErrorStatus := BackupNodeStatus_SendFileError;
  AddItem( Params );
end;

class procedure BackupErrorAppApi.WriteFileError(Params: TBackupErrorAddParams);
begin
  Params.ErrorStatus := BackupNodeStatus_WriteFileError;
  AddItem( Params );
end;

{ TSendItemSetIsDesBusyHandle }

procedure TBackupItemSetIsDesBusyHandle.SetIsDesBusy( _IsDesBusy : boolean );
begin
  IsDesBusy := _IsDesBusy;
end;

procedure TBackupItemSetIsDesBusyHandle.SetToInfo;
var
  SendItemSetIsDesBusyInfo : TBackupItemSetIsDesBusyInfo;
begin
  SendItemSetIsDesBusyInfo := TBackupItemSetIsDesBusyInfo.Create( DesItemID );
  SendItemSetIsDesBusyInfo.SetBackupPath( BackupPath );
  SendItemSetIsDesBusyInfo.SetIsDesBusy( IsDesBusy );
  SendItemSetIsDesBusyInfo.Update;
  SendItemSetIsDesBusyInfo.Free;
end;

procedure TBackupItemSetIsDesBusyHandle.SetToFace;
var
  SendItemSetIsDesBusyFace : TBackupItemSetIsDesBusyFace;
begin
  SendItemSetIsDesBusyFace := TBackupItemSetIsDesBusyFace.Create( DesItemID );
  SendItemSetIsDesBusyFace.SetBackupPath( BackupPath );
  SendItemSetIsDesBusyFace.SetIsDesBusy( IsDesBusy );
  SendItemSetIsDesBusyFace.AddChange;
end;

procedure TBackupItemSetIsDesBusyHandle.Update;
begin
  SetToInfo;
  SetToFace;
end;

{ TSendRootItemSetIsConnectedHandle }

procedure TDesItemSetIsConnectedHandle.SetIsConnected( _IsConnected : boolean );
begin
  IsConnected := _IsConnected;
end;

procedure TDesItemSetIsConnectedHandle.SetToFace;
var
  SendRootItemSetIsConnectedFace : TDesItemSetIsConnectedFace;
begin
  SendRootItemSetIsConnectedFace := TDesItemSetIsConnectedFace.Create( DesItemID );
  SendRootItemSetIsConnectedFace.SetIsConnected( IsConnected );
  SendRootItemSetIsConnectedFace.AddChange;
end;

procedure TDesItemSetIsConnectedHandle.Update;
begin
  SetToFace;
end;

{ TDesItemRemoveLocalHandle }

procedure TDesItemRemoveLocalHandle.RemoveFromEvent;
begin
  LocalBackupEvent.RemoveDesPath( DesItemID );
end;

procedure TDesItemRemoveLocalHandle.RemoveFromFace;
var
  FrmLocalDesRemove : TFrmLocalDesRemove;
begin
  inherited;

  FrmLocalDesRemove := TFrmLocalDesRemove.Create( DesItemID );
  FrmLocalDesRemove.AddChange;
end;

procedure TDesItemRemoveLocalHandle.Update;
begin
  inherited;

  RemoveFromEvent;
end;

{ BackupSpeedApi }

class procedure BackupSpeedApi.SetLimit(IsLimit : Boolean;
  LimitType, LimitValue: Integer);
var
  BackupSpeedLimitHandle : TBackupSpeedLimitHandle;
begin
  BackupSpeedLimitHandle := TBackupSpeedLimitHandle.Create( IsLimit );
  BackupSpeedLimitHandle.SetLimitInfo( LimitType, LimitValue );
  BackupSpeedLimitHandle.Update;
  BackupSpeedLimitHandle.Free;
end;

{ TBackupSpeedLimitHandle }

procedure TBackupSpeedLimitHandle.SetToXml;
var
  BackupSpeedLimitXml : TBackupSpeedLimitXml;
begin
  BackupSpeedLimitXml := TBackupSpeedLimitXml.Create;
  BackupSpeedLimitXml.SetIsLimit( IsLimit );
  BackupSpeedLimitXml.SetLimitXml( LimitValue, LimitType );
  BackupSpeedLimitXml.AddChange;
end;

procedure TBackupSpeedLimitHandle.Update;
begin
  inherited;
  SetToXml;
end;

{ TBackupSpeedLimitReadHandle }


constructor TBackupSpeedLimitReadHandle.Create(_IsLimit: Boolean);
begin
  IsLimit := _IsLimit;
end;

procedure TBackupSpeedLimitReadHandle.SetLimitInfo(_LimitType,
  _LimitValue: Integer);
begin
  LimitType := _LimitType;
  LimitValue := _LimitValue;
end;

procedure TBackupSpeedLimitReadHandle.SetToFace;
var
  BackupSpeedLimitFace : TBackupSpeedLimitFace;
  LimitSpeed : Int64;
  MainBackupSpeedLimitFace : TMainBackupSpeedLimitFace;
begin
  LimitSpeed := BackupSpeedInfoReadUtil.getLimitSpeed;

  BackupSpeedLimitFace := TBackupSpeedLimitFace.Create;
  BackupSpeedLimitFace.SetIsLimit( IsLimit );
  BackupSpeedLimitFace.SetLimitSpeed( LimitSpeed );
  BackupSpeedLimitFace.AddChange;

  MainBackupSpeedLimitFace := TMainBackupSpeedLimitFace.Create;
  MainBackupSpeedLimitFace.SetIsLimit( IsLimit );
  MainBackupSpeedLimitFace.AddChange;
end;

procedure TBackupSpeedLimitReadHandle.SetToInfo;
var
  BackupSpeedLimitInfo : TBackupSpeedLimitInfo;
begin
  BackupSpeedLimitInfo := TBackupSpeedLimitInfo.Create;
  BackupSpeedLimitInfo.SetIsLimit( IsLimit );
  BackupSpeedLimitInfo.SetLimitInfo( LimitValue, LimitType );
  BackupSpeedLimitInfo.Update;
  BackupSpeedLimitInfo.Free;
end;

procedure TBackupSpeedLimitReadHandle.Update;
begin
  SetToInfo;
  SetToFace;
end;

{ BackupSpeedInfoReadUtil }

class function BackupSpeedInfoReadUtil.getIsLimit: Boolean;
begin
  Result := MyBackupInfo.BackupSpeedInfo.IsLimit;
end;

class function BackupSpeedInfoReadUtil.getLimitSpeed: Int64;
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

class function BackupSpeedInfoReadUtil.getLimitType: Integer;
begin
  Result := MyBackupInfo.BackupSpeedInfo.LimitType;
end;

class function BackupSpeedInfoReadUtil.getLimitValue: Integer;
begin
  Result := MyBackupInfo.BackupSpeedInfo.LimitValue;
end;


{ TBackupItemAnalyzingHandle }

procedure TBackupItemAnalyzingHandle.Update;
begin
    // 重设分析数
  BackupItemAppApi.SetScaningCount( DesItemID, BackupPath, 0 );

    // 设置状态 正在分析
  BackupItemAppApi.SetBackupItemStatus( DesItemID, BackupPath, BackupNodeStatus_Analyizing );
end;

{ TDesItemSetLocalAvailableSpaceHandle }

procedure TDesItemSetLocalAvailableSpaceHandle.SetToFace;
var
  FrmLocalSetAvailableSpace : TFrmLocalSetAvailableSpace;
begin
  inherited;

    // 选择窗口空间信息
  FrmLocalSetAvailableSpace := TFrmLocalSetAvailableSpace.Create( DesItemID );
  FrmLocalSetAvailableSpace.SetAvailableSpace( AvailableSpace );
  FrmLocalSetAvailableSpace.AddChange;
end;

{ TDesItemSetNetworkAvailableSpaceHandle }

procedure TDesItemSetNetworkAvailableSpaceHandle.SetToFace;
var
  FrmNetworkSetAvailableSpace : TFrmNetworkSetAvailableSpace;
begin
  inherited;

    // 选择窗口空间信息
  FrmNetworkSetAvailableSpace := TFrmNetworkSetAvailableSpace.Create( DesItemID );
  FrmNetworkSetAvailableSpace.SetAvailableSpace( AvailableSpace );
  FrmNetworkSetAvailableSpace.AddChange;
end;


{ TDesItemRemoveNetworkHandle }

procedure TDesItemRemoveNetworkHandle.RemoveFromFace;
var
  FrmNetworkDesRemove : TFrmNetworkDesRemove;
  FrmBackupPcFilterRemove : TFrmBackupPcFilterRemove;
begin
  inherited;

  FrmNetworkDesRemove := TFrmNetworkDesRemove.Create( DesItemID );
  FrmNetworkDesRemove.AddChange;

  FrmBackupPcFilterRemove := TFrmBackupPcFilterRemove.Create( DesItemID );
  FrmBackupPcFilterRemove.AddChange;
end;

{ TBackupLogWriteHandle }

procedure TBackupLogWriteHandle.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

{ TBackupLogCompletedAddHandle }

procedure TBackupLogCompletedAddHandle.AddToXml;
var
  BackupLogAddCompletedXml : TBackupLogAddCompletedXml;
begin
  BackupLogAddCompletedXml := TBackupLogAddCompletedXml.Create( DesItemID );
  BackupLogAddCompletedXml.SetBackupPath( BackupPath );
  BackupLogAddCompletedXml.SetBackupDate( BackupDate );
  BackupLogAddCompletedXml.SetFilePath( FilePath );
  BackupLogAddCompletedXml.SetBackupTime( FileTime, BackupTime );
  BackupLogAddCompletedXml.AddChange;
end;

procedure TBackupLogCompletedAddHandle.SetBackupDate(_BackupDate: TDate);
begin
  BackupDate := _BackupDate;
end;

procedure TBackupLogCompletedAddHandle.SetBackupTime(_FileTime, _BackupTime: TDateTime);
begin
  FileTime := _FileTime;
  BackupTime := _BackupTime;
end;

procedure TBackupLogCompletedAddHandle.Update;
begin
  AddToXml;
end;

{ TBackupLogIncompletedAddHandle }

procedure TBackupLogIncompletedAddHandle.AddToXml;
var
  BackupLogAddIncompletedXml : TBackupLogAddIncompletedXml;
begin
  BackupLogAddIncompletedXml := TBackupLogAddIncompletedXml.Create( DesItemID );
  BackupLogAddIncompletedXml.SetBackupPath( BackupPath );
  BackupLogAddIncompletedXml.SetFilePath( FilePath );
  BackupLogAddIncompletedXml.AddChange;
end;

procedure TBackupLogIncompletedAddHandle.Update;
begin
  AddToXml;
end;

{ TBackupLogClearCompletedHandle }

procedure TBackupLogClearIncompletedHandle.ClearXml;
var
  BackupLogClearIncompletedXml : TBackupLogClearIncompletedXml;
begin
  BackupLogClearIncompletedXml := TBackupLogClearIncompletedXml.Create( DesItemID );
  BackupLogClearIncompletedXml.SetBackupPath( BackupPath );
  BackupLogClearIncompletedXml.AddChange;
end;

procedure TBackupLogClearIncompletedHandle.Update;
begin
  ClearXml;
end;

{ TBackupLogClearCompletedHandle }

procedure TBackupLogClearCompletedHandle.ClearXml;
var
  BackupLogClearCompletedXml : TBackupLogClearCompletedXml;
begin
  BackupLogClearCompletedXml := TBackupLogClearCompletedXml.Create( DesItemID );
  BackupLogClearCompletedXml.SetBackupPath( BackupPath );
  BackupLogClearCompletedXml.AddChange;
end;

procedure TBackupLogClearCompletedHandle.Update;
begin
  ClearXml;
end;

{ TBackupItemSetIsLostConnHandle }

procedure TBackupItemSetIsLostConnHandle.SetIsLostConn(_IsLostConn: boolean);
begin
  IsLostConn := _IsLostConn;
end;

procedure TBackupItemSetIsLostConnHandle.SetToInfo;
var
  BackupItemSetIsLostConnInfo : TBackupItemSetIsLostConnInfo;
begin
  BackupItemSetIsLostConnInfo := TBackupItemSetIsLostConnInfo.Create( DesItemID );
  BackupItemSetIsLostConnInfo.SetBackupPath( BackupPath );
  BackupItemSetIsLostConnInfo.SetIsLostConn( IsLostConn );
  BackupItemSetIsLostConnInfo.Update;
  BackupItemSetIsLostConnInfo.Free;
end;

procedure TBackupItemSetIsLostConnHandle.Update;
begin
  SetToInfo;
end;

{ TBackupDesSelectItemHandle }

procedure TBackupDesSelectItemHandle.Update;
var
  BackupPathList : TStringList;
  i : Integer;
begin
  BackupPathList := DesItemInfoReadUtil.ReadBackupList( DesItemID );
  for i := 0 to BackupPathList.Count - 1 do
    BackupItemUserApi.BackupSelectItem( DesItemID, BackupPathList[i] );
  BackupPathList.Free;
end;

{ TBackupCompletedLog }

procedure TBackupFileLogInfo.SetBackupTime(_FileTime,_BackupTime: TDateTime);
begin
  FileTime := _FileTime;
  BackupTime := _BackupTime;
end;

procedure TBackupFileLogInfo.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

{ TBackupDateLogInfo }

constructor TBackupDateLogInfo.Create(_BackupDate: TDate);
begin
  BackupDate := _BackupDate;
  BackupFileLogList := TBackupFileLogList.Create;
end;

destructor TBackupDateLogInfo.Destroy;
begin
  BackupFileLogList.Free;
  inherited;
end;

procedure TBackupDateLogInfo.SetFileCount(_FileCount: Integer);
begin
  FileCount := _FileCount;
end;

{ TRefreshBackupLogHandle }

constructor TRefreshBackupLogHandle.Create( _DesItemID, _BackupPath : string );
begin
  DesItemID := _DesItemID;
  BackupPath := _BackupPath;
  BackupCompletedDateLogList := TBackupDateLogList.Create;
  BackupIncompletedList := TStringList.Create;
end;

destructor TRefreshBackupLogHandle.Destroy;
begin
  BackupCompletedDateLogList.Free;
  BackupIncompletedList.Free;
  inherited;
end;

procedure TRefreshBackupLogHandle.ReadCompletedLogInfo;
var
  DateLogList, DateLog : IXMLNode;
  i: Integer;
  BackupDate : TDate;
  FileCount : Integer;
  BackupDateLogInfo : TBackupDateLogInfo;
  BackupFileLogList : TBackupFileLogList;
  FileLogList, FileLog : IXMLNode;
  j: Integer;
  FilePath : string;
  FileTime, BackupTime : TDateTime;
  BackupFileLogInfo : TBackupFileLogInfo;
begin
  MyXmlChange.EnterXml;
  try
    DateLogList := MyBackupLogXmlReadUtil.ReadCompletedDateLogList( DesItemID, BackupPath );
    for i := 0 to DateLogList.ChildNodes.Count - 1 do
    begin
      DateLog := DateLogList.ChildNodes[i];
      BackupDate := MyXmlUtil.GetChildFloatValue( DateLog, Xml_BackupDate );
      FileCount := MyXmlUtil.GetChildIntValue( DateLog, Xml_FileCount );
      FileLogList := MyXmlUtil.AddChild( DateLog, Xml_BackupCompletedFileLogList );

      BackupDateLogInfo := TBackupDateLogInfo.Create( BackupDate );
      BackupDateLogInfo.SetFileCount( FileCount );
      BackupFileLogList := BackupDateLogInfo.BackupFileLogList;
      BackupCompletedDateLogList.Insert( 0, BackupDateLogInfo );

      for j := 0 to FileLogList.ChildNodes.Count - 1 do
      begin
        FileLog := FileLogList.ChildNodes[j];
        FilePath := MyXmlUtil.GetChildValue( FileLog, Xml_FilePath );
        FileTime := MyXmlUtil.GetChildFloatValue( FileLog, Xml_FileTime );
        BackupTime := MyXmlUtil.GetChildFloatValue( FileLog, Xml_BackupTime );

        BackupFileLogInfo := TBackupFileLogInfo.Create;
        BackupFileLogInfo.SetFilePath( FilePath );
        BackupFileLogInfo.SetBackupTime( FileTime, BackupTime );
        BackupFileLogList.Insert( 0, BackupFileLogInfo );
      end;
    end;
  except
  end;
  MyXmlChange.LeaveXml;
end;

procedure TRefreshBackupLogHandle.ReadIncompletedLogInfo;
var
  LogList, LogNode : IXMLNode;
  i: Integer;
  FilePath : string;
begin
  MyXmlChange.EnterXml;
  try
    LogList := MyBackupLogXmlReadUtil.ReadIncompletedLogList( DesItemID, BackupPath );
    for i := 0 to LogList.ChildNodes.Count - 1 do
    begin
      LogNode := LogList.ChildNodes[i];
      FilePath := MyXmlUtil.GetChildValue( LogNode, Xml_FilePath );
      BackupIncompletedList.Insert( 0, FilePath );
    end;
  except
  end;
  MyXmlChange.LeaveXml;
end;

procedure TRefreshBackupLogHandle.ShowLogInfo;
var
  i, j: Integer;
  DataLog : TBackupDateLogInfo;
  FileLogList : TBackupFileLogList;
  FileLog : TBackupFileLogInfo;
begin
  frmBackupLog.ClearItems;

  for i := 0 to BackupCompletedDateLogList.Count - 1 do
  begin
    DataLog := BackupCompletedDateLogList[i];
    FileLogList := DataLog.BackupFileLogList;
    frmBackupLog.AddCompletedDate( DataLog.BackupDate, DataLog.FileCount );
    for j := 0 to FileLogList.Count - 1 do
    begin
      FileLog := FileLogList[j];
      frmBackupLog.AddCompleted( FileLog.FilePath, FileLog.FileTime, FileLog.BackupTime );
    end;
    if FileLogList.Count < DataLog.FileCount then
      frmBackupLog.AddMoreCompleted;
  end;

  for I := 0 to BackupIncompletedList.Count - 1 do
    frmBackupLog.AddIncompleted( BackupIncompletedList[i] );
end;

procedure TRefreshBackupLogHandle.Update;
begin
  try
    ReadCompletedLogInfo;
    ReadIncompletedLogInfo;
    ShowLogInfo;
  except
  end;
end;

{ BackupLogReadApi }

class procedure BackupLogReadApi.LocalPreview(Params: TBackupLogReadParams);
var
  LocalPreviewLogInfo : TLocalPreviewLogInfo;
begin
  LocalPreviewLogInfo := TLocalPreviewLogInfo.Create;
  LocalPreviewLogInfo.SetItemInfo( Params.DesItemID, Params.SourcePath );
  LocalPreviewLogInfo.SetFileInfo( Params.FilePath, Params.FileTime );
  MyBackupLogHandler.AddLogPathInfo( LocalPreviewLogInfo );
end;

class procedure BackupLogReadApi.LocalRestore(Params: TBackupLogReadParams);
var
  LocalRestoreLogInfo : TLocalRestoreLogInfo;
begin
  LocalRestoreLogInfo := TLocalRestoreLogInfo.Create;
  LocalRestoreLogInfo.SetItemInfo( Params.DesItemID, Params.SourcePath );
  LocalRestoreLogInfo.SetFileInfo( Params.FilePath, Params.FileTime );
  MyBackupLogHandler.AddLogPathInfo( LocalRestoreLogInfo );
end;

class procedure BackupLogReadApi.NetworkPreview(Params: TBackupLogReadParams);
var
  NetworkPreviewLogInfo : TNetworkPreviewLogInfo;
begin
  NetworkPreviewLogInfo := TNetworkPreviewLogInfo.Create;
  NetworkPreviewLogInfo.SetItemInfo( Params.DesItemID, Params.SourcePath );
  NetworkPreviewLogInfo.SetFileInfo( Params.FilePath, Params.FileTime );
  MyBackupLogHandler.AddLogPathInfo( NetworkPreviewLogInfo );
end;

class procedure BackupLogReadApi.NetworkRestore(Params: TBackupLogReadParams);
var
  NetworkRestoreLogInfo : TNetworkRestoreLogInfo;
begin
  NetworkRestoreLogInfo := TNetworkRestoreLogInfo.Create;
  NetworkRestoreLogInfo.SetItemInfo( Params.DesItemID, Params.SourcePath );
  NetworkRestoreLogInfo.SetFileInfo( Params.FilePath, Params.FileTime );
  MyBackupLogHandler.AddLogPathInfo( NetworkRestoreLogInfo );
end;

{ BackupLogAppApi }

class procedure BackupLogAppApi.CloudPcBusy;
var
  LogFileBusyFace : TLogFileBusyFace;
begin
  LogFileBusyFace := TLogFileBusyFace.Create;
  LogFileBusyFace.AddChange;
end;

class procedure BackupLogAppApi.CloudPcNotConn;
var
  LogFileNotConnFace : TLogFileNotConnFace;
begin
  LogFileNotConnFace := TLogFileNotConnFace.Create;
  LogFileNotConnFace.AddChange;
end;

class procedure BackupLogAppApi.FileNotExist;
var
  LogFileNotExistFace : TLogFileNotExistFace;
begin
  LogFileNotExistFace := TLogFileNotExistFace.Create;
  LogFileNotExistFace.AddChange;
end;

class procedure BackupLogAppApi.StartLoading;
var
  LogFileStartFace : TLogFileStartFace;
begin
  LogFileStartFace := TLogFileStartFace.Create;
  LogFileStartFace.AddChange;
end;

class procedure BackupLogAppApi.StartRestore;
var
  LogFileStartRestore : TLogFileStartRestore;
begin
  LogFileStartRestore := TLogFileStartRestore.Create;
  LogFileStartRestore.AddChange;
end;

class procedure BackupLogAppApi.StopLoading;
var
  LogFileStopFace : TLogFileStopFace;
begin
  LogFileStopFace := TLogFileStopFace.Create;
  LogFileStopFace.AddChange;
end;

{ BackupHintAppApi }

class procedure BackupHintAppApi.ShowBackupCompleted(
  Params: TCompletedHintParams);
var
  FrmBackupCompletedHintFace : TFrmBackupCompletedHintFace;
begin
  FrmBackupCompletedHintFace := TFrmBackupCompletedHintFace.Create( Params.DesItemID, Params.BackupPath );
  FrmBackupCompletedHintFace.SetBackupInfo( Params.BackupTo, Params.TotalBackup );
  FrmBackupCompletedHintFace.SetBackupFile( Params.BackupFileList );
  FrmBackupCompletedHintFace.AddChange;
end;

class procedure BackupHintAppApi.ShowBackuping(BackupPath, BackupTo: string);
var
  FrmBackupingHintFace : TFrmBackupingHintFace;
begin
  FrmBackupingHintFace := TFrmBackupingHintFace.Create( BackupPath, BackupTo );
  FrmBackupingHintFace.AddChange;
end;

end.
