unit UFormBackupingHint;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, RzPrgres;

type
  TfrmBackupingHint = class(TForm)
    ilShowFile: TImage;
    lbDestination: TLabel;
    lbFileName: TLabel;
    plRestoreTitle: TPanel;
    Image1: TImage;
    tbnClose: TButton;
    Panel1: TPanel;
    lbTitle: TLabel;
    Label1: TLabel;
    lbBackupTo: TLabel;
    Panel2: TPanel;
    pbBackup: TRzProgressBar;
    lbFiles: TLabel;
    lbFileCount: TLabel;
    Label2: TLabel;
    lbFileSize: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmBackupingHint: TfrmBackupingHint;

implementation

{$R *.dfm}

end.
