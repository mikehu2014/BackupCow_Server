unit UMyRestoreFaceInfo;

interface

uses UChangeInfo, VirtualTrees, UIconUtil, UMyUtil, SysUtils, stdctrls, ExtCtrls, DateUtils, ComCtrls,
     classes, Winapi.GDIPOBJ, Winapi.ActiveX, Vcl.Graphics, Winapi.GDIPAPI, Menus;

type

{$Region ' 恢复文件 选择 ' }

  {$Region ' 数据结构 ' }

      // 数据结构
  TVstRestoreData = record
  public
    ItemID : WideString;
  public
    IsFile : boolean;
    OwnerID, OwnerName : WideString;
  public
    FileCount : integer;
    FileSize : int64;
    LastBackupTime : TDateTime;
  public
    IsSaveDeleted : Boolean;
    IsEncrypted : Boolean;
    Password, PasswordHint : WideString;
  public
    ShowName, NodeType : WideString;
    MainIcon : Integer;
  end;
  PVstRestoreData = ^TVstRestoreData;


  {$EndRegion}

  {$Region ' 数据修改 Pc信息 ' }

    // 父类
  TRestoreDesChangeFace = class( TFaceChangeInfo )
  public
    VstRestore : TVirtualStringTree;
  protected
    procedure Update;override;
  end;

    // 恢复目标 Pc 信息
  TRestoreDesFaceOffline = class( TRestoreDesChangeFace )
  public
    DesPcID : string;
  public
    constructor Create( _DesPcID : string );
  protected
    procedure Update;override;
  end;

    // 修改
  TRestoreDesWriteFace = class( TRestoreDesChangeFace )
  public
    DesItemID : string;
  protected
    RestoreDesNode : PVirtualNode;
    RestoreDesData : PVstRestoreData;
  public
    constructor Create( _DesItemID : string );
  protected
    function FindRestoreDesNode : Boolean;
  end;

    // 添加
  TRestoreDesAddFace = class( TRestoreDesWriteFace )
  protected
    procedure Update;override;
  protected
    function getLastLocalNode : PVirtualNode;
    procedure CreateDesNode;virtual;abstract;
    procedure SetDesNodeInfo;virtual;abstract;
  end;

    // 添加 本地目标
  TRestoreDesAddLocalFace = class( TRestoreDesAddFace )
  protected
    procedure CreateDesNode;override;
    procedure SetDesNodeInfo;override;
  end;

    // 添加 网络目标
  TRestoreDesAddNetworkFace = class( TRestoreDesAddFace )
  public
    PcName : string;
  public
    procedure SetPcName( _PcName : string );
  protected
    procedure CreateDesNode;override;
    procedure SetDesNodeInfo;override;
  end;

    // 删除
  TNetworkRestoreDesRemoveFace = class( TRestoreDesWriteFace )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 数据修改 备份信息 ' }

    // 修改
  TRestoreItemWriteFace = class( TRestoreDesWriteFace )
  public
    OwnerID, BackupPath : string;
  protected
    RestorePcBackupNode : PVirtualNode;
    RestorePcBackupData : PVstRestoreData;
  public
    procedure SetOwnerID( _OwnerID : string );
    procedure SetBackupPath( _BackupPath : string );
  protected
    function FindRestorePcBackupNode : Boolean;
  end;

    // 添加
  TRestoreItemAddFace = class( TRestoreItemWriteFace )
  public
    IsFile : boolean;
    OwnerName : string;
  public
    FileCount : integer;
    FileSize : int64;
    LastBackupTime : TDateTime;
  public
    IsSaveDeleted : Boolean;
    IsEncrypted : Boolean;
    Password, PasswordHint : WideString;
  public
    procedure SetIsFile( _IsFile : boolean );
    procedure SetOwnerName( _OwnerName : string );
    procedure SetSpaceInfo( _FileCount : integer; _FileSize : int64 );
    procedure SetLastBackupTime( _LastBackupTime : TDateTime );
    procedure SetIsSaveDeleted( _IsSaveDeleted : Boolean );
    procedure SetEncryptedInfo( _IsEncrypted : Boolean; _Password, _PasswordHint : string );
  protected
    procedure Update;override;
  protected
    procedure SetNodeInfo;virtual;abstract;
  end;

    // 添加 本地恢复源
  TRestoreItemAddLocalFace = class( TRestoreItemAddFace )
  protected
    procedure SetNodeInfo;override;
  end;

    // 添加 网络恢复源
  TRestoreItemAddNetworkFace = class( TRestoreItemAddFace )
  protected
    procedure SetNodeInfo;override;
  end;

    // 删除
  TRestoreItemRemoveFace = class( TRestoreItemWriteFace )
  protected
    procedure Update;override;
  private
    function getIsExistVisibleChild : Boolean;
  end;

  {$EndRegion}

  {$Region ' 数据读取 ' }

  RestoreFaceReadUtil = class
  public
    class function ReadHintStr( Node : PVirtualNode ): string;
    class function ReadIsRestoreNode( Node : PVirtualNode ): Boolean;
    class function ReadIsExistVisibleChild( Node : PVirtualNode ): Boolean;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 恢复文件 Pc 过滤 ' }

  TRestorePcFilterData = record
  public
    PcID, PcName : WideString;
    MainIcon : Integer;
  end;
  PRestorePcFilterData = ^TRestorePcFilterData;

    // 父类
  TFrmRestorePcFilterChange = class( TFaceChangeInfo )
  public
    vstRestorePcFilter : TVirtualStringTree;
  protected
    procedure Update;override;
  end;

    // 清空
  TFrmRestorePcFilterClear = class( TFrmRestorePcFilterChange )
  protected
    procedure Update;override;
  end;

    // 修改
  TFrmRestorePcFilterWrite = class( TFrmRestorePcFilterChange )
  public
    PcID : string;
  protected
    RestorePcFilterNode : PVirtualNode;
    RestorePcFilterData : PRestorePcFilterData;
  public
    constructor Create( _PcID : string );
  protected
    function FindRestorePcFilterNode : Boolean;
  end;

    // 添加
  TFrmRestorePcFilterAdd = class( TFrmRestorePcFilterWrite )
  public
    PcName : string;
  public
    procedure SetPcName( _PcName : string );
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 恢复文件 Explorer ' }

    // 数据结构
  TRestoreExplorerData = record
  public
    FilePath : WideString;
    IsFile, IsDeleted : boolean;
  public
    FileSize : int64;
    FileTime : TDateTime;
  public
    ShowName : WideString;
    ShowIcon : Integer;
  end;
  PVstRestoreExplorerData = ^TRestoreExplorerData;

    // 父类
  TRestoreExplorerChangeFace = class( TFaceChangeInfo )
  public
    VstRestoreExplorer : TVirtualStringTree;
  protected
    procedure Update;override;
  end;

    // 添加文件
  TRestoreExplorerAddFace = class( TRestoreExplorerChangeFace )
  public
    FilePath : string;
    IsFile : boolean;
    FileSize : int64;
    FileTime : TDateTime;
  private
    ParentNode : PVirtualNode;
  public
    constructor Create( _FilePath : string );
    procedure SetIsFile( _IsFile : boolean );
    procedure SetFileInfo( _FileSize : int64; _FileTime : TDateTime );
    procedure Update;override;
  private
    function FindParentNode : Boolean;
    function AddNode: PVirtualNode;
  private
    function AddFileNode: PVirtualNode;
    function AddFolderNode: PVirtualNode;
  end;

  {$Region ' 搜索状态显示 ' }

  TRestoreExplorerStatusChangeFace = class( TFaceChangeInfo )
  public
    tmrStatus : TTimer;
    pbStatus : TProgressBar;
  public
    plStatus : TPanel;
    lbStatus : TLabel;
  public
    procedure Update;override;
  end;

    // 开始
  TRestoreExplorerStartFace = class( TRestoreExplorerStatusChangeFace )
  public
    procedure Update;override;
  end;

    // 结束
  TRestoreExplorerStopFace = class( TRestoreExplorerStatusChangeFace )
  public
    procedure Update;override;
  end;

    // 繁忙
  TRestoreExplorerBusyFace = class( TRestoreExplorerStatusChangeFace )
  public
    procedure Update;override;
  end;

    // 无法连接
  TRestoreExplorerNotConnFace = class( TRestoreExplorerStatusChangeFace )
  public
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 恢复删除文件 Explorer ' }

    // 数据结构
  TRestoreDeleteExplorerData = record
  public
    FilePath : WideString;
    IsFile : boolean;
  public
    FileSize : int64;
    FileTime : TDateTime;
    EditionNum : Integer; // 删除的版本号
  public
    ShowName : WideString;
    ShowIcon : Integer;
  end;
  PVsTRestoreDeleteExplorerData = ^TRestoreDeleteExplorerData;

    // 父类
  TRestoreDeleteExplorerChangeFace = class( TFaceChangeInfo )
  public
    VstRestoreDeleteExplorer : TVirtualStringTree;
  protected
    procedure Update;override;
  end;

      // 添加
  TRestoreDeleteExplorerAddFace = class( TRestoreDeleteExplorerChangeFace )
  public
    FilePath : string;
    IsFile : boolean;
    FileSize : int64;
    FileTime : TDateTime;
    EditionNum : Integer;
  private
    ParentNode : PVirtualNode;
    ChildNode : PVirtualNode;
  public
    constructor Create( _FilePath : string );
    procedure SetIsFile( _IsFile : boolean );
    procedure SetFileInfo( _FileSize : int64; _FileTime : TDateTime );
    procedure SetEditionNum( _EditionNum : Integer );
  protected
    procedure Update;override;
  private
    function FindParentNode : Boolean;
    function FindChildNode : Boolean;
  private    // 创建节点
    function AddNode : PVirtualNode;
    function AddFolderNode: PVirtualNode;
    function AddFileNode: PVirtualNode;
    function AddEditionNode : PVirtualNode;
  private
    function AddRootFileNode : PVirtualNode;
  end;

  {$Region ' 搜索状态显示 ' }

  TRestoreDeleteExplorerStatusChangeFace = class( TFaceChangeInfo )
  public
    tmrStatus : TTimer;
    pbStatus : TProgressBar;
  public
    plStatus : TPanel;
    lbStatus : TLabel;
  public
    procedure Update;override;
  end;

    // 开始
  TRestoreDeleteExplorerStartFace = class( TRestoreDeleteExplorerStatusChangeFace )
  public
    procedure Update;override;
  end;

    // 结束
  TRestoreDeleteExplorerStopFace = class( TRestoreDeleteExplorerStatusChangeFace )
  public
    procedure Update;override;
  end;

    // 繁忙
  TRestoreDeleteExplorerBusyFace = class( TRestoreDeleteExplorerStatusChangeFace )
  public
    procedure Update;override;
  end;

    // 无法连接
  TRestoreDeleteExplorerNotConnFace = class( TRestoreDeleteExplorerStatusChangeFace )
  public
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 恢复文件 Search ' }

    // 数据结构
  TRestoreSearchData = record
  public
    FilePath : WideString;
    IsFile : boolean;
  public
    FileSize : int64;
    FileTime : TDateTime;
  public
    IsDeleted : Boolean;
    EditionNum : Integer;
  public
    ShowName : WideString;
    ShowIcon, RecycleIcon : Integer;
  end;
  PVstRestoreSearchData = ^TRestoreSearchData;

    // 父类
  TRestoreSearchChangeFace = class( TFaceChangeInfo )
  public
    VstRestoreSearch : TVirtualStringTree;
  protected
    procedure Update;override;
  end;

    // 添加 父类
  TRestoreSearchAddBaseFace = class( TRestoreSearchChangeFace )
  protected
    FilePath : string;
    IsFile : boolean;
    FileSize : int64;
    FileTime : TDateTime;
  protected
    IsDeleted : boolean;
    EditionNum : Integer;
  protected
    ParentNode, ChildNode : PVirtualNode;
  public
    constructor Create( _FilePath : string );
    procedure SetIsFile( _IsFile : boolean );
    procedure SetFileInfo( _FileSize : int64; _FileTime : TDateTime );
    procedure SetDeletedInfo( _IsDeleted : boolean; _EditionNum : Integer );
  protected    // 创建节点
    function AddNode : PVirtualNode;
    function AddFolderNode: PVirtualNode;
    function AddFileNode: PVirtualNode;
    function AddDeletedFolderNode : PVirtualNode;
    function AddDeletedFileNode : PVirtualNode;
  protected
    function FindDeletedFileNode : Boolean;
    function AddEditionNode : PVirtualNode;
  end;

      // 添加
  TRestoreSearchAddFace = class( TRestoreSearchAddBaseFace )
  protected
    procedure Update;override;
  end;

    // 添加 子节点
  TRestoreSearchExplorerAddFace = class( TRestoreSearchAddBaseFace )
  protected
    procedure Update;override;
  private
    function FindParentNode : Boolean;
  private
    procedure RemoveRootExist;
  end;

  {$Region ' 搜索状态显示 ' }

  TRestoreSearchStatusChangeFace = class( TFaceChangeInfo )
  public
    tmrStatus : TTimer;
    pbStatus : TProgressBar;
  public
    plStatus : TPanel;
    lbStatus : TLabel;
  public
    btnSearch : TButton;
    btnStop : TButton;
  public
    procedure Update;override;
  end;

    // 开始
  TRestoreSearchStartFace = class( TRestoreSearchStatusChangeFace )
  public
    procedure Update;override;
  end;

    // 结束
  TRestoreSearchStopFace = class( TRestoreSearchStatusChangeFace )
  public
    procedure Update;override;
  end;

    // 繁忙
  TRestoreSearchBusyFace = class( TRestoreSearchStatusChangeFace )
  public
    procedure Update;override;
  end;

    // 无法连接
  TRestoreSearchNotConnFace = class( TRestoreSearchStatusChangeFace )
  public
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 恢复文件 预览 ' }

      // 预览父类
  TRestorePreviewShowFace = class( TFaceChangeInfo )
  protected
    FilePath : string;
  public
    procedure SetFilePath( _FilePath : string );
    procedure Update;override;
  protected
    procedure ShowPreview;virtual;
  end;

    // 从流中预览
  TRestorePreviewStreamShowFace = class( TRestorePreviewShowFace )
  protected
    PreviewStream : TStream;
  public
    procedure SetPreviewStream( _PreviewStream : TStream );
    destructor Destroy; override;
  end;

    // 预览图片
  TRestorePreviewPictureFace = class( TRestorePreviewStreamShowFace )
  protected
    procedure ShowPreview;override;
  end;

    // 预览文本文档
  TRestorePreviewTextFace = class( TRestorePreviewStreamShowFace )
  protected
    procedure ShowPreview;override;
  private
    procedure ShowCannotPreview;
  end;

    // 预览 Exe Icon
  TRestorePreviewExeIconFace = class( TRestorePreviewStreamShowFace )
  protected
    procedure ShowPreview;override;
  end;

    // 预览 word
  TRestorePreviewWordFace = class( TRestorePreviewShowFace )
  private
    WordText : string;
  public
    procedure SetWordText( _WordText : string );
  protected
    procedure ShowPreview;override;
  end;

    // 预览 Excel
  TRestorePreviewExcelFace = class( TRestorePreviewShowFace )
  private
    ExcelText : string;
    LvExcel : TListView;
  public
    procedure SetExcelText( _ExcelText : string );
  protected
    procedure ShowPreview;override;
  private
    procedure IniColumnShow( ColumnCount : Integer );
    procedure ShowRow( RowStr : string );
  end;

    // 预览 Zip
  TRestorePreviewZipFace = class( TRestorePreviewShowFace )
  private
    ZipText : string;
    LvZip : TListView;
  public
    procedure SetZipText( _ZipText : string );
  protected
    procedure ShowPreview;override;
  private
    procedure ShowFile( FileInfoStr : string );
  end;

    // 预览 exe
  TRestorePreviewExeDetailFace = class( TRestorePreviewShowFace )
  private
    ExeText : string;
  public
    procedure SetExeText( _ExeText : string );
  protected
    procedure ShowPreview;override;
  end;

    // 预览 Music
  TRestorePreviewMusicFace = class( TRestorePreviewShowFace )
  private
    MusicText : string;
  public
    procedure SetMusicText( _MusicText : string );
  protected
    procedure ShowPreview;override;
  end;

  {$Region ' 预览状态显示 ' }

    // 开始加载预览
  TRestoreFilePreviewStartFace = class( TFaceChangeInfo )
  protected
    procedure Update;override;
  end;

    // 结束加载预览
  TRestoreFilePreviewStopFace = class( TFaceChangeInfo )
  protected
    procedure Update;override;
  end;

      // 繁忙
  TSharePreivewBusyFace = class( TFaceChangeInfo )
  public
    procedure Update;override;
  end;

    // 无法连接
  TSharePreivewNotConnFace = class( TFaceChangeInfo )
  public
    procedure Update;override;
  end;

      // 无法预览
  TSharePreivewNotPreviewFace = class( TFaceChangeInfo )
  public
    procedure Update;override;
  end;

      // 无法预览加密
  TSharePreivewNotPreviewEncryptedFace = class( TFaceChangeInfo )
  public
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 恢复文件下载 ' }

  {$Region ' 数据结构 ' }

    // 数据结构
  TVstRestoreDownData = record
  public
    RestorePath, OwnerPcID, RestoreFrom : WideString;
    OwnerPcName, RestoreFromName : WideString;
    IsFile, IsCompleted, IsRestoring : Boolean;
    IsOnline, IsRestoreExist, IsDesBusy : Boolean;
    IsWrite, IsLackSpace, IsConnected  : Boolean;
  public
    FileCount : integer;
    FileSize, CompletedSize : int64;
    Percentage : Integer;
    Speed : Integer;
    AnalyzeCount : Integer;
  public
    IsDeleted, IsEncrypt : Boolean;
  public
    SavePath : WideString;
  public
    MainIcon : Integer;
    NodeStatus, NodeType : WideString;
  end;
  PVstRestoreDownData = ^TVstRestoreDownData;

  {$EndRegion}

  {$Region ' 数据修改 ' }

    // 父类
  TRestoreDownChangeFace = class( TFaceChangeInfo )
  public
    VstRestoreDown : TVirtualStringTree;
  protected
    procedure Update;override;
  end;

    // 修改
  TRestoreDownWriteFace = class( TRestoreDownChangeFace )
  public
    RestorePath, OwnerPcID, RestoreFrom : string;
  protected
    RestoreDownNode : PVirtualNode;
    RestoreDownData : PVstRestoreDownData;
  public
    constructor Create( _RestorePath, _OwnerPcID, _RestoreFrom : string );
  protected
    function FindRestoreDownNode : Boolean;
    procedure RefreshPercentage;
    procedure RefreshNode;
  end;

  {$Region ' 增删节点 ' }

    // 添加
  TRestoreDownAddFace = class( TRestoreDownWriteFace )
  public
    IsFile, IsCompleted : Boolean;
    OwnerPcName, FromPcName : string;
  public
    FileCount : integer;
    FileSize, CompletedSize : int64;
  public
    IsDeleted, IsEncrypt : Boolean;
    SavePath : string;
  public
    procedure SetIsFile( _IsFile : Boolean );
    procedure SetIsCompleted( _IsCompleted : Boolean );
    procedure SetOwnerPcName( _OwnerPcName : string );
    procedure SetFromPcName( _FromPcName : string );
    procedure SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
    procedure SetIsDeleted( _IsDeleted : Boolean );
    procedure SetIsEncrypt( _IsEncrypt : Boolean );
    procedure SetSavePath( _SavePath : string );
  protected
    procedure Update;override;
  protected
    procedure SetItemInfo;virtual;abstract;
  end;

    // 添加 本地恢复 下载
  TRestoreDownAddLocalFace = class( TRestoreDownAddFace )
  protected
    procedure SetItemInfo;override;
  end;

    // 添加 网络恢复 下载
  TRestoreDownAddNtworkFace = class( TRestoreDownAddFace )
  private
    IsOnline : Boolean;
  public
    procedure SetIsOnline( _IsOnline : Boolean );
  protected
    procedure SetItemInfo;override;
  end;

    // 删除
  TRestoreDownRemoveFace = class( TRestoreDownWriteFace )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 修改 状态 ' }

    // 设置 状态
  TRestoreDownSetStautsFace = class( TRestoreDownWriteFace )
  public
    NodeStatus : string;
  public
    procedure SetNodeStatus( _NodeStatus : string );
  protected
    procedure Update;override;
  end;

    // 设置 是否存在恢复源
  TRestoreDownSetIsExistFace = class( TRestoreDownWriteFace )
  public
    IsExist : Boolean;
  public
    procedure SetIsExist( _IsExist : Boolean );
  protected
    procedure Update;override;
  end;

    // 修改保存位置是否可写
  TRestoreDownSetIsWriteFace = class( TRestoreDownWriteFace )
  public
    IsWrite : boolean;
  public
    procedure SetIsWrite( _IsWrite : boolean );
  protected
    procedure Update;override;
  end;

    // 设置 是否缺少空间
  TRestoreDownSetIsLackSpaceFace = class( TRestoreDownWriteFace )
  public
    IsLackSpace : Boolean;
  public
    procedure SetIsLackSpace( _IsLackSpace : Boolean );
  protected
    procedure Update;override;
  end;

    // 修改 速度
  TRestoreDownSetSpeedFace = class( TRestoreDownWriteFace )
  public
    Speed : integer;
  public
    procedure SetSpeed( _Speed : integer );
  protected
    procedure Update;override;
  end;

    // 修改
  TRestoreDownSetAnalyzeCountFace = class( TRestoreDownWriteFace )
  public
    AnalyzeCount : integer;
  public
    procedure SetAnalyzeCount( _AnalyzeCount : integer );
  protected
    procedure Update;override;
  end;


    // 设置 Pc 是否上线
  TRestoreDownSetPcIsOnlineFace = class( TRestoreDownChangeFace )
  public
    DesPcID : string;
    IsOnline : Boolean;
  public
    constructor Create( _DesPcID : string );
    procedure SetIsOnline( _IsOnline : Boolean );
  protected
    procedure Update;override;
  end;

      // 修改
  TRestoreDownSetIsCompletedFace = class( TRestoreDownWriteFace )
  public
    IsCompleted : boolean;
  public
    procedure SetIsCompleted( _IsCompleted : boolean );
  protected
    procedure Update;override;
  end;

      // 修改
  TRestoreDownSetIsRestoringFace = class( TRestoreDownWriteFace )
  public
    IsRestoring : boolean;
  public
    procedure SetIsRestoring( _IsRestoring : boolean );
  protected
    procedure Update;override;
  end;

        // 修改
  TRestoreDownSetIsDesBusyFace = class( TRestoreDownWriteFace )
  public
    IsDesBusy : boolean;
  public
    procedure SetIsDesBusy( _IsIsDesBusy : boolean );
  protected
    procedure Update;override;
  end;

        // 修改
  TRestoreDownSetIsConnectedFace = class( TRestoreDownWriteFace )
  public
    IsConnected : boolean;
  public
    procedure SetIsConnected( _IsConnected : boolean );
  protected
    procedure Update;override;
  end;

    // 开始下载
  TRestoreDownStartFace = class( TFaceChangeInfo )
  protected
    procedure Update;override;
  end;

    // 暂停下载
  TRestoreDownPauseFace = class( TFaceChangeInfo )
  protected
    procedure Update;override;
  end;

    // 结束下载
  TRestoreDownStopFace = class( TFaceChangeInfo )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 空间信息 ' }

      // 修改
  TRestoreDownSetSpaceInfoFace = class( TRestoreDownWriteFace )
  public
    FileCount : integer;
    FileSize, CompletedSize : int64;
  public
    procedure SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
  protected
    procedure Update;override;
  end;

    // 修改
  TRestoreDownSetAddCompletedSpaceFace = class( TRestoreDownWriteFace )
  public
    AddCompletedSpace : int64;
  public
    procedure SetAddCompletedSpace( _AddCompletedSpace : int64 );
  protected
    procedure Update;override;
  end;

      // 修改
  TRestoreDownSetCompletedSizeFace = class( TRestoreDownWriteFace )
  public
    CompletedSize : int64;
  public
    procedure SetCompletedSize( _CompletedSize : int64 );
  protected
    procedure Update;override;
  end;


  {$EndRegion}

  {$Region ' 错误的信息 ' }

      // 添加 错误
  TRestoreDownErrorAddFace = class( TRestoreDownWriteFace )
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
  TRestoreDownErrorClearFace = class( TRestoreDownWriteFace )
  protected
    procedure Update;override;
  end;

  {$EndRegion}


  {$EndRegion}

  {$Region ' 数据读取 ' }

  RestoreDownFaceReadUtil = class
  public
    class function ReadStatusText( Node : PVirtualNode ): string;
    class function ReadStatusImg( Node : PVirtualNode ): Integer;
  public
    class function ReadHintStr( Node : PVirtualNode ): string;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 恢复速度 ' }

        // 速度限制
  TRestoreSpeedLimitFace = class( TFaceChangeInfo )
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

