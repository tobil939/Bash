#!/bin/bash

path="$HOME/Documents/test"
logfile="rename.log"
prefix="backup_"
counter="1"
namebase=""
#linenum=""

# changing into path
cdpath() {
  if [[ ! -e $path ]]; then
    mkdir -p "$path"
    echo "$path was created"
  else
    echo "$path exists"
  fi
  cd "$path" || exit
}

# creating and checking Logfile
mklogfile() {
  if [[ -n $logfile ]]; then
    echo "Logfile is not empty"
  elif [[ -z $logfile ]]; then
    echo "Logfile is empty"
  elif [[ ! -f $logfile ]]; then
    touch "$logfile" || echo "Logfile was created"
  else
    exit 1
  fi
}

changing() {
  for file in "$path"/*.txt; do
    [[ -f $file ]] || continue
    namebase=$(basename "$file")
    echo "$namebase found"
    newname="$prefix""$namebase"
    mv "$file" "$newname"
    echo "$file was renamed to $newname"
    echo "no: $counter changed name: $newname" >>"$logfile"
    ((counter++))
  done
}

# Maine
echo "Counter: $counter"
echo "checking Path"
cdpath
echo "checking Logfile"
mklogfile
echo "changing Files"
changing
echo "Counter: $counter"
