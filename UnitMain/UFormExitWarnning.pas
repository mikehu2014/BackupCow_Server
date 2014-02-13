unit UFormExitWarnning;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrmExitConfirm = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    btnYes: TButton;
    btnNo: TButton;
    ChkIsShow: TCheckBox;
    procedure btnYesClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmExitConfirm: TfrmExitConfirm;

implementation

uses UFormSetting, IniFiles, UMyUtil, UFormUtil;

{$R *.dfm}

procedure TfrmExitConfirm.btnYesClick(Sender: TObject);
var
  IniFile : TIniFile;
begin
    // 没有权限写
  if not MyIniFile.ConfirmWriteIni then
    Exit;

  if ChkIsShow.Checked then
  begin
    IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
    try
      IniFile.WriteBool( frmSetting.Name, frmSetting.chkShowAppExistDialog.Name, False );
    except
    end;
    IniFile.Free;
  end;
end;

procedure TfrmExitConfirm.FormShow(Sender: TObject);
begin
  FormUtil.SetFocuse( btnYes );
end;

end.
