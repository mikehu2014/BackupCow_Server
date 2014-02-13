unit UFmFilter;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, RzButton, ExtCtrls, Menus, ComCtrls, UMyUtil, UFileBaseInfo;

type
  TFrameFilter = class(TFrame)
    LvMask: TListView;
    PmSpaceLimit: TPopupMenu;
    Panel6: TPanel;
    btnSelectFile: TButton;
    btnAddMask: TButton;
    btnDelete: TButton;
    Addsmallerthan1: TMenuItem;
    Addlargerthan1: TMenuItem;
    BtnSpaceLimit: TButton;
    PmDeleteMask: TPopupMenu;
    Excludehiddenfiles1: TMenuItem;
    Excludesystemfiles1: TMenuItem;
    btnRemoveMask: TButton;
    procedure btnSelectFileClick(Sender: TObject);
    procedure btnAddMaskClick(Sender: TObject);
    procedure Addsmallerthan1Click(Sender: TObject);
    procedure Addlargerthan1Click(Sender: TObject);
    procedure BtnSpaceLimitMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LvMaskDeletion(Sender: TObject; Item: TListItem);
    procedure btnRemoveMaskMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Excludehiddenfiles1Click(Sender: TObject);
    procedure Excludesystemfiles1Click(Sender: TObject);
    procedure LvMaskChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure btnDeleteClick(Sender: TObject);
  private
    IsInclude : Boolean;
    RootPathList : TStringList; // 选择子路径
  private
    procedure AddBigSpaceMask( LimitSpace : Int64 );
    procedure AddSmallSpaceMask( LimitSpace : Int64 );
    procedure AddMask( Mask : string );
    procedure AddPathMask( Path : string );
    procedure AddHiddenFileMask;
    procedure AddSystemFileMask;
  public
    procedure SetIsInclude( _IsInclude : Boolean );
    procedure SetDefaultStatus;
    procedure ClearMask;
  public
    procedure SetRootPathList( _RootPathList : TStringList );
    procedure SetFilterList( FilterList : TFileFilterList );
    function getFilterList : TFileFilterList;
  public
    { Public declarations }
  end;

  LvMaskUtil = class
  public
    class function getSelectPathList( LvMask : TListView ) : TStringList;
    class procedure RemoveMask( LvMask: TListView; MaskStr : string );
  public
    class function FindMaskTypeIndex( LvMask: TListView; MaskType : string ): Integer;
    class procedure RemoveMaskType( LvMask: TListView; MaskType : string );
  private
    class function getMaskTypeInt( MaskType : string ): Integer;
  end;

  TLvMaskData = class
  public
    MaskType : string;
    MaskStr : string;
  public
    constructor Create( _MaskType, _MaskStr : string );overload;
    constructor Create( _MaskType : string; _MaskValue : Integer );overload;
  end;

const
  FilterTypeInt_SmallThan = 0;
  FilterTypeInt_LargerThan = 1;
  FilterTypeInt_SystemFile = 2;
  FilterTypeInt_HiddenFile = 3;
  FilterTypeInt_Mask = 4;
  FilterTypeInt_Path = 5;

implementation

Uses UFormFileSelect, UFormSelectMask, UFormSpaceLimit, UIconUtil;

{$R *.dfm}

{ TLvMastData }

constructor TLvMaskData.Create(_MaskType, _MaskStr: string);
begin
  MaskType := _MaskType;
  MaskStr := _MaskStr;
end;

procedure TFrameFilter.AddBigSpaceMask(LimitSpace: Int64);
var
  LvMaskData : TLvMaskData;
  SpaceIndex : Integer;
begin
  SpaceIndex := LvMaskUtil.FindMaskTypeIndex( LvMask, FilterType_LargerThan );

  LvMaskData := TLvMaskData.Create( FilterType_LargerThan, LimitSpace );
  with LvMask.Items.Insert(SpaceIndex) do
  begin
    Caption := MaskShow_LargerThan + MySize.getFileSizeStr( LimitSpace );
    ImageIndex := MyShellIconUtil.getBigThenIcon;
    Data := LvMaskData;
  end;
