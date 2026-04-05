#!/bin/bash

###############################################################################
# Robust Linux Backup Script (Bash 3+)
# - Exclusions defined as simple patterns
# - Compression: zstd (preferred) → pigz → gzip
# - Rotation: Keeps only the last 4 backups per type
###############################################################################

set -e
set -o pipefail

BACKUP_DIR="/backup"
LOG_FILE="/var/log/spindlecrank/backup-$(date +%Y%m%d-%H%M%S).log"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
KEEP_COUNT=4

log() {
  local level="$1"; shift
  local msg="$*"
  printf "[%s] [%s] %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$level" "$msg" | tee -a "$LOG_FILE"
}

error_handler() {
  local code=$?
  log "FATAL" "Script failed at line $1 with exit code $code"
  exit "$code"
}

trap 'error_handler $LINENO' ERR

log INFO "=== Backup run started: $TIMESTAMP ==="
mkdir -p "$BACKUP_DIR"

# --- Compression Selection ---
COMPRESS_CMD=""
COMPRESS_EXT=""
if command -v zstd >/dev/null 2>&1; then
  COMPRESS_CMD="zstd -T0 -19"
  COMPRESS_EXT="zst"
elif command -v pigz >/dev/null 2>&1; then
  COMPRESS_CMD="pigz -9"
  COMPRESS_EXT="gz"
else
  COMPRESS_CMD="gzip -9"
  COMPRESS_EXT="gz"
fi
log INFO "Using $COMPRESS_EXT compression"

# --- Paths & Exclusions ---
PATHS="bin etc music opt var usr home root usr/local srv volumes/docker"
TYPES="bin etc music opt var usr home root usrlocal srv vdocker"

EXCLUDE_PATTERNS=("/proc" "*.data" "/sys" "/dev" "/tmp" "/var/lib/docker" "/run" "/media" "/mnt" "*.sock" "*.pid")
EXCLUDE_ARGS=""
for pat in "${EXCLUDE_PATTERNS[@]}"; do
  EXCLUDE_ARGS="$EXCLUDE_ARGS --exclude='$pat'"
done

success=0
fail=0

# --- Main Backup Loop ---
i=1
for path in $PATHS; do
  type=$(echo $TYPES | cut -d' ' -f$i)
  i=$((i+1))

  src="/$path"
  archive="$BACKUP_DIR/${type}-${TIMESTAMP}.tar.$COMPRESS_EXT"

  if [ ! -e "$src" ]; then
    log WARN "Source missing, skipping: $src"
    fail=$((fail+1))
    continue
  fi

  log INFO "Backing up $src..."
  tmp_tar="$archive.tar"
  
  if tar_output=$(eval "tar -c --one-file-system $EXCLUDE_ARGS \"$src\"" 2>&1 > "$tmp_tar"); then
    if $COMPRESS_CMD < "$tmp_tar" > "$archive" 2>>"$LOG_FILE"; then
      rm -f "$tmp_tar"
      log SUCCESS "$type complete: $(du -h "$archive" | cut -f1)"
      success=$((success+1))
      
      # --- ROTATION ROUTINE ---
      # Finds files matching the current type, sorts by time (newest first), 
      # and deletes everything after the KEEP_COUNT.
      log INFO "Rotating old backups for $type..."
      ls -1t "$BACKUP_DIR/${type}-"*.tar.* 2>/dev/null | tail -n +$((KEEP_COUNT + 1)) | while read -r old_backup; do
        log INFO "Deleting old backup: $old_backup"
        rm -f "$old_backup"
      done
      
    else
      log ERROR "Compression failed for $type"
      rm -f "$tmp_tar" "$archive"
      fail=$((fail+1))
    fi
  else
    log ERROR "TAR failed for $type"
    printf '%s\n' "$tar_output" | sed 's/^/  /' >> "$LOG_FILE"
    rm -f "$tmp_tar"
    fail=$((fail+1))
  fi
done

log INFO "=== Backup complete. Success: $success | Fail: $fail ==="
