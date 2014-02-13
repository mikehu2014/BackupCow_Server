unit UNetPcInfoXml;

interface

uses UChangeInfo, UXmlUtil, xmldom, XMLIntf, msxmldom, XMLDoc, SysUtils, UMyUtil;

type

{$Region ' 写 网络Group ' }

    // 父类
  TNetworkGroupChangeXml = class( TXmlChangeInfo )
  protected
    MyNetworkConnNode : IXMLNode;
    NetworkGroupNodeList : IXMLNode;
  protected
    procedure Update;override;
  end;

    // 修改
  TNetworkGroupWriteXml = class( TNetworkGroupChangeXml )
  public
    GroupName : string;
  protected
    NetworkGroupIndex : Integer;
    NetworkGroupNode : IXMLNode;
  public
    constructor Create( _GroupName : string );
  protected
    function FindNetworkGroupNode: Boolean;
  end;

    // 添加
  TNetworkGroupAddXml = class( TNetworkGroupWriteXml )
  public
    Password : string;
  public
    procedure SetPassword( _Password : string );
  protected
    procedure Update;override;
  end;

    // 修改
  TNetworkGroupSetPasswordXml = class( TNetworkGroupWriteXml )
  public
    Password : string;
  public
    procedure SetPassword( _Password : string );
  protected
    procedure Update;override;
  end;


    // 删除
  TNetworkGroupRemoveXml = class( TNetworkGroupWriteXml )
  protected
    procedure Update;override;
  end;


{$EndRegion}

{$Region ' 写 网络ConnToPc ' }

    // 父类
  TNetworkPcConnChangeXml = class( TXmlChangeInfo )
  protected
    MyNetworkConnNode : IXMLNode;
    NetworkPcConnNodeList : IXMLNode;
  protected
    procedure Update;override;
  end;

    // 修改
  TNetworkPcConnWriteXml = class( TNetworkPcConnChangeXml )
  public
    Domain, Port : string;
  protected
    NetworkPcConnIndex : Integer;
    NetworkPcConnNode : IXMLNode;
  public
    constructor Create( _Domain, _Port : string );
  protected
    function FindNetworkPcConnNode: Boolean;
  end;

    // 添加
  TNetworkPcConnAddXml = class( TNetworkPcConnWriteXml )
  public
  protected
    procedure Update;override;
  end;

    // 删除
  TNetworkPcConnRemoveXml = class( TNetworkPcConnWriteXml )
  protected
    procedure Update;override;
  end;


{$EndRegion}

{$Region ' 写 网络模式 ' }

  TNetworkModeChangeXml = class( TXmlChangeInfo )
  public
    SelectType : string;
    SelectValue1, SelectValue2 : string;
  public
    constructor Create( _SelectType : string );
    procedure SetValue( _SelectValue1, _SelectValue2 : string );
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 写 本机信息 Xml ' }

    // 父类
  TMyPcInfoWriteXml = class( TXmlChangeInfo )
  public
    MyPcNode : IXMLNode;
  protected
    procedure Update;override;
  end;

    // 修改 Pc 信息
  TMyPcInfoSetXml = class( TMyPcInfoWriteXml )
  public
    PcID, PcName : string;
    LanIp, LanPort, InternetPort : string;
  public
    constructor Create( _PcID, _PcName : string );
    procedure SetSocketInfo( _LanIp, _LanPort, _InternetPort : string );
  protected
    procedure Update;override;
  end;

    // 设置 局域网 Ip
  TMyPcInfoSetLanIpXml = class( TMyPcInfoWriteXml )
  public
    LanIp : string;
  public
    constructor Create( _LanIp : string );
  protected
    procedure Update;override;
  end;

    // 设置 局域网端口号
  TMyPcInfoSetLanPortXml = class( TMyPcInfoWriteXml )
  public
    LanPort : string;
  public
    constructor Create( _LanPort : string );
  protected
    procedure Update;override;
  end;

    // 设置 互联网端口号
  TMyPcInfoSetInternetPortXml = class( TMyPcInfoWriteXml )
  public
    InternetPort : string;
  public
    constructor Create( _InternetPort : string );
  protected
    procedure Update;override;
  end;


{$EndRegion}

