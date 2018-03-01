#!/bin/bash

increase_version (){
    PROJECT_NAME=
    GET_VERSION=
    ARGS=
    VERBOSE=
    REMOVE_CONFIG=
    PART=
    CONFIG_FILE=
    SETUP_FILE=
    PROJECT_NAME=
    CURRENT_VERSION=
    WORKSPACE_DIR=

    version() {
        echo "$@" | awk -F. '{ if($1 <= 0) $1=$1+1; printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }';
    }

    usage(){
        echo "usage:
        increase_version [-p](major|minor|patch) [-t|-m] [-vhr] [-w] WORKSPACE_DIR [-c] CONFIG_FILE PROJECT_NAME
        increase_version -g PROJECT_NAME
              "
        echo "options: "
        echo "      -p : Specify the version part to bump i.e (minor| major| patch)."
        echo "      -t : Performs a test run without changes shows a verbose output by default."
        echo "      -m : Perform an actual run bumping the project version. Run with -v for more information."
        echo "      -v : Verbose option to show more information about the performed operation."
        echo "      -h : Displays the help message."
        echo "      -r : Remove project generated config file after run."
        echo "      -w : Specify path to workspace/project directory."
        echo "      -c : Specify path to another config template defualts to '.bumpversiontemplate.cfg'."
        echo "      -g : Retrieves the project's current version."
    }

    while getopts 'tmrghp:c:w:v' flag; do
          case "${flag}" in
            t) ARGS="--dry-run" VERBOSE="--verbose" ;;
            h) usage; return 0 ;;
            p) PART=${OPTARG} ;;
            r) REMOVE_CONFIG='yes' ;;
            g) GET_VERSION=1 ;;
            m) ARGS="--list" ;;
            c) CONFIG_FILE="${OPTARG:-''}" ;;
            v) VERBOSE="--verbose" ;;
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
  if [[ -z ${PROJECT_NAME} && ! -z ${WORKSPACE_DIR} ]]; then
    PROJECT_NAME=$(basename "$WORKSPACE_DIR")
  else
    PROJECT_NAME="${@:${#@}}"
    WORKSPACE_DIR="$HOME/workspace/$PROJECT_NAME"
  fi


  if [[ ! -z "$PART" ]]; then
    case "${PART}" in
        minor|major|patch) echo "Changing $PART version.";;
        *) echo "Invalid version part specified: (major|minor|patch)."; return 1;;
    esac
  fi

  SEPARATOR="'"

  if [[ ! -z "$CONFIG_FILE" && ! -f "$CONFIG_FILE" ]]; then
    echo "Config file doesn't exists specify path to config file with [-c] [CONFIG_FILE]"
    return 1
  fi

  if [ ! -d "$WORKSPACE_DIR" ]; then
     echo "No workspace directory exist at: $WORKSPACE_DIR"
  else
     echo "The project name is '$PROJECT_NAME' and the workspace location is: $WORKSPACE_DIR"
     MAINLINE_DIR="$WORKSPACE_DIR/mainline"
     SETUP_FILE=$(find "$WORKSPACE_DIR" -depth 1 -type f -name 'setup.py' 2>/dev/null)
     if [ -z $SETUP_FILE ]; then
       echo "No setup.py file not found in: $WORKSPACE_DIR"
       echo "Checking mainline directory: $MAINLINE_DIR"
       SETUP_FILE=$(find "$MAINLINE_DIR"  -depth 1 -type f -name 'setup.py' 2>/dev/null)
       if [[ $? -ne 0 ]]; then
          echo "Cannot find setup.py file in $WORKSPACE_DIR or $MAINLINE_DIR."
          return 1
       fi
     else
        WORKSPACE_DIR=`dirname ${SETUP_FILE}`
        echo "Found setup file at $SETUP_FILE"
     fi
  fi

  if [[ -d "$WORKSPACE_DIR" ]];then
      if [[ ! -z ${GET_VERSION} && -f $SETUP_FILE ]]; then
          echo "Getting current version..."
          CURRENT_VERSION=$(sed -n "s/.*version='//p" "$SETUP_FILE" | sed -n "s/[',\"]*//gp" | xargs)
          echo "Project: $PROJECT_NAME"
          echo "Workspace dir: $WORKSPACE_DIR"
          echo "Current local version: $CURRENT_VERSION"
          return 0
      else
         echo "Project name: $PROJECT_NAME"
         echo "Workspace dir: $WORKSPACE_DIR"
      fi
  fi

  if [[ ! -z "$PROJECT_NAME" && -d "$WORKSPACE_DIR" ]];then
     echo "Starting bumpversion..."
     CURRENT_VERSION=$(sed -n "s/.*version=//p" "$WORKSPACE_DIR/setup.py" | sed -n "s/[',\"]*//gp" | xargs)
     SEPARATOR=$(sed -n "s/.*version=//p" "$WORKSPACE_DIR/setup.py" | cut -d . -f 1 | cut -c 1 )
     if [ -z ${CONFIG_FILE} ]; then
        echo "Getting config file..."
        CONFIG_FILE="$HOME/.bumpversion-${PROJECT_NAME}.cfg"
        if [ ! -f ${CONFIG_FILE} ]; then
            echo "Cant find config file in $HOME directory."
            echo "Creating temp directory"
            TEMPDIR=`mktemp -d -t version_config`
            if [ $? -ne 0 ]; then
               echo "Can't create temp dir, specify config file path using -c option. exiting..."
               return 1
            else
                CONFIG_FILE="$TEMPDIR/.bumpversion-$PROJECT_NAME.cfg"
            fi
        fi
     fi
     echo "Current version: $CURRENT_VERSION"
     echo "Workspace:  $WORKSPACE_DIR"
     echo "Separator: $SEPARATOR"

     [ $(which bumpversion | wc -c) -ne 0 ] || pip install --upgrade bumpversion --quiet
     if [[ ! -z ${CONFIG_FILE} && ! -z ${CURRENT_VERSION} ]]; then
        if [[ ! -f  ${CONFIG_FILE} ||  $(wc -c <"$CONFIG_FILE") -lt 160 ]]; then
            echo "Generating config file Please wait..."
            SOURCE_TEMPLATE=$(find $HOME -name ".bumpversiontemplate.cfg" 2>/dev/null)
            if [ -z ${SOURCE_TEMPLATE} ]; then
                echo "Cannot find source config template file .bumpversiontemplate.cfg"
                echo "Check file prefix '.'"
                return 1
            else
                sed "s/VERSION/$CURRENT_VERSION/g;s/SEP/$SEPARATOR/g;s/PROJECT_NAME/$PROJECT_NAME/g;s/WORKSPACE/${WORKSPACE_DIR//\//\\/}/g" "${SOURCE_TEMPLATE}"  > "$CONFIG_FILE"
            fi
        else
            CONFIG_VERSION=$(sed -n "s/current_version =//1p" "$CONFIG_FILE")
            if [[ $(version ${CONFIG_VERSION}) -gt $(version ${CURRENT_VERSION}) || $(version ${CONFIG_VERSION}) -lt $(version ${CURRENT_VERSION}) ]];then
                echo "Updating the current version to $CURRENT_VERSION"
                sed "s/.*current_version =.*/current_version = $CURRENT_VERSION/;s/.*SEP.*/part:$SEPARATOR/" "$CONFIG_FILE" > "$CONFIG_FILE.new"
                mv "$CONFIG_FILE.new" "$CONFIG_FILE"
            fi
        fi
     fi
     BUMPVERSION=$(pip freeze | grep bumpversion)

     if [ -z $BUMPVERSION ]; then
        echo "No bumpversion package found. Please install bumpversion run 'pip install bumpversion' "
        return 1
     fi
     cd "$WORKSPACE_DIR"
     echo "Increasing version..."
     if [ -z "$VERBOSE" ]; then
        bumpversion "--allow-dirty" "${ARGS}" "--config-file" "$CONFIG_FILE" "${PART}" "$SETUP_FILE"
     else
        bumpversion "--allow-dirty" "${ARGS}" "--config-file" "$CONFIG_FILE" "${PART}" "$SETUP_FILE" "$VERBOSE"
     fi

     if [[ ! -z ${REMOVE_CONFIG} &&  ${REMOVE_CONFIG} -eq 'yes' ]]; then
        echo "Cleaning up $CONFIG_FILE."
        rm ${CONFIG_FILE}
     else
        if [[ ! -f $HOME/$(basename ${CONFIG_FILE}) ]]; then
            mv ${CONFIG_FILE} ${HOME}
        fi
     fi
     cd ${OLDPWD}

     if [ ! -z  ${TEMPDIR}  ]; then
        echo "Cleaning up..."
        rm -rf ${TEMPDIR}
     fi
  fi
}

[[ $0 != "$BASH_SOURCE" ]] || increase_version $@

if [ $? -ne 0 ];then
    echo "Error increasing version."
fi
