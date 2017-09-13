#!/bin/bash

increase_version (){
    WORKSPACE_DIR=''
    PROJECT_NAME=''
    SETUP_FILE=''
    CONFIG_FILE=''
    PART=''
    REMOVE_CONFIG=''
    ARGS=''
    usage(){
        echo "usage: upgrade-version.sh [-p](major|minor|patch)
           [-t|-m] [-r] [-w] WORKSPACE_PATH [-c] CONFIG_FILE PROJECT_NAME"
        echo "optional arguments: "
        echo "      -h : Displays the help message."
        echo " -t | -m : Perform a test run without changes or actual run upgrading the project version."
        echo "      -w : Path to Workspace directory"
        echo "      -c : Path the config file"
        echo "      -r : Remove config file after run."
    }

    if [[ $# -lt 4 ]]; then
        usage
        return 0
    fi

    while getopts 'tmrhp:c:w:v' flag; do
          case "${flag}" in
            t) ARGS="--dry-run";;
            h) usage ;;
            p) PART=${OPTARG} ;;
            r) REMOVE_CONFIG='yes' ;;
            m) ARGS="--list" ;;
            c) CONFIG_FILE="${OPTARG:-''}" ;;
            w) WORKSPACE_DIR="${OPTARG:-$HOME/workspace/$PROJECT_NAME}" ;;
            *) usage;;
          esac
     done
  if [[ -z ${PROJECT_NAME} && ! -z ${WORKSPACE_DIR} ]]; then
    PROJECT_NAME=$(basename "$WORKSPACE_DIR")
  else
    PROJECT_NAME="${@:${#@}}"
    WORKSPACE_DIR="$HOME/workspace/$PROJECT_NAME"
  fi
  if [[ ! -z "$PART" ]]; then
    case "${PART}" in
        minor|major|patch) echo "Changing $PART version.";;
        *) echo "Invalid version part specified (major|minor|patch)."; return 1;;
    esac
  fi

  echo "Project name: $PROJECT_NAME"
  echo "Workspace dir: $WORKSPACE_DIR"
  if [[ ! -z "$CONFIG_FILE" && ! -f "$CONFIG_FILE" ]]; then
    echo "Config file doesn't exists specify path to config file with [-c] [CONFIG_FILE]"
    return 1
  fi

  if [[ ! -d "$WORKSPACE_DIR" ]]; then
     echo "No workspace directory exist at path $WORKSPACE_DIR"
  else
     SETUP_FILE=$(find "$WORKSPACE_DIR" -type f -name 'setup.py')
     if [[ -z ${SETUP_FILE} || ! -f ${SETUP_FILE} ]]; then
       echo "setup.py file not found at $SETUP_FILE"
       echo "Checking mainline directory"
       WORKSPACE_DIR="$HOME/workspace/$PROJECT_NAME/mainline"
       SETUP_FILE=$(find "$WORKSPACE_DIR" -type f -name 'setup.py')
       if [[ -z ${SETUP_FILE} || ! -f ${SETUP_FILE} ]]; then
          echo "Could not find the setup.py in $SETUP_FILE"
          return 1
       fi
     else
        echo "Found setup file at $SETUP_FILE"
     fi
  fi

  if [[ ! -z "$PROJECT_NAME" && -d "$WORKSPACE_DIR" ]];then
     echo "Starting bumpversion..."
     CURRENT_VERSION=$(sed -n "s/version=//p" "$WORKSPACE_DIR/setup.py" | sed -n "s/[',]*//gp" | xargs)
     CONFIG_FILE="${CONFIG_FILE:-$HOME/.bumpversion-$PROJECT_NAME.cfg}"
     echo "Current version: $CURRENT_VERSION"
     echo "Workspace:  $WORKSPACE_DIR"
     if [[ ! -z ${CONFIG_FILE} && ! -f ${CONFIG_FILE} && ${CURRENT_VERSION} ]]; then
        SOURCE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
        sed "s/VERSION/$CURRENT_VERSION/g;s/WORKSPACE/${WORKSPACE_DIR//\//\\/}/g" "${SOURCE}/.bumpversiontemplate.cfg"  > "$CONFIG_FILE"
     fi
     echo "bumpversion —-config-file $CONFIG_FILE $PART"
     bumpversion --allow-dirty --config-file "$CONFIG_FILE"  "$PART" --verbose "$ARGS"
     if [[ ! -z ${REMOVE_CONFIG} && 'yes' ==  ${REMOVE_CONFIG} ]]; then
        rm ${CONFIG_FILE}
     fi

  fi
}

increase_version