unit UMyRestoreXmlInfo;

interface

uses UChangeInfo, UXmlUtil, xmldom, XMLIntf, msxmldom, XMLDoc, SysUtils, UMyUtil;

type

{$Region ' 恢复下载 数据修改 ' }

    // 父类
  TRestoreDownChangeXml = class( TXmlChangeInfo )
  protected
    MyRestoreDownNode : IXMLNode;
    RestoreDownNodeList : IXMLNode;
  protected
    procedure Update;override;
  end;

    // 修改
  TRestoreDownWriteXml = class( TRestoreDownChangeXml )
  public
    RestorePath, RestoreOwner, RestoreFrom : string;
  protected
    RestoreDownIndex : Integer;
    RestoreDownNode : IXMLNode;
  public
    constructor Create( _RestorePath, _RestoreOwner, _RestoreFrom : string );
  protected
    function FindRestoreDownNode: Boolean;
  end;

  {$Region ' 增删操作 ' }

    // 添加
  TRestoreDownAddXml = class( TRestoreDownWriteXml )
  public
    IsFile, IsCompleted : Boolean;
    OwnerName : string;
  public
    FileCount : integer;
    FileSize, CompletedSize : int64;
  public
    IsDeleted : Boolean;
    EditionNum : Integer;
  public
    IsEncrypt : Boolean;
    Password : string;
  public
    SavePath : string;
  public
    procedure SetIsFile( _IsFile : Boolean );
    procedure SetIsCompleted( _IsCompleted : Boolean ) ;
    procedure SetOwnerName( _OwnerName : string );
    procedure SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
    procedure SetDeletedInfo( _IsDeleted : Boolean; _EiditionNum : Integer );
    procedure SetEncryptInfo( _IsEncrypt : Boolean; _Password : string );
    procedure SetSavePath( _SavePath : string );
  protected
    procedure Update;override;
  protected
    procedure SetItemInfo;virtual;abstract;
  end;

    // 添加 本地恢复
  TRestoreDownAddLocalXml = class( TRestoreDownAddXml )
  protected
    procedure SetItemInfo;override;
  end;

    // 添加 网络恢复
  TRestoreDownAddNetworkXml = class( TRestoreDownAddXml )
  protected
    procedure SetItemInfo;override;
  end;

    // 删除
  TRestoreDownRemoveXml = class( TRestoreDownWriteXml )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 状态信息 ' }

      // 修改
  TRestoreDownSetIsCompletedXml = class( TRestoreDownWriteXml )
  public
    IsCompleted : boolean;
  public
    procedure SetIsCompleted( _IsCompleted : boolean );
  protected
    procedure Update;override;
  end;


  {$EndRegion}

  {$Region ' 空间信息 ' }

    // 修改
  TRestoreDownSetSpaceInfoXml = class( TRestoreDownWriteXml )
  public
    FileCount : integer;
    FileSize, CompletedSize : int64;
  public
    procedure SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
  protected
    procedure Update;override;
  end;

    // 修改
  TRestoreDownSetAddCompletedSpaceXml = class( TRestoreDownWriteXml )
  public
    AddCompletedSpace : int64;
  public
    procedure SetAddCompletedSpace( _AddCompletedSpace : int64 );
  protected
    procedure Update;override;
  end;

    // 修改
  TRestoreDownSetCompletedSizeXml = class( TRestoreDownWriteXml )
  public
    CompletedSize : int64;
  public
    procedure SetCompletedSize( _CompletedSize : int64 );
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 续传信息 ' }

    // 父类
  TRestoreDownContinusChangeXml = class( TRestoreDownWriteXml )
  protected
    ShareDownContinusNodeList : IXMLNode;
  protected
    function FindShareDownContinusNodeList : Boolean;
  end;

    // 修改
  TRestoreDownContinusWriteXml = class( TRestoreDownContinusChangeXml )
  public
    FilePath : string;
  protected
    ShareDownContinusIndex : Integer;
    ShareDownContinusNode : IXMLNode;
  public
    procedure SetFilePath( _FilePath : string );
  protected
    function FindShareDownContinusNode: Boolean;
  end;

      // 添加
  TRestoreDownContinusAddXml = class( TRestoreDownContinusWriteXml )
  public
    FileSize : int64;
    FileTime : TDateTime;
  public
    procedure SetFileInfo( _FileSize : int64; _FileTime : TDateTime );
  protected
    procedure Update;override;
  end;

    // 删除
  TRestoreDownContinusRemoveXml = class( TRestoreDownContinusWriteXml )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 文件版本信息 ' }

    // 修改
  TRestoreFileEditionWriteXml = class( TRestoreDownWriteXml )
  protected
    FileEditionList : IXMLNode;
  protected
    function FindFileEditionList : Boolean;
  end;

    // 清空版本信息
  TRestoreFileEditonClearXml = class( TRestoreFileEditionWriteXml )
  protected
    procedure Update;override;
  end;

    // 添加
  TRestoreFileEditionAddXml = class( TRestoreFileEditionWriteXml )
  public
    FilePath : string;
    EditionNum : Integer;
  public
    procedure SetFilePath( _FilePath : string );
    procedure SetEditionNum( _EditionNum : Integer );
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 速度信息 ' }

    // 父类
  TRestoreSpeedChangeXml = class( TXmlChangeInfo )
  public
    MyRestoreDownNode : IXMLNode;
    RestoreSpeedNode : IXMLNode;
  protected
    procedure Update;override;
  end;

    // 速度限制
  TRestoreSpeedLimitXml = class( TRestoreSpeedChangeXml )
  public
    IsLimit : Boolean;
    LimitValue, LimitType : Integer;
  public
    procedure SetIsLimit( _IsLimit : Boolean );
    procedure SetLimitXml( _LimitValue, _LimitType : Integer );
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 浏览历史 ' }

      // 父类
  TRestoreExplorerHistoryChangeXml = class( TXmlChangeInfo )
  protected
    MyRestoreDownNode : IXMLNode;
    RestoreExplorerHistoryNodeList : IXMLNode;
  protected
    procedure Update;override;
  end;

    // 修改
  TRestoreExplorerHistoryWriteXml = class( TRestoreExplorerHistoryChangeXml )
  public
    FilePath, OwnerPcID, RestoreFrom : string;
  protected
    RestoreExplorerHistoryIndex : Integer;
    RestoreExplorerHistoryNode : IXMLNode;
  public
    constructor Create( _FilePath, _OwnerPcID, _RestoreFrom : string );
  protected
    function FindRestoreExplorerHistoryNode: Boolean;
  end;

      // 添加
  TRestoreExplorerHistoryAddXml = class( TRestoreExplorerHistoryWriteXml )
  protected
    procedure Update;override;
  end;

    // 删除
  TRestoreExplorerHistoryRemoveXml = class( TRestoreExplorerHistoryChangeXml )
  public
    RemoveIndex : Integer;
  public
    constructor Create( _RemoveIndex : Integer );
  protected
    procedure Update;override;
  end;




  {$EndRegion}

