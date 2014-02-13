unit UMyRestoreDataInfo;

interface

uses Generics.Collections, UDataSetInfo, UMyUtil, classes, UFileBaseInfo;

type

{$Region ' 数据结构 ' }

    // 续传信息
  TRestoreDownContinusInfo = class
  public
    FilePath : string;
    FileSize : Int64;
    FileTime : TDateTime;
  public
    constructor Create( _FilePath : string );
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
  end;
  TRestoreDownContinusList = class( TObjectList< TRestoreDownContinusInfo > )end;

    // 数据结构
  TRestoreDownInfo = class
  public
    RestorePath, OwnerPcID, RestoreFrom : string;
    IsFile, IsCompleted, IsRestoring, IsLostConn : Boolean;
    IsDesBusy : Boolean;
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
    RestoreDownContinusList : TRestoreDownContinusList;
    FileEditionList : TFileEditionList;
  public
    constructor Create( _RestorePath, _OwnerPcID, _RestoreFrom : string );
    procedure SetIsFile( _IsFile : Boolean );
    procedure SetIsRestoring( _IsRestoring : Boolean );
    procedure SetIsCompleted( _IsCompleted : Boolean );
    procedure SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
    procedure SetDeletedInfo( _IsDeleted : Boolean; _EiditionNum : Integer );
    procedure SetEncryptInfo( _IsEncrypt : Boolean; _Password : string );
    procedure SetSavePath( _SavePath : string );
    destructor Destroy; override;
  end;
  TRestoreDownList = class( TObjectList<TRestoreDownInfo> );

    // 恢复本地文件
  TRestoreDownLocalInfo = class( TRestoreDownInfo )
  end;

    // 恢复网络文件
  TRestoreDownNetworkInfo = class( TRestoreDownInfo )
  end;

      // 备份速度信息
  TRestoreSpeedInfo = class
  public
    IsLimit : Boolean;
    LimitValue : Integer;
    LimitType : Integer;
  public
    constructor Create;
  end;

    // 浏览历史
  TRestoreExplorerHistoryInfo = class
  public
    FilePath, OwnerPcID, RestoreFrom : string;
  public
    constructor Create( _FilePath, _OwnerPcID, _RestoreFrom : string );
  end;
  TRestoreExplorerHistoryList = class( TObjectList<TRestoreExplorerHistoryInfo> )end;


    // 数据集
  TMyRestoreDownInfo = class( TMyDataInfo )
  public
    RestoreDownList : TRestoreDownList;
    RestoreSpeedInfo : TRestoreSpeedInfo;
  public
    RestoreExplorerHistoryList : TRestoreExplorerHistoryList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

{$EndRegion}

{$Region ' 数据访问 ' }

    // 访问 数据 List 接口
  TRestoreDownListAccessInfo = class
  protected
    RestoreDownList : TRestoreDownList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // 访问 数据接口
  TRestoreDownAccessInfo = class( TRestoreDownListAccessInfo )
  public
    RestorePath, RestoreOwner : string;
    RestoreFrom : string;
  protected
    RestoreDownIndex : Integer;
    RestoreDownInfo : TRestoreDownInfo;
  public
    constructor Create( _RestorePath, _RestoreOwner, _RestoreFrom : string );
  protected
    function FindRestoreDownInfo: Boolean;
  end;

      // 访问 数据 List 接口
  TRestoreDownContinusListAccessInfo = class( TRestoreDownAccessInfo )
  protected
    RestoreDownContinusList : TRestoreDownContinusList;
  protected
    function FindRestoreDownContinusList : Boolean;
  end;

    // 访问 数据接口
  TRestoreDownContinusAccessInfo = class( TRestoreDownContinusListAccessInfo )
  public
    FilePath : string;
  protected
    RestoreDownContinusIndex : Integer;
    RestoreDownContinusInfo : TRestoreDownContinusInfo;
  public
    procedure SetFilePath( _FilePath : string );
  protected
    function FindRestoreDownContinusInfo: Boolean;
  end;

    // 访问 恢复文件版本
  TRestoreFileEditionListAccessInfo = class( TRestoreDownAccessInfo )
  public
    FileEditionList : TFileEditionList;
  protected
    function FindFileEditionList : Boolean;
  end;

      // 备份速度 数据接口
  TRestoreSpeedAccessInfo = class
  public
    RestoreSpeedInfo : TRestoreSpeedInfo;
  public
    constructor Create;
  end;

      // 访问 数据 List 接口
  TRestoreExplorerHistoryListAccessInfo = class
  protected
    RestoreExplorerHistoryList : TRestoreExplorerHistoryList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // 访问 数据接口
  TRestoreExplorerHistoryAccessInfo = class( TRestoreExplorerHistoryListAccessInfo )
  public
    FilePath, OwnerPcID, RestoreFrom : string;
  protected
    RestoreExplorerHistoryIndex : Integer;
    RestoreExplorerHistoryInfo : TRestoreExplorerHistoryInfo;
  public
    constructor Create( _FilePath, _OwnerPcID, _RestoreFrom : string );
  protected
    function FindRestoreExplorerHistoryInfo: Boolean;
  end;

    // 修改父类
  TRestoreExplorerHistoryWriteInfo = class( TRestoreExplorerHistoryAccessInfo )
  end;

    // 读取父类
  TRestoreExplorerHistoryReadInfo = class( TRestoreExplorerHistoryAccessInfo )
  end;

{$EndRegion}

