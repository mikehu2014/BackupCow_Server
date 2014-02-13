unit UServerNetwork;

interface

uses UServerNet, UMsgUtil, UNetUtil, UNetworkUtil, UServerData;

type

{$Region ' Server ���ݷ��� ' }

    // ��¼���
  TLoginResult = ( lrNotExist, lrPasswordError, lrSuccess );

    // �������ʺ� ������
  TServerAccountAccesser = class
  public
    ServerAccountData : TServerAccountData;
  public
    constructor Create( _ServerAccountData : TServerAccountData );
  public
    function SignupAccount( AccountName, Password : string ): Boolean;  // �ʺ��Ѵ��ڣ����� false
    function LoginAccount( AccountName, Password : string ): TLoginResult; // ��¼�ʺ�
    procedure LogoutAccount( AccountName : string ); // ע���ʺ�
  end;

    // �ͻ����ʺŰ� ������
  TClientAccountBindAccesser = class
  public
    ClientAccountBindData : TClientAccountBindData;
  public
    constructor Create( _ClientAccountBindData : TClientAccountBindData );
  public        // ��ɾ
    procedure AddClient( ClientID : Int64; Account : string );
    procedure RemoveClient( ClientID : Int64 );
  public        // ����
    function ReadAccount( ClientID : Int64 ): string;
  end;

    // ��������Ϣ ������
  TServerInfoAccesser = class
  private
    ServerInfoData : TServerInfoData;
  public
    constructor Create( _ServerInfoData : TServerInfoData );
  public
    function ReadServerName : string;
  end;

{$EndRegion}

{$Region ' Server ������� ' }

    // ������ Udp ���� ������
  TServerUdpNetAccesser = class
  public
    ServerUdpHandler : TServerUdpHandler;
  public
    constructor Create( _ServerUdpHandler : TServerUdpHandler );
  public
    procedure SendMsgTo( Ip, Port, Msg : string );
  end;

    // ������ Tcp ���� ������
  TServerTcpNetAccesser = class
  public
    ServerTcpHandler : TServerTcpHandler;
  public
    constructor Create( _ServerTcpHandler : TServerTcpHandler );
  public
    procedure SendMsg( ClientID : Int64; Msg : string );
  end;

{$EndRegion}

{$Region ' Udp �������� ���� ' }

    // ����
  TServerUdpMsgRunner = class( TMsgRunner )
  private
    Ip, Port : string;
  public
    procedure Update;override;
  end;

    // ��������
  TSearchServerRequestMsgRunner = class( TServerUdpMsgRunner )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' Tcp �ʺ���Ϣ ���� ' }

    // ����
  TServerTcpMsgRunner = class( TMsgRunner )
  public
    ClientID : Int64;
  public
    procedure Update;override;
  protected
    procedure SendMsg( Msg : string );
  end;

    // ע�Ḹ��
  TAcccountSigupMsgBaseRunner = class( TServerTcpMsgRunner )
  public
    AccountName, Password : string;
  public
    procedure Update;override;
  end;

    // ע���ʺ�
  TAccountSignupMsgRunner = class( TAcccountSigupMsgBaseRunner )
  public
    procedure Update;override;
  private
    procedure SendSuccessMsg;  // ���ͳɹ�
    procedure SendAccountExistMsg;  // �����ʺ��Ѵ���
  end;

    // ��¼�ʺ�
  TAccountLoginMsgRunner = class( TAcccountSigupMsgBaseRunner )
  public
    procedure Update;override;
  private
    procedure SendSuccessMsg;  // �ɹ�
    procedure SendAccountNotExistMsg;  // �ʺŴ���
    procedure SendPasswordErrorMsg;  // �������
  end;

    // ע���ʺ�
  TAccountLogoutMsgRunner = class( TServerTcpMsgRunner )
  public
    procedure Update;override;
  private
    procedure SendSuccessMsg; // �ɹ�
  end;

{$EndRegion}

{$Region ' ������� ' }

    // Udp ���� ������Ϣ
  TUdpRunnerInfo = class( TRunnerInfo )
  public
    Ip, Port : string;
  public
    constructor Create( _Ip, _Port : string );
  end;

    // ������ Udp �������
  TServerUdpMsgHandler = class( TMsgHandler )
  public
    procedure IniRunnerClass;override;
  public
    procedure RevMsg( Ip, Port, Msg : string );
  end;

    // Tcp ���� ������Ϣ
  TTcpRunnerInfo = class( TRunnerInfo )
  public
    ClientID : Int64;
  public
    constructor Create( _ClientID : Int64 );
  end;

    // ������ Tcp �������
  TServerTcpMsgHandler = class( TMsgHandler )
  public
    procedure IniRunnerClass;override;
  public
    procedure RevMsg( ClientID : Int64; Msg : string );
  end;