{$EndRegion}

{$Region ' 恢复下载 数据读取 ' }

    // 读取
  TRestoreDownContinusReadXml = class
  public
    RestoreDownContinusNode : IXMLNode;
    RestorePath, OwnerPcID, RestoreFrom : string;
  public
    constructor Create( _RestoreDownContinusNode : IXMLNode );
    procedure SetItemInfo( _RestorePath, _OwnerPcID, _RestoreFrom : string );
    procedure Update;
  end;

    // 读取
  TRestoreFileEditonReadXml = class
  public
    FileEdtionNode : IXMLNode;
    RestorePath, OwnerPcID, RestoreFrom : string;
  public
    constructor Create( _FileEdtionNode : IXMLNode );
    procedure SetItemInfo( _RestorePath, _OwnerPcID, _RestoreFrom : string );
    procedure Update;
  end;

    // 读取 下载节点
  TRestoreDownReadXml = class
  public
    RestoreDownNode : IXMLNode;
    RestorePath, RestoreOwner, RestoreFrom : string;
  public
    constructor Create( _RestoreDownNode : IXMLNode );
    procedure Update;
  private
    procedure ReadRestoreDownContinus;
    procedure ReadRestoreFileEditionList;
  end;

    // 读取 备份速度
  TRestoreSpeedReadXml = class
  public
    RestoreSpeedNode : IXMLNode;
  public
    constructor Create( _RestoreSpeedNode : IXMLNode );
    procedure Update;
  end;

    // 读取
  TShareExplorerHistoryReadXml = class
  public
    ShareExplorerHistoryNode : IXMLNode;
  public
    constructor Create( _ShareExplorerHistoryNode : IXMLNode );
    procedure Update;
  end;

    // 读取 恢复下载
  TMyRestoreDownReadXml = class
  private
    MyRestoreDownNode : IXMLNode;
  public
    procedure Update;
  private
    procedure ReadRestoreDownList;
    procedure ReadRetoreSpeed;
  end;

{$EndRegion}


{$Region ' 本地恢复显示 数据修改 ' }

    // 父类
  TRestoreShowChangeXml = class( TXmlChangeInfo )
  protected
    MyRestoreDownNode : IXMLNode;
    RestoreShowNodeList : IXMLNode;
  protected
    procedure Update;override;
  end;

  {$Region ' 修改 根路径 ' }

    // 修改
  TRestoreShowWriteXml = class( TRestoreShowChangeXml )
  public
    DesItemID : string;
  protected
    RestoreShowIndex : Integer;
    RestoreShowNode : IXMLNode;
  public
    constructor Create( _DesItemID : string );
  protected
    function FindRestoreShowNode: Boolean;
  end;

      // 添加
  TRestoreShowAddXml = class( TRestoreShowWriteXml )
  protected
    procedure Update;override;
  end;

    // 删除
  TRestoreShowRemoveXml = class( TRestoreShowWriteXml )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 修改 子路径 ' }

      // 父类
  TRestoreShowItemChangeXml = class( TRestoreShowWriteXml )
  protected
    RestoreShowItemNodeList : IXMLNode;
  protected
    function FindRestoreShowItemNodeList : Boolean;
  end;

    // 修改
  TRestoreShowItemWriteXml = class( TRestoreShowItemChangeXml )
  public
    BackupPath, OwnerID : string;
  protected
    RestoreShowItemIndex : Integer;
    RestoreShowItemNode : IXMLNode;
  public
    procedure SetBackupPath( _BackupPath, _OwnerID : string );
  protected
    function FindRestoreShowItemNode: Boolean;
  end;

      // 添加
  TRestoreShowItemAddXml = class( TRestoreShowItemWriteXml )
  public
    IsFile : boolean;
    OwnerName : string;
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
    procedure SetOwnerName( _OwnerName : string );
    procedure SetSpaceInfo( _FileCount : integer; _ItemSize : int64 );
    procedure SetLastBackupTime( _LastBackupTime : TDateTime );
    procedure SetIsSaveDeleted( _IsSaveDeleted : boolean );
    procedure SetEncryptedInfo( _IsEncrypted : boolean; _Password, _PasswordHint : string );
  protected
    procedure Update;override;
  end;

    // 删除
  TRestoreShowItemRemoveXml = class( TRestoreShowItemWriteXml )
  protected
    procedure Update;override;
  end;



  {$EndRegion}

{$EndRegion}

{$Region ' 本地恢复显示 数据读取 ' }

    // 读取
  TRestoreShowItemReadXml = class
  public
    RestoreShowItemNode : IXMLNode;
    DesItemID : string;
  public
    constructor Create( _RestoreShowItemNode : IXMLNode );
    procedure SetDesItemID( _DesItemID : string );
    procedure Update;
  end;

    // 读取
  TRestoreShowReadXml = class
  public
    RestoreShowNode : IXMLNode;
    DesItemID : string;
  public
    constructor Create( _RestoreShowNode : IXMLNode );
    procedure Update;
  private
    procedure ReadShowItemList;
  end;

    // 读取
  TRestoreShowXmlReadHandle = class
  public
    procedure Update;
  end;

{$EndRegion}

const
  RestoreDownType_Local = 'l';
  RestoreDownType_Network = 'n';

const
  Xml_MyRestoreDownInfo = 'mrdi';
  Xml_RestoreDownList = 'rdl';

  Xml_RestorePath = 'rp';
  Xml_RestoreOwner = 'ro';
  Xml_RestoreFrom = 'rf';
  Xml_OwnerName = 'OwnerName';
  Xml_IsFile = 'if';
  Xml_IsCompleted = 'ic';
  Xml_FileCount = 'fc';
  Xml_FileSize = 'fs';
  Xml_CompletedSize = 'cs';
  Xml_IsDeleted = 'id';
  Xml_EditionNum = 'en';
  Xml_IsEncrypted = 'ie';
  Xml_Password = 'pd';
  Xml_SavePath = 'sp';
  Xml_RestoreDownType = 'rdt';
  Xml_ShareDownContinusList = 'sdcl';
  Xml_FileEditionList = 'fei';

  Xml_FilePath = 'fp';
