object frmNetworkPcDetail: TfrmNetworkPcDetail
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  BorderWidth = 3
  Caption = 'frmNetworkPcDetail'
  ClientHeight = 284
  ClientWidth = 436
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 17
    Top = 59
    Width = 65
    Height = 13
    Caption = 'Computer ID:'
  end
  object Label2: TLabel
    Left = 17
    Top = 83
    Width = 82
    Height = 13
    Caption = 'Last Online Time:'
  end
  object Label3: TLabel
    Left = 17
    Top = 108
    Width = 54
    Height = 13
    Caption = 'Reachable:'
  end
  object Label4: TLabel
    Left = 17
    Top = 132
    Width = 14
    Height = 13
    Caption = 'Ip:'
  end
  object Label5: TLabel
    Left = 17
    Top = 157
    Width = 24
    Height = 13
    Caption = 'Port:'
  end
  object lbComputerID: TLabel
    Left = 108
    Top = 59
    Width = 66
    Height = 13
    Caption = 'lbComputerID'
  end
  object lbReachable: TLabel
    Left = 108
    Top = 108
    Width = 58
    Height = 13
    Caption = 'lbReachable'
  end
  object lbIp: TLabel
    Left = 108
    Top = 132
    Width = 18
    Height = 13
    Caption = 'lbIp'
  end
  object lbPort: TLabel
    Left = 108
    Top = 157
    Width = 28
    Height = 13
    Caption = 'lbPort'
  end
  object lbLastOnlineTime: TLabel
    Left = 108
    Top = 83
    Width = 80
    Height = 13
    Caption = 'lbLastOnlineTime'
  end
  object Label6: TLabel
    Left = 231
    Top = 59
    Width = 91
    Height = 13
    Caption = 'Total Share Space:'
  end
  object Label7: TLabel
    Left = 231
    Top = 83
    Width = 60
    Height = 13
    Caption = 'Used Space:'
  end
  object Label8: TLabel
    Left = 231
    Top = 108
    Width = 79
    Height = 13
    Caption = 'Available Space:'
  end
  object Label9: TLabel
    Left = 231
    Top = 132
    Width = 96
    Height = 13
    Caption = 'Cloud Consumption:'
  end
  object lbTotalShace: TLabel
    Left = 336
    Top = 59
    Width = 61
    Height = 13
    Caption = 'lbTotalShace'
  end
  object lbAvailableSpace: TLabel
    Left = 336
    Top = 108
    Width = 80
    Height = 13
    Caption = 'lbAvailableSpace'
  end
  object lbCloudConsumpition: TLabel
    Left = 336
    Top = 132
    Width = 99
    Height = 13
    Caption = 'lbCloudConsumpition'
  end
  object lbUsedSpace: TLabel
    Left = 336
    Top = 83
    Width = 61
    Height = 13
    Caption = 'lbUsedSpace'
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 436
    Height = 49
    Align = alTop
    BevelEdges = [beBottom]
    BevelKind = bkSoft
    BevelOuter = bvNone
    TabOrder = 0
    object iPcStatus: TImage
      Left = 16
      Top = 9
      Width = 24
      Height = 24
    end
    object edtComputerName: TEdit
      Left = 55
      Top = 11
      Width = 330
      Height = 21
      ImeName = #20013#25991' - QQ'#25340#38899#36755#20837#27861
      ReadOnly = True
      TabOrder = 0
    end
  end
  object lvMyBackup: TListView
    Left = 0
    Top = 184
    Width = 436
    Height = 100
    Align = alBottom
    Columns = <
      item
        AutoSize = True
        Caption = 'Backup Item'
      end
      item
        Caption = 'Total Size'
        Tag = 1
        Width = 70
      end
      item
        Caption = 'Backup Size'
        Tag = 1
        Width = 70
      end
      item
        Caption = 'Percentage'
        Tag = 3
        Width = 100
      end>
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
    ExplicitTop = 179
  end
end
