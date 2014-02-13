unit UFrameFilter;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, UFmFilter, StdCtrls, ExtCtrls, UFileBaseInfo, ComCtrls;

type
  TFrameFilterPage = class(TFrame)
    plInclude: TPanel;
    gbIncludeFilter: TGroupBox;
    FrameInclude: TFrameFilter;
    plExclude: TPanel;
    gbExcludeFilter: TGroupBox;
    FrameExclude: TFrameFilter;
  published
    procedure FrameIncludeLvMaskDeletion(Sender: TObject; Item: TListItem);
    procedure FrameExcludeLvMaskDeletion(Sender: TObject; Item: TListItem);
  private
    { Private declarations }
  public
    procedure IniFrame;
    procedure SetDefaultStatus;
    procedure SetClearMask;
  public
    procedure SetRootPathList( RootPathList : TStringList );
    procedure SetIncludeFilterList( FilterList : TFileFilterList );
    procedure SetExcludeFilterList( FilterList : TFileFilterList );
  public
    function getIncludeFilterList : TFileFilterList;
    function getExcludeFilterList : TFileFilterList;
  end;

implementation

{$R *.dfm}

{ TFrame1 }

procedure TFrameFilterPage.FrameExcludeLvMaskDeletion(Sender: TObject;
  Item: TListItem);
begin
  FrameExclude.LvMaskDeletion(Sender, Item);
end;

procedure TFrameFilterPage.FrameIncludeLvMaskDeletion(Sender: TObject;
  Item: TListItem);
begin
  FrameInclude.LvMaskDeletion( Sender, Item );
end;

function TFrameFilterPage.getExcludeFilterList: TFileFilterList;
begin
  Result := FrameExclude.getFilterList;
end;

function TFrameFilterPage.getIncludeFilterList: TFileFilterList;
begin
  Result := FrameInclude.getFilterList;
end;

procedure TFrameFilterPage.IniFrame;
begin
  FrameInclude.SetIsInclude( True );
  FrameExclude.SetIsInclude( False );
end;

procedure TFrameFilterPage.SetClearMask;
begin
  FrameInclude.ClearMask;
  FrameExclude.ClearMask;
end;

procedure TFrameFilterPage.SetDefaultStatus;
begin
  FrameInclude.SetDefaultStatus;
  FrameExclude.SetDefaultStatus;
end;

procedure TFrameFilterPage.SetExcludeFilterList(FilterList: TFileFilterList);
begin
  FrameExclude.SetFilterList( FilterList );
end;

procedure TFrameFilterPage.SetIncludeFilterList(FilterList: TFileFilterList);
begin
  FrameInclude.SetFilterList( FilterList );
end;

procedure TFrameFilterPage.SetRootPathList(RootPathList: TStringList);
begin
  FrameInclude.SetRootPathList( RootPathList );
  FrameExclude.SetRootPathList( RootPathList );
end;

end.

