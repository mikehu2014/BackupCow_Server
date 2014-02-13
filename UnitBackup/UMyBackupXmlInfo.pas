unit UMyBackupXmlInfo;

interface

uses UChangeInfo, xmldom, XMLIntf, msxmldom, XMLDoc, UXmlUtil, UFileBaseInfo, UMyUtil, SysUtils, uDebug;

type

{$Region ' 数据修改 ' }

  {$Region ' 目标路径 ' }

  TDesItemChangeXml = class( TXmlChangeInfo )
  protected
    MyBackupNode : IXMLNode;
    DesItemNodeList : IXMLNode;
  protected
    procedure Update;override;
  end;

  TDesItemWriteXml = class( TDesItemChangeXml )
  public
    DesItemID : string;
  protected
    DesNodeIndex : Integer;
    DesNode : IXMLNode;
  public
    constructor Create( _DesPath : string );
  protected
    function FindDesNode : Boolean;
  end;

  TDesItemAddXml = class( TDesItemWriteXml )
  protected
    procedure Update;override;
  protected
    procedure SetItemInfo;virtual;abstract;
  end;

    // 添加 本地
  TDesItemAddLocalXml = class( TDesItemAddXml )
  protected
    procedure SetItemInfo;override;
  end;

    // 添加 网络
  TDesItemAddNetworkXml = class( TDesItemAddXml )
  protected
    procedure SetItemInfo;override;
  end;

    // 删除
  TDesItemRemoveXml = class( TDesItemWriteXml )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 源路径 增删 ' }

  TBackupWriteXml = class( TDesItemWriteXml )
  public
    BackupNodeList : IXMLNode;
  public
    function FindBackupNodeList : Boolean;
  end;

  TBackupItemWriteXml = class( TBackupWriteXml )
  public
    BackupPath : string;
  protected
    BackupNodeIndex : Integer;
    BackupItemNode : IXMLNode;
  public
    procedure SetBackupPath( _BackupPath : string );
  protected
    function FindBackupItemNode : Boolean;
  end;

  TBackupItemAddXml = class( TBackupItemWriteXml )
  public  // 路径信息
    IsFile, IsCompleted : Boolean;
  public  // 自动同步
    IsBackupNow, IsAutoSync : Boolean; // 是否自动同步
    SyncTimeType, SyncTimeValue : Integer; // 同步间隔
    LasSyncTime : TDateTime;  // 上一次同步时间
  public  // 加密设置
    IsEncrypt : boolean;
    Password, PasswordHint : string;
  public  // 删除保留信息
    IsKeepDeleted : Boolean;
    KeepEditionCount : Integer;
  public  // 空间信息
    FileCount : Integer;
    ItemSize, CompletedSize : Int64; // 空间信息
  public
    procedure SetIsFile( _IsFile : Boolean );
    procedure SetIsCompleted( _IsCompleted : Boolean );
    procedure SetIsBackupNow( _IsBackupNow : Boolean );
    procedure SetAutoSyncInfo( _IsAutoSync : Boolean; _LasSyncTime : TDateTime );
    procedure SetSyncTimeInfo( _SyncTimeType, _SyncTimeValue : Integer );
    procedure SetEncryptInfo( _IsEncrypt : boolean; _Password, _PasswordHint : string );
    procedure SetDeleteInfo( _IsKeepDeleted : Boolean; _KeepEditionCount : Integer );
    procedure SetSpaceInfo( _FileCount : Integer; _ItemSize, _CompletedSize : Int64 );
  protected
    procedure Update;override;
  end;

  TBackupItemRemoveXml = class( TBackupItemWriteXml )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 源路径 状态 ' }

      // 修改
  TBackupItemSetIsCompletedXml = class( TBackupItemWriteXml )
  public
    IsCompleted : boolean;
  public
    procedure SetIsCompleted( _IsCompleted : boolean );
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 源路径 同步信息 ' }

    // 是否 Backup Now 备份
  TBackupItemSetIsBackupNowXml = class( TBackupItemWriteXml )
  public
    IsBackupNow : Boolean;
  public
    procedure SetIsBackupNow( _IsBackupNow : Boolean );
  protected
    procedure Update;override;
  end;

    // 设置 上一次 同步时间
  TBackupItemSetLastSyncTimeXml = class( TBackupItemWriteXml )
  public
    LastSyncTime : TDateTime;
  public
    procedure SetLastSyncTime( _LastSyncTime : TDateTime );
  protected
    procedure Update;override;
  end;

    // 设置 同步周期
  TBackupItemSetAutoSyncXml = class( TBackupItemWriteXml )
  private
    IsAutoSync : Boolean;
    SyncTimeValue, SyncTimeType : Integer;
  public
    procedure SetIsAutoSync( _IsAutoSync : Boolean );
    procedure SetSyncInterval( _SyncTimeType, _SyncTimeValue : Integer );
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 源路径 加密信息 ' }

      // 修改
  TBackupItemSetEncryptInfoXml = class( TBackupItemWriteXml )
  public
    IsEncrypt : boolean;
    Password, PasswordHint : string;
  public
    procedure SetEncryptInfo( _IsEncrypt : boolean; _Password, _PasswordHint : string );
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 源路径 回收信息 ' }

      // 修改
  TBackupItemSetDeletedInfoXml = class( TBackupItemWriteXml )
  public
    IsKeepDeleted : boolean;
    KeepEditionCount : integer;
  public
    procedure SetDeletedInfo( _IsKeepDeleted : boolean; _KeepEditionCount : integer );
  protected
    procedure Update;override;
  end;




  {$EndRegion}

  {$Region ' 源路径 空间信息 ' }

    // 修改
  TBackupItemSetSpaceInfoXml = class( TBackupItemWriteXml )
  public
    FileCount : integer;
    ItemSize, CompletedSize : int64;
  public
    procedure SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSize : int64 );
  protected
    procedure Update;override;
  end;

  // 修改
  TBackupItemSetAddCompletedSpaceXml = class( TBackupItemWriteXml )
  public
    AddCompletedSpace : int64;
  public
    procedure SetAddCompletedSpace( _AddCompletedSpace : int64 );
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 源路径 过滤信息 ' }

    // 修改 过滤信息 父类
  TBackupItemFilterWriteXml = class( TBackupItemWriteXml )
  public
    IncludeFilterListNode : IXMLNode;
    ExcludeFilterListNode : IXMLNode;
  public
    function FindFilterList : Boolean;
  end;

    // 添加 父类
  TBackupItemFilterAddXml = class( TBackupItemFilterWriteXml )
  public
    FilterType, FilterValue : string;
  public
    procedure SetFilterXml( _FilterType, _FilterValue : string );
  end;

    // 清空
  TBackupItemIncludeFilterClearXml = class( TBackupItemFilterWriteXml )
  protected
    procedure Update;override;
  end;

    // 添加
  TBackupItemIncludeFilterAddXml = class( TBackupItemFilterAddXml )
  protected
    procedure Update;override;
  end;

    // 清空
  TBackupItemExcludeFilterClearXml = class( TBackupItemFilterWriteXml )
  protected
    procedure Update;override;
  end;

    // 添加
  TBackupItemExcludeFilterAddXml = class( TBackupItemFilterAddXml )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 源路径 续传信息 ' }

      // 父类
  TBackupContinusChangeXml = class( TBackupItemWriteXml )
  protected
    BackupContinusNodeList : IXMLNode;
  protected
    function FindBackupContinusNodeList : Boolean;
  end;

    // 修改
  TBackupContinusWriteXml = class( TBackupContinusChangeXml )
  public
    FilePath : string;
  protected
    BackupContinusIndex : Integer;
    BackupContinusNode : IXMLNode;
  public
    procedure SetFilePath( _FilePath : string );
  protected
    function FindBackupContinusNode: Boolean;
  end;

    // 添加
  TBackupContinusAddXml = class( TBackupContinusWriteXml )
  public
    FileSize : int64;
    FileTime : TDateTime;
  public
    procedure SetFileInfo( _FileSize : int64; _FileTime : TDateTime );
  protected
    procedure Update;override;
  end;

    // 删除
  TBackupContinusRemoveXml = class( TBackupContinusWriteXml )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 源路径 日志信息 已完成 ' }

      // 父类
  TBackupCompletedDateLogChangeXml = class( TBackupItemWriteXml )
  protected
    BackupDateLogNodeList : IXMLNode;
  protected
    function FindBackupDateLogNodeList : Boolean;
  end;

    // 修改
  TBackupCompletedDateLogWriteXml = class( TBackupCompletedDateLogChangeXml )
  public
    BackupDate : TDate;
  protected
    BackupDateLogNode : IXMLNode;
  public
    procedure SetBackupDate( _BackupDate : TDate );
  protected
    function FindBackupDateLogNode : Boolean;
    procedure AddBackupDateLogNode;
  end;

    // 父类
  TBackupLogChangeCompletedXml = class( TBackupCompletedDateLogWriteXml )
  protected
    BackupFileLogNodeList : IXMLNode;
  protected
    function FindBackupFileLogNodeList : Boolean;
  end;

    // 添加 已完成
  TBackupLogAddCompletedXml = class( TBackupLogChangeCompletedXml )
  public
    FilePath : string;
    FileTime, BackupTime : TDateTime;
  public
    procedure SetFilePath( _FilePath : string );
    procedure SetBackupTime( _FileTime, _BackupTime : TDateTime );
  protected
    procedure Update;override;
  private
    procedure AddDateLogFileCount;
    procedure RemoveTopLimit;
  end;

    // 清空 已完成
  TBackupLogClearCompletedXml = class( TBackupCompletedDateLogChangeXml )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 源路径 日志信息 未完成 ' }

      // 父类
  TBackupIncompletedLogChangeXml = class( TBackupItemWriteXml )
  protected
    BackupIncompletedLogNodeList : IXMLNode;
  protected
    function FindBackupIncompletedLogNodeList : Boolean;
  end;

    // 添加 未完成
  TBackupLogAddIncompletedXml = class( TBackupIncompletedLogChangeXml )
  public
    FilePath : string;
  public
    procedure SetFilePath( _FilePath : string );
  protected
    procedure Update;override;
  end;

    // 清空
  TBackupLogClearIncompletedXml = class( TBackupIncompletedLogChangeXml )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 源路径 日志信息 读取 ' }

  MyBackupLogXmlReadUtil = class
  public
    class function ReadCompletedDateLogList( DesItemID, BackupPath : string ) : IXMLNode;
    class function ReadIncompletedLogList( DesItemID, BackupPath : string ) : IXMLNode;
  end;

  {$EndRegion}

  {$Region ' 速度信息 ' }

    // 父类
  TBackupSpeedChangeXml = class( TXmlChangeInfo )
  public
    MyBackupNode : IXMLNode;
    BackupSpeedNode : IXMLNode;
  protected
    procedure Update;override;
  end;

    // 速度限制
  TBackupSpeedLimitXml = class( TBackupSpeedChangeXml )
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

