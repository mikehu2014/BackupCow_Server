unit UMyRegisterEventInfo;

interface

type

  MyRegisterEvent = class
  public
    class procedure SetEdition( RegisterEdition : string );
    class procedure SetEditonOnline( RegisterEdition, OnlinePcID : string );
  end;

  ActivetePcEvent = class
  public
    class procedure AddItem( PcID, LicenseStr : string );
  end;

implementation

uses UMyClient, UMyNetPcInfo;

{ MyRegisterEvent }

class procedure MyRegisterEvent.SetEdition(RegisterEdition: string);
var
  RegisterShowMsg : TRegisterShowMsg;
begin
  RegisterShowMsg := TRegisterShowMsg.Create;
  RegisterShowMsg.SetPcID( PcInfo.PcID );
  RegisterShowMsg.SetHardCode( PcInfo.PcHardCode );
  RegisterShowMsg.SetRegisterEdition( RegisterEdition );
  MyClient.SendMsgToAll( RegisterShowMsg );
end;

class procedure MyRegisterEvent.SetEditonOnline(RegisterEdition,
  OnlinePcID: string);
var
  RegisterShowMsg : TRegisterShowMsg;
begin
  RegisterShowMsg := TRegisterShowMsg.Create;
  RegisterShowMsg.SetPcID( PcInfo.PcID );
  RegisterShowMsg.SetHardCode( PcInfo.PcHardCode );
  RegisterShowMsg.SetRegisterEdition( RegisterEdition );
  MyClient.SendMsgToPc( OnlinePcID, RegisterShowMsg );
end;

{ ActivetePcEvent }

class procedure ActivetePcEvent.AddItem(PcID, LicenseStr: string);
var
  ActivatePcMsg : TActivatePcMsg;
begin
  ActivatePcMsg := TActivatePcMsg.Create;
  ActivatePcMsg.SetPcID( PcInfo.PcID );
  ActivatePcMsg.SetLicenseStr( LicenseStr );
  MyClient.SendMsgToPc( PcID, ActivatePcMsg );
end;

end.
