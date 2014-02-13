unit UServerNetwork;

interface

uses UServerNet, UMsgUtil, UNetUtil, UNetworkUtil, UServerData;

type

{$Region ' Server 数据访问 ' }

    // 登录结果
  TLoginResult = ( lrNotExist, lrPasswordError, lrSuccess );

    // 服务器帐号 访问器
  TServerAccountAccesser = class
  public
    ServerAccountData : TServerAccountData;
  public
    constructor Create( _ServerAccountData : TServerAccountData );
  public
    function SignupAccount( AccountName, Password : string ): Boolean;  // 帐号已存在，返回 false
    function LoginAccount( AccountName, Password : string ): TLoginResult; // 登录帐号
    procedure LogoutAccount( AccountName : string ); // 注销帐号
  end;

    // 客户端帐号绑定 访问器
  TClientAccountBindAccesser = class
  public
    ClientAccountBindData : TClientAccountBindData;
  public
    constructor Create( _ClientAccountBindData : TClientAccountBindData );
  public        // 增删
    procedure AddClient( ClientID : Int64; Account : string );
    procedure RemoveClient( ClientID : Int64 );
  public        // 查找
    function ReadAccount( ClientID : Int64 ): string;
  end;

    // 服务器信息 访问器
  TServerInfoAccesser = class
  private
    ServerInfoData : TServerInfoData;
  public
    constructor Create( _ServerInfoData : TServerInfoData );
  public
    function ReadServerName : string;
  end;

{$EndRegion}

{$Region ' Server 网络访问 ' }

    // 服务器 Udp 网络 访问器
  TServerUdpNetAccesser = class
  public
    ServerUdpHandler : TServerUdpHandler;
  public
    constructor Create( _ServerUdpHandler : TServerUdpHandler );
  public
    procedure SendMsgTo( Ip, Port, Msg : string );
  end;

    // 服务器 Tcp 网络 访问器
  TServerTcpNetAccesser = class
  public
    ServerTcpHandler : TServerTcpHandler;
  public
    constructor Create( _ServerTcpHandler : TServerTcpHandler );
  public
    procedure SendMsg( ClientID : Int64; Msg : string );
  end;

{$EndRegion}

{$Region ' Udp 搜索网络 处理 ' }

    // 父类
  TServerUdpMsgRunner = class( TMsgRunner )
  private
    Ip, Port : string;
  public
    procedure Update;override;
  end;

    // 搜索请求
  TSearchServerRequestMsgRunner = class( TServerUdpMsgRunner )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' Tcp 帐号信息 处理 ' }

    // 父类
  TServerTcpMsgRunner = class( TMsgRunner )
  public
    ClientID : Int64;
  public
    procedure Update;override;
  protected
    procedure SendMsg( Msg : string );
  end;

    // 注册父类
  TAcccountSigupMsgBaseRunner = class( TServerTcpMsgRunner )
  public
    AccountName, Password : string;
  public
    procedure Update;override;
  end;

    // 注册帐号
  TAccountSignupMsgRunner = class( TAcccountSigupMsgBaseRunner )
  public
    procedure Update;override;
  private
    procedure SendSuccessMsg;  // 发送成功
    procedure SendAccountExistMsg;  // 发送帐号已存在
  end;

    // 登录帐号
  TAccountLoginMsgRunner = class( TAcccountSigupMsgBaseRunner )
  public
    procedure Update;override;
  private
    procedure SendSuccessMsg;  // 成功
    procedure SendAccountNotExistMsg;  // 帐号存在
    procedure SendPasswordErrorMsg;  // 密码错误
  end;

    // 注销帐号
  TAccountLogoutMsgRunner = class( TServerTcpMsgRunner )
  public
    procedure Update;override;
  private
    procedure SendSuccessMsg; // 成功
  end;

{$EndRegion}

