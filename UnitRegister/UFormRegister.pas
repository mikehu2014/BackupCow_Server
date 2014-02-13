unit UFormRegister;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, IdHTTP, ComCtrls, ImgList, ToolWin, IniFiles, kg_dnc, UFormUtil,
  RzTabs, Menus, VirtualTrees;

type

  TfrmRegister = class(TForm)
    plActivate: TPanel;
    plTitle: TPanel;
    Label2: TLabel;
    plDiaBtn: TPanel;
    plContent: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    Image2: TImage;
    PcActivate: TRzPageControl;
    tsOnline: TRzTabSheet;
    plSelectPc: TPanel;
    tsOffline: TRzTabSheet;
    plOrderID: TPanel;
    lbBatOrderNumber: TLabel;
    edtBatOrderNum: TEdit;
    plOnlineTitle: TPanel;
    Panel7: TPanel;
    pmSelectComputer: TPopupMenu;
    SelectmyComputer1: TMenuItem;
    SelectAll1: TMenuItem;
    tbSelectComputer: TToolBar;
    tbtnSelectAll: TToolButton;
    btnUnSelectAll: TToolButton;
    ilPcMain: TImageList;
    SelectUnregistered1: TMenuItem;
    ilLvRegister: TImageList;
    LinkLabel1: TLinkLabel;
    tbtnRemove: TToolButton;
    vstRegister: TVirtualStringTree;
    pmPcFilter: TPopupMenu;
    MyComputer1: TMenuItem;
    UnregisterComputers1: TMenuItem;
    OnlineComputers1: TMenuItem;
    AllComputers1: TMenuItem;
    ToolButton1: TToolButton;
    tbtnPcFilter: TToolButton;
    plBatLicense: TPanel;
    mmoBatLicense: TMemo;
    Panel4: TPanel;
    Panel1: TPanel;
    Label1: TLabel;
    Panel2: TPanel;
    Label3: TLabel;
    edtHardCode: TEdit;
    btnCopy: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnBuyNowClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure lvComputerDeletion(Sender: TObject; Item: TListItem);
    procedure tbSelectAllClick(Sender: TObject);
    procedure btnUnSelectAllClick(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
    procedure lvComputerCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure btnCancelClick(Sender: TObject);
    procedure LinkLabel1LinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure Label2MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtBatOrderNumKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure vstRegisterGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstRegisterGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure tbtnRemoveClick(Sender: TObject);
    procedure tbtnSelectAllClick(Sender: TObject);
    procedure MyPcFilterClick(Sender: TObject);
    procedure tbtnPcFilterClick(Sender: TObject);
    procedure vstRegisterChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure btnCopyClick(Sender: TObject);
  private
    procedure SetVstRegisterChecked( IsChecked : Boolean );
    procedure SetDefaultSelect;
  private
    procedure BindToolBar;
    procedure BindSort;
  private       // 保存过滤信息
    procedure SaveIni;
    procedure LoadIni;
    procedure ReadHardCode;
  end;

{$Region ' 批激活 ' }

    // 批注册 License 处理
  TBatLicenseHandle = class
  private
    BatLicenseStr : string;
  public
    constructor Create( _BatLicenseStr : string );
    procedure Update;
  end;

    // 在线 批激活
  TOnlineBatActivate = class
  public
    OrderID : string;
  private
    HardCodeListStr : string;
    BatLicenseStr : string;
  public
    constructor Create( _OrderID : string );
    function get : Boolean;
  private
    function FindHardCodeListStr : Boolean;
    function FindBatLicenseStr : Boolean;
    procedure HandleBatLicense;
    procedure CancelSelectPc;
  end;

    // 离线 批激活
  TOfflineActivate = class
  public
    LicenseStr : string;
  public
    constructor Create( _LicenseStr : string );
    function get : Boolean;
  private
    function CheckLicenseStr: Boolean;
    procedure HandleLicenseStr;
  end;

      // 激活
  TBatActivateHandle = class
  public
    procedure Update;
  private
    function OnlineActivate : Boolean;
    function OfflineActivate : Boolean;
  end;

{$EndRegion}

  RegisterPcFilterUtil = class
  public
    class procedure SetFilterIndex( SelectIndex : Integer );
    class function getFilterIndex : Integer;
    class function getIsNodeShow( Node : PVirtualNode ): Boolean;
    class procedure RefreshShowNode;
  end;


const
  ShowHint_InputOrder : string = 'Please input order number.';
  ShowHint_SelectPc : string = 'Please select computer to register.';
  ShowForm_LicenseError : string = 'License is incorrect.';
  ShowForm_RegisterComplete : string = 'Congratulations, you have successfully ' +
                                       'completed Backup Cow software registration.';
  ShowForm_InputLicense : string = 'Please input License.';

  HttpReq_HardCode = 'HardCode';
  HttpReq_OrderID = 'OrderID';
  HttpReq_ActivateType = 'ActivateType';

  Split_Pc = '|';
  Split_PcInfo = '}';

  Split_Result = ']';
  Split_Computer = '{';
  Split_ComputerInfo = '[';

  HttpResult_OK = 'OK';
  HttpResult_Error = 'Error';

  ActivateType_Server = 'Server';

const
  RegisterPcFilterIndex_MyPc = 0;
  RegisterPcFilterIndex_UnregisterPc = 1;
  RegisterPcFilterIndex_OnlinePc = 2;
  RegisterPcFilterIndex_AllPc = 3;

  RegisterPcFilter_MyPc = 'MyPc';
  RegisterPcFilter_UnregisterPc = 'UnregisterPc';
  RegisterPcFilter_OnlinePc = 'OnlinePc';
  RegisterPcFilter_AllPc = 'AllPc';

const
  VstRegister_PcName = 0;
  VstRegister_PcID = 1;
  VstRegister_PcEdition = 2;

const
  Split_HardCodeStr = ':';

var
  frmRegister: TfrmRegister;
  Filter_RegisterPc : string = RegisterPcFilter_MyPc;

implementation

uses UMyUtil, DateUtils, UMyUrl, URegisterInfoIO, UMainForm, UNetworkFace, UMyNetPcInfo,
     UMyClient, UMyRegisterFaceInfo, UMyRegisterApiInfo, UBackupCow;

{$R *.dfm}

procedure TfrmRegister.BindSort;
begin
end;

procedure TfrmRegister.BindToolBar;
begin
  vstRegister.PopupMenu := FormUtil.getPopMenu( tbSelectComputer );
end;

procedure TfrmRegister.btnBuyNowClick(Sender: TObject);
begin
  MyInternetExplorer.OpenWeb( MyProductUrl.BuyNow );
end;

procedure TfrmRegister.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmRegister.btnCopyClick(Sender: TObject);
begin
  edtHardCode.SelectAll;
  edtHardCode.CopyToClipboard;
end;

procedure TfrmRegister.btnOKClick(Sender: TObject);
var
  BatActivateHandle : TBatActivateHandle;
begin
  BatActivateHandle := TBatActivateHandle.Create;
  BatActivateHandle.Update;
  BatActivateHandle.Free;
end;

procedure TfrmRegister.btnUnSelectAllClick(Sender: TObject);
begin
  SetVstRegisterChecked( False );
end;

procedure TfrmRegister.edtBatOrderNumKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_Return then
    btnOK.Click;
end;

procedure TfrmRegister.FormCreate(Sender: TObject);
begin
  BindSort;
  BindToolBar;
  vstRegister.NodeDataSize := SizeOf( TVstRegisterData );
  LoadIni;
  ReadHardCode;
end;

procedure TfrmRegister.FormDestroy(Sender: TObject);
begin
  SaveIni;
end;

procedure TfrmRegister.FormShow(Sender: TObject);
begin
  PcActivate.ActivePage := tsOnline;
  SetDefaultSelect;
  FormUtil.SetFocuse( edtBatOrderNum );
end;

procedure TfrmRegister.Label2MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  InputStr : string;
begin
  if not ( ssCtrl in Shift ) or ( Button <> mbRight ) then
    Exit;

  InputStr := InputBox( 'Infomation', 'Backup Cow', '' );
  if InputStr = 'clear' then
    MyRegisterUserApi.SetLicense( '' )
  else
  if InputStr = 'trial' then
    TestUtil.TestTrial;
end;

procedure TfrmRegister.LinkLabel1LinkClick(Sender: TObject;
  const Link: string; LinkType: TSysLinkType);
begin
  MyInternetExplorer.OpenWeb( MyProductUrl.BuyNow );
end;

procedure TfrmRegister.lvComputerCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
var
  LvTag : Integer;
  ColumnNum, SortNum, SortType : Integer;
  ItemStr1, ItemStr2 : string;
  SortStr1, SortStr2 : string;
  CompareSize : Int64;
begin
  LvTag := ( Sender as TListView ).Tag;

  SortType := LvTag div 1000;
  LvTag := LvTag mod 1000;
  SortNum := LvTag div 100;
  LvTag := LvTag mod 100;
  ColumnNum := LvTag;

    // 找出 要排序的列
  if ColumnNum = 0 then
  begin
    ItemStr1 := Item1.Caption;
    ItemStr2 := Item2.Caption;
  end
  else
  begin
    ItemStr1 := Item1.SubItems[ ColumnNum - 1 ];
    ItemStr2 := Item2.SubItems[ ColumnNum - 1 ];
  end;

    // 正序/倒序 排序
  if SortNum = 1 then
  begin
    SortStr1 := ItemStr1;
    SortStr2 := ItemStr2;
  end
  else
  begin
    SortStr1 := ItemStr2;
    SortStr2 := ItemStr1;
  end;

    // 不同列, 不同比较方式
  if ColumnNum = LvRetister_Edition + 1 then
    Compare := RegisterApiReadUtil.ReadEditionInt( SortStr1 ) - RegisterApiReadUtil.ReadEditionInt( SortStr2 )
  else
    Compare := CompareText( SortStr1, SortStr2 );
end;

procedure TfrmRegister.lvComputerDeletion(Sender: TObject; Item: TListItem);
var
  ItemData : TObject;
begin
  ItemData := Item.Data;
  ItemData.Free;
end;

procedure TfrmRegister.MyPcFilterClick(Sender: TObject);
var
  mi : TMenuItem;
  i: Integer;
begin
  mi := Sender as TMenuItem;
  for i := 0 to pmPcFilter.Items.Count - 1 do
    if pmPcFilter.Items[i] = mi then
    begin
      RegisterPcFilterUtil.SetFilterIndex( i );
      Break;
    end;
end;

procedure TfrmRegister.ReadHardCode;
var
  MacAdressStr, PcID : string;
  HardCodeStr : string;
begin
  MacAdressStr := MyMacAddress.getStr;
  PcID := MyComputerID.get;
  HardCodeStr := MacAdressStr + Split_HardCodeStr + PcID;
  edtHardCode.Text := HardCodeStr;
end;

procedure TfrmRegister.SelectAll1Click(Sender: TObject);
begin
  SetVstRegisterChecked( True );
end;

procedure TfrmRegister.SetDefaultSelect;
var
  SelectNode : PVirtualNode;
begin
  if vstRegister.CheckedCount > 0 then
    Exit;
  if vstRegister.RootNodeCount <= 0 then
    Exit;

  SelectNode := vstRegister.GetFirstVisible;
  if not Assigned( SelectNode ) then
    SelectNode := vstRegister.RootNode.FirstChild;
  vstRegister.CheckState[ SelectNode ] := csCheckedNormal;
end;

procedure TfrmRegister.SetVstRegisterChecked(IsChecked: Boolean);
var
  SelectNode : PVirtualNode;
begin
  SelectNode := vstRegister.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    if IsChecked then
      vstRegister.CheckState[ SelectNode ] := csCheckedNormal
    else
      vstRegister.CheckState[ SelectNode ] := csUncheckedNormal;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TfrmRegister.tbSelectAllClick(Sender: TObject);
begin
  SetVstRegisterChecked( True );
end;

procedure TfrmRegister.tbtnPcFilterClick(Sender: TObject);
begin
  tbtnPcFilter.Down := True;
  tbtnPcFilter.CheckMenuDropdown;
end;

procedure TfrmRegister.tbtnRemoveClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  NodeData : PVstRegisterData;
begin
  if not MyMessageBox.ShowRemoveComfirm then
    Exit;

  SelectNode := vstRegister.GetFirstSelected;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstRegister.GetNodeData( SelectNode );
    RegisterShowAppApi.RemoveItem( NodeData.PcID );
    SelectNode := vstRegister.GetNextSelected( SelectNode );
  end;
end;

procedure TfrmRegister.tbtnSelectAllClick(Sender: TObject);
begin
  SetVstRegisterChecked( True );
end;

procedure TfrmRegister.vstRegisterChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  tbtnRemove.Enabled := vstRegister.SelectedCount > 0;
end;

procedure TfrmRegister.vstRegisterGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData : PVstRegisterData;
begin
  ImageIndex := -1;
  if (Kind = ikNormal) or (Kind = ikSelected) then
  begin
    NodeData := Sender.GetNodeData( Node );
    if Column = VstRegister_PcName then
      ImageIndex := NodeData.MainIcon
    else
    if Column = VstRegister_PcEdition then
      ImageIndex := NodeData.EditionIcon;
  end;
end;

procedure TfrmRegister.vstRegisterGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  NodeData : PVstRegisterData;
begin
  NodeData := Sender.GetNodeData( Node );
  if Column = VstRegister_PcName then
    CellText := NodeData.PcName
  else
  if Column = VstRegister_PcID then
    CellText := NodeData.PcID
  else
  if Column = VstRegister_PcEdition then
    CellText := NodeData.Edition
  else
    CellText := '';
end;

{ TOnlineBatActivate }

procedure TOnlineBatActivate.CancelSelectPc;
begin
  frmRegister.btnUnSelectAll.Click;
end;

constructor TOnlineBatActivate.Create(_OrderID: string);
begin
  OrderID := _OrderID;
end;

function TOnlineBatActivate.FindHardCodeListStr: Boolean;
var
  vstRegister : TVirtualStringTree;
  SelectNode : PVirtualNode;
  SelectData : PVstRegisterData;
  PcStr : string;
begin
  HardCodeListStr := '';

  vstRegister := frmRegister.vstRegister;
  SelectNode := vstRegister.GetFirstChecked;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstRegister.GetNodeData( SelectNode );
    if vstRegister.IsVisible[ SelectNode ] and ( SelectData.HardCode <> '' ) then
    begin
      PcStr := SelectData.HardCode + Split_PcInfo + SelectData.PcName;
      PcStr := PcStr + Split_PcInfo + SelectData.PcID;
      if HardCodeListStr <> '' then
        HardCodeListStr := HardCodeListStr + Split_Pc;
      HardCodeListStr := HardCodeListStr + PcStr;
    end;
    SelectNode := vstRegister.GetNextChecked( SelectNode );
  end;

  Result := HardCodeListStr <> '';
end;

procedure TOnlineBatActivate.HandleBatLicense;
var
  BatLicenseHandle : TBatLicenseHandle;
begin
  BatLicenseHandle := TBatLicenseHandle.Create( BatLicenseStr );
  BatLicenseHandle.Update;
  BatLicenseHandle.Free;
end;

function TOnlineBatActivate.FindBatLicenseStr: Boolean;
var
  HttpStr : string;
  HttpResult, LicenseResult : string;
  params, ResultList : TStringList;
  idhttp : TIdHTTP;
begin
  Result := False;

  frmRegister.btnOK.Enabled := False;
  Application.ProcessMessages;

  params := TStringList.Create;
  params.Add( HttpReq_OrderID + '=' + orderID );
  params.Add( HttpReq_HardCode + '=' + HardCodeListStr );
  params.Add( HttpReq_ActivateType + '=' + ActivateType_Server );

  idhttp := TIdHTTP.Create(nil);
  idhttp.ReadTimeout := 60000;
  idhttp.ConnectTimeout := 60000;
  try
    HttpStr := idhttp.Post( MyUrl.getBatPayKey, params );
    ResultList := MySplitStr.getList( HttpStr, Split_Result );
    if ResultList.Count = 2 then
    begin
      HttpResult := ResultList[0];
      LicenseResult := ResultList[1];
      if HttpResult = HttpResult_OK then
      begin
        Result := True;
        BatLicenseStr := LicenseResult;
      end
      else
      if HttpResult = HttpResult_Error then
        MyMessageBox.ShowError( frmRegister.Handle, LicenseResult );
    end;
    ResultList.Free;
  except
  end;
  idhttp.Free;
  params.Free;
  frmRegister.btnOK.Enabled := True;
end;

function TOnlineBatActivate.get: Boolean;
begin
  Result := False;

    // Order Number
  if OrderID = '' then
  begin
    MyMessageHint.ShowError( frmRegister.edtBatOrderNum.Handle, ShowHint_InputOrder );
    Exit;
  end;

    // Select Computer
  if not FindHardCodeListStr then
  begin
    MyMessageHint.ShowError( frmRegister.vstRegister.Handle, ShowHint_SelectPc );
    Exit;
  end;

    // Activate Error
  if not FindBatLicenseStr then
    Exit;

    // 显示 激活成功
  CancelSelectPc;

    // 处理 Bat License;
  HandleBatLicense;

  Result := True;
end;

{ TOfflineBatActivate }

function TOfflineActivate.CheckLicenseStr: Boolean;
var
  DecryptedLicenseStr : string;
  LincenseList : TStringList;
  Hardcode, EditionNum, LastDateStr : string;
  LastDate : TDateTime;
begin
  Result := False;

    // licenseStr 为空
  if LicenseStr = '' then
    Exit;

    // 解密
  DecryptedLicenseStr := KeyDec( LicenseStr );

    // 提取 Lincense 信息
  LincenseList := MySplitStr.getList( DecryptedLicenseStr, Lincense_Split );
  if LincenseList.Count = 3 then
  begin
    Hardcode := LincenseList[ Lincense_HardCode ];
    EditionNum := LincenseList[ Lincense_EditionInfo ];
    LastDateStr := LincenseList[ Lincense_LastDate ];
    Result := MyMacAddress.Equals( Hardcode );
    if Result then
    begin
      LastDate := StrToFloatDef( LastDateStr, Now );
      Result := LastDate > Now;
    end;
  end;
  LincenseList.Free;
end;

constructor TOfflineActivate.Create(_LicenseStr: string);
begin
  LicenseStr := _LicenseStr;
end;

procedure TOfflineActivate.HandleLicenseStr;
begin
  MyRegisterUserApi.SetLicense( LicenseStr );
end;

function TOfflineActivate.get : Boolean;
begin
  if CheckLicenseStr then
  begin
    HandleLicenseStr;
    Result := True;
  end
  else
  begin
    MyMessageBox.ShowWarnning( frmRegister.Handle, ShowForm_LicenseError );
    Result := False;
  end;
end;

{ TBatActivateClick }

function TBatActivateHandle.OfflineActivate: Boolean;
var
  BatLicneseStr : string;
  OfflineBatActivate : TOfflineActivate;
begin
  Result := False;

  BatLicneseStr := frmRegister.mmoBatLicense.Text;

  if BatLicneseStr = '' then
  begin
    MyMessageBox.ShowWarnning( frmRegister.Handle, ShowForm_InputLicense );
    Exit;
  end;

  OfflineBatActivate := TOfflineActivate.Create( BatLicneseStr );
  Result := OfflineBatActivate.get;
  OfflineBatActivate.Free;
end;

function TBatActivateHandle.OnlineActivate: Boolean;
var
  OrderID : string;
  OnlineBatActivate : TOnlineBatActivate;
begin
  OrderID := frmRegister.edtBatOrderNum.Text;

  OnlineBatActivate := TOnlineBatActivate.Create( OrderID );
  Result := OnlineBatActivate.get;
  OnlineBatActivate.Free
end;

procedure TBatActivateHandle.Update;
var
  IsActiveSuccess : Boolean;
begin
    // 批激活 方式
  if frmRegister.PcActivate.ActivePage = frmRegister.tsOnline then
    IsActiveSuccess := OnlineActivate
  else
    IsActiveSuccess := OfflineActivate;

    // 激活 失败 跳过
  if not IsActiveSuccess then
    Exit;

    // 显示 激活成功
  MyMessageBox.ShowOk( frmRegister.Handle, ShowForm_RegisterComplete );
  frmRegister.Close;
end;

{ TBatLicenseHandle }

constructor TBatLicenseHandle.Create(_BatLicenseStr: string);
begin
  BatLicenseStr := _BatLicenseStr;
end;

procedure TBatLicenseHandle.Update;
var
  Computer, PcID, LicenseStr, DecLicense : string;
  ComputerList, ComputerInfoList : TStringList;
  i : Integer;
  SplitList : TStringList;
begin
  ComputerList := MySplitStr.getList( BatLicenseStr, Split_Computer );
  for i := 0 to ComputerList.Count - 1 do
  begin
    Computer := ComputerList[i];
    ComputerInfoList := MySplitStr.getList( Computer, Split_ComputerInfo );
    if ComputerInfoList.Count = 2 then
    begin
      PcID := ComputerInfoList[0];
      LicenseStr := ComputerInfoList[1];

        // 添加
      RegisterActivatePcApi.AddItem( PcID, LicenseStr );
    end;
    ComputerInfoList.Free;
  end;
  ComputerList.Free;
end;

{ RegisterPcFilterUtil }

class function RegisterPcFilterUtil.getFilterIndex: Integer;
var
  pmFilter : TPopupMenu;
  i: Integer;
  mi : TMenuItem;
begin
  Result := -1;
  pmFilter := frmRegister.pmPcFilter;
  for i := 0 to pmFilter.Items.Count - 1 do
  begin
    mi := pmFilter.Items[i];
    if mi.ImageIndex = ImgIndex_PcFilterSelect then
    begin
      Result := i;
      Break;
    end;
  end;
  if Result = -1 then
    Result := 0;
end;

class function RegisterPcFilterUtil.getIsNodeShow(Node: PVirtualNode): Boolean;
var
  NodeData : PVstRegisterData;
begin
  NodeData := frmRegister.vstRegister.GetNodeData( Node );
  if Filter_RegisterPc = RegisterPcFilter_MyPc then
    Result := NodeData.PcID = Network_LocalPcID
  else
  if Filter_RegisterPc = RegisterPcFilter_UnregisterPc then
    Result := not NodeData.IsRegister
  else
  if Filter_RegisterPc = RegisterPcFilter_OnlinePc then
    Result := NodeData.IsOnline
  else
    Result := True;
end;

class procedure RegisterPcFilterUtil.RefreshShowNode;
var
  vstRegister : TVirtualStringTree;
  SelectNode : PVirtualNode;
begin
  vstRegister := frmRegister.vstRegister;
  SelectNode := vstRegister.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    vstRegister.IsVisible[ SelectNode ] := RegisterPcFilterUtil.getIsNodeShow( SelectNode );
    if not vstRegister.IsVisible[ SelectNode ] then // 隐藏则取消check
      vstRegister.CheckState[ SelectNode ] := csUncheckedNormal;
    SelectNode := SelectNode.NextSibling;
  end;
end;

class procedure RegisterPcFilterUtil.SetFilterIndex(SelectIndex: Integer);
var
  pmFilter : TPopupMenu;
  i: Integer;
  mi : TMenuItem;
begin
  pmFilter := frmRegister.pmPcFilter;

  if ( SelectIndex < 0 ) or ( SelectIndex > pmFilter.Items.Count - 1 ) then
    SelectIndex := 0;

  for i := 0 to pmFilter.Items.Count - 1 do
  begin
    mi := pmFilter.Items[i];
    if i = SelectIndex then
    begin
      mi.ImageIndex := ImgIndex_PcFilterSelect;
      mi.Default := True;
      frmRegister.tbtnPcFilter.Caption := mi.Caption;
    end
    else
    begin
      mi.ImageIndex := -1;
      mi.Default := False;
    end;
  end;

  if SelectIndex = RegisterPcFilterIndex_MyPc then
    Filter_RegisterPc := RegisterPcFilter_MyPc
  else
  if SelectIndex = RegisterPcFilterIndex_UnregisterPc then
    Filter_RegisterPc := RegisterPcFilter_UnregisterPc
  else
  if SelectIndex = RegisterPcFilterIndex_OnlinePc then
    Filter_RegisterPc := RegisterPcFilter_OnlinePc
  else
  if SelectIndex = RegisterPcFilterIndex_AllPc then
    Filter_RegisterPc := RegisterPcFilter_AllPc;

  RegisterPcFilterUtil.RefreshShowNode;
end;

procedure TfrmRegister.SaveIni;
var
  IniFile : TIniFile;
begin
    // 没有权限写
  if not MyIniFile.ConfirmWriteIni then
    Exit;

  IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  try
    IniFile.WriteInteger( Self.Name, Self.tbtnPcFilter.Name, RegisterPcFilterUtil.getFilterIndex );
  except
  end;
  IniFile.Free;
end;

procedure TfrmRegister.LoadIni;
var
  IniFile : TIniFile;
  SelectIndex : Integer;
begin
  IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  SelectIndex := IniFile.ReadInteger( Self.Name, Self.tbtnPcFilter.Name, 0 );
  IniFile.Free;

  RegisterPcFilterUtil.SetFilterIndex( SelectIndex );
end;

end.
