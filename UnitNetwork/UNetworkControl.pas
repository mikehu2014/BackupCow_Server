unit UNetworkControl;

interface

uses Sockets, USearchServer, UMyNetPcInfo, UMyMaster, Menus, classes;

type

{$Region ' 本机信息 数据修改 ' }

    // 读取
  TMyPcInfoReadHandle = class
  public
    PcID, PcName : string;
    LanIp, LanPort, InternetPort : string;
  public
    constructor Create( _PcID, _PcName : string );
    procedure SetSocketInfo( _LanIp, _LanPort, _InternetPort : string );
    procedure Update;virtual;
  protected
    procedure SetToInfo;
    procedure SetToFace;virtual;
  end;

    // 第一次设置
  TMyPcInfoFirstSetHandle = class( TMyPcInfoReadHandle )
  public
    procedure Update;override;
  protected
    procedure SetToXml;
  end;

    // 设置
  TMyPcInfoSetHandle = class( TMyPcInfoFirstSetHandle )
  protected
    procedure SetToFace;override;
  end;

    // 设置 临时 局域网 Ip
  TMyPcInfoSetTempLanIpHandle = class
  public
    LanIp : string;
  public
    constructor Create( _LanIp : string );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToFace;
  end;

      // 设置 局域网 Ip
  TMyPcInfoSetLanIpHandle = class
  public
    LanIp : string;
  public
    constructor Create( _LanIp : string );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToFace;
    procedure SetToXml;
  end;

      // 设置 局域网端口号
  TMyPcInfoSetLanPortHandle = class
  public
    LanPort : string;
  public
    constructor Create( _LanPort : string );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToFace;
    procedure SetToXml;
  end;

    // 设置 互联网端口号
  TMyPcInfoSetInternetIpHandle = class
  public
    InternetIp : string;
  public
    constructor Create( _InternetIp : string );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToFace;
  end;

    // 设置 互联网端口号
  TMyPcInfoSetInternetPortHandle = class
  public
    InternetPort : string;
  public
    constructor Create( _InternetPort : string );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToFace;
    procedure SetToXml;
  end;

  TMyPcInfoSetParams = record
  public
    PcID, PcName : string;
    LanIp, LanPort, InternetPort : string;
  end;

    // 设置本机信息 Api
  MyPcInfoApi = class
  public
    class procedure SetItem( Params : TMyPcInfoSetParams );
    class procedure SetTempLanIp( TempLanIp : string );
    class procedure SetLanIp( LanIp : string );
    class procedure SetLanPort( LanPort : string );
    class procedure SetInternetIp( InternetIp : string );
    class procedure SetInternetPort( InternetPort : string );
  end;

{$EndRegion}

