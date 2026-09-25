@echo off
cd /d "%~dp0"

call helper-jar-helloworld.bat

cd /d "%~dp0"

smctl kp ls
echo.
set /p KEYPAIR_ALIAS="Keypair Alias: "

smctl certificate download --keypair-alias=%KEYPAIR_ALIAS% -n %KEYPAIR_ALIAS%.crt >nul 2>&1

jarsigner -keystore NONE -storepass NONE -storetype PKCS11 -sigalg SHA256withRSA -providerClass sun.security.pkcs11.SunPKCS11 -providerArg "C:\Program Files\DigiCert\DigiCert One Signing Manager Tools\pkcs11properties.cfg" -signedjar src\hello_signed.jar src\hello.jar %KEYPAIR_ALIAS% -tsa "http://timestamp.digicert.com"

del *.crt >nul 2>&1
