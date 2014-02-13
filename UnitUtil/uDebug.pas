{******************************************************************************}
{Create By: David                                                              }
{******************************************************************************}

{ 调试单元 }
unit uDebug;

interface

uses
  SysUtils, Windows, IdContext, IdSync, IdSchedulerOfThread;

procedure DebugLog(Msg: WideString; filename: string); overload;
procedure DebugLog(Msg: WideString); overload;
procedure DebugLog(Msg: WideString; const Args: array of const); overload;
procedure Logger(AContext: TIdContext; s: string); overload;
procedure Logger(s: string); overload;
procedure DebugMemo(Msg: string);

implementation

//uses
//  fMain;

var
  FLogLock: TRTLCriticalSection;
  FMemoLock: TRTLCriticalSection;

procedure DebugLog(Msg: WideString; filename: string);
var
  F: TextFile;
begin
  EnterCriticalSection(FLogLock);
  try
    try
      AssignFile(F, filename);

      if FileExists(FileName) then
        Append(F)
      else
        Rewrite(F);

      Writeln( F, DateTimeToStr(Now) + '   ' + Msg ); { Read first line of file }
      Writeln( F, '' );
      CloseFile(F);
    except
    end;
  finally
    LeaveCriticalSection(FLogLock);
  end;
end;

procedure DebugLog(Msg: WideString);
begin
  DebugLog(Msg, ExtractFilePath(Paramstr(0)) + 'Log\Log.' + FormatDateTime('yyyymmdd', Date) + '.txt');      
end;

procedure DebugLog(Msg: WideString; const Args: array of const);
begin
  DebugLog(Format(Msg, Args));
end;

procedure DebugLogx(s: string);
begin
 //frmMain.mmoLog.Lines.Add(datetimetostr(now)+' '+s);
end;

procedure Logger(AContext: TIdContext; s: string);
begin
//  if not frmMain.chkDebug.Checked then
//    Exit;
//  frmmain.LogStr_Lock;
  try
//    frmMain.LogStr_Write(s);
//    TIdSync.SynchronizeMethod(frmMain.LogStr_Update); //Indy10同步
//    TIdYarnOfThread(AContext.Yarn).Thread.Synchronize(frmMain.LogStr_Update);
  finally
//    frmmain.LogStr_Release;
  end;
end;

procedure Logger(s: string);
begin
//  if not frmMain.chkDebug.Checked then
//    Exit;
//  frmMain.mmoDebug.Lines.Add(s);
  Exit;

//  frmmain.LogStr_Lock;
  try
//    frmMain.LogStr_Write(s);
//    frmMain.LogStr_Update;
  finally
//    frmmain.LogStr_Release;
  end;
end;

procedure DebugMemo(Msg: string);
begin
  EnterCriticalSection(FMemoLock);
  try
//    frmMain.mmoDebug.Lines.Add(Msg);
  finally
    LeaveCriticalSection(FMemoLock);
  end;
end;

initialization
  InitializeCriticalSection(FLogLock);
  InitializeCriticalSection(FMemoLock);

finalization
  DeleteCriticalSection(FLogLock);
  DeleteCriticalSection(FMemoLock);

end.

