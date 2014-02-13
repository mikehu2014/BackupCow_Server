unit UMyBackupDataInfo;

interface

uses UFileBaseInfo, Generics.Collections, UDataSetInfo, UMyUtil, DateUtils, classes, SysUtils;

type

{$Region ' ���ݽṹ ' }

    // ������Ϣ
  TBackupContinusInfo = class
  public
    FilePath : string;
    FileSize : Int64;
    FileTime : TDateTime;
  public
    constructor Create( _FilePath : string );
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
  end;
  TBackupContinusList = class( TObjectList< TBackupContinusInfo > )end;

      // ��־��Ϣ
  TBackupLogInfo = class
  public
    FilePath : string;
  public
    constructor Create( _FilePath : string );
  end;

    // �������־
  TBackupCompletedLog = class( TBackupLogInfo )
  public
    BackupTime : TDateTime;
  public
    procedure SetBackupTime( _BackupTime : TDateTime );
  end;
  TBackupCompletedLogList = class( TObjectList< TBackupCompletedLog > )end;

    // δ�����־
  TBackupIncompletedLog = class( TBackupLogInfo )
  public
    ErrorStr : string;
  public
    procedure SetErrorStr( _ErrorStr : string );
  end;
  TBackupIncompletedLogList  = class( TObjectList< TBackupIncompletedLog > )end;


    // ���� Item ��Ϣ
  TBackupItemInfo = class
  public  // ·����Ϣ
    BackupPath : string;
    IsFile, IsCompleted : Boolean;
  public  // �Զ�ͬ��
    IsBackupNow, IsAutoSync : Boolean; // �Ƿ��Զ�ͬ��
    SyncTimeType, SyncTimeValue : Integer; // ͬ�����
    LasSyncTime, NextSyncTime : TDateTime;  // ��һ��ͬ��ʱ��
    IsBackuping : Boolean; // �Ƿ�����ͬ��
    IsDesBusy, IsLostConn : Boolean; // �Ƿ�Ŀ�귱æ���Ƿ�ͻȻ�Ͽ�����
  public  // ��������
    IsEncrypt : Boolean;
    Password, PasswordHint : string;
  public  // ����ɾ���ļ�����
    IsKeepDeleted : Boolean;
    KeepEditionCount : Integer;
  public  // �ռ���Ϣ
    FileCount : Integer;
    ItemSize, CompletedSize : Int64; // �ռ���Ϣ
  public  // ������
    IncludeFilterList : TFileFilterList;  // �����ļ� ������
    ExcludeFilterList : TFileFilterList;  // �ų��ļ� ������
  public  // ������Ϣ
    BackupContinusList : TBackupContinusList;
  public  // ��־��Ϣ
    BackupCompletedLogList : TBackupCompletedLogList;
    BackupIncompletedLogList : TBackupIncompletedLogList;
  public
    constructor Create( _BackupPath : string );
    procedure SetIsFile( _IsFile : Boolean );
    procedure SetIsCompleted( _IsCompleted : Boolean );
    procedure SetIsBackupNow( _IsBackupNow : Boolean );
    procedure SetAutoSyncInfo( _IsAutoSync : Boolean; _LasSyncTime : TDateTime );
    procedure SetSyncTimeInfo( _SyncTimeType, _SyncTimeValue : Integer );
    procedure SetEncryptInfo( _IsEncrypt : Boolean; _Password, _PasswordHint : string );
    procedure SetDeletedInfo( _IsKeepDeleted : Boolean; _KeepEditionCount : Integer );
    procedure SetSpaceInfo( _FileCount : Integer; _ItemSize, _CompletedSize : Int64 );
    destructor Destroy; override;
  end;
  TBackupItemList = class( TObjectList<TBackupItemInfo> )end;

    // Ŀ�� Item
  TDesItemInfo = class
  public
    DesItemID : string;
    BackupItemList : TBackupItemList;
  public
    constructor Create( _DesItemID : string );
    destructor Destroy; override;
  end;
  TDesItemList = class( TObjectList<TDesItemInfo> )end;

    // ����Ŀ�� Item
  TLocalDesItemInfo = class( TDesItemInfo )
  end;

    // ����Ŀ�� Item
  TNetworkDesItemInfo = class( TDesItemInfo )
  end;

    // �����ٶ���Ϣ
  TBackupSpeedInfo = class
  public
    IsLimit : Boolean;
    LimitValue : Integer;
    LimitType : Integer;
  public
    constructor Create;
  end;

    // ������Ϣ
  TMyBackupInfo = class( TMyDataInfo )
  public
    DesItemList : TDesItemList;
    BackupSpeedInfo : TBackupSpeedInfo;
  public
    constructor Create;
    destructor Destroy; override;
  end;

{$EndRegion}

{$Region ' ���ݽӿ� ' }

    // ���� ���� List �ӿ�
  TDesItemListAccessInfo = class
  protected
    DesItemList : TDesItemList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // ���� ���ݽӿ�
  TDesItemAccessInfo = class( TDesItemListAccessInfo )
  public
    DesItemID : string;
  protected
    DesItemIndex : Integer;
    DesItemInfo : TDesItemInfo;
  public
    constructor Create( _DesItemID : string );
  protected
    function FindDesItemInfo: Boolean;
  end;

    // ���� ���� List �ӿ�
  TBackupItemListAccessInfo = class( TDesItemAccessInfo )
  protected
    BackupItemList : TBackupItemList;
  protected
    function FindBackupItemList : Boolean;
  end;

    // ���� ���ݽӿ�
  TBackupItemAccessInfo = class( TBackupItemListAccessInfo )
  public
    BackupPath : string;
  protected
    BackupItemIndex : Integer;
    BackupItemInfo : TBackupItemInfo;
  public
    procedure SetBackupPath( _BackupPath : string );
  protected
    function FindBackupItemInfo: Boolean;
  end;

    // ���� ���� List �ӿ�
  TBackupContinusListAccessInfo = class( TBackupItemAccessInfo )
  protected
    BackupContinusList : TBackupContinusList;
  protected
    function FindBackupContinusList : Boolean;
  end;

    // ���� ���ݽӿ�
  TBackupContinusAccessInfo = class( TBackupContinusListAccessInfo )
  public
    FilePath : string;
  protected
    BackupContinusIndex : Integer;
    BackupContinusInfo : TBackupContinusInfo;
  public
    procedure SetFilePath( _FilePath : string );
  protected
    function FindBackupContinusInfo: Boolean;
  end;

    // ��ȡ����
  TBackupContinusReadInfo = class( TBackupContinusAccessInfo )
  end;


    // �����ٶ� ���ݽӿ�
  TBackupSpeedAccessInfo = class
  public
    BackupSpeedInfo : TBackupSpeedInfo;
  public
    constructor Create;
  end;

{$EndRegion}

{$Region ' Ŀ����Ϣ �����޸� ' }

  TDesItemAddInfo = class( TDesItemAccessInfo )
  public
    procedure Update;
  protected
    procedure CreateDesItem;virtual;abstract;
  end;

    // ��� ����Ŀ��
  TDesItemAddLocalInfo = class( TDesItemAddInfo )
  protected
    procedure CreateDesItem;override;
  end;

    // ��� ����Ŀ��
  TDesItemAddNetworkInfo = class( TDesItemAddInfo )
  protected
    procedure CreateDesItem;override;
  end;


    // ɾ��
  TDesItemRemoveInfo = class( TDesItemAccessInfo )
  public
    procedure Update;
  end;

{$EndRegion}

