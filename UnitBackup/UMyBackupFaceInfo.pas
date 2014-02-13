unit UMyBackupFaceInfo;

interface

uses UChangeInfo, VirtualTrees, UMyUtil, DateUtils, Vcl.ComCtrls, SysUtils, classes;

type

{$Region ' 数据结构 ' }

  TVstBackupData = record
  public
    ItemID : WideString;
    IsFile, IsCompleted : Boolean;
  public   // 备份状态
    IsWrite, IsLackSpace, IsOnline, IsConnected : Boolean;  // 目标状态
    IsExist : Boolean; // 目标和源 状态
    IsDesBusy : Boolean; // 目标是否繁忙
    AvailableSpace : Int64; // 可用空间
  public  // 自动同步
    IsAutoSync : Boolean; // 是否自动同步
    SyncTimeType, SyncTimeValue : Integer; // 同步间隔
    LastSyncTime, NextSyncTime : TDateTime;  // 上一次同步时间
    IsBackuping, IsBackupNow : Boolean; // 是否正在同步
    NextSyncTimeShow : WideString; // 下一次同步时间显示
  public  // 保存删除信息
    IsSaveDeleted : Boolean;
    SaveDeletedCount : Integer;
  public  // 加密
    IsEncrypted : Boolean;
    PasswordHint : WideString;
  public  // 过滤
    IncludeFilterStr : WideString;
    ExcludeFilterStr : WideString;
  public  // 空间信息
    FileCount : Integer;
    ItemSize, CompletedSize : Int64; // 空间信息
    Percentage : Integer;
    Speed : Int64; // 传输速度
    AnalyizeCount : Integer; // 分析文件数
  public
    ShowName, NodeType, NodeStatus : WideString;
    MainIcon : Integer;
  end;
  PVstBackupData = ^TVstBackupData;

{$EndRegion}