{$Region ' 恢复浏览历史 ' }

      // 父类
  TRestoreExplorerHistoryChangeFace = class( TFaceChangeInfo )
  public
    PmExplorerHistory : TPopupMenu;
  protected
    procedure Update;override;
  end;

      // 添加
  TRestoreExplorerHistoryAddFace = class( TRestoreExplorerHistoryChangeFace )
  public
    OwnerName, FilePath : string;
  public
    constructor Create( _OwnerName, _FilePath : string );
  protected
    procedure Update;override;
  end;

    // 删除
  TRestoreExplorerHistoryRemoveFace = class( TRestoreExplorerHistoryChangeFace )
  public
    RemoveIndex : Integer;
  public
    constructor Create( _RemoveIndex : Integer );
  protected
    procedure Update;override;
  end;

{$EndRegion}

const
  RestoreIcon_PcOnline = 1;
  RestoreIcon_Folder = 5;

  RestoreNodeType_LocalDes = 'LocalDes';
  RestoreNodeType_LocalRestore = 'LocalRestore';
  RestoreNodeType_NetworkDes = 'NetworkDes';
  RestoreNodeType_NetworkRestore = 'NetworkRestore';

const
  RestoreDownNodeType_Local = 'Local';
  RestoreDownNodeType_Network = 'Network';
  RestoreDownNodeType_Error = 'Error';

  RestoreNodeStatus_WaitingRestore = 'Waiting';
  RestoreNodeStatus_Restoreing = 'Restoreing';
  RestoreNodeStatus_Analyizing = 'Analyzing';
  RestoreNodeStatus_Empty = '';

  RestoreNodeStatus_ReadFileError = 'Read File Error';
  RestoreNodeStatus_WriteFileError = 'Write File Error';
  RestoreNodeStatus_ReceiveFileError = 'Receive File Error';
  RestoreNodeStatus_LostConnectFileError = 'Lost Connect File Error';

  RestoreStatusShow_NotExist = 'Restore Path Not Exist';
  RestoreStatusShow_NotWrite = 'Can not Write';
  RestoreStatusShow_NotSpace = 'Space Insufficient';
  RestoreStatusShow_PcOffline = 'Restore From PC Offline';
  RestoreStatusShow_Analyizing = 'Analyzing %s Files';
  RestoreStatusShow_DesBusy = 'Restore From PC Busy';
  RestoreStatusShow_NotConnect = 'Can not Connect to Restore From PC';

  RestoreStatusShow_Incompleted = 'Incompleted';
  RestoreStatusShow_Completed = 'Completed';

