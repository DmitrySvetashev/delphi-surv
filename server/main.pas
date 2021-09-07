unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdContext, IdServerIOHandler,
  IdServerIOHandlerSocket, IdServerIOHandlerStack, IdBaseComponent, IdComponent,
  IdCustomTCPServer, IdTCPServer, Vcl.ExtCtrls, Vcl.StdCtrls, IdEchoServer,
  Vcl.ComCtrls, sMemo, Vcl.Grids, Vcl.WinXPanels, System.ImageList, Vcl.ImgList,
  Vcl.BaseImageCollection, Vcl.ImageCollection, Vcl.VirtualImageList,
  System.Actions, Vcl.ActnList, Vcl.Menus, IdAntiFreezeBase, IdAntiFreeze, Jpeg, IniFiles, full,
  IdIPWatch;

type
  TForm_main = class(TForm)
    IdTCPServer_Pict: TIdTCPServer;
    IdTCPServer_Cmd: TIdTCPServer;
    Connect_Timer: TTimer;
    GridPanel_video: TGridPanel;
    PopupMenu: TPopupMenu;
    ImageList: TImageList;
    ActionList: TActionList;
    Action_disconnect: TAction;
    Action_sendmsg: TAction;
    Action_config: TAction;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    Action_expand: TAction;
    N4: TMenuItem;
    Panel1: TPanel;
    Image1: TImage;
    Panel2: TPanel;
    Image2: TImage;
    Panel3: TPanel;
    Image3: TImage;
    Panel4: TPanel;
    Image4: TImage;
    Panel5: TPanel;
    Image5: TImage;
    Panel6: TPanel;
    Image6: TImage;
    Panel7: TPanel;
    Image7: TImage;
    Panel8: TPanel;
    Image8: TImage;
    Panel9: TPanel;
    Image9: TImage;
    Panel10: TPanel;
    Image10: TImage;
    Panel11: TPanel;
    Image11: TImage;
    Panel12: TPanel;
    Image12: TImage;
    Panel13: TPanel;
    Image13: TImage;
    Panel14: TPanel;
    Image14: TImage;
    Panel15: TPanel;
    Image15: TImage;
    Panel16: TPanel;
    Image16: TImage;
    IdIPWatch: TIdIPWatch;

    function FindID(ClientName: String) : Byte;
    procedure FormCreate(Sender: TObject);
    procedure IdTCPServer_CmdExecute(AContext: TIdContext);
    procedure IdTCPServer_PictExecute(AContext: TIdContext);
    procedure Connect_TimerTimer(Sender: TObject);
    procedure GridPanel_videoResize(Sender: TObject);
    procedure PreviewClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TCli_info = record
                ID : Byte;
                IP, NAME : String[255];
                UPTIME, PIC_Q, FPS : Byte;
                PIC_W, PIC_H : UInt16;
              end;

var
  Form_main: TForm_main;
  Client_count : Byte;
  Clients : array [1..16] of TCli_info;
  Preffered_pict_quality, Preffered_fps : Byte;
  Client_full_idx : Byte;


implementation

{$R *.dfm}

function TForm_main.FindID(ClientName: String): Byte;
var
  i: Integer;
  pos_id : Byte;
begin
  pos_id := 0;
  if Client_count > 0
    then begin
          for i := 1 to Client_count do
            begin
              if (AnsiCompareStr(Clients[i].NAME,ClientName) = 0)
                then begin
                  pos_id := Clients[i].ID;
                  break;
                end;
            end;
          end;
  Result := pos_id;
end;

procedure TForm_main.FormCreate(Sender: TObject);
var
  Server_params_file : Tinifile;
  buffer : array[0..255] of WideChar;
  buff_size : Dword;
  Server_name : String;
begin
  Server_params_file := TiniFile.Create(ExtractFilePath(ParamStr(0))+'server.ini');
  Preffered_pict_quality := Server_params_file.ReadInteger('Видео','Качество',100);
  Preffered_fps := Server_params_file.ReadInteger('Видео','кадр/сек',10);
  Server_params_file.Free;

  Server_name := 'Сервер ';
  buff_size := 256;
  if GetComputerName (buffer, buff_size)
    then Server_name := Server_name + String(buffer)
    else Server_name := Server_name + 'noname';
  Form_main.Caption := Server_name + ' (' + IdIPWatch.LocalIP + ')';

  Client_count := 0;
  Client_full_idx := 0;
end;

procedure TForm_main.FormClose(Sender: TObject; var Action: TCloseAction);
var
  Server_params_file : Tinifile;
begin
  Server_params_file := TiniFile.Create(ExtractFilePath(ParamStr(0))+'server.ini');
  Server_params_file.WriteInteger('Видео','Качество',Preffered_pict_quality);
  Server_params_file.WriteInteger('Видео','кадр/сек',Preffered_fps);
  Server_params_file.Free;
end;

procedure TForm_main.GridPanel_videoResize(Sender: TObject);
var
  i : Integer;
