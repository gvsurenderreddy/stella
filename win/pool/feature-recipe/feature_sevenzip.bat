@echo off
call %*
goto :eof

:list_sevenzip
	set "%~1=9_20"
goto :eof

:default_sevenzip
	set "%~1=9_20"
goto :eof

:install_sevenzip
	set "_VER=%~1"
	call :default_sevenzip "_DEFAULT_VER"

	if not exist %STELLA_APP_FEATURE_ROOT%\sevenzip mkdir %STELLA_APP_FEATURE_ROOT%\sevenzip
	if "%_VER%"=="" (
		call :install_sevenzip_!_DEFAULT_VER!
	) else (
		call :install_sevenzip_%_VER%
	)
goto :eof

:feature_sevenzip
	set "_VER=%~1"
	call :default_sevenzip "_DEFAULT_VER"

	if "%_VER%"=="" (
		call :feature_sevenzip_!_DEFAULT_VER!
	) else (
		call :feature_sevenzip_%_VER%
	)
goto :eof

:install_sevenzip_9_20
	set VERSION=9_20
	set INSTALL_DIR="%STELLA_APP_FEATURE_ROOT%\sevenzip\%VERSION%"
	
	echo ** Installing sevenzip version %VERSION% in %INSTALL_DIR%

	call :feature_sevenzip_9_20
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	)
	if "!TEST_FEATURE!"=="0" (

		call %STELLA_COMMON%\common.bat :copy_folder_content_into "%STELLA_POOL%\feature\sevenzip" "%INSTALL_DIR%"

		call :feature_sevenzip_9_20
		if not "!TEST_FEATURE!"=="0" (
			cd /D "!TEST_FEATURE!"
			echo sevenzip installed
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof

:feature_sevenzip_9_20
	set TEST_FEATURE=0
	set FEATURE_PATH=
	set FEATURE_VER=
	if exist "%STELLA_APP_FEATURE_ROOT%\sevenzip\9_20\7z.exe" (
		set "TEST_FEATURE=%STELLA_APP_FEATURE_ROOT%\sevenzip\9_20"
	)
	if not "!TEST_FEATURE!"=="0" (
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : sevenzip in !TEST_FEATURE!
		)
		set "FEATURE_PATH=!TEST_FEATURE!"
		set FEATURE_VER=9_20
	)
goto :eof