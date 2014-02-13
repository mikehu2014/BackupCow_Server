unit UFormFreeEdition;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls, ImgList;

type
  TfrmFreeEdition = class(TForm)
    nbMain: TNotebook;
    plEditionCompare: TPanel;
    Panel2: TPanel;
    lvEditionCompare: TListView;
    plError: TPanel;
    lbDisplay: TLabel;
    IWarnning: TImage;
    Panel1: TPanel;
    btnBuyNow: TButton;
    btnClose: TButton;
    plImfomationBtn: TPanel;
    btnMoreInfomation: TButton;
    btnErrorClose: TButton;
    ilEdition: TImageList;
    procedure btnMoreInfomationClick(Sender: TObject);
    procedure btnErrorCloseClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnBuyNowClick(Sender: TObject);
  private
    procedure SetEdtionComparePage;
  public
    procedure ShowWarnning( WarnningStr : string );
    procedure ShowInfomation;
  end;

const
  Page_Error = 0;
  Page_EditionCompare = 1;

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

procedure TfrmFreeEdition.btnErrorCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmFreeEdition.btnMoreInfomationClick(Sender: TObject);
begin
  SetEdtionComparePage;
end;

procedure TfrmFreeEdition.SetEdtionComparePage;
begin
  nbMain.PageIndex := Page_EditionCompare;
  Self.Width := 520;
  Self.Height := 212;
end;

procedure TfrmFreeEdition.ShowInfomation;
begin
  SetEdtionComparePage;
  Show;
end;

procedure TfrmFreeEdition.ShowWarnning(WarnningStr: string);
var
  btnInfomationWidth : Integer;
begin
  lbDisplay.Caption := WarnningStr;
  nbMain.PageIndex := Page_Error;
  Self.Width := lbDisplay.Left + lbDisplay.Width + 30;
  Self.Height := plImfomationBtn.Top + plImfomationBtn.Height + 50;
  plImfomationBtn.Left := IWarnning.Left + ( ( lbDisplay.Left - IWarnning.Left + lbDisplay.Width - plImfomationBtn.Width ) div 2 );
  Show;
end;

end.
