unit URegisterInfo;

interface

uses IniFiles, UMyUtil, SysUtils, Classes, kg_dnc, URegisterInfoIO, Generics.Collections, UModelUtil,
     SyncObjs, UChangeInfo, xmldom, XMLIntf, msxmldom, XMLDoc, DateUtils, idhttp, uDebug;

type

{$Region ' 本机注册信息 ' }

    // 寻找 网络注册 信息
  TFindWebRegisterInfo = class
  private
    LincenseStr : string;
    Hardcode, EditionNum, LastDateStr : string;
  private
    RegisterEdition : string;
    LastDate : TDateTime;
  public
    procedure Update;
  private
    function LoadLinceseStr : Boolean;
    function FindLincenseInfo : Boolean;
    function CheckHardCode : Boolean;
    function CheckEditionNum : Boolean;
    function CheckLastDate : Boolean;
  end;

    // 加载 版本信息
  TRegisterInfoLoad = class
  public
    procedure Update;
  end;

    // 保存版本信息
  TRegisterInfoSave = class
  private
    LicenseStr : string;
  public
    constructor Create( _LicenseStr : string );
    procedure Update;
  private
    function CheckLicenseStr : Boolean;
    procedure SaveLicenseStr;
    procedure ResetAppTime;
  end;

    // 在网站上登记使用情况
  TRegisterUserToWeb = class
  public
    procedure Update;
  private
    function IsWebRegister : Boolean;
    procedure RunRegisterThread;
  end;

      // 注册信息
  TRegisterInfo = class
  public
    RegisterEditon : string;
    LastDate : TDateTime;
  public
    procedure FirstLoadLicense;
    procedure LoadLicense;
    procedure SaveLicense( LicenseStr : string );
  public
    function getAppEditionDate : string;
    function getIsPermanent : Boolean;
    function getIsFreeEdition : Boolean;
  end;

    // 本机注册 控制器
  TMyRegisterControl = class
  public
    procedure AddLicense( LicenseStr : string );
  end;

    // 记录 使用信息
  TAppFreeUserMarkThread = class( TThread )
  public
    constructor Create;
  protected
    procedure Execute; override;
  private
    procedure SaveFreeLicense( LicenseStr : string );
  end;

{$EndRegion}

{$Region ' 检测注册状态信息 ' }

    // 修改 系统运行时间
  TUpdateAppRunTime = class
  private
    DelRunTime : Integer;
  private
    RunTime : Int64;
  public
    constructor Create( _DelRunTime : Integer );
    procedure Update;
  private
    procedure ReadRunTime;
    procedure UpdateRunTIme;
    procedure WriteRunTime;
  private
    procedure CheckAppStartTime;
  end;

    // 获取网页时间
  TGetWebTime = class
  private
    DateStr : string;
  public
    function get : TDateTime;
  private
    function FindDateStr : Boolean;
    function getMonth( MonthStr : string ): Word;
  end;

    // 检测软件是否过期
  TAppExpiredCheck = class
  private
    ExpiredDate : TDateTime;
    IsCheckWebTime : Boolean;
  public
    constructor Create( _ExpiredDate : TDateTime );
    procedure SetIsCheckWebTime( _IsCheckWebTime : Boolean );
    function getIsExpired : Boolean;
  private
    function CheckLocalTime: Boolean;  // 本机时间
    function CheckWebTime: Boolean;   // 网络时间
    function CheckAppRunTime : Boolean;  // 本机记录的 程序运行时间
  end;

    // 定期检测软件是否过期
    // 定时写 AppRun 时间
  TAppExpiredCheckThread = class( TThread )
  private
    IsExpired : Boolean;
  public
    constructor Create;
    procedure SetIsExpired( _IsExpired : Boolean );
    destructor Destroy; override;
  protected
    procedure Execute;override;
  public
    procedure WriteAppTime;
    procedure CheckExpired;
    procedure ShowExpired;
  end;


{$EndRegion}

  EditionUtil = class
  public
    class function getEditionInt( RegisterEdition : string ): Integer;
  public
    class function getFileSpaceLimit( FileSize : Int64 ): Boolean;
    class function getFileCountLimit( FileCount : Integer ): Boolean;
  end;