{$Region ' 命令处理器 ' }

    // Udp 命令 运行信息
  TUdpRunnerInfo = class( TRunnerInfo )
  public
    Ip, Port : string;
  public
    constructor Create( _Ip, _Port : string );
  end;

    // 服务器 Udp 命令处理器
  TServerUdpMsgHandler = class( TMsgHandler )
  public
    procedure IniRunnerClass;override;
  public
    procedure RevMsg( Ip, Port, Msg : string );
  end;

    // Tcp 命令 运行信息
  TTcpRunnerInfo = class( TRunnerInfo )
  public
    ClientID : Int64;
  public
    constructor Create( _ClientID : Int64 );
  end;

    // 服务器 Tcp 命令处理器
  TServerTcpMsgHandler = class( TMsgHandler )
  public
    procedure IniRunnerClass;override;
  public
    procedure RevMsg( ClientID : Int64; Msg : string );
  end;

{$EndRegion}

{$Region ' 命令生成器 ' }

    // Udp 网络搜索
  UdpSearchServerMsgCreater = class
  public
    class function ReadResopnse( ServerName, ServerIp : string ): string;
  end;

    // Tcp 帐号
  TcpAccountMsgCreater = class
  public             // 注册
    class function ReadSignupSuccess : string;
    class function ReadSignupExist : string;
  public             // 登录
    class function ReadLoginSuccess : string;
    class function ReadLoginNotExist : string;
    class function ReadLoginPasswordError : string;
  public             // 注销
    class function ReadLogoutSuccess : string;
  end;

{$EndRegion}

    // 服务器网络 处理器
  TServerNetworkHandler = class
  private      // 命令收发器
    ServerUdpHandler : TServerUdpHandler;
    ServerTcpHandler : TServerTcpHandler;
  private      // 命令处理器
    ServerUdpMsgHandler : TServerUdpMsgHandler;
    ServerTcpMsgHandler : TServerTcpMsgHandler;
  private      // 数据结构
    ServerInfoData : TServerInfoData;
    ServerAccountData : TServerAccountData;
    ClientAccountBindData : TClientAccountBindData;
  public
    constructor Create;
    procedure Start;
    procedure Stop;
    destructor Destroy; override;
  end;

var
  ServerNetworkHandler : TServerNetworkHandler; // 总控制器

  ServerUdpNetAccesser : TServerUdpNetAccesser; // Udp 网络访问器
  ServerTcpNetAccesser : TServerTcpNetAccesser; // Tcp 网络访问器

  ServerInfoAccesser : TServerInfoAccesser;  // 服务器信息 访问器
  ServerAccountAccesser : TServerAccountAccesser; // 帐号数据 访问器
  ClientAccountBindAccesser : TClientAccountBindAccesser; // 客户端帐号绑定 访问器

implementation

{ TServerNetwork }

constructor TServerNetworkHandler.Create;
begin
    // 数据库
  ServerInfoData := TServerInfoData.Create;
  ServerAccountData := TServerAccountData.Create;
  ClientAccountBindData := TClientAccountBindData.Create;

    // 数据 访问器
  ServerInfoAccesser := TServerInfoAccesser.Create( ServerInfoData );
  ServerAccountAccesser := TServerAccountAccesser.Create( ServerAccountData );
  ClientAccountBindAccesser := TClientAccountBindAccesser.Create( ClientAccountBindData );

    // Tcp / Udp 数据接收器
  ServerUdpHandler := TServerUdpHandler.Create( ServerInfoData.UdpPort );
  ServerTcpHandler := TServerTcpHandler.Create( ServerInfoData.TcpPort );

    // 网络 访问器
  ServerUdpNetAccesser := TServerUdpNetAccesser.Create( ServerUdpHandler );
  ServerTcpNetAccesser := TServerTcpNetAccesser.Create( ServerTcpHandler );

    // Udp 数据处理器
  ServerUdpMsgHandler := TServerUdpMsgHandler.Create;
  ServerUdpHandler.OnUdpMsg := ServerUdpMsgHandler.RevMsg;

    // Tcp 数据处理器
  ServerTcpMsgHandler := TServerTcpMsgHandler.Create;
  ServerTcpHandler.OnTcpMsg := ServerTcpMsgHandler.RevMsg;
end;

