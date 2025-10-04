#!/usr/bin/env bash

dir="$HOME/test"
logfile="/var/tmp/logging.log"
dirnum="0"
filenum="0"

get_timestamp() {
  timestamp=$(date +"%Y_%m_%d__%H:%M:%S ##########")
}

logging() {
  local dir
  echo "Starting logging"
  echo "Creating logfile if nessesery"
  if [[ ! -f "$logfile" ]]; then
    echo "Logfile will be created"
    dir=$(dirname "$logfile")
    if [[ ! -d "$dir" ]]; then
      mkdir -p "$dir" || exit 1
    fi
    touch "$logfile" || exit 1
  else
    echo "$logfile exists"
  fi
  get_timestamp
  echo "$timestamp first entry" | tee -a "$logfile"
}

handling() {
  local error
  error="$1"
  get_timestamp
  case $error in
  0) echo "$timestamp Script ended as planned" | tee -a "$logfile" ;;
  1) echo "$timestamp something happend with the logfile" ;;
  2) echo "$timestamp ended after Help" | tee -a "$logfile" ;;
  *) echo "$timestamp Unknown error: $error" | tee -a "$logfile" ;;
  esac
}

finddirs() {
  get_timestamp
  dirnum=$(find "$dir" -type d -iname "*" | wc -l) || exit 2
  echo "$timestamp directorys found $dirnum" | tee -a "$logfile"
}

findfile() {
  get_timestamp
  filenum=$(find "$dir" -type f -iname "*" | wc -l) || exit 3
  echo "$timestamp files found $filenum" | tee -a "$logfile"
}

checkarg() {
  get_timestamp
  OPTERR=0
  while getopts "p:h" opt; do
    case $opt in
    p)
      p_arg="$OPTARG"
      echo "$timestamp -p was added with $p_arg"
      ;;
    h)
      tee -a "$logfile" <<EOF
-h help was selected
$dir will be searched
the count of the files and dirs 
will be printed
-p /path/
/path/ will be searched 
the count of the files and dirs 
will be printed 
logging will be in $logfile
EOF
      exit 2
      ;;
    \?) echo "$timestamp Unvalid argument" | tee -a "$logfile" ;;
    :) echo "$timestamp Option needs an argumen" | tee -a "$logfile" ;;
    esac
  done
  [[ -n "$p_arg" ]] && dir=$p_arg
}

trap 'handling $?' EXIT

logging
checkarg "$@"
finddirs
findfile

get_timestamp
echo "$timestamp $dir was searched, $dirnum and $filenum found" | tee -a "$logfile"