{$EndRegion}

{$Region ' 数据读取 ' }

    // 读取 包含过滤器
  TBackupItemIncludeFilterReadXml = class
  public
    DesItemID : string;
    BackupPath : string;
    IncludeFilterListNode : IXMLNode;
  public
    constructor Create( _IncludeFilterListNode : IXMLNode );
    procedure SetDesItemID( _DesItemID : string );
    procedure SetBackupPath( _BackupPath : string );
    procedure Update;
  end;

    // 读取 排除过滤器
  TBackupItemExcludeFilterReadXml = class
  public
    DesItemID : string;
    BackupPath : string;
    ExcludeFilterListNode : IXMLNode;
  public
    constructor Create( _ExcludeFilterListNode : IXMLNode );
    procedure SetDesItemID( _DesItemID : string );
    procedure SetBackupPath( _BackupPath : string );
    procedure Update;
  end;

    // 读取
  TBackupContinusReadXml = class
  public
    BackupContinusNode : IXMLNode;
    DesItemID, SourcePath : string;
  public
    constructor Create( _BackupContinusNode : IXMLNode );
    procedure SetItemInfo( _SendRootItemID, _SourcePath : string );
    procedure Update;
  end;

    // 读取 备份路径
  TBackupItemReadXml = class
  private
    DesItemID : string;
    BackupItemNode : IXMLNode;
    BackupPath : string;
  public
    constructor Create( _BackupItemNode : IXMLNode );
    procedure SetDesItemID( _DesItemID : string );
    procedure Update;
  private
    procedure ReadFilterList;
    procedure ReadContinuseList;
  end;

    // 读取 目标路径
  TBackupDesItemReadXml = class
  private
    DesItemNode : IXMLNode;
  private
    DesItemID : string;
  public
    constructor Create( _DesItemNode : IXMLNode );
    procedure Update;
  private
    procedure ReadBackupItemList;
  end;

    // 读取 备份速度
  TBackupSpeedReadXml = class
  public
    BackupSpeedNode : IXMLNode;
  public
    constructor Create( _BackupSpeedNode : IXMLNode );
    procedure Update;
  end;

    // 读取 本地备份 信息
  TBackupReadXmlHandle = class
  private
    MyBackupNode : IXMLNode;
  public
    procedure Update;
  private
    procedure ReadDesItemList;
    procedure ReadBackupSpeed;
  end;

{$EndRegion}


