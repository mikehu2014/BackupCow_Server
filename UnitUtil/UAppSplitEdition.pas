unit UAppSplitEdition;

interface

uses ExtCtrls, Vcl.Controls,  graphics;

type

    // �������ǰ汾
  TMaAppSplitStartHandle = class
  public
    procedure Update;
  private
    procedure HintGroupUrl;
    procedure ReplaceAppIconAndName;
  private
    procedure ReplaceAppImg( il : TImage; IconSize : Integer );
    procedure ReplaceAppIcon( il : TIcon; IconSize : Integer );
    function ReplaceAppName( s : string ): string;
  end;

    // �汾����
  AppSplitEditionUtl = class
  public
    class procedure StartSplit;
    class function ReadAccount : string;
  end;

const  // ��ѡ�汾��
  AppEdition_MA = 'MA';
  AppEdition_Normal = 'Normal';

var  // ��ǰ�汾��
  AppEdition_Now : string;

const
  IconSize_16 = 16;
  IconSize_24 = 24;
  IconSize_32 = 32;

implementation

uses UFromEnterGroup, UFormBackupHint, UFormAppSplitEdition, UFormAbout, Sysutils, UFormHint,
     UFormSetting, UFormEditionNotMatch, UFormTrialToFree, UMainForm;

{ AppSplitEditionUtl }

class function AppSplitEditionUtl.ReadAccount: string;
begin
  if AppEdition_Now = AppEdition_MA then
    Result := 'MA'
  else
    Result := '';
end;

class procedure AppSplitEditionUtl.StartSplit;
var
  MaAppSplitStartHandle : TMaAppSplitStartHandle;
begin
    // �����汾
  if AppEdition_Now = AppEdition_Normal then
    Exit;

  MaAppSplitStartHandle := TMaAppSplitStartHandle.Create;
  MaAppSplitStartHandle.Update;
  MaAppSplitStartHandle.Free;
end;

{ TMaAppSplitStartHandle }

procedure TMaAppSplitStartHandle.HintGroupUrl;
begin
  frmJoinGroup.llbForget.Visible := False;
  frmJoinGroup.llbInformation.Visible := False;
end;

procedure TMaAppSplitStartHandle.ReplaceAppImg(il: TImage; IconSize: Integer);
begin
  ReplaceAppIcon( il.Picture.Icon, IconSize );
end;

procedure TMaAppSplitStartHandle.ReplaceAppIcon(il: TIcon; IconSize: Integer);
var
  ImgList : TImageList;
begin
  if IconSize = IconSize_16 then
    ImgList := frmAppSplitEdition.il16
  else
  if IconSize = IconSize_24 then
    ImgList := frmAppSplitEdition.il24
  else
  if IconSize = IconSize_32 then
    ImgList := frmAppSplitEdition.il32
  else
    Exit;

  try
    ImgList.GetIcon( 0, il );
  except
  end;
end;

procedure TMaAppSplitStartHandle.ReplaceAppIconAndName;
begin
    // ����/�ָ������ʾ�Ĵ���
  ReplaceAppImg( frmBackupHint.ilTitle, IconSize_24 );
  ReplaceAppImg( frmHint.ilTitle, IconSize_24 );

    // About ����
  ReplaceAppIcon( frmAbout.Icon, IconSize_16 );
  ReplaceAppImg( frmAbout.ilApp, IconSize_32 );
  frmAbout.lbApp.Caption := ReplaceAppName( frmAbout.lbApp.Caption );
  frmAbout.llbApp.Caption := ReplaceAppName( frmAbout.llbApp.Caption );
  frmAbout.lbEdition.Left := frmAbout.lbEdition.Left + 10;

    // Setting ����
  frmSetting.Caption := ReplaceAppName( frmSetting.Caption );

    // Edition Not Match ����
  frmEditonNotMatch.Caption := ReplaceAppName( frmEditonNotMatch.Caption );
  frmEditonNotMatch.plMain.Caption := ReplaceAppName( frmEditonNotMatch.plMain.Caption );
  frmTrialToFree.Caption := ReplaceAppName( frmTrialToFree.Caption );

    // ������
  frmMainForm.Caption := ReplaceAppName( frmMainForm.Caption );
  ReplaceAppIcon( frmMainForm.Icon, IconSize_16 );
  frmMainForm.lbNotAvailable.Caption := ReplaceAppName( frmMainForm.lbNotAvailable.Caption );
  frmMainForm.lbOldProgram.Caption := ReplaceAppName( frmMainForm.lbOldProgram.Caption );
  frmMainForm.lbRemotePcNotConn.Caption := ReplaceAppName( frmMainForm.lbRemotePcNotConn.Caption );
  frmMainForm.btnEditionDetails.Left := frmMainForm.btnEditionDetails.Left + 10;

    // ����
  ReplaceAppIcon( frmMainForm.tiApp.Icon, IconSize_16 );
  frmMainForm.tiApp.Hint := ReplaceAppName( frmMainForm.tiApp.Hint );
end;

function TMaAppSplitStartHandle.ReplaceAppName(s: string): string;
begin
  Result := StringReplace( s, 'Backup Cow', 'Mango Backup', [rfReplaceAll, rfIgnoreCase] );
  Result := StringReplace( Result, 'BackupCow', 'MangoBackup', [rfReplaceAll, rfIgnoreCase] );
end;

procedure TMaAppSplitStartHandle.Update;
begin
    // ���� group
  HintGroupUrl;

    // Icon �� Name ����
  ReplaceAppIconAndName;
end;

end.
