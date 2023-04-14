@ECHO OFF
TITLE Windows repair

:init
setlocal DisableDelayedExpansion
set "batchPath=%~0"
for %%k in (%0) do set batchName=%%~nk
set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
setlocal EnableDelayedExpansion

:checkPrivileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)

ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
ECHO args = "ELEV " >> "%vbsGetPrivileges%"
ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
ECHO Next >> "%vbsGetPrivileges%"
ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
"%SystemRoot%\System32\WScript.exe" "%vbsGetPrivileges%" %*
exit /B

:gotPrivileges
setlocal & pushd .
cd /d %~dp0
if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)

:MENU
SET Q=
CLS
ECHO.
ECHO  Select an option please
ECHO.
ECHO  ----------------------
ECHO  ^| [1] WINDOWS REPAIR ^|
ECHO  ^| [2] CLEAN TEMP DIR ^|
ECHO  ^| [3] CHECK HDD/SSD  ^|
ECHO  ^| [4] CHECK RAM      ^|
ECHO  ^| [5] EXIT           ^|
ECHO  ----------------------
ECHO.
SET /P Q= #   
IF "%Q%"=="" GOTO EXIT
IF /I "%Q%" EQU "1" GOTO WIN
IF /I "%Q%" EQU "2" GOTO TEMP
IF /I "%Q%" EQU "3" GOTO HDD
IF /I "%Q%" EQU "4" GOTO RAM
IF /I "%Q%" EQU "5" EXIT
CLS
ECHO.
ECHO ------------------------------
ECHO ^| Enter a number from 1 to 5 ^|
ECHO ------------------------------
ECHO.
PAUSE
GOTO MENU
:WIN
CLS
ECHO.
ECHO   *****************************************************
ECHO   *** It requieres internet connection in order to  ***
ECHO   *** match and repair any corrupted system file.   ***
ECHO   *****************************************************
ECHO.
ECHO.
ECHO.
DISM /Online /Cleanup-Image /CheckHealth
ECHO.
DISM /Online /Cleanup-Image /ScanHealth
ECHO.
DISM /Online /Cleanup-Image /RestoreHealth
ECHO.
SFC /scannow
ECHO.
ECHO   **********************************
ECHO   *** Repair has been completed^^! ***
ECHO   **********************************
ECHO.
ECHO   Please check logs or anything you need before press any key.
ECHO.
ECHO.
ECHO.
PAUSE
GOTO MENU
:TEMP
CD /D %temp%
FOR /d %%D in (*) do RD /s /q "%%D"
DEL /f /q *
CLS
ECHO.
ECHO   *****************************************************
ECHO   *** Temporary folder has been cleaned succefully^^! ***
ECHO   *****************************************************
ECHO.
ECHO.
ECHO.
PAUSE
GOTO MENU
:HDD
CLS
CHKDSK /f /r
:HDD-Q
CLS
ECHO.
ECHO   **********************************************************************
ECHO   *** Restart your computer in order to perform a disk check/repair. ***
ECHO   **********************************************************************
ECHO.
ECHO.
ECHO.
ECHO Restart now? (y/n)
SET /P R=
IF "%R%"=="" SHUTDOWN /r /t 00
IF /I "%R%" EQU "y" SHUTDOWN /r /t 00
IF /I "%R%" EQU "n" EXIT
ECHO.
ECHO Choose (Y)es or (N)o
ECHO.
PAUSE
GOTO HDD-Q
:RAM
CLS
START "" MDSCHED
EXIT