//    Xml_FileSize = 'fs';
  Xml_Postion = 'pt';
  Xml_FileTime = 'ft';

//  Xml_FilePath = 'fp';
//  Xml_EditionNum = 'en';

const
  Xml_RestoreShowList = 'rsl';
  Xml_DesItemID = 'diid';

  Xml_RestoreShowItemList = 'rsil';
  Xml_BackupPath = 'bp';
  Xml_OwnerID = 'oid';
//  Xml_OwnerName = 'on';
//  Xml_IsFile = 'if';
//  Xml_FileCount = 'fc';
  Xml_ItemSize = 'is';
  Xml_LastBackupTime = 'lbt';
  Xml_IsSaveDeleted = 'isd';
//  Xml_IsEncrypted = 'ie';
//  Xml_Password = 'p';
  Xml_PasswordHint = 'ph';

const
  Xml_RestoreSpeed = 'rs';
  Xml_IsLimit = 'il';
  Xml_LimitType = 'lt';
  Xml_LimitValue = 'lv';

const
//    Xml_MyRestoreDownInfo = 'mrdi';
  Xml_RestoreExplorerHistoryList = 'rehl';
//    Xml_FilePath = 'fp';
  Xml_OwnerPcID = 'opid';
//    Xml_RestoreFrom = 'rf';



implementation

uses UMyRestoreApiInfo;

{ TRestoreDownChangeXml }

procedure TRestoreDownChangeXml.Update;
begin
  MyRestoreDownNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyRestoreDownInfo );
  RestoreDownNodeList := MyXmlUtil.AddChild( MyRestoreDownNode, Xml_RestoreDownList );
end;

{ TRestoreDownWriteXml }

constructor TRestoreDownWriteXml.Create( _RestorePath, _RestoreOwner, _RestoreFrom : string );
begin
  RestorePath := _RestorePath;
  RestoreOwner := _RestoreOwner;
  RestoreFrom := _RestoreFrom;
end;


function TRestoreDownWriteXml.FindRestoreDownNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  for i := 0 to RestoreDownNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := RestoreDownNodeList.ChildNodes[i];
    if ( MyXmlUtil.GetChildValue( SelectNode, Xml_RestorePath ) = RestorePath ) and
       ( MyXmlUtil.GetChildValue( SelectNode, Xml_RestoreOwner ) = RestoreOwner ) and
       ( MyXmlUtil.GetChildValue( SelectNode, Xml_RestoreFrom ) = RestoreFrom )
    then
    begin
      Result := True;
      RestoreDownIndex := i;
      RestoreDownNode := RestoreDownNodeList.ChildNodes[i];
      break;
    end;
  end;
end;

{ TRestoreDownAddXml }

procedure TRestoreDownAddXml.SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TRestoreDownAddXml.Update;
begin
  inherited;

    // 不存在，则创建
  if not FindRestoreDownNode then
  begin
    RestoreDownNode := MyXmlUtil.AddListChild( RestoreDownNodeList );
    MyXmlUtil.AddChild( RestoreDownNode, Xml_RestorePath, RestorePath );
    MyXmlUtil.AddChild( RestoreDownNode, Xml_RestoreOwner, RestoreOwner );
    MyXmlUtil.AddChild( RestoreDownNode, Xml_RestoreFrom, RestoreFrom );
  end;

    // 加密
  Password := MyEncrypt.EncodeStr( Password );

  MyXmlUtil.AddChild( RestoreDownNode, Xml_IsFile, IsFile );
  MyXmlUtil.AddChild( RestoreDownNode, Xml_IsCompleted, IsCompleted );
  MyXmlUtil.AddChild( RestoreDownNode, Xml_OwnerName, OwnerName );
  MyXmlUtil.AddChild( RestoreDownNode, Xml_FileCount, FileCount );
  MyXmlUtil.AddChild( RestoreDownNode, Xml_FileSize, FileSize );
  MyXmlUtil.AddChild( RestoreDownNode, Xml_CompletedSize, CompletedSize );
  MyXmlUtil.AddChild( RestoreDownNode, Xml_IsDeleted, IsDeleted );
  MyXmlUtil.AddChild( RestoreDownNode, Xml_EditionNum, EditionNum );
  MyXmlUtil.AddChild( RestoreDownNode, Xml_IsEncrypted, IsEncrypt );
  MyXmlUtil.AddChild( RestoreDownNode, Xml_Password, Password );
  MyXmlUtil.AddChild( RestoreDownNode, Xml_SavePath, SavePath );

  SetItemInfo;
end;

procedure TRestoreDownAddXml.SetEncryptInfo(_IsEncrypt: Boolean;
  _Password: string);
begin
  IsEncrypt := _IsEncrypt;
  Password := _Password;
end;

procedure TRestoreDownAddXml.SetIsCompleted(_IsCompleted: Boolean);
begin
  IsCompleted := _IsCompleted;
end;

procedure TRestoreDownAddXml.SetDeletedInfo(_IsDeleted: Boolean;
  _EiditionNum : Integer);
begin
  IsDeleted := _IsDeleted;
  EditionNum := _EiditionNum;
end;

procedure TRestoreDownAddXml.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TRestoreDownAddXml.SetOwnerName(_OwnerName: string);
begin
  OwnerName := _OwnerName;
end;

procedure TRestoreDownAddXml.SetSavePath( _SavePath : string );
begin
  SavePath := _SavePath;
end;

{ TRestoreDownRemoveXml }

procedure TRestoreDownRemoveXml.Update;
begin
  inherited;

  if not FindRestoreDownNode then
    Exit;

  MyXmlUtil.DeleteListChild( RestoreDownNodeList, RestoreDownIndex );
end;



{ TRestoreDownReadXmlHandle }

procedure TMyRestoreDownReadXml.ReadRestoreDownList;
var
  RestoreDownNodeList : IXMLNode;
  i : Integer;
  RestoreDownNode : IXMLNode;
  RestoreDownReadXml : TRestoreDownReadXml;
begin
  RestoreDownNodeList := MyXmlUtil.AddChild( MyRestoreDownNode, Xml_RestoreDownList );
  for i := 0 to RestoreDownNodeList.ChildNodes.Count - 1 do
  begin
    RestoreDownNode := RestoreDownNodeList.ChildNodes[i];
    RestoreDownReadXml := TRestoreDownReadXml.Create( RestoreDownNode );
    RestoreDownReadXml.Update;
    RestoreDownReadXml.Free;
  end;
end;

procedure TMyRestoreDownReadXml.ReadRetoreSpeed;
var
  RestoreSpeedNode : IXMLNode;
  RestoreSpeedReadXml : TRestoreSpeedReadXml;