{$Region ' 数据修改 Pc信息 ' }

    // 父类
  TNetPcChangeHandle = class
  public
    PcID : string;
  public
    constructor Create( _PcID : string );
  end;

  {$Region ' 增删信息 ' }

    // 读取
  TNetPcReadHandle = class( TNetPcChangeHandle )
  public
    PcName : string;
  public
    procedure SetPcName( _PcName : string );
    procedure Update;virtual;
  protected
    procedure AddToInfo;
  end;

    // 添加 云Pc 信息
  TNetPcAddHandle = class( TNetPcReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
    procedure AddToEvent;
    procedure AddToNetworkStatus;
    procedure AddToNetworkError;
  end;

  {$EndRegion}

  {$Region ' 位置信息 ' }

   // 读取 网络连接信息
  TNetPcSocketReadHandle = class( TNetPcChangeHandle )
  public
    Ip, Port : string;
    IsLanConn : Boolean;
  public
    procedure SetSocket( _Ip, _Port : string );
    procedure SetIsLanConn( _IsLanConn : Boolean );
    procedure Update;virtual;
  private
    procedure SetToInfo;
  end;

    // 设置 网络连接信息
  TNetPcSetSocketHandle = class( TNetPcSocketReadHandle )
  public
    procedure Update;override;
  private
    procedure SetToXml;
    procedure SetToNetworkStatus;
  end;

      // 设置 是否能连接 Pc
  TNetPcSetCanConnectToHandle = class( TNetPcChangeHandle )
  private
    CanConnectTo : Boolean;
  public
    procedure SetCanConnectTo( _CanConnectTo : Boolean );
    procedure Update;
  private
    procedure SetToInfo;
  end;

    // 设置 是否能被 Pc 连接
  TNetPcSetCanConnectFromHandle = class( TNetPcChangeHandle )
  private
    CanConnectFrom : Boolean;
  public
    procedure SetCanConnectFrom( _CanConnectFrom : Boolean );
    procedure Update;
  private
    procedure SetToInfo;
  end;

  {$EndRegion}

  {$Region ' 状态信息 ' }

    // 重设所有Pc信息
  TNetworkPcResetHandle = class
  public
    procedure Update;
  end;

    // 设置 Pc 上线
  TNetPcOnlineHandle = class( TNetPcChangeHandle )
  private
    Account : string;
  public
    procedure SetAccount( _Account : string );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToEvent;
    procedure SetToNetworkStatus;
  end;

    // 设置 Pc 离线
  TNetPcOfflineHandle = class( TNetPcChangeHandle )
  public
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToEvent;
    procedure SetToNetworkStatus;
  end;

      // 设置 Pc 成为 服务器
  TNetPcBeServerHandle = class( TNetPcChangeHandle )
  public
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToNetworkStatus;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' Group 修改 ' }

    // 修改
  TNetworkGroupWriteHandle = class
  public
    GroupName : string;
  public
    constructor Create( _GroupName : string );
  end;
  
    // 读取
  TNetworkGroupReadHandle = class( TNetworkGroupWriteHandle )
  public
    Password : string;
  public
    procedure SetPassword( _Password : string );
    procedure Update;virtual;
  private
    procedure AddToInfo;
    procedure AddToFace;
  end;
  
    // 添加
  TNetworkGroupAddHandle = class( TNetworkGroupReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 修改
  TNetworkGroupSetPasswordHandle = class( TNetworkGroupWriteHandle )
  public
    Password : string;
  public
    procedure SetPassword( _Password : string );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToFace;
     procedure SetToXml;
  end;
  
    // 删除
  TNetworkGroupRemoveHandle = class( TNetworkGroupWriteHandle )
  protected
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromFace;
    procedure RemoveFromXml;
  end;

{$EndRegion}

{$Region ' ConnToPc 修改 ' }

    // 修改
  TNetworkPcConnWriteHandle = class
  public
    Domain, Port : string;
  public
    constructor Create( _Domain, _Port : string );
  end;
  
    // 读取
  TNetworkPcConnReadHandle = class( TNetworkPcConnWriteHandle )
  public
    procedure Update;virtual;
  private
    procedure AddToInfo;
    procedure AddToFace;
  end;
  
    // 添加
  TNetworkPcConnAddHandle = class( TNetworkPcConnReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;
  
    // 删除
  TNetworkPcConnRemoveHandle = class( TNetworkPcConnWriteHandle )
  protected
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromFace;
    procedure RemoveFromXml;
  end;
  


{$EndRegion}

{$Region ' NetworkMode 修改 ' }

    // 读取 网络模式
  TNetworkModeReadHandle = class
  public
    SelectType : string;
    SelectValue1, SelectValue2 : string;
  public
    constructor Create( _SelectType : string );
    procedure SetValue( _SelectValue1, _SelectValue2 : string );
    procedure Update;virtual;
  protected
    procedure SetToInfo;
    procedure SetToFace;
  end;

    // 设置 网络模式
  TNetworkModeSetHandle = class( TNetworkModeReadHandle )
  public
    procedure Update;override;
  protected
    procedure SetToXml;
  end;

    // 进入Group网络
  TJoinAGroupHandle = class
  protected
    GroupName, Password : string;
  public
    constructor Create( _GroupName, _Password : string );
    procedure Update;
  private       // 网络类型的内容变化
    procedure AddGroup;
    function SetPassword: Boolean;
  end;

    // 连接一台 Pc
  TConnToPcHandle = class
  public
    Domain, Port : string;
  public
    constructor Create( _Domain, _Port : string );
    procedure Update;
  private
    procedure AddToPc;
  end;

{$EndRegion}

{$Region ' 网络状态 ' }

    // 修改
  TNetworkStatusWriteHandle = class
  public
    PcID : string;
  public
    constructor Create( _PcID : string );
  end;

    // 读取
  TNetworkStatusAddHandle = class( TNetworkStatusWriteHandle )
  public
    PcName : string;
  public
    procedure SetPcName( _PcName : string );
    procedure Update;virtual;
  private
    procedure AddToFace;
  end;


    // 删除
  TNetworkStatusRemoveHandle = class( TNetworkStatusWriteHandle )
  protected
    procedure Update;
  private
    procedure RemoveFromFace;
  end;

      // 修改
  TNetworkStatusSetConnectInfoHandle = class( TNetworkStatusWriteHandle )
  public
    Ip, Port : string;
    IsConnect, IsLanConn : boolean;
  public
    procedure SetConnectInfo( _Ip, _Port : string; _IsConnect, _IsLanConn : boolean );
    procedure Update;
  private
    procedure SetToFace;
  end;


      // 修改
  TNetworkStatusSetIsOnlineHandle = class( TNetworkStatusWriteHandle )
  public
    IsOnline : boolean;
  public
    procedure SetIsOnline( _IsOnline : boolean );
    procedure Update;
  private
     procedure SetToFace;
  end;


      // 修改
  TNetworkStatusSetIsServerHandle = class( TNetworkStatusWriteHandle )
  public
    IsServer : boolean;
  public
    procedure SetIsServer( _IsServer : boolean );
    procedure Update;
  private
     procedure SetToFace;
  end;

      // 修改
  TNetworkStatusClearItemHandle = class
  public
    procedure Update;
  private
     procedure SetToFace;
  end;

{$EndRegion}

{$Region ' 帐号信息 修改 ' }

    // 修改
  TAccountWriteHandle = class
  public
    AccountName : string;
  public
    constructor Create( _AccountName : string );
  end;

      // 读取
  TAccountReadHandle = class( TAccountWriteHandle )
  protected
    Password : string;
  public
    procedure SetPassword( _Password : string );
    procedure Update;virtual;
  private
    procedure AddToInfo;
    procedure AddToFace;
  end;

    // 添加
  TAccountAddHandle = class( TAccountReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 删除
  TAccountRemoveHandle = class( TAccountWriteHandle )
  protected
    procedure Update;
  private
    procedure RemoveFromFace;
    procedure RemoveFromInfo;
    procedure RemoveFromXml;
  end;

{$EndRegion}

{$Region ' 帐号路径 修改 ' }

    // 修改
  TBackupListWriteHandle = class( TAccountWriteHandle )
  public
    BackupPath : string;
  public
    procedure SetBackupPath( _BackupPath : string );
  end;

    // 读取
  TBackupListReadHandle = class( TBackupListWriteHandle )
  public
    procedure Update;virtual;
  private
    procedure AddToInfo;
    procedure AddToFace;
  end;

    // 添加
  TBackupListAddHandle = class( TBackupListReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 删除
  TBackupListRemoveHandle = class( TBackupListWriteHandle )
  protected
    procedure Update;
  private
    procedure RemoveFromFace;
    procedure RemoveFromInfo;
    procedure RemoveFromXml;
  end;



{$EndRegion}


  NetworkPcApi = class
  public
    class procedure AddItem( PcID, PcName : string );
    class procedure PcOnline( PcID, Account : string );
    class procedure PcOffline( PcID : string );
    class procedure BeServer( PcID : string );
  public
    class procedure SetSocketInfo( PcID, Ip, Port : string; IsLanConn : Boolean );
    class procedure SetCanConnectTo( PcID : string; CanConnectTo : Boolean );
    class procedure SetCanConnectFrom( PcID : string; CanConnectFrom : Boolean );
    class procedure SetAvailableSpace( PcID : string; AvailableSpace : Int64 ) ;
  public
    class procedure RestartNetwork;
  end;

  NetworkConnStatusShowApi = class
  public
    class procedure SetNotConnected;
    class procedure SetConnecting;
    class procedure SetConnected;
  public
    class procedure SetNotChangeNetwork;
    class procedure SetCanChangeNetwork;
  end;

  NetworkModeApi = class
  public              // Local Network 修改
    class procedure SelectLocalNetwork;
    class procedure SelectLocalConn( PcID : string ); // 设置特殊连接的端口
  public              // Group 修改
    class procedure AddGroup( GroupName, Password : string );
    class procedure SetPassword( GroupName, Password : string );
    class procedure RemoveGroup( GroupName : string );
    class procedure SelectGroup( GroupName : string );
  public              // Conn To Pc 修改
    class procedure AddConnToPc( Domain, Port : string );
    class procedure RemoveConnToPc( Domain, Port : string );
    class procedure SelectConnToPc( Domain, Port : string );
  public              // 设置 网络模式
    class procedure SetNetworkMode( SelectType, SelectValue1, SelectValue2 : string );
    class procedure RefreshSecurity;
  public             // 重启网络
    class procedure RestartNetwork;
    class procedure PmSelectGroupFace( Sender : TObject );
    class procedure PmSelectConnToPcFace( Sender : TObject );
  public             // 添加网络
    class procedure JoinAGroup( GroupName, Password : string );
    class procedure ConnToAPc( Domain, Port : string );
  public              // 进入网络
    class procedure EnterLan;
    class procedure EnterGroup( GroupName : string );
    class procedure EnterConnToPc( Domain, Port : string );
  public              // Group 出错
    class procedure PasswordError( GroupName : string );
    class procedure AccountNotExist( GroupName, Password : string );
  public              // Connect to Pc 出错
    class procedure DnsIpError( Domain, Port : string );
    class procedure CloudIDError;
  end;

      // 网络状态
  NetworkStatusApi = class
  public
    class procedure AddItem( PcID, PcName : string );
    class procedure SetConnInfo( PcID, Ip, Port : string; IsConnect, IsLanConn : Boolean );
    class procedure SetIsOnline( PcID : string; IsOnline : Boolean );
    class procedure SetIsServer( PcID : string; IsServer : Boolean );
    class procedure ClearItem;
  end;

    // 我的网络状态
  MyNetworkStatusApi = class
  public
    class procedure LanConnections;
    class procedure GroupConnections( GroupName : string );
    class procedure ConnToPcConnections( PcSocketInfo : string );
  public
    class procedure SetBroadcastDisable;
    class procedure SetBroadcastPort( BroadcastPort, ErrorStr : string );
  public
    class procedure SetLanSocket( LanIp, LanPort : string );
    class procedure SetLanSocketSuccess;
  public
    class procedure SetInternetSocket( InternetIp, InternetPort : string );
    class procedure SetInternetSocketSuccess;
  public
    class procedure SetIsExistUpnp( IsExist : Boolean; UpnpUrl : string );
    class procedure SetIsPortMapCompleted( IsCompleted : Boolean );
  end;

    // 网络连接失败的状态
  NetworkErrorStatusApi = class
  public
    class procedure ShowNoPc;
    class procedure ShowExistOldEdition( Ip : string; IsNewEdition : Boolean );
    class procedure ShowGroupNotExist( GroupName : string );
    class procedure ShowGroupPasswordError( GroupName : string );
  public
    class procedure ShowIpError( Domain, Port : string );
    class procedure ShowCannotConn( Domain, Port : string );
    class procedure ShowSecurityError( Domain, Port, ErrorType : string );
  public
    class procedure ShowConnAgainRemain( RemainSecond : Integer );
    class procedure HideError;
    class procedure HideNoPcError;
  end;

  NetworkConnEditionErrorApi = class
  public
    class procedure AddItem( Ip, PcName : string );
    class procedure RemoveItem( Ip : string );
    class procedure ClearItem;
  end;

      // 网络帐号信息
  NetworkAccountApi = class
  public
    class procedure AddAccount( Account, Password : string );
    class procedure RemoveAccount( Account : string );
  public
    class procedure AddAccountPath( Account, BackupPath : string );
    class procedure RemoveAccountPath( Account, BackupPath : string );
  public
    class procedure SetIpInfo( LanIp, LanPort, InternetIp, InternetPort : string );
    class procedure SetAccountIsOnline( Account : string; IsOnline : Boolean );
  end;


const
  SelectConnType_Local = 'Local';
  SelectConnType_Group = 'Group';
  SelectConnType_ConnPC = 'ConnPc';

implementation

uses  UNetworkFace, UMainForm, UNetPcInfoXml, UFormSetting, UNetworkEventInfo, UMyUtil, USettingInfo;


{ TNetPcChangeHandle }

constructor TNetPcChangeHandle.Create(_PcID: string);
begin
  PcID := _PcID;
end;

{ TNetPcSetSocketHandle }

procedure TNetPcSetSocketHandle.SetToNetworkStatus;
begin
  NetworkStatusApi.SetConnInfo( PcID, Ip, Port, True, IsLanConn );
end;

procedure TNetPcSetSocketHandle.SetToXml;
var
  NetPcSocketXml : TNetPcSocketXml;
begin
    // 写 Xml
  NetPcSocketXml := TNetPcSocketXml.Create( PcID );
  NetPcSocketXml.SetSocket( Ip, Port );
  NetPcSocketXml.SetIsLanConn( IsLanConn );
  NetPcSocketXml.AddChange;
end;

procedure TNetPcSetSocketHandle.Update;
begin
  inherited;
  SetToXml;
  SetToNetworkStatus;
end;

{ TNetPcOnlineHandle }

procedure TNetPcOnlineHandle.SetAccount(_Account: string);
begin
  Account := _Account;
end;

procedure TNetPcOnlineHandle.SetToEvent;
begin
  NetworkPcEvent.PcOnline( PcID, Account );
end;

procedure TNetPcOnlineHandle.SetToInfo;
var
  NetPcOnlineInfo : TNetPcOnlineInfo;
begin
  NetPcOnlineInfo := TNetPcOnlineInfo.Create( PcID );
  NetPcOnlineInfo.Update;
  NetPcOnlineInfo.Free;
end;

procedure TNetPcOnlineHandle.SetToNetworkStatus;
begin
  NetworkStatusApi.SetIsOnline( PcID, True );
end;

procedure TNetPcOnlineHandle.Update;
begin
  SetToInfo;
  SetToEvent;
  SetToNetworkStatus;
end;

{ TNetPcReadHandle }

procedure TNetPcReadHandle.AddToInfo;
var
  NetPcAddInfo : TNetPcAddInfo;
begin
    // 写 内存
  NetPcAddInfo := TNetPcAddInfo.Create( PcID );
  NetPcAddInfo.SetPcName( PcName );
  NetPcAddInfo.Update;
  NetPcAddInfo.Free;
end;

procedure TNetPcReadHandle.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TNetPcReadHandle.Update;
begin
  AddToInfo;
end;

{ TNetPcSocketReadHandle }

procedure TNetPcSocketReadHandle.SetIsLanConn(_IsLanConn: Boolean);
begin
  IsLanConn := _IsLanConn;
end;

procedure TNetPcSocketReadHandle.SetSocket(_Ip, _Port: string);
begin
  Ip := _Ip;
  Port := _Port;
end;

procedure TNetPcSocketReadHandle.SetToInfo;
var
  NetPcSocketInfo : TNetPcSocketInfo;
begin
    // 写 内存
  NetPcSocketInfo := TNetPcSocketInfo.Create( PcID );
  NetPcSocketInfo.SetSocket( Ip, Port );
  NetPcSocketInfo.SetIsLanConn( IsLanConn );
  NetPcSocketInfo.Update;
  NetPcSocketInfo.Free;
end;

procedure TNetPcSocketReadHandle.Update;
begin
  SetToInfo;
end;


{ TNetworkPcResetHandle }

procedure TNetworkPcResetHandle.Update;
var
  ActivatePcList : TStringList;
  i: Integer;
begin
    // 活动的pc都离线
  ActivatePcList := MyNetPcInfoReadUtil.ReadActivatePcList;
  for i := 0 to ActivatePcList.Count - 1 do
    NetworkPcApi.PcOffline( ActivatePcList[i] );
  ActivatePcList.Free;

    // 清空连接的Pc
  NetworkStatusApi.ClearItem;

    // 刷新 安全
  NetworkModeApi.RefreshSecurity;

    // 清空
  NetworkConnEditionErrorApi.ClearItem;
end;

{ TNetPcOfflineHandle }

procedure TNetPcOfflineHandle.SetToEvent;
begin
  NetworkPcEvent.PcOffline( PcID );
end;

procedure TNetPcOfflineHandle.SetToInfo;
var
  NetPcOfflineInfo : TNetPcOfflineInfo;
begin
  NetPcOfflineInfo := TNetPcOfflineInfo.Create( PcID );
  NetPcOfflineInfo.Update;
  NetPcOfflineInfo.Free;
end;

procedure TNetPcOfflineHandle.SetToNetworkStatus;
begin
  NetworkStatusApi.SetIsOnline( PcID, False );
end;

procedure TNetPcOfflineHandle.Update;
begin
  SetToInfo;
  SetToEvent;
  SetToNetworkStatus;
end;

{ TNetPcAddCloudHandle }

procedure TNetPcAddHandle.AddToEvent;
begin
  NetworkPcEvent.AddPc( PcID );
end;

procedure TNetPcAddHandle.AddToNetworkError;
begin
    // 本机
  if PcID = PcInfo.PcID then
    Exit;

    // 出现了其他机器
  NetworkErrorStatusApi.HideNoPcError;
end;

procedure TNetPcAddHandle.AddToNetworkStatus;
begin
  NetworkStatusApi.AddItem( PcID, PcName );
end;

procedure TNetPcAddHandle.AddToXml;
var
  NetPcAddXml : TNetPcAddXml;
begin
    // 写 Xml
  NetPcAddXml := TNetPcAddXml.Create( PcID );
  NetPcAddXml.SetPcName( PcName );
  NetPcAddXml.AddChange;
end;

procedure TNetPcAddHandle.Update;
begin
  inherited;
  AddToXml;
  AddToEvent;
  AddToNetworkStatus;
  AddToNetworkError;
end;

{ NetworkPcApi }

class procedure NetworkPcApi.AddItem(PcID, PcName: string);
var
  NetPcAddHandle : TNetPcAddHandle;
begin
  NetPcAddHandle := TNetPcAddHandle.Create( PcID );
  NetPcAddHandle.SetPcName( PcName );
  NetPcAddHandle.Update;
  NetPcAddHandle.Free;
end;

class procedure NetworkPcApi.BeServer(PcID: string);
var
  NetPcBeServerHandle : TNetPcBeServerHandle;
begin
  NetPcBeServerHandle := TNetPcBeServerHandle.Create( PcID );
  NetPcBeServerHandle.Update;
  NetPcBeServerHandle.Free;
end;

class procedure NetworkPcApi.PcOffline(PcID: string);
var
  NetPcOfflineHandle : TNetPcOfflineHandle;
begin
  NetPcOfflineHandle := TNetPcOfflineHandle.Create( PcID );
  NetPcOfflineHandle.Update;
  NetPcOfflineHandle.Free;
end;

class procedure NetworkPcApi.PcOnline(PcID, Account: string);
var
  NetPcOnlineHandle : TNetPcOnlineHandle;
begin
  NetPcOnlineHandle := TNetPcOnlineHandle.Create( PcID );
  NetPcOnlineHandle.SetAccount( Account );
  NetPcOnlineHandle.Update;
  NetPcOnlineHandle.Free;
end;

class procedure NetworkPcApi.RestartNetwork;
begin
  MySearchMasterHandler.RestartNetwork;
end;

class procedure NetworkPcApi.SetAvailableSpace(PcID: string;
  AvailableSpace: Int64);
begin

end;

class procedure NetworkPcApi.SetSocketInfo(PcID, Ip, Port: string;
  IsLanConn : Boolean);
var
  NetPcSetSocketHandle : TNetPcSetSocketHandle;
begin
  NetPcSetSocketHandle := TNetPcSetSocketHandle.Create( PcID );
  NetPcSetSocketHandle.SetSocket( Ip, Port );
  NetPcSetSocketHandle.SetIsLanConn( IsLanConn );
  NetPcSetSocketHandle.Update;
  NetPcSetSocketHandle.Free;
end;

{ NetworkModeApi }

class procedure NetworkModeApi.AccountNotExist(GroupName, Password: string);
var
  StandardAccountError : TStandardAccountError;
begin
  StandardAccountError := TStandardAccountError.Create( GroupName );
  StandardAccountError.SetPassword( Password );
  StandardAccountError.AddChange;
end;

class procedure NetworkModeApi.AddConnToPc(Domain, Port: string);
var
  NetworkPcConnAddHandle : TNetworkPcConnAddHandle;
begin
  NetworkPcConnAddHandle := TNetworkPcConnAddHandle.Create( Domain, Port );
  NetworkPcConnAddHandle.Update;
  NetworkPcConnAddHandle.Free;
end;
  


class procedure NetworkModeApi.AddGroup(GroupName, Password: string);
var
  NetworkGroupAddHandle : TNetworkGroupAddHandle;
begin
  NetworkGroupAddHandle := TNetworkGroupAddHandle.Create( GroupName );
  NetworkGroupAddHandle.SetPassword( Password );
  NetworkGroupAddHandle.Update;
  NetworkGroupAddHandle.Free;
end;
  

class procedure NetworkModeApi.ConnToAPc(Domain, Port: string);
var
  ConnToPcHandle : TConnToPcHandle;
begin
  ConnToPcHandle := TConnToPcHandle.Create( Domain, Port );
  ConnToPcHandle.Update;
  ConnToPcHandle.Free;
end;

class procedure NetworkModeApi.DnsIpError(Domain, Port: string);
var
  AdvanceDnsError : TAdvanceDnsError;
begin
  AdvanceDnsError := TAdvanceDnsError.Create( Domain, Port );
  AdvanceDnsError.AddChange;
end;

class procedure NetworkModeApi.EnterConnToPc(Domain, Port: string);
begin
  SelectConnToPc( Domain, Port );
  RestartNetwork;
end;

class procedure NetworkModeApi.EnterGroup(GroupName: string);
begin
  SelectGroup( GroupName );
  RestartNetwork;
end;

class procedure NetworkModeApi.EnterLan;
begin
  SelectLocalNetwork;
  RestartNetwork;
end;

class procedure NetworkModeApi.CloudIDError;
var
  AdvanceSecurityIDError : TAdvanceSecurityIDError;
begin
  AdvanceSecurityIDError := TAdvanceSecurityIDError.Create;
  AdvanceSecurityIDError.AddChange;
end;

class procedure NetworkModeApi.JoinAGroup(GroupName, Password: string);
var
  JoinAGroupHandle : TJoinAGroupHandle;
begin
  JoinAGroupHandle := TJoinAGroupHandle.Create( GroupName, Password );
  JoinAGroupHandle.Update;
  JoinAGroupHandle.Free;
end;

class procedure NetworkModeApi.PasswordError(GroupName: string);
var
  StandardPasswordError : TStandardPasswordError;
begin
  StandardPasswordError := TStandardPasswordError.Create( GroupName );
  StandardPasswordError.AddChange;
end;

class procedure NetworkModeApi.PmSelectConnToPcFace(Sender: TObject);
var
  miConnToPc : TMenuItem;
  ShowList : TStringList;
begin
  miConnToPc := sender as TMenuItem;

  if miConnToPc.ImageIndex = -1 then
  begin
    ShowList := MySplitStr.getList( miConnToPc.Caption, SplitStr_ConnPc );
    if ShowList.Count = 2 then
    begin
      NetworkModeApi.EnterConnToPc( ShowList[0], ShowList[1] );
    end;
    ShowList.Free;
  end
  else
  if MyMessageBox.ShowConfirm( ShowForm_RestartNetwork ) then
    NetworkModeApi.RestartNetwork;
end;

class procedure NetworkModeApi.PmSelectGroupFace(Sender: TObject);
var
  miGroup : TMenuItem;
begin
  miGroup := sender as TMenuItem;

  if miGroup.ImageIndex = -1 then
    NetworkModeApi.EnterGroup( miGroup.Caption )
  else
  if MyMessageBox.ShowConfirm( ShowForm_RestartNetwork ) then
    NetworkModeApi.RestartNetwork;
end;

class procedure NetworkModeApi.RefreshSecurity;
var
  SbNetworkSecuritySetFace : TSbNetworkSecuritySetFace;
begin
  SbNetworkSecuritySetFace := TSbNetworkSecuritySetFace.Create;
  SbNetworkSecuritySetFace.SetIsSecurity( CloudSafeSettingInfo.IsCloudSafe );
  SbNetworkSecuritySetFace.AddChange;
end;

class procedure NetworkModeApi.RemoveConnToPc(Domain, Port: string);
var
  NetworkPcConnRemoveHandle : TNetworkPcConnRemoveHandle;
begin
  NetworkPcConnRemoveHandle := TNetworkPcConnRemoveHandle.Create( Domain, Port );
  NetworkPcConnRemoveHandle.Update;
  NetworkPcConnRemoveHandle.Free;
end;
  

class procedure NetworkModeApi.RemoveGroup(GroupName: string);
var
  NetworkGroupRemoveHandle : TNetworkGroupRemoveHandle;
begin
  NetworkGroupRemoveHandle := TNetworkGroupRemoveHandle.Create( GroupName );
  NetworkGroupRemoveHandle.Update;
  NetworkGroupRemoveHandle.Free;
end;
  


class procedure NetworkModeApi.RestartNetwork;
begin
      // 重启网络
  MySearchMasterHandler.RestartNetwork;
end;

class procedure NetworkModeApi.SelectConnToPc(Domain, Port: string);
begin
  SetNetworkMode( SelectConnType_ConnPC, Domain, Port );
end;

class procedure NetworkModeApi.SelectGroup(GroupName: string);
begin
  SetNetworkMode( SelectConnType_Group, GroupName, '' );
end;

class procedure NetworkModeApi.SelectLocalConn(PcID: string);
begin
  if MyNetworkConnInfo.SelectType = SelectConnType_Local then
    MyNetworkConnInfo.SelectValue1 := PcID;
end;

class procedure NetworkModeApi.SelectLocalNetwork;
begin
  SetNetworkMode( SelectConnType_Local, '', '' );
end;

class procedure NetworkModeApi.SetNetworkMode(SelectType, SelectValue1,
  SelectValue2: string);
var
  NetworkModeSetHandle : TNetworkModeSetHandle;
begin
  NetworkModeSetHandle := TNetworkModeSetHandle.Create( SelectType );
  NetworkModeSetHandle.SetValue( SelectValue1, SelectValue2 );
  NetworkModeSetHandle.Update;
  NetworkModeSetHandle.Free;
end;


class procedure NetworkModeApi.SetPassword(GroupName, Password: string);
var
  NetworkGroupSetPasswordHandle : TNetworkGroupSetPasswordHandle;
begin
  NetworkGroupSetPasswordHandle := TNetworkGroupSetPasswordHandle.Create( GroupName );
  NetworkGroupSetPasswordHandle.SetPassword( Password );
  NetworkGroupSetPasswordHandle.Update;
  NetworkGroupSetPasswordHandle.Free;
end;
  

constructor TNetworkGroupWriteHandle.Create( _GroupName : string );
begin
  GroupName := _GroupName;
end;

{ TNetworkGroupReadHandle }

procedure TNetworkGroupReadHandle.SetPassword( _Password : string );
begin
  Password := _Password;
end;

procedure TNetworkGroupReadHandle.AddToInfo;
var
  NetworkGroupAddInfo : TNetworkGroupAddInfo;
begin
  NetworkGroupAddInfo := TNetworkGroupAddInfo.Create( GroupName );
  NetworkGroupAddInfo.SetPassword( Password );
  NetworkGroupAddInfo.Update;
  NetworkGroupAddInfo.Free;
end;

procedure TNetworkGroupReadHandle.AddToFace;
var
  NetworkGroupAddFace : TPmGroupAddFace;
  CbbGroupAddFace : TCbbGroupAddFace;
begin
  NetworkGroupAddFace := TPmGroupAddFace.Create( GroupName );
  NetworkGroupAddFace.AddChange;

  CbbGroupAddFace := TCbbGroupAddFace.Create( GroupName );
  CbbGroupAddFace.SetPassword( Password );
  CbbGroupAddFace.AddChange;
end;

procedure TNetworkGroupReadHandle.Update;
begin
  AddToInfo;
  AddToFace;
end;

{ TNetworkGroupAddHandle }

procedure TNetworkGroupAddHandle.AddToXml;
var
  NetworkGroupAddXml : TNetworkGroupAddXml;
begin
  NetworkGroupAddXml := TNetworkGroupAddXml.Create( GroupName );
  NetworkGroupAddXml.SetPassword( Password );
  NetworkGroupAddXml.AddChange;
end;

procedure TNetworkGroupAddHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TNetworkGroupRemoveHandle }

procedure TNetworkGroupRemoveHandle.RemoveFromInfo;
var
  NetworkGroupRemoveInfo : TNetworkGroupRemoveInfo;
begin
  NetworkGroupRemoveInfo := TNetworkGroupRemoveInfo.Create( GroupName );
  NetworkGroupRemoveInfo.Update;
  NetworkGroupRemoveInfo.Free;
end;

procedure TNetworkGroupRemoveHandle.RemoveFromFace;
var
  NetworkGroupRemoveFace : TPmGroupRemoveFace;
  CbbGroupRemoveFace : TCbbGroupRemoveFace;
begin
  NetworkGroupRemoveFace := TPmGroupRemoveFace.Create( GroupName );
  NetworkGroupRemoveFace.AddChange;

  CbbGroupRemoveFace := TCbbGroupRemoveFace.Create( GroupName );
  CbbGroupRemoveFace.AddChange;
end;

procedure TNetworkGroupRemoveHandle.RemoveFromXml;
var
  NetworkGroupRemoveXml : TNetworkGroupRemoveXml;
begin
  NetworkGroupRemoveXml := TNetworkGroupRemoveXml.Create( GroupName );
  NetworkGroupRemoveXml.AddChange;
end;

procedure TNetworkGroupRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromFace;
  RemoveFromXml;
end;

{ TNetworkGroupSetPasswordHandle }

procedure TNetworkGroupSetPasswordHandle.SetToInfo;
var
  NetworkGroupSetPasswordInfo : TNetworkGroupSetPasswordInfo;
begin
  NetworkGroupSetPasswordInfo := TNetworkGroupSetPasswordInfo.Create( GroupName );
  NetworkGroupSetPasswordInfo.SetPassword( Password );
  NetworkGroupSetPasswordInfo.Update;
  NetworkGroupSetPasswordInfo.Free;
end;

procedure TNetworkGroupSetPasswordHandle.SetToXml;
var
  NetworkGroupSetPasswordXml : TNetworkGroupSetPasswordXml;
begin
  NetworkGroupSetPasswordXml := TNetworkGroupSetPasswordXml.Create( GroupName );
  NetworkGroupSetPasswordXml.SetPassword( Password );
  NetworkGroupSetPasswordXml.AddChange;
end;

procedure TNetworkGroupSetPasswordHandle.SetPassword(_Password: string);
begin
  Password := _Password;
end;

procedure TNetworkGroupSetPasswordHandle.SetToFace;
var
  CbbGroupSetPasswordFace : TCbbGroupSetPasswordFace;
begin
  CbbGroupSetPasswordFace := TCbbGroupSetPasswordFace.Create( GroupName );
  CbbGroupSetPasswordFace.SetPassword( Password );
  CbbGroupSetPasswordFace.AddChange;
end;

procedure TNetworkGroupSetPasswordHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

constructor TNetworkPcConnWriteHandle.Create( _Domain, _Port : string );
begin
  Domain := _Domain;
  Port := _Port;
end;

{ TNetworkPcConnReadHandle }

procedure TNetworkPcConnReadHandle.AddToInfo;
var
  NetworkPcConnAddInfo : TNetworkPcConnAddInfo;
begin
  NetworkPcConnAddInfo := TNetworkPcConnAddInfo.Create( Domain, Port );
  NetworkPcConnAddInfo.Update;
  NetworkPcConnAddInfo.Free;
end;

procedure TNetworkPcConnReadHandle.AddToFace;
var
  NetworkPcConnAddFace : TPmPcConnAddFace;
  CbbConnToPcAddFace : TCbbConnToPcAddFace;
begin
  NetworkPcConnAddFace := TPmPcConnAddFace.Create( Domain, Port );
  NetworkPcConnAddFace.AddChange;

  CbbConnToPcAddFace := TCbbConnToPcAddFace.Create( Domain, Port );
  CbbConnToPcAddFace.AddChange;
end;

procedure TNetworkPcConnReadHandle.Update;
begin
  AddToInfo;
  AddToFace;
end;

{ TNetworkPcConnAddHandle }

procedure TNetworkPcConnAddHandle.AddToXml;
var
  NetworkPcConnAddXml : TNetworkPcConnAddXml;
begin
  NetworkPcConnAddXml := TNetworkPcConnAddXml.Create( Domain, Port );
  NetworkPcConnAddXml.AddChange;
end;

procedure TNetworkPcConnAddHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TNetworkPcConnRemoveHandle }

procedure TNetworkPcConnRemoveHandle.RemoveFromInfo;
var
  NetworkPcConnRemoveInfo : TNetworkPcConnRemoveInfo;
begin
  NetworkPcConnRemoveInfo := TNetworkPcConnRemoveInfo.Create( Domain, Port );
  NetworkPcConnRemoveInfo.Update;
  NetworkPcConnRemoveInfo.Free;
end;

procedure TNetworkPcConnRemoveHandle.RemoveFromFace;
var
  NetworkPcConnRemoveFace : TPmPcConnRemoveFace;
  CbbConnToPcRemoveFace : TCbbConnToPcRemoveFace;
begin
  NetworkPcConnRemoveFace := TPmPcConnRemoveFace.Create( Domain, Port );
  NetworkPcConnRemoveFace.AddChange;

  CbbConnToPcRemoveFace := TCbbConnToPcRemoveFace.Create( Domain, Port );
  CbbConnToPcRemoveFace.AddChange;
end;

procedure TNetworkPcConnRemoveHandle.RemoveFromXml;
var
  NetworkPcConnRemoveXml : TNetworkPcConnRemoveXml;
begin
  NetworkPcConnRemoveXml := TNetworkPcConnRemoveXml.Create( Domain, Port );
  NetworkPcConnRemoveXml.AddChange;
end;

procedure TNetworkPcConnRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromFace;
  RemoveFromXml;
end;


{ TNetworkModeSetHandle }

procedure TNetworkModeSetHandle.SetToXml;
var
  NetworkModeChangeXml : TNetworkModeChangeXml;
begin
  NetworkModeChangeXml := TNetworkModeChangeXml.Create( SelectType );
  NetworkModeChangeXml.SetValue( SelectValue1, SelectValue2 );
  NetworkModeChangeXml.AddChange;
end;

procedure TNetworkModeSetHandle.Update;
begin
  inherited;
  SetToXml;
end;

{ TNetworkModeReadHandle }

constructor TNetworkModeReadHandle.Create(_SelectType: string);
begin
  SelectType := _SelectType;
end;

procedure TNetworkModeReadHandle.SetToFace;
var
  NetworkModeSelectFace : TPmNetworkModeSelectFace;
  CbbNetworkModeSelectFace : TCbbNetworkModeSelectFace;
begin
  NetworkModeSelectFace := TPmNetworkModeSelectFace.Create( SelectType );
  NetworkModeSelectFace.SetValue( SelectValue1, SelectValue2 );
  NetworkModeSelectFace.AddChange;

  CbbNetworkModeSelectFace := TCbbNetworkModeSelectFace.Create( SelectType );
  CbbNetworkModeSelectFace.SetValue( SelectValue1, SelectValue2 );
  CbbNetworkModeSelectFace.AddChange;
end;

procedure TNetworkModeReadHandle.SetToInfo;
begin
  MyNetworkConnInfo.SelectType := SelectType;
  MyNetworkConnInfo.SelectValue1 := SelectValue1;
  MyNetworkConnInfo.SelectValue2 := SelectValue2;
end;

procedure TNetworkModeReadHandle.SetValue(_SelectValue1, _SelectValue2: string);
begin
  SelectValue1 := _SelectValue1;
  SelectValue2 := _SelectValue2;
end;

procedure TNetworkModeReadHandle.Update;
begin
  SetToInfo;
  SetToFace;
end;

{ TJoinAGroupHandle }

procedure TJoinAGroupHandle.AddGroup;
begin
    // 已存在
  if NetworkGroupInfoReadUtil.ReadIsExist( GroupName ) then
    Exit;

    // 添加
  NetworkModeApi.AddGroup( GroupName, Password );
end;

constructor TJoinAGroupHandle.Create(_GroupName, _Password: string);
begin
  GroupName := _GroupName;
  Password := _Password;
end;

function TJoinAGroupHandle.SetPassword: Boolean;
begin
  Result := False;

    // 密码相同
  if NetworkGroupInfoReadUtil.ReadPassword( GroupName ) = Password then
    Exit;

    // 修改密码
  NetworkModeApi.SetPassword( GroupName, Password );

  Result := True;
end;

procedure TJoinAGroupHandle.Update;
var
  IsChangePassword : Boolean;
begin
  AddGroup;
  IsChangePassword := SetPassword;

    // 已经在网络上
  if ( MyNetworkConnInfo.SelectType = SelectConnType_Group ) and
     ( MyNetworkConnInfo.SelectValue1 = GroupName ) and
       not IsChangePassword
  then
    Exit;

    // 选择 Group 网络
  NetworkModeApi.SelectGroup( GroupName );

    // 重启网络
  NetworkModeApi.RestartNetwork;
end;

{ TConnToPcHandle }

procedure TConnToPcHandle.AddToPc;
begin
    // 已存在
  if NetworkConnToPcInfoReadUtil.ReadIsExist( Domain, Port ) then
    Exit;

    // 添加
  NetworkModeApi.AddConnToPc( Domain, Port );
end;

constructor TConnToPcHandle.Create(_Domain, _Port: string);
begin
  Domain := _Domain;
  Port := _Port;
end;

procedure TConnToPcHandle.Update;
begin
    // 可能添加 Pc
  AddToPc;

    // 已选择
  if ( MyNetworkConnInfo.SelectType = SelectConnType_ConnPC ) and
     ( MyNetworkConnInfo.SelectValue1 = Domain ) and
     ( MyNetworkConnInfo.SelectValue2 = Port )
  then
    Exit;

    // 设置选择的网络
  NetworkModeApi.SelectConnToPc( Domain, Port );

    // 重启网络
  NetworkPcApi.RestartNetwork;
end;

{ TMyPcInfoReadHandle }

constructor TMyPcInfoReadHandle.Create(_PcID, _PcName: string);
begin
  PcID := _PcID;
  PcName := _PcName;
end;

procedure TMyPcInfoReadHandle.SetSocketInfo(_LanIp, _LanPort,
  _InternetPort: string);
begin
  LanIp := _LanIp;
  LanPort := _LanPort;
  InternetPort := _InternetPort;
end;

procedure TMyPcInfoReadHandle.SetToFace;
var
  MyPcInfoRaadFace : TMyPcInfoRaadFace;
begin
  MyPcInfoRaadFace := TMyPcInfoRaadFace.Create( PcID, PcName );
  MyPcInfoRaadFace.SetSocketInfo( LanIp, LanPort, InternetPort );
  MyPcInfoRaadFace.AddChange;

    // 界面信息
  Network_LocalPcID := PcID;
end;

procedure TMyPcInfoReadHandle.SetToInfo;
begin
  PcInfo.PcID := PcID;
  PcInfo.PcName := PcName;
  PcInfo.LanIp := LanIp;
  PcInfo.LanPort := LanPort;
  PcInfo.InternetPort := InternetPort;

  PcInfo.RealLanIp := LanIp;
end;

procedure TMyPcInfoReadHandle.Update;
begin
  SetToInfo;
  SetToFace;
end;

{ TMyPcInfoSetHandle }

procedure TMyPcInfoFirstSetHandle.SetToXml;
var
  MyPcInfoSetXml : TMyPcInfoSetXml;
begin
  MyPcInfoSetXml := TMyPcInfoSetXml.Create( PcID, PcName );
  MyPcInfoSetXml.SetSocketInfo( LanIp, LanPort, InternetPort );
  MyPcInfoSetXml.AddChange;
end;

procedure TMyPcInfoFirstSetHandle.Update;
begin
  inherited;
  SetToXml;
end;

{ TMyPcInfoSetHandle }

procedure TMyPcInfoSetHandle.SetToFace;
begin

end;

{ TMyPcInfoSetLanPortHandle }

constructor TMyPcInfoSetLanPortHandle.Create(_LanPort: string);
begin
  LanPort := _LanPort;
end;

procedure TMyPcInfoSetLanPortHandle.SetToFace;
var
  MyPcInfoSetLanPortFace : TMyPcInfoSetLanPortFace;
begin
  MyPcInfoSetLanPortFace := TMyPcInfoSetLanPortFace.Create( LanPort );
  MyPcInfoSetLanPortFace.AddChange;
end;

procedure TMyPcInfoSetLanPortHandle.SetToInfo;
begin
  PcInfo.LanPort := LanPort;
end;

procedure TMyPcInfoSetLanPortHandle.SetToXml;
var
  MyPcInfoSetLanPortXml : TMyPcInfoSetLanPortXml;
begin
  MyPcInfoSetLanPortXml := TMyPcInfoSetLanPortXml.Create( LanPort );
  MyPcInfoSetLanPortXml.AddChange;
end;

procedure TMyPcInfoSetLanPortHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TMyPcInfoSetInternetPortHandle }

constructor TMyPcInfoSetInternetPortHandle.Create(_InternetPort: string);
begin
  InternetPort := _InternetPort;
end;

procedure TMyPcInfoSetInternetPortHandle.SetToFace;
var
  MyPcInfoSetInternetPortFace : TMyPcInfoSetInternetPortFace;
begin
  MyPcInfoSetInternetPortFace := TMyPcInfoSetInternetPortFace.Create( InternetPort );
  MyPcInfoSetInternetPortFace.AddChange;
end;

procedure TMyPcInfoSetInternetPortHandle.SetToInfo;
begin
  PcInfo.InternetPort := InternetPort;
end;

procedure TMyPcInfoSetInternetPortHandle.SetToXml;
var
  MyPcInfoSetInternetPortXml : TMyPcInfoSetInternetPortXml;
begin
  MyPcInfoSetInternetPortXml := TMyPcInfoSetInternetPortXml.Create( InternetPort );
  MyPcInfoSetInternetPortXml.AddChange;
end;

procedure TMyPcInfoSetInternetPortHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ MyPcInfoApi }

