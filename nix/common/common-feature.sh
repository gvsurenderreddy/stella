if [ ! "$_STELLA_COMMON_FEATURE_INCLUDED_" == "1" ]; then
_STELLA_COMMON_FEATURE_INCLUDED_=1

# --------- API -------------------

function __list_active_features() {
	echo "$FEATURE_LIST_ENABLED"
}


function __list_feature_version() {
	local _SCHEMA=$1

	__internal_feature_context $_SCHEMA
	echo $FEAT_LIST_SCHEMA
}


function __feature_init() {
	local _SCHEMA=$1
	local _OPT="$2"
	local _opt_hidden_feature=OFF
	local o
	for o in $_OPT; do
		[ "$o" == "HIDDEN" ] && _opt_hidden_feature=ON
	done

	__internal_feature_context "$_SCHEMA"

	if [[ ! " ${FEATURE_LIST_ENABLED[@]} " =~ " $FEAT_NAME#$FEAT_VERSION " ]]; then

		__feature_inspect "$FEAT_SCHEMA_SELECTED"
		if [ "$TEST_FEATURE" == "1" ]; then

			if [ ! "$FEAT_BUNDLE" == "" ]; then
				local p

				__push_schema_context

				FEAT_BUNDLE_MODE=$FEAT_BUNDLE
				for p in $FEAT_BUNDLE_ITEM; do
					#__feature_init $p "HIDDEN"
					__internal_feature_context $p
					if [ ! "$FEAT_SEARCH_PATH" == "" ]; then
						PATH="$FEAT_SEARCH_PATH:$PATH"
					fi
					for c in $FEAT_ENV_CALLBACK; do
						$c
					done
				done
				FEAT_BUNDLE_MODE=

				__pop_schema_context
			fi

			if [ ! "$_opt_hidden_feature" == "ON" ]; then
				FEATURE_LIST_ENABLED="$FEATURE_LIST_ENABLED $FEAT_NAME#$FEAT_VERSION"
			fi
			if [ ! "$FEAT_SEARCH_PATH" == "" ]; then
				PATH="$FEAT_SEARCH_PATH:$PATH"
			fi

			local c
			for c in $FEAT_ENV_CALLBACK; do
				$c
			done


		fi

	fi
}



# get information on feature (from catalog)
function __feature_catalog_info() {
	local _SCHEMA=$1
	__internal_feature_context $_SCHEMA
}




