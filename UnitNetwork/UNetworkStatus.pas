unit UNetworkStatus;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, VirtualTrees,
  RzTabs, Vcl.ImgList, Vcl.ExtCtrls, UFormUtil;

type
  TfrmNeworkStatus = class(TForm)
    PcMain: TRzPageControl;
    tsNetworkConn: TRzTabSheet;
    tsMyPcConn: TRzTabSheet;
    vstNetworkStatus: TVirtualStringTree;
    LvMyNetworkStatus: TListView;
    PcStatus: TImageList;
    plHint: TPanel;
    PcErrorMsg: TRzPageControl;
    tsBroadcastNotAvailable: TRzTabSheet;
    tsBroadcastBindError: TRzTabSheet;
    tsLanNotConn: TRzTabSheet;
    tsInternetNotConn: TRzTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Panel2: TPanel;
    Image5: TImage;
    procedure btnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure vstNetworkStatusGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: string);
    procedure vstNetworkStatusGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure LvMyNetworkStatusChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure FormShow(Sender: TObject);
  private
    procedure AddDefaultItem;
  public
    procedure ShowNetworkStatus;
  end;

const
  VstNetworkStatus_PcName = 0;
  VstNetworkStatus_Ip = 1;
  VstNetworkStatus_Port = 2;
  VstNetworkStatus_Position = 3;
  VstNetworkStatus_CanConnect = 4;
  VstNetworkStatus_Status = 5;

const
  StatusIcon_Offline = 0;
  StatusIcon_Online = 1;
  StatusIcon_Server = 2;
  StatusIcon_CanConn = 9;
  StatusIcon_NotConn = 7;

var
  frmNeworkStatus: TfrmNeworkStatus;

implementation

uses UNetworkFace, UMainForm;

{$R *.dfm}

procedure TfrmNeworkStatus.AddDefaultItem;
var
  i: Integer;
  ItemData : TMyPcStatusData;
begin
  for i := 1 to 15 do
  begin
    ItemData := TMyPcStatusData.Create;
    with LvMyNetworkStatus.Items.Add do
    begin
      Caption := '';
      SubItems.Add('');
      Data := ItemData;
    end;
  end;

  LvMyNetworkStatus.Items[ MyPcStatusItem_NetworkMode ].Caption := 'Network Connections';
  LvMyNetworkStatus.Items[ MyPcStatusItem_BroadcastPort ].Caption := 'Broadcast Port ( UDP )';
  LvMyNetworkStatus.Items[ MyPcStatusItem_BroadcastRev ].Caption := 'Broadcast Revceive';
  LvMyNetworkStatus.Items[ MyPcStatusItem_LanIp ].Caption := 'LAN IP';
  LvMyNetworkStatus.Items[ MyPcStatusItem_LanPort ].Caption := 'LAN Port ( TCP )';
  LvMyNetworkStatus.Items[ MyPcStatusItem_LanAccept ].Caption := 'LAN Socket Accept';
  LvMyNetworkStatus.Items[ MyPcStatusItem_InternetIp ].Caption := 'Internet IP';
  LvMyNetworkStatus.Items[ MyPcStatusItem_InternetPort ].Caption := 'Internet Port ( TCP )';
  LvMyNetworkStatus.Items[ MyPcStatusItem_InternetAccept ].Caption := 'nternet Socket Accept';
  LvMyNetworkStatus.Items[ MyPcStatusItem_UpnpServer ].Caption := 'Upnp Route';
  LvMyNetworkStatus.Items[ MyPcStatusItem_UpnpPortMap ].Caption := 'Upnp Port Mapping';
end;

procedure TfrmNeworkStatus.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmNeworkStatus.FormCreate(Sender: TObject);
begin
  vstNetworkStatus.NodeDataSize := SizeOf( TNetworkStatusData );
  ListviewUtil.BindRemoveData( LvMyNetworkStatus );
  AddDefaultItem;
  FormUtil.BindEseClose( Self );
end;


procedure TfrmNeworkStatus.FormShow(Sender: TObject);
begin
  PcMain.ActivePage := tsNetworkConn;
end;

procedure TfrmNeworkStatus.LvMyNetworkStatusChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
var
  SelectItem : TListItem;
  ItemData : TMyPcStatusData;
  IsShowError : Boolean;
begin
  IsShowError := False;
  SelectItem := LvMyNetworkStatus.Selected;
  if SelectItem <> nil then
  begin
    ItemData := SelectItem.Data;
    IsShowError := ItemData.IsShowError;
  end;
  if IsShowError then
    PcErrorMsg.ActivePageIndex := ItemData.ErrorIndex;
  plHint.Visible := IsShowError;
end;

procedure TfrmNeworkStatus.ShowNetworkStatus;
begin
  PcMain.ActivePage := tsNetworkConn;
  Show;
end;

procedure TfrmNeworkStatus.vstNetworkStatusGetImageIndex(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind;
  Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData : PNetworkStatusData;
begin
  ImageIndex := -1;

  NodeData := Sender.GetNodeData( Node );
  if (Kind = ikNormal) or (Kind = ikSelected) then
  begin
    if ( Column = VstNetworkStatus_PcName ) and ( Node.Parent = Sender.RootNode ) then
    begin
      if NodeData.IsServer then
        ImageIndex := StatusIcon_Server
      else
      if NodeData.IsOnline then
        ImageIndex := StatusIcon_Online
      else
        ImageIndex := StatusIcon_Offline;
    end
    else
    if Column = VstNetworkStatus_CanConnect then
    begin
      if NodeData.IsConnect then
        ImageIndex := StatusIcon_CanConn
      else
      if NodeData.Ip <> '' then
        ImageIndex := StatusIcon_NotConn;
    end;
  end;
end;

procedure TfrmNeworkStatus.vstNetworkStatusGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  NodeData : PNetworkStatusData;
begin
  CellText := '';

  NodeData := Sender.GetNodeData( Node );

  if Column = VstNetworkStatus_Ip then
    CellText := NodeData.Ip
  else
  if Column = VstNetworkStatus_Port then
    CellText := NodeData.Port
  else
  if Column = VstNetworkStatus_Position then
  begin
    if NodeData.Ip = '' then
      Exit;
    if NodeData.IsLanConn then
      CellText := 'LAN'
    else
      CellText := 'Internet';
  end
  else
  if Column = VstNetworkStatus_CanConnect then
  begin
    if NodeData.IsConnect then
      CellText := 'Yes'
    else
    if NodeData.Ip <> '' then
      CellText := 'No';
  end
  else      // вспео╒
  if Node.Parent <> Sender.RootNode then
    CellText := ''
  else
  if Column = VstNetworkStatus_PcName then
    CellText := NodeData.PcName
  else
  if Column = VstNetworkStatus_Status then
  begin
    if NodeData.IsServer then
      CellText := 'Server'
    else
    if NodeData.IsOnline then
      CellText := 'Online'
    else
      CellText := 'Offline';
  end;
end;

end.
