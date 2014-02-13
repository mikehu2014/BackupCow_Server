unit UAppEditionInfo;

interface

uses classes, SysUtils, DateUtils, Defence, Forms, UChangeInfo, IniFiles, UMyUtil, uDebugLock;

type

    // ��ʾ������Ϣ
  TShowPiracyFaceInfo = class( TFaceChangeInfo )
  protected
    procedure Update;override;
  end;

      // ����Ƿ����
  TAppPiracyCheckHandle = class
  public
    procedure Update;
  private
    function getAppPiracy : Boolean;
    procedure ShowPiracyFace;
  end;

      // ��ʱ��
  MyAppPiracyAutoApi = class
  public
    class procedure CheckIsPiracy;
    class procedure MakeAppError;
  end;

implementation

uses UMainForm, UMyClient, UNetworkFace, UMyNetPcInfo, UMyTimerThread,
     UMyBackupDataInfo, UMyRestoreDataInfo, UMyCloudDataInfo;


{ TShowPiracyFaceInfo }

procedure TShowPiracyFaceInfo.Update;
begin
  frmMainForm.Caption := ' ' + frmMainForm.Caption;
end;

{ MyAppPiracyAutoApi }

class procedure MyAppPiracyAutoApi.CheckIsPiracy;
var
  AppPiracyCheckHandle : TAppPiracyCheckHandle;
begin
  AppPiracyCheckHandle := TAppPiracyCheckHandle.Create;
  AppPiracyCheckHandle.Update;
  AppPiracyCheckHandle.Free;
end;

class procedure MyAppPiracyAutoApi.MakeAppError;
var
  RanNum : Integer;
begin
  Randomize;
  RanNum := Random( 18 );
  if RanNum = 0 then
    MyBackupInfo := nil
  else
  if RanNum = 1 then
    MyRestoreDownInfo := nil
  else
  if RanNum = 2 then
    MyNetPcInfo := nil
end;

{ TAppPiracyCheckHandle }

function TAppPiracyCheckHandle.getAppPiracy: Boolean;
var
  MyCRC32: longInt;
  strA, strB: string;
begin
  MyCRC32 := $00112233;
  MyFileCRC32(Application.ExeName, MyCRC32);
  strA := inttohex(TrueCRC32, 8);
  strB := inttohex(MyCRC32, 8);
  Result := CompareStr(strA, strB) <> 0;
end;

procedure TAppPiracyCheckHandle.ShowPiracyFace;
var
  ShowPiracyFaceInfo : TShowPiracyFaceInfo;
begin
  ShowPiracyFaceInfo := TShowPiracyFaceInfo.Create;
  ShowPiracyFaceInfo.AddChange;
end;

procedure TAppPiracyCheckHandle.Update;
begin
    // �ǵ��棬����
  if not getAppPiracy then
    Exit;

    // ������ʾ������Ϣ
  ShowPiracyFace;

    // ���ͷ��ڴ�
//  Memory_IsFree := False;

    // ��ʱ����ʮ���Ӽ��һ��
//  MyTimerHandler.AddTimer( HandleType_MakePiracyError, 600 );
end;

end.
