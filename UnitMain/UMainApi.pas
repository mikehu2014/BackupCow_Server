unit UMainApi;

interface

type

  MyHintAppApi = class
  public
    class procedure ShowBackuping( FileName, Destination : string; IsFile : Boolean );
    class procedure ShowBackupCompleted( FileName, Destination : string; IsFile : Boolean );
  public
    class procedure ShowRestoring( FileName, Destination : string; IsFile : Boolean );
    class procedure ShowRestoreCompelted( FileName, Destination : string; IsFile : Boolean );
  public
    class procedure SetShowHintTime( ShowHintTime : Integer );
  end;

implementation

uses UMainFormFace, USettingInfo;

{ MyHintAppApi }

class procedure MyHintAppApi.SetShowHintTime(ShowHintTime: Integer);
var
  ShowHintTimeSetFace : TShowHintTimeSetFace;
begin
  ShowHintTimeSetFace := TShowHintTimeSetFace.Create( ShowHintTime );
  ShowHintTimeSetFace.AddChange;
end;

class procedure MyHintAppApi.ShowRestoreCompelted(FileName,
  Destination: string; IsFile : Boolean);
var
  ShowHintWriteFace : TShowHintWriteFace;
begin
  if not HintSettingInfo.IsShowRestorCompleted then
    Exit;

  ShowHintWriteFace := TShowHintWriteFace.Create( FileName, Destination );
  ShowHintWriteFace.SetIsFile( IsFile );
  ShowHintWriteFace.SetHintType( HintType_RestoreCompelted );
  ShowHintWriteFace.AddChange;
end;

class procedure MyHintAppApi.ShowRestoring(FileName, Destination: string;
  IsFile : Boolean);
var
  ShowHintWriteFace : TShowHintWriteFace;
begin
  if not HintSettingInfo.IsShowRestoring then
    Exit;

  ShowHintWriteFace := TShowHintWriteFace.Create( FileName, Destination );
  ShowHintWriteFace.SetIsFile( IsFile );
  ShowHintWriteFace.SetHintType( HintType_Restoring );
  ShowHintWriteFace.AddChange;
end;

class procedure MyHintAppApi.ShowBackupCompleted(FileName, Destination: string;
  IsFile : Boolean);
var
  ShowHintWriteFace : TShowHintWriteFace;
begin
  if not HintSettingInfo.IsShowBackupCompleted then
    Exit;

  ShowHintWriteFace := TShowHintWriteFace.Create( FileName, Destination );
  ShowHintWriteFace.SetIsFile( IsFile );
  ShowHintWriteFace.SetHintType( HintType_BackupCompleted );
  ShowHintWriteFace.AddChange;
end;

class procedure MyHintAppApi.ShowBackuping(FileName, Destination: string;
  IsFile : Boolean);
var
  ShowHintWriteFace : TShowHintWriteFace;
begin
  if not HintSettingInfo.IsShowBackuping then
    Exit;

  ShowHintWriteFace := TShowHintWriteFace.Create( FileName, Destination );
  ShowHintWriteFace.SetIsFile( IsFile );
  ShowHintWriteFace.SetHintType( HintType_Backuping );
  ShowHintWriteFace.AddChange;
end;

end.
