!include "FileFunc.nsh"
!include "x64.nsh"
!include "WinVer.nsh"

;--------------------------------
;The nsProcess provides simple macros for handling process control
!include "nsProcess.nsh"

;--------------------------------
;The LogicLib provides some very simple macros that allow easy construction of complex logical structures, see LogicLib.nsh
!include "LogicLib.nsh"
  
!define PRODUCT_NAME                "OSVR_Server"
!define PRODUCT_FRIENDLY_NAME       "OSVR_Services"
!define APP_EXE 					"osvr_server.exe"
!define APP_INSTALL_DIR       	    "$PROGRAMFILES\OSVR"
!define LOCAL_DATA_PATH             "${APP_INSTALL_DIR}\Data\"
!define UNINSTALL_DIR               "${APP_INSTALL_DIR}"
!define SRVC_SETUP_DIR		        "${APP_INSTALL_DIR}\ServiceSetup"

!define LOCAL_UNINSTALLER_NAME 		"Uninstall.exe"
!define LOCAL_UNINSTALLER_DIR 		"${APP_INSTALL_DIR}"

!define OSVRINSTALLLOG  " \..\ProgramData\OSVR\Logs\OSVRInstall.log"

; Version number needs to be changed when we install a new distribution. It is appended to the installer name just to allow for easy identification
!define REVISION                    XXXXX
!define VERSION                     2.5
!define CCVERSION					"2.5.0.0"
; required diskspace in KB
!define PAYLOAD_SIZE                "20000"

; icon used for the shortcuts, installer, and uninstaller
icon "osvr_server.ico"
UninstallIcon "osvr_server.ico"

; Splash screen. This may go away at some point.
Function .onInit
  SetOutPath $TEMP
  File /oname=spltmp.bmp "splash.bmp"

  advsplash::show 1000 600 400 -1 $TEMP\spltmp

  Pop $0 ; $0 has '1' if the user closed the splash screen early,
         ; '0' if everything closed normally, and '-1' if some error occurred.

  Delete $TEMP\spltmp.bmp
FunctionEnd

Function VersionCompare
	!define VersionCompare `!insertmacro VersionCompareCall`
 
	!macro VersionCompareCall _VER1 _VER2 _RESULT
		Push `${_VER1}`
		Push `${_VER2}`
		Call VersionCompare
		Pop ${_RESULT}
	!macroend
 
	Exch $1
	Exch
	Exch $0
	Exch
	Push $2
	Push $3
	Push $4
	Push $5
	Push $6
	Push $7
 
	begin:
	StrCpy $2 -1
	IntOp $2 $2 + 1
	StrCpy $3 $0 1 $2
	StrCmp $3 '' +2
	StrCmp $3 '.' 0 -3
	StrCpy $4 $0 $2
	IntOp $2 $2 + 1
	StrCpy $0 $0 '' $2
 
	StrCpy $2 -1
	IntOp $2 $2 + 1
	StrCpy $3 $1 1 $2
	StrCmp $3 '' +2
	StrCmp $3 '.' 0 -3
	StrCpy $5 $1 $2
	IntOp $2 $2 + 1
	StrCpy $1 $1 '' $2
 
	StrCmp $4$5 '' equal
 
	StrCpy $6 -1
	IntOp $6 $6 + 1
	StrCpy $3 $4 1 $6
	StrCmp $3 '0' -2
	StrCmp $3 '' 0 +2
	StrCpy $4 0
 
	StrCpy $7 -1
	IntOp $7 $7 + 1
	StrCpy $3 $5 1 $7
	StrCmp $3 '0' -2
	StrCmp $3 '' 0 +2
	StrCpy $5 0
 
	StrCmp $4 0 0 +2
	StrCmp $5 0 begin newer2
	StrCmp $5 0 newer1
	IntCmp $6 $7 0 newer1 newer2
 
	StrCpy $4 '1$4'
	StrCpy $5 '1$5'
	IntCmp $4 $5 begin newer2 newer1
 
	equal:
	StrCpy $0 0
	goto end
	newer1:
	StrCpy $0 1
	goto end
	newer2:
	StrCpy $0 2
 
	end:
	Pop $7
	Pop $6
	Pop $5
	Pop $4
	Pop $3
	Pop $2
	Pop $1
	Exch $0
