unit UFormRestoreChildTo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls;

type
  TfrmRestoreChildTo = class(TForm)
    lvFiles: TListView;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    procedure SetTitle( FolderPath : string );
    procedure ShowChild( PathList : TStringList );
    procedure SetIniPosition( FormHandle : Integer );
  end;

var
  frmRestoreChildTo: TfrmRestoreChildTo;

implementation

uses UIconUtil, UMyUtil;

{$R *.dfm}

{ TfrmRestoreChildTo }

procedure TfrmRestoreChildTo.SetIniPosition(FormHandle: Integer);
var
  R:TRect;
begin
  try
    GetWindowRect( FormHandle, R );
    MoveWindow( Handle, r.Left + r.Width, r.Top, Width, Height, True );
    Show;
  except
  end;
end;

procedure TfrmRestoreChildTo.SetTitle(FolderPath: string);
begin
  Caption := FolderPath;
end;

procedure TfrmRestoreChildTo.ShowChild(PathList: TStringList);
var
  i: Integer;
  PathStrList : TStringList;
  FileName : string;
  IsFile : Boolean;
begin
  lvFiles.Clear;
  for i := 0 to PathList.Count - 1 do
  begin
    PathStrList := MySplitStr.getList( PathList[i], '|' );
    if PathStrList.Count = 2 then
    begin
      FileName := PathStrList[0];
      IsFile := StrToBoolDef( PathStrList[1], True );
      with lvFiles.Items.Add do
      begin
        Caption := FileName;
        if IsFile then
          ImageIndex := MyIcon.getIconByFileExt( FileName )
        else
          ImageIndex := MyShellIconUtil.getFolderIcon;
      end;
    end;
    PathStrList.Free;
  end;
end;

procedure TfrmRestoreChildTo.FormCreate(Sender: TObject);
begin
  lvFiles.SmallImages := MyIcon.getSysIcon;
end;

end.
