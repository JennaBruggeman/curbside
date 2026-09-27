@echo off
rem Curbside: start the local server on port 8766 in its own window (unless something is
rem already listening there, which is left alone), then open the landing page in the default browser.
rem For testing only: PARKLET_PORT overrides the port, PARKLET_NOBROWSER=1 skips the browser.
setlocal
cd /d "%~dp0.."
set "PORT=8766"
if defined PARKLET_PORT set "PORT=%PARKLET_PORT%"
set "URL=http://localhost:%PORT%/"
if exist ".render-key" (set "KEYMSG=.render-key found") else (set "KEYMSG=.render-key not found")
if defined PROVIDER_KEY set "KEYMSG=%KEYMSG% (PROVIDER_KEY is set and takes precedence)"

call :answers 0
if not errorlevel 1 (
  set "MSG=Curbside server already running on port %PORT%, left alone"
  goto open
)
start "Curbside server" powershell -NoProfile -ExecutionPolicy Bypass -File tools\serve.ps1 -Port %PORT%
call :answers 10
if errorlevel 1 (
  echo Started the Curbside server window, but port %PORT% did not answer within 10 s - check that window. %KEYMSG%.
  goto done
)
set "MSG=Started the Curbside server on port %PORT%"

:open
if not "%PARKLET_NOBROWSER%"=="1" start "" "%URL%"
echo %MSG%; %KEYMSG%.

:done
rem keep the line readable when the script was double-clicked
timeout /t 5 >nul 2>nul
exit /b 0

rem :answers N -- errorlevel 0 when a TCP connection to 127.0.0.1:PORT succeeds within N seconds (0 = one try)
:answers
powershell -NoProfile -Command "$t = [DateTime]::Now.AddSeconds(%1); do { try { $c = New-Object Net.Sockets.TcpClient; $c.Connect('127.0.0.1', %PORT%); $c.Close(); exit 0 } catch { Start-Sleep -Milliseconds 250 } } while ([DateTime]::Now -lt $t); exit 1"
exit /b %errorlevel%
