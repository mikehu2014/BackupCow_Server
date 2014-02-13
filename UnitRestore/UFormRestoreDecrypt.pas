unit UFormRestoreDecrypt;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type

  TDecryptParams = record
  public
    RestorePath, OwnerName, RestoreFromName : string;
    PasswordHint, PasswordMD5 : string;
    IsFile : Boolean;
  end;

  TfrmDecrypt = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    lbOwner: TLabel;
    Label4: TLabel;
    lbRestoreFrom: TLabel;
    igShow: TImage;
    edtPath: TEdit;
    lbPasswordHint: TLabel;
    edtPasswordHint: TEdit;
    edtPassword: TEdit;
    lbPassword: TLabel;
    btnOK: TButton;
    BtnCancel: TButton;
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure edtPasswordKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    PasswordMD5 : string;
  public
    function getPassword( Params : TDecryptParams ): string;
  end;

var
  frmDecrypt: TfrmDecrypt;

implementation

uses UMyUtil, UIconUtil, UMainForm, UFormUtil;

{$R *.dfm}

{ TfrmDecrypt }

procedure TfrmDecrypt.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmDecrypt.btnOKClick(Sender: TObject);
begin
  if MyEncrypt.EncodeMD5String( edtPassword.Text ) <> PasswordMD5 then
  begin
    MyMessageBox.ShowWarnning( 'Password is incorrect.' );
    Exit;
  end;

  Close;
  ModalResult := mrOk;
end;

procedure TfrmDecrypt.edtPasswordKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_Return then
    btnOK.Click;
end;

procedure TfrmDecrypt.FormShow(Sender: TObject);
begin
  ModalResult := mrCancel;
  FormUtil.SetFocuse( edtPassword );
end;

function TfrmDecrypt.getPassword( Params : TDecryptParams ): string;
begin
  edtPath.Text := Params.RestorePath;
  lbOwner.Caption := Params.OwnerName;
  lbRestoreFrom.Caption := Params.RestoreFromName;

  edtPasswordHint.Text := Params.PasswordHint;
  edtPassword.Text :='';
  PasswordMD5 := Params.PasswordMD5;

        // œ‘ æÕº±Í
  try
    if Params.IsFile then
      MyIcon.getSysIcon32.GetIcon( MyIcon.getIconByFileExt( Params.RestorePath ), igShow.Picture.Icon )
    else
      frmMainForm.ilFolder.GetIcon( 0, igShow.Picture.Icon );
  except
  end;

  if ShowModal = mrOk then
    Result := edtPassword.Text
  else
    Result := '';
end;

end.
