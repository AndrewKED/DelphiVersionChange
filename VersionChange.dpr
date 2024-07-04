program VersionChange;

uses
  Vcl.Forms,
  Main in 'Main.pas' {Form1},
  UnParseDproj in 'UnParseDproj.pas',
  App_Ops in 'E:\DUnits12\App_Ops.pas',
  Form_Ops in 'E:\DUnits12\Form_Ops.pas',
  Str_Ops in 'E:\DUnits12\Str_Ops.pas',
  VCL_Ops in 'E:\DUnits12\VCL_Ops.pas',
  Ini_Ops in 'E:\DUnits12\Ini_Ops.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
