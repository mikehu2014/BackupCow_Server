unit UModelUtil;

interface

uses
  Generics.Collections, Classes, SyncObjs;

type

  TStringDictionary<TValue> = class( TObjectDictionary< string, TValue > )
  public
    constructor Create;overload;
  end;

    // ×Ö·û´®¹þÏ£½á¹¹
  TStringPart = TPair< string, string >;
  TStringHash = class( TDictionary< string, string > )
  public
    constructor Create;
    procedure AddString( s : string );
  end;

implementation

uses UXmlUtil;

{ TStringDictionary<TValue> }

constructor TStringDictionary<TValue>.Create;
begin
  inherited Create( [ doOwnsValues ] );
end;

{ TStringHash }

procedure TStringHash.AddString(s: string);
begin
  AddOrSetValue( s, s );
end;




constructor TStringHash.Create;
begin
  inherited Create;
end;

end.
