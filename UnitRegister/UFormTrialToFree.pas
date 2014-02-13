unit UFormTrialToFree;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TfrmTrialToFree = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    btnBuyNow: TButton;
    btnUseFree: TButton;
    btnEditionCompare: TButton;
    Image1: TImage;
    procedure btnBuyNowClick(Sender: TObject);
    procedure btnUseFreeClick(Sender: TObject);
    procedure btnEditionCompareClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmTrialToFree: TfrmTrialToFree;

implementation

uses UFormRegister, UMyUtil, UMyUrl;

{$R *.dfm}

procedure TfrmTrialToFree.btnBuyNowClick(Sender: TObject);
begin
  Close;

  frmRegister.Show;
  MyInternetExplorer.OpenWeb( MyProductUrl.BuyNow );
end;

procedure TfrmTrialToFree.btnUseFreeClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmTrialToFree.btnEditionCompareClick(Sender: TObject);
begin
  MyInternetExplorer.OpenWeb( MyProductUrl.EditionCompare );
end;

end.
