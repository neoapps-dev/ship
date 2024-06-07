@echo off & setlocal enableDelayedExpansion
set version=0.1
call lib\sound
call lib\util

for /f %%a in ('copy /Z "%~dpf0" nul') do set "CR=%%a"

:main
if /i "%~n0" == "ship" (
    goto :correct
) else (
    goto :wrong
)

:version
gecho.dll "<dgn>ship <white>v%version%"
gecho.dll "(C) 2024 <dgn>Asd22 Entertainment"
goto :EOF

:correct
if /i "%1" == "--help" (
    goto :help
)
if /i "%1" == "--version" (
    goto :version
)
if /i "%1" == "-i" (
    call :Download %2 "%2.zip"
    goto :EOF
)
if /i "%1" == "-s" (
    call :Search %2
    goto :EOF
)
if /i "%1" == "-u" (
    call :delete %2
    goto :EOF
)
if /i "%1" == "--all" (
    call :All
    goto :EOF
)
if /i "%1" == "--create" (
    call :newproj %2 %3
    goto :EOF
)
if /i "%1" == "--installed" (
    call :installed
    goto :EOF
)
if /i "%1" == "--open" (
    call :openproj %2 %3
    goto :EOF
)
if /i "%1" == "--projects" (
    if /i "%2" == "" (
    gecho.dll "<r>No Project Type selected, selecting batch..."
    call :projects batch
    goto :EOF
    )
    call :projects %2
    goto :EOF
)
gecho.dll "<white>Invalid syntax, use <dgn>ship --help <white>for help" && goto :EOF

:wrong
gecho.dll "<r>ERROR: <white>Modified Version of 'ship' is installed!"
goto :EOF

:help
gecho.dll "<dgn>ship <white>v!version!"
gecho.dll "Welcome to <dgn>ship!"
echo.
gecho.dll "Basic Commands:"
echo.
gecho.dll "<dgn>ship --help    <white>displays help page."
gecho.dll "<dgn>ship --version  <white>displays <dgn>ship<white>'s version."
gecho.dll "<dgn>ship --all      <white>displays all the packages."
gecho.dll "<dgn>ship -s PACKAGE <white>searches for PACKAGE. remember to replace it with the actual package"
gecho.dll "<dgn>ship -i PACKAGE  <white>installs PACKAGE."
gecho.dll "<dgn>ship -u PACKAGE  <white>uninstalls PACKAGE."
gecho.dll "<dgn>ship --create [batch|powershell] [Name]    <white>Makes a project in Batch or Powershell with name"
gecho.dll "<dgn>ship --installed                             <white>displays all installed packages."
gecho.dll "<dgn>ship --open [batch|powershell] [Name]      <white>Opens [Name] in explorer."
gecho.dll "<dgn>ship --projects [batch|powershell]            <white>Shows projects with type Batch or PowerShell"
goto :EOF

:Download
gecho.dll "<g>Downloading package '%~1'"
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -command "(New-Object System.Net.WebClient).DownloadFile('https://shipapi.vercel.app/v1/%~1.zip','%~2')" >nul
if %ERRORLEVEL% == 0 (
    gecho.dll "<green>Package Downloaded Successfully!"
    gecho.dll "<g>Extracting Package..."
    powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Path %~1.zip -DestinationPath '%USERPROFILE%\.ship\packages\'" >nul
    if %ERRORLEVEL% == 0 (
        rm %~1.zip
        gecho.dll "<green>Package Installed and Ready to use!"
    ) else (
        rm %~1.zip
        gecho.dll "<r>Error Extracting Package."
        gecho.dll "<r>Error code: %ERRORLEVEL%"
    )
) else (
    gecho.dll "<r>Package '%~1' not found!"
    %@playSound% "lib\sfx\cancel.wav"
)
goto :eof

:Search
gecho.dll "<g>Searching for package '%~1'"
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri https://shipapi.vercel.app/api/search?q=%~1 -OutFile ship.tmp" >nul

set "packages="
setlocal EnableDelayedExpansion
for /f "usebackq tokens=*" %%a in (`powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Get-Content ship.tmp | ConvertFrom-Json | ForEach-Object { $_ }"`) do (
    set "line=%%~a"
    if defined packages (
        set "packages=!packages!, %%~a"
    ) else (
        set "packages=%%~a"
    )
)

del ship.tmp

if "%packages%" == "" (
    gecho.dll "<red>No Package Found!"
) else (
    gecho.dll "<green>Package(s) Found:"
    setlocal enabledelayedexpansion
    set count=0
    for %%p in (!packages!) do (
        set /a count+=1
        echo !count!. %%p
    )
    gecho.dll "<white>( <dgn>!count! <white>Package(s) )"
    endlocal
)
goto :EOF

