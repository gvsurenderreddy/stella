@echo off
call %*
goto :eof

:list_vagrant
	set "%~1=git"
goto :eof

:install_vagrant
	set "_VER=%~1"
	set "_DEFAULT_VER=git"

	if not exist %STELLA_APP_FEATURE_ROOT%\vagrant mkdir %STELLA_APP_FEATURE_ROOT%\vagrant
	if "%_VER%"=="" (
		call :install_vagrant_%_DEFAULT_VER%
	) else (
		call :install_vagrant_%_VER%
	)
goto :eof

:feature_vagrant
	set "_VER=%~1"
	set "_DEFAULT_VER=git"

	if "%_VER%"=="" (
		call :feature_vagrant_%_DEFAULT_VER%
	) else (
		call :feature_vagrant_%_VER%
	)
goto :eof



:install_vagrant_git
	set URL=https://github.com/mitchellh/vagrant.git
	set VERSION=git
	set "INSTALL_DIR=%STELLA_APP_FEATURE_ROOT%\vagrant\%VERSION%"

	echo ** Installing vagrant version %VERSION% in %INSTALL_DIR%
	echo ** This version from git need RUBY 2.0 !!

	call :feature_vagrant_git
	if "%FORCE%"=="1" ( 
		set TEST_FEATURE=0
		call %STELLA_COMMON%\common.bat :del_folder "%INSTALL_DIR%"
	)
	if "!TEST_FEATURE!"=="0" (
		git clone https://github.com/mitchellh/vagrant.git "%INSTALL_DIR%"

		REM TODO
		REM call %STELLA_COMMON%\common.bat :init_features "feature_ruby2 feature_rdevkit2"
		
		cd /D "%INSTALL_DIR%"
		bundle install
		
		call :feature_vagrant_git
		if not "!TEST_FEATURE!"=="0" (
			cd /D "!TEST_FEATURE!"
			echo Vagrant installed
			bundle exec vagrant -v
		) else (
			echo ** ERROR
		)
	) else (
		echo ** Already installed
	)
goto :eof

:feature_vagrant_git
	set TEST_FEATURE=0
	set FEATURE_PATH=
	set FEATURE_VER=
	if exist "%STELLA_APP_FEATURE_ROOT%\vagrant\git\bin\vagrant" (
		set "TEST_FEATURE=%STELLA_APP_FEATURE_ROOT%\vagrant\git"
	)
	if not "!TEST_FEATURE!"=="0" (
		if %VERBOSE_MODE% GTR 0 (
			echo ** EXTRA FEATURE Detected : vagrant unstable from git in !TEST_FEATURE!
		)
		set "VAGRANT_CMD=call %STELLA_FEATURE_RECIPE%\feature_vagrant.bat :_call_vagrant_from_git"
		REM set "VAGRANT_CMD=set BUNDLE_GEMFILE!TEST_FEATURE!\Gemfile && bundle exec vagrant"
		REM set "VAGRANT_CMD=ruby -C!TEST_FEATURE! bin\%VAGRANT_CMD%"
		set "FEATURE_PATH=!TEST_FEATURE!"
		set FEATURE_VER=git
	)
goto :eof

:_call_vagrant_from_git
	call :feature_vagrant_git
	set "BUNDLE_GEMFILE=!TEST_FEATURE!\Gemfile"
	call bundle exec vagrant %*
	set BUNDLE_GEMFILE=
goto :eof