{$Region ' 备份信息 数据修改 ' }

  {$Region ' 目标路径 增删 ' }

  TDesItemChangeFace = class( TFaceChangeInfo )
  public
    VstBackup : TVirtualStringTree;
  protected
    procedure Update;override;
  end;

    // 刷新同步时间
  TDesItemRefreshSyncFace = class( TDesItemChangeFace )
  protected
    procedure Update;override;
  end;

    // 修改 目标路径
  TDesItemWriteFace = class( TDesItemChangeFace )
  public
    DesItemID : string;
  protected
    DesItemNode : PVirtualNode;
    DesItemData : PVstBackupData;
  public
    constructor Create( _DesPath : string );
  protected
    function FindDesItemNode : Boolean;
    procedure RefreshDesNode;
  end;

    // 添加 父类
  TDesItemAddFace = class( TDesItemWriteFace )
  protected
    AvailableSpace : Int64;
  public
    procedure SetAvailableSpace( _AvailableSpace : Int64 );
  protected
    procedure Update;override;
  protected
    procedure CreateDesItem;virtual;abstract;
    procedure SetDesItemInfo;virtual;abstract;
    procedure ResetItemInfo;virtual;abstract;
  protected
    function getLastLocalNode : PVirtualNode;
  end;

    // 添加 本地目标
  TDesItemAddLocalFace = class( TDesItemAddFace )
  protected
    procedure CreateDesItem;override;
    procedure SetDesItemInfo;override;
    procedure ResetItemInfo;override;
  end;

      // 添加 网络目标
  TDesItemAddNetworkFace = class( TDesItemAddFace )
  private
    PcName : string;
    IsOnline : Boolean;
  public
    procedure SetPcName( _PcName : string );
    procedure SetIsOnline( _IsOnline : Boolean );
  protected
    procedure CreateDesItem;override;
    procedure SetDesItemInfo;override;
    procedure ResetItemInfo;override;
  private
    function getLastNetworkNode : PVirtualNode;
    function getSameNameNode : PVirtualNode;
  end;

    // 修改
  TDesItemSetAvailableSpaceFace = class( TDesItemWriteFace )
  public
    AvailableSpace : int64;
  public
    procedure SetAvailableSpace( _AvailableSpace : int64 );
  protected
    procedure Update;override;
  end;


    // 删除
  TDesItemRemoveFace = class( TDesItemWriteFace )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 目标路径 状态 ' }

    // 修改 路径是否存在
  TDesItemSetIsExistFace = class( TDesItemWriteFace )
  public
    IsExist : boolean;
  public
    procedure SetIsExist( _IsExist : boolean );
  protected
    procedure Update;override;
  end;

    // 修改 路径是否可写
  TDesItemSetIsWriteFace = class( TDesItemWriteFace )
  public
    IsWrite : boolean;
  public
    procedure SetIsWrite( _IsWrite : boolean );
  protected
    procedure Update;override;
  end;

    // 修改 目标路径是否缺少备份空间
  TDesItemSetIsLackSpaceFace = class( TDesItemWriteFace )
  public
    IsLackSpace : boolean;
  public
    procedure SetIsLackSpace( _IsLackSpace : boolean );
  protected
    procedure Update;override;
  end;

      // 修改 是否可连接
  TDesItemSetIsConnectedFace = class( TDesItemWriteFace )
  public
    IsConnected : boolean;
  public
    procedure SetIsConnected( _IsConnected : boolean );
  protected
    procedure Update;override;
  end;


    // 上线/离线
  TDesItemSetPcIsOnlineFace = class( TDesItemChangeFace )
  public
    DesPcID : string;
    IsOnline : Boolean;
  public
    constructor Create( _DesPcID : string );
    procedure SetIsOnline( _IsOnline : Boolean );
  protected
    procedure Update;override;
  private
    function getOnlineMoveNode : PVirtualNode;
    function getLastNetworkOnlineNode : PVirtualNode;
    function getLastLocalNode : PVirtualNode;
  end;

  {$EndRegion}

  {$Region ' 目标路径 辅助类 ' }

  DesItemFaceUtil = class
  public
    class function ReadPcIcon( IsOnline : Boolean ): Integer;
  end;

  {$EndRegion}


  {$Region ' 源路径 增删 ' }

    // 修改 源路径
  TBackupItemWriteFace = class( TDesItemWriteFace )
  protected
    BackupPath : string;
  protected
    BackupItemNode : PVirtualNode;
    BackupItemData : PVstBackupData;
  public
    procedure SetBackupPath( _BackupPath : string );
  protected
    function FindBackupItemNode : Boolean;
    procedure RefreshBackupNode;
  protected
    procedure RefreshNextSyncTime;
    procedure RefreshPercentage;
  end;

    // 添加 源路径
  TBackupItemAddFace = class( TBackupItemWriteFace )
  public
    IsFile, IsCompleted : Boolean;
  public  // 自动同步
    IsAutoSync : Boolean; // 是否自动同步
    SyncTimeType, SyncTimeValue : Integer; // 同步间隔
    LasSyncTime : TDateTime;  // 上一次同步时间
    IsBackupNow : Boolean; // 是否包含在全部备份
  public  // 保存删除
    IsSaveDeleted : Boolean;
    SaveDeletedCount : Integer;
  public  // 加密
    IsEncrypted : Boolean;
    PasswordHint : string;
  public  // 空间信息
    FileCount : Integer;
    ItemSize, CompletedSize : Int64; // 空间信息
  public
    procedure SetIsFile( _IsFile : Boolean );
    procedure SetIsCompleted( _IsCompleted : Boolean );
    procedure SetIsEncrypted( _IsEncrypted : Boolean );
    procedure SetAutoSyncInfo( _IsAutoSync : Boolean; _LasSyncTime : TDateTime );
    procedure SetSyncTimeInfo( _SyncTimeType, _SyncTimeValue : Integer );
    procedure SetIsBackupNow( _IsBackupNow : Boolean );
    procedure SetSaveDeletedInfo( _IsSaveDeleted : Boolean; _SaveDeletedCount : Integer );
    procedure SetEncryptInfo( _IsEncrypted : Boolean; _PasswordHint : string );
    procedure SetSpaceInfo( _FileCount : Integer; _ItemSize, _CompletedSize : Int64 );
  protected
    procedure Update;override;
  end;

    // 删除 源路径
  TBackupItemRemoveFace = class( TBackupItemWriteFace )
  protected
    procedure Update;override;
  protected
    function getIsExistItem : Boolean;
  end;

  {$EndRegion}

  {$Region ' 源路径 状态 ' }

    // 修改 是否存在
  TBackupItemSetIsExistFace = class( TBackupItemWriteFace )
  public
    IsExist : boolean;
  public
    procedure SetIsExist( _IsExist : boolean );
  protected
    procedure Update;override;
  end;

    // 修改
  TBackupItemSetStatusFace = class( TBackupItemWriteFace )
  public
    BackupItemStatus : string;
  public
    procedure SetBackupItemStatus( _BackupItemStatus : string );
  protected
    procedure Update;override;
  end;

      // 修改
  TBackupItemSetSpeedFace = class( TBackupItemWriteFace )
  public
    Speed : int64;
  public
    procedure SetSpeed( _Speed : int64 );
  protected
    procedure Update;override;
  end;

      // 修改
  TBackupItemSetAnalyizeCountFace = class( TBackupItemWriteFace )
  public
    AnalyizeCount : integer;
  public
    procedure SetAnalyizeCount( _AnalyizeCount : integer );
  protected
    procedure Update;override;
  end;

      // 修改
  TBackupItemSetIsCompletedFace = class( TBackupItemWriteFace )
  public
    IsCompleted : boolean;
  public
    procedure SetIsCompleted( _IsCompleted : boolean );
  protected
    procedure Update;override;
  end;

     // 修改
  TBackupItemSetIsDesBusyFace = class( TBackupItemWriteFace )
  public
    IsDesBusy : boolean;
  public
    procedure SetIsDesBusy( _IsDesBusy : boolean );
  protected
    procedure Update;override;
  end;


  {$EndRegion}

  {$Region ' 源路径 自动同步 ' }

    // 是否 Backup Now 备份
  TBackupItemSetIsBackupNowFace = class( TBackupItemWriteFace )
  public
    IsBackupNow : Boolean;
  public
    procedure SetIsBackupNow( _IsBackupNow : Boolean );
  protected
    procedure Update;override;
  end;


    // 设置 自动同步
  TBackupItemSetAutoSyncFace = class( TBackupItemWriteFace )
  public
    IsAutoSync : Boolean; // 是否自动同步
    SyncTimeType, SyncTimeValue : Integer; // 同步间隔
  public
    procedure SetIsAutoSync( _IsAutoSync : Boolean );
    procedure SetSyncTime( _SyncTimeType, _SyncTimeValue : Integer );
  protected
    procedure Update;override;
  end;

    // 修改
  TBackupItemSetLastSyncTimeFace = class( TBackupItemWriteFace )
  public
    LastSyncTime : TDateTime;
  public
    procedure SetLastSyncTime( _LastSyncTime : TDateTime );
  protected
    procedure Update;override;
  end;

    // 修改
  TBackupItemSetIsBackupingFace = class( TBackupItemWriteFace )
  public
    IsBackuping : boolean;
  public
    procedure SetIsBackuping( _IsBackuping : boolean );
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 源路径 保存删除 ' }

  TBackupItemSetRecycleFace = class( TBackupItemWriteFace )
  public
    IsKeepDeleted : Boolean;
    KeepEditionCount : Integer;
  public
    procedure SetDeleteInfo( _IsKeepDeleted : Boolean; _KeepEditionCount : Integer );
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 源路径 加密信息 ' }

      // 修改
  TBackupItemSetEncryptInfoFace = class( TBackupItemWriteFace )
  public
    IsEncrypt : boolean;
    PasswordHint : string;
  public
    procedure SetEncryptInfo( _IsEncrypt : boolean; _PasswordHint : string );
  protected
    procedure Update;override;
  end;


  {$EndRegion}

  {$Region ' 过滤信息 ' }

       // 修改
  TBackupItemSetIncludeFilterFace = class( TBackupItemWriteFace )
  public
    IncludeFilterStr : string;
  public
    procedure SetIncludeFilterStr( _IncludeFilterStr : string );
  protected
    procedure Update;override;
  end;

       // 修改
  TBackupItemSetExcludeFilterFace = class( TBackupItemWriteFace )
  public
    ExcludeFilterStr : string;
  public
    procedure SetExcludeFilterStr( _ExcludeFilterStr : string );
  protected
    procedure Update;override;
  end;


  {$EndRegion}

  {$Region ' 源路径 空间信息 ' }

   // 设置 空间信息
  TBackupItemSetSpaceInfoFace = class( TBackupItemWriteFace )
  public
    FileCount : integer;
    ItemSize, CompletedSize : int64;
  public
    procedure SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSize : int64 );
  protected
    procedure Update;override;
  end;

    // 添加 已完成空间信息
  TBackupItemSetAddCompletedSpaceFace = class( TBackupItemWriteFace )
  public
    AddCompletedSpace : int64;
  public
    procedure SetAddCompletedSpace( _AddCompletedSpace : int64 );
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 发送路径 错误信息 ' }

    // 添加 错误
  TBackupItemErrorAddFace = class( TBackupItemWriteFace )
  public
    FilePath : string;
    FileSize, CompletedSpace : Int64;
    ErrorStatus : string;
  public
    procedure SetFilePath( _FilePath : string );
    procedure SetSpaceInfo( _FileSize, _CompletedSpace : Int64 );
    procedure SetErrorStatus( _ErrorStatus : string );
  protected
    procedure Update;override;
  end;

    // 清空 错误
  TBackupItemErrorClearFace = class( TBackupItemWriteFace )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 选择窗口 数据修改 ' }

  {$Region ' 本地目标路径 ' }

  TLocalDesData = record
  public
    DesPath : WideString;
    MainIcon : Integer;
    AvailaleSpace : Int64;
  end;
  PLocalDesData = ^TLocalDesData;

    // 父类
  TFrmLocalDesChange = class( TFaceChangeInfo )
  public
    vstLocalDes : TVirtualStringTree;
  protected
    procedure Update;override;
  end;

    // 修改
  TFrmLocalDesWrite = class( TFrmLocalDesChange )
  public
    DesPath : string;
  protected
    LocalDesNode : PVirtualNode;
    LocalDesData : PLocalDesData;
  public
    constructor Create( _DesPath : string );
  protected
    function FindDesItemNode : Boolean;
  end;

    // 读取
  TFrmLocalDesAdd = class( TFrmLocalDesWrite )
  private
    AvailableSpace : Int64;
    IsSelect : Boolean;
  public
    procedure SetAvailableSpace( _AvailableSpace : Int64 );
    procedure SetIsSelect( _IsSelect : Boolean );
  protected
    procedure Update;override;
  end;

      // 设置可用空间
  TFrmLocalSetAvailableSpace = class( TFrmLocalDesWrite )
  public
    AvaialbleSpace : Int64;
  public
    procedure SetAvailableSpace( _AvailableSpace : Int64 );
  protected
    procedure Update;override;
  end;

    // 删除
  TFrmLocalDesRemove = class( TFrmLocalDesWrite )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 网络目标路径 ' }

  TNetworkDesData = record
  public
    DesItemID, DesItemName : WideString;
    IsOnline : Boolean;
    MainIcon : Integer;
    AvailaleSpace : Int64;
  end;
  PNetworkDesData = ^TNetworkDesData;

    // 父类
  TFrmNetworkDesChange = class( TFaceChangeInfo )
  public
    vstNetworkDes : TVirtualStringTree;
  protected
    procedure Update;override;
  end;

    // 设置上线状态
  TFrmNetworkDesIsOnline = class( TFrmNetworkDesChange )
  public
    DesPcID : string;
    IsOnline : Boolean;
  public
    constructor Create( _DesPcID : string );
    procedure SetIsOnline( _IsOnline : Boolean );
  protected
    procedure Update;override;
  private
    function getLastOnlineNode : PVirtualNode;
  end;

    // 修改
  TFrmNetworkDesWrite = class( TFrmNetworkDesChange )
  public
    DesItemID : string;
  protected
    NetworkDesNode : PVirtualNode;
    NetworkDesData : PNetworkDesData;
  public
    constructor Create( _DesItemID : string );
  protected
    function FindNetworkDesItemNode : Boolean;
  end;

    // 添加
  TFrmNetworkDesAdd = class( TFrmNetworkDesWrite )
  public
    PcName : string;
    IsOnline : Boolean;
    AvailableSpace : Int64;
  public
    procedure SetPcName( _PcName : string );
    procedure SetIsOnline( _IsOnline : Boolean );
    procedure SetAvailableSpace( _AvailableSpace : Int64 );
  protected
    procedure Update;override;
  private
    procedure CreateDesNode;
    function getSameNameLastNode : PVirtualNode;
    function getLastOnlineNode : PVirtualNode;
  end;

    // 设置可用空间
  TFrmNetworkSetAvailableSpace = class( TFrmNetworkDesWrite )
  public
    AvaialbleSpace : Int64;
  public
    procedure SetAvailableSpace( _AvailableSpace : Int64 );
  protected
    procedure Update;override;
  end;


    // 删除
  TFrmNetworkDesRemove = class( TFrmNetworkDesWrite )
  protected
    procedure Update;override;
  end;

    // 读取图标
  FrmNetworkDesUtil = class
  public
    class function ReadIcon( IsOnline : Boolean ): Integer;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 日志窗口 ' }

    // 开始加载
  TLogFileStartFace = class( TFaceChangeInfo )
  protected
    procedure Update;override;
  end;

    // 结束加载
  TLogFileStopFace = class( TFaceChangeInfo )
  protected
    procedure Update;override;
  end;

    // 开始恢复
  TLogFileStartRestore = class( TFaceChangeInfo )
  protected
    procedure Update;override;
  end;

      // 繁忙
  TLogFileBusyFace = class( TFaceChangeInfo )
  public
    procedure Update;override;
  end;

    // 无法连接
  TLogFileNotConnFace = class( TFaceChangeInfo )
  protected
    procedure Update;override;
  end;

    // 文件不存在
  TLogFileNotExistFace = class( TFaceChangeInfo )
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 备份Pc过滤窗口 ' }

  TBackupPcFilterData = record
  public
    DesItemID, ComputerName, Directory : WideString;
    IsOnline : Boolean;
    MainIcon : Integer;
  end;
  PBackupPcFilterData = ^TBackupPcFilterData;

    // 父类
  TFrmBackupPcFilterChange = class( TFaceChangeInfo )
  public
    vstBackupPcFilter : TVirtualStringTree;
  protected
    procedure Update;override;
  end;

    // 设置上线状态
  TFrmBackupPcFilterIsOnline = class( TFrmBackupPcFilterChange )
  public
    DesPcID : string;
    IsOnline : Boolean;
  public
    constructor Create( _DesPcID : string );
    procedure SetIsOnline( _IsOnline : Boolean );
  protected
    procedure Update;override;
  private
    function getLastOnlineNode : PVirtualNode;
  end;

    // 修改
  TFrmBackupPcFilterWrite = class( TFrmBackupPcFilterChange )
  public
    DesItemID : string;
  protected
    BackupPcFilterNode : PVirtualNode;
    BackupPcFilterData : PBackupPcFilterData;
  public
    constructor Create( _DesItemID : string );
  protected
    function FindBackupPcFilterItemNode : Boolean;
  end;

    // 添加
  TFrmBackupPcFilterAdd = class( TFrmBackupPcFilterWrite )
  public
    PcName, Directory : string;
    IsOnline : Boolean;
  public
    procedure SetPcName( _PcName : string );
    procedure SetDirectory( _Directory : string );
    procedure SetIsOnline( _IsOnline : Boolean );
  protected
    procedure Update;override;
  private
    procedure CreateDesNode;
    function getSameNameLastNode : PVirtualNode;
    function getLastOnlineNode : PVirtualNode;
  end;

    // 删除
  TFrmBackupPcFilterRemove = class( TFrmBackupPcFilterWrite )
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 速度信息 ' }

      // 速度限制
  TBackupSpeedLimitFace = class( TFaceChangeInfo )
  public
    IsLimit : Boolean;
    LimitSpeed : Int64;
  public
    procedure SetIsLimit( _IsLimit : Boolean );
    procedure SetLimitSpeed( _LimitSpeed : Int64 );
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' Hint 窗口信息 ' }

    // 正在备份的 Hint
  TFrmBackupingHintFace = class( TFaceChangeInfo )
  public
    BackupPath : string;
    BackupTo : string;
  public
    constructor Create( _BackupPath, _BackupTo : string );
  protected
    procedure Update;override;
  end;

    // 备份完成的 Hint
  TFrmBackupCompletedHintFace = class( TFaceChangeInfo )
  public
    DesItemID, BackupPath : string;
    BackupTo : string;
  public
    TotalBackup : Integer;
    BackupFileList : TStringList;
  public
    constructor Create( _DesItemID, _BackupPath : string );
    procedure SetBackupInfo( _BackupTo : string; _TotalBackup : Integer );
    procedure SetBackupFile( AddFileList : TStringList );
    destructor Destroy; override;
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 主窗口信息 ' }

  TStartBackupFace = class( TFaceChangeInfo )
  protected
    procedure Update;override;
  end;

  TPauseBackupFace = class( TFaceChangeInfo )
  protected
    procedure Update;override;
  end;

  TStopBackupFace = class( TFaceChangeInfo )
  protected
    procedure Update;override;
  end;

    // 主窗口显示速度限制
  TMainBackupSpeedLimitFace = class( TFaceChangeInfo )
  public
    IsLimit : Boolean;
  public
    procedure SetIsLimit( _IsLimit : Boolean );
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 数据读取 ' }

  TBackupNodeGetHintStr = class
  public
    Node : PVirtualNode;
    NodeData : PVstBackupData;
  public
    constructor Create( _Node : PVirtualNode );
    function get : string;
  private
    function getBaseStr : string;
    function getAutoBackupStr : string;
    function getSaveDeletedStr : string;
    function getEncryptStr : string;
    function getFilterStr : string;
  end;

  VstBackupUtil = class
  public             // 状态文本
    class function getDesStatus( Node : PVirtualNode ): string;
    class function getBackupStatus( Node : PVirtualNode ): string;
  public             // 状态图标
    class function getDesStatusIcon( Node : PVirtualNode ): Integer;
    class function getBackupStatusIcon( Node : PVirtualNode ): Integer;
  public             // 下次备份显示
    class function getNextBackupText( Node : PVirtualNode ): string;
  public             // 刷新 下次同步
    class procedure RefreshSyncNode( Node : PVirtualNode );
  public             // 获取 Hint 信息
    class function getBackupHintStr( Node : PVirtualNode ): string;
  public             // 节点类型
    class function getIsBackupNode( NodeType : string ): Boolean;
    class function getIsDesNode( NodeType : string ): Boolean;
  end;

