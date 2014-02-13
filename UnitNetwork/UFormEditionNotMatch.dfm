object frmEditonNotMatch: TfrmEditonNotMatch
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  BorderWidth = 3
  Caption = 'Backup Cow'
  ClientHeight = 311
  ClientWidth = 412
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lvComputer: TListView
    Left = 0
    Top = 34
    Width = 412
    Height = 277
    Align = alClient
    Columns = <
      item
        Caption = 'Computer IP'
        Width = 130
      end
      item
        AutoSize = True
        Caption = 'Computer Name'
      end>
    ReadOnly = True
    RowSelect = True
    SmallImages = frmMainForm.ilNw16
    TabOrder = 0
    ViewStyle = vsReport
  end
  object plMain: TPanel
    Left = 0
    Top = 0
    Width = 412
    Height = 34
    Align = alTop
    BevelOuter = bvNone
    Caption = 
      'You must upgrade Backup Cow old version programs running on all ' +
      'the computers.'
    TabOrder = 1
  end
end