const
  Ini_Register = 'Register';
  Ini_License = 'License';

    // License
  Lincense_Split : string = '|';
  Lincense_SplitCount : Integer = 3;
  Lincense_HardCode : Integer = 0;
  Lincense_EditionInfo : Integer = 1;
  Lincense_LastDate : Integer = 2;

    // License Edition Number
  EditionNum_Try : string = '0';
  EditionNum_Professional : string = '1';
  EditionNum_Enterprise : string = '2';

    // 版本信息
  RegisterEdition_Evaluate = 'Evaluation';  // 试用版( 新版不使用 )
  RegisterEditon_Free = 'Free'; // 免费版
  RegisterEditon_Professional = 'Professional';  // 专业注册版
  RegisterEditon_Enterprise = 'Enterprise';  // 企业注册版

  Xml_PcID = 'pi';
  Xml_LicenseStr = 'ls';
  Time_CheckEdition : Integer = 1;


  FreeEditionLimit_SendFileCount = 1000;
  FreeEditionLimit_SendFileSize = 100 * 1024 * 1024;
  FreeEditionLimit_ShareFileSize = 100 * 1024 * 1024;

  FreeEditionError_BackupSpace = 'Total size limit of backup source files is 3 GB in Free Ediition.';
  FreeEditionError_SendFileSize = 'You are not allowed to transfer a file larger than 100 MB in the Free Edition. ' + #13#10 +
                                  'Please upgrade the software to a Registered Edition.';
  FreeEditionError_SendFileCount = 'The free edition doesn''t allow you to transfer a folder with more than 1000 files inside.';
  FreeEditionError_ShareDownSize = 'You are not allowed to download a shared file larger than 100 MB in the Free Edition. ' + #13#10 +
                                  'Please upgrade the software to a Registered Edition.';
  FreeEditionError_ShareDownCount = 'The free edition doesn''t allow you to download a shared folder with more than 1000 files inside.';


implementation

uses UMyClient, UMyNetPcInfo, UXmlUtil, UMainForm, UFormRegister,
     UNetworkFace, UMyUrl;

{ TCheckWebRegister }

function TFindWebRegisterInfo.CheckEditionNum: Boolean;
begin
  Result := True;

  if EditionNum = EditionNum_Professional then
    RegisterEdition := RegisterEditon_Professional
  else
  if EditionNum = EditionNum_Enterprise then
    RegisterEdition := RegisterEditon_Enterprise
  else
    Result := False;
end;

function TFindWebRegisterInfo.CheckHardCode: Boolean;
begin
  Result := MyMacAddress.Equals( Hardcode );
end;

function TFindWebRegisterInfo.CheckLastDate: Boolean;
var
  AppExpiredCheck : TAppExpiredCheck;
begin
  Result := StrToFloatDef( LastDateStr, -1 ) <> -1;

    // LastDate 字符串格式出错
  if not Result then
    Exit;

  LastDate := StrToFloat( LastDateStr);

    // 检测 是否过期
  AppExpiredCheck := TAppExpiredCheck.Create( LastDate );
  AppExpiredCheck.SetIsCheckWebTime( False );
  Result := not AppExpiredCheck.getIsExpired;
  AppExpiredCheck.Free;
end;

procedure TFindWebRegisterInfo.Update;
begin
    // 检查 license 信息
  if not ( LoadLinceseStr and FindLincenseInfo and CheckHardCode and
           CheckEditionNum and CheckLastDate )
  then
  begin
    RegisterEdition := RegisterEditon_Free;
    LastDate := IncYear( Now, 100 );
  end;
end;

function TFindWebRegisterInfo.FindLincenseInfo: Boolean;
var
  DecLincenseStr : string;
  LincenseList : TStringList;
begin
  Result := False;

      // 解密
  DecLincenseStr := KeyDec( LincenseStr );

    // 提取 Lincense 信息
  LincenseList := MySplitStr.getList( DecLincenseStr, Lincense_Split );
  if LincenseList.Count = 3 then
  begin
    Hardcode := LincenseList[ Lincense_HardCode ];
    EditionNum := LincenseList[ Lincense_EditionInfo ];
    LastDateStr := LincenseList[ Lincense_LastDate ];

    Result := True;
  end;
  LincenseList.Free;
end;

function TFindWebRegisterInfo.LoadLinceseStr: Boolean;
var
  iniFile : TIniFile;
begin
  Result := False;

    // Ini 文件读 Lincense 字符串
  iniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  LincenseStr := iniFile.ReadString( Ini_Register, Ini_License, '' );
  iniFile.Free;

    // Lincense 不存在
  if LincenseStr = '' then
    Exit;

  Result := True;
