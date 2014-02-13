unit UFormBackupHint;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls;

type

  THintParams = record
  public
    DesItemID, BackupPath : string;
    BackupTo : string;
  public
    TotalBackup : Integer;
    BackupFileList : TStringList;
  end;

  TfrmBackupHint = class(TForm)
    plHintTitle: TPanel;
    ilTitle: TImage;
    tbnClose: TButton;
    Panel1: TPanel;
    lbTitle: TLabel;
    plMain: TPanel;
    ilShowFile: TImage;
    Label1: TLabel;
    Label2: TLabel;
    lbBackupTo: TLabel;
    lbFileName: TLabel;
    tmrClose: TTimer;
    plBackupFiles: TPanel;
    lvFileBackup: TListView;
    Panel2: TPanel;
    lbBackupFiles: TLabel;
    btnShowLog: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tmrCloseTimer(Sender: TObject);
    procedure tbnCloseClick(Sender: TObject);
    procedure lvFileBackupMouseEnter(Sender: TObject);
    procedure lvFileBackupMouseLeave(Sender: TObject);
    procedure lvFileBackupMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure btnShowLogClick(Sender: TObject);
  private
    DesItemID, BackupPath : string;
  public
    procedure ShowBackuping( BackupPath, BackupTo : string );
    procedure ShowBackupCompleted( Params : THintParams );
  end;

        // ����
  TLvHintData = class
  public
    FilePath : string;
  public
    constructor Create( _FilePath : string );
  end;

var
  frmBackupHint: TfrmBackupHint;

implementation

uses UMyUtil, UIconUtil, UFormUtil, UFormBackupLog, UMyBackupApiInfo;

{$R *.dfm}

{ TfrmBackupHint }

procedure TfrmBackupHint.btnShowLogClick(Sender: TObject);
begin
    // ��ʾ log
  try
    frmBackupLog.SetItemInfo( DesItemID, BackupPath );
    BackupLogApi.RefreshLogFace( DesItemID, BackupPath );
    frmBackupLog.ShowLog;
  except
  end;
end;

procedure TfrmBackupHint.FormCreate(Sender: TObject);
begin
  lvFileBackup.SmallImages := MyIcon.getSysIcon;
  ListviewUtil.BindRemoveData( lvFileBackup );
end;

procedure TfrmBackupHint.FormShow(Sender: TObject);
begin
  tmrClose.Enabled := True;
end;

procedure TfrmBackupHint.lvFileBackupMouseEnter(Sender: TObject);
begin
  tmrClose.Enabled := False;
end;

procedure TfrmBackupHint.lvFileBackupMouseLeave(Sender: TObject);
begin
  tmrClose.Enabled := True;
end;

procedure TfrmBackupHint.lvFileBackupMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  SelectItem : TListItem;
  ItemData : TLvHintData;
  HintStr : string;
begin
  SelectItem := lvFileBackup.GetItemAt( x, Y );
  if Assigned( SelectItem ) then
  begin
    ItemData := SelectItem.Data;
    HintStr := ItemData.FilePath;
  end
  else
    HintStr := '';

  lvFileBackup.Hint := HintStr;
end;

procedure TfrmBackupHint.ShowBackupCompleted(Params: THintParams);
var
  BackupFileList : TStringList;
  i: Integer;
begin
    // Item ��Ϣ
  DesItemID := Params.DesItemID;
  BackupPath := Params.BackupPath;

    // ��ʾ����
  if Params.TotalBackup > 0 then
  begin
    Self.Height := 180;
    plBackupFiles.Visible := True;
  end
  else
  begin
    Self.Height := 80;
    plBackupFiles.Visible := False;
  end;
  lbTitle.Caption := 'Backup File Completed';

    // ��ʾ Item ��Ϣ
  MyIcon.Set32Icon( ilShowFile, Params.BackupPath );
  lbFileName.Caption := MyFileInfo.getFileName( Params.BackupPath );
  lbBackupTo.Caption := Params.BackupTo;

    // ��ʾ�ѱ����ļ�
  lbBackupFiles.Caption := IntToStr( Params.TotalBackup ) + ' files has been backed up';
  BackupFileList := Params.BackupFileList;
  lvFileBackup.Clear;
  for i := 0 to BackupFileList.Count - 1 do
    with lvFileBackup.Items.Add do
    begin
      Caption := MyFileInfo.getFileName( BackupFileList[i] );
      ImageIndex := MyIcon.getIconByFilePath( BackupFileList[i] );
      Data := TLvHintData.Create( BackupFileList[i] );
    end;

    // ��������λ��
  Top := Screen.WorkAreaHeight - Height;
  Left := Screen.WorkAreaWidth - Width;

    // ��ʾ
  Show;
end;

procedure TfrmBackupHint.ShowBackuping(BackupPath, BackupTo: string);
begin
    // ��ʾ����
  plBackupFiles.Visible := False;
  Self.Height := 80;
  lbTitle.Caption := 'File Backuping';

    // ��ʾ Item ��Ϣ
  MyIcon.Set32Icon( ilShowFile, BackupPath );
  lbFileName.Caption := MyFileInfo.getFileName( BackupPath );
  lbBackupTo.Caption := BackupTo;

    // ��������λ��
  Top := Screen.WorkAreaHeight - Height;
  Left := Screen.WorkAreaWidth - Width;

    // ��ʾ
  Show;
end;

procedure TfrmBackupHint.tbnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmBackupHint.tmrCloseTimer(Sender: TObject);
begin
  tmrClose.Enabled := False;
  Close;
end;

{ TLvHintData }

constructor TLvHintData.Create(_FilePath: string);
begin
  FilePath := _FilePath;
end;


end.