end;

procedure TFrameFilter.AddHiddenFileMask;
var
  InsertIndex : Integer;
  LvMaskData : TLvMaskData;
begin
  InsertIndex := LvMaskUtil.FindMaskTypeIndex( LvMask, FilterType_HiddenFile );

  LvMaskData := TLvMaskData.Create( FilterType_HiddenFile, '' );
  with LvMask.Items.Insert( InsertIndex ) do
  begin
    Caption := MaskShow_HiddenFile;
    ImageIndex := MyShellIconUtil.getSystemIcon;
    Data := LvMaskData;
  end;
end;

procedure TFrameFilter.Addlargerthan1Click(Sender: TObject);
var
  SpaceValue : Int64;
begin
    // 选择
  frmSpaceLimit.AddLargerThan;
  if frmSpaceLimit.ShowModal = mrCancel then
    Exit;

    // 删除存在的
  LvMaskUtil.RemoveMaskType( LvMask, FilterType_LargerThan );

    // 添加新的
  SpaceValue := frmSpaceLimit.getSpaceValue;
  AddBigSpaceMask( SpaceValue );
end;

procedure TFrameFilter.AddMask(Mask: string);
var
  InsertIndex : Integer;
  LvMaskData : TLvMaskData;
begin
  InsertIndex := LvMaskUtil.FindMaskTypeIndex( LvMask, FilterType_Mask );

  LvMaskData := TLvMaskData.Create( FilterType_Mask, Mask );
  with LvMask.Items.Insert( InsertIndex ) do
  begin
    Caption := Mask;
    ImageIndex := MyIcon.getIconByFileExt( Mask );
    Data := LvMaskData;
  end;
end;

procedure TFrameFilter.AddPathMask(Path: string);
var
  ShowStr : string;
  LvMaskData : TLvMaskData;
begin
  ShowStr := Path;
  if DirectoryExists( Path ) then
    ShowStr := MyFilePath.getPath( ShowStr ) + '*.*';

  LvMaskData := TLvMaskData.Create( FilterType_Path, Path );
  with LvMask.Items.Add do
  begin
    Caption := ShowStr;
    ImageIndex := MyIcon.getIconByFilePath( Path );
    Data := LvMaskData;
  end;
end;

procedure TFrameFilter.Addsmallerthan1Click(Sender: TObject);
var
  SpaceValue : Int64;
begin
    // 选择
  frmSpaceLimit.AddSmallerThan;
  if frmSpaceLimit.ShowModal = mrCancel then
    Exit;

    // 删除 存在的
  LvMaskUtil.RemoveMaskType( LvMask, FilterType_SmallThan );

    // 添加 新的
  SpaceValue := frmSpaceLimit.getSpaceValue;
  AddSmallSpaceMask( SpaceValue );
end;

procedure TFrameFilter.AddSmallSpaceMask(LimitSpace: Int64);
var
  SpaceIndex : Integer;
  LvMaskData : TLvMaskData;
begin
  SpaceIndex := LvMaskUtil.FindMaskTypeIndex( LvMask, FilterType_SmallThan );

  LvMaskData := TLvMaskData.Create( FilterType_SmallThan, LimitSpace );
  with LvMask.Items.Insert(SpaceIndex) do
  begin
    Caption := MaskShow_SmallerThan + MySize.getFileSizeStr( LimitSpace );
    ImageIndex := MyShellIconUtil.getSmallThenIcon;
    Data := LvMaskData;
  end;
end;


procedure TFrameFilter.AddSystemFileMask;
var
  InsertIndex : Integer;
  LvMaskData : TLvMaskData;
begin
  InsertIndex := LvMaskUtil.FindMaskTypeIndex( LvMask, FilterType_SystemFile );

  LvMaskData := TLvMaskData.Create( FilterType_SystemFile, '' );
  with LvMask.Items.Insert( InsertIndex ) do
  begin
    Caption := MaskShow_SystemFile;
    ImageIndex := MyShellIconUtil.getSystemIcon;
    Data := LvMaskData;
  end;
