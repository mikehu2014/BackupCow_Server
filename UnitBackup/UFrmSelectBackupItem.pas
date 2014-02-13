unit UFrmSelectBackupItem;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  VirtualTrees, StdCtrls,
  ImgList, ComCtrls, ExtCtrls, SyncObjs, UIconUtil, RzPanel, RzDlgBtn, RzTabs,
  Spin, pngimage, UFmFilter, UFileBaseInfo, UFrameFilter, Vcl.ToolWin, DateUtils,
  Vcl.Menus, IniFiles;

type

  // This data record contains all necessary information about a particular file system object.
  // This can either be a folder (virtual or real) or an image file.
  PShellObjectData = ^TShellObjectData;
  TShellObjectData = record
    FullPath, Display: WideString;
    IsFolder : Boolean;
    FileSize : Int64;
    FileTime : TDateTime;
    DisplayIcon : Integer;
  end;


    // 备份参数
  TBackupParams = record
  public   // Auto Backup Settings
    IsAutoSync : Boolean;
    SyncType, SyncValue : Integer;
    IsBackupNow : Boolean;
  public   // Keep Deleted Settings
    IsSaveDeleted : Boolean;
    SaveEdition : Integer;
  public   // Encrypt Settings
    IsEncrypted : Boolean;
    Password, PasswrodHint : string;
  end;


  TfrmSelectBackupItem = class(TForm)
    PcMain: TRzPageControl;
    TsSelectFile: TRzTabSheet;
    TsGenernal: TRzTabSheet;
    TsInclude: TRzTabSheet;
    vstSelectPath: TVirtualStringTree;
    pl5: TPanel;
    gbEncrypt: TGroupBox;
    lbEncPassword: TLabel;
    lbEncPassword2: TLabel;
    lbEncPasswordHint: TLabel;
    lbReqEncPassword: TLabel;
    lbReqEncPassword2: TLabel;
    img3: TImage;
    chkIsEncrypt: TCheckBox;
    edtEncPassword2: TEdit;
    edtEncPasswordHint: TEdit;
    edtEncPassword: TEdit;
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    cbbSyncTime: TComboBox;
    chkSyncBackupNow: TCheckBox;
    ChkSyncTime: TCheckBox;
    seSyncTime: TSpinEdit;
    ilPcMain16: TImageList;
    FrameFilter: TFrameFilterPage;
    tsSelectDes: TRzTabSheet;
    Panel3: TPanel;
    Panel4: TPanel;
    btnOK: TButton;
    BtnCancel: TButton;
    plLocal: TPanel;
    ilNw16: TImageList;
    Panel6: TPanel;
    GroupBox4: TGroupBox;
    img7: TImage;
    img6: TImage;
    chkIsKeepDeleted: TCheckBox;
    seKeepEditionCount: TSpinEdit;
    lbKeepEditionCount: TLabel;
    Panel9: TPanel;
    FileDialog: TOpenDialog;
    tbSelectFile: TToolBar;
    tbtnSelectFile: TToolButton;
    tbtnSelectFolder: TToolButton;
    tbtnManually: TToolButton;
    tbtnUnSelect: TToolButton;
    plSelectSource: TPanel;
    plBackupTitle: TPanel;
    edtPaste: TEdit;
    vstLocalDes: TVirtualStringTree;
    vstNetworkDes: TVirtualStringTree;
    plNetwork: TPanel;
    Panel2: TPanel;
    plBackupTo: TPanel;
    Panel5: TPanel;
    Splitter1: TSplitter;
    ToolBar1: TToolBar;
    tbtnAddDes: TToolButton;
    tbtnDesManual: TToolButton;
    tbtnRemove: TToolButton;
    btnNext: TButton;
    tbtnRefresh: TToolButton;
    pmLocalDes: TPopupMenu;
    procedure FormCreate(Sender: TObject);
    procedure vdtBackupFolderHeaderClick(Sender: TVTHeader; Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure vstSelectPathGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: String);
    procedure vstSelectPathFreeNode(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure vstSelectPathGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstSelectPathInitChildren(Sender: TBaseVirtualTree;
      Node: PVirtualNode; var ChildCount: Cardinal);
    procedure vstSelectPathInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure vstSelectPathChecked(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure FormShow(Sender: TObject);
    procedure FrameIncludebtnSelectFileClick(Sender: TObject);
    procedure FrameExcludebtnSelectFileClick(Sender: TObject);
    procedure chkIsEncryptClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure PcMainPageChange(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure ChkSyncTimeClick(Sender: TObject);
    procedure chkIsKeepDeletedClick(Sender: TObject);
    procedure btnRemoveLocalDesClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tbtnSelectFileClick(Sender: TObject);
    procedure tbtnSelectFolderClick(Sender: TObject);
    procedure Panel9Click(Sender: TObject);
    procedure tbtnManuallyClick(Sender: TObject);
    procedure tbtnUnSelectClick(Sender: TObject);
    procedure vstLocalDesGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstLocalDesGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstNetworkDesGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstNetworkDesGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure tbtnDesManualClick(Sender: TObject);
    procedure vstLocalDesChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstNetworkDesChecked(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure vstLocalDesChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure edtEncPasswordKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtEncPassword2KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure vstSelectPathFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure tbtnRefreshClick(Sender: TObject);
    procedure PmLocalDesMiClick(Sender: TObject);
  private
    DefaultParams : TBackupParams;
    procedure SaveIni;
    procedure LoadIni;
    procedure RefreshDefaultParams;
  private
    LastDriverList : TStringList;
    procedure WMDeviceChange(var Msg: TMessage); message WM_DEVICECHANGE;
    procedure AddDriver( Path : string );
    procedure RemoveDriver( Path : string );
  private
    OtherPathList : TStringList;
    procedure AddOtherPaths;
    procedure AddOtherPath( FolderPath : string );
    procedure ResetSettings;
    procedure CheckBtnOkEnable;
  private       // 初始化节点
    function AddFileNode( ParentNode : PVirtualNode; FileName : string ): PVirtualNode;
    function AddFolderNode( ParentNode : PVirtualNode; FolderName : string ): PVirtualNode;
  private
    IsAddItem : Boolean;
  public
    procedure DropFiles(var Msg: TMessage); message WM_DROPFILES;
  private       // 设置
    procedure SetUnCheckedSource( Node : PVirtualNode );   // 清空 Checked
    procedure SetUnCheckDes;
    procedure AddSourceItemList( SourcePathList : TStringList );
    procedure AddSourceItem( SourcePath : string );
    procedure AddDesItemList( DesItemList : TStringList );
    procedure AddDesItem( DesItemID : string );
  private       // 读取
    function getIsOK : Boolean; // 是否完成选择
    procedure FindSourcePathList( Node : PVirtualNode; SourcePathList : TStringList ); // Find Path
  public        // 添加/属性
    function ShowAddItem( DesItemList, SourceItemList : TStringList ): Boolean;
    function ShowItemProperies( SourcePath : string; IsFile : Boolean; BackupConfigInfo : TBackupConfigInfo ): Boolean;
  public
    function getSourcePathList : TStringList;   // 获取 选择路径
    function getLocalDesList : TStringList;   // 本地目标
    function getNetworkDesList : TStringList;  // 网络目标
    function getBackupConfigInfo : TBackupConfigInfo;  // 获取 配置信息
  end;

    // 默认配置
  TReadDefaultSettings = class
  public
    procedure Update;
  end;

    // 指定配置
  TReadConfigSetttings = class
  public
    BackupConfigInfo : TBackupConfigInfo;
  public
    constructor Create( _BackupConfigInfo : TBackupConfigInfo );
    procedure Update;
  end;

    // 辅助类
  SelectBackupFormUtil = class
  public
    class function getIsOtherPath( SourcePath : string ): Boolean;
    class function getOtherFirstNode : PVirtualNode;
  end;

    // 拖动文件
  TSelectBackupDropFileHandle = class
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
    procedure AddBackupSource;
    procedure AddBackupDestination;
  end;

const
  FormCaption_AddItem = 'Add Backup Items';
  FormCaption_ItemProperties = '%s Properies';
  FormIcon_AddItem = 4;
  FormIcon_ItemProperties = 5;

const
  DropFileType_BackupSource = 'BackupSource';
  DropFileType_BackupDestination = 'BackupDestination';
  
const
  ShowForm_SelectBackupFolder = 'Select your backup folder';

const
  VstSelectBackupPath_FileName = 0;
  VstSelectBackupPath_FileSize = 1;
  VstSelectBackupPath_FileTime = 2;

const
  VstSelectDes_ComputerName = 0;
  VstSelectDes_AvailableSpace = 1;

var
  frmSelectBackupItem: TfrmSelectBackupItem;
  SystemPath_NetHood : string;
  SystemPath_DriverCount : Integer;

implementation

uses
  FileCtrl, ShellAPI, Mask, ShlObj, ActiveX, UMyUtil, UFormSetting, UFormUtil,
  UMyBackupApiInfo, UMyBackupFaceInfo, UMyNetPcInfo;

{$R *.DFM}

procedure TfrmSelectBackupItem.FormCreate(Sender: TObject);
var
  i: Integer;
begin
    // 设置需要处理文件 WM_DROPFILES 拖放消息
  DragAcceptFiles(Handle, True);

    // 数据绑定
  vstSelectPath.NodeDataSize := SizeOf(TShellObjectData);
  vstSelectPath.Images := MyIcon.getSysIcon;
  vstLocalDes.NodeDataSize := SizeOf(TLocalDesData);
  vstLocalDes.Images := MyIcon.getSysIcon;
  vstNetworkDes.NodeDataSize := SizeOf(TNetworkDesData);
  vstSelectPath.PopupMenu := FormUtil.getPopMenu( tbSelectFile );

    // 初始化 磁盘路径
  SystemPath_DriverCount := 0;
  LastDriverList := MyHardDisk.getPathList;
  for i := 0 to LastDriverList.Count - 1 do
    AddDriver( LastDriverList[i] );

    // 特殊的路径
  OtherPathList := TStringList.Create;

    // 添加特殊路径
  AddOtherPaths;
  
    // 加载配置信息
  ResetSettings;

    // 读取
  LoadIni;
end;

procedure TfrmSelectBackupItem.FormDestroy(Sender: TObject);
begin
  LastDriverList.Free;
  OtherPathList.Free;

  SaveIni;
end;

procedure TfrmSelectBackupItem.FormShow(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmSelectBackupItem.FrameExcludebtnSelectFileClick(Sender: TObject);
var
  SelectPathList : TStringList;
begin
  SelectPathList := getSourcePathList;

  FrameFilter.SetRootPathList( SelectPathList );
  FrameFilter.FrameExclude.btnSelectFileClick(Sender);

  SelectPathList.Free;
end;

procedure TfrmSelectBackupItem.FrameIncludebtnSelectFileClick(Sender: TObject);
var
  SelectPathList : TStringList;
begin
  SelectPathList := getSourcePathList;

  FrameFilter.SetRootPathList( SelectPathList );
  FrameFilter.FrameInclude.btnSelectFileClick(Sender);

  SelectPathList.Free;
end;

function TfrmSelectBackupItem.getBackupConfigInfo: TBackupConfigInfo;
begin
  Result := TBackupConfigInfo.Create;
  Result.SetSyncInfo( ChkSyncTime.Checked, cbbSyncTime.ItemIndex, seSyncTime.Value );
  Result.SetIsBackupNow( chkSyncBackupNow.Checked );
  Result.SetEncryptInfo( chkIsEncrypt.Checked, edtEncPassword.Text, edtEncPasswordHint.Text );
  Result.SetDeleteInfo( chkIsKeepDeleted.Checked, seKeepEditionCount.Value );
  Result.SetIncludeFilterList( FrameFilter.getIncludeFilterList );
  Result.SetExcludeFilterList( FrameFilter.getExcludeFilterList );
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmSelectBackupItem.AddDesItem(DesItemID: string);
var
  SelectNode : PVirtualNode;
  LocalDesData : PLocalDesData;
  NetworkDesData : PNetworkDesData;
begin
  SelectNode := vstLocalDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    LocalDesData := vstLocalDes.GetNodeData( SelectNode );
    if LocalDesData.DesPath = DesItemID then
    begin
      vstLocalDes.CheckState[ SelectNode ] := csCheckedNormal;
      Exit;
    end;
    SelectNode := SelectNode.NextSibling;
  end;

  SelectNode := vstNetworkDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    NetworkDesData := vstNetworkDes.GetNodeData( SelectNode );
    if NetworkDesData.DesItemID = DesItemID then
    begin
      vstNetworkDes.CheckState[ SelectNode ] := csCheckedNormal;
      Exit;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TfrmSelectBackupItem.AddDesItemList(DesItemList: TStringList);
var
  i: Integer;
begin
  for i := 0 to DesItemList.Count - 1 do
    AddDesItem( DesItemList[i] );
end;

procedure TfrmSelectBackupItem.AddDriver(Path: string);
var
  RootNode : PVirtualNode;
  RootData : PShellObjectData;
  mi : TMenuItem;
begin
    // 磁盘不存在
  if not MyHardDisk.getDriverExist( Path ) then
    Exit;

  try
      // Virtual Tree
    RootNode := vstSelectPath.AddChild( vstSelectPath.RootNode );
    RootData := vstSelectPath.GetNodeData( RootNode );
    RootData.FullPath := Path;
    RootData.Display := Path;
    RootData.FileTime := MyFileInfo.getFileLastWriteTime( Path );
    RootData.IsFolder := True;
    Inc( SystemPath_DriverCount );

      // Local Destination
    mi := TMenuItem.Create(nil);
    mi.Caption := Path + 'BackupCow.LocalBackup';
    mi.ImageIndex := -1;
    mi.OnClick := PmLocalDesMiClick;
    pmLocalDes.Items.Add( mi );
  except
  end;
end;

function TfrmSelectBackupItem.AddFileNode(ParentNode: PVirtualNode;
  FileName: string): PVirtualNode;
var
  SelectNode, UpNode : PVirtualNode;
  SelectData : PShellObjectData;
begin
    // 寻找位置
  UpNode := nil;
  SelectNode := ParentNode.LastChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstSelectPath.GetNodeData( SelectNode );
    if ( SelectData.IsFolder ) or ( CompareText( FileName, SelectData.Display ) > 0 ) then
    begin
      UpNode := SelectNode;
      Break;
    end;
    SelectNode := SelectNode.PrevSibling;
  end;

    // 找到位置
  if Assigned( UpNode ) then
    Result := vstSelectPath.InsertNode( UpNode, amInsertAfter )
  else  // 添加到第一个位置
    Result := vstSelectPath.InsertNode( ParentNode, amAddChildFirst );
end;

function TfrmSelectBackupItem.AddFolderNode(ParentNode: PVirtualNode;
  FolderName: string): PVirtualNode;
var
  SelectNode, DownNode : PVirtualNode;
  SelectData : PShellObjectData;
begin
    // 寻找位置
  DownNode := nil;
  SelectNode := ParentNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstSelectPath.GetNodeData( SelectNode );
    if ( not SelectData.IsFolder ) or ( CompareText( SelectData.Display, FolderName ) > 0 ) then
    begin
      DownNode := SelectNode;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;

    // 找到位置
  if Assigned( DownNode ) then
    Result := vstSelectPath.InsertNode( DownNode, amInsertBefore )
  else  // 添加到第一个位置
    Result := vstSelectPath.AddChild( ParentNode );
end;

procedure TfrmSelectBackupItem.AddOtherPath(FolderPath: string);
var
  Node : PVirtualNode;
  NodeData : PShellObjectData;
begin
  OtherPathList.Add( FolderPath );
  
  Node := vstSelectPath.AddChild( vstSelectPath.RootNode );
  NodeData := vstSelectPath.GetNodeData( Node );
  NodeData.FullPath := FolderPath;
  NodeData.Display := ExtractFileName( FolderPath );
  NodeData.FileTime := MyFileInfo.getFileLastWriteTime( FolderPath );
  NodeData.IsFolder := True;
end;

procedure TfrmSelectBackupItem.AddOtherPaths;
begin
  AddOtherPath( MySystemPath.getDesktop );
  SystemPath_NetHood := MySystemPath.getNetworkFolder;
  AddOtherPath( SystemPath_NetHood );
  AddOtherPath( MySystemPath.getMyDoc ); 
end;

procedure TfrmSelectBackupItem.AddSourceItem(SourcePath: string);
var
  IsAdd : Boolean;
  ChildNode : PVirtualNode;
  NodeData : PShellObjectData;
  NodePath : string;
  NewNode : PVirtualNode;
begin
  IsAdd := False;
  if SelectBackupFormUtil.getIsOtherPath( SourcePath ) then
    ChildNode := SelectBackupFormUtil.getOtherFirstNode
  else
    ChildNode := vstSelectPath.RootNode.FirstChild;
  while Assigned( ChildNode ) do
  begin
    NodeData := vstSelectPath.GetNodeData( ChildNode );
    NodePath := NodeData.FullPath;

      // 找到了节点
    if SourcePath = NodePath then
    begin
      IsAdd := True;
      vstSelectPath.CheckState[ ChildNode ] := csCheckedNormal;
      Break;
    end;

      // 找到了父节点
    if MyMatchMask.CheckChild( SourcePath, NodePath ) then
    begin
      vstSelectPath.HasChildren[ ChildNode ] := True;
      vstSelectPath.CheckState[ ChildNode ] := csMixedNormal;
      vstSelectPath.ValidateChildren( ChildNode, False );
      ChildNode := ChildNode.FirstChild;
      Continue;
    end;

      // 下一个节点
    ChildNode := ChildNode.NextSibling;
  end;

    // 添加 成功
  if IsAdd then
    Exit;

    // 创建节点
  NewNode := vstSelectPath.AddChild( vstSelectPath.RootNode );
  vstSelectPath.CheckState[ NewNode ] := csCheckedNormal;
  NodeData := vstSelectPath.GetNodeData( NewNode );
  NodeData.FullPath := SourcePath;
  NodeData.Display := ExtractFileName( SourcePath );
  NodeData.FileTime := MyFileInfo.getFileLastWriteTime( SourcePath );
  NodeData.IsFolder := FileExists( SourcePath );  
end;

procedure TfrmSelectBackupItem.AddSourceItemList(SourcePathList: TStringList);
var
  i: Integer;
begin
  for i := 0 to SourcePathList.Count - 1 do
    AddSourceItem( SourcePathList[i] );
end;

procedure TfrmSelectBackupItem.btnAddClick(Sender: TObject);
var
  DestinationPath : string;
begin
  // 选择目录
  DestinationPath := MyHardDisk.getBiggestHardDIsk;
  if not MySelectFolderDialog.Select('Select your destination folder', '', DestinationPath) then
    Exit;
  DesItemUserApi.AddLocalItem( DestinationPath );
end;

procedure TfrmSelectBackupItem.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmSelectBackupItem.btnNextClick(Sender: TObject);
begin
  if PcMain.ActivePage = tsSelectDes then
  begin

  end;

  PcMain.ActivePageIndex := PcMain.ActivePageIndex + 1;
end;

procedure TfrmSelectBackupItem.btnOKClick(Sender: TObject);
begin
    // 收到条件限制
  if not getIsOK then
    Exit;

    // 添加 Item , 刷新默认配置
  if IsAddItem then
    RefreshDefaultParams;

  Close;
  ModalResult := mrOk;
end;


procedure TfrmSelectBackupItem.btnRemoveLocalDesClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  NodeData : PLocalDesData;
begin
  if not MyMessageBox.ShowRemoveComfirm then
    Exit;

  SelectNode := vstLocalDes.GetFirstSelected;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstLocalDes.GetNodeData( SelectNode );
    DesItemUserApi.RemoveLocalItem( NodeData.DesPath );
    SelectNode := vstLocalDes.GetNextSelected( SelectNode );
  end;
end;

procedure TfrmSelectBackupItem.CheckBtnOkEnable;
var
  IsEnable : Boolean;
begin
  IsEnable := ( vstSelectPath.CheckedCount > 0 ) and
              ( ( vstLocalDes.CheckedCount > 0 ) or ( vstNetworkDes.CheckedCount > 0 ) );

  btnOK.Enabled := IsEnable;
end;

procedure TfrmSelectBackupItem.chkIsEncryptClick(Sender: TObject);
var
  IsShow : Boolean;
  IsReset : Boolean;
begin
  IsShow := chkIsEncrypt.Checked;

  lbEncPassword.Enabled := IsShow;
  edtEncPassword.Enabled := IsShow;

  lbEncPassword2.Enabled := IsShow;
  edtEncPassword2.Enabled := IsShow;

  lbEncPasswordHint.Enabled := IsShow;
  edtEncPasswordHint.Enabled := IsShow;
end;

procedure TfrmSelectBackupItem.chkIsKeepDeletedClick(Sender: TObject);
begin
  seKeepEditionCount.Enabled := chkIsKeepDeleted.Checked;
end;

procedure TfrmSelectBackupItem.ChkSyncTimeClick(Sender: TObject);
var
  IsEnable : Boolean;
begin
  IsEnable := ChkSyncTime.Checked;
  seSyncTime.Enabled := IsEnable;
  cbbSyncTime.Enabled := IsEnable;
end;

procedure TfrmSelectBackupItem.DropFiles(var Msg: TMessage);
var
  SelectBackupDropFileHandle : TSelectBackupDropFileHandle;
begin
  SelectBackupDropFileHandle := TSelectBackupDropFileHandle.Create( Msg );
  SelectBackupDropFileHandle.Update;
  SelectBackupDropFileHandle.Free;

  FormUtil.ForceForegroundWindow( Handle );
end;

procedure TfrmSelectBackupItem.edtEncPassword2KeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_Return then
    selectnext(twincontrol(sender),true,true);
end;

procedure TfrmSelectBackupItem.edtEncPasswordKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_Return then
    selectnext(twincontrol(sender),true,true);
end;

procedure TfrmSelectBackupItem.RefreshDefaultParams;
begin
    // Auto Backup
  DefaultParams.IsAutoSync := ChkSyncTime.Checked;
  DefaultParams.SyncType := cbbSyncTime.ItemIndex;
  DefaultParams.SyncValue := seSyncTime.Value;
  DefaultParams.IsBackupNow := chkSyncBackupNow.Checked;

    // Save Delete
  DefaultParams.IsSaveDeleted := chkIsKeepDeleted.Checked;
  DefaultParams.SaveEdition := seKeepEditionCount.Value;

    // Encrypted Setting
  DefaultParams.IsEncrypted := chkIsEncrypt.Checked;
  DefaultParams.Password := edtEncPassword.Text;
  DefaultParams.PasswrodHint := edtEncPasswordHint.Text;
end;

procedure TfrmSelectBackupItem.RemoveDriver(Path: string);
var
  SelectNode : PVirtualNode;
  NodeData : PShellObjectData;
  mi : TMenuItem;
  i: Integer;
begin
  try
      // Virtual Tree
    SelectNode := vstSelectPath.RootNode.FirstChild;
    while Assigned( SelectNode ) do
    begin
      NodeData := vstSelectPath.GetNodeData( SelectNode );
      if NodeData.FullPath = Path then
      begin
        vstSelectPath.DeleteNode( SelectNode );
        Break;
      end;
      SelectNode := SelectNode.NextSibling;
    end;

      // PmLocalDes
    for i := 0 to pmLocalDes.Items.Count - 1 do
    begin
      mi := pmLocalDes.Items[i];
      if MyMatchMask.CheckEqualsOrChild( mi.Caption, Path ) then
      begin
        pmLocalDes.Items.Delete(i);
        mi.Free;
        Break;
      end;
    end;
  except
  end;
end;

procedure TfrmSelectBackupItem.ResetSettings;
begin
  FrameFilter.IniFrame;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmSelectBackupItem.FindSourcePathList(Node: PVirtualNode;
  SourcePathList : TStringList);
var
  ChildNode : PVirtualNode;
  NodeData : PShellObjectData;
begin
  ChildNode := Node.FirstChild;
  while Assigned( ChildNode ) do
  begin
    if ( ChildNode.CheckState = csCheckedNormal ) then  // 找到选择的路径
    begin
      NodeData := vstSelectPath.GetNodeData( ChildNode );
      SourcePathList.Add( NodeData.FullPath );
    end
    else
    if ChildNode.CheckState = csMixedNormal then  // 找下一层
      FindSourcePathList( ChildNode, SourcePathList );
    ChildNode := ChildNode.NextSibling;
  end;
end;

function TfrmSelectBackupItem.getIsOK: Boolean;
var
  IsError : Boolean;
  ErrorStr : string;
begin
  Result := False;

    // 没有选择 备份源
  if IsAddItem and ( vstSelectPath.CheckedCount = 0 ) then
  begin
    MyMessageBox.ShowWarnning( 'Please select backup Source.' );
    PcMain.ActivePage := TsSelectFile;
    Exit;
  end;

    // 没有选择 备份目标
  if IsAddItem and ( vstLocalDes.CheckedCount = 0 ) and ( vstNetworkDes.CheckedCount = 0 ) then
  begin
    MyMessageBox.ShowWarnning( 'Please select backup Destination.' );
    PcMain.ActivePage := tsSelectDes;
    Exit;
  end;

    // 加密设置异常
  if chkIsEncrypt.Checked then
  begin
    IsError := True;
    if edtEncPassword.Text = '' then
      ErrorStr := 'Please Input Password.'
    else
    if edtEncPassword.Text <> edtEncPassword2.Text then
      ErrorStr := 'Password and Retype Password are not matched'
    else
      IsError := False;
    if IsError then
    begin
      MyMessageBox.ShowWarnning( ErrorStr );
      PcMain.ActivePage := TsGenernal;
      lbReqEncPassword.Visible := True;
      lbReqEncPassword2.Visible := True;
      Exit;
    end;
  end;

  Result := True;
end;

function TfrmSelectBackupItem.getLocalDesList: TStringList;
var
  SelectNode : PVirtualNode;
  NodeData : PLocalDesData;
begin
  Result := TStringList.Create;

  SelectNode := vstLocalDes.GetFirstChecked;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstLocalDes.GetNodeData( SelectNode );
    Result.Add( NodeData.DesPath );
    SelectNode := vstLocalDes.GetNextChecked( SelectNode );
  end;
end;

function TfrmSelectBackupItem.getNetworkDesList: TStringList;
var
  SelectNode : PVirtualNode;
  NodeData : PNetworkDesData;
begin
  Result := TStringList.Create;

  SelectNode := vstNetworkDes.GetFirstChecked;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstNetworkDes.GetNodeData( SelectNode );
    Result.Add( NodeData.DesItemID );
    SelectNode := vstNetworkDes.GetNextChecked( SelectNode );
  end;
end;


function TfrmSelectBackupItem.getSourcePathList: TStringList;
begin
  Result := TStringList.Create;
  FindSourcePathList( vstSelectPath.RootNode, Result );
end;

procedure TfrmSelectBackupItem.LoadIni;
var
  IniFile : TIniFile;
  EncPassword : string;
begin
  IniFile := TIniFile.Create( MyIniFile.getIniFilePath );

    // Auto Backup
  DefaultParams.IsAutoSync := IniFile.ReadBool( Self.Name, ChkSyncTime.Name, True );
  DefaultParams.SyncType := IniFile.ReadInteger( Self.Name, cbbSyncTime.Name, 1 );
  DefaultParams.SyncValue := IniFile.ReadInteger( Self.Name, seSyncTime.Name, 1 );
  DefaultParams.IsBackupNow := IniFile.ReadBool( Self.Name, chkSyncBackupNow.Name, True );

    // Save Delete
  DefaultParams.IsSaveDeleted := IniFile.ReadBool( Self.Name, chkIsKeepDeleted.Name, True );
  DefaultParams.SaveEdition := IniFile.ReadInteger( Self.Name, seKeepEditionCount.Name, 5 );

    // Encrypted Setting
  DefaultParams.IsEncrypted := IniFile.ReadBool( Self.Name, chkIsEncrypt.Name, False );
  EncPassword := IniFile.ReadString( Self.Name, edtEncPassword.Name, '' );
  DefaultParams.Password := MyEncrypt.DecodeStr( EncPassword );
  DefaultParams.PasswrodHint := IniFile.ReadString( Self.Name, edtEncPasswordHint.Name, '' );

  IniFile.Free;
end;

procedure TfrmSelectBackupItem.Panel9Click(Sender: TObject);
begin
  MyExplore.OpenFolder( MySystemPath.getMyDoc );
end;

procedure TfrmSelectBackupItem.PcMainPageChange(Sender: TObject);
begin
  btnNext.Enabled := PcMain.ActivePage <> TsInclude;
end;

procedure TfrmSelectBackupItem.PmLocalDesMiClick(Sender: TObject);
var
  mi : TMenuItem;
begin
  mi := Sender as TMenuItem;
  DesItemUserApi.AddLocalItem( mi.Caption );
end;

procedure TfrmSelectBackupItem.SaveIni;
var
  IniFile : TIniFile;
  EncPassword : string;
begin
    // 没有权限写
  if not MyIniFile.ConfirmWriteIni then
    Exit;

  IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  try
      // Auto Backup
    IniFile.WriteBool( Self.Name, ChkSyncTime.Name, DefaultParams.IsAutoSync );
    IniFile.WriteInteger( Self.Name, cbbSyncTime.Name, DefaultParams.SyncType );
    IniFile.WriteInteger( Self.Name, seSyncTime.Name, DefaultParams.SyncValue );
    IniFile.WriteBool( Self.Name, chkSyncBackupNow.Name, DefaultParams.IsBackupNow );

      // Save Delete
    IniFile.WriteBool( Self.Name, chkIsKeepDeleted.Name, DefaultParams.IsSaveDeleted );
    IniFile.WriteInteger( Self.Name, seKeepEditionCount.Name, DefaultParams.SaveEdition );

      // Encrypted Setting
    EncPassword := MyEncrypt.EncodeStr( DefaultParams.Password );
    IniFile.WriteBool( Self.Name, chkIsEncrypt.Name, DefaultParams.IsEncrypted );
    IniFile.WriteString( Self.Name, edtEncPassword.Name, EncPassword );
    IniFile.WriteString( Self.Name, edtEncPasswordHint.Name, DefaultParams.PasswrodHint );
  except
  end;
  IniFile.Free;
end;

procedure TfrmSelectBackupItem.SetUnCheckDes;
var
  SelectNode : PVirtualNode;
begin
  SelectNode := vstLocalDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    vstLocalDes.CheckState[ SelectNode ] := csUncheckedNormal;
    SelectNode := SelectNode.NextSibling;
  end;

  SelectNode := vstNetworkDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    vstNetworkDes.CheckState[ SelectNode ] := csUncheckedNormal;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TfrmSelectBackupItem.SetUnCheckedSource(Node: PVirtualNode);
var
  ChildNode : PVirtualNode;
  NodeData : PShellObjectData;
begin
  ChildNode := Node.FirstChild;
  while Assigned( ChildNode ) do
  begin
    if ChildNode.CheckState <> csUncheckedNormal then
    begin
      ChildNode.CheckState := csUncheckedNormal;
      SetUnCheckedSource( ChildNode );
    end;
    ChildNode := ChildNode.NextSibling;
  end;
end;

function TfrmSelectBackupItem.ShowAddItem( DesItemList, SourceItemList : TStringList ): Boolean;
var
  ReadDefaultSettings : TReadDefaultSettings;
begin
  TsGenernal.TabVisible := True;
  TsInclude.TabVisible := True;

  IsAddItem := True;
  Self.Caption := FormCaption_AddItem;
  ilPcMain16.GetIcon( FormIcon_AddItem, Self.Icon );

    // 设置显示信息
  TsSelectFile.TabVisible := True;
  tsSelectDes.TabVisible := True;
  btnNext.Visible := True;

    // 读取默认配置
  ReadDefaultSettings := TReadDefaultSettings.Create;
  ReadDefaultSettings.Update;
  ReadDefaultSettings.Free;

    // 添加默认选择的
  AddSourceItemList( SourceItemList );
  AddDesItemList( DesItemList );

    // 已选择的源路径
  if SourceItemList.Count > 0 then
  begin
      // 已选择目标
    if DesItemList.Count > 0 then
      PcMain.ActivePage := TsGenernal
    else
      PcMain.ActivePage := tsSelectDes;
  end
  else   // 没有选择路径
    PcMain.ActivePage := TsSelectFile;

    // 检测是否已选中
  CheckBtnOkEnable;

    // 返回是否OK
  Result := ShowModal = mrOk;
end;

function TfrmSelectBackupItem.ShowItemProperies( SourcePath : string; IsFile : Boolean;
  BackupConfigInfo : TBackupConfigInfo ): Boolean;
var
  ReadConfigSetttings : TReadConfigSetttings;
begin
    // 文件不显示 Filter
  TsGenernal.TabVisible := not IsFile;
  TsInclude.TabVisible := not IsFile;

  IsAddItem := False;
  Self.Caption := Format( FormCaption_ItemProperties, [ MyFileInfo.getFileName( SourcePath ) ] );
  ilPcMain16.GetIcon( FormIcon_ItemProperties, Self.Icon );

    // 设置显示信息
  TsSelectFile.TabVisible := False;
  tsSelectDes.TabVisible := False;
  btnNext.Visible := False;
  PcMain.ActivePage := TsGenernal;

    // 读取配置信息
  ReadConfigSetttings := TReadConfigSetttings.Create( BackupConfigInfo );
  ReadConfigSetttings.Update;
  ReadConfigSetttings.Free;

    // 添加源
  AddSourceItem( SourcePath );

    // 关闭按钮
  BtnOK.Enabled := True;

    // 返回是否OK
  Result := ShowModal = mrOk;
end;

procedure TfrmSelectBackupItem.tbtnDesManualClick(Sender: TObject);
var
  InputPath : string;
begin
  edtPaste.PasteFromClipboard;
  InputPath := edtPaste.Text;
  if ( InputPath <> '' ) and ( not DirectoryExists( InputPath ) ) then
    InputPath := '';
  if not InputQuery( 'Manually Input', 'Folder Name', InputPath ) then
    Exit;

  if not DirectoryExists( InputPath ) then
  begin
    MyMessageBox.ShowWarnning( InputPath + ' does not exist.' );
    Exit;
  end;

  DesItemUserApi.AddLocalItem( InputPath );
end;

procedure TfrmSelectBackupItem.tbtnManuallyClick(Sender: TObject);
var
  InputPath : string;
begin
  edtPaste.PasteFromClipboard;
  InputPath := edtPaste.Text;
  if ( InputPath <> '' ) and ( not FileExists( InputPath ) and not DirectoryExists( InputPath ) ) then
    InputPath := '';
  if not InputQuery( 'Manually Input', 'File or Folder Name', InputPath ) then
    Exit;

  if not FileExists( InputPath ) and not DirectoryExists( InputPath ) then
  begin
    MyMessageBox.ShowWarnning( InputPath + ' does not exist.' );
    Exit;
  end;

  AddSourceItem( InputPath );
end;

procedure TfrmSelectBackupItem.tbtnRefreshClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  IsExpanded : Boolean;
begin
  SelectNode := vstSelectPath.FocusedNode;
  if not Assigned( SelectNode ) then
    Exit;
  IsExpanded := vstSelectPath.Expanded[ SelectNode ];
  vstSelectPath.DeleteChildren( SelectNode );
  vstSelectPath.InvalidateChildren( SelectNode, False );
  vstSelectPath.Expanded[ SelectNode ] := IsExpanded;
end;

procedure TfrmSelectBackupItem.tbtnSelectFileClick(Sender: TObject);
var
  i : Integer;
begin
  if not FileDialog.Execute then
    Exit;

  for i := 0 to FileDialog.Files.Count - 1 do
    AddSourceItem( FileDialog.Files[i] );
end;

var
  Path_SelectBackupFolder : string = '';
procedure TfrmSelectBackupItem.tbtnSelectFolderClick(Sender: TObject);
begin
  if not MySelectFolderDialog.SelectNormal( ShowForm_SelectBackupFolder, '', Path_SelectBackupFolder ) then
    Exit;
  AddSourceItem( Path_SelectBackupFolder );
end;

procedure TfrmSelectBackupItem.tbtnUnSelectClick(Sender: TObject);
begin
  tbtnUnSelect.Enabled := False;
  SetUnCheckedSource( vstSelectPath.RootNode );
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmSelectBackupItem.vdtBackupFolderHeaderClick(Sender: TVTHeader; Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);

// Click handler to switch the column on which will be sorted. Since we cannot sort image data sorting is actually
// limited to the main column.

begin
  if Button = mbLeft then
  begin
    with Sender do
    begin
      if Column <> MainColumn then
        SortColumn := NoColumn
      else
      begin
        if SortColumn = NoColumn then
        begin
          SortColumn := Column;
          SortDirection := sdAscending;
        end
        else
          if SortDirection = sdAscending then
            SortDirection := sdDescending
          else
            SortDirection := sdAscending;
        Treeview.SortTree(SortColumn, SortDirection, False);
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmSelectBackupItem.vstLocalDesChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  tbtnRemove.Enabled := Sender.SelectedCount > 0;
end;

procedure TfrmSelectBackupItem.vstLocalDesChecked(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  CheckBtnOkEnable;
end;

procedure TfrmSelectBackupItem.vstLocalDesGetImageIndex(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind;
  Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData : PLocalDesData;
begin
  if ( Column = VstSelectDes_ComputerName ) and
     ( ( Kind = ikNormal ) or ( Kind = ikSelected ) )
  then
  begin
    NodeData := Sender.GetNodeData( Node );
    ImageIndex := NodeData.MainIcon;
  end
  else
    ImageIndex := -1;
end;

procedure TfrmSelectBackupItem.vstLocalDesGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  NodeData : PLocalDesData;
begin
  NodeData := Sender.GetNodeData( Node );
  if Column = VstSelectDes_ComputerName then
    CellText := NodeData.DesPath
  else
  if Column = VstSelectDes_AvailableSpace then
    CellText := MySize.getFileSizeStr( NodeData.AvailaleSpace )
  else
    CellText := '';
end;

procedure TfrmSelectBackupItem.vstNetworkDesChecked(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  CheckBtnOkEnable;
end;

procedure TfrmSelectBackupItem.vstNetworkDesGetImageIndex(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind;
  Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData : PNetworkDesData;
begin
  if ( Column = VstSelectDes_ComputerName ) and
     ( ( Kind = ikNormal ) or ( Kind = ikSelected ) )
  then
  begin
    NodeData := Sender.GetNodeData( Node );
    ImageIndex := NodeData.MainIcon;
  end
  else
    ImageIndex := -1;
end;

procedure TfrmSelectBackupItem.vstNetworkDesGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  NodeData : PNetworkDesData;
begin
  NodeData := Sender.GetNodeData( Node );
  if Column = VstSelectDes_ComputerName then
    CellText := NodeData.DesItemName
  else
  if Column = VstSelectDes_AvailableSpace then
  begin
    if NodeData.IsOnline then
      CellText := MySize.getFileSizeStr( NodeData.AvailaleSpace )
    else
      CellText := 'Offline';
  end
  else
    CellText := '';
end;


procedure TfrmSelectBackupItem.vstSelectPathChecked(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  tbtnUnSelect.Enabled := Sender.CheckedCount > 0;
  CheckBtnOkEnable;
end;

procedure TfrmSelectBackupItem.vstSelectPathFocusChanged(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
var
  IsShowRefresh : Boolean;
  NodeData : PShellObjectData;
begin
  IsShowRefresh := False;
  if Assigned( Node ) then
  begin
    NodeData := Sender.GetNodeData( Node );
    IsShowRefresh := NodeData.IsFolder
  end;
  tbtnRefresh.Enabled := IsShowRefresh;
end;

procedure TfrmSelectBackupItem.vstSelectPathFreeNode(
  Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  Data: PShellObjectData;
begin
  Data := Sender.GetNodeData(Node);
  Finalize(Data^); // Clear string data.
end;


procedure TfrmSelectBackupItem.vstSelectPathGetImageIndex(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind;
  Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
var
  Data: PShellObjectData;
begin
  if ( Column = 0 ) and
     ( ( Kind = ikNormal ) or ( Kind = ikSelected ) )
  then
  begin
    Data := Sender.GetNodeData(Node);
    ImageIndex := data.DisplayIcon;
  end
  else
    ImageIndex := -1;
end;

procedure TfrmSelectBackupItem.vstSelectPathGetText(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType; var CellText: String);
var
  Data: PShellObjectData;
begin
  Data := Sender.GetNodeData( Node );

  if Column = VstSelectBackupPath_FileName then
    CellText := Data.Display
  else
  if Column = VstSelectBackupPath_FileSize then
  begin
    if Data.IsFolder then
      CellText := ''
    else
     CellText := MySize.getFileSizeStr( Data.FileSize )
  end
  else
  if Column = VstSelectBackupPath_FileTime then
    CellText := DateTimeToStr( Data.FileTime )
  else
    CellText := '';
end;

procedure TfrmSelectBackupItem.vstSelectPathInitChildren(
  Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
var
  IsNetHood : Boolean;
  Data, ChildData: PShellObjectData;
  sr: TSearchRec;
  FullPath, FileName, FilePath : string;
  ChildNode: PVirtualNode;
  LastWriteTimeSystem: TSystemTime;
begin
  Screen.Cursor := crHourGlass;

    // 搜索目录的信息，找不到则跳过
  Data := Sender.GetNodeData(Node);
  IsNetHood := Data.FullPath = SystemPath_NetHood;
  FullPath := MyFilePath.getPath( Data.FullPath );
  if FindFirst( FullPath + '*', faAnyfile, sr ) = 0 then
  begin
    repeat
      FileName := sr.Name;
      if ( FileName = '.' ) or ( FileName = '..' ) then
        Continue;

        // 子路径
      FilePath := FullPath + FileName;

        // 特殊的路径
      if OtherPathList.IndexOf( FilePath ) >= 0 then
        Continue;

        // 子节点数据
      if DirectoryExists( FilePath ) then
        ChildNode := AddFolderNode( Node, FileName )
      else
        ChildNode := AddFileNode( Node, FileName );
      ChildData := Sender.GetNodeData(ChildNode);
      if IsNetHood then
        ChildData.FullPath := MyFilePath.getLinkPath( FilePath )
      else
        ChildData.FullPath := FilePath;
      ChildData.Display := MyFileInfo.getFileName( FilePath );
      if DirectoryExists( FilePath ) then
        ChildData.IsFolder := True
      else
      begin
        ChildData.IsFolder := False;
        ChildData.FileSize := sr.Size
      end;
      FileTimeToSystemTime( sr.FindData.ftLastWriteTime, LastWriteTimeSystem );
      LastWriteTimeSystem.wMilliseconds := 0;
      ChildData.FileTime := SystemTimeToDateTime( LastWriteTimeSystem );
      ChildData.FileTime := TTimeZone.Local.ToLocalTime( ChildData.FileTime );

        // 初始化
      if Node.CheckState = csCheckedNormal then   // 如果父节点全部Check, 则子节点 check
        ChildNode.CheckState := csCheckedNormal;
      Sender.ValidateNode(ChildNode, False);

        // 子节点数目
      Inc( ChildCount );

    until FindNext(sr) <> 0;
  end;
  FindClose(sr);
  Screen.Cursor := crDefault;
end;


procedure TfrmSelectBackupItem.vstSelectPathInitNode(
  Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode;
  var InitialStates: TVirtualNodeInitStates);
var
  Data: PShellObjectData;
begin
  Data := Sender.GetNodeData(Node);
  Data.DisplayIcon := MyIcon.getIconByFilePath( Data.FullPath );

  if MyFilePath.getHasChild( Data.FullPath ) then
    Include(InitialStates, ivsHasChildren);

  Node.CheckType := ctTriStateCheckBox;
end;

procedure TfrmSelectBackupItem.WMDeviceChange(var Msg: TMessage);
var
  IsDriverChanged : Boolean;
  DriverList : TStringList;
  i, DriverIndex: Integer;
begin
  IsDriverChanged := ( Msg.WParam = 32768 ) or ( Msg.WParam = 32772 );
  if not IsDriverChanged then  // 驱动器变化
    Exit;

    // 比较前后驱动器
  DriverList := MyHardDisk.getPathList;
  try
    for i := 0 to DriverList.Count - 1 do
    begin
      DriverIndex := LastDriverList.IndexOf( DriverList[i] );
      if DriverIndex < 0 then
        AddDriver( DriverList[i] )
      else
        LastDriverList.Delete( DriverIndex );
    end;
    for i := LastDriverList.Count - 1 downto 0 do
      RemoveDriver( LastDriverList[i] );
  except
  end;
    // 刷新信息
  LastDriverList.Free;
  LastDriverList := DriverList;
end;


//----------------------------------------------------------------------------------------------------------------------


{ TReadDefaultSettings }

procedure TReadDefaultSettings.Update;
begin
  try
    with frmSelectBackupItem do
    begin
        // 取消以前选择的源
      SetUnCheckedSource( vstSelectPath.RootNode );

        // 取消以前选择的目标
      SetUnCheckDes;

        // Backup Settings
      ChkSyncTime.Checked := DefaultParams.IsAutoSync;
      cbbSyncTime.ItemIndex := DefaultParams.SyncType;
      seSyncTime.Value := DefaultParams.SyncValue;
      chkSyncBackupNow.Checked := DefaultParams.IsBackupNow;

        // Keep Deleted Settings
      chkIsKeepDeleted.Checked := DefaultParams.IsSaveDeleted;
      seKeepEditionCount.Value := DefaultParams.SaveEdition;

        // Encrypt Settings
      chkIsEncrypt.Checked := DefaultParams.IsEncrypted;
      edtEncPassword.Text := DefaultParams.Password;
      edtEncPassword2.Text := DefaultParams.Password;
      edtEncPasswordHint.Text := DefaultParams.PasswrodHint;
      lbReqEncPassword.Visible := False;
      lbReqEncPassword2.Visible := False;

        // Filter Settins
      FrameFilter.SetDefaultStatus;
    end;
  except
  end;
end;

{ TReadConfigSetttings }

constructor TReadConfigSetttings.Create(_BackupConfigInfo: TBackupConfigInfo);
begin
  BackupConfigInfo := _BackupConfigInfo;
end;

procedure TReadConfigSetttings.Update;
begin
  with frmSelectBackupItem do
  begin
      // 取消上次选择的源
    SetUnCheckedSource( vstSelectPath.RootNode );

      // 取消上次选择的目标
    SetUnCheckDes;

      // Backup Settings
    ChkSyncTime.Checked := BackupConfigInfo.IsAuctoSync;
    seSyncTime.Value := BackupConfigInfo.SyncTimeValue;
    cbbSyncTime.ItemIndex := BackupConfigInfo.SyncTimeType;
    chkSyncBackupNow.Checked := BackupConfigInfo.IsBackupupNow;

      // Encrypt Settings
    chkIsEncrypt.Checked := BackupConfigInfo.IsEncrypt;
    edtEncPassword.Text := BackupConfigInfo.Password;
    edtEncPassword2.Text := BackupConfigInfo.Password;
    edtEncPasswordHint.Text := BackupConfigInfo.PasswordHint;

      // Keep Deleted Settings
    chkIsKeepDeleted.Checked := BackupConfigInfo.IsKeepDeleted;
    seKeepEditionCount.Value := BackupConfigInfo.KeepEditionCount;

      // Filter Settings
    FrameFilter.SetClearMask;
    FrameFilter.SetIncludeFilterList( BackupConfigInfo.IncludeFilterList );
    FrameFilter.SetExcludeFilterList( BackupConfigInfo.ExcludeFilterList );
  end;
end;

{ FormUtil }


class function SelectBackupFormUtil.getIsOtherPath(SourcePath: string): Boolean;
var
  OtherPathList : TStringList;
  i : Integer;
begin
  Result := False;

  OtherPathList := frmSelectBackupItem.OtherPathList;
  for i := 0 to OtherPathList.Count - 1 do
    if MyMatchMask.CheckEqualsOrChild( SourcePath, OtherPathList[i] ) then
    begin
      Result := True;
      Break;
    end;
end;


class function SelectBackupFormUtil.getOtherFirstNode: PVirtualNode;
var
  SelectNode : PVirtualNode;
  i: Integer;
begin
  with frmSelectBackupItem do
  begin
    Result := vstSelectPath.RootNode.FirstChild;
    for i := 0 to SystemPath_DriverCount - 1 do
    begin
      if not Assigned( Result ) then
        Break;
      Result := Result.NextSibling;
    end;
  end;
end;

{ TSelectBackupDropFileHandle }

procedure TSelectBackupDropFileHandle.AddBackupDestination;
var
  i : Integer;
begin
  for i := 0 to FilePathList.Count - 1 do
    if not FileExists( FilePathList[i] ) then
      DesItemUserApi.AddLocalItem( FilePathList[i] );
end;

procedure TSelectBackupDropFileHandle.AddBackupSource;
var
  i : Integer;
begin
  for i := 0 to FilePathList.Count - 1 do
    frmSelectBackupItem.AddSourceItem( FilePathList[i] );
end;

constructor TSelectBackupDropFileHandle.Create(_Msg: TMessage);
begin
  Msg := _Msg;
  FilePathList := TStringList.Create;
end;

destructor TSelectBackupDropFileHandle.Destroy;
begin
  FilePathList.Free;
  inherited;
end;

procedure TSelectBackupDropFileHandle.FindDropFileType;
begin
  with frmSelectBackupItem do
  begin
    if PcMain.ActivePage = TsSelectFile then
      DropFileType := DropFileType_BackupSource
    else
    if PcMain.ActivePage = tsSelectDes then
      DropFileType := DropFileType_BackupDestination
    else
      DropFileType := '';
  end;
end;

procedure TSelectBackupDropFileHandle.FindFilePathList;
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

procedure TSelectBackupDropFileHandle.Update;
begin
  FindFilePathList;
  FindDropFileType;

  if DropFileType = DropFileType_BackupSource then
    AddBackupSource
  else
  if DropFileType = DropFileType_BackupDestination then
    AddBackupDestination;
end;

end.