begin
  RestoreSpeedNode := MyXmlUtil.AddChild( MyRestoreDownNode, Xml_RestoreSpeed );

  RestoreSpeedReadXml := TRestoreSpeedReadXml.Create( RestoreSpeedNode );
  RestoreSpeedReadXml.Update;
  RestoreSpeedReadXml.Free;
end;

procedure TMyRestoreDownReadXml.Update;
begin
  MyRestoreDownNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyRestoreDownInfo );

  ReadRestoreDownList;

  ReadRetoreSpeed;
end;



{ RestoreDownNode }

constructor TRestoreDownReadXml.Create( _RestoreDownNode : IXMLNode );
begin
  RestoreDownNode := _RestoreDownNode;
end;

procedure TRestoreDownReadXml.ReadRestoreDownContinus;
var
  ShareDownContinusNodeList : IXMLNode;
  i : Integer;
  ShareDownContinusNode : IXMLNode;
  ShareDownContinusReadXml : TRestoreDownContinusReadXml;
begin
  ShareDownContinusNodeList := MyXmlUtil.AddChild( RestoreDownNode, Xml_ShareDownContinusList );
  for i := 0 to ShareDownContinusNodeList.ChildNodes.Count - 1 do
  begin
    ShareDownContinusNode := ShareDownContinusNodeList.ChildNodes[i];
    ShareDownContinusReadXml := TRestoreDownContinusReadXml.Create( ShareDownContinusNode );
    ShareDownContinusReadXml.SetItemInfo( RestorePath, RestoreOwner, RestoreFrom );
    ShareDownContinusReadXml.Update;
    ShareDownContinusReadXml.Free;
  end;
end;

procedure TRestoreDownReadXml.ReadRestoreFileEditionList;
var
  FileEditionList : IXMLNode;
  i: Integer;
  RestoreFileEditonReadXml : TRestoreFileEditonReadXml;
begin
  FileEditionList := MyXmlUtil.AddChild( RestoreDownNode, Xml_FileEditionList );
  for i := 0 to FileEditionList.ChildNodes.Count - 1 do
  begin
    RestoreFileEditonReadXml := TRestoreFileEditonReadXml.Create( FileEditionList.ChildNodes[i] );
    RestoreFileEditonReadXml.SetItemInfo( RestorePath, RestoreOwner, RestoreFrom );
    RestoreFileEditonReadXml.Update;
    RestoreFileEditonReadXml.Free;
  end;
end;

procedure TRestoreDownReadXml.Update;
var
  IsFile, IsCompleted : Boolean;
  OwnerName : string;
  RestoreDownType : string;
  FileCount : integer;
  FileSize, CompletedSize : int64;
  IsDeletedFile : Boolean;
  EditionNum : Integer;
  IsEncrypt : Boolean;
  Password : string;
  SavePath : string;
  RestoreDownReadLocalHandle : TRestoreDownReadLocalHandle;
  RestoreDownReadNetworkHandle : TRestoreDownReadNetworkHandle;
begin
  RestorePath := MyXmlUtil.GetChildValue( RestoreDownNode, Xml_RestorePath );
  RestoreOwner := MyXmlUtil.GetChildValue( RestoreDownNode, Xml_RestoreOwner );
  RestoreFrom := MyXmlUtil.GetChildValue( RestoreDownNode, Xml_RestoreFrom );
  IsFile := MyXmlUtil.GetChildBoolValue( RestoreDownNode, Xml_IsFile );
  IsCompleted := MyXmlUtil.GetChildBoolValue( RestoreDownNode, Xml_IsCompleted );
  OwnerName := MyXmlUtil.GetChildValue( RestoreDownNode, Xml_OwnerName );
  FileCount := MyXmlUtil.GetChildIntValue( RestoreDownNode, Xml_FileCount );
  FileSize := MyXmlUtil.GetChildInt64Value( RestoreDownNode, Xml_FileSize );
  CompletedSize := MyXmlUtil.GetChildInt64Value( RestoreDownNode, Xml_CompletedSize );
  IsDeletedFile := MyXmlUtil.GetChildBoolValue( RestoreDownNode, Xml_IsDeleted );
  EditionNum := MyXmlUtil.GetChildIntValue( RestoreDownNode, Xml_EditionNum );
  IsEncrypt := MyXmlUtil.GetChildBoolValue( RestoreDownNode, Xml_IsEncrypted );
  Password := MyXmlUtil.GetChildValue( RestoreDownNode, Xml_Password );
  Password := MyEncrypt.DecodeStr( Password ); // 解密

  SavePath := MyXmlUtil.GetChildValue( RestoreDownNode, Xml_SavePath );
  RestoreDownType := MyXmlUtil.GetChildValue( RestoreDownNode, Xml_RestoreDownType );

  if RestoreDownType = RestoreDownType_Local then
  begin
    RestoreDownReadLocalHandle := TRestoreDownReadLocalHandle.Create( RestorePath, RestoreOwner, RestoreFrom );
    RestoreDownReadLocalHandle.SetIsFile( IsFile );
    RestoreDownReadLocalHandle.SetIsCompleted( IsCompleted );
    RestoreDownReadLocalHandle.SetOwnerName( OwnerName );
    RestoreDownReadLocalHandle.SetSpaceInfo( FileCount, FileSize, CompletedSize );
    RestoreDownReadLocalHandle.SetDeletedInfo( IsDeletedFile, EditionNum );
    RestoreDownReadLocalHandle.SetEncryptInfo( IsEncrypt, Password );
    RestoreDownReadLocalHandle.SetSavePath( SavePath );
    RestoreDownReadLocalHandle.Update;
    RestoreDownReadLocalHandle.Free;
  end
  else
  begin
    RestoreDownReadNetworkHandle := TRestoreDownReadNetworkHandle.Create( RestorePath, RestoreOwner, RestoreFrom );
    RestoreDownReadNetworkHandle.SetIsOnline( False );
    RestoreDownReadNetworkHandle.SetIsFile( IsFile );
    RestoreDownReadNetworkHandle.SetIsCompleted( IsCompleted );
    RestoreDownReadNetworkHandle.SetOwnerName( OwnerName );
    RestoreDownReadNetworkHandle.SetSpaceInfo( FileCount, FileSize, CompletedSize );
    RestoreDownReadNetworkHandle.SetDeletedInfo( IsDeletedFile, EditionNum );
    RestoreDownReadNetworkHandle.SetEncryptInfo( IsEncrypt, Password );
    RestoreDownReadNetworkHandle.SetSavePath( SavePath );
    RestoreDownReadNetworkHandle.Update;
    RestoreDownReadNetworkHandle.Free;
  end;

    // 读取续传信息
  ReadRestoreDownContinus;

    // 读取恢复版本信息
  ReadRestoreFileEditionList;