const
  Xml_MyBackupInfo = 'mbif';
  Xml_DesItemList = 'dil';

  Xml_DesItemID = 'did';
  Xml_DesItemType = 'dit';
  Xml_BackupItemList = 'bil';

  Xml_BackupPath = 'bp';
  Xml_IsFile = 'if';
  Xml_IsCompleted = 'ic';

  Xml_IsBackupNow = 'ibn';
  Xml_IsAutoSync = 'ias';
  Xml_SyncTimeType = 'stt';
  Xml_SyncTimeValue = 'stv';
  Xml_LastSyncTime = 'lst';

  Xml_FileCount = 'fc';
  Xml_ItemSize = 'is';
  Xml_CompletedSize = 'cs';

  Xml_IsKeepDeleted = 'ikd';
  Xml_KeepEditionCount = 'kec';

  Xml_IsEncrypt = 'ie';
  Xml_Password = 'pw';
  Xml_PasswordHint = 'ph';

  Xml_IncludeFilterList = 'ifl';
  Xml_ExcludeFilterList = 'efl';

  Xml_FilterType = 'ft';
  Xml_FilterValue = 'fv';

  Xml_BackupContinusList = 'bcl';

  Xml_FilePath = 'fp';
  Xml_FileSize = 'fs';
  Xml_Position = 'pt';
  Xml_FileTime = 'ft';

  Xml_BackupCompletedDateLogList = 'bcdll';
  Xml_BackupDate = 'bd';
//  Xml_FileCount = 'fc';
  Xml_BackupCompletedFileLogList = 'bcfll';
//  Xml_FilePath = 'fp';
//  Xml_FileTime = 'ft';
  Xml_BackupTime = 'bt';


  Xml_BackupIncompletedLogList = 'bicll';
//  Xml_FilePath = 'fp';;
  Xml_ErrorStr = 'es';

const
  Xml_BackupSpeed = 'bs';
  Xml_IsLimit = 'il';
  Xml_LimitType = 'lt';
  Xml_LimitValue = 'lv';


const
  DesItemType_Local = 'Local';
  DesItemType_Network = 'Network';

implementation

uses UMyBackupApiInfo;

{ TDesItemWriteXml }

constructor TDesItemWriteXml.Create(_DesPath: string);
begin
  DesItemID := _DesPath;
end;

function TDesItemWriteXml.FindDesNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  for i := 0 to DesItemNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := DesItemNodeList.ChildNodes[i];
    if MyXmlUtil.GetChildValue( SelectNode, Xml_DesItemID ) = DesItemID then
    begin
      Result := True;
      DesNodeIndex := i;
      DesNode := SelectNode;
      Break;
    end;
  end;
end;

{ TDesItemRemoveXml }

procedure TDesItemRemoveXml.Update;
begin
  inherited;

  if not FindDesNode then
    Exit;

  DesItemNodeList.ChildNodes.Delete( DesNodeIndex );
end;

{ TBackupItemWriteXml }

function TBackupItemWriteXml.FindBackupItemNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  BackupNodeList := nil;
  if not FindBackupNodeList then
    Exit;
  for i := 0 to BackupNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := BackupNodeList.ChildNodes[i];
    if MyXmlUtil.GetChildValue( SelectNode, Xml_BackupPath ) = BackupPath then
    begin
      Result := True;
      BackupNodeIndex := i;
      BackupItemNode := SelectNode;
      Break;
    end;
  end;
end;

procedure TBackupItemWriteXml.SetBackupPath(_BackupPath: string);
begin
  BackupPath := _BackupPath;
end;

{ TBackupWriteXml }

function TBackupWriteXml.FindBackupNodeList: Boolean;
begin
  Result := FindDesNode;
  if Result then
    BackupNodeList := MyXmlUtil.AddChild( DesNode, Xml_BackupItemList );
end;

{ TBackupItemAddXml }

procedure TBackupItemAddXml.SetAutoSyncInfo(_IsAutoSync: Boolean;
  _LasSyncTime: TDateTime);
begin
  IsAutoSync := _IsAutoSync;
  LasSyncTime := _LasSyncTime;
end;

procedure TBackupItemAddXml.SetIsBackupNow( _IsBackupNow: Boolean);
begin
  IsBackupNow := _IsBackupNow;
end;

procedure TBackupItemAddXml.SetIsCompleted(_IsCompleted: Boolean);
begin
  IsCompleted := _IsCompleted;
end;

procedure TBackupItemAddXml.SetDeleteInfo(_IsKeepDeleted: Boolean;
  _KeepEditionCount: Integer);
begin
  IsKeepDeleted := _IsKeepDeleted;
  KeepEditionCount := _KeepEditionCount;
end;

procedure TBackupItemAddXml.SetEncryptInfo(_IsEncrypt: boolean; _Password,
  _PasswordHint: string);
begin
  IsEncrypt := _IsEncrypt;
  Password := _Password;
  PasswordHint := _PasswordHint;
end;

