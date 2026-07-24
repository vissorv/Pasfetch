program pasfetch;

{$mode objfpc}{$H+}

uses
  SysUtils, Process, Classes;

type
  TDistroInfo = record
    Name: string;
    Color: string;
    Ascii: array of string;
  end;

  TInfoPair = record
    Name, Val: string;
  end;

var
  DistroMap: array of TDistroInfo;
  TargetLogoOverride: string = '';

const
  CReset   = #27'[0m';
  CBold    = #27'[1m';
  CRed     = #27'[38;5;131m';
  CGreen   = #27'[38;5;108m';
  CYellow  = #27'[38;5;136m';
  CBlue    = #27'[38;5;67m';
  CMagenta = #27'[38;5;96m';
  CCyan    = #27'[38;5;73m';
  CWhite   = #27'[38;5;252m';
  COlive   = #27'[38;5;100m';

function EscMoveUp(Lines: Integer): string;
begin
  if Lines <= 0 then Exit('');
  Result := #27 + '[' + IntToStr(Lines) + 'A';
end;

function EscMoveRight(Cols: Integer): string;
begin
  if Cols <= 0 then Exit('');
  Result := #27 + '[' + IntToStr(Cols) + 'C';
end;

function EscMoveLeft(Cols: Integer): string;
begin
  if Cols <= 0 then Exit('');
  Result := #27 + '[' + IntToStr(Cols) + 'D';
end;

function RunCmd(const Cmd: string): string;
var
  Output: string;
begin
  if RunCommand('/bin/sh', ['-c', Cmd], Output) then
    Result := Trim(Output)
  else
    Result := '';
end;

