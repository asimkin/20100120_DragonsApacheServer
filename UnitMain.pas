unit UnitMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Menus, WinSock, ShellApi, IniFiles, UnitINI,
  UnitFormSettings, UnitProcess;

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
    PopupMenu: TPopupMenu;
    MainMenu: TMainMenu;
    FI1: TMenuItem;
    Preferences1: TMenuItem;
    Exit1: TMenuItem;
    Minimize1: TMenuItem;
    About1: TMenuItem;
    Actions1: TMenuItem;
    Start1: TMenuItem;
    Restart1: TMenuItem;
    Stop1: TMenuItem;
    Switchof1: TMenuItem;
    Actions2: TMenuItem;
    SwitchOff1: TMenuItem;
    Stop2: TMenuItem;
    Restart2: TMenuItem;
    Start2: TMenuItem;
    File1: TMenuItem;
    Exit2: TMenuItem;
    Settings1: TMenuItem;
    AboutandHelp1: TMenuItem;
    Minimize2: TMenuItem;
    Help1: TMenuItem;
    About2: TMenuItem;
    Help2: TMenuItem;
    About3: TMenuItem;
    Configure1: TMenuItem;
    Apache1: TMenuItem;
    MysQL1: TMenuItem;
    PHP1: TMenuItem;
    Server1: TMenuItem;
    Server2: TMenuItem;
    Configure2: TMenuItem;
    PHP2: TMenuItem;
    MySQL2: TMenuItem;
    Apache2: TMenuItem;
    Server3: TMenuItem;
    Server4: TMenuItem;
    OpenSite1: TMenuItem;
    OpenSite2: TMenuItem;
    procedure UpdateIconHint();
    procedure TimerTimer(Sender: TObject);
    procedure IconOperation(Operation:integer; Icon:TIcon; hint:string='');
    procedure MinimizeForm();
    procedure UpdateTrayIcon();
    procedure Preferences1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Minimize1Click(Sender: TObject);
    procedure Minimize2Click(Sender: TObject);
    procedure Settings1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Exit2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ButtonStartClick(Sender: TObject);
    procedure ButtonRestartClick(Sender: TObject);
    procedure ButtonStopClick(Sender: TObject);
    procedure ButtonSwitchOffClick(Sender: TObject);
    procedure Start1Click(Sender: TObject);
    procedure Restart1Click(Sender: TObject);
    procedure Stop1Click(Sender: TObject);
    procedure Switchof1Click(Sender: TObject);
    procedure Start2Click(Sender: TObject);
    procedure Restart2Click(Sender: TObject);
    procedure Stop2Click(Sender: TObject);
    procedure SwitchOff1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure AboutandHelp1Click(Sender: TObject);
    procedure About3Click(Sender: TObject);
    procedure About2Click(Sender: TObject);
    procedure Apache1Click(Sender: TObject);
    procedure Apache2Click(Sender: TObject);
    procedure MySQL2Click(Sender: TObject);
    procedure MysQL1Click(Sender: TObject);
    procedure PHP1Click(Sender: TObject);
    procedure PHP2Click(Sender: TObject);
    procedure Server3Click(Sender: TObject);
    procedure Server4Click(Sender: TObject);
    procedure OpenSite1Click(Sender: TObject);
    procedure OpenSite2Click(Sender: TObject);
  protected
    procedure ControlWindow(var Msg: TMessage); message WM_SYSCOMMAND;
    procedure IconMouse(var Msg: TMessage); message WM_USER + 1;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TScanerThread = class(TThread)
  protected
    SleepTime: integer;
    procedure Execute; override;
    procedure Draw;
end;

var
  FormMain          : TFormMain;
  ApacheOn          : boolean     = false;
  MySQLOn           : boolean     = false;
  IniFile           : TIniFile;
  Minimize          : boolean     = true;
  TimerIntreval     : Integer     = 20;
  ip                : ansistring  = '127.0.0.1';
  TrayIcon          : boolean     = true;
  FormMinimized     : boolean;
  PortA             : Integer     = 80;
  PortM             : Integer     = 3306;
  cfgA              : string      = 'usr\local\apache\';
  cfgPHP            : string      = 'usr\local\php5\';
  cfgM              : string      = 'usr\local\mysql5\';
  FirstRun          : boolean;

implementation

{$R *.dfm}

/////////////////////////// Advanced ///////////////////////////

