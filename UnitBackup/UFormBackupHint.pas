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

        // 数据
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
    // 显示 log
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
    // Item 信息
  DesItemID := Params.DesItemID;
  BackupPath := Params.BackupPath;

    // 显示标题
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

    // 显示 Item 信息
  MyIcon.Set32Icon( ilShowFile, Params.BackupPath );
  lbFileName.Caption := MyFileInfo.getFileName( Params.BackupPath );
  lbBackupTo.Caption := Params.BackupTo;

    // 显示已备份文件
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

    // 调整窗口位置
  Top := Screen.WorkAreaHeight - Height;
  Left := Screen.WorkAreaWidth - Width;

    // 显示
  Show;
end;

procedure TfrmBackupHint.ShowBackuping(BackupPath, BackupTo: string);
begin
    // 显示标题
  plBackupFiles.Visible := False;
  Self.Height := 80;
  lbTitle.Caption := 'File Backuping';

    // 显示 Item 信息
  MyIcon.Set32Icon( ilShowFile, BackupPath );
  lbFileName.Caption := MyFileInfo.getFileName( BackupPath );
  lbBackupTo.Caption := BackupTo;

    // 调整窗口位置
  Top := Screen.WorkAreaHeight - Height;
  Left := Screen.WorkAreaWidth - Width;

    // 显示
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
