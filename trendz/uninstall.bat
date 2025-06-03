@ECHO OFF

@ECHO Stopping trendz ...
net stop trendz

@ECHO Uninstalling trendz ...
"%~dp0"trendz.exe uninstall

@ECHO DONE.