function IfThen(AValue: Boolean; const ATrue: String; const AFalse: String): String;
begin
  if AValue then
    Result := ATrue
  else
    Result := AFalse;
end;

/////////////////////////// Work with FORM ///////////////////////////

procedure UpdateForm();
begin
  with FormMain do begin
    Minimize1.Checked  := Minimize;
    Minimize2.Checked  := Minimize;
    Timer.Interval     := TimerIntreval*1000;
    EditApache.Text    := IntToStr(PortA);
    EditMySQL.Text     := IntToStr(PortM);
  end;
end; // UpdateForm();

procedure UpdateFromINI(UpdateTray: boolean = true);
begin
  ReadIni(TimerIntreval, Minimize, ip, TrayIcon, PortA, PortM, cfgA, cfgPHP, cfgM, FirstRun);
  UpdateForm();
  if UpdateTray then FormMain.UpdateTrayIcon();
end;

function TrayIconName(): String;
begin
  if ApacheOn          and MySQLOn then     Result := 'Icon_on_on'
  else if ApacheOn     and not MySQLOn then Result := 'Icon_on_off'
  else if not ApacheOn and MySQLOn then     Result := 'Icon_off_on'
  else if not ApacheOn and not MySQLOn then Result := 'Icon_off_off'
  else result := '';
end;

/////////////////////////// Work with Socket ///////////////////////////

function d_addr(IPaddr : ansistring) : Cardinal;
var
  pa: PAnsiChar;
  sa: TInAddr;
  Host: PHostEnt;
begin
  Result := inet_addr(PAnsiChar(IPaddr));
  // Перевод если адреа не в ip4
  if Result = INADDR_NONE then
  begin
    host := GetHostByName(PAnsiChar(IPaddr));
    if Host = nil then
      exit
    else
    begin
      // Преобразование
      pa              := Host^.h_addr_list^;
      sa.S_un_b.s_b1  := pa[0];
      sa.S_un_b.s_b2  := pa[1];
      sa.S_un_b.s_b3  := pa[2];
      sa.S_un_b.s_b4  := pa[3];
      with TInAddr(sa).S_un_b do
        Result:=inet_addr(PAnsiChar(AnsiString(IntToStr(Ord(s_b1)) + '.' + IntToStr(Ord(s_b2)) + '.' +
          IntToStr(Ord(s_b3)) + '.' + IntToStr(Ord(s_b4)))));
    end;
  end;
end; // d_addr()

function CheckSocket(ip:ansistring; port: word): boolean;
var WSA   : WSAData;
    Sock  : TSocket;
    Adress: TSockAddr;
begin
  if WSAStartup($101, WSA) <> 0 then begin
    Result := False;
    Exit;
  end;
  Adress.sin_family       := AF_INET;
  {
  Adress.sin_addr.S_addr  := inet_addr(pansichar(ip)) + 127;
  Adress.sin_addr.S_addr  := inet_addr('127.0.0.1');
  }
  Adress.sin_addr.S_addr  := d_addr(ip);
  Sock                    := socket(AF_INET, SOCK_STREAM, 0);
  if Sock = INVALID_SOCKET then begin
    Result := False;
    Exit;
  end;
  Adress.sin_port := htons(port);
  if connect(Sock, Adress, sizeof(Adress)) = 0 then Result := True
  else Result := False;
  closesocket(Sock);
  WSACleanup;
end; // CheckSocket();

procedure TScanerThread.Draw;
begin
  if ApacheOn then FormMain.ShapeApache.Brush.Color := clLime
  else FormMain.ShapeApache.Brush.Color := clRed;
  if MySQLOn then FormMain.ShapeMySQL.Brush.Color := clLime
  else FormMain.ShapeMySQL.Brush.Color := clRed;
  // Icon
  FormMain.UpdateTrayIcon();
  FormMain.UpdateIconHint();
end; // TScanerThread.Draw()

procedure TScanerThread.Execute;
begin
  if SleepTime <> 0 then Sleep(SleepTime);
  // apache
  ApacheOn  := CheckSocket(ip, strtoint(FormMain.EditApache.Text));
  Synchronize(Draw);
  // mysql
  MySQLOn   := CheckSocket(ip, strtoint(FormMain.EditMySQL.Text));
  Synchronize(Draw);
  Terminate;
end; // TScanerThread.Execute()

