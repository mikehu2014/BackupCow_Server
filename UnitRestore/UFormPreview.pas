unit UFormPreview;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, math, RzTabs, Generics.Collections,
  RzPanel, Vcl.ComCtrls, Vcl.ToolWin, Winapi.GDIPAPI, Winapi.GDIPOBJ, Vcl.ImgList, Winapi.ActiveX,
  Vcl.Grids, Vcl.ValEdit, Vcl.Menus;

type



  TfrmPreView = class(TForm)
    PcMain: TRzPageControl;
    tsPirture: TRzTabSheet;
    tsText: TRzTabSheet;
    ilPicture: TImage;
    plMain: TPanel;
    ilTb: TImageList;
    plCenter: TPanel;
    tsDoc: TRzTabSheet;
    reDoc: TRichEdit;
    tsExcel: TRzTabSheet;
    LvExcel: TListView;
    tsZip: TRzTabSheet;
    LvZip: TListView;
    tsExe: TRzTabSheet;
    tsMusic: TRzTabSheet;
    plPreviewTitle: TPanel;
    ImgPreview: TImage;
    edtPreviewPath: TEdit;
    veMusic: TValueListEditor;
    veExe: TValueListEditor;
    pbPreview: TProgressBar;
    tmrProgress: TTimer;
    pmSelect: TPopupMenu;
    miDownRun: TMenuItem;
    miDownExplorer: TMenuItem;
    ilTbGray: TImageList;
    plStatus: TPanel;
    Image1: TImage;
    lbStatus: TLabel;
    plSearch: TPanel;
    Label1: TLabel;
    cbbSearchName: TComboBox;
    btnNext: TButton;
    plTextCenter: TPanel;
    plSearchNotFind: TPanel;
    Image2: TImage;
    Label2: TLabel;
    mmoPreview: TMemo;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure tmrProgressTimer(Sender: TObject);
    procedure tbtnRunClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnNextClick(Sender: TObject);
    procedure cbbSearchNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure rePreviewKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure mmoPreviewKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    procedure AddSearchHistory( SearchName : string );
    procedure SaveIni;
    procedure LoadIni;
  public
    FilePath : string;
  public
    procedure SetIniPosition( FormHandle : Integer );
    procedure SetPreviewFile( _FilePath : string );
  end;

      // 预览文件入口
  TPreviewFileHandle = class
  public
    FilePath : string;
  public
    constructor Create( _FilePath : string );
    procedure Update;
  private
    procedure SetMainForm;
    procedure PreviewPicture;
    procedure PreviewWord;
    procedure PreviewExcel;
    procedure PreviewCompress;
    procedure PreviewExe;
    procedure PreviewText;
    procedure PreviewMusic;
  end;

const
  ImgTag_Next = 1;
  ImgTag_Last = 2;

var
  frmPreView: TfrmPreView;
  PreviewForm_IsShow : Boolean = False;

  Original_Width : Integer;
  Original_Height : Integer;

implementation

uses UMyUtil, UIconUtil, UFormRestoreExplorer, UFormSelectRestore, UFormBackupLog, IniFiles, UFormUtil;

{$R *.dfm}

procedure TfrmPreView.AddSearchHistory(SearchName: string);
var
  i: Integer;
begin
    // 已存在
  if cbbSearchName.Items.IndexOf( SearchName ) >= 0 then
    Exit;

    // 超过限制，删除组后一个
  if cbbSearchName.Items.Count >= 10 then
    cbbSearchName.Items.Delete( 9 );

    // 添加
  cbbSearchName.Items.Insert( 0, SearchName );
end;

procedure TfrmPreView.btnNextClick(Sender: TObject);
var
  StartPos, FindPos : Integer;
  SearchText:string;
  FullText : string;
begin
  try
    SearchText := LowerCase( cbbSearchName.Text ); //查找edit1中输入的文本
    StartPos := mmoPreview.SelStart + mmoPreview.SelLength;
    FullText := LowerCase( mmoPreview.Text );
    FullText := Copy( FullText, StartPos + 1, length( FullText ) - StartPos );

    FindPos := Pos( SearchText, FullText ); //求出首次出现SearchText的位置
    if FindPos <= 0 then // 找不到，则从头开始
    begin
      StartPos := 0;
      FullText := LowerCase( mmoPreview.Text );
      FindPos := Pos( SearchText, FullText );
      if FindPos <= 0 then // 没有找到
      begin
        plSearchNotFind.Visible := True;
        Exit;
      end;
    end;

    mmoPreview.SelStart := StartPos + FindPos - 1;
    mmoPreview.SelLength := length( SearchText );
    FormUtil.SetFocuse( mmoPreview );  //这一句很重要，否则就会看不到文字被选中

    plSearchNotFind.Visible := False;;

      // 添加到历史
    AddSearchHistory( SearchText );
  except
  end;
end;

procedure TfrmPreView.cbbSearchNameKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    btnNext.Click;
end;

procedure TfrmPreView.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  PreviewForm_IsShow := False;
  if frmRestoreExplorer.Showing then
    frmRestoreExplorer.ClosePreviewForm;
  if frmBackupLog.Showing then
    frmBackupLog.ClosePreviewForm;
end;

procedure TfrmPreView.FormCreate(Sender: TObject);
begin
  LvZip.SmallImages := MyIcon.getSysIcon;
  LoadIni;