begin
  for i := 1 to Client_count do
    begin
      Clients[i].PIC_W := (FindComponent('Image'+IntToStr(i)) as TImage).Width;
      Clients[i].PIC_H := (FindComponent('Image'+IntToStr(i)) as TImage).Height;
    end;
end;

procedure TForm_main.IdTCPServer_CmdExecute(AContext: TIdContext);
var
  Cmd, C_id : Byte;
  C_ip, C_name : String;
  Video_prev : TBitmap;
begin
  Video_prev := TBitmap.Create;
  Cmd := AContext.Connection.IOHandler.ReadByte;
  case Cmd of
    0 : begin
          C_ip := AContext.Connection.IOHandler.ReadLn();
          C_name := AContext.Connection.IOHandler.ReadLn();
          C_id := FindID(C_name);
          if C_id = 0
            then begin
                  Inc(Client_count);
                  C_id := Client_count;
                 end;
          Clients[C_id].ID := C_id;
          Clients[C_id].IP := C_ip;
          Clients[C_id].NAME := C_name;
          Clients[C_id].UPTIME := 0;
          Clients[C_id].PIC_Q := Preffered_pict_quality;
          Clients[C_id].PIC_W := (FindComponent('Image'+IntToStr(C_id)) as TImage).Width;
          Clients[C_id].PIC_H := (FindComponent('Image'+IntToStr(C_id)) as TImage).Height;
          Clients[C_id].FPS := Preffered_fps;
          (FindComponent('Image'+IntToStr(C_id)) as TImage).Visible := True;
          (FindComponent('Image'+IntToStr(C_id)) as TImage).Hint := IntToStr(C_id) + ' - ' + C_name + ' (' + C_ip + ')';
          AContext.Connection.IOHandler.Write(C_id);
        end;
    1 : begin
          C_id := AContext.Connection.IOHandler.ReadByte;
          AContext.Connection.IOHandler.Write(Clients[C_id].PIC_Q);
          AContext.Connection.IOHandler.Write(Clients[C_id].PIC_W,false);
          AContext.Connection.IOHandler.Write(Clients[C_id].PIC_H,false);
          AContext.Connection.IOHandler.Write(Clients[C_id].FPS);
        end;
    end;
  Video_prev.Destroy;
end;

procedure TForm_main.IdTCPServer_PictExecute(AContext: TIdContext);
var
  Pict_stream : TMemoryStream;
  Stream_size : uInt64;
  Jpeg_Picture : TJpegImage;
  C_id : Byte;
begin
  Pict_stream := TMemoryStream.Create;
  Jpeg_Picture := TJpegImage.Create;
  C_id := AContext.Connection.IOHandler.ReadByte;
  Stream_size := AContext.Connection.IOHandler.ReadUInt64(false);
  AContext.Connection.IOHandler.ReadStream(Pict_stream, Stream_size);
  Pict_stream.Position := 0;
  Jpeg_picture.LoadFromStream(Pict_stream);
  (FindComponent('Image'+IntToStr(C_id)) as TImage).Picture.Assign(Jpeg_Picture);
//  (FindComponent('Image'+IntToStr(C_id)) as TImage).Picture.LoadFromStream(Pict_stream);
  Pict_stream.Position := 0;
  if (C_id = Client_full_idx) then Form_full.Image_video.Picture.Assign(Jpeg_Picture);
//  if (C_id = Client_full_idx) then Form_full.Image_video.Picture.LoadFromStream(Pict_stream);
  Pict_stream.Clear;
  Pict_stream.Free;
//  Pict_stream.Destroy;
  Jpeg_Picture.Free;
  Clients[C_id].UPTIME := 0;
end;

procedure TForm_main.Connect_TimerTimer(Sender: TObject);
var
  i: Integer;
begin
  for i := 1 to Client_count do
    begin
      inc(Clients[i].UPTIME);
      if Clients[i].UPTIME > 1 then (FindComponent('Image'+IntToStr(i)) as TImage).Visible := False;
    end;
end;

procedure TForm_main.PreviewClick(Sender: TObject);
var
  img_name : String;
begin
  img_name := (Sender as TImage).Name;
  Delete(img_name,1,5);
  Client_full_idx := StrToInt(img_name);
  Form_full.Caption :=  img_name + ' - ' + Clients[Client_full_idx].NAME + ' (' + Clients[Client_full_idx].IP + ')';
//  Form_full.Width :=  Screen.Width;
//  Form_full.Height :=  Screen.Height;
  Clients[Client_full_idx].PIC_W := Form_full.Image_video.Width;
  Clients[Client_full_idx].PIC_H := Form_full.Image_video.Height;
  Form_full.ShowModal;
  Clients[Client_full_idx].PIC_W := (FindComponent('Image'+IntToStr(Client_full_idx)) as TImage).Width;
  Clients[Client_full_idx].PIC_H := (FindComponent('Image'+IntToStr(Client_full_idx)) as TImage).Height;
//  Form_full.Width :=  Clients[Client_full_idx].PIC_W;
//  Form_full.Height :=  Clients[Client_full_idx].PIC_H;
  Client_full_idx := 0;
end;

end.
