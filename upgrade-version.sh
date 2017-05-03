#!/bin/sh
PROJECT_NAME=$1
PART=$2
WORKSPACE_DIR=$3

if [[ "$#" < 2 ]]; then
   echo "Please provide a project name and part(major|minor|patch)."	 
else
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
     echo "Current version $CURRENT_VERSION"
     echo "Project name is $PROJECT_NAME"
     echo "Workspace $WORKSPACE_DIR" 
     sed "s/VERSION/$CURRENT_VERSION/g;s/WORKSPACE/${WORKSPACE_DIR//\//\\/}/g" ~/.bumpversiontemplate.cfg  > "$CONFIG_FILE"
     echo "bumpversion —-config-file $CONFIG_FILE $PART" 
     bumpversion --config-file "$CONFIG_FILE"  "$PART" --verbose
     rm "$CONFIG_FILE"
  fi
fi
