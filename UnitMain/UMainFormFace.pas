unit UMainFormFace;

interface

uses UChangeInfo;

type

{$Region ' Status Bar ������� ' }

    // ����
  TStatusBarChangeInfo = class( TFaceChangeInfo )
  public
    ShowStr : string;
  public
    constructor Create( _ShowStr : string );
  end;

    // Backup Cow ģʽ
  TModeChangeInfo = class( TStatusBarChangeInfo )
  public
    procedure Update;override;
  end;

    // ����ģʽ
  TNetworkModeChangeInfo = class( TStatusBarChangeInfo )
  public
    procedure Update;override;
  end;

    // �ϴ��ٶ�
  TUpSpeedChangeInfo = class( TStatusBarChangeInfo )
  public
    procedure Update;override;
  end;

    // �����ٶ�
  TDownSpeedChangeInfo = class( TStatusBarChangeInfo )
  public
    procedure Update;override;
  end;

    // ͬ��ʱ��
  TSyncTimeChangeInfo = class( TStatusBarChangeInfo )
  private
    HintStr : string;
  public
    procedure SetHintStr( _HintStr : string );
    procedure Update;override;
  end;

    // �汾��
  TEditionChangeInfo = class( TStatusBarChangeInfo )
  public
    procedure Update;override;
  end;

    // ���� ����״̬
  TNetStatusChangeInfo = class( TStatusBarChangeInfo )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' FreeEdition ������ʾ ' }

  TShowFreeEditionWarnning = class( TChangeInfo )
  public
    WarnningStr : string;
  public
    constructor Create( _WarnningStr : string );
    procedure Update;override;
  end;


{$EndRegion}

{$Region ' TrayIcon ��ʾ '}

  TShowTrayHintStr = class( TChangeInfo )
  public
    TitleStr : string;
    ContentStr : string;
  public
    constructor Create( _TitleStr, _ContentStr : string );
    procedure Update;override;
  end;

    // ��ʼ����
  TStartBackupTrayFace = class( TFaceChangeInfo )
  protected
    procedure Update;override;
  end;

    // ��������
  TStopBackupTrayFace = class( TFaceChangeInfo )
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' Hint ��ʾ ' }

  TShowHintWriteFace = class( TFaceChangeInfo )
  public
    FileName, Destination : string;
    IsFile : Boolean;
    HintType : string;
  public
    constructor Create( _FileName, _Destination : string );
    procedure SetHintType( _HintType : string );
    procedure SetIsFile( _IsFile : Boolean );
  protected
    procedure Update;override;
  end;

  TShowHintTimeSetFace = class( TFaceChangeInfo )
  public
    ShowHintTime : Integer;
  public
    constructor Create( _ShowHintTime : Integer );
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' Form Debug ' }

  TFormLogAddFace = class( TFaceChangeInfo )
  public
    LogStr : string;
  public
    constructor Create( _LogStr : string );
  protected
    procedure Update;override;
  end;

{$EndRegion}

const
  HintType_Backuping = 'Backuping';
  HintType_BackupCompleted = 'BackupCompeted';

  HintType_Restoring = 'Restoring';
  HintType_RestoreCompelted = 'RestoreCompleted';

implementation

uses UMainForm, UFormHint, UDebugForm;

{ TStatusBarChangeInfo }

constructor TStatusBarChangeInfo.Create(_ShowStr: string);
begin
  ShowStr := _ShowStr;
end;

{ TModeChangeInfo }

procedure TModeChangeInfo.Update;
begin
end;

{ TNetworkModeChangeInfo }

procedure TNetworkModeChangeInfo.Update;
begin
  frmMainForm.sbNetworkMode.Caption := ShowStr;
end;

{ TUpSpeedChangeInfo }

procedure TUpSpeedChangeInfo.Update;
begin
  frmMainForm.sbUpSpeed.Caption := ShowStr;
end;

{ TDownSpeedChangeInfo }

procedure TDownSpeedChangeInfo.Update;
begin
  frmMainForm.sbDownSpeed.Caption := ShowStr;
end;

{ TSyncTimeChangeInfo }

procedure TSyncTimeChangeInfo.SetHintStr(_HintStr: string);
begin
  HintStr := _HintStr;
end;

procedure TSyncTimeChangeInfo.Update;
begin

end;

{ TEditionChangeInfo }

procedure TEditionChangeInfo.Update;
begin
  frmMainForm.sbEdition.Caption := ShowStr;
end;

{ TNetStatusChangeInfo }

procedure TNetStatusChangeInfo.Update;
begin
  frmMainForm.sbMyStatus.Caption := ShowStr;
end;

{ TShowFreeEditionWarnning }

constructor TShowFreeEditionWarnning.Create(_WarnningStr: string);
begin
  WarnningStr := _WarnningStr;
end;

procedure TShowFreeEditionWarnning.Update;
begin
//  frmFreeEdition.ShowWarnning( WarnningStr );
end;

{ TShowTrayHintStr }

constructor TShowTrayHintStr.Create(_TitleStr, _ContentStr: string);
begin
  TitleStr := _TitleStr;
  ContentStr := _ContentStr;
end;

procedure TShowTrayHintStr.Update;
begin
  with frmMainForm do
  begin
    tiApp.BalloonTitle := TitleStr;
    tiApp.BalloonHint := ContentStr;
    tiApp.ShowBalloonHint;
  end;
end;

{ TShowHintWriteFace }

constructor TShowHintWriteFace.Create(_FileName, _Destination: string);
begin
  FileName := _FileName;
  Destination := _Destination;
end;

procedure TShowHintWriteFace.SetHintType(_HintType: string);
begin
  HintType := _HintType;
end;

procedure TShowHintWriteFace.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TShowHintWriteFace.Update;
var
  Params : TShowHintParams;
begin
  Params.FileName := FileName;
  Params.Destination := Destination;
  Params.IsFile := IsFile;

  if not frmMainForm.getIsShowHint then
    Exit
  else
  if HintType = HintType_Backuping then
    frmHint.ShowBackuping( Params )
  else
  if HintType = HintType_BackupCompleted then
    frmHint.ShowBackupCompleted( Params )
  else
  if HintType = HintType_Restoring then
    frmHint.ShowRestoring( Params )
  else
  if HintType = HintType_RestoreCompelted then
    frmHint.ShowRestoreCompelted( Params );
end;

{ TShowHintTimeSetFace }

constructor TShowHintTimeSetFace.Create(_ShowHintTime: Integer);
begin
  ShowHintTime := _ShowHintTime;
end;

procedure TShowHintTimeSetFace.Update;
begin
  frmHint.tmrClose.Interval := ShowHintTime * 1000;
end;

{ TStopBackupTrayFace }

procedure TStopBackupTrayFace.Update;
begin
//  frmMainForm.tiApp.IconIndex := 6;
end;

{ TStartBackupTrayFace }

procedure TStartBackupTrayFace.Update;
begin
//  frmMainForm.tiApp.IconIndex := 8;
end;

{ TFormLogAddFace }

constructor TFormLogAddFace.Create(_LogStr: string);
begin
  LogStr := _LogStr;
end;

procedure TFormLogAddFace.Update;
begin
  inherited;

    // ���һǧ��
  if frmDebug.mmoReceive.Lines.Count > 1000 then
    frmDebug.mmoReceive.Lines.Clear;

  frmDebug.mmoReceive.Lines.Add( LogStr );
end;

end.
