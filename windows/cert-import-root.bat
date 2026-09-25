@echo off
setlocal enabledelayedexpansion

set PKI_DIR=%~dp0..\pki

for %%D in (root ica) do (
    echo Importing %%D certificates from %PKI_DIR%\%%D
    echo.
    for %%F in ("%PKI_DIR%\%%D\*.pem") do (
        set "FNAME=%%~nF"
        set "ALIAS=!FNAME: =_!"
        keytool -list -alias "!ALIAS!" -cacerts -storepass changeit >nul 2>&1
        if !errorlevel! equ 0 (
            echo Skipping: %%~nxF  ^(already installed^)
        ) else (
            echo Importing: %%~nxF  ^(alias: !ALIAS!^)
            keytool -importcert -trustcacerts -file "%%F" -alias "!ALIAS!" -cacerts -storepass changeit -noprompt
        )
        echo.
    )
)

echo Done.
