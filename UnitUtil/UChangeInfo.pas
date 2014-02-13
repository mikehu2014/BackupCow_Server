unit UChangeInfo;

interface

uses Contnrs, ulkJson, TypInfo, SysUtils, Classes, Generics.Collections, SyncObjs, uDebug, UMyUtil, uDebugLock;

type

{$Region ' 变化处理 ' }

  {$Region ' 数据结构 ' }

    // 变化
  TChangeInfo = class
  protected
    procedure Update;virtual;
  end;
  TChangeInfoList = class( TObjectList< TChangeInfo > )end;

    // 界面变化
  TFaceChangeInfo = class( TChangeInfo )
  public
    procedure InsertChange;
    procedure AddChange;
  end;

    // Xml变化
  TXmlChangeInfo = class( TChangeInfo )
  public
    procedure InsertChange;
    procedure AddChange;
  end;

    // 变化集合
  TChangeInfoBox = class
  private
    Lock : TCriticalSection;
    ChangeInfoList : TChangeInfoList;
  public
    constructor Create;
    destructor Destroy; override;
  private
    function ExistChange : Boolean;
    function getChangeCount : Integer;
  private
    function getChangeInfo : TChangeInfo;
    procedure AddChangeInfo( ChangeInfo : TChangeInfo );
    procedure InsertChangeInfo( ChangeInfo : TChangeInfo );
  end;

  {$EndRegion}

  {$Region ' 数据线程 ' }

    // 处理 变化集合 线程
  TChangeHanldeThread = class( TDebugThread )
  private
    ChangeInfoBox : TChangeInfoBox;
  protected
    IsDebug : Boolean;
    IsHandleAll : Boolean;
  public
    constructor Create;
    procedure SetIsDebug( _IsDebug : Boolean );
    procedure SetChangeInfoBox( _ChangeInfoBox : TChangeInfoBox );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  protected
    procedure Handle( ChangeInfo : TChangeInfo );virtual;
    procedure EmptyJobHandle;virtual;
  end;
  TChangeHandleThreadList = class( TObjectList<TChangeHanldeThread> )
  public
    procedure RunAllThread;
  end;

      // 处理 数据 变化集合 线程
  TDataChangeHandleThread = class( TChangeHanldeThread )
  private
    DataLock : TCriticalSection;
  public
    procedure SetDataLock( _DataLock : TCriticalSection );
  protected
    procedure Handle( ChangeInfo : TChangeInfo );override;
  end;

    // 处理 界面 变化集合 线程
  TFaceChangeHandleThread = class( TChangeHanldeThread )
  private
    SelectChangeInfo : TChangeInfo;
  protected
    procedure Handle( ChangeInfo : TChangeInfo );override;
  private
    procedure HandleFaceChange;
  end;

    // 处理 Xml 变化集合 线程
  TXmlChangeHandleThread = class( TChangeHanldeThread )
  private
    XmlLock : TCriticalSection;
  public
    constructor Create;
    procedure SetXmlLock( _XmlLock : TCriticalSection );
  protected
    procedure Handle( ChangeInfo : TChangeInfo );override;
  end;

  {$EndRegion}

  {$Region ' 数据对象 ' }

    // 普通对象
  TMyChangeBase = class
  private   // 要处理的数据
    ChangeInfoBox : TChangeInfoBox;
  private
    ChangeHandThreadList : TChangeHandleThreadList;
  public
    IsRun : Boolean;
    IsDebug : Boolean;
  public
    constructor Create;
    destructor Destroy; override;
  public
    procedure AddChange( ChangeInfo : TChangeInfo );
    procedure InsertChange( ChangeInfo : TChangeInfo );
  public
    procedure AddThread( Count : Integer );
    procedure StopThread;
  protected
    function CreateThread : TChangeHanldeThread;virtual;
  end;

    // 普通对象
  TMyChangeInfo = class( TMyChangeBase )
  public
    constructor Create;
  end;

    // 界面对象
  TMyFaceChange = class( TMyChangeBase )
  public
    constructor Create;
  protected
    function CreateThread : TChangeHanldeThread;override;
  end;

    // Xml对象
  TMyXmlChange = class( TMyChangeBase )
  protected
    XmlLock : TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
  public
    procedure EnterXml;
    procedure LeaveXml;
  protected
    function CreateThread : TChangeHanldeThread;override;
  end;

    // 数据对象
  TMyDataChange = class( TMyChangeBase )
  protected
    DataLock : TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
  public
    procedure EnterData;
    procedure LeaveData;
  protected
    function CreateThread : TChangeHanldeThread;override;
  end;

    // 子界面 变化 对象
  TMyChildFaceChange = class
  public
    procedure AddChange( ChangeInfo : TChangeInfo );
    procedure InsertChange( ChangeInfo : TChangeInfo );
  end;

    // 子Xml 变化 对象
  TMyChildXmlChange = class
  public
    procedure AddChange( ChangeInfo : TChangeInfo );
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' Json 命令相关 ' }

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

    // 命令类 父类
  TMsgBase = class( TChangeInfo )
  private
    DestoryObjList : TObjectList;
  public
    constructor Create;
    procedure Update;override;
    destructor Destroy; override;
  protected        // 命令对象的 子对象
    procedure BeforeSetMsgStr; virtual;
    procedure AddDestoryObj( Obj : TObject );
  public        // 命令对象 序列化
    function getMsg : string;
    function getMsgStr : string;
    function getMsgType : string; virtual;
  public       // 命令对象 逆序列化
    procedure SetMsg( Msg : string );
    procedure SetMsgStr( MsgStr : string );
  end;

    // 发送命令的信息
  TMsgInfo = class
  public
    iMsgType : string;
    iMsgStr : string;
  published
    property MsgType : string Read iMsgType Write iMsgType;
    property MsgStr : string Read iMsgStr Write iMsgStr;
  public
    procedure SetMsgInfo( _MsgType, _MsgStr : string );
  public        // 命令对象 序列化
    procedure SetMsg( Msg : string );
    function getMsg : string;
  end;

    // 命令工厂
  TMsgFactory = class
  private
    FactoryType : string;
  protected
    MsgType : string;
  public
    constructor Create( _FactoryType : string );
    procedure SetMsg( _MsgType : string );
    function CheckType : Boolean;
    function get : TMsgBase; virtual;abstract;
  end;
  TMsgFactoryList = class( TObjectList<TMsgFactory> )end;

    // 命令处理对象
  TMyMsgChange = class( TMyChangeBase )
  private
    MsgFactoryList : TMsgFactoryList;
  public
    constructor Create;
    procedure AddMsgFactory( MsgFactory : TMsgFactory );
    procedure AddMsg( Msg : string );
    destructor Destroy; override;
  protected
    procedure SetFactoryList;virtual;
  end;

  MsgUtil = class
  public
    class function getMsg( MsgType, MsgStr : string ): string;
  public
    class function AddMsg( MsgListStr, Msg : string ): string;
    class function getMsgList( MsgListStr : string ): TStringList;
  public
    class function AddLevelTwoMsg( MsgListStr, Msg : string ): string;
    class function getLevelTwoMsgList( MsgListStr : string ): TStringList;
  end;

