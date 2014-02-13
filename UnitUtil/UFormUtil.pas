unit UFormUtil;

interface

uses ComCtrls, Controls, Menus, Generics.Collections, UModelUtil, Math, ListActns,
     SysUtils, UMyUtil, Classes, virtualtrees, StdCtrls, Windows, Forms;

type

  TTbMapping = class
  public
    pmName : string;
    tb : TToolBar;
  public
    constructor Create( _PcName : string; _tb : TToolBar );
  end;

  TTbMappingHash = class( TStringDictionary< TTbMapping > )end;

  FormUtil = class
  public
    class function getPopMenu( tb : TToolBar ) : TPopupMenu; overload;
    class function getPopMenu( tb : TToolBar; pm : TPopupMenu ): TPopupMenu; overload;
    class procedure PmPopup(Sender: TObject);
    class procedure EnableToolbar( tb : TToolBar; IsEnable : Boolean );
  public
    class procedure BindEnterNext( edt : TEdit );
    class procedure BindEseClose( frm : TForm );
  public
    class function ForceForegroundWindow(hwnd: THandle): boolean;
    class procedure SetFocuse( c : TWinControl );
  private
    class function getHintShow( OldStr : string ): string;
    class procedure edtKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    class procedure FormKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
  end;


  ListviewUtil = class
  public
    class procedure AddSubitem( ListItem : TListItem; Count : Integer );
  public
    class procedure MoveToTop( listItem : TListItem );
    class procedure MoveToSecond( listItem : TListItem );
    class procedure MoveToBottom( listItem : TListItem );
    class procedure CopyData( NewListItem, OldListItem : TListItem );
  public
    class procedure BindRemoveData( Lv : TListView );
    class procedure LvDeletion(Sender: TObject; Item: TListItem);
  public
    class procedure BindSort( ListView : TListView );
    class procedure ColumnClick( Sender: TObject; Column: TListColumn );
    class procedure ItemCompare( Sender: TObject; Item1, Item2: TListItem;
                                         Data: Integer; var Compare: Integer);
  end;

  ComboboxUtil = class
  public
    class procedure ClearData( ccb : TComboBoxEx );
  public
    class procedure MoveToTop( cbb : TComboBoxEx; cbbItem : TListControlItem );
    class procedure MoveToSecond( cbb : TComboBoxEx; cbbItem : TListControlItem );
    class procedure MoveToBottom( cbb : TComboBoxEx; cbbItem : TListControlItem );
    class procedure CopyData( NewcbbItem, OldcbbItem : TListControlItem );
  end;

  VirtualTreeUtil = class
  public
    class procedure MoveToTop( vst : TVirtualStringTree; Node : PVirtualNode );
    class procedure MoveToSecond( vst : TVirtualStringTree; Node : PVirtualNode );
    class procedure MoveToBottom( vst : TVirtualStringTree; Node : PVirtualNode );
  public
    class procedure BindSort( vst : TVirtualStringTree );
    class procedure VstHeaderClick( Sender: TVTHeader; HitInfo: TVTHeaderHitInfo );
  end;

const
  ColunmTag_Number = 1;

  SortType_String = 0;
  SortType_Size = 1;
  SortType_Int = 2;
  SortType_Percentage = 3;
  SortType_Count = 4;

    // 特别的 Button
  ToolBtnTag_Disable = -1;
  ToolBtnTag_ChangeFace = 1;

var
  TbMappingHash : TTbMappingHash;

implementation

{ FormUtil }

class function FormUtil.getPopMenu(tb: TToolBar): TPopupMenu;
var
  pm : TPopupMenu;
begin
  pm := TPopupMenu.Create( tb.Owner );
  pm.Name := 'Pm' + tb.Name;

  Result := getPopMenu( tb, pm );
end;

class procedure FormUtil.BindEnterNext(edt: TEdit);
begin
  edt.OnKeyUp := EdtKeyUp;
end;

class procedure FormUtil.BindEseClose(frm: TForm);
begin
  frm.KeyPreview := True;
  frm.OnKeyDown := FormKeyDown;
end;

class procedure FormUtil.edtKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

class procedure FormUtil.EnableToolbar(tb: TToolBar; IsEnable: Boolean);
var
  i : Integer;
  tbtn : TToolButton;
begin
  for i := 0 to tb.ButtonCount - 1 do
  begin
    tbtn := tb.Buttons[i];
    if tbtn.Style = tbsSeparator then // 分割条
      Continue;
    tbtn.Enabled := IsEnable;
  end;
end;

class function FormUtil.ForceForegroundWindow(hwnd: THandle): boolean;
const
    SPI_GETFOREGROUNDLOCKTIMEOUT = $2000;
    SPI_SETFOREGROUNDLOCKTIMEOUT = $2001;
