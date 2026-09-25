@echo off
if not "%~1"=="" (
    set KEYPAIR_ALIAS=%~1
) else (
    smctl kp ls
    echo.
    set /p KEYPAIR_ALIAS="Keypair Alias: "
)
copy "C:\Windows\notepad.exe" ".\src\" >nul

pause

smctl windows certsync --keypair-alias=%KEYPAIR_ALIAS% >nul
smctl sign --keypair-alias %KEYPAIR_ALIAS% --input ".\src\notepad.exe" --verbose
smctl sign verify --input ".\src\notepad.exe"
