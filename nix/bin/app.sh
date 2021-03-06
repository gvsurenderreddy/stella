#!/bin/bash
_STELLA_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $_STELLA_CURRENT_FILE_DIR/../../conf.sh

function usage() {
    echo "USAGE :"
    echo "----------------"
    echo "List of commands"
    echo " o-- application management :"
    echo " L     init <application name> [--approot=<path>] [--workroot=<abs or relative path to approot>] [--cachedir=<abs or relative path to approot>] [--samples]"
    echo " L     get-data|get-assets|update-data|update-assets|revert-data|revert-assets|delete-data|delete-assets <list of data id|list of assets id>"
    echo " L     get-data-pack|get-assets-pack|update-data-pack|update-assets-pack|revert-data-pack|revert-assets-pack|delete-data-pack|delete-assets-pack <data pack name|assets pack name>"
    echo " L     get-feature <all|feature schema> : install all features defined in app properties file or install a matching one"
    echo " L     link stella <app-path> [--stellaroot=<path>] : link an app to a specific stella path"
    echo " L     deploy user@host:path [--cache] [--workspace] : : deploy current app version to an other target via ssh. [--cache] : include app cache folder. [--workspace] : include app workspace folder"
    
}




# MAIN ------------------------
PARAMETERS="
ACTION=                         'action'                    a           'deploy link init get-data get-assets delete-data delete-assets update-data update-assets revert-data revert-assets get-feature get-data-pack get-assets-pack update-data-pack update-assets-pack revert-data-pack revert-assets-pack'            Action to compute.
ID=                          ''                             s           ''                      Data or Assets or Env ID or Application name.
"
OPTIONS="
FORCE=''							'f'			''					b			0		'1'						Force.
APPROOT=''                      ''          'path'              s           0           ''                      App path (default current)
WORKROOT=''                     ''          'path'              s           0           ''                      Work app path (default equal to app path)
CACHEDIR=''                     ''          'path'              s           0           ''                      Cache folder path
SAMPLES=''                      ''         ''                  b           0       '1'                     Generate app samples.
STELLAROOT=''                     ''          'path'              s           0           ''                      Stella path to link.
CACHE=''                        ''          ''                  b           0           '1'                     Include cache folder when deploying.
WORKSPACE=''                        ''          ''                  b           0           '1'                     Include workspace folder when deploying.
"


__argparse "$0" "$OPTIONS" "$PARAMETERS" "Stella application management" "$(usage)" "" "$@"

# common initializations
__init_stella_env



if [ "$ACTION" == "init" ]; then

    if [ "$APPROOT" == "" ]; then
        APPROOT="$STELLA_CURRENT_RUNNING_DIR/$ID"
    fi
    if [ "$WORKROOT" == "" ]; then
        WORKROOT="$APPROOT/workspace"
    fi
    if [ "$CACHEDIR" == "" ]; then
        CACHEDIR="$APPROOT/cache"
    fi

    __init_app "$ID" "$APPROOT" "$WORKROOT" "$CACHEDIR"
    [ "$SAMPLES" ] && __create_app_samples $APPROOT

else

    if [ "$ACTION" == "link" ]; then
        __link_app "$ID" "STELLA_ROOT $STELLAROOT"
        
    else


        if [ ! -f "$_STELLA_APP_PROPERTIES_FILE" ]; then
            echo "** ERROR properties file does not exist"
            exit
        fi

        case $ACTION in
            deploy)
                _deploy_options=
                [ "$CACHE" == "1" ] && _deploy_options="CACHE"
                [ "$WORKSPACE" == "1" ] && _deploy_options="$_deploy_options WORKSPACE"
                __transfert_app "$ID" "$_deploy_options"
                ;;
            get-feature)
                if [ "$ID" == "all" ]; then
                    __get_features
                else
                    __get_feature "$ID"
                fi
                ;;
            get-data)
                __get_data $ID
                ;;
            get-data-pack)
                __get_data_pack $ID
                ;;
            get-assets)
                __get_assets $ID
                ;;
            get-assets-pack)
                __get_assets_pack $ID
                ;;
            delete-data)
                __delete_data $ID
                ;;
            delete-assets)
                __delete_assets $ID
                ;;
            delete-data-pack)
                __delete_data_pack $ID
                ;;
            delete-assets-pack)
                __delete_assets_pack $ID
                ;;
            udpate-data)
                __update_data $ID
                ;;
            update-assets)
                __update_assets $ID
                ;;
            revert-data)
                __revert_data $ID
                ;;
            revert-assets)
                __revert_assets $ID
                ;;
            
            *)
                echo "use option --help for help"
                ;;
        esac
    fi
fi


echo "** END **"