:All
gecho.dll "<g>Updating Database..."
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri https://shipapi.vercel.app/api/pkgs -OutFile ship.tmp" >nul

set "packages="
setlocal EnableDelayedExpansion
for /f "usebackq tokens=*" %%a in (`powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Get-Content ship.tmp | ConvertFrom-Json | ForEach-Object { $_ }"`) do (
    set "line=%%~a"
    if defined packages (
        set "packages=!packages!, %%~a"
    ) else (
        set "packages=%%~a"
    )
)

del ship.tmp

if "%packages%" == "" (
    gecho.dll "<red>No Package Found!"
) else (
    gecho.dll "<green>Package(s) Found:"
    set count=0
    for %%p in (!packages!) do (
        set /a count+=1
        echo !count!. %%p
    )
    gecho.dll "<white>( <dgn>!count! <white>Package(s) )"
    endlocal
)
goto :EOF


:del
del %USERPROFILE%\.ship\packages\%~1
if /i "%ERRORLEVEL%" == "0" (
    gecho.dll "<green>Package uninstalled successfully!!"
    rmdir %USERPROFILE%\.ship\packages\%~1
) else (
    gecho.dll "<red>Package uninstallation cancelled!!"
)
goto :EOF

:newproj
if not defined %~1 (
if not defined %~2 (
gecho.dll "<white>Making Project <dgn>%~2 <white>in langauge <dgn>%~1<white>..."
%SystemRoot%\System32\timeout.exe 2>nul
if not exist "%USERPROFILE%\.ship\projects\%~1\%~2" (
    mkdir "%USERPROFILE%\.ship\projects\%~1\%~2" >nul 2>&1
    if %errorlevel% equ 0 (
        gecho.dll "<green>Project Created Successfully"
    ) else (
        gecho.dll "<r>Failed to create project."
    )
) else (
    gecho.dll "<r>Project Already Exist!!"
    goto :EOF
)
if /i "%~1" == "batch" (
type lib\default-template.bat >%USERPROFILE%\.ship\projects\%~1\%~2\main.bat
echo Made with 'ship' >%USERPROFILE%\.ship\projects\%~1\%~2\.ship
) else (
type lib\default-template.ps1 >%USERPROFILE%\.ship\projects\%~1\%~2\main.ps1
echo Made with 'ship' >%USERPROFILE%\.ship\projects\%~1\%~2\.ship
)
gecho.dll "<green>Project has been made successfully!!"
) else (
gecho.dll "<red>Invalid Syntax, check <dgn>ship --help<white>."
goto :EOF
)
) else (
gecho.dll "<red>Invalid Syntax, check <dgn>ship --help<white>."
goto :EOF
)

:installed
gecho.dll "<g>Please wait..."
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -Path '%USERPROFILE%\.ship\packages\' -Directory | Select-Object -ExpandProperty Name | Out-File -FilePath ship.tmp" >nul

set "packages="
setlocal EnableDelayedExpansion
for /f "usebackq tokens=*" %%a in (`type ship.tmp`) do (
    set "line=%%~a"
    if defined packages (
        set "packages=!packages!, %%~a"
    ) else (
        set "packages=%%~a"
    )
)

del ship.tmp

if "%packages%" == "" (
    gecho.dll "<red>No Package Installed!"
) else (
    gecho.dll "<green>Package(s) Installed:"
    set count=0
    for %%p in (!packages!) do (
        set /a count+=1
        echo !count!. %%p
    )
    gecho.dll "<white>( <dgn>!count! <white>Package(s) )"
    endlocal
)
goto :EOF

:openproj
if exist %USERPROFILE%\.ship\projects\%~1\%~2 (
explorer %USERPROFILE%\.ship\projects\%~1\%~2
gecho.dll "<green>Project opened in Explorer"
goto :EOF
) else (
gecho.dll "<r>Project isn't found!!"
)
goto :EOF

:projects
gecho.dll "<g>Please wait..."
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -Path '%USERPROFILE%\.ship\projects\%~1' -Directory | Select-Object -ExpandProperty Name | Out-File -FilePath ship.tmp" >nul

set "packages="
setlocal EnableDelayedExpansion
for /f "usebackq tokens=*" %%a in (`type ship.tmp`) do (
    set "line=%%~a"
    if defined packages (
        set "packages=!packages!, %%~a"
    ) else (
        set "packages=%%~a"
    )
)

del ship.tmp

if "%packages%" == "" (
    gecho.dll "<red>No Project Created, try ship --create %~1 project-name"
) else (
    gecho.dll "<green>Projects Located:"
    set count=0
    for %%p in (!packages!) do (
        set /a count+=1
        echo !count!. %%p
    )
    gecho.dll "<white>( <dgn>!count! <white>Project )"
    endlocal
)
goto :EOF