{$Region ' ������Ϣ �����޸� ' }

    // �޸ĸ���
  TBackupItemWriteInfo = class( TBackupItemAccessInfo )
  protected
    procedure RefreshNextSyncTime;
  end;

  {$Region ' ·����ɾ ' }

    // ���
  TBackupItemAddInfo = class( TBackupItemWriteInfo )
  public
    IsFile, IsCompleted : boolean;
  public
    IsBackupNow : boolean;
    IsAutoSync : boolean;
    LastSyncTime : TDateTime;
  public
    SyncTimeType, SyncTimeValue : integer;
  public
    IsEncrypt : boolean;
    Password, PasswordHint : string;
  public
    IsKeepDeleted : boolean;
    KeepEditionCount : integer;
  public
    FileCount : integer;
    ItemSize, CompletedSize : int64;
  public
    procedure SetIsFile( _IsFile : boolean );
    procedure SetIsCompleted( _IsCompleted : boolean );
    procedure SetIsBackupNow( _IsBackupNow : boolean );
    procedure SetAutoSyncInfo( _IsAutoSync : boolean; _LastSyncTime : TDateTime );
    procedure SetSyncTimeInfo( _SyncTimeType, _SyncTimeValue : integer );
    procedure SetEncryptInfo( _IsEncrypt : boolean; _Password, _PasswordHint : string );
    procedure SetDeletedInfo( _IsKeepDeleted : boolean; _KeepEditionCount : integer );
    procedure SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSize : int64 );
    procedure Update;
  end;

    // ɾ��
  TBackupItemRemoveInfo = class( TBackupItemAccessInfo )
  public
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' �޸�״̬ ' }

      // �޸�
  TBackupItemSetIsCompletedInfo = class( TBackupItemWriteInfo )
  public
    IsCompleted : boolean;
  public
    procedure SetIsCompleted( _IsCompleted : boolean );
    procedure Update;
  end;

        // �޸�
  TBackupItemSetIsDesBusyInfo = class( TBackupItemWriteInfo )
  public
    IsDesBusy : boolean;
  public
    procedure SetIsDesBusy( _IsDesBusy : boolean );
    procedure Update;
  end;

        // �޸�
  TBackupItemSetIsLostConnInfo = class( TBackupItemWriteInfo )
  public
    IsLostConn : boolean;
  public
    procedure SetIsLostConn( _IsLostConn : boolean );
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' �޸�ͬ�� ' }

      // �Ƿ� Backup Now ����
  TBackupItemSetIsBackupNowInfo = class( TBackupItemAccessInfo )
  public
    IsBackupNow : Boolean;
  public
    procedure SetIsBackupNow( _IsBackupNow : Boolean );
    procedure Update;
  end;


    // ���� ��һ�� ͬ��ʱ��
  TBackupItemSetLastSyncTimeInfo = class( TBackupItemWriteInfo )
  public
    LastSyncTime : TDateTime;
  public
    procedure SetLastSyncTime( _LastSyncTime : TDateTime );
    procedure Update;
  end;


    // ���� ͬ������
  TBackupItemSetAutoSyncInfo = class( TBackupItemWriteInfo )
  private
    IsAutoSync : Boolean;
    SyncTimeValue, SyncTimeType : Integer;
  public
    procedure SetIsAutoSync( _IsAutoSync : Boolean );
    procedure SetSyncInterval( _SyncTimeType, _SyncTimeValue : Integer );
    procedure Update;
  end;

      // �޸�
  TBackupItemSetIsBackupingInfo = class( TBackupItemWriteInfo )
  public
    IsBackuping : boolean;
  public
    procedure SetIsBackuping( _IsBackuping : boolean );
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' �޸ļ��� ' }

      // �޸�
  TBackupItemSetEncryptInfoInfo = class( TBackupItemWriteInfo )
  public
    IsEncrypt : boolean;
    Password, PasswordHint : string;
  public
    procedure SetEncryptInfo( _IsEncrypt : boolean; _Password, _PasswordHint : string );
    procedure Update;
  end;




  {$EndRegion}

  {$Region ' �޸Ļ��� ' }

  TBackupItemSetRecycleInfo = class( TBackupItemAccessInfo )
  public
    IsKeepDeleted : Boolean;
    KeepEditionCount : Integer;
  public
    procedure SetDeleteInfo( _IsKeepDeleted : Boolean; _KeepEditionCount : Integer );
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' �޸Ŀռ� ' }

    // ���� �ռ���Ϣ
  TBackupItemSetSpaceInfoInfo = class( TBackupItemAccessInfo )
  public
    FileCount : integer;
    ItemSize, CompletedSize : int64;
  public
    procedure SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSize : int64 );
    procedure Update;
  end;


    // ��� �������Ϣ
  TBackupItemSetAddCompletedSpaceInfo = class( TBackupItemAccessInfo )
  public
    AddCompletedSpace : int64;
  public
    procedure SetAddCompletedSpace( _AddCompletedSpace : int64 );
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' ������Ϣ ' }

    // ��� ����
  TBackupItemFilterAddInfo = class( TBackupItemAccessInfo )
  public
    FilterType, FilterValue : string;
  public
    procedure SetFilterInfo( _FilterType, _FilterValue : string );
  end;

    // ���
  TBackupItemIncludeFilterClearInfo = class( TBackupItemAccessInfo )
  public
    procedure Update;
  end;

    // ���
  TBackupItemIncludeFilterAddInfo = class( TBackupItemFilterAddInfo )
  public
    procedure Update;
  end;

    // ���
  TBackupItemExcludeFilterClearInfo = class( TBackupItemAccessInfo )
  public
    procedure Update;
  end;

    // ���
  TBackupItemExcludeFilterAddInfo = class( TBackupItemFilterAddInfo )
  public
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' ������Ϣ ' }

      // �޸ĸ���
  TBackupContinusWriteInfo = class( TBackupContinusAccessInfo )
  end;

      // ���
  TBackupContinusAddInfo = class( TBackupContinusWriteInfo )
  public
    FileTime : TDateTime;
    FileSize : int64;
  public
    procedure SetFileInfo( _FileSize : int64; _FileTime : TDateTime );
    procedure Update;
  end;

    // ɾ��
  TBackupContinusRemoveInfo = class( TBackupContinusWriteInfo )
  public
    procedure Update;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' �ٶ���Ϣ �����޸� ' }

    // �ٶ�����
  TBackupSpeedLimitInfo = class( TBackupSpeedAccessInfo )
  public
    IsLimit : Boolean;
    LimitValue, LimitType : Integer;
  public
    procedure SetIsLimit( _IsLimit : Boolean );
    procedure SetLimitInfo( _LimitValue, _LimitType : Integer );
    procedure Update;
  end;

{$EndRegion}

{$Region ' Ŀ����Ϣ ���ݶ�ȡ ' }

    // �ָ���Ϣ
  TRestoreSourceInfo = class
  public
    DesItemID, SourcePath : string;
    IsFile : Boolean;
  public
    FileCount : Integer;
    ItemSpace : Int64;
    LastSyncTime : TDateTime;
  public
    IsSaveDeleted : Boolean;
    IsEncrypted : Boolean;
    Password, PasswordHint : string;
  public
    constructor Create( _DesItemID, _SourcePath : string );
    procedure SetIsFile( _IsFile : Boolean );
    procedure SetSpaceInfo( _FileCount : Integer; _ItemSpace : Int64 );
    procedure SetLastSyncTime( _LastSyncTime : TDateTime );
    procedure SetIsSaveDeleted( _IsSaveDeleted : Boolean );
    procedure SetEncryptInfo( _IsEncrypted : Boolean; _Password, _PasswordHint : string );
  end;
  TRestoreSourceList = class( TObjectList<TRestoreSourceInfo> )end;


    // ��ȡ �����ܿռ���Ϣ
  TDesItemListReadTotalSpace = class( TDesItemListAccessInfo )
  public
    function get : Int64;
  end;

    // ��ȡ ��������ɿռ���Ϣ
  TDesItemListReadTotalCompletedSpace = class( TDesItemListAccessInfo )
  public
    function get : Int64;
  end;

    // ��ȡ �Ƿ���ڱ��ر���
  TDesItemListReadIsExistLocalBackup = class( TDesItemListAccessInfo )
  public
    function get : Boolean;
  end;


    // ��ȡ ����Ŀ���б�
  TDesItemListReadLocalList = class( TDesItemListAccessInfo )
  public
    function get : TStringList;
  end;

    // ��ȡ ����Ŀ���б�
  TDesItemListReadNetworkList = class( TDesItemListAccessInfo )
  public
    function get : TStringList;
  end;

    // ��ȡ ���ػָ��б�
  TDesItemListReadLocalRestoreList = class( TDesItemListAccessInfo )
  public
    function get : TRestoreSourceList;
  end;

    // ��ȡ ���б���·��
  TDesItemReadBackupList = class( TBackupItemListAccessInfo )
  public
    function get : TStringList;
  end;

    // ��ȡ ���б���·��
  TDesItemReadOnTimeBackupList = class( TBackupItemListAccessInfo )
  public
    function get : TStringList;
  end;

    // ��ȡ ���б���·��
  TDesItemReadLostConnBackupList = class( TBackupItemListAccessInfo )
  public
    function get : TStringList;
  end;

    // ��ȡ δ��ɵı���·��
  TDesItemReadIncompletedBackupList = class( TBackupItemListAccessInfo )
  public
    function get : TStringList;
  end;

    // ��ȡ ���б���·��
  TDesItemReadBackupAllList = class( TBackupItemListAccessInfo )
  public
    function get : TStringList;
  end;

    // �Ƿ񱾵�Ŀ��
  TDesItemReadIsLocalDes = class( TDesItemAccessInfo )
  public
    function get : Boolean;
  end;

    // ��ȡ ���� Item ��Ŀ
  TDesItemListReadLocalItemCount = class( TDesItemListAccessInfo )
  public
    function get : Integer;
  end;

    // ��ȡ ���� Item ��Ŀ
  TDesItemListReadNetworkItemCount = class( TDesItemListAccessInfo )
  public
    function get : Integer;
  end;

      // Ŀ����Ϣ ��ȡ
  DesItemInfoReadUtil = class
  public
    class function ReadTotalSpace : Int64;
    class function ReadTotalCompletedSpace : Int64;
    class function ReadLocaDesList : TStringList;
    class function ReadNetworkDesList : TStringList;
    class function ReadLocalRestoreList : TRestoreSourceList;
    class function ReadIsExistLocalBackup : Boolean;
  public
    class function ReadIsLocalDes( DesItemID : string ): Boolean;
    class function ReadBackupList( DesItemID : string ): TStringList;  // ��ȡ ���б���·��
    class function ReadBackupAllList( DesItemID : string ): TStringList; // ��ȡ Backup All ·��
    class function ReadOnTimeBackupList( DesItemID : string ): TStringList;  // ��ȡ ��ʱ�Զ�����·��
    class function ReadLostConnBackupList( DesItemID : string ): TStringList;  // ��ȡ ��ʱ�Զ�����·��
    class function ReadIncompletedList( DesItemID : string ): TStringList; // ��ȡδ��ɵı���·��
  public
    class function ReadLocalItemCount : Integer;
    class function ReadNetworkItemCount : Integer;
  end;

{$EndRegion}

