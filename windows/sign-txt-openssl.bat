@echo off
cd /d "%~dp0"
if exist .env for /f "usebackq eol=# tokens=1,* delims==" %%A in (".env") do set "%%A=%%~B"
if not "%~1"=="" (
    set KEYPAIR_ALIAS=%~1
) else (
    smctl kp ls
    echo.
    set /p KEYPAIR_ALIAS="Keypair Alias: "
)
set OPENSSL="C:\Program Files\OpenSSL-Win64\bin\openssl.exe"
set PROVIDER=-provider-path "C:\Program Files\DigiCert\DigiCert One Signing Manager Tools" -provider digicert_stm -provider default

echo Hello from DigiCert> ".\src\hello.txt"
smctl certificate download --keypair-alias %KEYPAIR_ALIAS% --chain -n %KEYPAIR_ALIAS%-chain.pem -o ".\src" >nul

%OPENSSL% cms -sign %PROVIDER% -md sha256 -inkey stm://%KEYPAIR_ALIAS% -signer ".\src\%KEYPAIR_ALIAS%-chain.pem" -certfile ".\src\%KEYPAIR_ALIAS%-chain.pem" -in ".\src\hello.txt" -out ".\src\hello.signed.txt"
%OPENSSL% cms -verify -purpose codesign -CAstore "org.openssl.winstore://" -in ".\src\hello.signed.txt" -out nul
