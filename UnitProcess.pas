unit UnitProcess;

interface

  function ProcessRunning(ProcessName:String):boolean; stdcall;

implementation

uses
Psapi, tlhelp32, Types, Classes, Windows, SysUtils;

procedure CreateWin9xProcessList(List: TstringList);
var
hSnapShot: THandle;
ProcInfo: TProcessEntry32;
begin
if List = nil then Exit;
hSnapShot := CreateToolHelp32Snapshot(TH32CS_SNAPPROCESS, 0);
if (hSnapShot <> THandle(-1)) then
begin
   ProcInfo.dwSize := SizeOf(ProcInfo);
   if (Process32First(hSnapshot, ProcInfo)) then
   begin
     List.Add(ProcInfo.szExeFile);
     while (Process32Next(hSnapShot, ProcInfo)) do
       List.Add(ProcInfo.szExeFile);
   end;
   CloseHandle(hSnapShot);
end;
end;



procedure CreateWinNTProcessList(List: TstringList);
var
PIDArray: array [0..1023] of DWORD;
cb: DWORD;
I: Integer;
ProcCount: Integer;
hMod: HMODULE;
hProcess: THandle;
ModuleName: array [0..300] of Char;
begin
if List = nil then Exit;
EnumProcesses(@PIDArray, SizeOf(PIDArray), cb);
ProcCount := cb div SizeOf(DWORD);
for I := 0 to ProcCount - 1 do
begin
   hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or
     PROCESS_VM_READ,
     False,
     PIDArray[I]);
   if (hProcess <> 0) then
   begin
     EnumProcessModules(hProcess, @hMod, SizeOf(hMod), cb);
     GetModuleFilenameEx(hProcess, hMod, ModuleName, SizeOf(ModuleName));
     List.Add(ModuleName);
     CloseHandle(hProcess);
   end;
end;
end;

procedure GetProcessList(var List: TstringList);
var
ovi: TOSVersionInfo;
begin
if List = nil then Exit;
ovi.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
GetVersionEx(ovi);
case ovi.dwPlatformId of
   VER_PLATFORM_WIN32_WINDOWS: CreateWin9xProcessList(List);
   VER_PLATFORM_WIN32_NT: CreateWinNTProcessList(List);
end
end;

function EXE_Running(FileName: string; bFullpath: Boolean): Boolean;
var
i: Integer;
MyProcList: TstringList;
begin
MyProcList := TStringList.Create;
try
   GetProcessList(MyProcList);
   Result := False;
   if MyProcList = nil then Exit;
   for i := 0 to MyProcList.Count - 1 do
   begin
     if not bFullpath then
     begin
       if CompareText(ExtractFileName(MyProcList.Strings[i]), FileName) = 0 then
         Result := True
     end
     else if CompareText(MyProcList.strings[i], FileName) = 0 then Result := True;
     if Result then Break;
   end;
finally
   MyProcList.Free;
end;

end;

function ProcessRunning(ProcessName:String):boolean;
begin
  if EXE_Running(ProcessName+'.exe', False) then Result:= True
  else Result := False;
end;



end.
