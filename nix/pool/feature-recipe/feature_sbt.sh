if [ ! "$_SBT_INCLUDED_" == "1" ]; then 
_SBT_INCLUDED_=1



function feature_sbt() {
	FEAT_NAME=sbt
	FEAT_LIST_SCHEMA="0_13_7:binary"
	FEAT_DEFAULT_VERSION=0_13_7
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="binary"
}

function feature_sbt_0_13_7() {
	FEAT_VERSION=0_13_7
	# need jvm
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	FEAT_BINARY_URL=https://dl.bintray.com/sbt/native-packages/sbt/0.13.7/sbt-0.13.7.tgz
	FEAT_BINARY_URL_FILENAME=sbt-0.13.7.tgz
	FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP
	
	
	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/sbt
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin
}


function feature_sbt_install_binary() {

	__get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "STRIP"
}


fi
