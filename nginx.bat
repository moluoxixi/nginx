@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

set NGINX_PATH=%~dp0
set NGINX_EXE=%NGINX_PATH%nginx.exe

if not exist "%NGINX_EXE%" (
    echo [错误] 未找到 nginx.exe，请确认脚本位置正确！
    timeout /t 2 >nul
    exit /b 1
)

:menu
cls
echo.
echo ========================================
echo          Nginx 服务管理脚本
echo ========================================
echo.
echo   1. 启动 Nginx
echo   2. 停止 Nginx
echo   3. 重启 Nginx
echo   4. 重载 Nginx
echo.
set /p choice=请选择操作 (1-4): 

if "%choice%"=="1" goto start
if "%choice%"=="2" goto stop
if "%choice%"=="3" goto restart
if "%choice%"=="4" goto reload

echo [错误] 无效选择，请重新运行脚本！
timeout /t 2 >nul
goto menu

:test_config
echo [测试] 正在测试配置文件...
cd /d "%NGINX_PATH%"
"%NGINX_EXE%" -t
if errorlevel 1 (
    echo.
    echo [错误] 配置文件测试失败，请检查配置！
    timeout /t 2 >nul
    goto menu
)
echo [成功] 配置文件测试通过！
echo.
goto :eof

:start
call :test_config
echo [信息] 正在启动 Nginx...
tasklist /FI "IMAGENAME eq nginx.exe" 2>NUL | find /I /N "nginx.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [警告] Nginx 已经在运行中！
    timeout /t 1 >nul
    goto menu
)
cd /d "%NGINX_PATH%"
start /B "" "%NGINX_EXE%"
timeout /t 1 /nobreak >nul
tasklist /FI "IMAGENAME eq nginx.exe" 2>NUL | find /I /N "nginx.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [成功] Nginx 启动成功！
) else (
    echo [失败] Nginx 启动失败！
)
timeout /t 1 >nul
goto menu

:stop
echo [信息] 正在停止 Nginx...
tasklist /FI "IMAGENAME eq nginx.exe" 2>NUL | find /I /N "nginx.exe">NUL
if not "%ERRORLEVEL%"=="0" (
    echo [警告] Nginx 未在运行！
    timeout /t 1 >nul
    goto menu
)
cd /d "%NGINX_PATH%"
"%NGINX_EXE%" -s stop
timeout /t 1 /nobreak >nul
tasklist /FI "IMAGENAME eq nginx.exe" 2>NUL | find /I /N "nginx.exe">NUL
if not "%ERRORLEVEL%"=="0" (
    echo [成功] Nginx 已停止！
) else (
    echo [警告] 尝试强制结束进程...
    taskkill /F /IM nginx.exe >nul 2>&1
    timeout /t 1 /nobreak >nul
    echo [成功] Nginx 已强制停止！
)
timeout /t 1 >nul
goto menu

:restart
call :test_config
echo [信息] 正在重启 Nginx...
tasklist /FI "IMAGENAME eq nginx.exe" 2>NUL | find /I /N "nginx.exe">NUL
if "%ERRORLEVEL%"=="0" (
    cd /d "%NGINX_PATH%"
    "%NGINX_EXE%" -s stop
    timeout /t 1 /nobreak >nul
)
cd /d "%NGINX_PATH%"
start /B "" "%NGINX_EXE%"
timeout /t 1 /nobreak >nul
tasklist /FI "IMAGENAME eq nginx.exe" 2>NUL | find /I /N "nginx.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [成功] Nginx 重启成功！
) else (
    echo [失败] Nginx 重启失败！
)
timeout /t 1 >nul
goto menu

:reload
call :test_config
echo [信息] 正在重新加载配置...
tasklist /FI "IMAGENAME eq nginx.exe" 2>NUL | find /I /N "nginx.exe">NUL
if not "%ERRORLEVEL%"=="0" (
    echo [警告] Nginx 未在运行，将启动 Nginx...
    cd /d "%NGINX_PATH%"
    start /B "" "%NGINX_EXE%"
    timeout /t 1 /nobreak >nul
    echo [成功] Nginx 已启动！
) else (
    cd /d "%NGINX_PATH%"
    "%NGINX_EXE%" -s reload
    if errorlevel 1 (
        echo [失败] 重新加载配置失败！
    ) else (
        echo [成功] Nginx 配置已重新加载！
    )
)
timeout /t 1 >nul
goto menu