end;



{ TRestoreDownAddLocalXml }

procedure TRestoreDownAddLocalXml.SetItemInfo;
begin
  MyXmlUtil.AddChild( RestoreDownNode, Xml_RestoreDownType, RestoreDownType_Local );
end;

{ TRestoreDownAddNetworkXml }

procedure TRestoreDownAddNetworkXml.SetItemInfo;
begin
  MyXmlUtil.AddChild( RestoreDownNode, Xml_RestoreDownType, RestoreDownType_Network );
end;

{ TRestoreDownSetSpaceInfoXml }

procedure TRestoreDownSetSpaceInfoXml.SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TRestoreDownSetSpaceInfoXml.Update;
begin
  inherited;

  if not FindRestoreDownNode then
    Exit;
  MyXmlUtil.AddChild( RestoreDownNode, Xml_FileCount, FileCount );
  MyXmlUtil.AddChild( RestoreDownNode, Xml_FileSize, FileSize );
  MyXmlUtil.AddChild( RestoreDownNode, Xml_CompletedSize, CompletedSize );
end;

{ TRestoreDownSetAddCompletedSpaceXml }

procedure TRestoreDownSetAddCompletedSpaceXml.SetAddCompletedSpace( _AddCompletedSpace : int64 );
begin
  AddCompletedSpace := _AddCompletedSpace;
end;

procedure TRestoreDownSetAddCompletedSpaceXml.Update;
var
  CompletedSize : Int64;
begin
  inherited;

  if not FindRestoreDownNode then
    Exit;

  CompletedSize := MyXmlUtil.GetChildInt64Value( RestoreDownNode, Xml_CompletedSize );
  CompletedSize := CompletedSize + AddCompletedSpace;
  MyXmlUtil.AddChild( RestoreDownNode, Xml_CompletedSize, CompletedSize );
end;

{ TRestoreDownSetCompletedSizeXml }

procedure TRestoreDownSetCompletedSizeXml.SetCompletedSize( _CompletedSize : int64 );
begin
  CompletedSize := _CompletedSize;
end;

procedure TRestoreDownSetCompletedSizeXml.Update;
begin
  inherited;

  if not FindRestoreDownNode then
    Exit;
  MyXmlUtil.AddChild( RestoreDownNode, Xml_CompletedSize, CompletedSize );
end;

{ TRestoreDownSetIsCompletedXml }

procedure TRestoreDownSetIsCompletedXml.SetIsCompleted( _IsCompleted : boolean );
begin
  IsCompleted := _IsCompleted;
end;

procedure TRestoreDownSetIsCompletedXml.Update;
begin
  inherited;

  if not FindRestoreDownNode then
    Exit;
  MyXmlUtil.AddChild( RestoreDownNode, Xml_IsCompleted, IsCompleted );
end;

{ TShareDownContinusChangeXml }

function TRestoreDownContinusChangeXml.FindShareDownContinusNodeList : Boolean;
begin
  Result := FindRestoreDownNode;
  if Result then
    ShareDownContinusNodeList := MyXmlUtil.AddChild( RestoreDownNode, Xml_ShareDownContinusList );
end;

{ TShareDownContinusWriteXml }

procedure TRestoreDownContinusWriteXml.SetFilePath( _FilePath : string );
begin
  FilePath := _FilePath;
end;


function TRestoreDownContinusWriteXml.FindShareDownContinusNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  if not FindShareDownContinusNodeList then
    Exit;
  for i := 0 to ShareDownContinusNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := ShareDownContinusNodeList.ChildNodes[i];
    if ( MyXmlUtil.GetChildValue( SelectNode, Xml_FilePath ) = FilePath ) then
    begin
      Result := True;
      ShareDownContinusIndex := i;
      ShareDownContinusNode := ShareDownContinusNodeList.ChildNodes[i];
      break;
    end;
  end;
end;

{ TShareDownContinusAddXml }

procedure TRestoreDownContinusAddXml.SetFileInfo( _FileSize : int64;
  _FileTime : TDateTime );
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TRestoreDownContinusAddXml.Update;
begin
  inherited;

  if not FindShareDownContinusNode then
  begin
    ShareDownContinusNode := MyXmlUtil.AddListChild( ShareDownContinusNodeList );
    MyXmlUtil.AddChild( ShareDownContinusNode, Xml_FilePath, FilePath );
    MyXmlUtil.AddChild( ShareDownContinusNode, Xml_FileSize, FileSize );
    MyXmlUtil.AddChild( ShareDownContinusNode, Xml_FileTime, FileTime );
  end;
end;

{ TShareDownContinusRemoveXml }

procedure TRestoreDownContinusRemoveXml.Update;
begin
  inherited;

  if not FindShareDownContinusNode then
    Exit;

  MyXmlUtil.DeleteListChild( ShareDownContinusNodeList, ShareDownContinusIndex );
end;

{ TShareDownContinusReadXml }

constructor TRestoreDownContinusReadXml.Create(_RestoreDownContinusNode: IXMLNode);
begin
  RestoreDownContinusNode := _RestoreDownContinusNode;
end;

procedure TRestoreDownContinusReadXml.SetItemInfo(_RestorePath, _OwnerPcID,
  _RestoreFrom: string);
begin
  RestorePath := _RestorePath;
  OwnerPcID := _OwnerPcID;
  RestoreFrom := _RestoreFrom;
end;

procedure TRestoreDownContinusReadXml.Update;
var
  FilePath : string;
  FileSize : int64;
  FileTime : TDateTime;
  ShareDownContinusReadHandle : TShareDownContinusReadHandle;
begin
  FilePath := MyXmlUtil.GetChildValue( RestoreDownContinusNode, Xml_FilePath );
  FileSize := MyXmlUtil.GetChildInt64Value( RestoreDownContinusNode, Xml_FileSize );
  FileTime := MyXmlUtil.GetChildFloatValue( RestoreDownContinusNode, Xml_FileTime );

  ShareDownContinusReadHandle := TShareDownContinusReadHandle.Create( RestorePath, OwnerPcID, RestoreFrom );
  ShareDownContinusReadHandle.SetFilePath( FilePath );
  ShareDownContinusReadHandle.SetFileInfo( FileSize, FileTime );
  ShareDownContinusReadHandle.Update;
  ShareDownContinusReadHandle.Free;
end;

{ TRestoreShowChangeXml }

