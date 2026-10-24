@echo off
setlocal EnableExtensions
cd /d "%~dp0"

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

set "GODOT="
if exist "%~dp0..\Godot_v4.8-dev7_win64.exe\Godot_v4.8-dev7_win64.exe" (
	set "GODOT=%~dp0..\Godot_v4.8-dev7_win64.exe\Godot_v4.8-dev7_win64.exe"
)
if not defined GODOT if exist "%~dp0Godot_v4.8-dev7_win64.exe" (
	set "GODOT=%~dp0Godot_v4.8-dev7_win64.exe"
)
if not defined GODOT if exist "C:\Users\steve\Desktop\Dev\Game Dev\Godot_v4.8-dev7_win64.exe\Godot_v4.8-dev7_win64.exe" (
	set "GODOT=C:\Users\steve\Desktop\Dev\Game Dev\Godot_v4.8-dev7_win64.exe\Godot_v4.8-dev7_win64.exe"
)

if not defined GODOT (
	echo Could not find Godot_v4.8-dev7_win64.exe
	echo.
	echo Put that file in this folder, next to this launcher, then try again.
	echo Use the normal Godot exe, not the console one.
	echo.
	pause
	exit /b 1
)

start "" "%GODOT%" --path "%ROOT%"
if errorlevel 1 (
	echo Godot did not start.
	pause
	exit /b 1
)
