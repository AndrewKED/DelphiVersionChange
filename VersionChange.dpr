program VersionChange;

uses
  Vcl.Forms,
  Main in 'Main.pas' {Form1},
  UnParseDproj in 'UnParseDproj.pas',
  App_Ops in 'E:\DUnits11\App_Ops.pas',
  Form_Ops in 'E:\DUnits11\Form_Ops.pas',
  Str_Ops in 'E:\DUnits11\Str_Ops.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
