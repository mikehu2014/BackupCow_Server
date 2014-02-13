program BackupCow_Server;

uses
  Forms,
  Windows,
  Messages,
  Dialogs,
  SysUtils,
  UFileBaseInfo in 'UnitUtil\UFileBaseInfo.pas',
  UFormUtil in 'UnitUtil\UFormUtil.pas',
  UModelUtil in 'UnitUtil\UModelUtil.pas',
  UMyUtil in 'UnitUtil\UMyUtil.pas',
  UXmlUtil in 'UnitUtil\UXmlUtil.pas',
  UBackupCow in 'UnitMain\UBackupCow.pas',
  USearchServer in 'UnitNetwork\USearchServer.pas',
  UNetworkControl in 'UnitNetwork\UNetworkControl.pas',
  UMyNetPcInfo in 'UnitNetwork\UMyNetPcInfo.pas',
  uLkJSON in 'UnitUtil\uLkJSON.pas',
  UNetworkFace in 'UnitNetwork\UNetworkFace.pas',
  UMyTcp in 'UnitNetwork\UMyTcp.pas',
  UMyServer in 'UnitNetwork\UMyServer.pas',
  UMyClient in 'UnitNetwork\UMyClient.pas',
  UMyMaster in 'UnitNetwork\UMyMaster.pas',
  UChangeInfo in 'UnitUtil\UChangeInfo.pas',
  uDebug in 'UnitUtil\uDebug.pas',
  UFormSetting in 'UnitMain\UFormSetting.pas' {frmSetting},
  USettingInfo in 'UnitMain\USettingInfo.pas',
  uEncrypt in 'UnitUtil\uEncrypt.pas',
  UMainFormFace in 'UnitMain\UMainFormFace.pas',
  UNetPcInfoXml in 'UnitNetwork\UNetPcInfoXml.pas',
  CnMD5 in 'UnitUtil\CnMD5.pas',
  UIconUtil in 'UnitUtil\UIconUtil.pas',
  UMyUrl in 'UnitUtil\UMyUrl.pas',
  UFormAbout in 'UnitMain\UFormAbout.pas' {frmAbout},
  CRC in 'UnitUtil\CRC.pas',
  FGInt in 'UnitUtil\FGInt.pas',
  FGIntRSA in 'UnitUtil\FGIntRSA.pas',
  kg_dnc in 'UnitUtil\kg_dnc.pas',
  UAppEditionInfo in 'UnitMain\UAppEditionInfo.pas',
  Defence in 'UnitUtil\Defence.pas',
  uDebugLock in 'UnitUtil\uDebugLock.pas',
  UFromEnterGroup in 'UnitNetwork\UFromEnterGroup.pas' {frmJoinGroup},
  UFormConnPc in 'UnitNetwork\UFormConnPc.pas' {frmConnComputer},
  UMainForm in 'UnitMain\UMainForm.pas' {frmMainForm},
  UFormExitWarnning in 'UnitMain\UFormExitWarnning.pas' {frmExitConfirm},
  UPortMap in 'UnitNetwork\UPortMap.pas',
  UDebugForm in 'UnitMain\UDebugForm.pas' {frmDebug},
  UBackupThread in 'UnitBackup\UBackupThread.pas',
  UFormFileSelect in 'UnitUtil\UFormFileSelect.pas' {frmFileSelect},
  UFormSelectMask in 'UnitUtil\UFormSelectMask.pas' {FrmEnterMask},
  UFormSpaceLimit in 'UnitUtil\UFormSpaceLimit.pas' {frmSpaceLimit},
  UFmFilter in 'UnitUtil\UFmFilter.pas' {FrameFilter: TFrame},
  UFrameFilter in 'UnitUtil\UFrameFilter.pas' {FrameFilterPage: TFrame},
  UDataSetInfo in 'UnitUtil\UDataSetInfo.pas',
  UMyBackupDataInfo in 'UnitBackup\UMyBackupDataInfo.pas',
  UMyBackupFaceInfo in 'UnitBackup\UMyBackupFaceInfo.pas',
  UMyBackupXmlInfo in 'UnitBackup\UMyBackupXmlInfo.pas',
  UMyBackupApiInfo in 'UnitBackup\UMyBackupApiInfo.pas',
  UNetworkEventInfo in 'UnitNetwork\UNetworkEventInfo.pas',
  UFrmSelectBackupItem in 'UnitBackup\UFrmSelectBackupItem.pas' {frmSelectBackupItem},
  UFolderCompare in 'UnitUtil\UFolderCompare.pas',
  UMyCloudDataInfo in 'UnitCloud\UMyCloudDataInfo.pas',
  UMyCloudXmlInfo in 'UnitCloud\UMyCloudXmlInfo.pas',
  UMyCloudApiInfo in 'UnitCloud\UMyCloudApiInfo.pas',
  UCloudThread in 'UnitCloud\UCloudThread.pas',
  UMyBackupEventInfo in 'UnitBackup\UMyBackupEventInfo.pas',
  UMyRestoreFaceInfo in 'UnitRestore\UMyRestoreFaceInfo.pas',
  UMyRestoreApiInfo in 'UnitRestore\UMyRestoreApiInfo.pas',
  UMyCloudEventInfo in 'UnitCloud\UMyCloudEventInfo.pas',
  UMyRestoreDataInfo in 'UnitRestore\UMyRestoreDataInfo.pas',
  UMyRestoreXmlInfo in 'UnitRestore\UMyRestoreXmlInfo.pas',
  UFormSelectRestore in 'UnitRestore\UFormSelectRestore.pas' {frmSelectRestore},
  URestoreThread in 'UnitRestore\URestoreThread.pas',
  UAutoBackupThread in 'UnitBackup\UAutoBackupThread.pas',
  UFormRestoreExplorer in 'UnitRestore\UFormRestoreExplorer.pas' {frmRestoreExplorer},
  UFormBackupLog in 'UnitBackup\UFormBackupLog.pas' {frmBackupLog},
  UMyCloudFaceInfo in 'UnitCloud\UMyCloudFaceInfo.pas',
  UFormRegister in 'UnitRegister\UFormRegister.pas' {frmRegister},
  UMyRegisterApiInfo in 'UnitRegister\UMyRegisterApiInfo.pas',
  UMyRegisterDataInfo in 'UnitRegister\UMyRegisterDataInfo.pas',
  UMyRegisterEventInfo in 'UnitRegister\UMyRegisterEventInfo.pas',
  UMyRegisterFaceInfo in 'UnitRegister\UMyRegisterFaceInfo.pas',
  UMyRegisterXmlInfo in 'UnitRegister\UMyRegisterXmlInfo.pas',
  URegisterInfoIO in 'UnitRegister\URegisterInfoIO.pas',
  URegisterThread in 'UnitRegister\URegisterThread.pas',
  UMyDebug in 'UnitMain\UMyDebug.pas',
  UNetworkStatus in 'UnitNetwork\UNetworkStatus.pas' {frmNeworkStatus},
  UMyRestoreEventInfo in 'UnitRestore\UMyRestoreEventInfo.pas',
  UFormRestoreDecrypt in 'UnitRestore\UFormRestoreDecrypt.pas' {frmDecrypt},
  UFormRemoveBackupConfirm in 'UnitBackup\UFormRemoveBackupConfirm.pas' {frmBackupDelete},
  UAutoRestoreThread in 'UnitRestore\UAutoRestoreThread.pas',
  UMainFormThread in 'UnitMain\UMainFormThread.pas',
  UFormBackupSpeedLimit in 'UnitBackup\UFormBackupSpeedLimit.pas' {frmBackupSpeedLimit},
  UFormRestoreSpeedLimit in 'UnitRestore\UFormRestoreSpeedLimit.pas' {frmRestoreSpeedLimit},
  UFormHint in 'UnitMain\UFormHint.pas' {frmHint},
  UMainApi in 'UnitMain\UMainApi.pas',
  UMyTimerThread in 'UnitMain\UMyTimerThread.pas',
  UFormBackupPcFilter in 'UnitBackup\UFormBackupPcFilter.pas' {frmSendPcFilter},
  UFormRestorePcFilter in 'UnitRestore\UFormRestorePcFilter.pas' {frmRestorePcFilter},
  UFormRestoreChildTo in 'UnitRestore\UFormRestoreChildTo.pas' {frmRestoreChildTo},
  UFormRestoreConfirm in 'UnitRestore\UFormRestoreConfirm.pas' {frmUserConfirm},
  UFormFreeTips in 'UnitRegister\UFormFreeTips.pas' {frmFreeTips},
  UFormTrialToFree in 'UnitRegister\UFormTrialToFree.pas' {frmTrialToFree},
  UFormEditionNotMatch in 'UnitNetwork\UFormEditionNotMatch.pas' {frmEditonNotMatch},
  VersionInfo in 'UnitUtil\VersionInfo.pas',
  mp3_id3v1 in 'UnitUtil\mp3_id3v1.pas',
  RAR in 'UnitUtil\RAR.pas',
  TWmaTag in 'UnitUtil\TWmaTag.pas',
  UFormPreview in 'UnitRestore\UFormPreview.pas' {frmPreView},
  RAR_DLL in 'UnitUtil\RAR_DLL.pas',
  UFormBackupHint in 'UnitBackup\UFormBackupHint.pas' {frmBackupHint},
  HashUnit in 'UnitUtil\HashUnit.pas',
  Diff in 'UnitUtil\Diff.pas',
  UFormFileCompare in 'UnitUtil\UFormFileCompare.pas' {frmFileCompare},
  UUserXmlInfo in 'UnitOther\UUserXmlInfo.pas',
  UUserApiInfo in 'UnitOther\UUserApiInfo.pas',
  UAppSplitEdition in 'UnitUtil\UAppSplitEdition.pas',
  UFormAppSplitEdition in 'UnitUtil\UFormAppSplitEdition.pas' {frmAppSplitEdition},
  UServerData in 'UnitNew\UServerData.pas',
  UDataUtil in 'UnitNew\UDataUtil.pas',
  UServerNet in 'UnitNew\UServerNet.pas',
  UMsgUtil in 'UnitNew\UMsgUtil.pas',
  UNetUtil in 'UnitNew\UNetUtil.pas',
  UWinApi in 'UnitNew\UWinApi.pas';

