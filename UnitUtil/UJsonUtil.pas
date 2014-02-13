unit UJsonUtil;

// 注意，只能用于测试版

interface

uses ulkjson, Contnrs, TypInfo, SysUtils;

type

  JsonUtil = class
  private
    class function getJsonObject( Obj : TObject ): TlkJSONobject;
    class procedure setJsonObject( Obj : TObject; JsonObj : TlkJSONobject );
  public
    class function getJsonStr( Obj : TObject ): string;
    class procedure SetJsobStr( Obj : TObject; JsonStr : string );
  private
    class function getEmptyValue( s : string; tk : TTypeKind ): string;
  end;

implementation

{ JsonUtil }

class function JsonUtil.getEmptyValue(s: string; tk: TTypeKind): string;
begin
  if ( tk = tkInteger ) or ( tk = tkInt64 ) or ( tk = tkFloat ) then
    Result := '0'
  else
    Result := s;
end;

class function JsonUtil.getJsonObject(Obj: TObject): TlkJSONobject;
var
  PropCount, i : Integer;
  PropList: PPropList;
  ProName : string;
  ProValue : Variant;
  ChildObj : TObject;
  ChildJson : TlkJSONobject;
  tk : TTypeKind;
begin
  Result := TlkJSONobject.Create;

  PropCount := GetTypeData(Obj.ClassInfo).PropCount;
  GetPropList(Obj.ClassInfo, PropList);
  for i := 0 to PropCount - 1 do
  begin
    ProName := PropList[i]^.Name;
    ProValue := GetPropValue( Obj, ProName );
    tk := PropList[i]^.PropType^.Kind;
    if tk = tkClass then // 属性类
    begin
      ChildObj := Pointer( Integer( ProValue ) );
      ChildJson := getJsonObject( ChildObj );
      Result.Add( ProName, ChildJson );
    end
    else
      Result.Add( ProName, String( ProValue ) );
  end;
  FreeMem(PropList);
end;

class function JsonUtil.getJsonStr(Obj: TObject): string;
var
  JsonObj : TlkJSONobject;
begin
  JsonObj := getJsonObject( Obj );
  Result := TlkJSON.GenerateText( JsonObj );
  JsonObj.Free;
end;

class procedure JsonUtil.SetJsobStr(Obj: TObject; JsonStr: string);
var
  JsonObj : TlkJSONobject;
begin
  try
    JsonObj := TlkJSON.ParseTextObj( JsonStr );
    setJsonObject( Obj, JsonObj );
    JsonObj.Free;
  except
  end;
end;

class procedure JsonUtil.setJsonObject(Obj: TObject; JsonObj: TlkJSONobject);
var
  PropCount, i : Integer;
  PropList: PPropList;
  ProName, Value : string;
  OldValue, ProValue : Variant;
  tk : TTypeKind;
  ChildObj : TObject;
  ChildJson : TlkJSONobject;
begin
  PropCount := GetTypeData(Obj.ClassInfo).PropCount;
  GetPropList(Obj.ClassInfo, PropList);
  for i := 0 to PropCount - 1 do
  begin
    ProName := PropList[i]^.Name;
    tk := PropList[i]^.PropType^.Kind;
    try
      if tk = tkClass then
      begin
        OldValue := GetPropValue( Obj, ProName );
        ChildObj := Pointer( Integer( OldValue ) );
        ChildJson := JsonObj.getObject( ProName );
        setJsonObject( ChildObj, ChildJson );
      end
      else
      begin
        Value := JsonObj.getString( ProName );
        if ( Value = '' ) then  // 版本差异，可能存在 空值
          Value := getEmptyValue( Value, tk );
        SetPropValue( Obj, ProName, Variant( Value ) );
      end;
    except
    end;
  end;
  FreeMem(PropList);
end;

end.