{$EndRegion}

const
  Split_MsgList = '<Split>';
  Split_LevelTwoMsgList = '<Split_Two>';

  HandleCount_Sleep = 10;

var
  Memory_IsFree : Boolean = True;
  MyFaceChange : TMyFaceChange; // 界面变化对象
  MyXmlChange : TMyXmlChange; // Xml变化对象

implementation

uses UXmlUtil;

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
    if tk = tkFloat then  // 浮点数，转化为通用符号
      Result.Add( ProName, MyRegionUtil.ReadRemoteTimeStr( Double( ProValue ) ) )
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
        if tk = tkFloat then  // 浮点数，通用符号转换为当地符号
          Value := FloatToStr( MyRegionUtil.ReadLocalTime( Value ) );
        SetPropValue( Obj, ProName, Variant( Value ) );
      end;
    except
    end;
  end;
  FreeMem(PropList);
end;


{ TMsgBase }

procedure TMsgBase.AddDestoryObj(Obj: TObject);
begin
  DestoryObjList.Add( Obj );
end;

procedure TMsgBase.BeforeSetMsgStr;
begin

end;

constructor TMsgBase.Create;
begin
  DestoryObjList := nil;
end;

destructor TMsgBase.Destroy;
begin
  DestoryObjList.Free;
  inherited;
end;

function TMsgBase.getMsg: string;
var
  MsgInfo : TMsgInfo;
  MsgType, MsgStr : string;
begin
  MsgType := getMsgType;
  MsgStr := getMsgStr;

  MsgInfo := TMsgInfo.Create;
  MsgInfo.SetMsgInfo( MsgType, MsgStr );
  Result := MsgInfo.getMsg;
  MsgInfo.Free;
end;

function TMsgBase.getMsgStr: string;
begin
  Result := JsonUtil.getJsonStr( Self );
end;

function TMsgBase.getMsgType: string;
begin

end;

