@echo off
rem build_android.cmd - one-click Android packaging on Windows.
rem   Double-click for the interactive menu, or run:
rem     build_android.cmd wrap     quick wrapper APK (official LÖVE shell + game.love)
rem     build_android.cmd compile  full APK compiled from source (Android SDK + NDK)
rem   Missing tools (Git Bash, JDK 17, LÖVE, Android SDK) are downloaded into
rem   the shared .tools\ dir next to the Kristal engine (mod root as fallback).
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0build_android.ps1" %*
exit /b %ERRORLEVEL%