const
  ExplorerStatus_Waiting = 'Restore directory is Loading...';
  ExplorerStatus_Searching = 'Restore directory is Searching...';
  ExplorerStatus_Stop = '';
  ExplorerStatus_Busy = 'Restore From PC Busy';
  ExplorerStatus_NotConn = 'Cannot Connect to Restore From PC';
  ExplorerStatus_Encrypted = 'Cannot preview this encrypted file';
  ExplorerStatus_NotPreview = 'Cannot preview this file';

const
  RestoreShowType_MyFiles = 'MyFiles';
  RestoreShowType_AllFiles = 'AllFiles';

var
  RestoreShow_Type : string = RestoreShowType_MyFiles;
  RestoreSearch_IsShow : Boolean = False;

implementation

uses UMainForm, UFOrmRestoreExplorer, UFormRestorePcFilter, UFormPreview;

{ TRestorePcChangeFace }

procedure TRestoreDesChangeFace.Update;
begin
  VstRestore := frmMainForm.vstRestoreShow;
end;

{ TRestorePcWriteFace }

constructor TRestoreDesWriteFace.Create( _DesItemID : string );
begin
  DesItemID := _DesItemID;
end;


function TRestoreDesWriteFace.FindRestoreDesNode : Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstRestoreData;
begin
  Result := False;
  SelectNode := VstRestore.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstRestore.GetNodeData( SelectNode );
    if ( SelectData.ItemID = DesItemID ) then
    begin
      Result := True;
      RestoreDesNode := SelectNode;
      RestoreDesData := SelectData;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TRestorePcAddFace }

procedure TRestoreDesAddNetworkFace.CreateDesNode;
begin
  RestoreDesNode := VstRestore.AddChild( VstRestore.RootNode );
end;

procedure TRestoreDesAddNetworkFace.SetDesNodeInfo;
begin
  RestoreDesData.ShowName := PcName;
  RestoreDesData.MainIcon := RestoreIcon_PcOnline;
  RestoreDesData.NodeType := RestoreNodeType_NetworkDes;
end;

procedure TRestoreDesAddNetworkFace.SetPcName( _PcName : string );
begin
  PcName := _PcName;
end;

{ TRestorePcRemoveFace }

procedure TNetworkRestoreDesRemoveFace.Update;
begin
  inherited;

  if not FindRestoreDesNode then
    Exit;

  VstRestore.DeleteNode( RestoreDesNode );
end;

{ TRestorePcBackupWriteFace }

procedure TRestoreItemWriteFace.SetBackupPath( _BackupPath : string );
begin
  BackupPath := _BackupPath;
end;


procedure TRestoreItemWriteFace.SetOwnerID(_OwnerID: string);
begin
  OwnerID := _OwnerID;
end;

function TRestoreItemWriteFace.FindRestorePcBackupNode : Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstRestoreData;
begin
  Result := False;
  if not FindRestoreDesNode then
    Exit;
  SelectNode := RestoreDesNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstRestore.GetNodeData( SelectNode );
    if ( SelectData.ItemID = BackupPath ) and ( SelectData.OwnerID = OwnerID ) then
    begin
      Result := True;
      RestorePcBackupNode := SelectNode;
      RestorePcBackupData := SelectData;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TRestorePcBackupAddFace }

procedure TRestoreItemAddFace.SetEncryptedInfo(_IsEncrypted: Boolean; _Password,
  _PasswordHint: string);
begin
  IsEncrypted := _IsEncrypted;
  Password := _Password;
  PasswordHint := _PasswordHint;
end;

procedure TRestoreItemAddFace.SetIsFile( _IsFile : boolean );
begin
  IsFile := _IsFile;
end;

procedure TRestoreItemAddFace.SetIsSaveDeleted(_IsSaveDeleted: Boolean);
begin
  IsSaveDeleted := _IsSaveDeleted;
end;

procedure TRestoreItemAddFace.SetLastBackupTime(_LastBackupTime: TDateTime);
begin
  LastBackupTime := _LastBackupTime;
end;

procedure TRestoreItemAddFace.SetOwnerName(_OwnerName: string);
begin
  OwnerName := _OwnerName;
end;

procedure TRestoreItemAddFace.SetSpaceInfo( _FileCount : integer; _FileSize : int64 );
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
end;

procedure TRestoreItemAddFace.Update;
begin
  inherited;

    // 不存在 则创建
  if not FindRestorePcBackupNode then
  begin
    if not Assigned( RestoreDesNode ) then
      Exit;

    RestorePcBackupNode := VstRestore.AddChild( RestoreDesNode );
    RestorePcBackupData := VstRestore.GetNodeData( RestorePcBackupNode );
    RestorePcBackupData.ItemID := BackupPath;
    RestorePcBackupData.ShowName := BackupPath;
    RestorePcBackupData.IsFile := IsFile;
    RestorePcBackupData.OwnerID := OwnerID;

      // 设置信息
    SetNodeInfo;
  end;

    // 修改 空间信息
  RestorePcBackupData.OwnerName := OwnerName;
  RestorePcBackupData.FileCount := FileCount;
  RestorePcBackupData.FileSize := FileSize;
  RestorePcBackupData.LastBackupTime := LastBackupTime;
  RestorePcBackupData.IsSaveDeleted := IsSaveDeleted;
  RestorePcBackupData.IsEncrypted := IsEncrypted;
  RestorePcBackupData.Password := Password;
  RestorePcBackupData.PasswordHint := PasswordHint;
end;

{ TRestorePcBackupRemoveFace }

function TRestoreItemRemoveFace.getIsExistVisibleChild: Boolean;
var
  SelectNode : PVirtualNode;
begin
  Result := False;

  SelectNode := RestoreDesNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    if VstRestore.IsVisible[ SelectNode ] then
    begin
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TRestoreItemRemoveFace.Update;
begin
  inherited;

  if not FindRestorePcBackupNode then
    Exit;

  VstRestore.DeleteNode( RestorePcBackupNode );

    // 不存在 可见的子节点， 隐藏根
  if not RestoreFaceReadUtil.ReadIsExistVisibleChild( RestoreDesNode ) then
    VstRestore.IsVisible[ RestoreDesNode ] := False;
end;

{ TRestoreDownChangeFace }

procedure TRestoreDownChangeFace.Update;
begin
  VstRestoreDown := frmMainForm.vstRestoreDown;
end;

{ TRestoreDownWriteFace }

constructor TRestoreDownWriteFace.Create( _RestorePath, _OwnerPcID, _RestoreFrom : string );
begin
  RestorePath := _RestorePath;
  OwnerPcID := _OwnerPcID;
  RestoreFrom := _RestoreFrom;
end;


function TRestoreDownWriteFace.FindRestoreDownNode : Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstRestoreDownData;
begin
  Result := False;
  SelectNode := VstRestoreDown.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstRestoreDown.GetNodeData( SelectNode );
    if ( SelectData.RestorePath = RestorePath ) and
       ( SelectData.OwnerPcID = OwnerPcID ) and
       ( SelectData.RestoreFrom = RestoreFrom )
    then
    begin
      Result := True;
      RestoreDownNode := SelectNode;
      RestoreDownData := SelectData;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TRestoreDownWriteFace.RefreshNode;
begin
  VstRestoreDown.RepaintNode( RestoreDownNode );
end;

procedure TRestoreDownWriteFace.RefreshPercentage;
begin
  RestoreDownData.Percentage := MyPercentage.getPercent( RestoreDownData.CompletedSize, RestoreDownData.FileSize );
end;

{ TRestoreDownAddFace }

procedure TRestoreDownAddFace.SetIsCompleted(_IsCompleted: Boolean);
begin
  IsCompleted := _IsCompleted;
end;

procedure TRestoreDownAddFace.SetIsDeleted(_IsDeleted: Boolean);
begin
  IsDeleted := _IsDeleted;
end;

procedure TRestoreDownAddFace.SetIsEncrypt(_IsEncrypt: Boolean);
begin
  IsEncrypt := _IsEncrypt;
end;

procedure TRestoreDownAddFace.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TRestoreDownAddFace.SetOwnerPcName(_OwnerPcName: string);
begin
  OwnerPcName := _OwnerPcName;
end;

procedure TRestoreDownAddFace.SetFromPcName( _FromPcName : string );
begin
  FromPcName := _FromPcName;
end;

procedure TRestoreDownAddFace.SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TRestoreDownAddFace.Update;
begin
  inherited;

    // 不存在，则创建
  if not FindRestoreDownNode then
  begin
    RestoreDownNode := VstRestoreDown.InsertNode( VstRestoreDown.RootNode, amAddChildFirst );
    RestoreDownData := VstRestoreDown.GetNodeData( RestoreDownNode );
    RestoreDownData.RestorePath := RestorePath;
    RestoreDownData.OwnerPcID := OwnerPcID;
    RestoreDownData.RestoreFrom := RestoreFrom;
  end;

  RestoreDownData.OwnerPcName := OwnerPcName;
  RestoreDownData.RestoreFromName := FromPcName;
  RestoreDownData.IsFile := IsFile;
  RestoreDownData.IsCompleted := IsCompleted;
  RestoreDownData.IsRestoring := False;
  RestoreDownData.IsOnline := True;
  RestoreDownData.IsRestoreExist := True;
  RestoreDownData.IsWrite := True;
  RestoreDownData.IsLackSpace := False;
  RestoreDownData.IsConnected := True;
  RestoreDownData.IsDesBusy := False;
  RestoreDownData.FileCount := FileCount;
  RestoreDownData.FileSize := FileSize;
  RestoreDownData.CompletedSize := CompletedSize;
  RestoreDownData.IsDeleted := IsDeleted;
  RestoreDownData.IsEncrypt := IsEncrypt;
  RestoreDownData.SavePath := SavePath;
  RestoreDownData.NodeStatus := '';
  if IsFile then
    RestoreDownData.MainIcon := MyIcon.getIconByFilePath( RestorePath )
  else
    RestoreDownData.MainIcon := MyShellIconUtil.getFolderIcon;

    // 设置 Item 信息
  SetItemInfo;

    // 刷新百分比
  RefreshPercentage;

    // 出现了恢复下载
  if VstRestoreDown.RootNodeCount = 1 then
  begin
    frmMainForm.plRestoreDown.Visible := True;
    frmMainForm.slRestoreDown.Visible := True;
  end;
  if IsCompleted then
    frmMainForm.tbtnRestoreDownClear.Enabled := True;
  if frmMainForm.btnHide.Tag = 1 then
    frmMainForm.btnHide.Click;
end;

procedure TRestoreDownAddFace.SetSavePath( _SavePath : string );
begin
  SavePath := _SavePath;
end;

{ TRestoreDownRemoveFace }

procedure TRestoreDownRemoveFace.Update;
begin
  inherited;

  if not FindRestoreDownNode then
    Exit;

  VstRestoreDown.DeleteNode( RestoreDownNode );
end;


{ TRestoreDesAddLocalFace }

procedure TRestoreDesAddLocalFace.CreateDesNode;
var
  LastLocalNode : PVirtualNode;
begin
  LastLocalNode := getLastLocalNode;
  if Assigned( LastLocalNode ) then
    RestoreDesNode := VstRestore.InsertNode( LastLocalNode, amInsertAfter )
  else
    RestoreDesNode := VstRestore.InsertNode( VstRestore.RootNode, amAddChildFirst );
end;

procedure TRestoreDesAddLocalFace.SetDesNodeInfo;
begin
  RestoreDesData.ShowName := DesItemID;
  RestoreDesData.MainIcon := RestoreIcon_Folder;
  RestoreDesData.NodeType := RestoreNodeType_LocalDes;
end;

{ TRestoreItemAddLocalFace }

procedure TRestoreItemAddLocalFace.SetNodeInfo;
var
  IconPath : string;
