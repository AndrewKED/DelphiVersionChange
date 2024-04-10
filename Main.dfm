object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Change Version'
  ClientHeight = 401
  ClientWidth = 569
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCanResize = FormCanResize
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    569
    401)
  TextHeight = 15
  object Label1: TLabel
    Left = 15
    Top = 15
    Width = 133
    Height = 15
    Caption = 'DPROJ file to be changed'
  end
  object Label2: TLabel
    Left = 15
    Top = 70
    Width = 125
    Height = 15
    Caption = 'Current version content'
  end
  object Label3: TLabel
    Left = 20
    Top = 325
    Width = 116
    Height = 15
    Anchors = [akLeft, akBottom]
    Caption = 'New version number :'
  end
  object Label4: TLabel
    Left = 75
    Top = 345
    Width = 32
    Height = 15
    Anchors = [akLeft, akBottom]
    Caption = 'Minor'
  end
  object Label5: TLabel
    Left = 20
    Top = 345
    Width = 31
    Height = 15
    Anchors = [akLeft, akBottom]
    Caption = 'Major'
  end
  object Label6: TLabel
    Left = 130
    Top = 345
    Width = 44
    Height = 15
    Anchors = [akLeft, akBottom]
    Caption = 'Revision'
  end
  object Memo1: TMemo
    Left = 15
    Top = 90
    Width = 540
    Height = 226
    Anchors = [akLeft, akTop, akRight, akBottom]
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object eMajor: TEdit
    Left = 20
    Top = 365
    Width = 45
    Height = 23
    Anchors = [akLeft, akBottom]
    NumbersOnly = True
    TabOrder = 3
    OnChange = eMajorChange
  end
  object eMinor: TEdit
    Left = 75
    Top = 365
    Width = 45
    Height = 23
    Anchors = [akLeft, akBottom]
    NumbersOnly = True
    TabOrder = 4
    OnChange = eMajorChange
  end
  object eRevision: TEdit
    Left = 130
    Top = 365
    Width = 45
    Height = 23
    Anchors = [akLeft, akBottom]
    NumbersOnly = True
    TabOrder = 5
    OnChange = eMajorChange
  end
  object eBuild: TEdit
    Left = 185
    Top = 365
    Width = 45
    Height = 23
    Anchors = [akLeft, akBottom]
    NumbersOnly = True
    TabOrder = 7
    Visible = False
    OnChange = eMajorChange
  end
  object eProjectFile: TEdit
    Left = 15
    Top = 35
    Width = 506
    Height = 23
    Anchors = [akLeft, akTop, akRight]
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 0
  end
  object cbChangeBuild: TCheckBox
    Left = 185
    Top = 344
    Width = 46
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Build'
    TabOrder = 6
    OnClick = cbChangeBuildClick
  end
  object bChangeVersion: TButton
    Left = 240
    Top = 365
    Width = 316
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Make the change'
    TabOrder = 8
    OnClick = bChangeVersionClick
  end
  object bGetProjectFile: TButton
    Left = 530
    Top = 34
    Width = 25
    Height = 25
    Anchors = [akTop, akRight]
    Caption = '...'
    TabOrder = 1
    OnClick = bGetProjectFileClick
  end
  object BindingsList1: TBindingsList
    Methods = <>
    OutputConverters = <>
    Left = 20
    Top = 5
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = 'dproj'
    Filter = 'dproj files|*.dproj|All files|*.*'
    Title = 'Select Delphi Project file'
    Left = 385
    Top = 15
  end
end
