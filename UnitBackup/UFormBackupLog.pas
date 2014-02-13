unit UFormBackupLog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VirtualTrees, Vcl.StdCtrls, Vcl.ExtCtrls,
  RzTabs, Vcl.ImgList, Vcl.ComCtrls, Vcl.ToolWin, UMainForm, IniFiles;

type

    // 数据结构
  TVstBackupLogData = record
  public
    FilePath : WideString;
    FileTime, BackupTime : TDateTime;
  public
    ShowName, ShowDir : WideString;
    NodeType : WideString;
    MainIcon : Integer;
  end;
  PVstBackupLogData = ^TVstBackupLogData;

    // 窗口
  TfrmBackupLog = class(TForm)
    plButtons: TPanel;
    btnClose: TButton;
    PcMain: TRzPageControl;
    tsCompleted: TRzTabSheet;
    tsInCompleted: TRzTabSheet;
    vstIncompleted: TVirtualStringTree;
    ilPcMain: TImageList;
    btnPreview: TButton;
    btnRestore: TButton;
    tmrProgress: TTimer;
    plCompleted: TPanel;
    pbProgress: TProgressBar;
    plStatus: TPanel;
    Image1: TImage;
    lbStatus: TLabel;
    tbCompleted: TToolBar;
    tbtnPreview: TToolButton;
    tbtnRestore: TToolButton;
    ToolButton3: TToolButton;
    tbtnExpand: TToolButton;
    tbtnCollapse: TToolButton;
    vstBackupLog: TVirtualStringTree;
    Panel1: TPanel;
    plSearch: TPanel;
    Label1: TLabel;
    btnSearch: TButton;
    ToolButton1: TToolButton;
    tbtnSearch: TToolButton;
    cbbFileName: TComboBox;
    tbtnExplorer: TToolButton;
    procedure btnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure vstBackupLogGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstBackupLogGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstIncompletedGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: string);
    procedure vstIncompletedGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure btnClearClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure vstBackupLogPaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure vstBackupLogFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure FormShow(Sender: TObject);
    procedure btnPreviewClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tmrProgressTimer(Sender: TObject);
    procedure btnRestoreClick(Sender: TObject);
    procedure tbtnPreviewClick(Sender: TObject);
    procedure tbtnRestoreClick(Sender: TObject);
    procedure tbtnExpandClick(Sender: TObject);
    procedure tbtnCollapseClick(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure tbtnSearchClick(Sender: TObject);
    procedure edtFileNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure cbbFileNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tbtnExplorerClick(Sender: TObject);
  private
    procedure SaveIni;
    procedure LoadIni;
    procedure AddHistory( FileName : string );
  private
    DesItemID, SourcePath : string;
    IncompletedCount : Integer;
  private
    procedure ShowPreviewForm;
    procedure AddToPreview;
    procedure AddToRestore;
  public
    procedure ClearItems;
    procedure SetItemInfo( _DesItemID, _SourcePath : string );
    procedure AddCompletedDate( BackupDate : TDate; FileCount : Integer );
    procedure AddCompleted( FilePath : string; FileTime, BackupTime : TDateTime );
    procedure AddMoreCompleted;
    procedure AddIncompleted( FilePath : string );
    procedure ClosePreviewForm;
    procedure ShowLog;
  end;

    // 搜索 log
  TLogFileSearchHandle = class
  public
    SearchText : string;
  public
    constructor Create( _SearchText : string );
    procedure Update;
  end;

  LogFileUtil = class
  public
    class function getIsPreview( SelectNode : PVirtualNode ): Boolean;
    class function getIsRestore( SelectNode : PVirtualNode ): Boolean;
    class function getIsExplorer( SelectNode : PVirtualNode ): Boolean;
  end;


const
  vstBackupLog_FileName = 0;
  vstBackupLog_FileDir = 1;
  vstBackupLog_BackupTime = 2;

const
  LogNodeType_Date = 'Date';
  LogNodeType_File = 'File';
  LogNodeType_Total = 'Total';

var
  frmBackupLog: TfrmBackupLog;

implementation

uses UMyBackupApiInfo, UMyBackupFaceInfo, UIconUtil, UMyUtil, UMyBackupDataInfo, UFormPreview;

{$R *.dfm}

procedure TfrmBackupLog.AddCompleted(FilePath: string; FileTime, BackupTime: TDateTime);
var
  DateNode, LogNode : PVirtualNode;
  NodeData : PVstBackupLogData;
begin
  DateNode := vstBackupLog.RootNode.LastChild;
  if not Assigned( DateNode ) then
    Exit;

  LogNode := vstBackupLog.AddChild( DateNode );
  NodeData := vstBackupLog.GetNodeData( LogNode );
  NodeData.FilePath := FilePath;
  NodeData.FileTime := FileTime;
  NodeData.BackupTime := BackupTime;
  NodeData.ShowName := ExtractFileName( FilePath );
  NodeData.ShowDir := ExtractFileDir( FilePath );
  NodeData.MainIcon := MyIcon.getIconByFilePath( FilePath );
  NodeData.NodeType := LogNodeType_File;
end;

procedure TfrmBackupLog.AddCompletedDate(BackupDate: TDate; FileCount : Integer);
var
  LogNode : PVirtualNode;
  NodeData : PVstBackupLogData;
begin
  LogNode := vstBackupLog.AddChild( vstBackupLog.RootNode );

    // 展开
  if FileCount <= 5 then
    LogNode.States := LogNode.States + [vsExpanded];

  NodeData := vstBackupLog.GetNodeData( LogNode );
  NodeData.ShowName := DateToStr( BackupDate );
  NodeData.ShowDir := IntToStr( FileCount ) + ' files';;
  NodeData.NodeType := LogNodeType_Date;
  NodeData.MainIcon := MyShellTransActionIconUtil.getDate;
end;

procedure TfrmBackupLog.AddHistory(FileName: string);
var
  i: Integer;
begin
    // 已存在
  if cbbFileName.Items.IndexOf( FileName ) >= 0 then
    Exit;

    // 超过限制，删除组后一个
  if cbbFileName.Items.Count >= 10 then
    cbbFileName.Items.Delete( 9 );

    // 添加
  cbbFileName.Items.Insert( 0, FileName );
end;

procedure TfrmBackupLog.AddIncompleted(FilePath: string);
var
  LogNode : PVirtualNode;
  NodeData : PVstBackupLogData;
begin
  LogNode := vstIncompleted.AddChild( vstIncompleted.RootNode );
  NodeData := vstIncompleted.GetNodeData( LogNode );
  NodeData.FilePath := FilePath;
  NodeData.ShowName := ExtractFileName( FilePath );
  NodeData.ShowDir := ExtractFileDir( FilePath );
  NodeData.MainIcon := MyIcon.getIconByFilePath( FilePath );

  Inc( IncompletedCount );
end;

procedure TfrmBackupLog.AddMoreCompleted;
var
  DateNode, LogNode : PVirtualNode;
  NodeData : PVstBackupLogData;
begin
  DateNode := vstBackupLog.RootNode.LastChild;
  if not Assigned( DateNode ) then
    Exit;

  LogNode := vstBackupLog.AddChild( DateNode );
  NodeData := vstBackupLog.GetNodeData( LogNode );
  NodeData.ShowName := '...';
  NodeData.ShowDir := '';
  NodeData.NodeType := LogNodeType_Total;
  NodeData.MainIcon := -1;
end;

procedure TfrmBackupLog.AddToPreview;
var
  NodeData : PVstBackupLogData;
  Params : TBackupLogReadParams;
begin
  if not Assigned( vstBackupLog.FocusedNode ) then
    Exit;
  NodeData := vstBackupLog.GetNodeData( vstBackupLog.FocusedNode );
  Params.DesItemID := DesItemID;
  Params.SourcePath := SourcePath;
  Params.FilePath := NodeData.FilePath;
  Params.FileTime := NodeData.FileTime;

  frmPreView.SetPreviewFile( NodeData.FilePath );

  if DesItemInfoReadUtil.ReadIsLocalDes( DesItemID ) then
    BackupLogReadApi.LocalPreview( Params )
  else
    BackupLogReadApi.NetworkPreview( Params );
end;

procedure TfrmBackupLog.AddToRestore;
var
  SelectNode : PVirtualNode;
  NodeData : PVstBackupLogData;
  Params : TBackupLogReadParams;
  IsLocalBackup : Boolean;
begin
  Params.DesItemID := DesItemID;
  Params.SourcePath := SourcePath;
  IsLocalBackup := DesItemInfoReadUtil.ReadIsLocalDes( DesItemID );

  SelectNode := vstBackupLog.GetFirstSelected;
  while Assigned( SelectNode ) do
  begin
    if LogFileUtil.getIsRestore( SelectNode ) then
    begin
      NodeData := vstBackupLog.GetNodeData( SelectNode );
      Params.FilePath := NodeData.FilePath;
      Params.FileTime := NodeData.FileTime;
      if IsLocalBackup then
        BackupLogReadApi.LocalRestore( Params )
      else
        BackupLogReadApi.NetworkRestore( Params );
    end;
    SelectNode := vstBackupLog.GetNextSelected( SelectNode );
  end;
end;

procedure TfrmBackupLog.btnClearClick(Sender: TObject);
begin
  BackupLogApi.ClearCompleted( DesItemID, SourcePath );
  BackupLogApi.ClearIncompleted( DesItemID, SourcePath );
end;

procedure TfrmBackupLog.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmBackupLog.btnPreviewClick(Sender: TObject);
begin
  ShowPreviewForm;
  AddToPreview;
end;

procedure TfrmBackupLog.btnRefreshClick(Sender: TObject);
begin
  BackupLogApi.RefreshLogFace( DesItemID, SourcePath );
end;

procedure TfrmBackupLog.btnRestoreClick(Sender: TObject);
begin
  AddToRestore;
end;

procedure TfrmBackupLog.btnSearchClick(Sender: TObject);
var
  FileName : string;
  LogFileSearchHandle : TLogFileSearchHandle;
begin
  FileName := cbbFileName.Text;

    // 过滤
  LogFileSearchHandle := TLogFileSearchHandle.Create( FileName );
  LogFileSearchHandle.Update;
  LogFileSearchHandle.Free;

    // 添加到历史
  AddHistory( FileName );
end;

procedure TfrmBackupLog.cbbFileNameKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    btnSearch.Click;
end;

procedure TfrmBackupLog.ClearItems;
begin
  vstBackupLog.Clear;
  vstIncompleted.Clear;
  IncompletedCount := 0;
end;

procedure TfrmBackupLog.ClosePreviewForm;
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
end;

procedure TfrmBackupLog.edtFileNameKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    btnSearch.Click;
end;

procedure TfrmBackupLog.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if PreviewForm_IsShow then
    frmPreView.Close;
end;

procedure TfrmBackupLog.FormCreate(Sender: TObject);
begin
  vstBackupLog.NodeDataSize := SizeOf( TVstBackupLogData );
  vstBackupLog.Images := MyIcon.getSysIcon;

  vstIncompleted.NodeDataSize := SizeOf( TVstBackupLogData );
  vstIncompleted.Images := MyIcon.getSysIcon;

  LoadIni;
end;

procedure TfrmBackupLog.FormDestroy(Sender: TObject);
begin
  SaveIni;
end;

procedure TfrmBackupLog.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TfrmBackupLog.FormShow(Sender: TObject);
begin
  tbtnRestore.Enabled := False;
  tbtnPreview.Enabled := False;
  tbtnPreview.Down := False;
  tbtnSearch.Down := False;
  plSearch.Visible := False;
end;

procedure TfrmBackupLog.LoadIni;
var
  IniFile : TIniFile;
  i, ItemCount: Integer;
  s : string;
begin
  IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  ItemCount := IniFile.ReadInteger( Self.Name, cbbFileName.Name + 'Count', 0 );
  for i := 0 to ItemCount - 1 do
  begin
    s := IniFile.ReadString( Self.Name, cbbFileName.Name + IntToStr(i), '' );
    cbbFileName.Items.Add( s );
  end;
  IniFile.Free;
end;

procedure TfrmBackupLog.SaveIni;
var
  IniFile : TIniFile;
  i: Integer;
begin
    // 没有权限写
  if not MyIniFile.ConfirmWriteIni then
    Exit;

  IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  try
    IniFile.WriteInteger( Self.Name, cbbFileName.Name + 'Count', cbbFileName.Items.Count );
    for i := 0 to cbbFileName.Items.Count - 1 do
      IniFile.WriteString( Self.Name, cbbFileName.Name + IntToStr(i), cbbFileName.Items[i] );
  except
  end;
  IniFile.Free;
end;

procedure TfrmBackupLog.SetItemInfo(_DesItemID, _SourcePath: string);
begin
  DesItemID := _DesItemID;
  SourcePath := _SourcePath;
  Self.Caption := MyFileInfo.getFileName( SourcePath ) + ' Logs';
end;

procedure TfrmBackupLog.ShowLog;
begin
  if IncompletedCount <= 0 then
  begin
    tsCompleted.TabVisible := False;
    tsInCompleted.TabVisible := False;
    PcMain.ShowCardFrame := False;
    PcMain.ActivePage := tsCompleted;
  end
  else
  begin
    tsCompleted.TabVisible := True;
    tsInCompleted.TabVisible := True;
    PcMain.ShowCardFrame := True;
    PcMain.ActivePage := tsInCompleted;
    tsInCompleted.Caption := 'Incompleted (' + IntToStr(IncompletedCount) + ')';
  end;
  Show;
end;

procedure TfrmBackupLog.ShowPreviewForm;
var
  NodeData : PVstBackupLogData;
  DelWidth : Integer;
begin
    // 取消预览
  if PreviewForm_IsShow then
  begin
    frmPreView.Close;
    Exit;
  end;

  if not Assigned( vstBackupLog.FocusedNode ) then
    Exit;
  NodeData := vstBackupLog.GetNodeData( vstBackupLog.FocusedNode );

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
end;


procedure TfrmBackupLog.tbtnCollapseClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
begin
  SelectNode := vstBackupLog.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    if vstBackupLog.Expanded[ SelectNode ] then
      vstBackupLog.Expanded[ SelectNode ] := False;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TfrmBackupLog.tbtnExpandClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
begin
  SelectNode := vstBackupLog.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    if not vstBackupLog.Expanded[ SelectNode ] then
      vstBackupLog.Expanded[ SelectNode ] := True;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TfrmBackupLog.tbtnExplorerClick(Sender: TObject);
var
  NodeData : PVstBackupLogData;
begin
  if not Assigned( vstBackupLog.FocusedNode ) then
    Exit;
  NodeData := vstBackupLog.GetNodeData( vstBackupLog.FocusedNode );
  MyExplore.OpenFolder( NodeData.FilePath );
end;

procedure TfrmBackupLog.tbtnPreviewClick(Sender: TObject);
begin
  ShowPreviewForm;
  AddToPreview;
end;

procedure TfrmBackupLog.tbtnRestoreClick(Sender: TObject);
begin
  AddToRestore;
end;

procedure TfrmBackupLog.tbtnSearchClick(Sender: TObject);
var
  LogFileSearchHandle : TLogFileSearchHandle;
begin
  plSearch.Visible := tbtnSearch.Down;
  if not plSearch.Visible then
  begin
    LogFileSearchHandle := TLogFileSearchHandle.Create( '*' );
    LogFileSearchHandle.Update;
    LogFileSearchHandle.Free;
  end;
end;

procedure TfrmBackupLog.tmrProgressTimer(Sender: TObject);
begin
  tmrProgress.Enabled := False;
  pbProgress.Style := pbstMarquee;
  pbProgress.Visible := True;
end;

procedure TfrmBackupLog.vstBackupLogFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
var
  IsShowPreview : Boolean;
begin
  IsShowPreview := LogFileUtil.getIsPreview( Node );

  tbtnPreview.Enabled := IsShowPreview;
  tbtnRestore.Enabled := LogFileUtil.getIsRestore( Node );
  tbtnExplorer.Enabled := LogFileUtil.getIsExplorer( Node );

    // 添加预览
  if PreviewForm_IsShow and IsShowPreview then
    AddToPreview;
end;

procedure TfrmBackupLog.vstBackupLogGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData : PVstBackupLogData;
begin
  ImageIndex := -1;
  if ( Kind = ikNormal ) or ( Kind = ikSelected ) then
  begin
    if Column = vstBackupLog_FileName then
    begin
      NodeData := Sender.GetNodeData( Node );
      ImageIndex := NodeData.MainIcon;
    end;
  end;
end;

procedure TfrmBackupLog.vstBackupLogGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  NodeData : PVstBackupLogData;
begin
  NodeData := Sender.GetNodeData( Node );
  if Column = vstBackupLog_FileName then
    CellText := NodeData.ShowName
  else
  if Column = vstBackupLog_FileDir then
    CellText := NodeData.ShowDir
  else
  if ( Column = vstBackupLog_BackupTime ) and ( NodeData.NodeType = LogNodeType_File ) then
    CellText := FormatDateTime( 'mm-dd hh:nn', NodeData.BackupTime )
  else
    CellText := '';
end;

procedure TfrmBackupLog.vstBackupLogPaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
var
  NodeData : PVstBackupLogData;
begin
  NodeData := Sender.GetNodeData( Node );
  if ( Column = vstBackupLog_FileName ) and ( NodeData.NodeType = LogNodeType_Date ) then
    TargetCanvas.Font.Style := TargetCanvas.Font.Style + [fsBold];
end;

procedure TfrmBackupLog.vstIncompletedGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData : PVstBackupLogData;
begin
  ImageIndex := -1;
  if ( Kind = ikNormal ) or ( Kind = ikSelected ) then
  begin
    if Column = vstBackupLog_FileName then
    begin
      NodeData := Sender.GetNodeData( Node );
      ImageIndex := NodeData.MainIcon;
    end;
  end;
end;

procedure TfrmBackupLog.vstIncompletedGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  NodeData : PVstBackupLogData;
begin
  NodeData := Sender.GetNodeData( Node );
  if Column = vstBackupLog_FileName then
    CellText := NodeData.ShowName
  else
  if Column = vstBackupLog_FileDir then
    CellText := NodeData.ShowDir
  else
    CellText := '';
end;

{ TLogFileSearchHandle }

constructor TLogFileSearchHandle.Create(_SearchText: string);
begin
  SearchText := _SearchText;
end;

procedure TLogFileSearchHandle.Update;
var
  vstLog : TVirtualStringTree;
  DateNode, FileNode : PVirtualNode;
  DateData, FileData : PVstBackupLogData;
  IsShowDate, IsShowFile : Boolean;
  VisibleCount : Integer;
begin
  SearchText := '*' + SearchText + '*';

  vstLog := frmBackupLog.vstBackupLog;
  DateNode := vstLog.RootNode.FirstChild;
  while Assigned( DateNode ) do
  begin
    FileNode := DateNode.FirstChild;
    IsShowDate := False;
    VisibleCount := 0;
    while Assigned( FileNode ) do
    begin
      FileData := vstLog.GetNodeData( FileNode );
      IsShowFile := MyMatchMask.Check( FileData.ShowName, SearchText );
      vstLog.IsVisible[ FileNode ] := IsShowFile;
      IsShowDate := IsShowDate or IsShowFile;
      if IsShowFile then
        Inc( VisibleCount );
      FileNode := FileNode.NextSibling;
    end;
    vstLog.IsVisible[ DateNode ] := IsShowDate;
    vstLog.Expanded[ DateNode ] := VisibleCount <= 5;
    DateData := vstLog.GetNodeData( DateNode );
    DateData.ShowDir := IntToStr( VisibleCount ) + ' Files';
    DateNode := DateNode.NextSibling;
  end;
  vstLog.Refresh;
end;

{ LogFileUtil }

class function LogFileUtil.getIsExplorer(SelectNode: PVirtualNode): Boolean;
var
  NodeData : PVstBackupLogData;
begin
  try
    Result := getIsPreview( SelectNode );
    if not Result then
      Exit;
    NodeData := frmBackupLog.vstBackupLog.GetNodeData( SelectNode );
    Result := FileExists( NodeData.FilePath );
    if not Result then
      Exit;
    Result := MyDatetime.Equals( NodeData.FileTime, MyFileInfo.getFileLastWriteTime( NodeData.FilePath ) );
  except
    Result := False;
  end;
end;

class function LogFileUtil.getIsPreview(SelectNode: PVirtualNode): Boolean;
var
  vstLog : TVirtualStringTree;
  IsShowPreview, IsShowRestore, IsShowExplorer : Boolean;
  NodeData : PVstBackupLogData;
begin
  try
    vstLog := frmBackupLog.vstBackupLog;

    Result := Assigned( SelectNode ) and ( SelectNode.Parent <> vstLog.RootNode );
    if Result then
    begin
      NodeData := vstLog.GetNodeData( SelectNode );
      Result := NodeData.NodeType = LogNodeType_File;
    end;
  except
    Result := False;
  end;
end;

class function LogFileUtil.getIsRestore(SelectNode: PVirtualNode): Boolean;
var
  NodeData : PVstBackupLogData;
begin
  try
    Result := getIsPreview( SelectNode );
    if not Result then
      Exit;
    NodeData := frmBackupLog.vstBackupLog.GetNodeData( SelectNode );
    Result := not MyDatetime.Equals( NodeData.FileTime, MyFileInfo.getFileLastWriteTime( NodeData.FilePath ) );
  except
    Result := False;
  end;
end;

end.
