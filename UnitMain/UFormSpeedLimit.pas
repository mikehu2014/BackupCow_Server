unit UFormSpeedLimit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfrmSpeedLimit = class(TForm)
    rbNoLimit: TRadioButton;
    rbLimit: TRadioButton;
    edtSpeed: TEdit;
    cbbSpeedType: TComboBox;
    btnOK: TButton;
    btnCancel: TButton;
    procedure rbNoLimitClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    function getIsLimit : Boolean;
    function getSpeedType : string;
    function getSpeedValue : string;
  end;

var
  frmSpeedLimit: TfrmSpeedLimit;

implementation

{$R *.dfm}

procedure TfrmSpeedLimit.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmSpeedLimit.btnOKClick(Sender: TObject);
begin
  Close;
  ModalResult := mrOk;
end;

procedure TfrmSpeedLimit.FormShow(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

function TfrmSpeedLimit.getIsLimit: Boolean;
begin

end;

function TfrmSpeedLimit.getSpeedType: string;
begin

end;

function TfrmSpeedLimit.getSpeedValue: string;
begin

end;

procedure TfrmSpeedLimit.rbNoLimitClick(Sender: TObject);
var
  IsEnable : Boolean;
begin
  IsEnable := rbLimit.Checked;
  edtSpeed.Enabled := IsEnable;
  cbbSpeedType.Enabled := IsEnable;
end;

end.
