unit UFormAbout;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, GIFImg;

type
  TfrmAbout = class(TForm)
    plBackupCow: TPanel;
    CodingBest: TLabel;
    ilApp: TImage;
    lbApp: TLabel;
    lbEdition: TLabel;
    llbApp: TLinkLabel;
    procedure llbAppLinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure ilAppDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    function getAppEdition : string;
  public
    { Public declarations }
  end;

const
  PageIndex_BackupCow = 0;
  PageIndex_FolderTransfer = 1;

var
  frmAbout: TfrmAbout;
  AppEdition_IsReset : Boolean = False;

implementation

uses UMyUtil, UAppEditionInfo, UMainForm, UMyUrl, UFormUtil;

{$R *.dfm}

procedure TfrmAbout.FormCreate(Sender: TObject);
begin
  lbEdition.Caption := getAppEdition;
  FormUtil.BindEseClose( Self );
end;

function TfrmAbout.getAppEdition: string;
var
  InfoSize, Wnd: DWORD;
  VerBuf: Pointer;
  szName: array[0..255] of Char;
  Value: Pointer;
  Len: UINT;
  TransString:string;
begin
  InfoSize := GetFileVersionInfoSize(PChar(Application.ExeName), Wnd);
  if InfoSize <> 0 then
  begin
    GetMem(VerBuf, InfoSize);
    try
      if GetFileVersionInfo(PChar(Application.ExeName), Wnd, InfoSize, VerBuf) then
      begin
        Value :=nil;
        VerQueryValue(VerBuf, '\VarFileInfo\Translation', Value, Len);
        if Value <> nil then
           TransString := IntToHex(MakeLong(HiWord(Longint(Value^)), LoWord(Longint(Value^))), 8);
        Result := '';
        StrPCopy(szName, '\StringFileInfo\'+Transstring+'\FileVersion');
                                                        // ^^^^^^^此处换成ProductVersion得到的是"产品版本"
        if VerQueryValue(VerBuf, szName, Value, Len) then
           Result := StrPas(PChar(Value));
      end;
    finally
      FreeMem(VerBuf);
    end;
  end;
end;

procedure TfrmAbout.ilAppDblClick(Sender: TObject);
begin
  AppEdition_IsReset := True;
end;

procedure TfrmAbout.llbAppLinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  MyInternetExplorer.OpenWeb( MyProductUrl.Home );
end;

end.
