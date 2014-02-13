unit UMyRegisterXmlInfo;

interface

uses UChangeInfo, xmldom, XMLIntf, msxmldom, XMLDoc, UXmlUtil;

type

{$Region ' 本机注册 数据修改 ' }

  TRegisterSetXml = class( TXmlChangeInfo )
  public
    LicenseStr : string;
  public
    constructor Create( _LicenseStr : string );
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 批注册 数据修改 ' }

    // 父类
  TActivatePcChangeXml = class( TXmlChangeInfo )
  protected
    MyRegisterNode : IXMLNode;
    ActivatePcNodeList : IXMLNode;
  protected
    procedure Update;override;
  end;

    // 修改
  TActivatePcWriteXml = class( TActivatePcChangeXml )
  public
    PcID : string;
  protected
    ActivatePcIndex : Integer;
    ActivatePcNode : IXMLNode;
  public
    constructor Create( _PcID : string );
  protected
    function FindActivatePcNode: Boolean;
  end;

    // 添加
  TActivatePcAddXml = class( TActivatePcWriteXml )
  public
    LicenseStr : string;
  public
    procedure SetLicenseStr( _LicenseStr : string );
  protected
    procedure Update;override;
  end;

    // 删除
  TActivatePcRemoveXml = class( TActivatePcWriteXml )
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 注册显示 数据修改 ' }

    // 父类
  TRegisterShowChangeXml = class( TXmlChangeInfo )
  protected
    MyRegisterNode : IXMLNode;
    RegisterShowNodeList : IXMLNode;
  protected
    procedure Update;override;
  end;

    // 修改
  TRegisterShowWriteXml = class( TRegisterShowChangeXml )
  public
    PcID : string;
  protected
    RegisterShowIndex : Integer;
    RegisterShowNode : IXMLNode;
  public
    constructor Create( _PcID : string );
  protected
    function FindRegisterShowNode: Boolean;
  end;

      // 添加
  TRegisterShowAddXml = class( TRegisterShowWriteXml )
  public
    HardCode : string;
  public
    RegisterEdition : string;
  public
    procedure SetHardCode( _HardCode : string );
    procedure SetRegisterEdition( _RegisterEdition : string );
  protected
    procedure Update;override;
  end;

    // 修改
  TRegisterShowSetRegisterEditionXml = class( TRegisterShowWriteXml )
  public
    RegisterEdition : string;
  public
    procedure SetRegisterEdition( _RegisterEdition : string );
  protected
    procedure Update;override;
  end;


    // 删除
  TRegisterShowRemoveXml = class( TRegisterShowWriteXml )
  protected
    procedure Update;override;
  end;


{$EndRegion}

{$Region ' 广告信息 ' }

  TAdsShowCountAddXml = class( TXmlChangeInfo )
  protected
    procedure Update;override;
  end;

  TTrialToFreeSetXml = class( TXmlChangeInfo )
  private
    IsShow : Boolean;
  public
    procedure SetIsShow( _IsShow : Boolean );
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 数据读取 ' }

    // 读取
  TRegisterShowReadXml = class
  public
    RegisterShowNode : IXMLNode;
  public
    constructor Create( _RegisterShowNode : IXMLNode );
    procedure Update;
  end;

      // 读取
  TActivatePcReadXml = class
  public
    ActivatePcNode : IXMLNode;
  public
    constructor Create( _ActivatePcNode : IXMLNode );
    procedure Update;
  end;



  TMyRegisterXmlRead = class
  private
    MyRegisterNode : IXMLNode;
  public
    procedure Update;
  private
    procedure ReadMyRegister;
    procedure ReadRegisterShow;
    procedure ReadActivtePcList;
    procedure ReadAdsShowCount;
    procedure ReadTrialToFree;
  end;

{$EndRegion}

const
  Xml_MyRegisterInfo = 'mri';
  Xml_MyLicenseStr = 'mls';
  Xml_ActivatePcList = 'apl';
  Xml_RegisterShowList = 'rsl';

  Xml_PcID = 'pid';
  Xml_LicenseStr = 'ls';

  Xml_HardCode = 'hc';
  Xml_RegisterEdition = 're';
  Xml_IsOnline = 'io';
  Xml_IsRegister = 'ir';

  Xml_AdsShowCount = 'adc';
  Xml_ShowTrialToFree = 'sttf';

  ShowTrialToFree_No = 'No';
  ShowTrialToFree_Yes = 'Yes';
var
  MyRegisterItem_AdsShowCount : Integer = 0;

implementation

uses UMyRegisterApiInfo;

{ TActivatePcChangeXml }

procedure TActivatePcChangeXml.Update;
begin
  MyRegisterNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyRegisterInfo );
  ActivatePcNodeList := MyXmlUtil.AddChild( MyRegisterNode, Xml_ActivatePcList );
end;

{ TActivatePcWriteXml }

constructor TActivatePcWriteXml.Create( _PcID : string );
begin
  PcID := _PcID;
end;