class procedure MyPcInfoApi.SetInternetIp(InternetIp: string);
var
  MyPcInfoSetInternetIpHandle : TMyPcInfoSetInternetIpHandle;
begin
  MyPcInfoSetInternetIpHandle := TMyPcInfoSetInternetIpHandle.Create( InternetIp );
  MyPcInfoSetInternetIpHandle.Update;
  MyPcInfoSetInternetIpHandle.Free;
end;

class procedure MyPcInfoApi.SetInternetPort(InternetPort: string);
var
  MyPcInfoSetInternetPortHandle : TMyPcInfoSetInternetPortHandle;
begin
  MyPcInfoSetInternetPortHandle := TMyPcInfoSetInternetPortHandle.Create( InternetPort );
  MyPcInfoSetInternetPortHandle.Update;
  MyPcInfoSetInternetPortHandle.Free;
end;

class procedure MyPcInfoApi.SetItem(Params: TMyPcInfoSetParams);
var
  MyPcInfoSetHandle : TMyPcInfoSetHandle;
begin
  MyPcInfoSetHandle := TMyPcInfoSetHandle.Create( Params.PcID, Params.PcName );
  MyPcInfoSetHandle.SetSocketInfo( Params.LanIp, Params.LanPort, Params.InternetPort );
  MyPcInfoSetHandle.Update;
  MyPcInfoSetHandle.Free;
