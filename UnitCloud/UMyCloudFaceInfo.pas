unit UMyCloudFaceInfo;

interface

uses UChangeInfo, comctrls, UMyUtil, UIconUtil, SysUtils;

type

  TSharePathData = class
  public
    SharePath : string;
  public
    constructor Create( _SharePath : string );
  end;

    // 父类
  TCloudPathChangeFace = class( TFaceChangeInfo )
  public
    LvSharePath : TListView;
  protected
    procedure Update;override;
  end;

    // 修改
  TCloudPathWriteFace = class( TCloudPathChangeFace )
  public
    SharePath : string;
  protected
    SharePathItem : TListItem;
    SharePathData : TSharePathData;
    SharePathIndex : Integer;
  public
    constructor Create( _SharePath : string );
  protected
    function FindSharePathItem : Boolean;
  end;

    // 添加
  TCloudPathAddFace = class( TCloudPathWriteFace )
  protected
    procedure Update;override;
  end;

    // 刷新空间信息
  TCloudPathRefreshFace = class( TCloudPathWriteFace )
  protected
    procedure Update;override;
  end;

    // 删除
  TCloudPathRemoveFace = class( TCloudPathWriteFace )
  protected
    procedure Update;override;
  end;



implementation

uses UFormSetting;

{ TCloudPathChangeFace }

procedure TCloudPathChangeFace.Update;
begin
  LvSharePath := frmSetting.lvSharePath;
end;

{ TCloudPathWriteFace }

constructor TCloudPathWriteFace.Create(_SharePath: string);
begin
  SharePath := _SharePath;
end;

function TCloudPathWriteFace.FindSharePathItem: Boolean;
var
  i : Integer;
  ItemData : TSharePathData;
begin
  Result := False;
  for i := 0 to LvSharePath.Items.Count - 1 do
  begin
    ItemData := LvSharePath.Items[i].Data;
    if ItemData.SharePath = SharePath then
    begin
      SharePathIndex := i;
      SharePathItem := LvSharePath.Items[i];
      SharePathData := ItemData;
      Result := True;
      Break;
    end;
  end;
end;

{ TCloudPathAddFace }

procedure TCloudPathAddFace.Update;
begin
  inherited;

  if FindSharePathItem then
    Exit;

  SharePathItem := LvSharePath.Items.Add;
  SharePathItem.Caption := SharePath;
  SharePathItem.SubItems.Add( MySize.getFileSizeStr( MyHardDisk.getHardDiskFreeSize( SharePath ) ) );
  if DirectoryExists( SharePath ) then
    SharePathItem.ImageIndex := MyIcon.getIconByFilePath( SharePath )
  else
    SharePathItem.ImageIndex := MyShellIconUtil.getFolderIcon;

  SharePathData := TSharePathData.Create( SharePath );
  SharePathItem.Data := SharePathData;
end;

{ TCloudPathRemoveFace }

procedure TCloudPathRemoveFace.Update;
begin
  inherited;

  if not FindSharePathItem then
    Exit;

  LvSharePath.Items.Delete( SharePathIndex );
end;

{ TSharePathData }

constructor TSharePathData.Create(_SharePath: string);
begin
  SharePath := _SharePath;
end;

{ TCloudPathRefreshFace }

procedure TCloudPathRefreshFace.Update;
begin
  inherited;

  if not FindSharePathItem then
    Exit;

  SharePathItem.SubItems[0] := MySize.getFileSizeStr( MyHardDisk.getHardDiskFreeSize( SharePath ) );
end;

end.
