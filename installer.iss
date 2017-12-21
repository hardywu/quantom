; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!
#include <idp.iss>
#define MyAppName "Quantom For Quantaxis"
#define MyAppVersion GetFileVersion("D:\Workspace\quantom\Quantom\bin\Release\Quantom.exe")
#define MyAppPublisher "Quantom"
#define MyAppURL "https://github.com/hardywu/quantom"
#define MyAppExeName "Quantom.exe"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{DD18FF3C-8D6C-4DCB-91F8-607CE6E126FD}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\{#MyAppName}
DisableProgramGroupPage=yes
OutputDir=D:\Workspace\quantom\dist
;OutputBaseFilename=quantom_for_quantaxis_v{#MyAppVersion}
Compression=lzma
SolidCompression=yes
VersionInfoVersion={#MyAppVersion}
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"
;Name: "install quantaxis python pkg"; Description: "install requests"; StatusMsg: "Installing requests..."; BeforeInstall: MyAfterInstall
 
[Files] 
Source: "D:\Workspace\quantom\Quantom\bin\Release\Quantom.exe"; DestDir: "{app}"; Flags: ignoreversion; 
Source: "D:\Workspace\quantom\Quantom\bin\Release\Quantom.exe.config"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\Workspace\quantom\Quantom\bin\Release\Hardcodet.Wpf.TaskbarNotification.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\Workspace\quantom\Quantom\bin\Release\Newtonsoft.Json.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\Workspace\quantom\Quantom\frontend\*"; DestDir: "{app}\frontend"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{commonprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Code]
// References:
//   https://blogs.msdn.microsoft.com/davidrickard/2015/07/17/installing-net-framework-4-5-automatically-with-inno-setup/
//   https://stackoverflow.com/questions/20752882/how-can-i-install-net-framework-as-a-prerequisite-using-innosetup
function _FrameworkIsNotInstalled: Boolean;
begin
  Result :=true;
end;

function FrameworkIsNotInstalled: Boolean;
var
  ver: Cardinal;
begin
  Result :=
    not (
    (
    (RegKeyExists(
      HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Client')
    and
        RegQueryDWordValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Client', 'Release', ver)
    )
    or
    (RegKeyExists(
      HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full')
    and
        RegQueryDWordValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full', 'Release', ver)
    )
    )
    and (ver >= 393295))     // .Net 4.6 Release DWORD
end;

function PythonIsNotInstalled: Boolean;
var
  Names: TArrayOfString;
  ver: Cardinal;
begin
  Result :=
    not
    ((
     (
      RegKeyExists(HKCU, 'SOFTWARE\Software\Python\PythonCore')
      and
      RegKeyExists(HKCU, 'SOFTWARE\Software\Python\ContinuumAnalytics')
      and
      RegGetSubkeyNames(HKCU, 'SOFTWARE\Software\Python\PythonCore', Names)
     )
     or
     (
      RegKeyExists(HKLM, 'SOFTWARE\Software\Python\PythonCore')
      and
      RegKeyExists(HKLM, 'SOFTWARE\Software\Python\ContinuumAnalytics')
      and
      RegGetSubkeyNames(HKLM, 'SOFTWARE\Software\Python\PythonCore', Names)
     ))
     and (GetArrayLength(Names) = 1) 
     and (Names[0] >= '3.6') 
    )
end;


var CancelWithoutPrompt: boolean;

procedure MyAfterInstall();
begin  
    MsgBox('Should cancel because...',mbError,MB_OK)
    CancelWithoutPrompt := true;
    WizardForm.Close;
end;

procedure InitializeWizard;
begin
  if FrameworkIsNotInstalled() then
  begin
    idpAddFile('http://go.microsoft.com/fwlink/?LinkId=528232', ExpandConstant('{tmp}\NetFrameworkInstaller.exe'));
    idpDownloadAfter(wpReady);
  end;
end;

procedure CancelButtonClick(CurPageID: Integer; var Cancel, Confirm: Boolean);
begin
  if CurPageID=wpInstalling then
    Confirm := not CancelWithoutPrompt;
end;

procedure InstallFramework;
var
  StatusText: string;
  ResultCode: Integer;
begin
  StatusText := WizardForm.StatusLabel.Caption;
  WizardForm.StatusLabel.Caption := 'Installing .NET framework...';
  WizardForm.ProgressGauge.Style := npbstMarquee;
  try
      if not Exec(ExpandConstant('{tmp}\NetFrameworkInstaller.exe'), '/passive /norestart', '', SW_SHOW, ewWaitUntilTerminated, ResultCode) then
  begin
    // you can interact with the user that the installation failed
    MsgBox('.NET installation failed with code: ' + IntToStr(ResultCode) + '.',
      mbError, MB_OK);
    CancelWithoutPrompt := true;
    WizardForm.Close;
  end;
  finally
    WizardForm.StatusLabel.Caption := StatusText;
    WizardForm.ProgressGauge.Style := npbstNormal;
    DeleteFile(ExpandConstant('{tmp}\NetFrameworkInstaller.exe'));
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  case CurStep of
    ssPostInstall:
      begin
        if FrameworkIsNotInstalled() then
        begin
          InstallFramework();
        end;
      end;
  end;
end;
