object MainForm: TMainForm
  Left = 235
  Top = 110
  Caption = 'Clipper Delphi Demo'
  ClientHeight = 728
  ClientWidth = 1012
  Color = clBtnFace
  Font.Charset = ARABIC_CHARSET
  Font.Color = clWindowText
  Font.Height = -18
  Font.Name = 'Arial'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnKeyPress = FormKeyPress
  OnMouseWheel = FormMouseWheel
  OnResize = FormResize
  PixelsPerInch = 144
  TextHeight = 21
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 256
    Height = 709
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alLeft
    TabOrder = 0
    object lblClipOpacity: TLabel
      Left = 24
      Top = 571
      Width = 149
      Height = 21
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Clip Opacity (255):'
      FocusControl = tbClipOpacity
    end
    object lblSubjOpacity: TLabel
      Left = 24
      Top = 511
      Width = 154
      Height = 21
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Subj &Opacity (255):'
      FocusControl = tbSubjOpacity
    end
    object GroupBox1: TGroupBox
      Left = 18
      Top = 11
      Width = 223
      Height = 161
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Clipping  Oper&ation'
      TabOrder = 0
      object rbIntersection: TRadioButton
        Left = 20
        Top = 53
        Width = 158
        Height = 24
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Intersection'
        Checked = True
        TabOrder = 1
        TabStop = True
        OnClick = rbIntersectionClick
      end
      object rbUnion: TRadioButton
        Left = 20
        Top = 78
        Width = 158
        Height = 24
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Union'
        TabOrder = 2
        OnClick = rbIntersectionClick
      end
      object rbDifference: TRadioButton
        Left = 20
        Top = 104
        Width = 158
        Height = 23
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Difference'
        TabOrder = 3
        OnClick = rbIntersectionClick
      end
      object rbXOR: TRadioButton
        Left = 20
        Top = 129
        Width = 158
        Height = 24
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'XOR'
        TabOrder = 4
        OnClick = rbIntersectionClick
      end
      object rbNone: TRadioButton
        Left = 20
        Top = 28
        Width = 158
        Height = 24
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'None'
        TabOrder = 0
        OnClick = rbIntersectionClick
      end
    end
    object rbStatic: TRadioButton
      Left = 22
      Top = 181
      Width = 161
      Height = 23
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = '&Static Polygons'
      Checked = True
      TabOrder = 1
      TabStop = True
      OnClick = rbStaticClick
    end
    object bExit: TButton
      Left = 153
      Top = 634
      Width = 72
      Height = 35
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Cancel = True
      Caption = 'E&xit'
      TabOrder = 7
      OnClick = bExitClick
    end
    object gbRandom: TGroupBox
      Left = 15
      Top = 258
      Width = 223
      Height = 236
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      TabOrder = 4
      object lblSubjCount: TLabel
        Left = 6
        Top = 56
        Width = 189
        Height = 21
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'No. Subject edges: (20)'
        Enabled = False
        FocusControl = tbSubj
      end
      object lblClipCount: TLabel
        Left = 6
        Top = 122
        Width = 160
        Height = 21
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'No. Clip edges (20):'
        Enabled = False
        FocusControl = tbClip
      end
      object tbSubj: TTrackBar
        Left = 7
        Top = 81
        Width = 203
        Height = 39
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Enabled = False
        Max = 100
        Min = 3
        Position = 20
        TabOrder = 2
        ThumbLength = 16
        TickStyle = tsNone
        OnChange = tbSubjChange
      end
      object tbClip: TTrackBar
        Left = 7
        Top = 148
        Width = 203
        Height = 40
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Enabled = False
        Max = 100
        Min = 3
        Position = 20
        TabOrder = 3
        ThumbLength = 16
        TickStyle = tsNone
        OnChange = tbSubjChange
      end
      object bNext: TButton
        Left = 14
        Top = 185
        Width = 188
        Height = 35
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = '&New Polygons'
        TabOrder = 4
        OnClick = bNextClick
      end
      object rbEvenOdd: TRadioButton
        Left = 7
        Top = 20
        Width = 102
        Height = 23
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'E&venOdd'
        Checked = True
        Enabled = False
        TabOrder = 0
        TabStop = True
        OnClick = rbEvenOddClick
      end
      object rbNonZero: TRadioButton
        Left = 115
        Top = 20
        Width = 96
        Height = 23
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Non&Zero'
        Enabled = False
        TabOrder = 1
        OnClick = rbEvenOddClick
      end
    end
    object rbRandom1: TRadioButton
      Left = 22
      Top = 204
      Width = 205
      Height = 24
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Random Polygons &1'
      TabOrder = 2
      OnClick = rbStaticClick
    end
    object tbClipOpacity: TTrackBar
      Left = 17
      Top = 595
      Width = 221
      Height = 39
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Max = 255
      Position = 255
      TabOrder = 6
      ThumbLength = 16
      TickStyle = tsNone
      OnChange = tbClipOpacityChange
    end
    object tbSubjOpacity: TTrackBar
      Left = 17
      Top = 535
      Width = 221
      Height = 39
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Max = 255
      Position = 255
      TabOrder = 5
      ThumbLength = 16
      TickStyle = tsNone
      OnChange = tbSubjOpacityChange
    end
    object rbRandom2: TRadioButton
      Left = 22
      Top = 230
      Width = 205
      Height = 23
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Random Polygons &2'
      TabOrder = 3
      OnClick = rbStaticClick
    end
    object bSaveSvg: TButton
      Left = 27
      Top = 634
      Width = 114
      Height = 35
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Cancel = True
      Caption = 'Save S&VG ...'
      TabOrder = 8
      OnClick = bSaveSvgClick
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 709
    Width = 1012
    Height = 19
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Panels = <>
    SimplePanel = True
  end
  object ImgView321: TImgView32
    Left = 256
    Top = 0
    Width = 756
    Height = 709
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alClient
    Bitmap.ResamplerClassName = 'TNearestResampler'
    BitmapAlign = baCustom
    Scale = 1.000000000000000000
    ScaleMode = smScale
    ScrollBars.ShowHandleGrip = True
    ScrollBars.Style = rbsDefault
    ScrollBars.Size = 16
    OverSize = 0
    TabOrder = 2
    OnDblClick = bNextClick
    OnResize = ImgView321Resize
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'svg'
    Filter = 'SVG Files (*.svg)|*.svg'
    Left = 239
    Top = 32
  end
end
