#!/bin/bash


increase_version (){
    WORKSPACE_DIR=
    PROJECT_NAME=
    SETUP_FILE=
    CONFIG_FILE=
    PART=
    REMOVE_CONFIG=
    ARGS=
    GET_VERSION=

    version() {
        echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }';
    }

    usage(){
        echo "usage: increase_version [-p](major|minor|patch)
           [-t | -m] [-r] [-w] WORKSPACE_PATH [-c] CONFIG_FILE PROJECT_NAME"
        echo "optional arguments: "
        echo "      -h : Displays the help message."
        echo " -t | -m : Performs a test run without changes or actual run upgrading the project version."
        echo "      -w : Specify path to workspace directory"
        echo "      -c : Specify path to the config file"
        echo "      -r : Remove config file after run."
        echo "      -g : Get the project current version. 'increase_version -g PROJECT_NAME' "
    }

    while getopts 'tmrghp:c:w:v' flag; do
          case "${flag}" in
            t) ARGS="--dry-run";;
            h) usage ;;
            p) PART=${OPTARG} ;;
            r) REMOVE_CONFIG='yes' ;;
            g) GET_VERSION=1 ;;
            m) ARGS="--list" ;;
            c) CONFIG_FILE="${OPTARG:-''}" ;;
            w) WORKSPACE_DIR="${OPTARG:-$HOME/workspace/$PROJECT_NAME}" ;;
            *) usage;;
          esac
     done

    if [[ ! -z ${GET_VERSION} && $# -lt 2 ]]; then
        usage
        return 0
    else
        if [[ -z ${GET_VERSION} && $# -lt 4 ]]; then
            usage
            return 0
        fi
    fi
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

  if [[ ! -z "$PROJECT_NAME" && -d "$WORKSPACE_DIR"  && ! -z ${GET_VERSION} ]];then
      echo "Getting current version..."
      CURRENT_VERSION=$(sed -n "s/version=//p" "$WORKSPACE_DIR/setup.py" | sed -n "s/[',]*//gp" | xargs)
      echo "Project: $PROJECT_NAME"
      echo "Workspace dir: $WORKSPACE_DIR"
      echo "Current version: $CURRENT_VERSION"
      return 0
  else
     echo "Project name: $PROJECT_NAME"
     echo "Workspace dir: $WORKSPACE_DIR"
  fi

  if [[ ! -z "$PROJECT_NAME" && -d "$WORKSPACE_DIR" ]];then
     echo "Starting bumpversion..."
     CURRENT_VERSION=$(sed -n "s/version=//p" "$WORKSPACE_DIR/setup.py" | sed -n "s/[',]*//gp" | xargs)
     CONFIG_FILE="${CONFIG_FILE:-$HOME/.bumpversion-$PROJECT_NAME.cfg}"
     echo "Current version: $CURRENT_VERSION"
     echo "Workspace:  $WORKSPACE_DIR"
     

     if [[ ! -z ${CONFIG_FILE} && ! -z ${CURRENT_VERSION} ]]; then
        WORD_COUNT=$(wc -c <"$CONFIG_FILE")
        if [[ ! -f  ${CONFIG_FILE} ||  ${WORD_COUNT} -lt 160 ]]; then
            echo "Generating config file Please wait..."
            SOURCE_TEMPLATE=$(find $HOME -name ".bumpversiontemplate.cfg" 2>/dev/null)
            if [ -z "$SOURCE_TEMPLATE" ]; then
                echo "Cannot find source config template file .bumpversiontemplate.cfg"
                return 1
            else
                sed "s/VERSION/$CURRENT_VERSION/g;s/WORKSPACE/${WORKSPACE_DIR//\//\\/}/g" "${SOURCE_TEMPLATE}"  > "$CONFIG_FILE"
            fi
        else
            echo "Updating the current version to $CURRENT_VERSION"
            sed "s/.*current_version =.*/current_version = $CURRENT_VERSION/" "$CONFIG_FILE" > "$CONFIG_FILE.new"
            mv "$CONFIG_FILE.new" "$CONFIG_FILE"
        fi
     fi
     cd ${WORKSPACE_DIR}
     bumpversion --allow-dirty --config-file "$CONFIG_FILE"  "$PART" --verbose "$ARGS"
     if [[ ! -z ${REMOVE_CONFIG} && 'yes' ==  ${REMOVE_CONFIG} ]]; then
        rm ${CONFIG_FILE}
     fi
     cd ${OLDPWD}
  fi
}

[[ $0 != "$BASH_SOURCE" ]] || increase_version $@