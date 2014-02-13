unit UMyCloudXmlInfo;

interface

uses UChangeInfo, xmldom, XMLIntf, msxmldom, XMLDoc, UXmlUtil, UMyUtil;

type

{$Region ' 数据修改 云路径信息 ' }

    // 父类
  TCloudPathChangeXml = class( TXmlChangeInfo )
  protected
    MyCloudNode : IXMLNode;
    CloudPathNodeList : IXMLNode;
  protected
    procedure Update;override;
  end;

    // 修改
  TCloudPathWriteXml = class( TCloudPathChangeXml )
  public
    CloudPath : string;
  protected
    CloudPathIndex : Integer;
    CloudPathNode : IXMLNode;
  public
    constructor Create( _CloudPath : string );
  protected
    function FindCloudPathNode: Boolean;
  end;

    // 添加
  TCloudPathAddXml = class( TCloudPathWriteXml )
  protected
    procedure Update;override;
  end;

    // 删除
  TCloudPathRemoveXml = class( TCloudPathWriteXml )
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 数据修改 云路径备份信息 ' }

    // 父类
  TCloudBackupPathChangeXml = class( TCloudPathWriteXml )
  protected
    CloudBackupPathNodeList : IXMLNode;
  protected
    function FindCloudBackupPathNodeList : Boolean;
  end;

    // 修改
  TCloudBackupPathWriteXml = class( TCloudBackupPathChangeXml )
  public
    BackupPath, OwnerID : string;
  protected
    CloudBackupPathIndex : Integer;
    CloudBackupPathNode : IXMLNode;
  public
    procedure SetBackupPath( _BackupPath, _OwnerID : string );
  protected
    function FindCloudBackupPathNode: Boolean;
  end;

    // 添加
  TCloudBackupPathAddXml = class( TCloudBackupPathWriteXml )
  public
    IsFile : boolean;
  public
    FileCount : integer;
    ItemSize : int64;
    LastBackupTime : TDateTime;
  public
    IsSaveDeleted : boolean;
    IsEncrypted : boolean;
    Password, PasswordHint : string;
  public
    procedure SetIsFile( _IsFile : boolean );
    procedure SetSpaceInfo( _FileCount : integer; _ItemSize : int64 );
    procedure SetLastBackupTime( _LastBackupTime : TDateTime );
    procedure SetIsSaveDeleted( _IsSaveDeleted : boolean );
    procedure SetEncryptInfo( _IsEncrypted : boolean; _Password, _PasswordHint : string );
  protected
    procedure Update;override;
  end;

    // 删除
  TCloudBackupPathRemoveXml = class( TCloudBackupPathWriteXml )
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 数据读取 ' }

    // 读取
  TCloudBackupPathReadXml = class
  public
    CloudBackupPathNode : IXMLNode;
    CloudPath : string;
  public
    constructor Create( _CloudBackupPathNode : IXMLNode );
    procedure SetCloudPath( _CloudPath : string );
    procedure Update;
  end;

    // 读取
  TCloudPathReadXml = class
  public
    CloudPathNode : IXMLNode;
    CloudPath : string;
  public
    constructor Create( _CloudPathNode : IXMLNode );
    procedure Update;
  public
    procedure ReadCloudBackupPathList;
  end;

    // 读取
  TMyCloudInfoReadXml = class
  public
    procedure Update;
  end;

{$EndRegion}

const
  Xml_MyCloudInfo = 'mcif';
  Xml_CloudPathList = 'cpl';

  Xml_CloudPath = 'cp';
  Xml_CloudBackupPathList = 'cbl';

  Xml_BackupPath = 'bp';
  Xml_OwnerID = 'oi';
  Xml_IsFile = 'if';
  Xml_FileCount = 'fc';
  Xml_ItemSize = 'is';
  Xml_LastBackupTime = 'lbt';
  Xml_IsSaveDeleted = 'isd';
  Xml_IsEncrypted = 'ie';
  Xml_Password = 'pd';
  Xml_PasswordHint = 'pdh';


implementation

uses UMyCloudApiInfo;


procedure TMyCloudInfoReadXml.Update;
var
  MyCloudNode : IXMLNode;
  CloudPathListNode : IXMLNode;
  i: Integer;
  CloudPathReadXml : TCloudPathReadXml;
begin
  MyCloudNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyCloudInfo );
  CloudPathListNode := MyXmlUtil.AddChild( MyCloudNode, Xml_CloudPathList );
  for i := 0 to CloudPathListNode.ChildNodes.Count - 1 do
  begin
    CloudPathReadXml := TCloudPathReadXml.Create( CloudPathListNode.ChildNodes[i] );
    CloudPathReadXml.Update;
    CloudPathReadXml.Free;
  end;
end;


{ CloudPcBackupNode }

