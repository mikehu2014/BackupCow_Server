unit UNetworkUtil;

interface

uses UMsgUtil;

type

{$Region ' Udp 搜索网络 ' }

    // 搜索请求
  TSearchServerRequestMsg = class( TMsgInfo )
  end;

    // 返回搜索结果
  TSearchServerResponseMsg = class( TMsgInfo )
  public
    ServerName, ServerIp : string;
  public
    procedure SetServerInfo( _ServerName, _ServerIp : string );
  end;

{$EndRegion}

{$Region ' 帐号信息 请求 ' }

    // 父类
  TAccountMsgBase = class( TMsgInfo )
  public
    AccountName : string;
    Password : string;
  public
    procedure SetAccountInfo( _AccountName, _Password : string );
  end;

    // 注册帐号
  TAccountSignupMsg = class( TAccountMsgBase )
  end;

    // 登录帐号
  TAccountLoginMsg = class( TAccountMsgBase )
  end;

    // 注销帐号
  TAccountLogoutMsg = class( TMsgInfo )
  end;

{$EndRegion}

{$Region ' 帐号信息 返回 ' }

    // 注册返回 父类
  TAccountSingupResultMsg = class( TMsgInfo )
  end;

    // 注册成功
  TAccountSignupSuccessMsg = class( TAccountSingupResultMsg )
  end;

    // 注册帐号 已存在
  TAccountSignupExistMsg = class( TAccountSingupResultMsg )
  end;


    // 登录返回 父类
  TAccountLoginResultMsg = class( TMsgInfo )
  end;

    // 登录成功
  TAccountLoginSuccessMsg = class( TAccountLoginResultMsg )
  end;

    // 登录帐号不存在
  TAccountLoginNotExistMsg = class( TAccountLoginResultMsg )
  end;

    // 登录密码错误
  TAccountLoginPasswordErrorMsg = class( TAccountLoginResultMsg )
  end;


    // 注销返回 父类
  TAccountLogoutResultMsg = class( TMsgInfo )
  end;

    // 注销成功
  TAccountLogoutSuccessMsg = class( TAccountLogoutResultMsg )
  end;

{$EndRegion}

const
  ServerPort_Udp = 39595;
  ServerPort_Tcp = 38585;

implementation

{ TAccountMsgBase }

procedure TAccountMsgBase.SetAccountInfo(_AccountName, _Password: string);
begin
  AccountName := _AccountName;
  Password := _Password;
end;

{ TSearchServerResponseMsg }

procedure TSearchServerResponseMsg.SetServerInfo(_ServerName, _ServerIp: string);
begin
  ServerName := _ServerName;
  ServerIp := _ServerIp;
end;

end.
