@echo off
call %*
goto :eof

REM TODO update this version to INTERNAL version (see wget recipe)

:feature_unzip
	set "FEAT_NAME=unzip"
	set "FEAT_LIST_SCHEMA=5_51_1:binary"
	set "FEAT_DEFAULT_VERSION=5_51_1"
	set "FEAT_DEFAULT_ARCH="
	set "FEAT_DEFAULT_FLAVOUR=binary"
goto :eof


:feature_unzip_5_51_1
	set "FEAT_VERSION=5_51_1"

	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set FEAT_SOURCE_URL=
	set FEAT_SOURCE_URL_FILENAME=
	set FEAT_SOURCE_URL_PROTOCOL=

	set FEAT_BINARY_URL=
	set FEAT_BINARY_URL_FILENAME=
	set FEAT_BINARY_URL_PROTOCOL=

	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=feature_unzip_5_51_1_patch
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\unzip.exe"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!\bin"

goto :eof


:feature_unzip_5_51_1_patch
	call %STELLA_COMMON%\common.bat :copy_folder_content_into "%STELLA_ARTEFACT%\unzip-5.51-1-bin" "%INSTALL_DIR%"
goto :eof

:feature_unzip_install_binary
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set SRC_DIR=
	set BUILD_DIR=

	call %STELLA_COMMON%\common-feature.bat :feature_callback

goto :eof
