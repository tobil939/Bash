#!/bin/bash

path="${1:-$HOME/Documents/test}"
log_file="$path/array_report.log"
empty_files="$path/empty_files"
non_empty_files="$path/non_empty_files"
filearray=()
counter="0"
counterempty="0"

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
  if [[ -d "$empty_files" ]]; then
    echo "empty_files exists"
  else
    mkdir -p "$empty_files"
    echo "empty_files was created"
  fi
  if [[ -d "$non_empty_files" ]]; then
    echo "non_empty_files exists"
  else
    mkdir -p "$non_empty_files"
    echo "non_empty_files was created"
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

findfiles() {
  for file in "$path"/*.txt; do
    [[ -f $file ]] || continue
    filearray+=("$file")
    echo "$file was found and added to the array" | tee -a "$log_file"
  done
}

checkempty() {
  for item in "${filearray[@]}"; do
    if [[ -z "$item" ]]; then
      ((counterempty++))
      echo "$item is empty No.: $counterempty" | tee -a "$log_file"
      mv "$item" "$empty_files/$item"
    elif [[ -n "$item" ]]; then
      ((counter++))
      echo "$item is not empty No.: $counter" | tee -a "$log_file"
      mv "$item" "$non_empty_files/$item"
    else
      echo "$item something is wrong" | tee -a "$log_file"
      exit 1
    fi
  done
}

checkpath
mkdirs
mkfiles
findfiles
checkempty
echo "$counterempty are empty, $counter are not" | tee -a "$log_file"