procedure CheckServers();
var ApacheOn, MySQLOn: boolean;
begin
  // apache
  ApacheOn  := CheckSocket(ip, strtoint(FormMain.EditApache.Text));
  // mysql
  MySQLOn   := CheckSocket(ip, strtoint(FormMain.EditMySQL.Text));
  // отображение
  if ApacheOn then FormMain.ShapeApache.Brush.Color := clLime
  else FormMain.ShapeApache.Brush.Color := clRed;
  if MySQLOn then FormMain.ShapeMySQL.Brush.Color := clLime
  else FormMain.ShapeMySQL.Brush.Color := clRed;
  // Icon
  FormMain.UpdateTrayIcon();
  FormMain.UpdateIconHint();
end;

procedure RunThread(sleep:integer=0);
var Scaner: TScanerThread;
begin
  //создать процесс, но пока не запускать
  Scaner                  := TScanerThread.Create(true);
  //Освободить память при прерывании процесса
  Scaner.FreeOnTerminate  := true;
  //установить приоритет
  Scaner.Priority         := tpLowest;
  Scaner.SleepTime := sleep;
  //запустить процесс
  Scaner.Resume;
end;

/////////////////////////// MENUS Procedures ///////////////////////////

procedure StartEXE(filename: string);
begin
  if ShellExecute(FormMain.Handle, 'open', pwidechar(filename), nil, nil, SW_HIDE) < 32 then begin
    ShowMessage('Error execute programm "'+filename+'"');
  end;
end;

procedure OpenDragons();
begin
  ShellExecute(FormMain.Handle, nil, 'http://dragons-portal.org/forum/viewtopic.php?&t=2194', nil, nil, SW_SHOW);
end;

procedure Run();
begin
  StartEXE('denwer\Run.exe');
  RunThread(5000);
end;

procedure Restart();
begin
  StartEXE('denwer\Restart.exe');
  RunThread(5000);
end;

procedure Stop();
begin
  StartEXE('denwer\Stop.exe');
  RunThread(7000);
end;

procedure SwitchOff();
begin
  StartEXE('denwer\SwitchOff.exe');
  RunThread(7000);
end;

procedure About();
begin
  ShowMessage('Server Monitor v.1.1.0.1 from 02.02.2010' + #13#10 +
              'by Anatoly Simkin special for Dragons-Portal (c)');
end;

procedure OpenCFGFile(FileName:string);
begin
    if WinExec(pansichar(ansistring('Notepad '+filename)), SW_SHOW) < 32 then begin
  //if ShellExecute(FormMain.Handle, 'open', pwidechar(filename), nil, nil, SW_NORMAL) < 32 then begin
    ShowMessage('Error open configuration file "'+filename+'"');
  end;
end;

procedure ApacheCFG();
begin
  //ShellExecute(FormMain.Handle, 'open', 'usr\local\php5\php.ini', nil, nil, SW_SHOW);
  // Используем ShellExecute
  //WinExec('Notepad usr\local\apache\conf\httpd.conf', SW_SHOW);
{if ShellExecute(FormMain.Handle, 'open', 'usr\local\apache\conf\httpd.conf', nil, nil, SW_SHOW) < 32 then
   begin
     ShowMessage('Немогу выполнить ShellExecute !')
   end;}
  OpenCFGFile(cfgA + 'conf\httpd.conf');
end;

procedure MySQLCFG();
begin
  OpenCFGFile(cfgM + 'my.cnf');
end;

procedure PHPCFG();
begin
  OpenCFGFile(cfgPHP + 'php.ini');
end;

procedure OpenLocalHost();
begin
  ShellExecute(FormMain.Handle, nil, 'http://localhost', nil, nil, SW_SHOW);
end;


/////////////////////////// FORM Objects ///////////////////////////

procedure TFormMain.TimerTimer(Sender: TObject);
begin
  RunThread();
  //CheckServers();
end; // procedure TFormMain.TimerTimer();

/////////////////////////// FORM Actions ///////////////////////////

procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveIni(TimerIntreval, Minimize, ip, TrayIcon, PortA, PortM, cfgA, cfgPHP, cfgM, FirstRun);
  IconOperation(2, Application.Icon);
end;

procedure TFormMain.FormCreate(Sender: TObject);
var Apache: boolean;
begin
  FormMain.Icon.Handle := LoadIcon(HInstance, 'Icon_Application');
  UpdateFromINI(false);                  //StepDown: Shortstring = #13#10
  if FirstRun then begin
    Apache := CheckSocket(ip, strtoint(FormMain.EditApache.Text));
    if Apache and ProcessRunning('Skype') then begin
      ShowMessage('Warning! Skype is running on port ' + FormMain.EditApache.Text +
        ', turn it off.' + #13#10 + 'Внимание! У Вас запущен Skype на ' +
        FormMain.EditApache.Text + ' порту, выключите его.');