FunctionEnd

### TimeStamp
!ifndef TimeStamp
    !define TimeStamp "!insertmacro _TimeStamp"
    !macro _TimeStamp FormatedString
        !ifdef __UNINSTALL__
            Call un.__TimeStamp
        !else
            Call __TimeStamp
        !endif
        Pop ${FormatedString}
    !macroend
 
!macro __TimeStamp UN
Function ${UN}__TimeStamp
    ClearErrors
    ## Store the needed Registers on the stack
        Push $0 ; Stack $0
        Push $1 ; Stack $1 $0
        Push $2 ; Stack $2 $1 $0
        Push $3 ; Stack $3 $2 $1 $0
        Push $4 ; Stack $4 $3 $2 $1 $0
        Push $5 ; Stack $5 $4 $3 $2 $1 $0
        Push $6 ; Stack $6 $5 $4 $3 $2 $1 $0
        Push $7 ; Stack $7 $6 $5 $4 $3 $2 $1 $0
        ;Push $8 ; Stack $8 $7 $6 $5 $4 $3 $2 $1 $0
 
    ## Call System API to get the current system Time
        System::Alloc 16
        Pop $0
        System::Call 'kernel32::GetLocalTime(i) i(r0)'
        System::Call '*$0(&i2, &i2, &i2, &i2, &i2, &i2, &i2, &i2)i (.r1, .r2, n, .r3, .r4, .r5, .r6, .r7)'
        System::Free $0
 
        IntFmt $2 "%02i" $2
        IntFmt $3 "%02i" $3
        IntFmt $4 "%02i" $4
        IntFmt $5 "%02i" $5
        IntFmt $6 "%02i" $6
 
    ## Generate Timestamp
        ;StrCpy $0 "YEAR=$1$\nMONTH=$2$\nDAY=$3$\nHOUR=$4$\nMINUITES=$5$\nSECONDS=$6$\nMS$7"
        StrCpy $0 "$1$2$3$4$5$6.$7"
 
    ## Restore the Registers and add Timestamp to the Stack
        ;Pop $8  ; Stack $7 $6 $5 $4 $3 $2 $1 $0
        Pop $7  ; Stack $6 $5 $4 $3 $2 $1 $0
        Pop $6  ; Stack $5 $4 $3 $2 $1 $0
        Pop $5  ; Stack $4 $3 $2 $1 $0
        Pop $4  ; Stack $3 $2 $1 $0
        Pop $3  ; Stack $2 $1 $0
        Pop $2  ; Stack $1 $0
        Pop $1  ; Stack $0
        Exch $0 ; Stack ${TimeStamp}
 
FunctionEnd
!macroend
!insertmacro __TimeStamp ""
!insertmacro __TimeStamp "un."
!endif
###########

;--------------------------------
;Check free space

!define sysGetDiskFreeSpaceEx 'kernel32::GetDiskFreeSpaceExA(t, *l, *l, *l) i'
 
; $0 - space required in kb
; $1 - path to check
; $2 - 0 = ignore quotas, 1 = obey quotas
; trashes $2
function CheckSpaceFunc
  IntCmp $2 0 ignorequota
  ; obey quota
  System::Call '${sysGetDiskFreeSpaceEx}(r1,.r2,,.)'
  goto converttokb
  ; ignore quota
  ignorequota:
  System::Call '${sysGetDiskFreeSpaceEx}(r1,.,,.r2)'
  converttokb:
  ; convert the large integer byte values into managable kb
  System::Int64Op $2 / 1024
  Pop $2
  ; check space
  System::Int64Op $2 > $0
  Pop $2
functionend

