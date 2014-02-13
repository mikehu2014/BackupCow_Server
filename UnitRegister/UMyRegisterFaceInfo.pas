unit UMyRegisterFaceInfo;

interface

uses UChangeInfo, Comctrls, vcl.dialogs, forms, stdctrls, Controls, UMyUtil, UMyUrl, VirtualTrees;

type

{$Region ' 注册显示 数据修改 ' }

 TVstRegisterData = record
  public
    PcID, PcName : WideString;
    HardCode, Edition : WideString;
    IsRegister, IsOnline : Boolean;
    MainIcon, EditionIcon : Integer;
  end;
  PVstRegisterData = ^TVstRegisterData;

    // 父类
  TRegisterShowChangeFace = class( TFaceChangeInfo )
  public
    vstRegister : TVirtualStringTree;
  protected
    procedure Update;override;
  end;

    // 修改
  TRegisterShowWriteFace = class( TRegisterShowChangeFace )
  public
    PcID : string;
  protected
    RegisterNode : PVirtualNode;
    RegisterData : PVstRegisterData;
  public
    constructor Create( _PcID : string );
  protected
    function FindRegisterShowNode : Boolean;
    procedure RefreshNode;
    procedure RefreshVisibleNode;
  protected
    function getLastOnlineNode : PVirtualNode;
  end;

      // 添加
  TRegisterShowAddFace = class( TRegisterShowWriteFace )
  public
    HardCode : string;
    IsOnline : boolean;
    PcName : string;
  public
    RegisterEdition : string;
    IsRegister : boolean;
  public
    procedure SetHardCode( _HardCode : string );
    procedure SetPcName( _PcName : string );
    procedure SetIsOnline( _IsOnline : boolean );
    procedure SetEditionInfo( _RegisterEdition : string; _IsRegister : boolean );
  protected
    procedure Update;override;
  private
    procedure CreateRegisterNode;
  end;

    // 修改
  TRegisterShowSetIsOnlineFace = class( TRegisterShowWriteFace )
  public
    IsOnline : boolean;
  public
    procedure SetIsOnline( _IsOnline : boolean );
  protected
    procedure Update;override;
  private
    procedure RefreshNodePosition;
  end;

      // 修改
  TRegisterShowSetEditionInfoFace = class( TRegisterShowWriteFace )
  public
    RegisterEdition : string;
    IsRegister : boolean;
  public
    procedure SetEditionInfo( _RegisterEdition : string; _IsRegister : boolean );
  protected
    procedure Update;override;
  end;

    // 删除
  TRegisterShowRemoveFace = class( TRegisterShowWriteFace )
  protected
    procedure Update;override;
  end;


  RegisterShowFaceUtil = class
  public
    class function ReadMainIcon( IsOnline : Boolean ): Integer;
    class function ReadEditionIcon( IsRegister : Boolean ): Integer;
  end;

{$EndRegion}

{$Region ' 版本限制 数据修改 ' }

    // 版本限制窗口
  TFreeLimitFormShow = class( TFaceChangeInfo )
  public
    ErrorStr : string;
  public
    constructor Create( _ErrorStr : string );
  protected
    procedure Update;override;
  end;

    // 远程网络限制
  TRemoteLimitChangeFace = class( TFaceChangeInfo )
  public
    IsRemoteLimit : Boolean;
  public
    constructor Create( _IsRemoteLimit : Boolean );
  protected
    procedure Update;override;
  end;

    // 试用版转免费版
  TTrialToFreeFormShowFace = class( TFaceChangeInfo )
  protected
    procedure Update;override;
  end;

{$EndRegion}

const
  RegisterSub_PcID = 0;
  RegisterSub_Edition = 1;

  RegisterIcon_Offline = 0;
  RegisterIcon_Online = 1;
  RegisterIcon_FreeEdition = 2;
  RegisterIcon_ProEdition = 3;

var
  RegisterError_IsShowing : Boolean = False;

const
  FreeEditionError_RemoteError = 'Please upgrade to the Enterprise edition in order to use this feature.';
  FreeEditionError_BackupSpace = 'Total size limit of backup source files is 1 GB in Free Ediition.' + #13#10 +
                                 'Please upgrade the software to a Registered Edition.';

implementation

uses UFormRegister, UMainForm, UFormSetting, UFormTrialToFree;



