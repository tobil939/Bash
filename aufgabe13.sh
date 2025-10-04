#!/usr/bin/env bash

verbosmode=false

path=$(pwd)
numfile=""
subdir=""
size=""
logfile="/var/log/mylogs/logging.log"

handling() {
  local error
  error="$1"

  get_timestamp
  case $error in
  0) echo "$timestamp everthing went as planed" ;;
  1) echo "$timestamp path to logfile cannot be created" ;;
  2) echo "$timestamp logfile cannot be created" ;;
  3) echo "$timestamp unknown argument" ;;
  4) echo "$timestamp arguement is needed" ;;
  *) echo "$timestamp unknown error $error" ;;
  esac
}

get_timestamp() {
  timestamp=$(date +"%Y.%m.%d %H:%M:%S")
}

logging() {
  logpath=$(dirname "$logfile")
  if [[ -d "$logpath" ]]; then
    verbose "$logpath exists"
  else
    verbose "$timestamp $logpath will be created"
    mkdir -p "$logpath" || exit 1
  fi
  if [[ -f "$logfile" ]]; then
    verbose "$logfile exists and will be cleared"
    rm -rf "$logfile"
    touch "$logfile" || exit 2
  else
    verbose "$logfile will be created"
    touch "$logfile" || exit 2
  fi
}

verbose() {
  local message
  message="$1"
  get_timestamp
  if [[ $verbosemode == true ]]; then
    echo "$timestamp $message" | tee -a "$logfile"
  fi
}

checkarg() {
  while getopts "vhp:" opt; do
    case $opt in
    v)
      verbosemode=true
      verbose "verbose mode activated"
      verbose "Script started"
      ;;
    h)
      cat <<EOF
### Help Page ### 
-v to activat verbose mode 
-h to show the help page 
-p /path/ to add the working directory
Script will show the number of files in 
the working directory.
Number of the sub directories.
Total size of the working directory. 
#################
EOF
      exit 0
      ;;
    p)
      path="$OPTARG"
      verbose "$OPTARG was added as working directory"
      ;;
    \?) echo "unvalid argumetn" || exit 3 ;;
    :) echo "argument needed" || exit 4 ;;
    esac
  done
}

getsize() {
  get_timestamp
  size=$(du -sb "$path")
  verbose "total size of $path is $size"
}

getnumfile() {
  get_timestamp
  numfile=$(find "$path" -type f -name "*" | wc -l)
  verbose "total count of files in $path is $numfile"
}

getnumdir() {
  get_timestamp
  subdir=$(find "$path" -type d -name "*" | wc -l)
  ((subdir = subdir - 1))
  verbose "total count of directories in $path is $subdir"
}

showresult() {
  get_timestamp
  echo "Verzeichnis: $path"
  echo "Dateien: $numfile"
  echo "Unterordner: $subdir"
  echo "Gesamtgröße: $size"
}

trap 'handling $?' EXIT

checkarg "$@"
logging
getsize
getnumfile
getnumdir
showresult
verbose "Script ended"
