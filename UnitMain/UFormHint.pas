unit UFormHint;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.ToolWin, UMainForm, UIconUtil;

type

  TShowHintParams = record
  public
    FileName, Destination : string;
    IsFile : Boolean;
    FormCaption, DestinationType : string;
  end;

  TfrmHint = class(TForm)
    plRestoreTitle: TPanel;
    tbnClose: TButton;
    Panel1: TPanel;
    lbTitle: TLabel;
    lbFileName: TLabel;
    lbDestination: TLabel;
    tmrClose: TTimer;
    ilTitle: TImage;
    tbMain: TToolBar;
    tbtnExplorer: TToolButton;
    tbtnRun: TToolButton;
    ilShowFile: TImage;
    procedure tmrCloseTimer(Sender: TObject);
    procedure FormMouseEnter(Sender: TObject);
    procedure FormMouseLeave(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tbtnExplorerClick(Sender: TObject);
    procedure tbtnRunClick(Sender: TObject);
    procedure tbnCloseClick(Sender: TObject);
  private
    FilePath : string;
  public
    procedure ShowBackuping( Params : TShowHintParams );
    procedure ShowBackupCompleted( Params : TShowHintParams );
  public
    procedure ShowRestoring( Params : TShowHintParams );
    procedure ShowRestoreCompelted( Params : TShowHintParams );
  private
    procedure ShowHint( Params : TShowHintParams );
  end;



const
  FormCaption_Backuping = 'File Backuping';
  FormCaption_BackupCompleted = 'Backup File Completed';

  FormCaption_Restoring = 'File Restoring';
  FormCaption_RestoreCompelted = 'Restore File Completed';

const
  Destination_BackupTo = 'Backup To';
  Destination_RestoreFrom = 'Restore From';

var
  frmHint: TfrmHint;

implementation

uses UMyUtil, UFormUtil;

{$R *.dfm}

procedure TfrmHint.FormCreate(Sender: TObject);
begin
  Top := Screen.WorkAreaHeight - Height;
  Left := Screen.WorkAreaWidth - Width;
  FormUtil.BindEseClose( Self );
end;

procedure TfrmHint.FormMouseEnter(Sender: TObject);
begin
  tmrClose.Enabled := False;
end;

procedure TfrmHint.FormMouseLeave(Sender: TObject);
begin
  tmrClose.Enabled := True;
end;

procedure TfrmHint.ShowHint(Params : TShowHintParams);
begin
  FilePath := Params.FileName;
  tbtnExplorer.Enabled := True;
  tbtnRun.Enabled := Params.IsFile;

  try
    if Params.IsFile then
      MyIcon.getSysIcon32.GetIcon( MyIcon.getIconByFilePath( FilePath ), ilShowFile.Picture.Icon )
    else
      frmMainForm.ilFolder.GetIcon( 0, ilShowFile.Picture.Icon );
  except
  end;

  lbTitle.Caption := Params.FormCaption;
  lbFileName.Caption := 'File Name: ' + ExtractFileName( Params.FileName );
  lbDestination.Caption := Params.DestinationType + ': ' + Params.Destination;
  tmrClose.Enabled := False;
  tmrClose.Enabled := True;
  Show;
end;

procedure TfrmHint.ShowRestoreCompelted(Params : TShowHintParams);
begin
  Params.FormCaption := FormCaption_RestoreCompelted;
  Params.DestinationType := Destination_RestoreFrom;
  ShowHint( Params );
end;

procedure TfrmHint.ShowRestoring(Params : TShowHintParams);
begin
  Params.FormCaption := FormCaption_Restoring;
  Params.DestinationType := Destination_RestoreFrom;
  ShowHint( Params );
end;

procedure TfrmHint.ShowBackupCompleted(Params : TShowHintParams);
begin
  Params.FormCaption := FormCaption_BackupCompleted;
  Params.DestinationType := Destination_BackupTo;
  ShowHint( Params );
end;

procedure TfrmHint.ShowBackuping(Params : TShowHintParams);
begin
  Params.FormCaption := FormCaption_Backuping;
  Params.DestinationType := Destination_BackupTo;
  ShowHint( Params );
end;

procedure TfrmHint.tbnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmHint.tbtnExplorerClick(Sender: TObject);
begin
  MyExplore.OpenFolder( FilePath );
end;

procedure TfrmHint.tbtnRunClick(Sender: TObject);
begin
  MyExplore.OpenFile( FilePath );
end;

procedure TfrmHint.tmrCloseTimer(Sender: TObject);
begin
  Close;
  tmrClose.Enabled := False;
end;

end.
