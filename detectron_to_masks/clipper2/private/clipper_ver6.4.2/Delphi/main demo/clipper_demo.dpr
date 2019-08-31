program clipper_demo;

uses
  Forms,
  main in 'main.pas' {MainForm},
  GR32_Misc in 'GR32_Misc.pas',
  clipper in '..\clipper.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