begin
  IconPath := MyFilePath.getPath( DesItemID ) + MyFilePath.getDownloadPath( BackupPath );
  if IsFile or DirectoryExists( IconPath ) then
    RestorePcBackupData.MainIcon := MyIcon.getIconByFilePath( IconPath )
  else
    RestorePcBackupData.MainIcon := MyShellIconUtil.getFolderIcon;

  RestorePcBackupData.NodeType := RestoreNodeType_LocalRestore;

    // 设置根节点信息
  if not VstRestore.IsVisible[ RestoreDesNode ] then
  begin
    VstRestore.Expanded[ RestoreDesNode ] := True;
    VstRestore.IsVisible[ RestoreDesNode ] := True;
  end;
end;

{ TRestoreItemAddNetworkFace }

procedure TRestoreItemAddNetworkFace.SetNodeInfo;
var
  IsShowNode : Boolean;
begin
  RestorePcBackupData.NodeType := RestoreNodeType_NetworkRestore;
  if IsFile then
    RestorePcBackupData.MainIcon := MyIcon.getIconByFileExt( BackupPath )
  else
    RestorePcBackupData.MainIcon := MyShellIconUtil.getFolderIcon;

    // 是否显示节点
  IsShowNode := PcFilterUtil.getRestorePcIsShow( RestorePcBackupNode );
  VstRestore.IsVisible[ RestorePcBackupNode ] := IsShowNode;

    // 不显示节点
  if not IsShowNode then
    Exit;

    // 设置根节点信息
  if not VstRestore.IsVisible[ RestoreDesNode ] then
  begin
    VstRestore.Expanded[ RestoreDesNode ] := True;
    VstRestore.IsVisible[ RestoreDesNode ] := True;
  end;
end;

{ TRestoreDownSetStautsFace }

procedure TRestoreDownSetStautsFace.SetNodeStatus(_NodeStatus: string);
begin
  NodeStatus := _NodeStatus;
end;

procedure TRestoreDownSetStautsFace.Update;
begin
  inherited;

  if not FindRestoreDownNode then
    Exit;

  RestoreDownData.NodeStatus := NodeStatus;

  RefreshNode;
end;

{ TRestoreDownSetIsLackSpaceFace }

procedure TRestoreDownSetIsLackSpaceFace.SetIsLackSpace(_IsLackSpace: Boolean);
begin
  IsLackSpace := _IsLackSpace;
end;

procedure TRestoreDownSetIsLackSpaceFace.Update;
begin
  inherited;

  if not FindRestoreDownNode then
    Exit;

  RestoreDownData.IsLackSpace := IsLackSpace;

  RefreshNode;
end;

{ TRestoreDownSetIsFace }

procedure TRestoreDownSetIsExistFace.SetIsExist(_IsExist: Boolean);
begin
  IsExist := _IsExist;
end;

procedure TRestoreDownSetIsExistFace.Update;
begin
  inherited;

  if not FindRestoreDownNode then
    Exit;

  RestoreDownData.IsRestoreExist := IsExist;

  RefreshNode;
end;

{ TRestoreDownSetSpaceInfoFace }

procedure TRestoreDownSetSpaceInfoFace.SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TRestoreDownSetSpaceInfoFace.Update;
begin
  inherited;

  if not FindRestoreDownNode then
    Exit;
  RestoreDownData.FileCount := FileCount;
  RestoreDownData.FileSize := FileSize;
  RestoreDownData.CompletedSize := CompletedSize;

  RefreshPercentage;

  RefreshNode;
end;

{ TRestoreDownSetAddCompletedSpaceFace }

procedure TRestoreDownSetAddCompletedSpaceFace.SetAddCompletedSpace( _AddCompletedSpace : int64 );
begin
  AddCompletedSpace := _AddCompletedSpace;
end;

procedure TRestoreDownSetAddCompletedSpaceFace.Update;
begin
  inherited;

  if not FindRestoreDownNode then
    Exit;
  RestoreDownData.CompletedSize := RestoreDownData.CompletedSize + AddCompletedSpace;

  RefreshPercentage;

  RefreshNode;
end;



{ RestoreDownFaceReadUtil }

class function RestoreDownFaceReadUtil.ReadHintStr(Node: PVirtualNode): string;
var
  NodeData : PVstRestoreDownData;
begin
  NodeData := frmMainForm.vstRestoreDown.GetNodeData( Node );
  Result := MyHtmlHintShowStr.getHintRowNext( 'Retore From',  NodeData.RestoreFromName );
  Result := Result + MyHtmlHintShowStr.getHintRowNext( 'Owner',  NodeData.OwnerPcName );
  Result := Result + MyHtmlHintShowStr.getHintRowNext( 'Item to Restore',  NodeData.RestorePath );
  Result := Result + MyHtmlHintShowStr.getHintRow( 'Retore to',  NodeData.SavePath );
  if NodeData.IsEncrypt then
  begin
    Result := Result + '<br />';
    Result := Result + MyHtmlHintShowStr.getHintRow( 'Encrypted',  'Yes' );
  end;
  if NodeData.IsDeleted then
  begin
    Result := Result + '<br />';
    Result := Result + MyHtmlHintShowStr.getHintRow( 'Restore Type',  'Deleted Files' );
  end;
end;

class function RestoreDownFaceReadUtil.ReadStatusImg(
  Node: PVirtualNode): Integer;
var
  NodeData : PVstRestoreDownData;
begin
  NodeData := frmMainForm.vstRestoreDown.GetNodeData( Node );
  if NodeData.IsCompleted then
    Result := MyShellBackupStatusIconUtil.getFilecompleted
  else
  if not NodeData.IsRestoreExist or
     not NodeData.IsOnline or
     not NodeData.IsWrite or
     not NodeData.IsConnected or
     NodeData.IsDesBusy or
     NodeData.IsLackSpace
  then
    Result := MyShellTransActionIconUtil.getLoadedError
  else
  if NodeData.NodeStatus = RestoreNodeStatus_WaitingRestore then
    Result := MyShellTransActionIconUtil.getWaiting
  else
  if NodeData.NodeStatus = RestoreNodeStatus_Analyizing then
    Result := MyShellTransActionIconUtil.getAnalyze
  else
  if NodeData.NodeStatus = RestoreNodeStatus_Restoreing then
    Result := MyShellTransActionIconUtil.getDownLoading
  else
    Result := MyShellBackupStatusIconUtil.getFileIncompleted;
end;

class function RestoreDownFaceReadUtil.ReadStatusText(
  Node: PVirtualNode): string;
var
  NodeData : PVstRestoreDownData;
begin
  NodeData := frmMainForm.vstRestoreDown.GetNodeData( Node );

  if NodeData.IsCompleted then
    Result := RestoreStatusShow_Completed
  else
  if not NodeData.IsOnline then
    Result := RestoreStatusShow_PcOffline
  else
  if not NodeData.IsRestoreExist then
    Result := RestoreStatusShow_NotExist
  else
  if not NodeData.IsWrite then
    Result := RestoreStatusShow_NotWrite
  else
  if NodeData.IsLackSpace then
    Result := RestoreStatusShow_NotSpace
  else
  if NodeData.IsDesBusy then
    Result := RestoreStatusShow_DesBusy
  else
  if not NodeData.IsConnected then
    Result := RestoreStatusShow_NotConnect
  else
  if NodeData.NodeStatus = RestoreNodeStatus_WaitingRestore then
    Result := RestoreNodeStatus_WaitingRestore
  else
  if NodeData.NodeStatus = RestoreNodeStatus_Analyizing then
  begin
    if NodeData.AnalyzeCount > 0 then
      Result := Format( RestoreStatusShow_Analyizing, [ MyCount.getCountStr( NodeData.AnalyzeCount ) ] )
    else
      Result := NodeData.NodeStatus;
  end
  else
  if NodeData.NodeStatus = RestoreNodeStatus_Restoreing then
  begin
    if NodeData.Speed > 0 then
      Result := MySpeed.getSpeedStr( NodeData.Speed )
    else
      Result := NodeData.NodeStatus;
  end
  else
    Result := RestoreStatusShow_Incompleted;
end;

{ TRestoreDownSetSpeedFace }

procedure TRestoreDownSetSpeedFace.SetSpeed( _Speed : integer );
begin
  Speed := _Speed;
end;

procedure TRestoreDownSetSpeedFace.Update;
begin
  inherited;

  if not FindRestoreDownNode then
    Exit;
  RestoreDownData.Speed := Speed;
  RefreshNode;
end;



{ RestoreFaceReadUtil }

class function RestoreFaceReadUtil.ReadHintStr(Node: PVirtualNode): string;
var
  NodeData, ParentData : PVstRestoreData;
  RestoreFrom : string;
begin
  NodeData := frmMainForm.vstRestoreShow.GetNodeData( Node );
  if Assigned( Node.Parent ) and ( Node.Parent <> frmMainForm.vstRestoreShow.RootNode ) then
  begin
    ParentData := frmMainForm.vstRestoreShow.GetNodeData( Node.Parent );
    RestoreFrom := ParentData.ShowName;
  end;
  Result := MyHtmlHintShowStr.getHintRowNext( 'Item to Restore',  RestoreFrom );
  Result := Result + MyHtmlHintShowStr.getHintRowNext( 'Owner',  NodeData.OwnerName );
  Result := Result + MyHtmlHintShowStr.getHintRowNext( 'Restore Path',  NodeData.ShowName );
  Result := Result + MyHtmlHintShowStr.getHintRowNext( 'Encrypted', MyBoolean.getBooleanStr( NodeData.IsEncrypted ) );
  Result := Result + MyHtmlHintShowStr.getHintRow( 'Save Deleted Files', MyBoolean.getBooleanStr( NodeData.IsSaveDeleted ) );
end;

class function RestoreFaceReadUtil.ReadIsExistVisibleChild(
  Node: PVirtualNode): Boolean;
var
  SelectNode : PVirtualNode;
begin
  Result := False;

  SelectNode := Node.FirstChild;
  while Assigned( SelectNode ) do
  begin
    if frmMainForm.vstRestoreShow.IsVisible[ SelectNode ] then
    begin
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;


class function RestoreFaceReadUtil.ReadIsRestoreNode(Node: PVirtualNode): Boolean;
var
  NodeData : PVstRestoreData;
begin
  NodeData := frmMainForm.vstRestoreShow.GetNodeData( Node );
  Result := ( NodeData.NodeType = RestoreNodeType_LocalRestore ) or
            ( NodeData.NodeType = RestoreNodeType_NetworkRestore );
end;

{ TRestoreExplorerChangeFace }

procedure TRestoreExplorerChangeFace.Update;
begin
  VstRestoreExplorer := frmRestoreExplorer.vstExplorer
end;

{ TRestoreDownSetIsWriteFace }

procedure TRestoreDownSetIsWriteFace.SetIsWrite( _IsWrite : boolean );
begin
  IsWrite := _IsWrite;
end;

procedure TRestoreDownSetIsWriteFace.Update;
begin
  inherited;

  if not FindRestoreDownNode then
    Exit;
  RestoreDownData.IsWrite := IsWrite;
  RefreshNode;
end;



{ TRestoreDownSetPcIsOnlineFace }

constructor TRestoreDownSetPcIsOnlineFace.Create(_DesPcID: string);
begin
  DesPcID := _DesPcID;
end;

procedure TRestoreDownSetPcIsOnlineFace.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TRestoreDownSetPcIsOnlineFace.Update;
var
  SelectNode : PVirtualNode;
  SelectData : PVstRestoreDownData;
  SelectPcID : string;
begin
  inherited;

  SelectNode := VstRestoreDown.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstRestoreDown.GetNodeData( SelectNode );
    if SelectData.NodeType = RestoreDownNodeType_Network then
    begin
      SelectPcID := NetworkDesItemUtil.getPcID( SelectData.RestoreFrom );
      if SelectPcID = DesPcID then
      begin
        SelectData.IsOnline := IsOnline;
        VstRestoreDown.RepaintNode( SelectNode );
      end;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TRestoreDownAddLocalFace }

procedure TRestoreDownAddLocalFace.SetItemInfo;
begin
  RestoreDownData.NodeType := RestoreDownNodeType_Local;
end;

{ TRestoreDownAddNtworkFace }

procedure TRestoreDownAddNtworkFace.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TRestoreDownAddNtworkFace.SetItemInfo;
begin
  RestoreDownData.NodeType := RestoreDownNodeType_Network;
  RestoreDownData.IsOnline := IsOnline;
end;

{ TRestoreDesFaceOffline }

constructor TRestoreDesFaceOffline.Create(_DesPcID: string);
begin
  DesPcID := _DesPcID;
end;

procedure TRestoreDesFaceOffline.Update;
var
  SelectNode, RemoveNode : PVirtualNode;
  SelectData : PVstRestoreData;
  SelectPcID : string;
begin
  inherited;

  SelectNode := VstRestore.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstRestore.GetNodeData( SelectNode );
    if SelectData.NodeType = RestoreNodeType_NetworkDes then
    begin
      SelectPcID := NetworkDesItemUtil.getPcID( SelectData.ItemID );
      if SelectPcID = DesPcID then
      begin
        RemoveNode := SelectNode;
        SelectNode := SelectNode.NextSibling;
        VstRestore.DeleteNode( RemoveNode );
        Continue;
      end;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TRestoreDownSetCompletedSizeFace }

