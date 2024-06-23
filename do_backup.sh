#!/bin/bash

BACKUP_DIR="/backup"
SHARE_DIR="/share/nano"

# Ensure target directory exists
mkdir -p "$SHARE_DIR"

# Copy files and subdirectories, skipping existing ones
rsync -av --ignore-existing "$BACKUP_DIR/" "$SHARE_DIR/"

# Delete files older than 4 days in backup directory
find "$BACKUP_DIR/" -type f -mtime +4 -delete

echo "Backup and cleanup complete."
