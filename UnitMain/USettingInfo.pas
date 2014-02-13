unit USettingInfo;

interface

uses UMyUtil, Math, Generics.Collections, SysUtils;

type

    // 云安全 设置
  TCloudSafeSettingInfo = class
  public
    IsCloudSafe : Boolean;
    CloudIDNum : string;
  public
    function getCloudIDNumMD5 : string;
  end;

    // 应用程序 设置
  TApplicationSettingInfo = class
  public
    IsRunAppStartUp : Boolean;
    IsShowDialogBeforeExist : Boolean;
  end;

      // 传输提示 设置
  THintSettingInfo = class
  public
    IsShowBackuping : Boolean;
    IsShowBackupCompleted : Boolean;
  public
    IsShowRestoring : Boolean;
    IsShowRestorCompleted : Boolean;
  public
    ShowHintTime : Integer;
  end;

var
  CloudSafeSettingInfo : TCloudSafeSettingInfo;
  ApplicationSettingInfo : TApplicationSettingInfo;
  HintSettingInfo : THintSettingInfo;

implementation


{ TCloudSafeSettingInfo }

function TCloudSafeSettingInfo.getCloudIDNumMD5: string;
begin
  if IsCloudSafe then
    Result := MyEncrypt.EncodeMD5String( CloudIDNum )
  else
    Result := '';
end;


end.