{$EndRegion}

const
  ItemName_BackupRoot = ' or Shared Folders';
  BackupIcon_Folder = 5;
  BackupIcon_PcOffline = 0;
  BackupIcon_PcOnline = 1;

  BackupNodeStatus_WaitingBackup = 'Waiting';
  BackupNodeStatus_Backuping = 'Backuping';
  BackupNodeStatus_Analyizing = 'Analyzing';
  BackupNodeStatus_Empty = '';

  BackupStatusShow_NotExist = 'Not Exist';
  BackupStatusShow_NotWrite = 'Cannot Write';
  BackupStatusShow_NotSpace = 'Space Insufficient';
  BackupStatusShow_Disable = 'Disable';
  BackupStatusShow_PcOffline = 'Offline';
  BackupStatusShow_Analyizing = 'Analyzing %s Files';

  BackupStatusShow_NotConnect = 'Cannot Connect';
  BackupStatusShow_Busy = 'Destination Busy';
  BackupStatusShow_Incompleted = 'Incompleted';
  BackupStatusShow_Completed = 'Completed';

  BackupNodeStatus_ReadFileError = 'Read File Error';
  BackupNodeStatus_WriteFileError = 'Write File Error';
  BackupNodeStatus_SendFileError = 'Send File Error';
  BackupNodeStatus_LostConnectError = 'Lost Connect Error';

const
  FrmDesIcon_PcOffline = 0;
  FrmDesIcon_PcOnline = 1;

const
  BackupNodeType_LocalDes = 'LocalDes';
  BackupNodeType_LocalBackup = 'Backup';

  BackupNodeType_NetworkDes = 'NetworkDes';
  BackupNodeType_NetworkBackup = 'NetworkBackup';

  BackupNodeType_ErrorItem = 'ErrorItem';

const
  LogStatus_Busy = 'Backup Destination PC Busy';
  LogStatus_NotConn = 'Cannot Connect to Backup Destination PC';
  LogStatus_NotExist = 'Backup file not exist';
  LogStatus_NotPreview = 'Cannot preview this file';
  LogStatus_NotRestore = 'Cannot restore this file';

var
  BackupItem_IsExist : Boolean = False;

implementation

uses UMainForm, UIconUtil, UFrmSelectBackupItem, UFormBackupLog, UMyBackupApiInfo, UFormBackupPcFilter,
     UFormBackupHint;

{ TVstBackupDesItemWrite }

constructor TDesItemWriteFace.Create(_DesPath: string);
begin
  DesItemID := _DesPath;
end;

function TDesItemWriteFace.FindDesItemNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstBackupData;
begin
  Result := False;
  SelectNode := vstBackup.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstBackup.GetNodeData( SelectNode );
    if SelectData.ItemID = DesItemID then
    begin
      Result := True;
      DesItemNode := SelectNode;
      DesItemData := SelectData;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TDesItemWriteFace.RefreshDesNode;
begin
  VstBackup.RepaintNode( DesItemNode );
end;

{ TVstBackupDesItemRemove }

procedure TDesItemRemoveFace.Update;
begin
  inherited;

    // 不存在
  if not FindDesItemNode then
    Exit;

  VstBackup.DeleteNode( DesItemNode );
end;

{ TVstBackupItemWrite }

function TBackupItemWriteFace.FindBackupItemNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstBackupData;
begin
  Result := False;
  DesItemNode := nil;
  if not FindDesItemNode then
    Exit;
  SelectNode := DesItemNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstBackup.GetNodeData( SelectNode );
    if SelectData.ItemID = BackupPath then
    begin
      Result := True;
      BackupItemNode := SelectNode;
      BackupItemData := SelectData;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TBackupItemWriteFace.RefreshBackupNode;
begin
  VstBackup.RepaintNode( BackupItemNode );
end;

procedure TBackupItemWriteFace.RefreshNextSyncTime;
begin
  VstBackupUtil.RefreshSyncNode( BackupItemNode );
end;

procedure TBackupItemWriteFace.RefreshPercentage;
begin
  BackupItemData.Percentage := MyPercentage.getPercent( BackupItemData.CompletedSize, BackupItemData.ItemSize );
end;

procedure TBackupItemWriteFace.SetBackupPath(_BackupPath: string);
begin
  BackupPath := _BackupPath;
end;

{ TVstBackupItemAdd }

procedure TBackupItemAddFace.SetAutoSyncInfo(_IsAutoSync: Boolean;
  _LasSyncTime: TDateTime);
begin
  IsAutoSync := _IsAutoSync;
  LasSyncTime := _LasSyncTime;
end;

procedure TBackupItemAddFace.SetEncryptInfo(_IsEncrypted: Boolean;
  _PasswordHint: string);
begin
  IsEncrypted := _IsEncrypted;
  PasswordHint := _PasswordHint;
end;

procedure TBackupItemAddFace.SetIsBackupNow(_IsBackupNow: Boolean);
begin
  IsBackupNow := _IsBackupNow;
end;

procedure TBackupItemAddFace.SetIsCompleted(_IsCompleted: Boolean);
begin
  IsCompleted := _IsCompleted;
end;

procedure TBackupItemAddFace.SetIsEncrypted(_IsEncrypted: Boolean);
begin
  IsEncrypted := _IsEncrypted;
end;

procedure TBackupItemAddFace.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TBackupItemAddFace.SetSaveDeletedInfo(_IsSaveDeleted: Boolean;
  _SaveDeletedCount: Integer);
begin
  IsSaveDeleted := _IsSaveDeleted;
  SaveDeletedCount := _SaveDeletedCount;
end;

