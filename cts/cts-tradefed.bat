@echo off

title cts test

set log=log.txt

if exist %log% (
    del %log%
)

set "CTS_ROOT="

call:checkPath aapt
call:checkPath adb
:: call:checkPath java
:: call:logd checkjava

call:logd check java version
for /f %%a in ('java -version 2^>^&1 ^| findstr "1\.[678]"') do (
    set JAVA_VERSION=%%a
)

if "%JAVA_VERSION%" equ "" (
    call:logd "%JAVA_VERSION% is not 1.6, 1.7 or 1.8"
    goto:end
)

call:logd check debug flag and set up remote debugging
if "%TF_DEBUG%" neq "" (
    if "%TF_DEBUG_PORT%" equ "" (
        set /A TF_DEBUG_PORT=10088
    )
    set RDBG_FLAG="-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=%TF_DEBUG_PORT%"
    call:logd TF_DEBUG=%TF_DEBUG% TF_DEBUG_PORT=%TF_DEBUG_PORT% RDBG_FLAG=%RDBG_FLAG%
 )

call:logd get OS
if "%OS%" equ "Windows_NT" (
    call:logd OS=%OS%
)

call:logd check if in Android build env
if "%ANDROID_BUILD_TOP%" neq "" (
    if "%ANDROID_HOST_OUT%" neq "" (
        set CTS_ROOT="%ANDROID_HOST_OUT%\cts"
    ) else (
        set CTS_ROOT="%ANDROID_BUILD_TOP%%OUT_DIR%\host\%OS%\cts"
    )
    if not exist "%CTS_ROOT%" (
        call:logd "Could not find $CTS_ROOT in Android build environment. Try 'make cts'"
        exit
    )
    call:logd CTS_ROOT=%CTS_ROOT%
)

if "%CTS_ROOT%" equ "" (
    call:logd "assume we're in an extracted cts install"
    set "CTS_ROOT=%CD%\..\.."
)
call:logd CTS_ROOT=%CTS_ROOT%

set "JAR_DIR=%CTS_ROOT%\android-cts\tools"
call:logd JAR_DIR=%JAR_DIR%
set "JARS1=tradefed hosttestlib compatibility-host-util loganalysis"
set "JARS2=compatibility-host-util-tests cts-tradefed cts-tradefed-tests hosttestlib"
set "JARS3=compatibility-common-util-tests compatibility-tradefed-tests host-libprotobuf-java-full"
set "JARS=%JARS1% %JARS2% %JARS3%"
call:logd JARS=%JARS%

set JARS_tmp=%JARS%
set "JAR_PATH="
:JARS_CHECK_BEGIN
::echo JARS_tmp=%JARS_tmp%
for /f "tokens=1,* delims= " %%a in ("%JARS_tmp%") do (
::  echo %%a
    if "%%a" neq "" (
        call:checkFile %JAR_DIR%\%%a.jar
        set "JAR_PATH=%JAR_PATH%;%JAR_DIR%\%%a.jar"
        set JARS_tmp=%%b
        goto:JARS_CHECK_BEGIN
    ) else (
        goto:JARS_CHECK_END
    )
)
:JARS_CHECK_END
set JAR_PATH=%JAR_PATH:~1%
call:logd JAR_PATH=%JAR_PATH%

set "OPTIONAL_JARS=google-tradefed google-tradefed-tests google-tf-prod-tests"
call:logd OPTIONAL_JARS=%OPTIONAL_JARS%

set "OPTIONAL_JARS_tmp=%OPTIONAL_JARS%"
:OPTIONAL_JARS_BEGIN
for /f "tokens=1,* delims= " %%a in ("%OPTIONAL_JARS_tmp%") do (
    if "%%a" neq "" (
        if exist "%JAR_DIR\%%a.jar%" (
            set "JAR_PATH=%JAR_PATH%;%JAR_DIR%\%%a.jar"
        )
        set OPTIONAL_JARS_tmp=%%b
        goto:OPTIONAL_JARS_BEGIN
    ) else (
        goto:OPTIONAL_JARS_END
    )
)
:OPTIONAL_JARS_END
call:logd OPTIONAL_JARS JAR_PATH=%JAR_PATH%


