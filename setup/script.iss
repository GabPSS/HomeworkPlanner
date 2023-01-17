; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "HomeworkPlanner"
#define MyAppVersion "1.0.0-alpha.2"
#define MyAppPublisher "Gabriel P."
#define MyAppURL "https://github.com/GabPSS/HomeworkPlanner"
#define MyAppExeName "HomeworkPlanner.exe"
#define MyAppAssocName MyAppName + " Plan"
#define MyAppAssocExt ".hwpf"
#define MyAppAssocKey StringChange(MyAppAssocName, " ", "") + MyAppAssocExt

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{E8C55B92-816F-425A-ACEA-8CCD1D1031A0}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
ChangesAssociations=yes
DisableProgramGroupPage=yes
;LicenseFile=LICENSE.rtf
;InfoBeforeFile=README.md
; Uncomment the following line to run in non administrative install mode (install for current user only.)
;PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
OutputDir=bin
OutputBaseFilename=HomeworkPlanner
SetupIconFile=installicon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=classic
DisableWelcomePage=no
WizardImageFile=banner.bmp
WizardSmallImageFile=smallicon.bmp

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\HomeworkPlanner\bin\Release\net6.0-windows\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\HomeworkPlanner\bin\Release\net6.0-windows\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Registry]
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocExt}\"; ValueType: string; ValueData: "HomeworkPlannerPlan.hwpf"; Flags: uninsdeletevalue
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocExt}\ShellNew"; ValueType: binary; ValueName: "Data"; ValueData: "7b 22 54 61 73 6b 73 22 3a 7b 22 4c 61 73 74 49 6e 64 65 78 22 3a 2d 31 2c 22 49 74 65 6d 73 22 3a 5b 5d 7d 2c 22 53 75 62 6a 65 63 74 73 22 3a 7b 22 4c 61 73 74 49 6e 64 65 78 22 3a 2d 31 2c 22 49 74 65 6d 73 22 3a 5b 5d 7d 2c 22 43 61 6e 63 65 6c 6c 65 64 44 61 79 73 22 3a 5b 5d 2c 22 53 65 74 74 69 6e 67 73 22 3a 7b 22 46 75 74 75 72 65 57 65 65 6b 73 22 3a 32 2c 22 44 61 79 73 54 6f 44 69 73 70 6c 61 79 22 3a 36 32 2c 22 44 69 73 70 6c 61 79 50 72 65 76 69 6f 75 73 54 61 73 6b 73 22 3a 66 61 6c 73 65 7d 7d"; Flags: uninsdeletevalue
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocExt}\OpenWithProgids"; ValueType: string; ValueName: "{#MyAppAssocKey}"; ValueData: ""; Flags: uninsdeletevalue
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}"; ValueType: string; ValueName: ""; ValueData: "{#MyAppAssocName}"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\{#MyAppExeName},0"
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}"" ""%1"""
Root: HKA; Subkey: "Software\Classes\Applications\{#MyAppExeName}\SupportedTypes"; ValueType: string; ValueName: "{#MyAppAssocExt}"; ValueData: ""

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

