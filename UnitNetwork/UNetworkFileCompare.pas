unit UNetworkFileCompare;

interface

uses classes, SyncObjs, UFileBaseInfo, UMyUtil;

type

{$Region '  ' }

    // 备份目录 网络比较
  TBackupFolderCompare = class
  private
    PcID : string;
    BackupFolderPath : string;
  private
    TempBackupFolder : TTempBackupFolderInfo;
  public
    constructor Create( _PcID : string );
    procedure SetBackupFolderPath( _BackupFolderPath : string );
    procedure Update;
    destructor Destroy; override;
  private
    procedure FindTempBackupFolder;
    procedure CheckFiles;
    procedure CheckFolders;
  private
    procedure FindFile( TempFileInfo : TTempBackupFileInfo );
    function CheckNextCompare : Boolean;
  end;

  TBackupFileCompareThread = class( TThread )
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  end;

    // 需要比较的 备份文件
  TMyBackupFileCompareInfo = class
  public
    Lock : TCriticalSection;
    PcIDList : TStringList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // 需要比较的 云文件
  TMyCloudFileCompareInfo = class
  public
    PcIDList : TStringList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses UMyBackupInfo;

{ TMyBackupFileCompareInfo }

constructor TMyBackupFileCompareInfo.Create;
begin
  Lock := TCriticalSection.Create;
  PcIDList := TStringList.Create;
end;

destructor TMyBackupFileCompareInfo.Destroy;
begin
  PcIDList.Free;
  Lock.Free;
  inherited;
end;

{ TMyCloudFileCompareInfo }

constructor TMyCloudFileCompareInfo.Create;
begin
  PcIDList := TStringList.Create;
end;

destructor TMyCloudFileCompareInfo.Destroy;
begin
  PcIDList.Free;
  inherited;
end;

{ TBackupFileCompareThread }

constructor TBackupFileCompareThread.Create;
begin
  inherited Create( True );
end;

destructor TBackupFileCompareThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  inherited;
end;

procedure TBackupFileCompareThread.Execute;
begin
  inherited;

end;

{ TBackupFolderCompare }

procedure TBackupFolderCompare.CheckFiles;
var
  FileHash : TTempBackupFileHash;
  p : TTempBackupFilePair;
begin
  FileHash := TempBackupFolder.TempBackupFileHash;
  for p in FileHash do
  begin
    if not CheckNextCompare then
      Break;

//      copy

//    if p.Value.CheckCopyHash.ContainsKey( PcID ) and
//       p.Value.CheckCopyHash[ PcID ].

    FindFile( p.Value );
  end;
end;

procedure TBackupFolderCompare.CheckFolders;
var
  FolderHash : TTempBackupFolderHash;
  p : TTempBackupFolderPair;
  ChildFolderPath : string;
  BackupFolderCompare : TBackupFolderCompare;
begin
  FolderHash := TempBackupFolder.TempBackupFolderHash;
  for p in FolderHash do
  begin
    if not CheckNextCompare then
      Break;

    ChildFolderPath := BackupFolderPath + p.Value.FileName;
    BackupFolderCompare := TBackupFolderCompare.Create( PcID );
    BackupFolderCompare.SetBackupFolderPath( ChildFolderPath );
    BackupFolderCompare.Update;
    BackupFolderCompare.Free;
  end;
end;

function TBackupFolderCompare.CheckNextCompare: Boolean;
begin

end;

constructor TBackupFolderCompare.Create(_PcID: string);
begin
  PcID := _PcID;
  TempBackupFolder := TTempBackupFolderInfo.Create;
end;

destructor TBackupFolderCompare.Destroy;
begin
  TempBackupFolder.Free;
  inherited;
end;

procedure TBackupFolderCompare.FindFile(TempFileInfo : TTempBackupFileInfo);
begin

end;

procedure TBackupFolderCompare.FindTempBackupFolder;
var
  FindTempBackupFolderInfo : TFindTempBackupFolderInfo;
begin
  FindTempBackupFolderInfo := TFindTempBackupFolderInfo.Create;
  FindTempBackupFolderInfo.SetFolderPath( BackupFolderPath );
  FindTempBackupFolderInfo.SetTempBackupFolderInfo( TempBackupFolder );
  TempBackupFolder := FindTempBackupFolderInfo.get;
  FindTempBackupFolderInfo.Free;
end;

procedure TBackupFolderCompare.SetBackupFolderPath(_BackupFolderPath: string);
begin
  BackupFolderPath := _BackupFolderPath;
end;

procedure TBackupFolderCompare.Update;
begin
  FindTempBackupFolder;

  BackupFolderPath := MyFilePath.getPath( BackupFolderPath );

  CheckFiles;

  CheckFolders;
end;

end.