destructor TServerNetworkHandler.Destroy;
begin
  ServerUdpMsgHandler.Free;
  ServerTcpMsgHandler.Free;

  ServerTcpNetAccesser.Free;
  ServerUdpNetAccesser.Free;

  ServerTcpHandler.Free;
  ServerUdpHandler.Free;

  ServerInfoAccesser.Free;
  ClientAccountBindAccesser.Free;
  ServerAccountAccesser.Free;

  ClientAccountBindData.Free;
  ServerAccountData.Free;
  ServerInfoData.Free;
  inherited;
end;

procedure TServerNetworkHandler.Start;
begin
  ServerUdpHandler.Start;
  ServerTcpHandler.Start;
end;

procedure TServerNetworkHandler.Stop;
begin
  ServerUdpHandler.Stop;
  ServerTcpHandler.Stop;
end;

{ TServerMsgHandler }

procedure TServerUdpMsgHandler.IniRunnerClass;
begin
  AddRunner( TSearchServerRequestMsg, TSearchServerRequestMsgRunner );
end;

{ TSearchServerRequestMsgRunner }

procedure TSearchServerRequestMsgRunner.Update;
var
  ServerIp, ServerName, MsgStr : string;
begin
  inherited;

    // 服务器信息
  ServerIp := MyIpUtil.ReadSameLanIp( Ip );
  ServerName := ServerInfoAccesser.ReadServerName;

    // 返回 服务器信息
  MsgStr := UdpSearchServerMsgCreater.ReadResopnse( ServerName, ServerIp );

    // 发送
  ServerUdpNetAccesser.SendMsgTo( Ip, Port, MsgStr );
end;

{ TServerTcpMsgRunner }

procedure TServerUdpMsgHandler.RevMsg(Ip, Port, Msg: string);
var
  UdpRunnerInfo : TUdpRunnerInfo;
begin
  UdpRunnerInfo := TUdpRunnerInfo.Create( Ip, Port );
  HandleMsg( Msg, UdpRunnerInfo );
  UdpRunnerInfo.Free;
end;

{ TServerTcpMsgRunner }

procedure TServerTcpMsgRunner.SendMsg(Msg: string);
begin
  ServerTcpNetAccesser.SendMsg( ClientID, Msg );
end;

procedure TServerTcpMsgRunner.Update;
var
  TcpRunnerInfo : TTcpRunnerInfo;
begin
  inherited;

  TcpRunnerInfo := RunnerInfo as TTcpRunnerInfo;
  ClientID := TcpRunnerInfo.ClientID;
end;

{ TServerTcpMsgHandler }

procedure TServerTcpMsgHandler.IniRunnerClass;
begin
  AddRunner( TAccountSignupMsg, TAccountSignupMsgRunner );
  AddRunner( TAccountLoginMsg, TAccountLoginMsgRunner );
  AddRunner( TAccountLogoutMsg, TAccountLogoutMsgRunner );
end;

procedure TServerTcpMsgHandler.RevMsg(ClientID : Int64; Msg: string);
var
  TcpRunnerInfo : TTcpRunnerInfo;
begin
  TcpRunnerInfo := TTcpRunnerInfo.Create( ClientID );
  HandleMsg( Msg, TcpRunnerInfo );
  TcpRunnerInfo.Free;
end;

{ TUdpRunnerInfo }

constructor TUdpRunnerInfo.Create(_Ip, _Port: string);
begin
  Ip := _Ip;
  Port := _Port;
end;

{ TTcpRunnerInfo }

constructor TTcpRunnerInfo.Create(_ClientID: Int64);
begin
  ClientID := _ClientID;
end;

{ TServerUdpMsgRunner }

procedure TServerUdpMsgRunner.Update;
var
  UdpRunnerInfo : TUdpRunnerInfo;
begin
  inherited;

  UdpRunnerInfo := RunnerInfo as TUdpRunnerInfo;
  Ip := UdpRunnerInfo.Ip;
  Port := UdpRunnerInfo.Port;
end;

{ TAccountSignupMsgRunner }

procedure TAccountSignupMsgRunner.SendAccountExistMsg;
begin
  SendMsg( TcpAccountMsgCreater.ReadSignupExist );
end;