{ RegisterShowFaceUtil }

class function RegisterShowFaceUtil.ReadEditionIcon(
  IsRegister: Boolean): Integer;
begin
  if IsRegister then
    Result := RegisterIcon_ProEdition
  else
    Result := RegisterIcon_FreeEdition;
end;

class function RegisterShowFaceUtil.ReadMainIcon(IsOnline: Boolean): Integer;
begin
  if IsOnline then
    Result := RegisterIcon_Online
  else
    Result := RegisterIcon_Offline;
end;

{ TFreeLimitFormShow }

constructor TFreeLimitFormShow.Create(_ErrorStr: string);
begin
  ErrorStr := _ErrorStr;
end;

procedure TFreeLimitFormShow.Update;
const
  mbFour = [mbYes, mbCancel]; // 可以控制显示哪些按钮，几个按钮
var
  FMessageDialog: TForm;
  IsBuyNow : Boolean;
  btnYes, btnCancel : TButton;
  CutWidth : Integer;
begin
  RegisterError_IsShowing := True;

  IsBuyNow := False;

  FMessageDialog := CreateMessageDialog( ErrorStr, mtWarning, mbFour ); // 可以控制message的种类
  FMessageDialog.Caption := 'Warnning'; // 对话框的title
  with FMessageDialog do
  begin
    try
      btnYes := TButton(FindComponent('Yes'));
      btnCancel := TButton(FindComponent('Cancel'));
      btnYes.Caption := 'Buy Now';
      btnCancel.Caption := 'Close';
      IsBuyNow := ShowModal = mrYes;
    except
    end;
    Free;
  end;

  if IsBuyNow then
    MyInternetExplorer.OpenWeb( MyProductUrl.BuyNow );

  RegisterError_IsShowing := False;
end;

{ TRemoteLimitChangeFace }

constructor TRemoteLimitChangeFace.Create(_IsRemoteLimit: Boolean);
begin
  IsRemoteLimit := _IsRemoteLimit;
end;

procedure TRemoteLimitChangeFace.Update;
begin
  inherited;

  if IsRemoteLimit then
  begin
    frmMainForm.tbtnBackupNetwork.DropdownMenu := nil;
    frmSetting.lbConnHint.Hint := FreeEditionError_RemoteError;
  end
  else
    frmMainForm.tbtnBackupNetwork.DropdownMenu := frmMainForm.PmNetwork;

  frmSetting.lbConnHint.Visible := IsRemoteLimit;
  frmSetting.cbbNetworkMode.Enabled := not IsRemoteLimit;
end;

{ TTrialToFreeFormShowFace }

procedure TTrialToFreeFormShowFace.Update;
begin
  frmTrialToFree.Show;
end;

{ TRegisterShowChangeFace }

procedure TRegisterShowChangeFace.Update;
begin
  vstRegister := frmRegister.vstRegister;
end;

{ TRegisterShowAddFace }

procedure TRegisterShowAddFace.SetHardCode( _HardCode : string );
begin
  HardCode := _HardCode;
end;

procedure TRegisterShowAddFace.SetIsOnline( _IsOnline : boolean );
begin
  IsOnline := _IsOnline;
end;

procedure TRegisterShowAddFace.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TRegisterShowAddFace.CreateRegisterNode;
var
  LastOnlineNode : PVirtualNode;
begin
  if IsOnline then
  begin
    LastOnlineNode := getLastOnlineNode;
    if Assigned( LastOnlineNode ) then
      RegisterNode := vstRegister.InsertNode( LastOnlineNode, amInsertAfter )
    else
      RegisterNode := vstRegister.InsertNode( vstRegister.RootNode, amAddChildFirst );
  end
  else
    RegisterNode := vstRegister.AddChild( vstRegister.RootNode );
end;

procedure TRegisterShowAddFace.SetEditionInfo( _RegisterEdition : string; _IsRegister : boolean );
begin
  RegisterEdition := _RegisterEdition;
  IsRegister := _IsRegister;
end;

