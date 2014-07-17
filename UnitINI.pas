unit UnitINI;

interface

uses IniFiles;

  procedure ReadIni(var TimerIntreval:integer; var Minimize: boolean;
                    var ip: ansistring; var TrayIcon: boolean;
                    var PortA, PortM: integer;
                    var cfgA, cfgPHP, cfgM: string; var FirstRun: boolean); stdcall;
  procedure SaveIni(var TimerIntreval:integer; var Minimize: boolean;
                    var ip: ansistring; var TrayIcon: boolean;
                    var PortA, PortM: integer;
                    var cfgA, cfgPHP, cfgM: string; var FirstRun: boolean); stdcall;

var
  IniFile: TIniFile;

implementation

procedure ReadIni(var TimerIntreval:integer; var Minimize: boolean; var ip: ansistring;
                  var TrayIcon: boolean; var PortA, PortM: integer; var cfgA, cfgPHP, cfgM: string;
                  var FirstRun: boolean);
var
  IniPath : string;
  FileName: string;
begin
  GetDir(0,IniPath);
  FileName      := IniPath + '\server_monitor.ini';
  IniFile       := TIniFile.Create(FileName);
  TimerIntreval := IniFile.ReadInteger('Settings','TimerIntreval',TimerIntreval);
  Minimize      := IniFile.ReadBool('Settings','Minimize',Minimize);
  TrayIcon      := IniFile.ReadBool('Settings','TrayIcon',TrayIcon);
  ip            := ansistring(IniFile.ReadString('Network','ip',string(ip)));
  PortA         := IniFile.ReadInteger('Network','ApachePort',PortA);
  PortM         := IniFile.ReadInteger('Network','MySQLPort',PortM);
  cfgA          := IniFile.ReadString('Settings','ApacheDir',cfgA);
  cfgPHP        := IniFile.ReadString('Settings','PHPDir',cfgPHP);
  cfgM          := IniFile.ReadString('Settings','MySQLDir',cfgM);
  FirstRun      := IniFile.ReadBool('Advanced','FirstRun',FirstRun);
  IniFile.Free;
end;

procedure SaveIni(var TimerIntreval:integer; var Minimize: boolean; var ip: ansistring;
                  var TrayIcon: boolean; var PortA, PortM: integer; var cfgA, cfgPHP, cfgM: string;
                  var FirstRun: boolean);
var
  IniPath : string;
  FileName: string;
begin
  GetDir(0,IniPath);
  FileName    := IniPath + '\server_monitor.ini';
  IniFile     := TIniFile.Create(FileName);
  IniFile.WriteInteger('Settings','TimerIntreval',TimerIntreval);
  IniFile.WriteBool('Settings','Minimize',Minimize);
  IniFile.WriteBool('Settings','TrayIcon',TrayIcon);
  IniFile.WriteString('Network','ip',string(ip));
  IniFile.WriteInteger('Network','ApachePort',PortA);
  IniFile.WriteInteger('Network','MySQLPort',PortM);
  IniFile.WriteString('Settings','ApacheDir',cfgA);
  IniFile.WriteString('Settings','PHPDir',cfgPHP);
  IniFile.WriteString('Settings','MySQLDir',cfgM);
  IniFile.WriteBool('Advanced','FirstRun',FirstRun);
  IniFile.Free;
end;

end.
