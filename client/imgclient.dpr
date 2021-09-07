program imgclient;

uses
  Vcl.Forms,
  main in 'main.pas' {Client_MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TClient_MainForm, Client_MainForm);
  Application.Run;
end.
