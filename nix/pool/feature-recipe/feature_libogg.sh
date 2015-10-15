if [ ! "$_libogg_INCLUDED_" == "1" ]; then 
_libogg_INCLUDED_=1

# darwin -- OK -- 20151012

function feature_libogg() {
	FEAT_NAME=libogg
	# CMakeList.txt are not yet present in official release
	FEAT_LIST_SCHEMA="DEV20150926:source"
	FEAT_DEFAULT_VERSION=DEV20150926
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_libogg_DEV20150926() {
	FEAT_VERSION=DEV20150926


	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=https://github.com/xiph/ogg/archive/6c36ab3fce6ed9b465dfbc3790596238b6b11e17.zip
	FEAT_SOURCE_URL_FILENAME=libogg-dev-20150926.zip
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/include/ogg/ogg.h
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

}

function feature_libogg_link() {
	__link_feature_library "zlib#1_2_8" "FORCE_DYNAMIC LIBS_NAME z"
	#__link_feature_library "zlib#1_2_8" "FORCE_STATIC"
}


function feature_libogg_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"
	
	__set_toolset "CMAKE"
	
	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "FORCE_NAME $FEAT_SOURCE_URL_FILENAME STRIP"

	

	AUTO_INSTALL_CONF_FLAG_PREFIX=
	AUTO_INSTALL_CONF_FLAG_POSTFIX="-DBUILD_SHARED_LIBS=TRUE"
	AUTO_INSTALL_BUILD_FLAG_PREFIX=
	AUTO_INSTALL_BUILD_FLAG_POSTFIX=

	__feature_callback

	__auto_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR"
	

	

}


fi