end;

{ TRegisterInfoLoadIni }

procedure TRegisterInfoLoad.Update;
var
  FindWebRegisterInfo : TFindWebRegisterInfo;
begin
  FindWebRegisterInfo := TFindWebRegisterInfo.Create;
  FindWebRegisterInfo.Update;
  FindWebRegisterInfo.Free;
end;

{ TRegisterInfo }

procedure TRegisterInfo.FirstLoadLicense;
var
  RegisterUserToWeb : TRegisterUserToWeb;
begin
    // 加载
  LoadLicense;

    // 如果没有在网上登记使用, 则登记
  RegisterUserToWeb := TRegisterUserToWeb.Create;
  RegisterUserToWeb.Update;
  RegisterUserToWeb.Free;
end;

function TRegisterInfo.getAppEditionDate: string;
begin
  Result := RegisterEditon;
  if getIsFreeEdition then
    Result := Result + ' (Limited Features)'
  else
  if getIsPermanent then
    Result := Result + ' (Permanent)'
  else
    Result := Result + ' (Expire on '+ DateToStr( LastDate ) + ')';
end;

function TRegisterInfo.getIsFreeEdition: Boolean;
begin
  Result := RegisterEditon = RegisterEditon_Free;
end;

function TRegisterInfo.getIsPermanent: Boolean;
var
  Year2100 : TDateTime;
begin
  Year2100 := EncodeDate( 2100,1,1 );
  Result := ( RegisterEditon = RegisterEditon_Free ) or
            ( LastDate > Year2100 );
end;

procedure TRegisterInfo.LoadLicense;
var
  RegisterInfoLoad : TRegisterInfoLoad;
begin
  RegisterInfoLoad := TRegisterInfoLoad.Create;
  RegisterInfoLoad.Update;
  RegisterInfoLoad.Free;
end;

procedure TRegisterInfo.SaveLicense(LicenseStr: string);
var
  RegisterInfoSave : TRegisterInfoSave;
begin
  RegisterInfoSave := TRegisterInfoSave.Create( LicenseStr );
  RegisterInfoSave.Update;
  RegisterInfoSave.Free;
end;

{ TWriteAppRunTime }

procedure TUpdateAppRunTime.CheckAppStartTime;
var
  ReadAppStartTime : TReadAppStartTime;
  IsExistStartTimeKey : Boolean;
  WriteAppStartTime : TWriteAppStartTime;
begin
    // 读取 程序开始时间 Key , 判断是否存在
  ReadAppStartTime := TReadAppStartTime.Create;
  ReadAppStartTime.ReadKey;
  IsExistStartTimeKey := ( ReadAppStartTime.RegistryKey <> '' ) or
                         ( ReadAppStartTime.AppDataKey <> '' );
  ReadAppStartTime.Free;

    // 存在 键
  if IsExistStartTimeKey then
    Exit;

    // 不存在则写键
  WriteAppStartTime := TWriteAppStartTime.Create( Now );
  WriteAppStartTime.Update;
  WriteAppStartTime.Free;
end;

constructor TUpdateAppRunTime.Create(_DelRunTime: Integer);
begin
  DelRunTime := _DelRunTime;
end;

procedure TUpdateAppRunTime.UpdateRunTIme;
begin
  RunTime := RunTime + DelRunTime;
end;


procedure TUpdateAppRunTime.ReadRunTime;
var
  ReadAppRunTime : TReadAppRunTime;
begin
  ReadAppRunTime := TReadAppRunTime.Create;
  RunTime := ReadAppRunTime.get;
  ReadAppRunTime.Free;
end;

procedure TUpdateAppRunTime.WriteRunTime;
var
  WriteAppRunTime : TWriteAppRunTime;
begin
  WriteAppRunTime := TWriteAppRunTime.Create( RunTime );
  WriteAppRunTime.Update;
  WriteAppRunTime.Free;
end;

procedure TUpdateAppRunTime.Update;
begin
  ReadRunTime;
  UpdateRunTIme;
  WriteRunTime;

  CheckAppStartTime;
end;

{ TCheckAppOutDate }

function TAppExpiredCheck.CheckAppRunTime: Boolean;
var
  ReadAppStartTime : TReadAppStartTime;
  StartTime, NowTime : TDateTime;
  ReadAppRunTime : TReadAppRunTime;
  RunTime : Int64;