{$Region ' 数据修改 ' }

    // 修改父类
  TRestoreDownWriteInfo = class( TRestoreDownAccessInfo )
  end;

  {$Region ' 增删修改 ' }

    // 添加
  TRestoreDownAddInfo = class( TRestoreDownWriteInfo )
  public
    IsFile, IsCompleted : Boolean;
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
    procedure SetIsCompleted( _IsCompleted : Boolean );
    procedure SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
    procedure SetDeletedInfo( _IsDeleted : Boolean; _EditionNum : Integer );
    procedure SetEncryptInfo( _IsEncrypt : Boolean; _Password : string );
    procedure SetSavePath( _SavePath : string );
    procedure Update;
  protected
    procedure CreateRestoreDown;virtual;abstract;
  end;

    // 添加 本地恢复
  TRestoreDownAddLocalInfo = class( TRestoreDownAddInfo )
  protected
    procedure CreateRestoreDown;override;
  end;

    // 添加 网络恢复
  TRestoreDownAddNetworkInfo = class( TRestoreDownAddInfo )
  protected
    procedure CreateRestoreDown;override;
  end;

    // 删除
  TRestoreDownRemoveInfo = class( TRestoreDownWriteInfo )
  public
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' 状态信息 ' }

    // 修改
  TRestoreDownSetIsRestoringInfo = class( TRestoreDownWriteInfo )
  public
    IsRestoring : boolean;
  public
    procedure SetIsRestoring( _IsRestoring : boolean );
    procedure Update;
  end;

      // 修改
  TRestoreDownSetIsCompletedInfo = class( TRestoreDownWriteInfo )
  public
    IsCompleted : boolean;
  public
    procedure SetIsCompleted( _IsCompleted : boolean );
    procedure Update;
  end;

    // 修改
  TRestoreDownSetIsDesBusyInfo = class( TRestoreDownWriteInfo )
  public
    IsDesBusy : boolean;
  public
    procedure SetIsDesBusy( _IsDesBusy : boolean );
    procedure Update;
  end;

    // 修改
  TRestoreDownSetIsLostConnInfo = class( TRestoreDownWriteInfo )
  public
    IsLostConn : boolean;
  public
    procedure SetIsLostConn( _IsLostConn : boolean );
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' 空间信息 ' }

    // 修改
  TRestoreDownSetSpaceInfoInfo = class( TRestoreDownWriteInfo )
  public
    FileCount : integer;
    FileSize, CompletedSize : int64;
  public
    procedure SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
    procedure Update;
  end;

    // 修改
  TRestoreDownSetAddCompletedSpaceInfo = class( TRestoreDownWriteInfo )
  public
    AddCompletedSpace : int64;
  public
    procedure SetAddCompletedSpace( _AddCompletedSpace : int64 );
    procedure Update;
  end;

      // 修改
  TRestoreDownSetCompletedSizeInfo = class( TRestoreDownWriteInfo )
  public
    CompletedSize : int64;
  public
    procedure SetCompletedSize( _CompletedSize : int64 );
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' 续传信息 ' }

      // 修改父类
  TRestoreDownContinusWriteInfo = class( TRestoreDownContinusAccessInfo )
  end;

    // 添加
  TRestoreDownContinusAddInfo = class( TRestoreDownContinusWriteInfo )
  public
    FileSize : int64;
    FileTime : TDateTime;
  public
    procedure SetFileInfo( _FileSize : int64; _FileTime : TDateTime );
    procedure Update;
  end;

    // 删除
  TRestoreDownContinusRemoveInfo = class( TRestoreDownContinusWriteInfo )
  public
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' 恢复文件版本 ' }

    // 清空版本信息
  TRestoreFileEditionClearInfo = class( TRestoreFileEditionListAccessInfo )
  public
    procedure Update;
  end;

    // 添加恢复版本信息
  TRestoreFileEditionAddInfo = class( TRestoreFileEditionListAccessInfo )
  public
    FilePath : string;
    EditionNum : Integer;
  public
    procedure SetFilePath( _FilePath : string );
    procedure SetEditionNum( _EditionNum : Integer );
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' 速度信息 ' }

    // 速度限制
  TRestoreSpeedLimitInfo = class( TRestoreSpeedAccessInfo )
  public
    IsLimit : Boolean;
    LimitValue, LimitType : Integer;
  public
    procedure SetIsLimit( _IsLimit : Boolean );
    procedure SetLimitInfo( _LimitValue, _LimitType : Integer );
    procedure Update;
  end;

{$EndRegion}

  {$Region ' 浏览历史信息 ' }

      // 添加
  TRestoreExplorerHistoryAddInfo = class( TRestoreExplorerHistoryWriteInfo )
  public
    procedure Update;
  end;

    // 删除
  TRestoreExplorerHistoryRemoveInfo = class( TRestoreExplorerHistoryListAccessInfo )
  public
    RemoveIndex : Integer;
  public
    constructor Create( _RemoveIndex : Integer );
    procedure Update;
  end;


  {$EndRegion}

{$EndRegion}

{$Region ' 数据读取 ' }

    // 读取父类
  TRestoreDownReadInfo = class( TRestoreDownAccessInfo )
  end;

    // 读取 恢复保存路径
  TRestoreDownReadSavePath = class( TRestoreDownReadInfo )
  public
    function get : string;
  end;

    // 读取恢复下载 是否生效
  TRestoreDownReadIsEnableInfo = class( TRestoreDownReadInfo )
  public
    function get : Boolean;
  end;

    // 读取恢复下载 是否已完成
  TRestoreDownReadIsCompletedInfo = class( TRestoreDownReadInfo )
  public
    function get : Boolean;
  end;

    // 读取恢复下载 是否已完成
  TRestoreDownReadIsRestoringInfo = class( TRestoreDownReadInfo )
  public
    function get : Boolean;
  end;

    // 读取恢复下载 是否 恢复删除的文件
  TRestoreDownReadIsFile = class( TRestoreDownReadInfo )
  public
    function get : Boolean;
  end;

    // 读取恢复下载 是否 本地恢复
  TRestoreDownReadIsLocal = class( TRestoreDownReadInfo )
  public
    function get : Boolean;
  end;

    // 读取恢复下载 是否 恢复删除的文件
  TRestoreDownReadIsDeleted = class( TRestoreDownReadInfo )
  public
    function get : Boolean;
  end;

    // 读取恢复下载 是否 恢复删除的文件
  TRestoreDownReadEditionNum = class( TRestoreDownReadInfo )
  public
    function get : Integer;
  end;

    // 读取恢复下载 是否 恢复删除的文件
  TRestoreDownReadFileEditionHash = class( TRestoreFileEditionListAccessInfo )
  public
    function get : TFileEditionHash;
  end;

    // 读取恢复下载 是否 恢复删除的文件
  TRestoreDownReadIsEncrypted = class( TRestoreDownReadInfo )
  public
    function get : Boolean;
  end;

    // 读取恢复下载 是否 恢复删除的文件
  TRestoreDownReadPassword = class( TRestoreDownReadInfo )
  public
    function get : string;
  end;

    // 上线恢复信息
  TRestoreKeyItemInfo = class
  public
    RestorePath, OwnerPcID, RestoreFrom : string;
  public
    constructor Create( _RestorePath, _OwnerPcID, _RestoreFrom : string );
  end;
  TRestoreKeyItemList = class( TObjectList<TRestoreKeyItemInfo> )end;

    // pc 上线 读取 Pc 的恢复Job
  TRestoreDownReadOnlineRestore = class( TRestoreDownListAccessInfo )
  public
    OnlinePcID : string;
  public
    procedure SetOnlinePcID( _OnlinePcID : string );
    function get : TRestoreKeyItemList;
  end;

    // 程序运行，读取本地开始恢复
  TRestoreDownReadLocalStartRestore = class( TRestoreDownListAccessInfo )
  public
    function get : TRestoreKeyItemList;
  end;

    // 程序运行，读取网络开始恢复
  TRestoreDownReadNetworkStartRestore = class( TRestoreDownListAccessInfo )
  public
    function get : TRestoreKeyItemList;
  end;

    // 读取 繁忙列表
  TRestoreDownReadDesBusyList = class( TRestoreDownListAccessInfo )
  public
    function get : TRestoreKeyItemList;
  end;

    // 读取 断开 Pc 列表
  TRestoreDownReadLostConnList = class( TRestoreDownListAccessInfo )
  public
    function get : TRestoreKeyItemList;
  end;

    // 读取 Incompleted 列表
  TRestoreDownReadIncompletedList = class( TRestoreDownListAccessInfo )
  public
    function get : TRestoreKeyItemList;
  end;

    // 读取 恢复下载扫描信息
  TRestoreDownScanInfo = class
  public
    IsFile : Boolean;
    IsDeleted : Boolean;
  public
    IsEncrypted : Boolean;
    Password : string;
  public
    procedure SetIsFile( _IsFile : Boolean );
    procedure SetIsDeleted( _IsDeleted : Boolean );
    procedure SetEncryptInfo( _IsEncrypted : Boolean; _Password : string );
  end;

    // 读取 恢复下载 扫描信息
  TRestoreDownReadScanInfo = class( TRestoreDownAccessInfo )
  public
    function get : TRestoreDownScanInfo;
  end;

      // 读取 续传列表
  TRestoreDownReadContinusList = class( TRestoreDownContinusListAccessInfo )
  public
    function get : TRestoreDownContinusList;
  end;

      // 读取 辅助类
  RestoreDownInfoReadUtil = class
  public
    class function ReadIsEnable( RestorePath, OwnerPcID, RestoreFrom : string ): Boolean;
    class function ReadIsCompleted( RestorePath, OwnerPcID, RestoreFrom : string ): Boolean;
    class function ReadIsRestoring( RestorePath, OwnerPcID, RestoreFrom : string ): Boolean;
    class function ReadIsLocal( RestorePath, OwnerPcID, RestoreFrom : string ): Boolean;
  public
    class function ReadSavePath( RestorePath, OwnerPcID, RestoreFrom : string ): string;
    class function ReadIsFile( RestorePath, OwnerPcID, RestoreFrom : string ): Boolean;
    class function ReadIsDeleted( RestorePath, OwnerPcID, RestoreFrom : string ): Boolean;
    class function ReadIsEditionNum( RestorePath, OwnerPcID, RestoreFrom : string ): Integer;
    class function ReadIsEncrypt( RestorePath, OwnerPcID, RestoreFrom : string ): Boolean;
    class function ReadPassword( RestorePath, OwnerPcID, RestoreFrom : string ): string;
  public
    class function ReadLocalStartRestore : TRestoreKeyItemList;
    class function ReadNetworkStartRestore : TRestoreKeyItemList;
    class function ReadOnlineRestore( OnlinePcID : string ):TRestoreKeyItemList;
    class function ReadDesBusyList : TRestoreKeyItemList;
    class function ReadLostConnList : TRestoreKeyItemList;
    class function ReadIncompletedList : TRestoreKeyItemList;
    class function ReadScanInfo( RestorePath, OwnerPcID, RestoreFrom : string ): TRestoreDownScanInfo;
  public
    class function ReadContinuesList( RestorePath, OwnerPcID, RestoreFrom : string ): TRestoreDownContinusList;
    class function ReadFileEditionHash( RestorePath, OwnerPcID, RestoreFrom : string ): TFileEditionHash;
  end;

