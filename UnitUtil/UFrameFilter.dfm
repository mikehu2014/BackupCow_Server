object FrameFilterPage: TFrameFilterPage
  Left = 0
  Top = 0
  Width = 414
  Height = 396
  TabOrder = 0
  object plInclude: TPanel
    Left = 0
    Top = 0
    Width = 414
    Height = 201
    Align = alTop
    BevelOuter = bvNone
    BorderWidth = 10
    TabOrder = 0
    object gbIncludeFilter: TGroupBox
      Left = 10
      Top = 10
      Width = 394
      Height = 181
      Align = alClient
      Caption = 'Include specifications (Files to be considered for copying)'
      Padding.Left = 5
      Padding.Top = 5
      Padding.Right = 5
      Padding.Bottom = 5
      TabOrder = 0
      inline FrameInclude: TFrameFilter
        Left = 7
        Top = 20
        Width = 380
        Height = 154
        Align = alClient
        TabOrder = 0
        ExplicitLeft = 7
        ExplicitTop = 20
        ExplicitWidth = 380
        ExplicitHeight = 154
        inherited LvMask: TListView
          Width = 295
          Height = 154
          ParentFont = False
          OnDeletion = FrameIncludeLvMaskDeletion
          ExplicitWidth = 295
          ExplicitHeight = 154
        end
        inherited Panel6: TPanel
          Left = 295
          Height = 154
          ExplicitLeft = 295
          ExplicitHeight = 154
          inherited btnRemoveMask: TButton
            Visible = False
          end
        end
        inherited PmSpaceLimit: TPopupMenu
          Left = 104
          Top = 48
        end
        inherited PmDeleteMask: TPopupMenu
          Left = 176
          Top = 40
        end
      end
    end
  end
  object plExclude: TPanel
    Left = 0
    Top = 201
    Width = 414
    Height = 195
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 10
    TabOrder = 1
    object gbExcludeFilter: TGroupBox
      Left = 10
      Top = 10
      Width = 394
      Height = 175
      Align = alClient
      Caption = 'Exclude specifications (Files to be ignored while copying)'
      Padding.Left = 5
      Padding.Top = 5
      Padding.Right = 5
      Padding.Bottom = 5
      TabOrder = 0
      inline FrameExclude: TFrameFilter
        Left = 7
        Top = 20
        Width = 380
        Height = 148
        Align = alClient
        TabOrder = 0
        ExplicitLeft = 7
        ExplicitTop = 20
        ExplicitWidth = 380
        ExplicitHeight = 148
        inherited LvMask: TListView
          Width = 295
          Height = 148
          ParentFont = False
          OnDeletion = FrameExcludeLvMaskDeletion
          ExplicitWidth = 295
          ExplicitHeight = 148
        end
        inherited Panel6: TPanel
          Left = 295
          Height = 148
          ExplicitLeft = 295
          ExplicitHeight = 148
        end
        inherited PmSpaceLimit: TPopupMenu
          Left = 104
          Top = 48
        end
        inherited PmDeleteMask: TPopupMenu
          Left = 176
          Top = 40
        end
      end
    end
  end
end