procedure TBackupItemAddXml.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TBackupItemAddXml.SetSpaceInfo(_FileCount: Integer; _ItemSize,
  _CompletedSize: Int64);
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TBackupItemAddXml.SetSyncTimeInfo(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TBackupItemAddXml.Update;
begin
  inherited;

    // 不存在则创建
  if not FindBackupItemNode then
  begin
    if BackupNodeList = nil then  // 父节点不存在
      Exit;
    BackupItemNode := MyXmlUtil.AddListChild( BackupNodeList );
    MyXmlUtil.AddChild( BackupItemNode, Xml_BackupPath, BackupPath );
  end;

  MyXmlUtil.AddChild( BackupItemNode, Xml_IsFile, IsFile );
  MyXmlUtil.AddChild( BackupItemNode, Xml_IsCompleted, IsCompleted );

  MyXmlUtil.AddChild( BackupItemNode, Xml_IsBackupNow, IsBackupNow );
  MyXmlUtil.AddChild( BackupItemNode, Xml_IsAutoSync, IsAutoSync );
  MyXmlUtil.AddChild( BackupItemNode, Xml_SyncTimeType, SyncTimeType );
  MyXmlUtil.AddChild( BackupItemNode, Xml_SyncTimeValue, SyncTimeValue );
  MyXmlUtil.AddChild( BackupItemNode, Xml_LastSyncTime, LasSyncTime );

  MyXmlUtil.AddChild( BackupItemNode, Xml_IsEncrypt, IsEncrypt );
  MyXmlUtil.AddChild( BackupItemNode, Xml_PasswordHint, PasswordHint );
  Password := MyEncrypt.EncodeStr( Password ); // 加密
  MyXmlUtil.AddChild( BackupItemNode, Xml_Password, Password );

  MyXmlUtil.AddChild( BackupItemNode, Xml_IsKeepDeleted, IsKeepDeleted );
  MyXmlUtil.AddChild( BackupItemNode, Xml_KeepEditionCount, KeepEditionCount );

  MyXmlUtil.AddChild( BackupItemNode, Xml_FileCount, FileCount );
  MyXmlUtil.AddChild( BackupItemNode, Xml_ItemSize, ItemSize );
  MyXmlUtil.AddChild( BackupItemNode, Xml_CompletedSize, CompletedSize );
end;

{ TBackupItemRemoveXml }

procedure TBackupItemRemoveXml.Update;
begin
  inherited;

  if not FindBackupItemNode then
  begin
    DebugLog( IntToStr( BackupNodeIndex ) );
    Exit;
  end;

  BackupNodeList.ChildNodes.Delete( BackupNodeIndex );
end;

{ TBackupItemSetIsBackupNowXml }

procedure TBackupItemSetIsBackupNowXml.SetIsBackupNow(
  _IsBackupNow: Boolean);
begin
  IsBackupNow := _IsBackupNow;
end;

procedure TBackupItemSetIsBackupNowXml.Update;
begin
  inherited;
  if not FindBackupItemNode then
    Exit;
  MyXmlUtil.AddChild( BackupItemNode, Xml_IsBackupNow, IsBackupNow );
end;

{ TBackupItemSetLastSyncTimeXml }

procedure TBackupItemSetLastSyncTimeXml.SetLastSyncTime(
  _LastSyncTime: TDateTime);
begin
  LastSyncTime := _LastSyncTime;
end;

procedure TBackupItemSetLastSyncTimeXml.Update;
begin
  inherited;
  if not FindBackupItemNode then
    Exit;
  MyXmlUtil.AddChild( BackupItemNode, Xml_LastSyncTime, LastSyncTime );
end;

{ TBackupItemSetAutoSyncXml }

procedure TBackupItemSetAutoSyncXml.SetIsAutoSync(_IsAutoSync: Boolean);
begin
  IsAutoSync := _IsAutoSync;
end;

procedure TBackupItemSetAutoSyncXml.SetSyncInterval(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TBackupItemSetAutoSyncXml.Update;
begin
  inherited;
  if not FindBackupItemNode then
    Exit;
  MyXmlUtil.AddChild( BackupItemNode, Xml_IsAutoSync, IsAutoSync );
  MyXmlUtil.AddChild( BackupItemNode, Xml_SyncTimeType, SyncTimeType );
  MyXmlUtil.AddChild( BackupItemNode, Xml_SyncTimeValue, SyncTimeValue );
end;


{ TBackupXmlReadHandle }

procedure TBackupReadXmlHandle.ReadBackupSpeed;
var
  BackupSpeedNode : IXMLNode;
  BackupSpeedReadXml : TBackupSpeedReadXml;
begin
  BackupSpeedNode := MyXmlUtil.AddChild( MyBackupNode, Xml_BackupSpeed );

  BackupSpeedReadXml := TBackupSpeedReadXml.Create( BackupSpeedNode );
  BackupSpeedReadXml.Update;
  BackupSpeedReadXml.Free;
end;

procedure TBackupReadXmlHandle.ReadDesItemList;
var
  DesItemNodeList : IXMLNode;
  i : Integer;
  DesItemNode : IXMLNode;
  BackupDesItemReadXml : TBackupDesItemReadXml;
begin
  DesItemNodeList := MyXmlUtil.AddChild( MyBackupNode, Xml_DesItemList );
  for i := 0 to DesItemNodeList.ChildNodes.Count - 1 do
  begin
    DesItemNode := DesItemNodeList.ChildNodes[i];

    BackupDesItemReadXml := TBackupDesItemReadXml.Create( DesItemNode );
    BackupDesItemReadXml.Update;
    BackupDesItemReadXml.Free;
  end;
end;

procedure TBackupReadXmlHandle.Update;
begin
  MyBackupNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyBackupInfo );

  ReadDesItemList;

  ReadBackupSpeed;
end;

{ TBackupDesItemReadXml }

constructor TBackupDesItemReadXml.Create(_DesItemNode: IXMLNode);
begin
  DesItemNode := _DesItemNode;
end;

procedure TBackupDesItemReadXml.ReadBackupItemList;
var
  BackupItemList : IXMLNode;
  i : Integer;
  BackupItemNode : IXMLNode;
  BackupItemReadXml : TBackupItemReadXml;
begin
  BackupItemList := MyXmlUtil.AddChild( DesItemNode, Xml_BackupItemList );
  for i := 0 to BackupItemList.ChildNodes.Count - 1 do
  begin
    BackupItemNode := BackupItemList.ChildNodes[i];

    BackupItemReadXml := TBackupItemReadXml.Create( BackupItemNode );
    BackupItemReadXml.SetDesItemID( DesItemID );
    BackupItemReadXml.Update;
    BackupItemReadXml.Free;
  end;
end;

procedure TBackupDesItemReadXml.Update;
var
  DesItemType : string;
  DesItemReadLocalHandle : TDesItemReadLocalHandle;
  DesItemReadNetworkHandle : TDesItemReadNetworkHandle;
begin
  DesItemID := MyXmlUtil.GetChildValue( DesItemNode, Xml_DesItemID );
  DesItemType := MyXmlUtil.GetChildValue( DesItemNode, Xml_DesItemType );

    // 读取 本地目标路径
  if DesItemType = DesItemType_Local then
  begin
    DesItemReadLocalHandle := TDesItemReadLocalHandle.Create( DesItemID );
    DesItemReadLocalHandle.Update;
    DesItemReadLocalHandle.Free;
  end
  else
  begin   // 读取 网络目标路径
    DesItemReadNetworkHandle := TDesItemReadNetworkHandle.Create( DesItemID );
    DesItemReadNetworkHandle.SetIsOnline( False );
    DesItemReadNetworkHandle.SetAvailableSpace( -1 );
    DesItemReadNetworkHandle.Update;
    DesItemReadNetworkHandle.Free;
  end;


    // 读取 目标路径 的源路径
  ReadBackupItemList;
end;

{ TBackupItemReadXml }

constructor TBackupItemReadXml.Create(_BackupItemNode: IXMLNode);
begin
  BackupItemNode := _BackupItemNode;
end;

procedure TBackupItemReadXml.ReadContinuseList;
var
  SendContinusNodeList : IXMLNode;
  i : Integer;
  SendContinusNode : IXMLNode;
  SendContinusReadXml : TBackupContinusReadXml;
begin
  SendContinusNodeList := MyXmlUtil.AddChild( BackupItemNode, Xml_BackupContinusList );
  for i := 0 to SendContinusNodeList.ChildNodes.Count - 1 do
  begin
    SendContinusNode := SendContinusNodeList.ChildNodes[i];
    SendContinusReadXml := TBackupContinusReadXml.Create( SendContinusNode );
    SendContinusReadXml.SetItemInfo( DesItemID, BackupPath );
    SendContinusReadXml.Update;
    SendContinusReadXml.Free;
  end;
end;

procedure TBackupItemReadXml.ReadFilterList;
var
  IncludeFilterListNode, ExcludeFilterListNode : IXMLNode;
  BackupItemIncludeFilterReadXml : TBackupItemIncludeFilterReadXml;
  BackupItemExcludeFilterReadXml : TBackupItemExcludeFilterReadXml;
begin
    // 读取 包含过滤
  IncludeFilterListNode := MyXmlUtil.AddChild( BackupItemNode, Xml_IncludeFilterList );
  BackupItemIncludeFilterReadXml := TBackupItemIncludeFilterReadXml.Create( IncludeFilterListNode );
  BackupItemIncludeFilterReadXml.SetDesItemID( DesItemID );
  BackupItemIncludeFilterReadXml.SetBackupPath( BackupPath );
  BackupItemIncludeFilterReadXml.Update;
  BackupItemIncludeFilterReadXml.Free;

    // 读取 包含过滤
  ExcludeFilterListNode := MyXmlUtil.AddChild( BackupItemNode, Xml_ExcludeFilterList );
  BackupItemExcludeFilterReadXml := TBackupItemExcludeFilterReadXml.Create( ExcludeFilterListNode );
  BackupItemExcludeFilterReadXml.SetDesItemID( DesItemID );
  BackupItemExcludeFilterReadXml.SetBackupPath( BackupPath );
  BackupItemExcludeFilterReadXml.Update;
  BackupItemExcludeFilterReadXml.Free;
end;

procedure TBackupItemReadXml.SetDesItemID(_DesItemID: string);
begin
  DesItemID := _DesItemID;
end;

procedure TBackupItemReadXml.Update;
var
  IsFile, IsCompleted : Boolean;
  IsBackupNow, IsAutoSync : Boolean; // 是否自动同步
  SyncTimeType, SyncTimeValue : Integer; // 同步间隔
  LastSyncTime : TDateTime;  // 上一次同步时间
  IsKeepDeleted : Boolean;
  KeepEditionCount : Integer;
  IsEncrypt : Boolean;
  Password, PasswordHint : string;
  FileCount : Integer;
  ItemSize, CompletedSize : Int64; // 空间信息
  BackupItemReadHandle : TBackupItemReadHandle;
begin
  BackupPath := MyXmlUtil.GetChildValue( BackupItemNode, Xml_BackupPath );
  IsFile := MyXmlUtil.GetChildBoolValue( BackupItemNode, Xml_IsFile );
  IsCompleted := MyXmlUtil.GetChildBoolValue( BackupItemNode, Xml_IsCompleted );

  IsBackupNow := MyXmlUtil.GetChildBoolValue( BackupItemNode, Xml_IsBackupNow );
  IsAutoSync := MyXmlUtil.GetChildBoolValue( BackupItemNode, Xml_IsAutoSync );
  SyncTimeType := MyXmlUtil.GetChildIntValue( BackupItemNode, Xml_SyncTimeType );
  SyncTimeValue := MyXmlUtil.GetChildIntValue( BackupItemNode, Xml_SyncTimeValue );
  LastSyncTime := MyXmlUtil.GetChildFloatValue( BackupItemNode, Xml_LastSyncTime );

  IsKeepDeleted := MyXmlUtil.GetChildBoolValue( BackupItemNode, Xml_IsKeepDeleted );
  KeepEditionCount := MyXmlUtil.GetChildIntValue( BackupItemNode, Xml_KeepEditionCount );

  IsEncrypt := MyXmlUtil.GetChildBoolValue( BackupItemNode, Xml_IsEncrypt );
  PasswordHint := MyXmlUtil.GetChildValue( BackupItemNode, Xml_PasswordHint );
  Password := MyXmlUtil.GetChildValue( BackupItemNode, Xml_Password );
  Password := MyEncrypt.DecodeStr( Password ); // 解密


  FileCount := MyXmlUtil.GetChildIntValue( BackupItemNode, Xml_FileCount );
  ItemSize := MyXmlUtil.GetChildInt64Value( BackupItemNode, Xml_ItemSize );
  CompletedSize := MyXmlUtil.GetChildInt64Value( BackupItemNode, Xml_CompletedSize );

  BackupItemReadHandle := TBackupItemReadHandle.Create( DesItemID );
  BackupItemReadHandle.SetBackupPath( BackupPath );
  BackupItemReadHandle.SetIsFile( IsFile );
  BackupItemReadHandle.SetIsCompleted( IsCompleted );
  BackupItemReadHandle.SetIsBackupNow( IsBackupNow );
  BackupItemReadHandle.SetAutoSyncInfo( IsAutoSync, LastSyncTime );
  BackupItemReadHandle.SetSyncTimeInfo( SyncTimeType, SyncTimeValue );
  BackupItemReadHandle.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
  BackupItemReadHandle.SetDeleteInfo( IsKeepDeleted, KeepEditionCount );
  BackupItemReadHandle.SetEncryptInfo( IsEncrypt, Password, PasswordHint );
  BackupItemReadHandle.Update;
  BackupItemReadHandle.Free;

  ReadFilterList;

  ReadContinuseList;
end;

{ TDesItemChangeXml }

procedure TDesItemChangeXml.Update;
begin
  MyBackupNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyBackupInfo );
  DesItemNodeList := MyXmlUtil.AddChild( MyBackupNode, Xml_DesItemList );
