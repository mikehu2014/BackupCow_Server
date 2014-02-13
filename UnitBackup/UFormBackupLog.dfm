object frmBackupLog: TfrmBackupLog
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderWidth = 3
  Caption = 'Backup Log'
  ClientHeight = 407
  ClientWidth = 466
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Icon.Data = {
    0000010001001010000001000800680500001600000028000000100000002000
    0000010008000000000000010000000000000000000000010000000100000000
    0000875F24008A7559008F7A5B008F7B5C009F7E5100917D5F00957E5C00AA72
    4E00A6745300AC785300917E6100A0824D00A1815100A3845700938163009482
    67009B8866009C886800B2876500B8836400BB896B00BA896C00BD8D6E00AF93
    6700AE956700BE8E7100BF907200B59B7100B89F7600B7A07C00BBA37D00C090
    7200C3937500C4937600C4947600C5957800C8967900C8987900BFA68100BBA8
    8900BDAB8800C0A98600C7A48E00C2AC8800C4AE8D00C2AF9200D0AF9B00C5B4
    9500C9B79B00CAB89A00CDBB9E00D5B19B00CBBAA000CCBBA000CDBCA300CEBE
    A400D6B5A000D1BDA100CEC0A700D1C0A700D3C5AD00DBCFBA00DDD3C300E0D1
    C100E0D4C600E5DCCF00E9D8CD00E6DCD200E6DED500E7E0D600EAE1D600EDE0
    D600EBE3D900ECE3DA00EBE4DA00ECE5DA00EDE9E100F0EAE200F1ECE400F3EF
    EB00F3F1E800F4F1EA00F5F1ED00F6F4ED00F8F2F100F9F4F100F9F7F500F9F9
    F500F9FAFA00FBFCF90000000000000000000000000000000000000000000000
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
    010D0D0D0D0D0D0D0D0D0D05020000000D565858585858585858585202000000
    18481B1B1B1B1A17171A2F4C040000001C575252525252525252524C04000000
    1D432424242424232424394C040000001D575252525256525757574C04000000
    1D4324242423242625252F4C040000001E5752525656575858524F4C04000000
    284824232424242317172B40060000002E575A585A5A57524D45403D0B000000
    32482624242423170A08132A0F0000003657595A5A524F4232453E1F0F000000
    364824241A17140936522D1200000000365A5A574E45403A283C110000000000
    3B525750453F3C2D0C12000000000000303B3636312D2718060000000000C001
    0000C0010000C0010000C0010000C0010000C0010000C0010000C0010000C001
    0000C0010000C0010000C0010000C0030000C0070000C00F0000C01F0000}
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object plButtons: TPanel
    Left = 0
    Top = 372
    Width = 466
    Height = 35
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    Visible = False
    object btnClose: TButton
      Left = 312
      Top = 8
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Close'
      TabOrder = 0
      OnClick = btnCloseClick
    end
    object btnPreview: TButton
      Left = 191
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Preview'
      Enabled = False
      TabOrder = 1
      OnClick = btnPreviewClick
    end
    object btnRestore: TButton
      Left = 72
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Restore'
      Enabled = False
      TabOrder = 2
      OnClick = btnRestoreClick
    end
  end
  object PcMain: TRzPageControl
    Left = 0
    Top = 0
    Width = 466
    Height = 372
    ActivePage = tsCompleted
    Align = alClient
    BoldCurrentTab = True
    Images = ilPcMain
    ShowFocusRect = False
    ShowFullFrame = False
    ShowShadow = False
    TabIndex = 0
    TabOrder = 1
    TabStyle = tsRoundCorners
    FixedDimension = 22
    object tsCompleted: TRzTabSheet
      ImageIndex = 0
      Caption = 'Completed'
      Padding.Top = 5
      object plCompleted: TPanel
        Left = 0
        Top = 5
        Width = 466
        Height = 341
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object pbProgress: TProgressBar
          Left = 0
          Top = 305
          Width = 466
          Height = 16
          Align = alBottom
          MarqueeInterval = 50
          TabOrder = 0
          Visible = False
        end
        object plStatus: TPanel
          Left = 0
          Top = 321
          Width = 466
          Height = 20
          Align = alBottom
          BevelEdges = [beLeft, beRight, beBottom]
          BevelOuter = bvLowered
          Color = clInfoBk
          Padding.Left = 3
          ParentBackground = False
          TabOrder = 1
          Visible = False
          object Image1: TImage
            Left = 4
            Top = 1
            Width = 22
            Height = 18
            Align = alLeft
            Picture.Data = {
              055449636F6E0000010001001010000001000800680500001600000028000000
              1000000020000000010008000000000000010000000000000000000000010000
              00010000000000005D000000650000006F000000750000007900000055280E00
              5B2D14005E2F15007347290068443600624144008F2E06008C3D1E008C3C2300
              9A452800A5573600A55836008E574E008A644C0094634100966B4B0085695D00
              8F6F5B00886A5C00AB784D00896F65009375650090766D00977E7200C0704F00
              AF876400AD896400AD8A6B00B4816200DD8D5C00CE9F6F00E9956300DFA67B00
              AF978700B3938200BAA59A00BAA79D00CAAA8700CDAF9400CFB29500D7B69400
              D8B89300D2B69900DABD9B00C2AEA300C5B2A000C9B6A700CBB8A200C5B5AF00
              CFBFAE00D1BDAD00D6C1AA00CFC2B700D0C7BD00E7CAA800E4CAAF00F9C8A600
              E2CAB400EDD5B800F4D6B200F5D7B700F8D6B700FFDCB300FDE4BF00D8CBC300
              D7CEC900DFD4C800ECD7C000EED8C100E8DBC700E6D9C900F2DEC900E8DED500
              F7E5C400FFE7C300FCE3C500FFE5C600FFE9C700FFE6C900FFE7CE00FFEAC900
              FFEDCB00FFE9CE00FFEECF00FFF7C400EFE6DA00EAE3DC00F8E7D500FFEAD000
              FFEDD100FFEBD600FFECD500FFEED900FFEEDD00FFF0D700FFF8D100FFF2D900
              FFF0DC00FFF4DF00E4E5E500ECE7E200EDEDEF00F1EBE600FDEFE000FFF4E300
              FFF2E600FFFFE200FFFAE500F6F3EF00F7F4EF00FEF5E800FFF6EC00FFF9EB00
              FFFAEF00FFFEEE00F2F4F500FFFBF300FFFFF100FBF8F400FFFFF900FFFFFE00
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
              0000000000000000000000001617000000000000000000000000001524191600
              00000000000000000000152B5A14160000000000000000001B133C44441F060A
              1600000000002A2A303C455365412F200816000000344B4057431E2523265041
              2E091A00354B4B575F7022050C4F575041310800334B5F5F55782D03117B5450
              5750211C3755745F627B2C04107B5F54555F3D163A6D7462627E3904117E5F55
              5F6249163B75786F7B5B0D020E7E626262704D1D48727E757E4C282A327E7462
              757E3F1D00697E7E787E7E3E787E74787E7E2700006A6B7E7E7E12010F7E7E7E
              7E38000000006C797E7E470B367E7E7E4E000000000000005B797E7E7E7B4600
              00000000FF3F0000FE1F0000FC1F0000F0070000C00300008001000000010000
              00000000000000000000000000000000000000008001000080030000C0070000
              F01F0000}
            ExplicitLeft = 1
          end
          object lbStatus: TLabel
            Left = 26
            Top = 1
            Width = 439
            Height = 18
            Align = alClient
            Caption = 'Share Directory is loading...'
            Layout = tlCenter
            ExplicitWidth = 134
            ExplicitHeight = 13
          end
        end
        object tbCompleted: TToolBar
          Left = 0
          Top = 0
          Width = 466
          Height = 30
          AutoSize = True
          ButtonHeight = 30
          ButtonWidth = 73
          Caption = 'tbCompleted'
          DisabledImages = frmMainForm.ilTb24Gray
          Images = frmMainForm.ilTb24
          List = True
          ParentShowHint = False
          ShowCaptions = True
          ShowHint = True
          TabOrder = 2
          object tbtnPreview: TToolButton
            Left = 0
            Top = 0
            AutoSize = True
            Caption = 'Preview'
            Enabled = False
            ImageIndex = 35
            OnClick = tbtnPreviewClick
          end
          object tbtnRestore: TToolButton
            Left = 77
            Top = 0
            AutoSize = True
            Caption = 'Restore'
            Enabled = False
            ImageIndex = 9
            OnClick = tbtnRestoreClick
          end
          object tbtnExplorer: TToolButton
            Left = 154
            Top = 0
            Hint = 'Explorer'
            AutoSize = True
            Enabled = False
            ImageIndex = 1
            OnClick = tbtnExplorerClick
          end
          object ToolButton3: TToolButton
            Left = 196
            Top = 0
            Width = 8
            Caption = 'ToolButton3'
            ImageIndex = 2
            Style = tbsSeparator
          end
          object tbtnExpand: TToolButton
            Left = 204
            Top = 0
            Hint = 'Expand All'
            AutoSize = True
            ImageIndex = 18
            OnClick = tbtnExpandClick
          end
          object tbtnCollapse: TToolButton
            Left = 246
            Top = 0
            Hint = 'Collapse All'
            AutoSize = True
            ImageIndex = 17
            OnClick = tbtnCollapseClick
          end
          object ToolButton1: TToolButton
            Left = 288
            Top = 0
            Width = 8
            Caption = 'ToolButton1'
            ImageIndex = 18
            Style = tbsSeparator
          end
          object tbtnSearch: TToolButton
            Left = 296
            Top = 0
            Caption = 'Search'
            ImageIndex = 36
            Style = tbsCheck
            OnClick = tbtnSearchClick
          end
        end
        object Panel1: TPanel
          Left = 0
          Top = 30
          Width = 466
          Height = 275
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 3
          object vstBackupLog: TVirtualStringTree
            Left = 0
            Top = 32
            Width = 466
            Height = 243
            Align = alClient
            BorderWidth = 1
            Header.AutoSizeIndex = 0
            Header.Font.Charset = DEFAULT_CHARSET
            Header.Font.Color = clWindowText
            Header.Font.Height = -11
            Header.Font.Name = 'Tahoma'
            Header.Font.Style = []
            Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
            ParentShowHint = False
            ShowHint = True
            TabOrder = 0
            TreeOptions.SelectionOptions = [toFullRowSelect, toMultiSelect]
            OnFocusChanged = vstBackupLogFocusChanged
            OnGetText = vstBackupLogGetText
            OnPaintText = vstBackupLogPaintText
            OnGetImageIndex = vstBackupLogGetImageIndex
            Columns = <
              item
                Position = 0
                Width = 190
                WideText = 'File Name'
              end
              item
                Position = 1
                Width = 170
                WideText = 'Directory'
              end
              item
                Position = 2
                Width = 100
                WideText = 'Backup Time'
              end>
          end
          object plSearch: TPanel
            Left = 0
            Top = 0
            Width = 466
            Height = 32
            Align = alTop
            BevelEdges = [beTop]
            BevelKind = bkTile
            BevelOuter = bvNone
            TabOrder = 1
            Visible = False
            object Label1: TLabel
              Left = 4
              Top = 8
              Width = 50
              Height = 13
              Caption = 'FileName: '
            end
            object btnSearch: TButton
              Left = 403
              Top = 3
              Width = 62
              Height = 25
              Caption = 'Search'
              TabOrder = 0
              OnClick = btnSearchClick
            end
            object cbbFileName: TComboBox
              Left = 54
              Top = 5
              Width = 347
              Height = 21
              ImeName = #20013#25991' - QQ'#25340#38899#36755#20837#27861
              TabOrder = 1
              OnKeyDown = cbbFileNameKeyDown
            end
          end
        end
      end
    end
    object tsInCompleted: TRzTabSheet
      ImageIndex = 1
      Caption = 'Incompleted'
      Padding.Top = 5
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object vstIncompleted: TVirtualStringTree
        Left = 0
        Top = 5
        Width = 466
        Height = 341
        Align = alClient
        BorderWidth = 1
        Header.AutoSizeIndex = 0
        Header.Font.Charset = DEFAULT_CHARSET
        Header.Font.Color = clWindowText
        Header.Font.Height = -11
        Header.Font.Name = 'Tahoma'
        Header.Font.Style = []
        Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
        TabOrder = 0
        TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowTreeLines, toThemeAware, toUseBlendedImages]
        TreeOptions.SelectionOptions = [toFullRowSelect, toMultiSelect]
        OnGetText = vstIncompletedGetText
        OnGetImageIndex = vstIncompletedGetImageIndex
        Columns = <
          item
            Position = 0
            Width = 216
            WideText = 'File Name'
          end
          item
            Position = 1
            Width = 250
            WideText = 'Directory'
          end>
      end
    end
  end
  object ilPcMain: TImageList
    Left = 216
    Top = 128
    Bitmap = {
      494C010102000400040010001000FFFFFFFFFF00FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000DEE0DD00D8D9D900A1B6A00086AB8B0089B39300AAC8B200E5EDE700D8D9
      D900000000000000000000000000000000000000000000000000000000000000
      0000DDDDDD00CFD1D9009496B600797DB0008285BA00ACAECD00E5E7F0000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000DEE1
      E0007A95760032783B0028854200288542002A8644002A86440032874B008AB8
      9700EAEEEC00000000000000000000000000000000000000000000000000DDDD
      DD00646893001E2686001A2292001A2292001A2292001A2292002A339400989B
      C900E4E6E9000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000DEE0DD00587D
      530028854200298D4C00298D4C0069A07400298D4C00298D4C00298D4C002889
      470066A67800EDEFEE0000000000000000000000000000000000DDDDDD003F44
      7F001A2292001A24C2001A24C200CBC5C100CCC2BC001A24C2001A24C2001A22
      9200767EBC00E5E6E60000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000DEE1E0006E8769002A86
      44002A9451002A94510089B39300DEE1E00073AB850028985600269653002696
      5300298D4C007FBB9700000000000000000000000000E0E1E100585B85001A24
      9E001A24C2001A24C2001A24C200D1D1D100D1CBC0001A24C2001A24C2001A24
      C2001A249E00A5A9D20000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C8CEC6002E7135002898
      56002D9C59008CBC9C00EDEFEE00EAEEEC00D0DDD300389D62002D9C5900289B
      59002696530032915600DDECE3000000000000000000B8BAC1001E2686001A24
      C2001A24C2001A24C2001A24C200E4E2DF00E2DACB001A24C2001A24C2001A24
      C2001A22A1003C44A600E8E9EF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000086968200298D4C002D9C
      590096C5A900F1F4F200EFF1F000EFF1F000EFF1F00095C3A3002AA7660028A3
      65002D9C590028985600A1C9B1000000000000000000727590001A249E001A24
      C2001A24C2001A24C2001A24C200EFEEEB00E5DED4001A24C2001A24C2001A24
      C2001A24C2001A249E00CBCDE500000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000005E7C5C002DA05D00559C
      6900F8F9F700F6F9F8008DC8A5007B9F7A00F5F8F500EFF1F00051AE780028AC
      690028A36500289F5C007FBB9700000000000000000052557D001A249E001A24
      C2001A24C2001A24C2001A24C200F8F9F400EDE8DC001A24C2001A24C2001A24
      C2001A24C2001A22A100ACAED400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000005E7C5C002FA865002A94
      5100C6D6C3007CC49C0029B472002A945100D0D9CA00F5F8F500C3DCCD0031AE
      710028AC690027A664007ABB9900000000000000000052557D001A22A1001A24
      C2001A24C2001A24C2001A24C200FDFDFD00F4EFE0001A24C2001A24C2001A24
      C2001A24C2001B25AD00ACAED400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000007B8B78002D9C590029B4
      7200389D620026B6750026B976002AB87800518F5D00F5F8F500F1F4F20089C2
      A10029B4720028AC690096C5A9000000000000000000727590001A22A1001A24
      C2001A24C2001A24C2001A24C200F4EFE000E2DACB001A24C2001A24C2001A24
      C2001A24C2001B25AD00CBCDE500000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000BABCBC002A86440029B4
      720026B6750029B9770026BA7A0026BA7A0028AC69008CAC8A00F5F6F500EAEE
      EC0059B2810031AE7100D0DDD3000000000000000000BABCBD00202588001A24
      C2001A24CD001A24CD001A24CD001A24CD001A24CD001A24CD001A24CD001A24
      CD001A24CD004249B300E5E6E600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000005474570028AC
      69002AB8780026BA7A0026BA7A0024C0800024C080002D975900BFCDB900DEE1
      E00059B281006EB99600000000000000000000000000EFEEEB00585A80001B25
      AD001A24C2001A24CD001A24CD00F2EDDE00E8DFCA001A24CD001A24C2001A24
      C2002027B600A6A8CE0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000CDD1CD004172
      4A0029B4720026BA7A0026BA7A0026BF810024C080002AB878003291560059B2
      810051B386000000000000000000000000000000000000000000D3D6D8004146
      7C001C23B7001A24CD001D25D200F8F9F400F2EDDE001A24CD001A24C2001D28
      BC007D82BF00E0E1E10000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000CFD4
      D000527B5A002B9D620029BE7F0026BF810026BF810024C0800030B77C0064B1
      8E0000000000000000000000000000000000000000000000000000000000D7D9
      DB0065688C00262D9F001A24C2001D25D2001D25D2001A24C2003740B800979A
      C400E5E6E6000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000B1B9B20071967E00599F7E005CAA89007BB19B00B9CBC2000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000EDEEED00C8C9C9009698B100797DB0008285BA00ACAECD00E0E1E1000000
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
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FFFFFFFF00000000F00FF01F00000000
      E007E00700000000C003C0030000000080038003000000008001800100000000
      8001800100000000800180010000000080018001000000008001800100000000
      8001800100000000C003800300000000C007C00300000000E00FE00700000000
      F81FF01F00000000FFFFFFFF00000000}
  end
  object tmrProgress: TTimer
    Enabled = False
    Interval = 1500
    OnTimer = tmrProgressTimer
    Left = 40
    Top = 112
  end
end