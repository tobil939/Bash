#!/bin/bash

workingpath="$HOME/test/logs"
logfile="$HOME/test/logs/loggins.log"
logsum="$HOME/test/logs/cleanup_summary.log"
word1="DEBUG"
word2="ERROR"
sufix=".cleaned"
finds=()

handler() {
  local error
  error="$?"

  case $error in
  0) echo "Everything went fine" ;;
  1) echo "Logging can't be initialized" ;;
  2) echo "Nothing was found" ;;
  3) echo "$word1 or $word2 where not found" ;;
  esac
}

logini() {
  local file
  local path
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")

  file=$(basename "$logfile")
  path=$(dirname "$logfile")

  if [[ -d "$path" ]]; then
    echo "Log Path exists"
  else
    mkdir -p "$path"
    echo "Log Path was created"
  fi

  [[ -d "$path" ]] || exit 1

  if [[ -f "$logfile" ]]; then
    echo "Log File exists"
  else
    touch "$logfile"
    echo "Log File was created"
  fi

  [[ -f "$logfile" ]] || exit 1

  file=$(basename "$logsum")
  path=$(dirname "$logsum")

  if [[ -f "$logsum" ]]; then
    echo "Log Sum File exists"
  else
    touch "$logsum"
    echo "Log Sum File was created"
  fi

  echo "$timestamp first log entry" >>"$logsum"
  echo "$timestamp first log entry" | tee -a "$logfile"
}

findings() {
  local length
  local countn
  local count1
  local count2
  local file

  mapfile -d '' finds < <(find "$workingpath" -type f -iname "*.log" -mtime +7 -print0)
  length=${#finds[@]}
  [[ "$length" -eq 0 ]] || exit 2
  echo "$timestamp $length many files where found" | tee -a "$logfile"

  for file in "${finds[@]}"; do
    countn=$(grep -ci "$word1" "$file")
    ((count1 = count1 + countn))
    [[ count1 -eq 0 ]] || exit 3
  done
  echo "$timestamp $count1 many files where found with $word1" | tee -a "$logfile"
  echo "$timestamp $count1 many files where found with $word1" >>"$logsum"

  for file in "${finds[@]}"; do
    countn=$(grep -ci "$word2" "$file")
    ((count2 = count2 + countn))
    [[ count2 -eq 0 ]] || exit 3
  done
  echo "$timestamp $count2 many files where found with $word2" | tee -a "$logfile"
  echo "$timestamp $count2 many files where found with $word2" >>"$logsum"
}

seddings() {
  local file
  for file in "${finds[@]}"; do
    sed -E "/$word1/Id" "$file" >"$file.$sufix"
    echo "$timestamp $file was changed" | tee -a "$logfile"
    echo "$timestamp $file was changed" >>"$logsum"
    stat -c "Name: %n | Size: %s | Datatype: %F" "$file" >>"$logsum"
  done
}

logini
findings
seddings
handler

trap handler EXIT