end;

class procedure MyPcInfoApi.SetLanIp(LanIp: string);
var
  MyPcInfoSetLanIpHandle : TMyPcInfoSetLanIpHandle;
begin
  MyPcInfoSetLanIpHandle := TMyPcInfoSetLanIpHandle.Create( LanIp );
  MyPcInfoSetLanIpHandle.Update;
  MyPcInfoSetLanIpHandle.Free;
end;

class procedure MyPcInfoApi.SetLanPort(LanPort: string);
var
  MyPcInfoSetLanPortHandle : TMyPcInfoSetLanPortHandle;
begin
  MyPcInfoSetLanPortHandle := TMyPcInfoSetLanPortHandle.Create( LanPort );
  MyPcInfoSetLanPortHandle.Update;
  MyPcInfoSetLanPortHandle.Free;
end;

class procedure MyPcInfoApi.SetTempLanIp(TempLanIp: string);
var
  MyPcInfoSetTempLanIpHandle : TMyPcInfoSetTempLanIpHandle;
begin
  MyPcInfoSetTempLanIpHandle := TMyPcInfoSetTempLanIpHandle.Create( TempLanIp );
  MyPcInfoSetTempLanIpHandle.Update;
  MyPcInfoSetTempLanIpHandle.Free;
end;

{ TMyPcInfoSetLanIpHandle }

