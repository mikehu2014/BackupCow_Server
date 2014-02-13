unit UFormRegisterNew;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, IdHTTP, ComCtrls, ImgList, ToolWin, IniFiles, kg_dnc, UFormUtil,
  RzTabs, Menus;

type

  TfrmRegisterNew = class(TForm)
    plActivate: TPanel;
    plTitle: TPanel;
    Label2: TLabel;
    plDiaBtn: TPanel;
    plContent: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    Image2: TImage;
    ilSelectComputer: TImageList;
    PcActivate: TRzPageControl;
    tsOnline: TRzTabSheet;
    plSelectPc: TPanel;
    lvComputer: TListView;
    tsOffline: TRzTabSheet;
    plOrderID: TPanel;
    lbBatOrderNumber: TLabel;
    edtBatOrderNum: TEdit;
    plOnlineTitle: TPanel;
    plBatLicense: TPanel;
    mmoBatLicense: TMemo;
    Panel7: TPanel;
    Panel4: TPanel;
    pmSelectComputer: TPopupMenu;
    SelectmyComputer1: TMenuItem;
    SelectAll1: TMenuItem;
    tbSelectComputer: TToolBar;
    tbtnSelectUnRegisterAll: TToolButton;
    btnUnSelectAll: TToolButton;
    ilPcMain: TImageList;
    SelectUnregistered1: TMenuItem;
    ilLvRegister: TImageList;
    LinkLabel1: TLinkLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnBuyNowClick(Sender: TObject);
    procedure tbtnSelectUnRegisterAllClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure lvComputerDeletion(Sender: TObject; Item: TListItem);
    procedure tbSelectAllClick(Sender: TObject);
    procedure btnUnSelectAllClick(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
    procedure SelectmyComputer1Click(Sender: TObject);
    procedure lvComputerCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure btnCancelClick(Sender: TObject);
    procedure Label2DblClick(Sender: TObject);
    procedure Label2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SelectUnregistered1Click(Sender: TObject);
    procedure LinkLabel1LinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
  private
    procedure SetLvRegisterChecked( IsChecked : Boolean );
    procedure SetLvRegisterUnReigsgered;
  private
    procedure BindToolBar;
    procedure BindSort;
  end;

{$Region ' 申请试用 ' }

      // 申请网络试用
  TWebTrialHandle = class
  private
    HardCode : string;
  private
    HttpStr : string;
    LincenseStr : string;
  public
    constructor Create( _HardCode : string );
    function get : Boolean;
  private
    function getLicenseStr : string;
  end;

    // 本地申请试用
  TLocalTrialHandle = class
  private
    procedure Update;
  end;

    // 申请试用
  TTrialHandle = class
  private
    HardCode : string;
  public
    constructor Create;
    procedure Update;
  private
    function WebTrial: Boolean; // 网络申请试用
    procedure LocalTrial; // 本地申请试用
  private
    procedure ShowTrialSuccess;  // 申请成功
    procedure ShowTrialExpired;  // 申请失败
  end;

{$EndRegion}

{$Region ' 批激活 ' }

    // Pc License 处理
  TPcLicneseHandle = class
  private
    PcID : string;
    LicenseStr : string;
  public
    constructor Create( _PcID, _LicenseStr : string );
    procedure Update;
  private
    procedure AddToLocalPc;
    procedure SendToPc;
    procedure AddToMyBatRegister;
  end;

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
  TOfflineBatActivate = class
  public
    BatLicenseStr : string;
  public
    constructor Create( _BatLicenseStr : string );
    function get : Boolean;
  private
    function CheckBatLicense: Boolean;
    procedure HandleBatLicense;
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

const
  Ini_License : string = 'License';
  Ini_License_Key : string = 'Key';
  Ini_License_OrderID : string = 'OrderID';

  Key_Split : string = '|';
  Key_SplitCount : Integer = 3;
  Key_HardCode : Integer = 0;
  Key_EditionInfo : Integer = 1;
  Key_LastDate : Integer = 2;

  HttpReqTrial_HardCode : string = 'HardCode';
  HttpReqTrial_PcName : string = 'PcName';
  HttpReqTrial_PcID : string = 'PcID';

  HttpReqActivate_HardCode : string = 'HardCode';
  HttpReqActivate_PcName : string = 'PcName';
  HttpReqActivate_OrderID : string = 'OrderID';


  WebKey_Split : string = '|';
  WebKey_SplitCount : Integer = 3;
  WebKey_CheckNum : Integer = 0;
  WebKey_Lincense : Integer = 1;
  WebKey_StartTime : Integer = 2;

  Activate_Split : string = '|';
  Activate_SplitCount : Integer = 2;
  Activate_Result : Integer = 0;
  Activate_Key : Integer = 1;

  BtnTrialTag_Trial = 1;
  BtnTrialTag_Cancel = 2;
  BtnTrailTag_Expired = 3;

  TestDay_LocalRegister : Integer = 15;   // 本地试用版使用日期

  FrmShowResult_Success : Integer = 1;
  FrmShowResult_Failure : Integer = 2;

  CheckResult_OK : string = 'OK';
  CheckResult_Error : string = 'Error';

  EditionInfo_Try : string = '0';
  EditionInfo_Standard : string = '1';

  FormHeigh_First : Integer = 258;
  FormHeigh_Activate : Integer = 400;

  NbPage_First = 0;
  NbPage_Activate = 1;

  RegisterLabel_Edition : string = 'Backup Cow is registered as %s edition now.';
  RegisterLabel_RemainDay : string = 'It will expire on %s.';
  RegisterLabel_Expired : string = 'Your Backup Cow %s edition has expired already';

  MessageShow_Expired : string = 'The %s edition is expired.';

    // 试用按钮
  btnTrialShow_Trial : string = 'Evaluate';   // 申请试用
  btnTrialShow_Cancel : string = 'Cancel';   // 继续试用
  btnTrialShow_Later : string = 'Evaluate';   // 继续试用

  ShowHint_InputOrder : string = 'Please input order number.';
  ShowHint_SelectPc : string = 'Please select computer to register.';
  ShowForm_LicenseError : string = 'License is incorrect.';
  ShowForm_RegisterComplete : string = 'Congratulations, you have successfully ' +
                                       'completed Backup Cow software registration.';
  ShowForm_InputLicense : string = 'Please input License.';
  ShowForm_ExpiredRun : string = 'Your software evaluation has expired. Please register ' +
                                 'Backup Cow within 5 minutes, otherwise the program will be closed.';

  HttpReq_HardCode : string = 'HardCode';
  HttpReq_OrderID : string = 'OrderID';
  Split_Pc : string = '|';
  Split_PcInfo : string = '}';

  Split_Result : string = ']';
  Split_Computer : string = '{';
  Split_ComputerInfo : string = '[';

  HttpResult_OK : string = 'OK';
  HttpResult_Error : string = 'Error';

  Page_OrderID = 0;
  Page_License = 1;

var
  frmRegisterNew: TfrmRegisterNew;
  IsReSet_Register : Boolean = False;

implementation

uses UMyUtil, DateUtils, UMyUrl, URegisterInfoIO, UMainForm, UNetworkFace, UMyNetPcInfo,
     UMyClient;

{$R *.dfm}

procedure TfrmRegisterNew.BindSort;
begin
  lvComputer.OnColumnClick := ListviewUtil.ColumnClick;
end;

procedure TfrmRegisterNew.BindToolBar;
begin
//  lvComputer.PopupMenu := FormUtil.getPopMenu( tbSelectComputer );
end;

procedure TfrmRegisterNew.btnBuyNowClick(Sender: TObject);
begin
  MyInternetExplorer.OpenWeb( MyUrl.BuyNow );
end;

procedure TfrmRegisterNew.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmRegisterNew.btnOKClick(Sender: TObject);
var
  BatActivateHandle : TBatActivateHandle;
begin
  BatActivateHandle := TBatActivateHandle.Create;
  BatActivateHandle.Update;
  BatActivateHandle.Free;
end;

procedure TfrmRegisterNew.btnUnSelectAllClick(Sender: TObject);
begin
  SetLvRegisterChecked( False );
end;

procedure TfrmRegisterNew.FormCreate(Sender: TObject);
begin
  BindSort;
  BindToolBar;
end;

procedure TfrmRegisterNew.FormShow(Sender: TObject);
begin
  PcActivate.ActivePage := tsOnline;
end;

procedure TfrmRegisterNew.Label2DblClick(Sender: TObject);
begin
  IsReSet_Register := True;
end;

procedure TfrmRegisterNew.Label2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if ( Button <> mbRight ) or not IsReSet_Register then
    Exit;

  if InputBox( 'Infomation', 'Backup Cow', '' ) = 'clear' then
  begin
    RegisterInfo.SaveLicense( '' );
    RegisterInfo.LoadLicense;
    frmMainForm.RefreshRegisterEdition;
  end;

  IsReSet_Register := False;
end;

procedure TfrmRegisterNew.LinkLabel1LinkClick(Sender: TObject;
  const Link: string; LinkType: TSysLinkType);
begin
  MyInternetExplorer.OpenWeb( MyUrl.BuyNow );
end;

procedure TfrmRegisterNew.lvComputerCompare(Sender: TObject; Item1,
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
    Compare := EditionUtil.getEditionInt( SortStr1 ) - EditionUtil.getEditionInt( SortStr2 )
  else
    Compare := CompareText( SortStr1, SortStr2 );
end;

procedure TfrmRegisterNew.lvComputerDeletion(Sender: TObject; Item: TListItem);
var
  ItemData : TObject;
begin
  ItemData := Item.Data;
  ItemData.Free;
end;

procedure TfrmRegisterNew.SelectAll1Click(Sender: TObject);
begin
  SetLvRegisterChecked( True );
end;

procedure TfrmRegisterNew.SelectmyComputer1Click(Sender: TObject);
var
  i : Integer;
  ItemData : TRegisterPcItemData;
begin
  for i := 0 to lvComputer.Items.Count - 1 do
  begin
    ItemData := lvComputer.Items[i].Data;
    if ItemData.PcID = Network_LocalPcID then
      lvComputer.Items[i].Checked := True
    else
      lvComputer.Items[i].Checked := False;
  end;
end;

procedure TfrmRegisterNew.SelectUnregistered1Click(Sender: TObject);
begin
  SetLvRegisterUnReigsgered;
end;

procedure TfrmRegisterNew.SetLvRegisterChecked(IsChecked: Boolean);
var
  i : Integer;
begin
  for i := 0 to lvComputer.Items.Count - 1 do
    lvComputer.Items[i].Checked := IsChecked;
end;

procedure TfrmRegisterNew.SetLvRegisterUnReigsgered;
var
  i : Integer;
  ItemData : TRegisterPcItemData;
begin
  for i := 0 to lvComputer.Items.Count - 1 do
  begin
    ItemData := lvComputer.Items[i].Data;
    if ( ItemData.RegisterEdition = RegisterEditon_Professional ) or
       ( ItemData.RegisterEdition = RegisterEditon_Enterprise )
    then
      lvComputer.Items[i].Checked := False
    else
      lvComputer.Items[i].Checked := True;
  end;
end;

procedure TfrmRegisterNew.tbSelectAllClick(Sender: TObject);
begin
  SetLvRegisterChecked( True );
end;

procedure TfrmRegisterNew.tbtnSelectUnRegisterAllClick(Sender: TObject);
begin
  tbtnSelectUnRegisterAll.Down := True;
  tbtnSelectUnRegisterAll.CheckMenuDropdown;
end;

{ TBtnApplyClick }

constructor TTrialHandle.Create;
begin

end;

procedure TTrialHandle.LocalTrial;
var
  LocalApply : TLocalTrialHandle;
begin
    // 本地注册
  LocalApply := TLocalTrialHandle.Create;
  LocalApply.Update;
  LocalApply.Free;
end;


procedure TTrialHandle.ShowTrialExpired;
var
  ShowStr : string;
begin
  ShowStr := Format( MessageShow_Expired, [ RegisterInfo.RegisterEditon ] );
  MyMessageBox.ShowError( frmRegisterNew.Handle, ShowStr );
end;

procedure TTrialHandle.ShowTrialSuccess;
var
  ShowStr, LastDateStr : string;
  LastDate : TDate;
begin
  LastDate := RegisterInfo.LastDate;
  LastDateStr := DateToStr( LastDate );

  ShowStr := Format( RegisterLabel_RemainDay, [ LastDateStr ] );
  MyMessageBox.ShowOk( frmRegisterNew.Handle, ShowStr );
end;

procedure TTrialHandle.Update;
begin
    // 网络注册失败 则进行 本地注册
  if not WebTrial then
    LocalTrial;

      // 刷新版本信息
  RegisterInfo.LoadLicense;
  frmMainForm.RefreshRegisterEdition;

    // 显示 试用结果
  if RegisterInfo.LastDate >= Now then
  begin
    ShowTrialSuccess;
    frmRegisterNew.Close;
  end
  else
    ShowTrialExpired;
end;

function TTrialHandle.WebTrial: Boolean;
var
  WebApply : TWebTrialHandle;
begin
  WebApply := TWebTrialHandle.Create( HardCode );
  Result := WebApply.get;
  WebApply.Free;
end;

{ TWebApply }

constructor TWebTrialHandle.Create( _HardCode : string );
begin
  HardCode := _HardCode;
end;

function TWebTrialHandle.getLicenseStr: string;
var
  Url : string;
  IdHttp : TIdHTTP;
  ParamList : TStringList;
begin
  Result := '';


  Application.ProcessMessages;

  Url := MyUrl.getTrialKey;

  ParamList := TStringList.Create;
  ParamList.Add( HttpReqTrial_HardCode + '=' + HardCode );
  ParamList.Add( HttpReqTrial_PcName + '=' + MyComputerName.get );
  IdHttp := TIdHTTP.Create(nil);
  try
    Result := IdHttp.Post( Url, ParamList );
  except
    Result := '';
  end;
  IdHttp.Free;
  ParamList.Free;
end;

function TWebTrialHandle.get: Boolean;
begin
  Result := False;

    // 获取 试用 License
  LincenseStr := getLicenseStr;
  if LincenseStr = '' then
    Exit;

    // 写 Ini 文件
  RegisterInfo.SaveLicense( LincenseStr );

  Result := True;
end;

{ TLocalApply }

procedure TLocalTrialHandle.Update;
var
  LocalTrail : TDate;
  WriteLocalTrial : TWriteLocalTrial;
begin
  LocalTrail := Now;

    // 设置 本地试用期 截止日期
  LocalTrail := IncDay( Now, TestDay_LocalRegister );

    // 写本地系统
  WriteLocalTrial := TWriteLocalTrial.Create( LocalTrail );
  WriteLocalTrial.Update;
  WriteLocalTrial.Free;
end;


{ TOnlineBatActivate }

procedure TOnlineBatActivate.CancelSelectPc;
var
  lvComputer : TListView;
  i : Integer;
begin
  lvComputer := frmRegisterNew.lvComputer;
  for i := 0 to lvComputer.Items.Count - 1 do
    lvComputer.Items[i].Checked := False;
end;

constructor TOnlineBatActivate.Create(_OrderID: string);
begin
  OrderID := _OrderID;
end;

function TOnlineBatActivate.FindHardCodeListStr: Boolean;
var
  i : Integer;
  lvRegisterPc : TListView;
  ItemData : TRegisterPcItemData;
  PcStr : string;
begin
  HardCodeListStr := '';

  lvRegisterPc := frmRegisterNew.lvComputer;
  for i := 0 to lvRegisterPc.Items.Count - 1 do
    if lvRegisterPc.Items[i].Checked then
    begin
      ItemData := lvRegisterPc.Items[i].Data;
      if ItemData.RegisterHardCode = '' then
        Continue;
      PcStr := ItemData.RegisterHardCode + Split_PcInfo + ItemData.PcName;
      PcStr := PcStr + Split_PcInfo + ItemData.PcID;
      if HardCodeListStr = '' then
        HardCodeListStr := PcStr
      else
        HardCodeListStr := HardCodeListStr + Split_Pc + PcStr;
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

  frmRegisterNew.btnOK.Enabled := False;
  Application.ProcessMessages;

  params := TStringList.Create;
  params.Add( 'OrderID=' + orderID );
  params.Add( 'Hardcode=' + HardCodeListStr );

  idhttp := TIdHTTP.Create(nil);
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
        MyMessageBox.ShowError( frmRegisterNew.Handle, LicenseResult );
    end;
    ResultList.Free;
  except
  end;
  idhttp.Free;
  params.Free;
  frmRegisterNew.btnOK.Enabled := True;
end;

function TOnlineBatActivate.get: Boolean;
begin
  Result := False;

    // Order Number
  if OrderID = '' then
  begin
    MyMessageHint.ShowError( frmRegisterNew.edtBatOrderNum.Handle, ShowHint_InputOrder );
    Exit;
  end;

    // Select Computer
  if not FindHardCodeListStr then
  begin
    MyMessageHint.ShowError( frmRegisterNew.lvComputer.Handle, ShowHint_SelectPc );
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

function TOfflineBatActivate.CheckBatLicense: Boolean;
var
  Computer, HardCode, LicenseStr, DecLicense : string;
  ComputerList, ComputerInfoList : TStringList;
  i : Integer;
  SplitList : TStringList;
begin
  Result := True;

  Application.ProcessMessages;
  ComputerList := MySplitStr.getList( BatLicenseStr, Split_Computer );
  for i := 0 to ComputerList.Count - 1 do
  begin
    Computer := ComputerList[i];
    ComputerInfoList := MySplitStr.getList( Computer, Split_ComputerInfo );
    if ComputerInfoList.Count = 2 then
    begin
      HardCode := ComputerInfoList[0];
      LicenseStr := ComputerInfoList[1];

        // 检查 Pc 的 License
      DecLicense := KeyDec( LicenseStr );
      SplitList := MySplitStr.getList( DecLicense, Lincense_Split );
      if ( SplitList.Count <> Lincense_SplitCount ) or
         ( SplitList[ Lincense_HardCode ] <> HardCode )
      then
        Result := False;
      SplitList.Free;
    end
    else
      Result := False;
    ComputerInfoList.Free;

    if not Result then
      Break;
  end;
  ComputerList.Free;
end;

constructor TOfflineBatActivate.Create(_BatLicenseStr: string);
begin
  BatLicenseStr := _BatLicenseStr;
end;

procedure TOfflineBatActivate.HandleBatLicense;
var
  BatLicenseHandle : TBatLicenseHandle;
begin
  BatLicenseHandle := TBatLicenseHandle.Create( BatLicenseStr );
  BatLicenseHandle.Update;
  BatLicenseHandle.Free;
end;

function TOfflineBatActivate.get : Boolean;
begin
  if CheckBatLicense then
  begin
    HandleBatLicense;
    Result := True;
  end
  else
  begin
    MyMessageBox.ShowWarnning( frmRegisterNew.Handle, ShowForm_LicenseError );
    Result := False;
  end;
end;

{ TBatActivateClick }

function TBatActivateHandle.OfflineActivate: Boolean;
var
  BatLicneseStr : string;
  OfflineBatActivate : TOfflineBatActivate;
begin
  Result := False;

  BatLicneseStr := frmRegisterNew.mmoBatLicense.Text;

  if BatLicneseStr = '' then
  begin
    MyMessageBox.ShowWarnning( frmRegisterNew.Handle, ShowForm_InputLicense );
    Exit;
  end;

  OfflineBatActivate := TOfflineBatActivate.Create( BatLicneseStr );
  Result := OfflineBatActivate.get;
  OfflineBatActivate.Free;
end;

function TBatActivateHandle.OnlineActivate: Boolean;
var
  OrderID : string;
  OnlineBatActivate : TOnlineBatActivate;
begin
  OrderID := frmRegisterNew.edtBatOrderNum.Text;

  OnlineBatActivate := TOnlineBatActivate.Create( OrderID );
  Result := OnlineBatActivate.get;
  OnlineBatActivate.Free
end;

procedure TBatActivateHandle.Update;
var
  IsActiveSuccess : Boolean;
begin
    // 批激活 方式
  if frmRegisterNew.PcActivate.ActivePage = frmRegisterNew.tsOnline then
    IsActiveSuccess := OnlineActivate
  else
    IsActiveSuccess := OfflineActivate;

    // 激活 失败 跳过
  if not IsActiveSuccess then
    Exit;

    // 显示 激活成功
  MyMessageBox.ShowOk( frmRegisterNew.Handle, ShowForm_RegisterComplete );
  frmRegisterNew.Close;
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
  PcLicneseHandle : TPcLicneseHandle;
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

        // 单独 处理
      PcLicneseHandle := TPcLicneseHandle.Create( PcID, LicenseStr );
      PcLicneseHandle.Update;
      PcLicneseHandle.Free;
    end;
    ComputerInfoList.Free;
  end;
  ComputerList.Free;
end;

{ TPcLicneseHandle }

procedure TPcLicneseHandle.AddToLocalPc;
begin
  MyRegisterControl.AddLicense( LicenseStr );
end;

procedure TPcLicneseHandle.AddToMyBatRegister;
var
  PcBatRegisterAddInfo : TPcBatRegisterAddInfo;
  PcBatRegisterAddXml : TPcBatRegisterAddXml;
begin
    // 写内存
  PcBatRegisterAddInfo := TPcBatRegisterAddInfo.Create( PcID );
  PcBatRegisterAddInfo.SetLicenseStr( LicenseStr );
  MyBatRegisterInfo.AddChange( PcBatRegisterAddInfo );

    // 写Xml
  PcBatRegisterAddXml := TPcBatRegisterAddXml.Create( PcID );
  PcBatRegisterAddXml.SetLicenseStr( LicenseStr );
  MyBatRegisteWriterXml.AddChange( PcBatRegisterAddXml );
end;

constructor TPcLicneseHandle.Create(_PcID, _LicenseStr: string);
begin
  PcID := _PcID;
  LicenseStr := _LicenseStr;
end;

procedure TPcLicneseHandle.SendToPc;
var
  PcBatRegisterMsg : TPcBatRegisterMsg;
begin
  PcBatRegisterMsg := TPcBatRegisterMsg.Create;
  PcBatRegisterMsg.SetPcID( PcInfo.PcID );
  PcBatRegisterMsg.SetLicenseStr( LicenseStr );
  MyClient.SendMsgToPc( PcID, PcBatRegisterMsg );
end;

procedure TPcLicneseHandle.Update;
begin
  if PcID = Network_LocalPcID then
    AddToLocalPc
  else
  if MyNetPcInfoReadUtil.ReadIsOnline( PcID ) then
    SendToPc
  else
    AddToMyBatRegister;
end;

end.