procedure TRestoreDownSetCompletedSizeFace.SetCompletedSize( _CompletedSize : int64 );
begin
  CompletedSize := _CompletedSize;
end;

procedure TRestoreDownSetCompletedSizeFace.Update;
begin
  inherited;

  if not FindRestoreDownNode then
    Exit;
  RestoreDownData.CompletedSize := CompletedSize;
  RefreshPercentage;
  RefreshNode;
end;

{ TRestoreDownSetIsCompletedFace }

procedure TRestoreDownSetIsCompletedFace.SetIsCompleted( _IsCompleted : boolean );
begin
  IsCompleted := _IsCompleted;
end;

procedure TRestoreDownSetIsCompletedFace.Update;
begin
  inherited;

  if not FindRestoreDownNode then
    Exit;
  RestoreDownData.IsCompleted := IsCompleted;
  RefreshNode;

  if IsCompleted then
    frmMainForm.tbtnRestoreDownClear.Enabled := True;
end;

{ TRestoreDownSetIsRestoringFace }

procedure TRestoreDownSetIsRestoringFace.SetIsRestoring( _IsRestoring : boolean );
begin
  IsRestoring := _IsRestoring;
end;

procedure TRestoreDownSetIsRestoringFace.Update;
begin
  inherited;

  if not FindRestoreDownNode then
    Exit;
  RestoreDownData.IsRestoring := IsRestoring;
  RefreshNode;
end;



{ TRestoreDownStartFace }

procedure TRestoreDownStartFace.Update;
begin
  with frmMainForm do
  begin
    tbtnRestoreDownAgain.Enabled := False;
    tbtnRestoreStart.Visible := False;
    tbtnRestoreStop.Enabled := True;
    tbtnRestoreStop.Visible := True;
//    tbtnRestoreSpeed.Visible := True;
    tbtnRestoreDownSplit.Visible := True;
  end;
end;

{ TRestoreDownStopFace }

procedure TRestoreDownStopFace.Update;
begin
  with frmMainForm do
  begin
    tbtnRestoreDownSplit.Visible := False;
    tbtnRestoreStop.Visible := False;
    tbtnRestoreStart.Visible := False;
//    tbtnRestoreSpeed.Visible := False;
    tbtnRestoreDownAgain.Enabled := VstRestoreDown.SelectedCount > 0;
  end;
end;

{ TRestoreDownSetAnalyzeCountFace }

procedure TRestoreDownSetAnalyzeCountFace.SetAnalyzeCount( _AnalyzeCount : integer );
begin
  AnalyzeCount := _AnalyzeCount;
end;

procedure TRestoreDownSetAnalyzeCountFace.Update;
begin
  inherited;

  if not FindRestoreDownNode then
    Exit;
  RestoreDownData.AnalyzeCount := AnalyzeCount;
  RefreshNode;
end;

{ TShareDownErrorAddFace }

procedure TRestoreDownErrorAddFace.SetErrorStatus(_ErrorStatus: string);
begin
  ErrorStatus := _ErrorStatus;
end;

procedure TRestoreDownErrorAddFace.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TRestoreDownErrorAddFace.SetSpaceInfo(_FileSize,
  _CompletedSpace: Int64);
begin
  FileSize := _FileSize;
  CompletedSpace := _CompletedSpace;
end;

procedure TRestoreDownErrorAddFace.Update;
var
  ErrorNode : PVirtualNode;
  ErrorData : PVstRestoreDownData;
begin
  inherited;

  if not FindRestoreDownNode then
    Exit;

  ErrorNode := VstRestoreDown.AddChild( RestoreDownNode );
  ErrorData := VstRestoreDown.GetNodeData( ErrorNode );
  ErrorData.RestorePath := FilePath;
  ErrorData.FileSize := FileSize;
  ErrorData.Percentage := MyPercentage.getPercent( CompletedSpace, FileSize );
  ErrorData.NodeType := RestoreDownNodeType_Error;
  ErrorData.NodeStatus := ErrorStatus;
  ErrorData.MainIcon := MyIcon.getIconByFileExt( FilePath );

  VstRestoreDown.Expanded[ RestoreDownNode ] := True;
end;

{ TShareDownErrorClearFace }

procedure TRestoreDownErrorClearFace.Update;
begin
  inherited;

  if not FindRestoreDownNode then
    Exit;

  VstRestoreDown.DeleteChildren( RestoreDownNode );
end;

{ TRestoreDownSetIsDesBusyFace }

procedure TRestoreDownSetIsDesBusyFace.SetIsDesBusy(_IsIsDesBusy: boolean);
begin
  IsDesBusy := _IsIsDesBusy;
end;

procedure TRestoreDownSetIsDesBusyFace.Update;
begin
  inherited;

  if not FindRestoreDownNode then
    Exit;
  RestoreDownData.IsDesBusy := IsDesBusy;
  RefreshNode;
end;


{ TRestoreDownSetIsConnectedFace }

procedure TRestoreDownSetIsConnectedFace.SetIsConnected(_IsConnected: boolean);
begin
  IsConnected := _IsConnected;
end;

procedure TRestoreDownSetIsConnectedFace.Update;
begin
  inherited;

  if not FindRestoreDownNode then
    Exit;
  RestoreDownData.IsConnected := IsConnected;
  RefreshNode;
end;

{ TRestoreDownPauseFace }

procedure TRestoreDownPauseFace.Update;
begin
  with frmMainForm do
  begin
    tbtnRestoreStop.Visible := False;
    tbtnRestoreStart.Visible := True;
  end;
end;

{ TShareExplorerStartFace }

procedure TRestoreExplorerStartFace.Update;
begin
  inherited;

  tmrStatus.Enabled := True;
  plStatus.Visible := False;
end;

{ TShareExplorerStatusChangeFace }

procedure TRestoreExplorerStatusChangeFace.Update;
begin
  tmrStatus := frmRestoreExplorer.tmrExploring;
  pbStatus := frmRestoreExplorer.pbExplorer;
  plStatus := frmRestoreExplorer.plStatus;
  lbStatus := frmRestoreExplorer.lbStatus;
end;

{ TShareExplorerStopFace }

procedure TRestoreExplorerStopFace.Update;
begin
  inherited;

  tmrStatus.Enabled := False;
  pbStatus.Visible := False;
  pbStatus.Style := pbstNormal;
  frmRestoreExplorer.vstExplorer.Refresh;
end;

{ TShareExplorerBusyFace }

procedure TRestoreExplorerBusyFace.Update;
begin
  inherited;

  lbStatus.Caption := ExplorerStatus_Busy;
  plStatus.Visible := True;
end;

{ TShareExplorerNotConnFace }

procedure TRestoreExplorerNotConnFace.Update;
begin
  inherited;

  lbStatus.Caption := ExplorerStatus_NotConn;
  plStatus.Visible := True;
end;

{ TRestoreDesAddFace }

function TRestoreDesAddFace.getLastLocalNode: PVirtualNode;
var
  SelectNode : PVirtualNode;
  SelectData : PVstRestoreData;
begin
  Result := nil;
  SelectNode := VstRestore.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstRestore.GetNodeData( SelectNode );
    if SelectData.NodeType = RestoreNodeType_LocalDes then
      Result := SelectNode;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TRestoreDesAddFace.Update;
begin
  inherited;

    // 不存在，则创建
  if not FindRestoreDesNode then
  begin
    CreateDesNode;
    RestoreDesNode.NodeHeight := 28;

    RestoreDesData := VstRestore.GetNodeData( RestoreDesNode );
    RestoreDesData.ItemID := DesItemID;
  end;

    // 设置节点信息
  SetDesNodeInfo;

    // 隐藏没有文件的
  VstRestore.IsVisible[ RestoreDesNode ] := RestoreFaceReadUtil.ReadIsExistVisibleChild( RestoreDesNode );
end;

{ TRestoreSpeedLimitFace }

procedure TRestoreSpeedLimitFace.SetIsLimit(_IsLimit: Boolean);
begin
  IsLimit := _IsLimit;
end;

procedure TRestoreSpeedLimitFace.SetLimitSpeed(_LimitSpeed: Int64);
begin
  LimitSpeed := _LimitSpeed;
end;

procedure TRestoreSpeedLimitFace.Update;
var
  ShowType, ShowStr : string;
begin
  ShowType := 'Network Restore Speed: ';
  if not IsLimit then
    ShowStr := 'Unlimited'
  else
    ShowStr := 'Limit to ' + MySpeed.getSpeedStr( LimitSpeed );

  ShowStr := MyHtmlHintShowStr.getHintRow( ShowType, ShowStr );
  frmMainForm.tbtnRestoreSpeed.Hint := ShowStr;
end;

{ TRestoreDeleteExplorerChangeFace }

procedure TRestoreDeleteExplorerChangeFace.Update;
begin
  VstRestoreDeleteExplorer := frmRestoreExplorer.vstDeleteFile;
end;

{ TRestoreDeleteExplorerAddFace }

procedure TRestoreDeleteExplorerAddFace.SetIsFile( _IsFile : boolean );
begin
  IsFile := _IsFile;
end;

function TRestoreDeleteExplorerAddFace.AddEditionNode: PVirtualNode;
var
  FirstChild, SelectNode, UpNode : PVirtualNode;
  ChildData, FirstChildData, SelectData : PVsTRestoreDeleteExplorerData;
begin
    // 添加默认的版本节点
  ChildData := VstRestoreDeleteExplorer.GetNodeData( ChildNode );
  if ChildNode.ChildCount = 0 then
  begin
    FirstChild := VstRestoreDeleteExplorer.AddChild( ChildNode );
    FirstChildData := VstRestoreDeleteExplorer.GetNodeData( FirstChild );

    FirstChildData.FilePath := ChildData.FilePath;
    FirstChildData.IsFile := ChildData.IsFile;
    FirstChildData.FileSize := ChildData.FileSize;
    FirstChildData.FileTime := ChildData.FileTime;
    FirstChildData.ShowName := ChildData.ShowName;
    FirstChildData.ShowIcon := ChildData.ShowIcon;
    FirstChildData.EditionNum := ChildData.EditionNum;
  end;

    // 找出当前版本的位置
  UpNode := nil;
  SelectNode := ChildNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstRestoreDeleteExplorer.GetNodeData( SelectNode );
    if EditionNum < SelectData.EditionNum then
    begin
      UpNode := SelectNode;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;

    // 添加节点位置
  if Assigned( UpNode ) then
    Result := VstRestoreDeleteExplorer.InsertNode( UpNode, amInsertBefore )
  else
    Result := VstRestoreDeleteExplorer.AddChild( ChildNode );

    // 添加了一个最新的节点
  if EditionNum < ChildData.EditionNum then
  begin
    ChildData.FileSize := FileSize;
    ChildData.FileTime := TTimeZone.Local.ToLocalTime( FileTime );
    ChildData.FileSize := FileSize;
    ChildData.EditionNum := EditionNum;
  end;
end;

function TRestoreDeleteExplorerAddFace.AddFileNode: PVirtualNode;
var
  FileName : string;
  SelectNode, UpNode : PVirtualNode;
  SelectData : PVsTRestoreDeleteExplorerData;
begin
  FileName := ExtractFileName( FilePath );

    // 寻找位置
  UpNode := nil;
  SelectNode := ParentNode.LastChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstRestoreDeleteExplorer.GetNodeData( SelectNode );
    if ( not SelectData.IsFile ) or ( CompareText( FileName, SelectData.ShowName ) > 0 ) then
    begin
      UpNode := SelectNode;
      Break;
    end;
    SelectNode := SelectNode.PrevSibling;
  end;

    // 找到位置
  if Assigned( UpNode ) then
    Result := VstRestoreDeleteExplorer.InsertNode( UpNode, amInsertAfter )
  else  // 添加到第一个位置
    Result := VstRestoreDeleteExplorer.InsertNode( ParentNode, amAddChildFirst );
end;


function TRestoreDeleteExplorerAddFace.AddFolderNode: PVirtualNode;
var
  FolderName : string;
  SelectNode, DownNode : PVirtualNode;
  SelectData : PVsTRestoreDeleteExplorerData;
begin
  FolderName := ExtractFileName( FilePath );

    // 寻找位置
  DownNode := nil;
  SelectNode := ParentNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstRestoreDeleteExplorer.GetNodeData( SelectNode );
    if ( SelectData.IsFile ) or ( CompareText( SelectData.ShowName, FolderName ) > 0 ) then
    begin
      DownNode := SelectNode;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;

    // 找到位置
  if Assigned( DownNode ) then
    Result := VstRestoreDeleteExplorer.InsertNode( DownNode, amInsertBefore )
  else  // 添加到第一个位置
    Result := VstRestoreDeleteExplorer.AddChild( ParentNode );
end;

function TRestoreDeleteExplorerAddFace.AddNode: PVirtualNode;
begin
  if not IsFile then  // 添加目录
    Result := AddFolderNode
  else
  if not FindChildNode then  // 添加文件
    Result := AddFileNode
  else   // 添加文件版本
    Result := AddEditionNode;
