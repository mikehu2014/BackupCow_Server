object frmDecrypt: TfrmDecrypt
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Restore File Decrypt'
  ClientHeight = 205
  ClientWidth = 341
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Icon.Data = {
    0000010001001010000001000800680500001600000028000000100000002000
    0000010008000000000000010000000000000000000000010000000100000000
    000000202000202020000040400020404000007F7F0020606000307070004040
    4000505050005F5F5F0048727200407F7F005D70700060606000646F6F006E6E
    6E006A72720070707000797979007E7E7E00209F9F0000BFBF0030AFAF004B8C
    8C004C8C8C00409F9F007E8A8A0040BFBF0000DFDF0020DFDF0000FFFF0030EF
    EF0060DFDF00909090009F9F9F00A0A0A000A3A5A500AFAFAF00B0B0B000BABF
    BF00BFBFBF00BAC0C000BDC0C000C0C0C000CFCFCF00DFDFDF00000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000FFFFFF000000
    0000000013130000000000000000000000131310232400000000000000000000
    002C270A27240000000000000000000000232412232400000000000D1D040000
    2427240A2724000000001A1D0C010000002324132D2400000006160C03000000
    242724142D2400001C1F0C03000000002A2D242D270E02191F0C030000000000
    2A292D090C1C1C1E0C0300000000002A2D290E1E1F2020211700000000002C2D
    2E29151F16051721170000000000292C2E091C1F1C050517170000000000292C
    10261C05000E1621030000000000002D2208090C02191D070000000000000000
    290A221B24240B000000000000000000000011000F000000000000000000FCFF
    0000E0FF0000E0FF0000E0F80000C0F00000E0E10000C0C30000C0070000C00F
    0000801F0000001F0000001F0000021F0000803F0000C07F0000F5FF0000}
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 66
    Top = 19
    Width = 70
    Height = 13
    Caption = 'Restore Path: '
  end
  object Label2: TLabel
    Left = 66
    Top = 43
    Width = 39
    Height = 13
    Caption = 'Owner: '
  end
  object lbOwner: TLabel
    Left = 143
    Top = 43
    Width = 40
    Height = 13
    Caption = 'lbOwner'
  end
  object Label4: TLabel
    Left = 66
    Top = 67
    Width = 72
    Height = 13
    Caption = 'Restore From: '
  end
  object lbRestoreFrom: TLabel
    Left = 144
    Top = 67
    Width = 70
    Height = 13
    Caption = 'lbRestoreFrom'
  end
  object igShow: TImage
    Left = 12
    Top = 28
    Width = 32
    Height = 32
  end
  object lbPasswordHint: TLabel
    Left = 10
    Top = 101
    Width = 28
    Height = 13
    Caption = 'Hints:'
  end
  object lbPassword: TLabel
    Left = 10
    Top = 131
    Width = 50
    Height = 13
    Caption = 'Password:'
  end
  object edtPath: TEdit
    Left = 143
    Top = 19
    Width = 171
    Height = 21
    TabStop = False
    BorderStyle = bsNone
    Color = clBtnFace
    ImeName = #20013#25991' - QQ'#25340#38899#36755#20837#27861
    ReadOnly = True
    TabOrder = 1
  end
  object edtPasswordHint: TEdit
    Left = 66
    Top = 101
    Width = 265
    Height = 21
    TabStop = False
    BorderStyle = bsNone
    Color = clBtnFace
    ImeName = #20013#25991' - QQ'#25340#38899#36755#20837#27861
    ReadOnly = True
    TabOrder = 2
  end
  object edtPassword: TEdit
    Left = 66
    Top = 128
    Width = 265
    Height = 21
    ImeName = #20013#25991' - QQ'#25340#38899#36755#20837#27861
    PasswordChar = '*'
    TabOrder = 0
    OnKeyDown = edtPasswordKeyDown
  end
  object btnOK: TButton
    Left = 80
    Top = 169
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 3
    OnClick = btnOKClick
  end
  object BtnCancel: TButton
    Left = 193
    Top = 169
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 4
    OnClick = BtnCancelClick
  end
end