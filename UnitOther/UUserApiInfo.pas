unit UUserApiInfo;

interface

uses Generics.Collections, math;

type

{$Region ' 备份路径统计信息 ' }

    // 修改
  TMaxBackupPathWriteHandle = class
  public
    FilePath : string;
  public
    constructor Create( _FilePath : string );
  end;


    // 添加
  TMaxBackupPathAddHandle = class( TMaxBackupPathWriteHandle )
  public
    procedure Update;
  private
    procedure AddToXml;
  end;

    // 删除
  TMaxBackupPathRemoveHandle = class( TMaxBackupPathWriteHandle )
  protected
    procedure Update;
  private
    procedure RemoveFromXml;
  end;

{$EndRegion}

{$Region ' 最大备份数的文件类型 ' }

    // 修改
  TMaxBackupCountWriteHandle = class( TMaxBackupPathWriteHandle )
  public
    TypeName : string;
  public
    procedure SetTypeName( _TypeName : string );
  end;

    // 添加
  TMaxBackupCountAddHandle = class( TMaxBackupCountWriteHandle )
  public
    FileCount : integer;
  public
    procedure SetFileCount( _FileCount : integer );
    procedure Update;
  private
    procedure AddToXml;
  end;

    // 删除
  TMaxBackupCountRemoveHandle = class( TMaxBackupCountWriteHandle )
  protected
    procedure Update;
  private
    procedure RemoveFromXml;
  end;

{$EndRegion}

{$Region ' 最大备份数的文件类型 ' }

    // 修改
  TMaxBackupSizeWriteHandle = class( TMaxBackupPathWriteHandle )
  public
    TypeName : string;
  public
    procedure SetTypeName( _TypeName : string );
  end;

    // 添加
  TMaxBackupSizeAddHandle = class( TMaxBackupSizeWriteHandle )
  public
    FileSize : int64;
  public
    procedure SetFileSize( _FileSize : int64 );
    procedure Update;
  private
    procedure AddToXml;
  end;

    // 删除
  TMaxBackupSizeRemoveHandle = class( TMaxBackupSizeWriteHandle )
  protected
    procedure Update;
  private
    procedure RemoveFromXml;
  end;

{$EndRegion}


{$Region ' 读取文件统计信息 ' }

    // 文件数目最大的文件类型
  TMaxBackupCountInfo = class
  public
    TypeName : string;
    FileCount : Integer;
  public
    constructor Create( _TypeName : string );
    procedure AddFileCount( NewFileCount : Integer );
  end;
  TMaxBackupCountList = class( TObjectList<TMaxBackupCountInfo> )end;

    // 文件空间最大的文件类型
  TMaxBackupSizeInfo = class
  public
    TypeName : string;
    FileSize : Int64;
  public
    constructor Create( _TypeName : string );
    procedure AddFileSize( NewFileSize : Int64 );
  end;
  TMaxBackupSizeList = class( TObjectList<TMaxBackupSizeInfo> )end;


    // 读取 备份文件分析信息
  TBackupMaxAnalyzeReadXml = class
  private
    MaxBackupCountList : TMaxBackupCountList;
    MaxBackupSizeList : TMaxBackupSizeList;
  public
    constructor Create;
    function get : string;
    destructor Destroy; override;
  private
    procedure ReadMaxBackupInfo;
    procedure SortMaxBackupInfo;
    function GetMaxBackupInfo: string;
  private
    function FindMaxBackupCount( TypeName : string ): Integer;
    function FindMaxBackupSize( TypeName : string ): Integer;
  end;

{$EndRegion}


    // Api
  MaxBackupPathApi = class
  public
    class procedure AddPath( FilePath : string );
    class procedure RemovePath( FilePath : string );
  public
    class procedure AddCount( FilePath, TypeName : string; FileCount : Integer );
    class procedure AddSize( FilePath, TypeName : string; FileSize : Int64 );
  end;

const
  Split_UserType = '|';
  Split_UserList = '_';

var
  BackupAnalyze_LastTime : string = '';

implementation

uses UUserXmlInfo, xmldom, XMLIntf, msxmldom, XMLDoc, UXmlUtil, UChangeInfo;


constructor TMaxBackupPathWriteHandle.Create( _FilePath : string );
begin
  FilePath := _FilePath;
end;


{ TMaxBackupPathAddHandle }

