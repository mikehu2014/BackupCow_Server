unit URegisterThread;

interface

uses classes, SysUtils, DateUtils, udebuglock;

type

    // �޸� ϵͳ����ʱ��
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

    // ͳ�Ƴ�������ʱ��
  TRegisterExpiredThread = class( TDebugThread )
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure MarkRunTime;
  end;


    // ��� ����Ƿ����
  TMyRegisterExpiredHandler = class
  public
    IsRun, IsRunThread : Boolean;
    RegisterExpiredThread : TRegisterExpiredThread;
  public
    constructor Create;
    procedure StartRun;
    procedure StopRun;
  end;

var
  MyRegisterExpiredHandler : TMyRegisterExpiredHandler;

implementation

uses URegisterInfoIO;

{ TRegisterExpiredThread }

constructor TRegisterExpiredThread.Create;
begin
  inherited Create;
end;

destructor TRegisterExpiredThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  inherited;
end;

procedure TRegisterExpiredThread.Execute;
var
  StartTime : TDateTime;
begin
  while not Terminated do
  begin
    StartTime := Now;
    if not Terminated and ( MinutesBetween( Now, StartTime ) < 30 ) then
      Sleep( 100 );

    if Terminated then
      Break;

      // 30 ���� ˢ��һ������ʱ��
    MarkRunTime;
  end;
  inherited;
end;

procedure TRegisterExpiredThread.MarkRunTime;
var
  UpdateAppRunTime : TUpdateAppRunTime;
begin
  UpdateAppRunTime := TUpdateAppRunTime.Create( 30 );
  UpdateAppRunTime.Update;
  UpdateAppRunTime.Free;
end;

{ TWriteAppRunTime }

procedure TUpdateAppRunTime.CheckAppStartTime;
var
  ReadAppStartTime : TReadAppStartTime;
  IsExistStartTimeKey : Boolean;
  WriteAppStartTime : TWriteAppStartTime;
begin
    // ��ȡ ����ʼʱ�� Key , �ж��Ƿ����
  ReadAppStartTime := TReadAppStartTime.Create;
  ReadAppStartTime.ReadKey;
  IsExistStartTimeKey := ( ReadAppStartTime.RegistryKey <> '' ) or
                         ( ReadAppStartTime.AppDataKey <> '' );
  ReadAppStartTime.Free;

    // ���� ��
  if IsExistStartTimeKey then
    Exit;

    // ��������д��
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


{ TMyRegisterExpiredHandle }

constructor TMyRegisterExpiredHandler.Create;
begin
  IsRun := True;
  IsRunThread := False;
end;

procedure TMyRegisterExpiredHandler.StartRun;
begin
  if not IsRun then
    Exit;

  IsRunThread := True;
  RegisterExpiredThread := TRegisterExpiredThread.Create;
  RegisterExpiredThread.Resume;
end;

procedure TMyRegisterExpiredHandler.StopRun;
begin
  IsRun := False;
  if IsRunThread then
    RegisterExpiredThread.Free;
end;

end.
