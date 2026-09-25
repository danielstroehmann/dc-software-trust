@echo off
if not "%~1"=="" (
    set KEYPAIR_ALIAS=%~1
) else (
    smctl kp ls
    echo.
    set /p KEYPAIR_ALIAS="Keypair Alias: "
)
echo MsgBox "Hello from DigiCert" > ".\src\helloworld.vbs"


smctl windows certsync --keypair-alias=%KEYPAIR_ALIAS% >nul
smctl sign --keypair-alias %KEYPAIR_ALIAS% --input ".\src\helloworld.vbs" --verbose



smctl sign verify --input ".\src\helloworld.vbs"