# look for information about an installed feature
function __feature_match_installed() {
	local _SCHEMA="$1"

	local _tested=
	local _found=

	if [ "$_SCHEMA" == "" ]; then
		__internal_feature_context
		return
	fi
	# we are NOT inside a bundle, because FEAT_BUNDLE_MODE is NOT set
	if [ "$FEAT_BUNDLE_MODE" == "" ]; then
		__translate_schema "$_SCHEMA" "__VAR_FEATURE_NAME" "__VAR_FEATURE_VER" "__VAR_FEATURE_ARCH" "__VAR_FEATURE_FLAVOUR"
		[ ! "$__VAR_FEATURE_VER" == "" ] && _tested="$__VAR_FEATURE_VER"
		[ ! "$__VAR_FEATURE_ARCH" == "" ] && _tested="$_tested"@"$__VAR_FEATURE_ARCH"

		if [ -d "$STELLA_APP_FEATURE_ROOT/$__VAR_FEATURE_NAME" ]; then
				# for each detected version
				for _f in  "$STELLA_APP_FEATURE_ROOT"/"$__VAR_FEATURE_NAME"/*; do
					if [ -d "$_f" ]; then
						if [ "$_tested" == "" ]; then
							_found="$_f"
						else
							case $_f in
								*"$_tested"*)
									_found="$_f"
								;;
								*)
								;;
							esac
						fi
					fi
				done
		fi

		if [ ! "$_found" == "" ]; then
			# we fix the found version with the flavour of the requested schema
			if [ ! "$__VAR_FEATURE_FLAVOUR" == "" ]; then
				__internal_feature_context "$__VAR_FEATURE_NAME"#"$(__get_filename_from_string $_found)":"$__VAR_FEATURE_FLAVOUR"
			else
				__internal_feature_context "$__VAR_FEATURE_NAME"#"$(__get_filename_from_string $_found)"
			fi
		else
			# empty info values
			__internal_feature_context
		fi
	else
		__internal_feature_context "$_SCHEMA"
	fi
}

# save context before calling __feature_inspect, in case we use it inside a schema context
function __push_schema_context() {
	__stack_push "$TEST_FEATURE"
	__stack_push "$FEAT_SCHEMA_SELECTED"
}
# load context before calling __feature_inspect, in case we use it inside a schema context
function __pop_schema_context() {
	__stack_pop FEAT_SCHEMA_SELECTED
	__internal_feature_context $FEAT_SCHEMA_SELECTED
	__stack_pop TEST_FEATURE
}


# test if a feature is installed
# AND retrieve informations based on actually installed feature (looking inside STELLA_APP_FEATURE_ROOT)
# OR from feature recipe if not installed
function __feature_inspect() {
	local _SCHEMA="$1"
	TEST_FEATURE=0

	[ "$_SCHEMA" == "" ] && return
	__feature_match_installed "$_SCHEMA"

	if [ ! "$FEAT_SCHEMA_SELECTED" == "" ]; then
		if [ ! "$FEAT_BUNDLE" == "" ]; then

			local p
			local _t=1
			__push_schema_context

			FEAT_BUNDLE_MODE="$FEAT_BUNDLE"
			for p in $FEAT_BUNDLE_ITEM; do
				TEST_FEATURE=0
				__feature_inspect $p
				[ "$TEST_FEATURE" == "0" ] && _t=0
			done
			FEAT_BUNDLE_MODE=
			__pop_schema_context

			TEST_FEATURE=$_t
			if [ "$TEST_FEATURE" == "1" ]; then
				if [ ! "$FEAT_INSTALL_TEST" == "" ]; then
					for f in $FEAT_INSTALL_TEST; do
						if [ ! -f "$f" ]; then
							TEST_FEATURE=0
						fi
					done
				fi
			fi
		else
			TEST_FEATURE=1
			for f in $FEAT_INSTALL_TEST; do
				if [ ! -f "$f" ]; then
					TEST_FEATURE=0
				fi
			done
		fi
	else
		__feature_catalog_info $_SCHEMA
	fi
}





# TODO : update FEATURE_LIST_ENABLED ?
function __feature_remove() {
	local _SCHEMA=$1
	local _OPT="$2"

	local o
	local _opt_internal_feature=OFF
	local _opt_hidden_feature=OFF
	for o in $_OPT; do
		[ "$o" == "INTERNAL" ] && _opt_internal_feature=ON
		[ "$o" == "HIDDEN" ] && _opt_hidden_feature=ON
	done

	__feature_inspect "$_SCHEMA"

	if [ ! "$FEAT_SCHEMA_OS_RESTRICTION" == "" ]; then
		if [ ! "$FEAT_SCHEMA_OS_RESTRICTION" == "$STELLA_CURRENT_OS" ]; then
			return
		fi
	fi


	if [ ! "$FEAT_SCHEMA_OS_EXCLUSION" == "" ]; then
		if [ "$FEAT_SCHEMA_OS_EXCLUSION" == "$STELLA_CURRENT_OS" ]; then
			return
		fi
	fi

	local _save_app_feature_root=
	if [ "$_opt_internal_feature" == "ON" ]; then
		_save_app_feature_root=$STELLA_APP_FEATURE_ROOT
		STELLA_APP_FEATURE_ROOT=$STELLA_INTERNAL_FEATURE_ROOT
		_save_app_cache_dir=$STELLA_APP_CACHE_DIR
		STELLA_APP_CACHE_DIR=$STELLA_INTERNAL_CACHE_DIR
		_save_app_temp_dir=$STELLA_APP_TEMP_DIR
		STELLA_APP_TEMP_DIR=$STELLA_INTERNAL_TEMP_DIR
	fi

	if [ ! "$_opt_hidden_feature" == "ON" ]; then
		__remove_app_feature $_SCHEMA
	fi

	if [ "$TEST_FEATURE" == "1" ]; then

		if [ ! "$FEAT_BUNDLE" == "" ]; then
			echo " ** Remove bundle $FEAT_NAME version $FEAT_VERSION"
			__del_folder $FEAT_INSTALL_ROOT

			__push_schema_context

			FEAT_BUNDLE_MODE="$FEAT_BUNDLE"
			for p in $FEAT_BUNDLE_ITEM; do
				__feature_remove $p "HIDDEN"
			done
			FEAT_BUNDLE_MODE=
			__pop_schema_context
		else
			echo " ** Remove $FEAT_NAME version $FEAT_VERSION from $FEAT_INSTALL_ROOT"
			__del_folder $FEAT_INSTALL_ROOT
		fi
	fi


	if [ "$_opt_internal_feature" == "ON" ]; then
		STELLA_APP_FEATURE_ROOT=$_save_app_feature_root
		STELLA_APP_CACHE_DIR=$_save_app_cache_dir
		STELLA_APP_TEMP_DIR=$_save_app_temp_dir
	fi

}


function __feature_install_list() {
	local _list=$1

	for f in $_list; do
		__feature_install $f
	done
}

function __feature_install() {
	local _SCHEMA=$1
	local _OPT="$2"

	local o
	local _opt_internal_feature=OFF
	local _opt_hidden_feature=OFF
	local _opt_ignore_dep=OFF
	local _opt_force_reinstall_dep=0
	local _flag_export=OFF
	local _dir_export=
	local _export_mode=OFF
	local _flag_portable=OFF
	local _dir_portable=
	local _portable_mode=OFF

	for o in $_OPT; do
		# INTERNAL : install feature inside stella root
		[ "$o" == "INTERNAL" ] && _opt_internal_feature=ON && _export_mode=OFF
		# HIDDEN : this feature will not be seen in list of active features and not added to current app properties
		[ "$o" == "HIDDEN" ] && _opt_hidden_feature=ON
		# DEP_FORCE : force reinstall all dependencies
		[ "$o" == "DEP_FORCE" ] && _opt_force_reinstall_dep=1
		# DEP_IGNORE : ignore installation step of all dependencies
		[ "$o" == "DEP_IGNORE" ] && _opt_ignore_dep=ON
		# EXPORT <dir> : will install feature in this specified root directory
		[ "$_flag_export" == "ON" ] && _dir_export="$o" && _export_mode=ON && _flag_export=OFF
		[ "$o" == "EXPORT" ] && _flag_export=ON
		# PORTABLE <dir> : will install feature in this specified root directory in a portable way - this folder will ship every dependencies
		[ "$_flag_portable" == "ON" ] && _dir_portable="$o" && _portable_mode=ON && _flag_portable=OFF
		[ "$o" == "PORTABLE" ] && _flag_portable=ON
	done




	# EXPORT / PORTABLE MODE ------------------------------------
	if [ "$_export_mode" == "ON" ]; then
		_opt_internal_feature=OFF
		_opt_hidden_feature=ON

		FEAT_MODE_EXPORT_SCHEMA="$_SCHEMA"
		_SCHEMA="mode-export"

		local _save_app_feature_root="$STELLA_APP_FEATURE_ROOT"
		STELLA_APP_FEATURE_ROOT="$(__rel_to_abs_path "$_dir_export")"
		_OPT="${_OPT//EXPORT/__}"
	fi

	# TODO REVIEW PORTABLE MODE
	if [ "$_portable_mode" == "ON" ]; then
		_opt_internal_feature=OFF
		_opt_hidden_feature=ON

		FEAT_MODE_EXPORT_SCHEMA="$_SCHEMA"
		_SCHEMA="mode-export"

		local _save_app_feature_root="$STELLA_APP_FEATURE_ROOT"
		STELLA_APP_FEATURE_ROOT="$(__rel_to_abs_path "$_dir_portable")"
		_OPT="${_OPT//PORTABLE/__}"

		local _save_relocate_default_mode=$STELLA_BUILD_RELOCATE_DEFAULT
		__set_build_mode_default "RELOCATE" "ON"
	fi




	local _flag=0
	local a

	__internal_feature_context "$_SCHEMA"

	if [ ! "$FEAT_SCHEMA_OS_RESTRICTION" == "" ]; then
		if [ ! "$FEAT_SCHEMA_OS_RESTRICTION" == "$STELLA_CURRENT_OS" ]; then
			echo " $_SCHEMA not installed on $STELLA_CURRENT_OS"
			return
		fi
	fi
	if [ ! "$FEAT_SCHEMA_OS_EXCLUSION" == "" ]; then
		if [ "$FEAT_SCHEMA_OS_EXCLUSION" == "$STELLA_CURRENT_OS" ]; then
			echo " $_SCHEMA not installed on $STELLA_CURRENT_OS"
			return
		fi
	fi

	if [ ! "$FEAT_SCHEMA_SELECTED" == "" ]; then



		local _save_app_feature_root=
		if [ "$_opt_internal_feature" == "ON" ]; then
			_save_app_feature_root=$STELLA_APP_FEATURE_ROOT
			STELLA_APP_FEATURE_ROOT=$STELLA_INTERNAL_FEATURE_ROOT
			_save_app_cache_dir=$STELLA_APP_CACHE_DIR
			STELLA_APP_CACHE_DIR=$STELLA_INTERNAL_CACHE_DIR
			_save_app_temp_dir=$STELLA_APP_TEMP_DIR
			STELLA_APP_TEMP_DIR=$STELLA_INTERNAL_TEMP_DIR
		fi

		if [ ! "$_opt_hidden_feature" == "ON" ]; then
			__add_app_feature $_SCHEMA
		fi


		if [ "$FORCE" == "1" ]; then
			TEST_FEATURE=0
			if [ "$_export_mode" == "OFF" ]; then
				if [ "$_portable_mode" == "OFF" ]; then
					__del_folder $FEAT_INSTALL_ROOT
				fi
			fi
		else
			__feature_inspect "$FEAT_SCHEMA_SELECTED"
		fi


		if [ "$TEST_FEATURE" == "0" ]; then

			if [ "$_export_mode" == "OFF" ]; then
				if [ "$_portable_mode" == "OFF" ]; then
					mkdir -p "$FEAT_INSTALL_ROOT"
				fi
			fi

			# dependencies -----------------
			if [ "$_opt_ignore_dep" == "OFF" ]; then
				local dep

				local _origin=
				local _force_origin=
				local _dependencies=
				[ "$FEAT_SCHEMA_FLAVOUR" == "source" ] && _dependencies="$FEAT_SOURCE_DEPENDENCIES"
				[ "$FEAT_SCHEMA_FLAVOUR" == "binary" ] && _dependencies="$FEAT_BINARY_DEPENDENCIES"

				save_FORCE=$FORCE
				FORCE=$_opt_force_reinstall_dep

				__push_schema_context

				for dep in $_dependencies; do

					if [ "$dep" == "FORCE_ORIGIN_STELLA" ]; then
						_force_origin="STELLA"
						continue
					fi
					if [ "$dep" == "FORCE_ORIGIN_SYSTEM" ]; then
						_force_origin="SYSTEM"
						continue
					fi

					if [ "$_force_origin" == "" ]; then
						_origin="$(__dep_choose_origin $dep)"
					else
						_origin="$_force_origin"
					fi

					if [ "$_origin" == "STELLA" ]; then
						echo "Installing dependency $dep"


						__feature_install $dep "$_OPT HIDDEN"
						if [ "$TEST_FEATURE" == "0" ]; then
							echo "** Error while installing dependency feature $FEAT_SCHEMA_SELECTED"
						fi

					fi
					[ "$_origin" == "SYSTEM" ] && echo "Using dependency $dep from SYSTEM."

				done

				__pop_schema_context
				FORCE=$save_FORCE
			fi

			# bundle -----------------
			if [ ! "$FEAT_BUNDLE" == "" ]; then


				# save export/portable mode
				__stack_push "$_export_mode"
				__stack_push "$_portable_mode"

				if [ ! "$FEAT_BUNDLE_ITEM" == "" ]; then

					__push_schema_context
					FEAT_BUNDLE_MODE=$FEAT_BUNDLE

					if [ ! "$FEAT_BUNDLE_MODE" == "LIST" ]; then
						save_FORCE=$FORCE
						FORCE=0
					fi

					# should be  MERGE or NESTED or LIST
					# NESTED : each item will be installed inside the bundle path in a separate directory (with each feature name but without version) (bundle_name/bunle_version/item_name)
					# MERGE : each item will be installed in the bundle path (without each feature name/version)
					# LIST : this bundle is just a list of items that will be installed normally (without bundle name nor version in path: item_name/item_version )
					# MERGE_LIST : this bundle is a list of items that will be installed in a MERGED way (without bundle name nor version AND without each feature name/version)

					local _flag_hidden
					if [ "$FEAT_BUNDLE_MODE" == "LIST" ]; then
						_flag_hidden=
					else
						_flag_hidden="HIDDEN"
					fi

					local _item=
					for _item in $FEAT_BUNDLE_ITEM; do
						__feature_install $_item "$_OPT $_flag_hidden"
					done

					if [ ! "$FEAT_BUNDLE_MODE" == "LIST" ]; then
						FORCE=$save_FORCE
					fi

					FEAT_BUNDLE_MODE=
					__pop_schema_context
				fi


				# restore export/portable mode
				__stack_pop "_portable_mode"
				__stack_pop "_export_mode"

				# automatic call of bundle's callback after installation of all items
				__feature_callback


			else

				echo " ** Installing $FEAT_NAME version $FEAT_VERSION in $FEAT_INSTALL_ROOT"

				# NOTE : feature_callback is called from recipe itself

				[ "$FEAT_SCHEMA_FLAVOUR" == "source" ] && __start_build_session
				feature_"$FEAT_NAME"_install_"$FEAT_SCHEMA_FLAVOUR"

				# Sometimes current directory is lost by the system. For example when deleting source folder at the end of the install recipe
				cd $STELLA_APP_ROOT

			fi

			if [ "$_export_mode" == "OFF" ]; then
				if [ "$_portable_mode" == "OFF" ]; then
					__feature_inspect $FEAT_SCHEMA_SELECTED

					if [ "$TEST_FEATURE" == "1" ]; then
						echo "** Feature $_SCHEMA is installed"
						__feature_init "$FEAT_SCHEMA_SELECTED" $_OPT
					else
						echo "** Error while installing feature $FEAT_SCHEMA_SELECTED"
						#__del_folder $FEAT_INSTALL_ROOT
						# Sometimes current directory is lost by the system
						cd $STELLA_APP_ROOT
					fi
				fi
			fi
		else
			echo "** Feature $_SCHEMA already installed"
			__feature_init "$FEAT_SCHEMA_SELECTED" $_OPT
		fi

		if [ "$_export_mode" == "ON" ]; then
			STELLA_APP_FEATURE_ROOT=$_save_app_feature_root
		fi

		if [ "$_portable_mode" == "ON" ]; then
			STELLA_APP_FEATURE_ROOT=$_save_app_feature_root
			__set_build_mode_default "RELOCATE" "$_save_relocate_default_mode"
		fi

		if [ "$_opt_internal_feature" == "ON" ]; then
			STELLA_APP_FEATURE_ROOT=$_save_app_feature_root
			STELLA_APP_CACHE_DIR=$_save_app_cache_dir
			STELLA_APP_TEMP_DIR=$_save_app_temp_dir
		fi


	else
		echo " ** Error unknow feature $_SCHEMA"
	fi

}






# ----------- INTERNAL ----------------


function __feature_init_installed() {
	local _tested_feat_name=
	local _tested_feat_ver=
	# init internal features
	# internal feature are not prioritary over app features
	if [ ! "$STELLA_APP_FEATURE_ROOT" == "$STELLA_INTERNAL_FEATURE_ROOT" ]; then

		_save_app_feature_root=$STELLA_APP_FEATURE_ROOT
		STELLA_APP_FEATURE_ROOT=$STELLA_INTERNAL_FEATURE_ROOT


		for f in "$STELLA_INTERNAL_FEATURE_ROOT"/*; do
			if [ -d "$f" ]; then
				_tested_feat_name="$(__get_filename_from_string $f)"
				# check for official feature
				if [[ " ${__STELLA_FEATURE_LIST[@]} " =~ " ${_tested_feat_name} " ]]; then
					# for each detected version
					for v in  "$f"/*; do
						if [ -d "$v" ]; then
							_tested_feat_ver="$(__get_filename_from_string $v)"
							__feature_init "$_tested_feat_name#$_tested_feat_ver" "INTERNAL HIDDEN"
						fi
					done
				fi
			fi
		done
		STELLA_APP_FEATURE_ROOT=$_save_app_feature_root
	fi



	for f in  "$STELLA_APP_FEATURE_ROOT"/*; do

		if [ -d "$f" ]; then
			_tested_feat_name="$(__get_filename_from_string $f)"
			# check for official feature
			if [[ " ${__STELLA_FEATURE_LIST[@]} " =~ " ${_tested_feat_name} " ]]; then
				# for each detected version
				for v in  "$f"/*; do
					if [ -d "$v" ]; then
						_tested_feat_ver="$(__get_filename_from_string $v)"
						__feature_init "$_tested_feat_name#$_tested_feat_ver"
					fi
				done
			fi
		fi
	done

	# TODO log
	echo "** Features initialized : $FEATURE_LIST_ENABLED"
}




function __feature_reinit_installed() {
	FEATURE_LIST_ENABLED=
	__feature_init_installed
}


function __feature_callback() {
	local p

	if [ ! "$FEAT_BUNDLE" == "" ]; then
		for p in $FEAT_BUNDLE_CALLBACK; do
			$p
		done
	else

		if [ "$FEAT_SCHEMA_FLAVOUR" == "source" ]; then
			for p in $FEAT_SOURCE_CALLBACK; do
				$p
			done
		fi
		if [ "$FEAT_SCHEMA_FLAVOUR" == "binary" ]; then
			for p in $FEAT_BINARY_CALLBACK; do
				$p
			done
		fi
	fi
}

# init feature context (properties, variables, ...)
function __internal_feature_context() {
	local _SCHEMA="$1"

	FEAT_ARCH=

	local TMP_FEAT_SCHEMA_NAME=
	local TMP_FEAT_SCHEMA_VERSION=
	FEAT_SCHEMA_SELECTED=
	FEAT_SCHEMA_FLAVOUR=
	FEAT_SCHEMA_OS_RESTRICTION=
	FEAT_SCHEMA_OS_EXCLUSION=

	FEAT_NAME=
	FEAT_LIST_SCHEMA=
	FEAT_DEFAULT_VERSION=
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR=
	FEAT_VERSION=
	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=
	FEAT_BINARY_DEPENDENCIES=
	FEAT_BINARY_CALLBACK=
	FEAT_DEPENDENCIES=
	FEAT_INSTALL_TEST=
	FEAT_INSTALL_ROOT=
	FEAT_SEARCH_PATH=
	FEAT_ENV_CALLBACK=
	FEAT_BUNDLE_ITEM=
	FEAT_BUNDLE_CALLBACK=
	# MERGE / NESTED / LIST / MERGE_LIST
	FEAT_BUNDLE=


	if [ "$_SCHEMA" == "" ]; then
		return
	fi

	if [ ! "$_SCHEMA" == "" ]; then
		__select_official_schema "$_SCHEMA" "FEAT_SCHEMA_SELECTED" "TMP_FEAT_SCHEMA_NAME" "TMP_FEAT_SCHEMA_VERSION" "FEAT_ARCH" "FEAT_SCHEMA_FLAVOUR" "FEAT_SCHEMA_OS_RESTRICTION" "FEAT_SCHEMA_OS_EXCLUSION"
	fi

	if [ ! "$FEAT_SCHEMA_SELECTED" == "" ]; then

		# set install root (FEAT_INSTALL_ROOT)
		if [ "$FEAT_BUNDLE_MODE" == "" ]; then
			if [ ! "$FEAT_ARCH" == "" ]; then
				FEAT_INSTALL_ROOT="$STELLA_APP_FEATURE_ROOT"/"$TMP_FEAT_SCHEMA_NAME"/"$TMP_FEAT_SCHEMA_VERSION"@"$FEAT_ARCH"
			else
				FEAT_INSTALL_ROOT="$STELLA_APP_FEATURE_ROOT"/"$TMP_FEAT_SCHEMA_NAME"/"$TMP_FEAT_SCHEMA_VERSION"
			fi
		else

			if [ "$FEAT_BUNDLE_MODE" == "MERGE" ]; then
				FEAT_INSTALL_ROOT="$FEAT_BUNDLE_PATH"
			fi
			if [ "$FEAT_BUNDLE_MODE" == "NESTED" ]; then
				FEAT_INSTALL_ROOT="$FEAT_BUNDLE_PATH"/"$TMP_FEAT_SCHEMA_NAME"
			fi
			if [ "$FEAT_BUNDLE_MODE" == "LIST" ]; then
				if [ ! "$FEAT_ARCH" == "" ]; then
					FEAT_INSTALL_ROOT="$STELLA_APP_FEATURE_ROOT"/"$TMP_FEAT_SCHEMA_NAME"/"$TMP_FEAT_SCHEMA_VERSION"@"$FEAT_ARCH"
				else
					FEAT_INSTALL_ROOT="$STELLA_APP_FEATURE_ROOT"/"$TMP_FEAT_SCHEMA_NAME"/"$TMP_FEAT_SCHEMA_VERSION"
				fi
			fi
			if [ "$FEAT_BUNDLE_MODE" == "MERGE_LIST" ]; then
				FEAT_INSTALL_ROOT="$STELLA_APP_FEATURE_ROOT"
			fi
		fi

		# grab feature info
		source $STELLA_FEATURE_RECIPE/feature_$TMP_FEAT_SCHEMA_NAME.sh
		feature_$TMP_FEAT_SCHEMA_NAME
		feature_"$TMP_FEAT_SCHEMA_NAME"_"$TMP_FEAT_SCHEMA_VERSION"

		# bundle path
		if [ ! "$FEAT_BUNDLE" == "" ]; then
			if [ "$FEAT_BUNDLE" == "LIST" ]; then
				FEAT_BUNDLE_PATH=
			else
				FEAT_BUNDLE_PATH="$FEAT_INSTALL_ROOT"
			fi
		fi

		# set url dependending on arch
		if [ ! "$FEAT_ARCH" == "" ]; then
			local _tmp="FEAT_BINARY_URL_$FEAT_ARCH"
			FEAT_BINARY_URL=${!_tmp}
			_tmp="FEAT_BINARY_URL_FILENAME_$FEAT_ARCH"
			FEAT_BINARY_URL_FILENAME=${!_tmp}
			_tmp="FEAT_BINARY_URL_PROTOCOL_$FEAT_ARCH"
			FEAT_BINARY_URL_PROTOCOL=${!_tmp}
			_tmp="FEAT_BUNDLE_ITEM_$FEAT_ARCH"
			FEAT_BUNDLE_ITEM=${!_tmp}
			_tmp="FEAT_BINARY_DEPENDENCIES_$FEAT_ARCH"
			FEAT_BINARY_DEPENDENCIES=${!_tmp}
		fi
	else
		# we grab only os option
		# TODO why we grab os option ?
		__translate_schema "$_SCHEMA" "NONE" "NONE" "NONE" "NONE" "FEAT_SCHEMA_OS_RESTRICTION" "FEAT_SCHEMA_OS_EXCLUSION"
	fi
}



# select an official schema
# pick a feature schema by filling some values with default one
# and may return split schema properties
function __select_official_schema() {
	local _SCHEMA="$1"
	local _RESULT_SCHEMA="$2"

	local _VAR_FEATURE_NAME="$3"
	local _VAR_FEATURE_VER="$4"
	local _VAR_FEATURE_ARCH="$5"
	local _VAR_FEATURE_FLAVOUR="$6"
	local _VAR_FEATURE_OS_RESTRICTION="$7"
	local _VAR_FEATURE_OS_EXCLUSION="$8"

	local _FILLED_SCHEMA=


 	if [ ! "$_RESULT_SCHEMA" == "" ]; then
		eval $_RESULT_SCHEMA=
	fi

 	# __translate_schema "$_SCHEMA" "$_VAR_FEATURE_NAME" "$_VAR_FEATURE_VER" "$_VAR_FEATURE_ARCH" "$_VAR_FEATURE_FLAVOUR" "$_VAR_FEATURE_OS_RESTRICTION" "$_VAR_FEATURE_OS_EXCLUSION"
	__translate_schema "$_SCHEMA" "$3" "$4" "$5" "$6" "$7" "$8"


	local _TR_FEATURE_NAME=${!_VAR_FEATURE_NAME}
	local _TR_FEATURE_VER=${!_VAR_FEATURE_VER}
	local _TR_FEATURE_ARCH=${!_VAR_FEATURE_ARCH}
	local _TR_FEATURE_FLAVOUR=${!_VAR_FEATURE_FLAVOUR}
	local _TR_FEATURE_OS_RESTRICTION=${!_VAR_FEATURE_OS_RESTRICTION}
	local _TR_FEATURE_OS_EXCLUSION=${!_VAR_FEATURE_OS_EXCLUSION}
	local _official=0
	if [[ " ${__STELLA_FEATURE_LIST[@]} " =~ " ${_TR_FEATURE_NAME} " ]]; then
		# grab feature info
		source $STELLA_FEATURE_RECIPE/feature_$_TR_FEATURE_NAME.sh
		feature_$_TR_FEATURE_NAME

		# fill schema with default values
		if [ "$_TR_FEATURE_VER" == "" ]; then
			_TR_FEATURE_VER=$FEAT_DEFAULT_VERSION
			[ ! "$_VAR_FEATURE_VER" == "" ] && eval $_VAR_FEATURE_VER=$FEAT_DEFAULT_VERSION
		fi
		if [ "$_TR_FEATURE_ARCH" == "" ]; then
			_TR_FEATURE_ARCH=$FEAT_DEFAULT_ARCH
			[ ! "$_VAR_FEATURE_ARCH" == "" ] && eval $_VAR_FEATURE_ARCH=$FEAT_DEFAULT_ARCH
		fi
		if [ "$_TR_FEATURE_FLAVOUR" == "" ]; then
			_TR_FEATURE_FLAVOUR=$FEAT_DEFAULT_FLAVOUR
			[ ! "$_VAR_FEATURE_FLAVOUR" == "" ] && eval $_VAR_FEATURE_FLAVOUR=$FEAT_DEFAULT_FLAVOUR
		fi

		_FILLED_SCHEMA="$_TR_FEATURE_NAME"#"$_TR_FEATURE_VER"
		[ ! "$_TR_FEATURE_ARCH" == "" ] && _FILLED_SCHEMA="$_FILLED_SCHEMA"@"$_TR_FEATURE_ARCH"
		[ ! "$_TR_FEATURE_FLAVOUR" == "" ] && _FILLED_SCHEMA="$_FILLED_SCHEMA":"$_TR_FEATURE_FLAVOUR"

		# ADDING OS restriction and OS exclusion
		_OS_OPTION=
		[ ! "$_TR_FEATURE_OS_RESTRICTION" == "" ] && _OS_OPTION="$_OS_OPTION/$_TR_FEATURE_OS_RESTRICTION"
		[ ! "$_TR_FEATURE_OS_EXCLUSION" == "" ] && _OS_OPTION="$_OS_OPTION"\\\\"$_TR_FEATURE_OS_EXCLUSION"


		# check filled schema exists
		local l
		for l in $FEAT_LIST_SCHEMA; do
			if [ "$_TR_FEATURE_NAME"#"$l" == "$_FILLED_SCHEMA" ]; then
				[ ! "$_RESULT_SCHEMA" == "" ] && _official=1
			fi
		done

	fi

	if [ "$_official" == "1" ]; then
		eval $_RESULT_SCHEMA=$_FILLED_SCHEMA$_OS_OPTION
	else
		# not official so empty split values
		[ ! "$_VAR_FEATURE_NAME" == "" ] && eval $_VAR_FEATURE_NAME=
		[ ! "$_VAR_FEATURE_VER" == "" ] && eval $_VAR_FEATURE_VER=
		[ ! "$_VAR_FEATURE_ARCH" == "" ] && eval $_VAR_FEATURE_ARCH=
		[ ! "$_VAR_FEATURE_FLAVOUR" == "" ] && eval $_VAR_FEATURE_FLAVOUR=
		[ ! "$_VAR_FEATURE_OS_RESTRICTION" == "" ] && eval $_VAR_FEATURE_OS_RESTRICTION=
		[ ! "$_VAR_FEATURE_OS_EXCLUSION" == "" ] && eval $_VAR_FEATURE_OS_EXCLUSION=
	fi

}


# split schema properties
# feature schema name[#version][@arch][:flavour][/os_restriction][\os_exclusion] in any order
#				@arch could be x86 or x64
#				:flavour could be binary or source
# example: wget/ubuntu#1_2@x86:source wget/ubuntu#1_2@x86:source\macos
function __translate_schema() {

	local _tr_schema="$1"

	local _VAR_FEATURE_NAME="$2"
	local _VAR_FEATURE_VER="$3"
	local _VAR_FEATURE_ARCH="$4"
	local _VAR_FEATURE_FLAVOUR="$5"
	local _VAR_FEATURE_OS_RESTRICTION="$6"
	local _VAR_FEATURE_OS_EXCLUSION="$7"

	if [ ! "$_VAR_FEATURE_NAME" == "" ]; then
		eval $_VAR_FEATURE_NAME=
	fi
	if [ ! "$_VAR_FEATURE_VER" == "" ]; then
		eval $_VAR_FEATURE_VER=
	fi
	if [ ! "$_VAR_FEATURE_ARCH" == "" ]; then
		eval $_VAR_FEATURE_ARCH=
	fi
	if [ ! "$_VAR_FEATURE_FLAVOUR" == "" ]; then
		eval $_VAR_FEATURE_FLAVOUR=
	fi
	if [ ! "$_VAR_FEATURE_OS_RESTRICTION" == "" ]; then
		eval $_VAR_FEATURE_OS_RESTRICTION=
	fi
	if [ ! "$_VAR_FEATURE_OS_EXCLUSION" == "" ]; then
		eval $_VAR_FEATURE_OS_EXCLUSION=
	fi

	local _char=

	_char=":"
	if [ -z "${_tr_schema##*$_char*}" ]; then
		if [ ! "$_VAR_FEATURE_FLAVOUR" == "" ]; then eval $_VAR_FEATURE_FLAVOUR="$(echo $_tr_schema | sed 's,^.*:\([^/\\#@]*\).*$,\1,')"; fi
	fi

	_char="/"
	if [ -z "${_tr_schema##*$_char*}" ]; then
		if [ ! "$_VAR_FEATURE_OS_RESTRICTION" == "" ]; then eval $_VAR_FEATURE_OS_RESTRICTION="$(echo $_tr_schema | sed 's,^.*/\([^:\\#@]*\).*$,\1,')"; fi
	fi

	_char='\\'
	if [ -z "${_tr_schema##*\\*}" ]; then
		if [ ! "$_VAR_FEATURE_OS_EXCLUSION" == "" ]; then eval $_VAR_FEATURE_OS_EXCLUSION="$(echo $_tr_schema | sed 's,^.*\\\([^:/#@]*\).*$,\1,')"; fi
	fi

	_char="#"
	if [ -z "${_tr_schema##*$_char*}" ]; then
		if [ ! "$_VAR_FEATURE_VER" == "" ]; then eval $_VAR_FEATURE_VER="$(echo $_tr_schema | sed 's,^.*#\([^:/\\@]*\).*$,\1,')"; fi
	fi

	_char="@"
	if [ -z "${_tr_schema##*$_char*}" ]; then
		if [ ! "$_VAR_FEATURE_ARCH" == "" ]; then eval $_VAR_FEATURE_ARCH="$(echo $_tr_schema | sed 's,^.*@\([^:/\\#]*\).*$,\1,')"; fi
	fi


	if [ ! "$_VAR_FEATURE_NAME" == "" ]; then eval $_VAR_FEATURE_NAME="$(echo $_tr_schema | sed 's,^\([^:/\\#@]*\).*$,\1,')"; fi

	# Debug log
	#echo TRANSLATE RESULT N: $_VAR_FEATURE_NAME = $(eval echo \$${_VAR_FEATURE_NAME})  V: $_VAR_FEATURE_VER = $(eval echo \$${_VAR_FEATURE_VER}) OSR: $_VAR_FEATURE_OS_RESTRICTION = $(eval echo \$${_VAR_FEATURE_OS_RESTRICTION})
}


# --------------- DEPRECATED ---------------------------------------------


function __file5() {
	URL=ftp://ftp.astron.com/pub/file/file-5.15.tar.gz
	VER=5.15
	FILE_NAME=file-5.15.tar.gz
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/cross-tools"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/file-$VER-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/file-$VER-build"

	AUTO_INSTALL_FLAG_PREFIX=
	AUTO_INSTALL_FLAG_POSTFIX="--disable-static"

	__auto_build "configure" "file" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"

}



function __binutils() {
	#TODO configure flag
	URL=http://ftp.gnu.org/gnu/binutils/binutils-2.23.2.tar.bz2
	VER=2.23.2
	FILE_NAME=binutils-2.23.2.tar.bz2
	INSTALL_DIR="$STELLA_APP_FEATURE_ROOT/cross-tools"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/binutils-$VER-src"
	BUILD_DIR="$STELLA_APP_FEATURE_ROOT/binutils-$VER-build"

	AUTO_INSTALL_FLAG_PREFIX="AR=ar AS=as"
	AUTO_INSTALL_FLAG_POSTFIX="--host=$CROSS_HOST --target=$CROSS_TARGET \
  	--with-sysroot=${CLFS} --with-lib-path=/tools/lib --disable-nls \
  	--disable-static --enable-64-bit-bfd"

	__auto_build "configure" "binutils" "$FILE_NAME" "$URL" "$SRC_DIR" "$BUILD_DIR" "$INSTALL_DIR" "STRIP"
}









fi