procedure TBackupItemAddFace.SetSpaceInfo(_FileCount: Integer; _ItemSize,
  _CompletedSize: Int64);
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TBackupItemAddFace.SetSyncTimeInfo(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TBackupItemAddFace.Update;
begin
  inherited;

    // 不存在则创建
  if not FindBackupItemNode then
  begin
    if DesItemNode = nil then // 找不到父节点
      Exit;
    BackupItemNode := VstBackup.AddChild( DesItemNode );
    BackupItemData := VstBackup.GetNodeData( BackupItemNode );
    BackupItemData.ItemID := BackupPath;
    if DesItemData.NodeType = BackupNodeType_LocalDes then
      BackupItemData.NodeType := BackupNodeType_LocalBackup
    else
      BackupItemData.NodeType := BackupNodeType_NetworkBackup;
  end;

    // 修改节点
  BackupItemData.ShowName := BackupPath;
  BackupItemData.IsFile := IsFile;
  BackupItemData.IsCompleted := IsCompleted;
  BackupItemData.IsExist := True;
  BackupItemData.IsDesBusy := False;
  BackupItemData.IsBackuping := False;
  BackupItemData.IsAutoSync := IsAutoSync;
  BackupItemData.SyncTimeType := SyncTimeType;
  BackupItemData.SyncTimeValue := SyncTimeValue;
  BackupItemData.LastSyncTime := LasSyncTime;
  BackupItemData.IsBackupNow := IsBackupNow;
  BackupItemData.IsSaveDeleted := IsSaveDeleted;
  BackupItemData.SaveDeletedCount := SaveDeletedCount;
  BackupItemData.IsEncrypted := IsEncrypted;
  BackupItemData.PasswordHint := PasswordHint;
  BackupItemData.IncludeFilterStr := '';
  BackupItemData.ExcludeFilterStr := '';
  BackupItemData.FileCount := FileCount;
  BackupItemData.ItemSize := ItemSize;
  BackupItemData.CompletedSize := CompletedSize;
  BackupItemData.NodeStatus := '';
  BackupItemData.MainIcon := MyIcon.getIconByFilePath( BackupPath );

    // 展开父目录
  VstBackup.Expanded[ DesItemNode ] := True;

    // 刷新信息
  RefreshNextSyncTime;
  RefreshPercentage;
  RefreshBackupNode;

    // 出现了 Backup Item，影响 Backup All 按钮
  if not BackupItem_IsExist then
  begin
    frmMainForm.tbtnBackupAll.Visible := True;
    frmMainForm.tbtnBackupExpandAll.Enabled := True;
    frmMainForm.tbtnBackupCollapse.Enabled := True;
    BackupItem_IsExist := True;
  end;
end;

{ TVstBackupItemRemove }

function TBackupItemRemoveFace.getIsExistItem: Boolean;
var
  SelectNode : PVirtualNode;
begin
  Result := True;
  SelectNode := VstBackup.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    if SelectNode.ChildCount > 0 then  // 存在 Item
      Exit;
    SelectNode := SelectNode.NextSibling;
  end;
  Result := False;
end;

procedure TBackupItemRemoveFace.Update;
begin
  inherited;
  if not FindBackupItemNode then
    Exit;
  VstBackup.DeleteNode( BackupItemNode );

    // 没有任何 Item
  if not getIsExistItem then
  begin
    BackupItem_IsExist := False;
    frmMainForm.tbtnBackupAll.Visible := False;
//    frmMainForm.tbtnBackupSpeed.Visible := False;
  end;
end;

{ TVstBackupItemSetAutoSync }

procedure TBackupItemSetAutoSyncFace.SetIsAutoSync(_IsAutoSync: Boolean);
begin
  IsAutoSync := _IsAutoSync;
end;

procedure TBackupItemSetAutoSyncFace.SetSyncTime(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TBackupItemSetAutoSyncFace.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;

  BackupItemData.IsAutoSync := IsAutoSync;
  BackupItemData.SyncTimeType := SyncTimeType;
  BackupItemData.SyncTimeValue := SyncTimeValue;

    // 刷新下次同步
  RefreshNextSyncTime;

    // 刷新节点
  RefreshBackupNode;
end;

{ TBackupItemSetSpaceInfoFace }

procedure TBackupItemSetSpaceInfoFace.SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TBackupItemSetSpaceInfoFace.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;
  BackupItemData.FileCount := FileCount;
  BackupItemData.ItemSize := ItemSize;
  BackupItemData.CompletedSize := CompletedSize;

    // 刷新节点
  RefreshPercentage;
  RefreshBackupNode;
end;

{ TBackupItemSetAddCompletedSpaceFace }

procedure TBackupItemSetAddCompletedSpaceFace.SetAddCompletedSpace( _AddCompletedSpace : int64 );
begin
  AddCompletedSpace := _AddCompletedSpace;
end;

procedure TBackupItemSetAddCompletedSpaceFace.Update;
var
  LastPercentage : Integer;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;
  BackupItemData.CompletedSize := BackupItemData.CompletedSize + AddCompletedSpace;


  LastPercentage := BackupItemData.Percentage;
  RefreshPercentage;

    // 百分比发生变化, 刷新节点
  if BackupItemData.Percentage <> LastPercentage then
    RefreshBackupNode;
end;

{ TNetworkDesItemChangeFace }

procedure TFrmNetworkDesChange.Update;
begin
  vstNetworkDes := frmSelectBackupItem.vstNetworkDes;
end;

{ TNetworkDesItemWriteFace }

constructor TFrmNetworkDesWrite.Create( _DesItemID : string );
begin
  DesItemID := _DesItemID;
end;


function TFrmNetworkDesWrite.FindNetworkDesItemNode : Boolean;
var
  SelectNode : PVirtualNode;
  NodeData : PNetworkDesData;
begin
  Result := False;

  SelectNode := vstNetworkDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstNetworkDes.GetNodeData( SelectNode );
    if NodeData.DesItemID = DesItemID then
    begin
      Result := True;
      NetworkDesNode := SelectNode;
      NetworkDesData := NodeData;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TFrmNetworkDesAdd }

procedure TFrmNetworkDesAdd.CreateDesNode;
var
  SameNameLastNode, LastOnlineNode : PVirtualNode;
begin
  SameNameLastNode := getSameNameLastNode;
  if Assigned( SameNameLastNode ) then
    NetworkDesNode := vstNetworkDes.InsertNode( SameNameLastNode, amInsertAfter )
  else
  if IsOnline then
  begin
    LastOnlineNode := getLastOnlineNode;
    if Assigned( LastOnlineNode ) then
      NetworkDesNode := vstNetworkDes.InsertNode( LastOnlineNode, amInsertAfter )
    else
      NetworkDesNode := vstNetworkDes.InsertNode( vstNetworkDes.RootNode, amAddChildFirst );
  end
  else
    NetworkDesNode := vstNetworkDes.AddChild( vstNetworkDes.RootNode );
end;

function TFrmNetworkDesAdd.getLastOnlineNode: PVirtualNode;
var
  SelectNode : PVirtualNode;
  SelectData : PNetworkDesData;
begin
  Result := nil;
  SelectNode := vstNetworkDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstNetworkDes.GetNodeData( SelectNode );
    if SelectData.IsOnline then
      Result := SelectNode;
    SelectNode := SelectNode.NextSibling;
  end;
end;

function TFrmNetworkDesAdd.getSameNameLastNode: PVirtualNode;
var
  SelectNode : PVirtualNode;
  SelectData : PNetworkDesData;
  ReceivePcID, SelectPcID : string;
begin
  ReceivePcID := NetworkDesItemUtil.getPcID( DesItemID );

  Result := nil;
  SelectNode := vstNetworkDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstNetworkDes.GetNodeData( SelectNode );
    SelectPcID := NetworkDesItemUtil.getPcID( SelectData.DesItemID );
    if SelectPcID = ReceivePcID then
      Result := SelectNode;
    SelectNode := SelectNode.NextSibling;
  end;
end;


procedure TFrmNetworkDesAdd.SetAvailableSpace(_AvailableSpace: Int64);
begin
  AvailableSpace := _AvailableSpace;
end;

procedure TFrmNetworkDesAdd.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TFrmNetworkDesAdd.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TFrmNetworkDesAdd.Update;
begin
  inherited;

    // 不存在 则创建
  if not FindNetworkDesItemNode then
  begin
    CreateDesNode;
    vstNetworkDes.CheckType[ NetworkDesNode ] := ctTriStateCheckBox;
    NetworkDesData := vstNetworkDes.GetNodeData( NetworkDesNode );
    NetworkDesData.DesItemID := DesItemID;
  end;
    // 刷新信息
  NetworkDesData.IsOnline := IsOnline;
  NetworkDesData.MainIcon := FrmNetworkDesUtil.ReadIcon( IsOnline );
  NetworkDesData.DesItemName := PcName;
  NetworkDesData.AvailaleSpace := AvailableSpace;
end;

{ TFrmNetworkDesRemove }

procedure TFrmNetworkDesRemove.Update;
begin
  inherited;

  if not FindNetworkDesItemNode then
    Exit;

  vstNetworkDes.DeleteNode( NetworkDesNode );
end;

{ TDesItemChangeFace }

procedure TFrmLocalDesChange.Update;
begin
  vstLocalDes := frmSelectBackupItem.vstLocalDes;
end;

{ TDesItemChangeFace }

procedure TDesItemChangeFace.Update;
begin
  VstBackup := FrmMainForm.VstBackup;
end;

{ TDesItemWriteFace }

constructor TFrmLocalDesWrite.Create( _DesPath : string );
begin
  DesPath := _DesPath;
end;


function TFrmLocalDesWrite.FindDesItemNode : Boolean;
var
  SelectNode : PVirtualNode;
  NodeData : PLocalDesData;
begin
  Result := False;

  SelectNode := vstLocalDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstLocalDes.GetNodeData( SelectNode );
    if NodeData.DesPath = DesPath then
    begin
      Result := True;
      LocalDesNode := SelectNode;
      LocalDesData := NodeData;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;


{ TFrmDesAdd }

procedure TFrmLocalDesAdd.SetAvailableSpace(_AvailableSpace: Int64);
begin
  AvailableSpace := _AvailableSpace;
end;

procedure TFrmLocalDesAdd.SetIsSelect(_IsSelect: Boolean);
begin
  IsSelect := _IsSelect;
end;

procedure TFrmLocalDesAdd.Update;
begin
  inherited;

  if not FindDesItemNode then
  begin
    LocalDesNode := vstLocalDes.AddChild( vstLocalDes.RootNode );
    vstLocalDes.CheckType[ LocalDesNode ] := ctTriStateCheckBox;
    LocalDesData := vstLocalDes.GetNodeData( LocalDesNode );
    LocalDesData.DesPath := DesPath;
    if DirectoryExists( DesPath ) then
      LocalDesData.MainIcon := MyIcon.getIconByFilePath( DesPath )
    else
      LocalDesData.MainIcon := MyShellIconUtil.getFolderIcon;
  end;

  LocalDesData.AvailaleSpace := AvailableSpace;

  if IsSelect then
    vstLocalDes.CheckState[ LocalDesNode ] := csCheckedNormal;
end;

{ TFrmDesRemove }

procedure TFrmLocalDesRemove.Update;
begin
  inherited;

  if not FindDesItemNode then
    Exit;

  vstLocalDes.DeleteNode( LocalDesNode );
end;

{ TDesItemSetIsExistFace }

procedure TDesItemSetIsExistFace.SetIsExist( _IsExist : boolean );
begin
  IsExist := _IsExist;
end;

procedure TDesItemSetIsExistFace.Update;
begin
  inherited;

  if not FindDesItemNode then
    Exit;

  DesItemData.IsExist := IsExist;

    // 刷新节点
  RefreshDesNode;
end;

{ TDesItemSetIsWriteFace }

procedure TDesItemSetIsWriteFace.SetIsWrite( _IsWrite : boolean );
begin
  IsWrite := _IsWrite;
end;

procedure TDesItemSetIsWriteFace.Update;
begin
  inherited;

  if not FindDesItemNode then
    Exit;
  DesItemData.IsWrite := IsWrite;

    // 刷新节点
  RefreshDesNode;
end;

{ TDesItemSetIsLackSpaceFace }

procedure TDesItemSetIsLackSpaceFace.SetIsLackSpace( _IsLackSpace : boolean );
begin
  IsLackSpace := _IsLackSpace;
end;

procedure TDesItemSetIsLackSpaceFace.Update;
begin
  inherited;

  if not FindDesItemNode then
    Exit;
  DesItemData.IsLackSpace := IsLackSpace;

    // 刷新节点
  RefreshDesNode;
end;

{ TBackupItemSetIsExistFace }

procedure TBackupItemSetIsExistFace.SetIsExist( _IsExist : boolean );
begin
  IsExist := _IsExist;
end;

procedure TBackupItemSetIsExistFace.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;

  BackupItemData.IsExist := IsExist;

    // 刷新节点
  RefreshBackupNode;
end;

{ TBackupItemSetBackupItemStatusFace }

procedure TBackupItemSetStatusFace.SetBackupItemStatus( _BackupItemStatus : string );
begin
  BackupItemStatus := _BackupItemStatus;
end;

procedure TBackupItemSetStatusFace.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;
  BackupItemData.NodeStatus := BackupItemStatus;

    // 刷新节点
  RefreshBackupNode;
end;



{ VstBackupUtil }

class function VstBackupUtil.getBackupHintStr(Node: PVirtualNode): string;
var
  BackupNodeGetHintStr : TBackupNodeGetHintStr;
begin
  BackupNodeGetHintStr := TBackupNodeGetHintStr.Create( Node );
  Result := BackupNodeGetHintStr.get;
  BackupNodeGetHintStr.Free;
end;

class function VstBackupUtil.getBackupStatus(Node: PVirtualNode): string;
var
  NodeData : PVstBackupData;
begin
  NodeData := frmMainForm.VstBackup.GetNodeData( Node );
  if NodeData.IsCompleted then
    Result := BackupStatusShow_Completed
  else
  if NodeData.IsDesBusy then
    Result := BackupStatusShow_Busy
  else
  if not NodeData.IsExist then
    Result := BackupStatusShow_NotExist
  else
  if NodeData.NodeStatus = BackupNodeStatus_Analyizing then
  begin
    if NodeData.AnalyizeCount <= 0 then
      Result := BackupNodeStatus_Analyizing
    else
      Result := Format( BackupStatusShow_Analyizing, [  MyCount.getCountStr( NodeData.AnalyizeCount ) ] );
  end
  else
  if NodeData.NodeStatus = BackupNodeStatus_Backuping then
  begin
    if NodeData.Speed <= 0 then
      Result := BackupNodeStatus_Backuping
    else
      Result := MySpeed.getSpeedStr( NodeData.Speed )
  end
  else
  if NodeData.NodeStatus <> '' then
    Result := NodeData.NodeStatus
  else
    Result := BackupStatusShow_InCompleted;
end;

class function VstBackupUtil.getBackupStatusIcon(
  Node: PVirtualNode): Integer;
var
  NodeData : PVstBackupData;
begin
  NodeData := frmMainForm.VstBackup.GetNodeData( Node );
  if NodeData.IsCompleted then
    Result := MyShellBackupStatusIconUtil.getFilecompleted
  else
  if NodeData.IsDesBusy then
    Result := MyShellTransActionIconUtil.getWaiting
  else
  if not NodeData.IsExist then
    Result := MyShellTransActionIconUtil.getLoadedError
  else
  if NodeData.NodeStatus = BackupNodeStatus_WaitingBackup then
    Result := MyShellTransActionIconUtil.getWaiting
  else
  if NodeData.NodeStatus = BackupNodeStatus_Analyizing then
    Result := MyShellTransActionIconUtil.getAnalyze
  else
  if NodeData.NodeStatus = BackupNodeStatus_Backuping then
    Result := MyShellTransActionIconUtil.getUpLoading
  else
    Result := MyShellBackupStatusIconUtil.getFileIncompleted;
end;

class function VstBackupUtil.getDesStatus(Node: PVirtualNode): string;
var
  NodeData : PVstBackupData;
begin
  NodeData := frmMainForm.VstBackup.GetNodeData( Node );
  if not NodeData.IsExist then
    Result := BackupStatusShow_NotExist
  else
  if not NodeData.IsWrite then
    Result := BackupStatusShow_NotWrite
  else
  if NodeData.IsLackSpace then
    Result := BackupStatusShow_NotSpace
  else
  if not NodeData.IsOnline then
    Result := BackupStatusShow_PcOffline
  else
  if not NodeData.IsConnected then
    Result := BackupStatusShow_NotConnect
  else
  if NodeData.AvailableSpace >= 0 then
    Result := MySize.getFileSizeStr( NodeData.AvailableSpace ) + ' Available';
end;

class function VstBackupUtil.getDesStatusIcon(Node: PVirtualNode): Integer;
var
  NodeData : PVstBackupData;
begin
  NodeData := frmMainForm.VstBackup.GetNodeData( Node );
  if not NodeData.IsExist or
     not NodeData.IsWrite or
     not NodeData.IsOnline or
     not NodeData.IsConnected or
     NodeData.IsLackSpace
  then
    Result := MyShellTransActionIconUtil.getLoadedError
  else
  if NodeData.AvailableSpace >= 0 then
    Result := MyShellTransActionIconUtil.getLoaded;
end;

class function VstBackupUtil.getIsBackupNode(NodeType: string): Boolean;
begin
  Result := ( NodeType = BackupNodeType_LocalBackup ) or ( NodeType = BackupNodeType_NetworkBackup );
end;

class function VstBackupUtil.getIsDesNode(NodeType: string): Boolean;
begin
  Result := ( NodeType = BackupNodeType_LocalDes ) or ( NodeType = BackupNodeType_NetworkDes );
end;

class function VstBackupUtil.getNextBackupText(Node: PVirtualNode): string;
var
  NodeData : PVstBackupData;
begin
  Result := '';
  NodeData := frmMainForm.VstBackup.GetNodeData( Node );
  if not NodeData.IsAutoSync or NodeData.IsBackuping or not NodeData.IsCompleted then
    Exit;
  Result := NodeData.NextSyncTimeShow;
end;

class procedure VstBackupUtil.RefreshSyncNode(Node: PVirtualNode);
var
  NodeData : PVstBackupData;
  SyncMins, MinsSplite : Integer;
begin
  NodeData := frmMainForm.VstBackup.GetNodeData( Node );

    // 计算下次 同步时间
  SyncMins := TimeTypeUtil.getMins( NodeData.SyncTimeType, NodeData.SyncTimeValue );
  NodeData.NextSyncTime := IncMinute( NodeData.LastSyncTime, SyncMins );
  if NodeData.NextSyncTime < Now then  // 应该进行备份
    MinsSplite := 0
  else
    MinsSplite := MinutesBetween( NodeData.NextSyncTime, Now );
  NodeData.NextSyncTimeShow := 'After ' + TimeTypeUtil.getMinShowStr( MinsSplite );
end;

{ TBackupItemSetLastSyncTimeFace }

procedure TBackupItemSetLastSyncTimeFace.SetLastSyncTime( _LastSyncTime : TDateTime );
begin
  LastSyncTime := _LastSyncTime;
end;

procedure TBackupItemSetLastSyncTimeFace.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;

  BackupItemData.LastSyncTime := LastSyncTime;

  RefreshNextSyncTime;
  RefreshBackupNode;
end;


{ TBackupItemSetSpeedFace }

procedure TBackupItemSetSpeedFace.SetSpeed( _Speed : int64 );
begin
  Speed := _Speed;
end;

procedure TBackupItemSetSpeedFace.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;
  BackupItemData.Speed := Speed;

  RefreshBackupNode;
end;

{ TDesItemAddLocalFace }

procedure TDesItemAddLocalFace.CreateDesItem;
var
  LastLocalNode : PVirtualNode;
begin
  LastLocalNode := getLastLocalNode;
  if Assigned( LastLocalNode ) then
    DesItemNode := VstBackup.InsertNode( LastLocalNode, amInsertAfter )
  else
    DesItemNode := VstBackup.InsertNode( VstBackup.RootNode, amAddChildFirst );
end;

procedure TDesItemAddLocalFace.ResetItemInfo;
begin

end;

procedure TDesItemAddLocalFace.SetDesItemInfo;
begin
  DesItemData.IsOnline := True;
  DesItemData.ShowName := DesItemID;
  DesItemData.MainIcon := BackupIcon_Folder;
  DesItemData.NodeType := BackupNodeType_LocalDes;
end;


{ TDesItemAddNetworkFace }

procedure TDesItemAddNetworkFace.CreateDesItem;
var
  LastNetworkNode, LastLocalNode : PVirtualNode;
begin
  LastNetworkNode := getLastNetworkNode;
  if Assigned( LastNetworkNode ) then
    DesItemNode := VstBackup.InsertNode( LastNetworkNode, amInsertAfter )
  else
  if IsOnline then
  begin
    LastLocalNode := getLastLocalNode;
    if Assigned( LastLocalNode ) then
      DesItemNode := VstBackup.InsertNode( LastLocalNode, amInsertAfter )
    else
      DesItemNode := VstBackup.InsertNode( VstBackup.RootNode, amAddChildFirst )
  end
  else
    DesItemNode := VstBackup.InsertNode( VstBackup.RootNode, amAddChildLast );
end;

function TDesItemAddNetworkFace.getLastNetworkNode: PVirtualNode;
var
  SelectNode : PVirtualNode;
  SelectData : PVstBackupData;
begin
    // 寻找同名
  Result := getSameNameNode;
  if Assigned( Result ) then // 已找到
    Exit;

    // 寻找状态相同
  Result := nil;
  SelectNode := vstBackup.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstBackup.GetNodeData( SelectNode );
    if ( SelectData.NodeType = BackupNodeType_NetworkDes ) and
       ( SelectData.IsOnline = IsOnline )
    then
      Result := SelectNode;
    SelectNode := SelectNode.NextSibling;
  end;
end;

function TDesItemAddNetworkFace.getSameNameNode: PVirtualNode;
var
  SelectNode : PVirtualNode;
  SelectData : PVstBackupData;
  CloudPcID, SelectPcID : string;
begin
  CloudPcID := NetworkDesItemUtil.getPcID( DesItemID );

  Result := nil;
  SelectNode := VstBackup.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstBackup.GetNodeData( SelectNode );
    if SelectData.NodeType = BackupNodeType_NetworkDes then
    begin
      SelectPcID := NetworkDesItemUtil.getPcID( SelectData.ItemID );
      if SelectPcID = CloudPcID then
        Result := SelectNode;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;


procedure TDesItemAddNetworkFace.ResetItemInfo;
begin
  DesItemData.IsOnline := IsOnline;
  DesItemData.ShowName := PcName;
  DesItemData.MainIcon := DesItemFaceUtil.ReadPcIcon( IsOnline );

      // 可见性
  VstBackup.IsVisible[ DesItemNode ] := PcFilterUtil.getBackupPcIsShow( DesItemNode );
end;

procedure TDesItemAddNetworkFace.SetDesItemInfo;
begin
  DesItemData.NodeType := BackupNodeType_NetworkDes;
end;

procedure TDesItemAddNetworkFace.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TDesItemAddNetworkFace.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

{ TStartBackupFace }

procedure TStartBackupFace.Update;
begin
  with frmMainForm do
  begin
    tbtnBackupSelected.Enabled := False;
    tbtnBackupAll.Visible := False;
    tbtnBackupStart.Visible := False;
    tbtnBackupStop.Enabled := True;
    tbtnBackupStop.Visible := True;
  end;
end;

{ TStopBackupFace }

procedure TStopBackupFace.Update;
begin
  with frmMainForm do
  begin
    tbtnBackupStop.Visible := False;
    tbtnBackupAll.Visible := BackupItem_IsExist;
    tbtnBackupSelected.Enabled := VstBackup.SelectedCount > 0;
  end;
end;

{ TBackupItemSetIsBackupingFace }

procedure TBackupItemSetIsBackupingFace.SetIsBackuping( _IsBackuping : boolean );
begin
  IsBackuping := _IsBackuping;
end;

procedure TBackupItemSetIsBackupingFace.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;
  BackupItemData.IsBackuping := IsBackuping;
  RefreshBackupNode;
end;

{ TBackupItemSetEncryptInfoFace }

procedure TBackupItemSetEncryptInfoFace.SetEncryptInfo( _IsEncrypt : boolean ;
  _PasswordHint : string);
begin
  IsEncrypt := _IsEncrypt;
  PasswordHint := _PasswordHint;
end;

procedure TBackupItemSetEncryptInfoFace.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;
  BackupItemData.IsEncrypted := IsEncrypt;
  BackupItemData.PasswordHint := PasswordHint;
end;



{ TDesItemRefreshSyncFace }

procedure TDesItemRefreshSyncFace.Update;
var
  DesNode, SourceNode : PVirtualNode;
begin
  inherited;

  DesNode := VstBackup.RootNode.FirstChild;
  while Assigned( DesNode ) do
  begin
    SourceNode := DesNode.FirstChild;
    while Assigned( SourceNode ) do
    begin
      VstBackupUtil.RefreshSyncNode( SourceNode );
      SourceNode := SourceNode.NextSibling;
    end;
    DesNode := DesNode.NextSibling;
  end;
  VstBackup.Refresh;
end;

{ TBackupNodeGetHintStr }

constructor TBackupNodeGetHintStr.Create(_Node: PVirtualNode);
begin
  Node := _Node;
end;

function TBackupNodeGetHintStr.get: string;
begin
  NodeData := frmMainForm.VstBackup.GetNodeData( Node );
  Result := getBaseStr + getAutoBackupStr + getSaveDeletedStr + getEncryptStr + getFilterStr;
end;

function TBackupNodeGetHintStr.getAutoBackupStr: string;
begin
  Result := MyHtmlHintShowStr.getHintRowNext( 'Auto Backup', MyBoolean.getBooleanStr( NodeData.IsAutoSync ) );
  if NodeData.IsAutoSync then
  begin
    Result := Result + MyHtmlHintShowStr.getHintRowNext( 'Auto Backup Interval', TimeTypeUtil.getTimeShow( NodeData.SyncTimeType, NodeData.SyncTimeValue ) );
    Result := Result + MyHtmlHintShowStr.getHintRowNext( 'Next Auto Backup Time', DateTimeToStr( NodeData.NextSyncTime ) );
  end;
  Result := Result + MyHtmlHintShowStr.getHintRowNext( 'Backup immediately when clicking "Back Up All"', MyBoolean.getBooleanStr( NodeData.IsBackupNow ) );
  Result := Result + '<br />';
end;

function TBackupNodeGetHintStr.getBaseStr: string;
var
  DestinationStr : string;
  ParentData : PVstBackupData;
begin
  DestinationStr := '';
  if Assigned( Node.Parent ) then
  begin
    ParentData := frmMainForm.VstBackup.GetNodeData( Node.Parent );
    DestinationStr := ParentData.ShowName;
  end;

  Result := MyHtmlHintShowStr.getHintRowNext( 'Backup Item', NodeData.ShowName );
  Result := Result + MyHtmlHintShowStr.getHintRowNext( 'Destination', DestinationStr );
  Result := Result + MyHtmlHintShowStr.getHintRowNext( 'Last Backup Time', DateTimeToStr( NodeData.LastSyncTime ) );
  Result := Result + '<br />';
end;

function TBackupNodeGetHintStr.getEncryptStr: string;
begin
  Result := MyHtmlHintShowStr.getHintRowNext( 'Encrypted', MyBoolean.getBooleanStr( NodeData.IsEncrypted ) );
  if NodeData.IsEncrypted then
    Result := Result + MyHtmlHintShowStr.getHintRowNext( 'Password Hints', NodeData.PasswordHint );
end;

function TBackupNodeGetHintStr.getFilterStr: string;
begin
  Result := '';
  if NodeData.IncludeFilterStr <> '' then
  begin
    Result := Result + '<br />';
    Result := Result + MyHtmlHintShowStr.getHintRowNext( 'Include Filter', '' );
    Result := Result + NodeData.IncludeFilterStr;
  end;

  if NodeData.ExcludeFilterStr <> '' then
  begin
    if Result <> '' then
      Result := Result + '<br />';
    Result := Result + '<br />';
    Result := Result + MyHtmlHintShowStr.getHintRowNext( 'Exclude Filter', '' );
    Result := Result + NodeData.ExcludeFilterStr;
  end;
end;

function TBackupNodeGetHintStr.getSaveDeletedStr: string;
begin
  Result := MyHtmlHintShowStr.getHintRowNext( 'Save Deleted Files', MyBoolean.getBooleanStr( NodeData.IsSaveDeleted ) );
  if NodeData.IsSaveDeleted then
    Result := Result + MyHtmlHintShowStr.getHintRowNext( 'Save Deleted Editions', IntToStr( NodeData.SaveDeletedCount ) );
  Result := Result + '<br />';
end;

{ TBackupItemSetIsBackupNowFace }

procedure TBackupItemSetIsBackupNowFace.SetIsBackupNow(_IsBackupNow: Boolean);
begin
  IsBackupNow := _IsBackupNow;
end;

procedure TBackupItemSetIsBackupNowFace.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;

  BackupItemData.IsAutoSync := IsBackupNow;
end;

{ TBackupItemSetRecycleFace }

procedure TBackupItemSetRecycleFace.SetDeleteInfo(_IsKeepDeleted: Boolean;
  _KeepEditionCount: Integer);
begin
  IsKeepDeleted := _IsKeepDeleted;
  KeepEditionCount := _KeepEditionCount;
end;

procedure TBackupItemSetRecycleFace.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;

  BackupItemData.IsSaveDeleted := IsKeepDeleted;
  BackupItemData.SaveDeletedCount := KeepEditionCount;
end;

{ TBackupItemSetIncludeFilterFace }

procedure TBackupItemSetIncludeFilterFace.SetIncludeFilterStr(
  _IncludeFilterStr: string);
begin
  IncludeFilterStr := _IncludeFilterStr;
end;

procedure TBackupItemSetIncludeFilterFace.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;

  BackupItemData.IncludeFilterStr := IncludeFilterStr;
end;

{ TBackupItemSetExcludeFilterFace }

procedure TBackupItemSetExcludeFilterFace.SetExcludeFilterStr(
  _ExcludeFilterStr: string);
begin
  ExcludeFilterStr := _ExcludeFilterStr;
end;

procedure TBackupItemSetExcludeFilterFace.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;

  BackupItemData.ExcludeFilterStr := ExcludeFilterStr;
end;

{ TDesItemSetPcIsOnlineFace }

constructor TDesItemSetPcIsOnlineFace.Create(_DesPcID: string);
begin
  DesPcID := _DesPcID;
end;

function TDesItemSetPcIsOnlineFace.getLastLocalNode: PVirtualNode;
var
  SelectNode : PVirtualNode;
  SelectData : PVstBackupData;
begin
  Result := nil;
  SelectNode := VstBackup.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstBackup.GetNodeData( SelectNode );
    if SelectData.NodeType = BackupNodeType_LocalDes then
      Result := SelectNode;
    SelectNode := SelectNode.NextSibling;
  end;
end;

function TDesItemSetPcIsOnlineFace.getLastNetworkOnlineNode: PVirtualNode;
var
  SelectNode : PVirtualNode;
  SelectData : PVstBackupData;
begin
  Result := nil;
  SelectNode := VstBackup.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstBackup.GetNodeData( SelectNode );
    if ( SelectData.NodeType = BackupNodeType_NetworkDes ) and SelectData.IsOnline then
      Result := SelectNode;
    SelectNode := SelectNode.NextSibling;
  end;
end;

function TDesItemSetPcIsOnlineFace.getOnlineMoveNode: PVirtualNode;
begin
  Result := getLastNetworkOnlineNode;
  if not Assigned( Result ) then
    Result := getLastLocalNode;
end;

procedure TDesItemSetPcIsOnlineFace.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TDesItemSetPcIsOnlineFace.Update;
var
  MoveToNode : PVirtualNode;
  SelectNode, ChangeNode : PVirtualNode;
  NodeData : PVstBackupData;
  SelectPcID : string;
begin
  inherited;

  SelectNode := VstBackup.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    NodeData := VstBackup.GetNodeData( SelectNode );
    if NodeData.NodeType = BackupNodeType_NetworkDes then
    begin
      SelectPcID := NetworkDesItemUtil.getPcID( NodeData.ItemID );
      if ( DesPcID = SelectPcID ) and ( IsOnline <> NodeData.IsOnline ) then
      begin
          // 位置发生变化，需要变量转换
        ChangeNode := SelectNode;
        SelectNode := SelectNode.NextSibling; // 先移动，以免位置变化
        if IsOnline then  // 上线时，向上显示
        begin
          MoveToNode := getOnlineMoveNode;
          if Assigned( MoveToNode ) then
          begin
            if ChangeNode <> MoveToNode then
              VstBackup.MoveTo( ChangeNode, MoveToNode, amInsertAfter, False )
          end
          else
          if ChangeNode <> VstBackup.RootNode.FirstChild then
            VstBackup.MoveTo( ChangeNode, VstBackup.RootNode, amAddChildFirst, False );
        end
        else    // 离线时，移到最后
        if ChangeNode <> VstBackup.RootNode.LastChild then
          VstBackup.MoveTo( ChangeNode, VstBackup.RootNode, amAddChildLast, False );

          // 设置状态信息
        NodeData.IsOnline := IsOnline;
        NodeData.MainIcon := DesItemFaceUtil.ReadPcIcon( IsOnline );
        VstBackup.IsVisible[ ChangeNode ] := PcFilterUtil.getBackupPcIsShow( ChangeNode );
        VstBackup.RepaintNode( ChangeNode );
        Continue;
      end;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ DesItemFaceUtil }