end;


{ TBackupItemSetSpaceInfoXml }

procedure TBackupItemSetSpaceInfoXml.SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TBackupItemSetSpaceInfoXml.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;
  MyXmlUtil.AddChild( BackupItemNode, Xml_FileCount, FileCount );
  MyXmlUtil.AddChild( BackupItemNode, Xml_ItemSize, ItemSize );
  MyXmlUtil.AddChild( BackupItemNode, Xml_CompletedSize, CompletedSize );
end;

{ TBackupItemSetAddCompletedSpaceXml }

procedure TBackupItemSetAddCompletedSpaceXml.SetAddCompletedSpace( _AddCompletedSpace : int64 );
begin
  AddCompletedSpace := _AddCompletedSpace;
end;

procedure TBackupItemSetAddCompletedSpaceXml.Update;
var
  CompletedSpace : Int64;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;

  CompletedSpace := MyXmlUtil.GetChildInt64Value( BackupItemNode, Xml_CompletedSize );
  CompletedSpace := CompletedSpace + AddCompletedSpace;
  MyXmlUtil.AddChild( BackupItemNode, Xml_CompletedSize, CompletedSpace );
end;

{ TDesItemAddLocalXml }

procedure TDesItemAddLocalXml.SetItemInfo;
begin
  MyXmlUtil.AddChild( DesNode, Xml_DesItemType, DesItemType_Local );
end;

{ TDesItemAddNetworkXml }

procedure TDesItemAddNetworkXml.SetItemInfo;
begin
  MyXmlUtil.AddChild( DesNode, Xml_DesItemType, DesItemType_Network );