{$Region ' 写 网络Pc Xml ' }

  TNetPcChangeXml = class( TXmlChangeInfo )
  public
    MyNetPcInfoXml : IXMLNode;
    NetPcHashXml : IXMLNode;
  public
    procedure Update;override;
  end;

    // 添加 Pc 然后修改
  TNetPcWriteXml = class( TNetPcChangeXml )
  public
    PcID : string;
  protected
    NetPcNode : IXMLNode;
  public
    constructor Create( _PcID : string );
  protected
    function FindNetPcNode : Boolean;
  end;

    // 增加 Pc
  TNetPcAddXml = class( TNetPcWriteXml )
  public
    PcName : string;
  public
    procedure SetPcName( _PcName : string );
  protected
    procedure Update;override;
  end;

    // 修改 Socket
  TNetPcSocketXml = class( TNetPcWriteXml )
  private
    Ip, Port : string;
    IsLanConn : Boolean;
  public
    procedure SetSocket( _Ip, _Port : string );
    procedure SetIsLanConn( _IsLanConn : Boolean );
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 写 帐号 Xml ' }

    // 父类
  TAccountChangeXml = class( TXmlChangeInfo )
  protected
    MyAccountNode : IXMLNode;
    AccountNodeList : IXMLNode;
  protected
    procedure Update;override;
  end;

    // 修改
  TAccountWriteXml = class( TAccountChangeXml )
  public
    AccountName : string;
  protected
    AccountIndex : Integer;
    AccountNode : IXMLNode;
  public
    constructor Create( _AccountName : string );
  protected
    function FindAccountNode: Boolean;
  end;

      // 添加
  TAccountAddXml = class( TAccountWriteXml )
  private
    Password : string;
  public
    procedure SetPassword( _Password : string );
  protected
    procedure Update;override;
  end;

    // 删除
  TAccountRemoveXml = class( TAccountWriteXml )
  protected
    procedure Update;override;
  end;


{$EndRegion}

{$Region ' 写帐号路径 Xml ' }

    // 父类
  TBackupListChangeXml = class( TAccountWriteXml )
  protected
    BackupList : IXMLNode;
  protected
    function FindBackupList : Boolean;
  end;

    // 修改
  TBackupListWriteXml = class( TBackupListChangeXml )
  public
    BackupPath : string;
  protected
    BackupNode : IXMLNode;
    BackupListIndex : Integer;
  public
    procedure SetBackupPath( _BackupPath : string );
  protected
    function FindBackupNode: Boolean;
  end;

    // 添加
  TBackupListAddXml = class( TBackupListWriteXml )
  protected
    procedure Update;override;
  end;

    // 删除
  TBackupListRemoveXml = class( TBackupListWriteXml )
  protected
    procedure Update;override;
  end;


{$EndRegion}


{$Region ' 读取 本机Xml ' }

  TMyPcXmlReadHandle = class
  public
    procedure Update;
  end;

{$EndRegion}

{$Region ' 读 网络 Xml ' }

    // 读取 Pc 节点信息
  TNetPcNodeReadHandle = class
  public
    PcNode : IXMLNode;
  private
    PcID, PcName : string;
    Ip, Port : string;
    IsLanConn : Boolean;
  public
    constructor Create( _PcNode : IXMLNode );
    procedure Update;
  private
    procedure FindPcInfo;
    procedure AddNetworkPc;
    procedure SetPcSocket;
  end;

  TNetPcXmlRead = class
  public
    procedure Update;
  end;

{$EndRegion}

{$Region ' 读取 网络模式 ' }

    // 读取 Group
  TNetworkGroupReadXml = class
  public
    NetworkGroupNode : IXMLNode;
  public
    constructor Create( _NetworkGroupNode : IXMLNode );
    procedure Update;
  end;

    // 读取 ConnToPc
  TNetworkPcConnReadXml = class
  public
    NetworkPcConnNode : IXMLNode;
  public
    constructor Create( _NetworkPcConnNode : IXMLNode );
    procedure Update;
  end;


    // 读取网络模式
  TNetworkModeXmlRead = class
  private
    MyNetworkConnNode : IXMLNode;
  public
    procedure Update;
  private
    procedure ReadGroupList;
    procedure ReadConnPcList;
    procedure ReadSelectNetwork;
  end;

{$EndRegion}