;--------------------------------
;General

  ;Name and file
  Name "OSVR ${PRODUCT_FRIENDLY_NAME} Installer"
  OutFile "${PRODUCT_NAME}_v${VERSION}.exe"

  ; Admin priviledge is required
  RequestExecutionLevel admin

  ; ShowInstDetails show
  ; ShowUnInstDetails show
  ShowInstDetails nevershow
  ShowUnInstDetails nevershow
  AutoCloseWindow true
  ; SetCompressor lzma

  ;--------------------------------

; Pages
Page instfiles
UninstPage uninstConfirm
UninstPage instfiles
  
;--------------------------------
;Installer Sections
Section "Setting" SEC00
  SetShellVarContext all
  LogEx::Init "$TEMP\osvr_log.txt"
SectionEnd

Section "VersionCheck" SEC001
;version Checking
  ${TimeStamp} $0
  LogEx::Write true true "$0:Version Check"


  ${GetFileVersion} "${APP_INSTALL_DIR}\bin\osvr_server.exe" $R0
  
  
  ${VersionCompare} $R0 ${CCVERSION} $R1
  ${if}  "$R1" == "2" 
       LogEx::Write true true "$0:Replacing $R0 with ${CCVERSION}"
       Goto InstallThis
  ${Else}
	${TimeStamp} $0
    LogEx::Write true true "$0:Version Check: $R0 is newer than ${CCVERSION}}"
    MessageBox MB_OK "Attempting to install version ${CCVERSION}, which is not newer than already installed $R0. Quitting installer."
    Quit
  ${EndIf}
  InstallThis:
 
  ; should check for free space here
  ${TimeStamp} $0
  LogEx::Write true true "$0:Free space check"
 
  StrCpy $0 ${PAYLOAD_SIZE} ; kb u need
  StrCpy $1 '$PROGRAMFILES' ; check drive c: for space
  Call CheckSpaceFunc
  IntCmp $2 1 okay
  MessageBox MB_OK "Error: Not enough disk space. Please make sure you have at least ${PAYLOAD_SIZE} KB free. $2"
  Quit
  okay:
  
SectionEnd

; Check if there is a process already running and kill it so we can install all necessary files.
Section "InitialCleanup" SEC01
  ${TimeStamp} $0
    LogEx::Write true true "$0:InitialCleanup"

	${nsProcess::FindProcess} "${APP_EXE}" $R0
    ;MessageBox MB_OK "nsProcess::FindProcess$\n$\n Errorlevel: [$R0]"

	${If} $R0 == 0
		DetailPrint "${APP_EXE} is running. Closing it down"
		${nsProcess::KillProcess} "${APP_EXE}" $R0
        ;MessageBox MB_OK "nsProcess::KillProcess$\n$\n Errorlevel: [$R0]"
		DetailPrint "Waiting for ${APP_EXE} to close"
		Sleep 2000  
	${Else}
		DetailPrint "${APP_EXE} was not found to be running"        
	${EndIf}    

    ;MessageBox MB_OK "nsProcess::Unload$\n$\n"
	${nsProcess::Unload}
SectionEnd

Section "MainInstall" SEC02

  ${TimeStamp} $0
  LogEx::Write true true "$0:Main Install"

  ; We may want to check here first for existing earlier version before installing. We only do overwrite here and no deletion of existing items
  ; Copy files 
  SetOverwrite on
  SetOutPath "${APP_INSTALL_DIR}"
  File /r /x . Distro\*.*
  
  File osvr_server.ico

