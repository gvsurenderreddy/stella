if [ ! "$_vagrant_INCLUDED_" == "1" ]; then
_vagrant_INCLUDED_=1

# for linux, the downloaded .deb file contains compiled libraries but these libraries may not work on some linux distro
# https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/tools/vagrant/default.nix

function feature_vagrant() {
	FEAT_NAME=vagrant
	FEAT_LIST_SCHEMA="1_8_4@x64:binary 1_8_4@x86:binary"
	FEAT_DEFAULT_VERSION=1_8_4
	FEAT_DEFAULT_ARCH=x64
	FEAT_DEFAULT_FLAVOUR="binary"
}


function feature_vagrant_1_8_4() {
	FEAT_VERSION=1_8_4
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		FEAT_BINARY_URL_x86=https://releases.hashicorp.com/vagrant/1.8.4/vagrant_1.8.4_i686.deb
		FEAT_BINARY_URL_FILENAME_x86=vagrant_1.8.4_i686.deb
		FEAT_BINARY_URL_PROTOCOL_x86=HTTP
		FEAT_BINARY_URL_x64=https://releases.hashicorp.com/vagrant/1.8.4/vagrant_1.8.4_x86_64.deb
		FEAT_BINARY_URL_FILENAME_x64=vagrant_1.8.4_x86_64.deb
		FEAT_BINARY_URL_PROTOCOL_x64=HTTP

	fi
	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		FEAT_BINARY_URL_x86=https://releases.hashicorp.com/vagrant/1.8.4/vagrant_1.8.4.dmg
		FEAT_BINARY_URL_FILENAME_x86=vagrant_1.8.4.dmg
		FEAT_BINARY_URL_PROTOCOL_x86=HTTP
		FEAT_BINARY_URL_x64=https://releases.hashicorp.com/vagrant/1.8.4/vagrant_1.8.4.dmg
		FEAT_BINARY_URL_FILENAME_x64=vagrant_1.8.4.dmg
		FEAT_BINARY_URL_PROTOCOL_x64=HTTP
	fi

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=


	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/vagrant
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

}



function feature_vagrant_install_binary() {

	rm -Rf "$STELLA_APP_TEMP_DIR"
	mkdir -p "$STELLA_APP_TEMP_DIR"

	__get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "$STELLA_APP_TEMP_DIR"

	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		DMG_VOLUME_NAME="Vagrant"
		PKG_NAME="Vagrant.pkg"

		# mount dmg file and extract pkg file
		hdiutil mount "$STELLA_APP_TEMP_DIR/$FEAT_BINARY_URL_FILENAME"
		cp "/Volumes/$DMG_VOLUME_NAME/$PKG_NAME" "$STELLA_APP_TEMP_DIR/$PKG_NAME"
		hdiutil unmount "/Volumes/$DMG_VOLUME_NAME"

		# unzip pkg file
		pkgutil --expand "$STELLA_APP_TEMP_DIR/$PKG_NAME" "$STELLA_APP_TEMP_DIR/$DMG_VOLUME_NAME/"

		# extract files from payload
		cd "$FEAT_INSTALL_ROOT"
		for payload in "$STELLA_APP_TEMP_DIR"/$DMG_VOLUME_NAME/*; do
			[ -f "$payload/Payload" ] && tar xvzf "$payload/Payload"
		done

		__check_binary_file "$FEAT_INSTALL_ROOT"/bin
		__check_binary_file "$FEAT_INSTALL_ROOT"/embedded/lib "EXCLUDE_FILTER python*|ruby*"
	fi



	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then

		__uncompress "$FEAT_BINARY_URL_FILENAME" "$STELLA_APP_TEMP_DIR"

		__copy_folder_content_into "$STELLA_APP_TEMP_DIR/opt/vagrant" "$FEAT_INSTALL_ROOT"
		__copy_folder_content_into "$STELLA_APP_TEMP_DIR/usr/bin" "$FEAT_INSTALL_ROOT"

		sed -i".bak" "s,/opt/vagrant,$FEAT_INSTALL_ROOT," "$FEAT_INSTALL_ROOT"/vagrant

		#__tweak_binary_file "$FEAT_INSTALL_ROOT"/bin "FIX_LINKED_LIB $FEAT_INSTALL_ROOT/embedded/lib"
		__tweak_binary_file "$FEAT_INSTALL_ROOT"/embedded/bin "FIX_LINKED_LIB $FEAT_INSTALL_ROOT/embedded/lib"
		__tweak_binary_file "$FEAT_INSTALL_ROOT"/embedded/lib "FIX_LINKED_LIB $FEAT_INSTALL_ROOT/embedded/lib"
		__check_binary_file "$FEAT_INSTALL_ROOT"/bin
		__check_binary_file "$FEAT_INSTALL_ROOT"/embedded/lib "EXCLUDE_FILTER python*|ruby*"
	fi

	rm -Rf "$STELLA_APP_TEMP_DIR"
	mkdir -p "$STELLA_APP_TEMP_DIR"
}


fi
