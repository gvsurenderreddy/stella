if [ ! "$_LIBTOOL_INCLUDED_" == "1" ]; then
_LIBTOOL_INCLUDED_=1


function feature_libtool() {
	FEAT_NAME=libtool
	FEAT_LIST_SCHEMA="2_4_2:source"
	FEAT_DEFAULT_VERSION=2_4_2
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_libtool_2_4_2() {
	FEAT_VERSION=2_4_2

	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=http://ftp.gnu.org/gnu/libtool/libtool-2.4.2.tar.gz
	FEAT_SOURCE_URL_FILENAME=libtool-2.4.2.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/libtool
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

}


function feature_libtool_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"


	__set_toolset "STANDARD"

	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP"



	AUTO_INSTALL_CONF_FLAG_PREFIX=
	AUTO_INSTALL_CONF_FLAG_POSTFIX=
	AUTO_INSTALL_BUILD_FLAG_PREFIX=
	AUTO_INSTALL_BUILD_FLAG_POSTFIX=

	__auto_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR"

	# some scripts call libtoolize as glibtoolize
 	ln -s "$FEAT_INSTALL_ROOT"/bin/libtoolize "$FEAT_INSTALL_ROOT"/bin/glibtoolize
}

fi
