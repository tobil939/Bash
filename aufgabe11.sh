#!/usr/bin/env bash

logfile="/var/log/mylogs/logging.log"
dir=$(pwd)

declare -A finds

get_timestamp() {
  timestamp=$(date +"%Y_%m_%d  %H:%M:%S ##########")
}

logging() {
  local dir
  dir=$(dirname "$logfile")

  if [[ -f "$logfile" ]]; then
    get_timestamp
    echo "$timestamp Logfile exists"
  else
    if [[ ! -d "$dir" ]]; then
      echo "$timestamp $dir will be created"
      mkdir -p "$dir" || exit 1
    fi
    echo "$timestamp Logfile will be created"
    touch "$logfile" || exit 2
  fi

  get_timestamp
  echo "$timestamp first entry" | tee -a "$logfile"
  [[ ! -f "$timestamp" ]] || exit 3
}

handling() {
  local error
  error="$1"

  get_timestamp
  case $error in
  0) echo "$timestamp everything went ok" | tee -a "$logfile" ;;
  1) echo "$timestamp directory for the Logfile can not be created" | tee -a "$logfile" ;;
  2) echo "$timestamp Logfile can not be created" | tee -a "$logfile" ;;
  3) echo "$timestamp $logfile does not existes" | tee -a "$logfile" ;;
  *) echo "$timestamp unknown Error $error" | tee -a "$logfile" ;;
  esac
}

checkarg() {
  OPTERR=0

  while getopts "p:h" opt; do
    case $opt in
    p)
      dir="$OPTARG"
      echo "$dir was admitted"
      ;;
    h)
      cat <<EOF
### Help Page ### 
-p /path/
will check for the 5 biggest files
whitout -p checks in the current directory
### Help Page ###
EOF
      ;;
    \?) echo "Unvalid argument" ;;
    :) echo "Option needs an argument" ;;
    esac
  done
}

findfile() {
  if [[ ! -d "$dir" ]]; then
    exit 4
  else
    mapfile -t -d '' horst < <(find "$dir" -type f -iname "*" -print0)
    for bunga in "${horst[@]}"; do
      get_timestamp
      #echo "$timestamp $bunga" | tee -a "$logfile"
      value=$(ls -l "$bunga" | awk '{print $5}')
      key="$bunga"
      finds["$key"]="$value"
    done
  fi
  for bunga in "${!finds[@]}"; do
    get_timestamp
    #echo "$timestamp $bunga ${finds[$bunga]}" | tee -a "$logfile"
  done
}

sortfile() {
  sorted=$(for key in "${!finds[@]}"; do
    echo "${finds[$key]} $key"
  done | sort -nr)

  echo "Die 5 größten Dateien:"
  echo "$sorted" | head -n 5
}

trap 'handling $?' EXIT
logging

get_timestamp
echo "$timestamp done" | tee -a "$logfile"
checkarg "$@"
findfile
sortfile
