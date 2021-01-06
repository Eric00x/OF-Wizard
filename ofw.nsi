#===============================================
/* OFW/OFI version 1.0, 6th January 2021
# Based on OF Install Script made by brysondev
# https://github.com/brysondev/OF-Install-Script
#
# Made by watermelon.mdl
#
# NOTE: I AM USING MODERNUI 2.0, NOT CLASSIC ONE
# Strings longer than ${NSIS_MAX_STRLEN} (1024) will get truncated/corrupted. (oh no)
# Also 2GB limit, makensisw is 32-bit afaik */
#===============================================
# Included modules/files

!include 'MUI2.nsh'
# ModernUI 2.0

!include 'LogicLib.nsh'
# If/Else and other stuff

!include 'x64.nsh'
# We have to check which version of Windows user has installed.

#===============================================
# Basic installer setup

Name "Open Fortress"
Caption "Open Fortress Wizard"
OutFile "OFWizard.exe"

Unicode True
SetDatablockOptimize on
CRCCheck on
RequestExecutionLevel admin
SetCompressor /SOLID lzma

ShowInstDetails show
BrandingText "Open Fortress Team"

InstallDir "$LOCALAPPDATA\Temp"
# default install dir

!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\classic-install.ico"
# icons in the NSIS install path

!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP 'OFheader.bmp'
#size: 150x57, displays at the top of window

!define MUI_ABORTWARNING
#===============================================
# License

!insertmacro MUI_PAGE_LICENSE  "license.rtf"
# DO NOT USE LicenseForceSelection - nobody reads our shit anyways so why bother forcing user to check a box.

#===============================================
# Installer

!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_ABORTWARNING_CANCEL_DEFAULT
# Allow the user to check the install log, without auto-closing. CANCEL is the default button, because we set it in the second line.

!insertmacro MUI_PAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"
# Yes, this is the right place for it, DO NOT CHANGE IT or NSIS will warn you about that.

Section Install
# FUNCTIONS ARE UNDER!

Call checkTF2
Call checkSDK
# Since we checked if user has Steam, we don't have to do it again

Call checkTortoise
/* I have included both x64 and x32 releases.
# Hoping that TSVN auto-updates itself, otherwise I'll have to parse RSS xml from their shit repo.
# Why? Because NSIS is so old that it does not support HTTPS afaik - at least in most plugins for pasing pages. */
 
Call OFSync

SectionEnd

#===============================================
# Functions

Function checkTF2
# TF2's ID is 440
checkTF2Again:
	DetailPrint "Checking if you have TF2 installed..."
	ClearErrors
	ReadRegDWORD $0 HKCU "SOFTWARE\Valve\Steam\Apps\440" "Installed"
	${If} ${Errors}
	
		DetailPrint "TF2 is not present."
		MessageBox MB_YESNO "You don't have Team Fortress 2 installed, without it we can't install Open Fortress.$\r$\nDo you want to install it?" IDYES checkSteamExistsTF
/* Line break and carriage return. Use this if you want a new line.
# DO NOT insert line breaks (and/or carriage return) into comments, NSIS will warn you about that but that's all. Just don't.*/
		Abort "User cancelled TF2 installation."
		
	${Else}
		${IF} $0 == ""
# The error flag will be set and $x will be set to an empty string ("" which is interpreted as 0 in math operations) if the DWORD is not present.
			DetailPrint "TF2 is not present."
			MessageBox MB_YESNO "You don't have Team Fortress 2 installed, without it we can't install Open Fortress.$\r$\nDo you want to install it?" IDYES checkSteamExistsTF
			Abort "User cancelled TF2 installation."
        ${ELSE}
			${IF} $0 == 0
				DetailPrint "TF2 is not present."
				MessageBox MB_YESNO "You don't have Team Fortress 2 installed, without it we can't install Open Fortress.$\r$\nDo you want to install it?" IDYES checkSteamExistsTF
				DetailPrint "User cancelled TF2 installation."
				Abort
			${ELSE}
				DetailPrint "TF2 is present."
				Goto endTFInstall
			${ENDIF}
        ${ENDIF}
	${EndIf}
checkSteamExistsTF:
# Detect if user does even have Steam installed

	ReadRegStr $0 HKCU "SOFTWARE\Valve\Steam\" "SteamExe"
	${If} ${Errors}
		Abort "Do you even have Steam installed? https://store.steampowered.com/about/"
	${Else}
		${IF} $0 == ""	
			Abort "Do you even have Steam installed? https://store.steampowered.com/about/"
		${EndIf}
	${EndIf}
	Pop $0
	ClearErrors
	DetailPrint "Launching TF2 installation on Steam, this might take a while..."
	ExecShell "open" "steam://install/440"
	MessageBox MB_OK "Press OK if TF2 installation ended.$\r$\nSorry, I can't check that..."
	DetailPrint "User clicked on OK button."
	Pop $0
	Goto checkTF2Again
	
endTFInstall:
	Pop $0
	ClearErrors
FunctionEnd