class function DesItemFaceUtil.ReadPcIcon(IsOnline: Boolean): Integer;
begin
  if IsOnline then
    Result := BackupIcon_PcOnline
  else
    Result := BackupIcon_PcOffline;
end;

{ TFrmNetworkDesIsOnline }

constructor TFrmNetworkDesIsOnline.Create(_DesPcID: string);
begin
  DesPcID := _DesPcID;
end;

function TFrmNetworkDesIsOnline.getLastOnlineNode: PVirtualNode;
var
  SelectNode : PVirtualNode;
  SelectData : PNetworkDesData;
begin
  Result := nil;
  SelectNode := vstNetworkDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstNetworkDes.GetNodeData( SelectNode );
    if SelectData.IsOnline then
      Result := SelectNode;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TFrmNetworkDesIsOnline.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TFrmNetworkDesIsOnline.Update;
var
  SelectPcID : string;
  LastOnlineNode : PVirtualNode;
  ChangeNode, SelectNode : PVirtualNode;
  NodeData : PNetworkDesData;
begin
  inherited;

  SelectNode := vstNetworkDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstNetworkDes.GetNodeData( SelectNode );
    SelectPcID := NetworkDesItemUtil.getPcID( NodeData.DesItemID );
    if ( SelectPcID = DesPcID ) and ( IsOnline <> NodeData.IsOnline ) then
    begin
        // 位置发生变化，需要变量转换
      ChangeNode := SelectNode;
      SelectNode := SelectNode.NextSibling;
      if IsOnline then  // 上线时，向上显示
      begin
        LastOnlineNode := getLastOnlineNode;
        if Assigned( LastOnlineNode ) then
        begin
          if ChangeNode <> LastOnlineNode then
            vstNetworkDes.MoveTo( ChangeNode, LastOnlineNode, amInsertAfter, False )
        end
        else
        if ChangeNode <> vstNetworkDes.RootNode.FirstChild then
          vstNetworkDes.MoveTo( ChangeNode, vstNetworkDes.RootNode, amAddChildFirst, False );
      end
      else       // 离线时，移到最后
      if ChangeNode <> vstNetworkDes.RootNode.LastChild then
        vstNetworkDes.MoveTo( ChangeNode, vstNetworkDes.RootNode, amAddChildLast, False );

      NodeData.IsOnline := IsOnline;
      NodeData.MainIcon := FrmNetworkDesUtil.ReadIcon( IsOnline );
      vstNetworkDes.RepaintNode( ChangeNode );
      Continue;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ FrmNetworkDesUtil }