end;

{ TBackupItemFilterAddXml }

procedure TBackupItemFilterAddXml.SetFilterXml(_FilterType,
  _FilterValue: string);
begin
  FilterType := _FilterType;
  FilterValue := _FilterValue;
end;

{ TBackupItemIncludeFilterClearXml }

procedure TBackupItemIncludeFilterClearXml.Update;
begin
  inherited;
  if not FindFilterList then
    Exit;
  IncludeFilterListNode.ChildNodes.Clear;
end;

{ TBackupItemFilterWriteXml }

function TBackupItemFilterWriteXml.FindFilterList: Boolean;
begin
  Result := False;
  if not FindBackupItemNode then
    Exit;
  IncludeFilterListNode := MyXmlUtil.AddChild( BackupItemNode, Xml_IncludeFilterList );
  ExcludeFilterListNode := MyXmlUtil.AddChild( BackupItemNode, Xml_ExcludeFilterList );
  Result := True;
end;

{ TBackupItemIncludeFilterAddXml }

procedure TBackupItemIncludeFilterAddXml.Update;
var
  FilterNode : IXMLNode;
begin
  inherited;
  if not FindFilterList then
    Exit;
  FilterNode := MyXmlUtil.AddListChild( IncludeFilterListNode );
  MyXmlUtil.AddChild( FilterNode, Xml_FilterType, FilterType );
  MyXmlUtil.AddChild( FilterNode, Xml_FilterValue, FilterValue );
end;

{ TBackupItemExcludeFilterClearXml }

procedure TBackupItemExcludeFilterClearXml.Update;
begin
  inherited;
  if not FindFilterList then
    Exit;
  ExcludeFilterListNode.ChildNodes.Clear;
end;

{ TBackupItemExcludeFilterAddXml }

procedure TBackupItemExcludeFilterAddXml.Update;
var
  FilterNode : IXMLNode;
begin
  inherited;
  if not FindFilterList then
    Exit;
  FilterNode := MyXmlUtil.AddListChild( ExcludeFilterListNode );
  MyXmlUtil.AddChild( FilterNode, Xml_FilterType, FilterType );
  MyXmlUtil.AddChild( FilterNode, Xml_FilterValue, FilterValue );
end;


{ TBackupItemIncludeFilterReadXml }

constructor TBackupItemIncludeFilterReadXml.Create(
  _IncludeFilterListNode: IXMLNode);
begin
  IncludeFilterListNode := _IncludeFilterListNode;
end;

procedure TBackupItemIncludeFilterReadXml.SetBackupPath(_BackupPath: string);
begin
  BackupPath := _BackupPath;
end;

procedure TBackupItemIncludeFilterReadXml.SetDesItemID(_DesItemID: string);
begin
  DesItemID := _DesItemID;
end;

procedure TBackupItemIncludeFilterReadXml.Update;
var
  FilterList : TFileFilterList;
  i: Integer;
  FilterNode : IXMLNode;
  FilterType, FilterValue : string;
  FilterInfo : TFileFilterInfo;
  BackupItemIncludeFilterReadHandle : TBackupItemIncludeFilterReadHandle;
begin
    // 读取信息
  FilterList := TFileFilterList.Create;
  for i := 0 to IncludeFilterListNode.ChildNodes.Count - 1 do
  begin
    FilterNode := IncludeFilterListNode.ChildNodes[i];
    FilterType := MyXmlUtil.GetChildValue( FilterNode, Xml_FilterType );
    FilterValue := MyXmlUtil.GetChildValue( FilterNode, Xml_FilterValue );
    FilterInfo := TFileFilterInfo.Create( FilterType, FilterValue );
    FilterList.Add( FilterInfo );
  end;

    // 处理信息
  BackupItemIncludeFilterReadHandle := TBackupItemIncludeFilterReadHandle.Create( DesItemID );
  BackupItemIncludeFilterReadHandle.SetBackupPath( BackupPath );
  BackupItemIncludeFilterReadHandle.SetIncludeFilterList( FilterList );
  BackupItemIncludeFilterReadHandle.Update;
  BackupItemIncludeFilterReadHandle.Free;

  FilterList.Free;
end;

{ TBackupItemExcludeFilterReadXml }

constructor TBackupItemExcludeFilterReadXml.Create(
  _ExcludeFilterListNode: IXMLNode);
begin
  ExcludeFilterListNode := _ExcludeFilterListNode;
end;

procedure TBackupItemExcludeFilterReadXml.SetBackupPath(_BackupPath: string);
begin
  BackupPath := _BackupPath;
end;

procedure TBackupItemExcludeFilterReadXml.SetDesItemID(_DesItemID: string);
begin
  DesItemID := _DesItemID;
end;

procedure TBackupItemExcludeFilterReadXml.Update;
var
  FilterList : TFileFilterList;
  i: Integer;
  FilterNode : IXMLNode;
  FilterType, FilterValue : string;
  FilterInfo : TFileFilterInfo;
  BackupItemExcludeFilterReadHandle : TBackupItemExcludeFilterReadHandle;
begin
    // 读取信息
  FilterList := TFileFilterList.Create;
  for i := 0 to ExcludeFilterListNode.ChildNodes.Count - 1 do
  begin
    FilterNode := ExcludeFilterListNode.ChildNodes[i];
    FilterType := MyXmlUtil.GetChildValue( FilterNode, Xml_FilterType );
    FilterValue := MyXmlUtil.GetChildValue( FilterNode, Xml_FilterValue );
    FilterInfo := TFileFilterInfo.Create( FilterType, FilterValue );
    FilterList.Add( FilterInfo );
  end;

    // 处理信息
  BackupItemExcludeFilterReadHandle := TBackupItemExcludeFilterReadHandle.Create( DesItemID );
  BackupItemExcludeFilterReadHandle.SetBackupPath( BackupPath );
  BackupItemExcludeFilterReadHandle.SetExcludeFilterList( FilterList );
  BackupItemExcludeFilterReadHandle.Update;
  BackupItemExcludeFilterReadHandle.Free;

  FilterList.Free;
end;

{ TBackupItemSetEncryptInfoXml }

procedure TBackupItemSetEncryptInfoXml.SetEncryptInfo( _IsEncrypt : boolean; _Password, _PasswordHint : string );
begin
  IsEncrypt := _IsEncrypt;
  Password := _Password;
  PasswordHint := _PasswordHint;
end;

procedure TBackupItemSetEncryptInfoXml.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;
  MyXmlUtil.AddChild( BackupItemNode, Xml_IsEncrypt, IsEncrypt );
  MyXmlUtil.AddChild( BackupItemNode, Xml_PasswordHint, PasswordHint );
  Password := MyEncrypt.EncodeStr( Password ); // 加密
  MyXmlUtil.AddChild( BackupItemNode, Xml_Password, Password );
