unit UFormFreeTips;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Imaging.pngimage, RzTabs, Vcl.Imaging.jpeg, Vcl.Imaging.GIFImg;

type
  TfrmFreeTips = class(TForm)
    Panel1: TPanel;
    plRestoreTitle: TPanel;
    pcMain: TRzPageControl;
    tsBackupCow: TRzTabSheet;
    plTitle: TPanel;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label13: TLabel;
    lkBackupCow: TLinkLabel;
    btnLater: TButton;
    tsc4s: TRzTabSheet;
    plContent: TPanel;
    Panel2: TPanel;
    Label3: TLabel;
    Panel3: TPanel;
    Image2: TImage;
    Label5: TLabel;
    Label6: TLabel;
    lkc4s: TLinkLabel;
    tsKeywordCompeting: TRzTabSheet;
    Panel4: TPanel;
    Label7: TLabel;
    Panel5: TPanel;
    Image3: TImage;
    Label8: TLabel;
    Label9: TLabel;
    lkKeyword: TLinkLabel;
    tsDuplicateFilter: TRzTabSheet;
    Panel6: TPanel;
    Label10: TLabel;
    Panel7: TPanel;
    Image4: TImage;
    Label11: TLabel;
    Label12: TLabel;
    lkDuplicate: TLinkLabel;
    tsTextFinding: TRzTabSheet;
    Panel8: TPanel;
    Label14: TLabel;
    Panel9: TPanel;
    Image5: TImage;
    Label15: TLabel;
    Label16: TLabel;
    lkTextFinding: TLinkLabel;
    btnRegister: TButton;
    procedure btnLaterClick(Sender: TObject);
    procedure lkBackupCowLinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure lkc4sLinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure lkKeywordLinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure lkDuplicateLinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure lkTextFindingLinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure btnRegisterClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure MarkAdsClick( AdsName : string );
  public
    function ShowRandomPage: Boolean;
  end;

var
  frmFreeTips: TfrmFreeTips;

implementation

uses UMyUtil, UMyUrl, UFormRegister, UMyRegisterApiInfo;

{$R *.dfm}

procedure TfrmFreeTips.btnLaterClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmFreeTips.lkTextFindingLinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  MyInternetExplorer.OpenWeb( MyOtherWebUrl.getTextFinding );
  MarkAdsClick( AdsName_TextFinding );
end;

procedure TfrmFreeTips.btnRegisterClick(Sender: TObject);
begin
  Close;
  ModalResult := mrOk;

  frmRegister.Show;
  MyInternetExplorer.OpenWeb( MyProductUrl.BuyNow );
end;

procedure TfrmFreeTips.FormShow(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmFreeTips.lkBackupCowLinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  MyInternetExplorer.OpenWeb( MyOtherWebUrl.getFolderTransfer );
  MarkAdsClick( AdsName_FolderTransfer );
end;

procedure TfrmFreeTips.lkc4sLinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  MyInternetExplorer.OpenWeb( MyOtherWebUrl.getC4s );
  MarkAdsClick( AdsName_c4s );
end;

procedure TfrmFreeTips.lkDuplicateLinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  MyInternetExplorer.OpenWeb( MyOtherWebUrl.getDuplicateFilter );
  MarkAdsClick( AdsName_DuplicateFilter );
end;

procedure TfrmFreeTips.lkKeywordLinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  MyInternetExplorer.OpenWeb( MyOtherWebUrl.getKeywordCompeting );
  MarkAdsClick( AdsName_KeywordCompeting );
end;

procedure TfrmFreeTips.MarkAdsClick(AdsName: string);
begin
  try
    Application.ProcessMessages;
    RegisterLimitApi.MarkAdsClick( AdsName );
  except
  end;
end;

function TfrmFreeTips.ShowRandomPage: Boolean;
begin
  Randomize;
  pcMain.ActivePageIndex := Random( pcMain.PageCount );
  Result := ShowModal = mrCancel;
end;

end.
