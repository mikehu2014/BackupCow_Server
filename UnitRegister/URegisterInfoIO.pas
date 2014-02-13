unit URegisterInfoIO;

interface

uses classes,SysUtils, inifiles, Registry, Math, ShlObj, UMyUtil, Windows, Forms, Winapi.ShellAPI;

type

{$Region ' ��/д ������Ϣ ���� '}

  ReadAppDataUtil = class
  public
    class function getAppDataPath : string;
  end;

  TLocalInfoHandle = class
  protected
    RegKey : string;
    AppKey : string;
  public
    AppDataKey : string;
    RegistryKey : string;
  public
    constructor Create( _RegKey, _AppKey : string );
  end;

    // ��ȡ��Ϣ ����
  TReadLocalInfo = class( TLocalInfoHandle )
  public
    procedure ReadKey;
  private
    procedure ReadAppDataKey;
    procedure ReadRegistryKey;
    function Decode( EncodeKey : string ):string;
  end;

    // д����Ϣ ����
  TWriteLocalInfo = class( TLocalInfoHandle )
  public
    procedure WriteKey;
  private
    function Encode( DecodeKey : string ): string;
    procedure WriteAppDataKey;
    procedure WriteRegistryKey;
  end;

{$EndRegion}

{$Region ' ��/д ϵͳ����ʱ�� '}

      // ��ȡ ϵͳ����ʱ��
  TReadAppRunTime = class( TReadLocalInfo )
  public
    constructor Create;
    function get : Int64;
  end;

    // д�� ϵͳ����ʱ��
  TWriteAppRunTime = class( TWriteLocalInfo )
  private
    RunTime : Int64;
  public
    constructor Create( _RunTime : Int64 );
    procedure Update;
  end;

{$EndRegion}

{$Region ' ��/д ϵͳ����ʱ�� ' }

    // ��ȡ ϵͳ����ʱ��
  TReadAppStartTime = class( TReadLocalInfo )
  public
    constructor Create;
    function get : TDateTime;
  end;

    // д�� ϵͳ����ʱ��
  TWriteAppStartTime = class( TWriteLocalInfo )
  private
    StartTime : TDateTime;
  public
    constructor Create( _StartTime : TDateTime );
    procedure Update;
  end;

{$EndRegion}

{$Region ' ��/д ����ʱ�� ' }

    // ��ȡ ����ʱ��
  TReadWebTime = class( TReadLocalInfo )
  public
    constructor Create;
    function get : TDateTime;
  end;

    // д�� ����ʱ��
  TWriteWebTime = class( TWriteLocalInfo )
  private
    WebTime : TDateTime;
  public
    constructor Create( _WebTime : TDateTime );
    procedure Update;
  end;

{$EndRegion}

{$Region ' ��/д ����ע��ʱ�� ' }

    // ��ȡ ����ʱ��
  TReadLocalTrial = class( TReadLocalInfo )
  public
    constructor Create;
    function get : TDateTime;
    function getIsWrite : Boolean;
  end;

    // д�� ����ʱ��
  TWriteLocalTrial = class( TWriteLocalInfo )
  private
    LocalTrial : TDateTime;
  public
    constructor Create( _LocalTrial : TDateTime );
    procedure Update;
  end;


{$EndRegion}

{$Region ' д ���򿪻��Զ����� ' }

    // �����Զ�����
  RunAppStartupUtil = class
  public
    class function Startup( IsRun : Boolean ): Boolean;
  end;

{$EndRegion}

{$Region ' ����ԱȨ�� д���� ' }

  MyAppAdminRunasUtil = class
  public
    class function StartUp( IsRun : Boolean ): Boolean; // ����ʱ����
    class function SetAppDataModify : Boolean; // ���� AppData ���޸�
  public              // ������ڵ���
    class function getIsRunAsAdmin( Params : string ): Boolean;
  private
    class function RunAs( Params : string ): Boolean;
    class function RunAsAdmin( hWnd : HWND; aFile, aParameters : string ): Boolean;
  end;

{$EndRegion}

const
  AppRunParams_Hide = 'h';
  AppRunParams_StartUpOpen = 'suo';
  AppRunParams_StartUpClose = 'suc';
  AppRunParams_AppDataModify = 'adm';

const
  RegKey_Root : string = '\Software\BackupCow';

const
  RegKey_StartTime : string = 'BackupFiles';
  RegKey_RunTime : string = 'BackupFolders';
  RegKey_WebTime : string = 'BackupPaths';
  RegKey_LocalTrial : string = 'BackupCopys';

  AppData_BackupCow : string = 'MyData.dat';
  AppData_SectionName : string = 'BackupData';
  AppData_StartTime : string = 'BackupFiles';
  AppData_RunTime : string = 'BackupFolders';
  AppData_WebTime : string = 'BackupPaths';
  AppData_LocalTrial : string = 'BackupCopys';

  RegKeyPath_AppRun = '\SOFTWARE\Microsoft\windows\CurrentVersion\Run';

