unit UIconUtil;

interface

uses Controls, ShellAPI, SysUtils, Windows, Graphics, Forms, UMyUtil, Classes, IniFiles, uDebug,
     ExtCtrls;

type

    // 系统图标类
  TMyIcon = class
  private
    SysIcon: TImageList;
    SysIcon32 : TImageList;
  public
    constructor Create;
    procedure SaveMyIcon;
    destructor Destroy; override;
  private
    procedure SaveShellIcon;
    function getIconEdition : Boolean;
    procedure SaveImgList( il : TImageList; IsOldEdition : Boolean );
    procedure setIconEdition;
  public
    function getSysIcon: TImageList;
    function getSysIcon32 : TImageList;
  public
    function getIconByFilePath(FilePath: string): Integer;
    function getIconByFileExt(FileName: string): Integer;
  public
    procedure Set32Icon( il : TImage; FilePath : string );
  public
    function getIconByPath( PathType, Path : string ): Integer;
  end;

    // 图标路径
  MyIconPathUtil = class
  public
    class function getResourcesPath : string;
    class function getResourceIniPath : string;
  end;

    // 系统文件图标
  MyShellIconUtil = class
  public
    class function getFileIcon : Integer;
    class function getFolderIcon : Integer;
    class function getFolderExpandIcon : Integer;
    class function getSystemIcon : Integer;
    class function getBigThenIcon : Integer;
    class function getSmallThenIcon : Integer;
  private
    class function getShellIcon( IconIndex : Integer ): Integer;
    class function getShellFolder : string;
  public
    class function getLocalFileIcon( FullPath : string; IsFile : Boolean ): Integer;
  end;

    // 父类
  MyShellIconBaseUtil = class
  protected
    class function getShellIcon( IconIndex : Integer ): Integer;
    class function getShellFolder : string;
    class function getImageListName : string;virtual;abstract;
  end;

    // 备份状态图标
  MyShellBackupStatusIconUtil = class( MyShellIconBaseUtil )
  public
    class function getFileIncompleted : Integer;
    class function getFilePartcompleted : Integer;
    class function getFilecompleted : Integer;
  protected
    class function getImageListName : string;override;
  end;

    // 传输状态图标
  MyShellTransActionIconUtil =  class( MyShellIconBaseUtil )
  public
    class function getWaiting : Integer;
    class function getDownLoading : Integer;
    class function getUpLoading : Integer;
    class function getLoaded : Integer;
    class function getLoadedError : Integer;
  public
    class function getRecycle : Integer;
    class function getCopyFile : Integer;
    class function getDisable : Integer;
    class function getAnalyze : Integer;
    class function getSave : Integer;
    class function getRecycle2 : Integer;
    class function getSync : Integer;
    class function getEncrypted : Integer;
    class function getDate : Integer;
  protected
    class function getImageListName : string;override;
  end;

    // 图标保存到磁盘
  TSaveImgListHandle = class
  private
    ImgList : TImageList;
    IsOldEdition : Boolean;
  public
    constructor Create( _ImgList : TImageList );
    procedure SetIsOldEdition( _IsOldEdition : Boolean );
    procedure Update;
  end;

const
  AppFolderName_Resources = 'Resources';
  IconEdition_Now = 1;

  IconIni_Section = 'Icons';
  IconIni_Name = 'IconEdition';

  ShellIcon_File = 0;
  ShellIcon_Folder = 1;
  ShellIcon_FolderExpand = 2;
  ShellIcon_SystemFile = 3;
  ShellIcon_Smallthen = 4;
  ShellIcon_Bigthen = 5;

  ShellBackupStatus_FileIncompleted = 0;
  ShellBackupStatus_FilePartCompleted = 1;
  ShellBackupStatus_FileCompleted = 2;

  ShellTranAction_Waiting = 0;
  ShellTranAction_DownLoading = 1;
  ShellTranAction_Loaded = 2;
  ShellTranAction_LoadedError = 3;
  ShellTranAction_Recycle = 4;
  ShellTranAction_CopyFile = 5;
  ShellTranAction_Disable = 6;
  ShellTranAction_Uploading = 7;
  ShellTranAction_Analyze = 8;
  ShellTranAction_Save = 9;
  ShellTranAction_Recycle2 = 10;
  ShellTranAction_Sync = 11;
  ShellTranAction_Encrypted = 12;
  ShellTranAction_Date = 13;