constructor TMyPcInfoSetLanIpHandle.Create(_LanIp: string);
begin
  LanIp := _LanIp;
end;

procedure TMyPcInfoSetLanIpHandle.SetToFace;
var
  MyPcInfoSetLanIpFace : TMyPcInfoSetLanIpFace;
begin
  MyPcInfoSetLanIpFace := TMyPcInfoSetLanIpFace.Create( LanIp );
  MyPcInfoSetLanIpFace.AddChange;
end;

procedure TMyPcInfoSetLanIpHandle.SetToInfo;
begin
  PcInfo.LanIp := LanIp;
  PcInfo.RealLanIp := LanIp;
end;

procedure TMyPcInfoSetLanIpHandle.SetToXml;
var
  MyPcInfoSetLanIpXml : TMyPcInfoSetLanIpXml;
begin
  MyPcInfoSetLanIpXml := TMyPcInfoSetLanIpXml.Create( LanIp );
  MyPcInfoSetLanIpXml.AddChange;
end;

procedure TMyPcInfoSetLanIpHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TMyPcInfoSetInternetIpHandle }

constructor TMyPcInfoSetInternetIpHandle.Create(_InternetIp: string);
begin
  InternetIp := _InternetIp;
end;

procedure TMyPcInfoSetInternetIpHandle.SetToFace;
var
  InternetSocketChangeInfo : TInternetSocketChangeInfo;
