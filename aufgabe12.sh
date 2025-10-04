#!/usr/bin/env bash

verbose=false
path="$HOME/test/"
logfile="/var/log/mylogs/logging.log"

declare -a typearray
declare -a findings

handling() {
  local error
  error="$1"
  get_timestamp
  case $error in
  0) echo "$timestamp nothing wronge happend" | tee -a "$logfile" ;;
  *) echo "$timestamp unknown error $error" | tee -a "$logfile" ;;
  esac
}

helppage() {
  cat <<EOF
### Help Page begin ### 
-h opens the Help page 
-v activates the verbose mode 
-p /path/ to add the search path 
### Help Page end ###
EOF
  exit 0
}

get_timestamp() {
  timestamp=$(date +"%Y_%m_%d %H:%M:%S")
}

verbose() {
  get_timestamp
  [[ $verbose == true ]] && echo "$@" | tee -a "$logfile"
}

checkarg() {
  while getopts "p:vh" opt; do
    case $opt in
    v)
      verbose=true
      verbose "$timestamp verbose activated"
      ;;
    p)
      path="$OPTARG"
      verbose "$timestamp $path was added"
      ;;
    h) helppage ;;
    :) verbose "$timestamp Option needs an argument" ;;
    \?) verbose "$timestamp Unvalid argument" ;;
    esac
  done
}

logging() {
  dirname=$(dirname "$logfile")
  if [[ -f "$logfile" ]]; then
    verbose "$timestamp $logfile exists"
  else
    if [[ -d "$dirname" ]]; then
      verbose "$timestamp $dirname eixts"
    else
      mkdir "$dirname"
    fi
  fi
  get_timestamp
  verbose "$timestamp first entry "
}

findtypes() {
  get_timestamp
  mapfile -t typearray < <(find "$path" -type f -name "*.*" | awk -F. '{print $NF}' | sort -u)
}

trap 'handling $?' EXIT

verbose "$timestamp starting the script"
logging
checkarg "$@"
findtypes
echo "${typearray[@]}"
