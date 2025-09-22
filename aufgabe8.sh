#!/bin/bash

# Variabels
logfile="$HOME/test/logs1/log.log"
searchfile="$HOME/test/log"
grepbase="[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}"
grepwords1="INFO"
grepwords2="WARNING"
grepwords3="ERROR"
finds=()
greps=()
greps1=()
greps2=()
greps3=()

# Errorhandling
handler() {
  local error=$?
  case $error in
  0) ;;
  1) echo "File coud not be found, check rights" ;;
  2) echo "Directory coud not be found, check right" ;;
  3) echo "Notthing found" ;;
  4) ;;
  esac
}

# Logger
logging() {
  timestamp=$(date +"%Y_%m_%d %H:%M:%S")
  if [[ -f "$logfile" ]]; then
    echo "File exists"
  else
    echo "File will be created"
    mkdir -p "$logfile"
  fi
  [[ ! -f "$logfile" ]] || exit 1
  echo "First log entry $timestamp" >>"$logfile"
}

finding() {
  local file
  local arraylength
  mapfile -d '' finds < <(find -type f -iname "*.log" -mtime -30 -print0)
  arraylength="${#finds[@]}"
  [[ "$arraylength" -ne 0 ]] || exit 3
  echo "Log files found, modified in the last 30 days" >>"$logfile"
  for file in "${finds[@]}"; do
    echo "$file" >>"$logfile"
  done
}

grepping() {
  local file line
  for file in "${finds[@]}"; do
    while IFS= read -r line; do
      # Prüfen auf Zeitstempel
      if [[ $line =~ $grepbase ]]; then
        for word in "${grepwords[@]}"; do
          if [[ $line =~ $word ]]; then
            echo "[$word] $line" >>"$logfile"
          fi
        done
      fi
    done <"$file"
  done
}

# Main
logging
[[ ! -d "$searchfile" ]] || exit 2
grepping
trap handler EXIT