begin
    // 程序开始时间
  ReadAppStartTime := TReadAppStartTime.Create;
  StartTime := ReadAppStartTime.get;
  ReadAppStartTime.Free;

    // 程序运行时间
  ReadAppRunTime := TReadAppRunTime.Create;
  RunTime := ReadAppRunTime.get;
  ReadAppRunTime.Free;

    // 理论上的时间
  NowTime := IncMinute( StartTime, RunTime );

  Result := ExpiredDate > NowTime;
end;

function TAppExpiredCheck.CheckLocalTime: Boolean;
begin
  Result := ExpiredDate > Now;
end;

function TAppExpiredCheck.CheckWebTime: Boolean;
var
  GetWebTime : TGetWebTime;
  ReadWebTime : TReadWebTime;
  WebTime : TDateTime;
  WriteWebTime : TWriteWebTime;
begin
  Result := True;
  if not IsCheckWebTime then
    Exit;

    // 访问网站 获取网络时间
  GetWebTime := TGetWebTime.Create;
  WebTime := GetWebTime.get;
  GetWebTime.Free;

    // 无法访问网站
  if WebTime = -1 then
  begin
      // 读取上一次访问网站的时间
    ReadWebTime := TReadWebTime.Create;
    WebTime := ReadWebTime.get;
    ReadWebTime.Free;
  end
  else
  begin
      // 记录这次访问网站的时间
    WriteWebTime := TWriteWebTime.Create( WebTime );
    WriteWebTime.Update;
    WriteWebTime.Free;
  end;

    // 判断版本是否过期
  Result := ExpiredDate > WebTime;
end;

constructor TAppExpiredCheck.Create(_ExpiredDate: TDateTime);
begin
  ExpiredDate := _ExpiredDate;
end;

function TAppExpiredCheck.getIsExpired: Boolean;
begin
  Result := not CheckLocalTime or
            not CheckWebTime or
            not CheckAppRunTime;
end;

procedure TAppExpiredCheck.SetIsCheckWebTime(_IsCheckWebTime: Boolean);
begin
  IsCheckWebTime := _IsCheckWebTime;
end;

{ TGetWebTime }

function TGetWebTime.FindDateStr: Boolean;
var
  getTimeHttp : TIdHTTP;
begin
  getTimeHttp := TIdHTTP.Create(nil);
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

{ TCheckOutDateThread }

procedure TAppExpiredCheckThread.CheckExpired;
var
  CheckAppExpired : TAppExpiredCheck;
  IsExpired : Boolean;
begin

end;

constructor TAppExpiredCheckThread.Create;
begin
  inherited Create( True );
  IsExpired := True;
end;

destructor TAppExpiredCheckThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  inherited;
end;

procedure TAppExpiredCheckThread.Execute;
var
  StartTime : TDateTime;
begin
  while not Terminated do
  begin
    StartTime := Now;
    while ( not Terminated ) and
          ( IsExpired or ( MinutesBetween( Now, StartTime ) < Time_CheckEdition ) )
    do
      Sleep( 100 );


      // 程序结束
    if Terminated then
      Break;

      // 添加 App运行时间
    WriteAppTime;

      // 检查 过期信息
    CheckExpired;
  end;

  inherited;
end;

procedure TAppExpiredCheckThread.SetIsExpired(_IsExpired: Boolean);
begin
  IsExpired := _IsExpired;
end;

procedure TAppExpiredCheckThread.ShowExpired;
begin

end;

procedure TAppExpiredCheckThread.WriteAppTime;
var
  UpdateAppRunTime : TUpdateAppRunTime;
begin
  UpdateAppRunTime := TUpdateAppRunTime.Create( Time_CheckEdition );
  UpdateAppRunTime.Update;
  UpdateAppRunTime.Free;
end;


{ TRegisterInfoSave }

function TRegisterInfoSave.CheckLicenseStr: Boolean;
var
  iniFile : TIniFile;
  ReadLicenseStr : string;
begin
    // Ini 文件读 Lincense 字符串
  iniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  ReadLicenseStr := iniFile.ReadString( Ini_Register, Ini_License, '' );
  iniFile.Free;

  Result := ReadLicenseStr <> LicenseStr;
end;

constructor TRegisterInfoSave.Create(_LicenseStr: string);
begin
  LicenseStr := _LicenseStr;
end;

procedure TRegisterInfoSave.ResetAppTime;
var
  WriteAppStartTime : TWriteAppStartTime;
  WriteAppRunTime : TWriteAppRunTime;
