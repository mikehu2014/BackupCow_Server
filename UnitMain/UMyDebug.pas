unit UMyDebug;

interface

uses UMyUrl, idhttp, classes, UMyUtil;

type

  MyWebDebug = class
  public
    class procedure AddItem( ErrorType, ErrorStr : string );
  end;

const
  HttpReqDebug_PcID = 'PcID';
  HttpReqDebug_PcName = 'PcName';
  HttpReqDebug_ErrorType = 'ErrorType';
  HttpReqDebug_ErrorStr = 'ErrorStr';

implementation

{ MyWebDebug }

class procedure MyWebDebug.AddItem( ErrorType, ErrorStr: string);
var
  Url, PcName, PcID : string;
  IdHttp : TIdHTTP;
  ParamList : TStringList;
begin
  Url := MyUrl.getDebug;
  PcName := MyComputerName.get;
  PcID := MyComputerID.get;

  ParamList := TStringList.Create;
  ParamList.Add( HttpReqDebug_PcID + '=' + PcID );
  ParamList.Add( HttpReqDebug_PcName + '=' + PcName );
  ParamList.Add( HttpReqDebug_ErrorType + '=' + ErrorType );
  ParamList.Add( HttpReqDebug_ErrorStr + '=' + ErrorStr );
  IdHttp := TIdHTTP.Create(nil);
  IdHttp.ConnectTimeout := 5000;
  IdHttp.ReadTimeout := 5000;
  try
    IdHttp.Post( Url, ParamList );
  except
  end;
  IdHttp.Free;
  ParamList.Free;
end;

end.