end;

procedure TfrmPreView.FormDestroy(Sender: TObject);
begin
  SaveIni;
end;

procedure TfrmPreView.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TfrmPreView.FormShow(Sender: TObject);
begin
  PreviewForm_IsShow := True;
end;

procedure TfrmPreView.LoadIni;
var
  IniFile : TIniFile;
  i, ItemCount: Integer;
  s : string;
begin
  IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  ItemCount := IniFile.ReadInteger( Self.Name, cbbSearchName.Name + 'Count', 0 );
  for i := 0 to ItemCount - 1 do
  begin
    s := IniFile.ReadString( Self.Name, cbbSearchName.Name + IntToStr(i), '' );
    cbbSearchName.Items.Add( s );
  end;
  IniFile.Free;
end;

procedure TfrmPreView.mmoPreviewKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    btnNext.Click;
end;

procedure TfrmPreView.rePreviewKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    btnNext.Click;
end;

procedure TfrmPreView.SaveIni;
var
  IniFile : TIniFile;
  i: Integer;
begin
    // 没有权限写
  if not MyIniFile.ConfirmWriteIni then
    Exit;

  IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  try
    IniFile.WriteInteger( Self.Name, cbbSearchName.Name + 'Count', cbbSearchName.Items.Count );
    for i := 0 to cbbSearchName.Items.Count - 1 do
      IniFile.WriteString( Self.Name, cbbSearchName.Name + IntToStr(i), cbbSearchName.Items[i] );
  except
  end;
  IniFile.Free;
end;

procedure TfrmPreView.SetIniPosition( FormHandle : Integer );
var
  R:TRect;
begin
  try
    GetWindowRect( FormHandle, R );
    Height := 446;
    Width := 476;
    Original_Height := Height;
    Original_Width := Width;
    MoveWindow( Handle, r.Left - Width, r.Top, Width, Height, True );
  except
  end;
  Show;
end;

procedure TfrmPreView.SetPreviewFile(_FilePath: string);
var
  PreviewFileHandle : TPreviewFileHandle;
begin
  FilePath := _FilePath;

  PreviewFileHandle := TPreviewFileHandle.Create( FilePath );
  PreviewFileHandle.Update;
  PreviewFileHandle.Free;
end;

procedure TfrmPreView.tmrProgressTimer(Sender: TObject);
begin
  tmrProgress.Enabled := False;
  pbPreview.Style := pbstMarquee;
  pbPreview.Visible := True;
end;

procedure TfrmPreView.tbtnRunClick(Sender: TObject);
begin

end;

{ TPreviewFileHandle }

constructor TPreviewFileHandle.Create(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TPreviewFileHandle.PreviewExcel;
begin
  frmPreView.PcMain.ActivePage := frmPreView.tsExcel;
  frmPreView.LvExcel.Items.Clear;
  frmPreView.LvExcel.Columns.Clear;
end;

procedure TPreviewFileHandle.PreviewExe;
begin
  frmPreView.PcMain.ActivePage := frmPreView.tsExe;
  with frmPreView do
    veExe.Strings.Clear;
end;

procedure TPreviewFileHandle.PreviewMusic;
begin
  frmPreView.PcMain.ActivePage := frmPreView.tsMusic;
  with frmPreView do
    veMusic.Strings.Clear;
end;

procedure TPreviewFileHandle.PreviewPicture;
begin
  frmPreView.PcMain.ActivePage := frmPreView.tsPirture;
  frmPreView.ilPicture.Picture := nil;
end;

procedure TPreviewFileHandle.PreviewText;
begin
  frmPreView.PcMain.ActivePage := frmPreView.tsText;
  frmPreView.mmoPreview.Clear;
end;

procedure TPreviewFileHandle.PreviewWord;
begin
  frmPreView.PcMain.ActivePage := frmPreView.tsDoc;
  frmPreView.reDoc.Clear;
end;

procedure TPreviewFileHandle.SetMainForm;
begin
  frmPreView.edtPreviewPath.Text := FilePath;
  frmPreView.Caption := ExtractFileName( FilePath ) + ' - Preview';

  try
    MyIcon.getSysIcon32.GetIcon( MyIcon.getIconByFileExt( FilePath ), frmPreView.ImgPreview.Picture.Icon );
  except
  end;
end;

procedure TPreviewFileHandle.PreviewCompress;
begin
  frmPreView.PcMain.ActivePage := frmPreView.tsZip;
  frmPreView.LvZip.Items.Clear;
end;

procedure TPreviewFileHandle.Update;
begin
    // 设置正在预览的文件
  SetMainForm;

    // 预览图片
  if MyPictureUtil.getIsPictureFile( FilePath ) then
    PreviewPicture
  else  // 预览 word
  if MyPreviewUtil.getIsDocFile( FilePath )  then
    PreviewWord
  else  // 预览 Excel
  if MyPreviewUtil.getIsExcelFile( FilePath ) then
    PreviewExcel
  else  // 预览 Zip
  if MyPreviewUtil.getIsCompressFile( FilePath ) then
    PreviewCompress
  else  // 预览 Exe
  if MyPreviewUtil.getIsExeFile( FilePath ) then
    PreviewExe
  else  // 预览 Music
  if MyPreviewUtil.getIsMusicFile( FilePath ) then
    PreviewMusic
  else   // 以文本方式预览
    PreviewText;
end;


end.
