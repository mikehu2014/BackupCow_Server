unit UUserXmlInfo;

interface

uses UChangeInfo, xmldom, XMLIntf, msxmldom, XMLDoc, UXmlUtil;

type

{$Region ' ����·��ͳ����Ϣ ' }

    // ����
  TMaxBackupPathChangeXml = class( TXmlChangeInfo )
  protected
    MyUserNode : IXMLNode;
    MaxBackupPathNodeList : IXMLNode;
  protected
    procedure Update;override;
  end;

    // �޸�
  TMaxBackupPathWriteXml = class( TMaxBackupPathChangeXml )
  public
    FilePath : string;
  protected
    MaxBackupPathIndex : Integer;
    MaxBackupPathNode : IXMLNode;
  public
    constructor Create( _FilePath : string );
  protected
    function FindMaxBackupPathNode: Boolean;
  end;

      // ���
  TMaxBackupPathAddXml = class( TMaxBackupPathWriteXml )
  protected
    procedure Update;override;
  end;

    // ɾ��
  TMaxBackupPathRemoveXml = class( TMaxBackupPathWriteXml )
  protected
    procedure Update;override;
  end;


{$EndRegion}

{$Region ' ��󱸷������ļ����� ' }

    // ����
  TMaxBackupCountChangeXml = class( TMaxBackupPathWriteXml )
  protected
    MaxBackupCountNodeList : IXMLNode;
  protected
    function FindMaxBackupCountNodeList : Boolean;
  end;

    // �޸�
  TMaxBackupCountWriteXml = class( TMaxBackupCountChangeXml )
  public
    TypeName : string;
  protected
    MaxBackupCountIndex : Integer;
    MaxBackupCountNode : IXMLNode;
  public
    procedure SetTypeName( _TypeName : string );
  protected
    function FindMaxBackupCountNode: Boolean;
  end;

      // ���
  TMaxBackupCountAddXml = class( TMaxBackupCountWriteXml )
  public
    FileCount : integer;
  public
    procedure SetFileCount( _FileCount : integer );
  protected
    procedure Update;override;
  end;

    // ɾ��
  TMaxBackupCountRemoveXml = class( TMaxBackupCountWriteXml )
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' ��󱸷ݿռ���ļ����� ' }

    // ����
  TMaxBackupSizeChangeXml = class( TMaxBackupPathWriteXml )
  protected
    MaxBackupSizeNodeList : IXMLNode;
  protected
    function FindMaxBackupSizeNodeList : Boolean;
  end;

    // �޸�
  TMaxBackupSizeWriteXml = class( TMaxBackupSizeChangeXml )
  public
    TypeName : string;
  protected
    MaxBackupSizeIndex : Integer;
    MaxBackupSizeNode : IXMLNode;
  public
    procedure SetTypeName( _TypeName : string );
  protected
    function FindMaxBackupSizeNode: Boolean;
  end;

    // ���
  TMaxBackupSizeAddXml = class( TMaxBackupSizeWriteXml )
  public
    FileSize : int64;
  public
    procedure SetFileSize( _FileSize : int64 );
  protected
    procedure Update;override;
  end;

    // ɾ��
  TMaxBackupSizeRemoveXml = class( TMaxBackupSizeWriteXml )
  protected
    procedure Update;override;
  end;


{$EndRegion}

const
  Xml_MyUserInfo = 'mui';
  Xml_MaxBackupPathList = 'mbpl';
  Xml_FilePath = 'fp';

const
  Xml_MaxBackupCountList = 'mbcl';
  Xml_TypeName = 'tn';
  Xml_FileCount = 'fc';

const
  Xml_MaxBackupSizeList = 'mbsl';
  Xml_FileSize = 'fs';

implementation

{ TMaxBackupPathChangeXml }

procedure TMaxBackupPathChangeXml.Update;
begin
  MyUserNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyUserInfo );
  MaxBackupPathNodeList := MyXmlUtil.AddChild( MyUserNode, Xml_MaxBackupPathList );
end;

{ TMaxBackupPathWriteXml }

constructor TMaxBackupPathWriteXml.Create( _FilePath : string );
begin
  FilePath := _FilePath;
end;


function TMaxBackupPathWriteXml.FindMaxBackupPathNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  for i := 0 to MaxBackupPathNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := MaxBackupPathNodeList.ChildNodes[i];
    if ( MyXmlUtil.GetChildValue( SelectNode, Xml_FilePath ) = FilePath ) then
    begin
      Result := True;
      MaxBackupPathIndex := i;
      MaxBackupPathNode := MaxBackupPathNodeList.ChildNodes[i];
      break;
    end;
  end;
end;

{ TMaxBackupPathAddXml }

procedure TMaxBackupPathAddXml.Update;
begin
  inherited;

  if FindMaxBackupPathNode then
    Exit;

  MaxBackupPathNode := MyXmlUtil.AddListChild( MaxBackupPathNodeList );
  MyXmlUtil.AddChild( MaxBackupPathNode, Xml_FilePath, FilePath );
end;

{ TMaxBackupPathRemoveXml }

