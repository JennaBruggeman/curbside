@echo off
rem Curbside: stop the server on port 8766 (the PowerShell process running serve.ps1 -Port 8766)
rem and nothing else. The port itself is held by http.sys (PID 4), so the process is found by its
rem command line, not by the port's owner; a serve.ps1 on any other port is not touched.
setlocal
powershell -NoProfile -Command "$p = @(Get-CimInstance Win32_Process | Where-Object { ('powershell.exe', 'pwsh.exe') -contains $_.Name -and $_.ProcessId -ne $PID -and $_.CommandLine -match 'serve\.ps1' -and $_.CommandLine -match '-Port\s+8766(\s|$)' }); if (-not $p.Count) { 'No Curbside server on port 8766 is running.'; exit 1 }; $p | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }; 'Stopped the Curbside server on port 8766 (process ' + (($p | ForEach-Object { $_.ProcessId }) -join ', ') + ').'"
timeout /t 5 >nul 2>nul