function OnlyDigits(const S: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(S) do
    if S[i] in ['0'..'9'] then
      Result := Result + S[i];
end;

procedure AddDistro(const AName, AColor: string; const AAscii: array of string);
var
  Idx, i: Integer;
begin
  Idx := Length(DistroMap);
  SetLength(DistroMap, Idx + 1);
  DistroMap[Idx].Name := AName;
  DistroMap[Idx].Color := AColor;
  SetLength(DistroMap[Idx].Ascii, Length(AAscii));
  for i := 0 to High(AAscii) do
    DistroMap[Idx].Ascii[i] := AAscii[i];
end;

procedure InitDistros;
begin
  AddDistro('arch', CCyan, [
    '       /\',
    '      /  \',
    '     /\   \',
    '    /      \',
    '   /   ,,   \',
    '  /   |  |  -\',
    ' /_-''    ''-_\'
  ]);

  AddDistro('debian', CRed, [
    '  _____',
    ' /  __ \',
    '|  /    |',
    '|  \___-',
    '-_',
    '  --_'
  ]);

  AddDistro('devuan', CMagenta, [
    ' ..:::.      ',
    '    ..-==-   ',
    '        .+#: ',
    '         =@@ ',
    '      :+%@#: ',
    '.:=+#@@%*:   ',
    '#@@@#=:      '
  ]);

  AddDistro('openbsd', CYellow, [
    '      _____',
    '    \-     -/',
    ' \_/         \',
    ' |        O O |',
    ' |_  <   )  3 )',
    ' / \         /',
    '   /-____-\'
  ]);

  AddDistro('netbsd', CYellow, [
    '\\`-______,----__',
    ' \\        __,---`_',
    '  \\       `.____',
    '   \\-______,----`-',
    '    \\',
    '     \\',
    '      \\'
  ]);

  AddDistro('freebsd', CRed, [
    '/\,-''''''-,/\',
    '\_)       (_/',
    '|           |',
    '|           |',
    ' ;         ;',
    '  ''-_____-'''
  ]);

  AddDistro('opensuse', CGreen, [
    '  _______',
    '__|   __ \',
    '     / .\ \',
    '     \__/ |',
    '   _______|',
    '   \_______',
    '__________/'
  ]);

  AddDistro('void', COlive, [
    '    _______',
    ' _ \______ -',
    '| \  ___  \ |',
    '| | /   \ | |',
    '| | \___/ | |',
    '| \______ \_|',
    ' -_______\'
  ]);

  AddDistro('gentoo', CMagenta, [
    ' _-----_',
    '(       \',
    '\    0   \',
    ' \        )',
    ' /      _/',
    '(     _-',
    '\____-'
  ]);

  AddDistro('slackware', CBlue, [
    '   ________',
    '  /  ______|',
    '  | |______',
    '  \______  \',
    '   ______| |',
    '| |________/',
    '|____________'
  ]);

  AddDistro('guix', CYellow, [
    '|.__          __|.|',
    '|__ \        / __|',
    '   \ \      / /',
    '    \ \    / /',
    '     \ \  / /',
    '      \ \/ /',
    '       \__/'
  ]);

  AddDistro('nixos', CCyan, [
    '  \\  \\ //',
    ' ==\\__\\/ //',
    '   //   \\//',
    '==//     //==',
    ' //\\___//',
    '// /\\  \\==',
    '  // \\\\  \\'
  ]);

  AddDistro('kiss', CMagenta, [
    '    ---',
    '   (.· |',
    '   (<> |',
    '  / --  \',
    ' ( /  \ /|',
    ' _/\ __)/_)',
    ' \/-____\/'
  ]);

  AddDistro('mint', CGreen, [
    ' ___________',
    '|_          \',
    '  | | _____ |',
    '  | | | | | |',
    '  | | | | | |',
    '  | | \_____/ |',
    '  \_________/'
  ]);

  AddDistro('fedora', CBlue, [
    '      _____',
    '     /   __)\',
    '     |  /  \ \',
    '  ___|  |__/ /',
    ' / (_    _)_/',
    ' \___)'
  ]);

  AddDistro('alpine', CBlue, [
    '   /\ /\\',
    '  // \  \\',
    ' //   \  \\',
    '///    \  \\',
    '//      \  \\',
    '         \\'
  ]);

  AddDistro('linux', CWhite, [
    '    .--.',
    '   |o_o |',
    '   |:_/ |',
    '  //   \ \',
    ' (|     | )',
    '/''\_   _/`\',
    '\___)=(___/'
  ]);
end;

function DetectDistroKey: string;
var
  OSRelease: TStringList;
  i: Integer;
  Line, RawName: string;
begin
  if TargetLogoOverride <> '' then
    Exit(LowerCase(TargetLogoOverride));

  RawName := '';
  if FileExists('/etc/os-release') then
  begin
    OSRelease := TStringList.Create;
    try
      OSRelease.LoadFromFile('/etc/os-release');
      for i := 0 to OSRelease.Count - 1 do
      begin
        Line := OSRelease[i];
        if Copy(Line, 1, 3) = 'ID=' then
        begin
          RawName := Copy(Line, 4, Length(Line));
          RawName := StringReplace(RawName, '"', '', [rfReplaceAll]);
          Break;
        end;
      end;
    finally
      OSRelease.Free;
    end;
  end;

  if RawName = '' then
    RawName := RunCmd('uname -s');

  Result := LowerCase(RawName);
end;

function GetOS: string;
begin
  Result := RunCmd('. /etc/os-release 2>/dev/null && echo $PRETTY_NAME');
  if Result = '' then
    Result := RunCmd('uname -sr');
end;

function GetHost: string;
begin
  Result := RunCmd('cat /sys/devices/virtual/dmi/id/product_name 2>/dev/null');
  if Result = '' then
    Result := RunCmd('uname -m');
end;

function GetKernel: string;
begin
  Result := RunCmd('uname -r');
end;

function GetUptime: string;
var
  UptimeSec, Days, Hours, Mins: Integer;
  Raw: string;
begin
  Raw := RunCmd('cut -d. -f1 /proc/uptime 2>/dev/null');
  if Raw <> '' then
  begin
    UptimeSec := StrToIntDef(Raw, 0);
    Days := UptimeSec div 86400;
    Hours := (UptimeSec mod 86400) div 3600;
    Mins := (UptimeSec mod 3600) div 60;

    Result := '';
    if Days > 0 then Result := Result + IntToStr(Days) + 'd ';
    if Hours > 0 then Result := Result + IntToStr(Hours) + 'h ';
    Result := Result + IntToStr(Mins) + 'm';
  end
  else
    Result := 'desconhecido';
end;

function GetPkgs: string;
begin
  Result := RunCmd(
    'if command -v xbps-query >/dev/null; then xbps-query -l | wc -l; ' +
    'elif command -v pacman >/dev/null; then pacman -Qq | wc -l; ' +
    'elif command -v dpkg >/dev/null; then dpkg-query -f ".\n" -W | wc -l; ' +
    'elif command -v rpm >/dev/null; then rpm -qa | wc -l; ' +
    'elif command -v apk >/dev/null; then apk info | wc -l; ' +
    'elif command -v guix >/dev/null; then guix package --list-installed | wc -l; ' +
    'elif command -v nix-store >/dev/null; then nix-store -q --requisites /run/current-system/sw | wc -l; ' +
    'else echo 0; fi'
  );
  Result := Trim(Result);
  if Result = '0' then Result := '';
end;

function GetMemory: string;
var
  MemInfo: TStringList;
  i, Total, Avail, Used: Integer;
  Line: string;
begin
  Total := 0; Avail := 0;
  if FileExists('/proc/meminfo') then
  begin
    MemInfo := TStringList.Create;
    try
      MemInfo.LoadFromFile('/proc/meminfo');
      for i := 0 to MemInfo.Count - 1 do
      begin
        Line := MemInfo[i];
        if Copy(Line, 1, 9) = 'MemTotal:' then
          Total := StrToIntDef(OnlyDigits(Line), 0) div 1024;
        if Copy(Line, 1, 13) = 'MemAvailable:' then
          Avail := StrToIntDef(OnlyDigits(Line), 0) div 1024;
      end;
    finally
      MemInfo.Free;
    end;
  end;

  if (Total > 0) and (Avail > 0) then
  begin
    Used := Total - Avail;
    Result := IntToStr(Used) + 'M / ' + IntToStr(Total) + 'M';
  end
  else
    Result := 'N/A';
end;

procedure RenderFetch;
const
  InfoNames: array[0..5] of string = ('os', 'host', 'kernel', 'uptime', 'pkgs', 'memory');
var
  Key: string;
  SelectedDistro: TDistroInfo;
  i, AsciiWidth, AsciiHeight, InfoHeight, PadGap, MaxNameLen: Integer;
  UserHost, ThemeColor: string;
  InfoValues: array[0..5] of string;
  ValidInfos: array of TInfoPair;

  procedure PrintInfoLine(const AName, AVal: string);
  begin
    Write(EscMoveRight(AsciiWidth + PadGap));
    Write(ThemeColor + CBold + AName + CReset);
    Write(EscMoveLeft(Length(AName)));
    Write(EscMoveRight(MaxNameLen + 1));
    Writeln(CWhite + AVal + CReset);
    Inc(InfoHeight);
  end;

begin
  Key := DetectDistroKey;

  SelectedDistro := DistroMap[High(DistroMap)];
  for i := 0 to High(DistroMap) do
  begin
    if Pos(DistroMap[i].Name, Key) > 0 then
    begin
      SelectedDistro := DistroMap[i];
      Break;
    end;
  end;

  ThemeColor := SelectedDistro.Color;
  AsciiHeight := Length(SelectedDistro.Ascii);
  AsciiWidth := 0;
  for i := 0 to AsciiHeight - 1 do
    if Length(SelectedDistro.Ascii[i]) > AsciiWidth then
      AsciiWidth := Length(SelectedDistro.Ascii[i]);

  PadGap := 4;

  for i := 0 to AsciiHeight - 1 do
    Writeln(ThemeColor + CBold + SelectedDistro.Ascii[i] + CReset);

  Write(EscMoveUp(AsciiHeight));

  InfoValues[0] := GetOS;
  InfoValues[1] := GetHost;
  InfoValues[2] := GetKernel;
  InfoValues[3] := GetUptime;
  InfoValues[4] := GetPkgs;
  InfoValues[5] := GetMemory;

  MaxNameLen := 0;
  SetLength(ValidInfos, 0);
  for i := 0 to 5 do
  begin
    if InfoValues[i] <> '' then
    begin
      SetLength(ValidInfos, Length(ValidInfos) + 1);
      ValidInfos[High(ValidInfos)].Name := InfoNames[i];
      ValidInfos[High(ValidInfos)].Val := InfoValues[i];
      if Length(InfoNames[i]) > MaxNameLen then
        MaxNameLen := Length(InfoNames[i]);
    end;
  end;

  InfoHeight := 0;

  UserHost := GetEnvironmentVariable('USER') + '@' + RunCmd('hostname');
  Write(EscMoveRight(AsciiWidth + PadGap));
  Writeln(ThemeColor + CBold + UserHost + CReset);
  Inc(InfoHeight);

  for i := 0 to High(ValidInfos) do
    PrintInfoLine(ValidInfos[i].Name, ValidInfos[i].Val);

  if AsciiHeight > InfoHeight then
    for i := 1 to (AsciiHeight - InfoHeight) do Writeln
  else
    Writeln;
end;

var
  i: Integer;
begin
  InitDistros;

  if ParamCount > 0 then
    for i := 1 to ParamCount do
      if (ParamStr(i) = '-logo') and (i < ParamCount) then
      begin
        TargetLogoOverride := ParamStr(i + 1);
        Break;
      end;

  RenderFetch;
end.
