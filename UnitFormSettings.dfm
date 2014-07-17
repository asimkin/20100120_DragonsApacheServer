object FormSettings: TFormSettings
  Left = 0
  Top = 0
  Caption = 'Settings'
  ClientHeight = 80
  ClientWidth = 235
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
  object Label1: TLabel
    Left = 8
    Top = 31
    Width = 147
    Height = 13
    Caption = 'Update servers time (seconds)'
  end
  object Label2: TLabel
    Left = 8
    Top = 58
    Width = 52
    Height = 13
    Caption = 'Checked ip'
  end
  object Edit1: TEdit
    Left = 161
    Top = 28
    Width = 72
    Height = 21
    TabOrder = 0
    Text = '20'
  end
  object CheckBox1: TCheckBox
    Left = 8
    Top = 8
    Width = 97
    Height = 17
    Caption = 'Minimize to tray'
    TabOrder = 1
    OnClick = CheckBox1Click
  end
  object Edit2: TEdit
    Left = 80
    Top = 55
    Width = 153
    Height = 21
    TabOrder = 2
    Text = '127.0.0.1'
  end
  object CheckBox2: TCheckBox
    Left = 130
    Top = 8
    Width = 97
    Height = 17
    Caption = 'Tray Icon'
    TabOrder = 3
    OnClick = CheckBox2Click
  end
end