end;


procedure TFrameFilter.btnSelectFileClick(Sender: TObject);
var
  SelectPathList : TStringList;
  i : Integer;
begin
    // 获取 选择路径
  SelectPathList := LvMaskUtil.getSelectPathList( LvMask );
  frmFileSelect.AddRootFolder( RootPathList, SelectPathList );
  SelectPathList.Free;

    // Include Root
  if IsInclude then
    frmFileSelect.AddDefaultRoot;

    // 取消 选择
  if frmFileSelect.ShowModal = mrCancel then
    Exit;

    // 删除 旧的
  LvMaskUtil.RemoveMaskType( LvMask, FilterType_Path );

    // 设置 选择
  SelectPathList := frmFileSelect.getSelectFileList;
  for i := 0 to SelectPathList.Count - 1 do
    AddPathMask( SelectPathList[i] );
  SelectPathList.Free;
end;

procedure TFrameFilter.BtnSpaceLimitMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  pt:TPoint;
begin
  GetCursorPos(pt);
  PmSpaceLimit.Popup((pt.x-x),(pt.y+(BtnSpaceLimit.Height-y)));
end;

procedure TFrameFilter.ClearMask;
begin
  LvMask.Clear;
  btnDelete.Enabled := False;
end;

procedure TFrameFilter.Excludehiddenfiles1Click(Sender: TObject);
begin
  LvMaskUtil.RemoveMaskType( LvMask, FilterType_HiddenFile );
  AddHiddenFileMask;
end;

procedure TFrameFilter.Excludesystemfiles1Click(Sender: TObject);
begin
  LvMaskUtil.RemoveMaskType( LvMask, FilterType_SystemFile );
  AddSystemFileMask;
end;

function TFrameFilter.getFilterList: TFileFilterList;
var
  i : Integer;
  ItemData : TLvMaskData;
  FilterInfo : TFileFilterInfo;
begin
  Result := TFileFilterList.Create;
  for i := 0 to LvMask.Items.Count - 1 do
  begin
    ItemData := LvMask.Items[i].Data;
    FilterInfo := TFileFilterInfo.Create( ItemData.MaskType, ItemData.MaskStr );
    Result.Add( FilterInfo );
  end;
end;

procedure TFrameFilter.LvMaskChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  btnDelete.Enabled := LvMask.SelCount > 0;
end;

procedure TFrameFilter.LvMaskDeletion(Sender: TObject; Item: TListItem);
var
  ItemData : TObject;
begin
  ItemData := Item.Data;
  ItemData.Free;
end;

procedure TFrameFilter.SetDefaultStatus;
begin
    // 清空
  ClearMask;

    // Exclude
  if not IsInclude then
  begin
    AddHiddenFileMask;
    AddSystemFileMask;
  end;
end;

procedure TFrameFilter.SetFilterList(FilterList: TFileFilterList);
var
  i : Integer;
  FilterType, FilterStr : string;
begin
  for i := 0 to FilterList.Count - 1 do
  begin
    FilterType := FilterList[i].FilterType;
    FilterStr := FilterList[i].FilterStr;
    if FilterType = FilterType_SmallThan then
      AddSmallSpaceMask( StrToInt64Def( FilterStr, 0 ) )
    else
    if FilterType = FilterType_LargerThan then
      AddBigSpaceMask( StrToInt64Def( FilterStr, 0 ) )
    else
    if FilterType = FilterType_SystemFile then
      AddSystemFileMask
    else
    if FilterType = FilterType_HiddenFile then
      AddHiddenFileMask
    else
    if FilterType = FilterType_Mask then
      AddMask( FilterStr )
    else
    if FilterType = FilterType_Path then
      AddPathMask( FilterStr );
  end;
end;

