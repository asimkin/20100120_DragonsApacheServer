program ServerMonitor;

{$R *.dres}

uses
  Forms,
  UnitMain in 'UnitMain.pas' {FormMain},
  UnitFormSettings in 'UnitFormSettings.pas' {FormSettings},
  UnitINI in 'UnitINI.pas',
  UnitProcess in 'UnitProcess.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Server monitor';
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TFormSettings, FormSettings);
  Application.Run;
end.