end;

{ TBackupItemSetDeletedInfoXml }

procedure TBackupItemSetDeletedInfoXml.SetDeletedInfo( _IsKeepDeleted : boolean; _KeepEditionCount : integer );
begin
  IsKeepDeleted := _IsKeepDeleted;
  KeepEditionCount := _KeepEditionCount;
end;

procedure TBackupItemSetDeletedInfoXml.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;
  MyXmlUtil.AddChild( BackupItemNode, Xml_IsKeepDeleted, IsKeepDeleted );
  MyXmlUtil.AddChild( BackupItemNode, Xml_KeepEditionCount, KeepEditionCount );
end;

{ TBackupLogChangeXml }

function TBackupCompletedDateLogChangeXml.FindBackupDateLogNodeList: Boolean;
begin
  Result := FindBackupItemNode;
  if Result then
    BackupDateLogNodeList := MyXmlUtil.AddChild( BackupItemNode, Xml_BackupCompletedDateLogList )
  else
    BackupDateLogNodeList := nil;
end;

{ TBackupLogClearXml }

procedure TBackupLogClearCompletedXml.Update;
begin
  inherited;

    // Item 不存在
  if not FindBackupDateLogNodeList then
    Exit;

  BackupDateLogNodeList.ChildNodes.Clear;
end;

{ TBackupItemSetIsCompletedXml }

procedure TBackupItemSetIsCompletedXml.SetIsCompleted( _IsCompleted : boolean );
begin
  IsCompleted := _IsCompleted;
end;

procedure TBackupItemSetIsCompletedXml.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;
  MyXmlUtil.AddChild( BackupItemNode, Xml_IsCompleted, IsCompleted );
end;

{ TBackupContinusChangeXml }

function TBackupContinusChangeXml.FindBackupContinusNodeList : Boolean;
begin
  Result := FindBackupItemNode;
  if Result then
    BackupContinusNodeList := MyXmlUtil.AddChild( BackupItemNode, Xml_BackupContinusList );
end;

{ TBackupContinusWriteXml }

procedure TBackupContinusWriteXml.SetFilePath( _FilePath : string );
begin
  FilePath := _FilePath;
end;


function TBackupContinusWriteXml.FindBackupContinusNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  if not FindBackupContinusNodeList then
    Exit;
  for i := 0 to BackupContinusNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := BackupContinusNodeList.ChildNodes[i];
    if ( MyXmlUtil.GetChildValue( SelectNode, Xml_FilePath ) = FilePath ) then
    begin
      Result := True;
      BackupContinusIndex := i;
      BackupContinusNode := BackupContinusNodeList.ChildNodes[i];
      break;
    end;
  end;
end;

{ TBackupContinusAddXml }

procedure TBackupContinusAddXml.SetFileInfo( _FileSize : int64;
  _FileTime : TDateTime );
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TBackupContinusAddXml.Update;
begin
  inherited;

    // 不存在 则创建
  if not FindBackupContinusNode then
  begin
    BackupContinusNode := MyXmlUtil.AddListChild( BackupContinusNodeList );
    MyXmlUtil.AddChild( BackupContinusNode, Xml_FilePath, FilePath );
    MyXmlUtil.AddChild( BackupContinusNode, Xml_FileSize, FileSize );
    MyXmlUtil.AddChild( BackupContinusNode, Xml_FileTime, FileTime );
  end;
end;

{ TBackupContinusRemoveXml }

procedure TBackupContinusRemoveXml.Update;
begin
  inherited;

  if not FindBackupContinusNode then
    Exit;

  MyXmlUtil.DeleteListChild( BackupContinusNodeList, BackupContinusIndex );
end;

{ SendContinusNode }

constructor TBackupContinusReadXml.Create( _BackupContinusNode : IXMLNode );
begin
  BackupContinusNode := _BackupContinusNode;
end;

procedure TBackupContinusReadXml.SetItemInfo(_SendRootItemID,
  _SourcePath: string);
begin
  DesItemID := _SendRootItemID;
  SourcePath := _SourcePath;
end;

procedure TBackupContinusReadXml.Update;
var
  FilePath : string;
  FileSize : int64;
  FileTime : TDateTime;
  BackupContinusReadHandle : TBackupContinusReadHandle;
begin
  FilePath := MyXmlUtil.GetChildValue( BackupContinusNode, Xml_FilePath );
  FileSize := MyXmlUtil.GetChildInt64Value( BackupContinusNode, Xml_FileSize );
  FileTime := MyXmlUtil.GetChildFloatValue( BackupContinusNode, Xml_FileTime );

  BackupContinusReadHandle := TBackupContinusReadHandle.Create( DesItemID );
  BackupContinusReadHandle.SetBackupPath( SourcePath );
  BackupContinusReadHandle.SetFilePath( FilePath );
  BackupContinusReadHandle.SetFileInfo( FileSize, FileTime );
  BackupContinusReadHandle.Update;
  BackupContinusReadHandle.Free;
end;



{ TDesItemAddXml }

procedure TDesItemAddXml.Update;
begin
  inherited;

    // 已存在
  if FindDesNode then
    Exit;

  DesNode := MyXmlUtil.AddListChild( DesItemNodeList );
  MyXmlUtil.AddChild( DesNode, Xml_DesItemID, DesItemID );

    // 设置信息
  SetItemInfo;
end;

{ TBackupSpeedChangeXml }

procedure TBackupSpeedChangeXml.Update;
begin
  MyBackupNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyBackupInfo );
  BackupSpeedNode := MyXmlUtil.AddChild( MyBackupNode, Xml_BackupSpeed );
end;

{ TBackupSpeedLimitXml }

procedure TBackupSpeedLimitXml.SetIsLimit(_IsLimit: Boolean);
begin
  IsLimit := _IsLimit;
end;

procedure TBackupSpeedLimitXml.SetLimitXml(_LimitValue, _LimitType: Integer);
begin
  LimitValue := _LimitValue;
  LimitType := _LimitType;
end;

procedure TBackupSpeedLimitXml.Update;
begin
  inherited;

  MyXmlUtil.AddChild( BackupSpeedNode, Xml_IsLimit, IsLimit );
  MyXmlUtil.AddChild( BackupSpeedNode, Xml_LimitType, LimitType );
  MyXmlUtil.AddChild( BackupSpeedNode, Xml_LimitValue, LimitValue );
end;

{ TBackupSpeedReadXml }

constructor TBackupSpeedReadXml.Create(_BackupSpeedNode: IXMLNode);
begin
  BackupSpeedNode := _BackupSpeedNode;
end;

procedure TBackupSpeedReadXml.Update;
var
  IsLimit : Boolean;
  LimitType, LimitValue : Integer;
  BackupSpeedLimitReadHandle : TBackupSpeedLimitReadHandle;