procedure TRestoreShowChangeXml.Update;
begin
  MyRestoreDownNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyRestoreDownInfo );
  RestoreShowNodeList := MyXmlUtil.AddChild( MyRestoreDownNode, Xml_RestoreShowList );
end;

{ TRestoreShowWriteXml }

constructor TRestoreShowWriteXml.Create( _DesItemID : string );
begin
  DesItemID := _DesItemID;
end;


function TRestoreShowWriteXml.FindRestoreShowNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  for i := 0 to RestoreShowNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := RestoreShowNodeList.ChildNodes[i];
    if ( MyXmlUtil.GetChildValue( SelectNode, Xml_DesItemID ) = DesItemID ) then
    begin
      Result := True;
      RestoreShowIndex := i;
      RestoreShowNode := RestoreShowNodeList.ChildNodes[i];
      break;
    end;
  end;
end;

{ TRestoreShowAddXml }

procedure TRestoreShowAddXml.Update;
begin
  inherited;

  if FindRestoreShowNode then
    Exit;

  RestoreShowNode := MyXmlUtil.AddListChild( RestoreShowNodeList );
  MyXmlUtil.AddChild( RestoreShowNode, Xml_DesItemID, DesItemID );
end;

{ TRestoreShowRemoveXml }

procedure TRestoreShowRemoveXml.Update;
begin
  inherited;

  if not FindRestoreShowNode then
    Exit;

  MyXmlUtil.DeleteListChild( RestoreShowNodeList, RestoreShowIndex );
end;

{ RestoreShowNode }

constructor TRestoreShowReadXml.Create( _RestoreShowNode : IXMLNode );
begin
  RestoreShowNode := _RestoreShowNode;
end;

procedure TRestoreShowReadXml.ReadShowItemList;
var
  RestoreShowItemNodeList : IXMLNode;
  i : Integer;
  RestoreShowItemNode : IXMLNode;
  RestoreShowItemReadXml : TRestoreShowItemReadXml;
begin
  RestoreShowItemNodeList := MyXmlUtil.AddChild( RestoreShowNode, Xml_RestoreShowItemList );
  for i := 0 to RestoreShowItemNodeList.ChildNodes.Count - 1 do
  begin
    RestoreShowItemNode := RestoreShowItemNodeList.ChildNodes[i];
    RestoreShowItemReadXml := TRestoreShowItemReadXml.Create( RestoreShowItemNode );
    RestoreShowItemReadXml.SetDesItemID( DesItemID );
    RestoreShowItemReadXml.Update;
    RestoreShowItemReadXml.Free;
  end;
end;



procedure TRestoreShowReadXml.Update;
var
  RestoreDesReadLocalHandle : TRestoreDesReadLocalHandle;
begin
  DesItemID := MyXmlUtil.GetChildValue( RestoreShowNode, Xml_DesItemID );

  RestoreDesReadLocalHandle := TRestoreDesReadLocalHandle.Create( DesItemID );
  RestoreDesReadLocalHandle.Update;
  RestoreDesReadLocalHandle.Free;

  ReadShowItemList;
end;




{ TRestoreShowXmlReadHandle }

procedure TRestoreShowXmlReadHandle.Update;
var
  MyRestoreDownNode, RestoreShowNodeList : IXMLNode;
  i : Integer;
  RestoreShowNode : IXMLNode;
  RestoreShowReadXml : TRestoreShowReadXml;
begin
  MyRestoreDownNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyRestoreDownInfo );
  RestoreShowNodeList := MyXmlUtil.AddChild( MyRestoreDownNode, Xml_RestoreShowList );
  for i := 0 to RestoreShowNodeList.ChildNodes.Count - 1 do
  begin
    RestoreShowNode := RestoreShowNodeList.ChildNodes[i];
    RestoreShowReadXml := TRestoreShowReadXml.Create( RestoreShowNode );
    RestoreShowReadXml.Update;
    RestoreShowReadXml.Free;
  end;
end;

{ TRestoreShowItemChangeXml }

function TRestoreShowItemChangeXml.FindRestoreShowItemNodeList : Boolean;
begin
  Result := FindRestoreShowNode;
  if Result then
    RestoreShowItemNodeList := MyXmlUtil.AddChild( RestoreShowNode, Xml_RestoreShowItemList );
end;

{ TRestoreShowItemWriteXml }

procedure TRestoreShowItemWriteXml.SetBackupPath( _BackupPath, _OwnerID : string );
begin
  BackupPath := _BackupPath;
  OwnerID := _OwnerID;
end;


function TRestoreShowItemWriteXml.FindRestoreShowItemNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  if not FindRestoreShowItemNodeList then
    Exit;
  for i := 0 to RestoreShowItemNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := RestoreShowItemNodeList.ChildNodes[i];
    if ( MyXmlUtil.GetChildValue( SelectNode, Xml_BackupPath ) = BackupPath ) and ( MyXmlUtil.GetChildValue( SelectNode, Xml_OwnerID ) = OwnerID ) then
    begin
      Result := True;
      RestoreShowItemIndex := i;
      RestoreShowItemNode := RestoreShowItemNodeList.ChildNodes[i];
      break;
    end;
  end;
end;

{ TRestoreShowItemAddXml }

procedure TRestoreShowItemAddXml.SetIsFile( _IsFile : boolean );
begin
  IsFile := _IsFile;
end;

procedure TRestoreShowItemAddXml.SetOwnerName( _OwnerName : string );
begin
  OwnerName := _OwnerName;
end;

