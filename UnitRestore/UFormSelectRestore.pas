unit UFormSelectRestore;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, UMyUtil,
  Vcl.ExtCtrls, UIconUtil;

type

  TShowResotreParams = record
  public
    RestorePath, OwnerPcName, RestoreFromName : string;
    IsFile, IsDeleted : Boolean;
  end;

  TfrmSelectRestore = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    lbOwner: TLabel;
    Label4: TLabel;
    lbRestoreFrom: TLabel;
    igShow: TImage;
    edtPath: TEdit;
    btnBrows: TButton;
    Label3: TLabel;
    btnCancel: TButton;
    btnOK: TButton;
    cbbRestoreTo: TComboBox;
    tmrDetails: TTimer;
    procedure FormShow(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnBrowsClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tmrDetailsTimer(Sender: TObject);
  private
    Params : TShowResotreParams;
  public
    function getRestoreTo( _Params : TShowResotreParams ): string;overload;
    function getRestoreTo( _Params : TShowResotreParams; ChildList : TStringList ): string;overload;
  private
    function getSavePath: string;
    procedure IniRestoreTo;
  end;



const
  ShowHint_RestoreTo = 'Please select files or folders you wish to save';

var
  frmSelectRestore: TfrmSelectRestore;

implementation

uses UMainForm, UFormRestoreChildTo, UFormUtil;

{$R *.dfm}

procedure TfrmSelectRestore.btnBrowsClick(Sender: TObject);
var
  SelectFolder : string;
begin
  SelectFolder := '';
  if not MySelectFolderDialog.Select( ShowHint_RestoreTo, '', SelectFolder ) then
    Exit;
  if Params.IsFile then
    SelectFolder := MyFilePath.getPath( SelectFolder ) + ExtractFileName( Params.RestorePath );

    // 添加路径
  cbbRestoreTo.Items.Add( SelectFolder );
  cbbRestoreTo.ItemIndex := cbbRestoreTo.Items.Count - 1;
end;

procedure TfrmSelectRestore.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmSelectRestore.btnOKClick(Sender: TObject);
begin
  Close;
  ModalResult := mrOk;
end;

procedure TfrmSelectRestore.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  frmRestoreChildTo.Close;
end;

procedure TfrmSelectRestore.FormShow(Sender: TObject);
begin
  ModalResult := mrCancel;
  FormUtil.SetFocuse( btnOK );
end;

function TfrmSelectRestore.getRestoreTo(_Params: TShowResotreParams): string;
begin
  Result := getRestoreTo( _Params, nil );
end;

function TfrmSelectRestore.getRestoreTo(_Params: TShowResotreParams;
  ChildList: TStringList): string;
begin
  Params := _Params;

    // 基本信息
  edtPath.Text := Params.RestorePath;
  lbOwner.Caption := Params.OwnerPcName;
  lbRestoreFrom.Caption := Params.RestoreFromName;

      // 显示图标
  try
    if Params.IsFile then
      MyIcon.getSysIcon32.GetIcon( MyIcon.getIconByFileExt( Params.RestorePath ), igShow.Picture.Icon )
    else
      frmMainForm.ilFolder.GetIcon( 0, igShow.Picture.Icon );
  except
  end;

    // 初始化保存路径
  IniRestoreTo;

    // 显示子路径
  if ChildList <> nil then
  begin
    frmRestoreChildTo.SetTitle( Params.RestorePath );
    frmRestoreChildTo.ShowChild( ChildList );
    tmrDetails.Enabled := True;
  end;

    // 显示窗口
  if ShowModal = mrOk then
    Result := cbbRestoreTo.Text
  else
    Result := '';
end;

function TfrmSelectRestore.getSavePath: string;
var
  SavePath : string;
begin
  SavePath := Params.RestorePath;

    // 网上邻居
  if MyNetworkFolderUtil.IsNetworkFolder( SavePath ) then
    SavePath := MyFilePath.getDownloadPath( SavePath );

    // 磁盘可用路径
  SavePath := MyHardDisk.getAvailablePath( SavePath );

  Result := SavePath;
end;

procedure TfrmSelectRestore.IniRestoreTo;
var
  TempSavePath : string;
begin
  TempSavePath := MyHardDisk.getBiggestHardDIsk + 'BackupCow.Restore\';
  TempSavePath := TempSavePath + ExtractFileName( Params.RestorePath );

  cbbRestoreTo.Clear;
  cbbRestoreTo.Items.Add( getSavePath );
  cbbRestoreTo.Items.Add( TempSavePath );
  cbbRestoreTo.ItemIndex := 0;
end;

procedure TfrmSelectRestore.tmrDetailsTimer(Sender: TObject);
begin
  tmrDetails.Enabled := False;
  frmRestoreChildTo.SetIniPosition( Self.Handle );
end;

end.