begin
    // 记录 程序开始运行时间
  WriteAppStartTime := TWriteAppStartTime.Create( Now );
  WriteAppStartTime.Update;
  WriteAppStartTime.Free;

    // 记录 程序运行时间
  WriteAppRunTime := TWriteAppRunTime.Create( 0 );
  WriteAppRunTime.Update;
  WriteAppRunTime.Free;
end;

procedure TRegisterInfoSave.SaveLicenseStr;
var
  IniFile : TIniFile;
begin
    // 写 Ini 文件
  IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  IniFile.WriteString( Ini_Register, Ini_License, LicenseStr );
  IniFile.Free;
end;

procedure TRegisterInfoSave.Update;
begin
    // 相同的 License
  if not CheckLicenseStr then
    Exit;

    // 保存 License
  SaveLicenseStr;

    // 重置 App 时间
  ResetAppTime;
end;

{ FreeEditionUtil }

class function EditionUtil.getEditionInt(RegisterEdition: string): Integer;
begin
  if RegisterEdition = RegisterEditon_Enterprise then
    Result := 2
  else
  if RegisterEdition = RegisterEditon_Professional then
    Result := 1
  else
    Result := 0;
end;

class function EditionUtil.getFileCountLimit(FileCount: Integer): Boolean;
begin
  Result := FileCount > 500;
end;

class function EditionUtil.getFileSpaceLimit(FileSize: Int64): Boolean;
begin
  Result := FileSize > 50 * Size_MB;
end;

{ TMyRegisterControl }

procedure TMyRegisterControl.AddLicense(LicenseStr: string);
begin

end;

{ TAppFreeUserMarkThread }

constructor TAppFreeUserMarkThread.Create;
begin
  inherited Create( True );
  FreeOnTerminate := True;
end;

procedure TAppFreeUserMarkThread.Execute;
var
  Url, HardCode, PcName, PcID : string;
  IdHttp : TIdHTTP;
  ParamList : TStringList;
  LicenseStr : string;
begin
  Url := MyUrl.getTrialKey;
  HardCode := MyMacAddress.getStr;
  PcName := MyComputerName.get;
  PcID := MyComputerID.get;

  ParamList := TStringList.Create;
//  ParamList.Add( HttpReqTrial_HardCode + '=' + HardCode );
//  ParamList.Add( HttpReqTrial_PcName + '=' + PcName );
//  ParamList.Add( HttpReqTrial_PcID + '=' + PcID );
  IdHttp := TIdHTTP.Create(nil);
  try
    LicenseStr := IdHttp.Post( Url, ParamList );
  except
    LicenseStr := '';
  end;
  IdHttp.Free;
  ParamList.Free;

    // 登记
  if LicenseStr <> '' then
    SaveFreeLicense( LicenseStr );
end;

procedure TAppFreeUserMarkThread.SaveFreeLicense( LicenseStr : string );
var
  IniFile : TIniFile;
begin
    // 写 Ini 文件
  IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  IniFile.WriteString( Ini_Register, Ini_License, LicenseStr );
  IniFile.Free;
end;

{ TRegisterUserToWeb }

function TRegisterUserToWeb.IsWebRegister: Boolean;
var
  iniFile : TIniFile;
  LicenseStr, HardCode : string;
  LincenseList : TStringList;
begin
  Result := False;

    // Ini 文件读 Lincense 字符串
  iniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  LicenseStr := iniFile.ReadString( Ini_Register, Ini_License, '' );
  iniFile.Free;

    // 空
  if LicenseStr = '' then
    Exit;

    // 解密
  LicenseStr := KeyDec( LicenseStr );

    // 提取信息
  LincenseList := MySplitStr.getList( LicenseStr, Lincense_Split );
  if LincenseList.Count = 3 then
    Result := MyMacAddress.Equals( LincenseList[ Lincense_HardCode ] );
  LincenseList.Free;
end;

procedure TRegisterUserToWeb.RunRegisterThread;
var
  AppFreeUserMarkThread : TAppFreeUserMarkThread;
begin
  AppFreeUserMarkThread := TAppFreeUserMarkThread.Create;
  AppFreeUserMarkThread.Resume;
end;

procedure TRegisterUserToWeb.Update;
begin
    // 没有注册 则 运行注册线程
//  Register_IsFirst := not IsWebRegister; // 未注册
//  if Register_IsFirst then
//    RunRegisterThread;
end;

end.