implementation

{ TWriteAppRunTime }

constructor TWriteAppRunTime.Create(_RunTime: Int64);
begin
  inherited Create( RegKey_RunTime, AppData_RunTime );

  RunTime := _RunTime;
end;

procedure TWriteAppRunTime.Update;
begin
  RegistryKey := IntToStr( RunTime );
  AppDataKey := IntToStr( RunTime );

  WriteKey;
end;


{ TReadAppRunTime }


constructor TReadAppRunTime.Create;
begin
  inherited Create( RegKey_RunTime, AppData_RunTime );
end;

function TReadAppRunTime.get: Int64;
var
  RegTime, AppTime, MaxTime : Int64;
begin
  ReadKey;

  RegTime := StrToInt64Def( RegistryKey, 0 );
  AppTime := StrToInt64Def( AppDataKey, 0 );

  MaxTime := max( RegTime, AppTime );
  Result := max( 0, MaxTime );
end;

{ TReadLocalInfo }

function TReadLocalInfo.Decode(EncodeKey: string): string;
begin
  Result := MyEncrypt.DecodeStr( EncodeKey );
end;

procedure TReadLocalInfo.ReadAppDataKey;
var
  AppIni : TIniFile;
  AppDataPath : string;
begin
  AppDataKey := '';

  AppDataPath := ReadAppDataUtil.getAppDataPath;
  if FileExists( AppDataPath ) then
  begin
    AppIni := TIniFile.Create( AppDataPath );
    AppDataKey := AppIni.ReadString( AppData_SectionName, AppKey, '' );
    AppDataKey := Decode( AppDataKey );
    AppIni.Free;
  end;
end;


procedure TReadLocalInfo.ReadKey;
begin
  try
    ReadAppDataKey;

    ReadRegistryKey;
  except
  end;
end;

procedure TReadLocalInfo.ReadRegistryKey;
var
  Reg : TRegistry;
begin
  RegistryKey := '';

  Reg := TRegistry.Create;
  if Reg.OpenKey( RegKey_Root, False ) then
  begin
    RegistryKey := Reg.ReadString( RegKey );
    if RegistryKey <> '' then
      RegistryKey := Decode( RegistryKey );
    Reg.CloseKey;
  end;
  Reg.Free;
end;

{ TLocalInfoHandle }

constructor TLocalInfoHandle.Create(_RegKey, _AppKey: string);
begin
  RegKey := _RegKey;
  AppKey := _AppKey;
end;

{ TWriteLocalInfo }

function TWriteLocalInfo.Encode(DecodeKey: string): string;
begin
  Result := MyEncrypt.EncodeStr( DecodeKey );
end;

procedure TWriteLocalInfo.WriteAppDataKey;
var
  AppIni : TIniFile;
  AppDataPath : string;
begin
  AppDataKey := Encode( AppDataKey );

  AppDataPath := ReadAppDataUtil.getAppDataPath;
  ForceDirectories( ExtractFileDir( AppDataPath ) );
  AppIni := TIniFile.Create( AppDataPath );
  try
    AppIni.WriteString( AppData_SectionName, AppKey, AppDataKey );
  except
  end;
  AppIni.Free;
end;

procedure TWriteLocalInfo.WriteKey;
begin
  try
    WriteRegistryKey;

    WriteAppDataKey;
  except
  end;
end;

procedure TWriteLocalInfo.WriteRegistryKey;
var
  Reg : TRegistry;
begin
  RegistryKey := Encode( RegistryKey );

  Reg := TRegistry.Create;
  if Reg.OpenKey( RegKey_Root, True ) then
  begin
    Reg.WriteString( RegKey, RegistryKey );
    Reg.CloseKey;
  end;
  Reg.Free;
end;

{ TReadAppStartTime }

constructor TReadAppStartTime.Create;
begin
  inherited Create( RegKey_StartTime, AppData_StartTime );
end;

function TReadAppStartTime.get: TDateTime;
var
  RegStartTime, AppDataStartTime, MinTime : TDateTime;
begin
  ReadKey;

  RegStartTime := StrToFloatDef( RegistryKey, Now );
  AppDataStartTime := StrToFloatDef( RegistryKey, Now );

  Result := Min( RegStartTime, AppDataStartTime );
end;

{ TWriteAppStartTime }

constructor TWriteAppStartTime.Create(_StartTime: TDateTime);
begin
  inherited Create( RegKey_StartTime, AppData_StartTime );
  StartTime := _StartTime;
end;

procedure TWriteAppStartTime.Update;
begin
  RegistryKey := FloatToStr( StartTime );
  AppDataKey := FloatToStr( StartTime );

  WriteKey;
