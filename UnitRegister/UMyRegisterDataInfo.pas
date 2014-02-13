unit UMyRegisterDataInfo;

interface

uses Generics.Collections, UDataSetInfo, SysUtils;

type

{$Region ' ���ݽṹ ' }

    // ����Pc��Ϣ
  TActivatePcInfo = class
  public
    PcID : string;
    LicenseStr : string;
  public
    constructor Create( _PcID : string );
    procedure SetLicenseStr( _LicenseStr : string );
  end;
  TActivatePcList = class( TObjectList<TActivatePcInfo> )end;

    // ע����Ϣ
  TMyRegisterInfo = class( TMyDataInfo )
  public  // ������Ϣ
    RegisterEdition : string;
    LastDate : TDateTime;
    IsFreeLimit, IsRemoteLimit : Boolean;
  public  // ��������Ϣ
    ActivatePcList : TActivatePcList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

{$EndRegion}

{$Region ' ���ݽӿ� ' }

    // ���� ���� List �ӿ�
  TActivatePcListAccessInfo = class
  protected
    ActivatePcList : TActivatePcList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // ���� ���ݽӿ�
  TActivatePcAccessInfo = class( TActivatePcListAccessInfo )
  public
    PcID : string;
  protected
    ActivatePcIndex : Integer;
    ActivatePcInfo : TActivatePcInfo;
  public
    constructor Create( _PcID : string );
  protected
    function FindActivatePcInfo: Boolean;
  end;

{$EndRegion}

{$Region ' �����޸� ' }

    // �޸ĸ���
  TActivatePcWriteInfo = class( TActivatePcAccessInfo )
  end;


    // ���
  TActivatePcAddInfo = class( TActivatePcWriteInfo )
  public
    LicenseStr : string;
  public
    procedure SetLicenseStr( _LicenseStr : string );
    procedure Update;
  end;

    // ɾ��
  TActivatePcRemoveInfo = class( TActivatePcWriteInfo )
  public
    procedure Update;
  end;



{$EndRegion}

{$Region ' ���ݶ�ȡ ' }

    // ��ȡ License ��Ϣ
  TActivatePcReadLicense = class( TActivatePcAccessInfo )
  public
    function get : string;
  end;

    // ��ȡ ������Ϣ
  ActivatePcInfoReadUtil = class
  public
    class function ReadLicenseStr( PcID : string ): string;
  end;

{$EndRegion}


var
  MyRegisterInfo : TMyRegisterInfo;

implementation

{ TActivateInfo }

constructor TActivatePcInfo.Create(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TActivatePcInfo.SetLicenseStr(_LicenseStr: string);
begin
  LicenseStr := _LicenseStr;
end;

{ TMyRegisterInfo }

constructor TMyRegisterInfo.Create;
begin
  inherited;
  ActivatePcList := TActivatePcList.Create;
end;

destructor TMyRegisterInfo.Destroy;
begin
  ActivatePcList.Free;
  inherited;
end;

{ TActivatePcListAccessInfo }

constructor TActivatePcListAccessInfo.Create;
begin
  MyRegisterInfo.EnterData;
  ActivatePcList := MyRegisterInfo.ActivatePcList;
end;

destructor TActivatePcListAccessInfo.Destroy;
begin
  MyRegisterInfo.LeaveData;
  inherited;
end;

{ TActivatePcAccessInfo }

constructor TActivatePcAccessInfo.Create( _PcID : string );
begin
  inherited Create;
  PcID := _PcID;
end;

function TActivatePcAccessInfo.FindActivatePcInfo: Boolean;
var
  i : Integer;
begin
  Result := False;
  for i := 0 to ActivatePcList.Count - 1 do
    if ( ActivatePcList[i].PcID = PcID ) then
    begin
      Result := True;
      ActivatePcIndex := i;
      ActivatePcInfo := ActivatePcList[i];
      break;
    end;
end;

{ TActivatePcAddInfo }

procedure TActivatePcAddInfo.SetLicenseStr( _LicenseStr : string );
begin
  LicenseStr := _LicenseStr;
end;

procedure TActivatePcAddInfo.Update;
begin
    // �����ڣ��򴴽�
  if not FindActivatePcInfo then
  begin
    ActivatePcInfo := TActivatePcInfo.Create( PcID );
    ActivatePcList.Add( ActivatePcInfo );
  end;

  ActivatePcInfo.SetLicenseStr( LicenseStr );
end;

{ TActivatePcRemoveInfo }

procedure TActivatePcRemoveInfo.Update;
begin
  if not FindActivatePcInfo then
    Exit;

  ActivatePcList.Delete( ActivatePcIndex );
end;

{ ActivatePcInfoReadUtil }

class function ActivatePcInfoReadUtil.ReadLicenseStr(PcID: string): string;
var
  ActivatePcReadLicense : TActivatePcReadLicense;
begin
  ActivatePcReadLicense := TActivatePcReadLicense.Create( PcID );
  Result := ActivatePcReadLicense.get;
  ActivatePcReadLicense.Free;
end;

{ TActivatePcReadLicense }

function TActivatePcReadLicense.get: string;
begin
  Result := '';
  if not FindActivatePcInfo then
    Exit;
  Result := ActivatePcInfo.LicenseStr;
end;

end.
