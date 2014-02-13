unit UFormBackupPcFilter;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  VirtualTrees, Vcl.ImgList, Vcl.ToolWin, UMainForm;

type
  TfrmSendPcFilter = class(TForm)
    Panel2: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    vstGroupPc: TVirtualStringTree;
    ilNw16: TImageList;
    tbMain: TToolBar;
    tbtnSelectOnline: TToolButton;
    tbtnSelectAll: TToolButton;
    tbtnRemoveAll: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure vstGroupPcGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstGroupPcGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure btnCancelClick(Sender: TObject);
    procedure tbtnSelectOnlineClick(Sender: TObject);
    procedure tbtnSelectAllClick(Sender: TObject);
    procedure tbtnRemoveAllClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    SelectItemList : TStringList;
    procedure LoadIni;
    procedure SaveIni;
  public
    function getIsSelectPc : Boolean;
    function getSelectItemList : TStringList;
    function getIsChecked( DesItemID : string ): Boolean;
  end;

const
  VstGroupPc_ComputerName = 0;
  VstGroupPc_Directory = 1;

var
  frmSendPcFilter: TfrmSendPcFilter;

implementation

uses UMyBackupFaceInfo, IniFiles, UMyUtil;

{$R *.dfm}

procedure TfrmSendPcFilter.btnCancelClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  NodeData : PBackupPcFilterData;
begin
  Close;

  SelectNode := vstGroupPc.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstGroupPc.GetNodeData( SelectNode );
    if SelectItemList.IndexOf( NodeData.DesItemID ) >= 0 then
      vstGroupPc.CheckState[ SelectNode ] := csCheckedNormal
    else
      vstGroupPc.CheckState[ SelectNode ] := csUncheckedNormal;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TfrmSendPcFilter.btnOKClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  NodeData : PBackupPcFilterData;
begin
  Close;
  ModalResult := mrOk;

  SelectItemList.Clear;
  SelectNode := vstGroupPc.GetFirstChecked;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstGroupPc.GetNodeData( SelectNode );
    SelectItemList.Add( NodeData.DesItemID );
    SelectNode := vstGroupPc.GetNextChecked( SelectNode );
  end;
end;

procedure TfrmSendPcFilter.FormCreate(Sender: TObject);
begin
  vstGroupPc.NodeDataSize := SizeOf( TBackupPcFilterData );
  SelectItemList := TStringList.Create;
  LoadIni;
end;

procedure TfrmSendPcFilter.FormDestroy(Sender: TObject);
begin
  SaveIni;
  SelectItemList.Free;
end;

procedure TfrmSendPcFilter.FormShow(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

function TfrmSendPcFilter.getIsChecked(DesItemID: string): Boolean;
begin
  Result := SelectItemList.IndexOf( DesItemID ) >= 0;
end;

function TfrmSendPcFilter.getIsSelectPc: Boolean;
begin
  Result := ShowModal = mrOk;
end;

function TfrmSendPcFilter.getSelectItemList: TStringList;
begin
  Result := SelectItemList;
end;

procedure TfrmSendPcFilter.LoadIni;
var
  IniFile : TIniFile;
  SelectCount, i : Integer;
  SelectItemStr : string;
begin
  IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  SelectCount := IniFile.ReadInteger( Self.Name, vstGroupPc.Name + '.Count', 0 );
  for i := 0 to SelectCount - 1 do
  begin
    SelectItemStr := IniFile.ReadString( Self.Name, vstGroupPc.Name + '.' + IntToStr( i ), '' );
    if SelectItemStr = '' then
      Continue;
    SelectItemList.Add( SelectItemStr );
  end;
  IniFile.Free;
end;

procedure TfrmSendPcFilter.SaveIni;
var
  IniFile : TIniFile;
  i: Integer;
begin
    // 没有权限写
  if not MyIniFile.ConfirmWriteIni then
    Exit;

  IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  try
    IniFile.WriteInteger( Self.Name, vstGroupPc.Name + '.Count', SelectItemList.Count );
    for i := 0 to SelectItemList.Count - 1 do
      IniFile.WriteString( Self.Name, vstGroupPc.Name + '.' + IntToStr( i ), SelectItemList[i] );
  except
  end;
  IniFile.Free;
end;

procedure TfrmSendPcFilter.tbtnRemoveAllClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
begin
  SelectNode := vstGroupPc.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    vstGroupPc.CheckState[ SelectNode ] := csUncheckedNormal;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TfrmSendPcFilter.tbtnSelectAllClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
begin
  SelectNode := vstGroupPc.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    vstGroupPc.CheckState[ SelectNode ] := csCheckedNormal;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TfrmSendPcFilter.tbtnSelectOnlineClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  NodeData : PBackupPcFilterData;
begin
  SelectNode := vstGroupPc.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstGroupPc.GetNodeData( SelectNode );
    if NodeData.IsOnline then
      vstGroupPc.CheckState[ SelectNode ] := csCheckedNormal
    else
      vstGroupPc.CheckState[ SelectNode ] := csUncheckedNormal;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TfrmSendPcFilter.vstGroupPcGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData : PBackupPcFilterData;
begin
  if ( Column = VstGroupPc_ComputerName ) and
     ( ( Kind = ikNormal ) or ( Kind = ikSelected ) )
  then
  begin
    NodeData := Sender.GetNodeData( Node );
    ImageIndex := NodeData.MainIcon;
  end
  else
    ImageIndex := -1;
end;

procedure TfrmSendPcFilter.vstGroupPcGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  NodeData : PBackupPcFilterData;
begin
  NodeData := Sender.GetNodeData( Node );
  if Column = VstGroupPc_ComputerName then
    CellText := NodeData.ComputerName
  else
  if Column = VstGroupPc_Directory then
    CellText := NodeData.Directory
  else
    CellText := '';
end;

end.