procedure TRestoreShowItemAddXml.SetSpaceInfo( _FileCount : integer; _ItemSize : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
end;

procedure TRestoreShowItemAddXml.SetLastBackupTime( _LastBackupTime : TDateTime );
begin
  LastBackupTime := _LastBackupTime;
end;

procedure TRestoreShowItemAddXml.SetIsSaveDeleted( _IsSaveDeleted : boolean );
begin
  IsSaveDeleted := _IsSaveDeleted;
end;

procedure TRestoreShowItemAddXml.SetEncryptedInfo( _IsEncrypted : boolean; _Password, _PasswordHint : string );
begin
  IsEncrypted := _IsEncrypted;
  Password := _Password;
  PasswordHint := _PasswordHint;
end;

procedure TRestoreShowItemAddXml.Update;
begin
  inherited;

  if not FindRestoreShowItemNode then
  begin
    if RestoreShowItemNodeList = nil then // 根节点不存在
      Exit;
    RestoreShowItemNode := MyXmlUtil.AddListChild( RestoreShowItemNodeList );
    MyXmlUtil.AddChild( RestoreShowItemNode, Xml_BackupPath, BackupPath );
    MyXmlUtil.AddChild( RestoreShowItemNode, Xml_OwnerID, OwnerID );
  end;

  MyXmlUtil.AddChild( RestoreShowItemNode, Xml_OwnerName, OwnerName );
  MyXmlUtil.AddChild( RestoreShowItemNode, Xml_FileCount, FileCount );
  MyXmlUtil.AddChild( RestoreShowItemNode, Xml_ItemSize, ItemSize );
  MyXmlUtil.AddChild( RestoreShowItemNode, Xml_LastBackupTime, LastBackupTime );
  MyXmlUtil.AddChild( RestoreShowItemNode, Xml_IsSaveDeleted, IsSaveDeleted );
  MyXmlUtil.AddChild( RestoreShowItemNode, Xml_IsEncrypted, IsEncrypted );
  MyXmlUtil.AddChild( RestoreShowItemNode, Xml_Password, Password );
  MyXmlUtil.AddChild( RestoreShowItemNode, Xml_PasswordHint, PasswordHint );
  MyXmlUtil.AddChild( RestoreShowItemNode, Xml_IsFile, IsFile );
end;

{ TRestoreShowItemRemoveXml }

procedure TRestoreShowItemRemoveXml.Update;
begin
  inherited;

  if not FindRestoreShowItemNode then
    Exit;

  MyXmlUtil.DeleteListChild( RestoreShowItemNodeList, RestoreShowItemIndex );
end;

{ RestoreShowItemNode }

constructor TRestoreShowItemReadXml.Create( _RestoreShowItemNode : IXMLNode );
begin
  RestoreShowItemNode := _RestoreShowItemNode;
end;

procedure TRestoreShowItemReadXml.SetDesItemID(_DesItemID: string);
begin
  DesItemID := _DesItemID;
end;

procedure TRestoreShowItemReadXml.Update;
var
  BackupPath, OwnerID, OwnerName : string;
  FileCount : integer;
  ItemSize : int64;
  LastBackupTime : TDateTime;
  IsSaveDeleted, IsEncrypted : boolean;
  Password, PasswordHint : string;
  IsFile : boolean;
  RestoreItemReadLocalHandle : TRestoreItemReadLocalHandle;
begin
  BackupPath := MyXmlUtil.GetChildValue( RestoreShowItemNode, Xml_BackupPath );
  OwnerID := MyXmlUtil.GetChildValue( RestoreShowItemNode, Xml_OwnerID );
  OwnerName := MyXmlUtil.GetChildValue( RestoreShowItemNode, Xml_OwnerName );
  FileCount := MyXmlUtil.GetChildIntValue( RestoreShowItemNode, Xml_FileCount );
  ItemSize := MyXmlUtil.GetChildInt64Value( RestoreShowItemNode, Xml_ItemSize );
  LastBackupTime := MyXmlUtil.GetChildFloatValue( RestoreShowItemNode, Xml_LastBackupTime );
  IsSaveDeleted := MyXmlUtil.GetChildBoolValue( RestoreShowItemNode, Xml_IsSaveDeleted );
  IsEncrypted := MyXmlUtil.GetChildBoolValue( RestoreShowItemNode, Xml_IsEncrypted );
  Password := MyXmlUtil.GetChildValue( RestoreShowItemNode, Xml_Password );
  PasswordHint := MyXmlUtil.GetChildValue( RestoreShowItemNode, Xml_PasswordHint );
  IsFile := MyXmlUtil.GetChildBoolValue( RestoreShowItemNode, Xml_IsFile );

  RestoreItemReadLocalHandle := TRestoreItemReadLocalHandle.Create( DesItemID );
  RestoreItemReadLocalHandle.SetBackupPath( BackupPath );
  RestoreItemReadLocalHandle.SetOwnerID( OwnerID );
  RestoreItemReadLocalHandle.SetIsFile( IsFile );
  RestoreItemReadLocalHandle.SetOwnerName( OwnerName );
  RestoreItemReadLocalHandle.SetSpaceInfo( FileCount, ItemSize );
  RestoreItemReadLocalHandle.SetLastBackupTime( LastBackupTime );
  RestoreItemReadLocalHandle.SetIsSaveDeleted( IsSaveDeleted );
  RestoreItemReadLocalHandle.SetEncryptedInfo( IsEncrypted, Password, PasswordHint );
  RestoreItemReadLocalHandle.Update;
  RestoreItemReadLocalHandle.Free;
end;

{ TBackupSpeedChangeXml }

procedure TRestoreSpeedChangeXml.Update;
begin
  MyRestoreDownNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyRestoreDownInfo );
  RestoreSpeedNode := MyXmlUtil.AddChild( MyRestoreDownNode, Xml_RestoreSpeed );
end;

{ TBackupSpeedLimitXml }

procedure TRestoreSpeedLimitXml.SetIsLimit(_IsLimit: Boolean);
begin
  IsLimit := _IsLimit;
end;

procedure TRestoreSpeedLimitXml.SetLimitXml(_LimitValue, _LimitType: Integer);
begin
  LimitValue := _LimitValue;
  LimitType := _LimitType;
end;

procedure TRestoreSpeedLimitXml.Update;
begin
  inherited;

  MyXmlUtil.AddChild( RestoreSpeedNode, Xml_IsLimit, IsLimit );
  MyXmlUtil.AddChild( RestoreSpeedNode, Xml_LimitType, LimitType );
  MyXmlUtil.AddChild( RestoreSpeedNode, Xml_LimitValue, LimitValue );
end;

{ TBackupSpeedReadXml }

constructor TRestoreSpeedReadXml.Create(_RestoreSpeedNode: IXMLNode);
begin
  RestoreSpeedNode := _RestoreSpeedNode;
end;

procedure TRestoreSpeedReadXml.Update;
var
  IsLimit : Boolean;
  LimitType, LimitValue : Integer;
  RestoreSpeedLimitReadHandle : TRestoreSpeedLimitReadHandle;
begin
  IsLimit := StrToBoolDef( MyXmlUtil.GetChildValue( RestoreSpeedNode, Xml_IsLimit ), False );
  LimitType := MyXmlUtil.GetChildIntValue( RestoreSpeedNode, Xml_LimitType );
  LimitValue := MyXmlUtil.GetChildIntValue( RestoreSpeedNode, Xml_LimitValue );

  RestoreSpeedLimitReadHandle := TRestoreSpeedLimitReadHandle.Create( IsLimit );
  RestoreSpeedLimitReadHandle.SetLimitInfo( LimitType, LimitValue );
  RestoreSpeedLimitReadHandle.Update;
  RestoreSpeedLimitReadHandle.Free