procedure TMaxBackupPathAddHandle.AddToXml;
var
  MaxBackupPathAddXml : TMaxBackupPathAddXml;
begin
  MaxBackupPathAddXml := TMaxBackupPathAddXml.Create( FilePath );
  MaxBackupPathAddXml.AddChange;
end;

procedure TMaxBackupPathAddHandle.Update;
begin
  AddToXml;
end;

{ TMaxBackupPathRemoveHandle }

procedure TMaxBackupPathRemoveHandle.RemoveFromXml;
var
  MaxBackupPathRemoveXml : TMaxBackupPathRemoveXml;
begin
  MaxBackupPathRemoveXml := TMaxBackupPathRemoveXml.Create( FilePath );
  MaxBackupPathRemoveXml.AddChange;
end;

procedure TMaxBackupPathRemoveHandle.Update;
begin
  RemoveFromXml;
end;

procedure TMaxBackupCountWriteHandle.SetTypeName( _TypeName : string );
begin
  TypeName := _TypeName;
end;

{ TMaxBackupCountAddHandle }

procedure TMaxBackupCountAddHandle.AddToXml;
var
  MaxBackupCountAddXml : TMaxBackupCountAddXml;
begin
  MaxBackupCountAddXml := TMaxBackupCountAddXml.Create( FilePath );
  MaxBackupCountAddXml.SetTypeName( TypeName );
  MaxBackupCountAddXml.SetFileCount( FileCount );
  MaxBackupCountAddXml.AddChange;
end;

procedure TMaxBackupCountAddHandle.SetFileCount(_FileCount: integer);
begin
  FileCount := _FileCount;
end;

procedure TMaxBackupCountAddHandle.Update;
begin
  AddToXml;
end;

{ TMaxBackupCountRemoveHandle }

procedure TMaxBackupCountRemoveHandle.RemoveFromXml;
var
  MaxBackupCountRemoveXml : TMaxBackupCountRemoveXml;
begin
  MaxBackupCountRemoveXml := TMaxBackupCountRemoveXml.Create( FilePath );
  MaxBackupCountRemoveXml.SetTypeName( TypeName );
  MaxBackupCountRemoveXml.AddChange;
end;

procedure TMaxBackupCountRemoveHandle.Update;
begin
  RemoveFromXml;
end;

procedure TMaxBackupSizeWriteHandle.SetTypeName( _TypeName : string );
begin
  TypeName := _TypeName;
end;

{ TMaxBackupSizeAddHandle }

procedure TMaxBackupSizeAddHandle.AddToXml;
var
  MaxBackupSizeAddXml : TMaxBackupSizeAddXml;
begin
  MaxBackupSizeAddXml := TMaxBackupSizeAddXml.Create( FilePath );
  MaxBackupSizeAddXml.SetTypeName( TypeName );
  MaxBackupSizeAddXml.SetFileSize( FileSize );
  MaxBackupSizeAddXml.AddChange;
end;

procedure TMaxBackupSizeAddHandle.SetFileSize(_FileSize: int64);
begin
  FileSize := _FileSize;
end;

procedure TMaxBackupSizeAddHandle.Update;
begin
  AddToXml;
end;

{ TMaxBackupSizeRemoveHandle }

procedure TMaxBackupSizeRemoveHandle.RemoveFromXml;
var
  MaxBackupSizeRemoveXml : TMaxBackupSizeRemoveXml;
begin
  MaxBackupSizeRemoveXml := TMaxBackupSizeRemoveXml.Create( FilePath );
  MaxBackupSizeRemoveXml.SetTypeName( TypeName );
  MaxBackupSizeRemoveXml.AddChange;
end;

procedure TMaxBackupSizeRemoveHandle.Update;
begin
  RemoveFromXml;
end;







{ MaxBackupPathApi }

class procedure MaxBackupPathApi.AddCount(FilePath, TypeName: string;
  FileCount: Integer);
var
  MaxBackupCountAddHandle : TMaxBackupCountAddHandle;
begin
  MaxBackupCountAddHandle := TMaxBackupCountAddHandle.Create( FilePath );
  MaxBackupCountAddHandle.SetTypeName( TypeName );
  MaxBackupCountAddHandle.SetFileCount( FileCount );
  MaxBackupCountAddHandle.Update;
  MaxBackupCountAddHandle.Free;
end;



class procedure MaxBackupPathApi.AddPath(FilePath: string);
var
  MaxBackupPathAddHandle : TMaxBackupPathAddHandle;