procedure TRegisterShowAddFace.Update;
begin
  inherited;

    // 不存在则创建
  if not FindRegisterShowNode then
  begin
    CreateRegisterNode;
    vstRegister.CheckType[ RegisterNode ] := ctTriStateCheckBox;
    vstRegister.CheckState[ RegisterNode ] := csUncheckedNormal;
    RegisterData := vstRegister.GetNodeData( RegisterNode );
    RegisterData.PcID := PcID;
  end;

    // 刷新信息
  RegisterData.PcName := PcName;
  RegisterData.HardCode := HardCode;
  RegisterData.Edition := RegisterEdition;
  RegisterData.IsRegister := IsRegister;
  RegisterData.IsOnline := IsOnline;
  RegisterData.MainIcon := RegisterShowFaceUtil.ReadMainIcon( IsOnline );
  RegisterData.EditionIcon := RegisterShowFaceUtil.ReadEditionIcon( IsRegister );
  RefreshVisibleNode;
  RefreshNode;
end;

{ TRegisterShowRemoveFace }

procedure TRegisterShowRemoveFace.Update;
begin
  inherited;

  if not FindRegisterShowNode then
    Exit;

  vstRegister.DeleteNode( RegisterNode );
end;

{ TRegisterShowWriteFace }

constructor TRegisterShowWriteFace.Create(_PcID: string);
begin
  PcID := _PcID;
end;

function TRegisterShowWriteFace.FindRegisterShowNode: Boolean;
var
  SelectNode : PVirtualNode;
  ItemData : PVstRegisterData;
begin
  Result := False;
  SelectNode := vstRegister.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    ItemData := vstRegister.GetNodeData( SelectNode );
    if ItemData.PcID = PcID then
    begin
      RegisterNode := SelectNode;
      RegisterData := ItemData;
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

function TRegisterShowWriteFace.getLastOnlineNode: PVirtualNode;
var
  SelectNode : PVirtualNode;
  ItemData : PVstRegisterData;
begin
  Result := nil;
  SelectNode := vstRegister.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    ItemData := vstRegister.GetNodeData( SelectNode );
    if ItemData.IsOnline then
      Result := SelectNode
    else
      Break;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TRegisterShowWriteFace.RefreshNode;
begin
  vstRegister.RepaintNode( RegisterNode );
end;

procedure TRegisterShowWriteFace.RefreshVisibleNode;
begin
  vstRegister.IsVisible[ RegisterNode ] := RegisterPcFilterUtil.getIsNodeShow( RegisterNode );
end;

{ TRegisterShowSetIsOnlineFace }

procedure TRegisterShowSetIsOnlineFace.RefreshNodePosition;
var
  LastOnlineNode : PVirtualNode;
begin
  if RegisterData.IsOnline = IsOnline then
    Exit;

  if not IsOnline then
    vstRegister.MoveTo( RegisterNode, vstRegister.RootNode, amAddChildLast, False )
  else
  begin
    LastOnlineNode := getLastOnlineNode;
    if Assigned( LastOnlineNode ) then
      vstRegister.MoveTo( RegisterNode, LastOnlineNode, amInsertAfter, False )
    else
      vstRegister.MoveTo( RegisterNode, vstRegister.RootNode, amAddChildFirst, False );
  end;
end;

procedure TRegisterShowSetIsOnlineFace.SetIsOnline( _IsOnline : boolean );
begin
  IsOnline := _IsOnline;
end;

procedure TRegisterShowSetIsOnlineFace.Update;
var
  LastOnlineNode : PVirtualNode;
begin
  inherited;

  if not FindRegisterShowNode then
    Exit;

    // 刷新节点位置
  RefreshNodePosition;

  RegisterData.IsOnline := IsOnline;
  RegisterData.MainIcon := RegisterShowFaceUtil.ReadMainIcon( IsOnline );
  RefreshVisibleNode;
  RefreshNode;
end;

{ TRegisterShowSetEditionInfoFace }

procedure TRegisterShowSetEditionInfoFace.SetEditionInfo( _RegisterEdition : string; _IsRegister : boolean );
begin
  RegisterEdition := _RegisterEdition;
  IsRegister := _IsRegister;
end;

procedure TRegisterShowSetEditionInfoFace.Update;
begin
  inherited;

  if not FindRegisterShowNode then
    Exit;

  RegisterData.Edition := RegisterEdition;
  RegisterData.IsRegister := IsRegister;
  RegisterData.EditionIcon := RegisterShowFaceUtil.ReadEditionIcon( IsRegister );
  RefreshVisibleNode;
  RefreshNode;
end;


end.
