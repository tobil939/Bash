#!/bin/bash

# Variablen definieren
path="$HOME/test"
logfile="$path/error_report.log"
today=$(date +"%Y-%m-%d")
lastmodded=7
searchword="error"
suffix=".txt"
file_count=0
total_errors=0
files=()

# Log-Datei initialisieren
startlog() {
  if [[ -d "$path" ]]; then
    echo "$path exists" | tee -a "$logfile"
  else
    echo "$path will be created" | tee -a "$logfile"
    mkdir -p "$path" || {
      echo "Failed to create $path" | tee -a "$logfile"
      exit 1
    }
  fi

  if [[ -f "$logfile" ]]; then
    echo "Logfile exists" | tee -a "$logfile"
  else
    echo "Logfile will be created" | tee -a "$logfile"
    touch "$logfile" || {
      echo "Failed to create $logfile" | tee -a "$logfile"
      exit 1
    }
  fi
  echo "$(date +"%Y-%m-%d %H:%M:%S") ### Untersuchung des Verzeichnisses $path" | tee -a "$logfile"
}

# Dateien finden und in Array speichern
finding() {
  mapfile -d '' files < <(find "$path" -type f -mtime -"$lastmodded" -iname "*$suffix" -print0)

  if [[ ${#files[@]} -eq 0 ]]; then
    echo "$(date +"%Y-%m-%d %H:%M:%S") ### Keine .txt-Dateien in den letzten $lastmodded Tagen gefunden." | tee -a "$logfile"
    return
  fi

  grepping
}

# Textsuche in Dateien
grepping() {
  for file in "${files[@]}"; do
    local filename
    filename=$(basename "$file")
    local error_count
    error_count=$(grep -ic "$searchword" "$file")

    if [[ $error_count -gt 0 ]]; then
      ((file_count++))
      ((total_errors += error_count))
      logentry "$file" "$filename" "$error_count"
    fi
  done

  if [[ $file_count -eq 0 ]]; then
    echo "$(date +"%Y-%m-%d %H:%M:%S") ### Keine .txt-Dateien mit '$searchword' in den letzten $lastmodded Tagen gefunden." | tee -a "$logfile"
  else
    echo "$(date +"%Y-%m-%d %H:%M:%S") ### Gesamt: $file_count Dateien mit '$searchword' gefunden, $total_errors Vorkommen insgesamt." | tee -a "$logfile"
  fi
}

# Log-Eintrag erstellen
logentry() {
  local file="$1"
  local filename="$2"
  local error_count="$3"

  echo "$(date +"%Y-%m-%d %H:%M:%S") ### Datei: $file" | tee -a "$logfile"
  grep -in "$searchword" "$file" | while IFS= read -r line; do
    echo "Zeile $line" | tee -a "$logfile"
  done
  echo "Anzahl der '$searchword'-Vorkommen in $file: $error_count" | tee -a "$logfile"
  echo "---" | tee -a "$logfile"
}

# Hauptprogramm
startlog || exit 1
finding || exit 2
