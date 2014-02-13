unit uDebugLock;

interface

uses
  Classes, Windows, SysUtils;

type
  TDebugLockItem = packed record
    ThreadId: Cardinal;
    ThreadName: string;
    Msg: string;
    MsgLast: string;
    LastTick: Cardinal;
  end;
  PDebugLockItem = ^TDebugLockItem;

  TDebugLock = class
    FLock: TRTLCriticalSection;
    FList: TList;
  public
    procedure Lock;
    procedure Unlock;
    procedure Clean;
  public
    constructor Create;
    destructor Destroy; override;
  public
    procedure AddDebug(ThreadId: Cardinal; ThreadName: string );
    procedure RemoveDebug(ThreadId: Cardinal);
  public
    procedure Debug(Msg: string);overload;
    procedure Debug( MsgType, MsgStr : string );overload;
    procedure DebugFile(Msg, FilePath: string);
    function TrackDebug: string;
  end;

  MyThreadDebugUtil = class
  public
    class procedure AddDebug( t : TThread );
    class procedure RemoveDebug(t : TThread );
  end;


    // ¸¸Ïß³Ì
  TDebugThread = class( TThread )
  public
    constructor Create;
    destructor Destroy; override;
  end;

var
  DebugLock: TDebugLock;

implementation

{ TDebugLock }

procedure TDebugLock.AddDebug(ThreadId: Cardinal; ThreadName: string);
var
  DebugLockItem: PDebugLockItem;
begin
  New(DebugLockItem);
  DebugLockItem^.ThreadId := ThreadId;
  DebugLockItem^.ThreadName := ThreadName;
  DebugLockItem^.Msg := '';
  DebugLockItem^.MsgLast := '';
  DebugLockItem^.LastTick := GetTickCount;
  Lock;
  try
    FList.Add(DebugLockItem);
  finally
    Unlock;
  end;
end;

procedure TDebugLock.Clean;
var
  I: Integer;
begin
  Lock;
  try
    for I := 0 to FList.Count - 1 do
    begin
      Dispose(PDebugLockItem(FList.Items[I]));
    end;
    FList.Clear;
  finally
    Unlock;
  end;
end;

constructor TDebugLock.Create;
begin
  inherited Create;
  InitializeCriticalSection(FLock);
  FList := TList.Create;
end;

procedure TDebugLock.Debug(Msg: string);
var
  ThreadId: Cardinal;
  I: Integer;
begin
  ThreadId := GetCurrentThreadId;
  Lock;
  try
    for I := 0 to FList.Count - 1 do
      if PDebugLockItem(FList.Items[I])^.ThreadId = ThreadId then
      begin
        PDebugLockItem(FList.Items[I])^.Msg := PDebugLockItem(FList.Items[I])^.MsgLast;
        PDebugLockItem(FList.Items[I])^.MsgLast := Msg;
        PDebugLockItem(FList.Items[I])^.LastTick := GetTickCount;
        Break;
      end;
  except
  end;
  Unlock;
end;

procedure TDebugLock.Debug(MsgType, MsgStr: string);
begin
  Debug( MsgType + ': ' + MsgStr );
end;

procedure TDebugLock.DebugFile(Msg, FilePath: string);
var
  FileName : string;
begin
  FileName := ExtractFileName( FilePath );
  if FileName = '' then
    FileName := FilePath;
  Debug( Msg + ': ' + FileName );
end;

destructor TDebugLock.Destroy;
begin
  Clean;
  FList.Free;
  DeleteCriticalSection(FLock);
  inherited Destroy;
end;

procedure TDebugLock.Lock;
begin
  EnterCriticalSection(FLock);
end;

procedure TDebugLock.RemoveDebug(ThreadId: Cardinal);
var
  I: Integer;
  DebugLockItem: PDebugLockItem;
begin
  DebugLockItem := nil;
  Lock;
  try
    for I := 0 to FList.Count - 1 do
    begin
      if PDebugLockItem(FList.Items[I])^.ThreadId = ThreadId then
      begin
        DebugLockItem := FList.Items[I];
        FList.Delete(I);
        Break;
      end;
    end;
  finally
    Unlock;
  end;
  if DebugLockItem <> nil then
  begin
    Dispose(DebugLockItem);
  end;
end;

function TDebugLock.TrackDebug: string;
var
  I: Integer;
  DebugLockItem: PDebugLockItem;
  s : string;
begin
  Result := '--TDebugLock.TrackDebug--' + #13#10 + #13#10;
  Lock;
  try
    for I := 0 to FList.Count - 1 do
    begin
      DebugLockItem := FList.Items[I];
      s := 'ThreadId: ' + IntToStr( DebugLockItem^.ThreadId ) + #13#10;
      s := s + 'ThreadName: ' + DebugLockItem^.ThreadName + #13#10;
      s := s + 'Msg: ' + DebugLockItem^.Msg + #13#10;
      s := s + 'LastMsg: ' + DebugLockItem^.MsgLast + #13#10;
      s := s + 'LastTick: ' + IntToStr( GetTickCount - DebugLockItem^.LastTick ) + #13#10;
      Result := Result + s + #13#10;
   end;
  except
  end;
  Unlock;

//      Result := Result + Format('ThreadId: %u, Msg: %s -> LastMsg: %s, LastTick: %dms'
//        , [DebugLockItem^.ThreadId, DebugLockItem^.Msg, DebugLockItem^.MsgLast, GetTickCount - DebugLockItem^.LastTick]) + #13#10;

end;

procedure TDebugLock.Unlock;
begin
  LeaveCriticalSection(FLock);
end;

{ MyThreadDebugUtil }

class procedure MyThreadDebugUtil.AddDebug(t: TThread);
begin
  try
    DebugLock.AddDebug( t.ThreadID, t.ClassName );
  except
  end;
end;

class procedure MyThreadDebugUtil.RemoveDebug(t: TThread);
begin
  try
    DebugLock.RemoveDebug( t.ThreadID );
  except
  end;
end;

{ TAppThread }

constructor TDebugThread.Create;
begin
  inherited Create( True );
  MyThreadDebugUtil.AddDebug( Self );
end;

destructor TDebugThread.Destroy;
begin
  MyThreadDebugUtil.RemoveDebug( Self );
  inherited;
end;

initialization
  DebugLock := TDebugLock.Create;

finalization
  DebugLock.Free;

end.