{$Region ' 读取 帐号信息 ' }

    // 读取
  TBackupListReadXml = class
  public
    BackupNode : IXMLNode;
    AccountName : string;
  public
    constructor Create( _BackupNode : IXMLNode );
    procedure SetAccountName( _AccountName : string );
    procedure Update;
  end;


    // 读取
  TAccountReadXml = class
  public
    AccountNode : IXMLNode;
    AccountName : string;
  public
    constructor Create( _AccountNode : IXMLNode );
    procedure Update;
  private
    procedure ReadAccountBackupList;
  end;

  TAccountXmlRead = class
  private
    MyAccountNode : IXMLNode;
    AccountNodeList : IXMLNode;
  public
    procedure Update;
  private
    procedure ReadAccountList;
  end;

{$EndRegion}


const
    // 网络计算机信息
  Xml_MyNetPcInfo  = 'mnpi';
  Xml_NetPcHash = 'nph';

    // Net Pc Info
  Xml_PcID = 'pi';
  Xml_PcName = 'pn';
  Xml_Ip = 'ip';
  Xml_Port = 'pt';
  Xml_IsLanConn = 'ilc';

const
  Xml_MyNetworkConnInfo = 'mnci';
  Xml_SelectType = 'st';
  Xml_SelectValue1 = 'sv1';
  Xml_SelectValue2 = 'sv2';
  Xml_NetworkGroupList = 'ngl';

  Xml_GroupName = 'gn';
  Xml_Password = 'pw';

  Xml_NetworkPcConnList = 'npcl';
  Xml_Domain = 'dm';

const
  Xml_MyPcInfo = 'mpi';
//  Xml_PcID = 'pi';
//  Xml_PcName = 'pn';
  Xml_LanIp = 'li';
  Xml_LanPort = 'lp';
  Xml_InternetPort = 'ip';

const
  Xml_MyAccountInfo = 'mai';
  Xml_AccountList = 'al';
  Xml_AccountName = 'an';
  Xml_BackupList = 'bl';
  Xml_BackupPath = 'bp';

implementation

uses UMyNetPcInfo, UNetworkFace, UNetworkControl;

{ TNetPcSocketXml }

procedure TNetPcSocketXml.SetIsLanConn(_IsLanConn: Boolean);
begin
  IsLanConn := _IsLanConn;
end;

procedure TNetPcSocketXml.SetSocket(_Ip, _Port: string);
begin
  Ip := _Ip;
  Port := _Port;
end;

procedure TNetPcSocketXml.Update;
begin
  inherited;

    // 不存在
  if not FindNetPcNode then
    Exit;

  MyXmlUtil.AddChild( NetPcNode, Xml_Ip, Ip );
  MyXmlUtil.AddChild( NetPcNode, Xml_Port, Port );
  MyXmlUtil.AddChild( NetPcNode, Xml_IsLanConn, IsLanConn );
end;

{ TNetPcAddXml }

procedure TNetPcAddXml.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TNetPcAddXml.Update;
begin
  inherited;

    // 不存在，则创建
  if not FindNetPcNode then
  begin
    NetPcNode := MyXmlUtil.AddListChild( NetPcHashXml, PcID );
    MyXmlUtil.AddChild( NetPcNode, Xml_PcID, PcID );
  end;

    // 改名
  MyXmlUtil.AddChild( NetPcNode, Xml_PcName, PcName );
end;

{ TNetPcWriteXml }

constructor TNetPcWriteXml.Create(_PcID: string);
begin
  PcID := _PcID;
end;

function TNetPcWriteXml.FindNetPcNode: Boolean;
begin
  NetPcNode := MyXmlUtil.FindListChild( NetPcHashXml, PcID );
  Result := NetPcNode <> nil;
end;

{ TNetPcXmlRead }

procedure TNetPcXmlRead.Update;
var
  MyNetPcInfoXml : IXMLNode;
  NetPcHashXml : IXMLNode;
  i : Integer;
  PcXmlNode : IXMLNode;
  NetPcNodeReadHandle : TNetPcNodeReadHandle;
begin
    // 网络计算机信息的 Xml 节点
  MyNetPcInfoXml := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyNetPcInfo );
  NetPcHashXml := MyXmlUtil.AddChild( MyNetPcInfoXml, Xml_NetPcHash );

  for i := 0 to NetPcHashXml.ChildNodes.Count - 1 do
  begin
    PcXmlNode := NetPcHashXml.ChildNodes[i];
    NetPcNodeReadHandle := TNetPcNodeReadHandle.Create( PcXmlNode );
    NetPcNodeReadHandle.Update;
    NetPcNodeReadHandle.Free;
  end;