procedure TMsgBase.SetMsg(Msg: string);
var
  MsgInfo : TMsgInfo;
begin
  MsgInfo := TMsgInfo.Create;
  MsgInfo.SetMsg( Msg );
  SetMsgStr( MsgInfo.MsgStr );
  MsgInfo.Free;
end;

procedure TMsgBase.SetMsgStr(MsgStr: string);
var
  JsonObject : TlkJSONobject;
begin
  DestoryObjList := TObjectList.Create;

  BeforeSetMsgStr;

  JsonUtil.SetJsobStr( Self, MsgStr );
end;

procedure TMsgBase.Update;
begin
  inherited;
end;

{ TMsgInfo }

function TMsgInfo.getMsg: string;
begin
  Result := JsonUtil.getJsonStr( Self );
end;

procedure TMsgInfo.SetMsg(Msg: string);
begin
  JsonUtil.SetJsobStr( Self, Msg );
end;

procedure TMsgInfo.SetMsgInfo(_MsgType, _MsgStr: string);
begin
  MsgType := _MsgType;
  MsgStr := _MsgStr;
end;

{ TChangeInfo }

procedure TChangeInfo.Update;
begin

end;

{ TChangeInfoBox }

procedure TChangeInfoBox.AddChangeInfo(ChangeInfo: TChangeInfo);
begin
  Lock.Enter;
  try
    ChangeInfoList.Add( ChangeInfo );
  except
  end;
  Lock.Leave;
end;

constructor TChangeInfoBox.Create;
begin
  Lock := TCriticalSection.Create;
  ChangeInfoList := TChangeInfoList.Create;
  ChangeInfoList.OwnsObjects := False;
end;

destructor TChangeInfoBox.Destroy;
begin
  ChangeInfoList.OwnsObjects := True;
  ChangeInfoList.Free;
  Lock.Free;
  inherited;
end;

function TChangeInfoBox.ExistChange: Boolean;
begin
  Lock.Enter;
  try
    Result := ChangeInfoList.Count > 0;
  except
  end;
  Lock.Leave;
end;

function TChangeInfoBox.getChangeCount: Integer;
begin
  Lock.Enter;
  try
    Result := ChangeInfoList.Count;
  except
  end;
  Lock.Leave;
end;

function TChangeInfoBox.getChangeInfo: TChangeInfo;
begin
  Lock.Enter;
  try
    if ChangeInfoList.Count > 0 then
    begin
      Result := ChangeInfoList[0];
      ChangeInfoList.Delete(0);
    end
    else
      Result := nil;
  except
  end;
  Lock.Leave;
end;

procedure TChangeInfoBox.InsertChangeInfo(ChangeInfo: TChangeInfo);
begin
  Lock.Enter;
  try
    ChangeInfoList.Insert( 0, ChangeInfo );
  except
  end;
  Lock.Leave;
end;

{ TChangeHanldeThread }

constructor TChangeHanldeThread.Create;
begin
  inherited Create;
  IsDebug := False;
  IsHandleAll := False;
end;

destructor TChangeHanldeThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  inherited;
end;

procedure TChangeHanldeThread.EmptyJobHandle;
begin
  if not Terminated then
    Suspend;
end;

procedure TChangeHanldeThread.Execute;
var
  ChangeInfo : TChangeInfo;
  HandleCount : Integer;
  HasMsg : Boolean;
begin
  HandleCount := 0;
  HasMsg := False;
  while not Terminated or HasMsg do
  begin
      // 获取变化
    ChangeInfo := ChangeInfoBox.getChangeInfo;

      // 处理路径变化
    if ChangeInfo = nil then
    begin
      HasMsg := False;
      EmptyJobHandle; // 没有 Job
      Continue;
    end
    else   // 部分线程必须全部完成才能结束
    if IsHandleAll then
      HasMsg := True;

    try  // 处理变化
      Handle( ChangeInfo );
    except
      DebugLog( 'Error' );
    end;

    try  // 盗版 则不释放内存
      if Memory_IsFree then
        ChangeInfo.Free;
    except
    end;

      // 暂停一下
    Inc( HandleCount );
    if HandleCount >= HandleCount_Sleep then
    begin
      Sleep(1);
      HandleCount := 0;
    end;

  end;

  inherited;
end;

procedure TChangeHanldeThread.Handle(ChangeInfo: TChangeInfo);
begin
  ChangeInfo.Update;
end;

procedure TChangeHanldeThread.SetChangeInfoBox(_ChangeInfoBox: TChangeInfoBox);
begin
  ChangeInfoBox := _ChangeInfoBox;
end;