var
    ForegroundThreadID: DWORD;
    ThisThreadID      : DWORD;
    timeout           : DWORD;
begin

  try

  if IsIconic(hwnd) then ShowWindow(hwnd, SW_RESTORE);

  // Windows 98/2000 doesn't want to foreground a window when some other
  // window has keyboard focus

  if ((Win32Platform = VER_PLATFORM_WIN32_NT) and (Win32MajorVersion > 4))
      or
      ((Win32Platform = VER_PLATFORM_WIN32_WINDOWS) and
      ((Win32MajorVersion > 4) or ((Win32MajorVersion = 4) and
       (Win32MinorVersion > 0)))) then begin
      // Code from Karl E. Peterson, www.mvps.org/vb/sample.htm
      // Converted to Delphi by Ray Lischner
      // Published in The Delphi Magazine 55, page 16

      Result := false;
      ForegroundThreadID := GetWindowThreadProcessID(GetForegroundWindow,nil);
      ThisThreadID := GetWindowThreadPRocessId(hwnd,nil);
      if AttachThreadInput(ThisThreadID, ForegroundThreadID, true) then begin
          BringWindowToTop(hwnd); // IE 5.5 related hack
          SetForegroundWindow(hwnd);
          AttachThreadInput(ThisThreadID, ForegroundThreadID, false);
          Result := (GetForegroundWindow = hwnd);
      end;

      if not Result then begin
          // Code by Daniel P. Stasinski
          SystemParametersInfo(SPI_GETFOREGROUNDLOCKTIMEOUT, 0, @timeout, 0);
          SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, TObject(0), SPIF_SENDCHANGE);
          BringWindowToTop(hwnd); // IE 5.5 related hack
          SetForegroundWindow(hWnd);
          SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, TObject(timeout), SPIF_SENDCHANGE);
      end;
  end
  else begin
      BringWindowToTop(hwnd); // IE 5.5 related hack
      SetForegroundWindow(hwnd);
  end;

  Result := (GetForegroundWindow = hwnd);
  except
  end;
end;

class procedure FormUtil.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Frm : TForm;
begin
  if ( Key = VK_ESCAPE ) and ( frm is TForm ) then
  begin
    Frm := Sender as TForm;
    Frm.Close;
  end;
end;

class function FormUtil.getHintShow(OldStr: string): string;
var
  SplitList : TStringList;
  i : Integer;
  ShowStr : string;
begin
  Result := '';

  SplitList := MySplitStr.getList( OldStr, ' ' );
  if SplitList.Count > 1 then
  begin
    for i := 0 to SplitList.Count - 1 do
    begin
      ShowStr := SplitList[i];
      if i = 0 then
        Result := ShowStr
      else
        Result := Result + ' ' + LowerCase( ShowStr );
    end;
  end
  else
    Result := OldStr;
  SplitList.Free;
end;


class function FormUtil.getPopMenu(tb: TToolBar;
  pm: TPopupMenu): TPopupMenu;
var
  mi : TMenuItem;
  i : Integer;
  tbtn : TToolButton;
  TbMapping : TTbMapping;
begin
  pm.Images := tb.Images;

  TbMapping := TTbMapping.Create( pm.Name, tb );
  TbMappingHash.AddOrSetValue( pm.Name, TbMapping );

  pm.OnPopup := PmPopup;

  for i := 0 to tb.ButtonCount - 1 do
  begin
    tbtn := tb.Buttons[i];
    tbtn.Hint := getHintShow( tbtn.Hint );

      // 不添加
    if tbtn.Tag = ToolBtnTag_Disable then
      Continue;

    mi := TMenuItem.Create( pm );
    if tbtn.Style = tbsSeparator then // 分割条
      mi.Caption := '-'
    else
    if tbtn.Caption = '' then
      mi.Caption := tbtn.Hint
    else
      mi.Caption := tbtn.Caption;
    mi.ImageIndex := tbtn.ImageIndex;
    mi.OnClick := tbtn.OnClick;

    pm.Items.Add( mi );
  end;

  Result := pm;
end;

class procedure FormUtil.PmPopup(Sender: TObject);
var
  pm : TPopupMenu;
  PmName : string;
  tb : TToolBar;
  Count, i, j : Integer;
  mi : TMenuItem;
  tbtn : TToolButton;
begin
  pm := ( Sender as TPopupMenu );
  PmName := pm.Name;

  if not TbMappingHash.ContainsKey( PmName ) then
    Exit;

  tb := TbMappingHash[ PmName ].tb;
  Count := Min( pm.Items.Count, tb.ButtonCount );

  j := 0;
  for i := 0 to Count - 1 do
  begin
    mi := pm.Items[i];
    while tb.Buttons[j].Tag = ToolBtnTag_Disable do
      Inc(j);
    tbtn := tb.Buttons[j];

    mi.Visible := tbtn.Enabled;

    if ( tbtn.Tag = ToolBtnTag_ChangeFace ) then
    begin
      if mi.ImageIndex <> tbtn.ImageIndex then
        mi.ImageIndex := tbtn.ImageIndex;

      if mi.Caption <> tbtn.Caption then
        mi.Caption := tbtn.Caption;
    end;
    Inc(j);
  end;