{$EndRegion}

{$Region ' 浏览历史 数据读取 ' }

    // 获取下标
 TShareExplorerHistoryReadExistIndex = class( TRestoreExplorerHistoryListAccessInfo )
  public
    FilePath, OwnerID, RestoreFrom : string;
  public
    procedure SetExplorerInfo( _FilePath, _OwnerID, _RestoreFrom : string );
    function get : Integer;
  end;

    // 获取历史数目
  TShareExplorerHistoryReadCount = class( TRestoreExplorerHistoryListAccessInfo )
  public
    function get : Integer;
  end;

    // 读取历史信息
  TShareExplorerHistoryReadList = class( TRestoreExplorerHistoryListAccessInfo )
  public
    HistoryIndex : Integer;
  public
    procedure SetHistoryIndex( _HistoryIndex : Integer );
    function get : TRestoreExplorerHistoryInfo;
  end;

    // 读取辅助类
  ShareExplorerHistoryInfoReadUtil = class
  public
    class function ReadExistIndex( FilePath, OwnerID, RestoreFrom : string ): Integer;
    class function ReadHistoryInfo( HistoryIndex : Integer ): TRestoreExplorerHistoryInfo;
    class function ReadHistoryCount : Integer;
  end;

{$EndRegion}

var
  MyRestoreDownInfo : TMyRestoreDownInfo;

implementation

{ TRestoreDownInfo }

constructor TRestoreDownInfo.Create( _RestorePath, _OwnerPcID, _RestoreFrom : string );
begin
  RestorePath := _RestorePath;
  OwnerPcID := _OwnerPcID;
  RestoreFrom := _RestoreFrom;
  RestoreDownContinusList := TRestoreDownContinusList.Create;
  FileEditionList := TFileEditionList.Create;
end;

procedure TRestoreDownInfo.SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

destructor TRestoreDownInfo.Destroy;
begin
  RestoreDownContinusList.Free;
  FileEditionList.Free;
  inherited;
end;

procedure TRestoreDownInfo.SetEncryptInfo(_IsEncrypt: Boolean;
  _Password: string);
begin
  IsEncrypt := _IsEncrypt;
  Password := _Password;
end;

procedure TRestoreDownInfo.SetIsCompleted(_IsCompleted: Boolean);
begin
  IsCompleted := _IsCompleted;
end;

procedure TRestoreDownInfo.SetDeletedInfo(_IsDeleted: Boolean; _EiditionNum : Integer);
begin
  IsDeleted := _IsDeleted;
  EditionNum := _EiditionNum;
end;

procedure TRestoreDownInfo.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TRestoreDownInfo.SetIsRestoring(_IsRestoring: Boolean);
begin
  IsRestoring := _IsRestoring;
end;

procedure TRestoreDownInfo.SetSavePath( _SavePath : string );
begin
  SavePath := _SavePath;
end;

{ TMyRestoreDownInfo }

constructor TMyRestoreDownInfo.Create;
begin
  inherited Create;
  RestoreDownList := TRestoreDownList.Create;
  RestoreSpeedInfo := TRestoreSpeedInfo.Create;
  RestoreExplorerHistoryList := TRestoreExplorerHistoryList.Create;
end;

destructor TMyRestoreDownInfo.Destroy;
begin
  RestoreExplorerHistoryList.Free;
  RestoreSpeedInfo.Free;
  RestoreDownList.Free;
  inherited;
end;

{ TRestoreDownListAccessInfo }

constructor TRestoreDownListAccessInfo.Create;
begin
  MyRestoreDownInfo.EnterData;
  RestoreDownList := MyRestoreDownInfo.RestoreDownList;
end;

destructor TRestoreDownListAccessInfo.Destroy;
begin
  MyRestoreDownInfo.LeaveData;
  inherited;
end;

{ TRestoreDownAccessInfo }

constructor TRestoreDownAccessInfo.Create( _RestorePath, _RestoreOwner, _RestoreFrom : string );
begin
  inherited Create;
  RestorePath := _RestorePath;
  RestoreOwner := _RestoreOwner;
  RestoreFrom := _RestoreFrom;
end;

function TRestoreDownAccessInfo.FindRestoreDownInfo: Boolean;
var
  i : Integer;
begin
  Result := False;
  for i := 0 to RestoreDownList.Count - 1 do
    if ( RestoreDownList[i].RestorePath = RestorePath ) and
       ( RestoreDownList[i].OwnerPcID = RestoreOwner ) and
       ( RestoreDownList[i].RestoreFrom = RestoreFrom )
    then
    begin
      Result := True;
      RestoreDownIndex := i;
      RestoreDownInfo := RestoreDownList[i];
      break;
    end;
end;

{ TRestoreDownAddInfo }

