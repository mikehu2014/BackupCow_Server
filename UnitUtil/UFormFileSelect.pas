unit UFormFileSelect;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, VirtualTrees, UMyUtil, UIconUtil, ExtCtrls, StdCtrls;

type

  TVstSelectFileData = record
    FullPath : WideString;
    IsFolder : Boolean;
    FileSize : Int64;
    FileTime : TDateTime;
  end;
  PVstSelectFileData = ^TVstSelectFileData;

  TfrmFileSelect = class(TForm)
    vstSelectPath: TVirtualStringTree;
    Panel1: TPanel;
    Panel2: TPanel;
    btnCancel: TButton;
    btnOK: TButton;
    procedure vstSelectPathGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure vstSelectPathGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstSelectPathInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure vstSelectPathInitChildren(Sender: TBaseVirtualTree;
      Node: PVirtualNode; var ChildCount: Cardinal);
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    procedure AddRootFolder( RootPathList, SelectList : TStringList );
    procedure AddDefaultRoot;
    function getSelectFileList : TStringList;
  private
    procedure CheckedNode( Node : PVirtualNode );
    procedure AddSelectFile( FilePath : string );
    procedure FindSelectFile( Node : PVirtualNode; SelectFileList : TStringList );
  end;

const
  VstSelectFile_FileName = 0;
  VstSelectFile_FileSize = 1;
  VstSelectFile_FileTime = 2;

var
  frmFileSelect: TfrmFileSelect;

implementation

{$R *.dfm}

{ TForm3 }

procedure TfrmFileSelect.AddSelectFile(FilePath: string);
var
  ChildNode : PVirtualNode;
  NodeData : PVstSelectFileData;
  NodeFullPath : string;
begin
  ChildNode := vstSelectPath.RootNode.FirstChild;
  while Assigned( ChildNode ) do
  begin
    NodeData := vstSelectPath.GetNodeData( ChildNode );
    NodeFullPath := NodeData.FullPath;

      // 找到了节点
    if FilePath = NodeFullPath then
    begin
      CheckedNode( ChildNode );
      Break;
    end;

      // 找到了父节点
    if MyMatchMask.CheckChild( FilePath, NodeFullPath ) then
    begin
      ChildNode.States := ChildNode.States + [ vsHasChildren ];
      ChildNode.CheckState := csMixedNormal;
      vstSelectPath.ValidateChildren( ChildNode, False );
      ChildNode := ChildNode.FirstChild;
      Continue;
    end;

      // 下一个节点
    ChildNode := ChildNode.NextSibling;
  end;
end;

procedure TfrmFileSelect.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmFileSelect.btnOKClick(Sender: TObject);
begin
  Close;
  ModalResult := mrOk;
end;

procedure TfrmFileSelect.CheckedNode(Node: PVirtualNode);
var
  ChildNode : PVirtualNode;
begin
  vstSelectPath.CheckState[ Node ] := csCheckedNormal;

  ChildNode := Node.FirstChild;
  while Assigned( ChildNode ) do
  begin
    CheckedNode( ChildNode );
    ChildNode := ChildNode.NextSibling;
  end;
end;

procedure TfrmFileSelect.FindSelectFile(Node : PVirtualNode;
  SelectFileList: TStringList);
var
  ChildNode : PVirtualNode;
  NodeData : PVstSelectFileData;
  FullPath : string;
begin
  ChildNode := Node.FirstChild;
  while Assigned( ChildNode ) do
  begin
    if ( ChildNode.CheckState = csCheckedNormal ) then  // 找到选择的路径
    begin
      NodeData := vstSelectPath.GetNodeData( ChildNode );
      FullPath := NodeData.FullPath;
      SelectFileList.Add( FullPath );
    end
    else
    if ChildNode.CheckState = csMixedNormal then  // 找下一层
      FindSelectFile( ChildNode, SelectFileList );
    ChildNode := ChildNode.NextSibling;
  end;
end;

procedure TfrmFileSelect.FormCreate(Sender: TObject);
begin
  vstSelectPath.NodeDataSize := SizeOf( TVstSelectFileData );
  vstSelectPath.Images := MyIcon.getSysIcon;
end;