{$Region ' ������Ϣ ���ݶ�ȡ ' }

    // ��ȡ �Ƿ񱸷���Ч
  TDesItemReadExistBackup = class( TDesItemAccessInfo )
  public
    function get : Boolean;
  end;

    // ��ȡ �Ƿ񱸷���Ч
  TBackupItemReadIsEnable = class( TBackupItemAccessInfo )
  public
    function get : Boolean;
  end;

    // ��ȡ �Ƿ��Ѿ����
  TBackupItemReadIsCompleted = class( TBackupItemAccessInfo )
  public
    function get : Boolean;
  end;

    // ��ȡ ����ɾ���ļ��汾��
  TBackupItemReadIsBackuping = class( TBackupItemAccessInfo )
  public
    function get : Boolean;
  end;

    // ��ȡ ����ɾ���ļ��汾��
  TBackupItemReadIsLostConn = class( TBackupItemAccessInfo )
  public
    function get : Boolean;
  end;

        // ��ȡ �Ƿ񱣴�ɾ���ļ�
  TBackupItemReadIsFile = class( TBackupItemAccessInfo )
  public
    function get : Boolean;
  end;

      // ��ȡ �Ƿ񱣴�ɾ���ļ�
  TBackupItemReadIsKeepDeleted = class( TBackupItemAccessInfo )
  public
    function get : Boolean;
  end;

    // ��ȡ ����ɾ���ļ��汾��
  TBackupItemReadKeepDeletedCount = class( TBackupItemAccessInfo )
  public
    function get : Integer;
  end;

    // ��ȡ �Ƿ����
  TBackupItemReadIsEncrypted = class( TBackupItemAccessInfo )
  public
    function get : Boolean;
  end;

    // ��ȡ ��������
  TBackupItemReadPassword = class( TBackupItemAccessInfo )
  public
    function get : string;
  end;


    // ��ȡ ����������
  TBackupItemReadIncludeFilter = class( TBackupItemAccessInfo )
  public
    function get : TFileFilterList;
  end;

    // ��ȡ �ų�������
  TBackupItemReadExcludeFilter = class( TBackupItemAccessInfo )
  public
    function get : TFileFilterList;
  end;

    // ��ȡ������Ϣ
  TBackupItemReadConfigInfo = class( TBackupItemAccessInfo )
  public
    function get : TBackupConfigInfo;
  end;

      // ��ȡ �ָ���Ϣ
  TBackupItemReadRestoreSourceInfo = class( TBackupItemAccessInfo )
  public
    function get : TRestoreSourceInfo;
  end;

    // ��ȡ ������Ϣ
  TBackupItemReadContinusList = class( TBackupItemAccessInfo )
  public
    function get : TBackupContinusList;
  end;

    // ����Item��Ϣ
  TBackupKeyItemInfo = class
  public
    DesItem, BackupPath : string;
  public
    constructor Create( _DesItem, _BackupPath : string );
  end;
  TBackupKeyItemList = class( TObjectList< TBackupKeyItemInfo > )end;

    // ��ȡ ����δ��ɱ���
  TBackupItemReadLocalIncompleteList = class( TDesItemListAccessInfo )
  public
    function get : TBackupKeyItemList;
  end;

   // ��ȡ ����δ��ɱ���
  TBackupItemReadNetworkIncompleteList = class( TDesItemListAccessInfo )
  public
    function get : TBackupKeyItemList;
  end;

    // ��ȡ Pcδ��ɱ���
  TBackupItemReadPcOnlineInfo = class( TDesItemListAccessInfo )
  public
    OnlinePcID : string;
  public
    procedure SetOnlinePcID( _OnlinePcID : string );
    function get : TBackupKeyItemList;
  end;

    // ��æ�ı�����Ϣ
  TBackupItemReadDesBusyList = class( TDesItemListAccessInfo )
  public
    function get : TBackupKeyItemList;
  end;


    // ������Ϣ ��ȡ
  BackupItemInfoReadUtil = class
  public
    class function ReadIsEnable( DesItemID, BackupPath : string ): Boolean;
    class function ReadIsCompleted( DesItemID, BackupPath : string ): Boolean;
    class function ReadIsBackuping( DesItemID, BackupPath : string ): Boolean;
    class function ReadIsLostConnect( DesItemID, BackupPath : string ): Boolean;
    class function ReadExistBackup( DesItemID : string ): Boolean;
  public
    class function ReadIsFile( DesItemID, BackupPath : string ): Boolean;
    class function ReadIsKeepDeleted( DesItemID, BackupPath : string ): Boolean;
    class function ReadIsKeepEditionCount( DesItemID, BackupPath : string ): Integer;
    class function ReadIsEncrypted( DesItemID, BackupPath : string ): Boolean;
    class function ReadPassword( DesItemID, BackupPath : string ): string;
  public
    class function ReadLocalIncompletedList : TBackupKeyItemList;
    class function ReadNetworkIncompletedList : TBackupKeyItemList;
    class function ReadPcOnline( OnlinePcID : string ) : TBackupKeyItemList;
    class function ReadDesBusyList : TBackupKeyItemList;
  public
    class function ReadIncludeFilter( DesItemID, BackupPath : string ): TFileFilterList;
    class function ReadExcludeFilter( DesItemID, BackupPath : string ): TFileFilterList;
  public
    class function ReadConfigInfo( DesItemID, BackupPath : string ): TBackupConfigInfo;
    class function ReadRestoreSourceInfo( DesItemID, BackupPath : string ): TRestoreSourceInfo;
  public
    class function ReadContinuesList( DesItemID, BackupPath : string ): TBackupContinusList;
  end;


{$EndRegion}

var
  MyBackupInfo : TMyBackupInfo;

implementation

{ TMyBackupInfo }

constructor TMyBackupInfo.Create;
begin
  inherited;
  DesItemList := TDesItemList.Create;
  BackupSpeedInfo := TBackupSpeedInfo.Create;
end;

destructor TMyBackupInfo.Destroy;
begin
  BackupSpeedInfo.Free;
  DesItemList.Free;
  inherited;
end;

{ TBackupItemInfo }

constructor TBackupItemInfo.Create(_BackupPath: string);
begin
  BackupPath := _BackupPath;
  IncludeFilterList := TFileFilterList.Create;
  ExcludeFilterList := TFileFilterList.Create;
  BackupContinusList := TBackupContinusList.Create;
  BackupCompletedLogList := TBackupCompletedLogList.Create;
  BackupIncompletedLogList := TBackupIncompletedLogList.Create;
end;

destructor TBackupItemInfo.Destroy;
begin
  BackupIncompletedLogList.Free;
  BackupCompletedLogList.Free;
  BackupContinusList.Free;
  ExcludeFilterList.Free;
  IncludeFilterList.Free;
  inherited;
end;

procedure TBackupItemInfo.SetAutoSyncInfo(_IsAutoSync: Boolean;
  _LasSyncTime: TDateTime);
begin
  IsAutoSync := _IsAutoSync;
  LasSyncTime := _LasSyncTime;
end;

procedure TBackupItemInfo.SetIsBackupNow(_IsBackupNow: Boolean);
begin
  IsBackupNow := _IsBackupNow;
end;

procedure TBackupItemInfo.SetIsCompleted(_IsCompleted: Boolean);
begin
  IsCompleted := _IsCompleted;
end;

procedure TBackupItemInfo.SetDeletedInfo(_IsKeepDeleted: Boolean;
  _KeepEditionCount: Integer);
begin
  IsKeepDeleted := _IsKeepDeleted;
  KeepEditionCount := _KeepEditionCount;
end;

procedure TBackupItemInfo.SetEncryptInfo(_IsEncrypt: Boolean; _Password,
  _PasswordHint: string);
begin
  IsEncrypt := _IsEncrypt;
  Password := _Password;
  PasswordHint := _PasswordHint;
end;