end;

function TRestoreDeleteExplorerAddFace.AddRootFileNode: PVirtualNode;
var
  SelectNode, UpNode : PVirtualNode;
  SelectData : PVsTRestoreDeleteExplorerData;
begin
    // 寻找位置
  UpNode := nil;
  SelectNode := VstRestoreDeleteExplorer.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstRestoreDeleteExplorer.GetNodeData( SelectNode );
    if EditionNum < SelectData.EditionNum then
    begin
      UpNode := SelectNode;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;

    // 找到位置
  if Assigned( UpNode ) then
    Result := VstRestoreDeleteExplorer.InsertNode( UpNode, amInsertBefore )
  else  // 添加到第一个位置
    Result := VstRestoreDeleteExplorer.AddChild( VstRestoreDeleteExplorer.RootNode );
end;

constructor TRestoreDeleteExplorerAddFace.Create(_FilePath: string);
begin
  FilePath := _FilePath;
end;

function TRestoreDeleteExplorerAddFace.FindChildNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVsTRestoreDeleteExplorerData;
begin
  Result := False;

  SelectNode := ParentNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstRestoreDeleteExplorer.GetNodeData( SelectNode );

      // 找到父节点
    if SelectData.FilePath = FilePath then
    begin
      ChildNode := SelectNode;
      Result := True;
      Break;
    end;

    SelectNode := SelectNode.NextSibling;
  end;
end;

function TRestoreDeleteExplorerAddFace.FindParentNode: Boolean;
var
  ParentPath : string;
  SelectNode : PVirtualNode;
  SelectData : PVsTRestoreDeleteExplorerData;
begin
  Result := False;
  ParentPath := ExtractFileDir( FilePath );

  SelectNode := VstRestoreDeleteExplorer.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstRestoreDeleteExplorer.GetNodeData( SelectNode );

      // 找到父节点
    if SelectData.FilePath = ParentPath then
    begin
      ParentNode := SelectNode;
      Result := True;
      Break;
    end
    else  // 找到上层节点
    if MyMatchMask.CheckChild( ParentPath, SelectData.FilePath ) then
      SelectNode := SelectNode.FirstChild
    else  // 下一个节点
      SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TRestoreDeleteExplorerAddFace.SetEditionNum(_EditionNum: Integer);
begin
  EditionNum := _EditionNum;
end;

procedure TRestoreDeleteExplorerAddFace.SetFileInfo( _FileSize : int64; _FileTime : TDateTime );
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TRestoreDeleteExplorerAddFace.Update;
var
  RestoreExplorerNode : PVirtualNode;
  RestoreExplorerData : PVsTRestoreDeleteExplorerData;
  IconIndex : Integer;
begin
  inherited;

    // 寻找父节点
  if not FindParentNode then
    RestoreExplorerNode := AddRootFileNode
  else
    RestoreExplorerNode := AddNode;

    // 文件/目录
  if not IsFile then
  begin
    VstRestoreDeleteExplorer.HasChildren[ RestoreExplorerNode ] := True;
    IconIndex := MyShellIconUtil.getFolderIcon;
  end
  else
    IconIndex := MyIcon.getIconByFileExt( FilePath );

    // 初始化数据信息
  RestoreExplorerData := VstRestoreDeleteExplorer.GetNodeData( RestoreExplorerNode );
  RestoreExplorerData.FilePath := FilePath;
  RestoreExplorerData.IsFile := IsFile;
  RestoreExplorerData.FileSize := FileSize;
  RestoreExplorerData.FileTime := TTimeZone.Local.ToLocalTime( FileTime );
  RestoreExplorerData.EditionNum := EditionNum;
  RestoreExplorerData.ShowName := ExtractFileName( FilePath );;
  RestoreExplorerData.ShowIcon := IconIndex;

    // 展开父节点
  if Assigned( ParentNode ) then
  begin
    ParentNode.ChildCount := ParentNode.ChildCount + 1;
    if not VstRestoreDeleteExplorer.Expanded[ ParentNode ] then
      VstRestoreDeleteExplorer.Expanded[ ParentNode ] := True;
  end;
end;

{ TShareExplorerStatusChangeFace }

procedure TRestoreDeleteExplorerStatusChangeFace.Update;
begin
  tmrStatus := frmRestoreExplorer.tmrExploringDeleted;
  pbStatus := frmRestoreExplorer.pbExplorerDelete;
  plStatus := frmRestoreExplorer.plDeletedStatus;
  lbStatus := frmRestoreExplorer.lbDeleteStatus;
end;

{ TShareExplorerStopFace }

procedure TRestoreDeleteExplorerStopFace.Update;
begin
  inherited;

  tmrStatus.Enabled := False;
  pbStatus.Visible := False;
  pbStatus.Style := pbstNormal;
  frmRestoreExplorer.vstDeleteFile.Refresh;
end;

{ TShareExplorerBusyFace }

procedure TRestoreDeleteExplorerBusyFace.Update;
begin
  inherited;

  lbStatus.Caption := ExplorerStatus_Busy;
  plStatus.Visible := True;
end;

{ TShareExplorerNotConnFace }

procedure TRestoreDeleteExplorerNotConnFace.Update;
begin
  inherited;

  lbStatus.Caption := ExplorerStatus_NotConn;
  plStatus.Visible := True;
end;

{ TShareExplorerStartFace }

procedure TRestoreDeleteExplorerStartFace.Update;
begin
  inherited;

  tmrStatus.Enabled := True;
  plStatus.Visible := False;
end;

{ TRestoreSearchChangeFace }

procedure TRestoreSearchChangeFace.Update;
begin
  VstRestoreSearch := frmRestoreExplorer.vstSearchFile;
end;

{ TRestoreSearchAddFace }

procedure TRestoreSearchAddFace.Update;
var
  MainIcon, RecycleIcon : Integer;
  RestoreSearchNode : PVirtualNode;
  RestoreSearchData : PVstRestoreSearchData;
begin
    // 搜索取消
  if not RestoreSearch_IsShow then
    Exit;

  inherited;

    // 选择图标
  if IsFile then
    MainIcon := MyIcon.getIconByFileExt( FilePath )
  else
    MainIcon := MyShellIconUtil.getFolderIcon;

    // 添加节点
  ParentNode := VstRestoreSearch.RootNode;
  RestoreSearchNode := AddNode;

      // 删除的图标
  if IsDeleted and ( RestoreSearchNode.Parent = VstRestoreSearch.RootNode ) then
    RecycleIcon := MyShellTransActionIconUtil.getRecycle
  else
    RecycleIcon := -1;

  RestoreSearchData := VstRestoreSearch.GetNodeData( RestoreSearchNode );
  RestoreSearchData.FilePath := FilePath;
  RestoreSearchData.IsFile := IsFile;
  RestoreSearchData.IsDeleted := IsDeleted;
  RestoreSearchData.FileSize := FileSize;
  RestoreSearchData.FileTime := TTimeZone.Local.ToLocalTime( FileTime );
  RestoreSearchData.ShowName := ExtractFileName( FilePath );
  RestoreSearchData.ShowIcon := MainIcon;
  RestoreSearchData.RecycleIcon := RecycleIcon;
  RestoreSearchData.EditionNum := EditionNum;

    // 可以展开
  if not IsFile then
    VstRestoreSearch.HasChildren[ RestoreSearchNode ] := True;
end;

{ TShareExplorerStartFace }

procedure TRestoreSearchStartFace.Update;
begin
  inherited;

  tmrStatus.Enabled := True;
  plStatus.Visible := False;

  btnSearch.Visible := False;
  btnStop.Enabled := True;
  btnStop.Visible := True;
  RestoreSearch_IsShow := True;
end;

{ TShareExplorerStatusChangeFace }

procedure TRestoreSearchStatusChangeFace.Update;
begin
  tmrStatus := frmRestoreExplorer.tmrSearching;
  pbStatus := frmRestoreExplorer.pbSearch;

  plStatus := frmRestoreExplorer.plSearchStatus;
  lbStatus := frmRestoreExplorer.lbSearchStatus;

  btnSearch := frmRestoreExplorer.btnSearch;
  btnStop := frmRestoreExplorer.btnStopSearch;
end;

{ TShareExplorerStopFace }

procedure TRestoreSearchStopFace.Update;
begin
  inherited;

  tmrStatus.Enabled := False;
  pbStatus.Visible := False;
  pbStatus.Style := pbstNormal;

  btnStop.Visible := False;
  btnSearch.Visible := True;
  RestoreSearch_IsShow := False;

  frmRestoreExplorer.vstSearchFile.Refresh;
end;

{ TShareExplorerBusyFace }

procedure TRestoreSearchBusyFace.Update;
begin
  inherited;

  plStatus.Visible := True;
  lbStatus.Caption := ExplorerStatus_Busy;
end;

{ TShareExplorerNotConnFace }

procedure TRestoreSearchNotConnFace.Update;
begin
  inherited;

  plStatus.Visible := True;
  lbStatus.Caption := ExplorerStatus_NotConn;
end;

{ TRestoreSearchExplorerAddFace }

function TRestoreSearchExplorerAddFace.FindParentNode: Boolean;
var
  ParentPath : string;
  SelectNode : PVirtualNode;
  SelectData : PVstRestoreSearchData;
begin
  Result := False;
  ParentPath := ExtractFileDir( FilePath );

  SelectNode := VstRestoreSearch.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstRestoreSearch.GetNodeData( SelectNode );

      // 文件类型不同
    if ( SelectData.IsDeleted <> IsDeleted ) then
    begin
      SelectNode := SelectNode.NextSibling;
      Continue;
    end;

      // 找到父节点
    if SelectData.FilePath = ParentPath then
    begin
      ParentNode := SelectNode;
      Result := True;
      Break;
    end
    else  // 找到上层节点
    if MyMatchMask.CheckChild( ParentPath, SelectData.FilePath ) and
       VstRestoreSearch.Expanded[ SelectNode ]
    then
      SelectNode := SelectNode.FirstChild
    else  // 下一个节点
      SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TRestoreSearchExplorerAddFace.RemoveRootExist;
var
  SelectNode : PVirtualNode;
  SelectData : PVstRestoreSearchData;
begin
  SelectNode := VstRestoreSearch.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstRestoreSearch.GetNodeData( SelectNode );

      // 删除同名的根节点
    if not SelectData.IsFile and ( SelectData.FilePath = FilePath ) and
       ( SelectData.IsDeleted = IsDeleted )
    then
    begin
      VstRestoreSearch.DeleteNode( SelectNode );
      Break;
    end
    else  // 下一个节点
      SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TRestoreSearchExplorerAddFace.Update;
var
  RestoreExplorerNode : PVirtualNode;
  RestoreExplorerData, ParentData : PVstRestoreSearchData;
  ShowName : string;
begin
  inherited;

    // 寻找父节点
  ShowName := ExtractFileName( FilePath );
  if not FindParentNode then
  begin
    ParentNode := VstRestoreSearch.RootNode; // 添加到根节点
    ShowName := FilePath;
    RestoreExplorerNode := VstRestoreSearch.AddChild( ParentNode );
  end
  else
  begin
    RestoreExplorerNode := AddNode;
    ParentData := VstRestoreSearch.GetNodeData( ParentNode );
  end;

  if not IsFile then
    VstRestoreSearch.HasChildren[ RestoreExplorerNode ] := True;
  RestoreExplorerData := VstRestoreSearch.GetNodeData( RestoreExplorerNode );
  RestoreExplorerData.FilePath := FilePath;
  RestoreExplorerData.IsFile := IsFile;
  RestoreExplorerData.IsDeleted := IsDeleted;
  RestoreExplorerData.FileSize := FileSize;
  RestoreExplorerData.FileTime := TTimeZone.Local.ToLocalTime( FileTime );
  RestoreExplorerData.ShowName := ShowName;
  RestoreExplorerData.RecycleIcon := -1;
  RestoreExplorerData.EditionNum := EditionNum;
  if IsFile then
    RestoreExplorerData.ShowIcon := MyIcon.getIconByFileExt( FilePath )
  else
    RestoreExplorerData.ShowIcon := MyShellIconUtil.getFolderIcon;
  ParentNode.ChildCount := ParentNode.ChildCount + 1;
  if not VstRestoreSearch.Expanded[ ParentNode ] then
    VstRestoreSearch.Expanded[ ParentNode ] := True;

    // 删除存在的根节点
  RemoveRootExist;
end;

{ TFrmRestorePcFilterChange }

procedure TFrmRestorePcFilterChange.Update;
begin
  vstRestorePcFilter := frmRestorePcFilter.vstGroupPc;
end;

{ TFrmRestorePcFilterClear }

procedure TFrmRestorePcFilterClear.Update;
begin
  inherited;
  vstRestorePcFilter.Clear;
end;

{ TFrmRestorePcFilterWrite }

constructor TFrmRestorePcFilterWrite.Create(_PcID: string);
begin
  PcID := _PcID;
end;

function TFrmRestorePcFilterWrite.FindRestorePcFilterNode: Boolean;
var
  SelectNode : PVirtualNode;
  NodeData : PRestorePcFilterData;
