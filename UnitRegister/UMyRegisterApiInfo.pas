unit UMyRegisterApiInfo;

interface

uses UMyUtil, classes, SysUtils, DateUtils, kg_dnc;

type

{$Region ' ����ע�� �޸� ' }

    // ��ȡ
  TRegisterReadHandle = class
  public
    LicenseStr : string;
  public
    RegisgerEdition : string;
    LastDate : TDateTime;
    ClientCount : Integer;
    IsFreeLimit, IsRemoteLimit : Boolean;
    IsShowTrialToFree : Boolean;
  public
    constructor Create( _LicenseStr : string );
    procedure Update;virtual;
  private
    procedure FindLicenseInfo;
    procedure SetToInfo;
    procedure SetToFace;
    procedure RsetNetworkMode;virtual;
    procedure RunExpired;
  private
    function ReadLastDateIsExpired : Boolean;
  end;

    // ����
  TRegisterSetHandle = class( TRegisterReadHandle )
  public
    procedure Update;override;
  private
    procedure SetToXml;
    procedure SetToEvent;
    procedure RsetNetworkMode;override;
  end;

      // ��ȡ��ҳʱ��
  TGetWebTime = class
  private
    DateStr : string;
  public
    function get : TDateTime;
  private
    function FindDateStr : Boolean;
    function getMonth( MonthStr : string ): Word;
  end;

    // �Ƿ� ע���ѹ���
  TRegisterTimeReadIsExpired = class
  public
    LastDate : TDateTime;
  public
    constructor Create( _LastDate : TDateTime );
    function get : Boolean;
  protected
    function getIsPermanent : Boolean;
    function getIsLocalExpired : Boolean;
    function getIsWebExpired : Boolean;
    function getIsRegisterExpired : Boolean;
  end;

{$EndRegion}

