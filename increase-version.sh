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
    TEMPDIR=

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
            h) usage; return 0 ;;
            p) PART=${OPTARG} ;;
            r) REMOVE_CONFIG='yes' ;;
            g) GET_VERSION=1 ;;
            m) ARGS="--list" ;;
            c) CONFIG_FILE="${OPTARG:-''}" ;;
            w) WORKSPACE_DIR="${OPTARG:-$HOME/workspace/$PROJECT_NAME}" ;;
            *) usage; return 0 ;;
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
  [ $(pip show bumpversion | wc -c) -ne 0 ] || pip install --upgrade bumpversion --quiet
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
     MAINLINE_DIR="$WORKSPACE_DIR/mainline"
     SETUP_FILE=$(find "$WORKSPACE_DIR" -type f -name 'setup.py')
     if [[ $? -ne 0 ]]; then
       echo "No setup.py file not found in: $WORKSPACE_DIR"
       echo "Checking mainline directory : $MAINLINE_DIR"
       SETUP_FILE=$(find "$MAINLINE_DIR" -type f -name 'setup.py')
       if [[ $? -ne 0 ]]; then
          echo "Cannot find setup.py file in $WORKSPACE_DIR or $MAINLINE_DIR."
          return 1
       fi
     else
        WORKSPACE_DIR=`dirname ${SETUP_FILE}`
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

     if [ -z ${CONFIG_FILE} ]; then
        TEMPDIR=`mktemp -d -t version_config`
        if [ $? -ne 0 ]; then
           echo "Can't create temp dir, specify config file path using -c option. exiting..."
           return 1
        else
            CONFIG_FILE="$TEMPDIR/.bumpversion-$PROJECT_NAME.cfg"
        fi
     fi
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
        echo "Cleaning up"
        rm ${CONFIG_FILE}
     else
        mv ${CONFIG_FILE} ~
     fi
     cd ${OLDPWD}

     if [ ! -z  ${TEMPDIR}  ]; then
        echo "Cleaning up..."
        rm -f ${TEMPDIR}
     fi
  fi
}

[[ $0 != "$BASH_SOURCE" ]] || increase_version $@