end;

{ TNetPcNodeReadHandle }

procedure TNetPcNodeReadHandle.AddNetworkPc;
var
  NetPcReadHandle : TNetPcReadHandle;
begin
  NetPcReadHandle := TNetPcReadHandle.Create( PcID );
  NetPcReadHandle.SetPcName( PcName );
  NetPcReadHandle.Update;
  NetPcReadHandle.Free;
end;

constructor TNetPcNodeReadHandle.Create(_PcNode: IXMLNode);
begin
  PcNode := _PcNode;
end;

procedure TNetPcNodeReadHandle.FindPcInfo;
begin
    // Pc 信息
  PcID := MyXmlUtil.GetChildValue( PcNode, Xml_PcID );
  PcName := MyXmlUtil.GetChildValue( PcNode, Xml_PcName );
  Ip := MyXmlUtil.GetChildValue( PcNode, Xml_Ip );
  Port := MyXmlUtil.GetChildValue( PcNode, Xml_Port );
  IsLanConn := StrToBoolDef( MyXmlUtil.GetChildValue( PcNode, Xml_IsLanConn ), True );
end;

procedure TNetPcNodeReadHandle.SetPcSocket;
var
  NetPcSocketReadHandle : TNetPcSocketReadHandle;
begin
  NetPcSocketReadHandle := TNetPcSocketReadHandle.Create( PcID );
  NetPcSocketReadHandle.SetSocket( Ip, Port );
  NetPcSocketReadHandle.SetIsLanConn( IsLanConn );
  NetPcSocketReadHandle.Update;
  NetPcSocketReadHandle.Free;
end;

procedure TNetPcNodeReadHandle.Update;
begin
    // 提取 Pc 信息
  FindPcInfo;

    // 设置 Pc 信息
  AddNetworkPc;
  SetPcSocket;
end;

{ TNetworkGroupChangeXml }

procedure TNetworkGroupChangeXml.Update;
begin
  MyNetworkConnNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyNetworkConnInfo );
  NetworkGroupNodeList := MyXmlUtil.AddChild( MyNetworkConnNode, Xml_NetworkGroupList );
end;

{ TNetworkGroupWriteXml }

constructor TNetworkGroupWriteXml.Create( _GroupName : string );
begin
  GroupName := _GroupName;
end;


function TNetworkGroupWriteXml.FindNetworkGroupNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  for i := 0 to NetworkGroupNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := NetworkGroupNodeList.ChildNodes[i];
    if ( MyXmlUtil.GetChildValue( SelectNode, Xml_GroupName ) = GroupName ) then
    begin
      Result := True;
      NetworkGroupIndex := i;
      NetworkGroupNode := NetworkGroupNodeList.ChildNodes[i];
      break;
    end;
  end;
end;

{ TNetworkGroupAddXml }

procedure TNetworkGroupAddXml.SetPassword( _Password : string );
begin
  Password := _Password;
end;

procedure TNetworkGroupAddXml.Update;
begin
  inherited;

  if FindNetworkGroupNode then
    Exit;

    // 加密
  Password := MyEncrypt.EncodeStr( Password );

  NetworkGroupNode := MyXmlUtil.AddListChild( NetworkGroupNodeList );
  MyXmlUtil.AddChild( NetworkGroupNode, Xml_GroupName, GroupName );
  MyXmlUtil.AddChild( NetworkGroupNode, Xml_Password, Password );
end;

{ TNetworkGroupRemoveXml }

procedure TNetworkGroupRemoveXml.Update;
begin
  inherited;

  if not FindNetworkGroupNode then
    Exit;

  MyXmlUtil.DeleteListChild( NetworkGroupNodeList, NetworkGroupIndex );
end;

{ TNetworkGroupSetPasswordXml }

procedure TNetworkGroupSetPasswordXml.SetPassword( _Password : string );
begin
  Password := _Password;
end;

procedure TNetworkGroupSetPasswordXml.Update;
begin
  inherited;

  if not FindNetworkGroupNode then
    Exit;

    // 加密
  Password := MyEncrypt.EncodeStr( Password );
  MyXmlUtil.AddChild( NetworkGroupNode, Xml_Password, Password );
end;

{ TNetworkPcConnChangeXml }