class function FrmNetworkDesUtil.ReadIcon(IsOnline: Boolean): Integer;
begin
  if IsOnline then
    Result := FrmDesIcon_PcOnline
  else
    Result := FrmDesIcon_PcOffline;
end;

{ TBackupItemSetIsCompletedFace }

procedure TBackupItemSetIsCompletedFace.SetIsCompleted( _IsCompleted : boolean );
begin
  IsCompleted := _IsCompleted;
end;

procedure TBackupItemSetIsCompletedFace.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;
  BackupItemData.IsCompleted := IsCompleted;
  RefreshBackupNode;
end;

{ TBackupItemSetAnalyizeCountFace }

procedure TBackupItemSetAnalyizeCountFace.SetAnalyizeCount( _AnalyizeCount : integer );
begin
  AnalyizeCount := _AnalyizeCount;
end;

procedure TBackupItemSetAnalyizeCountFace.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;
  BackupItemData.AnalyizeCount := AnalyizeCount;
  RefreshBackupNode;
end;



{ TDesItemAddFace }

function TDesItemAddFace.getLastLocalNode: PVirtualNode;
var
  SelectNode : PVirtualNode;
  SelectData : PVstBackupData;
begin
  Result := nil;
  SelectNode := vstBackup.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstBackup.GetNodeData( SelectNode );
    if SelectData.NodeType = BackupNodeType_LocalDes then
      Result := SelectNode;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TDesItemAddFace.SetAvailableSpace(_AvailableSpace: Int64);
