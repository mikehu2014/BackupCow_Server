unit UDataSetInfo;

interface

uses Syncobjs;

type

  TMyDataInfo = class
  public
    DataLock : TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
  public
    procedure EnterData;
    procedure LeaveData;
  end;

implementation

{ TMyDataInfo }

constructor TMyDataInfo.Create;
begin
  DataLock := TCriticalSection.Create;
end;

destructor TMyDataInfo.Destroy;
begin
  DataLock.Free;
  inherited;
end;

procedure TMyDataInfo.EnterData;
begin
  DataLock.Enter;
end;

procedure TMyDataInfo.LeaveData;
begin
  DataLock.Leave;
end;

end.
