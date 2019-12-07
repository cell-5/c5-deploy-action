#!/bin/bash
set -euxo pipefail

setupSSH(){
    SSH_PATH="$HOME/.ssh" && mkdir -p "$SSH_PATH" && touch "$SSH_PATH/known_hosts"
    echo "$INPUT_KEY" > "$SSH_PATH/deploy_key"
    chmod 700 "$SSH_PATH" && chmod 600 "$SSH_PATH/known_hosts" "$SSH_PATH/deploy_key"
    eval $(ssh-agent)
    ssh-add "$SSH_PATH/deploy_key"
    ssh-keyscan -t rsa $INPUT_HOST >> "$SSH_PATH/known_hosts"
}

run_rsync(){
    sh -c "rsync $INPUT_ARGS -e 'ssh -i $SSH_PATH/deploy_key -o StrictHostKeyChecking=no -p $INPUT_PORT' $GITHUB_WORKSPACE$INPUT_SOURCE $INPUT_USER@$INPUT_HOST:$INPUT_DESTINATION"
}

executeSSH() {
  local LINES=$1
  local COMMAND=""
  local COMMANDS=""

  while IFS= read -r LINE; do
    LINE=$(eval 'echo "$LINE"')
    LINE=$(eval echo "$LINE")
    COMMAND=$(echo $LINE)

    if [ -z "$COMMANDS" ]; then
      COMMANDS="$COMMAND"
    else
      COMMANDS="$COMMANDS;$COMMAND"
    fi
  done <<< $LINES

  echo "$COMMANDS"
  ssh -o StrictHostKeyChecking=no -p ${INPUT_PORT:-22} $INPUT_USER@$INPUT_HOST "$COMMANDS"
}

setupSSH
echo "+++++++++++++++++++RUNNING BEFORE SSH+++++++++++++++++++"
executeSSH "$INPUT_SSH_BEFORE"
echo "+++++++++++++++++++DONE RUNNING BEFORE SSH+++++++++++++++++++"INPUT_SSH_BEFORE

echo "+++++++++++++++++++RUNNING rsync+++++++++++++++++++"
run_rsync
echo "+++++++++++++++++++DONE RUNNING rsync+++++++++++++++++++"

echo "+++++++++++++++++++RUNNING AFTER SSH+++++++++++++++++++"
executeSSH "$INPUT_SSH_AFTER"
echo "+++++++++++++++++++DONE RUNNING AFTER SSH+++++++++++++++++++"