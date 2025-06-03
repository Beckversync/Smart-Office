@ECHO OFF

setlocal ENABLEEXTENSIONS

@ECHO Upgrading trendz ...

SET BASE=%~dp0

:loop
IF NOT "%1"=="" (
    IF "%1"=="--fromVersion" (
        SET fromVersion=%2
    )
    SHIFT
    GOTO :loop
)

if not defined fromVersion (
    echo "--fromVersion parameter is invalid or unspecified!"
    echo "Usage: upgrade.bat --fromVersion {VERSION}"
    exit /b 1
)

SET LOADER_PATH=%BASE%\conf,%BASE%\extensions
SET jarfile=%BASE%\lib\trendz.jar
SET installDir=%BASE%\data

PUSHD "%BASE%\conf"

java -cp "%jarfile%" -Dloader.main=org.thingsboard.trendz.TrendzInstall^
                    -Dinstall.data_dir="%installDir%"^
                    -Dspring.jpa.hibernate.ddl-auto=none^
                    -Dinstall.upgrade=true^
                    -Dinstall.upgrade.from_version=%fromVersion%^
                    -Dlogging.config="%BASE%\install\logback.xml"^
                    org.springframework.boot.loader.launch.PropertiesLauncher

if errorlevel 1 (
   @echo Trendz upgrade failed!
   POPD
   exit /b %errorlevel%
)
POPD

@ECHO Trendz upgraded successfully!

GOTO END

:END