{$R *.res}

var
  myhandle : hwnd;
  ParamsStr : string;

{$R *.res}
begin
    // 正常版本
  AppEdition_Now := AppEdition_Normal;

    // 设置防火墙
  MyFireWall.MakeThrough;

      // 参数信息
  ParamsStr := '';
  if ParamCount > 0 then
    ParamsStr := ParamStr( ParamCount );

    // 运行程序目的是通过管理员执行代码
  if MyAppAdminRunasUtil.getIsRunAsAdmin( ParamsStr ) then
    Exit;

    // 防止多个 BackupCow 同时运行
  myhandle := findwindow( AppName_FileCloud, nil );
  if myhandle > 0 then  // 窗口在同一个 用户 ID 已经运行, 恢复之前的窗口
  begin
    postmessage( myhandle,hfck,0,0 );
    Exit;
  end
  else    // 存在相同的程序, 但不同 用户 ID, 结束程序
  if MyAppRun.getAppCount > 1 then
  begin
    if ParamsStr <> AppRunParams_Hide then  // 以隐藏方式运行, 不显示
      MyMessageBox.ShowWarnning( 0, 'Application is running' );
    Exit;
  end;

      // 是否以 隐藏方式 运行程序
  if ParamsStr = AppRunParams_Hide then
    Application.ShowMainForm := False;

  try
    ReportMemoryLeaksOnShutdown := DebugHook<>0;
    Application.Initialize;
    Application.MainFormOnTaskbar := True;
    Application.CreateForm(TfrmMainForm, frmMainForm);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.CreateForm(TfrmBackupLog, frmBackupLog);
  Application.CreateForm(TfrmSetting, frmSetting);
  Application.CreateForm(TfrmJoinGroup, frmJoinGroup);
  Application.CreateForm(TfrmConnComputer, frmConnComputer);
  Application.CreateForm(TfrmExitConfirm, frmExitConfirm);
  Application.CreateForm(TfrmDebug, frmDebug);
  Application.CreateForm(TfrmFileSelect, frmFileSelect);
  Application.CreateForm(TFrmEnterMask, FrmEnterMask);
  Application.CreateForm(TfrmSpaceLimit, frmSpaceLimit);
  Application.CreateForm(TfrmSelectBackupItem, frmSelectBackupItem);
  Application.CreateForm(TfrmSelectRestore, frmSelectRestore);
  Application.CreateForm(TfrmRestoreExplorer, frmRestoreExplorer);
  Application.CreateForm(TfrmRegister, frmRegister);
  Application.CreateForm(TfrmNeworkStatus, frmNeworkStatus);
  Application.CreateForm(TfrmDecrypt, frmDecrypt);
  Application.CreateForm(TfrmBackupDelete, frmBackupDelete);
  Application.CreateForm(TfrmBackupSpeedLimit, frmBackupSpeedLimit);
  Application.CreateForm(TfrmRestoreSpeedLimit, frmRestoreSpeedLimit);
  Application.CreateForm(TfrmHint, frmHint);
  Application.CreateForm(TfrmSendPcFilter, frmSendPcFilter);
  Application.CreateForm(TfrmRestorePcFilter, frmRestorePcFilter);
  Application.CreateForm(TfrmRestoreChildTo, frmRestoreChildTo);
  Application.CreateForm(TfrmUserConfirm, frmUserConfirm);
  Application.CreateForm(TfrmFreeTips, frmFreeTips);
  Application.CreateForm(TfrmTrialToFree, frmTrialToFree);
  Application.CreateForm(TfrmEditonNotMatch, frmEditonNotMatch);
  Application.CreateForm(TfrmPreView, frmPreView);
  Application.CreateForm(TfrmBackupHint, frmBackupHint);
  Application.CreateForm(TfrmFileCompare, frmFileCompare);
  Application.CreateForm(TFrmFileCompare, FrmFileCompare);
  Application.CreateForm(TfrmAppSplitEdition, frmAppSplitEdition);
  frmMainForm.CreateBackupCow;
    Application.Run;
  except
  end;
end.
