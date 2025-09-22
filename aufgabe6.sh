#!/bin/bash

path="$HOME/test"
logfile="$HOME/watch_dir/log.txt"
timestamp=$(date +"%Y-%m-%d_%H:%M:%S")
backup="$HOME/test/backup"
filename=""

logstart() {
  if [[ -f "$logfile" ]]; then
    echo "Logfile exists"
    echo "$timestamp starting checking for .txt files" >>"$logfile"
  else
    echo "Logfile will be created"
    touch "logfile" || exit
    echo "$timestamp starting checking for .txt files" >>"$logfile"
  fi
}

chekdir() {
  if [[ -e "$path" ]]; then
    echo "$path exists" | tee -a "$logfile"
  else
    echo "$path will be created" | tee -a "$logfile"
    mkdir -p "$path" || exit
  fi

  if [[ -e "$backup" ]]; then
    echo "$backup exists" | tee -a "$logfile"
  else
    echo "$backup will be created" | tee -a "$logfile"
    mkdir -p "$backup" || exit
  fi
}

check() {
  echo "$timestamp first check"
  cp "$path/"* "$backup/" || exit

  while true; do
    for file in "$path"/*.txt; do
      [[ -f "$file" ]] || continue

      filename=$(basename "$file")

      if [[ -e "${backup}/${filename}" ]]; then
        echo "$timestamp $filename is new" | tee -a "$logfile"
        cp "$file" "$backup/" || exit
        echo "$timestamp clearing backup folder" | tee -a "$logfile"
        rm -rf "$backup/"*
        echo "$timestamp creating updated backup" | tee -a "$logfile"
        cp "$path/"* "$backup/" || exit
      fi

      sleep 10
    done
  done
}

logstart
checkdir
check