procedure TRestoreDownAddInfo.SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TRestoreDownAddInfo.Update;
begin
    // 不存在则创建
  if not FindRestoreDownInfo then
  begin
    CreateRestoreDown;
    RestoreDownList.Add( RestoreDownInfo );
  end;

  RestoreDownInfo.SetIsFile( IsFile );
  RestoreDownInfo.SetIsCompleted( IsCompleted );
  RestoreDownInfo.SetIsRestoring( False );
  RestoreDownInfo.SetSpaceInfo( FileCount, FileSize, CompletedSize );
  RestoreDownInfo.SetDeletedInfo( IsDeleted, EditionNum );
  RestoreDownInfo.SetEncryptInfo( IsEncrypt, Password );
  RestoreDownInfo.SetSavePath( SavePath );
  RestoreDownInfo.IsDesBusy := False;
  RestoreDownInfo.IsLostConn := False;
end;

procedure TRestoreDownAddInfo.SetEncryptInfo(_IsEncrypt: Boolean;
  _Password: string);
begin
  IsEncrypt := _IsEncrypt;
  Password := _Password;
end;

procedure TRestoreDownAddInfo.SetIsCompleted(_IsCompleted: Boolean);
begin
  IsCompleted := _IsCompleted;
end;

procedure TRestoreDownAddInfo.SetDeletedInfo(_IsDeleted: Boolean; _EditionNum : Integer);
begin
  IsDeleted := _IsDeleted;
  EditionNum := _EditionNum;
end;

procedure TRestoreDownAddInfo.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TRestoreDownAddInfo.SetSavePath( _SavePath : string );
begin
  SavePath := _SavePath;
end;

{ TRestoreDownRemoveInfo }

procedure TRestoreDownRemoveInfo.Update;
begin
  if not FindRestoreDownInfo then
    Exit;

  RestoreDownList.Delete( RestoreDownIndex );
end;

{ TRestoreDownAddLocalInfo }

procedure TRestoreDownAddLocalInfo.CreateRestoreDown;
begin
  RestoreDownInfo := TRestoreDownLocalInfo.Create( RestorePath, RestoreOwner, RestoreFrom );
end;

{ TRestoreDownAddNetworkInfo }

procedure TRestoreDownAddNetworkInfo.CreateRestoreDown;
begin
  RestoreDownInfo := TRestoreDownNetworkInfo.Create( RestorePath, RestoreOwner, RestoreFrom );
end;

{ TRestoreDownReadSavePath }

function TRestoreDownReadSavePath.get: string;
begin
  Result := '';
  if not FindRestoreDownInfo then
    Exit;
  Result := RestoreDownInfo.SavePath;
end;

{ TRestoreDownSetSpaceInfoInfo }

procedure TRestoreDownSetSpaceInfoInfo.SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TRestoreDownSetSpaceInfoInfo.Update;
begin
  if not FindRestoreDownInfo then
    Exit;
  RestoreDownInfo.FileCount := FileCount;
  RestoreDownInfo.FileSize := FileSize;
  RestoreDownInfo.CompletedSize := CompletedSize;
end;

{ TRestoreDownSetAddCompletedSpaceInfo }

procedure TRestoreDownSetAddCompletedSpaceInfo.SetAddCompletedSpace( _AddCompletedSpace : int64 );
begin
  AddCompletedSpace := _AddCompletedSpace;
end;

procedure TRestoreDownSetAddCompletedSpaceInfo.Update;
begin
  if not FindRestoreDownInfo then
    Exit;
  RestoreDownInfo.CompletedSize := RestoreDownInfo.CompletedSize + AddCompletedSpace;
end;

{ TRestoreDownReadIsEnableInfo }

function TRestoreDownReadIsEnableInfo.get: Boolean;
begin
  Result := FindRestoreDownInfo;
end;

{ TRestoreDownSetCompletedSizeInfo }

procedure TRestoreDownSetCompletedSizeInfo.SetCompletedSize( _CompletedSize : int64 );
begin
  CompletedSize := _CompletedSize;
end;

procedure TRestoreDownSetCompletedSizeInfo.Update;
begin
  if not FindRestoreDownInfo then
    Exit;
  RestoreDownInfo.CompletedSize := CompletedSize;
end;



{ TOnlineRestoreInfo }

constructor TRestoreKeyItemInfo.Create(_RestorePath, _OwnerPcID, _RestoreFrom: string);
begin
  RestorePath := _RestorePath;
  OwnerPcID := _OwnerPcID;
  RestoreFrom := _RestoreFrom;
end;

{ TRestoreDownReadOnlineRestore }

function TRestoreDownReadOnlineRestore.get: TRestoreKeyItemList;
var
  i: Integer;
  OnlineRestoreInfo : TRestoreKeyItemInfo;
  RestoreDownInfo : TRestoreDownInfo;
  SelectPcID : string;
begin
  Result := TRestoreKeyItemList.Create;

  for i := 0 to RestoreDownList.Count - 1 do
    if RestoreDownList[i] is TRestoreDownNetworkInfo then
    begin
      RestoreDownInfo := RestoreDownList[i];
      SelectPcID := NetworkDesItemUtil.getPcID( RestoreDownInfo.RestoreFrom );
      if ( SelectPcID = OnlinePcID ) and ( not RestoreDownInfo.IsCompleted ) then
      begin
        OnlineRestoreInfo := TRestoreKeyItemInfo.Create( RestoreDownInfo.RestorePath, RestoreDownInfo.OwnerPcID, RestoreDownInfo.RestoreFrom );
        Result.Add( OnlineRestoreInfo );
      end;
    end;
end;

procedure TRestoreDownReadOnlineRestore.SetOnlinePcID(_OnlinePcID: string);
begin
  OnlinePcID := _OnlinePcID;
end;

{ RestoreDownInfoReadUtil }

class function RestoreDownInfoReadUtil.ReadIsRestoring(RestorePath, OwnerPcID,
  RestoreFrom: string): Boolean;
var
  RestoreDownReadIsRestoringInfo : TRestoreDownReadIsRestoringInfo;
begin
  RestoreDownReadIsRestoringInfo := TRestoreDownReadIsRestoringInfo.Create( RestorePath, OwnerPcID, RestoreFrom );
  Result := RestoreDownReadIsRestoringInfo.get;
  RestoreDownReadIsRestoringInfo.Free;
end;

class function RestoreDownInfoReadUtil.ReadContinuesList(RestorePath, OwnerPcID,
  RestoreFrom: string): TRestoreDownContinusList;
var
  ShareDownReadContinusList : TRestoreDownReadContinusList;
begin
  ShareDownReadContinusList := TRestoreDownReadContinusList.Create( RestorePath, OwnerPcID, RestoreFrom );
  Result := ShareDownReadContinusList.get;
  ShareDownReadContinusList.Free;
end;

class function RestoreDownInfoReadUtil.ReadDesBusyList: TRestoreKeyItemList;
var
  RestoreDownReadDesBusyList : TRestoreDownReadDesBusyList;
begin
  RestoreDownReadDesBusyList := TRestoreDownReadDesBusyList.Create;
  Result := RestoreDownReadDesBusyList.get;
  RestoreDownReadDesBusyList.Free;
end;

