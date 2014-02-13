unit UFormRestoreConfirm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.ToolWin, UMainForm;

type
  TfrmUserConfirm = class(TForm)
    lvConfirm: TListView;
    Panel2: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    tbMain: TToolBar;
    tbtnSelectAll: TToolButton;
    tbtnUnselectAll: TToolButton;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tbtnSelectAllClick(Sender: TObject);
    procedure tbtnUnselectAllClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure ClearItems;
    function getIsConfirm : Boolean;
    function getCancelList : TStringList;
  end;

    // 数据结构
  TRestoreConfirmData = class
  public
    LocalPath, RestorePath : string;
    LocalSize, RestoreSize : Int64;
    LocalDate, RestoreDate : TDateTime;
    Action : string;
  public
    constructor Create( _LocalPath, _RestorePath : string );
    procedure SetSizeInfo( _LocalSize, _RestoreSize : Int64 );
    procedure SetDateInfo( _LocalDate, _RestoreDate : TDateTime );
  end;

    // 添加
  TRestoreConfirmItemAdd = class
  public
    LocalPath, RestorePath : string;
    LocalSize, RestoreSize : Int64;
    LocalDate, RestoreDate : TDateTime;
  public
    constructor Create( _LocalPath, _RestorePath : string );
    procedure SetSizeInfo( _LocalSize, _RestoreSize : Int64 );
    procedure SetDateInfo( _LocalDate, _RestoreDate : TDateTime );
    procedure Update;
  end;

var
  frmUserConfirm: TfrmUserConfirm;

implementation

uses UIconUtil, UFormUtil, DateUtils;

{$R *.dfm}

{ TRestoreConfirmData }

constructor TRestoreConfirmData.Create(_LocalPath, _RestorePath: string);
begin
  LocalPath := _LocalPath;
  RestorePath := _RestorePath;
end;

procedure TRestoreConfirmData.SetDateInfo(_LocalDate, _RestoreDate: TDateTime);
begin
  LocalDate := _LocalDate;
  RestoreDate := _RestoreDate;
end;

procedure TRestoreConfirmData.SetSizeInfo(_LocalSize, _RestoreSize: Int64);
begin
  LocalSize := _LocalSize;
  RestoreSize := _RestoreSize;
end;

{ TRestoreConfirmItemAdd }

constructor TRestoreConfirmItemAdd.Create(_LocalPath, _RestorePath: string);
begin
  LocalPath := _LocalPath;
  RestorePath := _RestorePath;
end;

procedure TRestoreConfirmItemAdd.SetDateInfo(_LocalDate,
  _RestoreDate: TDateTime);
begin
  LocalDate := _LocalDate;
  RestoreDate := _RestoreDate;
end;

procedure TRestoreConfirmItemAdd.SetSizeInfo(_LocalSize, _RestoreSize: Int64);
begin
  LocalSize := _LocalSize;
  RestoreSize := _RestoreSize;
end;

procedure TRestoreConfirmItemAdd.Update;
var
  lvConfirm : TListView;
  ItemData : TRestoreConfirmData;
begin
  lvConfirm := frmUserConfirm.lvConfirm;
  ItemData := TRestoreConfirmData.Create( LocalPath, RestorePath );
  ItemData.SetSizeInfo( LocalSize, RestoreSize );
  ItemData.SetDateInfo( LocalDate, RestoreDate );
  with lvConfirm.Items.Add do
  begin
    Caption := ExtractFileName( LocalPath );
    SubItems.Add( DateTimeToStr( TTimeZone.Local.ToLocalTime( LocalDate ) ) );
    SubItems.Add( DateTimeToStr( TTimeZone.Local.ToLocalTime( RestoreDate ) ) );
    ImageIndex := MyIcon.getIconByFilePath( LocalPath );
    Data := ItemData;
    Checked := True;
  end;
end;

{ TfrmUserConfirm }

procedure TfrmUserConfirm.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmUserConfirm.btnOKClick(Sender: TObject);
begin
  Close;
  ModalResult := mrOk;
end;

procedure TfrmUserConfirm.ClearItems;
begin
  lvConfirm.Clear;
end;

procedure TfrmUserConfirm.FormCreate(Sender: TObject);
begin
  lvConfirm.SmallImages := MyIcon.getSysIcon;
  ListviewUtil.BindRemoveData( lvConfirm );
end;

procedure TfrmUserConfirm.FormShow(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

function TfrmUserConfirm.getCancelList: TStringList;
var
  i: Integer;
  ItemData : TRestoreConfirmData;
begin
  Result := TStringList.Create;
  for i := 0 to lvConfirm.Items.Count - 1 do
  begin
    if lvConfirm.Items[i].Checked then
      Continue;
    ItemData := lvConfirm.Items[i].Data;
    Result.Add( ItemData.LocalPath );
  end;
end;

function TfrmUserConfirm.getIsConfirm: Boolean;
begin
  Result := ShowModal = mrOk;
end;

procedure TfrmUserConfirm.tbtnSelectAllClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to lvConfirm.Items.Count - 1 do
    lvConfirm.Items[i].Checked := True;
end;

procedure TfrmUserConfirm.tbtnUnselectAllClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to lvConfirm.Items.Count - 1 do
    lvConfirm.Items[i].Checked := False;
end;

end.
