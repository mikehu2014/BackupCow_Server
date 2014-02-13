object frmSpeedLimit: TfrmSpeedLimit
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Speed Settings...'
  ClientHeight = 159
  ClientWidth = 268
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object rbNoLimit: TRadioButton
    Left = 35
    Top = 24
    Width = 113
    Height = 17
    Caption = 'Don'#39't limit'
    Checked = True
    TabOrder = 0
    TabStop = True
    OnClick = rbNoLimitClick
  end
  object rbLimit: TRadioButton
    Left = 35
    Top = 64
    Width = 57
    Height = 17
    Caption = 'Limit to:  '
    TabOrder = 1
  end
  object edtSpeed: TEdit
    Left = 98
    Top = 62
    Width = 50
    Height = 21
    Enabled = False
    ImeName = #20013#25991' - QQ'#25340#38899#36755#20837#27861
    NumbersOnly = True
    TabOrder = 2
  end
  object cbbSpeedType: TComboBox
    Left = 149
    Top = 62
    Width = 66
    Height = 21
    Style = csDropDownList
    Enabled = False
    ImeName = #20013#25991' - QQ'#25340#38899#36755#20837#27861
    ItemIndex = 0
    TabOrder = 3
    Text = 'KB / S'
    Items.Strings = (
      'KB / S'
      'MB / S')
  end
  object btnOK: TButton
    Left = 48
    Top = 112
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 4
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 140
    Top = 112
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 5
    OnClick = btnCancelClick
  end
end