class function RestoreDownInfoReadUtil.ReadLostConnList: TRestoreKeyItemList;
var
  RestoreDownReadLostConnList : TRestoreDownReadLostConnList;
begin
  RestoreDownReadLostConnList := TRestoreDownReadLostConnList.Create;
  Result := RestoreDownReadLostConnList.get;
  RestoreDownReadLostConnList.Free;
end;

class function RestoreDownInfoReadUtil.ReadFileEditionHash(RestorePath,
  OwnerPcID, RestoreFrom: string): TFileEditionHash;
var
  RestoreDownReadFileEditionHash : TRestoreDownReadFileEditionHash;
begin
  RestoreDownReadFileEditionHash := TRestoreDownReadFileEditionHash.Create( RestorePath, OwnerPcID, RestoreFrom );
  Result := RestoreDownReadFileEditionHash.get;
  RestoreDownReadFileEditionHash.Free;
end;

class function RestoreDownInfoReadUtil.ReadIncompletedList: TRestoreKeyItemList;
var
  RestoreDownReadIncompletedList : TRestoreDownReadIncompletedList;
begin
  RestoreDownReadIncompletedList := TRestoreDownReadIncompletedList.Create;
  Result := RestoreDownReadIncompletedList.get;
  RestoreDownReadIncompletedList.Free;
end;

class function RestoreDownInfoReadUtil.ReadIsCompleted(RestorePath, OwnerPcID,
  RestoreFrom: string): Boolean;
var
  RestoreDownReadIsCompletedInfo : TRestoreDownReadIsCompletedInfo;
begin
  RestoreDownReadIsCompletedInfo := TRestoreDownReadIsCompletedInfo.Create( RestorePath, OwnerPcID, RestoreFrom );
  Result := RestoreDownReadIsCompletedInfo.get;
  RestoreDownReadIsCompletedInfo.Free;
end;

class function RestoreDownInfoReadUtil.ReadIsDeleted(RestorePath, OwnerPcID,
  RestoreFrom: string): Boolean;
var
  RestoreDownReadIsDeletedInfo : TRestoreDownReadIsDeleted;
begin
  RestoreDownReadIsDeletedInfo := TRestoreDownReadIsDeleted.Create( RestorePath, OwnerPcID, RestoreFrom );
  Result := RestoreDownReadIsDeletedInfo.get;
  RestoreDownReadIsDeletedInfo.Free;
end;


class function RestoreDownInfoReadUtil.ReadIsEditionNum(RestorePath, OwnerPcID,
  RestoreFrom: string): Integer;
var
  RestoreDownReadEditionNum : TRestoreDownReadEditionNum;
begin
  RestoreDownReadEditionNum := TRestoreDownReadEditionNum.Create( RestorePath, OwnerPcID, RestoreFrom );
  Result := RestoreDownReadEditionNum.get;
  RestoreDownReadEditionNum.Free;
end;

class function RestoreDownInfoReadUtil.ReadIsEnable(RestorePath, OwnerPcID,
  RestoreFrom: string): Boolean;
var
  RestoreDownReadIsEnableInfo : TRestoreDownReadIsEnableInfo;
begin
  RestoreDownReadIsEnableInfo := TRestoreDownReadIsEnableInfo.Create( RestorePath, OwnerPcID, RestoreFrom );
  Result := RestoreDownReadIsEnableInfo.get;
  RestoreDownReadIsEnableInfo.Free;
end;

class function RestoreDownInfoReadUtil.ReadIsEncrypt(RestorePath, OwnerPcID,
  RestoreFrom: string): Boolean;
var
  RestoreDownReadIsEncrypted : TRestoreDownReadIsEncrypted;
begin
  RestoreDownReadIsEncrypted := TRestoreDownReadIsEncrypted.Create( RestorePath, OwnerPcID, RestoreFrom );
  Result := RestoreDownReadIsEncrypted.get;
  RestoreDownReadIsEncrypted.Free;
end;

class function RestoreDownInfoReadUtil.ReadIsFile(RestorePath, OwnerPcID,
  RestoreFrom: string): Boolean;
var
  RestoreDownReadIsFile : TRestoreDownReadIsFile;
begin
  RestoreDownReadIsFile := TRestoreDownReadIsFile.Create( RestorePath, OwnerPcID, RestoreFrom );
  Result := RestoreDownReadIsFile.get;
  RestoreDownReadIsFile.Free;
end;


class function RestoreDownInfoReadUtil.ReadIsLocal(RestorePath, OwnerPcID,
  RestoreFrom: string): Boolean;
var
  RestoreDownReadIsLocal : TRestoreDownReadIsLocal;
begin
  RestoreDownReadIsLocal := TRestoreDownReadIsLocal.Create( RestorePath, OwnerPcID, RestoreFrom );
  Result := RestoreDownReadIsLocal.get;
  RestoreDownReadIsLocal.Free;
end;

class function RestoreDownInfoReadUtil.ReadLocalStartRestore: TRestoreKeyItemList;
var
  RestoreDownReadLocalStartRestore : TRestoreDownReadLocalStartRestore;
begin
  RestoreDownReadLocalStartRestore := TRestoreDownReadLocalStartRestore.Create;
  Result := RestoreDownReadLocalStartRestore.get;
  RestoreDownReadLocalStartRestore.Free;
end;

class function RestoreDownInfoReadUtil.ReadNetworkStartRestore: TRestoreKeyItemList;
var
  RestoreDownReadNetworkStartRestore : TRestoreDownReadNetworkStartRestore;
begin
  RestoreDownReadNetworkStartRestore := TRestoreDownReadNetworkStartRestore.Create;
  Result := RestoreDownReadNetworkStartRestore.get;
  RestoreDownReadNetworkStartRestore.Free;
end;


class function RestoreDownInfoReadUtil.ReadOnlineRestore(
  OnlinePcID: string): TRestoreKeyItemList;
var
  RestoreDownReadOnlineRestore : TRestoreDownReadOnlineRestore;
begin
  RestoreDownReadOnlineRestore := TRestoreDownReadOnlineRestore.Create;
  RestoreDownReadOnlineRestore.SetOnlinePcID( OnlinePcID );
  Result := RestoreDownReadOnlineRestore.get;
  RestoreDownReadOnlineRestore.Free;
end;

class function RestoreDownInfoReadUtil.ReadPassword(RestorePath, OwnerPcID,
  RestoreFrom: string): string;
var
  RestoreDownReadPassword : TRestoreDownReadPassword;
begin
  RestoreDownReadPassword := TRestoreDownReadPassword.Create( RestorePath, OwnerPcID, RestoreFrom );
  Result := RestoreDownReadPassword.get;
  RestoreDownReadPassword.Free;
end;

class function RestoreDownInfoReadUtil.ReadSavePath(RestorePath,
  OwnerPcID, RestoreFrom: string): string;
var
  RestoreDownReadSavePath : TRestoreDownReadSavePath;
begin
  RestoreDownReadSavePath := TRestoreDownReadSavePath.Create( RestorePath, OwnerPcID, RestoreFrom );
  Result := RestoreDownReadSavePath.get;
  RestoreDownReadSavePath.Free;
end;

