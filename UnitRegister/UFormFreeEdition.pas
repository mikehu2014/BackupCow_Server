unit UFormFreeEdition;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls, ImgList;

type
  TfrmFreeEdition = class(TForm)
    ilEdition: TImageList;
    plEditionCompare: TPanel;
    lvEditionCompare: TListView;
    Panel1: TPanel;
    btnBuyNow: TButton;
    btnClose: TButton;
    procedure btnCloseClick(Sender: TObject);
    procedure btnBuyNowClick(Sender: TObject);
  end;

var
  frmFreeEdition: TfrmFreeEdition;

implementation

uses UMyUtil, UMyUrl;

{$R *.dfm}

{ TfrmFreeEdition }

procedure TfrmFreeEdition.btnBuyNowClick(Sender: TObject);
begin
  MyInternetExplorer.OpenWeb( MyUrl.BuyNow );
end;

procedure TfrmFreeEdition.btnCloseClick(Sender: TObject);
begin
  Close;
end;

end.