procedure TBackupItemInfo.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TBackupItemInfo.SetSpaceInfo(_FileCount : Integer;
  _ItemSize, _CompletedSize: Int64);
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TBackupItemInfo.SetSyncTimeInfo(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;


{ TLocalDesRestoreInfo }

constructor TRestoreSourceInfo.Create(_DesItemID, _SourcePath: string);
begin
  DesItemID := _DesItemID;
  SourcePath := _SourcePath;
end;

procedure TRestoreSourceInfo.SetEncryptInfo(_IsEncrypted: Boolean; _Password,
  _PasswordHint: string);
begin
  IsEncrypted := _IsEncrypted;
  Password := _Password;
  PasswordHint := _PasswordHint;
end;

procedure TRestoreSourceInfo.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TRestoreSourceInfo.SetIsSaveDeleted(_IsSaveDeleted: Boolean);
begin
  IsSaveDeleted := _IsSaveDeleted;
end;

procedure TRestoreSourceInfo.SetLastSyncTime(_LastSyncTime: TDateTime);
begin
  LastSyncTime := _LastSyncTime;
end;

procedure TRestoreSourceInfo.SetSpaceInfo(_FileCount: Integer;
  _ItemSpace: Int64);
begin
  FileCount := _FileCount;
  ItemSpace := _ItemSpace;
end;

{ TDesItemInfo }

constructor TDesItemInfo.Create(_DesItemID: string);
begin
  DesItemID := _DesItemID;
  BackupItemList := TBackupItemList.Create;
end;

destructor TDesItemInfo.Destroy;
begin
  BackupItemList.Free;
  inherited;
end;

{ TDesItemListAccessInfo }

constructor TDesItemListAccessInfo.Create;
begin
  MyBackupInfo.EnterData;
  DesItemList := MyBackupInfo.DesItemList;
end;

destructor TDesItemListAccessInfo.Destroy;
begin
  MyBackupInfo.LeaveData;
  inherited;
end;

{ TDesItemAccessInfo }

constructor TDesItemAccessInfo.Create( _DesItemID : string );
begin
  inherited Create;
  DesItemID := _DesItemID;
end;

function TDesItemAccessInfo.FindDesItemInfo: Boolean;
var
  i : Integer;
begin
  Result := False;
  for i := 0 to DesItemList.Count - 1 do
    if ( DesItemList[i].DesItemID = DesItemID ) then
    begin
      Result := True;
      DesItemIndex := i;
      DesItemInfo := DesItemList[i];
      break;
    end;
end;

{ TDesItemRemoveInfo }

procedure TDesItemRemoveInfo.Update;
begin
  if not FindDesItemInfo then
    Exit;

  DesItemList.Delete( DesItemIndex );
end;

{ TBackupItemListAccessInfo }

function TBackupItemListAccessInfo.FindBackupItemList : Boolean;
begin
  Result := FindDesItemInfo;
  if Result then
    BackupItemList := DesItemInfo.BackupItemList
  else
    BackupItemList := nil;
end;

{ TBackupItemAccessInfo }

procedure TBackupItemAccessInfo.SetBackupPath( _BackupPath : string );
begin
  BackupPath := _BackupPath;
end;


function TBackupItemAccessInfo.FindBackupItemInfo: Boolean;
var
  i : Integer;
begin
  Result := False;
  if not FindBackupItemList then
    Exit;
  for i := 0 to BackupItemList.Count - 1 do
    if ( BackupItemList[i].BackupPath = BackupPath ) then
    begin
      Result := True;
      BackupItemIndex := i;
      BackupItemInfo := BackupItemList[i];
      break;
    end;
end;

{ TBackupItemAddInfo }

procedure TBackupItemAddInfo.SetIsFile( _IsFile : boolean );
begin
  IsFile := _IsFile;
end;

procedure TBackupItemAddInfo.SetIsBackupNow( _IsBackupNow : boolean );
begin
  IsBackupNow := _IsBackupNow;
end;

procedure TBackupItemAddInfo.SetIsCompleted(_IsCompleted: boolean);
begin
  IsCompleted := _IsCompleted;
end;

procedure TBackupItemAddInfo.SetAutoSyncInfo( _IsAutoSync : boolean; _LastSyncTime : TDateTime );
begin
  IsAutoSync := _IsAutoSync;
  LastSyncTime := _LastSyncTime;
end;

procedure TBackupItemAddInfo.SetSyncTimeInfo( _SyncTimeType, _SyncTimeValue : integer );
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TBackupItemAddInfo.SetEncryptInfo( _IsEncrypt : boolean; _Password, _PasswordHint : string );
begin
  IsEncrypt := _IsEncrypt;
  Password := _Password;
  PasswordHint := _PasswordHint;
end;

procedure TBackupItemAddInfo.SetDeletedInfo( _IsKeepDeleted : boolean; _KeepEditionCount : integer );
begin
  IsKeepDeleted := _IsKeepDeleted;
  KeepEditionCount := _KeepEditionCount;
end;

procedure TBackupItemAddInfo.SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TBackupItemAddInfo.Update;
begin
    // �������򴴽�
  if not FindBackupItemInfo then
  begin
    if BackupItemList = nil then  // �Ҳ���Ŀ��·��
      Exit;
    BackupItemInfo := TBackupItemInfo.Create( BackupPath );
    BackupItemList.Add( BackupItemInfo );
  end;

  BackupItemInfo.SetIsFile( IsFile );
  BackupItemInfo.SetIsCompleted( IsCompleted );
  BackupItemInfo.SetIsBackupNow( IsBackupNow );
  BackupItemInfo.SetAutoSyncInfo( IsAutoSync, LastSyncTime );
  BackupItemInfo.SetSyncTimeInfo( SyncTimeType, SyncTimeValue );
  BackupItemInfo.SetEncryptInfo( IsEncrypt, Password, PasswordHint );
  BackupItemInfo.SetDeletedInfo( IsKeepDeleted, KeepEditionCount );
  BackupItemInfo.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
  BackupItemInfo.IsBackuping := False;
  BackupItemInfo.IsDesBusy := False;
  BackupItemInfo.IsLostConn := False;

    // ˢ��ͬ��ʱ��
  RefreshNextSyncTime;
end;

{ TBackupItemRemoveInfo }

procedure TBackupItemRemoveInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;

  BackupItemList.Delete( BackupItemIndex );
end;

{ TDesItemListReadTotalSpace }

function TDesItemListReadTotalSpace.get: Int64;
var
  i, j : Integer;
begin
  Result := 0;
  for i := 0 to DesItemList.Count - 1 do
    for j := 0 to DesItemList[i].BackupItemList.Count - 1 do
      Result := Result + DesItemList[i].BackupItemList[j].ItemSize;
end;

{ DesItemInfoReadUtil }

class function DesItemInfoReadUtil.ReadBackupAllList(
  DesItemID: string): TStringList;
var
  DesItemReadBackupAllList : TDesItemReadBackupAllList;
begin
  DesItemReadBackupAllList := TDesItemReadBackupAllList.Create( DesItemID );
  Result := DesItemReadBackupAllList.get;
  DesItemReadBackupAllList.Free;
end;

class function DesItemInfoReadUtil.ReadBackupList(
  DesItemID: string): TStringList;
var
  DesItemReadBackupList : TDesItemReadBackupList;
begin
  DesItemReadBackupList := TDesItemReadBackupList.Create( DesItemID );
  Result := DesItemReadBackupList.get;
  DesItemReadBackupList.Free;
end;

class function DesItemInfoReadUtil.ReadIncompletedList(
  DesItemID: string): TStringList;
var
  DesItemReadIncompletedBackupList : TDesItemReadIncompletedBackupList;
begin
  DesItemReadIncompletedBackupList := TDesItemReadIncompletedBackupList.Create( DesItemID );
  Result := DesItemReadIncompletedBackupList.get;
  DesItemReadIncompletedBackupList.Free;
end;

class function DesItemInfoReadUtil.ReadIsExistLocalBackup: Boolean;
var
  DesItemListReadIsExistLocalBackup : TDesItemListReadIsExistLocalBackup;
begin
  DesItemListReadIsExistLocalBackup := TDesItemListReadIsExistLocalBackup.Create;
  Result := DesItemListReadIsExistLocalBackup.get;
  DesItemListReadIsExistLocalBackup.Free;
end;

class function DesItemInfoReadUtil.ReadIsLocalDes(DesItemID: string): Boolean;
var
  DesItemReadIsLocalDes : TDesItemReadIsLocalDes;
begin
  DesItemReadIsLocalDes := TDesItemReadIsLocalDes.Create( DesItemID );
  Result := DesItemReadIsLocalDes.get;
  DesItemReadIsLocalDes.Free;
end;

class function DesItemInfoReadUtil.ReadLocaDesList: TStringList;
var
  DesItemListReadLocalList : TDesItemListReadLocalList;
begin
  DesItemListReadLocalList := TDesItemListReadLocalList.Create;
  Result := DesItemListReadLocalList.get;
  DesItemListReadLocalList.Free;
end;

class function DesItemInfoReadUtil.ReadLocalItemCount: Integer;
var
  DesItemListReadLocalItemCount : TDesItemListReadLocalItemCount;
begin
  DesItemListReadLocalItemCount := TDesItemListReadLocalItemCount.Create;
  Result := DesItemListReadLocalItemCount.get;
  DesItemListReadLocalItemCount.Free;
end;

class function DesItemInfoReadUtil.ReadLocalRestoreList: TRestoreSourceList;
var
  DesItemListReadLocalRestoreList : TDesItemListReadLocalRestoreList;
begin
  DesItemListReadLocalRestoreList := TDesItemListReadLocalRestoreList.Create;
  Result := DesItemListReadLocalRestoreList.get;
  DesItemListReadLocalRestoreList.Free;
end;

class function DesItemInfoReadUtil.ReadLostConnBackupList(
  DesItemID: string): TStringList;
var
  DesItemReadLostConnBackupList : TDesItemReadLostConnBackupList;
begin
  DesItemReadLostConnBackupList := TDesItemReadLostConnBackupList.Create( DesItemID );
  Result := DesItemReadLostConnBackupList.get;
  DesItemReadLostConnBackupList.Free;
end;

class function DesItemInfoReadUtil.ReadNetworkDesList: TStringList;
var
  DesItemListReadNetworkList : TDesItemListReadNetworkList;
begin
  DesItemListReadNetworkList := TDesItemListReadNetworkList.Create;
  Result := DesItemListReadNetworkList.get;
  DesItemListReadNetworkList.Free;
end;

class function DesItemInfoReadUtil.ReadNetworkItemCount: Integer;
var
  DesItemListReadNetworkItemCount : TDesItemListReadNetworkItemCount;
begin
  DesItemListReadNetworkItemCount := TDesItemListReadNetworkItemCount.Create;
  Result := DesItemListReadNetworkItemCount.get;
  DesItemListReadNetworkItemCount.Free;
end;

class function DesItemInfoReadUtil.ReadOnTimeBackupList(
  DesItemID: string): TStringList;
var
  DesItemReadOnTimeBackupList : TDesItemReadOnTimeBackupList;
begin
  DesItemReadOnTimeBackupList := TDesItemReadOnTimeBackupList.Create( DesItemID );
  Result := DesItemReadOnTimeBackupList.get;
  DesItemReadOnTimeBackupList.Free;
end;

class function DesItemInfoReadUtil.ReadTotalCompletedSpace: Int64;
var
  DesItemListReadTotalCompletedSpace : TDesItemListReadTotalCompletedSpace;
begin
  DesItemListReadTotalCompletedSpace := TDesItemListReadTotalCompletedSpace.Create;
  Result := DesItemListReadTotalCompletedSpace.get;
  DesItemListReadTotalCompletedSpace.Free;
end;

class function DesItemInfoReadUtil.ReadTotalSpace: Int64;
var
  DesItemListReadTotalSpace : TDesItemListReadTotalSpace;
begin
  DesItemListReadTotalSpace := TDesItemListReadTotalSpace.Create;
  Result := DesItemListReadTotalSpace.get;
  DesItemListReadTotalSpace.Free;
end;

{ TDesItemListReadLocalList }

function TDesItemListReadLocalList.get: TStringList;
var
  i : Integer;
begin
  Result := TStringList.Create;
  for i := 0 to DesItemList.Count - 1 do
    if DesItemList[i] is TLocalDesItemInfo then
      Result.Add( DesItemList[i].DesItemID );
end;

{ TDesItemListReadLocalRestoreList }

function TDesItemListReadLocalRestoreList.get: TRestoreSourceList;
var
  i, j: Integer;
  DesInfo : TDesItemInfo;
  BackupList : TBackupItemList;
  BackupInfo : TBackupItemInfo;
  RestoreSourceInfo : TRestoreSourceInfo;
begin
  Result := TRestoreSourceList.Create;
  for i := 0 to DesItemList.Count - 1 do
  begin
    DesInfo := DesItemList[i];
    if not ( DesInfo is TLocalDesItemInfo ) then
      Continue;
    BackupList := DesInfo.BackupItemList;
    for j := 0 to BackupList.Count - 1 do
    begin
      BackupInfo := BackupList[j];
      if BackupInfo.CompletedSize < BackupInfo.ItemSize then
        Continue;

        // ��ȡ�ָ���Ϣ
      RestoreSourceInfo := BackupItemInfoReadUtil.ReadRestoreSourceInfo( DesInfo.DesItemID, BackupInfo.BackupPath );
      Result.Add( RestoreSourceInfo );
    end;
  end;
end;

{ TDesItemReadBackupList }

function TDesItemReadBackupList.get: TStringList;
var
  i : Integer;
begin
  Result := TStringList.Create;
  if not FindBackupItemList then
    Exit;
  for i := 0 to BackupItemList.Count - 1 do
    Result.Add( BackupItemList[i].BackupPath );
end;

{ TBackupItemReadIsEnable }

function TBackupItemReadIsEnable.get: Boolean;
begin
  Result := FindBackupItemInfo;
end;

{ TBackupItemReadIsKeepDeleted }

function TBackupItemReadIsKeepDeleted.get: Boolean;
begin
  Result := False;
  if not FindBackupItemInfo then
    Exit;
  Result := BackupItemInfo.IsKeepDeleted;
end;

{ TBackupItemReadKeepDeletedCount }

function TBackupItemReadKeepDeletedCount.get: Integer;
begin
  Result := 0;
  if not FindBackupItemInfo then
    Exit;
  Result := BackupItemInfo.KeepEditionCount;
end;

{ TBackupReadIncludeFilter }

function TBackupItemReadIncludeFilter.get: TFileFilterList;
var
  IncludeFilterList : TFileFilterList;
  i : Integer;
  FilterType, FilterStr : string;
  FileFilterInfo : TFileFilterInfo;
begin
  Result := TFileFilterList.Create;
  if not FindBackupItemInfo then
    Exit;
  IncludeFilterList := BackupItemInfo.IncludeFilterList;
  for i := 0 to IncludeFilterList.Count - 1 do
  begin
    FilterType := IncludeFilterList[i].FilterType;
    FilterStr := IncludeFilterList[i].FilterStr;
    FileFilterInfo := TFileFilterInfo.Create( FilterType, FilterStr );
    Result.Add( FileFilterInfo );
  end;
end;

{ TBackupReadExcludeFilter }

function TBackupItemReadExcludeFilter.get: TFileFilterList;
var
  ExcludeFilterList : TFileFilterList;
  i : Integer;
  FilterType, FilterStr : string;
  FileFilterInfo : TFileFilterInfo;
begin
  Result := TFileFilterList.Create;
  if not FindBackupItemInfo then
    Exit;
  ExcludeFilterList := BackupItemInfo.ExcludeFilterList;
  for i := 0 to ExcludeFilterList.Count - 1 do
  begin
    FilterType := ExcludeFilterList[i].FilterType;
    FilterStr := ExcludeFilterList[i].FilterStr;
    FileFilterInfo := TFileFilterInfo.Create( FilterType, FilterStr );
    Result.Add( FileFilterInfo );
  end;
end;

{ TBackupItemWriteInfo }

procedure TBackupItemWriteInfo.RefreshNextSyncTime;
var
  SyncMins : Integer;
begin
    // �����´� ͬ��ʱ��
  SyncMins := TimeTypeUtil.getMins( BackupItemInfo.SyncTimeType, BackupItemInfo.SyncTimeValue );
  BackupItemInfo.NextSyncTime := IncMinute( BackupItemInfo.LasSyncTime, SyncMins );
end;

{ TBackupItemSetIsBackupNowInfo }

procedure TBackupItemSetIsBackupNowInfo.SetIsBackupNow(
  _IsBackupNow: Boolean);
begin
  IsBackupNow := _IsBackupNow;
end;

procedure TBackupItemSetIsBackupNowInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.IsBackupNow := IsBackupNow;
end;

{ TBackupItemSetLastSyncTimeInfo }

procedure TBackupItemSetLastSyncTimeInfo.SetLastSyncTime(
  _LastSyncTime: TDateTime);
begin
  LastSyncTime := _LastSyncTime;
end;

procedure TBackupItemSetLastSyncTimeInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;

  BackupItemInfo.LasSyncTime := LastSyncTime;

    // ˢ�� �´�ͬ��ʱ��
  RefreshNextSyncTime;
end;

{ TBackupItemSetAutoSyncInfo }

procedure TBackupItemSetAutoSyncInfo.SetIsAutoSync(_IsAutoSync: Boolean);
begin
  IsAutoSync := _IsAutoSync;
end;

procedure TBackupItemSetAutoSyncInfo.SetSyncInterval(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TBackupItemSetAutoSyncInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;

  BackupItemInfo.IsAutoSync := IsAutoSync;
  BackupItemInfo.SyncTimeType := SyncTimeType;
  BackupItemInfo.SyncTimeValue := SyncTimeValue;

    // ˢ�� �´�ͬ��ʱ��
  RefreshNextSyncTime;
end;

{ TBackupItemSetRecycleInfo }

procedure TBackupItemSetRecycleInfo.SetDeleteInfo(_IsKeepDeleted: Boolean;
  _KeepEditionCount: Integer);
begin
  IsKeepDeleted := _IsKeepDeleted;
  KeepEditionCount := _KeepEditionCount;
end;

procedure TBackupItemSetRecycleInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.IsKeepDeleted := IsKeepDeleted;
  BackupItemInfo.KeepEditionCount := KeepEditionCount;
end;

{ TBackupItemSetSpaceInfoInfo }

procedure TBackupItemSetSpaceInfoInfo.SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TBackupItemSetSpaceInfoInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.FileCount := FileCount;
  BackupItemInfo.ItemSize := ItemSize;
  BackupItemInfo.CompletedSize := CompletedSize;
end;


{ TBackupItemSetAddCompletedSpaceInfo }

procedure TBackupItemSetAddCompletedSpaceInfo.SetAddCompletedSpace( _AddCompletedSpace : int64 );
begin
  AddCompletedSpace := _AddCompletedSpace;
end;

procedure TBackupItemSetAddCompletedSpaceInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.CompletedSize := BackupItemInfo.CompletedSize + AddCompletedSpace;
end;


{ TDesItemAddLocalInfo }

procedure TDesItemAddLocalInfo.CreateDesItem;
begin
  DesItemInfo := TLocalDesItemInfo.Create( DesItemID );
end;

{ TDesItemAddNetworkInfo }

procedure TDesItemAddNetworkInfo.CreateDesItem;
begin
  DesItemInfo := TNetworkDesItemInfo.Create( DesItemID );
end;

{ BackupItemReadUtil }


class function BackupItemInfoReadUtil.ReadConfigInfo(DesItemID,
  BackupPath: string): TBackupConfigInfo;
var
  BackupItemReadConfigInfo : TBackupItemReadConfigInfo;
begin
  BackupItemReadConfigInfo := TBackupItemReadConfigInfo.Create( DesItemID );
  BackupItemReadConfigInfo.SetBackupPath( BackupPath );
  Result := BackupItemReadConfigInfo.get;
  BackupItemReadConfigInfo.Free;
end;

class function BackupItemInfoReadUtil.ReadContinuesList(DesItemID,
  BackupPath: string): TBackupContinusList;
var
  BackupItemReadContinusList : TBackupItemReadContinusList;
begin
  BackupItemReadContinusList := TBackupItemReadContinusList.Create( DesItemID );
  BackupItemReadContinusList.SetBackupPath( BackupPath );
  Result := BackupItemReadContinusList.get;
  BackupItemReadContinusList.Free;
end;

class function BackupItemInfoReadUtil.ReadDesBusyList: TBackupKeyItemList;
var
  BackupItemReadDesBusyList : TBackupItemReadDesBusyList;
begin
  BackupItemReadDesBusyList := TBackupItemReadDesBusyList.Create;
  Result := BackupItemReadDesBusyList.get;
  BackupItemReadDesBusyList.Free;
end;

class function BackupItemInfoReadUtil.ReadNetworkIncompletedList: TBackupKeyItemList;
var
  BackupItemReadNetworkOnlineInfo : TBackupItemReadNetworkIncompleteList;
begin
  BackupItemReadNetworkOnlineInfo := TBackupItemReadNetworkIncompleteList.Create;
  Result := BackupItemReadNetworkOnlineInfo.get;
  BackupItemReadNetworkOnlineInfo.Free;
end;


class function BackupItemInfoReadUtil.ReadExcludeFilter(DesItemID,
  BackupPath: string): TFileFilterList;
var
  BackupItemReadExcludeFilter : TBackupItemReadExcludeFilter;
begin
  BackupItemReadExcludeFilter := TBackupItemReadExcludeFilter.Create( DesItemID );
  BackupItemReadExcludeFilter.SetBackupPath( BackupPath );
  Result := BackupItemReadExcludeFilter.get;
  BackupItemReadExcludeFilter.Free;
end;

class function BackupItemInfoReadUtil.ReadExistBackup(
  DesItemID: string): Boolean;
var
  DesItemReadExistBackup : TDesItemReadExistBackup;
begin
  DesItemReadExistBackup := TDesItemReadExistBackup.Create( DesItemID );
  Result := DesItemReadExistBackup.get;
  DesItemReadExistBackup.Free;
end;

class function BackupItemInfoReadUtil.ReadIncludeFilter(DesItemID,
  BackupPath: string): TFileFilterList;
var
  BackupItemReadIncludeFilter : TBackupItemReadIncludeFilter;
begin
  BackupItemReadIncludeFilter := TBackupItemReadIncludeFilter.Create( DesItemID );
  BackupItemReadIncludeFilter.SetBackupPath( BackupPath );
  Result := BackupItemReadIncludeFilter.get;
  BackupItemReadIncludeFilter.Free;
end;

class function BackupItemInfoReadUtil.ReadIsBackuping(DesItemID,
  BackupPath: string): Boolean;
var
  BackupItemReadIsBackuping : TBackupItemReadIsBackuping;
begin
  BackupItemReadIsBackuping := TBackupItemReadIsBackuping.Create( DesItemID );
  BackupItemReadIsBackuping.SetBackupPath( BackupPath );
  Result := BackupItemReadIsBackuping.get;
  BackupItemReadIsBackuping.Free;
end;

class function BackupItemInfoReadUtil.ReadIsCompleted(DesItemID,
  BackupPath: string): Boolean;
var
  BackupItemReadIsCompleted : TBackupItemReadIsCompleted;
begin
  BackupItemReadIsCompleted := TBackupItemReadIsCompleted.Create( DesItemID );
  BackupItemReadIsCompleted.SetBackupPath( BackupPath );
  Result := BackupItemReadIsCompleted.get;
  BackupItemReadIsCompleted.Free;
end;

class function BackupItemInfoReadUtil.ReadIsEnable(DesItemID,
  BackupPath: string): Boolean;
var
  BackupItemReadIsEnable : TBackupItemReadIsEnable;
begin
  BackupItemReadIsEnable := TBackupItemReadIsEnable.Create( DesItemID );
  BackupItemReadIsEnable.SetBackupPath( BackupPath );
  Result := BackupItemReadIsEnable.get;
  BackupItemReadIsEnable.Free;
end;

class function BackupItemInfoReadUtil.ReadIsEncrypted(DesItemID,
  BackupPath: string): Boolean;
var
  BackupItemReadIsEncrypted : TBackupItemReadIsEncrypted;
begin
  BackupItemReadIsEncrypted := TBackupItemReadIsEncrypted.Create( DesItemID );
  BackupItemReadIsEncrypted.SetBackupPath( BackupPath );
  Result := BackupItemReadIsEncrypted.get;
  BackupItemReadIsEncrypted.Free;
end;

class function BackupItemInfoReadUtil.ReadIsFile(DesItemID,
  BackupPath: string): Boolean;
var
  BackupItemReadIsFile : TBackupItemReadIsFile;
begin
  BackupItemReadIsFile := TBackupItemReadIsFile.Create( DesItemID );
  BackupItemReadIsFile.SetBackupPath( BackupPath );
  Result := BackupItemReadIsFile.get;
  BackupItemReadIsFile.Free;
end;

class function BackupItemInfoReadUtil.ReadIsKeepDeleted(DesItemID,
  BackupPath: string): Boolean;
var
  BackupItemReadIsKeepDeleted : TBackupItemReadIsKeepDeleted;
begin
  BackupItemReadIsKeepDeleted := TBackupItemReadIsKeepDeleted.Create( DesItemID );
  BackupItemReadIsKeepDeleted.SetBackupPath( BackupPath );
  Result := BackupItemReadIsKeepDeleted.get;
  BackupItemReadIsKeepDeleted.Free;
end;

class function BackupItemInfoReadUtil.ReadIsKeepEditionCount(DesItemID,
  BackupPath: string): Integer;
var
  BackupItemReadKeepDeletedCount : TBackupItemReadKeepDeletedCount;
begin
  BackupItemReadKeepDeletedCount := TBackupItemReadKeepDeletedCount.Create( DesItemID );
  BackupItemReadKeepDeletedCount.SetBackupPath( BackupPath );
  Result := BackupItemReadKeepDeletedCount.get;
  BackupItemReadKeepDeletedCount.Free;
end;

class function BackupItemInfoReadUtil.ReadIsLostConnect(DesItemID,
  BackupPath: string): Boolean;
var
  BackupItemReadIsLostConn : TBackupItemReadIsLostConn;
begin
  BackupItemReadIsLostConn := TBackupItemReadIsLostConn.Create( DesItemID );
  BackupItemReadIsLostConn.SetBackupPath( BackupPath );
  Result := BackupItemReadIsLostConn.get;
  BackupItemReadIsLostConn.Free;
end;

class function BackupItemInfoReadUtil.ReadLocalIncompletedList: TBackupKeyItemList;
var
  BackupItemReadLocalOnlineInfo : TBackupItemReadLocalIncompleteList;
begin
  BackupItemReadLocalOnlineInfo := TBackupItemReadLocalIncompleteList.Create;
  Result := BackupItemReadLocalOnlineInfo.get;
  BackupItemReadLocalOnlineInfo.Free;
end;

class function BackupItemInfoReadUtil.ReadPassword(DesItemID,
  BackupPath: string): string;
var
  BackupItemReadPassword : TBackupItemReadPassword;
begin
  BackupItemReadPassword := TBackupItemReadPassword.Create( DesItemID );
  BackupItemReadPassword.SetBackupPath( BackupPath );
  Result := BackupItemReadPassword.get;
  BackupItemReadPassword.Free;
end;

class function BackupItemInfoReadUtil.ReadPcOnline(
  OnlinePcID: string): TBackupKeyItemList;
var
  BackupItemReadPcOnlineInfo : TBackupItemReadPcOnlineInfo;
begin
  BackupItemReadPcOnlineInfo := TBackupItemReadPcOnlineInfo.Create;
  BackupItemReadPcOnlineInfo.SetOnlinePcID( OnlinePcID );
  Result := BackupItemReadPcOnlineInfo.get;
  BackupItemReadPcOnlineInfo.Free;
end;

class function BackupItemInfoReadUtil.ReadRestoreSourceInfo(DesItemID,
  BackupPath: string): TRestoreSourceInfo;
var
  BackupItemReadRestoreSourceInfo : TBackupItemReadRestoreSourceInfo;
begin
  BackupItemReadRestoreSourceInfo := TBackupItemReadRestoreSourceInfo.Create( DesItemID );
  BackupItemReadRestoreSourceInfo.SetBackupPath( BackupPath );
  Result := BackupItemReadRestoreSourceInfo.get;
  BackupItemReadRestoreSourceInfo.Free;
end;

{ TBackupItemSetIsBackupingInfo }

procedure TBackupItemSetIsBackupingInfo.SetIsBackuping( _IsBackuping : boolean );
begin
  IsBackuping := _IsBackuping;
end;

procedure TBackupItemSetIsBackupingInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.IsBackuping := IsBackuping;
end;



{ TBackupItemReadConfigInfo }

function TBackupItemReadConfigInfo.get: TBackupConfigInfo;
var
  IncludeFilterList, ExcludeFilterList : TFileFilterList;
begin
  Result := nil;
  if not FindBackupItemInfo then
    Exit;

  IncludeFilterList := FileFilterUtil.getCloneFilter( BackupItemInfo.IncludeFilterList );
  ExcludeFilterList := FileFilterUtil.getCloneFilter( BackupItemInfo.ExcludeFilterList );

  Result := TBackupConfigInfo.Create;
  Result.SetIsBackupNow( BackupItemInfo.IsBackupNow );
  Result.SetSyncInfo( BackupItemInfo.IsAutoSync, BackupItemInfo.SyncTimeType, BackupItemInfo.SyncTimeValue );
  Result.SetEncryptInfo( BackupItemInfo.IsEncrypt, BackupItemInfo.Password, BackupItemInfo.PasswordHint );
  Result.SetDeleteInfo( BackupItemInfo.IsKeepDeleted, BackupItemInfo.KeepEditionCount );
  Result.SetIncludeFilterList( IncludeFilterList );
  Result.SetExcludeFilterList( ExcludeFilterList );
end;

{ TBackupItemIncludeFilterClearInfo }

procedure TBackupItemIncludeFilterClearInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.IncludeFilterList.Clear;
end;

{ TBackupItemFilterAddInfo }

procedure TBackupItemFilterAddInfo.SetFilterInfo(_FilterType,
  _FilterValue: string);
begin
  FilterType := _FilterType;
  FilterValue := _FilterValue;
end;

{ TBackupItemIncludeFilterAddInfo }

procedure TBackupItemIncludeFilterAddInfo.Update;
var
  FilterInfo : TFileFilterInfo;
begin
  if not FindBackupItemInfo then
    Exit;
  FilterInfo := TFileFilterInfo.Create( FilterType, FilterValue );
  BackupItemInfo.IncludeFilterList.Add( FilterInfo );
end;

{ TBackupItemExcludeFilterClearInfo }

procedure TBackupItemExcludeFilterClearInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.ExcludeFilterList.Clear;
end;

{ TBackupItemExcludeFilterAddInfo }

procedure TBackupItemExcludeFilterAddInfo.Update;
var
  FilterInfo : TFileFilterInfo;
begin
  if not FindBackupItemInfo then
    Exit;
  FilterInfo := TFileFilterInfo.Create( FilterType, FilterValue );
  BackupItemInfo.ExcludeFilterList.Add( FilterInfo );
end;

{ TBackupItemSetEncryptInfoInfo }

procedure TBackupItemSetEncryptInfoInfo.SetEncryptInfo( _IsEncrypt : boolean; _Password, _PasswordHint : string );
begin
  IsEncrypt := _IsEncrypt;
  Password := _Password;
  PasswordHint := _PasswordHint;
end;

procedure TBackupItemSetEncryptInfoInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.IsEncrypt := IsEncrypt;
  BackupItemInfo.Password := Password;
  BackupItemInfo.PasswordHint := PasswordHint;
end;




{ TDesItemListReadNetworkList }

function TDesItemListReadNetworkList.get: TStringList;
var
  i : Integer;
begin
  Result := TStringList.Create;
  for i := 0 to DesItemList.Count - 1 do
    if DesItemList[i] is TNetworkDesItemInfo then
      Result.Add( DesItemList[i].DesItemID );
end;

{ TDesItemReadOnTimeBackupList }

function TDesItemReadOnTimeBackupList.get: TStringList;
var
  i : Integer;
  BackupItemInfo : TBackupItemInfo;
begin
  Result := TStringList.Create;
  if not FindBackupItemList then
    Exit;
  for i := 0 to BackupItemList.Count - 1 do
  begin
    BackupItemInfo := BackupItemList[i];
    if not BackupItemInfo.IsAutoSync then // ���Զ�ͬ��
      Continue;
    if BackupItemInfo.NextSyncTime > Now then  // ͬ��ʱ��δ��
      Continue;
    if BackupItemInfo.IsBackuping then // ���ڱ���
      Continue;
    if not BackupItemInfo.IsCompleted then // δ���
      Continue;
    Result.Add( BackupItemInfo.BackupPath );
  end;
end;

{ TDesItemReadBackupAllList }

function TDesItemReadBackupAllList.get: TStringList;
var
  i : Integer;
begin
  Result := TStringList.Create;
  if not FindBackupItemList then
    Exit;
  for i := 0 to BackupItemList.Count - 1 do
    if BackupItemList[i].IsBackupNow then
      Result.Add( BackupItemList[i].BackupPath );
end;

{ TBackupItemReadRestoreSourceInfo }

function TBackupItemReadRestoreSourceInfo.get: TRestoreSourceInfo;
var
  EncryptedPassword : string;
begin
  Result := TRestoreSourceInfo.Create( DesItemID, BackupPath );
  if not FindBackupItemInfo then
    Exit;

    // �������
  EncryptedPassword := MyEncrypt.EncodeMD5String( BackupItemInfo.Password );

  Result.SetIsFile( BackupItemInfo.IsFile );
  Result.SetSpaceInfo( BackupItemInfo.FileCount, BackupItemInfo.ItemSize );
  Result.SetLastSyncTime( BackupItemInfo.LasSyncTime );
  Result.SetIsSaveDeleted( BackupItemInfo.IsKeepDeleted );
  Result.SetEncryptInfo( BackupItemInfo.IsEncrypt, EncryptedPassword, BackupItemInfo.PasswordHint );
end;

{ TBackupLogInfo }

constructor TBackupLogInfo.Create(_FilePath: string);
begin
  FilePath := _FilePath;
end;


{ TBackupItemReadIsCompleted }

function TBackupItemReadIsCompleted.get: Boolean;
begin
  Result := False;
  if not FindBackupItemInfo then
    Exit;
  Result := BackupItemInfo.CompletedSize >= BackupItemInfo.ItemSize;
end;

{ TDesItemReadExistBackup }

function TDesItemReadExistBackup.get: Boolean;
begin
  Result := False;
  if not FindDesItemInfo then
    Exit;
  Result := DesItemInfo.BackupItemList.Count > 0;
end;

{ TBackupItemSetIsCompletedInfo }

procedure TBackupItemSetIsCompletedInfo.SetIsCompleted( _IsCompleted : boolean );
begin
  IsCompleted := _IsCompleted;
end;

procedure TBackupItemSetIsCompletedInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.IsCompleted := IsCompleted;
end;


{ TOnlineBackupInfo }

constructor TBackupKeyItemInfo.Create(_DesItem, _BackupPath: string);
begin
  DesItem := _DesItem;
  BackupPath := _BackupPath;
end;

{ TBackupItemReadLocalOnlineInfo }

function TBackupItemReadLocalIncompleteList.get: TBackupKeyItemList;
var
  i, j: Integer;
  OnlineBackupIfno : TBackupKeyItemInfo;
  BackupItemInfo : TBackupItemInfo;
begin
  Result := TBackupKeyItemList.Create;

  for i := 0 to DesItemList.Count - 1 do
    if DesItemList[i] is TLocalDesItemInfo then
      for j := 0 to DesItemList[i].BackupItemList.Count - 1 do
      begin
        BackupItemInfo := DesItemList[i].BackupItemList[j];
        if BackupItemInfo.IsCompleted then // ����ɣ�����
          Continue;
        OnlineBackupIfno := TBackupKeyItemInfo.Create( DesItemList[i].DesItemID, BackupItemInfo.BackupPath );
        Result.Add( OnlineBackupIfno );
      end;
end;

{ TBackupItemReadPcOnlineInfo }

function TBackupItemReadPcOnlineInfo.get: TBackupKeyItemList;
var
  i, j: Integer;
  SelectPcID : string;
  OnlineBackupIfno : TBackupKeyItemInfo;
  BackupItemInfo : TBackupItemInfo;
begin
  Result := TBackupKeyItemList.Create;

  for i := 0 to DesItemList.Count - 1 do
    if DesItemList[i] is TNetworkDesItemInfo then
    begin
      SelectPcID := NetworkDesItemUtil.getPcID( DesItemList[i].DesItemID );
      if SelectPcID <> OnlinePcID then
        Continue;
      for j := 0 to DesItemList[i].BackupItemList.Count - 1 do
      begin
        BackupItemInfo := DesItemList[i].BackupItemList[j];
        if BackupItemInfo.IsCompleted then
          Continue;
        OnlineBackupIfno := TBackupKeyItemInfo.Create( DesItemList[i].DesItemID, BackupItemInfo.BackupPath );
        Result.Add( OnlineBackupIfno );
      end;
    end;
end;

procedure TBackupItemReadPcOnlineInfo.SetOnlinePcID(_OnlinePcID: string);
begin
  OnlinePcID := _OnlinePcID;
end;

{ TBackupItemReadIsBackuping }

function TBackupItemReadIsBackuping.get: Boolean;
begin
  Result := False;
  if not FindBackupItemInfo then
    Exit;
  Result := BackupItemInfo.IsBackuping;
end;

{ TBackupContinusInfo }

constructor TBackupContinusInfo.Create(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TBackupContinusInfo.SetFileInfo(_FileSize : Int64;
  _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

{ TBackupContinusListAccessInfo }

function TBackupContinusListAccessInfo.FindBackupContinusList : Boolean;
begin
  Result := FindBackupItemInfo;
  if Result then
    BackupContinusList := BackupItemInfo.BackupContinusList
  else
    BackupContinusList := nil;
end;

{ TBackupContinusAccessInfo }

procedure TBackupContinusAccessInfo.SetFilePath( _FilePath : string );
begin
  FilePath := _FilePath;
end;


function TBackupContinusAccessInfo.FindBackupContinusInfo: Boolean;
var
  i : Integer;
begin
  Result := False;
  if not FindBackupContinusList then
    Exit;
  for i := 0 to BackupContinusList.Count - 1 do
    if ( BackupContinusList[i].FilePath = FilePath ) then
    begin
      Result := True;
      BackupContinusIndex := i;
      BackupContinusInfo := BackupContinusList[i];
      break;
    end;
end;

{ TBackupContinusAddInfo }

procedure TBackupContinusAddInfo.SetFileInfo( _FileSize : int64;
  _FileTime : TDateTime );
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TBackupContinusAddInfo.Update;
begin
    // �������򴴽�
  if not FindBackupContinusInfo then
  begin
    BackupContinusInfo := TBackupContinusInfo.Create( FilePath );
    BackupContinusInfo.SetFileInfo( FileSize, FileTime );
    BackupContinusList.Add( BackupContinusInfo );
  end;
end;

{ TBackupContinusRemoveInfo }

procedure TBackupContinusRemoveInfo.Update;
begin
  if not FindBackupContinusInfo then
    Exit;

  BackupContinusList.Delete( BackupContinusIndex );
end;




{ TBackupItemReadContinusList }

function TBackupItemReadContinusList.get: TBackupContinusList;
var
  BackupContinuseList : TBackupContinusList;
  i: Integer;
  OldContinuesInfo, NewContinuesInfo : TBackupContinusInfo;
begin
  Result := TBackupContinusList.Create;
  if not FindBackupItemInfo then
    Exit;
  BackupContinuseList := BackupItemInfo.BackupContinusList;
  for i := 0 to BackupContinuseList.Count - 1 do
  begin
    OldContinuesInfo := BackupContinuseList[i];
    NewContinuesInfo := TBackupContinusInfo.Create( OldContinuesInfo.FilePath );
    NewContinuesInfo.SetFileInfo( OldContinuesInfo.FileSize, OldContinuesInfo.FileTime );
    Result.Add( NewContinuesInfo );
  end;
end;

{ TDesItemListReadTotalCompletedSpace }

function TDesItemListReadTotalCompletedSpace.get: Int64;
var
  i, j : Integer;
begin
  Result := 0;
  for i := 0 to DesItemList.Count - 1 do
    for j := 0 to DesItemList[i].BackupItemList.Count - 1 do
      Result := Result + DesItemList[i].BackupItemList[j].CompletedSize;
end;

{ TBackupItemSetIsDesBusyInfo }

procedure TBackupItemSetIsDesBusyInfo.SetIsDesBusy(_IsDesBusy: boolean);
begin
  IsDesBusy := _IsDesBusy;
end;

procedure TBackupItemSetIsDesBusyInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.IsDesBusy := IsDesBusy;
end;

{ TBackupItemReadNetworkOnlineInfo }

function TBackupItemReadNetworkIncompleteList.get: TBackupKeyItemList;
var
  i, j: Integer;
  OnlineBackupIfno : TBackupKeyItemInfo;
  BackupItemInfo : TBackupItemInfo;
begin
  Result := TBackupKeyItemList.Create;

  for i := 0 to DesItemList.Count - 1 do
    if DesItemList[i] is TNetworkDesItemInfo then
      for j := 0 to DesItemList[i].BackupItemList.Count - 1 do
      begin
        BackupItemInfo := DesItemList[i].BackupItemList[j];
        if BackupItemInfo.IsCompleted then // ����ɣ�����
          Continue;
        OnlineBackupIfno := TBackupKeyItemInfo.Create( DesItemList[i].DesItemID, BackupItemInfo.BackupPath );
        Result.Add( OnlineBackupIfno );
      end;
end;

{ TDesItemListReadIsExistLocalBackup }

function TDesItemListReadIsExistLocalBackup.get: Boolean;
var
  i, j : Integer;
begin
  Result := False;
  for i := 0 to DesItemList.Count - 1 do
    if ( DesItemList[i] is TLocalDesItemInfo ) and
       ( DesItemList[i].BackupItemList.Count > 0 )
    then
    begin
      Result := True;
      Break;
    end;
end;

{ TDesItemReadIsLocalDes }

function TDesItemReadIsLocalDes.get: Boolean;
begin
  Result := False;
  if not FindDesItemInfo then
    Exit;
  Result := DesItemInfo is TLocalDesItemInfo;
end;

{ TDesItemAddInfo }

procedure TDesItemAddInfo.Update;
begin
  if FindDesItemInfo then
    Exit;

  CreateDesItem;
  DesItemList.Add( DesItemInfo );
end;

{ TBackupItemReadDesBusyList }

function TBackupItemReadDesBusyList.get: TBackupKeyItemList;
var
  i, j: Integer;
  OnlineBackupIfno : TBackupKeyItemInfo;
  BackupItemInfo : TBackupItemInfo;
begin
  Result := TBackupKeyItemList.Create;

  for i := 0 to DesItemList.Count - 1 do
    if DesItemList[i] is TNetworkDesItemInfo then
      for j := 0 to DesItemList[i].BackupItemList.Count - 1 do
      begin
        BackupItemInfo := DesItemList[i].BackupItemList[j];
        if not BackupItemInfo.IsDesBusy then // �Ƿ�æ������
          Continue;
        OnlineBackupIfno := TBackupKeyItemInfo.Create( DesItemList[i].DesItemID, BackupItemInfo.BackupPath );
        Result.Add( OnlineBackupIfno );
      end;
end;

{ TBackupItemReadIsEncrypted }

function TBackupItemReadIsEncrypted.get: Boolean;
begin
  Result := False;
  if not FindBackupItemInfo then
    Exit;
  Result := BackupItemInfo.IsEncrypt;
end;

{ TBackupItemReadPassword }

function TBackupItemReadPassword.get: string;
begin
  Result := '';
  if not FindBackupItemInfo then
    Exit;
  if not BackupItemInfo.IsEncrypt then
    Exit;
  Result := BackupItemInfo.Password;
end;

{ TBackupItemReadIsFile }

function TBackupItemReadIsFile.get: Boolean;
begin
  Result := False;
  if not FindBackupItemInfo then
    Exit;
  Result := BackupItemInfo.IsFile;
end;

{ TBackupSpeedInfo }

constructor TBackupSpeedInfo.Create;
begin
  IsLimit := False;
end;

{ TBackupSpeedAccessInfo }

constructor TBackupSpeedAccessInfo.Create;
begin
  BackupSpeedInfo := MyBackupInfo.BackupSpeedInfo;
end;

{ TBackupSpeedLimitInfo }

procedure TBackupSpeedLimitInfo.SetIsLimit(_IsLimit: Boolean);
begin
  IsLimit := _IsLimit;
end;

procedure TBackupSpeedLimitInfo.SetLimitInfo(_LimitValue, _LimitType: Integer);
begin
  LimitValue := _LimitValue;
  LimitType := _LimitType;
end;

procedure TBackupSpeedLimitInfo.Update;
begin
  BackupSpeedInfo.IsLimit := IsLimit;
  BackupSpeedInfo.LimitValue := LimitValue;
  BackupSpeedInfo.LimitType := LimitType;
end;

{ TDesItemListReadLocalItemCount }

function TDesItemListReadLocalItemCount.get: Integer;
var
  i : Integer;
begin
  Result := 0;

  for i := 0 to DesItemList.Count - 1 do
    if DesItemList[i] is TLocalDesItemInfo then
      Result := Result + DesItemList[i].BackupItemList.Count;
end;

{ TDesItemListReadNetworkItemCount }

function TDesItemListReadNetworkItemCount.get: Integer;
var
  i : Integer;
begin
  Result := 0;

  for i := 0 to DesItemList.Count - 1 do
    if DesItemList[i] is TNetworkDesItemInfo then
      Result := Result + DesItemList[i].BackupItemList.Count;
end;

{ TBackupCompletedLog }

procedure TBackupCompletedLog.SetBackupTime(_BackupTime: TDateTime);
begin
  BackupTime := _BackupTime;
end;

{ TBackupIncompletedLog }

procedure TBackupIncompletedLog.SetErrorStr(_ErrorStr: string);
begin
  ErrorStr := _ErrorStr;
end;

{ TBackupItemSetIsLostConnInfo }

procedure TBackupItemSetIsLostConnInfo.SetIsLostConn(_IsLostConn: boolean);
begin
  IsLostConn := _IsLostConn;
end;

procedure TBackupItemSetIsLostConnInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.IsLostConn := IsLostConn;
end;

{ TBackupItemReadIsLostConn }

function TBackupItemReadIsLostConn.get: Boolean;
begin
  Result := False;
  if not FindBackupItemInfo then
    Exit;
  Result := BackupItemInfo.IsLostConn;
end;

{ TDesItemReadLostConnBackupList }

function TDesItemReadLostConnBackupList.get: TStringList;
var
  i : Integer;
  BackupItemInfo : TBackupItemInfo;
begin
  Result := TStringList.Create;
  if not FindBackupItemList then
    Exit;
  for i := 0 to BackupItemList.Count - 1 do
  begin
    BackupItemInfo := BackupItemList[i];
    if not BackupItemInfo.IsLostConn then // �ǶϿ�����
      Continue;
    Result.Add( BackupItemInfo.BackupPath );
  end;
end;

{ TDesItemReadIncompletedBackupList }

function TDesItemReadIncompletedBackupList.get: TStringList;
var
  i : Integer;
  BackupItemInfo : TBackupItemInfo;
begin
  Result := TStringList.Create;
  if not FindBackupItemList then
    Exit;
  for i := 0 to BackupItemList.Count - 1 do
  begin
    BackupItemInfo := BackupItemList[i];
      // �����������ģ�����
    if BackupItemInfo.IsDesBusy or BackupItemInfo.IsLostConn or
       BackupItemInfo.IsBackuping or BackupItemInfo.IsCompleted
    then
      Continue;
    Result.Add( BackupItemInfo.BackupPath );
  end;
end;

end.
