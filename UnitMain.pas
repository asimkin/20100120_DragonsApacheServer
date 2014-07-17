unit UnitMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Sockets, DB, DBClient, MConnect, SConnect;

type
  TFormMain = class(TForm)
    ShapeApache: TShape;
    ShapeMySQL: TShape;
    LabelApache: TLabel;
    LabelMySQL: TLabel;
    EditApache: TEdit;
    EditMySQL: TEdit;
    ButtonStart: TButton;
    ButtonRestart: TButton;
    ButtonStop: TButton;
    ButtonSwitchOff: TButton;
    Timer: TTimer;
    TcpClient: TTcpClient;
    procedure TimerTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TMyThread = class(TThread)
  protected
    procedure Execute; override;
end;

var
  FormMain          : TFormMain;
  ip                : string  = '127.0.0.1';
  Enabled           : boolean = false;
  Disabled          : boolean = false;

implementation

{$R *.dfm}

procedure TMyThread.Execute;
begin
  with FormMain do begin
  // apache
    TcpClient.RemotePort := EditApache.Text;
    TcpClient.RemoteHost := ip;
    TcpClient.Open;
    if TcpClient.Connected then begin
      ShapeApache.Brush.Color := clLime;
      Enabled                 := True;
    end
    else ShapeApache.Brush.Color := clRed;
    TcpClient.Close;
  // mysql
  {  TcpClient.RemotePort := EditMySQL.Text;
    TcpClient.RemoteHost := ip;
    TcpClient.Open;
    if TcpClient.Connected then begin
      ShapeMySQL.Brush.Color  := clLime;
      Disabled                := False;
    end
    else begin
      ShapeMySQL.Brush.Color  := clRed;
      Enabled                 := False;
      Disabled                := True;
    end;
    TcpClient.Close; }
  // check
   { if (ShapeApache.Brush.Color = clLime)and(ShapeMySQL.Brush.Color = clLime)
      then Enabled := True;
    if (ShapeApache.Brush.Color = clRed)and(ShapeMySQL.Brush.Color = clRed)
      then Disabled := True;  }
  end;
end;

procedure TFormMain.TimerTimer(Sender: TObject);
var ThreadID: DWORD; HThread: THandle;
MyThread: TMyThread;
begin
  //HThread := CreateThread(nil, 0, @CheckServers, nil, 0, ThreadID);
 //CheckServers();
  MyThread := TMyThread.Create(False);
  if Enabled then
  begin
    ButtonStart.Enabled := False;
    ButtonStop.Enabled  := True;
  end
  else if Disabled then begin
    ButtonStart.Enabled := True;
    ButtonStop.Enabled  := False;
  end
  else begin
    ButtonStart.Enabled := True;
    ButtonStop.Enabled  := True;
  end;
end; // procedure TFormMain.TimerTimer();

end.