end;

class procedure FormUtil.SetFocuse(c: TWinControl);
begin
  try
    c.SetFocus;
  except
  end;
end;

{ TTbMapping }

constructor TTbMapping.Create(_PcName: string; _tb: TToolBar);
begin
  pmName := _PcName;
  tb := _tb;
end;

{ ListviewUtil }

class procedure ListviewUtil.AddSubitem(ListItem: TListItem; Count: Integer);
var
  i : Integer;
begin
  for i := 0 to Count - 1 do
    ListItem.SubItems.Add('');
end;

class procedure ListviewUtil.BindRemoveData(Lv: TListView);
begin
  Lv.OnDeletion := LvDeletion;
end;

class procedure ListviewUtil.BindSort(ListView: TListView);
begin
  ListView.OnColumnClick := ColumnClick;
  ListView.OnCompare := ItemCompare;
end;

class procedure ListviewUtil.ColumnClick(Sender: TObject; Column: TListColumn);
var
  lv : TListView;
  IsSmallToBig : Boolean;
  OldSortNumber : Integer;
  ColumnNum, SortNum, SortType, LvTag : Integer;
begin
  lv := Sender as TListView;
  LvTag := lv.Tag;
  OldSortNumber := ( LvTag mod 1000 ) div 100;
  SortNum := ( OldSortNumber + 1 ) mod 2;

  ColumnNum := Column.Index;
  SortNum := SortNum * 100;
  SortType := Column.Tag * 1000;
  LvTag := ColumnNum + SortNum + SortType;
  lv.Tag := LvTag;

  lv.AlphaSort;
end;

class procedure ListviewUtil.CopyData(NewListItem, OldListItem: TListItem);
var
  i : Integer;
begin
  NewListItem.Caption := OldListItem.Caption;
  NewListItem.ImageIndex := OldListItem.ImageIndex;
  for i := 0 to OldListItem.SubItems.Count - 1 do
  begin
    NewListItem.SubItems.Add( OldListItem.SubItems[i] );
    NewListItem.SubItemImages[i] := OldListItem.SubItemImages[i];
  end;

  NewListItem.Data := OldListItem.Data;
  OldListItem.Data := nil;
end;

class procedure ListviewUtil.ItemCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
var
  LvTag : Integer;
  ColumnNum, SortNum, SortType : Integer;
  ItemStr1, ItemStr2 : string;
  SortStr1, SortStr2 : string;
  CompareSize : Int64;
begin
  LvTag := ( Sender as TListView ).Tag;

  SortType := LvTag div 1000;
  LvTag := LvTag mod 1000;
  SortNum := LvTag div 100;
  LvTag := LvTag mod 100;
  ColumnNum := LvTag;

    // 找出 要排序的列
  if ColumnNum = 0 then
  begin
    ItemStr1 := Item1.Caption;
    ItemStr2 := Item2.Caption;
  end
  else
  begin
    ItemStr1 := Item1.SubItems[ ColumnNum - 1 ];
    ItemStr2 := Item2.SubItems[ ColumnNum - 1 ];
  end;

    // 正序/倒序 排序
  if SortNum = 1 then
  begin
    SortStr1 := ItemStr1;
    SortStr2 := ItemStr2;
  end
  else
  begin
    SortStr1 := ItemStr2;
    SortStr2 := ItemStr1;
  end;

    // 排序 方式
  if SortType = SortType_String then  // 字符串排序
    Compare := CompareText( SortStr1, SortStr2 )
  else
  if SortType = SortType_Size then  // Size 排序
  begin
    CompareSize := MySize.getFileSize( SortStr1 ) - MySize.getFileSize( SortStr2 );
    if CompareSize > 0 then
      Compare := 1
    else
    if CompareSize = 0 then
      Compare := 0
    else
      Compare := -1;
  end
  else
  if SortType = SortType_Int then  // Count 排序
    Compare := StrToIntDef( SortStr1, 0 ) - StrToIntDef( SortStr2, 0 )
  else
  if SortType = SortType_Percentage then  // Percentage 排序
    Compare := MyPercentage.getStrToPercentage( SortStr1 ) - MyPercentage.getStrToPercentage( SortStr2 )
  else
  if SortType = SortType_Count then
    Compare := MyCount.getCountInt( SortStr1 ) - MyCount.getCountInt( SortStr2 )
  else
    Compare := CompareText( SortStr1, SortStr2 ); // Others
end;

