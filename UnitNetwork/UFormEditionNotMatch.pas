unit UFormEditionNotMatch;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ExtCtrls, UMainForm, UFormUtil;

type
  TfrmEditonNotMatch = class(TForm)
    lvComputer: TListView;
    plMain: TPanel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmEditonNotMatch: TfrmEditonNotMatch;

implementation

{$R *.dfm}

procedure TfrmEditonNotMatch.FormCreate(Sender: TObject);
begin
  ListviewUtil.BindRemoveData( lvComputer );
end;

end.
