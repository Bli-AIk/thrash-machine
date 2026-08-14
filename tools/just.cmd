@echo off
rem tools\just.cmd - run the mod's justfile recipes from cmd/PowerShell/Explorer.
rem Delegates to tools\just (the bash wrapper), which uses the debug-tools GUI's
rem embedded just on Windows, so no standalone just install is needed. Requires
rem Git Bash (the build scripts need bash/tar/curl anyway).
setlocal EnableExtensions
set "BASH="
for %%P in ("%ProgramFiles%\Git\bin\bash.exe" "%ProgramFiles(x86)%\Git\bin\bash.exe" "%LocalAppData%\Programs\Git\bin\bash.exe") do (
    if not defined BASH if exist "%%~P" set "BASH=%%~P"
)
if not defined BASH (
    echo [tools\just] Git Bash not found. Install Git for Windows to use the build scripts. 1>&2
    exit /b 1
)
pushd "%~dp0"
"%BASH%" -lc './just "$@"' just %*
set "ERR=%ERRORLEVEL%"
popd
exit /b %ERR%