procedure TNetworkPcConnChangeXml.Update;
begin
  MyNetworkConnNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyNetworkConnInfo );
  NetworkPcConnNodeList := MyXmlUtil.AddChild( MyNetworkConnNode, Xml_NetworkPcConnList );
end;

{ TNetworkPcConnWriteXml }

constructor TNetworkPcConnWriteXml.Create( _Domain, _Port : string );
begin
  Domain := _Domain;
  Port := _Port;
end;


function TNetworkPcConnWriteXml.FindNetworkPcConnNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  for i := 0 to NetworkPcConnNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := NetworkPcConnNodeList.ChildNodes[i];
    if ( MyXmlUtil.GetChildValue( SelectNode, Xml_Domain ) = Domain ) and ( MyXmlUtil.GetChildValue( SelectNode, Xml_Port ) = Port ) then
    begin
      Result := True;
      NetworkPcConnIndex := i;
      NetworkPcConnNode := NetworkPcConnNodeList.ChildNodes[i];
      break;
    end;
  end;
end;

{ TNetworkPcConnAddXml }

procedure TNetworkPcConnAddXml.Update;
begin
  inherited;

  if FindNetworkPcConnNode then
    Exit;

  NetworkPcConnNode := MyXmlUtil.AddListChild( NetworkPcConnNodeList );
  MyXmlUtil.AddChild( NetworkPcConnNode, Xml_Domain, Domain );
  MyXmlUtil.AddChild( NetworkPcConnNode, Xml_Port, Port );
end;

{ TNetworkPcConnRemoveXml }

procedure TNetworkPcConnRemoveXml.Update;
begin
  inherited;

  if not FindNetworkPcConnNode then
    Exit;

  MyXmlUtil.DeleteListChild( NetworkPcConnNodeList, NetworkPcConnIndex );
end;



{ TNetworkModeChangeXml }

constructor TNetworkModeChangeXml.Create(_SelectType: string);
begin
  SelectType := _SelectType;
end;

procedure TNetworkModeChangeXml.SetValue(_SelectValue1, _SelectValue2: string);
begin
  SelectValue1 := _SelectValue1;
  SelectValue2 := _SelectValue2;
end;

procedure TNetworkModeChangeXml.Update;
var
  MyNetworkConnNode : IXMLNode;
begin
  MyNetworkConnNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyNetworkConnInfo );
  MyXmlUtil.AddChild( MyNetworkConnNode, Xml_SelectType, SelectType );
  MyXmlUtil.AddChild( MyNetworkConnNode, Xml_SelectValue1, SelectValue1 );
  MyXmlUtil.AddChild( MyNetworkConnNode, Xml_SelectValue2, SelectValue2 );
end;

{ TNetPcChangeXml }

procedure TNetPcChangeXml.Update;
begin
    // 网络计算机信息的 Xml 节点
  MyNetPcInfoXml := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyNetPcInfo );
  NetPcHashXml := MyXmlUtil.AddChild( MyNetPcInfoXml, Xml_NetPcHash );
end;

{ TNetworkModeXmlRead }

procedure TNetworkModeXmlRead.ReadConnPcList;
var
  NetworkPcConnNodeList : IXMLNode;
  i : Integer;
  NetworkPcConnNode : IXMLNode;
  NetworkPcConnReadXml : TNetworkPcConnReadXml;
begin
  NetworkPcConnNodeList := MyXmlUtil.AddChild( MyNetworkConnNode, Xml_NetworkPcConnList );
  for i := 0 to NetworkPcConnNodeList.ChildNodes.Count - 1 do
  begin
    NetworkPcConnNode := NetworkPcConnNodeList.ChildNodes[i];
    NetworkPcConnReadXml := TNetworkPcConnReadXml.Create( NetworkPcConnNode );
    NetworkPcConnReadXml.Update;
    NetworkPcConnReadXml.Free;
  end;
end;



procedure TNetworkModeXmlRead.ReadGroupList;
var
  NetworkGroupNodeList : IXMLNode;
  i : Integer;
  NetworkGroupNode : IXMLNode;
  NetworkGroupReadXml : TNetworkGroupReadXml;
begin
  NetworkGroupNodeList := MyXmlUtil.AddChild( MyNetworkConnNode, Xml_NetworkGroupList );
  for i := 0 to NetworkGroupNodeList.ChildNodes.Count - 1 do
  begin
    NetworkGroupNode := NetworkGroupNodeList.ChildNodes[i];
    NetworkGroupReadXml := TNetworkGroupReadXml.Create( NetworkGroupNode );
    NetworkGroupReadXml.Update;
    NetworkGroupReadXml.Free;
  end;