begin
  IsLimit := StrToBoolDef( MyXmlUtil.GetChildValue( BackupSpeedNode, Xml_IsLimit ), False );
  LimitType := MyXmlUtil.GetChildIntValue( BackupSpeedNode, Xml_LimitType );
  LimitValue := MyXmlUtil.GetChildIntValue( BackupSpeedNode, Xml_LimitValue );

  BackupSpeedLimitReadHandle := TBackupSpeedLimitReadHandle.Create( IsLimit );
  BackupSpeedLimitReadHandle.SetLimitInfo( LimitType, LimitValue );
  BackupSpeedLimitReadHandle.Update;
  BackupSpeedLimitReadHandle.Free
end;

{ TBackupLogAddCompletedXml }

procedure TBackupLogAddCompletedXml.AddDateLogFileCount;
var
  FileCount : Integer;
begin
  FileCount := MyXmlUtil.GetChildIntValue( BackupDateLogNode, Xml_FileCount );
  Inc( FileCount );
  MyXmlUtil.AddChild( BackupDateLogNode, Xml_FileCount, FileCount );
end;

procedure TBackupLogAddCompletedXml.RemoveTopLimit;
var
  i: Integer;
begin
  for i := 1 to 20 do
    BackupFileLogNodeList.ChildNodes.Delete( 0 );
end;

procedure TBackupLogAddCompletedXml.SetBackupTime(_FileTime, _BackupTime: TDateTime);
begin
  FileTime := _FileTime;
  BackupTime := _BackupTime;
end;

procedure TBackupLogAddCompletedXml.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TBackupLogAddCompletedXml.Update;
var
  BackupLogNode : IXMLNode;
begin
  inherited;

    // 寻找文件列表
  if not FindBackupFileLogNodeList then
    Exit;

    // 超过限制
  if BackupFileLogNodeList.ChildNodes.Count >= 100 then
    RemoveTopLimit;

    // 统计Date总共有多少个文件
  AddDateLogFileCount;

    // 添加日志
  BackupLogNode := MyXmlUtil.AddListChild( BackupFileLogNodeList );
  MyXmlUtil.AddChild( BackupLogNode, Xml_FilePath, FilePath );
  MyXmlUtil.AddChild( BackupLogNode, Xml_FileTime, FileTime );
  MyXmlUtil.AddChild( BackupLogNode, Xml_BackupTime, BackupTime );
end;

{ TBackupLogAddIncompletedXml }

procedure TBackupLogAddIncompletedXml.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TBackupLogAddIncompletedXml.Update;
var
  BackupLogNode : IXMLNode;
begin
  inherited;

  if not FindBackupIncompletedLogNodeList then
    Exit;

  BackupLogNode := MyXmlUtil.AddListChild( BackupIncompletedLogNodeList );
  MyXmlUtil.AddChild( BackupLogNode, Xml_FilePath, FilePath );
end;

{ TBackupLogClearIncompletedXml }

procedure TBackupLogClearIncompletedXml.Update;
begin
  inherited;

  if not FindBackupIncompletedLogNodeList then
    Exit;

  BackupIncompletedLogNodeList.ChildNodes.Clear;
end;

{ TBackupIncompletedLogChangeXml }

function TBackupIncompletedLogChangeXml.FindBackupIncompletedLogNodeList: Boolean;
begin
  Result := FindBackupItemNode;
  if Result then
    BackupIncompletedLogNodeList := MyXmlUtil.AddChild( BackupItemNode, Xml_BackupIncompletedLogList );
end;

{ TBackupCompletedDateLogWriteXml }

procedure TBackupCompletedDateLogWriteXml.AddBackupDateLogNode;
begin
  if BackupDateLogNodeList.ChildNodes.Count >= 10 then
    BackupDateLogNodeList.ChildNodes.Delete( 0 );

  BackupDateLogNode := MyXmlUtil.AddListChild( BackupDateLogNodeList );
  MyXmlUtil.AddChild( BackupDateLogNode, Xml_BackupDate, BackupDate );
end;

function TBackupCompletedDateLogWriteXml.FindBackupDateLogNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  if not FindBackupDateLogNodeList then
    Exit;

  for i := 0 to BackupDateLogNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := BackupDateLogNodeList.ChildNodes[i];
    if ( MyXmlUtil.GetChildFloatValue( SelectNode, Xml_BackupDate ) = BackupDate ) then
    begin
      Result := True;
      BackupDateLogNode := BackupDateLogNodeList.ChildNodes[i];
      break;
    end;
  end;
end;

procedure TBackupCompletedDateLogWriteXml.SetBackupDate(_BackupDate: TDate);
begin
  BackupDate := _BackupDate;
end;

{ TBackupLogChangeCompletedXml }

function TBackupLogChangeCompletedXml.FindBackupFileLogNodeList: Boolean;
begin
  Result := False;

    // 寻找当前日期的日志
  if not FindBackupDateLogNode then
  begin
    if BackupDateLogNodeList = nil then // Backup Item 不存在
      Exit;
    AddBackupDateLogNode;  // 添加
  end;

    // 添加
  BackupFileLogNodeList := MyXmlUtil.AddChild( BackupDateLogNode, Xml_BackupCompletedFileLogList );

  Result := True;
end;

{ MyBackupLogXmlReadUtil }

class function MyBackupLogXmlReadUtil.ReadCompletedDateLogList( DesItemID,
  BackupPath : string ): IXMLNode;
var
  BackupCompletedDateLogChangeXml : TBackupCompletedDateLogChangeXml;
begin
  BackupCompletedDateLogChangeXml := TBackupCompletedDateLogChangeXml.Create( DesItemID );
  BackupCompletedDateLogChangeXml.SetBackupPath( BackupPath );
  BackupCompletedDateLogChangeXml.Update;
  if BackupCompletedDateLogChangeXml.FindBackupDateLogNodeList then
    Result := BackupCompletedDateLogChangeXml.BackupDateLogNodeList
  else
    Result := nil;
  BackupCompletedDateLogChangeXml.Free;
end;

class function MyBackupLogXmlReadUtil.ReadIncompletedLogList(DesItemID,
  BackupPath: string): IXMLNode;
var
  BackupIncompletedLogChangeXml : TBackupIncompletedLogChangeXml;
begin
  BackupIncompletedLogChangeXml := TBackupIncompletedLogChangeXml.Create( DesItemID );
  BackupIncompletedLogChangeXml.SetBackupPath( BackupPath );
  BackupIncompletedLogChangeXml.Update;
  if BackupIncompletedLogChangeXml.FindBackupIncompletedLogNodeList then
    Result := BackupIncompletedLogChangeXml.BackupIncompletedLogNodeList
  else
    Result := nil;
  BackupIncompletedLogChangeXml.Free;
end;

end.
