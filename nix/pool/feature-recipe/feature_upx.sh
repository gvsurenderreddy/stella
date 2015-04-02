if [ ! "$_UPX_INCLUDED_" == "1" ]; then 
_UPX_INCLUDED_=1

function feature_upx() {
	FEAT_NAME=upx
	FEAT_LIST_SCHEMA="3_91/source"
	FEAT_DEFAULT_VERSION=3_91
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}

function feature_upx_3_91() {
	FEAT_VERSION=3_91

	FEAT_SOURCE_URL=http://upx.sourceforge.net/download/upx-3.91-src.tar.bz2
	FEAT_SOURCE_URL_FILENAME=upx-3.91-src.tar.bz2
	FEAT_SOURCE_CALLBACK=feature_ucl_link
	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_CALLBACK=

	# TODO : mandatory dep on ucl
	FEAT_DEPENDENCIES=
	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/upx
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin
	FEAT_ENV=
	
	FEAT_BUNDLE_LIST=
}


function feature_ucl_link() {

	save_FEAT_SCHEMA_SELECTED=$FEAT_SCHEMA_SELECTED

	__feature_inspect ucl
	if [ "$TEST_FEATURE" == "0" ]; then
		echo " ** ERROR : depend on lib upx"
		return
	fi
	export UPX_UCLDIR="$FEAT_INSTALL_ROOT"
	ln -fs $FEAT_INSTALL_ROOT/lib/libucl.a $FEAT_INSTALL_ROOT/libucl.a

	FEAT_SCHEMA_SELECTED=$save_FEAT_SCHEMA_SELECTED
	__internal_feature_context $FEAT_SCHEMA_SELECTED

}

function feature_upx_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"
	BUILD_DIR=

	AUTO_INSTALL_FLAG_PREFIX=
	AUTO_INSTALL_FLAG_POSTFIX=


	__download_uncompress "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_FILENAME" "$SRC_DIR" "DEST_ERASE STRIP"

	__feature_apply_source_callback

	# can not build doc
	sed -i".old" '/-C doc/d' "$SRC_DIR/Makefile"

	cd "$SRC_DIR"
	make all

	if [ -f "$SRC_DIR/src/upx.out" ]; then
		mkdir -p "$INSTALL_DIR/bin"
		cp "$SRC_DIR/src/upx.out" "$INSTALL_DIR/bin/upx"
		__del_folder "$SRC_DIR"
	fi

}



fi