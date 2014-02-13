unit UServerData;

interface

uses UDataUtil;

type

    // 帐号信息
  TServerAccountData = class( TDataInfo )
  protected
    procedure IniColumn;override;
  public         // 增删
    function ReadAccountExist( Account : string ): Boolean;
    procedure AddAccount( Account, Password : string );
  public         // 查
    function ReadPassword( Account : string ): string;
    function ReadStatus( Account : string ): Integer;
  public         // 改
    procedure SetStatus( Account : string; AccountStatus : Integer );
  end;

    // 服务器信息
  TServerInfoData = class
  public
    ServerName : string;
    UdpPort, TcpPort : Integer;
  end;

    // 客户端帐号绑定信息
  TClientAccountBindData = class( TDataInfo )
  protected
    procedure IniColumn;override;
  public         // 增/删
    procedure AddClient( ClientID : Int64; Account : string );
    procedure RemoveClient( ClientID : Int64 );
  public         // 查
    function ReadAccount( ClientID : Int64 ): string;
  end;

const   // 列信息
  AccountCol_Account = 'Account';
  AccountCol_Password = 'Password';
  AccountCol_Status = 'Status';

const   // 状态枚举
  AccountStatus_Online = 0;
  AccountStatus_Offline = 1;

const    // 列信息
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
