@echo off

if not "%~1"=="" (
    set KP_ID=%~1
) else (
    smctl kp ls
    echo.
    set /p KP_ID="Key Pair ID: "
)

echo.
smctl certificate profile ls
echo.
set /p CP_ID="Certificate Profile ID: "

echo.
set /p ALIAS="Certificate Alias: "

echo.
smctl kp generate-cert "%KP_ID%" --cert-alias "%ALIAS%" --cert-profile-id "%CP_ID%"