procedure TChangeHanldeThread.SetIsDebug(_IsDebug: Boolean);
begin
  IsDebug := _IsDebug;
end;

{ TFaceChangeHandleThread }

procedure TFaceChangeHandleThread.Handle(ChangeInfo: TChangeInfo);
begin
  SelectChangeInfo := ChangeInfo;
  Synchronize( HandleFaceChange );
end;

procedure TFaceChangeHandleThread.HandleFaceChange;
begin
  try
    SelectChangeInfo.Update;
  except
  end;
end;

{ TDataChangeHandleThread }

procedure TDataChangeHandleThread.Handle(ChangeInfo: TChangeInfo);
begin
  DataLock.Enter;
  try
    ChangeInfo.Update;
  except
  end;
  DataLock.Leave;
end;

procedure TDataChangeHandleThread.SetDataLock(_DataLock: TCriticalSection);
begin
  DataLock := _DataLock;
end;

{ TMyChangeInfo }

procedure TMyChangeBase.AddChange(ChangeInfo: TChangeInfo);
begin
  ChangeInfoBox.AddChangeInfo( ChangeInfo );
  ChangeHandThreadList.RunAllThread;
end;

procedure TMyChangeBase.AddThread(Count: Integer);
var
  i : Integer;
  NewThread : TChangeHanldeThread;
begin
  for i := 0 to Count - 1 do
  begin
    NewThread := CreateThread;
    NewThread.SetIsDebug( IsDebug );
    NewThread.SetChangeInfoBox( ChangeInfoBox );
    ChangeHandThreadList.Add( NewThread );
  end;
end;

procedure TMyChangeBase.StopThread;
begin
  IsRun := False;

  ChangeHandThreadList.Clear;
end;

constructor TMyChangeBase.Create;
begin
  IsRun := True;
  IsDebug := False;
  ChangeInfoBox := TChangeInfoBox.Create;
  ChangeHandThreadList := TChangeHandleThreadList.Create;
end;

function TMyChangeBase.CreateThread: TChangeHanldeThread;
begin
  Result := TChangeHanldeThread.Create;
end;

destructor TMyChangeBase.Destroy;
begin
  IsRun := False;
  ChangeHandThreadList.Free;
  ChangeInfoBox.Free;
  inherited;
end;

procedure TMyChangeBase.InsertChange(ChangeInfo: TChangeInfo);
begin
  ChangeInfoBox.InsertChangeInfo( ChangeInfo );
  ChangeHandThreadList.RunAllThread;
end;

{ TMyChangeInfo }

constructor TMyChangeInfo.Create;
begin
  inherited;
  AddThread(1);
end;

{ TMyFaceChange }

procedure TMyChildFaceChange.AddChange(ChangeInfo: TChangeInfo);
begin
  MyFaceChange.AddChange( ChangeInfo );
end;

procedure TMyChildFaceChange.InsertChange(ChangeInfo: TChangeInfo);
begin
  MyFaceChange.InsertChange( ChangeInfo );
end;

{ TMyDataChange }


constructor TMyDataChange.Create;
begin
  inherited;
  DataLock := TCriticalSection.Create;
end;

function TMyDataChange.CreateThread: TChangeHanldeThread;
var
  DataThread : TDataChangeHandleThread;
begin
  DataThread := TDataChangeHandleThread.Create;
  DataThread.SetDataLock( DataLock );
  Result := DataThread;
end;

destructor TMyDataChange.Destroy;
begin
  DataLock.Free;
  inherited;
end;

procedure TMyDataChange.EnterData;
begin
  DataLock.Enter;
end;

procedure TMyDataChange.LeaveData;
begin
  DataLock.Leave;
end;

{ TXmlChangeHandleThread }

constructor TXmlChangeHandleThread.Create;
begin
  inherited;
  IsHandleAll := True;
end;

procedure TXmlChangeHandleThread.Handle(ChangeInfo: TChangeInfo);
begin
  XmlLock.Enter;
  try
    ChangeInfo.Update;
  except
  end;
  XmlLock.Leave;
end;

procedure TXmlChangeHandleThread.SetXmlLock(_XmlLock: TCriticalSection);
begin
  XmlLock := _XmlLock;
end;

{ TMyXmlWriteData }

procedure TMyChildXmlChange.AddChange(ChangeInfo: TChangeInfo);
begin
  MyXmlChange.AddChange( ChangeInfo );
end;

{ TChangeHandleThreadList }

procedure TChangeHandleThreadList.RunAllThread;
var
  i : Integer;
begin
  for i := 0 to Count - 1 do
    Self[i].Resume;
