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
    cbProjectFile: TComboBox;
    procedure bChangeVersionClick(Sender: TObject);
    procedure bGetProjectFileClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cbChangeBuildClick(Sender: TObject);
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
      var Resize: Boolean);
    procedure eMajorChange(Sender: TObject);
    procedure cbProjectFileChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    procedure CheckKeyStrokes(Sender : TObject);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  System.Win.Registry, System.StrUtils,
  UnParseDproj,
  App_Ops, Str_Ops, Form_Ops, VCL_Ops, Ini_Ops;

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
procedure TForm1.CheckKeyStrokes(Sender : TObject);
begin
  if (Sender is TEdit) then
  begin
    if IsAnInteger(TEdit(Sender).Text) then
    begin
      Exit;
    end
    else if (TEdit(Sender).Text <> '') then
    begin
      if (Pos('.', TEdit(Sender).Text) > 0) then
      begin
        TEdit(Sender).Text := ReplaceStr(TEdit(Sender).Text, '.', '');
        if (ActiveControl = eMajor) then
          ActiveControl := eMinor
        else if (ActiveControl = eMinor) then
          ActiveControl := eRevision
        else if (ActiveControl = eRevision) then
        begin
          if (cbChangeBuild.Checked) then
            ActiveControl := eBuild
          else
            ActiveControl := bChangeVersion;
        end // if
        else if (ActiveControl = eBuild) then
          ActiveControl := bChangeVersion;
      end;
    end; // if
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
procedure TForm1.bChangeVersionClick(Sender: TObject);
var
  DprojParser : TDprojParser;

begin
  if ((cbProjectFile.Text = '') or
      (not FileExists(cbProjectFile.Text))) then
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
    DprojParser.DprojFile := cbProjectFile.Text;
    DprojParser.VersionString :=
      eMajor.Text + '.' + eMinor.Text + '.' + eRevision.Text +
      ifthens(cbchangeBuild.Checked, '.' + eBuild.Text, '');
    DprojParser.ChangeVersion;

    DprojParser.GetVersionInfo(Memo1.Lines);
    eMajor.Text := '';
    eMinor.Text := '';
    eRevision.Text := '';
    eBuild.Text := '';

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
begin
  if (cbProjectFile.Text <> '') then
  begin
    OpenDialog1.InitialDir := ExtractFilePath(cbProjectFile.Text);
  end;

  if (OpenDialog1.Execute) then
  begin
    cbProjectFile.Text := OpenDialog1.FileName;
    UpdateTComboBoxItems(cbProjectFile);
    cbProjectFileChange(nil)
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
procedure TForm1.cbProjectFileChange(Sender: TObject);
var
  DprojParser : TDprojParser;

begin
  progConfig.WriteString('Config', 'Last Folder', ExtractFilePath(cbProjectFile.Text));

  DprojParser := TDprojParser.Create;
  try
    DprojParser.DprojFile := cbProjectFile.Text;
    DprojParser.GetVersionInfo(Memo1.Lines);

    eMajor.SetFocus;

    eMajorChange(Sender);
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
procedure TForm1.eMajorChange(Sender: TObject);
begin
  bChangeVersion.Enabled := (
    (eMajor.Text <> '') and
    (eMinor.Text <> '') and
    (eRevision.Text <> '') and
    ((not cbChangeBuild.Checked) or (eBuild.Text <> '')) and
    (FileExists(cbProjectFile.Text))
  );

  CheckKeyStrokes(Sender);
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
procedure TForm1.FormActivate(Sender: TObject);
begin
  if (cbProjectFile.Items.Count > 0) then
  begin
    cbProjectFile.ItemIndex := 0;
    cbProjectFileChange(nil);
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
var
  n : Integer;

begin
  SetMinimumFormSizes(ctrlForm, ClientWidth, ClientHeight);

  LoadFormSizePosition(self, progConfig, 'Main');

  cbChangeBuild.Checked := progConfig.ReadBool('Config', 'Use Build', FALSE);
  OpenDialog1.InitialDir := progConfig.ReadString('Config', 'Last Folder', '');

  cbProjectFile.Items.Clear;
  for n := 0 to CountValues(progConfig, 'ProjectFiles')-1 do
  begin
    cbProjectFile.Items.Add(progConfig.ReadString('ProjectFiles', n.ToString, ''));
  end;

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
var
  n : Integer;

begin
  SaveFormSizePosition(self, progConfig, 'Main');

  progConfig.WriteBool('Config', 'Use Build', cbChangeBuild.Checked);

  for n := 0 to cbProjectFile.Items.Count-1 do
  begin
    progConfig.WriteString('ProjectFiles', n.ToString, cbProjectFile.Items[n]);
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