constructor TCloudBackupPathReadXml.Create( _CloudBackupPathNode : IXMLNode );
begin
  CloudBackupPathNode := _CloudBackupPathNode;
end;

procedure TCloudBackupPathReadXml.SetCloudPath(_CloudPath: string);
begin
  CloudPath := _CloudPath;
end;

procedure TCloudBackupPathReadXml.Update;
var
  BackupPath, OwnerID : string;
  IsFile : boolean;
  FileCount : integer;
  ItemSize : int64;
  LastBackupTime : TDateTime;
  IsSaveDeleted : Boolean;
  IsEncrypted : Boolean;
  Password, PasswordHint : string;
  CloudBackupPathReadHandle : TCloudBackupPathReadHandle;
begin
  BackupPath := MyXmlUtil.GetChildValue( CloudBackupPathNode, Xml_BackupPath );
  OwnerID := MyXmlUtil.GetChildValue( CloudBackupPathNode, Xml_OwnerID );
  IsFile := MyXmlUtil.GetChildBoolValue( CloudBackupPathNode, Xml_IsFile );
  FileCount := MyXmlUtil.GetChildIntValue( CloudBackupPathNode, Xml_FileCount );
  ItemSize := MyXmlUtil.GetChildInt64Value( CloudBackupPathNode, Xml_ItemSize );
  LastBackupTime := MyXmlUtil.GetChildFloatValue( CloudBackupPathNode, Xml_LastBackupTime );
  IsSaveDeleted := MyXmlUtil.GetChildBoolValue( CloudBackupPathNode, Xml_IsSaveDeleted );
  IsEncrypted := MyXmlUtil.GetChildBoolValue( CloudBackupPathNode, Xml_IsEncrypted );
  Password := MyXmlUtil.GetChildValue( CloudBackupPathNode, Xml_Password );
  PasswordHint := MyXmlUtil.GetChildValue( CloudBackupPathNode, Xml_PasswordHint );

  CloudBackupPathReadHandle := TCloudBackupPathReadHandle.Create( CloudPath );
  CloudBackupPathReadHandle.SetBackupInfo( BackupPath, OwnerID );
  CloudBackupPathReadHandle.SetIsFile( IsFile );
  CloudBackupPathReadHandle.SetSpaceInfo( FileCount, ItemSize );
  CloudBackupPathReadHandle.SetLastBackupTime( LastBackupTime );
  CloudBackupPathReadHandle.SetIsSaveDeleted( IsSaveDeleted );
  CloudBackupPathReadHandle.SetEncryptInfo( IsEncrypted, Password, PasswordHint );
  CloudBackupPathReadHandle.Update;
  CloudBackupPathReadHandle.Free;
end;

{ TCloudPathChangeXml }

procedure TCloudPathChangeXml.Update;
begin
  MyCloudNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyCloudInfo );
  CloudPathNodeList := MyXmlUtil.AddChild( MyCloudNode, Xml_CloudPathList );
end;

{ TCloudPathWriteXml }

constructor TCloudPathWriteXml.Create( _CloudPath : string );
begin
  CloudPath := _CloudPath;
end;


function TCloudPathWriteXml.FindCloudPathNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  for i := 0 to CloudPathNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := CloudPathNodeList.ChildNodes[i];
    if ( MyXmlUtil.GetChildValue( SelectNode, Xml_CloudPath ) = CloudPath ) then
    begin
      Result := True;
      CloudPathIndex := i;
      CloudPathNode := CloudPathNodeList.ChildNodes[i];
      break;
    end;
  end;
end;

{ TCloudPathAddXml }

procedure TCloudPathAddXml.Update;
begin
  inherited;

  if FindCloudPathNode then
    Exit;

  CloudPathNode := MyXmlUtil.AddListChild( CloudPathNodeList );
  MyXmlUtil.AddChild( CloudPathNode, Xml_CloudPath, CloudPath );
end;

{ TCloudPathRemoveXml }

procedure TCloudPathRemoveXml.Update;
begin
  inherited;

  if not FindCloudPathNode then
    Exit;

  MyXmlUtil.DeleteListChild( CloudPathNodeList, CloudPathIndex );
end;

{ TCloudPcBackupPathChangeXml }

function TCloudBackupPathChangeXml.FindCloudBackupPathNodeList : Boolean;
begin
  Result := FindCloudPathNode;
  if Result then
    CloudBackupPathNodeList := MyXmlUtil.AddChild( CloudPathNode, Xml_CloudBackupPathList );
end;

{ TCloudPcBackupPathWriteXml }

procedure TCloudBackupPathWriteXml.SetBackupPath( _BackupPath, _OwnerID : string );
begin
  BackupPath := _BackupPath;
  OwnerID := _OwnerID;
end;


