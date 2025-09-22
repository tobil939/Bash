#!/bin/bash

path="$HOME/Documents/test"
log_file="size_report.log"
large_files=""
small_files=""
filesize="100"
countersmall="0"
counterlarge="0"
size="0"

checkpath() {
  if [[ -d "$path" ]]; then
    echo "path exists"
  else
    mkdir -p "$path"
    echo "path was created"
  fi
  cd "$path" || exit
}

mkdirs() {
  if [[ -d "$large_files" ]]; then
    echo "large_files exists"
  else
    mkdir -p "$large_files"
    echo "large_files was created"
  fi
  if [[ -d "$small_files" ]]; then
    echo "small_files exists"
  else
    mkdir -p "$small_files"
    echo "small_files was created"
  fi
}

mkfiles() {
  if [[ -f "$log_file" ]]; then
    echo "Logfile exists"
  else
    touch "$log_file"
    echo "Logfile was created"
  fi
}

checkfiles() {
  for file in "$path"/*.txt; do
    [[ -f $file ]] || continue
    echo "$file found"
    size=$(wc -c "$file" | awk '{print $1}')

    if [[ $size -lt $filesize ]]; then
      ((countersmall++))
      echo "$file is less then 100 Bytes, $size"
      echo "No.: $countersmall File: $file" >>"$log_file"
      mv "$file" "$small_files/$file"
    elif [[ $size -eq $filesize ]]; then
      ((countersmall++))
      echo "$file is 100 Bytes big"
      echo "No.: $countersmall File: $file" >>"$log_file"
      mv "$file" "$small_files/$file"
    elif [[ $size -gt $filesize ]]; then
      ((counterlarge++))
      echo "$file is bigger then 100 Bytes, $size"
      echo "No.: $counterlarge File: $file" >>"$log_file"
      mv "$file" "$large_files/$file"
    else
      echo "something is wronge"
      exit 1
    fi
  done
}

checkpath
mkdirs
mkfiles
checkfiles

echo "$counterlarge are bigger then 100 Bytes" | tee -a "log_file"
echo "$countersmall are smaller or 100 Bytes" | tee -a "log_file"