begin
  MaxBackupPathAddHandle := TMaxBackupPathAddHandle.Create( FilePath );
  MaxBackupPathAddHandle.Update;
  MaxBackupPathAddHandle.Free;
end;



class procedure MaxBackupPathApi.AddSize(FilePath, TypeName: string;
  FileSize: Int64);
var
  MaxBackupSizeAddHandle : TMaxBackupSizeAddHandle;
begin
  MaxBackupSizeAddHandle := TMaxBackupSizeAddHandle.Create( FilePath );
  MaxBackupSizeAddHandle.SetTypeName( TypeName );
  MaxBackupSizeAddHandle.SetFileSize( FileSize );
  MaxBackupSizeAddHandle.Update;
  MaxBackupSizeAddHandle.Free;
end;

class procedure MaxBackupPathApi.RemovePath(FilePath: string);
var
  MaxBackupPathRemoveHandle : TMaxBackupPathRemoveHandle;
begin
  MaxBackupPathRemoveHandle := TMaxBackupPathRemoveHandle.Create( FilePath );
  MaxBackupPathRemoveHandle.Update;
  MaxBackupPathRemoveHandle.Free;
end;



{ TBackupMaxAnalyzeRead }

constructor TBackupMaxAnalyzeReadXml.Create;
begin
  MaxBackupCountList := TMaxBackupCountList.Create;
  MaxBackupSizeList := TMaxBackupSizeList.Create;
end;

destructor TBackupMaxAnalyzeReadXml.Destroy;
begin
  MaxBackupSizeList.Free;
  MaxBackupCountList.Free;
  inherited;
end;

