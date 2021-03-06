if [ ! "$_GOBUILD_INCLUDED_" == "1" ]; then 
_GOBUILD_INCLUDED_=1




function feature_go-build-chain() {
	FEAT_NAME="go-build-chain"
	FEAT_LIST_SCHEMA="1_4_3 1_5_3"
	FEAT_DEFAULT_VERSION=1_5_3
	FEAT_DEFAULT_ARCH=

	FEAT_BUNDLE=NESTED
}

function feature_go-build-chain_1_5_3() {
	FEAT_VERSION=1_5_3
	
	# need gcc
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_BUNDLE_ITEM="go#1_5_3:binary"

	FEAT_ENV_CALLBACK=feature_go_buildchain_setenv
	FEAT_BUNDLE_CALLBACK="feature_go_buildchain_setenv feature_go_prepare_buildchain"

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT/_WORKSPACE_/bin/godep"
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT/_WORKSPACE_/bin"

	BUILDCHAIN_GO_VERSION="1.5.3"
}


function feature_go-build-chain_1_4_3() {
	FEAT_VERSION=1_4_3
	
	# need gcc
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_BUNDLE_ITEM="go#1_4_3:binary"

	FEAT_ENV_CALLBACK=feature_go_buildchain_setenv
	FEAT_BUNDLE_CALLBACK="feature_go_buildchain_setenv feature_go_prepare_buildchain"

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT/_WORKSPACE_/bin/godep"
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT/_WORKSPACE_/bin"

	BUILDCHAIN_GO_VERSION="1.4.3"
}

function feature_go_buildchain_setenv() {
	GOPATH="$FEAT_INSTALL_ROOT/_WORKSPACE_"
	GOROOT="$FEAT_INSTALL_ROOT/go"

	echo " ** GOLANG build environment"
	echo " GOROOT = $GOROOT"
	echo " GOPATH = $GOPATH"
	echo "   ** To restore your dependencies from folder containing Godeps :"
	echo "      godep restore"
}

function feature_go_prepare_buildchain() {
	PATH="$FEAT_SEARCH_PATH:$PATH"


	echo "** install godep"
	go get github.com/tools/godep
	
}

fi