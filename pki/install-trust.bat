@echo off
:: Install all Root and Intermediate CA certificates from pki\root and pki\ica into the Windows OS and Java trust stores.
:: Run as Administrator.
setlocal enabledelayedexpansion
cd /d "%~dp0"

net session >nul 2>&1 || (echo ERROR: Run as Administrator & exit /b 1)

:: ── Windows OS trust store ────────────────────────────────────────────────────

echo =^> Installing into Windows OS trust store...

for %%D in (root ica) do (
    if "%%D"=="root" (set STORE=Root) else (set STORE=CA)
    for %%f in ("%%D\*.pem") do (
        certutil -addstore "!STORE!" "%%f" >nul
        echo     + %%~nf  [!STORE!]
    )
)

echo.

:: ── Java trust store ──────────────────────────────────────────────────────────

where keytool >nul 2>&1 || (echo ERROR: keytool not found - install a JDK & exit /b 1)
for /f "delims=" %%i in ('where keytool') do set "KEYTOOL=%%i"

for %%i in ("!KEYTOOL!") do set "JAVA_BIN=%%~dpi"
set "JAVA_BIN_TRIMMED=!JAVA_BIN:~0,-1!"
for %%i in ("!JAVA_BIN_TRIMMED!") do set "JAVA_HOME_D=%%~dpi"

set "CACERTS=!JAVA_HOME_D!lib\security\cacerts"
if not exist "!CACERTS!" set "CACERTS=!JAVA_HOME_D!jre\lib\security\cacerts"
if not exist "!CACERTS!" (echo ERROR: cacerts not found under !JAVA_HOME_D! & exit /b 1)

echo =^> Installing into Java trust store (!CACERTS!)...

for %%f in ("root\*.pem" "ica\*.pem") do (
    set "ALIAS=%%~nf"
    set "ALIAS=!ALIAS: =-!"

    "!KEYTOOL!" -delete -alias "!ALIAS!" -keystore "!CACERTS!" -storepass changeit -noprompt >nul 2>&1
    "!KEYTOOL!" -importcert -alias "!ALIAS!" -file "%%f" -keystore "!CACERTS!" -storepass changeit -noprompt -trustcacerts >nul
    echo     + !ALIAS!
)

echo.
echo Done. Verify with:
echo   certutil -store Root
echo   "%KEYTOOL%" -list -cacerts -storepass changeit
