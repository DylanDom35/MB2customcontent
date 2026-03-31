; ============================================================
;  Acrowe's Cave — Movie Battles II Content Installer
;  Inno Setup 6 Script
; ============================================================

#define MyAppName    "Acrowe's Cave — MBII Custom Content"
#define MyAppVersion "1.0"
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
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
WizardResizable=no
DisableWelcomePage=no
LicenseFile=
UninstallDisplayIcon=
; No uninstall needed - we're just placing PK3 files
Uninstallable=no
CreateUninstallRegKey=no
;; Visual
WizardImageFile=
WizardSmallImageFile=
; Banner color approximation via compiler directives only — style set in Pascal
BackColor=$0F141E
BackColor2=$1B263B
BackColorDirection=toptobottom

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[CustomMessages]
english.WelcomeLabel1=Welcome to Acrowe's Cave Installer
english.WelcomeLabel2=This wizard will install the KOTOR/KOTOR 2 custom map pack for Movie Battles II.%n%nThese maps bring expanded KOTOR environments into MBII with high player-count Siege support:%n%n  - mb2_korribanacademy%n  - mb2_peragus%n  - mb2_daviks_estate%n  - KOTOR 2 Asset Packs%n%nClick Next to continue.
english.SelectDirLabel3=The installer needs to place files in your MBII folder.%n%nSteam users: ...%steamapps%\common\Jedi Academy\GameData\MBII%nGOG users: C:\GOG Games\Star Wars Jedi Knight - Jedi Academy\GameData\MBII%n%nIf the path below is wrong, click Browse and navigate to your MBII folder.
english.SelectDirBrowseLabel=To continue, click Next. If you would like to select a different MBII folder, click Browse.

[Files]
; KOTOR 2 Asset Packs
Source: "MBII\zzz_kotor2_assets_part1.pk3"; DestDir: "{app}"; Flags: ignoreversion
Source: "MBII\zzz_kotor2_assets_part2.pk3"; DestDir: "{app}"; Flags: ignoreversion
Source: "MBII\zzz_kotor2_assets_part3.pk3"; DestDir: "{app}"; Flags: ignoreversion
Source: "MBII\zzz_kotor2_assets_part4.pk3"; DestDir: "{app}"; Flags: ignoreversion
Source: "MBII\zzz_kotor2_assets_part5.pk3"; DestDir: "{app}"; Flags: ignoreversion
Source: "MBII\zzz_kotor2_bsps.pk3";         DestDir: "{app}"; Flags: ignoreversion
Source: "MBII\zzz_kotor2_custom.pk3";        DestDir: "{app}"; Flags: ignoreversion
Source: "MBII\zzz_kotor2_entities.pk3";      DestDir: "{app}"; Flags: ignoreversion
Source: "MBII\zzz_kotor_siege_fix.pk3";      DestDir: "{app}"; Flags: ignoreversion
; Maps
Source: "MBII\mb2_korribanacademy.pk3";      DestDir: "{app}"; Flags: ignoreversion
Source: "MBII\mb2_peragus.pk3";              DestDir: "{app}"; Flags: ignoreversion
Source: "MBII\zzz_mb2_daviks_estate.pk3";    DestDir: "{app}"; Flags: ignoreversion
; Sky + Legend packs
Source: "MBII\TELOSSKY.pk3";                DestDir: "{app}"; Flags: ignoreversion
Source: "MBII\z_MBLegends.pk3";             DestDir: "{app}"; Flags: ignoreversion

[Code]
// -------------------------------------------------------
// Auto-detect the MBII installation directory
// Priority: Steam > GOG > Manual
// -------------------------------------------------------

function GetSteamMBIIDir(): String;
var
  SteamPath: String;
  Candidate: String;
begin
  Result := '';
  // Try registry for Steam install path
  if RegQueryStringValue(HKLM, 'SOFTWARE\WOW6432Node\Valve\Steam', 'InstallPath', SteamPath) or
     RegQueryStringValue(HKCU, 'SOFTWARE\Valve\Steam', 'SteamPath', SteamPath) then
  begin
    Candidate := SteamPath + '\steamapps\common\Jedi Academy\GameData\MBII';
    if DirExists(Candidate) then
      Result := Candidate;
    // Try common secondary library
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
  // Common GOG install locations
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

  // Fallback default
  Result := 'C:\Program Files (x86)\Steam\steamapps\common\Jedi Academy\GameData\MBII';
end;

// -------------------------------------------------------
// Validate the selected directory actually looks like MBII
// -------------------------------------------------------
function NextButtonClick(CurPageID: Integer): Boolean;
var
  SelDir: String;
  Msg: String;
begin
  Result := True;
  if CurPageID = wpSelectDir then
  begin
    SelDir := WizardDirValue();
    // Warn if the path doesn't end with \MBII (case-insensitive)
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
