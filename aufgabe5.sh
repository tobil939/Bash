#!/bin/bash

path="$HOME/test/bash_aufgabe"
today=$(date +"%Y-%m-%d")
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
tofolder="${path}/backup"
logfile="${tofolder}/${today}_log.log"
namebackup=""
namebase=""

checkdir() {
  if [[ -d "$path" ]]; then
    echo "$path exists" | tee -a "$logfile"
  else
    echo "$path will be created" | tee -a "$logfile"
    mkdir -p "$path" || exit
  fi
}

mkdirs() {
  if [[ -d "$tofolder" ]]; then
    echo "$tofolder exists" | tee -a "$logfile"
  else
    echo "$tofolder will be created" | tee -a "$logfile"
    mkdir -p "$tofolder" || exit
  fi
}

logstart() {
  touch "$logfile"
  echo "starting backup $timestamp" | tee -a "$logfile"
}

backupname() {
  namebase=$(basename "$file")
  namebackup="${tofolder}/${today}${namebase}.txt"
  return "$namebackup"
}

backupfiles() {
  for file in "$path"/*.txt; do
    [[ -f "$file" ]] || continue
    echo "$timestamp ### $file copied to backup" | tee -a "$logfile"
    backupname "$file"
    cp "${path}/${file}" "$namebackup" || exit
  done
}

main() {
  logstart
  checkdir
  cd "$path" || exit
  mkdirs
  backupfiles
  echo "$timestamp ### backup is done" | tee -a "$logfile"
}

# starting main programm
main
