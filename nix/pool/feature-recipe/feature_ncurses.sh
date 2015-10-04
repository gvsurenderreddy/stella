if [ ! "$_NCURSES_INCLUDED_" == "1" ]; then 
_NCURSES_INCLUDED_=1


function feature_ncurses() {
	FEAT_NAME=ncurses
	FEAT_LIST_SCHEMA="6_0:source"
	FEAT_DEFAULT_VERSION=6_0
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_ncurses_6_0() {
	FEAT_VERSION=6_0


	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=http://ftp.gnu.org/gnu/ncurses/ncurses-6.0.tar.gz
	FEAT_SOURCE_URL_FILENAME=ncurses-6.0.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/lib/libncursesw.a
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

}



function feature_ncurses_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"
	
	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE STRIP"


	AUTO_INSTALL_CONF_FLAG_PREFIX=
	AUTO_INSTALL_CONF_FLAG_POSTFIX="
			--disable-dependency-tracking \
			--with-shared           \
            --without-debug         \
            --enable-pc-files       \
            --enable-widec" # wide encoding
	AUTO_INSTALL_BUILD_FLAG_PREFIX=
	AUTO_INSTALL_BUILD_FLAG_POSTFIX=

	__auto_build "$FEAT_NAME" "$SRC_DIR" "$INSTALL_DIR" "CONFIG_TOOL configure"
	

	

}


fi