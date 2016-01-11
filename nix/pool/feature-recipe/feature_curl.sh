if [ ! "$_curl_INCLUDED_" == "1" ]; then 
_curl_INCLUDED_=1


function feature_curl() {
	FEAT_NAME=curl

	FEAT_LIST_SCHEMA="7_36_0:source"
	FEAT_DEFAULT_VERSION=7_36_0
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"


}

function feature_curl_7_36_0() {
	FEAT_VERSION=7_36_0


	FEAT_SOURCE_DEPENDENCIES="zlib#1_2_8 openssl#1_0_2d"
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=https://github.com/bagder/curl/archive/curl-7_36_0.tar.gz
	FEAT_SOURCE_URL_FILENAME=curl-7_36_0.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=feature_curl_link
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/curl
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

}


function feature_curl_link() {
	__link_feature_library "openssl#1_0_2d"
	__link_feature_library "zlib#1_2_8" "LIBS_NAME z"
}

function feature_curl_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"
	
	__set_toolset "CMAKE"

	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP"

	__feature_callback

	AUTO_INSTALL_CONF_FLAG_PREFIX=
	AUTO_INSTALL_CONF_FLAG_POSTFIX="-DCURL_STATICLIB=ON -DBUILD_CURL_TESTS=OFF -DENABLE_IPV6=ON"
	AUTO_INSTALL_BUILD_FLAG_PREFIX=
	AUTO_INSTALL_BUILD_FLAG_POSTFIX=

	__auto_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR" "SOURCE_KEEP"

	# shared lib build
	AUTO_INSTALL_CONF_FLAG_POSTFIX="-DCURL_STATICLIB=OFF -DBUILD_CURL_TESTS=OFF -DENABLE_IPV6=ON"
	
	__auto_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR"

	

}


fi