end;

{ ReadAppDataUtil }

class function ReadAppDataUtil.getAppDataPath: string;
begin
  Result := MyAppDataUtil.getPath + AppData_BackupCow;
end;

{ TReadWebTime }

constructor TReadWebTime.Create;
begin
  inherited Create( RegKey_WebTime, AppData_WebTime );
end;

function TReadWebTime.get: TDateTime;
var
  RegWebTime, AppDataWebTime, MinTime : TDateTime;
begin
  ReadKey;

  RegWebTime := StrToFloatDef( RegistryKey, Now );
  AppDataWebTime := StrToFloatDef( AppDataKey, Now );

  Result := Max( RegWebTime, AppDataWebTime );
end;

{ TWriteWebTime }

constructor TWriteWebTime.Create(_WebTime: TDateTime);
begin
  inherited Create( RegKey_WebTime, AppData_WebTime );
  WebTime := _WebTime;
end;

procedure TWriteWebTime.Update;
begin
  RegistryKey := FloatToStr( WebTime );
  AppDataKey := FloatToStr( WebTime );

  WriteKey;
end;

{ TReadLocalTrial }

constructor TReadLocalTrial.Create;
begin
  inherited Create( RegKey_LocalTrial, AppData_LocalTrial );
end;

function TReadLocalTrial.get: TDateTime;
var
  RegLocalTrial, AppDataLocalTrial, MinTime : TDateTime;
begin
  ReadKey;

  RegLocalTrial := StrToFloatDef( RegistryKey, Now );
  AppDataLocalTrial := StrToFloatDef( AppDataKey, Now );

  Result := Min( RegLocalTrial, AppDataLocalTrial );
end;

function TReadLocalTrial.getIsWrite: Boolean;
begin
  ReadKey;

  Result := ( RegistryKey <> '' ) or ( AppDataKey <> '' );
end;

{ TWriteLocalTrial }

constructor TWriteLocalTrial.Create(_LocalTrial: TDateTime);
begin
  inherited Create( RegKey_LocalTrial, AppData_LocalTrial );
  LocalTrial := _LocalTrial;
end;

procedure TWriteLocalTrial.Update;
begin
  RegistryKey := FloatToStr( LocalTrial );
  AppDataKey := FloatToStr( LocalTrial );

  WriteKey;
end;

{ RunAppStartupUtil }

  //�����Զ�����
class function RunAppStartupUtil.Startup(IsRun: Boolean): Boolean;
var
  Reg:TRegistry;
  AppName : string;
begin
  AppName := 'BackupCow';

  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    Result := Reg.OpenKey( RegKeyPath_AppRun, True );
    if IsRun then
      Reg.writeString( AppName, Application.Exename + ' ' + AppRunParams_Hide )
    else
      Reg.DeleteValue( AppName );
    Reg.CloseKey;
  except
    Result := False;
  end;
  Reg.Free;
end;

{ MyAppAdminRunasUtil }

class function MyAppAdminRunasUtil.getIsRunAsAdmin(Params: string): Boolean;
begin
  Result := True;
  if Params = AppRunParams_StartUpOpen then
    RunAppStartupUtil.Startup( True )
  else
  if Params = AppRunParams_StartUpClose then
    RunAppStartupUtil.Startup( False )
  else
  if Params = AppRunParams_AppDataModify then
    MyAppDataUtil.SetAppDataModify
  else
    Result := False;
end;

class function MyAppAdminRunasUtil.RunAs(Params: string): Boolean;
begin
  Result := RunAsAdmin( 0, Application.ExeName, Params );
end;

class function MyAppAdminRunasUtil.RunAsAdmin(hWnd: HWND; aFile,
  aParameters: string): Boolean;
var
  sei: _SHELLEXECUTEINFOW;
begin
  try
    FillChar(sei, SizeOf(sei), 0);
    sei.cbSize := SizeOf(sei);
    sei.Wnd := hWnd;
    sei.fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI;
    sei.lpVerb := 'runas';
    sei.lpFile := PChar(aFile);
    sei.lpParameters := PChar(aParameters);
    sei.nShow := SW_SHOWNORMAL;
    Result := ShellExecuteEx(@sei);
  except
    Result := False;
  end;

     // �û�ȡ������
  if not Result then
    RaiseLastOSError;
end;

class function MyAppAdminRunasUtil.SetAppDataModify: Boolean;
begin
  Result := RunAs( AppRunParams_AppDataModify );
end;

class function MyAppAdminRunasUtil.StartUp(IsRun: Boolean): Boolean;
begin
  if IsRun then
    Result := RunAs( AppRunParams_StartUpOpen )
  else
    Result := RunAs( AppRunParams_StartUpClose );
end;

end.