end;

{ TMyMsgChange }

procedure TMyMsgChange.AddMsg(Msg: string);
var
  i : Integer;
  MsgInfo : TMsgInfo;
  MsgFactory : TMsgFactory;
  MsgBase : TMsgBase;
begin
  MsgInfo := TMsgInfo.Create;
  MsgInfo.SetMsg( Msg );
  for i := 0 to MsgFactoryList.Count - 1 do
  begin
    MsgFactory := MsgFactoryList[i];
    MsgFactory.SetMsg( MsgInfo.MsgType );
    if MsgFactory.CheckType then
    begin
      MsgBase := MsgFactory.get;
      if MsgBase <> nil then
      begin
        MsgBase.SetMsgStr( MsgInfo.MsgStr );
        AddChange( MsgBase );
      end;
      Break;
    end;
  end;
  MsgInfo.Free;
end;

procedure TMyMsgChange.AddMsgFactory(MsgFactory: TMsgFactory);
begin
  MsgFactoryList.Add( MsgFactory );
end;

constructor TMyMsgChange.Create;
begin
  inherited;
  MsgFactoryList := TMsgFactoryList.Create;
  SetFactoryList;
end;

destructor TMyMsgChange.Destroy;
begin
  MsgFactoryList.Free;
  inherited;
end;

procedure TMyMsgChange.SetFactoryList;
begin

end;

{ TMsgFactory }

function TMsgFactory.CheckType: Boolean;
begin
  Result := Pos( FactoryType, MsgType ) > 0;
end;

constructor TMsgFactory.Create(_FactoryType: string);
begin
  FactoryType := _FactoryType;
end;

procedure TMsgFactory.SetMsg(_MsgType: string);
begin
  MsgType := _MsgType;
end;

{ TMyFaceChangeBase }

constructor TMyFaceChange.Create;
begin
  inherited;
  AddThread(1);
end;

function TMyFaceChange.CreateThread: TChangeHanldeThread;
begin
  Result := TFaceChangeHandleThread.Create;
end;

{ MsgUtil }

class function MsgUtil.AddLevelTwoMsg(MsgListStr, Msg: string): string;
begin
  if MsgListStr = '' then
    MsgListStr := Msg
  else
    MsgListStr := MsgListStr + Split_LevelTwoMsgList + Msg;
  Result := MsgListStr;
end;

class function MsgUtil.AddMsg(MsgListStr, Msg: string): string;
begin
  if MsgListStr = '' then
    MsgListStr := Msg
  else
    MsgListStr := MsgListStr + Split_MsgList + Msg;
  Result := MsgListStr;
end;

class function MsgUtil.getLevelTwoMsgList(MsgListStr: string): TStringList;
begin
  Result := MySplitStr.getList( MsgListStr, Split_LevelTwoMsgList );
end;

class function MsgUtil.getMsg(MsgType, MsgStr: string): string;
var
  MsgInfo : TMsgInfo;
begin
  MsgInfo := TMsgInfo.Create;
  MsgInfo.SetMsgInfo( MsgType, MsgStr );
  Result := MsgInfo.getMsg;
  MsgInfo.Free;
end;

class function MsgUtil.getMsgList(MsgListStr: string): TStringList;
begin
  Result := MySplitStr.getList( MsgListStr, Split_MsgList );
end;

{ TMyXmlChange }

constructor TMyXmlChange.Create;
begin
  inherited;
  XmlLock := TCriticalSection.Create;
  AddThread(1);
end;

function TMyXmlChange.CreateThread: TChangeHanldeThread;
var
  XmlThread : TXmlChangeHandleThread;
begin
  XmlThread := TXmlChangeHandleThread.Create;
  XmlThread.SetXmlLock( XmlLock );
  Result := XmlThread;
end;

destructor TMyXmlChange.Destroy;
begin
  XmlLock.Free;
  inherited;
end;

procedure TMyXmlChange.EnterXml;
begin
  XmlLock.Enter;
end;

procedure TMyXmlChange.LeaveXml;
begin
  XmlLock.Leave;
end;

{ TFaceChangeInfo }

procedure TFaceChangeInfo.AddChange;
begin
  MyFaceChange.AddChange( Self );
end;

procedure TFaceChangeInfo.InsertChange;
begin
  MyFaceChange.InsertChange( Self );
end;

{ TXmlChangeInfo }

procedure TXmlChangeInfo.AddChange;
begin
  MyXmlChange.AddChange( Self );
end;

procedure TXmlChangeInfo.InsertChange;
begin
  MyXmlChange.InsertChange( Self );
end;

end.