class function RestoreDownInfoReadUtil.ReadScanInfo(RestorePath, OwnerPcID,
  RestoreFrom: string): TRestoreDownScanInfo;
var
  RestoreDownReadScanInfo : TRestoreDownReadScanInfo;
begin
  RestoreDownReadScanInfo := TRestoreDownReadScanInfo.Create( RestorePath, OwnerPcID, RestoreFrom );
  Result := RestoreDownReadScanInfo.get;
  RestoreDownReadScanInfo.Free;
end;

{ TRestoreDownScanInfo }

procedure TRestoreDownScanInfo.SetEncryptInfo(_IsEncrypted: Boolean;
  _Password: string);
begin
  IsEncrypted := _IsEncrypted;
  Password := _Password;
end;

procedure TRestoreDownScanInfo.SetIsDeleted(_IsDeleted: Boolean);
begin
  IsDeleted := _IsDeleted;
end;

procedure TRestoreDownScanInfo.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

{ TRestoreDownReadScanInfo }

function TRestoreDownReadScanInfo.get: TRestoreDownScanInfo;
begin
  Result := TRestoreDownScanInfo.Create;
  if not FindRestoreDownInfo then
    Exit;
  Result.SetIsFile( RestoreDownInfo.IsFile );
  Result.SetIsDeleted( RestoreDownInfo.IsDeleted );
  Result.SetEncryptInfo( RestoreDownInfo.IsEncrypt, RestoreDownInfo.Password );
end;

{ TRestoreDownSetIsCompletedInfo }

procedure TRestoreDownSetIsCompletedInfo.SetIsCompleted( _IsCompleted : boolean );
begin
  IsCompleted := _IsCompleted;
end;

procedure TRestoreDownSetIsCompletedInfo.Update;
begin
  if not FindRestoreDownInfo then
    Exit;
  RestoreDownInfo.IsCompleted := IsCompleted;
end;



{ TRestoreDownReadIsCompletedInfo }

function TRestoreDownReadIsCompletedInfo.get: Boolean;
begin
  Result := False;
  if not FindRestoreDownInfo then
    Exit;
  Result := RestoreDownInfo.CompletedSize >= RestoreDownInfo.FileSize;
end;

{ TRestoreDownReadLocalStartRestore }

function TRestoreDownReadLocalStartRestore.get: TRestoreKeyItemList;
var
  i: Integer;
  OnlineRestoreInfo : TRestoreKeyItemInfo;
  RestoreDownInfo : TRestoreDownInfo;
begin
  Result := TRestoreKeyItemList.Create;

  for i := 0 to RestoreDownList.Count - 1 do
    if RestoreDownList[i] is TRestoreDownLocalInfo then
    begin
      RestoreDownInfo := RestoreDownList[i];
      if not RestoreDownInfo.IsCompleted then
      begin
        OnlineRestoreInfo := TRestoreKeyItemInfo.Create( RestoreDownInfo.RestorePath, RestoreDownInfo.OwnerPcID, RestoreDownInfo.RestoreFrom );
        Result.Add( OnlineRestoreInfo );
      end;
    end;
end;

{ TRestoreDownSetIsRestoringInfo }

procedure TRestoreDownSetIsRestoringInfo.SetIsRestoring( _IsRestoring : boolean );
begin
  IsRestoring := _IsRestoring;
end;

procedure TRestoreDownSetIsRestoringInfo.Update;
begin
  if not FindRestoreDownInfo then
    Exit;
  RestoreDownInfo.IsRestoring := IsRestoring;
end;



{ TRestoreDownReadIsRestoringInfo }

function TRestoreDownReadIsRestoringInfo.get: Boolean;
begin
  Result := False;
  if not FindRestoreDownInfo then
    Exit;
  Result := RestoreDownInfo.IsRestoring;
end;

{ TShareDownContinusInfo }