begin
  AvailableSpace := _AvailableSpace;
end;

{ TFrmSetAvailableSpaceFace }

procedure TFrmNetworkSetAvailableSpace.SetAvailableSpace(_AvailableSpace: Int64);
begin
  AvaialbleSpace := _AvailableSpace;
end;

procedure TFrmNetworkSetAvailableSpace.Update;
begin
  inherited;

  if not FindNetworkDesItemNode then
    Exit;

  NetworkDesData.AvailaleSpace := AvaialbleSpace;
  vstNetworkDes.RepaintNode( NetworkDesNode );
end;

procedure TDesItemAddFace.Update;
begin
  inherited;

    // 不存在则创建并初始化节点
  if not FindDesItemNode then
  begin
      // 在特定位置创建节点
    CreateDesItem;
    DesItemNode.NodeHeight := 28;

      // 初始化信息
    DesItemData := VstBackup.GetNodeData( DesItemNode );
    DesItemData.ItemID := DesItemID;
    DesItemData.IsExist := True;
    DesItemData.IsWrite := True;
    DesItemData.IsLackSpace := False;
    DesItemData.IsConnected := True;
    DesItemData.NodeStatus := '';

      // 设置信息
    SetDesItemInfo;
  end;

    // 刷新信息
  DesItemData.AvailableSpace := AvailableSpace;
  ResetItemInfo;

    // 刷新节点
  RefreshDesNode;
end;

{ TFrmLocalSetAvailableSpace }

procedure TFrmLocalSetAvailableSpace.SetAvailableSpace(_AvailableSpace: Int64);
begin
  AvaialbleSpace := _AvailableSpace;
end;

procedure TFrmLocalSetAvailableSpace.Update;
begin
  inherited;

  if not FindDesItemNode then
    Exit;

  LocalDesData.AvailaleSpace := AvaialbleSpace;

  vstLocalDes.RepaintNode( LocalDesNode );
end;

{ TDesItemSetAvailableSpaceFace }

procedure TDesItemSetAvailableSpaceFace.SetAvailableSpace( _AvailableSpace : int64 );
begin
  AvailableSpace := _AvailableSpace;
end;

procedure TDesItemSetAvailableSpaceFace.Update;
begin
  inherited;

  if not FindDesItemNode then
    Exit;
  DesItemData.AvailableSpace := AvailableSpace;
  RefreshDesNode;
end;

{ TPauseBackupFace }

procedure TPauseBackupFace.Update;
begin
  with frmMainForm do
  begin
    tbtnBackupStop.Visible := False;
    tbtnBackupStart.Visible := True;
  end;
end;

{ TSendItemErrorWriteFace }

procedure TBackupItemErrorAddFace.SetErrorStatus(_ErrorStatus: string);
begin
  ErrorStatus := _ErrorStatus;
end;

procedure TBackupItemErrorAddFace.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TBackupItemErrorAddFace.SetSpaceInfo(_FileSize,
  _CompletedSpace: Int64);
begin
  FileSize := _FileSize;
  CompletedSpace := _CompletedSpace;
end;

procedure TBackupItemErrorAddFace.Update;
var
  ErrorNode : PVirtualNode;
  ErrorData : PVstBackupData;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;

  ErrorNode := VstBackup.AddChild( BackupItemNode );
  ErrorData := VstBackup.GetNodeData( ErrorNode );
  ErrorData.ItemID := FilePath;
  ErrorData.ShowName := FilePath;
  ErrorData.ItemSize := FileSize;
  ErrorData.NodeType := BackupNodeType_ErrorItem;
  ErrorData.MainIcon := MyIcon.getIconByFilePath( FilePath );
  ErrorData.Percentage := MyPercentage.getPercent( CompletedSpace, FileSize );
  ErrorData.NodeStatus := ErrorStatus;

  VstBackup.Expanded[ BackupItemNode ] := True;
end;

{ TSendItemErrorClearFace }

procedure TBackupItemErrorClearFace.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;

  VstBackup.DeleteChildren( BackupItemNode );
end;


{ TBackupItemSetIsDesBusyFace }

procedure TBackupItemSetIsDesBusyFace.SetIsDesBusy(_IsDesBusy: boolean);
begin
  IsDesBusy := _IsDesBusy;
end;

procedure TBackupItemSetIsDesBusyFace.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;
  BackupItemData.IsDesBusy := IsDesBusy;
  RefreshBackupNode;
end;

{ TDesItemSetIsConnectedFace }

procedure TDesItemSetIsConnectedFace.SetIsConnected(_IsConnected: boolean);
begin
  IsConnected := _IsConnected;
end;

procedure TDesItemSetIsConnectedFace.Update;
begin
  inherited;

  if not FindDesItemNode then
    Exit;

  DesItemData.IsConnected := IsConnected;

    // 刷新节点
  RefreshDesNode;
end;

{ TBackupSpeedLimitFace }

procedure TBackupSpeedLimitFace.SetIsLimit(_IsLimit: Boolean);
begin
  IsLimit := _IsLimit;
end;

procedure TBackupSpeedLimitFace.SetLimitSpeed(_LimitSpeed: Int64);
begin
  LimitSpeed := _LimitSpeed;
end;

procedure TBackupSpeedLimitFace.Update;
var
  ShowType, ShowStr : string;
begin
  ShowType := 'Network Backup Speed: ';
  if not IsLimit then
    ShowStr := 'Unlimited'
  else
    ShowStr := 'Limit to ' + MySpeed.getSpeedStr( LimitSpeed );

  ShowStr := MyHtmlHintShowStr.getHintRow( ShowType, ShowStr );
  frmMainForm.tbtnBackupSpeed.Hint := ShowStr;
