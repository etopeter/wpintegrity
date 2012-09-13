#!/bin/bash
#
#
# wpintegrity.sh: Simple website integrity checker
#
# Piotr Strzyzewski
# github: https://github.com/etopeter

# Global Declarations
# ---------------------------------------
declare -rx SCRIPT=${0##*/}                   # script name

# Settings
# ---------------------------------------
declare -r REMOTE_HOST="phobos"               # remote IP or ~/.ssh/config alias
declare -r RH_SAVE_PATH="/home/tc/"           # Where to save templorary backup file on remote host ending with /
declare -r RH_BACKUP_DIR="/usr/local/html"    # remote path where to save templorary backup file
declare -r SCRIPT_PATH="/Users/Pio/development/wordpress/" # this script absolute local path ending with /

declare -rx ssh="/usr/bin/ssh"
declare -rx scp="/usr/bin/scp"
declare -rx tar="/usr/bin/tar"
declare -rx diff="/usr/bin/diff"
declare -rx mtree="/usr/sbin/mtree"

# --------------------------------------
# Do not change below
# --------------------------------------

# Usage/Help
#
if [ $# -gt 0 ] ; then
   if [ "$1" = "-h" -o "$1" = "--help" ] ; then
      printf "%s\n" "$SCRIPT:$LINENO: Simple website integrity checker"
      printf "%s\n" "No parameters"
      printf "\n"
      exit 0
   fi
fi

if [ ! -x "$ssh" ] ; then
   printf "%s\n" "$SCRIPT:$LINENO: Can't find $ssh" >&2
   exit 192
fi
if [ ! -x "$scp" ] ; then
   printf "%s\n" "$SCRIPT:$LINENO: Can't find $scp" >&2
   exit 192
fi
if [ ! -x "$diff" ] ; then
   printf "%s\n" "$SCRIPT:$LINENO: Can't find $diff" >&2
   exit 192
fi
if [ ! -x "$tar" ] ; then
   printf "%s\n" "$SCRIPT:$LINENO: Can't find $tar" >&2
   exit 192
fi
if [ ! -x "$mtree" ] ; then
   printf "%s\n" "$SCRIPT:$LINENO: Can't find $mtree" >&2
   exit 192
fi



# Generate backup filename
declare -r BACKUP_FILE=`date +%Y-%m-%d-%ss_backup.tar.gz`

# Cleaning up the workspace
if test -d "$SCRIPT_PATH"tmp; then
   printf "removing temp files\n"
   rm -rf "$SCRIPT_PATH"tmp
   mkdir "$SCRIPT_PATH"tmp

else
   mkdir "$SCRIPT_PATH"tmp
fi

if test -f "$SCRIPT_PATH"hashes_latest.txt; then
   mv "$SCRIPT_PATH"hashes_latest.txt "$SCRIPT_PATH"hashes_old.txt
fi


# FULLBACKUP_MODE
#
# Full backup method via SCP and tar

function fullbackup_mode {
printf "%s\n" "Using full backup" >&2
printf "%s\n" "Generating remote backup..." >&2
ssh "$REMOTE_HOST" tar -czf "$RH_SAVE_PATH$BACKUP_FILE $RH_BACKUP_DIR"

printf "%s\n" "Downloading backup file" >&2
scp "$REMOTE_HOST:$RH_SAVE_PATH$BACKUP_FILE" "$SCRIPT_PATH"tmp/"$BACKUP_FILE"

printf "%s\n" "Cleaning up remote backup" >&2
ssh "$REMOTE_HOST" rm "$RH_SAVE_PATH$BACKUP_FILE"

printf "%s\n" "Uncompressing backup file..." >&2
cd "$SCRIPT_PATH"tmp
tar -zxf "$SCRIPT_PATH"tmp/"$BACKUP_FILE"

rm "$SCRIPT_PATH"tmp/"$BACKUP_FILE"

printf "%s\n" "Generating new hashes..." >&2
mtree -c -f "$SCRIPT_PATH"tmp"$RH_BACKUP_DIR" -K sha256digest > "$SCRIPT_PATH"hashes_latest.txt

if test -f "$SCRIPT_PATH"hashes_old.txt; then
   printf "%s\n" "Comparing to last snapshot: "
   declare -r CHANGES_FOUND=`mtree -f "$SCRIPT_PATH"hashes_old.txt -p "$SCRIPT_PATH"tmp -K sha256digest|grep SHA-256|wc -l`
   printf "%s\n" "$CHANGES_FOUND changed files found." >&2
   mtree -f "$SCRIPT_PATH"hashes_old.txt -p "$SCRIPT_PATH"tmp -K sha256digest|grep changed
fi
}

# REMOTEMTREE_MODE
#
# Only copy mtree output (fast)

function remotemtree_mode {
printf "%s\n" "Using remote mtree" >&2
printf "%s\n" "Generating hashes on remote host..." >&2
ssh "$REMOTE_HOST" mtree -c -f "$RH_BACKUP_DIR" -K sha256digest > "$RH_SAVE_PATH"hashes_last.txt

printf "%s\n" "Downloading hashes file" >&2
scp "$REMOTE_HOST:$RH_SAVE_PATH"hashes_last.txt "$SCRIPT_PATH"hashes_last.txt

printf "%s\n" "Cleaning up remote hashes" >&2
ssh "$REMOTE_HOST" rm "$RH_SAVE_PATH"hashes_last.txt

printf "%s\n" "Comparing to last snapshit:"
   declare -r CHANGES_FOUND=`diff -n "$SCRIPT_PATH"hashes_last.txt "$SCRIPT_PATH"hashes_old.txt |grep sha256|wc -l`
   printf "%s\n" "$CHANGES_FOUND changed files found." >&2
   diff -n "$SCRIPT_PATH"hashes_last.txt "$SCRIPT_PATH"hashes_old.txt |grep size

}

declare -t fullbackup_mode
declare -t remotemtree_mode

# Check if remote host has mtree
declare -r REMOTE_MTREE=`ssh "$REMOTE_HOST" type -P mtree &>/dev/null && echo "Found" || echo "Not Found"`

if [ "$REMOTE_MTREE" = "Found" ] ; then
   remotemtree_mode
else
   fullbackup_mode
fi





