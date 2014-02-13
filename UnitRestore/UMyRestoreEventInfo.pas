unit UMyRestoreEventInfo;

interface

type

  RestoreDownBackConnEvent = class
  public
    class procedure AddDown( CloudPcID : string );
  end;

implementation

uses UMyClient, UMyNetPcInfo;

{ RestoreDownBackConnEvent }

class procedure RestoreDownBackConnEvent.AddDown(CloudPcID: string);
var
  RestoreItemBackConnMsg : TRestoreItemBackConnMsg;
begin
  RestoreItemBackConnMsg := TRestoreItemBackConnMsg.Create;
  RestoreItemBackConnMsg.SetPcID( PcInfo.PcID );
  MyClient.SendMsgToPc( CloudPcID, RestoreItemBackConnMsg );
end;

end.