{$EndRegion}

{$Region ' ���������� ' }

    // Udp ��������
  UdpSearchServerMsgCreater = class
  public
    class function ReadResopnse( ServerName, ServerIp : string ): string;
  end;

    // Tcp �ʺ�
  TcpAccountMsgCreater = class
  public             // ע��
    class function ReadSignupSuccess : string;
    class function ReadSignupExist : string;
  public             // ��¼
    class function ReadLoginSuccess : string;
    class function ReadLoginNotExist : string;
    class function ReadLoginPasswordError : string;
  public             // ע��
    class function ReadLogoutSuccess : string;
  end;

{$EndRegion}

    // ���������� ������
  TServerNetworkHandler = class
  private      // �����շ���
    ServerUdpHandler : TServerUdpHandler;
    ServerTcpHandler : TServerTcpHandler;
  private      // �������
    ServerUdpMsgHandler : TServerUdpMsgHandler;
    ServerTcpMsgHandler : TServerTcpMsgHandler;
  private      // ���ݽṹ
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
  ServerNetworkHandler : TServerNetworkHandler; // �ܿ�����

  ServerUdpNetAccesser : TServerUdpNetAccesser; // Udp ���������
  ServerTcpNetAccesser : TServerTcpNetAccesser; // Tcp ���������

  ServerInfoAccesser : TServerInfoAccesser;  // ��������Ϣ ������
  ServerAccountAccesser : TServerAccountAccesser; // �ʺ����� ������
  ClientAccountBindAccesser : TClientAccountBindAccesser; // �ͻ����ʺŰ� ������

implementation

{ TServerNetwork }

constructor TServerNetworkHandler.Create;
begin
    // ���ݿ�
  ServerInfoData := TServerInfoData.Create;
  ServerAccountData := TServerAccountData.Create;
  ClientAccountBindData := TClientAccountBindData.Create;

    // ���� ������
  ServerInfoAccesser := TServerInfoAccesser.Create( ServerInfoData );
  ServerAccountAccesser := TServerAccountAccesser.Create( ServerAccountData );
  ClientAccountBindAccesser := TClientAccountBindAccesser.Create( ClientAccountBindData );

    // Tcp / Udp ���ݽ�����
  ServerUdpHandler := TServerUdpHandler.Create( ServerInfoData.UdpPort );
  ServerTcpHandler := TServerTcpHandler.Create( ServerInfoData.TcpPort );

    // ���� ������
  ServerUdpNetAccesser := TServerUdpNetAccesser.Create( ServerUdpHandler );
  ServerTcpNetAccesser := TServerTcpNetAccesser.Create( ServerTcpHandler );

    // Udp ���ݴ�����
  ServerUdpMsgHandler := TServerUdpMsgHandler.Create;
  ServerUdpHandler.OnUdpMsg := ServerUdpMsgHandler.RevMsg;

    // Tcp ���ݴ�����
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

    // ��������Ϣ
  ServerIp := MyIpUtil.ReadSameLanIp( Ip );
  ServerName := ServerInfoAccesser.ReadServerName;

    // ���� ��������Ϣ
  MsgStr := UdpSearchServerMsgCreater.ReadResopnse( ServerName, ServerIp );

    // ����
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

    // ע���û� �Ƿ�ɹ�
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
    // ���� ��������Ϣ
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

    // ��¼
  lr := ServerAccountAccesser.LoginAccount( AccountName, Password );

    // ��¼���
  case lr of
    lrSuccess :
    begin
      ClientAccountBindAccesser.AddClient( ClientID, AccountName );  // ��¼�ɹ����󶨿ͻ���
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

    // ��ȡ�ʺ���Ϣ
  Account := ClientAccountBindAccesser.ReadAccount( ClientID );
  ClientAccountBindAccesser.RemoveClient( ClientID ); // ɾ����

    // ��¼�ǳ�
  ServerAccountAccesser.LogoutAccount( Account );

    // ���ͳɹ��ǳ�
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