class procedure ListviewUtil.LvDeletion(Sender: TObject; Item: TListItem);
var
  Data: TObject;
begin
  Data := Item.Data;
  Data.Free;
end;

class procedure ListviewUtil.MoveToBottom(listItem: TListItem);
var
  lv : TListView;
  NewItem : TListItem;
begin
  lv := ListItem.ListView as TListView;
  NewItem := lv.Items.Add;
  CopyData( NewItem, listItem );
  lv.Items.Delete( listItem.Index );
end;

class procedure ListviewUtil.MoveToSecond(listItem: TListItem);
var
  lv : TListView;
  NewItem : TListItem;
begin
  lv := ListItem.ListView as TListView;
  NewItem := lv.Items.Insert(1);
  CopyData( NewItem, listItem );
  lv.Items.Delete( listItem.Index );
end;

class procedure ListviewUtil.MoveToTop(listItem: TListItem);
var
  lv : TListView;
  NewItem : TListItem;
begin
  lv := ListItem.ListView as TListView;
  NewItem := lv.Items.Insert(0);
  CopyData( NewItem, listItem );
  lv.Items.Delete( listItem.Index );
end;

{ ComboboxUtil }

class procedure ComboboxUtil.ClearData(ccb: TComboBoxEx);
var
  i : Integer;
  o : TObject;
begin
  for i := 0 to ccb.ItemsEx.Count - 1 do
  begin
    o := ccb.ItemsEx.Items[i].Data;
    o.Free;
  end;
end;

class procedure ComboboxUtil.CopyData(NewcbbItem, OldcbbItem: TListControlItem);
begin
  NewcbbItem.Caption := OldcbbItem.Caption;
  NewcbbItem.ImageIndex := OldcbbItem.ImageIndex;
  NewcbbItem.Data := OldcbbItem.Data;
  OldcbbItem.Data := nil;
end;

class procedure ComboboxUtil.MoveToBottom(cbb : TComboBoxEx; cbbItem: TListControlItem);
var
  IsSelect : Boolean;
  NewItem : TListControlItem;
begin
  IsSelect := cbb.ItemIndex = cbbItem.Index;
  NewItem := cbb.ItemsEx.Add;
  CopyData( NewItem, cbbItem );
  if IsSelect then
    cbb.ItemIndex := NewItem.Index;
  cbb.ItemsEx.Delete( cbbItem.Index );
end;

class procedure ComboboxUtil.MoveToSecond(cbb: TComboBoxEx;
  cbbItem: TListControlItem);
var
  IsSelect : Boolean;
  NewItem : TListControlItem;
begin
  IsSelect := cbb.ItemIndex = cbbItem.Index;
  NewItem := cbb.ItemsEx.Insert(2);
  CopyData( NewItem, cbbItem );
  if IsSelect then
    cbb.ItemIndex := NewItem.Index;
  cbb.ItemsEx.Delete( cbbItem.Index );
end;

class procedure ComboboxUtil.MoveToTop(cbb : TComboBoxEx; cbbItem: TListControlItem);
var
  IsSelect : Boolean;
  NewItem : TListControlItem;
begin
  IsSelect := cbb.ItemIndex = cbbItem.Index;
  NewItem := cbb.ItemsEx.Insert(1);
  CopyData( NewItem, cbbItem );
  if IsSelect then
    cbb.ItemIndex := NewItem.Index;
  cbb.ItemsEx.Delete( cbbItem.Index );
end;

{ VirtualTreeUtil }

class procedure VirtualTreeUtil.BindSort(vst: TVirtualStringTree);
begin
  vst.OnHeaderClick := VstHeaderClick;
end;

class procedure VirtualTreeUtil.MoveToBottom(vst : TVirtualStringTree;
  Node: PVirtualNode);
begin
  vst.MoveTo( Node, vst.RootNode.LastChild, amInsertAfter, False );
end;

class procedure VirtualTreeUtil.MoveToSecond(vst: TVirtualStringTree;
  Node: PVirtualNode);
begin
  vst.MoveTo( Node, vst.RootNode.FirstChild, amInsertAfter, False );
end;

class procedure VirtualTreeUtil.MoveToTop(vst : TVirtualStringTree;
  Node: PVirtualNode);
begin
  vst.MoveTo( Node, vst.RootNode.FirstChild, amInsertBefore, False );
end;

class procedure VirtualTreeUtil.VstHeaderClick(Sender: TVTHeader;
  HitInfo: TVTHeaderHitInfo);
begin
  if Sender.SortDirection = sdAscending then
    Sender.SortDirection := sdDescending
  else
    Sender.SortDirection := sdAscending;

  Sender.Treeview.SortTree(HitInfo.Column, Sender.SortDirection, False);
end;

initialization
  TbMappingHash := TTbMappingHash.Create;
finalization
  TbMappingHash.Free;

end.