Function checkSDK
# literally copy-paste from TF2 check
# SDK's ID is 243750
checkSDKAgain:

	DetailPrint "Checking if you have Source SDK 2013 Multiplayer installed..."
	ClearErrors
	ReadRegDWORD $0 HKCU "SOFTWARE\Valve\Steam\Apps\243750" "Installed"
	${If} ${Errors}
	
		DetailPrint "Source SDK is not present."
		MessageBox MB_YESNO "You don't have Source SDK 2013 Multiplayer installed, without it we can't install Open Fortress.$\r$\nDo you want to install it?" IDYES installSDK
		Abort "User cancelled Source SDK installation."
		
	${Else}
		${IF} $0 == ""
		
			DetailPrint "Source SDK is not present."
			MessageBox MB_YESNO "You don't have Source SDK 2013 Multiplayer installed, without it we can't install Open Fortress.$\r$\nDo you want to install it?" IDYES installSDK
			Abort "User cancelled SDK installation."
			
        ${ELSE}
			${IF} $0 == 0
			
				DetailPrint "Source SDK is not present."
				MessageBox MB_YESNO "You don't have Source SDK 2013 Multiplayer installed, without it we can't install Open Fortress.$\r$\nDo you want to install it?" IDYES installSDK
				DetailPrint "User cancelled SDK installation."
				Abort
				
			${ELSE}
				DetailPrint "Source SDK is present."
				Goto endSDKInstall
			${ENDIF}
        ${ENDIF}
	${EndIf}
installSDK:

	DetailPrint "Launching Source SDK 2013 Multiplayer installation on Steam, this might take a while..."
	ExecShell "open" "steam://install/243750"
	MessageBox MB_OK "Press OK if Source SDK 2013 Multiplayer installation ended.$\r$\nSorry, I can't check that..."
	DetailPrint "User clicked on OK button."
	Pop $0
	Goto checkSDKAgain
	
endSDKInstall:
	Pop $0
	ClearErrors
FunctionEnd

Function checkTortoise
# ctrl+c ctrl+v except we can FINALLY check if it did install.
# SDK's ID is 243750

	DetailPrint "Checking if you have TortoiseSVN installed..."
	ClearErrors
	ReadRegStr $0 HKLM "SOFTWARE\TortoiseSVN" "ProcPath"
	# more reliable than version from HKCU
	
	${If} ${Errors}
	
		DetailPrint "TortoiseSVN is not present."
		MessageBox MB_YESNO "You don't have TortoiseSVN installed, without it we can't install Open Fortress.$\r$\nDo you want to install it?" IDYES installTortoise
		Abort "User cancelled TortoiseSVN installation. Install it manually if you want to: https://tortoisesvn.net/downloads.html"
		
	${Else}
		${IF} $0 == ""
		
			DetailPrint "TortoiseSVN is not present."
			MessageBox MB_YESNO "You don't have TortoiseSVN installed, without it we can't install Open Fortress.$\r$\nDo you want to install it?" IDYES installTortoise
			Abort "User cancelled TortoiseSVN installation. Install it manually if you want to: https://tortoisesvn.net/downloads.html"
		${ELSE}
				DetailPrint "TortoiseSVN is present."
				Goto endTortoiseInstall
		${ENDIF}
	${EndIf}
	
	Pop $0
	ClearErrors
	installTortoise:
	SetOutPath "$LOCALAPPDATA\Temp"
	
		${If} ${RunningX64}
			# 64bit
			File "Tortoise64.msi"
			ExecWait '"msiexec.exe" /i $LOCALAPPDATA\Temp\Tortoise64.msi /quiet /passive' $0
			# M S I E X E C won't return fucking ANYTHING if user exits from installer for example, NSIS is just waiting for it to end.
			Delete "$LOCALAPPDATA\Temp\Tortoise64.msi"
		${Else}
			# 32bit
			File "Tortoise32.msi"
			ExecWait '"msiexec.exe" /i $LOCALAPPDATA\Temp\Tortoise32.msi /quiet /passive' $0
			Delete "$LOCALAPPDATA\Temp\Tortoise32.msi"
		${EndIf}  
		
		${If} ${Errors}
		Abort "Error while installing TortoiseSVN, return code is $0 . If no code - that's still a problem."
		${Else}
		DetailPrint "TortoiseSVN installation completed."
		${EndIf}
		Pop $0
		
endTortoiseInstall:
	Pop $0
	ClearErrors
FunctionEnd

Function OFSync
	ReadRegStr $0 HKCU "SOFTWARE\Valve\Steam" "SourceModInstallPath"
	SetOutPath $0
	StrCpy $0 '"$0\open_fortress"'
	ReadRegStr $1 HKLM "SOFTWARE\TortoiseSVN" "ProcPath"
	
	IFFileExists '$OUTDIR\open_fortress\.svn\wc.db' 0 +6	# Skip syncing whole catalog.
	DetailPrint "Updating Open Fortress, this might take a while..."
	ExecWait '"$1" /command:update /path:$0 /skipprechecks /closeonend:1'
	${If} ${Errors}
		Abort "Update failed!"
	${EndIf}
	Goto +7
	DetailPrint "Installing Open Fortress, this might take a while..."
	DetailPrint "Press OK button in TortoiseSVN's window to continue"
	ExecWait '"$1" /command:checkout /url:https://svn.openfortress.fun/svn/open_fortress /path:$0 /closeonend:0 /noui'
		${If} ${Errors}
		Abort "Installation failed!"
	${EndIf}
	DetailPrint "Cleaning up..."
	ExecWait '"$1" /command:cleanup /path:$0 /noui /noprogressui /breaklocks /refreshshell /externals /fixtimestamps /vacuum /closeonend:1'
		${If} ${Errors}
		Abort "Cleaning up failed!"
	${EndIf}
	Pop $1
FunctionEnd