begin
  Result := False;

  SelectNode := vstRestorePcFilter.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstRestorePcFilter.GetNodeData( SelectNode );
    if NodeData.PcID = PcID then
    begin
      Result := True;
      RestorePcFilterNode := SelectNode;
      RestorePcFilterData := NodeData;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TFrmRestorePcFilterAdd }

procedure TFrmRestorePcFilterAdd.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TFrmRestorePcFilterAdd.Update;
begin
  inherited;

  if not FindRestorePcFilterNode then
  begin
    RestorePcFilterNode := vstRestorePcFilter.AddChild( vstRestorePcFilter.RootNode );
    vstRestorePcFilter.CheckType[ RestorePcFilterNode ] := ctTriStateCheckBox;
    if frmRestorePcFilter.getIsChecked( PcID ) then
      vstRestorePcFilter.CheckState[ RestorePcFilterNode ] := csCheckedNormal;

    RestorePcFilterData := vstRestorePcFilter.GetNodeData( RestorePcFilterNode );
    RestorePcFilterData.PcID := PcID;
    RestorePcFilterData.MainIcon := 1;
  end;
  RestorePcFilterData.PcName := PcName;
end;

{ TRestoreSearchAddBaseFace }

function TRestoreSearchAddBaseFace.AddDeletedFileNode: PVirtualNode;
var
  FileName : string;
  SelectNode, UpNode : PVirtualNode;
  SelectData : PVstRestoreSearchData;
begin
  FileName := ExtractFileName( FilePath );

    // 寻找位置
  UpNode := nil;
  SelectNode := ParentNode.LastChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstRestoreSearch.GetNodeData( SelectNode );
    if not SelectData.IsDeleted or not SelectData.IsFile or ( CompareText( FileName, SelectData.ShowName ) > 0 ) then
    begin
      UpNode := SelectNode;
      Break;
    end;
    SelectNode := SelectNode.PrevSibling;
  end;

    // 找到位置
  if Assigned( UpNode ) then
    Result := VstRestoreSearch.InsertNode( UpNode, amInsertAfter )
  else  // 添加到第一个位置
    Result := VstRestoreSearch.InsertNode( ParentNode, amAddChildFirst );
end;

function TRestoreSearchAddBaseFace.AddDeletedFolderNode: PVirtualNode;
var
  FileName : string;
  SelectNode, UpNode : PVirtualNode;
  SelectData : PVstRestoreSearchData;
begin
  FileName := ExtractFileName( FilePath );

    // 寻找位置
  UpNode := nil;
  SelectNode := ParentNode.LastChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstRestoreSearch.GetNodeData( SelectNode );
    if not SelectData.IsDeleted or ( not SelectData.IsFile and ( CompareText( FileName, SelectData.ShowName ) > 0 ) ) then
    begin
      UpNode := SelectNode;
      Break;
    end;
    SelectNode := SelectNode.PrevSibling;
  end;

    // 找到位置
  if Assigned( UpNode ) then
    Result := VstRestoreSearch.InsertNode( UpNode, amInsertAfter )
  else  // 添加到第一个位置
    Result := VstRestoreSearch.InsertNode( ParentNode, amAddChildFirst );
end;

function TRestoreSearchAddBaseFace.AddEditionNode: PVirtualNode;
var
  FirstChild, SelectNode, UpNode : PVirtualNode;
  ChildData, FirstChildData, SelectData : PVstRestoreSearchData;
begin
    // 添加默认的版本节点
  ChildData := VstRestoreSearch.GetNodeData( ChildNode );
  if ChildNode.ChildCount = 0 then
  begin
    FirstChild := VstRestoreSearch.AddChild( ChildNode );
    FirstChildData := VstRestoreSearch.GetNodeData( FirstChild );

    FirstChildData.FilePath := ChildData.FilePath;
    FirstChildData.IsFile := ChildData.IsFile;
    FirstChildData.FileSize := ChildData.FileSize;
    FirstChildData.FileTime := ChildData.FileTime;
    FirstChildData.ShowName := ChildData.ShowName;
    FirstChildData.ShowIcon := ChildData.ShowIcon;
    FirstChildData.RecycleIcon := -1;
    FirstChildData.EditionNum := ChildData.EditionNum;
    FirstChildData.IsDeleted := True;
  end;

    // 找出当前版本的位置
  UpNode := nil;
  SelectNode := ChildNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstRestoreSearch.GetNodeData( SelectNode );
    if EditionNum < SelectData.EditionNum then
    begin
      UpNode := SelectNode;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;

    // 添加节点位置
  if Assigned( UpNode ) then
    Result := VstRestoreSearch.InsertNode( UpNode, amInsertBefore )
  else
    Result := VstRestoreSearch.AddChild( ChildNode );

    // 添加了一个最新的节点
  if EditionNum < ChildData.EditionNum then
  begin
    ChildData.FileSize := FileSize;
    ChildData.FileTime := TTimeZone.Local.ToLocalTime( FileTime );
    ChildData.FileSize := FileSize;
    ChildData.EditionNum := EditionNum;
  end;
end;

function TRestoreSearchAddBaseFace.AddFileNode: PVirtualNode;
var
  FileName : string;
  SelectNode, UpNode : PVirtualNode;
  SelectData : PVstRestoreSearchData;
begin
  FileName := ExtractFileName( FilePath );

    // 寻找位置
  UpNode := nil;
  SelectNode := ParentNode.LastChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstRestoreSearch.GetNodeData( SelectNode );
    if not SelectData.IsFile or ( CompareText( FileName, SelectData.ShowName ) > 0 ) then
    begin
      UpNode := SelectNode;
      Break;
    end;
    SelectNode := SelectNode.PrevSibling;
  end;

    // 找到位置
  if Assigned( UpNode ) then
    Result := VstRestoreSearch.InsertNode( UpNode, amInsertAfter )
  else  // 添加到第一个位置
    Result := VstRestoreSearch.InsertNode( ParentNode, amAddChildFirst );
end;

function TRestoreSearchAddBaseFace.AddFolderNode: PVirtualNode;
var
  FolderName : string;
  SelectNode, DownNode : PVirtualNode;
  SelectData : PVstRestoreSearchData;
begin
  FolderName := ExtractFileName( FilePath );

    // 寻找位置
  DownNode := nil;
  SelectNode := ParentNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstRestoreSearch.GetNodeData( SelectNode );
    if SelectData.IsFile or ( CompareText( SelectData.ShowName, FolderName ) > 0 ) then
    begin
      DownNode := SelectNode;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;

    // 找到位置
  if Assigned( DownNode ) then
    Result := VstRestoreSearch.InsertNode( DownNode, amInsertBefore )
  else  // 添加到第一个位置
    Result := VstRestoreSearch.AddChild( ParentNode );
end;

function TRestoreSearchAddBaseFace.AddNode: PVirtualNode;
begin
    // 普通文件
  if not IsDeleted then
  begin
    if IsFile then
      Result := AddFileNode
    else
      Result := AddFolderNode;
  end
  else  // 删除目录
  if not IsFile then
    Result := AddDeletedFolderNode
  else  // 删除文件
  if FindDeletedFileNode then
    Result := AddEditionNode
  else
    Result := AddDeletedFileNode;
end;

constructor TRestoreSearchAddBaseFace.Create(_FilePath: string);
begin
  FilePath := _FilePath;
end;

