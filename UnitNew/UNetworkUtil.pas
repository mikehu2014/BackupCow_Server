unit UNetworkUtil;

interface

uses UMsgUtil;

type

{$Region ' Udp �������� ' }

    // ��������
  TSearchServerRequestMsg = class( TMsgInfo )
  end;

    // �����������
  TSearchServerResponseMsg = class( TMsgInfo )
  public
    ServerName, ServerIp : string;
  public
    procedure SetServerInfo( _ServerName, _ServerIp : string );
  end;

{$EndRegion}

{$Region ' �ʺ���Ϣ ���� ' }

    // ����
  TAccountMsgBase = class( TMsgInfo )
  public
    AccountName : string;
    Password : string;
  public
    procedure SetAccountInfo( _AccountName, _Password : string );
  end;

    // ע���ʺ�
  TAccountSignupMsg = class( TAccountMsgBase )
  end;

    // ��¼�ʺ�
  TAccountLoginMsg = class( TAccountMsgBase )
  end;

    // ע���ʺ�
  TAccountLogoutMsg = class( TMsgInfo )
  end;

{$EndRegion}

{$Region ' �ʺ���Ϣ ���� ' }

    // ע�᷵�� ����
  TAccountSingupResultMsg = class( TMsgInfo )
  end;

    // ע��ɹ�
  TAccountSignupSuccessMsg = class( TAccountSingupResultMsg )
  end;

    // ע���ʺ� �Ѵ���
  TAccountSignupExistMsg = class( TAccountSingupResultMsg )
  end;


    // ��¼���� ����
  TAccountLoginResultMsg = class( TMsgInfo )
  end;

    // ��¼�ɹ�
  TAccountLoginSuccessMsg = class( TAccountLoginResultMsg )
  end;

    // ��¼�ʺŲ�����
  TAccountLoginNotExistMsg = class( TAccountLoginResultMsg )
  end;

    // ��¼�������
  TAccountLoginPasswordErrorMsg = class( TAccountLoginResultMsg )
  end;


    // ע������ ����
  TAccountLogoutResultMsg = class( TMsgInfo )
  end;

    // ע���ɹ�
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