//      Exit;
    end
    else if Apache then begin
      ShowMessage('Warning! Port ' + FormMain.EditApache.Text +
        ' is occupied by the system or another program, turn it off for the proper functioning of the server.' +
        #13#10 + 'Внимание! ' + FormMain.EditApache.Text +
        '-ый Порт занят системой или другой программой, выключите ее для правильного функционирования сервера.');
//      Exit;
    end;
    if CheckSocket(ip, strtoint(FormMain.EditMySQL.Text)) then begin
      ShowMessage('Warning! Port ' + FormMain.EditMySQL.Text +
        ' is occupied by the system or another program, turn it off for the proper functioning of the server.' +
        #13#10 + 'Внимание! ' + FormMain.EditMySQL.Text +
        '-ый Порт занят системой или другой программой, выключите ее для правильного функционирования сервера.');
     end;
    FirstRun := False;
    SaveIni(TimerIntreval, Minimize, ip, TrayIcon, PortA, PortM, cfgA, cfgPHP, cfgM, FirstRun);
  end;
  RunThread();//CheckServers();
  if Minimize then MinimizeForm;
  //if TrayIcon then UpdateTrayIcon;
end;

procedure TFormMain.FormShow(Sender: TObject);
begin
  //if FormMinimized then MinimizeForm;
end;

procedure TFormMain.MinimizeForm;
begin
  UpdateTrayIcon();    // Добавляем значок в трей
  ShowWindow(Handle, SW_HIDE);  // Скрываем программу
  FormMinimized := true;
  //WindowState := wsMinimized;
end;

procedure TFormMain.UpdateIconHint();
begin
  if TrayIcon then begin
    IconOperation(3, Application.Icon, 'Apache: '+ifthen(ApacheOn,'On','Off')+'; MySQL: '+ifthen(MySQLOn,'On','Off'));
  end;
end;

procedure TFormMain.UpdateTrayIcon();
var HandleIcon: Cardinal;
begin
  if TrayIcon then begin
    HandleIcon := LoadIcon(hInstance, PWideChar(TrayIconName()));
    if Application.Icon.Handle <> HandleIcon then begin
      Application.Icon.Handle := HandleIcon;
      FormMain.IconOperation(1, Application.Icon);
    end;
  end;
end;

procedure TFormMain.IconOperation(Operation:integer; Icon:TIcon; hint:string='');
Var NIM: TNotifyIconData; i:integer;
begin
  With NIM do
  Begin
    cbSize  := SizeOf(NIM);
    Wnd     := FormMain.Handle;
    uID     := 1;
    uFlags  := NIF_ICON or NIF_MESSAGE or NIF_TIP;
    hicon   := Icon.Handle;
    uCallbackMessage  :=  wm_user + 1;
    szTip := '';
    //for i := 0 to 127 do szTip[i]:=pwidechar('');
    for i := 1 to length(hint) do szTip[i-1]:=char(hint[i]);
    //szTip   := StrToArrays(hint);
  End;
  Case Operation OF
    1: Shell_NotifyIcon(Nim_Add,    @NIM);
    2: Shell_NotifyIcon(Nim_Delete, @NIM);
    3: Shell_NotifyIcon(Nim_Modify, @NIM);
  End;
end;

procedure TFormMain.ControlWindow(var Msg: TMessage);
begin
  if (Msg.WParam = SC_MINIMIZE) and Minimize then
    begin
      MinimizeForm;
    end
  else inherited;
end;

procedure TFormMain.IconMouse(var Msg: TMessage);
var p: tpoint;
begin
  GetCursorPos(p); // Запоминаем координаты курсора мыши
  case Msg.LParam of // Проверяем какая кнопка была нажата
   WM_LBUTTONUP, WM_LBUTTONDBLCLK: {Действия, выполняемый по одинарному или двойному щел?ку левой кнопки мыши на зна?ке. В нашем слу?ае это просто активация приложения}
     begin
       if FormMinimized then begin
        ShowWindow(Handle, SW_SHOWNORMAL); // Восстанавливаем окно программы
        FormMinimized := False;
        //WindowState := wsNormal;
       end
       else MinimizeForm;
       if not TrayIcon then IconOperation(2, Application.Icon); // Удаляем зна?ок из трея
     end;
   WM_RBUTTONUP: {Действия, выполняемый по одинарному щел?ку правой кнопки мыши}
     begin
       SetForegroundWindow(Handle); // Восстанавливаем программу в ка?естве переднего окна
       PopupMenu.Popup(p.X, p.Y); // Заставляем всплыть тот самый TPopUp о котором я говорил ?уть раньше
       PostMessage(Handle, WM_NULL, 0, 0) // Обнуляем сообщение
     end;
 end;
