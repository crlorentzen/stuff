# Sysmon Monitoring

## Scheduled Task Script to install/update config
Updated from https://zacbergart.blogspot.com/2018/06/sysmon-install-and-config.html
Get Sysmon https://live.sysinternals.com/Sysmon.exe
```
@echo off
REM Sysmon can be downloaded here:
REM https://docs.microsoft.com/en-gb/sysinternals/downloads/sysmon
REM
REM A generic config can be downloaded here:
REM https://github.com/SwiftOnSecurity/sysmon-config
REM
REM A more expansive config can be downloaded here:
REM https://github.com/olafhartong/sysmon-modular/blob/master/sysmonconfig.xml
cls

Set SysmonSourceFiles=\\Server\Shared Folder\FolderPath\Sysmon
Set SysmonSourceFiles=.
Set SysmonConfigFile=sysmon_config.xml

Echo Copying network Sysmon config file
copy /z /y "%SysmonSourceFiles%\%SysmonConfigFile%" %SystemRoot%

If Exist %SystemRoot%\%SysmonConfigFile% (goto chkprocess)

ECHO Error in copying the Sysmon config to: %SystemRoot%\%SysmonConfigFile%
GOTO exitscript

REM un-remark the following command if you wish to have the script install a
REM new Sysmon.exe executable as the Sysmon service; this will force this script
REM to use the network source Sysmon.exe and thereby use the new executable
REM
REM Sysmon -u


:chkprocess
ECHO Checking Sysmon process
sc query "Sysmon" >nul
IF %ERRORLEVEL% EQU 0 (goto isitrunning)

:installsysmon
ECHO Trying to install Sysmon
"%SysmonSourceFiles%\Sysmon.exe" /accepteula -i %SystemRoot%\%SysmonConfigFile%


:isitrunning
ECHO Checking Sysmon process run state
sc query "Sysmon" | Find /i "Running" >nul
IF %ERRORLEVEL% EQU 0 (GOTO updateconfig)

:startsysmon
net start Sysmon

:updateconfig
ECHO.
ECHO Trying to update Sysmon config
sysmon -c %SystemRoot%\%SysmonConfigFile%

:exitscript
```