end;

procedure TNetworkModeXmlRead.ReadSelectNetwork;
var
  SelectType : string;
  SelectValue1, SelectValue2 : string;
  NetworkModeReadHandle : TNetworkModeReadHandle;
begin
  SelectType := MyXmlUtil.GetChildValue( MyNetworkConnNode, Xml_SelectType );
  SelectValue1 := MyXmlUtil.GetChildValue( MyNetworkConnNode, Xml_SelectValue1 );
  SelectValue2 := MyXmlUtil.GetChildValue( MyNetworkConnNode, Xml_SelectValue2 );

    // 默认是 局域网
  if SelectType = '' then
    SelectType := SelectConnType_Local;

  NetworkModeReadHandle := TNetworkModeReadHandle.Create( SelectType );
  NetworkModeReadHandle.SetValue( SelectValue1, SelectValue2 );
  NetworkModeReadHandle.Update;
  NetworkModeReadHandle.Free;
end;

procedure TNetworkModeXmlRead.Update;
begin
  MyNetworkConnNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyNetworkConnInfo );

    // 读取 Group 信息
  ReadGroupList;

    // 读取 Connect Pc 信息
  ReadConnPcList;

    // 读取选择信息
  ReadSelectNetwork;
end;

{ NetworkGroupNode }

constructor TNetworkGroupReadXml.Create( _NetworkGroupNode : IXMLNode );
begin
  NetworkGroupNode := _NetworkGroupNode;
end;

procedure TNetworkGroupReadXml.Update;
var
  GroupName, Password : string;
  NetworkGroupReadHandle : TNetworkGroupReadHandle;
begin
  GroupName := MyXmlUtil.GetChildValue( NetworkGroupNode, Xml_GroupName );
  Password := MyXmlUtil.GetChildValue( NetworkGroupNode, Xml_Password );
  Password := MyEncrypt.DecodeStr( Password ); // 解密

  NetworkGroupReadHandle := TNetworkGroupReadHandle.Create( GroupName );
  NetworkGroupReadHandle.SetPassword( Password );
  NetworkGroupReadHandle.Update;
  NetworkGroupReadHandle.Free;
end;

{ NetworkPcConnNode }

constructor TNetworkPcConnReadXml.Create( _NetworkPcConnNode : IXMLNode );
begin
  NetworkPcConnNode := _NetworkPcConnNode;
end;

procedure TNetworkPcConnReadXml.Update;
var
  Domain, Port : string;
  NetworkPcConnReadHandle : TNetworkPcConnReadHandle;
begin
  Domain := MyXmlUtil.GetChildValue( NetworkPcConnNode, Xml_Domain );
  Port := MyXmlUtil.GetChildValue( NetworkPcConnNode, Xml_Port );

  NetworkPcConnReadHandle := TNetworkPcConnReadHandle.Create( Domain, Port );
  NetworkPcConnReadHandle.Update;
  NetworkPcConnReadHandle.Free;
end;

{ TMyPcInfoWriteXml }

procedure TMyPcInfoWriteXml.Update;
begin
  MyPcNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyPcInfo );
end;

{ TMyPcInfoSetXml }

constructor TMyPcInfoSetXml.Create(_PcID, _PcName: string);
begin
  PcID := _PcID;
  PcName := _PcName;
end;

procedure TMyPcInfoSetXml.SetSocketInfo(_LanIp, _LanPort,
  _InternetPort: string);
begin
  LanIp := _LanIp;
  LanPort := _LanPort;
  InternetPort := _InternetPort;
end;

procedure TMyPcInfoSetXml.Update;
begin
  inherited;
  MyXmlUtil.AddChild( MyPcNode, Xml_PcID, PcID );
  MyXmlUtil.AddChild( MyPcNode, Xml_PcName, PcName );
  MyXmlUtil.AddChild( MyPcNode, Xml_LanIp, LanIp );
  MyXmlUtil.AddChild( MyPcNode, Xml_LanPort, LanPort );
  MyXmlUtil.AddChild( MyPcNode, Xml_InternetPort, InternetPort );
end;

{ TMyPcInfoSetLanPortXml }