procedure TAccountSignupMsgRunner.SendSuccessMsg;
begin
  SendMsg( TcpAccountMsgCreater.ReadSignupSuccess );
end;

procedure TAccountSignupMsgRunner.Update;
begin
  inherited;

    // 注册用户 是否成功
  if ServerAccountAccesser.SignupAccount( AccountName, Password ) then
    SendSuccessMsg
  else
    SendAccountExistMsg;
end;

{ TServerAccountAccesser }

constructor TServerAccountAccesser.Create(
  _ServerAccountData: TServerAccountData);
begin
  ServerAccountData := _ServerAccountData;
end;

function TServerAccountAccesser.LoginAccount(AccountName,
  Password: string): TLogInResult;
begin
  if not ServerAccountData.ReadAccountExist( AccountName ) then
    Result := lrNotExist
  else
  if ServerAccountData.ReadPassword( AccountName ) <> AccountName then
    Result := lrPasswordError
  else
  begin
    ServerAccountData.SetStatus( AccountName, AccountStatus_Online );
    Result := lrSuccess;
  end;
end;

procedure TServerAccountAccesser.LogoutAccount(AccountName: string);
begin
  ServerAccountData.SetStatus( AccountName, AccountStatus_Offline );
end;

function TServerAccountAccesser.SignupAccount(AccountName, Password: string): Boolean;
begin
  Result := not ServerAccountData.ReadAccountExist( AccountName );
  if Result then
    ServerAccountData.AddAccount( AccountName, Password );
end;

{ TServerTcpNetAccesser }

constructor TServerTcpNetAccesser.Create(_ServerTcpHandler: TServerTcpHandler);
begin
  ServerTcpHandler := _ServerTcpHandler;
end;

procedure TServerTcpNetAccesser.SendMsg(ClientID : Int64; Msg: string);
begin
  ServerTcpHandler.SendMsg( ClientID, Msg );
end;

{ TServerUdpNetAccesser }

constructor TServerUdpNetAccesser.Create(_ServerUdpHandler: TServerUdpHandler);
begin
  ServerUdpHandler := _ServerUdpHandler;
end;

procedure TServerUdpNetAccesser.SendMsgTo(Ip, Port, Msg: string);
begin
  ServerUdpHandler.SendMsgTo( Ip, Port, Msg );
end;

{ UdpMsgCreater }

class function UdpSearchServerMsgCreater.ReadResopnse(ServerName,
  ServerIp: string): string;
var
  SearchServerResponseMsg : TSearchServerResponseMsg;
begin
    // 返回 服务器信息
  SearchServerResponseMsg := TSearchServerResponseMsg.Create;
  SearchServerResponseMsg.SetServerInfo( ServerName, ServerIp );
  Result := SearchServerResponseMsg.getJsonStr;
  SearchServerResponseMsg.Free;
end;

{ TcpAccountMsgCreater }

class function TcpAccountMsgCreater.ReadLoginNotExist: string;
var
  AccountLoginNotExistMsg : TAccountLoginNotExistMsg;
begin
  AccountLoginNotExistMsg := TAccountLoginNotExistMsg.Create;
  Result := AccountLoginNotExistMsg.getJsonStr;
  AccountLoginNotExistMsg.Free;
end;

class function TcpAccountMsgCreater.ReadLoginPasswordError: string;
var
  AccountLoginPasswordErrorMsg : TAccountLoginPasswordErrorMsg;
begin
  AccountLoginPasswordErrorMsg := TAccountLoginPasswordErrorMsg.Create;
  Result := AccountLoginPasswordErrorMsg.getJsonStr;
  AccountLoginPasswordErrorMsg.Free;
end;

class function TcpAccountMsgCreater.ReadLoginSuccess: string;
var
  AccountLoginSuccessMsg : TAccountLoginSuccessMsg;
begin
  AccountLoginSuccessMsg := TAccountLoginSuccessMsg.Create;
  Result := AccountLoginSuccessMsg.getJsonStr;
  AccountLoginSuccessMsg.Free;
end;

class function TcpAccountMsgCreater.ReadLogoutSuccess: string;
var
  AccountLogoutSuccessMsg : TAccountLogoutSuccessMsg;