procedure TFrameFilter.SetIsInclude(_IsInclude: Boolean);
begin
  IsInclude := _IsInclude;
  LvMask.SmallImages := MyIcon.getSysIcon;
end;

procedure TFrameFilter.SetRootPathList(_RootPathList : TStringList);
begin
  RootPathList := _RootPathList;
end;

procedure TFrameFilter.btnAddMaskClick(Sender: TObject);
var
  MaskStr : string;
begin
    // 取消 选择
  if FrmEnterMask.ShowModal = mrCancel then
    Exit;

    // 读取 选择
  MaskStr := FrmEnterMask.getMaskStr;

    // 删除 相同的
  LvMaskUtil.RemoveMask( LvMask, MaskStr );

    // 添加 选择
  AddMask( MaskStr );
end;

procedure TFrameFilter.btnDeleteClick(Sender: TObject);
begin
  LvMask.DeleteSelected;
end;

procedure TFrameFilter.btnRemoveMaskMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  pt:TPoint;
begin
  GetCursorPos(pt);
  PmDeleteMask.Popup((pt.x-x-btnAddMask.Width),(pt.y+(btnAddMask.Height-y)));
end;

{ LvMaskUtil }

class function LvMaskUtil.FindMaskTypeIndex(LvMask: TListView;
  MaskType: string): Integer;
var
  NewMaskInt : Integer;
  i : Integer;
  LvMaskData : TLvMaskData;
begin
  NewMaskInt := getMaskTypeInt( MaskType );

  for i := 0 to LvMask.Items.Count - 1 do
  begin
    LvMaskData := LvMask.Items[i].Data;
    if NewMaskInt < getMaskTypeInt( LvMaskData.MaskType ) then
    begin
      Result := i;
      Break;
    end;
  end;
end;

class function LvMaskUtil.getMaskTypeInt(MaskType: string): Integer;
begin
  if MaskType = FilterType_SmallThan then
    Result := FilterTypeInt_SmallThan
  else
  if MaskType = FilterType_LargerThan then
    Result := FilterTypeInt_LargerThan
  else
  if MaskType = FilterType_SystemFile then
    Result := FilterTypeInt_SystemFile
  else
  if MaskType = FilterType_HiddenFile then
    Result := FilterTypeInt_HiddenFile
  else
  if MaskType = FilterType_Mask then
    Result := FilterTypeInt_Mask
  else
  if MaskType = FilterType_Path then
    Result := FilterTypeInt_Path
end;

class function LvMaskUtil.getSelectPathList( LvMask : TListView ): TStringList;
var
  i : Integer;
  LvMaskData : TLvMaskData;
begin
  Result := TStringList.Create;
  for i := 0 to LvMask.Items.Count - 1 do
  begin
    LvMaskData := LvMask.Items[i].Data;
    if LvMaskData.MaskType = FilterType_Path then
      Result.Add( LvMaskData.MaskStr );
  end;
end;

class procedure LvMaskUtil.RemoveMask(LvMask: TListView; MaskStr: string);
var
  i : Integer;
  LvMaskData : TLvMaskData;
begin
  for i := LvMask.Items.Count - 1 downto 0 do
  begin
    LvMaskData := LvMask.Items[i].Data;
    if ( LvMaskData.MaskType = FilterType_Mask ) and ( LvMaskData.MaskStr = MaskStr ) then
      LvMask.Items.Delete(i);
  end;
end;

class procedure LvMaskUtil.RemoveMaskType(LvMask: TListView; MaskType: string);
var
  i : Integer;
  LvMaskData : TLvMaskData;
begin
  for i := LvMask.Items.Count - 1 downto 0 do
  begin
    LvMaskData := LvMask.Items[i].Data;
    if LvMaskData.MaskType = MaskType then
      LvMask.Items.Delete(i);
  end;
end;

constructor TLvMaskData.Create(_MaskType: string; _MaskValue: Integer);
begin
  Create( _MaskType, IntToStr( _MaskValue ) );
end;

end.