procedure TfrmFileSelect.FormShow(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

function TfrmFileSelect.getSelectFileList: TStringList;
begin
  Result := TStringList.Create;
  FindSelectFile( vstSelectPath.RootNode, Result );
end;

procedure TfrmFileSelect.AddDefaultRoot;
var
  RootNode : PVirtualNode;
begin
  RootNode := vstSelectPath.RootNode.FirstChild;
  while Assigned( RootNode ) do
  begin
    if RootNode.CheckState = csUncheckedNormal then
      CheckedNode( RootNode );

      // 下一个节点
    RootNode := RootNode.NextSibling;
  end;
end;

procedure TfrmFileSelect.AddRootFolder( RootPathList,SelectList : TStringList );
var
  RootFolderNode : PVirtualNode;
  RootFolderData : PVstSelectFileData;
  i : Integer;
  FolderPath : string;
begin
  vstSelectPath.Clear;

  for i := 0 to RootPathList.Count - 1 do
  begin
    FolderPath := RootPathList[i];

    RootFolderNode := vstSelectPath.AddChild( vstSelectPath.RootNode );
    RootFolderData := vstSelectPath.GetNodeData( RootFolderNode );
    RootFolderData.FullPath := FolderPath;
    RootFolderData.IsFolder := True;
    RootFolderData.FileSize := 0;
    RootFolderData.FileTime := MyFileInfo.getFileLastWriteTime( FolderPath );

    vstSelectPath.Expanded[ RootFolderNode ] := True;
  end;

  for i := 0 to SelectList.Count - 1 do
    AddSelectFile( SelectList[i] );
end;

procedure TfrmFileSelect.vstSelectPathGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData: PVstSelectFileData;
begin
  if ( Column = VstSelectFile_FileName ) and
     ( ( Kind = ikNormal ) or ( Kind = ikSelected ) )
  then
  begin
    NodeData := Sender.GetNodeData(Node);
    ImageIndex := MyIcon.getIconByFilePath( NodeData.FullPath );
  end
  else
    ImageIndex := -1;
end;

procedure TfrmFileSelect.vstSelectPathGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  NodeData : PVstSelectFileData;
begin
  NodeData := Sender.GetNodeData( Node );
  if Column = VstSelectFile_FileName then
  begin
    if Node.Parent = Sender.RootNode then
      CellText := NodeData.FullPath
    else
      CellText := ExtractFileName( NodeData.FullPath );
  end
  else
  if Column = VstSelectFile_FileSize then
  begin
    if NodeData.IsFolder then
      CellText := ''
    else
      CellText := MySize.getFileSizeStr( NodeData.FileSize )
  end
  else
  if Column = VstSelectFile_FileTime then
    CellText := DateTimeToStr( NodeData.FileTime )
  else
    CellText := '';
end;

procedure TfrmFileSelect.vstSelectPathInitChildren(Sender: TBaseVirtualTree;
  Node: PVirtualNode; var ChildCount: Cardinal);
var
  Data, ChildData: PVstSelectFileData;
  sr: TSearchRec;
  FullPath, FileName, FilePath : string;
  FileSize : Int64;
  FileTime : TDateTime;
  IsFolder : Boolean;
  ChildNode: PVirtualNode;
  LastWriteTimeSystem: TSystemTime;
begin
  Screen.Cursor := crHourGlass;

    // 搜索目录的信息，找不到则跳过
  Data := Sender.GetNodeData(Node);
  FullPath := MyFilePath.getPath( Data.FullPath );
  if FindFirst( FullPath + '*', faAnyfile, sr ) = 0 then
  begin
    repeat
      FileName := sr.Name;
      if ( FileName = '.' ) or ( FileName = '..' ) then
        Continue;

        // 文件信息
      FilePath := FullPath + FileName;
      FileSize := sr.Size;
      FileTimeToSystemTime( sr.FindData.ftLastWriteTime, LastWriteTimeSystem );
      LastWriteTimeSystem.wMilliseconds := 0;
      FileTime := SystemTimeToDateTime( LastWriteTimeSystem );
      IsFolder := DirectoryExists( FilePath );

        // 子节点数据
      ChildNode := Sender.AddChild( Node );
      ChildData := Sender.GetNodeData(ChildNode);
      ChildData.FullPath := FilePath;
      ChildData.FileSize := FileSize;
      ChildData.FileTime := FileTime;
      ChildData.IsFolder := IsFolder;

        // 初始化
      if Node.CheckState = csCheckedNormal then   // 如果父节点全部Check, 则子节点 check
        ChildNode.CheckState := csCheckedNormal;

        // 子节点数目
      Inc( ChildCount );

    until FindNext(sr) <> 0;
  end;
  FindClose(sr);
  Screen.Cursor := crDefault;
end;

procedure TfrmFileSelect.vstSelectPathInitNode(Sender: TBaseVirtualTree;
  ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
var
  NodeData: PVstSelectFileData;
begin
  NodeData := Sender.GetNodeData(Node);

  if MyFilePath.getHasChild( NodeData.FullPath ) then
    Include( InitialStates, ivsHasChildren );

  Node.CheckType := ctTriStateCheckBox;
end;


end.
