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

::::::::::::::::::::::::::::
::START
::::::::::::::::::::::::::::
:MENU
CLS
ECHO.
ECHO  Select an option please
ECHO.
ECHO  -------------------
ECHO  ^| [1] SFC SCAN    ^|
ECHO  ^| [2] DISM SCAN   ^|
ECHO  ^| [3] DISM REPAIR ^|
ECHO  ^| [4] EXIT        ^|
ECHO  -------------------
ECHO.
SET /P Q= #   
IF /I "%Q%" EQU "1" GOTO SFC
IF /I "%Q%" EQU "2" GOTO DISM-SCAN
IF /I "%Q%" EQU "3" GOTO DISM-REPAIR
IF /I "%Q%" EQU "4" EXIT
CLS
ECHO.
ECHO ------------------------------
ECHO ^| Enter a number from 1 to 4 ^|
ECHO ------------------------------
ECHO.
PAUSE
GOTO MENU
:SFC
CLS
sfc /scannow
PAUSE
GOTO MENU
:DISM-SCAN
CLS
DISM /Online /Cleanup-Image /CheckHealth
DISM /Online /Cleanup-Image /ScanHealth
PAUSE
GOTO MENU
:DISM-REPAIR
CLS
DISM /Online /Cleanup-Image /RestoreHealth
PAUSE
GOTO MENU
