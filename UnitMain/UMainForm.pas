unit UMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, ExtCtrls, StdCtrls,
  ShellCtrls, xmldom, XMLIntf, auHTTP, auAutoUpgrader, XPMan, ImgList,
  Menus, msxmldom, XMLDoc, RzPanel, RzButton, RzStatus, VirtualTrees, IniFiles,
  FileCtrl,
  ActnList, XPStyleActnCtrls, ActnMan,
  AppEvnts, ActiveX, ShellAPI, TlHelp32,
  Spin, Buttons, ShlObj, UIconUtil, Math,
  DateUtils, CommCtrl, RzShellDialogs, uDebugLock, RzPrgres,
   RzTabs, Grids, ValEdit, ActnCtrls, UFileBaseInfo,
  VCLTee.Series, VCLTee.TeEngine, VCLTee.TeeProcs, UMyUtil, VCLTee.Chart, htmlhint, uDebug,Generics.Collections;

const
  hfck = wm_user + $1000;
  AppName_FileCloud = 'BackupCow_Server';

type

  TfrmMainForm = class(TForm)
    ilStatusBar: TImageList;
    ilTbMf16: TImageList;
    ilTbCoolBar: TImageList;
    pmHelp: TPopupMenu;
    miRegister1: TMenuItem;
    miAbout1: TMenuItem;
    xpmnfst1: TXPManifest;
    Upgrade1: TMenuItem;
    plMainForm: TPanel;
    N1: TMenuItem;
    N2: TMenuItem;
    ContactUs1: TMenuItem;
    HomePage1: TMenuItem;
    ilBackupSetting: TImageList;
    ilTbMf: TImageList;
    ilTbFs16: TImageList;
    ilTbFs16Gray: TImageList;
    ilNw16: TImageList;
    pmTrayIcon: TPopupMenu;
    miShow1: TMenuItem;
    miOpenFolder4: TMenuItem;
    Exit1: TMenuItem;
    SbMainForm: TRzStatusBar;
    sbNetworkMode: TRzGlyphStatus;
    sbDownSpeed: TRzGlyphStatus;
    sbUpSpeed: TRzGlyphStatus;
    sbEdition: TRzGlyphStatus;
    sbMyStatus: TRzGlyphStatus;
    ilNw: TImageList;
    tbMainForm: TRzToolbar;
    tbtnRestorePage: TRzToolButton;
    tbtnSettings: TRzToolButton;
    tbtnHelp: TRzToolButton;
    tbtnExit: TRzToolButton;
    ilShellFile: TImageList;
    OnlineManual1: TMenuItem;
    auApp: TauAutoUpgrader;
    iShellBackupStatus: TImageList;
    ilShellTransAction: TImageList;
    tiApp: TTrayIcon;
    ilTbNw: TImageList;
    ilTbNwGray: TImageList;
    Log1: TMenuItem;
    ilTb24: TImageList;
    ilTb24Gray: TImageList;
    PcMain: TRzPageControl;
    tsBackup: TRzTabSheet;
    tsRestore: TRzTabSheet;
    XmlDoc: TXMLDocument;
    plRestore: TPanel;
    vstRestoreShow: TVirtualStringTree;
    tbRestore: TToolBar;
    tbtnRestoreSelected: TToolButton;
    plRestoreTitle: TPanel;
    slRestoreDown: TSplitter;
    plBackup: TPanel;
    plBackupTitle: TPanel;
    Label19: TLabel;
    lbNotAvailable: TLabel;
    tbBackup: TToolBar;
    tbtnBackupAll: TToolButton;
    tbtnBackupSelected: TToolButton;
    tbtnBackupAdd: TToolButton;
    tbtnBackupRemove: TToolButton;
    tbtnBackupExplorer: TToolButton;
    tbtnBackupOptions: TToolButton;
    VstBackup: TVirtualStringTree;
    plBackupBoard: TPanel;
    ToolButton1: TToolButton;
    plRestoreDown: TPanel;
    vstRestoreDown: TVirtualStringTree;
    tbRestoreDown: TToolBar;
    tbtnRestoreDownExplorer: TToolButton;
    tbtnRestoreDownRemove: TToolButton;
    tbtnRestoreDownClear: TToolButton;
    tbtnRestoreDownAgain: TToolButton;
    tbtnBackupStop: TToolButton;
    HTMLHint1: THTMLHint;
    tbtnBackupShowLog: TToolButton;
    tbtnRestoreStop: TToolButton;
    tbtnBackupNetwork: TToolButton;
    PmNetwork: TPopupMenu;
    miLocalNetwork: TMenuItem;
    N4: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    JoinaGroup1: TMenuItem;
    ConnecttoaComputer1: TMenuItem;
    Settings1: TMenuItem;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    pcNetworkWarnning: TRzPageControl;
    tsNotConn: TRzTabSheet;
    tsNoPc: TRzTabSheet;
    NetworkStatus1: TMenuItem;
    tbtnBackupStart: TToolButton;
    ToolButton5: TToolButton;
    tbtnRestoreDownSplit: TToolButton;
    tbtnRestoreDownRun: TToolButton;
    tbtnRestoreStart: TToolButton;
    plMyDownloadTitle: TPanel;
    btnHide: TButton;
    ilFolder: TImageList;
    ToolButton2: TToolButton;
    tbtnRestoreRemove: TToolButton;
    tbtnRestoreExplorer: TToolButton;
    tbtnBackupSpeed: TToolButton;
    tbtnRestoreSpeed: TToolButton;
    tbtnBackupCollapse: TToolButton;
    tbtnBackupExpandAll: TToolButton;
    ToolButton6: TToolButton;
    tbtnRestoreCollapse: TToolButton;
    tbtnRestoreExpand: TToolButton;
    ToolButton9: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    BuyNow1: TMenuItem;
    PcRemoteWarinning: TRzPageControl;
    tsGroupNotEixst: TRzTabSheet;
    tsGroupPasswordError: TRzTabSheet;
    tsIpError: TRzTabSheet;
    tsNotConnPc: TRzTabSheet;
    Image5: TImage;
    lbNotConnPcTitle: TLabel;
    lbRemotePcNotConn: TLabel;
    lbNetworkConn: TLabel;
    btnConnNow: TButton;
    tsSecurityIDError: TRzTabSheet;
    Image1: TImage;
    lbGroupNotExist: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Button1: TButton;
    btnSignupGroup: TButton;
    Image2: TImage;
    lbGroupPassword: TLabel;
    Label4: TLabel;
    btnInputAgain: TButton;
    Image3: TImage;
    lbIpError: TLabel;
    Label5: TLabel;
    lbIpErrorTime: TLabel;
    Button2: TButton;
    btnInputDomain: TButton;
    Label1: TLabel;
    Button3: TButton;
    Image4: TImage;
    lbConnPcSecurityID: TLabel;
    Label7: TLabel;
    Button4: TButton;
    Panel1: TPanel;
    btnNotPcClose: TButton;
    Label18: TLabel;
    Panel2: TPanel;
    Label6: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Image6: TImage;
    Label10: TLabel;
    Image7: TImage;
    btnAddLocalItem: TButton;
    Label11: TLabel;
    tbtnBackupPcFilter: TToolButton;
    pmBackupPcFilter: TPopupMenu;
    OnlineComputers1: TMenuItem;
    GroupComputers1: TMenuItem;
    AllComputers1: TMenuItem;
    tbtnRestorePcFilter: TToolButton;
    pmRestorePcFilter: TPopupMenu;
    ShowMyFiles1: TMenuItem;
    ShowGroupFiles1: TMenuItem;
    ShowAllFiles1: TMenuItem;
    tsEditionNotMatch: TRzTabSheet;
    plNewEditionShow: TPanel;
    lbOldProgram: TLabel;
    Label13: TLabel;
    Image8: TImage;
    btnEditionDetails: TButton;
    btnJoinAGroup: TButton;
    pcEditionNotMatch: TRzPageControl;
    tsNewEdition: TRzTabSheet;
    tsOldEdition: TRzTabSheet;
    Image9: TImage;
    Label14: TLabel;
    Label15: TLabel;
    btnCheck4Upgrade: TButton;
    Button5: TButton;
    tmrRefreshHint: TTimer;
    pmRestoreHistory: TPopupMenu;
    tsAccount: TRzTabSheet;
    plAccount: TPanel;
    vstAccount: TVirtualStringTree;
    ilAccount: TImageList;
    sbInternetIp: TRzGlyphStatus;
    sbLanIp: TRzGlyphStatus;
    tbAccount: TToolBar;
    tbtnAccountRemove: TToolButton;
    Register1: TMenuItem;
    procedure tbtnMainFormClick(Sender: TObject);
    procedure tbtnExitClick(Sender: TObject);
    procedure LvNetworkDeletion(Sender: TObject; Item: TListItem);
    procedure lvSearchFileDeletion(Sender: TObject; Item: TListItem);
    procedure lvCloudPcDeletion(Sender: TObject; Item: TListItem);
    procedure lvFileStatusDeletion(Sender: TObject; Item: TListItem);
    procedure tbtnSettingsClick(Sender: TObject);
    procedure Upgrade1Click(Sender: TObject);
    procedure ContactUs1Click(Sender: TObject);
    procedure HomePage1Click(Sender: TObject);
    procedure miAbout1Click(Sender: TObject);
    procedure OnlineManual1Click(Sender: TObject);
    procedure miRegister1Click(Sender: TObject);
    procedure lvCloudTotalDeletion(Sender: TObject; Item: TListItem);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Exit1Click(Sender: TObject);
    procedure miShow1Click(Sender: TObject);
    procedure lvSearchDownloadDeletion(Sender: TObject; Item: TListItem);
    procedure btnConnNowClick(Sender: TObject);
    procedure tiAppClick(Sender: TObject);
    procedure lvMyDestinationDeletion(Sender: TObject; Item: TListItem);
    procedure lvMyCloudPcDeletion(Sender: TObject; Item: TListItem);
    procedure lvMyFileReceiveDeletion(Sender: TObject; Item: TListItem);
    procedure lvLocalBackupSourceDeletion(Sender: TObject; Item: TListItem);
    procedure Enteragroup1Click(Sender: TObject);
    procedure Connectacomputer1Click(Sender: TObject);
    procedure BackupCow1Click(Sender: TObject);
    procedure VstBackupGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure VstBackupGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure VstBackupDragOver(Sender: TBaseVirtualTree; Source: TObject;
      Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: Integer; var Accept: Boolean);
    procedure VstBackupFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure VstBackupChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure tbtnBackupRemoveClick(Sender: TObject);
    procedure tbtnBackupSelectedClick(Sender: TObject);
    procedure tbtnBackupExplorerClick(Sender: TObject);
    procedure vstRestoreShowGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure vstRestoreShowGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstRestoreShowChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure FormCreate(Sender: TObject);
    procedure tbtnBackupAddClick(Sender: TObject);
    procedure tbtnRestoreSelectedClick(Sender: TObject);
    procedure vstRestoreDownGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: String);
    procedure vstRestoreDownGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstRestoreDownMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure vstRestoreDownChange(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure tbtnRestoreDownExplorerClick(Sender: TObject);
    procedure tbtnRestoreDownRemoveClick(Sender: TObject);
    procedure tbtnRestoreDownAgainClick(Sender: TObject);
    procedure tbtnBackupAllClick(Sender: TObject);
    procedure tbtnBackupStopClick(Sender: TObject);
    procedure tbtnBackupOptionsClick(Sender: TObject);
    procedure vstRestoreShowMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure tbtnBackupShowLogClick(Sender: TObject);
    procedure tbtnRestoreStopClick(Sender: TObject);
    procedure tbtnBackupNetworkClick(Sender: TObject);
    procedure Settings1Click(Sender: TObject);
    procedure JoinaGroup1Click(Sender: TObject);
    procedure ConnecttoaComputer1Click(Sender: TObject);
    procedure miLocalNetworkClick(Sender: TObject);
    procedure NetworkStatus1Click(Sender: TObject);
    procedure tbtnBackupStartClick(Sender: TObject);
    procedure vstRestoreShowPaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType);
    procedure tbtnRestoreDownRunClick(Sender: TObject);
    procedure tbtnRestoreStartClick(Sender: TObject);
    procedure btnHideClick(Sender: TObject);
    procedure tbtnRestoreDownClearClick(Sender: TObject);
    procedure tbtnRestoreRemoveClick(Sender: TObject);
    procedure tbtnRestoreExplorerClick(Sender: TObject);
    procedure tbtnBackupSpeedClick(Sender: TObject);
    procedure tbtnRestoreSpeedClick(Sender: TObject);
    procedure VstBackupMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure VstBackupPaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType);
    procedure VstBackupDblClick(Sender: TObject);
    procedure VstBackupKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure vstRestoreShowDblClick(Sender: TObject);
    procedure vstRestoreShowKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure vstRestoreDownDblClick(Sender: TObject);
    procedure vstRestoreDownKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tbtnBackupCollapseClick(Sender: TObject);
    procedure tbtnBackupExpandAllClick(Sender: TObject);
    procedure tbtnRestoreCollapseClick(Sender: TObject);
    procedure tbtnRestoreExpandClick(Sender: TObject);
    procedure btnNotPcCloseClick(Sender: TObject);
    procedure tbtnBackupPageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BuyNow1Click(Sender: TObject);
    procedure btnSignupGroupClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnInputAgainClick(Sender: TObject);
    procedure btnInputDomainClick(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure sbMyStatusMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pcNetworkWarnningPageChange(Sender: TObject);
    procedure btnAddLocalItemClick(Sender: TObject);
    procedure tbtnBackupPcFilterClick(Sender: TObject);
    procedure SendPcFilterClick(Sender: TObject);
    procedure GroupComputers1Click(Sender: TObject);
    procedure tbtnRestorePcFilterClick(Sender: TObject);
    procedure RestorePcFilter(Sender: TObject);
    procedure ShowGroupFiles1Click(Sender: TObject);
    procedure btnEditionDetailsClick(Sender: TObject);
    procedure tbtnHelpMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnCheck4UpgradeClick(Sender: TObject);
    procedure tmrRefreshHintTimer(Sender: TObject);
    procedure vstAccountGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstAccountGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstAccountChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure tbtnAccountRemoveClick(Sender: TObject);
    procedure sbEditionClick(Sender: TObject);
    procedure Register1Click(Sender: TObject);
  public
    procedure ShareExplorerHistoryClick(Sender: TObject);
    procedure DropFiles(var Msg: TMessage); message WM_DROPFILES;
    procedure WMQueryEndSession(var Message: TMessage); message WM_QUERYENDSESSION;
    procedure createparams(var params: tcreateparams); override;
    procedure restorerequest(var Msg: TMessage); message hfck;
    function getIsShowHint : Boolean;
    procedure OpenRefreshHint;
  private
    procedure MainFormIni;
    procedure LoadMainFormIni;
    procedure BindToolbar;
    procedure BindSysItemIcon;
    procedure BindVstData;
    procedure SaveMainFormIni;
  private // 托盘
    IsHideForm : Boolean;
    procedure ShowMainForm;
    procedure HideMainForm;
  public
    procedure CreateBackupCow;
    procedure AppUpgrade;
  end;

  MainFormUtil = class
  public
    class function getIsShowRestoreExplorer( SelectNode : PVirtualNode ): Boolean;
    class function getIsRestoreExplorerPath( SelectNode : PVirtualNode ): string;
  public
    class procedure EnterMainPage( MainPage : integer );
  end;

{$Region ' Pc 过滤 ' }

  PcFilterUtil = class
  public
    class procedure SetBackupPcFilter( SelectIndex : Integer );
    class function getBackupPcFilter : Integer;
    class function getBackupPcIsShow( Node : PVirtualNode ): Boolean;
    class procedure RefreshBackupShowNode;
  public
    class procedure SetRestorePcFilter( SelectIndex : Integer );
    class function getRestorePcFilter : Integer;
    class function getRestorePcIsShow( Node : PVirtualNode ): Boolean;
    class procedure RefreshRestoreShowNode;
  end;

{$EndRegion}

{$Region ' 备份文件操作 ' }

    // 选择备份路径
  TSelectBackupItemHandle = class
  private
    DesItemList : TStringList;
    SourceItemList : TStringList;
  public
    constructor Create( _DesItemList : TStringList );
    procedure SetSourceItemList( _SourceItemList : TStringList );
    procedure Update;
  private
    procedure AddNewSelectedItem;
  end;

    // 重设 备份 Options
  TResetBackupOptionHandle = class
  public
    NewBackupConfigInfo : TBackupConfigInfo;
    OldBackupConfigInfo : TBackupConfigInfo;
  public
    DesItemID, BackupPath : string;
    IsBackupNow : Boolean;
  public
    constructor Create( _NewBackupConfigInfo : TBackupConfigInfo );
    procedure SetOldBackupConfigInfo( _OldBackupConfigInfo : TBackupConfigInfo );
    procedure SetItemInfo( _DesItemID, _BackupPath : string );
    procedure Update;
  private
    procedure ResetIsBackupNow;
    procedure ResetAutoSync;
    procedure ResetIsEncrypt;
    procedure ResetIsSaveDeleted;
    procedure ResetIncludeFilter;
    procedure ResetExcludeFilter;
  end;

    // 设置备份路径属性
  TBackupItemOptionsHandle = class
  private
    DesItemID, BackupPath : string;
    IsFile : Boolean;
  public
    constructor Create( _DesItemID, _BackupPath : string );
    procedure SetIsFile( _IsFile : Boolean );
    procedure Update;
  end;

{$EndRegion}

{$Region ' 恢复文件操作 ' }

    // 恢复文件
  TRestoreAllFileHandle = class
  private
    vstRestoreShow : TVirtualStringTree;
  public
    procedure Update;
  private
    function FileHandle( Node : PVirtualNode ): Boolean;
    function FolderHandle( Node : PVirtualNode ): Boolean;
  end;

    // 立刻恢复
  TRestoreNowSelectHandle = class
  public
    Node : PVirtualNode;
  private
    vstRestoreShow : TVirtualStringTree;
    RestoreTo, Password : string;
  public
    constructor Create( _Node : PVirtualNode );
    function Update: Boolean;
  private
    function getPassword : Boolean;
    function getRestoreTo : Boolean;
    procedure AddRestoreDown;
  end;

    // 恢复下载信息
  TRestoreDownInfo = class
  public
    RestorePath : string;
    IsFile, IsDeleted : Boolean;
    EditionNum : Integer;
    SavePath : string;
  public
    constructor Create( _RestorePath : string );
    procedure SetIsFile( _IsFile : Boolean );
    procedure SetDeletedInfo( _IsDeleted : Boolean; _EditionNum : Integer );
    procedure SetSavePath( _SavePath : string );
  end;
  TRestoreDownList = class( TObjectList<TRestoreDownInfo> )end;

    // Explorer
  TRestoreExplorerSelectHandle = class
  private
    SelectNode : PVirtualNode;
  private
    RestorePath, OwnerID, OwnerName : string;
    RestoreFrom, RestoreFromName : string;
    IsFile, IsLocalRestore, IsSaveDeleted, IsEncrypted : Boolean;
    PasswordMD5, PasswordHint : string;
    FileSize : Int64;
  private
    Password, RestoreTo : string;
    RestoreDownList : TRestoreDownList;
    FileEditionList : TFileEditionList;
  public
    constructor Create( _SelectNode : PVirtualNode );
    function Update: Boolean;
    destructor Destroy; override;
  private
    procedure FindRestoreInfo;
    function getPassword : Boolean;
    function getRestorePathList: Boolean;
    function getRestoreTo : Boolean;
    procedure AddRestoreDown;
  private        // Restore To 方法
    function getSameRestore( ParentPath : string; StartIndex : Integer ): TIntList;
    function getSameRestoreName( SameList : TIntList ): TStringList;
    procedure SetSameRestore( SavePath : string; SameList : TIntList );
  private
    procedure AddFileEdition( FolderPath : string );
  end;

{$EndRegion}

{$Region ' 拖动文件 ' }

    // 拖动 备份文件处理
  TAddDropBackupFile = class
  private
    DesItemList : TStringList;
    FilePathList: TStringList;
  public
    constructor Create( _FilePathList: TStringList );
    procedure Update;
    destructor Destroy; override;
  private
    procedure FindDropDesItem;
  end;

  // 拖动文件处理
  TDropFileHandle = class
  public
    Msg: TMessage;
  public
    DropFileType: string;
    FilePathList: TStringList;
  public
    constructor Create(_Msg: TMessage);
    procedure Update;
    destructor Destroy; override;
  private
    procedure FindFilePathList;
    procedure FindDropFileType;
  private
    procedure AddFileBackup;
  private
    procedure ResetStatus;
  end;

{$EndRegion}

{$Region ' 停止程序 ' }

  TStopAppThread = class( TDebugThread )
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  end;

{$EndRegion}

const // 拖动文件
  DropFileType_Backup = 'Backup';

  DropFile_Hint = 'Drag and drop files or folders here from Windows Explorer';
  DropFolder_Hint = 'Drag and drop folders here from Windows Explorer';

var // 拖动文件
  DragFile_LastX : Integer = 0;
  DragFile_LastY : Integer = 0;

const
  MainPage_Backup = 0;
  MainPage_Restore = 1;
  MainPage_Account = 2;

const
  RestoreShowTag_MyFile = 1;
  RestoreShowTag_AllFile = 2;

const
  VstBackup_BackupName = 0;
  VstBackup_FileCount = 1;
  VstBackup_FileSize = 2;
  VstBackup_NextBackup = 3;
  VstBackup_Percentage = 4;
  VstBackup_Status = 5;

  VstRestore_RestoreName = 0;
  VstRestore_RestoreOwner = 1;
  VstRestore_FileCount = 2;
  VstRestore_FileSize = 3;
  VstRestore_LastBackupTime = 4;

  VstRestoreDown_RestorePath = 0;
  VstRestoreDown_Owner = 1;
  VstRestoreDown_FileCount = 2;
  VstRestoreDown_FileSize = 3;
  VstRestoreDown_Percentage = 4;
  VstRestoreDown_Status = 5;

const
  BackupPcFilter_Online = 'Online';
  BackupPcFilter_Group = 'Group';
  BackupPcFilter_All = 'All';
  ImgIndex_PcFilterSelect = 3;

const
  RestorePcFilter_MyPc = 'MyPc';
  RestorePcFilter_GroupPc = 'GroupPc';
  RestorePcFilter_All = 'AllPc';

const
  // NetworkMode Show Icon
  NetworkModeIcon_LAN = 1;
  NetworkModeIcon_Remote = 8;

const
  Time_ShowHint: Integer = 30000;

  // Network
  ShowForm_RestartNetwork = 'Are you sure to restart network?';


var // 应用程序
  App_IsExit: Boolean = True;
  Filter_BackupPc : string = BackupPcFilter_Online;
  Filter_RestorePc : string = RestorePcFilter_MyPc;

var
  frmMainForm: TfrmMainForm;

implementation

uses
  UFormUtil, UXmlUtil, UBackupCow,
  UMyBackupFaceInfo, UMyBackupApiInfo, UFrmSelectBackupItem, UMyBackupDataInfo, UBackupThread,
  UMyRestoreFaceInfo, UMyCloudDataInfo, UFormSelectRestore, UMyRestoreApiInfo, UFormRestoreExplorer,
  URestoreThread, UFormRegister, UMyBackupEventInfo,
  UNetworkFace, UNetworkControl,
  UMyNetPcInfo, UFormSetting, UMyUrl,
  UFormAbout, 
  UAppEditionInfo, URegisterInfoIO, UFormBackupPcFilter, UFormRestorePcFilter,
  USettingInfo, UAppSplitEdition,
  UFromEnterGroup, UFormConnPc, UFormBackupSpeedLimit, UFormRestoreSpeedLimit,
  UFormExitWarnning, UDebugForm, UNetworkStatus, UFormRemoveBackupConfirm, UFormEditionNotMatch,
  UFormFileSelect, UFormBackupLog, UFormRestoreDecrypt, UMyRegisterApiInfo;

{$R *.dfm}


procedure TfrmMainForm.AppUpgrade;
begin
  try
    auApp.InfoFileURL := MyProductUrl.AppUpgrade;
    auApp.CheckUpdate;
  except
  end;
end;

procedure TfrmMainForm.BindSysItemIcon;
begin
  VstBackup.Images := MyIcon.getSysIcon;
  vstRestoreShow.Images := MyIcon.getSysIcon;
  vstRestoreDown.Images := MyIcon.getSysIcon;
end;

procedure TfrmMainForm.BindToolbar;
begin
  VstBackup.PopupMenu := FormUtil.getPopMenu( tbBackup );
  vstRestoreShow.PopupMenu := FormUtil.getPopMenu( tbRestore );
  vstRestoreDown.PopupMenu := FormUtil.getPopMenu( tbRestoreDown );
  vstAccount.PopupMenu := FormUtil.getPopMenu( tbAccount );
end;

procedure TfrmMainForm.BindVstData;
begin
  VstBackup.NodeDataSize := SizeOf(TVstBackupData);
  vstRestoreShow.NodeDataSize := SizeOf(TVstRestoreData);
  vstRestoreDown.NodeDataSize := SizeOf(TVstRestoreDownData);
  vstAccount.NodeDataSize := SizeOf(TAccountData);
end;

procedure TfrmMainForm.miAbout1Click(Sender: TObject);
begin
  frmAbout.Show;
end;

procedure TfrmMainForm.miRegister1Click(Sender: TObject);
begin
  frmRegister.Show;
end;

procedure TfrmMainForm.miShow1Click(Sender: TObject);
begin
  if App_IsExit then
    Exit;

  ShowMainForm;
end;

procedure TfrmMainForm.NetworkStatus1Click(Sender: TObject);
begin
  frmNeworkStatus.Show;
end;

procedure TfrmMainForm.OnlineManual1Click(Sender: TObject);
begin
  MyInternetExplorer.OpenWeb(MyProductUrl.OnlineManual);
end;

procedure TfrmMainForm.OpenRefreshHint;
begin
  tmrRefreshHint.Enabled := False;
  tmrRefreshHint.Enabled := True;
end;

procedure TfrmMainForm.pcNetworkWarnningPageChange(Sender: TObject);
begin
  if pcNetworkWarnning.ActivePage = tsNoPc then
    plBackupBoard.Height := 200
  else
    plBackupBoard.Height := 115;
end;

procedure TfrmMainForm.Register1Click(Sender: TObject);
begin
  frmRegister.Show;
end;

procedure TfrmMainForm.RestorePcFilter(Sender: TObject);
var
  mi : TMenuItem;
  i, SendPcSelect: Integer;
begin
  mi := Sender as TMenuItem;
  SendPcSelect := -1;
  for i := 0 to pmRestorePcFilter.Items.Count - 1 do
    if pmRestorePcFilter.Items[i] = mi then
    begin
      SendPcSelect := i;
      Break;
    end;
  PcFilterUtil.SetRestorePcFilter( SendPcSelect );
end;

procedure TfrmMainForm.btnCheck4UpgradeClick(Sender: TObject);
begin
  auApp.ShowMessages := auApp.ShowMessages + [mNoUpdateAvailable];
  auApp.CheckUpdate;

  NetworkErrorStatusApi.HideError;
end;

procedure TfrmMainForm.btnConnNowClick(Sender: TObject);
begin
  NetworkPcApi.RestartNetwork;
end;

procedure TfrmMainForm.btnEditionDetailsClick(Sender: TObject);
begin
  frmEditonNotMatch.Show;
end;

var
  Height_MyDownload : Integer = 0;
procedure TfrmMainForm.btnHideClick(Sender: TObject);
var
  IsHide : Boolean;
begin
  try
    IsHide := btnHide.Tag = 0;
    slRestoreDown.Visible := not IsHide;
    if IsHide then
    begin
      btnHide.Caption := 'Show >>';
      Height_MyDownload := plRestoreDown.Height;
      plRestoreDown.Height := plMyDownloadTitle.Height;
      btnHide.Tag := 1;
    end
    else
    begin
      btnHide.Caption := '<< Hide';
      plRestoreDown.Height := Height_MyDownload;
      btnHide.Tag := 0;
    end;
  except
  end;
end;

procedure TfrmMainForm.btnInputAgainClick(Sender: TObject);
begin
  frmJoinGroup.ShowResetPassword( GroupError_Name );
end;

procedure TfrmMainForm.btnInputDomainClick(Sender: TObject);
begin
  frmConnComputer.ShowDnsError( ConnPcError_Domain, ConnPcError_Port );
end;

procedure TfrmMainForm.btnNotPcCloseClick(Sender: TObject);
begin
  NetworkErrorStatusApi.HideError;
end;

procedure TfrmMainForm.btnSignupGroupClick(Sender: TObject);
begin
  frmJoinGroup.ShowSignUpGroup( GroupError_Name );
end;

procedure TfrmMainForm.Button1Click(Sender: TObject);
begin
  frmJoinGroup.ShowJobaGroup;
end;

procedure TfrmMainForm.Button4Click(Sender: TObject);
begin
  frmSetting.ShowResetCloudID;
end;

procedure TfrmMainForm.btnAddLocalItemClick(Sender: TObject);
var
  DesItemList : TStringList;
  SourceItemList : TStringList;
  SelectNode : PVirtualNode;
  NodeData : PVstBackupData;
  SelectBackupItemHandle : TSelectBackupItemHandle;
begin
  DesItemList := TStringList.Create;
  SourceItemList := TStringList.Create;

    // 寻找选中的源
  SelectNode := VstBackup.RootNode.FirstChild;
  if Assigned( SelectNode ) then
  begin
    NodeData := VstBackup.GetNodeData( SelectNode );
    if NodeData.NodeType = BackupNodeType_LocalDes then
      DesItemList.Add( NodeData.ItemID );
  end;

    // 设置备份信息
  SelectBackupItemHandle := TSelectBackupItemHandle.Create( DesItemList );
  SelectBackupItemHandle.SetSourceItemList( SourceItemList );
  SelectBackupItemHandle.Update;
  SelectBackupItemHandle.Free;

  SourceItemList.Free;
  DesItemList.Free;
end;

procedure TfrmMainForm.BuyNow1Click(Sender: TObject);
begin
  MyInternetExplorer.OpenWeb( MyProductUrl.BuyNow );
end;

procedure TfrmMainForm.Connectacomputer1Click(Sender: TObject);
begin
  frmConnComputer.ShowConnToPc;
end;

procedure TfrmMainForm.ConnecttoaComputer1Click(Sender: TObject);
begin
  frmConnComputer.ShowConnToPc;
end;

procedure TfrmMainForm.ContactUs1Click(Sender: TObject);
begin
  MyInternetExplorer.OpenWeb(MyProductUrl.ContactUs);
end;

procedure TfrmMainForm.CreateBackupCow;
begin
  try
    AppSplitEditionUtl.StartSplit;
  except
  end;

  tiApp.Visible := True;

  try
    BackupCow := TBackupCow.Create;
  except
  end;
end;

procedure TfrmMainForm.createparams(var params: tcreateparams);
begin
  try
    inherited createparams(params);
    params.WinClassName := AppName_FileCloud;
  except
  end;
end;

procedure TfrmMainForm.DropFiles(var Msg: TMessage);
var
  DropFileHandle: TDropFileHandle;
begin
  try
    DropFileHandle := TDropFileHandle.Create(Msg);
    DropFileHandle.Update;
    DropFileHandle.Free;
  except
  end;
end;

procedure TfrmMainForm.Enteragroup1Click(Sender: TObject);
begin
  frmJoinGroup.ShowJobaGroup;
end;

procedure TfrmMainForm.Exit1Click(Sender: TObject);
begin
  if App_IsExit then
    Exit;

  tbtnExit.Click;
end;

procedure TfrmMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if not App_IsExit then
  begin
    CanClose := False;
    HideMainForm;
  end;
end;

procedure TfrmMainForm.FormCreate(Sender: TObject);
begin
  MainFormIni;
end;

function TfrmMainForm.getIsShowHint: Boolean;
begin
  Result := ( Self.WindowState = wsMinimized ) or( Self.IsHideForm ) and not App_IsExit;
end;

procedure TfrmMainForm.GroupComputers1Click(Sender: TObject);
begin
  if not frmSendPcFilter.getIsSelectPc then
    Exit;

  SendPcFilterClick( Sender );
end;

procedure TfrmMainForm.HideMainForm;
begin
  try
    ShowWindow(Self.Handle, SW_HIDE);
    IsHideForm := True;
  except
  end;
end;

procedure TfrmMainForm.HomePage1Click(Sender: TObject);
begin
  MyInternetExplorer.OpenWeb(MyProductUrl.Home);
end;

procedure TfrmMainForm.JoinaGroup1Click(Sender: TObject);
begin
  frmJoinGroup.ShowJobaGroup;
end;

procedure TfrmMainForm.BackupCow1Click(Sender: TObject);
begin
  MyInternetExplorer.OpenWeb( Url_BackuCowHome );
end;

procedure TfrmMainForm.LoadMainFormIni;
var
  iniFile: TIniFile;
  MainPage: Integer;
  BackupPcFilter, RestorePcFilter : Integer;
begin
  try
      // 读取配置信息
    iniFile := TIniFile.Create(MyIniFile.getIniFilePath);
    MainPage := iniFile.ReadInteger(frmMainForm.Name, PcMain.Name, -1);
    BackupPcFilter := iniFile.ReadInteger(frmMainForm.Name, pmBackupPcFilter.Name, 0 );
    RestorePcFilter := iniFile.ReadInteger(frmMainForm.Name, pmRestorePcFilter.Name, 0 );
    iniFile.Free;

      // 主界面页面
    MainFormUtil.EnterMainPage( MainPage );

      // 备份文件显示的 Items
    if ( BackupPcFilter < 0 ) or ( BackupPcFilter >= pmBackupPcFilter.Items.Count ) then  // 越界
      BackupPcFilter := 0;
    PcFilterUtil.SetBackupPcFilter( BackupPcFilter );

      // 显示的恢复 Pc
    if ( RestorePcFilter < 0 ) or ( RestorePcFilter >= pmRestorePcFilter.Items.Count ) then // 越界
      RestorePcFilter := 0;
    PcFilterUtil.SetRestorePcFilter( RestorePcFilter );
  except
  end;
end;

procedure TfrmMainForm.miLocalNetworkClick(Sender: TObject);
begin
  if miLocalNetwork.ImageIndex = -1 then
    NetworkModeApi.EnterLan
  else
  if MyMessageBox.ShowConfirm( ShowForm_RestartNetwork ) then
    NetworkModeApi.RestartNetwork;
end;

procedure TfrmMainForm.lvCloudPcDeletion(Sender: TObject; Item: TListItem);
var
  Data: TObject;
begin
  Data := Item.Data;
  Data.Free;
end;

procedure TfrmMainForm.lvCloudTotalDeletion(Sender: TObject; Item: TListItem);
var
  Data: TObject;
begin
  Data := Item.Data;
  Data.Free;
end;

procedure TfrmMainForm.lvFileStatusDeletion(Sender: TObject; Item: TListItem);
var
  Data: TObject;
begin
  Data := Item.Data;
  Data.Free;
end;

procedure TfrmMainForm.lvLocalBackupSourceDeletion(Sender: TObject;
  Item: TListItem);
var
  ItemData: TObject;
begin
  ItemData := Item.Data;
  ItemData.Free;
end;

procedure TfrmMainForm.lvMyCloudPcDeletion(Sender: TObject; Item: TListItem);
var
  ItemData: TObject;
begin
  ItemData := Item.Data;
  ItemData.Free;
end;

procedure TfrmMainForm.lvMyDestinationDeletion(Sender: TObject;
  Item: TListItem);
var
  ItemData: TObject;
begin
  ItemData := Item.Data;
  ItemData.Free;
end;

procedure TfrmMainForm.lvMyFileReceiveDeletion(Sender: TObject;
  Item: TListItem);
var
  ItemData: TObject;
begin
  ItemData := Item.Data;
  ItemData.Free;
end;

procedure TfrmMainForm.LvNetworkDeletion(Sender: TObject; Item: TListItem);
var
  Data: TObject;
begin
  Data := Item.Data;
  Data.Free;
end;

procedure TfrmMainForm.lvSearchDownloadDeletion(Sender: TObject;
  Item: TListItem);
var
  Data: TObject;
begin
  Data := Item.Data;
  Data.Free;
end;

procedure TfrmMainForm.lvSearchFileDeletion(Sender: TObject; Item: TListItem);
var
  Data: TObject;
begin
  Data := Item.Data;
  Data.Free;
end;

procedure TfrmMainForm.MainFormIni;
begin
  IsHideForm := not Application.ShowMainForm;
  App_IsExit := False;
  DragAcceptFiles(Handle, True); // 设置需要处理文件 WM_DROPFILES 拖放消息
  Application.HintHidePause := Time_ShowHint;
  MainFormHandle := Self.Handle;

  MyProductUrl.IniUrl; // 初始化 Url

  MyIcon := TMyIcon.Create; // 创建系统图标
  MyIcon.SaveMyIcon;

  LoadMainFormIni; // 读取配置信息
  BindSysItemIcon; // 系统图标
  BindToolbar; // ToolBar 绑定 控件右键 PopMenu
  BindVstData; // Vst NodeData Size 绑定
end;

procedure TfrmMainForm.restorerequest(var Msg: TMessage);
begin
  if not App_IsExit then
    ShowMainForm;
end;

procedure TfrmMainForm.SaveMainFormIni;
var
  iniFile: TIniFile;
begin
    // 没有权限写
  if not MyIniFile.ConfirmWriteIni then
    Exit;

  iniFile := TIniFile.Create(MyIniFile.getIniFilePath);
  try
    iniFile.WriteInteger(frmMainForm.Name, PcMain.Name, PcMain.ActivePageIndex);
    iniFile.WriteInteger(frmMainForm.Name, pmBackupPcFilter.Name, PcFilterUtil.getBackupPcFilter);
    iniFile.WriteInteger(frmMainForm.Name, pmRestorePcFilter.Name, PcFilterUtil.getRestorePcFilter);
  except
  end;
  iniFile.Free;
end;

procedure TfrmMainForm.sbEditionClick(Sender: TObject);
begin
  frmRegister.Show;
end;

procedure TfrmMainForm.sbMyStatusMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if ( ssCtrl in Shift ) and ( Button = mbRight ) then
    frmDebug.Show;
end;

procedure TfrmMainForm.SendPcFilterClick(Sender: TObject);
var
  mi : TMenuItem;
  i, SendPcSelect: Integer;
begin
  mi := Sender as TMenuItem;
  SendPcSelect := -1;
  for i := 0 to pmBackupPcFilter.Items.Count - 1 do
    if pmBackupPcFilter.Items[i] = mi then
    begin
      SendPcSelect := i;
      Break;
    end;
  PcFilterUtil.SetBackupPcFilter( SendPcSelect );
end;

procedure TfrmMainForm.Settings1Click(Sender: TObject);
begin
  frmSetting.PcMain.ActivePage := frmSetting.tsNetwork;
  frmSetting.Show;
end;

procedure TfrmMainForm.ShareExplorerHistoryClick(Sender: TObject);
var
  mi : TMenuItem;
  i, HistoryIndex: Integer;
//  ShareExplorerHistoryInfo : TShareExplorerHistoryInfo;
//  ShareExplorerSelectHandle : TShareExplorerSelectHandle;
begin
  mi := Sender as TMenuItem;

  HistoryIndex := -1;
  for i := 0 to pmRestoreHistory.Items.Count - 1 do
    if pmRestoreHistory.Items[i] = mi then
    begin
      HistoryIndex := i;
      Break;
    end;

  if HistoryIndex < 0 then
    Exit;

//  ShareExplorerHistoryInfo := ShareExplorerHistoryInfoReadUtil.ReadHistoryInfo( HistoryIndex );
//
//  ShareExplorerSelectHandle := TShareExplorerSelectHandle.Create( ShareExplorerHistoryInfo.FilePath, ShareExplorerHistoryInfo.OwnerID );
//  ShareExplorerSelectHandle.SetItemInfo( False, False );
//  ShareExplorerSelectHandle.Update;
//  ShareExplorerSelectHandle.Free;
//
//  ShareExplorerHistoryInfo.Free;
end;


procedure TfrmMainForm.ShowGroupFiles1Click(Sender: TObject);
begin
  if not frmRestorePcFilter.getIsSelectPc then
    Exit;

  RestorePcFilter( Sender );
end;

procedure TfrmMainForm.ShowMainForm;
begin
  try
    if not Self.Visible then
      Self.Visible := True;
    ShowWindow(Self.Handle, SW_RESTORE);
    SetForegroundWindow(Self.Handle);
    IsHideForm := False;
  except
  end;
end;


procedure TfrmMainForm.tbtnBackupSelectedClick(Sender: TObject);
var
  SelectNode, ChildNode : PVirtualNode;
  NodeData, ParentData : PVstBackupData;
begin
    // 免费版限制
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  tbtnBackupSelected.Enabled := False;

  SelectNode := VstBackup.GetFirstSelected;
  while Assigned( SelectNode ) do
  begin
    NodeData := VstBackup.GetNodeData( SelectNode );

      // 目标路径
    if ( NodeData.NodeType = BackupNodeType_LocalDes ) or
       ( NodeData.NodeType = BackupNodeType_NetworkDes )
    then
      DesItemUserApi.BackupSelectItem( NodeData.ItemID )
    else       // 源路径
    if ( ( NodeData.NodeType = BackupNodeType_LocalBackup ) or
         ( NodeData.NodeType = BackupNodeType_NetworkBackup ) ) and
        not VstBackup.Selected[ SelectNode.Parent ]
    then
    begin
      ParentData := VstBackup.GetNodeData( SelectNode.Parent );
      BackupItemUserApi.BackupSelectItem( ParentData.ItemID, NodeData.ItemID );
    end;

    SelectNode := VstBackup.GetNextSelected( SelectNode );
  end;
end;

procedure TfrmMainForm.tbtnBackupShowLogClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  NodeData, ParentData : PVstBackupData;
begin
    // 免费版限制
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  try  // 定位
    SelectNode := VstBackup.FocusedNode;
    if not Assigned( SelectNode ) or not Assigned( SelectNode.Parent ) then
      Exit;
    NodeData := VstBackup.GetNodeData( SelectNode );
    ParentData := VstBackup.GetNodeData( SelectNode.Parent );
  except
  end;

    // 显示 log
  try
    frmBackupLog.SetItemInfo( ParentData.ItemID, NodeData.ItemID );
    BackupLogApi.RefreshLogFace( ParentData.ItemID, NodeData.ItemID );
    frmBackupLog.ShowLog;
  except
  end;
end;

procedure TfrmMainForm.tbtnBackupSpeedClick(Sender: TObject);
var
  IsLimit, NewIsLimit : Boolean;
  LimitType, LimitValue : Integer;
  NewLimitType, NewLimitValue : Integer;
begin
    // 免费版限制
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  IsLimit := BackupSpeedInfoReadUtil.getIsLimit;
  LimitType := BackupSpeedInfoReadUtil.getLimitType;
  LimitValue := BackupSpeedInfoReadUtil.getLimitValue;

    // 取消设置
  if not frmBackupSpeedLimit.ResetLimit( IsLimit, LimitValue, LimitType ) then
    Exit;

  NewIsLimit := frmBackupSpeedLimit.getIsLimit;
  NewLimitType := frmBackupSpeedLimit.getSpeedType;
  NewLimitValue := frmBackupSpeedLimit.getSpeedValue;

    // 没有发生变化
  if ( IsLimit = NewIsLimit ) and ( LimitType = NewLimitType ) and ( LimitValue = NewLimitValue ) then
    Exit;

    // 重新设置
  BackupSpeedApi.SetLimit( NewIsLimit, NewLimitType, NewLimitValue );
end;

procedure TfrmMainForm.tbtnBackupStartClick(Sender: TObject);
begin
  tbtnBackupStart.Visible := False;
  BackupItemAppApi.BackupContinus;
end;

procedure TfrmMainForm.tbtnBackupStopClick(Sender: TObject);
begin
    // 免费版限制
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  tbtnBackupStop.Enabled := False;
  MyBackupHandler.IsBackupRun := False;
end;

procedure TfrmMainForm.tbtnExitClick(Sender: TObject);
var
  StopAppThread : TStopAppThread;
begin
  if App_IsExit then
    Exit;
  App_IsExit := True;

    // 显示退出提示
  try
    if ApplicationSettingInfo.IsShowDialogBeforeExist then
    begin
      if frmExitConfirm.ShowModal <> mrYes then
        Exit;
    end;
  except
  end;

    // 隐藏主窗口
  HideMainForm;

    // 定时强行结束程序
  try
    StopAppThread := TStopAppThread.Create;
    StopAppThread.Resume;
    try
      MyXmlUtil.LastSaveXml;
      SaveMainFormIni;
      BackupCow.Free;
      MyIcon.Free;
      MyProductUrl.UniniUrl;
    except
    end;
    StopAppThread.Free;
  except
  end;

  try  // 关闭窗口，结束程序
    Close;
  except
  end;
end;

procedure TfrmMainForm.tbtnHelpMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  InputStr : string;
  t : TObject;
begin
  if not ( ssCtrl in Shift ) or ( Button <> mbRight ) then
    Exit;

  InputStr := InputBox( 'Infomation', 'Backup Cow', '' );
  if InputStr = 'error' then  // 测试 EurekaLog
  begin
    t := TObject.Create;
    t.Free;
    t.Free;
  end
  else
  if InputStr = 'trial' then  // 测试试用
    TestUtil.TestTrial;
end;

procedure TfrmMainForm.tbtnMainFormClick(Sender: TObject);
begin
  PcMain.ActivePageIndex := (Sender as TRzToolButton).Tag;
end;

procedure TfrmMainForm.tbtnRestoreCollapseClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
begin
  SelectNode := vstRestoreShow.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    vstRestoreShow.Expanded[ SelectNode ] := False;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TfrmMainForm.tbtnRestoreDownAgainClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  NodeData : PVstRestoreDownData;
begin
  tbtnRestoreDownAgain.Enabled := False;

  SelectNode := vstRestoreDown.GetFirstSelected;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstRestoreDown.GetNodeData( SelectNode );

    if NodeData.NodeType = RestoreDownNodeType_Local then
      RestoreDownUserApi.RestoreSelectLocalItem( NodeData.RestorePath, NodeData.OwnerPcID, NodeData.RestoreFrom )
    else
      RestoreDownUserApi.RestoreSelectNetworkItem( NodeData.RestorePath, NodeData.OwnerPcID, NodeData.RestoreFrom );
    SelectNode := vstRestoreDown.GetNextSelected( SelectNode );
  end;
end;

procedure TfrmMainForm.tbtnRestoreDownClearClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  NodeData : PVstRestoreDownData;
begin
  if not MyMessageBox.ShowClearComfirm then
    Exit;

  tbtnRestoreDownClear.Enabled := False;

  SelectNode := vstRestoreDown.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstRestoreDown.GetNodeData( SelectNode );
    if NodeData.IsCompleted then
      RestoreDownUserApi.RemoveItem( NodeData.RestorePath, NodeData.OwnerPcID, NodeData.RestoreFrom );
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TfrmMainForm.tbtnRestoreDownExplorerClick(Sender: TObject);
var
  NodeData : PVstRestoreDownData;
begin
  if not Assigned( vstRestoreDown.FocusedNode ) then
    Exit;
  NodeData := vstRestoreDown.GetNodeData( vstRestoreDown.FocusedNode );
  MyExplore.OpenFolder( NodeData.SavePath );
end;

procedure TfrmMainForm.tbtnRestoreDownRemoveClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  NodeData : PVstRestoreDownData;
begin
  if not MyMessageBox.ShowRemoveComfirm then
    Exit;

  SelectNode := vstRestoreDown.GetFirstSelected;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstRestoreDown.GetNodeData( SelectNode );
    RestoreDownUserApi.RemoveItem( NodeData.RestorePath, NodeData.OwnerPcID, NodeData.RestoreFrom );
    SelectNode := vstRestoreDown.GetNextSelected( SelectNode );
  end;
end;

procedure TfrmMainForm.tbtnRestoreDownRunClick(Sender: TObject);
var
  NodeData : PVstRestoreDownData;
begin
  if not Assigned( vstRestoreDown.FocusedNode ) then
    Exit;
  NodeData := vstRestoreDown.GetNodeData( vstRestoreDown.FocusedNode );
  MyExplore.OpenFile( NodeData.SavePath );
end;

procedure TfrmMainForm.tbtnRestoreExpandClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
begin
  SelectNode := vstRestoreShow.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    vstRestoreShow.Expanded[ SelectNode ] := True;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TfrmMainForm.tbtnRestoreExplorerClick(Sender: TObject);
var
  FilePath : string;
begin
  if not Assigned( vstRestoreShow.FocusedNode ) then
    Exit;
  FilePath := MainFormUtil.getIsRestoreExplorerPath( vstRestoreShow.FocusedNode );
  MyExplore.OpenFolder( FilePath );
end;

procedure TfrmMainForm.tbtnRestorePcFilterClick(Sender: TObject);
begin
  tbtnRestorePcFilter.Down := True;
  tbtnRestorePcFilter.CheckMenuDropdown;
end;

procedure TfrmMainForm.tbtnRestoreRemoveClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  NodeData, ParentData : PVstRestoreData;
begin
  if not MyMessageBox.ShowConfirm( 'Are you sure to delete backuped files' ) then
    Exit;

  SelectNode := vstRestoreShow.GetFirstSelected;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstRestoreShow.GetNodeData( SelectNode );
    if Assigned( SelectNode.Parent ) then
      ParentData := vstRestoreShow.GetNodeData( SelectNode.Parent );
    if NodeData.NodeType = RestoreNodeType_LocalRestore then
      LocalBackupEvent.RemoveBackupItem( ParentData.ItemID, NodeData.ItemID )
    else
    if NodeData.NodeType = RestoreNodeType_NetworkRestore then
      NetworkBackupEvent.RemoveBackupItem( ParentData.ItemID, NodeData.ItemID );
    SelectNode := vstRestoreShow.GetNextSelected( SelectNode );
  end;
end;

procedure TfrmMainForm.tbtnRestoreSelectedClick(Sender: TObject);
var
  RestoreAllFileHandle : TRestoreAllFileHandle;
begin
  RestoreAllFileHandle := TRestoreAllFileHandle.Create;
  RestoreAllFileHandle.Update;
  RestoreAllFileHandle.Free;
end;

procedure TfrmMainForm.tbtnRestoreSpeedClick(Sender: TObject);
var
  IsLimit, NewIsLimit : Boolean;
  LimitType, LimitValue : Integer;
  NewLimitType, NewLimitValue : Integer;
begin
  IsLimit := RestoreSpeedInfoReadUtil.getIsLimit;
  LimitType := RestoreSpeedInfoReadUtil.getLimitType;
  LimitValue := RestoreSpeedInfoReadUtil.getLimitValue;

    // 取消设置
  if not frmRestoreSpeedLimit.ResetLimit( IsLimit, LimitValue, LimitType ) then
    Exit;

  NewIsLimit := frmRestoreSpeedLimit.getIsLimit;
  NewLimitType := frmRestoreSpeedLimit.getSpeedType;
  NewLimitValue := frmRestoreSpeedLimit.getSpeedValue;

    // 没有发生变化
  if ( IsLimit = NewIsLimit ) and ( LimitType = NewLimitType ) and ( LimitValue = NewLimitValue ) then
    Exit;

    // 重新设置
  RestoreSpeedApi.SetLimit( NewIsLimit, NewLimitType, NewLimitValue );
end;


procedure TfrmMainForm.tbtnRestoreStartClick(Sender: TObject);
begin
  tbtnRestoreStart.Visible := False;
//  tbtnRestoreSpeed.Visible := False;
  tbtnRestoreDownSplit.Visible := False;
  RestoreDownAppApi.ContinusRestore;
end;

procedure TfrmMainForm.tbtnRestoreStopClick(Sender: TObject);
begin
  tbtnRestoreStop.Enabled := False;
  MyRestoreHandler.IsRestoreRun := False;
end;

procedure TfrmMainForm.tiAppClick(Sender: TObject);
begin
  if App_IsExit then
    Exit;
  ShowMainForm;
end;

procedure TfrmMainForm.tmrRefreshHintTimer(Sender: TObject);
begin
  tmrRefreshHint.Enabled := False;
  MyHintUtil.RefreshHint;
end;

procedure TfrmMainForm.tbtnAccountRemoveClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  NodeData : PAccountData;
begin
  SelectNode := vstAccount.GetFirstSelected;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstAccount.GetNodeData( SelectNode );
    NetworkAccountApi.RemoveAccount( NodeData.AccountName );
    SelectNode := vstAccount.GetNextSelected( SelectNode );
  end;
end;

procedure TfrmMainForm.tbtnBackupAddClick(Sender: TObject);
var
  DesItemList : TStringList;
  SourceItemList : TStringList;
  SelectNode : PVirtualNode;
  NodeData : PVstBackupData;
  SelectBackupItemHandle : TSelectBackupItemHandle;
begin
  DesItemList := TStringList.Create;
  SourceItemList := TStringList.Create;

    // 寻找选中的源
  SelectNode := VstBackup.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    if VstBackup.Selected[ SelectNode ] then
    begin
      NodeData := VstBackup.GetNodeData( SelectNode );
      DesItemList.Add( NodeData.ItemID );
    end;
    SelectNode := SelectNode.NextSibling;
  end;

    // 设置备份信息
  SelectBackupItemHandle := TSelectBackupItemHandle.Create( DesItemList );
  SelectBackupItemHandle.SetSourceItemList( SourceItemList );
  SelectBackupItemHandle.Update;
  SelectBackupItemHandle.Free;

  SourceItemList.Free;
  DesItemList.Free;
end;

procedure TfrmMainForm.tbtnBackupAllClick(Sender: TObject);
begin
    // 免费版限制
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  BackupItemUserApi.BackupAllItem;
end;

procedure TfrmMainForm.tbtnBackupCollapseClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
begin
    // 免费版限制
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  SelectNode := VstBackup.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    VstBackup.Expanded[ SelectNode ] := False;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TfrmMainForm.tbtnBackupExpandAllClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
begin
    // 免费版限制
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  SelectNode := VstBackup.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    VstBackup.Expanded[ SelectNode ] := True;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TfrmMainForm.tbtnBackupExplorerClick(Sender: TObject);
var
  ExplorerPath : string;
  NodeData : PVstBackupData;
begin
    // 免费版限制
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  if not Assigned( VstBackup.FocusedNode ) then
    Exit;

  NodeData := VstBackup.GetNodeData( VstBackup.FocusedNode );
  ExplorerPath := NodeData.ItemID;
  MyExplore.OpenFolder( ExplorerPath );
end;

procedure TfrmMainForm.tbtnBackupNetworkClick(Sender: TObject);
begin
  if tbtnBackupNetwork.DropdownMenu = nil then
  begin
    RegisterLimitApi.ShowRemoteNetworkError;
    Exit;
  end;

  tbtnBackupNetwork.Down := True;
  tbtnBackupNetwork.CheckMenuDropdown;
end;

procedure TfrmMainForm.tbtnBackupOptionsClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  NodeData, ParentData : PVstBackupData;
  BackupItemOptionsHandle : TBackupItemOptionsHandle;
begin
    // 免费版限制
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  SelectNode := VstBackup.FocusedNode;
  if not Assigned( SelectNode ) or not Assigned( SelectNode.Parent ) then
    Exit;
  NodeData := VstBackup.GetNodeData( SelectNode );
  ParentData := VstBackup.GetNodeData( SelectNode.Parent );

  BackupItemOptionsHandle := TBackupItemOptionsHandle.Create( ParentData.ItemID, NodeData.ItemID );
  BackupItemOptionsHandle.SetIsFile( NodeData.IsFile );
  BackupItemOptionsHandle.Update;
  BackupItemOptionsHandle.Free;
end;

procedure TfrmMainForm.tbtnBackupPageMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if ( ssCtrl in Shift ) and ( Button = mbRight ) then
    frmDebug.Show;
end;

procedure TfrmMainForm.tbtnBackupPcFilterClick(Sender: TObject);
begin
  tbtnBackupPcFilter.Down := True;
  tbtnBackupPcFilter.CheckMenuDropdown;
end;

procedure TfrmMainForm.tbtnBackupRemoveClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  NodeData, ParentData : PVstBackupData;
  IsDelete : Boolean;
begin
  if not frmBackupDelete.getIsRemove then
    Exit;
  IsDelete := frmBackupDelete.getIsDelete;

  SelectNode := VstBackup.GetFirstSelected;
  while Assigned( SelectNode ) do
  begin
    NodeData := VstBackup.GetNodeData( SelectNode );
    if NodeData.NodeType = BackupNodeType_LocalDes then
      DesItemUserApi.RemoveLocalItem( NodeData.ItemID )
    else
    if ( NodeData.NodeType = BackupNodeType_LocalBackup ) and
         Assigned( SelectNode.Parent )
    then
    begin
      ParentData := VstBackup.GetNodeData( SelectNode.Parent );
      BackupItemUserApi.RemoveLocalItem( ParentData.ItemID, NodeData.ItemID, IsDelete );
    end
    else
    if NodeData.NodeType = BackupNodeType_NetworkDes then
      DesItemUserApi.RemoveNetworkItem( NodeData.ItemID )
    else
    if ( NodeData.NodeType = BackupNodeType_NetworkBackup ) and
         Assigned( SelectNode.Parent )
    then
    begin
      ParentData := VstBackup.GetNodeData( SelectNode.Parent );
      BackupItemUserApi.RemoveNetworkItem( ParentData.ItemID, NodeData.ItemID, IsDelete );
    end;
    SelectNode := VstBackup.GetNextSelected( SelectNode );
  end;
end;


procedure TfrmMainForm.tbtnSettingsClick(Sender: TObject);
begin
  frmSetting.Show;
end;

procedure TfrmMainForm.Upgrade1Click(Sender: TObject);
begin
  auApp.ShowMessages := auApp.ShowMessages + [mNoUpdateAvailable];
  auApp.CheckUpdate;
end;

procedure TfrmMainForm.vstAccountChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  tbtnAccountRemove.Enabled := vstAccount.SelectedCount > 0;
end;

procedure TfrmMainForm.vstAccountGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData : PAccountData;
begin
  ImageIndex := -1;
  if ( (Kind = ikNormal) or (Kind = ikSelected) ) and ( Column = 0 ) then
  begin
    NodeData := Sender.GetNodeData( Node );
    ImageIndex := NodeData.ShowIcon;
  end;
end;

procedure TfrmMainForm.vstAccountGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  NodeData : PAccountData;
begin
  NodeData := Sender.GetNodeData( Node );
  if Column = 0 then
    CellText := NodeData.ShowName
  else
  if Column = 1 then
    CellText := NodeData.ShowStatus
  else
    CellText := '';
end;

procedure TfrmMainForm.VstBackupChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  IsSelected, IsChild : Boolean;
  SelectNode : PVirtualNode;
  NodeData : PVstBackupData;
  IsShowExplorer, IsShowOptions, IsBackupSelect : Boolean;
begin
  IsSelected := Sender.SelectedCount > 0;
  tbtnBackupRemove.Enabled := IsSelected;

  SelectNode := Sender.FocusedNode;
  if Assigned( SelectNode )  then
  begin
    NodeData := Sender.GetNodeData( SelectNode );
    IsChild := ( NodeData.NodeType = BackupNodeType_LocalBackup ) or
               ( NodeData.NodeType = BackupNodeType_NetworkBackup );
    IsShowExplorer := NodeData.NodeType <> BackupNodeType_NetworkDes;
    IsShowOptions := IsChild;
    IsBackupSelect := IsChild and not NodeData.IsBackuping;
  end
  else
  begin
    IsShowExplorer := False;
    IsShowOptions := False;
    IsBackupSelect := False;
  end;
  tbtnBackupSelected.Enabled := IsBackupSelect and IsSelected;
  tbtnBackupExplorer.Enabled := IsShowExplorer and IsSelected;
  tbtnBackupOptions.Enabled := IsShowOptions and IsSelected;
  tbtnBackupShowLog.Enabled := IsShowOptions and IsSelected;
end;

procedure TfrmMainForm.VstBackupDblClick(Sender: TObject);
begin
  MyButton.Click( tbtnBackupSelected );
end;

procedure TfrmMainForm.VstBackupDragOver(Sender: TBaseVirtualTree;
  Source: TObject; Shift: TShiftState; State: TDragState; Pt: TPoint;
  Mode: TDropMode; var Effect: Integer; var Accept: Boolean);
begin
  Accept := False;

  // 设置状态
  if (Pt.X > 0) and (Pt.Y > 0) then
  begin
    DragFile_LastX := Pt.X;
    DragFile_LastY := Pt.Y;
  end;
end;

procedure TfrmMainForm.VstBackupFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  Data: PVstBackupData;
begin
  Data := Sender.GetNodeData(Node);
  Finalize(Data^); // Clear string data.
end;

procedure TfrmMainForm.VstBackupGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData : PVstBackupData;
begin
  ImageIndex := -1;
  NodeData := Sender.GetNodeData( Node );
  if Node.Parent = Sender.RootNode then
  begin
    if Column = VstBackup_BackupName then
    begin
      if Kind = ikState then
        ImageIndex := NodeData.MainIcon
    end
    else
    if Column = VstBackup_Status then
    begin
      if (Kind = ikNormal) or (Kind = ikSelected) then
        ImageIndex := VstBackupUtil.getDesStatusIcon( Node )
    end;
  end
  else
  if (Kind = ikNormal) or (Kind = ikSelected) then
  begin
    if Column = VstBackup_BackupName then
      ImageIndex := NodeData.MainIcon
    else
    if Column = VstBackup_Status then
    begin
      if NodeData.NodeType = BackupNodeType_ErrorItem then
        ImageIndex := MyShellTransActionIconUtil.getLoadedError
      else
        ImageIndex := VstBackupUtil.getBackupStatusIcon( Node );
    end;
  end;
end;

procedure TfrmMainForm.VstBackupGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  NodeData : PVstBackupData;
  NodeCount : Integer;
begin
  CellText := '';
  NodeData := Sender.GetNodeData( Node );
  if Node.Parent = Sender.RootNode then
  begin
    if Column = VstBackup_BackupName then
    begin
      CellText := 'Backup to ';
      if NodeData.NodeType = BackupNodeType_LocalDes then
        CellText := CellText + 'local folder ';
      CellText := CellText + NodeData.ShowName
    end
    else
    if ( Column = VstBackup_FileCount ) and not Sender.Expanded[ Node ] then
    begin
      NodeCount := Node.ChildCount;
      if NodeCount > 0 then
        CellText := IntToStr( NodeCount ) + ' Item';
      if NodeCount > 1 then
        CellText := CellText + 's';
    end
    else
    if Column = VstBackup_Status then
      CellText := VstBackupUtil.getDesStatus( Node );
  end
  else     // 错误 Item
  if NodeData.NodeType = BackupNodeType_ErrorItem then
  begin
    if Column = VstBackup_BackupName then
      CellText := NodeData.ShowName
    else
    if Column = VstBackup_FileSize then
      CellText := MySize.getFileSizeStr( NodeData.ItemSize )
    else
    if Column = VstBackup_Percentage then
      CellText := MyPercentage.getPercentageStr( NodeData.Percentage )
    else
    if Column = VstBackup_Status then
      CellText := NodeData.NodeStatus;
  end
  else
  if Column = VstBackup_BackupName then
    CellText := NodeData.ShowName
  else
  if Column = VstBackup_Status then
    CellText := VstBackupUtil.getBackupStatus( Node )
  else
  if NodeData.FileCount = -1 then // 初始化状态
    CellText := ''
  else
  if Column = VstBackup_FileCount then
    CellText := MyCount.getCountStr( NodeData.FileCount )
  else
  if Column = VstBackup_FileSize then
    CellText := MySize.getFileSizeStr( NodeData.ItemSize )
  else
  if Column = VstBackup_NextBackup then
    CellText := VstBackupUtil.getNextBackupText( Node )
  else
  if Column = VstBackup_Percentage then
  begin
    if ( NodeData.Percentage >= 100 ) and
       ( not NodeData.IsCompleted )
    then
      CellText := ''
    else
      CellText := MyPercentage.getPercentageStr( NodeData.Percentage );
  end;
end;

procedure TfrmMainForm.VstBackupKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  MyKeyBorad.CheckDeleteAndEnter( tbtnBackupRemove, tbtnBackupSelected, Key );
end;

procedure TfrmMainForm.VstBackupMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  SelectNode : PVirtualNode;
  NodeData : PVstBackupData;
  HintStr : string;
begin
  try   // 鼠标定位
    SelectNode := VstBackup.GetNodeAt( X, Y );
    if Assigned( SelectNode ) then
    begin
      NodeData := VstBackup.GetNodeData( SelectNode );
      if VstBackupUtil.getIsBackupNode( NodeData.NodeType ) then
        HintStr := VstBackupUtil.getBackupHintStr( SelectNode );
    end
    else
      HintStr := DropFile_Hint;
  except
    HintStr := '';
  end;

    // 刷新 Hint 信息
  if VstBackup.Hint <> HintStr then
  begin
    VstBackup.Hint := HintStr;
    OpenRefreshHint;
  end;
end;

procedure TfrmMainForm.VstBackupPaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
var
  NodeData : PVstBackupData;
begin
  if ( Node.Parent = Sender.RootNode ) and ( Column = VstBackup_BackupName ) then
  begin
    NodeData := Sender.GetNodeData( Node );
    if ( NodeData.NodeType = BackupNodeType_LocalDes ) or NodeData.IsOnline then
      TargetCanvas.Font.Style := TargetCanvas.Font.Style + [fsBold];
  end;
end;

procedure TfrmMainForm.vstRestoreShowChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  IsSelected, IsShowRestore, IsShowRestoreDeleted, IsShowDeleted, IsShowExplorer : Boolean;
  NodeData : PVstRestoreData;
  NodeType : string;
  SelectNode : PVirtualNode;
begin
  IsSelected := Sender.SelectedCount > 0;
  IsShowRestore := False;
  IsShowRestoreDeleted := False;
  IsShowDeleted := False;
  IsShowExplorer := False;
  SelectNode := Sender.FocusedNode;
  if Assigned( SelectNode ) then
  begin
    NodeData := Sender.GetNodeData( SelectNode );
    NodeType := NodeData.NodeType;
    IsShowExplorer := MainFormUtil.getIsShowRestoreExplorer( SelectNode );

    if ( NodeType = RestoreNodeType_LocalRestore ) or
       ( NodeType = RestoreNodeType_NetworkRestore )
    then
    begin
      IsShowRestore := True;
      IsShowRestoreDeleted := NodeData.IsSaveDeleted;
      IsShowDeleted := ( NodeType = RestoreNodeType_LocalRestore ) or
                       ( NodeData.OwnerID = Network_LocalPcID );
    end;
  end;
  tbtnRestoreSelected.Enabled := IsShowRestore and IsSelected;
  tbtnRestoreRemove.Enabled := IsShowDeleted and IsSelected;
  tbtnRestoreExplorer.Enabled := IsShowExplorer and IsSelected;
end;

procedure TfrmMainForm.vstRestoreShowDblClick(Sender: TObject);
begin
  MyButton.Click( tbtnRestoreSelected );
end;

procedure TfrmMainForm.vstRestoreDownChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  IsSelected, IsShowAgain, IsShowRun, IsShowExplorer : Boolean;
  NodeData : PVstRestoreDownData;
begin
  IsSelected := Sender.SelectedCount > 0;

  if Assigned( Sender.FocusedNode ) then
  begin
    NodeData := Sender.GetNodeData( Sender.FocusedNode );
    IsShowAgain := not NodeData.IsRestoring;
    IsShowRun := NodeData.IsFile;
    IsShowExplorer := True;
  end
  else
  begin
    IsShowAgain := False;
    IsShowRun := False;
    IsShowExplorer := False;
  end;

  tbtnRestoreDownAgain.Enabled := IsShowAgain and IsSelected;
  tbtnRestoreDownExplorer.Enabled := IsShowExplorer and IsSelected;
  tbtnRestoreDownRun.Enabled := IsShowRun and IsSelected;
  tbtnRestoreDownRemove.Enabled := IsSelected;
end;

procedure TfrmMainForm.vstRestoreDownDblClick(Sender: TObject);
begin
  MyButton.Click( tbtnRestoreDownExplorer );
end;

procedure TfrmMainForm.vstRestoreDownGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData : PVstRestoreDownData;
begin
  ImageIndex := -1;
  if (Kind = ikNormal) or (Kind = ikSelected)  then
  begin
    NodeData := Sender.GetNodeData( Node );
    if Column = VstRestoreDown_RestorePath then
      ImageIndex := NodeData.MainIcon
    else
    if Column = VstRestoreDown_Status then
    begin
      if NodeData.NodeType = RestoreDownNodeType_Error then
        ImageIndex := MyShellTransActionIconUtil.getLoadedError
      else
        ImageIndex := RestoreDownFaceReadUtil.ReadStatusImg( Node );
    end;
  end;
end;

procedure TfrmMainForm.vstRestoreDownGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  NodeData : PVstRestoreDownData;
begin
  CellText := '';

  NodeData := Sender.GetNodeData( Node );
  if NodeData.NodeType = RestoreDownNodeType_Error then
  begin
    if Column = VstRestoreDown_RestorePath then
      CellText := NodeData.RestorePath
    else
    if Column = VstRestoreDown_FileSize then
      CellText := MySize.getFileSizeStr( NodeData.FileSize )
    else
    if Column = VstRestoreDown_Percentage then
      CellText := MyPercentage.getPercentageStr( NodeData.Percentage )
    else
    if Column = VstRestoreDown_Status then
      CellText := NodeData.NodeStatus;
  end
  else
  if Column = VstRestoreDown_RestorePath then
    CellText := NodeData.RestorePath
  else
  if Column = VstRestoreDown_Owner then
    CellText := NodeData.OwnerPcName
  else
  if Column = VstRestoreDown_Status then
    CellText := RestoreDownFaceReadUtil.ReadStatusText( Node )
  else
  if NodeData.FileCount = -1 then  // 未知的情况
    CellText := ''
  else
  if Column = VstRestoreDown_FileCount then
    CellText := MyCount.getCountStr( NodeData.FileCount )
  else
  if Column = VstRestoreDown_FileSize then
    CellText := MySize.getFileSizeStr( NodeData.FileSize )
  else
  if Column = VstRestoreDown_Percentage then
  begin
    if ( not NodeData.IsCompleted ) and
       ( NodeData.CompletedSize >= NodeData.FileSize )
    then
      CellText := ''
    else
      CellText := MyPercentage.getPercentageStr( NodeData.Percentage );
  end;
end;

procedure TfrmMainForm.vstRestoreDownKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  MyKeyBorad.CheckDeleteAndEnter( tbtnRestoreDownRemove, tbtnRestoreDownExplorer, Key );
end;

procedure TfrmMainForm.vstRestoreDownMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  SelectNode : PVirtualNode;
  HintText : string;
begin
  HintText := '';

  try   // 提取 Hint 信息
    SelectNode := vstRestoreDown.GetNodeAt( x, Y );
    if Assigned( SelectNode ) then
      HintText := RestoreDownFaceReadUtil.ReadHintStr( SelectNode );
  except
  end;

    // 刷新 Hint 信息
  if vstRestoreDown.Hint <> HintText then
  begin
    vstRestoreDown.Hint := HintText;
    OpenRefreshHint;
  end;
end;

procedure TfrmMainForm.vstRestoreShowGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData : PVstRestoreData;
begin
  ImageIndex := -1;
  NodeData := Sender.GetNodeData( Node );
  if Node.Parent = Sender.RootNode then
  begin
    if Column = VstRestore_RestoreName then
    begin
      if Kind = ikState then
        ImageIndex := NodeData.MainIcon
    end;
  end
  else
  if (Kind = ikNormal) or (Kind = ikSelected) then
  begin
    if Column = VstRestore_RestoreName then
      ImageIndex := NodeData.MainIcon
  end;
end;

procedure TfrmMainForm.vstRestoreShowGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  NodeData : PVstRestoreData;
  NodeCount : Integer;
begin
  CellText := '';

  try
    NodeData := Sender.GetNodeData( Node );
    if Column = VstRestore_RestoreName then
    begin
      CellText := NodeData.ShowName;
      if Node.Parent = Sender.RootNode then
        CellText := 'Backups stored in ' + CellText;
    end
    else
    if Node.Parent = Sender.RootNode then
    begin
      if ( Column = VstRestore_FileCount ) and not Sender.Expanded[ Node ] then
      begin
        NodeCount := Node.ChildCount;
        if NodeCount > 0 then
          CellText := IntToStr( NodeCount ) + ' Item';
        if NodeCount > 1 then
          CellText := CellText + 's';
      end
    end
    else
    if Column = VstRestore_RestoreOwner then
      CellText := NodeData.OwnerName
    else
    if Column = VstRestore_FileCount then
      CellText := MyCount.getCountStr( NodeData.FileCount )
    else
    if Column = VstRestore_FileSize then
      CellText := MySize.getFileSizeStr( NodeData.FileSize )
    else
    if Column = VstRestore_LastBackupTime then
      CellText := formatdatetime('yyyy-mm-dd hh:mm', NodeData.LastBackupTime );
  except
  end;
end;

procedure TfrmMainForm.vstRestoreShowKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  MyKeyBorad.CheckDeleteAndEnter( tbtnRestoreRemove, tbtnRestoreSelected, Key );
end;

procedure TfrmMainForm.vstRestoreShowMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  SelectNode : PVirtualNode;
  HintText : string;
begin
  try   // 提取 Hint 信息
    SelectNode := vstRestoreShow.GetNodeAt( x, Y );
    if Assigned( SelectNode ) and RestoreFaceReadUtil.ReadIsRestoreNode( SelectNode ) then
      HintText := RestoreFaceReadUtil.ReadHintStr( SelectNode )
    else
      HintText := '';
  except
    HintText := '';
  end;

    // 刷新 Hint 信息
  if vstRestoreShow.Hint <> HintText then
  begin
    vstRestoreShow.Hint := HintText;
    OpenRefreshHint;
  end;
end;

procedure TfrmMainForm.vstRestoreShowPaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
begin
  if ( Node.Parent = Sender.RootNode ) and ( Column = VstBackup_BackupName ) then
    TargetCanvas.Font.Style := TargetCanvas.Font.Style + [fsBold];
end;

procedure TfrmMainForm.WMQueryEndSession(var Message: TMessage);
begin
  try
    if not App_IsExit then
    begin
      ApplicationSettingInfo.IsShowDialogBeforeExist := False;
      tbtnExit.Click;
    end;
  except
  end;

  Message.Result := 1;
end;

{ TDropFileHandle }



procedure TDropFileHandle.AddFileBackup;
var
  AddDropBackupFile : TAddDropBackupFile;
begin
  AddDropBackupFile := TAddDropBackupFile.Create( FilePathList );
  AddDropBackupFile.Update;
  AddDropBackupFile.Free;
end;

constructor TDropFileHandle.Create(_Msg: TMessage);
begin
  Msg := _Msg;
  FilePathList := TStringList.Create;
end;

destructor TDropFileHandle.Destroy;
begin
  FilePathList.Free;
  inherited;
end;

procedure TDropFileHandle.FindDropFileType;
begin
  if frmMainForm.PcMain.ActivePageIndex = MainPage_Backup  then
    DropFileType := DropFileType_Backup;
end;

procedure TDropFileHandle.FindFilePathList;
var
  FilesCount: Integer; // 文件总数
  i: Integer;
  FileName: array [0 .. 255] of Char;
  FilePath: string;
begin
  // 获取文件总数
  FilesCount := DragQueryFile(Msg.WParam, $FFFFFFFF, nil, 0);

  try
    // 获取文件名
    for i := 0 to FilesCount - 1 do
    begin
      DragQueryFile(Msg.WParam, i, FileName, 256);
      FilePath := FileName;
      FilePath := MyFilePath.getLinkPath( FilePath );
      FilePathList.Add(FilePath);
    end;
  except
  end;

  // 释放
  DragFinish(Msg.WParam);
end;

procedure TDropFileHandle.ResetStatus;
begin
end;

procedure TDropFileHandle.Update;
begin
    // 免费版限制
  if not RegisterLimitApi.ProfessionalAction then
    Exit;

  FormUtil.ForceForegroundWindow( frmMainForm.Handle );

  // 寻找拖动的文件列表
  FindFilePathList;
  FindDropFileType;

    // 不同的处理
  if DropFileType = DropFileType_Backup then
    AddFileBackup;

    // 重设状态
  ResetStatus;
end;

{ TAddDropBackupFile }

constructor TAddDropBackupFile.Create(_FilePathList: TStringList);
begin
  FilePathList := _FilePathList;
  DesItemList := TStringList.Create;
end;

destructor TAddDropBackupFile.Destroy;
begin
  DesItemList.Free;
  inherited;
end;

procedure TAddDropBackupFile.FindDropDesItem;
var
  SelectNode : PVirtualNode;
  NodeData : PVstBackupData;
begin
  with frmMainForm do
  begin
    SelectNode := VstBackup.GetNodeAt( DragFile_LastX, DragFile_LastY );
    if not Assigned( SelectNode ) then
      Exit;
    if SelectNode.Parent <> VstBackup.RootNode then
      Exit;
    NodeData := VstBackup.GetNodeData( SelectNode );
    DesItemList.Add( NodeData.ItemID );
  end;
end;

procedure TAddDropBackupFile.Update;
var
  SelectBackupItemHandle : TSelectBackupItemHandle;
begin
    // 获取 目标路径
  FindDropDesItem;

    // 弹出选择窗口
  SelectBackupItemHandle := TSelectBackupItemHandle.Create( DesItemList );
  SelectBackupItemHandle.SetSourceItemList( FilePathList );
  SelectBackupItemHandle.Update;
  SelectBackupItemHandle.Free;
end;

{ TSelectBackupItemHandle }

procedure TSelectBackupItemHandle.AddNewSelectedItem;
var
  BackupConfigInfo : TBackupConfigInfo;
  BackupPathList : TStringList;
  LocaDesList, NetworkDesList : TStringList;
  i, j : Integer;
begin
  BackupConfigInfo := frmSelectBackupItem.getBackupConfigInfo;

  BackupPathList := frmSelectBackupItem.getSourcePathList;
  LocaDesList := frmSelectBackupItem.getLocalDesList;
  NetworkDesList := frmSelectBackupItem.getNetworkDesList;
  for i := 0 to LocaDesList.Count - 1 do
    for j := 0 to BackupPathList.Count - 1 do
    begin
      BackupItemUserApi.AddItem( LocaDesList[i], BackupPathList[j], BackupConfigInfo );
      BackupItemUserApi.BackupSelectItem( LocaDesList[i], BackupPathList[j] );
    end;
  for i := 0 to NetworkDesList.Count - 1 do
    for j := 0 to BackupPathList.Count - 1 do
    begin
      BackupItemUserApi.AddItem( NetworkDesList[i], BackupPathList[j], BackupConfigInfo );
      BackupItemUserApi.BackupSelectItem( NetworkDesList[i], BackupPathList[j] );
    end;
  NetworkDesList.Free;
  LocaDesList.Free;
  BackupPathList.Free;

  BackupConfigInfo.Free;
end;

constructor TSelectBackupItemHandle.Create(_DesItemList : TStringList);
begin
  DesItemList := _DesItemList;
end;

procedure TSelectBackupItemHandle.SetSourceItemList(
  _SourceItemList: TStringList);
begin
  SourceItemList := _SourceItemList;
end;

procedure TSelectBackupItemHandle.Update;
begin
    // 用户选择路径
  if not frmSelectBackupItem.ShowAddItem( DesItemList, SourceItemList ) then
    Exit;

    // 添加 新选择路径
  AddNewSelectedItem;
end;

{ TBackupItemOptionsHandle }

constructor TBackupItemOptionsHandle.Create(_DesItemID, _BackupPath: string);
begin
  DesItemID := _DesItemID;
  BackupPath := _BackupPath;
end;

procedure TBackupItemOptionsHandle.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TBackupItemOptionsHandle.Update;
var
  BackupConfigInfo : TBackupConfigInfo;
  NewBackupConfigInfo : TBackupConfigInfo;
  ResetBackupOptionHandle : TResetBackupOptionHandle;
begin
  BackupConfigInfo := BackupItemInfoReadUtil.ReadConfigInfo( DesItemID, BackupPath );
  if BackupConfigInfo = nil then
    Exit;
  if frmSelectBackupItem.ShowItemProperies( BackupPath, IsFile, BackupConfigInfo ) then
  begin
    NewBackupConfigInfo := frmSelectBackupItem.getBackupConfigInfo;
    ResetBackupOptionHandle := TResetBackupOptionHandle.Create( NewBackupConfigInfo );
    ResetBackupOptionHandle.SetOldBackupConfigInfo( BackupConfigInfo );
    ResetBackupOptionHandle.SetItemInfo( DesItemID, BackupPath );
    ResetBackupOptionHandle.Update;
    ResetBackupOptionHandle.Free;
    NewBackupConfigInfo.Free;
  end;
  BackupConfigInfo.Free;
end;

{ TResetBackupOptionHandle }

constructor TResetBackupOptionHandle.Create(
  _NewBackupConfigInfo: TBackupConfigInfo);
begin
  NewBackupConfigInfo := _NewBackupConfigInfo;
end;

procedure TResetBackupOptionHandle.ResetAutoSync;
var
  Params : TBackupAutoSynParams;
begin
    // 没有发生变化
  if ( NewBackupConfigInfo.IsAuctoSync = OldBackupConfigInfo.IsAuctoSync ) and
     ( NewBackupConfigInfo.SyncTimeType = OldBackupConfigInfo.SyncTimeType ) and
     ( NewBackupConfigInfo.SyncTimeValue = OldBackupConfigInfo.SyncTimeValue )
  then
    Exit;

  Params.DesItemID := DesItemID;
  Params.BackupPath := BackupPath;
  Params.IsAutoSync := NewBackupConfigInfo.IsAuctoSync;
  Params.SyncTimeType := NewBackupConfigInfo.SyncTimeType;
  Params.SyncTimeValue := NewBackupConfigInfo.SyncTimeValue;
  BackupItemUserApi.SetAutoSyncInfo( Params );

    // 检测是否立刻备份
  BackupItemAppApi.AutoBackupNowCheck;
end;

procedure TResetBackupOptionHandle.ResetExcludeFilter;
begin
  if FileFilterUtil.getIsEquals( NewBackupConfigInfo.ExcludeFilterList, OldBackupConfigInfo.ExcludeFilterList ) then
    Exit;

  BackupItemUserApi.SetExcludeFilterList( DesItemID, BackupPath, NewBackupConfigInfo.ExcludeFilterList );

    // 改变了过滤信息
  IsBackupNow := True;
end;

procedure TResetBackupOptionHandle.ResetIncludeFilter;
begin
  if FileFilterUtil.getIsEquals( NewBackupConfigInfo.IncludeFilterList, OldBackupConfigInfo.IncludeFilterList ) then
    Exit;

  BackupItemUserApi.SetIncludeFilterList( DesItemID, BackupPath, NewBackupConfigInfo.IncludeFilterList );

    // 改变了过滤信息
  IsBackupNow := True;
end;

procedure TResetBackupOptionHandle.ResetIsBackupNow;
begin
    // 没有发生变化
  if NewBackupConfigInfo.IsBackupupNow = OldBackupConfigInfo.IsBackupupNow then
    Exit;

  BackupItemUserApi.SetIsBackupNow( DesItemID, BackupPath, NewBackupConfigInfo.IsBackupupNow );
end;

procedure TResetBackupOptionHandle.ResetIsEncrypt;
var
  Params : TBackupEncryptParams;
begin
    // 没有发生变化
  if ( NewBackupConfigInfo.IsEncrypt = OldBackupConfigInfo.IsEncrypt ) and
     ( NewBackupConfigInfo.Password = OldBackupConfigInfo.Password ) and
     ( NewBackupConfigInfo.PasswordHint = OldBackupConfigInfo.PasswordHint )
  then
    Exit;

  Params.DesItemID := DesItemID;
  Params.BackupPath := BackupPath;
  Params.IsEncrypt := NewBackupConfigInfo.IsEncrypt;
  Params.Password := NewBackupConfigInfo.Password;
  Params.PasswordHint := NewBackupConfigInfo.PasswordHint;
  BackupItemUserApi.SetEncryptInfo( Params );

    // 改变了加密信息
  IsBackupNow := True;
end;

procedure TResetBackupOptionHandle.ResetIsSaveDeleted;
var
  Params : TBackupSaveDeletedParams;
begin
    // 没有发生变化
  if ( NewBackupConfigInfo.IsKeepDeleted = OldBackupConfigInfo.IsKeepDeleted ) and
     ( NewBackupConfigInfo.KeepEditionCount = OldBackupConfigInfo.KeepEditionCount )
  then
    Exit;

  Params.DesItemID := DesItemID;
  Params.BackupPath := BackupPath;
  Params.IsSaveDeleted := NewBackupConfigInfo.IsKeepDeleted;
  Params.SaveDeletedEdition := NewBackupConfigInfo.KeepEditionCount;
  BackupItemUserApi.SetSaveDeletedInfo( Params );
end;

procedure TResetBackupOptionHandle.SetItemInfo(_DesItemID, _BackupPath: string);
begin
  DesItemID := _DesItemID;
  BackupPath := _BackupPath;
end;

procedure TResetBackupOptionHandle.SetOldBackupConfigInfo(
  _OldBackupConfigInfo: TBackupConfigInfo);
begin
  OldBackupConfigInfo := _OldBackupConfigInfo;
end;

procedure TResetBackupOptionHandle.Update;
begin
  IsBackupNow := False;

  ResetIsBackupNow;
  ResetAutoSync;
  ResetIsEncrypt;
  ResetIsSaveDeleted;
  ResetIncludeFilter;
  ResetExcludeFilter;

    // 不需要立刻备份
  if not IsBackupNow then
    Exit;

    // 立刻备份
  BackupItemUserApi.BackupSelectItem( DesItemID, BackupPath )
end;

{ TRestoreFileHandle }

function TRestoreAllFileHandle.FileHandle(Node: PVirtualNode): Boolean;
var
  RestoreNowSelectHandle : TRestoreNowSelectHandle;
begin
  RestoreNowSelectHandle := TRestoreNowSelectHandle.Create( Node );
  Result := RestoreNowSelectHandle.Update;
  RestoreNowSelectHandle.Free;
end;

function TRestoreAllFileHandle.FolderHandle(Node: PVirtualNode): Boolean;
var
  RestoreExplorerSelectHandle : TRestoreExplorerSelectHandle;
begin
  RestoreExplorerSelectHandle := TRestoreExplorerSelectHandle.Create( Node );
  Result := RestoreExplorerSelectHandle.Update;
  RestoreExplorerSelectHandle.Free;
end;

procedure TRestoreAllFileHandle.Update;
var
  SelectNode : PVirtualNode;
  NodeData : PVstRestoreData;
  IsRestore : Boolean;
begin
  vstRestoreShow := frmMainForm.vstRestoreShow;
  SelectNode := vstRestoreShow.GetFirstSelected;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstRestoreShow.GetNodeData( SelectNode );
    if ( NodeData.NodeType = RestoreNodeType_LocalRestore ) or
       ( NodeData.NodeType = RestoreNodeType_NetworkRestore )
    then
    begin
      if NodeData.IsFile and not NodeData.IsSaveDeleted then
        IsRestore := FileHandle( SelectNode )
      else
        IsRestore := FolderHandle( SelectNode );
      if not IsRestore then
        Break;
    end;
    SelectNode := vstRestoreShow.GetNextSelected( SelectNode );
  end;
end;

{ TRestoreExplorerSelectHandle }

procedure TRestoreExplorerSelectHandle.AddFileEdition(FolderPath: string);
var
  i: Integer;
  FilePath : string;
  EditionNum : Integer;
  Params : TRestoreFileEditionAddParams;
begin
    // 清空旧的
  RestoreFileEditionApi.ClearItems( FolderPath, OwnerID, RestoreFrom );

    // 添加新的
  Params.RestorePath := FolderPath;
  Params.OwnerPcID := OwnerID;
  Params.RestoreFrom := RestoreFrom;
  for i := 0 to FileEditionList.Count - 1 do
  begin
    FilePath := FileEditionList[i].FilePath;
    EditionNum := FileEditionList[i].EditionNum;
    if not MyMatchMask.CheckChild( FilePath, FolderPath ) then
      Continue;
    Params.FilePath := FilePath;
    Params.EditionNum := EditionNum;
    RestoreFileEditionApi.AddItem( Params );
  end;
end;

procedure TRestoreExplorerSelectHandle.AddRestoreDown;
var
  Params : TRestoreDownAddParams;
  i: Integer;
  RestoreInfo : TRestoreDownInfo;
  j: Integer;
begin
  FileEditionList := frmRestoreExplorer.getFileEditionList;

      // 参数信息
  Params.OwnerPcID := OwnerID;
  Params.RestoreFrom := RestoreFrom;
  Params.OwnerName := OwnerName;
  Params.IsEncrypt := IsEncrypted;
  Params.Password := Password;
  Params.FileCount := -1;
  Params.FileSize := 0;


    // 下载选择的路径
  for i := 0 to RestoreDownList.Count - 1 do
  begin
    RestoreInfo := RestoreDownList[i];
    Params.RestorePath := RestoreInfo.RestorePath;
    Params.IsFile := RestoreInfo.IsFile;
    Params.IsDeleted := RestoreInfo.IsDeleted;
    Params.EditionNum := RestoreInfo.EditionNum;
    Params.SavePath := RestoreInfo.SavePath;

        // 本地/网络 下载
    if IsLocalRestore then
      RestoreDownUserApi.AddLocalItem( Params )
    else
      RestoreDownUserApi.AddNetworkItem( Params );

      // 删除的目录
    if RestoreInfo.IsDeleted and not RestoreInfo.IsFile then
      AddFileEdition( RestoreInfo.RestorePath );
  end;

  FileEditionList.Free;
end;

constructor TRestoreExplorerSelectHandle.Create(_SelectNode: PVirtualNode);
begin
  SelectNode := _SelectNode;
  RestoreDownList := TRestoreDownList.Create;
end;

destructor TRestoreExplorerSelectHandle.Destroy;
begin
  RestoreDownList.Free;
  inherited;
end;

procedure TRestoreExplorerSelectHandle.FindRestoreInfo;
var
  vstRestore : TVirtualStringTree;
  NodeData, ParentData : PVstRestoreData;
  Params : TDecryptParams;
begin
    // 提取节点
  vstRestore := frmMainForm.vstRestoreShow;
  NodeData := vstRestore.GetNodeData( SelectNode );
  ParentData := vstRestore.GetNodeData( SelectNode.Parent );

    // 获取基本信息
  RestorePath := NodeData.ItemID;
  OwnerID := NodeData.OwnerID;
  OwnerName := NodeData.OwnerName;
  IsFile := NodeData.IsFile;
  FileSize := NodeData.FileSize;
  IsLocalRestore := NodeData.NodeType = RestoreNodeType_LocalRestore;
  IsSaveDeleted := NodeData.IsSaveDeleted;
  RestoreFrom := ParentData.ItemID;
  RestoreFromName := ParentData.ShowName;

    // 加密信息
  IsEncrypted := NodeData.IsEncrypted;
  PasswordMD5 := NodeData.Password;
  PasswordHint := NodeData.PasswordHint;
end;

function TRestoreExplorerSelectHandle.getPassword: Boolean;
var
  Params : TDecryptParams;
begin
  Result := True;
  if not IsEncrypted then // 文件没有加密
    Exit;

    // 填充参数
  Params.RestorePath := RestorePath;
  Params.IsFile := IsFile;
  Params.OwnerName := OwnerName;
  Params.RestoreFromName := RestoreFromName;
  Params.PasswordHint := PasswordHint;
  Params.PasswordMD5 := PasswordMD5;

    // 获取解密密码
  Password := frmDecrypt.getPassword( Params );
  Result := Password <> '';
end;

function TRestoreExplorerSelectHandle.getRestorePathList: Boolean;
var
  Params : TRestoreSelectParams;
  PathList : TRestoreSelectList;
  i: Integer;
  PathInfo : TRestoreSelectInfo;
  RestoreDownInfo : TRestoreDownInfo;
begin
    // 获取 恢复参数
  Params.RestorePath := RestorePath;
  Params.OwnerID := OwnerID;
  Params.OwnerName := OwnerID;
  Params.RestoreFrom := RestoreFrom;
  Params.RestoreFromName := RestoreFromName;
  Params.IsFile := IsFile;
  Params.HasDeleted := IsSaveDeleted;
  Params.IsLocal := IsLocalRestore;
  Params.IsEncrypted := IsEncrypted;
  if IsEncrypted then
  begin
    Params.PasswordExt := MyEncrypt.getPasswordMD5Ext( PasswordMD5 );
    Params.Password := Password;
  end
  else
    Params.PasswordExt := '';
  if Params.IsFile then
    Params.FileSize := FileSize;
  Result := frmRestoreExplorer.getIsRestore( Params );
  if not Result then  // 取消选择
    Exit;

    // 获取恢复信息
  PathList := frmRestoreExplorer.getSelectPathList;
  for i := 0 to PathList.Count - 1 do
  begin
    PathInfo := PathList[i];
    RestoreDownInfo := TRestoreDownInfo.Create( PathInfo.FilePath );
    RestoreDownInfo.SetIsFile( PathInfo.IsFile );
    RestoreDownInfo.SetDeletedInfo( PathInfo.IsDeleted, PathInfo.EditionNum );
    RestoreDownList.Add( RestoreDownInfo );
  end;
  PathList.Free;
end;

function TRestoreExplorerSelectHandle.getRestoreTo: Boolean;
var
  Params : TShowResotreParams;
  SameRestoreList : TIntList;
  ParentPath, SavePath : string;
  i: Integer;
  RestoreDownInfo : TRestoreDownInfo;
  SameRestoreChildList : TStringList;
begin
  Result := True;

  Params.OwnerPcName := OwnerName;
  Params.RestoreFromName := RestoreFromName;

  for i := 0 to RestoreDownList.Count - 1 do
  begin
    RestoreDownInfo := RestoreDownList[i];
    if RestoreDownInfo.SavePath <> '' then
      Continue;

    ParentPath := ExtractFileDir( RestoreDownInfo.RestorePath );
    SameRestoreList := getSameRestore( ParentPath, i );
    if SameRestoreList.Count > 1 then
    begin
      Params.RestorePath := ParentPath;
      Params.IsFile := False;
      Params.IsDeleted := False;
      SameRestoreChildList := getSameRestoreName( SameRestoreList );
      SavePath := frmSelectRestore.getRestoreTo( Params, SameRestoreChildList );
      SameRestoreChildList.Free;
      SetSameRestore( SavePath, SameRestoreList )
    end
    else
    begin
      Params.RestorePath := RestoreDownInfo.RestorePath;
      Params.IsFile := RestoreDownInfo.IsFile;
      Params.IsDeleted := RestoreDownInfo.IsDeleted;
      SavePath := frmSelectRestore.getRestoreTo( Params );
      RestoreDownList[i].SavePath := SavePath;
    end;
    SameRestoreList.Free;

    if SavePath = '' then
    begin
      Result := False;
      Break;
    end;
  end;
end;

function TRestoreExplorerSelectHandle.getSameRestore(
  ParentPath: string; StartIndex : Integer): TIntList;
var
  i: Integer;
  SelectParent : string;
begin
  Result := TIntList.Create;
  for i := StartIndex to RestoreDownList.Count - 1 do
  begin
    if RestoreDownList[i].SavePath <> '' then
      Continue;
    SelectParent := ExtractFileDir( RestoreDownList[i].RestorePath );
    if SelectParent = ParentPath then
      Result.Add( i );
  end;
end;

function TRestoreExplorerSelectHandle.getSameRestoreName(
  SameList: TIntList): TStringList;
var
  i: Integer;
  RestoreDownInfo : TRestoreDownInfo;
  s : string;
begin
  Result := TStringList.Create;
  for i := 0 to SameList.Count - 1 do
  begin
    RestoreDownInfo := RestoreDownList[SameList[i]];
    s := ExtractFileName( RestoreDownInfo.RestorePath ) + '|';
    s := s + BoolToStr( RestoreDownInfo.IsFile );
    Result.Add( s );
  end;
end;

procedure TRestoreExplorerSelectHandle.SetSameRestore(SavePath: string;
  SameList: TIntList);
var
  i : Integer;
  SameIndex : Integer;
  FileName : string;
begin
  for i := 0 to SameList.Count - 1 do
  begin
    SameIndex := SameList[i];
    FileName := ExtractFileName( RestoreDownList[SameIndex].RestorePath );
    if RestoreDownList[SameIndex].IsDeleted then
      FileName := MyFilePath.getRecycleShowName( FileName );
    RestoreDownList[SameIndex].SavePath := MyFilePath.getPath( SavePath ) + FileName;
  end;
end;

function TRestoreExplorerSelectHandle.Update: Boolean;
begin
  FindRestoreInfo;

  Result := getPassword and getRestorePathList and getRestoreTo;
  if not Result then
    Exit;

  AddRestoreDown;
end;

{ TRestoreNowSelectHandle }

procedure TRestoreNowSelectHandle.AddRestoreDown;
var
  NodeData, ParentData : PVstRestoreData;
  Params : TRestoreDownAddParams;
begin
  NodeData := vstRestoreShow.GetNodeData( Node );
  ParentData := vstRestoreShow.GetNodeData( Node.Parent );

    // 参数信息
  Params.RestorePath := NodeData.ItemID;
  Params.OwnerPcID := NodeData.OwnerID;
  Params.RestoreFrom := ParentData.ItemID;
  Params.OwnerName := NodeData.OwnerName;
  Params.IsFile := NodeData.IsFile;
  Params.IsDeleted := False;
  Params.IsEncrypt := NodeData.IsEncrypted;
  Params.Password := Password;
  Params.FileCount := NodeData.FileCount;
  Params.FileSize := NodeData.FileSize;
  Params.SavePath := RestoreTo;

    // 本地/网络 下载
  if ParentData.NodeType = RestoreNodeType_LocalDes then
    RestoreDownUserApi.AddLocalItem( Params )
  else
    RestoreDownUserApi.AddNetworkItem( Params );
end;
constructor TRestoreNowSelectHandle.Create(_Node: PVirtualNode);
begin
  Node := _Node;
end;

function TRestoreNowSelectHandle.getPassword: Boolean;
var
  NodeData, ParentData : PVstRestoreData;
  Params : TDecryptParams;
begin
  NodeData := vstRestoreShow.GetNodeData( Node );
  ParentData := vstRestoreShow.GetNodeData( Node.Parent );

  Result := True;
  if not NodeData.IsEncrypted then // 文件没有加密
    Exit;

  Params.RestorePath := NodeData.ItemID;
  Params.OwnerName := NodeData.OwnerName;
  Params.RestoreFromName := ParentData.ShowName;
  Params.PasswordHint := NodeData.PasswordHint;
  Params.PasswordMD5 := NodeData.Password;
  Params.IsFile := NodeData.IsFile;

  Password := frmDecrypt.getPassword( Params );
  Result := Password <> '';
end;

function TRestoreNowSelectHandle.getRestoreTo: Boolean;
var
  NodeData, ParentData : PVstRestoreData;
  Params : TShowResotreParams;
begin
  NodeData := vstRestoreShow.GetNodeData( Node );
  ParentData := vstRestoreShow.GetNodeData( Node.Parent );

    // 设置 参数
  Params.RestorePath := NodeData.ItemID;
  Params.OwnerPcName := NodeData.OwnerName;
  Params.RestoreFromName := ParentData.ShowName;
  Params.IsFile := NodeData.IsFile;

    // 获取 恢复路径
  RestoreTo := frmSelectRestore.getRestoreTo( Params );
  Result := RestoreTo <> '';

  if not Result then
    Exit;

    // 保存路径是一个目录
  if NodeData.IsFile and DirectoryExists( RestoreTo ) then
    RestoreTo := MyFilePath.getPath( RestoreTo ) + ExtractFileName( NodeData.ItemID );
end;

function TRestoreNowSelectHandle.Update: Boolean;
begin
  vstRestoreShow := frmMainForm.vstRestoreShow;

    // 获取 下载路径 和 密码
  Result := getPassword and getRestoreTo;

    // 已取消
  if not Result then
    Exit;

  AddRestoreDown;
end;

{ TStopAppThread }

constructor TStopAppThread.Create;
begin
  inherited Create;
end;

destructor TStopAppThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  inherited;
end;

procedure TStopAppThread.Execute;
var
  SleepCount : Integer;
begin
  SleepCount := 0;
  while not Terminated and ( SleepCount < 120 ) do
  begin
    Sleep( 100 );
    Inc( SleepCount );
  end;

    // 10 秒钟都没有结束程序，则强行结束
  if not Terminated then
  begin
    try
      ExitProcess(0);
      Application.Terminate;
    except
    end;
  end;

  inherited;
end;

{ MainFormUtil }

class procedure MainFormUtil.EnterMainPage(MainPage: integer);
begin
    // 主界面页面
  if ( MainPage < 0 ) or ( MainPage >= frmMainForm.PcMain.PageCount ) then  // 越界
    MainPage := MainPage_Account;
//  if MainPage = MainPage_Backup then
//    frmMainForm.tbtnBackupPage.Down := True
//  else
  if MainPage = MainPage_Restore then
    frmMainForm.tbtnRestorePage.Down := True;
//  else
//  if MainPage = MainPage_Account then
//    frmMainForm.tbtnAccount.Down := True;
  frmMainForm.PcMain.ActivePageIndex := MainPage;
end;

class function MainFormUtil.getIsRestoreExplorerPath(
  SelectNode: PVirtualNode): string;
var
  vstRestore : TVirtualStringTree;
  NodeData, ParentData : PVstRestoreData;
  NodeType : string;
  CloudPath, OwnerID, FilePath : string;
begin
  vstRestore := frmMainForm.vstRestoreShow;
  NodeData := vstRestore.GetNodeData( SelectNode );
  NodeType := NodeData.NodeType;
  if NodeType = RestoreNodeType_LocalDes then
    Result := NodeData.ItemID
  else
  if ( NodeType = RestoreNodeType_LocalRestore ) and Assigned( SelectNode.Parent ) then
  begin
    ParentData := vstRestore.GetNodeData( SelectNode.Parent );
    Result := MyFilePath.getLocalBackupPath( ParentData.ItemID, NodeData.ItemID );
  end
  else
  if NodeType = RestoreNodeType_NetworkDes then
  begin
    CloudPath := NetworkDesItemUtil.getCloudPath( NodeData.ItemID );
    Result := CloudPath;
  end
  else
  if ( NodeType = RestoreNodeType_NetworkRestore ) and Assigned( SelectNode.Parent ) then
  begin
    ParentData := vstRestore.GetNodeData( SelectNode.Parent );
    CloudPath := NetworkDesItemUtil.getCloudPath( ParentData.ItemID );
    OwnerID := NodeData.OwnerID;
    FilePath := NodeData.ItemID;
    Result := MyFilePath.getPath( CloudPath ) + OwnerID;
    Result := MyFilePath.getPath( Result ) + MyFilePath.getDownloadPath( FilePath );
  end;
end;

class function MainFormUtil.getIsShowRestoreExplorer(
  SelectNode: PVirtualNode): Boolean;
var
  vstRestore : TVirtualStringTree;
  NodeData, ParentData : PVstRestoreData;
  NodeType : string;
  DesPcID : string;
begin
  vstRestore := frmMainForm.vstRestoreShow;
  NodeData := vstRestore.GetNodeData( SelectNode );
  NodeType := NodeData.NodeType;
  if NodeType = RestoreNodeType_LocalDes then
    Result := True
  else
  if ( NodeType = RestoreNodeType_LocalRestore ) and not NodeData.IsEncrypted then
    Result := True
  else
  if NodeType = RestoreNodeType_NetworkDes then
  begin
    DesPcID := NetworkDesItemUtil.getPcID( NodeData.ItemID );
    Result := DesPcID = Network_LocalPcID;
  end
  else
  if ( NodeType = RestoreNodeType_NetworkRestore ) and Assigned( SelectNode.Parent ) then
  begin
    ParentData := vstRestore.GetNodeData( SelectNode.Parent );
    DesPcID := NetworkDesItemUtil.getPcID( ParentData.ItemID );
    Result := ( DesPcID = Network_LocalPcID ) and not NodeData.IsEncrypted;
  end;
end;

{ PcFilterUtil }

class function PcFilterUtil.getBackupPcFilter: Integer;
var
  pmBackupPcFilter : TPopupMenu;
  i: Integer;
begin
  Result := -1;
  pmBackupPcFilter := frmMainForm.pmBackupPcFilter;
  for i := 0 to pmBackupPcFilter.Items.Count - 1 do
  begin
    if pmBackupPcFilter.Items[i].ImageIndex = ImgIndex_PcFilterSelect then
    begin
      Result := i;
      Break;
    end;
  end;

    // 不存在，则选择在线Pc
  if Result = -1 then
    Result := 0;
end;

class function PcFilterUtil.getBackupPcIsShow(Node: PVirtualNode): Boolean;
var
  NodeData : PVstBackupData;
begin
  NodeData := frmMainForm.VstBackup.GetNodeData( Node );
  if NodeData.NodeType = BackupNodeType_LocalDes then
    Result := True
  else
  if Filter_BackupPc = BackupPcFilter_Online then
    Result := NodeData.IsOnline
  else
  if Filter_BackupPc = BackupPcFilter_Group then
    Result := frmSendPcFilter.getIsChecked( NodeData.ItemID )
  else
    Result := True;
end;

class function PcFilterUtil.getRestorePcFilter: Integer;
var
  pmRestorePcFilter : TPopupMenu;
  i: Integer;
begin
  Result := -1;
  pmRestorePcFilter := frmMainForm.pmRestorePcFilter;
  for i := 0 to pmRestorePcFilter.Items.Count - 1 do
  begin
    if pmRestorePcFilter.Items[i].ImageIndex = ImgIndex_PcFilterSelect then
    begin
      Result := i;
      Break;
    end;
  end;

    // 不存在，则选择在线Pc
  if Result = -1 then
    Result := 0;
end;

class function PcFilterUtil.getRestorePcIsShow(Node: PVirtualNode): Boolean;
var
  NodeData : PVstRestoreData;
begin
  NodeData := frmMainForm.VstBackup.GetNodeData( Node );
  if NodeData.NodeType = RestoreNodeType_LocalRestore then
    Result := True
  else
  if Filter_RestorePc = RestorePcFilter_MyPc then
    Result := NodeData.OwnerID = Network_LocalPcID
  else
  if Filter_RestorePc = RestorePcFilter_GroupPc then
    Result := frmRestorePcFilter.getIsChecked( NodeData.OwnerID )
  else
    Result := True;
end;


class procedure PcFilterUtil.RefreshBackupShowNode;
var
  SelectNode : PVirtualNode;
begin
  SelectNode := frmMainForm.VstBackup.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    frmMainForm.VstBackup.IsVisible[ SelectNode ] := getBackupPcIsShow( SelectNode );
    SelectNode := SelectNode.NextSibling;
  end;
end;


class procedure PcFilterUtil.RefreshRestoreShowNode;
var
  SelectNode, ChildNode : PVirtualNode;
  IsShowChild, IsShow : Boolean;
begin
  SelectNode := frmMainForm.vstRestoreShow.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    IsShowChild := False;
    ChildNode := SelectNode.FirstChild;
    while Assigned( ChildNode ) do
    begin
      IsShow := getRestorePcIsShow( ChildNode );
      frmMainForm.vstRestoreShow.IsVisible[ ChildNode ] := IsShow;
      IsShowChild := IsShowChild or IsShow;
      ChildNode := ChildNode.NextSibling;
    end;
    frmMainForm.vstRestoreShow.IsVisible[ SelectNode ] := IsShowChild;
    frmMainForm.vstRestoreShow.Expanded[ SelectNode ] := IsShowChild;
    SelectNode := SelectNode.NextSibling;
  end;
end;


class procedure PcFilterUtil.SetBackupPcFilter(SelectIndex: Integer);
var
  pmBackupPc : TPopupMenu;
  i: Integer;
begin
  pmBackupPc := frmMainForm.pmBackupPcFilter;

    // 越界
  if ( SelectIndex < 0 ) or ( SelectIndex > ( pmBackupPc.Items.Count - 1 ) ) then
    SelectIndex := 0;

  for i := 0 to pmBackupPc.Items.Count - 1 do
  begin
    if i = SelectIndex then
    begin
      pmBackupPc.Items[i].ImageIndex := ImgIndex_PcFilterSelect;
      pmBackupPc.Items[i].Default := True;
      frmMainForm.tbtnBackupPcFilter.Caption := pmBackupPc.Items[i].Caption;
    end
    else
    begin
      pmBackupPc.Items[i].ImageIndex := -1;
      pmBackupPc.Items[i].Default := False;
    end;
  end;

    // 设置过滤器
  if SelectIndex = 0 then
    Filter_BackupPc := BackupPcFilter_Online
  else
  if SelectIndex = 1 then
    Filter_BackupPc := BackupPcFilter_Group
  else
    Filter_BackupPc := BackupPcFilter_All;

    // 刷新显示节点
  RefreshBackupShowNode;
end;

class procedure PcFilterUtil.SetRestorePcFilter(SelectIndex: Integer);
var
  pmRestorePcFilter : TPopupMenu;
  i: Integer;
begin
  pmRestorePcFilter := frmMainForm.pmRestorePcFilter;

    // 越界
  if ( SelectIndex < 0 ) or ( SelectIndex > ( pmRestorePcFilter.Items.Count - 1 ) ) then
    SelectIndex := 0;

  for i := 0 to pmRestorePcFilter.Items.Count - 1 do
  begin
    if i = SelectIndex then
    begin
      pmRestorePcFilter.Items[i].ImageIndex := ImgIndex_PcFilterSelect;
      pmRestorePcFilter.Items[i].Default := True;
      frmMainForm.tbtnRestorePcFilter.Caption := pmRestorePcFilter.Items[i].Caption;
    end
    else
    begin
      pmRestorePcFilter.Items[i].ImageIndex := -1;
      pmRestorePcFilter.Items[i].Default := False;
    end;
  end;

    // 设置过滤器
  if SelectIndex = 0 then
    Filter_RestorePc := RestorePcFilter_MyPc
  else
  if SelectIndex = 1 then
    Filter_RestorePc := RestorePcFilter_GroupPc
  else
    Filter_RestorePc := RestorePcFilter_All;

    // 刷新显示节点
  RefreshRestoreShowNode;
end;

{ TRestoreDownInfo }

constructor TRestoreDownInfo.Create(_RestorePath: string);
begin
  RestorePath := _RestorePath;
  SavePath := '';
end;

procedure TRestoreDownInfo.SetDeletedInfo(_IsDeleted: Boolean; _EditionNum : Integer);
begin
  IsDeleted := _IsDeleted;
  EditionNum := _EditionNum;
end;

procedure TRestoreDownInfo.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TRestoreDownInfo.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

end.