call:logd load any shared libraries for host-side executables
set LIB_DIR=%CTS_ROOT%\android-cts\lib
call:logd LIB_DIR=%LIB_DIR%
rem if "%OS%" equ "Windows_NT" (
rem     set PATH=%LIB_DIR%:%LIB_DIR%64:%PATH%
rem )
rem call:logd PATH=%PATH%

@setlocal enabledelayedexpansion
call:logd include any host-side test jars
set "JAR_TESTCASES="
set TESTCASE_PATH=E:\CTS\android-cts
for /R "%CTS_ROOT%\android-cts\testcases" %%a in (*.jar) do (
::  input line is too long ... use relative path replace absolute path
	set TEMP=%%a
	set FILE=!TEMP:%TESTCASE_PATH%=..!
	set "JAR_TESTCASES=!FILE!;!JAR_TESTCASES!"
	call:logd JARS=!FILE!
)
call:logd JAR_TESTCASES=%JAR_TESTCASES%
set JAR_PATH=%JAR_PATH%;%JAR_TESTCASES%
call:logd android-cts JAR_PATH=%JAR_PATH%

rem pause

call:logd java %RDBG_FLAG% -Xmx4g -XX:+HeapDumpOnOutOfMemoryError -cp %JAR_PATH% -DCTS_ROOT=%CTS_ROOT% com.android.compatibility.common.tradefed.command.CompatibilityConsole "%*"
call java %RDBG_FLAG% -Xmx4g -XX:+HeapDumpOnOutOfMemoryError -cp %JAR_PATH% -DCTS_ROOT=%CTS_ROOT% com.android.compatibility.common.tradefed.command.CompatibilityConsole "%*"


goto end

:logd
rem echo %*
echo %* >>%log%
goto:eof

:checkFile
if not exist "%~1"  (
    call:logd not exist %~1
    exit
) else (
    call:logd exist %~1
)
goto:eof

:checkPath
for /f "delims=" %%a in ('where %~1') do (
    set _cmd=%%a
)

if not exist "%_cmd%"  (
    call:logd not exist %_cmd%
    exit
) else (
    call:logd exist %_cmd%
)
goto:eof

:printEnter
rem echo %1 %2 %3
set /p num=<%2
rem echo num1=%num%
set /a num=%num% + 1
rem echo num2=%num%
set /a tmp=%num% %% %3
rem echo tmp=%tmp%
if "%tmp%" equ "0" (
    echo.>>%1
) 
echo %num% > %2
goto:eof

:getJars
rem echo %*
for /f "tokens=1,2,3,4 delims= " %%a in ("%*") do (
    set getJars_jar=%%a
    set getJars_jar_temp_file=%%b
    set getJars_file_name=%%c
    set getJars_jar_name_file=%%d
)
::echo getJars_jar=%getJars_jar%
::echo getJars_jar_temp_file=%getJars_jar_temp_file%
::echo getJars_file_name=%getJars_file_name%
::echo getJars_jar_name_file=%getJars_jar_name_file%
::set /p num=<%getJars_jar_temp_file%
::set /a num=%num% + 1
::set "%getJars_file_name%%num%=%getJars_jar%"
::echo %JAR_PATH_TMP1%
::echo %num% > %getJars_jar_temp_file%
::echo "set %getJars_file_name%%num%"
::echo %getJars_file_name%%num% >> %getJars_jar_name_file%
::>> %getJars_jar_name_file% set /p="%%" <nul
::>> %getJars_jar_name_file% set /p="%getJars_file_name%%num%" <nul
::>> %getJars_jar_name_file% set /p="%%" <nul
::echo. >> %getJars_jar_name_file%
goto:end

:end
