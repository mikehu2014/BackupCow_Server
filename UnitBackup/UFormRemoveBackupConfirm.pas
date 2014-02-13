unit UFormRemoveBackupConfirm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TfrmBackupDelete = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    btnYes: TButton;
    btnNo: TButton;
    ChkIsDelete: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure btnNoClick(Sender: TObject);
    procedure btnYesClick(Sender: TObject);
  private
    { Private declarations }
  public
    function getIsRemove : Boolean;
    function getIsDelete : Boolean;
  end;

var
  frmBackupDelete: TfrmBackupDelete;

implementation

uses UFormUtil;

{$R *.dfm}

{ TfrmBackupDelete }

procedure TfrmBackupDelete.btnNoClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmBackupDelete.btnYesClick(Sender: TObject);
begin
  Close;
  ModalResult := mrOk;
end;

procedure TfrmBackupDelete.FormShow(Sender: TObject);
begin
  ModalResult := mrCancel;
  ChkIsDelete.Checked := True;
  FormUtil.SetFocuse( btnYes );
end;

function TfrmBackupDelete.getIsDelete: Boolean;
begin
  Result := ChkIsDelete.Checked;
end;

function TfrmBackupDelete.getIsRemove: Boolean;
begin
  Result := ShowModal = mrOk;
end;

end.
