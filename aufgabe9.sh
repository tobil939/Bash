#!/bin/bash

# Variabels
timestamp=""
finds={}

# Paths
logfile="$HOME/test/log/categorization.log"
searchpath="$HOME/test/docs"
firstpath="$HOME/test/docs/technik"
secondpath="$HOME/test/docs/persönlich"
thirdpath="$HOME/test/docs/andere"

# Errorhandling
handling() {
  local error
  error="$?"

  case $error in
  0) echo "Everything is good!" ;;
  1) echo "Problems with creating Logfile" ;;
  2) echo "Nothing was found" ;;
  3) echo "Path does not exitst" ;;
  4) echo " " ;;
  esac
}

makepath() {
  [[ ! -d "$searchpath" ]] || exit 3

  if [[ -d "$firstpath" ]]; then
    echo "$timestamp $firstpath exists"
  else
    mkdir -p "$firstpath"
    echo "$timestamp $firstpath will be created"
  fi
  [[ ! -d "$firstpath" ]] || exit 3

  if [[ -d "$secondpath" ]]; then
    echo "$timestamp $secondpath exists"
  else
    mkdir -p "$secondpath"
    echo "$timestamp $secondpath will be created"
  fi
  [[ ! -d "$secondpath" ]] || exit 3

  if [[ -d "$thirdpath" ]]; then
    echo "$timestamp $thirdpath exists"
  else
    mkdir -p "$thirdpath"
    echo "$timestamp $thirdpath will be created"
  fi
  [[ ! -d "$thirdpath" ]] || exit 3
}

logini() {
  local file
  local path
  file=$(basename "$logfile")
  path=$(dirname "$logfile")

  timestamp=$(date +"%Y_%M_%D %H:%M:%S")

  # creating Logfile
  if [[ -d "$path" ]]; then
    echo "$path is allready existing"
  else
    echo "$path will be created"
    mkdir -p "$path"
  fi

  [[ ! -d "$path" ]] || exit 1

  cd "$path" || exit 1

  if [[ -f "$file" ]]; then
    echo "$file is allready existing"
  else
    echo "$file will be created"
    touch "$file"
  fi

  [[ ! -f "$file" ]] || exit 1

  echo "$timestamp logging started" >>"$logfile"
}

findings() {
  mapfile -d '' finds < <(find "$searchpath" -type f -iname "*.txt" -size -1M)
  [[ ${#finds[@]} -ne 0 ]] || exit 2
  echo "$timestamp Something was found"
}

grepping() {
  local file

  for file in "${finds[@]}"; do
    if grep -qiE "server|network|database" "$file"; then
      mv "$file" "${firstpath}${file}"
      echo "$timestamp $file moved to $firstpath" >>"$logfile"
    elif grep -qiE "diary|note|personal" "$file"; then
      mv "$file" "${secondpath}${file}"
      echo "$timestamp $file moved to $firstpath" >>"$logfile"
    else
      mv "$file" "${thirdpath}${file}"
      echo "$timestamp $file moved to $firstpath" >>"$logfile"
    fi
  done
}

evaling() {
  local counttechnik
  local countpersoenlich
  local countanders

  counttechnik=$(find "$firstpath" -type f | wc -l)
  countpersoenlich=$(find "$secondpath" -type f | wc -l)
  countanders=$(find "$thirdpath" -type f | wc -l)

  echo "$timestamp Technik $counttechnik where found" | tee -a "$logfile"
  echo "$timestamp Persönlich $countpersoenlich where found" | tee -a "$logfile"
  echo "$timestamp Andere $countanders where found" | tee -a "$logfile"
}

# Main
logini
echo "$timestamp first log entry" >>"$logfile"
cd "$searchpath"
makepath
findings
grepping
evaling
trap handling EXIT
