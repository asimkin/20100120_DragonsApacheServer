unit UnitFormSettings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, UnitINI;

type
  TFormSettings = class(TForm)
    Edit1: TEdit;
    CheckBox1: TCheckBox;
    Label1: TLabel;
    Edit2: TEdit;
    Label2: TLabel;
    CheckBox2: TCheckBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormSettings      : TFormSettings;
  Minimize          : boolean;
  TimerIntreval     : Integer;
  ip                : ansistring;
  TrayIcon          : boolean;
  PortA, PortM      : Integer;
  cfgA, cfgPHP, cfgM : string;
  FirstRun          : boolean;

implementation

{$R *.dfm}

procedure UpdateForm();
begin
  with FormSettings do begin
    CheckBox1.Checked := Minimize;
    Edit1.Text := IntToStr(TimerIntreval);
    Edit2.Text := string(ip);
    CheckBox2.Checked := TrayIcon;
  end;
end; // UpdateForm();

procedure UpdateData();
begin
  with FormSettings do begin
    Minimize      := CheckBox1.Checked;
    TimerIntreval := StrToInt(Edit1.Text);
    ip            := ansistring(Edit2.Text);
    TrayIcon      := CheckBox2.Checked;
  end;
end;

procedure TFormSettings.CheckBox1Click(Sender: TObject);
begin
  if CheckBox1.Checked then begin
      CheckBox2.Checked := True;
      CheckBox2.Enabled := False;
    end
  else CheckBox2.Enabled := True;
  UpdateData();
end;

procedure TFormSettings.CheckBox2Click(Sender: TObject);
begin
  if not CheckBox2.Checked and CheckBox1.Checked then CheckBox2.Checked := True;
  UpdateData();
end;

procedure TFormSettings.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  UpdateData();
  SaveIni(TimerIntreval, Minimize, ip, TrayIcon, PortA, PortM, cfgA, cfgPHP, cfgM, FirstRun);
end;

procedure TFormSettings.FormCreate(Sender: TObject);
begin
  FormSettings.Icon.Handle := LoadIcon(HInstance, 'Icon_Application');
end;

procedure TFormSettings.FormShow(Sender: TObject);
begin
  ReadIni(TimerIntreval, Minimize, ip, TrayIcon, PortA, PortM, cfgA, cfgPHP, cfgM, FirstRun);
  UpdateForm();
end;

end.
