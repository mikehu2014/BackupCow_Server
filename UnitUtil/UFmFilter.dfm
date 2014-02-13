object FrameFilter: TFrameFilter
  Left = 0
  Top = 0
  Width = 357
  Height = 140
  TabOrder = 0
  object LvMask: TListView
    Left = 0
    Top = 0
    Width = 272
    Height = 140
    Align = alClient
    Columns = <
      item
        AutoSize = True
        Caption = 'Mask'
      end>
    MultiSelect = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnChange = LvMaskChange
    OnDeletion = LvMaskDeletion
  end
  object Panel6: TPanel
    Left = 272
    Top = 0
    Width = 85
    Height = 140
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 1
    object btnSelectFile: TButton
      Left = 4
      Top = 6
      Width = 65
      Height = 25
      Caption = 'Select Files'
      TabOrder = 0
      OnClick = btnSelectFileClick
    end
    object btnAddMask: TButton
      Left = 4
      Top = 39
      Width = 65
      Height = 25
      Caption = 'Add Masks'
      PopupMenu = PmSpaceLimit
      TabOrder = 1
      OnClick = btnAddMaskClick
    end
    object btnDelete: TButton
      Left = 4
      Top = 107
      Width = 65
      Height = 25
      Caption = 'Delete'
      Enabled = False
      TabOrder = 2
      OnClick = btnDeleteClick
    end
    object BtnSpaceLimit: TButton
      Left = 4
      Top = 73
      Width = 65
      Height = 25
      Caption = 'Space Limit'
      DropDownMenu = PmSpaceLimit
      TabOrder = 3
      OnMouseUp = BtnSpaceLimitMouseUp
    end
    object btnRemoveMask: TButton
      Left = 68
      Top = 39
      Width = 9
      Height = 25
      TabOrder = 4
      OnMouseUp = btnRemoveMaskMouseUp
    end
  end
  object PmSpaceLimit: TPopupMenu
    TrackButton = tbLeftButton
    Left = 120
    Top = 64
    object Addsmallerthan1: TMenuItem
      Caption = 'Add smaller than'
      OnClick = Addsmallerthan1Click
    end
    object Addlargerthan1: TMenuItem
      Caption = 'Add larger than'
      OnClick = Addlargerthan1Click
    end
  end
  object PmDeleteMask: TPopupMenu
    Left = 56
    Top = 56
    object Excludehiddenfiles1: TMenuItem
      Caption = 'Exclude hidden files'
      OnClick = Excludehiddenfiles1Click
    end
    object Excludesystemfiles1: TMenuItem
      Caption = 'Exclude system files'
      OnClick = Excludesystemfiles1Click
    end
  end
end