function TActivatePcWriteXml.FindActivatePcNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  for i := 0 to ActivatePcNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := ActivatePcNodeList.ChildNodes[i];
    if ( MyXmlUtil.GetChildValue( SelectNode, Xml_PcID ) = PcID ) then
    begin
      Result := True;
      ActivatePcIndex := i;
      ActivatePcNode := ActivatePcNodeList.ChildNodes[i];
      break;
    end;
  end;
end;

{ TActivatePcAddXml }

procedure TActivatePcAddXml.SetLicenseStr( _LicenseStr : string );
begin
  LicenseStr := _LicenseStr;
end;

procedure TActivatePcAddXml.Update;
begin
  inherited;

    // 不存在，则创建
  if not FindActivatePcNode then
  begin
    ActivatePcNode := MyXmlUtil.AddListChild( ActivatePcNodeList );
    MyXmlUtil.AddChild( ActivatePcNode, Xml_PcID, PcID );
  end;

  MyXmlUtil.AddChild( ActivatePcNode, Xml_LicenseStr, LicenseStr );
end;

{ TActivatePcRemoveXml }

procedure TActivatePcRemoveXml.Update;
begin
  inherited;

  if not FindActivatePcNode then
    Exit;

  MyXmlUtil.DeleteListChild( ActivatePcNodeList, ActivatePcIndex );
end;



{ TRegisterSetXml }

constructor TRegisterSetXml.Create(_LicenseStr: string);
begin
  LicenseStr := _LicenseStr;
end;

procedure TRegisterSetXml.Update;
var
  MyRegisterNode : IXMLNode;
begin
  inherited;

  MyRegisterNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyRegisterInfo );
  MyXmlUtil.AddChild( MyRegisterNode, Xml_MyLicenseStr, LicenseStr );
end;

{ TRegisterShowChangeXml }

procedure TRegisterShowChangeXml.Update;
begin
  MyRegisterNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyRegisterInfo );
  RegisterShowNodeList := MyXmlUtil.AddChild( MyRegisterNode, Xml_RegisterShowList );
end;

{ TRegisterShowWriteXml }

constructor TRegisterShowWriteXml.Create( _PcID : string );
begin
  PcID := _PcID;
end;


function TRegisterShowWriteXml.FindRegisterShowNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  for i := 0 to RegisterShowNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := RegisterShowNodeList.ChildNodes[i];
    if ( MyXmlUtil.GetChildValue( SelectNode, Xml_PcID ) = PcID ) then
    begin
      Result := True;
      RegisterShowIndex := i;
      RegisterShowNode := RegisterShowNodeList.ChildNodes[i];
      break;
    end;
  end;
end;

{ TRegisterShowAddXml }

procedure TRegisterShowAddXml.SetHardCode( _HardCode : string );
begin
  HardCode := _HardCode;
end;

procedure TRegisterShowAddXml.SetRegisterEdition( _RegisterEdition : string );
begin
  RegisterEdition := _RegisterEdition;
end;

procedure TRegisterShowAddXml.Update;
begin
  inherited;

    // 不存在，则创建
  if not FindRegisterShowNode then
  begin
    RegisterShowNode := MyXmlUtil.AddListChild( RegisterShowNodeList );
    MyXmlUtil.AddChild( RegisterShowNode, Xml_PcID, PcID );
  end;
  MyXmlUtil.AddChild( RegisterShowNode, Xml_HardCode, HardCode );
  MyXmlUtil.AddChild( RegisterShowNode, Xml_RegisterEdition, RegisterEdition );
end;

{ TRegisterShowRemoveXml }

procedure TRegisterShowRemoveXml.Update;
begin
  inherited;

  if not FindRegisterShowNode then
    Exit;

  MyXmlUtil.DeleteListChild( RegisterShowNodeList, RegisterShowIndex );
end;

{ TRegisterShowSetRegisterEditionXml }

procedure TRegisterShowSetRegisterEditionXml.SetRegisterEdition( _RegisterEdition : string );
begin
  RegisterEdition := _RegisterEdition;
end;

procedure TRegisterShowSetRegisterEditionXml.Update;
begin
  inherited;

  if not FindRegisterShowNode then
    Exit;
  MyXmlUtil.AddChild( RegisterShowNode, Xml_RegisterEdition, RegisterEdition );
end;



{ TMyRegisterXmlRead }

procedure TMyRegisterXmlRead.ReadActivtePcList;
var
  ActivatePcNodeList : IXMLNode;
  i : Integer;
  ActivatePcNode : IXMLNode;
  ActivatePcReadXml : TActivatePcReadXml;
begin
  ActivatePcNodeList := MyXmlUtil.AddChild( MyRegisterNode, Xml_ActivatePcList );
  for i := 0 to ActivatePcNodeList.ChildNodes.Count - 1 do
  begin
    ActivatePcNode := ActivatePcNodeList.ChildNodes[i];
    ActivatePcReadXml := TActivatePcReadXml.Create( ActivatePcNode );
    ActivatePcReadXml.Update;
    ActivatePcReadXml.Free;
  end;