end;

{ TBackupPcFilterItemChangeFace }

procedure TFrmBackupPcFilterChange.Update;
begin
  vstBackupPcFilter := frmSendPcFilter.vstGroupPc;
end;

{ TBackupPcFilterItemWriteFace }

constructor TFrmBackupPcFilterWrite.Create( _DesItemID : string );
begin
  DesItemID := _DesItemID;
end;


function TFrmBackupPcFilterWrite.FindBackupPcFilterItemNode : Boolean;
var
  SelectNode : PVirtualNode;
  NodeData : PBackupPcFilterData;
begin
  Result := False;

  SelectNode := vstBackupPcFilter.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstBackupPcFilter.GetNodeData( SelectNode );
    if NodeData.DesItemID = DesItemID then
    begin
      Result := True;
      BackupPcFilterNode := SelectNode;
      BackupPcFilterData := NodeData;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TFrmBackupPcFilterAdd }

procedure TFrmBackupPcFilterAdd.CreateDesNode;
var
  SameNameLastNode, LastOnlineNode : PVirtualNode;
begin
  SameNameLastNode := getSameNameLastNode;
  if Assigned( SameNameLastNode ) then
    BackupPcFilterNode := vstBackupPcFilter.InsertNode( SameNameLastNode, amInsertAfter )
  else
  if IsOnline then
  begin
    LastOnlineNode := getLastOnlineNode;
    if Assigned( LastOnlineNode ) then
      BackupPcFilterNode := vstBackupPcFilter.InsertNode( LastOnlineNode, amInsertAfter )
    else
      BackupPcFilterNode := vstBackupPcFilter.InsertNode( vstBackupPcFilter.RootNode, amAddChildFirst );
  end
  else
    BackupPcFilterNode := vstBackupPcFilter.AddChild( vstBackupPcFilter.RootNode );
end;

function TFrmBackupPcFilterAdd.getLastOnlineNode: PVirtualNode;
var
  SelectNode : PVirtualNode;
  SelectData : PBackupPcFilterData;
begin
  Result := nil;
  SelectNode := vstBackupPcFilter.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstBackupPcFilter.GetNodeData( SelectNode );
    if SelectData.IsOnline then
      Result := SelectNode;
    SelectNode := SelectNode.NextSibling;
  end;
end;

function TFrmBackupPcFilterAdd.getSameNameLastNode: PVirtualNode;
var
  SelectNode : PVirtualNode;
  SelectData : PBackupPcFilterData;
  ReceivePcID, SelectPcID : string;
begin
  ReceivePcID := NetworkDesItemUtil.getPcID( DesItemID );

  Result := nil;
  SelectNode := vstBackupPcFilter.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstBackupPcFilter.GetNodeData( SelectNode );
    SelectPcID := NetworkDesItemUtil.getPcID( SelectData.DesItemID );
    if SelectPcID = ReceivePcID then
      Result := SelectNode;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TFrmBackupPcFilterAdd.SetDirectory(_Directory: string);
begin
  Directory := _Directory;
end;

procedure TFrmBackupPcFilterAdd.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TFrmBackupPcFilterAdd.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TFrmBackupPcFilterAdd.Update;
begin
  inherited;

    // 不存在 则创建并初始化信息
  if not FindBackupPcFilterItemNode then
  begin
    CreateDesNode;
    vstBackupPcFilter.CheckType[ BackupPcFilterNode ] := ctTriStateCheckBox;
    if frmSendPcFilter.getIsChecked( DesItemID ) then
      vstBackupPcFilter.CheckState[ BackupPcFilterNode ] := csCheckedNormal;

    BackupPcFilterData := vstBackupPcFilter.GetNodeData( BackupPcFilterNode );
    BackupPcFilterData.DesItemID := DesItemID;
  end;

    // 刷新信息
  BackupPcFilterData.IsOnline := IsOnline;
  BackupPcFilterData.MainIcon := FrmNetworkDesUtil.ReadIcon( IsOnline );
  BackupPcFilterData.ComputerName := PcName;
  BackupPcFilterData.Directory := Directory;
end;

{ TFrmBackupPcFilterRemove }

procedure TFrmBackupPcFilterRemove.Update;
begin
  inherited;

  if not FindBackupPcFilterItemNode then
    Exit;

  vstBackupPcFilter.DeleteNode( BackupPcFilterNode );
end;

{ TFrmBackupPcFilterIsOnline }

constructor TFrmBackupPcFilterIsOnline.Create(_DesPcID: string);
begin
  DesPcID := _DesPcID;
end;

function TFrmBackupPcFilterIsOnline.getLastOnlineNode: PVirtualNode;
var
  SelectNode : PVirtualNode;
  SelectData : PBackupPcFilterData;
begin
  Result := nil;
  SelectNode := vstBackupPcFilter.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstBackupPcFilter.GetNodeData( SelectNode );
    if SelectData.IsOnline then
      Result := SelectNode;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TFrmBackupPcFilterIsOnline.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TFrmBackupPcFilterIsOnline.Update;
var
  SelectPcID : string;
  LastOnlineNode : PVirtualNode;
  ChangeNode, SelectNode : PVirtualNode;
  NodeData : PBackupPcFilterData;
begin
  inherited;

  SelectNode := vstBackupPcFilter.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstBackupPcFilter.GetNodeData( SelectNode );
    SelectPcID := NetworkDesItemUtil.getPcID( NodeData.DesItemID );
    if ( SelectPcID = DesPcID ) and ( IsOnline <> NodeData.IsOnline ) then
    begin
        // 位置发生变化，需要变量转换
      ChangeNode := SelectNode;
      SelectNode := SelectNode.NextSibling;
      if IsOnline then  // 上线时，向上显示
      begin
        LastOnlineNode := getLastOnlineNode;
        if Assigned( LastOnlineNode ) then  // 存在 Online 节点，移到其后
        begin
          if ChangeNode <> LastOnlineNode then
            vstBackupPcFilter.MoveTo( ChangeNode, LastOnlineNode, amInsertAfter, False )
        end
        else  // 不存在，移到最顶
        if ChangeNode <> vstBackupPcFilter.RootNode.FirstChild then
          vstBackupPcFilter.MoveTo( ChangeNode, vstBackupPcFilter.RootNode, amAddChildFirst, False );
      end
      else       // 离线时，移到最后
      if ChangeNode <> vstBackupPcFilter.RootNode.LastChild then
        vstBackupPcFilter.MoveTo( ChangeNode, vstBackupPcFilter.RootNode, amAddChildLast, False );

      NodeData.IsOnline := IsOnline;
      NodeData.MainIcon := FrmNetworkDesUtil.ReadIcon( IsOnline );
      vstBackupPcFilter.RepaintNode( ChangeNode );
      Continue;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TLogFileStartFace }

procedure TLogFileStartFace.Update;
begin
  frmBackupLog.tmrProgress.Enabled := True;
  frmBackupLog.plStatus.Visible := False;
end;

{ TLogFileStopFace }

procedure TLogFileStopFace.Update;
begin
  frmBackupLog.tmrProgress.Enabled := False;
  frmBackupLog.pbProgress.Visible := False;
  frmBackupLog.pbProgress.Style := pbstNormal;
end;

{ TLogFileBusyFace }

procedure TLogFileBusyFace.Update;
begin
  frmBackupLog.lbStatus.Caption := LogStatus_Busy;
  frmBackupLog.plStatus.Visible := True;
end;

{ TLogFileNotConnFace }

procedure TLogFileNotConnFace.Update;
begin
  frmBackupLog.lbStatus.Caption := LogStatus_NotConn;
  frmBackupLog.plStatus.Visible := True;
end;

{ TLogFileNotExistFace }

procedure TLogFileNotExistFace.Update;
begin
  frmBackupLog.lbStatus.Caption := LogStatus_NotExist;
  frmBackupLog.plStatus.Visible := True;
end;

{ TLogFileStartRestore }

procedure TLogFileStartRestore.Update;
begin
  frmBackupLog.Close;
  MainFormUtil.EnterMainPage( MainPage_Restore );
end;

{ TMainBackupSpeedLimitFace }

procedure TMainBackupSpeedLimitFace.SetIsLimit(_IsLimit: Boolean);
begin
  IsLimit := _IsLimit;
end;

procedure TMainBackupSpeedLimitFace.Update;
var
  ShowStr : string;
begin
  ShowStr := 'Speed';
  if IsLimit then
    ShowStr := ShowStr + ' ( Limited )';
  frmMainForm.tbtnBackupSpeed.Caption := ShowStr;
end;

{ TFrmBackupingHintFace }

constructor TFrmBackupingHintFace.Create(_BackupPath, _BackupTo: string);
begin
  BackupPath := _BackupPath;
  BackupTo := _BackupTo;
end;

procedure TFrmBackupingHintFace.Update;
begin
  if not frmMainForm.getIsShowHint then
    Exit;

  frmBackupHint.ShowBackuping( BackupPath, BackupTo );
end;

{ TFrmBackupCompletedHintFace }

constructor TFrmBackupCompletedHintFace.Create(_DesItemID, _BackupPath: string);
begin
  DesItemID := _DesItemID;
  BackupPath := _BackupPath;
  BackupFileList := TStringList.Create;
end;

destructor TFrmBackupCompletedHintFace.Destroy;
begin
  BackupFileList.Free;
  inherited;
end;

procedure TFrmBackupCompletedHintFace.SetBackupFile(AddFileList: TStringList);
var
  i: Integer;
begin
  for i := 0 to AddFileList.Count - 1 do
    BackupFileList.Add( AddFileList[i] );
end;

procedure TFrmBackupCompletedHintFace.SetBackupInfo(_BackupTo: string;
  _TotalBackup: Integer);
begin
  BackupTo := _BackupTo;
  TotalBackup := _TotalBackup;
end;

procedure TFrmBackupCompletedHintFace.Update;
var
  Params : THintParams;
begin
  if not frmMainForm.getIsShowHint then
    Exit;

  Params.DesItemID := DesItemID;
  Params.BackupPath := BackupPath;
  Params.BackupTo := BackupTo;
  Params.TotalBackup := TotalBackup;
  Params.BackupFileList := BackupFileList;

  frmBackupHint.ShowBackupCompleted( Params );
end;

end.