procedure TMaxBackupPathRemoveXml.Update;
begin
  inherited;

  if not FindMaxBackupPathNode then
    Exit;

  MyXmlUtil.DeleteListChild( MaxBackupPathNodeList, MaxBackupPathIndex );
end;

{ TMaxBackupCountChangeXml }

function TMaxBackupCountChangeXml.FindMaxBackupCountNodeList : Boolean;
begin
  Result := FindMaxBackupPathNode;
  if Result then
    MaxBackupCountNodeList := MyXmlUtil.AddChild( MaxBackupPathNode, Xml_MaxBackupCountList );
end;

{ TMaxBackupCountWriteXml }

procedure TMaxBackupCountWriteXml.SetTypeName( _TypeName : string );
begin
  TypeName := _TypeName;
end;


function TMaxBackupCountWriteXml.FindMaxBackupCountNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  MaxBackupCountNodeList := nil;
  if not FindMaxBackupCountNodeList then
    Exit;
  for i := 0 to MaxBackupCountNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := MaxBackupCountNodeList.ChildNodes[i];
    if ( MyXmlUtil.GetChildValue( SelectNode, Xml_TypeName ) = TypeName ) then
    begin
      Result := True;
      MaxBackupCountIndex := i;
      MaxBackupCountNode := MaxBackupCountNodeList.ChildNodes[i];
      break;
    end;
  end;
end;

{ TMaxBackupCountAddXml }

procedure TMaxBackupCountAddXml.SetFileCount( _FileCount : integer );
begin
  FileCount := _FileCount;
end;

procedure TMaxBackupCountAddXml.Update;
var
  LastFileCount : Integer;
begin
  inherited;

    // �����������
  if not FindMaxBackupCountNode then
  begin
    if not Assigned( MaxBackupCountNodeList ) then  // ���ڵ㲻����
      Exit;
    MaxBackupCountNode := MyXmlUtil.AddListChild( MaxBackupCountNodeList );
    MyXmlUtil.AddChild( MaxBackupCountNode, Xml_TypeName, TypeName );
  end;
  LastFileCount := MyXmlUtil.GetChildIntValue( MaxBackupCountNode, Xml_FileCount );
  LastFileCount := LastFileCount + FileCount;

    // ˢ���ļ���
  MyXmlUtil.AddChild( MaxBackupCountNode, Xml_FileCount, LastFileCount );
end;

{ TMaxBackupCountRemoveXml }

procedure TMaxBackupCountRemoveXml.Update;
begin
  inherited;

  if not FindMaxBackupCountNode then
    Exit;

  MyXmlUtil.DeleteListChild( MaxBackupCountNodeList, MaxBackupCountIndex );
end;

{ TMaxBackupSizeChangeXml }

function TMaxBackupSizeChangeXml.FindMaxBackupSizeNodeList : Boolean;
begin
  Result := FindMaxBackupPathNode;
  if Result then
    MaxBackupSizeNodeList := MyXmlUtil.AddChild( MaxBackupPathNode, Xml_MaxBackupSizeList );
end;

{ TMaxBackupSizeWriteXml }

procedure TMaxBackupSizeWriteXml.SetTypeName( _TypeName : string );
begin
  TypeName := _TypeName;
end;


function TMaxBackupSizeWriteXml.FindMaxBackupSizeNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  MaxBackupSizeNodeList := nil;
  if not FindMaxBackupSizeNodeList then
    Exit;
  for i := 0 to MaxBackupSizeNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := MaxBackupSizeNodeList.ChildNodes[i];
    if ( MyXmlUtil.GetChildValue( SelectNode, Xml_TypeName ) = TypeName ) then
    begin
      Result := True;
      MaxBackupSizeIndex := i;
      MaxBackupSizeNode := MaxBackupSizeNodeList.ChildNodes[i];
      break;
    end;
  end;
end;

{ TMaxBackupSizeAddXml }

procedure TMaxBackupSizeAddXml.SetFileSize( _FileSize : int64 );
begin
  FileSize := _FileSize;
end;

procedure TMaxBackupSizeAddXml.Update;
var
  LastFileSize : Int64;
begin
  inherited;

    // �������򴴽�
  if not FindMaxBackupSizeNode then
  begin
    if not Assigned( MaxBackupSizeNodeList ) then  // ���ڵ㲻����
      Exit;

    MaxBackupSizeNode := MyXmlUtil.AddListChild( MaxBackupSizeNodeList );
    MyXmlUtil.AddChild( MaxBackupSizeNode, Xml_TypeName, TypeName );
  end;
  LastFileSize := MyXmlUtil.GetChildInt64Value( MaxBackupSizeNode, Xml_FileSize );
  LastFileSize := LastFileSize + FileSize;

    // ˢ���ļ��ռ�
  MyXmlUtil.AddChild( MaxBackupSizeNode, Xml_FileSize, LastFileSize );
end;

{ TMaxBackupSizeRemoveXml }

procedure TMaxBackupSizeRemoveXml.Update;
begin
  inherited;

  if not FindMaxBackupSizeNode then
    Exit;

  MyXmlUtil.DeleteListChild( MaxBackupSizeNodeList, MaxBackupSizeIndex );
end;



end.
