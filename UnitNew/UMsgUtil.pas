unit UMsgUtil;

interface

uses Rtti, DBXJSon, TypInfo, SysUtils, Generics.Collections;

type

    // 对象 Json 化
  TMsgInfo = class
  public
    function getJsonStr : string;
    procedure SetJsonStr( JsonStr : string );
  end;

    // 运行者信息
  TRunnerInfo = class
  end;

    // 命令执行者
  TMsgRunner = class
  protected
    MsgInfo : TMsgInfo;
    RunnerInfo : TRunnerInfo;
  public
    procedure SetMsgInfo( _MsgInfo : TMsgInfo );
    procedure SetRunnerInfo( _RunnerInfo : TRunnerInfo );
    procedure Update;virtual;abstract;
  end;

    // 命令处理信息
  TMsgHandleInfo = class
  public
    MsgClass : TClass;
    RunnerClass : TClass;
  public
    constructor Create( _MsgClass : TClass );
    procedure SetRunClass( _RunnerClass : TClass );
  end;
  TMsgHandleList = class( TObjectList<TMsgHandleInfo> )end;

    // 命令处理器
  TMsgHandler = class
  public
    MsgHandleList : TMsgHandleList;
  public
    constructor Create;
    procedure HandleMsg( Msg : string; RunnerInfo : TRunnerInfo );
    destructor Destroy; override;
  protected
    procedure IniRunnerClass;virtual;abstract;
    procedure AddRunner( MsgClass, RunnerClass : TClass );
  end;

const
  Json_MsgType = 'MsgType';

implementation

{ TJsonMsgBase }

function TMsgInfo.getJsonStr: string;
var
  JsonObject : TJSONObject;
  JsonValue : TJSONValue;
  ctx: TRttiContext;
  t: TRttiType;
  f : TRttiField;
  value : TValue;
  v : Variant;
begin
    // 序列化
  JsonObject := TJSONObject.Create;
  JsonObject.AddPair( TJSONPair.Create( Json_MsgType, Self.ClassName ) );
  t := ctx.GetType( Self.ClassType );
  for f in t.GetFields do
  begin
    value := f.GetValue( Self );
    if value.IsOrdinal then
      v := value.AsOrdinal
    else
      v := value.AsVariant;

    case f.FieldType.TypeKind of
      tkFloat, tkInteger, tkInt64, tkEnumeration : JsonValue := TJSONNumber.Create( v );
    else
      JsonValue := TJSONString.Create( v );
    end;
    JsonObject.AddPair( TJSONPair.Create( f.Name, JsonValue ) );
  end;
  Result := JsonObject.ToString;
  JsonObject.Free;
end;

procedure TMsgInfo.SetJsonStr(JsonStr: string);
var
  JsonObject : TJSONObject;
  ctx: TRttiContext;
  t: TRttiType;
  f : TRttiField;
  value : TValue;
  v : Variant;
  Str: string;
begin
  JsonObject := TJSONObject.ParseJSONValue( JsonStr ) as TJSONObject;
  t := ctx.GetType( Self.ClassType );
  for f in t.GetFields do
  begin
    Str := JsonObject.Get( f.Name ).JsonValue.Value;
    case f.FieldType.TypeKind of
      tkInteger, tkEnumeration: v := StrToIntDef( Str, 0 );
      tkFloat: v := StrToFloatDef( Str, 0 );
      tkInt64: v := StrToInt64Def( Str, 0 );
    else
      v := Str;
    end;
    if f.FieldType.IsOrdinal then
      value := TValue.FromOrdinal( f.FieldType.Handle, v )
    else
      value := TValue.FromVariant( v );
    f.SetValue( Self, Value );
  end;
  JsonObject.Free;
end;

{ TMsgHandler }

procedure TMsgHandler.AddRunner( MsgClass, RunnerClass : TClass );
var
  MsgHandleInfo : TMsgHandleInfo;
begin
  MsgHandleInfo := TMsgHandleInfo.Create( MsgClass );
  MsgHandleInfo.SetRunClass( RunnerClass );
  MsgHandleList.Add( MsgHandleInfo );
end;

constructor TMsgHandler.Create;
begin
  MsgHandleList := TMsgHandleList.Create;
  IniRunnerClass;
end;

destructor TMsgHandler.Destroy;
begin
  MsgHandleList.Free;
  inherited;
end;

procedure TMsgHandler.HandleMsg(Msg: string; RunnerInfo : TRunnerInfo);
var
  JsonObject : TJSONObject;
  MsgType : string;
  i: Integer;
  MsgInfo : TMsgInfo;
  MsgRunner : TMsgRunner;
begin
    // 信息的类型
  JsonObject := TJSONObject.ParseJSONValue( Msg ) as TJSONObject;
  MsgType := JsonObject.Get( 'MsgType' ).JsonValue.Value;
  JsonObject.Free;

    // 找到对应的处理类
  for i := 0 to MsgHandleList.Count - 1 do
    if MsgHandleList[i].MsgClass.ClassName = MsgType then
    begin
      MsgInfo := MsgHandleList[i].MsgClass.Create as TMsgInfo;
      MsgInfo.SetJsonStr( Msg );

      MsgRunner := MsgHandleList[i].RunnerClass.Create as TMsgRunner;
      MsgRunner.SetMsgInfo( MsgInfo );
      MsgRunner.SetRunnerInfo( RunnerInfo );
      MsgRunner.Update;
      MsgRunner.Free;

      MsgInfo.Free;
      Break;
    end;
end;

{ TMsgHandleInfo }

constructor TMsgHandleInfo.Create(_MsgClass : TClass);
begin
  MsgClass := _MsgClass;
end;

procedure TMsgHandleInfo.SetRunClass(_RunnerClass: TClass);
begin
  RunnerClass := _RunnerClass;
end;

{ TMsgRunner }

procedure TMsgRunner.SetMsgInfo(_MsgInfo: TMsgInfo);
begin
  MsgInfo := _MsgInfo;
end;

procedure TMsgRunner.SetRunnerInfo(_RunnerInfo: TRunnerInfo);
begin
  RunnerInfo := _RunnerInfo;
end;

end.