begin
    // 显示到 Setting 界面
  InternetSocketChangeInfo := TInternetSocketChangeInfo.Create( InternetIp );
  InternetSocketChangeInfo.AddChange;
end;

procedure TMyPcInfoSetInternetIpHandle.SetToInfo;
begin
  PcInfo.InternetIp := InternetIp;
end;

procedure TMyPcInfoSetInternetIpHandle.Update;
begin
  SetToInfo;
  SetToFace;
end;

{ NetworkConnStatusShowApi }

class procedure NetworkConnStatusShowApi.SetCanChangeNetwork;
var
  PmNetworkOpenChangeInfo : TPmNetworkOpenChangeInfo;
begin
    // 可以改变网络
  PmNetworkOpenChangeInfo := TPmNetworkOpenChangeInfo.Create;
  PmNetworkOpenChangeInfo.AddChange;
end;

class procedure NetworkConnStatusShowApi.SetConnected;
var
  SbMyStatusConnInfo : TSbMyStatusConnInfo;
begin
  SbMyStatusConnInfo := TSbMyStatusConnInfo.Create;
  SbMyStatusConnInfo.AddChange;
end;

class procedure NetworkConnStatusShowApi.SetConnecting;
var
  SbMyStatusConningInfo : TSbMyStatusConningInfo;
begin
  SbMyStatusConningInfo := TSbMyStatusConningInfo.Create;
  SbMyStatusConningInfo.AddChange;
end;

class procedure NetworkConnStatusShowApi.SetNotChangeNetwork;
var
  PmNetworkCloseChangeInfo : TPmNetworkCloseChangeInfo;
begin
    // 不能改变网络
  PmNetworkCloseChangeInfo := TPmNetworkCloseChangeInfo.Create;
  PmNetworkCloseChangeInfo.AddChange;
end;

class procedure NetworkConnStatusShowApi.SetNotConnected;
var
  SbMyStatusNotConnInfo : TSbMyStatusNotConnInfo;
begin
  SbMyStatusNotConnInfo := TSbMyStatusNotConnInfo.Create;
  SbMyStatusNotConnInfo.AddChange;
end;

{ NetworkStatusApi }

class procedure NetworkStatusApi.AddItem(PcID, PcName: string);
var
  NetworkStatusAddHandle : TNetworkStatusAddHandle;
begin
  NetworkStatusAddHandle := TNetworkStatusAddHandle.Create( PcID );
  NetworkStatusAddHandle.SetPcName( PcName );
  NetworkStatusAddHandle.Update;
  NetworkStatusAddHandle.Free;
end;



class procedure NetworkStatusApi.ClearItem;
var
  NetworkStatusClearItemHandle : TNetworkStatusClearItemHandle;
begin
  NetworkStatusClearItemHandle := TNetworkStatusClearItemHandle.Create;
  NetworkStatusClearItemHandle.Update;
  NetworkStatusClearItemHandle.Free;
end;

class procedure NetworkStatusApi.SetConnInfo(PcID, Ip, Port: string;
  IsConnect, IsLanConn: Boolean);
var
  NetworkStatusSetConnectInfoHandle : TNetworkStatusSetConnectInfoHandle;
begin
  NetworkStatusSetConnectInfoHandle := TNetworkStatusSetConnectInfoHandle.Create( PcID );
  NetworkStatusSetConnectInfoHandle.SetConnectInfo( Ip, Port, IsConnect, IsLanConn );
  NetworkStatusSetConnectInfoHandle.Update;
  NetworkStatusSetConnectInfoHandle.Free;
end;





class procedure NetworkStatusApi.SetIsOnline(PcID: string; IsOnline: Boolean);
var
  NetworkStatusSetIsOnlineHandle : TNetworkStatusSetIsOnlineHandle;
begin
  NetworkStatusSetIsOnlineHandle := TNetworkStatusSetIsOnlineHandle.Create( PcID );
  NetworkStatusSetIsOnlineHandle.SetIsOnline( IsOnline );
  NetworkStatusSetIsOnlineHandle.Update;
  NetworkStatusSetIsOnlineHandle.Free;
end;



class procedure NetworkStatusApi.SetIsServer(PcID: string; IsServer: Boolean);
var
  NetworkStatusSetIsServerHandle : TNetworkStatusSetIsServerHandle;
begin
  NetworkStatusSetIsServerHandle := TNetworkStatusSetIsServerHandle.Create( PcID );
  NetworkStatusSetIsServerHandle.SetIsServer( IsServer );
  NetworkStatusSetIsServerHandle.Update;
  NetworkStatusSetIsServerHandle.Free;
end;



constructor TNetworkStatusWriteHandle.Create( _PcID : string );
begin
  PcID := _PcID;
end;

{ TNetworkStatusReadHandle }

procedure TNetworkStatusAddHandle.SetPcName( _PcName : string );
begin
  PcName := _PcName;
end;

procedure TNetworkStatusAddHandle.AddToFace;
var
  NetworkStatusAddFace : TNetworkStatusAddFace;
begin
  NetworkStatusAddFace := TNetworkStatusAddFace.Create( PcID );
  NetworkStatusAddFace.SetPcName( PcName );
  NetworkStatusAddFace.AddChange;
end;

procedure TNetworkStatusAddHandle.Update;
begin
  AddToFace;
end;


{ TNetworkStatusRemoveHandle }


procedure TNetworkStatusRemoveHandle.RemoveFromFace;
var
  NetworkStatusRemoveFace : TNetworkStatusRemoveFace;
begin
  NetworkStatusRemoveFace := TNetworkStatusRemoveFace.Create( PcID );
  NetworkStatusRemoveFace.AddChange;
end;

procedure TNetworkStatusRemoveHandle.Update;
begin
  RemoveFromFace;
end;

{ TNetworkStatusSetConnectInfoHandle }

procedure TNetworkStatusSetConnectInfoHandle.SetConnectInfo( _Ip, _Port : string;
  _IsConnect, _IsLanConn : boolean );
begin
  Ip := _Ip;
  Port := _Port;
  IsConnect := _IsConnect;
  IsLanConn := _IsLanConn;
end;

procedure TNetworkStatusSetConnectInfoHandle.SetToFace;
var
  NetworkStatusSetConnectInfoFace : TNetworkStatusSetConnectInfoFace;
begin
  NetworkStatusSetConnectInfoFace := TNetworkStatusSetConnectInfoFace.Create( PcID );
  NetworkStatusSetConnectInfoFace.SetConnectInfo( Ip, Port, IsConnect, IsLanConn );
  NetworkStatusSetConnectInfoFace.AddChange;
end;

procedure TNetworkStatusSetConnectInfoHandle.Update;
begin
  SetToFace;
end;

{ TNetworkStatusSetIsOnlineHandle }

procedure TNetworkStatusSetIsOnlineHandle.SetIsOnline( _IsOnline : boolean );
begin
  IsOnline := _IsOnline;
end;

procedure TNetworkStatusSetIsOnlineHandle.SetToFace;
var
  NetworkStatusSetIsOnlineFace : TNetworkStatusSetIsOnlineFace;
begin
  NetworkStatusSetIsOnlineFace := TNetworkStatusSetIsOnlineFace.Create( PcID );
  NetworkStatusSetIsOnlineFace.SetIsOnline( IsOnline );
  NetworkStatusSetIsOnlineFace.AddChange;
end;

procedure TNetworkStatusSetIsOnlineHandle.Update;
begin
  SetToFace;
end;

{ TNetworkStatusSetIsServerHandle }

procedure TNetworkStatusSetIsServerHandle.SetIsServer( _IsServer : boolean );
begin
  IsServer := _IsServer;
end;

procedure TNetworkStatusSetIsServerHandle.SetToFace;
var
  NetworkStatusSetIsServerFace : TNetworkStatusSetIsServerFace;
begin
  NetworkStatusSetIsServerFace := TNetworkStatusSetIsServerFace.Create( PcID );
  NetworkStatusSetIsServerFace.SetIsServer( IsServer );
  NetworkStatusSetIsServerFace.AddChange;
end;

procedure TNetworkStatusSetIsServerHandle.Update;
begin
  SetToFace;
end;

{ TNetworkStatusClearItemHandle }

procedure TNetworkStatusClearItemHandle.SetToFace;
var
  NetworkStatusClearFace : TNetworkStatusClearFace;
begin
  NetworkStatusClearFace := TNetworkStatusClearFace.Create;
  NetworkStatusClearFace.AddChange;
end;

procedure TNetworkStatusClearItemHandle.Update;
begin
  SetToFace;
end;

{ MyNetworkStatusApi }

class procedure MyNetworkStatusApi.ConnToPcConnections( PcSocketInfo : string );
var
  MyPcStatusNetworkModeSetFace : TMyPcStatusNetworkModeSetFace;
begin
  MyPcStatusNetworkModeSetFace := TMyPcStatusNetworkModeSetFace.Create( MyNetworkModeShow_ConnToPc );
  MyPcStatusNetworkModeSetFace.SetDetailShow( PcSocketInfo );
  MyPcStatusNetworkModeSetFace.AddChange;
end;

class procedure MyNetworkStatusApi.GroupConnections( GroupName : string );
var
  MyPcStatusNetworkModeSetFace : TMyPcStatusNetworkModeSetFace;