function TRestoreSearchAddBaseFace.FindDeletedFileNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstRestoreSearchData;
begin
  Result := False;

  SelectNode := ParentNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstRestoreSearch.GetNodeData( SelectNode );

      // 找到父节点
    if SelectData.IsDeleted and SelectData.IsFile and ( SelectData.FilePath = FilePath ) then
    begin
      ChildNode := SelectNode;
      Result := True;
      Break;
    end;

    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TRestoreSearchAddBaseFace.SetFileInfo(_FileSize: int64;
  _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TRestoreSearchAddBaseFace.SetDeletedInfo(_IsDeleted: boolean;
  _EditionNum : Integer);
begin
  IsDeleted := _IsDeleted;
  EditionNum := _EditionNum;
end;

procedure TRestoreSearchAddBaseFace.SetIsFile(_IsFile: boolean);
begin
  IsFile := _IsFile;
end;

{ TRestoreExplorerAddFaceBase }

function TRestoreExplorerAddFace.AddFileNode: PVirtualNode;
var
  FileName : string;
  SelectNode, UpNode : PVirtualNode;
  SelectData : PVstRestoreExplorerData;
begin
  FileName := ExtractFileName( FilePath );

    // 寻找位置
  UpNode := nil;
  SelectNode := ParentNode.LastChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstRestoreExplorer.GetNodeData( SelectNode );
    if ( not SelectData.IsFile ) or ( CompareText( FileName, SelectData.ShowName ) > 0 ) then
    begin
      UpNode := SelectNode;
      Break;
    end;
    SelectNode := SelectNode.PrevSibling;
  end;

    // 找到位置
  if Assigned( UpNode ) then
    Result := VstRestoreExplorer.InsertNode( UpNode, amInsertAfter )
  else  // 添加到第一个位置
    Result := VstRestoreExplorer.InsertNode( ParentNode, amAddChildFirst );
end;

function TRestoreExplorerAddFace.AddFolderNode: PVirtualNode;
var
  FolderName : string;
  SelectNode, DownNode : PVirtualNode;
  SelectData : PVstRestoreExplorerData;
begin
  FolderName := ExtractFileName( FilePath );

    // 寻找位置
  DownNode := nil;
  SelectNode := ParentNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstRestoreExplorer.GetNodeData( SelectNode );
    if ( SelectData.IsFile ) or ( CompareText( SelectData.ShowName, FolderName ) > 0 ) then
    begin
      DownNode := SelectNode;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;

    // 找到位置
  if Assigned( DownNode ) then
    Result := VstRestoreExplorer.InsertNode( DownNode, amInsertBefore )
  else  // 添加到第一个位置
    Result := VstRestoreExplorer.AddChild( ParentNode );
end;

function TRestoreExplorerAddFace.AddNode: PVirtualNode;
begin
  if IsFile then
    Result := AddFileNode
  else
    Result := AddFolderNode;
end;

constructor TRestoreExplorerAddFace.Create(_FilePath: string);
begin
  FilePath := _FilePath;
end;

function TRestoreExplorerAddFace.FindParentNode: Boolean;
var
  ParentPath : string;
  SelectNode : PVirtualNode;
  SelectData : PVstRestoreExplorerData;
begin
  Result := False;
  ParentPath := ExtractFileDir( FilePath );

  SelectNode := VstRestoreExplorer.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstRestoreExplorer.GetNodeData( SelectNode );

      // 找到父节点
    if SelectData.FilePath = ParentPath then
    begin
      ParentNode := SelectNode;
      Result := True;
      Break;
    end
    else  // 找到上层节点
    if MyMatchMask.CheckChild( ParentPath, SelectData.FilePath ) then
      SelectNode := SelectNode.FirstChild
    else  // 下一个节点
      SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TRestoreExplorerAddFace.SetFileInfo(_FileSize: int64;
  _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TRestoreExplorerAddFace.SetIsFile(_IsFile: boolean);
begin
  IsFile := _IsFile;
end;

procedure TRestoreExplorerAddFace.Update;
var
  RestoreExplorerNode : PVirtualNode;
  RestoreExplorerData : PVstRestoreExplorerData;
  IconIndex : Integer;
begin
  inherited;

    // 父节点不存在
  if not FindParentNode then
    RestoreExplorerNode := VstRestoreExplorer.AddChild( VstRestoreExplorer.RootNode )
  else
    RestoreExplorerNode := AddNode;

    // 文件/ 目录
  if not IsFile then
  begin
    VstRestoreExplorer.HasChildren[ RestoreExplorerNode ] := True;  // 目录节点，设置可展开
    IconIndex := MyShellIconUtil.getFolderIcon;
  end
  else
    IconIndex := MyIcon.getIconByFileExt( FilePath );


    // 初始化数据
  RestoreExplorerData := VstRestoreExplorer.GetNodeData( RestoreExplorerNode );
  RestoreExplorerData.FilePath := FilePath;
  RestoreExplorerData.IsFile := IsFile;
  RestoreExplorerData.IsDeleted := False;
  RestoreExplorerData.FileSize := FileSize;
  RestoreExplorerData.FileTime := TTimeZone.Local.ToLocalTime( FileTime );
  RestoreExplorerData.ShowName := ExtractFileName( FilePath );
  RestoreExplorerData.ShowIcon := IconIndex;

    // 展开父节点
  if Assigned( ParentNode )  then
  begin
    ParentNode.ChildCount := ParentNode.ChildCount + 1;
    if not VstRestoreExplorer.Expanded[ ParentNode ] then
      VstRestoreExplorer.Expanded[ ParentNode ] := True;
  end;
end;

{ TRestoreFilePreviewPictureFace }

procedure TRestorePreviewPictureFace.ShowPreview;
var
  Img : TImage;
  GdiGraphics: TGPGraphics;
  GdiBrush : TGPSolidBrush;
  GdiStream : IStream;
  GdiImg : TGPImage;
  InpuParams : TInputParams;
  OutputParams : TOutputParams;
begin
  Img := frmPreView.ilPicture;
  Img.Picture := nil;

    // 画纸
  GdiGraphics := TGPGraphics.Create( Img.Canvas.Handle );

    // 填充背景颜色
  GdiBrush := TGPSolidBrush.Create( MakeColor( 255, 255, 255 ) );
  GdiGraphics.FillRectangle( GdiBrush, 0, 0, Img.Width, Img.Height );
  GdiBrush.Free;

    // 创建图片
  PreviewStream.Position := 0;
  GdiStream := TStreamAdapter.Create( PreviewStream );
  GdiImg := TGPImage.Create( GdiStream );

    // 画图片
  InpuParams.SourceWidth := GdiImg.GetWidth;
  InpuParams.SourceHeigh := GdiImg.GetHeight;
  InpuParams.DesWidth := Img.Width;
  InpuParams.DesHeigh := Img.Height;
  InpuParams.IsKeepSpace := True;
  MyPictureUtil.FindPreviewPoint( InpuParams, OutputParams );
  GdiGraphics.DrawImage( GdiImg, OutputParams.ShowX, OutputParams.ShowY, OutputParams.ShowWidth, OutputParams.ShowHeigh );
  GdiImg.Free;

  GdiGraphics.Free;
end;

{ TRestoreFilePreviewTextFace }

procedure TRestorePreviewTextFace.ShowCannotPreview;
var
  SharePreivewNotPreviewFace : TSharePreivewNotPreviewFace;
begin
  SharePreivewNotPreviewFace := TSharePreivewNotPreviewFace.Create;
  SharePreivewNotPreviewFace.Update;
  SharePreivewNotPreviewFace.Free;
end;

procedure TRestorePreviewTextFace.ShowPreview;
begin
  frmPreView.mmoPreview.Lines.Clear;
  PreviewStream.Position := 0;
  frmPreView.mmoPreview.Lines.LoadFromStream( PreviewStream );
  if Length( AnsiString( frmPreView.mmoPreview.Text ) ) < ( PreviewStream.Size div 2 ) then
  begin
    frmPreView.mmoPreview.Lines.Clear;
    ShowCannotPreview;
  end;
end;


{ TRestoreFilePreviewWordFace }

procedure TRestorePreviewWordFace.SetWordText(_WordText: string);
begin
  WordText := _WordText;
end;

procedure TRestorePreviewWordFace.ShowPreview;
begin
  frmPreView.reDoc.Text := WordText;
end;

{ TRestorePreviewShowFace }

procedure TRestorePreviewShowFace.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TRestorePreviewShowFace.ShowPreview;
begin

end;

procedure TRestorePreviewShowFace.Update;
begin
  if frmPreView.FilePath = FilePath then
    ShowPreview;
end;

{ TRestorePreviewStreamShowFace }

destructor TRestorePreviewStreamShowFace.Destroy;
begin
  PreviewStream.Free;
  inherited;
end;

procedure TRestorePreviewStreamShowFace.SetPreviewStream(_PreviewStream: TStream);
begin
  PreviewStream := _PreviewStream;
end;

{ TRestoreFilePreviewExcelFace }

procedure TRestorePreviewExcelFace.IniColumnShow(ColumnCount: Integer);
var
  ColWidth, i : Integer;
begin
  ColWidth := ( LvExcel.Width - 20 ) div ColumnCount;
  for i := 1 to ColumnCount do
    with LvExcel.Columns.Add do
    begin
      Caption := 'Column ' + IntToStr( i );
      Width := ColWidth;
    end;
end;

procedure TRestorePreviewExcelFace.SetExcelText(_ExcelText: string);
begin
  ExcelText := _ExcelText;
end;

procedure TRestorePreviewExcelFace.ShowPreview;
var
  RowList : TStringList;
  i: Integer;
begin
  LvExcel := frmPreView.LvExcel;

  RowList := MySplitStr.getList( ExcelText, SplitExcel_Row );
  if RowList.Count > 0 then
    IniColumnShow( StrToIntDef( RowList[0], 0 ) );
  for i := 1 to RowList.Count - 1 do
    ShowRow( RowList[i] );
  RowList.Free;
end;


procedure TRestorePreviewExcelFace.ShowRow(RowStr: string);
var
  ColumnList : TStringList;
  i: Integer;
  NewItem : TListItem;
  s : string;
begin
  NewItem := LvExcel.Items.Add;
  ColumnList := MySplitStr.getList( RowStr, SplitExcel_Col );
  for i := 0 to ColumnList.Count - 1 do
  begin
    s := ColumnList[i];
    if s = SplitExcel_Empt then // 空字符串
      s := '';
    if i = 0 then
      NewItem.Caption := s
    else
      NewItem.SubItems.Add( s );
  end;
  ColumnList.Free;
end;


{ TRestoreFilePreviewZipFace }

procedure TRestorePreviewZipFace.SetZipText(_ZipText: string);
begin
  ZipText := _ZipText;
end;

procedure TRestorePreviewZipFace.ShowFile(FileInfoStr: string);
var
  FileInfoList : TStringList;
  FileName, FileSizeStr : string;
  FileSize : Int64;
  TimeStr : string;
  FileTime : TDateTime;
  IsFolder : Boolean;
  MainIcon : Integer;
begin
  FileInfoList := MySplitStr.getList( FileInfoStr, SplitCompress_FileInfo );
  if FileInfoList.Count = 4 then
  begin
    FileName := FileInfoList[0];
    FileSize := StrToInt64Def( FileInfoList[1], 0 );
    TimeStr := FileInfoList[2];
    FileTime := MyRegionUtil.ReadLocalTime( TimeStr );
    IsFolder := StrToBoolDef( FileInfoList[3], True );

    if IsFolder and ( FileSize <= 0 ) then
    begin
      MainIcon := MyShellIconUtil.getFolderIcon;
      FileSizeStr := '';
    end
    else
    begin
      MainIcon := MyIcon.getIconByFileExt( FileName );
      FileSizeStr := MySize.getFileSizeStr( FileSize );
    end;

    with LvZip.Items.Add do
    begin
      Caption := FileName;
      SubItems.Add( FileSizeStr );
      SubItems.Add( DateTimeToStr( FileTime ) );
      ImageIndex := MainIcon;
    end;
  end;
  FileInfoList.Free;
end;

procedure TRestorePreviewZipFace.ShowPreview;
var
  FileList : TStringList;
  i: Integer;
begin
  LvZip := frmPreView.LvZip;
  FileList := MySplitStr.getList( ZipText, SplitCompress_FileList );
  for i := 0 to FileList.Count - 1 do
    ShowFile( FileList[i] );
  FileList.Free;
end;

{ TRestoreFilePreviewExeFace }

procedure TRestorePreviewExeDetailFace.SetExeText(_ExeText: string);
begin
  ExeText := _ExeText;
end;

procedure TRestorePreviewExeDetailFace.ShowPreview;
var
  ExeStrList : TStringList;
  Version : string;
  Description : string;
  Copyright : string;
  i: Integer;
  s : string;
begin
  ExeStrList := MySplitStr.getList( ExeText, SplitExe_FileInfo );
  for i := 0 to ExeStrList.Count - 1 do
    if ExeStrList[i] = SplitExe_Empty then
      ExeStrList[i] := '';
  if ExeStrList.Count = 3 then
  begin
    Version := ExeStrList[0];
    Description := ExeStrList[1];
    Copyright := ExeStrList[2];
  end;

  with frmPreView do
  begin
    s := 'File version=' + Version;
    veExe.Strings.Add( s );
    s := 'Description=' + Description;
    veExe.Strings.Add( s );
    s := 'Copyright=' + Copyright;
    veExe.Strings.Add( s );
  end;

  ExeStrList.Free;
end;


{ TRestoreFilePreviewMusicFace }

procedure TRestorePreviewMusicFace.SetMusicText(_MusicText: string);
begin
  MusicText := _MusicText;
end;

procedure TRestorePreviewMusicFace.ShowPreview;
var
  MusicList : TStringList;
  TitleStr, ArtStr : string;
  AblumStr, YearStr : string;
  i: Integer;
  s : string;
begin
  MusicList := MySplitStr.getList( MusicText, SplitMusic_FileInfo );
  for i := 0 to MusicList.Count - 1 do
    if MusicList[i] = SplitMusic_Empty then
      MusicList[i] := '';
  if MusicList.Count = 4 then
  begin
    TitleStr := MusicList[0];
    ArtStr := MusicList[1];
    AblumStr := MusicList[2];
    YearStr := MusicList[3];
  end;
  MusicList.Free;

  with frmPreView do
  begin
    s := 'Title=' + TitleStr;
    veMusic.Strings.Add( s );
    s := 'Artist=' + ArtStr;
    veMusic.Strings.Add( s );
    s := 'Album Title=' + AblumStr;
    veMusic.Strings.Add( s );
    s := 'Year=' + YearStr;
    veMusic.Strings.Add( s );
  end;
end;

{ TRestorePreviewExeIconFace }

procedure TRestorePreviewExeIconFace.ShowPreview;
var
  ImgExe : TImage;
  c : Integer;
  red, green, blue : Byte;
  img : TGPImage;
  GdiStream : IStream;
  GdiGraphics: TGPGraphics;
  GdiBrush : TGPSolidBrush;
begin
  ImgExe := frmPreView.ImgPreview;
  ImgExe.Picture := nil;

  GdiGraphics := TGPGraphics.Create( ImgExe.Canvas.Handle ) ;

    // 填充背景色
  c := ColorToRGB( frmPreView.plPreviewTitle.Color );
  red := GetRed( c );
  green := GetGreen( c );
  blue := GetBlue( c );
  GdiBrush := TGPSolidBrush.Create( MakeColor( red, green, blue ) );
  GdiGraphics.FillRectangle( GdiBrush, 0, 0, imgExe.Width, imgExe.Height );
  GdiBrush.Free;

    // 画图标
  GdiStream := TStreamAdapter.Create( PreviewStream );
  img := TGPImage.Create( GdiStream );
  GdiGraphics.DrawImage( img, 0, 0, imgExe.Width, imgExe.Height );
  img.Free;

  GdiGraphics.Free;
end;

{ TRestoreFilePreviewStopFace }

procedure TRestoreFilePreviewStopFace.Update;
begin
  frmPreView.tmrProgress.Enabled := False;
  frmPreView.pbPreview.Visible := False;
  frmPreView.pbPreview.Style := pbstNormal;
end;

{ TRestoreFilePreviewStartFace }

procedure TRestoreFilePreviewStartFace.Update;
begin
  frmPreView.tmrProgress.Enabled := True;
  frmPreView.plStatus.Visible := False;
end;

{ TSharePreivewBusyFace }

procedure TSharePreivewBusyFace.Update;
begin
  inherited;
  frmPreView.lbStatus.Caption := ExplorerStatus_Busy;
  frmPreView.plStatus.Visible := True;
end;

{ TSharePreivewNotConnFace }

procedure TSharePreivewNotConnFace.Update;
begin
  inherited;
  frmPreView.lbStatus.Caption := ExplorerStatus_NotConn;
  frmPreView.plStatus.Visible := True;
end;


{ TSharePreivewNotPreviewFace }

procedure TSharePreivewNotPreviewFace.Update;
begin
  inherited;
  frmPreView.lbStatus.Caption := ExplorerStatus_NotPreview;
  frmPreView.plStatus.Visible := True;
end;

{ TSharePreivewNotPreviewEncryptedFace }

procedure TSharePreivewNotPreviewEncryptedFace.Update;
begin
  inherited;
  frmPreView.lbStatus.Caption := ExplorerStatus_Encrypted;
  frmPreView.plStatus.Visible := True;
end;

{ TShareExplorerHistoryChangeFace }

procedure TRestoreExplorerHistoryChangeFace.Update;
begin
  PmExplorerHistory := frmMainForm.pmRestoreHistory;
end;

{ TShareExplorerHistoryAddFace }

constructor TRestoreExplorerHistoryAddFace.Create(_OwnerName, _FilePath: string);
begin
  OwnerName := _OwnerName;
  FilePath := _FilePath;
end;

procedure TRestoreExplorerHistoryAddFace.Update;
var
  ShowStr : string;
  mi : TMenuItem;
begin
  inherited;

  ShowStr := OwnerName + ' ( ' + FilePath + ' )';

  mi := TMenuItem.Create(nil);
  mi.Caption := ShowStr;
  mi.ImageIndex := -1;
  mi.OnClick := frmMainForm.ShareExplorerHistoryClick;
  PmExplorerHistory.Items.Insert( 0, mi );
end;

{ TShareExplorerHistoryRemoveFace }

constructor TRestoreExplorerHistoryRemoveFace.Create(_RemoveIndex: Integer);
begin
  RemoveIndex := _RemoveIndex;
end;

procedure TRestoreExplorerHistoryRemoveFace.Update;
var
  mi : TMenuItem;
begin
  inherited;

  if PmExplorerHistory.Items.Count <= RemoveIndex then
    Exit;

  mi := PmExplorerHistory.Items[ RemoveIndex ];
  PmExplorerHistory.Items.Delete( RemoveIndex );
  mi.free;
end;

end.
