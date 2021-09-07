unit full;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls;

type
  TForm_full = class(TForm)
    Panel_video: TPanel;
    Image_video: TImage;
    Panel_cmd: TPanel;
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form_full: TForm_full;

implementation

{$R *.dfm}

uses main;

procedure TForm_full.FormResize(Sender: TObject);
begin
  main.Clients[Client_full_idx].PIC_W := Form_full.Image_video.Width;
  main.Clients[Client_full_idx].PIC_H := Form_full.Image_video.Height;
end;

end.