begin
  MyPcStatusNetworkModeSetFace := TMyPcStatusNetworkModeSetFace.Create( MyNetworkModeShow_Group );
  MyPcStatusNetworkModeSetFace.SetDetailShow( GroupName );
  MyPcStatusNetworkModeSetFace.AddChange;
end;

class procedure MyNetworkStatusApi.LanConnections;
var
  MyPcStatusNetworkModeSetFace : TMyPcStatusNetworkModeSetFace;
begin
  MyPcStatusNetworkModeSetFace := TMyPcStatusNetworkModeSetFace.Create( MyNetworkModeShow_LAN );
  MyPcStatusNetworkModeSetFace.AddChange;
end;

class procedure MyNetworkStatusApi.SetBroadcastDisable;
var
  MyPcStatusBroadcastDisableFace : TMyPcStatusBroadcastDisableFace;
begin
  MyPcStatusBroadcastDisableFace := TMyPcStatusBroadcastDisableFace.Create;
  MyPcStatusBroadcastDisableFace.AddChange;
end;

class procedure MyNetworkStatusApi.SetBroadcastPort(BroadcastPort, ErrorStr: string);
var
  MyPcStatusBroadcastSetPortFace : TMyPcStatusBroadcastSetPortFace;
begin
  MyPcStatusBroadcastSetPortFace := TMyPcStatusBroadcastSetPortFace.Create( BroadcastPort );
  MyPcStatusBroadcastSetPortFace.SetErrorStr( ErrorStr );
  MyPcStatusBroadcastSetPortFace.AddChange;
end;


class procedure MyNetworkStatusApi.SetInternetSocket(InternetIp,
  InternetPort: string);
var
  MyPcStatusInternetSetSocketFace : TMyPcStatusInternetSetSocketFace;
begin
  MyPcStatusInternetSetSocketFace := TMyPcStatusInternetSetSocketFace.Create( InternetIp, InternetPort );
  MyPcStatusInternetSetSocketFace.AddChange;
end;

class procedure MyNetworkStatusApi.SetInternetSocketSuccess;
var
  MyPcStatusInternetSuccessFace : TMyPcStatusInternetSuccessFace;
begin
  MyPcStatusInternetSuccessFace := TMyPcStatusInternetSuccessFace.Create;
  MyPcStatusInternetSuccessFace.AddChange;
end;

class procedure MyNetworkStatusApi.SetIsExistUpnp(IsExist: Boolean;
  UpnpUrl: string);
var
  MyPcStatusUpnpServerFace : TMyPcStatusUpnpServerFace;
begin
  MyPcStatusUpnpServerFace := TMyPcStatusUpnpServerFace.Create( IsExist, UpnpUrl );
  MyPcStatusUpnpServerFace.AddChange;
end;

class procedure MyNetworkStatusApi.SetIsPortMapCompleted(IsCompleted: Boolean);
var
  MyPcStatusUpnpPortMapFace : TMyPcStatusUpnpPortMapFace;
begin
  MyPcStatusUpnpPortMapFace := TMyPcStatusUpnpPortMapFace.Create( IsCompleted );
  MyPcStatusUpnpPortMapFace.AddChange;
end;

class procedure MyNetworkStatusApi.SetLanSocket(LanIp, LanPort: string);
var
  MyPcStatusLanSetSocketFace : TMyPcStatusLanSetSocketFace;
begin
  MyPcStatusLanSetSocketFace := TMyPcStatusLanSetSocketFace.Create( LanIp, LanPort );
  MyPcStatusLanSetSocketFace.AddChange;
end;

class procedure MyNetworkStatusApi.SetLanSocketSuccess;
var
  MyPcStatusLanSuccessFace : TMyPcStatusLanSuccessFace;
begin
  MyPcStatusLanSuccessFace := TMyPcStatusLanSuccessFace.Create;
  MyPcStatusLanSuccessFace.AddChange;
end;

{ NetworkErrorStatusApi }

class procedure NetworkErrorStatusApi.HideError;
var
  PlNetworkConnHideInfo : TPlNetworkConnHideInfo;
begin
  PlNetworkConnHideInfo := TPlNetworkConnHideInfo.Create;
  PlNetworkConnHideInfo.AddChange;
end;

class procedure NetworkErrorStatusApi.HideNoPcError;
var
  PlNetworkNoPcErrorHindeInfo : TPlNetworkNoPcErrorHindeInfo;
begin
  PlNetworkNoPcErrorHindeInfo := TPlNetworkNoPcErrorHindeInfo.Create;
  PlNetworkNoPcErrorHindeInfo.AddChange;
end;

class procedure NetworkErrorStatusApi.ShowCannotConn( Domain, Port : string );
var
  PlNetworkNotConnShowInfo : TPlNetworkConnPcError;
begin
  PlNetworkNotConnShowInfo := TPlNetworkConnPcError.Create;
  PlNetworkNotConnShowInfo.SetConnPcInfo( Domain, Port );
  PlNetworkNotConnShowInfo.AddChange;
end;

class procedure NetworkErrorStatusApi.ShowConnAgainRemain(
  RemainSecond: Integer);
var
  PlNetworkConnRemainInfo : TPlNetworkConnRemainInfo;
begin
  PlNetworkConnRemainInfo := TPlNetworkConnRemainInfo.Create( RemainSecond );
  PlNetworkConnRemainInfo.AddChange;
end;

class procedure NetworkErrorStatusApi.ShowGroupNotExist;
var
  PlNetworkGroupNotExist : TPlNetworkGroupNotExist;
begin
  PlNetworkGroupNotExist := TPlNetworkGroupNotExist.Create;
  PlNetworkGroupNotExist.SetGroupName( GroupName );
  PlNetworkGroupNotExist.AddChange;
end;

class procedure NetworkErrorStatusApi.ShowGroupPasswordError(GroupName: string);
var
  PlNetworkGroupPasswordError : TPlNetworkGroupPasswordError;
begin
  PlNetworkGroupPasswordError := TPlNetworkGroupPasswordError.Create;
  PlNetworkGroupPasswordError.SetGroupName( GroupName );
  PlNetworkGroupPasswordError.AddChange;
end;

class procedure NetworkErrorStatusApi.ShowIpError(Domain, Port: string);
var
  PlNetworkConnPcIpError : TPlNetworkConnPcIpError;
begin
  PlNetworkConnPcIpError := TPlNetworkConnPcIpError.Create;
  PlNetworkConnPcIpError.SetConnPcInfo( Domain, Port );
  PlNetworkConnPcIpError.AddChange;
end;

class procedure NetworkErrorStatusApi.ShowExistOldEdition(Ip: string;
  IsNewEdition : Boolean);
var
  PlNetworkPcExistNewEditionInfo : TPlNetworkPcExistNewEditionInfo;
  PlNetworkPcExistOldEditionInfo : TPlNetworkPcExistOldEditionInfo;
  PcName : string;
begin
    // 出现了新版本，显示升级提示
  if IsNewEdition then
  begin
    PlNetworkPcExistNewEditionInfo := TPlNetworkPcExistNewEditionInfo.Create;
    PlNetworkPcExistNewEditionInfo.AddChange;
    Exit;
  end;

    // 出现了旧版本，显示旧版Pc信息
  PlNetworkPcExistOldEditionInfo := TPlNetworkPcExistOldEditionInfo.Create;
  PlNetworkPcExistOldEditionInfo.AddChange;

    // 添加旧版Pc
  PcName := MyNetPcInfoReadUtil.ReadPcNameByIp( Ip );
  NetworkConnEditionErrorApi.AddItem( Ip, PcName );
end;

class procedure NetworkErrorStatusApi.ShowNoPc;
var
  PlNetworkNotPcShowInfo : TPlNetworkNotPcShowInfo;
begin
  PlNetworkNotPcShowInfo := TPlNetworkNotPcShowInfo.Create;
  PlNetworkNotPcShowInfo.AddChange;
end;

class procedure NetworkErrorStatusApi.ShowSecurityError( Domain, Port, ErrorType : string );
var
  PlNetworkConnPcSecurityNumberError : TPlNetworkConnPcSecurityNumberError;
begin
  PlNetworkConnPcSecurityNumberError := TPlNetworkConnPcSecurityNumberError.Create;
  PlNetworkConnPcSecurityNumberError.SetConnPcInfo( Domain, Port );
  PlNetworkConnPcSecurityNumberError.SetErrorType( ErrorType );
  PlNetworkConnPcSecurityNumberError.AddChange;
end;

{ TNetPcBeMasterHandle }

procedure TNetPcBeServerHandle.SetToInfo;
var
  NetPcServerInfo : TNetPcServerInfo;
begin
  NetPcServerInfo := TNetPcServerInfo.Create( PcID );
  NetPcServerInfo.Update;
  NetPcServerInfo.Free;
end;

procedure TNetPcBeServerHandle.SetToNetworkStatus;
begin
  NetworkStatusApi.SetIsServer( PcID, True );
end;

procedure TNetPcBeServerHandle.Update;
begin
  SetToInfo;
  SetToNetworkStatus;
end;

{ TNetPcSetCanConnectToHandle }

procedure TNetPcSetCanConnectToHandle.SetCanConnectTo(_CanConnectTo: Boolean);
begin
  CanConnectTo := _CanConnectTo;
end;

procedure TNetPcSetCanConnectToHandle.SetToInfo;
var
  NetPcSetCanConnectToInfo : TNetPcSetCanConnectToInfo;
begin
  NetPcSetCanConnectToInfo := TNetPcSetCanConnectToInfo.Create( PcID );
  NetPcSetCanConnectToInfo.SetCanConnectTo( CanConnectTo );
  NetPcSetCanConnectToInfo.Update;
  NetPcSetCanConnectToInfo.Free;
end;

procedure TNetPcSetCanConnectToHandle.Update;
begin
  SetToInfo;
end;

{ TNetPcSetCanConnectFromHandle }

procedure TNetPcSetCanConnectFromHandle.SetCanConnectFrom(_CanConnectFrom: Boolean);
begin
  CanConnectFrom := _CanConnectFrom;
end;

procedure TNetPcSetCanConnectFromHandle.SetToInfo;
var
  NetPcSetCanConnectFromInfo : TNetPcSetCanConnectFromInfo;
