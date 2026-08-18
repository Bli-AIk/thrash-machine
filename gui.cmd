@echo off
rem gui.cmd - start a Kristal-compatible kristal-debug-tools GUI release.
rem   - The GUI release is selected from the nearest Kristal engine VERSION:
rem       0.10.0     -> v0.1.5
rem       0.11.0-dev -> v0.2.0
rem   - Assets are downloaded into the shared <Kristal>\.tools\gui\ cache and
rem     SHA256-verified before they replace a cached release.
rem   - Unknown engines deliberately fail instead of downloading latest.
setlocal EnableExtensions

set "ARCH=x64"
set "MOD_ROOT="
for %%I in ("%~dp0.") do set "MOD_ROOT=%%~fI"
set "KRISTAL_ROOT_ENV=%KRISTAL_ROOT%"
set "ENGINE_ROOT="

rem Prefer the engine containing this project. Explicit roots are only a
rem fallback for projects cloned outside an engine tree.
call :find-kristal "%MOD_ROOT%"
if not defined ENGINE_ROOT if defined KRISTAL_ROOT_ENV call :use-engine "%KRISTAL_ROOT_ENV%"
if not defined ENGINE_ROOT if defined THRASH_MACHINE_KRISTAL_DIR call :use-engine "%THRASH_MACHINE_KRISTAL_DIR%"
if not defined ENGINE_ROOT (
    echo [thrash-machine] Kristal engine not found. Put this project under ^<Kristal^>\mods\ or set KRISTAL_ROOT. 1>&2
    exit /b 1
)

set "ENGINE_VERSION="
for /f "usebackq delims=" %%V in ("%ENGINE_ROOT%\VERSION") do if not defined ENGINE_VERSION set "ENGINE_VERSION=%%V"
set "GUI_TAG="
if /i "%ENGINE_VERSION%"=="0.10.0" set "GUI_TAG=v0.1.5"
if /i "%ENGINE_VERSION%"=="v0.10.0" set "GUI_TAG=v0.1.5"
if /i "%ENGINE_VERSION%"=="0.11.0-dev" set "GUI_TAG=v0.2.0"
if /i "%ENGINE_VERSION%"=="v0.11.0-dev" set "GUI_TAG=v0.2.0"
if not defined GUI_TAG (
    echo [thrash-machine] Unsupported Kristal VERSION "%ENGINE_VERSION%". Supported versions: 0.10.0, 0.11.0-dev. 1>&2
    exit /b 1
)

set "KDT_MOD_ROOT=%MOD_ROOT%"
set "KRISTAL_ROOT=%ENGINE_ROOT%"
set "DL_DIR=%ENGINE_ROOT%\.tools\gui"
set "DL_EXE=%DL_DIR%\kristal-debug-tools-gui-windows-%ARCH%.exe"
set "DL_SIDE=%DL_DIR%\kristal-run-windows-%ARCH%.exe"
set "DL_SUMS=%DL_DIR%\checksums-windows-%ARCH%.txt"
set "DL_BASE=https://github.com/Bli-AIk/kristal-debug-tools-gui/releases/download/%GUI_TAG%/"

if not exist "%DL_EXE%" goto need-download
if not exist "%DL_SIDE%" goto need-download
if not exist "%DL_SUMS%" goto need-download
if not exist "%DL_DIR%\version.txt" goto need-download
set "CACHED="
set /p CACHED=<"%DL_DIR%\version.txt"
if /i not "%CACHED%"=="%GUI_TAG%" goto need-download
call :verify-cached
if errorlevel 1 (
    echo [thrash-machine] Cached GUI %GUI_TAG% failed checksum verification; downloading it again.
    goto need-download
)
goto run-cached

:need-download
echo [thrash-machine] Downloading kristal-debug-tools GUI %GUI_TAG% for Kristal %ENGINE_VERSION%...
call :download-assets "%DL_BASE%"
if errorlevel 1 (
    echo [thrash-machine] Could not download GUI %GUI_TAG%. Check your network or build from source with just gui-dev. 1>&2
    exit /b 1
)
>"%DL_DIR%\version.txt" echo %GUI_TAG%

:run-cached
"%DL_EXE%" %*
exit /b %ERRORLEVEL%

:download-assets
rem %1 is the exact release's asset base URL. Files are downloaded to .tmp
rem names and only moved into place after both executable hashes verify.
if not exist "%DL_DIR%" mkdir "%DL_DIR%"
powershell -NoProfile -Command ^
  "$base='%~1';" ^
  "$dir='%DL_DIR%';" ^
  "$files=@('kristal-debug-tools-gui-windows-%ARCH%.exe','kristal-run-windows-%ARCH%.exe','checksums-windows-%ARCH%.txt');" ^
  "foreach($f in $files){" ^
  "  Write-Host ('Downloading '+$f);" ^
  "  Invoke-WebRequest -Uri ($base+$f) -OutFile (Join-Path $dir ($f+'.tmp'));" ^
  "  $sz=(Get-Item (Join-Path $dir ($f+'.tmp'))).Length;" ^
  "  Write-Host ('  done - '+[math]::Round($sz/1MB,1)+' MB') };" ^
  "$sums=Get-Content (Join-Path $dir ('checksums-windows-%ARCH%.txt'+'.tmp'));" ^
  "foreach($f in $files){ if($f -eq 'checksums-windows-%ARCH%.txt'){continue};" ^
  "  $h=(Get-FileHash (Join-Path $dir ($f+'.tmp')) -Algorithm SHA256).Hash.ToLower();" ^
  "  if(-not ($sums -match $h)){ Write-Error ('checksum mismatch: '+$f); exit 1 } };" ^
  "foreach($f in $files){ Move-Item -Force (Join-Path $dir ($f+'.tmp')) (Join-Path $dir $f) }"
exit /b %ERRORLEVEL%

:verify-cached
powershell -NoProfile -Command ^
  "$s=Get-Content '%DL_SUMS%';" ^
  "$ok=$true;" ^
  "foreach($f in @('%DL_EXE%','%DL_SIDE%')){ $h=(Get-FileHash $f -Algorithm SHA256).Hash.ToLower(); if(-not ($s -match $h)){ $ok=$false } };" ^
  "if($ok){ exit 0 } else { Write-Error 'cached GUI failed checksum verification'; exit 1 }"
exit /b %ERRORLEVEL%

:find-kristal
set "CAND=%~1"
if exist "%CAND%\main.lua" if exist "%CAND%\src\kristal.lua" (
    set "ENGINE_ROOT=%CAND%"
    exit /b 0
)
for %%I in ("%CAND%\..") do set "PARENT=%%~fI"
if /i "%PARENT%"=="%CAND%" exit /b 1
call :find-kristal "%PARENT%"
exit /b %ERRORLEVEL%

:use-engine
if exist "%~1\main.lua" if exist "%~1\src\kristal.lua" if exist "%~1\VERSION" (
    for %%I in ("%~1") do set "ENGINE_ROOT=%%~fI"
    exit /b 0
)
exit /b 1
