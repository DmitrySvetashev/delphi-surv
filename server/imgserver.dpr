program imgserver;

uses
  Vcl.Forms,
  main in 'main.pas' {Form_main},
  full in 'full.pas' {Form_full};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm_main, Form_main);
  Application.CreateForm(TForm_full, Form_full);
  Application.Run;
end.