begin
  NetPcSetCanConnectFromInfo := TNetPcSetCanConnectFromInfo.Create( PcID );
  NetPcSetCanConnectFromInfo.SetCanConnectFrom( CanConnectFrom );
  NetPcSetCanConnectFromInfo.Update;
  NetPcSetCanConnectFromInfo.Free;
end;

procedure TNetPcSetCanConnectFromHandle.Update;
begin
  SetToInfo;
end;

class procedure NetworkPcApi.SetCanConnectFrom(PcID: string;
  CanConnectFrom: Boolean);
var
  NetPcSetCanConnectFromHandle : TNetPcSetCanConnectFromHandle;
begin
  NetPcSetCanConnectFromHandle := TNetPcSetCanConnectFromHandle.Create( PcID );
  NetPcSetCanConnectFromHandle.SetCanConnectFrom( CanConnectFrom );
  NetPcSetCanConnectFromHandle.Update;
  NetPcSetCanConnectFromHandle.Free;
end;

class procedure NetworkPcApi.SetCanConnectTo(PcID: string;
  CanConnectTo: Boolean);
var
  NetPcSetCanConnectToHandle : TNetPcSetCanConnectToHandle;
begin
  NetPcSetCanConnectToHandle := TNetPcSetCanConnectToHandle.Create( PcID );
  NetPcSetCanConnectToHandle.SetCanConnectTo( CanConnectTo );
  NetPcSetCanConnectToHandle.Update;
  NetPcSetCanConnectToHandle.Free;
end;

{ NetworkConnEditionErrorApi }

class procedure NetworkConnEditionErrorApi.AddItem(Ip, PcName: string);
var
  ConnEditionAddFace : TConnEditionAddFace;
begin
  ConnEditionAddFace := TConnEditionAddFace.Create( Ip );
  ConnEditionAddFace.SetPcName( PcName );
  ConnEditionAddFace.AddChange;
end;

class procedure NetworkConnEditionErrorApi.ClearItem;
var
  ConnEditionClearFace : TConnEditionClearFace;
begin
  ConnEditionClearFace := TConnEditionClearFace.Create;
  ConnEditionClearFace.AddChange;
end;

class procedure NetworkConnEditionErrorApi.RemoveItem(Ip: string);
var
  ConnEditionRemoveFace : TConnEditionRemoveFace;
begin
  ConnEditionRemoveFace := TConnEditionRemoveFace.Create( Ip );
  ConnEditionRemoveFace.AddChange;
end;


{ TMyPcInfoSetTempLanIpHandle }

constructor TMyPcInfoSetTempLanIpHandle.Create(_LanIp: string);
begin
  LanIp := _LanIp;
end;

procedure TMyPcInfoSetTempLanIpHandle.SetToFace;
var
  MyPcInfoSetLanIpFace : TMyPcInfoSetLanIpFace;
begin
  MyPcInfoSetLanIpFace := TMyPcInfoSetLanIpFace.Create( LanIp );
  MyPcInfoSetLanIpFace.AddChange;
end;

procedure TMyPcInfoSetTempLanIpHandle.SetToInfo;
begin
  PcInfo.LanIp := LanIp;
end;

procedure TMyPcInfoSetTempLanIpHandle.Update;
begin
  SetToInfo;
  SetToFace;
end;

constructor TAccountWriteHandle.Create( _AccountName : string );
begin
  AccountName := _AccountName;
end;

{ TAccountReadHandle }

procedure TAccountReadHandle.AddToFace;
var
  AccountAddFace : TAccountAddFace;
begin
  AccountAddFace := TAccountAddFace.Create( AccountName );
  AccountAddFace.AddChange;
end;

procedure TAccountReadHandle.AddToInfo;
var
  AccountAddInfo : TAccountAddInfo;
begin
  AccountAddInfo := TAccountAddInfo.Create( AccountName );
  AccountAddInfo.SetPassword( Password );
  AccountAddInfo.Update;
  AccountAddInfo.Free;
end;

procedure TAccountReadHandle.SetPassword(_Password: string);
begin
  Password := _Password;
end;

procedure TAccountReadHandle.Update;
begin
  AddToInfo;
  AddToFace;
end;

{ TAccountAddHandle }

procedure TAccountAddHandle.AddToXml;
var
  AccountAddXml : TAccountAddXml;
begin
  AccountAddXml := TAccountAddXml.Create( AccountName );
  AccountAddXml.SetPassword( Password );
  AccountAddXml.AddChange;
end;

procedure TAccountAddHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TAccountRemoveHandle }

procedure TAccountRemoveHandle.RemoveFromFace;
var
  AccountRemoveFace : TAccountRemoveFace;
begin
  AccountRemoveFace := TAccountRemoveFace.Create( AccountName );
  AccountRemoveFace.AddChange;
end;

procedure TAccountRemoveHandle.RemoveFromInfo;
var
  AccountRemoveInfo : TAccountRemoveInfo;
begin
  AccountRemoveInfo := TAccountRemoveInfo.Create( AccountName );
  AccountRemoveInfo.Update;
  AccountRemoveInfo.Free;
end;

procedure TAccountRemoveHandle.RemoveFromXml;
var
  AccountRemoveXml : TAccountRemoveXml;
begin
  AccountRemoveXml := TAccountRemoveXml.Create( AccountName );
  AccountRemoveXml.AddChange;
end;

procedure TAccountRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromFace;
  RemoveFromXml;
end;



procedure TBackupListWriteHandle.SetBackupPath( _BackupPath : string );
begin
  BackupPath := _BackupPath;
end;


{ TBackupListReadHandle }

procedure TBackupListReadHandle.AddToFace;
var
  BackupListAddFace : TBackupListAddFace;
begin
  BackupListAddFace := TBackupListAddFace.Create( AccountName );
  BackupListAddFace.SetBackupPath( BackupPath );
  BackupListAddFace.AddChange;
end;

procedure TBackupListReadHandle.AddToInfo;
var
  BackupListAddInfo : TBackupListAddInfo;
begin
  BackupListAddInfo := TBackupListAddInfo.Create( AccountName );
  BackupListAddInfo.SetBackupPath( BackupPath );
  BackupListAddInfo.Update;
  BackupListAddInfo.Free;
end;

procedure TBackupListReadHandle.Update;
begin
  AddToFace;
  AddToInfo;
end;

{ TBackupListAddHandle }

procedure TBackupListAddHandle.AddToXml;
var
  BackupListAddXml : TBackupListAddXml;
begin
  BackupListAddXml := TBackupListAddXml.Create( AccountName );
  BackupListAddXml.SetBackupPath( BackupPath );
  BackupListAddXml.AddChange;
end;

procedure TBackupListAddHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TBackupListRemoveHandle }

procedure TBackupListRemoveHandle.RemoveFromFace;
var
  BackupListRemoveFace : TBackupListRemoveFace;
begin
  BackupListRemoveFace := TBackupListRemoveFace.Create( AccountName );
  BackupListRemoveFace.SetBackupPath( BackupPath );
  BackupListRemoveFace.AddChange;
end;

procedure TBackupListRemoveHandle.RemoveFromInfo;
var
  BackupListRemoveInfo : TBackupListRemoveInfo;
begin
  BackupListRemoveInfo := TBackupListRemoveInfo.Create( AccountName );
  BackupListRemoveInfo.SetBackupPath( BackupPath );
  BackupListRemoveInfo.Update;
  BackupListRemoveInfo.Free;
end;


procedure TBackupListRemoveHandle.RemoveFromXml;
var
  BackupListRemoveXml : TBackupListRemoveXml;
begin
  BackupListRemoveXml := TBackupListRemoveXml.Create( AccountName );
  BackupListRemoveXml.SetBackupPath( BackupPath );
  BackupListRemoveXml.AddChange;
end;

procedure TBackupListRemoveHandle.Update;
begin
  RemoveFromFace;
  RemoveFromInfo;
  RemoveFromXml;
end;

{ NetworkAccountApi }

class procedure NetworkAccountApi.AddAccount(Account, Password: string);
var
  AccountAddHandle : TAccountAddHandle;
begin
  AccountAddHandle := TAccountAddHandle.Create( Account );
  AccountAddHandle.SetPassword( Password );
  AccountAddHandle.Update;
  AccountAddHandle.Free;
end;



class procedure NetworkAccountApi.AddAccountPath(Account, BackupPath: string);
var
  BackupListAddHandle : TBackupListAddHandle;
begin
  BackupListAddHandle := TBackupListAddHandle.Create( Account );
  BackupListAddHandle.SetBackupPath( BackupPath );
  BackupListAddHandle.Update;
  BackupListAddHandle.Free;
end;



class procedure NetworkAccountApi.RemoveAccount(Account: string);
var
  AccountRemoveHandle : TAccountRemoveHandle;
begin
  AccountRemoveHandle := TAccountRemoveHandle.Create( Account );
  AccountRemoveHandle.Update;
  AccountRemoveHandle.Free;
end;

class procedure NetworkAccountApi.RemoveAccountPath(Account,
  BackupPath: string);
var
  BackupListRemoveHandle : TBackupListRemoveHandle;
begin
  BackupListRemoveHandle := TBackupListRemoveHandle.Create( Account );
  BackupListRemoveHandle.SetBackupPath( BackupPath );
  BackupListRemoveHandle.Update;
  BackupListRemoveHandle.Free;
end;


class procedure NetworkAccountApi.SetAccountIsOnline(Account: string;
  IsOnline: Boolean);
var
  AccountSetIsOnlineFace : TAccountSetIsOnlineFace;
begin
  AccountSetIsOnlineFace := TAccountSetIsOnlineFace.Create( Account );
  AccountSetIsOnlineFace.SetIsOnline( IsOnline );
  AccountSetIsOnlineFace.AddChange;
end;

class procedure NetworkAccountApi.SetIpInfo(LanIp, LanPort, InternetIp, InternetPort : string);
var
  AccountServerSetIpFace : TAccountServerSetIpFace;
begin
  AccountServerSetIpFace := TAccountServerSetIpFace.Create( LanIp, InternetIp );
  AccountServerSetIpFace.SetPortInfo( LanPort, InternetPort );
  AccountServerSetIpFace.AddChange;
end;

end.
