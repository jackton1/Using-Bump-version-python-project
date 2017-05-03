#!/bin/sh
PROJECT_NAME=$1
PART=$2
WORKSPACE_DIR=$4
ARGS=$3

if [[ "$#" < 3 ]]; then
   echo "\nUsage projectname part(major|minor|patch) [-t|-m]"
   echo "\t-t : Test Run"
   echo "\t-m : Main Run"
else
  if [ "$ARGS" != "-t" || "$ARGS" != "-m"]; then
      echo "Invalid arguments used. specify either options [-t|-m]"
  elif [ "$ARGS" == "-t" ]; then
      ARGS="--dry-run"
  else
     ARGS="--list" 
  fi
  
  if [[ -z "$WORKSPACE_DIR" ]]; then
      WORKSPACE_DIR="$HOME/workspace/$PROJECT_NAME"
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
     SCRIPT_DIR=`dirname "$BASH_SOURCE"`
     echo "Current version $CURRENT_VERSION"
     echo "Project name is $PROJECT_NAME"
     echo "Workspace $WORKSPACE_DIR"
     echo "Script directory $SCRIPT_DIR"
     sed "s/VERSION/$CURRENT_VERSION/g;s/WORKSPACE/${WORKSPACE_DIR//\//\\/}/g" "${SCRIPT_DIR}/.bumpversiontemplate.cfg"  > "$CONFIG_FILE"
     echo "bumpversion —-config-file $CONFIG_FILE $PART" 
     bumpversion --config-file "$CONFIG_FILE"  "$PART" --verbose "$ARGS"
     rm "$CONFIG_FILE"
  fi
fi