function TCloudBackupPathWriteXml.FindCloudBackupPathNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  if not FindCloudBackupPathNodeList then
    Exit;
  for i := 0 to CloudBackupPathNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := CloudBackupPathNodeList.ChildNodes[i];
    if ( MyXmlUtil.GetChildValue( SelectNode, Xml_BackupPath ) = BackupPath ) and
       ( MyXmlUtil.GetChildValue( SelectNode, Xml_OwnerID ) = OwnerID )
    then
    begin
      Result := True;
      CloudBackupPathIndex := i;
      CloudBackupPathNode := CloudBackupPathNodeList.ChildNodes[i];
      break;
    end;
  end;
end;

{ TCloudPcBackupPathAddXml }

procedure TCloudBackupPathAddXml.SetIsFile( _IsFile : boolean );
begin
  IsFile := _IsFile;
end;

procedure TCloudBackupPathAddXml.SetSpaceInfo( _FileCount : integer; _ItemSize : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
end;

procedure TCloudBackupPathAddXml.SetLastBackupTime( _LastBackupTime : TDateTime );
begin
  LastBackupTime := _LastBackupTime;
end;

procedure TCloudBackupPathAddXml.SetIsSaveDeleted( _IsSaveDeleted : boolean );
begin
  IsSaveDeleted := _IsSaveDeleted;
end;

procedure TCloudBackupPathAddXml.SetEncryptInfo( _IsEncrypted : boolean; _Password, _PasswordHint : string );
begin
  IsEncrypted := _IsEncrypted;
  Password := _Password;
  PasswordHint := _PasswordHint;
end;

procedure TCloudBackupPathAddXml.Update;
begin
  inherited;

    // 不存在，则创建
  if not FindCloudBackupPathNode then
  begin
    if CloudBackupPathNodeList = nil then
      Exit;

    CloudBackupPathNode := MyXmlUtil.AddListChild( CloudBackupPathNodeList );
    MyXmlUtil.AddChild( CloudBackupPathNode, Xml_BackupPath, BackupPath );
    MyXmlUtil.AddChild( CloudBackupPathNode, Xml_OwnerID, OwnerID );
  end;

  MyXmlUtil.AddChild( CloudBackupPathNode, Xml_IsFile, IsFile );
  MyXmlUtil.AddChild( CloudBackupPathNode, Xml_FileCount, FileCount );
  MyXmlUtil.AddChild( CloudBackupPathNode, Xml_ItemSize, ItemSize );
  MyXmlUtil.AddChild( CloudBackupPathNode, Xml_LastBackupTime, LastBackupTime );
  MyXmlUtil.AddChild( CloudBackupPathNode, Xml_IsSaveDeleted, IsSaveDeleted );
  MyXmlUtil.AddChild( CloudBackupPathNode, Xml_IsEncrypted, IsEncrypted );
  MyXmlUtil.AddChild( CloudBackupPathNode, Xml_Password, Password );
  MyXmlUtil.AddChild( CloudBackupPathNode, Xml_PasswordHint, PasswordHint );
end;

{ TCloudPcBackupPathRemoveXml }

procedure TCloudBackupPathRemoveXml.Update;
begin
  inherited;

  if not FindCloudBackupPathNode then
    Exit;

  MyXmlUtil.DeleteListChild( CloudBackupPathNodeList, CloudBackupPathIndex );
end;

{ CloudPathNode }

constructor TCloudPathReadXml.Create( _CloudPathNode : IXMLNode );
begin
  CloudPathNode := _CloudPathNode;
end;

procedure TCloudPathReadXml.ReadCloudBackupPathList;
var
  CloudBackupPathNodeList : IXMLNode;
  i : Integer;
  CloudBackupPathNode : IXMLNode;
  CloudBackupPathReadXml : TCloudBackupPathReadXml;
begin
  CloudBackupPathNodeList := MyXmlUtil.AddChild( CloudPathNode, Xml_CloudBackupPathList );
  for i := 0 to CloudBackupPathNodeList.ChildNodes.Count - 1 do
  begin
    CloudBackupPathNode := CloudBackupPathNodeList.ChildNodes[i];
    CloudBackupPathReadXml := TCloudBackupPathReadXml.Create( CloudBackupPathNode );
    CloudBackupPathReadXml.SetCloudPath( CloudPath );
    CloudBackupPathReadXml.Update;
    CloudBackupPathReadXml.Free;
  end;
end;

procedure TCloudPathReadXml.Update;
var
  CloudPathReadHandle : TCloudPathReadHandle;
begin
  CloudPath := MyXmlUtil.GetChildValue( CloudPathNode, Xml_CloudPath );

  CloudPathReadHandle := TCloudPathReadHandle.Create( CloudPath );
  CloudPathReadHandle.Update;
  CloudPathReadHandle.Free;

  ReadCloudBackupPathList;
end;



end.
