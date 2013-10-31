object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'EloBot DrawBot XYZ'
  ClientHeight = 667
  ClientWidth = 1109
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel4: TPanel
    Left = 0
    Top = 0
    Width = 346
    Height = 667
    Align = alLeft
    TabOrder = 0
    ExplicitLeft = 4
    object Label1: TLabel
      Left = 8
      Top = 646
      Width = 31
      Height = 13
      Caption = 'Label1'
    end
    object Label2: TLabel
      Left = 19
      Top = 258
      Width = 10
      Height = 13
      Caption = 'X:'
    end
    object Label3: TLabel
      Left = 183
      Top = 258
      Width = 16
      Height = 13
      Caption = 'mm'
    end
    object Label4: TLabel
      Left = 19
      Top = 286
      Width = 10
      Height = 13
      Caption = 'Y:'
    end
    object Label5: TLabel
      Left = 183
      Top = 286
      Width = 16
      Height = 13
      Caption = 'mm'
    end
    object Label6: TLabel
      Left = 19
      Top = 314
      Width = 10
      Height = 13
      Caption = 'Z:'
    end
    object Label7: TLabel
      Left = 183
      Top = 314
      Width = 16
      Height = 13
      Caption = 'mm'
    end
    object Label8: TLabel
      Left = 19
      Top = 373
      Width = 34
      Height = 13
      Caption = 'Speed:'
    end
    object clearButton: TButton
      Left = 262
      Top = 582
      Width = 75
      Height = 25
      Caption = 'Clear'
      TabOrder = 0
    end
    object onlineButton: TButton
      Left = 182
      Top = 582
      Width = 75
      Height = 25
      Caption = 'online'
      TabOrder = 1
      OnClick = onlineButtonClick
    end
    object Button3: TButton
      Left = 8
      Top = 553
      Width = 121
      Height = 25
      Caption = 'Open G-Code'
      TabOrder = 2
      OnClick = Button3Click
    end
    object PortButton: TButton
      Left = 181
      Top = 553
      Width = 75
      Height = 25
      Caption = 'Serial Port'
      TabOrder = 3
      OnClick = PortButtonClick
    end
    object ConnButton: TButton
      Left = 262
      Top = 553
      Width = 75
      Height = 25
      Caption = 'Connect'
      TabOrder = 4
      OnClick = ConnButtonClick
    end
    object Memo1: TMemo
      Left = 2
      Top = 8
      Width = 337
      Height = 241
      Lines.Strings = (
        'Memo1')
      ScrollBars = ssVertical
      TabOrder = 5
    end
    object BitBtn1: TBitBtn
      Left = 8
      Top = 584
      Width = 121
      Height = 25
      Caption = 'Send G-Code'
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 6
      OnClick = BitBtn1Click
    end
    object Button1: TButton
      Left = 8
      Top = 615
      Width = 75
      Height = 25
      Caption = 'Button1'
      TabOrder = 7
    end
    object Button2: TButton
      Left = 56
      Top = 339
      Width = 75
      Height = 25
      Caption = 'Set to Zero'
      TabOrder = 8
      OnClick = Button2Click
    end
    object XEdit: TAdvSpinEdit
      Left = 56
      Top = 255
      Width = 121
      Height = 22
      SpinType = sptFloat
      Value = 0
      DateValue = 41411.024493518520000000
      HexValue = 0
      Enabled = True
      IncrementFloat = 0.042300000000000000
      IncrementFloatPage = 1.000000000000000000
      LabelFont.Charset = DEFAULT_CHARSET
      LabelFont.Color = clWindowText
      LabelFont.Height = -11
      LabelFont.Name = 'Tahoma'
      LabelFont.Style = []
      MinFloatValue = -150.000000000000000000
      MaxFloatValue = 150.000000000000000000
      Signed = True
      TabOrder = 9
      Visible = True
      Version = '1.4.4.7'
      OnChange = XEditChange
    end
    object YEdit: TAdvSpinEdit
      Left = 56
      Top = 283
      Width = 121
      Height = 22
      SpinType = sptFloat
      Value = 0
      DateValue = 41411.024493518520000000
      HexValue = 0
      Enabled = True
      IncrementFloat = 0.042300000000000000
      IncrementFloatPage = 1.000000000000000000
      LabelFont.Charset = DEFAULT_CHARSET
      LabelFont.Color = clWindowText
      LabelFont.Height = -11
      LabelFont.Name = 'Tahoma'
      LabelFont.Style = []
      MinFloatValue = -150.000000000000000000
      MaxFloatValue = 150.000000000000000000
      Signed = True
      TabOrder = 10
      Visible = True
      Version = '1.4.4.7'
      OnChange = XEditChange
    end
    object ZEdit: TAdvSpinEdit
      Left = 56
      Top = 311
      Width = 121
      Height = 22
      SpinType = sptFloat
      Value = 0
      DateValue = 41411.024493530090000000
      HexValue = 0
      Enabled = True
      IncrementFloat = 0.042300000000000000
      IncrementFloatPage = 1.000000000000000000
      LabelFont.Charset = DEFAULT_CHARSET
      LabelFont.Color = clWindowText
      LabelFont.Height = -11
      LabelFont.Name = 'Tahoma'
      LabelFont.Style = []
      MinFloatValue = -150.000000000000000000
      MaxFloatValue = 150.000000000000000000
      Signed = True
      TabOrder = 11
      Visible = True
      Version = '1.4.4.7'
      OnChange = XEditChange
    end
    object FlipX: TCheckBox
      Left = 224
      Top = 257
      Width = 97
      Height = 17
      Caption = 'Flip X'
      TabOrder = 12
    end
    object FlipY: TCheckBox
      Left = 224
      Top = 285
      Width = 97
      Height = 17
      Caption = 'Flip Y'
      Checked = True
      State = cbChecked
      TabOrder = 13
    end
    object StepSpeedEdit: TAdvSpinEdit
      Left = 56
      Top = 370
      Width = 121
      Height = 22
      SpinType = sptFloat
      Value = 200
      FloatValue = 200.000000000000000000
      HexValue = 0
      Enabled = True
      IncrementFloat = 1.000000000000000000
      IncrementFloatPage = 1.000000000000000000
      LabelFont.Charset = DEFAULT_CHARSET
      LabelFont.Color = clWindowText
      LabelFont.Height = -11
      LabelFont.Name = 'Tahoma'
      LabelFont.Style = []
      MaxValue = 300
      MaxFloatValue = 300.000000000000000000
      Signed = True
      TabOrder = 14
      Visible = True
      Version = '1.4.4.7'
      OnChange = StepSpeedEditChange
    end
  end
  object Panel3: TPanel
    Left = 346
    Top = 0
    Width = 763
    Height = 667
    Align = alClient
    TabOrder = 1
    object Panel2: TPanel
      Left = 1
      Top = 638
      Width = 761
      Height = 28
      Align = alBottom
      TabOrder = 0
      object ZoomLabel: TLabel
        Left = 9
        Top = 7
        Width = 30
        Height = 13
        Caption = 'Zoom:'
      end
      object ProgressLabel: TLabel
        Left = 280
        Top = 8
        Width = 46
        Height = 13
        Caption = 'Progress:'
      end
      object ScrollBar1: TScrollBar
        Left = 76
        Top = 6
        Width = 141
        Height = 17
        Max = 160
        Min = 1
        PageSize = 0
        Position = 81
        TabOrder = 0
        OnChange = ScrollBar1Change
      end
      object ProgressBar1: TProgressBar
        Left = 348
        Top = 6
        Width = 405
        Height = 17
        TabOrder = 1
      end
    end
    object ScrollBox1: TScrollBox
      Left = 1
      Top = 1
      Width = 761
      Height = 637
      HorzScrollBar.Smooth = True
      HorzScrollBar.Tracking = True
      VertScrollBar.Smooth = True
      VertScrollBar.Tracking = True
      Align = alClient
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 1
      object Image1: TPaintBox
        Left = -1
        Top = -1
        Width = 758
        Height = 633
        OnPaint = Image1Paint
      end
    end
  end
  object IdHTTPServer1: TIdHTTPServer
    Bindings = <>
    DefaultPort = 88
    OnCommandGet = IdHTTPServer1CommandGet
    Left = 264
    Top = 56
  end
  object ComPort: TComPort
    BaudRate = br115200
    Port = 'COM4'#0'anel'
    Parity.Bits = prNone
    StopBits = sbOneStopBit
    DataBits = dbEight
    DiscardNull = True
    Events = [evRxChar, evTxEmpty, evRxFlag, evRing, evBreak, evCTS, evDSR, evError, evRLSD, evRx80Full]
    FlowControl.OutCTSFlow = False
    FlowControl.OutDSRFlow = False
    FlowControl.ControlDTR = dtrEnable
    FlowControl.ControlRTS = rtsDisable
    FlowControl.XonXoffOut = False
    FlowControl.XonXoffIn = False
    StoredProps = [spBasic]
    TriggersOnRxChar = True
    OnAfterOpen = ComPortAfterOpen
    OnAfterClose = ComPortAfterClose
    OnRxChar = ComPortRxChar
    Left = 264
    Top = 120
  end
  object OpenDialog1: TOpenDialog
    Left = 264
    Top = 192
  end
  object xyzTimer: TTimer
    Interval = 1
    OnTimer = xyzTimerTimer
    Left = 152
    Top = 176
  end
end