var
  MyIcon : TMyIcon;

implementation

uses UMainForm;

{ TMyIcon }

function TMyIcon.getIconEdition: Boolean;
var
  IniFile : TIniFile;
  IconEdition : Integer;
begin
  IniFile := TIniFile.Create( MyIconPathUtil.getResourceIniPath );
  IconEdition := IniFile.ReadInteger( IconIni_Section, IconIni_Name, -1 );
  IniFile.Free;

  Result := IconEdition = IconEdition_Now;
end;

constructor TMyIcon.Create;
var
  SysIL, SysIL32 : THandle;
  SFI, SFI32 : TSHFileInfo;
begin
  try   // 16 * 16 系统图标 创建
    SysIcon := TImageList.Create(nil);
    SysIL := SHGetFileInfo('', 0, SFI, SizeOf(SFI), SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
    if SysIL <> 0 then
    begin
      SysIcon.Handle := SysIL;
      SysIcon.ShareImages := TRUE;
    end;
  except
  end;

  try  // 32 * 32 系统图标 创建
    SysIcon32 := TImageList.Create( nil );
    SysIL32 := SHGetFileInfo('', 0, SFI32, SizeOf(SFI32), SHGFI_SYSICONINDEX or SHGFI_LARGEICON);
    if SysIL32 <> 0 then
    begin
      SysIcon32.Handle := SysIL32;
      SysIcon32.ShareImages := TRUE;
    end;
  except
  end;
end;

destructor TMyIcon.Destroy;
begin
  SysIcon32.Free;
  SysIcon.Free;
  inherited;
end;

function TMyIcon.getIconByFileExt(FileName: string): Integer;
var
  FileInfo: TSHFileInfo;
begin
  try
    FileInfo.iIcon := 0;

    SHGetFileInfo(pchar('*' + ExtractFileExt(FileName)), 0, FileInfo, SizeOf(TSHFileInfo),
      SHGFI_SYSICONINDEX or SHGFI_SMALLICON or SHGFI_USEFILEATTRIBUTES);

    DestroyIcon(FileInfo.hIcon);
    Result := FileInfo.iIcon;
  except
    Result := 0;
  end;

  if Result = 0 then
    Result := MyShellIconUtil.getFileIcon;
end;


function TMyIcon.getIconByFilePath(FilePath: string): Integer;
var
  FileInfo: TSHFileInfo;
begin
    // 文件或目录存在
  try
    if FileExists( FilePath ) or DirectoryExists( FilePath ) then
    begin
      FileInfo.iIcon := 0;

      SHGetFileInfo(pchar(FilePath), 0, FileInfo, SizeOf(TSHFileInfo), SHGFI_SYSICONINDEX or SHGFI_SMALLICON);

      DestroyIcon(FileInfo.hIcon);
      Result := FileInfo.iIcon;
    end
    else   // 文件不存在则取后缀名
      Result := getIconByFileExt( FilePath );
  except
    Result := 0;
  end;

  if Result = 0 then
    Result := MyShellIconUtil.getFileIcon;;
end;

function TMyIcon.getIconByPath(PathType, Path: string): Integer;
begin
  if MyFilePath.getIsExist( Path ) then
    Result := getIconByFilePath( Path )
  else
  if PathType = PathType_File then
    Result := getIconByFileExt( Path )
  else
    Result := MyShellIconUtil.getFolderIcon;
end;

function TMyIcon.getSysIcon: TImageList;
begin
  Result := SysIcon;
end;

function TMyIcon.getSysIcon32: TImageList;
begin
  Result := SysIcon32;
end;

procedure TMyIcon.setIconEdition;
var
  IniFile : TIniFile;
begin
      // 无法写入 Ini
  if not MyIniFile.ConfirmWriteIni then
    Exit;


  IniFile := TIniFile.Create( MyIconPathUtil.getResourceIniPath );
  try
    IniFile.WriteInteger( IconIni_Section, IconIni_Name, IconEdition_Now );
  except
  end;
  IniFile.Free;

  MyHideFile.Hide( MyIconPathUtil.getResourceIniPath );
end;

procedure TMyIcon.SaveImgList(il: TImageList;
  IsOldEdition : Boolean);
var
  SaveImgListHandle : TSaveImgListHandle;
begin
  SaveImgListHandle := TSaveImgListHandle.Create( il );
  SaveImgListHandle.SetIsOldEdition( IsOldEdition );
  SaveImgListHandle.Update;
  SaveImgListHandle.Free;
end;

procedure TMyIcon.SaveMyIcon;
begin
    // 保存 自定义图标
  try
    SaveShellIcon;
  except
  end;
end;

procedure TMyIcon.SaveShellIcon;
var
  IsOldEdition : Boolean;
begin
  IsOldEdition := getIconEdition;
  SaveImgList( frmMainForm.ilShellFile, IsOldEdition );
  SaveImgList( frmMainForm.iShellBackupStatus, IsOldEdition );
  SaveImgList( frmMainForm.ilShellTransAction, IsOldEdition );
  setIconEdition;
end;

procedure TMyIcon.Set32Icon(il: TImage; FilePath: string);
begin
  try
    SysIcon32.GetIcon( getIconByFilePath( FilePath ), il.Picture.Icon );
  except
  end;
end;

{ TSaveImgList }

constructor TSaveImgListHandle.Create(_ImgList: TImageList);
begin
  ImgList := _ImgList;
end;

procedure TSaveImgListHandle.SetIsOldEdition(_IsOldEdition: Boolean);
begin
  IsOldEdition := _IsOldEdition;
end;

procedure TSaveImgListHandle.Update;
var
  i : Integer;
  Icon : TIcon;
  FolderPath, FilePath : string;
begin
  FolderPath := MyIconPathUtil.getResourcesPath + ImgList.Name;
  ForceDirectories( FolderPath );

  FolderPath := MyFilePath.getPath( FolderPath );
  for i := 0 to ImgList.Count - 1 do
  begin
    FilePath := FolderPath + IntToStr(i) + '.ico';

    if FileExists( FilePath ) and IsOldEdition then
      Continue;

    Icon := TIcon.Create;
    ImgList.GetIcon( i, Icon );
    Icon.SaveToFile( FilePath );
    Icon.Free;
  end;
end;

{ MyIconUtil }

class function MyShellIconUtil.getBigThenIcon: Integer;
begin
  Result := getShellIcon( ShellIcon_Bigthen );
end;

class function MyShellIconUtil.getFileIcon: Integer;
begin
  Result := getShellIcon( ShellIcon_File )
end;

class function MyShellIconUtil.getFolderExpandIcon: Integer;
begin
  Result := getShellIcon( ShellIcon_FolderExpand );
end;

class function MyShellIconUtil.getFolderIcon: Integer;
begin
  Result := getShellIcon( ShellIcon_Folder );
end;

class function MyShellIconUtil.getLocalFileIcon(FullPath: string;
  IsFile: Boolean): Integer;
begin
  if IsFile then
    Result := MyIcon.getIconByFilePath( FullPath )
  else
  if DirectoryExists( FullPath ) then
    Result := MyIcon.getIconByFilePath( FullPath )
  else
    Result := MyShellIconUtil.getFolderIcon;
end;

class function MyShellIconUtil.getShellFolder: string;
begin
  Result := MyIconPathUtil.getResourcesPath + frmMainForm.ilShellFile.Name;
  Result := MyFilePath.getPath( Result );
end;

class function MyShellIconUtil.getShellIcon(IconIndex: Integer): Integer;
var
  FilePath : string;
  FileInfo: TSHFileInfo;
begin
  FilePath := getShellFolder;
  FilePath := FilePath + IntToStr( IconIndex ) + '.ico';

  FileInfo.iIcon := 0;
  SHGetFileInfo(pchar(FilePath), 0, FileInfo, SizeOf(TSHFileInfo), SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
  DestroyIcon(FileInfo.hIcon);
  Result := FileInfo.iIcon;
end;

class function MyShellIconUtil.getSmallThenIcon: Integer;
begin
  Result := getShellIcon( ShellIcon_Smallthen );
end;

class function MyShellIconUtil.getSystemIcon: Integer;
begin
  Result := getShellIcon( ShellIcon_SystemFile );
end;

{ MyIconPathUtil }

class function MyIconPathUtil.getResourceIniPath: string;
begin
  Result := getResourcesPath;
  Result := Result + 'Icon.ini';
end;

class function MyIconPathUtil.getResourcesPath: string;
begin
  Result := MyAppDataUtil.getPath + AppFolderName_Resources;
  Result := MyFilePath.getPath( Result );
end;

{ MyShellBackupStatusIconUtil }

class function MyShellBackupStatusIconUtil.getFilecompleted: Integer;
begin
  Result := getShellIcon( ShellBackupStatus_Filecompleted );
end;

class function MyShellBackupStatusIconUtil.getFileIncompleted: Integer;
begin
  Result := getShellIcon( ShellBackupStatus_FileIncompleted );
end;

class function MyShellBackupStatusIconUtil.getFilePartcompleted: Integer;
begin
  Result := getShellIcon( ShellBackupStatus_FilePartCompleted );
end;

class function MyShellBackupStatusIconUtil.getImageListName: string;
begin
  Result := frmMainForm.iShellBackupStatus.Name;
end;


{ MyShellTransActionIconUtil }

class function MyShellTransActionIconUtil.getAnalyze: Integer;
begin
  Result := getShellIcon( ShellTranAction_Analyze );
end;

class function MyShellTransActionIconUtil.getCopyFile: Integer;
begin
  Result := getShellIcon( ShellTranAction_CopyFile );
end;

class function MyShellTransActionIconUtil.getDate: Integer;
begin
  Result := getShellIcon( ShellTranAction_Date );
end;

class function MyShellTransActionIconUtil.getDisable: Integer;
begin
  Result := getShellIcon( ShellTranAction_Disable );
end;

class function MyShellTransActionIconUtil.getImageListName: string;
begin
  Result := frmMainForm.ilShellTransAction.Name;
end;

class function MyShellTransActionIconUtil.getLoaded: Integer;
begin
  Result := getShellIcon( ShellTranAction_Loaded );
end;

class function MyShellTransActionIconUtil.getLoadedError: Integer;
begin
  Result := getShellIcon( ShellTranAction_LoadedError );
end;

class function MyShellTransActionIconUtil.getDownLoading: Integer;
begin
  Result := getShellIcon( ShellTranAction_DownLoading );
end;

class function MyShellTransActionIconUtil.getEncrypted: Integer;
begin
  Result := getShellIcon( ShellTranAction_Encrypted );
end;

class function MyShellTransActionIconUtil.getRecycle: Integer;
begin
  Result := getShellIcon( ShellTranAction_Recycle );
end;

class function MyShellTransActionIconUtil.getRecycle2: Integer;
begin
  Result := getShellIcon( ShellTranAction_Recycle2 );
end;

class function MyShellTransActionIconUtil.getSave: Integer;
begin
  Result := getShellIcon( ShellTranAction_Save );
end;

class function MyShellTransActionIconUtil.getSync: Integer;
begin
  Result := getShellIcon( ShellTranAction_Sync );
end;

class function MyShellTransActionIconUtil.getUpLoading: Integer;
begin
  Result := getShellIcon( ShellTranAction_UpLoading );
end;

class function MyShellTransActionIconUtil.getWaiting: Integer;
begin
  Result := getShellIcon( ShellTranAction_Waiting );
end;

{ MyShellIconBaseUtil }

class function MyShellIconBaseUtil.getShellFolder: string;
begin
  Result := MyIconPathUtil.getResourcesPath + getImageListName;
  Result := MyFilePath.getPath( Result );
end;

class function MyShellIconBaseUtil.getShellIcon(IconIndex: Integer): Integer;
var
  FilePath : string;
  FileInfo: TSHFileInfo;
begin
  FilePath := getShellFolder;
  FilePath := FilePath + IntToStr( IconIndex ) + '.ico';
  Result := MyIcon.getIconByFilePath( FilePath );
end;

end.