function TBackupMaxAnalyzeReadXml.FindMaxBackupCount(TypeName: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to MaxBackupCountList.Count - 1 do
    if MaxBackupCountList[i].TypeName = TypeName then
    begin
      Result := i;
      Break;
    end;
end;

function TBackupMaxAnalyzeReadXml.FindMaxBackupSize(TypeName: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to MaxBackupSizeList.Count - 1 do
    if MaxBackupSizeList[i].TypeName = TypeName then
    begin
      Result := i;
      Break;
    end;
end;

function TBackupMaxAnalyzeReadXml.get: string;
begin
  try
      // 读取
    ReadMaxBackupInfo;

      // 排序
    SortMaxBackupInfo;

      // 序列化
    Result := GetMaxBackupInfo;
  except
    Result := '';
  end;
end;

function TBackupMaxAnalyzeReadXml.GetMaxBackupInfo: string;
var
  i, ReadCount : Integer;
  MaxCountStr, MaxSizeStr : string;
begin
    // 文件数统计
  MaxCountStr := '';
  ReadCount := Min( 3, MaxBackupCountList.Count );
  for i := 0 to ReadCount - 1 do
  begin
    if MaxCountStr <> '' then
      MaxCountStr := MaxCountStr + Split_UserList;
    MaxCountStr := MaxCountStr + MaxBackupCountList[i].TypeName;
  end;

    // 文件空间统计
  MaxSizeStr := '';
  ReadCount := Min( 3, MaxBackupSizeList.Count );
  for i := 0 to ReadCount - 1 do
  begin
    if MaxSizeStr <> '' then
      MaxSizeStr := MaxSizeStr + Split_UserList;
    MaxSizeStr := MaxSizeStr + MaxBackupSizeList[i].TypeName;
  end;

    // 返回
  Result := MaxCountStr + Split_UserType + MaxSizeStr;
end;

procedure TBackupMaxAnalyzeReadXml.ReadMaxBackupInfo;
var
  MyUserNode, MaxBackupPathNodeList : IXMLNode;
  MaxBackupPathNode, MaxBackupCountNodeList, MaxBackupSizeNodeList : IXMLNode;
  MaxBackupCountNode, MaxBackupSizeNode : IXMLNode;
  i, j, SelectIndex: Integer;
  TypeName : string;
  FileCount : Integer;
  FileSize : Int64;
  MaxBackupCountInfo : TMaxBackupCountInfo;
  MaxBackupSizeInfo : TMaxBackupSizeInfo;
begin
  MyUserNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyUserInfo );
  MaxBackupPathNodeList := MyXmlUtil.AddChild( MyUserNode, Xml_MaxBackupPathList );

    // 遍历所有路径
  for i := 0 to MaxBackupPathNodeList.ChildNodes.Count - 1 do
  begin
    MaxBackupPathNode := MaxBackupPathNodeList.ChildNodes[i];

      // 遍历文件数
    MaxBackupCountNodeList := MyXmlUtil.AddChild( MaxBackupPathNode, Xml_MaxBackupCountList );
    for j := 0 to MaxBackupCountNodeList.ChildNodes.Count - 1 do
    begin
      MaxBackupCountNode := MaxBackupCountNodeList.ChildNodes[j];
      TypeName := MyXmlUtil.GetChildValue( MaxBackupCountNode, Xml_TypeName );
      FileCount := MyXmlUtil.GetChildIntValue( MaxBackupCountNode, Xml_FileCount );
      SelectIndex := FindMaxBackupCount( TypeName );
      if SelectIndex < 0 then
      begin
        MaxBackupCountInfo := TMaxBackupCountInfo.Create( TypeName );
        MaxBackupCountList.Add( MaxBackupCountInfo );
      end
      else
        MaxBackupCountInfo := MaxBackupCountList[ SelectIndex ];
      MaxBackupCountInfo.AddFileCount( FileCount );
    end;

      // 遍历文件空间
    MaxBackupSizeNodeList := MyXmlUtil.AddChild( MaxBackupPathNode, Xml_MaxBackupSizeList );
    for j := 0 to MaxBackupSizeNodeList.ChildNodes.Count - 1 do
    begin
      MaxBackupSizeNode := MaxBackupSizeNodeList.ChildNodes[j];
      TypeName := MyXmlUtil.GetChildValue( MaxBackupSizeNode, Xml_TypeName );
      FileSize := MyXmlUtil.GetChildInt64Value( MaxBackupSizeNode, Xml_FileSize );
      SelectIndex := FindMaxBackupSize( TypeName );
      if SelectIndex < 0 then
      begin
        MaxBackupSizeInfo := TMaxBackupSizeInfo.Create( TypeName );
        MaxBackupSizeList.Add( MaxBackupSizeInfo );
      end
      else
        MaxBackupSizeInfo := MaxBackupSizeList[ SelectIndex ];
      MaxBackupSizeInfo.AddFileSize( FileSize );
    end;
  end;
end;

procedure TBackupMaxAnalyzeReadXml.SortMaxBackupInfo;
var
  i, j: Integer;
  TempCountInfo : TMaxBackupCountInfo;
  TempSizeInfo : TMaxBackupSizeInfo;
begin
    // 文件数排序
  MaxBackupCountList.OwnsObjects := False;
  for i := 0 to MaxBackupCountList.Count - 2 do
    for j := 0 to MaxBackupCountList.Count - i - 2 do
      if MaxBackupCountList[j].FileCount < MaxBackupCountList[j+1].FileCount then
      begin
        TempCountInfo := MaxBackupCountList[j];
        MaxBackupCountList[j] := MaxBackupCountList[j+1];
        MaxBackupCountList[j+1] := TempCountInfo;
      end;
  MaxBackupCountList.OwnsObjects := True;

    // 文件空间排序
  MaxBackupSizeList.OwnsObjects := False;
  for i := 0 to MaxBackupSizeList.Count - 2 do
    for j := 0 to MaxBackupSizeList.Count - i - 2 do
      if MaxBackupSizeList[j].FileSize < MaxBackupSizeList[j+1].FileSize then
      begin
        TempSizeInfo := MaxBackupSizeList[j];
        MaxBackupSizeList[j] := MaxBackupSizeList[j+1];
        MaxBackupSizeList[j+1] := TempSizeInfo;
      end;
  MaxBackupSizeList.OwnsObjects := True;
end;

{ TMaxBackupCountInfo }

procedure TMaxBackupCountInfo.AddFileCount(NewFileCount: Integer);
begin
  FileCount := FileCount + NewFileCount;
end;

constructor TMaxBackupCountInfo.Create(_TypeName: string);
begin
  TypeName := _TypeName;
  FileCount := 0;
end;

{ TMaxBackupSizeInfo }

procedure TMaxBackupSizeInfo.AddFileSize(NewFileSize: Int64);
begin
  FileSize := FileSize + NewFileSize;
end;

constructor TMaxBackupSizeInfo.Create(_TypeName: string);
begin
  TypeName := _TypeName;
  FileSize := 0;
end;

end.
