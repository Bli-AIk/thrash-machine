@echo off
rem gui.cmd — start the kristal-debug-tools GUI without installing anything.
rem   - Uses the locally built exe (libraries\kristal-debug-tools\dist) when
rem     present, so development builds work offline.
rem   - Otherwise downloads the latest release binary into .tools\gui\.
rem   - The GUI itself embeds just, so no `just` install is needed.
setlocal EnableExtensions
set "LOCAL_EXE=%~dp0libraries\kristal-debug-tools\dist\kristal-debug-tools-gui-windows-x64.exe"
set "DL_EXE=%~dp0.tools\gui\kristal-debug-tools-gui-windows-x64.exe"

if exist "%LOCAL_EXE%" (
    "%LOCAL_EXE%" %*
    exit /b %ERRORLEVEL%
)

if exist "%DL_EXE%" (
    "%DL_EXE%" %*
    exit /b %ERRORLEVEL%
)

echo [thrash-machine] Downloading kristal-debug-tools GUI (latest release)...
if not exist "%~dp0.tools\gui" mkdir "%~dp0.tools\gui"
powershell -NoProfile -Command ^
  "$ProgressPreference='SilentlyContinue';" ^
  "$u='https://github.com/Bli-AIk/kristal-debug-tools/releases/latest/download/kristal-debug-tools-gui-windows-x64.exe';" ^
  "Invoke-WebRequest -Uri $u -OutFile '%DL_EXE%';" ^
  "if(-not (Test-Path '%DL_EXE%')){Write-Error 'download failed'; exit 1}"
if errorlevel 1 (
    echo [thrash-machine] Download failed. Build it locally with: just gui-build-windows
    exit /b 1
)

"%DL_EXE%" %*
exit /b %ERRORLEVEL%
