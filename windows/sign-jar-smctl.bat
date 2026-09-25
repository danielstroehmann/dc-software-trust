@echo off
cd /d "%~dp0"

call helper-jar-helloworld.bat

cd /d "%~dp0"

smctl kp ls
echo.
set /p KEYPAIR_ALIAS="Keypair Alias: "



smctl sign --input src\hello.jar --keypair-alias %KEYPAIR_ALIAS% --verbose --config-file "C:\Program Files\DigiCert\DigiCert One Signing Manager Tools\pkcs11properties.cfg"
