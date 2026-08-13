@echo off
rem gui.cmd - start the kristal-debug-tools GUI without installing anything.
rem   - Uses the locally built exe (libraries\kristal-debug-tools\dist) when
rem     present, so development builds work offline.
rem   - Otherwise checks the latest GitHub release and downloads/updates the
rem     release binaries into .tools\gui\ (SHA256-verified). `just` is
rem     compiled into the kristal-run sidecar.
rem   - Fallback: when the latest release's assets are not uploaded yet
rem     (e.g. release-please just cut the tag and CI is still building),
rem     the previous release is downloaded instead. If the previous release
rem     is already cached, the user is asked before it is used.
setlocal EnableExtensions
set "ARCH=x64"
set "DL_DIR=%~dp0.tools\gui"
set "LOCAL_EXE=%~dp0libraries\kristal-debug-tools\dist\kristal-debug-tools-gui-windows-x64.exe"
set "DL_EXE=%DL_DIR%\kristal-debug-tools-gui-windows-%ARCH%.exe"
set "DL_SIDE=%DL_DIR%\kristal-run-windows-%ARCH%.exe"
set "DL_SUMS=%DL_DIR%\checksums-windows-%ARCH%.txt"

if exist "%LOCAL_EXE%" (
    "%LOCAL_EXE%" %*
    exit /b %ERRORLEVEL%
)

if exist "%DL_EXE%" if exist "%DL_SIDE%" if exist "%DL_SUMS%" goto check-version
goto need-download

:check-version
set "LATEST="
for /f "usebackq delims=" %%V in (`powershell -NoProfile -Command "try { (Invoke-RestMethod -Uri 'https://api.github.com/repos/Bli-AIk/kristal-debug-tools-gui/releases/latest' -Headers @{'User-Agent'='kristal-debug-tools-gui'} -TimeoutSec 10).tag_name } catch { '' }"`) do set "LATEST=%%V"
if not defined LATEST (
    echo [thrash-machine] Could not check for updates, using cached build.
    goto run-cached
)
if not exist "%DL_DIR%\version.txt" goto need-download
set "CACHED="
set /p CACHED=<"%DL_DIR%\version.txt"
if "%CACHED%"=="%LATEST%" goto run-cached
goto need-download

:run-cached
"%DL_EXE%" %*
exit /b %ERRORLEVEL%

:need-download
echo [thrash-machine] Downloading kristal-debug-tools GUI (latest release)...
set "DL_BASE=https://github.com/Bli-AIk/kristal-debug-tools-gui/releases/latest/download/"
call :download-assets "%DL_BASE%"
if errorlevel 1 goto fallback
if defined LATEST (
    >"%DL_DIR%\version.txt" echo %LATEST%
)
"%DL_EXE%" %*
exit /b %ERRORLEVEL%

:fallback
rem The latest release's assets are not uploaded yet (e.g. CI is still
rem building them), so fall back to the previous release.
set "PREV="
for /f "usebackq delims=" %%V in (`powershell -NoProfile -Command "$r=Invoke-RestMethod -Uri 'https://api.github.com/repos/Bli-AIk/kristal-debug-tools-gui/releases?per_page=10' -Headers @{'User-Agent'='kristal-debug-tools-gui'} -TimeoutSec 10; $v=@($r).Where({ -not $_.draft -and -not $_.prerelease }); if($v.Count -ge 2){ $v[1].tag_name }"`) do set "PREV=%%V"
if not defined PREV (
    echo [thrash-machine] The latest release is not ready and no previous release was found. Try again later.
    exit /b 1
)
if defined LATEST (
    echo [thrash-machine] The latest release ^(%LATEST%^) is still being built; falling back to previous release %PREV%.
) else (
    echo [thrash-machine] The latest release is still being built; falling back to previous release %PREV%.
)

rem If the previous release was fetched before and is still intact, ask the
rem user whether to use it instead of re-downloading it.
if exist "%DL_EXE%" if exist "%DL_SIDE%" if exist "%DL_SUMS%" goto check-prev-cache
goto download-prev

:check-prev-cache
set "CACHED="
if exist "%DL_DIR%\version.txt" set /p CACHED=<"%DL_DIR%\version.txt"
if not "%CACHED%"=="%PREV%" goto download-prev
set "SUMS_OK="
for /f "usebackq delims=" %%S in (`powershell -NoProfile -Command "$s=Get-Content '%DL_SUMS%'; $h1=(Get-FileHash '%DL_EXE%' -Algorithm SHA256).Hash.ToLower(); $h2=(Get-FileHash '%DL_SIDE%' -Algorithm SHA256).Hash.ToLower(); if($s -match $h1 -and $s -match $h2){ '1' } else { '' }"`) do set "SUMS_OK=%%S"
if not "%SUMS_OK%"=="1" goto download-prev
echo [thrash-machine] Previous release %PREV% is already downloaded.
set "USE_CACHED="
set /p USE_CACHED="[thrash-machine] Use the cached previous release %PREV%? [y/N] "
if /i "%USE_CACHED%"=="y" goto run-cached
if /i "%USE_CACHED%"=="yes" goto run-cached
echo [thrash-machine] Not using the cached release. Try again later once the latest release is ready.
exit /b 1

:download-prev
echo [thrash-machine] Downloading previous release %PREV%...
set "DL_BASE=https://github.com/Bli-AIk/kristal-debug-tools-gui/releases/download/%PREV%/"
call :download-assets "%DL_BASE%"
if errorlevel 1 (
    echo [thrash-machine] Could not download the latest or previous release. Check your network or build locally.
    exit /b 1
)
>"%DL_DIR%\version.txt" echo %PREV%
"%DL_EXE%" %*
exit /b %ERRORLEVEL%

:download-assets
rem %1 = base URL of this release's assets (latest/... or downloads/<tag>/)
rem Downloads to .tmp names and only moves them into place after the SHA256
rem check, so a failed attempt never corrupts a cached release.
if not exist "%DL_DIR%" mkdir "%DL_DIR%"
powershell -NoProfile -Command ^
  "$ProgressPreference='SilentlyContinue';" ^
  "$base='%~1';" ^
  "$dir='%DL_DIR%';" ^
  "$files=@('kristal-debug-tools-gui-windows-%ARCH%.exe','kristal-run-windows-%ARCH%.exe','checksums-windows-%ARCH%.txt');" ^
  "foreach($f in $files){ Invoke-WebRequest -Uri ($base+$f) -OutFile (Join-Path $dir ($f+'.tmp')) };" ^
  "$sums=Get-Content (Join-Path $dir ('checksums-windows-%ARCH%.txt'+'.tmp'));" ^
  "foreach($f in $files){ if($f -eq 'checksums-windows-%ARCH%.txt'){continue};" ^
  "  $h=(Get-FileHash (Join-Path $dir ($f+'.tmp')) -Algorithm SHA256).Hash.ToLower();" ^
  "  if(-not ($sums -match $h)){ Write-Error ('checksum mismatch: '+$f); exit 1 } };" ^
  "foreach($f in $files){ Move-Item -Force (Join-Path $dir ($f+'.tmp')) (Join-Path $dir $f) }"
exit /b %ERRORLEVEL%
