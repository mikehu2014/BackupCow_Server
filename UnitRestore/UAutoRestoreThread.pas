unit UAutoRestoreThread;

interface

uses classes, SysUtils, DateUtils;

type

    // 自动恢复
  AutoRestoreApi = class
  public
    class procedure CheckBusy;
    class procedure CheckLostConn;
    class procedure CheckIncompleted;
  end;

implementation

uses UMyUtil, UMyRestoreDataInfo, UMyRestoreApiInfo, UMyNetPcInfo;

{ AutoRestoreApi }

class procedure AutoRestoreApi.CheckBusy;
var
  RestoreKeyItemList : TRestoreKeyItemList;
  i: Integer;
  RestorePath, OwnerPcID, RestoreFrom : string;
begin
  RestoreKeyItemList := RestoreDownInfoReadUtil.ReadDesBusyList;
  for i := 0 to RestoreKeyItemList.Count - 1 do
  begin
    RestorePath := RestoreKeyItemList[i].RestorePath;
    OwnerPcID := RestoreKeyItemList[i].OwnerPcID;
    RestoreFrom := RestoreKeyItemList[i].RestoreFrom;
    RestoreDownUserApi.RestoreSelectNetworkItem( RestorePath, OwnerPcID, RestoreFrom );
  end;
  RestoreKeyItemList.Free;
end;

class procedure AutoRestoreApi.CheckIncompleted;
var
  RestoreIncompletedList : TRestoreKeyItemList;
  i: Integer;
  RestorePath, OwnerPcID, RestoreFrom : string;
  RestoreFromPcID : string;
begin
  RestoreIncompletedList := RestoreDownInfoReadUtil.ReadIncompletedList;
  for i := 0 to RestoreIncompletedList.Count - 1 do
  begin
    RestorePath := RestoreIncompletedList[i].RestorePath;
    OwnerPcID := RestoreIncompletedList[i].OwnerPcID;
    RestoreFrom := RestoreIncompletedList[i].RestoreFrom;

      // 本地/网络恢复
    if RestoreDownInfoReadUtil.ReadIsLocal( RestorePath, OwnerPcID, RestoreFrom ) then
      RestoreDownUserApi.RestoreSelectLocalItem( RestorePath, OwnerPcID, RestoreFrom )
    else
    begin
      RestoreFromPcID := NetworkDesItemUtil.getPcID( RestoreFrom );
      if MyNetPcInfoReadUtil.ReadIsOnline( RestoreFromPcID ) then
        RestoreDownUserApi.RestoreSelectNetworkItem( RestorePath, OwnerPcID, RestoreFrom );
    end;
  end;
  RestoreIncompletedList.Free;
end;

class procedure AutoRestoreApi.CheckLostConn;
var
  RestoreKeyItemList : TRestoreKeyItemList;
  i: Integer;
  RestorePath, OwnerPcID, RestoreFrom : string;
begin
  RestoreKeyItemList := RestoreDownInfoReadUtil.ReadLostConnList;
  for i := 0 to RestoreKeyItemList.Count - 1 do
  begin
    RestorePath := RestoreKeyItemList[i].RestorePath;
    OwnerPcID := RestoreKeyItemList[i].OwnerPcID;
    RestoreFrom := RestoreKeyItemList[i].RestoreFrom;
    RestoreDownUserApi.RestoreSelectNetworkItem( RestorePath, OwnerPcID, RestoreFrom );
  end;
  RestoreKeyItemList.Free;
end;

end.
