unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Data.Bind.EngExt,
  Vcl.Bind.DBEngExt, System.Rtti, System.Bindings.Outputs, Vcl.Bind.Editors,
  Data.Bind.Components;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    eMajor: TEdit;
    eMinor: TEdit;
    eRevision: TEdit;
    eBuild: TEdit;
    eProjectFile: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    cbChangeBuild: TCheckBox;
    bChangeVersion: TButton;
    bGetProjectFile: TButton;
    BindingsList1: TBindingsList;
    OpenDialog1: TOpenDialog;
    procedure bChangeVersionClick(Sender: TObject);
    procedure bGetProjectFileClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cbChangeBuildClick(Sender: TObject);
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
      var Resize: Boolean);
    procedure eMajorChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  System.Win.Registry,
  UnParseDproj,
  App_Ops, Str_Ops, Form_Ops;

var
  progConfig : TRegIniFile;
  ctrlForm : TFormControl;

{$R *.dfm}

//***************************************************************************
//
//  FUNCTION  :
//
//  I/P       :
//
//  O/P       :
//
//  OPERATION :
//
//  UPDATED   :
//
//***************************************************************************
procedure TForm1.bChangeVersionClick(Sender: TObject);
var
  DprojParser : TDprojParser;

begin
  if ((OpenDialog1.FileName = '') or
      (not FileExists(OpenDialog1.FileName))) then
  begin
    MessageDlg('Invalid DPROJ project file', mtError, [mbOk], 0);
    bGetProjectFile.SetFocus;
    Exit;
  end; // if

  if ((not IsAnInteger(eMajor.Text)) or
      (not IsAnInteger(eMinor.Text)) or
      (not IsAnInteger(eRevision.Text)) or
      ((not IsAnInteger(eBuild.Text)) and (cbChangeBuild.Checked))) then
  begin
    MessageDlg('Invalid version information', mtError, [mbOk], 0);
    if (not IsAnInteger(eMajor.Text)) then
      eMajor.SetFocus
    else if (not IsAnInteger(eMinor.Text)) then
      eMinor.SetFocus
    else if (not IsAnInteger(eRevision.Text)) then
      eRevision.SetFocus
    else
      eBuild.SetFocus;
    Exit;
  end; // if

  DprojParser := TDprojParser.Create;
  try
    DprojParser.DprojFile := OpenDialog1.FileName;
    DprojParser.VersionString :=
      eMajor.Text + '.' + eMinor.Text + '.' + eRevision.Text +
      ifthens(cbchangeBuild.Checked, '.' + eBuild.Text, '');
    DprojParser.ChangeVersion;

    MessageDlg('To effect this change:' + #13 +
               '1) Expand and highlight each required Build Configuration.' + #13 +
               '2) Rebuild it.',
               mtInformation, [mbOk], 0);

    bChangeVersion.Enabled := FALSE;
  finally
    DprojParser.Free;
  end;
end;

//***************************************************************************
//
//  FUNCTION  :
//
//  I/P       :
//
//  O/P       :
//
//  OPERATION :
//
//  UPDATED   :
//
//***************************************************************************
procedure TForm1.bGetProjectFileClick(Sender: TObject);
var
  DprojParser : TDprojParser;

begin
  if (OpenDialog1.Execute) then
  begin
    eProjectFile.Text := OpenDialog1.FileName;

    progConfig.WriteString('Config', 'Last Folder', ExtractFilePath(eProjectFile.Text));

    DprojParser := TDprojParser.Create;
    try
      DprojParser.DprojFile := OpenDialog1.FileName;
      DprojParser.GetVersionInfo(Memo1.Lines);

      eMajor.SetFocus;

      eMajorChange(Sender);
    finally
      DprojParser.Free;
    end;
  end;
end;

//***************************************************************************
//
//  FUNCTION  :
//
//  I/P       :
//
//  O/P       :
//
//  OPERATION :
//
//  UPDATED   :
//
//***************************************************************************
procedure TForm1.cbChangeBuildClick(Sender: TObject);
begin
  eBuild.Visible := cbChangeBuild.Checked;
  eMajorChange(Sender);
end;

//***************************************************************************
//
//  FUNCTION  :
//
//  I/P       :
//
//  O/P       :
//
//  OPERATION :
//
//  UPDATED   :
//
//***************************************************************************
procedure TForm1.eMajorChange(Sender: TObject);
begin
  bChangeVersion.Enabled := (
    (eMajor.Text <> '') and
    (eMinor.Text <> '') and
    (eRevision.Text <> '') and
    ((not cbChangeBuild.Checked) or (eBuild.Text <> '')) and
    (FileExists(eProjectFile.Text))
  );
end;

//***************************************************************************
//
//  FUNCTION  :
//
//  I/P       :
//
//  O/P       :
//
//  OPERATION :
//
//  UPDATED   :
//
//***************************************************************************
procedure TForm1.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  Resize := FormResizable(Self, ctrlForm, NewWidth, NewHeight);
end;

//***************************************************************************
//
//  FUNCTION  :
//
//  I/P       :
//
//  O/P       :
//
//  OPERATION :
//
//  UPDATED   :
//
//***************************************************************************
procedure TForm1.FormCreate(Sender: TObject);
begin
  SetMinimumFormSizes(ctrlForm, ClientWidth, ClientHeight);

  LoadFormSizePosition(self, progConfig, 'Main');

  cbChangeBuild.Checked := progConfig.ReadBool('Config', 'Use Build', FALSE);
  OpenDialog1.InitialDir := progConfig.ReadString('Config', 'Last Folder', '');

  Caption := Caption + ' V' + GetApplicationVersion(TRUE);
end;

//***************************************************************************
//
//  FUNCTION  :
//
//  I/P       :
//
//  O/P       :
//
//  OPERATION :
//
//  UPDATED   :
//
//***************************************************************************
procedure TForm1.FormDestroy(Sender: TObject);
begin
  SaveFormSizePosition(self, progConfig, 'Main');

  progConfig.WriteBool('Config', 'Use Build', cbChangeBuild.Checked);
end;

//***************************************************************************
//
//  FUNCTION  :
//
//  I/P       :
//
//  O/P       :
//
//  OPERATION :
//
//  UPDATED   :
//
//***************************************************************************
initialization
  progConfig := TRegIniFile.Create('Software\KED\VersionChange')

//***************************************************************************
//
//  FUNCTION  :
//
//  I/P       :
//
//  O/P       :
//
//  OPERATION :
//
//  UPDATED   :
//
//***************************************************************************
finalization
  progConfig.Free;

end.
