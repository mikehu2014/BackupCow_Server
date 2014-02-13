unit UDataUtil;

interface

uses Datasnap.DBClient, Data.DB;

type

  TDataInfo = class
  public
    ClientDataSet : TClientDataSet;
  public
    constructor Create;
    destructor Destroy; override;
  protected     // 初始化
    procedure IniColumn;virtual;abstract;
    procedure AddCol( ColName, ColType : string );
    procedure SetKeyCol( ColName : string );
    procedure CreateData;
  protected     // 增删
    procedure AddRow( const Values: array of const );
    procedure RemoveRow( KeyValue : Variant );
  protected     // 查
    function ReadKeyExist( KeyValue : Variant ): Boolean;
    function ReadKeyColValue( KeyValue : Variant; ColName : string ): Variant;
  protected     // 改
    procedure BeforeEdit;
    procedure SetKeyColValue( KeyValue : Variant; ColName : string; ColValue : Variant );
    procedure AfterEdit;
  end;

const
  ColType_String = 's';
  ColType_Int = 'i';
  ColType_Int64 = 'i64';

implementation

{ TDataInfo }

procedure TDataInfo.AddCol(ColName, ColType: string);
var
  fk: TFieldType;
begin
  if ColType = ColType_String then
    fk := ftString
  else
  if ColType = ColType_Int then
    fk := ftInteger
  else
  if ColType = ColType_Int64 then
    fk := ftLargeint;

  with ClientDataSet.FieldDefs.AddFieldDef do
  begin
    Name := ColName;
    DataType := fk;
  end;
end;

procedure TDataInfo.AddRow(const Values: array of const);
begin
  ClientDataSet.AppendRecord( Values );
end;

procedure TDataInfo.AfterEdit;
begin
  ClientDataSet.Post;
end;

procedure TDataInfo.BeforeEdit;
begin
  ClientDataSet.Edit;
end;

constructor TDataInfo.Create;
begin
  ClientDataSet := TClientDataSet.Create(nil);
  IniColumn;
end;

procedure TDataInfo.CreateData;
begin
  ClientDataSet.CreateDataSet;
end;

destructor TDataInfo.Destroy;
begin
  ClientDataSet.Free;
  inherited;
end;

function TDataInfo.ReadKeyColValue(KeyValue : Variant; ColName: string): Variant;
begin
  if ClientDataSet.FindKey( [ KeyValue ] ) then
    Result := ClientDataSet.FieldValues[ ColName ];
end;

function TDataInfo.ReadKeyExist(KeyValue: Variant): Boolean;
begin
  Result := ClientDataSet.FindKey( [ KeyValue ] );
end;

procedure TDataInfo.RemoveRow(KeyValue: Variant);
begin
  while ClientDataSet.FindKey( [ KeyValue ] ) do
    ClientDataSet.Delete;
end;

procedure TDataInfo.SetKeyCol(ColName: string);
begin
  ClientDataSet.IndexFieldNames := ColName;
end;

procedure TDataInfo.SetKeyColValue(KeyValue : Variant; ColName: string;
  ColValue: Variant);
begin
  BeforeEdit;
  if ClientDataSet.FindKey( [ KeyValue ] ) then
    ClientDataSet.FieldValues[ ColName ] := ColValue;
  AfterEdit;
end;

end.