end;

/////////////////////////// FORM Menus ///////////////////////////

procedure TFormMain.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TFormMain.Exit2Click(Sender: TObject);
begin
  Close;
end;

procedure TFormMain.Minimize1Click(Sender: TObject);
begin
  Minimize := not Minimize;
  Minimize1.Checked := Minimize;
  Minimize2.Checked := Minimize;
  SaveIni(TimerIntreval, Minimize, ip, TrayIcon, PortA, PortM, cfgA, cfgPHP, cfgM, FirstRun);
end;

procedure TFormMain.Minimize2Click(Sender: TObject);
begin
  Minimize := not Minimize;
  Minimize1.Checked := Minimize;
  Minimize2.Checked := Minimize;
  SaveIni(TimerIntreval, Minimize, ip, TrayIcon, PortA, PortM, cfgA, cfgPHP, cfgM, FirstRun);
end;

procedure TFormMain.MysQL1Click(Sender: TObject);
begin
  MySQLCFG();
end;

procedure TFormMain.MySQL2Click(Sender: TObject);
begin
  MySQLCFG();
end;

procedure TFormMain.OpenSite1Click(Sender: TObject);
begin
  OpenLocalHost();
end;

procedure TFormMain.OpenSite2Click(Sender: TObject);
begin
  OpenLocalHost();
end;

procedure TFormMain.About2Click(Sender: TObject);
begin
  About();
end;

procedure TFormMain.About3Click(Sender: TObject);
begin
  About();
end;

procedure TFormMain.AboutandHelp1Click(Sender: TObject);
begin
  OpenDragons();
end;

procedure TFormMain.Apache1Click(Sender: TObject);
begin
  ApacheCFG();
end;

procedure TFormMain.Apache2Click(Sender: TObject);
begin
  ApacheCFG();
end;

procedure TFormMain.ButtonRestartClick(Sender: TObject);
begin
  Restart();
end;

procedure TFormMain.ButtonStartClick(Sender: TObject);
begin
  Run();
end;

procedure TFormMain.ButtonStopClick(Sender: TObject);
begin
  Stop();
end;

procedure TFormMain.ButtonSwitchOffClick(Sender: TObject);
begin
  SwitchOff();
end;

procedure TFormMain.About1Click(Sender: TObject);
begin
   OpenDragons();
end;

procedure TFormMain.PHP1Click(Sender: TObject);
begin
  PHPCFG();
end;

procedure TFormMain.PHP2Click(Sender: TObject);
begin
  PHPCFG();
end;

procedure TFormMain.Preferences1Click(Sender: TObject);
begin
  FormSettings.ShowModal;
  UpdateFromINI();
end;

procedure TFormMain.Restart1Click(Sender: TObject);
begin
  Restart();
end;

procedure TFormMain.Restart2Click(Sender: TObject);
begin
  Restart();
end;

procedure TFormMain.Server3Click(Sender: TObject);
begin
   OpenCFGFile('denwer\CONFIGURATION.txt');
end;

procedure TFormMain.Server4Click(Sender: TObject);
begin
  OpenCFGFile('denwer\CONFIGURATION.txt');
end;

procedure TFormMain.Settings1Click(Sender: TObject);
begin
  FormSettings.ShowModal;
  UpdateFromINI();
end;

procedure TFormMain.Start1Click(Sender: TObject);
begin
  Run();
end;

procedure TFormMain.Start2Click(Sender: TObject);
begin
  Run();
end;

procedure TFormMain.Stop1Click(Sender: TObject);
begin
  Stop();
end;

procedure TFormMain.Stop2Click(Sender: TObject);
begin
  Stop();
end;

procedure TFormMain.Switchof1Click(Sender: TObject);
begin
  SwitchOff();
end;

procedure TFormMain.SwitchOff1Click(Sender: TObject);
begin
  SwitchOff();
end;

end.