{$Region ' ��ע�� �޸� ' }

    // �޸�
  TActivatePcWriteHandle = class
  public
    PcID : string;
  public
    constructor Create( _PcID : string );
  end;

    // ��ȡ
  TActivatePcReadHandle = class( TActivatePcWriteHandle )
  public
    LicenseStr : string;
  public
    procedure SetLicenseStr( _LicenseStr : string );
    procedure Update;virtual;
  private
    procedure AddToInfo;
  end;

    // ���
  TActivatePcAddHandle = class( TActivatePcReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
    procedure AddToEvent;
  end;

    // ɾ��
  TActivatePcRemoveHandle = class( TActivatePcWriteHandle )
  protected
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromXml;
  end;

    // Pc ���ߣ����ͼ�����Ϣ
  TActivatePcOnlineHandle = class
  public
    OnlinePcID : string;
  public
    constructor Create( _OnlinePcID : string );
    procedure Update;
  end;

{$EndRegion}

{$Region ' ע����ʾ �޸� ' }

    // �޸�
  TRegisterShowWriteHandle = class
  public
    PcID : string;
  public
    constructor Create( _PcID : string );
  end;

      // ��ȡ
  TRegisterShowReadHandle = class( TRegisterShowWriteHandle )
  public
    HardCode : string;
  public
    RegisterEdition : string;
  public
    procedure SetHardCode( _HardCode : string );
    procedure SetRegisterEdition( _RegisterEdition : string );
    procedure Update;virtual;
  private
    procedure AddToFace;
  end;

    // ���
  TRegisterShowAddHandle = class( TRegisterShowReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // �޸�
  TRegisterShowSetRegisterEditionHandle = class( TRegisterShowWriteHandle )
  public
    RegisterEdition : string;
  public
    procedure SetRegisterEdition( _RegisterEdition : string );
    procedure Update;
  private
     procedure SetToFace;
     procedure SetToXml;
  end;

    // �޸�
  TRegisterShowSetIsOnlineHandle = class( TRegisterShowWriteHandle )
  public
    IsOnline : boolean;
  public
    procedure SetIsOnline( _IsOnline : boolean );
    procedure Update;
  private
     procedure SetToFace;
  end;


    // ɾ��
  TRegisterShowRemoveHandle = class( TRegisterShowWriteHandle )
  protected
    procedure Update;
  private
    procedure RemoveFromFace;
    procedure RemoveFromXml;
  end;



{$EndRegion}

  RegisterApiReadUtil = class
  public
    class function ReadRegisterEditon( EditionNum : string ): string;
    class function ReadEditionInt( RegisterEditon : string ): Integer;
  public
    class function ReadIsRegister( RegisterEditon : string ): Boolean;
    class function ReadIePermanent( LastDate : TDateTime ): Boolean; // �Ƿ����ù���
  end;

    // ����ע����Ϣ
  MyRegisterUserApi = class
  public
    class procedure SetLicense( LicenseStr : string );
    class procedure SetRegisterOnline( OnlinePcID : string );
  end;

    // ע����ʾ��Ϣ
  RegisterShowAppApi = class
  public
    class procedure AddItem( PcID, HardCode, RegisterEditon : string );
    class procedure SetRegisterEditon( PcID, RegisterEditon : string );
    class procedure SetIsOnline( PcID : string; IsOnline : Boolean );
    class procedure RemoveItem( PcID : string );
  end;

    // ������Ϣ
  RegisterActivatePcApi = class
  public
    class procedure AddItem( PcID, LicenseStr : string );
    class procedure PcOnline( PcID : string );
    class procedure RemoveItem( PcID : string );
  end;

    // ʹ������
  RegisterLimitApi = class
  public             // ���ð�����
    class function ReadFeeBackupSpace : Int64;
  public             // ��ʾ����
    class procedure ShowRemoteNetworkError;
    class procedure ShowBackupSpaceError;
  public
    class procedure MarkAdsClick( AdsName : string );
    class function ProfessionalAction: Boolean;
    class procedure ShowTrialToFree;
  private
    class procedure ShowWarnning( WarnningStr : string );
  end;

const
    // License
  Lincense_Split = '|';
  Lincense_SplitCount = 3;
  Lincense_HardCode = 0;
  Lincense_EditionInfo = 1;
  Lincense_LastDate = 2;

    // License Edition Number
  EditionNum_Trial = '0';
  EditionNum_Professional = '1';
  EditionNum_Enterprise = '2';

  RegisterEdition_Free = 'Free';
  RegisterEdition_Trial = 'Trial';
  RegisterEdition_Professional = 'Professional';
  RegisterEdition_Enterprise = 'Enterprise';

const
  HttpStr_ProductName = 'ProductName';
  HttpStr_PcID = 'PcID';
  HttpStr_PcName = 'PcName';

const
  AdsName_FolderTransfer = 'FolderTransfer';
  AdsName_c4s = 'Chat4Support';
  AdsName_DuplicateFilter = 'DuplicateFilter';
  AdsName_KeywordCompeting = 'KeywordCompeting';
  AdsName_TextFinding = 'TextFinding';

var
  TrialToFree_IsShow : Boolean = True;


implementation

uses UMyRegisterDataInfo, UMyRegisterXmlInfo, UmainFormFace, UmyRegisterFaceInfo,
     UMyNetPcInfo, UNetworkControl, UMyRegisterEventInfo, idhttp, URegisterInfoIO, URegisterThread,
     UMyUrl, UFormFreeTips;

{ MyRegisterUserApi }

class procedure MyRegisterUserApi.SetLicense(LicenseStr: string);
var
  RegisterSetHandle : TRegisterSetHandle;
begin
  RegisterSetHandle := TRegisterSetHandle.Create( LicenseStr );
  RegisterSetHandle.Update;
  RegisterSetHandle.Free;
end;

constructor TActivatePcWriteHandle.Create( _PcID : string );
begin
  PcID := _PcID;
end;


class procedure MyRegisterUserApi.SetRegisterOnline(OnlinePcID: string);
begin
  MyRegisterEvent.SetEditonOnline( MyRegisterInfo.RegisterEdition, OnlinePcID );
end;

{ TActivatePcReadHandle }

procedure TActivatePcReadHandle.SetLicenseStr( _LicenseStr : string );
begin
  LicenseStr := _LicenseStr;
end;

procedure TActivatePcReadHandle.AddToInfo;
var
  ActivatePcAddInfo : TActivatePcAddInfo;
begin
  ActivatePcAddInfo := TActivatePcAddInfo.Create( PcID );
  ActivatePcAddInfo.SetLicenseStr( LicenseStr );
  ActivatePcAddInfo.Update;
  ActivatePcAddInfo.Free;
end;

procedure TActivatePcReadHandle.Update;
begin
  AddToInfo;
end;

{ TActivatePcAddHandle }

procedure TActivatePcAddHandle.AddToEvent;
begin
  ActivetePcEvent.AddItem( PcID, LicenseStr );
end;

procedure TActivatePcAddHandle.AddToXml;
var
  ActivatePcAddXml : TActivatePcAddXml;
begin
  ActivatePcAddXml := TActivatePcAddXml.Create( PcID );
  ActivatePcAddXml.SetLicenseStr( LicenseStr );
  ActivatePcAddXml.AddChange;
end;

procedure TActivatePcAddHandle.Update;
begin
  inherited;
  AddToXml;
  AddToEvent;
end;

{ TActivatePcRemoveHandle }

procedure TActivatePcRemoveHandle.RemoveFromInfo;
var
  ActivatePcRemoveInfo : TActivatePcRemoveInfo;
begin
  ActivatePcRemoveInfo := TActivatePcRemoveInfo.Create( PcID );
  ActivatePcRemoveInfo.Update;
  ActivatePcRemoveInfo.Free;
end;

procedure TActivatePcRemoveHandle.RemoveFromXml;
var
  ActivatePcRemoveXml : TActivatePcRemoveXml;
begin
  ActivatePcRemoveXml := TActivatePcRemoveXml.Create( PcID );
  ActivatePcRemoveXml.AddChange;
end;

procedure TActivatePcRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromXml;
end;





{ TRegisterReadHandle }

procedure TRegisterReadHandle.FindLicenseInfo;
var
  DecryptedLicenseStr : string;
  LincenseList : TStringList;
  Hardcode, EditionNumStr, LastDateStr : string;
  EditionNumber : Integer;
begin
    // Ĭ�ϵ����
  RegisgerEdition := RegisterEdition_Free;
  LastDate := Now;
  ClientCount := 3;

    // ����
  if LicenseStr <> '' then
    DecryptedLicenseStr := KeyDec( LicenseStr );

    // ��ȡ Lincense ��Ϣ
  LincenseList := MySplitStr.getList( DecryptedLicenseStr, Lincense_Split );
  if LincenseList.Count = 3 then
  begin
    Hardcode := LincenseList[ Lincense_HardCode ];
    EditionNumStr := LincenseList[ Lincense_EditionInfo ];
    LastDateStr := LincenseList[ Lincense_LastDate ];

      // ��ȡ User ��Ϣ
    EditionNumber := StrToIntDef( EditionNumStr, 0 );
    if EditionNumber > 10 then
    begin
      ClientCount := EditionNumber div 10;
      EditionNumber := EditionNumber mod 10;
    end;
    EditionNumStr := IntToStr( EditionNumber );

      // ����Ƿ񱾻� HardCode
    if MyMacAddress.Equals( Hardcode ) then
    begin
      RegisgerEdition := RegisterApiReadUtil.ReadRegisterEditon( EditionNumStr );
      LastDate := MyRegionUtil.ReadLocalTime( LastDateStr );
    end;
  end;
  LincenseList.Free;

      // ���ð��ҹ���, �����Ѱ�
  if ( RegisgerEdition = RegisterEdition_Trial ) and ReadLastDateIsExpired then
  begin
    RegisgerEdition := RegisterEdition_Free;
    IsShowTrialToFree := True;
  end;

    // �Ƿ��ܵ���������
  IsFreeLimit := not RegisterApiReadUtil.ReadIsRegister( RegisgerEdition ) or
                 ReadLastDateIsExpired;

    // �ܵ�Զ������
  IsRemoteLimit := ( RegisgerEdition = RegisterEdition_Professional ) and not IsFreeLimit;
end;


function TRegisterReadHandle.ReadLastDateIsExpired: Boolean;
var
  RegisterTimeReadIsExpired : TRegisterTimeReadIsExpired;
begin
  RegisterTimeReadIsExpired := TRegisterTimeReadIsExpired.Create( LastDate );
  Result := RegisterTimeReadIsExpired.get;
  RegisterTimeReadIsExpired.Free;
end;

procedure TRegisterReadHandle.RsetNetworkMode;
begin
  NetworkModeApi.SelectLocalNetwork;
end;

procedure TRegisterReadHandle.RunExpired;
begin
    // δע��
  if not RegisterApiReadUtil.ReadIsRegister( RegisgerEdition ) then
    Exit;

    // ����ע��
  if RegisterApiReadUtil.ReadIePermanent( LastDate ) then
    Exit;

    // ������ʱ��
  MyRegisterExpiredHandler.StartRun;
end;

procedure TRegisterReadHandle.SetToFace;
var
  ShowStr : string;
  EditionChangeInfo : TEditionChangeInfo;
  RemoteLimitChangeFace : TRemoteLimitChangeFace;
  TrialToFreeFormShowFace : TTrialToFreeFormShowFace;
begin
  ShowStr := RegisgerEdition;
  if not RegisterApiReadUtil.ReadIsRegister( RegisgerEdition ) then
    ShowStr := ShowStr + ' (Limited Features)'
  else
  if RegisterApiReadUtil.ReadIePermanent( LastDate ) then
    ShowStr := ShowStr + ' (' + IntToStr( ClientCount ) + ' Users)'
  else
    ShowStr := ShowStr + ' (Expire on '+ DateToStr( LastDate ) + ')';

    // ��ʾ������
  EditionChangeInfo := TEditionChangeInfo.Create( ShowStr );
  EditionChangeInfo.AddChange;

    // Զ�̽�ֹ
  RemoteLimitChangeFace := TRemoteLimitChangeFace.Create( IsRemoteLimit );
  RemoteLimitChangeFace.AddChange;

    // ���ð�ת��Ѱ�
  if IsShowTrialToFree and TrialToFree_IsShow then
    RegisterLimitApi.ShowTrialToFree;
end;

procedure TRegisterReadHandle.SetToInfo;
begin
  MyRegisterInfo.RegisterEdition := RegisgerEdition;
  MyRegisterInfo.LastDate := LastDate;
  MyRegisterInfo.IsFreeLimit := IsFreeLimit;
  MyRegisterInfo.IsRemoteLimit := isRemoteLimit;

  PcInfo.ClientCount := ClientCount;
end;

constructor TRegisterReadHandle.Create(_LicenseStr: string);
begin
  LicenseStr := _LicenseStr;
  IsShowTrialToFree := False;
end;

procedure TRegisterReadHandle.Update;
begin
    // ��ȡ License ��Ϣ
  FindLicenseInfo;

  SetToInfo;

  SetToFace;

    // ���½��������
  if IsRemoteLimit and ( MyNetworkConnInfo.SelectType <> SelectConnType_Local ) then
    RsetNetworkMode;
end;

{ TRegisterSetHandle }

procedure TRegisterSetHandle.RsetNetworkMode;
begin
  NetworkModeApi.EnterLan;
end;

procedure TRegisterSetHandle.SetToEvent;
begin
  MyRegisterEvent.SetEdition( RegisgerEdition );
end;

procedure TRegisterSetHandle.SetToXml;
var
  RegisterSetXml : TRegisterSetXml;
begin
  RegisterSetXml := TRegisterSetXml.Create( LicenseStr );
  RegisterSetXml.AddChange;
end;

procedure TRegisterSetHandle.Update;
begin
  inherited;

  SetToXml;
  SetToEvent;
end;

{ RegisterApiReadUtil }

class function RegisterApiReadUtil.ReadEditionInt(
  RegisterEditon: string): Integer;
begin
  if RegisterEditon = RegisterEdition_Free then
    Result := 1
  else
  if RegisterEditon = RegisterEdition_Trial then
    Result := 2
  else
  if RegisterEditon = RegisterEdition_Professional then
    Result := 3
  else
  if RegisterEditon = RegisterEdition_Enterprise then
    Result := 4;
end;

class function RegisterApiReadUtil.ReadIePermanent(
  LastDate: TDateTime): Boolean;
begin
  Result := LastDate > EncodeDate( 2100, 1, 1 );
end;

class function RegisterApiReadUtil.ReadIsRegister(
  RegisterEditon: string): Boolean;
begin
  Result := ( RegisterEditon = RegisterEdition_Trial ) or
            ( RegisterEditon = RegisterEdition_Professional ) or
            ( RegisterEditon = RegisterEdition_Enterprise );
end;

class function RegisterApiReadUtil.ReadRegisterEditon(
  EditionNum: string): string;
begin
  if EditionNum = EditionNum_Trial then
    Result := RegisterEdition_Trial
  else
  if EditionNum = EditionNum_Professional then
    Result := RegisterEdition_Professional
  else
  if EditionNum = EditionNum_Enterprise then
    Result := RegisterEdition_Enterprise
  else
    Result := RegisterEdition_Free;
end;

constructor TRegisterShowWriteHandle.Create( _PcID : string );
begin
  PcID := _PcID;
end;

{ TRegisterShowReadHandle }

procedure TRegisterShowReadHandle.SetHardCode( _HardCode : string );
begin
  HardCode := _HardCode;
end;

procedure TRegisterShowReadHandle.SetRegisterEdition( _RegisterEdition : string );
begin
  RegisterEdition := _RegisterEdition;
end;

procedure TRegisterShowReadHandle.AddToFace;
var
  IsOnline, IsRegister : Boolean;
  PcName : string;
  RegisterShowAddFace : TRegisterShowAddFace;
begin
  IsOnline := MyNetPcInfoReadUtil.ReadIsOnline( PcID );
  IsRegister := RegisterApiReadUtil.ReadIsRegister( RegisterEdition );
  PcName := MyNetPcInfoReadUtil.ReadName( PcID );

  RegisterShowAddFace := TRegisterShowAddFace.Create( PcID );
  RegisterShowAddFace.SetHardCode( HardCode );
  RegisterShowAddFace.SetPcName( PcName );
  RegisterShowAddFace.SetIsOnline( IsOnline );
  RegisterShowAddFace.SetEditionInfo( RegisterEdition, IsRegister );
  RegisterShowAddFace.AddChange;
end;

procedure TRegisterShowReadHandle.Update;
begin
  AddToFace;
end;

{ TRegisterShowAddHandle }

procedure TRegisterShowAddHandle.AddToXml;
var
  RegisterShowAddXml : TRegisterShowAddXml;
begin
  RegisterShowAddXml := TRegisterShowAddXml.Create( PcID );
  RegisterShowAddXml.SetHardCode( HardCode );
  RegisterShowAddXml.SetRegisterEdition( RegisterEdition );
  RegisterShowAddXml.AddChange;
end;

procedure TRegisterShowAddHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TRegisterShowRemoveHandle }

procedure TRegisterShowRemoveHandle.RemoveFromFace;
var
  RegisterShowRemoveFace : TRegisterShowRemoveFace;
begin
  RegisterShowRemoveFace := TRegisterShowRemoveFace.Create( PcID );
  RegisterShowRemoveFace.AddChange;
end;

procedure TRegisterShowRemoveHandle.RemoveFromXml;
var
  RegisterShowRemoveXml : TRegisterShowRemoveXml;
begin
  RegisterShowRemoveXml := TRegisterShowRemoveXml.Create( PcID );
  RegisterShowRemoveXml.AddChange;
end;

procedure TRegisterShowRemoveHandle.Update;
begin
  RemoveFromFace;
  RemoveFromXml;
end;


{ TRegisterShowSetRegisterEditionHandle }

procedure TRegisterShowSetRegisterEditionHandle.SetRegisterEdition( _RegisterEdition : string );
begin
  RegisterEdition := _RegisterEdition;
end;

procedure TRegisterShowSetRegisterEditionHandle.SetToXml;
var
  RegisterShowSetRegisterEditionXml : TRegisterShowSetRegisterEditionXml;
begin
  RegisterShowSetRegisterEditionXml := TRegisterShowSetRegisterEditionXml.Create( PcID );
  RegisterShowSetRegisterEditionXml.SetRegisterEdition( RegisterEdition );
  RegisterShowSetRegisterEditionXml.AddChange;
end;

procedure TRegisterShowSetRegisterEditionHandle.SetToFace;
var
  IsRegister : Boolean;
  RegisterShowSetEditionInfoFace : TRegisterShowSetEditionInfoFace;
begin
  IsRegister := RegisterApiReadUtil.ReadIsRegister( RegisterEdition );

  RegisterShowSetEditionInfoFace := TRegisterShowSetEditionInfoFace.Create( PcID );
  RegisterShowSetEditionInfoFace.SetEditionInfo( RegisterEdition, IsRegister );
  RegisterShowSetEditionInfoFace.AddChange;
end;

procedure TRegisterShowSetRegisterEditionHandle.Update;
begin
  SetToFace;
  SetToXml;
end;

{ TRegisterShowSetIsOnlineHandle }

procedure TRegisterShowSetIsOnlineHandle.SetIsOnline( _IsOnline : boolean );
begin
  IsOnline := _IsOnline;
end;

procedure TRegisterShowSetIsOnlineHandle.SetToFace;
var
  RegisterShowSetIsOnlineFace : TRegisterShowSetIsOnlineFace;
begin
  RegisterShowSetIsOnlineFace := TRegisterShowSetIsOnlineFace.Create( PcID );
  RegisterShowSetIsOnlineFace.SetIsOnline( IsOnline );
  RegisterShowSetIsOnlineFace.AddChange;
end;

procedure TRegisterShowSetIsOnlineHandle.Update;
begin
  SetToFace;
end;

{ RegisterShowAppApi }

class procedure RegisterShowAppApi.AddItem(PcID, HardCode,
  RegisterEditon: string);
var
  RegisterShowAddHandle : TRegisterShowAddHandle;
begin
  RegisterShowAddHandle := TRegisterShowAddHandle.Create( PcID );
  RegisterShowAddHandle.SetHardCode( HardCode );
  RegisterShowAddHandle.SetRegisterEdition( RegisterEditon );
  RegisterShowAddHandle.Update;
  RegisterShowAddHandle.Free;
end;


class procedure RegisterShowAppApi.RemoveItem(PcID: string);
var
  RegisterShowRemoveHandle : TRegisterShowRemoveHandle;
begin
  RegisterShowRemoveHandle := TRegisterShowRemoveHandle.Create( PcID );
  RegisterShowRemoveHandle.Update;
  RegisterShowRemoveHandle.Free;
end;



class procedure RegisterShowAppApi.SetIsOnline(PcID: string; IsOnline: Boolean);
var
  RegisterShowSetIsOnlineHandle : TRegisterShowSetIsOnlineHandle;
begin
  RegisterShowSetIsOnlineHandle := TRegisterShowSetIsOnlineHandle.Create( PcID );
  RegisterShowSetIsOnlineHandle.SetIsOnline( IsOnline );
  RegisterShowSetIsOnlineHandle.Update;
  RegisterShowSetIsOnlineHandle.Free;
end;


class procedure RegisterShowAppApi.SetRegisterEditon(PcID,
  RegisterEditon: string);
var
  RegisterShowSetRegisterEditionHandle : TRegisterShowSetRegisterEditionHandle;
begin
  RegisterShowSetRegisterEditionHandle := TRegisterShowSetRegisterEditionHandle.Create( PcID );
  RegisterShowSetRegisterEditionHandle.SetRegisterEdition( RegisterEditon );
  RegisterShowSetRegisterEditionHandle.Update;
  RegisterShowSetRegisterEditionHandle.Free;
end;






{ RegisterActivatePcApi }

class procedure RegisterActivatePcApi.AddItem(PcID, LicenseStr: string);
var
  ActivatePcAddHandle : TActivatePcAddHandle;
begin
  ActivatePcAddHandle := TActivatePcAddHandle.Create( PcID );
  ActivatePcAddHandle.SetLicenseStr( LicenseStr );
  ActivatePcAddHandle.Update;
  ActivatePcAddHandle.Free;
end;

class procedure RegisterActivatePcApi.PcOnline(PcID: string);
var
  ActivatePcOnlineHandle : TActivatePcOnlineHandle;
begin
  ActivatePcOnlineHandle := TActivatePcOnlineHandle.Create( PcID );
  ActivatePcOnlineHandle.Update;
  ActivatePcOnlineHandle.Free;
end;

class procedure RegisterActivatePcApi.RemoveItem(PcID: string);
var
  ActivatePcRemoveHandle : TActivatePcRemoveHandle;
begin
  ActivatePcRemoveHandle := TActivatePcRemoveHandle.Create( PcID );
  ActivatePcRemoveHandle.Update;
  ActivatePcRemoveHandle.Free;
end;



{ TActivatePcOnlineHandle }

constructor TActivatePcOnlineHandle.Create(_OnlinePcID: string);
begin
  OnlinePcID := _OnlinePcID;
end;

procedure TActivatePcOnlineHandle.Update;
var
  LicenseStr : string;
begin
  LicenseStr := ActivatePcInfoReadUtil.ReadLicenseStr( OnlinePcID );
  if LicenseStr = '' then // û�м����Pc
    Exit;

  ActivetePcEvent.AddItem( OnlinePcID, LicenseStr );
end;

{ TGetWebTime }

function TGetWebTime.FindDateStr: Boolean;
var
  getTimeHttp : TIdHTTP;
begin
  getTimeHttp := TIdHTTP.Create(nil);
  getTimeHttp.ConnectTimeout := 10000;
  getTimeHttp.ReadTimeout := 10000;
  getTimeHttp.HandleRedirects := True;
  try
    getTimeHttp.Get( 'http://www.BackupCow.com/' );
    DateStr := getTimeHttp.Response.RawHeaders.Values[ 'Date' ];
    Result := True;
  except
    Result := False;
  end;
  getTimeHttp.Free;
end;

function TGetWebTime.get: TDateTime;
var
  YearStr, MonthStr, DayStr : string;
  Year, Month, Day: Word;
begin
  Result := Now;
  Exit;

  if not FindDateStr then
    Exit;

  DateStr := Copy(DateStr, 6, 11);
  YearStr := Copy(DateStr, 8, 4);
  MonthStr := Copy(DateStr, 4, 3);
  DayStr := Copy(DateStr, 1, 2);

  Year := StrToIntDef( YearStr, 0 );
  Month := getMonth( MonthStr );
  Day := StrToIntDef( DayStr, 0 );

  if ( Year = 0 ) or ( Month = 0 ) or ( Day = 0 ) then
    Exit;

  Result := EncodeDate( Year, Month, Day );
end;

function TGetWebTime.getMonth(MonthStr: string): Word;
var
  m : Word;
begin
  if CompareText(MonthStr, 'jan') = 0 then
    m := 1
  else if CompareText(MonthStr, 'feb') = 0 then
    m := 2
  else if CompareText(MonthStr, 'mar') = 0 then
    m := 3
  else if CompareText(MonthStr, 'apr') = 0 then
    m := 4
  else if CompareText(MonthStr, 'may') = 0 then
    m := 5
  else if CompareText(MonthStr, 'jun') = 0 then
    m := 6
  else if CompareText(MonthStr, 'jul') = 0 then
    m := 7
  else if CompareText(MonthStr, 'aug') = 0 then
    m := 8
  else if CompareText(MonthStr, 'sep') = 0 then
    m := 9
  else if CompareText(MonthStr, 'oct') = 0 then
    m := 10
  else if CompareText(MonthStr, 'nov') = 0 then
    m := 11
  else if CompareText(MonthStr, 'dec') = 0 then
    m := 12
  else
    m := 0;
end;

{ TRegisterTimeReadIsExpired }

constructor TRegisterTimeReadIsExpired.Create(_LastDate: TDateTime);
begin
  LastDate := _LastDate;
end;

function TRegisterTimeReadIsExpired.get: Boolean;
begin
    // ���ù���
  if getIsPermanent then
  begin
    Result := False;
    Exit;
  end;

    // ��� ����ʱ��
  Result := True;
  if getIsLocalExpired or getIsWebExpired or getIsRegisterExpired then
    Exit;
  Result := False;
end;

function TRegisterTimeReadIsExpired.getIsLocalExpired: Boolean;
begin
  Result := LastDate <= Now;
end;

function TRegisterTimeReadIsExpired.getIsPermanent: Boolean;
begin
  Result := RegisterApiReadUtil.ReadIePermanent( LastDate );
end;

function TRegisterTimeReadIsExpired.getIsRegisterExpired: Boolean;
var
  ReadAppStartTime : TReadAppStartTime;
  StartTime, NowTime : TDateTime;
  ReadAppRunTime : TReadAppRunTime;
  RunTime : Int64;
begin
    // ����ʼʱ��
  ReadAppStartTime := TReadAppStartTime.Create;
  StartTime := ReadAppStartTime.get;
  ReadAppStartTime.Free;

    // ��������ʱ��
  ReadAppRunTime := TReadAppRunTime.Create;
  RunTime := ReadAppRunTime.get;
  ReadAppRunTime.Free;

    // �����ϵ�ʱ��
  NowTime := IncMinute( StartTime, RunTime );

  Result := LastDate <= NowTime;
end;

function TRegisterTimeReadIsExpired.getIsWebExpired: Boolean;
var
  GetWebTime : TGetWebTime;
  ReadWebTime : TReadWebTime;
  WebTime : TDateTime;
  WriteWebTime : TWriteWebTime;
begin
  Result := True;

    // ������վ ��ȡ����ʱ��
  GetWebTime := TGetWebTime.Create;
  WebTime := GetWebTime.get;
  GetWebTime.Free;

    // �޷�������վ
  if WebTime = -1 then
  begin
      // ��ȡ��һ�η�����վ��ʱ��
    ReadWebTime := TReadWebTime.Create;
    WebTime := ReadWebTime.get;
    ReadWebTime.Free;
  end
  else
  begin
      // ��¼��η�����վ��ʱ��
    WriteWebTime := TWriteWebTime.Create( WebTime );
    WriteWebTime.Update;
    WriteWebTime.Free;
  end;

    // �жϰ汾�Ƿ����
  Result := LastDate <= WebTime;
end;

{ RegisterLimitApi }

class procedure RegisterLimitApi.MarkAdsClick(AdsName: string);
var
  PcID, PcName: string;
  params : TStringlist;
  idhttp : TIdHTTP;
begin
    // ������Ϣ
  PcID := PcInfo.PcID;
  PcName := PcInfo.PcName;

    // ��¼����ȡ���� Pc ��Ϣ
  params := TStringList.Create;
  params.Add( HttpStr_ProductName + '=' + AdsName );
  params.Add( HttpStr_PcID + '=' + PcID );
  params.Add( HttpStr_PcName + '=' + PcName );

  idhttp := TIdHTTP.Create(nil);
  idhttp.ConnectTimeout := 5000;
  idhttp.ReadTimeout := 5000;
  try
    idhttp.Post( MyUrl.getAdsRunMark , params );
  except
  end;
  idhttp.Free;

  params.free;
end;

class function RegisterLimitApi.ProfessionalAction: Boolean;
var
  AdsShowCountAddXml : TAdsShowCountAddXml;
begin
  Result := True;
  Exit;

    // ����Ѱ�
  if not MyRegisterInfo.IsFreeLimit then
    Exit;

    // ��ʾ�����Ϣ
  Result := frmFreeTips.ShowRandomPage;

    // ��¼��ʾ�����
  AdsShowCountAddXml := TAdsShowCountAddXml.Create;
  AdsShowCountAddXml.AddChange;
end;

class function RegisterLimitApi.ReadFeeBackupSpace: Int64;
begin
  Result := 1 * Size_GB;
end;

class procedure RegisterLimitApi.ShowBackupSpaceError;
begin
  ShowWarnning( FreeEditionError_BackupSpace );
end;

class procedure RegisterLimitApi.ShowRemoteNetworkError;
begin
  ShowWarnning( FreeEditionError_RemoteError );
end;

class procedure RegisterLimitApi.ShowTrialToFree;
var
  TrialToFreeFormShowFace : TTrialToFreeFormShowFace;
  TrialToFreeSetXml : TTrialToFreeSetXml;
begin
    // ������ʾ
  TrialToFreeFormShowFace := TTrialToFreeFormShowFace.Create;
  TrialToFreeFormShowFace.AddChange;

    // ���ò�����ʾ
  TrialToFreeSetXml := TTrialToFreeSetXml.Create;
  TrialToFreeSetXml.SetIsShow( False );
  TrialToFreeSetXml.AddChange;
end;

class procedure RegisterLimitApi.ShowWarnning(WarnningStr: string);
var
  FreeLimitFormShow : TFreeLimitFormShow;
begin
    // ������ʾ���󴰿�
  if RegisterError_IsShowing then
    Exit;

  FreeLimitFormShow := TFreeLimitFormShow.Create( WarnningStr );
  FreeLimitFormShow.AddChange;
end;

end.

