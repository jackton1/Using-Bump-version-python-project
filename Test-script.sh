increase_version (){
  PROJECT_NAME=${@:${#@}}  

  HELP="\nUsage -h For Help options:\n
        \tOptions [-p][part(major|minor|patch)] [-t|-m] Optional [-w][WORKSPACE_PATH] [-c][CONFIG_FILE] projectname\n\t\t-t : Test Run\n\t\t-m : Main Run\n\t\t-w : Path to Workspace directory\n\t\t-c : Path the config file"

  if [ $# -lt 2 ]; then 
      echo "$HELP" 
      return 0
  fi

  while getopts 'tmhp:c:w:v' flag; do
      case "${flag}" in 
        t) ARGS="--dry-run" ;;
        h) echo "$HELP" ;;
        p) PART=${OPTARG} ;;
        m) ARGS="--list" ;;
        c) CONFIG_FILE="${OPTARG:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}" ;;
        w) WORKSPACE_DIR="${OPTARG:-$HOME/workspace/$PROJECT_NAME}" ;;
        *) echo "Invalid arguments used. Use [-h] for usage. valid options [-t|-m|-c]" return 1 ;;
      esac 
      echo "$2, $3, $4"
  done
  echo "$CONFIG_FILE, $PROJECT_NAME"
  return 1
  if [ ! -f "$CONFIG_FILE" ]; then 
    echo "Invalid path to config file using option [-c][CONFIG_FILE]" 
    return 1 
  fi 
      
  if [[ ! -d "$WORKSPACE_DIR" ]]; then
     echo "No workspace directory exist in path $WORKSPACE_DIR"
  else 
     if [ ! -f "$WORKSPACE_DIR/setup.py" ]; then 
       echo "setup.py file not found in $WORKSPACE_DIR"
       echo "Checking mainline directory"
       WORKSPACE_DIR="$HOME/workspace/$PROJECT_NAME/mainline"
       if [ ! -f "$WORKSPACE_DIR/setup.py" ]; then
          echo "Could not find the setup.py in $WORKSPACE_DIR" 
          exit 0
       fi
     fi 
  fi

  if [[ "$PROJECT_NAME" && "$WORKSPACE_DIR" ]];then
     CURRENT_VERSION=$(sed -n "s/version='//1p" "$WORKSPACE_DIR/setup.py" | sed -n "s/',//1p" | xargs) 
     CONFIG_FILE="$HOME/.bumpversion$PROJECT_NAME.cfg"
     echo "Current version $CURRENT_VERSION"
     echo "Project name is $PROJECT_NAME"
     echo "Workspace $WORKSPACE_DIR"
     echo "Script directory $CONFIG_FILE $ABSOLUTE_PATH"
     sed "s/VERSION/$CURRENT_VERSION/g;s/WORKSPACE/${WORKSPACE_DIR//\//\\/}/g" "${CONFIG_FILE}/.bumpversiontemplate.cfg"  > "$CONFIG_FILE"
     echo "bumpversion —-config-file $CONFIG_FILE $PART" 
     bumpversion --config-file "$CONFIG_FILE"  "$PART" --verbose "$ARGS"
     rm "$CONFIG_FILE"
  fi

}