end;



procedure TMyRegisterXmlRead.ReadAdsShowCount;
begin
  MyRegisterItem_AdsShowCount := MyXmlUtil.GetChildInt64Value( MyRegisterNode, Xml_AdsShowCount );
end;

procedure TMyRegisterXmlRead.ReadMyRegister;
var
  LicenseStr : string;
  RegisterReadHandle : TRegisterReadHandle;
begin
  LicenseStr := MyXmlUtil.GetChildValue( MyRegisterNode, Xml_MyLicenseStr );

  RegisterReadHandle := TRegisterReadHandle.Create( LicenseStr );
  RegisterReadHandle.Update;
  RegisterReadHandle.Free;
end;

procedure TMyRegisterXmlRead.ReadRegisterShow;
var
  RegisterShowNodeList : IXMLNode;
  i : Integer;
  RegisterShowNode : IXMLNode;
  RegisterShowReadXml : TRegisterShowReadXml;
begin
  RegisterShowNodeList := MyXmlUtil.AddChild( MyRegisterNode, Xml_RegisterShowList );
  for i := 0 to RegisterShowNodeList.ChildNodes.Count - 1 do
  begin
    RegisterShowNode := RegisterShowNodeList.ChildNodes[i];
    RegisterShowReadXml := TRegisterShowReadXml.Create( RegisterShowNode );
    RegisterShowReadXml.Update;
    RegisterShowReadXml.Free;
  end;
end;



procedure TMyRegisterXmlRead.ReadTrialToFree;
var
  TrialToFreeStr : string;
begin
  TrialToFreeStr := MyXmlUtil.GetChildValue( MyRegisterNode, Xml_ShowTrialToFree );
  TrialToFree_IsShow := TrialToFreeStr = ShowTrialToFree_Yes;
end;

procedure TMyRegisterXmlRead.Update;
begin
  MyRegisterNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyRegisterInfo );

  ReadTrialToFree;
  ReadMyRegister;
  ReadRegisterShow;
  ReadActivtePcList;
  ReadAdsShowCount;
end;

{ RegisterShowNode }

constructor TRegisterShowReadXml.Create( _RegisterShowNode : IXMLNode );
begin
  RegisterShowNode := _RegisterShowNode;
end;

procedure TRegisterShowReadXml.Update;
var
  PcID, HardCode, RegisterEdition : string;
  RegisterShowReadHandle : TRegisterShowReadHandle;
begin
  PcID := MyXmlUtil.GetChildValue( RegisterShowNode, Xml_PcID );
  HardCode := MyXmlUtil.GetChildValue( RegisterShowNode, Xml_HardCode );
  RegisterEdition := MyXmlUtil.GetChildValue( RegisterShowNode, Xml_RegisterEdition );

  RegisterShowReadHandle := TRegisterShowReadHandle.Create( PcID );
  RegisterShowReadHandle.SetHardCode( HardCode );
  RegisterShowReadHandle.SetRegisterEdition( RegisterEdition );
  RegisterShowReadHandle.Update;
  RegisterShowReadHandle.Free;
end;

{ ActivatePcNode }

constructor TActivatePcReadXml.Create( _ActivatePcNode : IXMLNode );
begin
  ActivatePcNode := _ActivatePcNode;
end;

procedure TActivatePcReadXml.Update;
var
  PcID, LicenseStr : string;
  ActivatePcReadHandle : TActivatePcReadHandle;
begin
  PcID := MyXmlUtil.GetChildValue( ActivatePcNode, Xml_PcID );
  LicenseStr := MyXmlUtil.GetChildValue( ActivatePcNode, Xml_LicenseStr );

  ActivatePcReadHandle := TActivatePcReadHandle.Create( PcID );
  ActivatePcReadHandle.SetLicenseStr( LicenseStr );
  ActivatePcReadHandle.Update;
  ActivatePcReadHandle.Free;
end;

procedure TAdsShowCountAddXml.Update;
var
  MyRegisterNode : IXMLNode;
  AdsShowCount : Integer;
begin
  MyRegisterNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyRegisterInfo );
  AdsShowCount := MyXmlUtil.GetChildInt64Value( MyRegisterNode, Xml_AdsShowCount );
  Inc( AdsShowCount );
  MyXmlUtil.AddChild( MyRegisterNode, Xml_AdsShowCount, AdsShowCount );
end;



{ TTrialToFreeSetXml }

procedure TTrialToFreeSetXml.SetIsShow(_IsShow: Boolean);
begin
  IsShow := _IsShow;
end;

procedure TTrialToFreeSetXml.Update;
var
  MyRegisterNode : IXMLNode;
  ShowTrialToFreeStr : string;
begin
  MyRegisterNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyRegisterInfo );

  if IsShow then
    ShowTrialToFreeStr := ShowTrialToFree_Yes
  else
    ShowTrialToFreeStr := ShowTrialToFree_No;

  MyXmlUtil.AddChild( MyRegisterNode, Xml_ShowTrialToFree, ShowTrialToFreeStr );
end;

end.
