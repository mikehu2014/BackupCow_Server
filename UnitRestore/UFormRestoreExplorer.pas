unit UFormRestoreExplorer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, VirtualTrees, Vcl.StdCtrls,UMyRestoreApiInfo,
  Generics.Collections, RzTabs, Vcl.ImgList, StrUtils, Vcl.ComCtrls, UModelUtil, UFileBaseInfo,
  Vcl.ToolWin;

type

  TRestoreSelectParams = record
  public
    RestorePath : string;
    IsFile : Boolean;
    OwnerID, OwnerName : string;
    RestoreFrom, RestoreFromName : string;
    IsLocal, HasDeleted, IsEncrypted : Boolean;
    PasswordExt, Password : string;
  public
    FileSize : Int64;
  end;

      // 恢复子路径
  TRestoreSelectInfo = class
  public
    FilePath : string;
    IsFile : Boolean;
    FileCount : Integer;
    FileSize : Int64;
  public
    IsDeleted : Boolean;
    EditionNum : Integer;
  public
    constructor Create( _FilePath : string; _IsFile : Boolean );
    procedure SetFileInfo( _FileCount : Integer; _FileSize : Int64 );
    procedure SetDeletedInfo( _IsDeleted : Boolean; _EditionNum : Integer );
  end;
  TRestoreSelectList = class( TObjectList< TRestoreSelectInfo > );

    // 其他版本信息
  TRestoreOtherEdition = class
  public
    FilePath : string;
    EditionNum : Integer;
    ParentNode : PVirtualNode;
  public
    constructor Create( _FilePath : string; _EditionNum : Integer );
    procedure SetParentNode( _ParentNode : PVirtualNode );
  end;
  TRestoreOtherEditionPair = TPair<string,TRestoreOtherEdition>;
  TRestoreOtherEditionHash = class( TStringDictionary<TRestoreOtherEdition> )end;

  TfrmRestoreExplorer = class(TForm)
    Panel1: TPanel;
    tmrExploring: TTimer;
    PcMain: TRzPageControl;
    tsExplorer: TRzTabSheet;
    tsDeletedFile: TRzTabSheet;
    tsSearchFile: TRzTabSheet;
    ilPcMain: TImageList;
    Panel2: TPanel;
    btnCancel: TButton;
    btnOK: TButton;
    tmrSearching: TTimer;
    tmrStop: TTimer;
    tmrExploringDeleted: TTimer;
    plExplorer: TPanel;
    pbExplorer: TProgressBar;
    plStatus: TPanel;
    Image1: TImage;
    lbStatus: TLabel;
    tbExplorer: TToolBar;
    tbtnPreview: TToolButton;
    tbtnSplit: TToolButton;
    tbtnLeft: TToolButton;
    tbtnRight: TToolButton;
    tbtnSelect: TToolButton;
    vstExplorer: TVirtualStringTree;
    ilTb: TImageList;
    ilTbGray: TImageList;
    plRecycled: TPanel;
    pbExplorerDelete: TProgressBar;
    plDeletedStatus: TPanel;
    Image2: TImage;
    lbDeleteStatus: TLabel;
    vstDeleteFile: TVirtualStringTree;
    tbRecycled: TToolBar;
    tbtnRecyclePreview: TToolButton;
    tbtnRecycleSplit: TToolButton;
    tbtnRecycleLeft: TToolButton;
    tbtnRecycleRight: TToolButton;
    tbtnRecycleSelect: TToolButton;
    plRestoreSearch: TPanel;
    pbSearch: TProgressBar;
    plSearch: TPanel;
    btnSearch: TButton;
    btnStopSearch: TButton;
    plSearchStatus: TPanel;
    Image3: TImage;
    lbSearchStatus: TLabel;
    vstSearchFile: TVirtualStringTree;
    tbSearch: TToolBar;
    tbtnSearchPreview: TToolButton;
    tbtnSearchSplit: TToolButton;
    tbtnSearchLeft: TToolButton;
    tbtnSearchRight: TToolButton;
    tbtnSearchSelect: TToolButton;
    cbbSearchName: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure vstExplorerGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstExplorerGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstExplorerInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure vstExplorerInitChildren(Sender: TBaseVirtualTree;
      Node: PVirtualNode; var ChildCount: Cardinal);
    procedure btnCancelClick(Sender: TObject);
    procedure vstExplorerChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure btnOKClick(Sender: TObject);
    procedure tmrExploringTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure vstDeleteFileGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstDeleteFileGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstDeleteFileInitChildren(Sender: TBaseVirtualTree;
      Node: PVirtualNode; var ChildCount: Cardinal);
    procedure btnSearchClick(Sender: TObject);
    procedure vstSearchFileGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstSearchFileGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure edtSearchKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure vstSearchFileMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure tmrSearchingTimer(Sender: TObject);
    procedure btnStopSearchClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tmrStopTimer(Sender: TObject);
    procedure vstSearchFileInitChildren(Sender: TBaseVirtualTree;
      Node: PVirtualNode; var ChildCount: Cardinal);
    procedure tmrExploringDeletedTimer(Sender: TObject);
    procedure vstExplorerPaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType);
    procedure vstDeleteFileInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure vstDeleteFileChecked(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure FormDestroy(Sender: TObject);
    procedure vstDeleteFileGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; var LineBreakStyle: TVTTooltipLineBreakStyle;
      var HintText: string);
    procedure vstSearchFileInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure vstSearchFileChecked(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure vstExplorerFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure tbtnPreviewClick(Sender: TObject);
    procedure tbtnLeftClick(Sender: TObject);
    procedure tbtnRightClick(Sender: TObject);
    procedure tbtnSelectClick(Sender: TObject);
    procedure tbtnRecyclePreviewClick(Sender: TObject);
    procedure tbtnRecycleLeftClick(Sender: TObject);
    procedure tbtnRecycleRightClick(Sender: TObject);
    procedure tbtnRecycleSelectClick(Sender: TObject);
    procedure vstDeleteFileFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure tbtnSearchPreviewClick(Sender: TObject);
    procedure tbtnSearchLeftClick(Sender: TObject);
    procedure tbtnSearchRightClick(Sender: TObject);
    procedure tbtnSearchSelectClick(Sender: TObject);
    procedure vstSearchFileFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure cbbSearchNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    procedure SaveIni;
    procedure LoadIni;
    procedure AddSearchHistory( FileName : string );
  public
    procedure ShowPreviewForm;
    procedure ClosePreviewForm;
    procedure ShowPreiveBtn( IsShow : Boolean );
    procedure ShowPreview( FilePath : string; IsDeleted : Boolean; EditionNum : Integer );
  private
    Params : TRestoreSelectParams;
    ExplorerParams : TRestoreExplorerParams;
    SearchParams : TRestoreSearchParams;
    PreviewParams : TRestorePreviewParams;
  private
    RestoreOtherEditionHash : TRestoreOtherEditionHash;
  public
    function getIsRestore( _Params : TRestoreSelectParams ): Boolean;
    function getSelectPathList : TRestoreSelectList;
    function getFileEditionList : TFileEditionList;
  private
    procedure AddRootNode;
    procedure AddRootDeleteNode;
  private
    procedure ExplorerAction;
    procedure Explorer( Path : string );
    procedure ExplorerDelete( Path : string );
    procedure ExplorerSearch( Path : string; IsDeleted : Boolean );
  private
    function getSavePath : string;
    procedure FindSelectNode( Node : PVirtualNode; PathList : TRestoreSelectList );
    procedure FindDeleteNode( Node : PVirtualNode; PathList : TRestoreSelectList );
    procedure FindSearchNode( Node : PVirtualNode; PathList : TRestoreSelectList );
  end;

const
  VstExplorer_FileName = 0;
  VstExplorer_FileSize = 1;
  VstExplorer_FileTime = 2;
  VstExplorer_Recycled = 3;

var
  frmRestoreExplorer: TfrmRestoreExplorer;

implementation

uses UMyRestoreFaceInfo, UIconUtil, UMyUtil,  UFormSelectRestore, URestoreThread, UFormPreview,
     UMainForm, inifiles;

{$R *.dfm}

procedure TfrmRestoreExplorer.AddRootDeleteNode;
var
  ExplorerNode : PVirtualNode;
  NodeData : PVstRestoreDeleteExplorerData;
begin
    // 添加第一个节点
  ExplorerNode := vstDeleteFile.AddChild( vstDeleteFile.RootNode );
  NodeData := vstDeleteFile.GetNodeData( ExplorerNode );
  NodeData.FilePath := Params.RestorePath;
  NodeData.IsFile := Params.IsFile;
  NodeData.ShowName := Params.RestorePath;
  NodeData.ShowIcon := MyShellIconUtil.getFolderIcon;
end;

procedure TfrmRestoreExplorer.AddRootNode;
var
  MainIcon : Integer;
  ExplorerNode : PVirtualNode;
  NodeData : PVstRestoreExplorerData;
begin
  if Params.IsFile then
    MainIcon := MyIcon.getIconByFileExt( Params.RestorePath )
  else
    MainIcon := MyShellIconUtil.getFolderIcon;

    // 添加第一个节点
  ExplorerNode := vstExplorer.AddChild( vstExplorer.RootNode );
  NodeData := vstExplorer.GetNodeData( ExplorerNode );
  NodeData.FilePath := Params.RestorePath;
  NodeData.IsFile := Params.IsFile;
  NodeData.IsDeleted := False;
  NodeData.FileSize := Params.FileSize;
  NodeData.ShowName := Params.RestorePath;
  NodeData.ShowIcon := MainIcon;
end;

procedure TfrmRestoreExplorer.AddSearchHistory(FileName: string);
var
  i: Integer;
begin
    // 已存在
  if cbbSearchName.Items.IndexOf( FileName ) >= 0 then
    Exit;

    // 超过限制，删除组后一个
  if cbbSearchName.Items.Count >= 10 then
    cbbSearchName.Items.Delete( 9 );

    // 添加
  cbbSearchName.Items.Insert( 0, FileName );
end;

procedure TfrmRestoreExplorer.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmRestoreExplorer.btnOKClick(Sender: TObject);
begin
  Close;
  ModalResult := mrOk;
end;

procedure TfrmRestoreExplorer.btnSearchClick(Sender: TObject);
var
  SearchName : string;
begin
    // 清空旧记录
  vstSearchFile.Clear;

    // 搜索新记录
  SearchName := cbbSearchName.Text;
  if LeftStr( SearchName, 1 ) <> '*' then
    SearchName := '*' + SearchName;
  if RightStr( SearchName, 1 ) <> '*' then
    SearchName := SearchName + '*';
  SearchParams.SerachName := SearchName;
  if Params.IsLocal then
    RestoreSearchUserApi.ReadLocal( SearchParams )
  else
    RestoreSearchUserApi.ReadNetwork( SearchParams );

    // 添加到历史
  AddSearchHistory( cbbSearchName.Text );
end;

procedure TfrmRestoreExplorer.btnStopSearchClick(Sender: TObject);
begin
  btnStopSearch.Enabled := False;
  MyRestoreSearchHandler.IsRestoreRun := False;
  RestoreSearch_IsShow := False;
end;

procedure TfrmRestoreExplorer.cbbSearchNameKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if ( Key = VK_RETURN ) and btnSearch.Enabled then
    btnSearch.Click;
end;

procedure TfrmRestoreExplorer.ClosePreviewForm;
var
  DelWidth : Integer;
begin
    // 设置本窗口位置
  try
    DelWidth := Screen.WorkAreaWidth - Self.Width;
    DelWidth := DelWidth div 2;
    Self.Left := DelWidth;
  except
  end;
  ShowPreiveBtn( False );
end;

procedure TfrmRestoreExplorer.edtSearchKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ( Key = VK_RETURN ) and btnSearch.Enabled then
    btnSearch.Click;
end;

procedure TfrmRestoreExplorer.Explorer(Path: string);
begin
  ExplorerParams.RestorePath := Path;
  ExplorerParams.IsDeleted := False;
  ExplorerParams.IsSerach := False;

  ExplorerAction;
end;

procedure TfrmRestoreExplorer.ExplorerAction;
begin
    // 开始搜索文件
  if Params.IsLocal then
    RestoreExplorerUserApi.ReadLocal( ExplorerParams )
  else
    RestoreExplorerUserApi.ReadNetwork( ExplorerParams );
end;

procedure TfrmRestoreExplorer.ExplorerDelete(Path: string);
begin
  ExplorerParams.RestorePath := Path;
  ExplorerParams.IsDeleted := True;
  ExplorerParams.IsSerach := False;

  ExplorerAction;
end;

procedure TfrmRestoreExplorer.ExplorerSearch(Path : string; IsDeleted : Boolean);
begin
  ExplorerParams.RestorePath := Path;
  ExplorerParams.IsDeleted := IsDeleted;
  ExplorerParams.IsSerach := True;

    // 开始搜索文件
  ExplorerAction;
end;

procedure TfrmRestoreExplorer.FindDeleteNode(Node: PVirtualNode;
  PathList: TRestoreSelectList);
var
  SelectNode : PVirtualNode;
  NodeData : PVstRestoreDeleteExplorerData;
  RestoreSelectInfo : TRestoreSelectInfo;
begin
  SelectNode := Node.FirstChild;
  while Assigned( SelectNode ) do
  begin
    if vstDeleteFile.CheckState[ SelectNode ] = cscheckedNormal then
    begin
      NodeData := vstDeleteFile.GetNodeData( SelectNode );
      RestoreSelectInfo := TRestoreSelectInfo.Create( NodeData.FilePath, NodeData.IsFile );
      RestoreSelectInfo.SetDeletedInfo( True, NodeData.EditionNum );
      if NodeData.IsFile then
        RestoreSelectInfo.SetFileInfo( 1, NodeData.FileSize );
      PathList.Add( RestoreSelectInfo );
    end
    else
    if vstDeleteFile.CheckState[ SelectNode ] = csMixedNormal then
      FindDeleteNode( SelectNode, PathList );
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TfrmRestoreExplorer.FindSearchNode(Node: PVirtualNode;
  PathList: TRestoreSelectList);
var
  SelectNode : PVirtualNode;
  NodeData : PVstRestoreSearchData;
  RestoreSelectInfo : TRestoreSelectInfo;
begin
  SelectNode := Node.FirstChild;
  while Assigned( SelectNode ) do
  begin
    if vstSearchFile.CheckState[ SelectNode ] = cscheckedNormal then
    begin
      NodeData := vstSearchFile.GetNodeData( SelectNode );
      RestoreSelectInfo := TRestoreSelectInfo.Create( NodeData.FilePath, NodeData.IsFile );
      RestoreSelectInfo.SetDeletedInfo( NodeData.IsDeleted, NodeData.EditionNum );
      if NodeData.IsFile then
        RestoreSelectInfo.SetFileInfo( 1, NodeData.FileSize );
      PathList.Add( RestoreSelectInfo );
    end
    else
    if vstSearchFile.CheckState[ SelectNode ] = csMixedNormal then
      FindSearchNode( SelectNode, PathList );
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TfrmRestoreExplorer.FindSelectNode(Node: PVirtualNode;
  PathList: TRestoreSelectList);
var
  SelectNode : PVirtualNode;
  NodeData : PVstRestoreExplorerData;
  RestoreSelectInfo : TRestoreSelectInfo;
begin
  SelectNode := Node.FirstChild;
  while Assigned( SelectNode ) do
  begin
    if vstExplorer.CheckState[ SelectNode ] = cscheckedNormal then
    begin
      NodeData := vstExplorer.GetNodeData( SelectNode );
      RestoreSelectInfo := TRestoreSelectInfo.Create( NodeData.FilePath, NodeData.IsFile );
      RestoreSelectInfo.SetDeletedInfo( False, 0 );
      if NodeData.IsFile then
        RestoreSelectInfo.SetFileInfo( 1, NodeData.FileSize );
      PathList.Add( RestoreSelectInfo );
    end
    else
    if vstExplorer.CheckState[ SelectNode ] = csMixedNormal then
      FindSelectNode( SelectNode, PathList );
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TfrmRestoreExplorer.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if PreviewForm_IsShow then
    frmPreView.Close;
  tmrStop.Enabled := True;
end;

procedure TfrmRestoreExplorer.FormCreate(Sender: TObject);
begin
  vstExplorer.NodeDataSize := SizeOf( TRestoreExplorerData );
  vstExplorer.Images := MyIcon.getSysIcon;

  vstDeleteFile.NodeDataSize := SizeOf( TRestoreDeleteExplorerData );
  vstDeleteFile.Images := MyIcon.getSysIcon;

  vstSearchFile.NodeDataSize := SizeOf( TRestoreSearchData );
  vstSearchFile.Images := MyIcon.getSysIcon;

  RestoreOtherEditionHash := TRestoreOtherEditionHash.Create;

  LoadIni;
end;

procedure TfrmRestoreExplorer.FormDestroy(Sender: TObject);
begin
  RestoreOtherEditionHash.Free;

  SaveIni;
end;

procedure TfrmRestoreExplorer.FormShow(Sender: TObject);
begin
  btnOK.Enabled := False;
  ModalResult := mrCancel;
  PcMain.ActivePage := tsExplorer;
end;

function TfrmRestoreExplorer.getIsRestore(
  _Params: TRestoreSelectParams): Boolean;
var
  col : TVirtualTreeColumn;
begin
    // 清空旧数据
  RestoreOtherEditionHash.Clear;

  Params := _Params;

    // 控制页面显示
  tsSearchFile.TabVisible := not Params.IsFile;
  tsDeletedFile.TabVisible := Params.HasDeleted;
  col := vstSearchFile.Header.Columns[ VstExplorer_Recycled ];
  if Params.HasDeleted then
    col.Options := col.Options + [ coVisible ]
  else
    col.Options := col.Options - [ coVisible ];

    // 添加第一个节点
  vstExplorer.Clear;
  if not Params.IsFile then
    AddRootNode;

    // 添加删除第一个节点
  vstDeleteFile.Clear;
  if Params.HasDeleted and not Params.IsFile then
    AddRootDeleteNode;

    // 浏览信息参数
  ExplorerParams.OwnerID := Params.OwnerID;
  ExplorerParams.RestoreFrom := Params.RestoreFrom;
  ExplorerParams.IsFile := Params.IsFile;
  ExplorerParams.IsDeleted := Params.HasDeleted;
  ExplorerParams.IsEncrypted := Params.IsEncrypted;
  ExplorerParams.PasswordExt := Params.PasswordExt;

    // 开始搜索文件
  Explorer( Params.RestorePath );
  if Params.HasDeleted then
    ExplorerDelete( Params.RestorePath );

    // 搜索参数
  vstSearchFile.Clear;
  cbbSearchName.Clear;
  SearchParams.RestorePath := Params.RestorePath;
  SearchParams.OwnerID := Params.OwnerID;
  SearchParams.RestoreFrom := Params.RestoreFrom;
  SearchParams.IsFile := Params.IsFile;
  SearchParams.HasDeleted := Params.HasDeleted;
  SearchParams.IsEncrypted := Params.IsEncrypted;
  SearchParams.PasswordExt := Params.PasswordExt;

    // 预览参数
  PreviewParams.OwnerID := Params.OwnerID;
  PreviewParams.RestoreFrom := Params.RestoreFrom;
  PreviewParams.IsEncrypted := Params.IsEncrypted;
  PreviewParams.Password := Params.Password;
  PreviewParams.PasswordExt := Params.PasswordExt;

    // 默认选择 Explorer
  PcMain.ActivePage := tsExplorer;

    // 是否 OK
  Result := ShowModal = mrOk;
end;

function TfrmRestoreExplorer.getFileEditionList: TFileEditionList;
var
  p : TRestoreOtherEditionPair;
  SelectNode : PVirtualNode;
  FileEditionInfo : TFileEditionInfo;
begin
  Result := TFileEditionList.Create;
  for p in RestoreOtherEditionHash do
  begin
    SelectNode := p.Value.ParentNode;
    if not Assigned( SelectNode ) or ( vstDeleteFile.CheckState[ SelectNode ] <> csCheckedNormal ) then
      Continue;
    FileEditionInfo := TFileEditionInfo.Create( p.Value.FilePath, p.Value.EditionNum );
    Result.Add( FileEditionInfo );
  end;
end;

function TfrmRestoreExplorer.getSavePath: string;
var
  SavePath : string;
begin
  SavePath := Params.RestorePath;

    // 网上邻居
  if MyNetworkFolderUtil.IsNetworkFolder( SavePath ) then
    SavePath := MyFilePath.getDownloadPath( SavePath );

    // 磁盘可用路径
  SavePath := MyHardDisk.getAvailablePath( SavePath );

    // 已存在路径则改名
  if MyFilePath.getIsExist( SavePath ) then
    SavePath := SavePath + '.Restore';

  Result := SavePath;
end;

function TfrmRestoreExplorer.getSelectPathList: TRestoreSelectList;
begin
  Result := TRestoreSelectList.Create;
  FindSelectNode( vstExplorer.RootNode, Result );
  FindDeleteNode( vstDeleteFile.RootNode, Result );
  FindSearchNode( vstSearchFile.RootNode, Result );
end;

procedure TfrmRestoreExplorer.LoadIni;
var
  IniFile : TIniFile;
  i, ItemCount: Integer;
  s : string;
begin
  IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  ItemCount := IniFile.ReadInteger( Self.Name, cbbSearchName.Name + 'Count', 0 );
  for i := 0 to ItemCount - 1 do
  begin
    s := IniFile.ReadString( Self.Name, cbbSearchName.Name + IntToStr(i), '' );
    cbbSearchName.Items.Add( s );
  end;
  IniFile.Free;
end;

procedure TfrmRestoreExplorer.SaveIni;
var
  IniFile : TIniFile;
  i: Integer;
begin
    // 没有权限写
  if not MyIniFile.ConfirmWriteIni then
    Exit;

  IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  try
    IniFile.WriteInteger( Self.Name, cbbSearchName.Name + 'Count', cbbSearchName.Items.Count );
    for i := 0 to cbbSearchName.Items.Count - 1 do
      IniFile.WriteString( Self.Name, cbbSearchName.Name + IntToStr(i), cbbSearchName.Items[i] );
  except
  end;
  IniFile.Free;
end;

procedure TfrmRestoreExplorer.ShowPreiveBtn(IsShow: Boolean);
begin
  tbtnPreview.Down := IsShow;
  tbtnSplit.Visible := IsShow;
  tbtnLeft.Visible := IsShow;
  tbtnRight.Visible := IsShow;
  tbtnSelect.Visible := IsShow;

  tbtnRecyclePreview.Down := IsShow;
  tbtnRecycleSplit.Visible := IsShow;
  tbtnRecycleLeft.Visible := IsShow;
  tbtnRecycleRight.Visible := IsShow;
  tbtnRecycleSelect.Visible := IsShow;

  tbtnSearchPreview.Down := IsShow;
  tbtnSearchSplit.Visible := IsShow;
  tbtnSearchLeft.Visible := IsShow;
  tbtnSearchRight.Visible := IsShow;
  tbtnSearchSelect.Visible := IsShow;
end;

procedure TfrmRestoreExplorer.ShowPreview(FilePath: string;
  IsDeleted : Boolean; EditionNum : Integer);
begin
    // 显示预览文件基本信息
  frmPreView.SetPreviewFile( FilePath );

    // 读取预览文件
  PreviewParams.RestorePath := FilePath;
  PreviewParams.IsDeleted := IsDeleted;
  PreviewParams.EditionNum := EditionNum;

  if Params.IsLocal then
    RestorePreviewUserApi.PreviewLocal( PreviewParams )
  else
    RestorePreviewUserApi.PreviewNetwork( PreviewParams );
end;

procedure TfrmRestoreExplorer.ShowPreviewForm;
var
  DelWidth : Integer;
begin
    // 设置本窗口位置
  try
    DelWidth := Screen.WorkAreaWidth - ( Self.Width * 2 );
    if DelWidth < 10 then
    begin
      Self.Width := ( Screen.WorkAreaWidth div 2 ) - 20;
      DelWidth := 10;
    end
    else
      DelWidth := DelWidth div 2;
    Self.Left := Self.Width + DelWidth;
  except
  end;

  frmPreView.SetIniPosition( Self.Handle );
  ShowPreiveBtn( True );
end;

procedure TfrmRestoreExplorer.tbtnLeftClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
begin
  SelectNode := vstExplorer.FocusedNode;
  if Assigned( SelectNode ) then
    SelectNode := SelectNode.PrevSibling;
  if Assigned( SelectNode ) then
  begin
    vstExplorer.Selected[ SelectNode ] := True;
    vstExplorer.FocusedNode := SelectNode;
  end;
end;

procedure TfrmRestoreExplorer.tbtnPreviewClick(Sender: TObject);
var
  NodeData : PVstRestoreExplorerData;
begin
    // 取消预览
  if PreviewForm_IsShow then
  begin
    frmPreView.Close;
    Exit;
  end;

    // 没有选中文件
  if not Assigned( vstExplorer.FocusedNode ) then
    Exit;

    // 预览
  NodeData := vstExplorer.GetNodeData( vstExplorer.FocusedNode );
  ShowPreview( NodeData.FilePath, False, 0 );
  ShowPreviewForm;
end;

procedure TfrmRestoreExplorer.tbtnRecycleLeftClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
begin
  SelectNode := vstDeleteFile.FocusedNode;
  if Assigned( SelectNode ) then
    SelectNode := SelectNode.PrevSibling;
  if Assigned( SelectNode ) then
  begin
    vstDeleteFile.Selected[ SelectNode ] := True;
    vstDeleteFile.FocusedNode := SelectNode;
  end;
end;

procedure TfrmRestoreExplorer.tbtnRecyclePreviewClick(Sender: TObject);
var
  NodeData : PVsTRestoreDeleteExplorerData;
begin
    // 取消预览
  if PreviewForm_IsShow then
  begin
    frmPreView.Close;
    Exit;
  end;

    // 没有选中文件
  if not Assigned( vstDeleteFile.FocusedNode ) then
    Exit;

    // 预览
  NodeData := vstDeleteFile.GetNodeData( vstDeleteFile.FocusedNode );
  ShowPreview( NodeData.FilePath, True, NodeData.EditionNum );
  ShowPreviewForm;
end;

procedure TfrmRestoreExplorer.tbtnRecycleRightClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
begin
  SelectNode := vstDeleteFile.FocusedNode;
  if Assigned( SelectNode ) then
    SelectNode := SelectNode.NextSibling;
  if Assigned( SelectNode ) then
  begin
    vstDeleteFile.Selected[ SelectNode ] := True;
    vstDeleteFile.FocusedNode := SelectNode;
  end;
end;

procedure TfrmRestoreExplorer.tbtnRecycleSelectClick(Sender: TObject);
begin
  if not Assigned( vstDeleteFile.FocusedNode ) then
    Exit;

  vstDeleteFile.CheckState[ vstDeleteFile.FocusedNode ] := csCheckedNormal;
end;

procedure TfrmRestoreExplorer.tbtnRightClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
begin
  SelectNode := vstExplorer.FocusedNode;
  if Assigned( SelectNode ) then
    SelectNode := SelectNode.NextSibling;
  if Assigned( SelectNode ) then
  begin
    vstExplorer.Selected[ SelectNode ] := True;
    vstExplorer.FocusedNode := SelectNode;
  end;
end;

procedure TfrmRestoreExplorer.tbtnSearchLeftClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
begin
  SelectNode := vstSearchFile.FocusedNode;
  if Assigned( SelectNode ) then
    SelectNode := SelectNode.PrevSibling;
  if Assigned( SelectNode ) then
  begin
    vstSearchFile.Selected[ SelectNode ] := True;
    vstSearchFile.FocusedNode := SelectNode;
  end;
end;

procedure TfrmRestoreExplorer.tbtnSearchPreviewClick(Sender: TObject);
var
  NodeData : PVstRestoreSearchData;
begin
    // 取消预览
  if PreviewForm_IsShow then
  begin
    frmPreView.Close;
    Exit;
  end;

    // 没有选中文件
  if not Assigned( vstSearchFile.FocusedNode ) then
    Exit;

    // 预览
  NodeData := vstSearchFile.GetNodeData( vstSearchFile.FocusedNode );
  ShowPreview( NodeData.FilePath, NodeData.IsDeleted, NodeData.EditionNum );
  ShowPreviewForm;
end;

procedure TfrmRestoreExplorer.tbtnSearchRightClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
begin
  SelectNode := vstSearchFile.FocusedNode;
  if Assigned( SelectNode ) then
    SelectNode := SelectNode.NextSibling;
  if Assigned( SelectNode ) then
  begin
    vstSearchFile.Selected[ SelectNode ] := True;
    vstSearchFile.FocusedNode := SelectNode;
  end;
end;

procedure TfrmRestoreExplorer.tbtnSearchSelectClick(Sender: TObject);
begin
  if not Assigned( vstSearchFile.FocusedNode ) then
    Exit;

  vstSearchFile.CheckState[ vstSearchFile.FocusedNode ] := csCheckedNormal;
end;

procedure TfrmRestoreExplorer.tbtnSelectClick(Sender: TObject);
begin
  if not Assigned( vstExplorer.FocusedNode ) then
    Exit;

  vstExplorer.CheckState[ vstExplorer.FocusedNode ] := csCheckedNormal;
end;

procedure TfrmRestoreExplorer.tmrExploringDeletedTimer(Sender: TObject);
begin
  tmrExploringDeleted.Enabled := False;
  pbExplorerDelete.Style := pbstMarquee;
  pbExplorerDelete.Visible := True;
end;

procedure TfrmRestoreExplorer.tmrExploringTimer(Sender: TObject);
begin
  tmrExploring.Enabled := False;
  pbExplorer.Style := pbstMarquee;
  pbExplorer.Visible := True;
end;

procedure TfrmRestoreExplorer.tmrSearchingTimer(Sender: TObject);
begin
  tmrSearching.Enabled := False;
  pbSearch.Style := pbstMarquee;
  pbSearch.Visible := True;
end;

procedure TfrmRestoreExplorer.tmrStopTimer(Sender: TObject);
begin
  tmrStop.Enabled := False;
  if btnStopSearch.Visible and btnStopSearch.Enabled then
    btnStopSearch.Click;
end;

procedure TfrmRestoreExplorer.vstDeleteFileChecked(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  ParentData, ChildData : PVsTRestoreDeleteExplorerData;
  RestoreOtherEdition : TRestoreOtherEdition;
begin
  btnOK.Enabled := ( vstExplorer.CheckedCount > 0 ) or ( vstDeleteFile.CheckedCount > 0 ) or
                   ( vstSearchFile.CheckedCount > 0 );

  if not Assigned( Node.Parent ) or ( Node.Parent = Sender.RootNode ) then
    Exit;
  ParentData := Sender.GetNodeData( Node.Parent );
  if not ParentData.IsFile then
    Exit;

    // 设置了新的子节点
  ChildData := Sender.GetNodeData( Node );
  ParentData.FileSize := ChildData.FileSize;
  ParentData.FileTime := ChildData.FileTime;
  ParentData.EditionNum := ChildData.EditionNum;
  if Sender.CheckState[ Node.Parent ] = csUncheckedNormal then
    Sender.CheckState[ Node.Parent ] := csCheckedNormal;
  Sender.RepaintNode( Node.Parent );

    // 不存在，则先添加
  if not RestoreOtherEditionHash.ContainsKey( ChildData.FilePath ) then
  begin
    RestoreOtherEdition := TRestoreOtherEdition.Create( ChildData.FilePath, ChildData.EditionNum );
    RestoreOtherEdition.SetParentNode( Node.Parent );
    RestoreOtherEditionHash.Add( ChildData.FilePath, RestoreOtherEdition );
  end
  else
    RestoreOtherEditionHash[ ChildData.FilePath ].EditionNum := ChildData.EditionNum;
end;

procedure TfrmRestoreExplorer.vstDeleteFileFocusChanged(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
var
  NodeData : PVsTRestoreDeleteExplorerData;
begin
  if not Assigned( Node ) then
    Exit;

    // 按钮
  tbtnRecycleLeft.Enabled := Assigned( Node.PrevSibling );
  tbtnRecycleRight.Enabled := Assigned( Node.NextSibling );
  tbtnRecycleSelect.Enabled := True;

    // 预览按钮
  NodeData := Sender.GetNodeData( Node );
  tbtnRecyclePreview.Enabled := PreviewForm_IsShow or NodeData.IsFile;

    // 预览选中的文件
  if PreviewForm_IsShow and NodeData.IsFile then
    ShowPreview( NodeData.FilePath, True, NodeData.EditionNum );
end;

procedure TfrmRestoreExplorer.vstDeleteFileGetHint(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex;
  var LineBreakStyle: TVTTooltipLineBreakStyle; var HintText: string);
var
  NodeData : PVsTRestoreDeleteExplorerData;
begin
  NodeData := Sender.GetNodeData( Node );
  if not NodeData.IsFile then
    Exit;
  HintText := 'Edition: ' + IntToStr( NodeData.EditionNum );
end;

procedure TfrmRestoreExplorer.vstDeleteFileGetImageIndex(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind;
  Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData : PVstRestoreDeleteExplorerData;
begin
  if ( Column = VstExplorer_FileName ) and
     ( ( Kind = ikNormal ) or ( Kind = ikSelected ) )
  then
  begin
    NodeData := Sender.GetNodeData( Node );
    ImageIndex := NodeData.ShowIcon;
  end
  else
    ImageIndex := -1;
end;

procedure TfrmRestoreExplorer.vstDeleteFileGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  NodeData : PVstRestoreDeleteExplorerData;
begin
  NodeData := Sender.GetNodeData( Node );
  if Column = VstExplorer_FileName then
    CellText := NodeData.ShowName
  else
  if not NodeData.IsFile then
    CellText := ''
  else
  if Column = VstExplorer_FileSize then
    CellText := MySize.getFileSizeStr( NodeData.FileSize )
  else
  if Column = VstExplorer_FileTime then
    CellText := DateTimeToStr( NodeData.FileTime )
  else
    CellText := '';
end;

procedure TfrmRestoreExplorer.vstDeleteFileInitChildren(
  Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
var
  NodeData : PVstRestoreDeleteExplorerData;
begin
  if Node.Parent = Sender.RootNode then
    Exit;
  NodeData := Sender.GetNodeData( Node );

    // 搜索下一层文件
  if not NodeData.IsFile then
    ExplorerDelete( NodeData.FilePath );
end;

procedure TfrmRestoreExplorer.vstDeleteFileInitNode(Sender: TBaseVirtualTree;
  ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
var
  ParentData : PVsTRestoreDeleteExplorerData;
  IsEditionFile, IsDefaultFile : Boolean;
begin
  IsEditionFile := False;
  IsDefaultFile := False;
  if Assigned( ParentNode ) then
  begin
    ParentData := Sender.GetNodeData( ParentNode );
    IsEditionFile := ParentData.IsFile;
    if IsEditionFile then
      IsDefaultFile := ParentNode.FirstChild = Node;
  end;

  if IsEditionFile then
  begin
    Node.CheckType := ctRadioButton;
    if IsDefaultFile then
      Node.CheckState := csCheckedNormal
    else
      Node.CheckState := csUnCheckedNormal;
  end
  else
  begin
    Node.CheckType := ctTriStateCheckBox;
    if Assigned( ParentNode ) and ( ParentNode.CheckState = csCheckedNormal ) then
      Node.CheckState := csCheckedNormal
    else
      Node.CheckState := csUnCheckedNormal;
  end;
end;

procedure TfrmRestoreExplorer.vstExplorerChecked(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  btnOK.Enabled := ( vstExplorer.CheckedCount > 0 ) or ( vstDeleteFile.CheckedCount > 0 ) or
                   ( vstSearchFile.CheckedCount > 0 );
end;

procedure TfrmRestoreExplorer.vstExplorerFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
var
  NodeData : PVstRestoreExplorerData;
begin
  if not Assigned( Node ) then
    Exit;

    // 按钮
  tbtnLeft.Enabled := Assigned( Node.PrevSibling );
  tbtnRight.Enabled := Assigned( Node.NextSibling );
  tbtnSelect.Enabled := True;

    // 预览按钮
  NodeData := Sender.GetNodeData( Node );
  tbtnPreview.Enabled := PreviewForm_IsShow or NodeData.IsFile;

    // 预览选中的文件
  if PreviewForm_IsShow and NodeData.IsFile then
    ShowPreview( NodeData.FilePath, False, 0 );
end;

procedure TfrmRestoreExplorer.vstExplorerGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData : PVstRestoreExplorerData;
begin
  if ( ( Kind = ikNormal ) or ( Kind = ikSelected ) ) and ( Column = VstExplorer_FileName ) then
  begin
    NodeData := Sender.GetNodeData( Node );
    ImageIndex := NodeData.ShowIcon
  end
  else
    ImageIndex := -1;
end;

procedure TfrmRestoreExplorer.vstExplorerGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  NodeData : PVstRestoreExplorerData;
begin
  NodeData := Sender.GetNodeData( Node );
  if Column = VstExplorer_FileName then
    CellText := NodeData.ShowName
  else
  if not NodeData.IsFile then
    CellText := ''
  else
  if Column = VstExplorer_FileSize then
    CellText := MySize.getFileSizeStr( NodeData.FileSize )
  else
  if Column = VstExplorer_FileTime then
    CellText := DateTimeToStr( NodeData.FileTime )
  else
    CellText := '';
end;

procedure TfrmRestoreExplorer.vstExplorerInitChildren(Sender: TBaseVirtualTree;
  Node: PVirtualNode; var ChildCount: Cardinal);
var
  NodeData : PVstRestoreExplorerData;
begin
  if Node.Parent = Sender.RootNode then
    Exit;
  NodeData := Sender.GetNodeData( Node );

    // 搜索下一层文件
  Explorer( NodeData.FilePath );
end;

procedure TfrmRestoreExplorer.vstExplorerInitNode(Sender: TBaseVirtualTree;
  ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
begin
  Node.CheckType := ctTriStateCheckBox;
  if Assigned( ParentNode ) and ( ParentNode.CheckState = csCheckedNormal ) then
    Node.CheckState := csCheckedNormal
  else
    Node.CheckState := csUnCheckedNormal;
end;

procedure TfrmRestoreExplorer.vstExplorerPaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
var
  NodeData : PVstRestoreExplorerData;
begin
  if ( Column = VstExplorer_FileName ) then
  begin
    NodeData := Sender.GetNodeData( Node );
    if NodeData.IsDeleted then
      TargetCanvas.Font.Color := clGray;
  end;
end;

procedure TfrmRestoreExplorer.vstSearchFileChecked(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  ParentData, ChildData : PVstRestoreSearchData;
  RestoreOtherEdition : TRestoreOtherEdition;
begin
  btnOK.Enabled := ( vstExplorer.CheckedCount > 0 ) or ( vstDeleteFile.CheckedCount > 0 ) or
                   ( vstSearchFile.CheckedCount > 0 );

  if not Assigned( Node.Parent ) or ( Node.Parent = Sender.RootNode ) then
    Exit;
  ParentData := Sender.GetNodeData( Node.Parent );
  if not ParentData.IsFile then
    Exit;

    // 设置了新的子节点
  ChildData := Sender.GetNodeData( Node );
  ParentData.FileSize := ChildData.FileSize;
  ParentData.FileTime := ChildData.FileTime;
  ParentData.EditionNum := ChildData.EditionNum;
  if Sender.CheckState[ Node.Parent ] = csUncheckedNormal then
    Sender.CheckState[ Node.Parent ] := csCheckedNormal;
  Sender.RepaintNode( Node.Parent );

    // 不存在，则先添加
  if not RestoreOtherEditionHash.ContainsKey( ChildData.FilePath ) then
  begin
    RestoreOtherEdition := TRestoreOtherEdition.Create( ChildData.FilePath, ChildData.EditionNum );
    RestoreOtherEdition.SetParentNode( Node.Parent );
    RestoreOtherEditionHash.Add( ChildData.FilePath, RestoreOtherEdition );
  end
  else
    RestoreOtherEditionHash[ ChildData.FilePath ].EditionNum := ChildData.EditionNum;
end;

procedure TfrmRestoreExplorer.vstSearchFileFocusChanged(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
var
  NodeData : PVstRestoreSearchData;
begin
  if not Assigned( Node ) then
    Exit;

    // 按钮
  tbtnSearchLeft.Enabled := Assigned( Node.PrevSibling );
  tbtnSearchRight.Enabled := Assigned( Node.NextSibling );
  tbtnSearchSelect.Enabled := True;

    // 预览按钮
  NodeData := Sender.GetNodeData( Node );
  tbtnSearchPreview.Enabled := PreviewForm_IsShow or NodeData.IsFile;

    // 预览选中的文件
  if PreviewForm_IsShow and NodeData.IsFile then
    ShowPreview( NodeData.FilePath, NodeData.IsDeleted, NodeData.EditionNum );
end;

procedure TfrmRestoreExplorer.vstSearchFileGetImageIndex(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind;
  Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData : PVstRestoreSearchData;
begin
  if ( Kind = ikNormal ) or ( Kind = ikSelected ) then
  begin
    NodeData := Sender.GetNodeData( Node );
    if Column = VstExplorer_FileName then
      ImageIndex := NodeData.ShowIcon
    else
    if Column = VstExplorer_Recycled then
      ImageIndex := NodeData.RecycleIcon
  end
  else
    ImageIndex := -1;
end;

procedure TfrmRestoreExplorer.vstSearchFileGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  NodeData : PVstRestoreSearchData;
begin
  NodeData := Sender.GetNodeData( Node );
  if Column = VstExplorer_FileName then
    CellText := NodeData.ShowName
  else
  if not NodeData.IsFile then
    CellText := ''
  else
  if Column = VstExplorer_FileSize then
    CellText := MySize.getFileSizeStr( NodeData.FileSize )
  else
  if Column = VstExplorer_FileTime then
    CellText := DateTimeToStr( NodeData.FileTime )
  else
    CellText := '';
end;

procedure TfrmRestoreExplorer.vstSearchFileInitChildren(
  Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
var
  NodeData : PVstRestoreSearchData;
begin
  NodeData := Sender.GetNodeData( Node );

    // 搜索下一层文件
  ExplorerSearch( NodeData.FilePath, NodeData.IsDeleted );
end;

procedure TfrmRestoreExplorer.vstSearchFileInitNode(Sender: TBaseVirtualTree;
  ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
var
  ParentData : PVstRestoreSearchData;
  IsEditionFile, IsDefaultFile : Boolean;
begin
  IsEditionFile := False;
  IsDefaultFile := False;
  if Assigned( ParentNode ) then
  begin
    ParentData := Sender.GetNodeData( ParentNode );
    IsEditionFile := ParentData.IsFile;
    if IsEditionFile then
      IsDefaultFile := ParentNode.FirstChild = Node;
  end;

  if IsEditionFile then
  begin
    Node.CheckType := ctRadioButton;
    if IsDefaultFile then
      Node.CheckState := csCheckedNormal
    else
      Node.CheckState := csUnCheckedNormal;
  end
  else
  begin
    Node.CheckType := ctTriStateCheckBox;
    if Assigned( ParentNode ) and ( ParentNode.CheckState = csCheckedNormal ) then
      Node.CheckState := csCheckedNormal
    else
      Node.CheckState := csUnCheckedNormal;
  end;
end;

procedure TfrmRestoreExplorer.vstSearchFileMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  SelectNode : PVirtualNode;
  NodeData : PVstRestoreSearchData;
  HintText : string;
begin
  HintText := '';

  try  // 提取 Hint 信息
    SelectNode := vstSearchFile.GetNodeAt( x, Y );
    if Assigned( SelectNode ) then
    begin
      NodeData := vstSearchFile.GetNodeData( SelectNode );
      HintText := MyHtmlHintShowStr.getHintRowNext( 'File Path', NodeData.FilePath );
      if NodeData.IsDeleted then
        HintText := HintText + MyHtmlHintShowStr.getHintRow( 'File Type', 'Deleted File' );
    end;
  except
  end;

    // 刷新 Hint 信息
  if vstSearchFile.Hint <> HintText then
  begin
    vstSearchFile.Hint := HintText;
    frmMainForm.OpenRefreshHint;
  end;
end;

{ TRestoreSelectInfo }

constructor TRestoreSelectInfo.Create(_FilePath: string; _IsFile: Boolean);
begin
  FilePath := _FilePath;
  IsFile := _IsFile;;
  FileCount := -1;
  FileSize := 0;
end;

procedure TRestoreSelectInfo.SetFileInfo(_FileCount : Integer; _FileSize: Int64);
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
end;

procedure TRestoreSelectInfo.SetDeletedInfo(_IsDeleted: Boolean; _EditionNum : Integer);
begin
  IsDeleted := _IsDeleted;
  EditionNum := _EditionNum;
end;

{ TRestoreOtherEdition }

constructor TRestoreOtherEdition.Create(_FilePath: string;
  _EditionNum: Integer);
begin
  FilePath := _FilePath;
  EditionNum := _EditionNum;
end;

procedure TRestoreOtherEdition.SetParentNode(_ParentNode: PVirtualNode);
begin
  ParentNode := _ParentNode;
end;

end.
