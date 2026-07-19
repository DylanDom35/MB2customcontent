; ============================================================
;  Acrowe's Cave — Movie Battles II Content Installer
;  Inno Setup 6 Script
; ============================================================

#define MyAppName    "Acrowe's Cave — MBII Custom Content"
#define MyAppVersion "1.2"
#define MyAppPublisher "Acrowe"
#define MyAppURL     "https://acrowescave.com"
#define MyExeName    "AcroweCave_Setup.exe"

[Setup]
AppId={{F2A1B3C4-D5E6-7890-ABCD-EF1234567890}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={code:GetMBIIDir}
DisableDirPage=no
DirExistsWarning=no
AppendDefaultDirName=no
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputBaseFilename=AcroweCave_Setup
SetupIconFile=
Compression=lzma/fast
SolidCompression=no
WizardStyle=modern
DisableWelcomePage=no
Uninstallable=no
CreateUninstallRegKey=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[CustomMessages]
english.WelcomeLabel1=Welcome to Acrowe's Cave Installer
english.WelcomeLabel2=This wizard will install Acrowe's Cave custom content for Movie Battles II v1.2.%n%n  NEW SIEGE EXPANSION MAPS:%n  - naboo_sanctuary (Naboo Crystal Sanctuary)%n  - mos_kreetle (Tatooine Mos Kreetle)%n  - taris_hangar (Taris Hangar T-31)%n%n  CUSTOM MAPS & ASSETS:%n  - mb2_korribanacademy%n  - mb2_peragus%n  - mb2_daviks_estate%n  - mb2_sulon%n  - KOTOR / KOTOR 2 Map & Asset Packs%n  - CTF Map Pack%n%n  LEGENDS BALANCE PACK & BOTS:%n  - z_MBLegends.pk3  (Luke Skywalker & Darth Nihilus updates)%n  - zzzz_acrow_ultimate.pk3%n  - zzzzz_acrow_bots.pk3%n%nClick Next to continue.
english.SelectDirLabel3=The installer needs to place files in your MBII folder.%n%nSteam users: ...\steamapps\common\Jedi Academy\GameData\MBII%nGOG users: C:\GOG Games\Star Wars Jedi Knight - Jedi Academy\GameData\MBII%n%nIf the path below is wrong, click Browse and navigate to your MBII folder.
english.SelectDirBrowseLabel=To continue, click Next. If you would like to select a different MBII folder, click Browse.

[Files]
; Core Map & Siege Expansion Packs
Source: "MBII\acrow_pack_siege_expansion.pk3";   DestDir: "{app}"; Flags: ignoreversion
Source: "MBII\zzz_kotor2_assets.pk3";            DestDir: "{app}"; Flags: ignoreversion
Source: "MBII\zzzz_acrow_ultimate.pk3";          DestDir: "{app}"; Flags: ignoreversion
Source: "MBII\acrow_ctf_maps.pk3";               DestDir: "{app}"; Flags: ignoreversion
; Individual Maps
Source: "MBII\acrow_maps.pk3";                   DestDir: "{app}"; Flags: ignoreversion
Source: "MBII\mb2_boonta_eve.pk3";               DestDir: "{app}"; Flags: ignoreversion
Source: "MBII\mb2_corellia_platform.pk3";        DestDir: "{app}"; Flags: ignoreversion
Source: "MBII\mb2_ilumcaverns.pk3";              DestDir: "{app}"; Flags: ignoreversion
Source: "MBII\mb2_korribanacademy.pk3";          DestDir: "{app}"; Flags: ignoreversion
Source: "MBII\mb2_peragus.pk3";                  DestDir: "{app}"; Flags: ignoreversion
Source: "MBII\mb2_sulon.pk3";                   DestDir: "{app}"; Flags: ignoreversion
Source: "MBII\zzz_mb2_daviks_estate.pk3";        DestDir: "{app}"; Flags: ignoreversion
; Sky, Legends & Bots
Source: "MBII\z_MBLegends.pk3";                   DestDir: "{app}"; Flags: ignoreversion
Source: "MBII\zzzz_acrow_bots.pk3";              DestDir: "{app}"; Flags: ignoreversion
Source: "MBII\zzzzz_acrow_bots.pk3";             DestDir: "{app}"; Flags: ignoreversion

[Code]

function GetSteamMBIIDir(): String;
var
  SteamPath: String;
  Candidate: String;
begin
  Result := '';
  if RegQueryStringValue(HKLM, 'SOFTWARE\WOW6432Node\Valve\Steam', 'InstallPath', SteamPath) or
     RegQueryStringValue(HKCU, 'SOFTWARE\Valve\Steam', 'SteamPath', SteamPath) then
  begin
    Candidate := SteamPath + '\steamapps\common\Jedi Academy\GameData\MBII';
    if DirExists(Candidate) then
      Result := Candidate;
    if Result = '' then begin
      Candidate := SteamPath + '\steam\steamapps\common\Jedi Academy\GameData\MBII';
      if DirExists(Candidate) then
        Result := Candidate;
    end;
  end;
end;

function GetGOGMBIIDir(): String;
var
  Candidate: String;
begin
  Result := '';
  Candidate := 'C:\GOG Games\Star Wars Jedi Knight - Jedi Academy\GameData\MBII';
  if DirExists(Candidate) then begin Result := Candidate; Exit; end;
  Candidate := 'D:\GOG Games\Star Wars Jedi Knight - Jedi Academy\GameData\MBII';
  if DirExists(Candidate) then begin Result := Candidate; Exit; end;
  Candidate := ExpandConstant('{pf}') + '\GOG Galaxy\Games\Star Wars Jedi Knight - Jedi Academy\GameData\MBII';
  if DirExists(Candidate) then  Result := Candidate;
end;

function GetMBIIDir(Param: String): String;
var
  Found: String;
begin
  Found := GetSteamMBIIDir();
  if Found <> '' then begin Result := Found; Exit; end;

  Found := GetGOGMBIIDir();
  if Found <> '' then begin Result := Found; Exit; end;

  Result := 'C:\Program Files (x86)\Steam\steamapps\common\Jedi Academy\GameData\MBII';
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  SelDir: String;
  Msg: String;
begin
  Result := True;
  if CurPageID = wpSelectDir then
  begin
    SelDir := WizardDirValue();
    if CompareText(ExtractFileName(SelDir), 'MBII') <> 0 then
    begin
      Msg := 'The selected folder does not appear to be an MBII directory.' + #13#10 +
             'The folder name should be "MBII" (e.g. ...\GameData\MBII).' + #13#10#13#10 +
             'Are you sure you want to install here?';
      if MsgBox(Msg, mbConfirmation, MB_YESNO) = IDNO then
        Result := False;
    end;
  end;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = wpSelectDir then
  begin
    WizardForm.DirEdit.Hint :=
      'Steam: ...\steamapps\common\Jedi Academy\GameData\MBII' + #13#10 +
      'GOG:   C:\GOG Games\Star Wars Jedi Knight - Jedi Academy\GameData\MBII';
  end;
end;