begin
  AccountLogoutSuccessMsg := TAccountLogoutSuccessMsg.Create;
  Result := AccountLogoutSuccessMsg.getJsonStr;
  AccountLogoutSuccessMsg.Free;
end;

class function TcpAccountMsgCreater.ReadSignupExist: string;
var
  AccountSignupExistMsg : TAccountSignupExistMsg;
begin
  AccountSignupExistMsg := TAccountSignupExistMsg.Create;
  Result := AccountSignupExistMsg.getJsonStr;
  AccountSignupExistMsg.Free;
end;

class function TcpAccountMsgCreater.ReadSignupSuccess: string;
var
  AccountSignupSuccessMsg : TAccountSignupSuccessMsg;
begin
  AccountSignupSuccessMsg := TAccountSignupSuccessMsg.Create;
  Result := AccountSignupSuccessMsg.getJsonStr;
  AccountSignupSuccessMsg.Free;
end;

{ TAcccountSigupMsgBaseRunner }

procedure TAcccountSigupMsgBaseRunner.Update;
var
  AccountMsgBase : TAccountMsgBase;
begin
  inherited;

  AccountMsgBase := MsgInfo as TAccountMsgBase;
  AccountName := AccountMsgBase.AccountName;
  Password := AccountMsgBase.Password;
end;

{ TAccountLoginMsgRunner }

procedure TAccountLoginMsgRunner.SendAccountNotExistMsg;
begin
  SendMsg( TcpAccountMsgCreater.ReadLoginNotExist );
end;

procedure TAccountLoginMsgRunner.SendPasswordErrorMsg;
begin
  SendMsg( TcpAccountMsgCreater.ReadLoginPasswordError );
end;

procedure TAccountLoginMsgRunner.SendSuccessMsg;
begin
  SendMsg( TcpAccountMsgCreater.ReadLoginSuccess );
end;

procedure TAccountLoginMsgRunner.Update;
var
  lr : TLoginResult;
begin
  inherited;

    // 登录
  lr := ServerAccountAccesser.LoginAccount( AccountName, Password );

    // 登录结果
  case lr of
    lrSuccess :
    begin
      ClientAccountBindAccesser.AddClient( ClientID, AccountName );  // 登录成功，绑定客户端
      SendSuccessMsg;
    end;
    lrNotExist : SendAccountNotExistMsg;
    lrPasswordError : SendPasswordErrorMsg;
  end;
end;

{ TAccountLogoutMsgRunner }

procedure TAccountLogoutMsgRunner.SendSuccessMsg;
begin
  SendMsg( TcpAccountMsgCreater.ReadLogoutSuccess );
end;

procedure TAccountLogoutMsgRunner.Update;
var
  Account : string;
begin
  inherited;

    // 读取帐号信息
  Account := ClientAccountBindAccesser.ReadAccount( ClientID );
  ClientAccountBindAccesser.RemoveClient( ClientID ); // 删除绑定

    // 记录登出
  ServerAccountAccesser.LogoutAccount( Account );

    // 发送成功登出
  SendSuccessMsg;
end;

{ TClientAccountBindAccesser }

procedure TClientAccountBindAccesser.AddClient(ClientID: Int64;
  Account: string);
begin
  ClientAccountBindData.AddClient( ClientID, Account );
end;

constructor TClientAccountBindAccesser.Create(
  _ClientAccountBindData: TClientAccountBindData);
begin
  ClientAccountBindData := _ClientAccountBindData;
end;

function TClientAccountBindAccesser.ReadAccount(ClientID: Int64): string;
begin
  Result := ClientAccountBindData.ReadAccount( ClientID );
end;

procedure TClientAccountBindAccesser.RemoveClient(ClientID: Int64);
begin
  ClientAccountBindData.RemoveClient( ClientID );
end;

{ TServerInfoAccesser }

constructor TServerInfoAccesser.Create(_ServerInfoData: TServerInfoData);
begin
  ServerInfoData := _ServerInfoData;
end;

function TServerInfoAccesser.ReadServerName: string;
begin
  Result := ServerInfoData.ServerName;
end;

end.