end;

{ TRestoreFileEditionAddXml }

procedure TRestoreFileEditionAddXml.SetEditionNum(_EditionNum: Integer);
begin
  EditionNum := _EditionNum;
end;

procedure TRestoreFileEditionAddXml.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TRestoreFileEditionAddXml.Update;
var
  FileEditionNode : IXMLNode;
begin
  inherited;

  if not FindFileEditionList then
    Exit;

  FileEditionList := MyXmlUtil.AddChild( RestoreDownNode, Xml_FileEditionList );
  FileEditionNode := MyXmlUtil.AddListChild( FileEditionList );
  MyXmlUtil.AddChild( FileEditionNode, Xml_FilePath, FilePath );
  MyXmlUtil.AddChild( FileEditionNode, Xml_EditionNum, EditionNum );
end;

{ TRestoreFileEditonReadXml }

constructor TRestoreFileEditonReadXml.Create(_FileEdtionNode: IXMLNode);
begin
  FileEdtionNode := _FileEdtionNode;
end;

procedure TRestoreFileEditonReadXml.SetItemInfo(_RestorePath, _OwnerPcID,
  _RestoreFrom: string);
begin
  RestorePath := _RestorePath;
  OwnerPcID := _OwnerPcID;
  RestoreFrom := _RestoreFrom;
end;

procedure TRestoreFileEditonReadXml.Update;
var
  FilePath : string;
  EditionNum : Integer;
  RestoreFileEditionReadHandle : TRestoreFileEditionReadHandle;
begin
  FilePath := MyXmlUtil.GetChildValue( FileEdtionNode, Xml_FilePath );
  EditionNum := MyXmlUtil.GetChildIntValue( FileEdtionNode, Xml_EditionNum );

  RestoreFileEditionReadHandle := TRestoreFileEditionReadHandle.Create( RestorePath, OwnerPcID, RestoreFrom );
  RestoreFileEditionReadHandle.SetFilePath( FilePath );
  RestoreFileEditionReadHandle.SetEditionNum( EditionNum );
  RestoreFileEditionReadHandle.Update;
  RestoreFileEditionReadHandle.Free;
end;

{ TRestoreFileEditionWriteXml }

function TRestoreFileEditionWriteXml.FindFileEditionList: Boolean;
begin
  Result := FindRestoreDownNode;
  if not Result then
    Exit;

  FileEditionList := MyXmlUtil.AddChild( RestoreDownNode, Xml_FileEditionList );
end;

{ TRestoreFileEditonClearXml }

procedure TRestoreFileEditonClearXml.Update;
begin
  inherited;
  if not FindFileEditionList then
    Exit;
  FileEditionList.ChildNodes.Clear;
end;

{ TRestoreExplorerHistoryChangeXml }

procedure TRestoreExplorerHistoryChangeXml.Update;
begin
  MyRestoreDownNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyRestoreDownInfo );
  RestoreExplorerHistoryNodeList := MyXmlUtil.AddChild( MyRestoreDownNode, Xml_RestoreExplorerHistoryList );
end;

{ TRestoreExplorerHistoryWriteXml }

constructor TRestoreExplorerHistoryWriteXml.Create( _FilePath, _OwnerPcID, _RestoreFrom : string );
begin
  FilePath := _FilePath;
  OwnerPcID := _OwnerPcID;
  RestoreFrom := _RestoreFrom;
end;


function TRestoreExplorerHistoryWriteXml.FindRestoreExplorerHistoryNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  for i := 0 to RestoreExplorerHistoryNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := RestoreExplorerHistoryNodeList.ChildNodes[i];
    if ( MyXmlUtil.GetChildValue( SelectNode, Xml_FilePath ) = FilePath ) and ( MyXmlUtil.GetChildValue( SelectNode, Xml_OwnerPcID ) = OwnerPcID ) and ( MyXmlUtil.GetChildValue( SelectNode, Xml_RestoreFrom ) = RestoreFrom ) then
    begin
      Result := True;
      RestoreExplorerHistoryIndex := i;
      RestoreExplorerHistoryNode := RestoreExplorerHistoryNodeList.ChildNodes[i];
      break;
    end;
  end;
end;

{ TRestoreExplorerHistoryAddXml }

procedure TRestoreExplorerHistoryAddXml.Update;
begin
  inherited;

  if FindRestoreExplorerHistoryNode then
    Exit;

  RestoreExplorerHistoryNode := MyXmlUtil.AddListChild( RestoreExplorerHistoryNodeList );
  MyXmlUtil.AddChild( RestoreExplorerHistoryNode, Xml_FilePath, FilePath );
  MyXmlUtil.AddChild( RestoreExplorerHistoryNode, Xml_OwnerPcID, OwnerPcID );
  MyXmlUtil.AddChild( RestoreExplorerHistoryNode, Xml_RestoreFrom, RestoreFrom );
end;

{ TRestoreExplorerHistoryRemoveXml }

constructor TRestoreExplorerHistoryRemoveXml.Create(_RemoveIndex: Integer);
begin
  RemoveIndex := _RemoveIndex;
end;

procedure TRestoreExplorerHistoryRemoveXml.Update;
begin
  inherited;

  RemoveIndex := RestoreExplorerHistoryNodeList.ChildNodes.Count - 1 - RemoveIndex;
  if RestoreExplorerHistoryNodeList.ChildNodes.Count <= RemoveIndex then
    Exit;

  MyXmlUtil.DeleteListChild( RestoreExplorerHistoryNodeList, RemoveIndex );
end;


constructor TShareExplorerHistoryReadXml.Create(
  _ShareExplorerHistoryNode: IXMLNode);
begin
  ShareExplorerHistoryNode := _ShareExplorerHistoryNode;
end;

procedure TShareExplorerHistoryReadXml.Update;
var
  FilePath, OwnerID, RestoreFrom : string;
  ShareExplorerHistoryReadHandle : TShareExplorerHistoryReadHandle;
begin
  FilePath := MyXmlUtil.GetChildValue( ShareExplorerHistoryNode, Xml_FilePath );
  OwnerID := MyXmlUtil.GetChildValue( ShareExplorerHistoryNode, Xml_OwnerID );
  RestoreFrom := MyXmlUtil.GetChildValue( ShareExplorerHistoryNode, Xml_RestoreFrom );

  ShareExplorerHistoryReadHandle := TShareExplorerHistoryReadHandle.Create( FilePath, OwnerID, RestoreFrom );
  ShareExplorerHistoryReadHandle.Update;
  ShareExplorerHistoryReadHandle.Free;
end;


end.