constructor TRestoreDownContinusInfo.Create(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TRestoreDownContinusInfo.SetFileInfo(_FileSize : Int64;
  _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

{ TShareDownContinusListAccessInfo }

function TRestoreDownContinusListAccessInfo.FindRestoreDownContinusList : Boolean;
begin
  Result := FindRestoreDownInfo;
  if Result then
    RestoreDownContinusList := RestoreDownInfo.RestoreDownContinusList
  else
    RestoreDownContinusList := nil;
end;

{ TShareDownContinusAccessInfo }

procedure TRestoreDownContinusAccessInfo.SetFilePath( _FilePath : string );
begin
  FilePath := _FilePath;
end;


function TRestoreDownContinusAccessInfo.FindRestoreDownContinusInfo: Boolean;
var
  i : Integer;
begin
  Result := False;
  if not FindRestoreDownContinusList then
    Exit;
  for i := 0 to RestoreDownContinusList.Count - 1 do
    if ( RestoreDownContinusList[i].FilePath = FilePath ) then
    begin
      Result := True;
      RestoreDownContinusIndex := i;
      RestoreDownContinusInfo := RestoreDownContinusList[i];
      break;
    end;
end;

{ TShareDownContinusAddInfo }

procedure TRestoreDownContinusAddInfo.SetFileInfo( _FileSize : int64;
  _FileTime : TDateTime );
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TRestoreDownContinusAddInfo.Update;
begin
  if not FindRestoreDownContinusInfo then
  begin
    if RestoreDownContinusList = nil then
      Exit;
    RestoreDownContinusInfo := TRestoreDownContinusInfo.Create( FilePath );
    RestoreDownContinusInfo.SetFileInfo( FileSize, FileTime );
    RestoreDownContinusList.Add( RestoreDownContinusInfo );
  end;
end;

{ TShareDownContinusRemoveInfo }

procedure TRestoreDownContinusRemoveInfo.Update;
begin
  if not FindRestoreDownContinusInfo then
    Exit;

  RestoreDownContinusList.Delete( RestoreDownContinusIndex );
end;


{ TShareDownReadContinusList }

function TRestoreDownReadContinusList.get: TRestoreDownContinusList;
var
  i : Integer;
  OldContinuesInfo, NewContinuesInfo : TRestoreDownContinusInfo;
begin
  Result := TRestoreDownContinusList.Create;
  if not FindRestoreDownContinusList then
    Exit;

  for i := 0 to RestoreDownContinusList.Count - 1 do
    begin
    OldContinuesInfo := RestoreDownContinusList[i];
    NewContinuesInfo := TRestoreDownContinusInfo.Create( OldContinuesInfo.FilePath );
    NewContinuesInfo.SetFileInfo( OldContinuesInfo.FileSize, OldContinuesInfo.FileTime );
    Result.Add( NewContinuesInfo );
  end;
end;

{ TRestoreDownSetIsDesBusyInfo }

procedure TRestoreDownSetIsDesBusyInfo.SetIsDesBusy(_IsDesBusy: boolean);
begin
  IsDesBusy := _IsDesBusy;
end;

procedure TRestoreDownSetIsDesBusyInfo.Update;
begin
  if not FindRestoreDownInfo then
    Exit;
  RestoreDownInfo.IsDesBusy := IsDesBusy;
end;

{ TRestoreDownReadNetworkStartRestore }

function TRestoreDownReadNetworkStartRestore.get: TRestoreKeyItemList;
var
  i: Integer;
  OnlineRestoreInfo : TRestoreKeyItemInfo;
  RestoreDownInfo : TRestoreDownInfo;
begin
  Result := TRestoreKeyItemList.Create;

  for i := 0 to RestoreDownList.Count - 1 do
    if RestoreDownList[i] is TRestoreDownNetworkInfo then
    begin
      RestoreDownInfo := RestoreDownList[i];
      if not RestoreDownInfo.IsCompleted then
      begin
        OnlineRestoreInfo := TRestoreKeyItemInfo.Create( RestoreDownInfo.RestorePath, RestoreDownInfo.OwnerPcID, RestoreDownInfo.RestoreFrom );
        Result.Add( OnlineRestoreInfo );
      end;
    end;
end;

{ TRestoreDownReadIsDeletedInfo }

function TRestoreDownReadIsDeleted.get: Boolean;
begin
  Result := False;
  if not FindRestoreDownInfo then
    Exit;
  Result := RestoreDownInfo.IsDeleted;
end;

{ TRestoreDownReadDesBusyList }

function TRestoreDownReadDesBusyList.get: TRestoreKeyItemList;
var
  i: Integer;
  OnlineRestoreInfo : TRestoreKeyItemInfo;
  RestoreDownInfo : TRestoreDownInfo;
begin
  Result := TRestoreKeyItemList.Create;

  for i := 0 to RestoreDownList.Count - 1 do
    if RestoreDownList[i] is TRestoreDownNetworkInfo then
    begin
      RestoreDownInfo := RestoreDownList[i];
      if RestoreDownInfo.IsDesBusy then
      begin
        OnlineRestoreInfo := TRestoreKeyItemInfo.Create( RestoreDownInfo.RestorePath, RestoreDownInfo.OwnerPcID, RestoreDownInfo.RestoreFrom );
        Result.Add( OnlineRestoreInfo );
      end;
    end;
end;

{ TRestoreDownReadIsEncrypted }

function TRestoreDownReadIsEncrypted.get: Boolean;
begin
  Result := False;
  if not FindRestoreDownInfo then
    Exit;
  Result := RestoreDownInfo.IsEncrypt;
end;

{ TRestoreDownReadPassword }

function TRestoreDownReadPassword.get: string;
begin
  Result := '';
  if not FindRestoreDownInfo then
    Exit;
  if not RestoreDownInfo.IsEncrypt then
    Exit;
  Result := RestoreDownInfo.Password;
end;

{ TRestoreDownReadIsFile }

function TRestoreDownReadIsFile.get: Boolean;
begin
  Result := False;
  if not FindRestoreDownInfo then
    Exit;
  Result := RestoreDownInfo.IsFile;
end;

{ TBackupSpeedInfo }

constructor TRestoreSpeedInfo.Create;
begin
  IsLimit := False;
end;

{ TBackupSpeedAccessInfo }

constructor TRestoreSpeedAccessInfo.Create;
begin
  RestoreSpeedInfo := MyRestoreDownInfo.RestoreSpeedInfo;
end;

{ TRestoreSpeedLimitInfo }

procedure TRestoreSpeedLimitInfo.SetIsLimit(_IsLimit: Boolean);
begin
  IsLimit := _IsLimit;
end;

procedure TRestoreSpeedLimitInfo.SetLimitInfo(_LimitValue, _LimitType: Integer);
begin
  LimitValue := _LimitValue;
  LimitType := _LimitType;
end;

procedure TRestoreSpeedLimitInfo.Update;
begin
  RestoreSpeedInfo.IsLimit := IsLimit;
  RestoreSpeedInfo.LimitValue := LimitValue;
  RestoreSpeedInfo.LimitType := LimitType;
end;

{ TRestoreDownReadEditionNum }

function TRestoreDownReadEditionNum.get: Integer;
begin
  Result := 0;
  if not FindRestoreDownInfo then
    Exit;
  Result := RestoreDownInfo.EditionNum;
end;

{ TRestoreFileEditionListAccessInfo }

function TRestoreFileEditionListAccessInfo.FindFileEditionList: Boolean;
begin
  Result := FindRestoreDownInfo;
  if Result then
    FileEditionList := RestoreDownInfo.FileEditionList
  else
    FileEditionList := nil;
end;

{ TRestoreFileEditionAddInfo }

procedure TRestoreFileEditionAddInfo.SetEditionNum(_EditionNum: Integer);
begin
  EditionNum := _EditionNum;
end;

procedure TRestoreFileEditionAddInfo.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TRestoreFileEditionAddInfo.Update;
var
  FileEditionInfo : TFileEditionInfo;
begin
  if not FindFileEditionList then
    Exit;
  FileEditionInfo := TFileEditionInfo.Create( FilePath, EditionNum );
  FileEditionList.Add( FileEditionInfo );
end;

{ TRestoreDownReadFileEditionHash }

function TRestoreDownReadFileEditionHash.get: TFileEditionHash;
var
  FileEditionInfo : TFileEditionInfo;
  i: Integer;
  FilePath : string;
begin
  Result := TFileEditionHash.Create;
  if not FindFileEditionList then
    Exit;
  for i := 0 to FileEditionList.Count - 1 do
  begin
    FilePath := FileEditionList[i].FilePath;
    FileEditionInfo := TFileEditionInfo.Create( FilePath, FileEditionList[i].EditionNum );
    Result.AddOrSetValue( FilePath, FileEditionInfo );
  end;
end;

{ TRestoreFileEditionClearInfo }

procedure TRestoreFileEditionClearInfo.Update;
begin
  if not FindFileEditionList then
    Exit;
  FileEditionList.Clear;
end;

{ TRestoreDownSetIsLostConnInfo }

procedure TRestoreDownSetIsLostConnInfo.SetIsLostConn(_IsLostConn: boolean);
begin
  IsLostConn := _IsLostConn;
end;

procedure TRestoreDownSetIsLostConnInfo.Update;
begin
  if not FindRestoreDownInfo then
    Exit;
  RestoreDownInfo.IsLostConn := IsLostConn;
end;

{ TRestoreDownReadLostConnList }

function TRestoreDownReadLostConnList.get: TRestoreKeyItemList;
var
  i: Integer;
  LostConnRestoreInfo : TRestoreKeyItemInfo;
  RestoreDownInfo : TRestoreDownInfo;
begin
  Result := TRestoreKeyItemList.Create;

  for i := 0 to RestoreDownList.Count - 1 do
    if RestoreDownList[i] is TRestoreDownNetworkInfo then
    begin
      RestoreDownInfo := RestoreDownList[i];
      if RestoreDownInfo.IsLostConn then
      begin
        LostConnRestoreInfo := TRestoreKeyItemInfo.Create( RestoreDownInfo.RestorePath, RestoreDownInfo.OwnerPcID, RestoreDownInfo.RestoreFrom );
        Result.Add( LostConnRestoreInfo );
      end;
    end;
end;

{ TRestoreDownReadIncompletedList }

function TRestoreDownReadIncompletedList.get: TRestoreKeyItemList;
var
  i: Integer;
  IncompletedRestoreInfo : TRestoreKeyItemInfo;
  RestoreDownInfo : TRestoreDownInfo;
begin
  Result := TRestoreKeyItemList.Create;

  for i := 0 to RestoreDownList.Count - 1 do
  begin
    RestoreDownInfo := RestoreDownList[i];

      // 不符合条件的过滤
    if RestoreDownInfo.IsDesBusy or RestoreDownInfo.IsLostConn or
       RestoreDownInfo.IsRestoring or RestoreDownInfo.IsCompleted
    then
      Continue;

    IncompletedRestoreInfo := TRestoreKeyItemInfo.Create( RestoreDownInfo.RestorePath, RestoreDownInfo.OwnerPcID, RestoreDownInfo.RestoreFrom );
    Result.Add( IncompletedRestoreInfo );
  end;
end;

{ TRestoreDownReadIsLocal }

function TRestoreDownReadIsLocal.get: Boolean;
begin
  Result := False;
  if not FindRestoreDownInfo then
    Exit;
  Result := RestoreDownInfo is TRestoreDownLocalInfo;
end;

{ TRestoreExplorerHistoryInfo }

constructor TRestoreExplorerHistoryInfo.Create(_FilePath, _OwnerPcID,
  _RestoreFrom: string);
begin
  FilePath := _FilePath;
  OwnerPcID := _OwnerPcID;
  RestoreFrom := _RestoreFrom;
end;

{ TRestoreExplorerHistoryListAccessInfo }

constructor TRestoreExplorerHistoryListAccessInfo.Create;
begin
  MyRestoreDownInfo.EnterData;
  RestoreExplorerHistoryList := MyRestoreDownInfo.RestoreExplorerHistoryList;
end;

destructor TRestoreExplorerHistoryListAccessInfo.Destroy;
begin
  MyRestoreDownInfo.LeaveData;
  inherited;
end;

{ TRestoreExplorerHistoryAccessInfo }

constructor TRestoreExplorerHistoryAccessInfo.Create( _FilePath, _OwnerPcID, _RestoreFrom : string );
begin
  inherited Create;
  FilePath := _FilePath;
  OwnerPcID := _OwnerPcID;
  RestoreFrom := _RestoreFrom;
end;

function TRestoreExplorerHistoryAccessInfo.FindRestoreExplorerHistoryInfo: Boolean;
var
  i : Integer;
begin
  Result := False;
  for i := 0 to RestoreExplorerHistoryList.Count - 1 do
    if ( RestoreExplorerHistoryList[i].FilePath = FilePath ) and ( RestoreExplorerHistoryList[i].OwnerPcID = OwnerPcID ) and ( RestoreExplorerHistoryList[i].RestoreFrom = RestoreFrom ) then
    begin
      Result := True;
      RestoreExplorerHistoryIndex := i;
      RestoreExplorerHistoryInfo := RestoreExplorerHistoryList[i];
      break;
    end;
end;

{ TRestoreExplorerHistoryAddInfo }

procedure TRestoreExplorerHistoryAddInfo.Update;
begin
  if FindRestoreExplorerHistoryInfo then
    Exit;

  RestoreExplorerHistoryInfo := TRestoreExplorerHistoryInfo.Create( FilePath, OwnerPcID, RestoreFrom );
  RestoreExplorerHistoryList.Insert( 0, RestoreExplorerHistoryInfo );
end;

{ TRestoreExplorerHistoryRemoveInfo }

constructor TRestoreExplorerHistoryRemoveInfo.Create(_RemoveIndex: Integer);
begin
  RemoveIndex := _RemoveIndex;
end;

procedure TRestoreExplorerHistoryRemoveInfo.Update;
begin
  if RestoreExplorerHistoryList.Count <= RemoveIndex then
    Exit;

  RestoreExplorerHistoryList.Delete( RemoveIndex );
end;

{ TShareExplorerHistoryReadExistIndex }

function TShareExplorerHistoryReadExistIndex.get: Integer;
var
  i : Integer;
begin
  Result := -1;
  for i := 0 to RestoreExplorerHistoryList.Count - 1 do
    if ( RestoreExplorerHistoryList[i].FilePath = FilePath ) and
       ( RestoreExplorerHistoryList[i].OwnerPcID = OwnerID ) and
       ( RestoreExplorerHistoryList[i].RestoreFrom = RestoreFrom )
    then
    begin
      Result := i;
      Break;
    end;
end;

procedure TShareExplorerHistoryReadExistIndex.SetExplorerInfo(_FilePath, _OwnerID, _RestoreFrom : string);
begin
  FilePath := _FilePath;
  OwnerID := _OwnerID;
  RestoreFrom := _RestoreFrom;
end;

{ TShareExplorerHistoryReadCount }

function TShareExplorerHistoryReadCount.get: Integer;
begin
  Result := RestoreExplorerHistoryList.Count;
end;

{ TShareExplorerHistoryReadList }

function TShareExplorerHistoryReadList.get: TRestoreExplorerHistoryInfo;
var
  OwnerID, FilePath, RestoreFrom : string;
begin
  if RestoreExplorerHistoryList.Count > HistoryIndex then
  begin
    FilePath := RestoreExplorerHistoryList[ HistoryIndex ].FilePath;
    OwnerID := RestoreExplorerHistoryList[ HistoryIndex ].OwnerPcID;
    RestoreFrom := RestoreExplorerHistoryList[ HistoryIndex ].RestoreFrom;
  end;

  Result := TRestoreExplorerHistoryInfo.Create( FilePath, OwnerID, RestoreFrom );
end;

procedure TShareExplorerHistoryReadList.SetHistoryIndex(_HistoryIndex: Integer);
begin
  HistoryIndex := _HistoryIndex;
end;

{ ShareExplorerHistoryInfoReadUtil }

class function ShareExplorerHistoryInfoReadUtil.ReadExistIndex(
   FilePath, OwnerID, RestoreFrom : string ): Integer;
var
  ShareExplorerHistoryReadExistIndex : TShareExplorerHistoryReadExistIndex;
begin
  ShareExplorerHistoryReadExistIndex := TShareExplorerHistoryReadExistIndex.Create;
  ShareExplorerHistoryReadExistIndex.SetExplorerInfo( FilePath, OwnerID, RestoreFrom );
  Result := ShareExplorerHistoryReadExistIndex.get;
  ShareExplorerHistoryReadExistIndex.Free;
end;

class function ShareExplorerHistoryInfoReadUtil.ReadHistoryCount: Integer;
var
  ShareExplorerHistoryReadCount : TShareExplorerHistoryReadCount;
begin
  ShareExplorerHistoryReadCount := TShareExplorerHistoryReadCount.Create;
  Result := ShareExplorerHistoryReadCount.get;
  ShareExplorerHistoryReadCount.Free;
end;

class function ShareExplorerHistoryInfoReadUtil.ReadHistoryInfo(
  HistoryIndex: Integer): TRestoreExplorerHistoryInfo;
var
  ShareExplorerHistoryReadList : TShareExplorerHistoryReadList;
begin
  ShareExplorerHistoryReadList := TShareExplorerHistoryReadList.Create;
  ShareExplorerHistoryReadList.SetHistoryIndex( HistoryIndex );
  Result := ShareExplorerHistoryReadList.get;
  ShareExplorerHistoryReadList.Free;
end;


end.