constructor TMyPcInfoSetLanPortXml.Create(_LanPort: string);
begin
  LanPort := _LanPort;
end;

procedure TMyPcInfoSetLanPortXml.Update;
begin
  inherited;
  MyXmlUtil.AddChild( MyPcNode, Xml_LanPort, LanPort );
end;

{ TMyPcInfoSetInternetPortXml }

constructor TMyPcInfoSetInternetPortXml.Create(_InternetPort: string);
begin
  InternetPort := _InternetPort;
end;

procedure TMyPcInfoSetInternetPortXml.Update;
begin
  inherited;
  MyXmlUtil.AddChild( MyPcNode, Xml_InternetPort, InternetPort );
end;

{ TMyPcInfoSetLanIpXml }

constructor TMyPcInfoSetLanIpXml.Create(_LanIp: string);
begin
  LanIp := _LanIp;
end;

procedure TMyPcInfoSetLanIpXml.Update;
begin
  inherited;
  MyXmlUtil.AddChild( MyPcNode, Xml_LanIp, LanIp );
end;

{ TMyPcXmlReadHandle }

procedure TMyPcXmlReadHandle.Update;
var
  MyPcNode : IXMLNode;
  PcID, PcName : string;
  LanIp, LanPort, InternetPort : string;
  MyPcInfoReadHandle : TMyPcInfoReadHandle;
  MyPcInfoFirstSetHandle : TMyPcInfoFirstSetHandle;
begin
  MyPcNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyPcInfo );
  PcID := MyXmlUtil.GetChildValue( MyPcNode, Xml_PcID );
  PcName := MyXmlUtil.GetChildValue( MyPcNode, Xml_PcName );
  LanIp := MyXmlUtil.GetChildValue( MyPcNode, Xml_LanIp );
  LanPort := MyXmlUtil.GetChildValue( MyPcNode, Xml_LanPort );
  InternetPort := MyXmlUtil.GetChildValue( MyPcNode, Xml_InternetPort );

  if PcID = '' then
  begin
    PcID := MyComputerID.get;
    PcName := MyComputerName.get;
    LanIp := MyIp.get;
    LanPort := '9494';
    InternetPort := MyUpnpUtil.getUpnpPort( LanIp );

    MyPcInfoFirstSetHandle := TMyPcInfoFirstSetHandle.Create( PcID, PcName );
    MyPcInfoFirstSetHandle.SetSocketInfo( LanIp, LanPort, InternetPort );
    MyPcInfoFirstSetHandle.Update;
    MyPcInfoFirstSetHandle.Free;
  end
  else
  begin
    MyPcInfoReadHandle := TMyPcInfoReadHandle.Create( PcID, PcName );
    MyPcInfoReadHandle.SetSocketInfo( LanIp, LanPort, InternetPort );
    MyPcInfoReadHandle.Update;
    MyPcInfoReadHandle.Free;
  end;
end;

{ TAccountChangeXml }

procedure TAccountChangeXml.Update;
begin
  MyAccountNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyAccountInfo );
  AccountNodeList := MyXmlUtil.AddChild( MyAccountNode, Xml_AccountList );
end;

{ TAccountWriteXml }

constructor TAccountWriteXml.Create( _AccountName : string );
begin
  AccountName := _AccountName;
end;


function TAccountWriteXml.FindAccountNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  for i := 0 to AccountNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := AccountNodeList.ChildNodes[i];
    if ( MyXmlUtil.GetChildValue( SelectNode, Xml_AccountName ) = AccountName ) then
    begin
      Result := True;
      AccountIndex := i;
      AccountNode := AccountNodeList.ChildNodes[i];
      break;
    end;
  end;
end;

{ TAccountAddXml }

procedure TAccountAddXml.SetPassword(_Password: string);
begin
  Password := _Password;
end;

procedure TAccountAddXml.Update;
begin
  inherited;

  if FindAccountNode then
    Exit;

  AccountNode := MyXmlUtil.AddListChild( AccountNodeList );
  MyXmlUtil.AddChild( AccountNode, Xml_AccountName, AccountName );
  MyXmlUtil.AddChild( AccountNode, Xml_Password, Password );
end;

{ TAccountRemoveXml }

procedure TAccountRemoveXml.Update;
begin
  inherited;

  if not FindAccountNode then
    Exit;

  MyXmlUtil.DeleteListChild( AccountNodeList, AccountIndex );
