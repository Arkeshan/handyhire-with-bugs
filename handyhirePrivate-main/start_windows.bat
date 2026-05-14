@echo off
REM ═══════════════════════════════════════════════════════════════════════════
REM  HandyHire — Windows Starter
REM  Double-click this file OR run it from Command Prompt
REM ═══════════════════════════════════════════════════════════════════════════

echo.
echo ============================================
echo        HandyHire — Starting Up
echo ============================================
echo.

REM Kill anything on port 8080
for /f "tokens=5" %%a in ('netstat -aon 2^>nul ^| findstr ":8080"') do (
    taskkill /F /PID %%a 2>nul
)

echo [1/3] Starting the backend server...
echo       (A new window will open — leave it running)
echo.

start "HandyHire Backend" cmd /k "cd /d "%~dp0backend" && .\mvnw.cmd spring-boot:run"

echo [2/3] Waiting 60 seconds for the backend to start...
echo       Watch the "HandyHire Backend" window.
echo       When you see "Started HandyhireBackendApplication" it is ready.
echo.
timeout /t 60 /nobreak

echo.
echo [3/3] Starting the Flutter app...
echo.
echo IMPORTANT: Before continuing, make sure:
echo   - Android emulator is open (start it from Android Studio)
echo   - OR a real Android phone is plugged in with USB debugging ON
echo.
echo Press any key when your emulator/phone is ready...
pause >nul

cd /d "%~dp0frontend"
flutter run

echo.
echo Finished. You can close this window.
pause