SectionEnd
Section "EndInstall" SEC04
  ;Give full access to all users in the system
  AccessControl::GrantOnFile "${APP_INSTALL_DIR}" "(S-1-5-32-545)" "FullAccess"

   ${TimeStamp} $0
  LogEx::Write true true "$0:Creating uninstaller"

 ;Create local uninstaller 
  CreateDirectory "${LOCAL_UNINSTALLER_DIR}"
  WriteUninstaller "${LOCAL_UNINSTALLER_DIR}\${LOCAL_UNINSTALLER_NAME}"

  ${TimeStamp} $0
  LogEx::Write true true "$0:Setting shortcuts"


  ; create a shortcut named "new shortcut" in the start menu programs directory
  ; point the new shortcut at the program uninstaller
  SetOutPath "${APP_INSTALL_DIR}\bin"
  CreateDirectory "$SMPROGRAMS\OSVR"
  CreateShortCut "$SMPROGRAMS\OSVR\osvr_server.lnk" "${APP_INSTALL_DIR}\bin\osvr_server.exe" "" "${APP_INSTALL_DIR}\osvr_server.ico"
  CreateShortCut "$SMPROGRAMS\OSVR\osvr_uninstall.lnk" "${APP_INSTALL_DIR}\uninstall.exe" "" "${APP_INSTALL_DIR}\osvr_server.ico"

  ; sets the default configuration file. If a user wants to change this, he will have to go in and edit the registry (no tools at the moment)
  ${TimeStamp} $0
  LogEx::Write true true "$0:Setting up Run registry"

  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Run" "${PRODUCT_NAME}" '"${APP_INSTALL_DIR}\bin\osvr_server.exe" "${APP_INSTALL_DIR}\bin\osvr_server_config.json"'
 
   ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\osvr_server" "DisplayName" "osvr_server"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\osvr_server" "DisplayVersion" "${VERSION}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\osvr_server" "UninstallString" "$\"${APP_INSTALL_DIR}\uninstall.exe$\""
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\osvr_server" "QuietUninstallString" "$\"${APP_INSTALL_DIR}\uninstall.exe$\" /S"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\osvr_server" "DisplayIcon" "$\"${APP_INSTALL_DIR}\osvr_server.ico$\""
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\osvr_server" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\osvr_server" "NoRepair" 1
 
  ; Execute the Razer Merger if it exist, otherwise skip
  IfFileExists "${APP_INSTALL_DIR}\bin\osvr_server.exe" 0 +2
  Exec '"${APP_INSTALL_DIR}\bin\osvr_server.exe"'
  
  LogEx::Close
 
 ${TimeStamp} $0
  LogEx::Write true true "$0:Finished with install"

  
SectionEnd

Section "Uninstall"

  SetShellVarContext all
  SetAutoClose true
  LogEx::Init "$TEMP\osvr_log.txt"

  ${TimeStamp} $0
  LogEx::Write true true "$0:Uninstall start"

    ; Kill process first before uninstalling
	${nsProcess::FindProcess} "${APP_EXE}" $R0
	;MessageBox MB_OK "nsProcess::FindProcess$\n$\n Errorlevel: [$R0]"

	${If} $R0 == 0
		DetailPrint "${APP_EXE} is running. Closing it down"
		${nsProcess::KillProcess} "${APP_EXE}" $R0
		;MessageBox MB_OK "nsProcess::KillProcess$\n$\n Errorlevel: [$R0]"
		DetailPrint "Waiting for ${APP_EXE} to close"
		Sleep 2000  
	${Else}
		DetailPrint "${APP_EXE} was not found to be running"        
	${EndIf}    

	;MessageBox MB_OK "nsProcess::Unload$\n$\n"
	${nsProcess::Unload}

  ${TimeStamp} $0
  LogEx::Write true true "$0:Cleaning up registry"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Run\${PRODUCT_NAME}" 
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" 
 
  Delete "$SMPROGRAMS\OSVR\osvr_server.lnk"
  Delete "$SMPROGRAMS\OSVR\osvr_uninstall.lnk"
  RMDIR /r  "$SMPROGRAMS\OSVR"
	
  ; Delete the app folder
  RMDIR /r ${APP_INSTALL_DIR}
  
  ; Delete the uninstaller folder
  RMDIR /r ${UNINSTALL_DIR}

  ${TimeStamp} $0
  LogEx::Write true true "$0:Finished uninstall"
  LogEx::Close
SectionEnd
