unit UServerData;

interface

uses UDataUtil;

type

    // �ʺ���Ϣ
  TServerAccountData = class( TDataInfo )
  protected
    procedure IniColumn;override;
  public         // ��ɾ
    function ReadAccountExist( Account : string ): Boolean;
    procedure AddAccount( Account, Password : string );
  public         // ��
    function ReadPassword( Account : string ): string;
    function ReadStatus( Account : string ): Integer;
  public         // ��
    procedure SetStatus( Account : string; AccountStatus : Integer );
  end;

    // ��������Ϣ
  TServerInfoData = class
  public
    ServerName : string;
    UdpPort, TcpPort : Integer;
  end;

    // �ͻ����ʺŰ���Ϣ
  TClientAccountBindData = class( TDataInfo )
  protected
    procedure IniColumn;override;
  public         // ��/ɾ
    procedure AddClient( ClientID : Int64; Account : string );
    procedure RemoveClient( ClientID : Int64 );
  public         // ��
    function ReadAccount( ClientID : Int64 ): string;
  end;

const   // ����Ϣ
  AccountCol_Account = 'Account';
  AccountCol_Password = 'Password';
  AccountCol_Status = 'Status';

const   // ״̬ö��
  AccountStatus_Online = 0;
  AccountStatus_Offline = 1;

const    // ����Ϣ
  ClientAccount_ClientID = 'ClientID';
  ClientAccount_Account = 'Account';

implementation

{ TServerAccountData }

procedure TServerAccountData.AddAccount(Account, Password: string);
begin
  AddRow( [ Account, Password, AccountStatus_Online ] );
end;

procedure TServerAccountData.IniColumn;
begin
  AddCol( AccountCol_Account, ColType_String );
  AddCol( AccountCol_Password, ColType_String );
  AddCol( AccountCol_Status, ColType_Int );
  SetKeyCol( AccountCol_Account );
  CreateData;
end;

function TServerAccountData.ReadAccountExist(Account: string): Boolean;
begin
  Result := ReadKeyExist( Account );
end;

function TServerAccountData.ReadPassword(Account: string): string;
begin
  Result := ReadKeyColValue( Account, AccountCol_Password );
end;

function TServerAccountData.ReadStatus(Account: string): Integer;
begin
  Result := ReadKeyColValue( Account, AccountCol_Status );
end;

procedure TServerAccountData.SetStatus(Account: string; AccountStatus: Integer);
begin

end;

{ TClientAccountData }

procedure TClientAccountBindData.AddClient(ClientID: Int64; Account: string);
begin
  AddRow( [ ClientID, Account ] );
end;

procedure TClientAccountBindData.IniColumn;
begin
  AddCol( ClientAccount_ClientID, ColType_Int64 );
  AddCol( ClientAccount_Account, ColType_String );
  SetKeyCol( ClientAccount_ClientID );
  CreateData;
end;

function TClientAccountBindData.ReadAccount(ClientID: Int64): string;
begin
  Result := ReadKeyColValue( ClientID, ClientAccount_Account );
end;

procedure TClientAccountBindData.RemoveClient(ClientID: Int64);
begin
  RemoveRow( ClientID );
end;

end.