end;

{ TBackupListChangeXml }

function TBackupListChangeXml.FindBackupList : Boolean;
begin
  Result := FindAccountNode;
  if Result then
    BackupList := MyXmlUtil.AddChild( AccountNode, Xml_BackupList );
end;

{ TBackupListWriteXml }

procedure TBackupListWriteXml.SetBackupPath( _BackupPath : string );
begin
  BackupPath := _BackupPath;
end;


function TBackupListWriteXml.FindBackupNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  if not FindBackupList then
    Exit;
  for i := 0 to BackupList.ChildNodes.Count - 1 do
  begin
    SelectNode := BackupList.ChildNodes[i];
    if ( MyXmlUtil.GetChildValue( SelectNode, Xml_BackupPath ) = BackupPath ) then
    begin
      Result := True;
      BackupListIndex := i;
      BackupNode := SelectNode;
      break;
    end;
  end;
end;

{ TBackupListAddXml }

procedure TBackupListAddXml.Update;
begin
  inherited;

  if FindBackupNode then
    Exit;

  BackupNode := MyXmlUtil.AddListChild( BackupList );
  MyXmlUtil.AddChild( BackupNode, Xml_BackupPath, BackupPath );
end;

{ TBackupListRemoveXml }

procedure TBackupListRemoveXml.Update;
begin
  inherited;

  if not FindBackupNode then
    Exit;

  MyXmlUtil.DeleteListChild( BackupList, BackupListIndex );
end;

{ BackupList }

constructor TBackupListReadXml.Create( _BackupNode : IXMLNode );
begin
  BackupNode := _BackupNode;
end;

procedure TBackupListReadXml.SetAccountName(_AccountName: string);
begin
  AccountName := _AccountName;
end;

procedure TBackupListReadXml.Update;
var
  BackupPath : string;
  BackupListReadHandle : TBackupListReadHandle;
begin
  BackupPath := MyXmlUtil.GetChildValue( BackupNode, Xml_BackupPath );

  BackupListReadHandle := TBackupListReadHandle.Create( AccountName );
  BackupListReadHandle.SetBackupPath( BackupPath );
  BackupListReadHandle.Update;
  BackupListReadHandle.Free;
end;

{ AccountNode }

constructor TAccountReadXml.Create( _AccountNode : IXMLNode );
begin
  AccountNode := _AccountNode;
end;

procedure TAccountReadXml.ReadAccountBackupList;
var
  BackupList, BackupNode : IXMLNode;
  i : Integer;
  BackupListReadXml : TBackupListReadXml;
begin
  BackupList := MyXmlUtil.AddChild( AccountNode, Xml_BackupList );
  for i := 0 to BackupList.ChildNodes.Count - 1 do
  begin
    BackupNode := BackupList.ChildNodes[i];
    BackupListReadXml := TBackupListReadXml.Create( BackupNode );
    BackupListReadXml.SetAccountName( AccountName );
    BackupListReadXml.Update;
    BackupListReadXml.Free;
  end;
end;



procedure TAccountReadXml.Update;
var
  Password : string;
  AccountReadHandle : TAccountReadHandle;
begin
  AccountName := MyXmlUtil.GetChildValue( AccountNode, Xml_AccountName );
  Password := MyXmlUtil.GetChildValue( AccountNode, Xml_Password );

  AccountReadHandle := TAccountReadHandle.Create( AccountName );
  AccountReadHandle.SetPassword( Password );
  AccountReadHandle.Update;
  AccountReadHandle.Free;

  ReadAccountBackupList;
end;

{ TAccountXmlRead }

procedure TAccountXmlRead.ReadAccountList;
var
  AccountNodeList : IXMLNode;
  i : Integer;
  AccountNode : IXMLNode;
  AccountReadXml : TAccountReadXml;
begin
  AccountNodeList := MyXmlUtil.AddChild( MyAccountNode, Xml_AccountList );
  for i := 0 to AccountNodeList.ChildNodes.Count - 1 do
  begin
    AccountNode := AccountNodeList.ChildNodes[i];
    AccountReadXml := TAccountReadXml.Create( AccountNode );
    AccountReadXml.Update;
    AccountReadXml.Free;
  end;
end;



procedure TAccountXmlRead.Update;
begin
  MyAccountNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyAccountInfo );

  ReadAccountList;
end;

end.

