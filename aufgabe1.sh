#!/bin/bash
path="$HOME/Documents/test"
log_file="report.log"
moveto="$HOME/Documents/test/big"

linenum="0"
maxnum="50"
size_true="0"

name=" "

counter="0"

cd $path

echo "$counter Dateien wurden verschoben"

numcount() {
  linenum=$(wc -l "$file" | awk '{print $1}')
}

namebase() {
  name=$(basename "$file")
}

bigname() {
  if [[ linenum -gt maxnum ]]; then
    size_true="1"
  else
    size_true="0"
  fi
}

writelog() {
  if [[ $size_true == 1 ]]; then
    echo "$name $linenum verschoben" >>"$log_file"
  else
    echo "$name $linenum" >>"$log_file"
  fi
}

movingto() {
  if [[ $size_true == 1 ]]; then
    mv $file "$moveto"/"$file"
    echo "$file verschoben"
    ((counter++))
  fi
}

if [ ! -f "$log_file" ]; then
  echo "Log-File nicht vorhanden, wird angelegt"
  touch "$log_file"
fi

for file in "$path"/*.txt; do
  echo "Gefunde Datei $file"
  numcount
  namebase
  bigname
  writelog
  movingto
done
