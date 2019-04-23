#!/bin/bash

set -o errexit
set -o pipefail

rsync_app_name=$1
rsync_args="$3 $4 $5 $6 $7"

encoded_command=$(iconv -f utf8 -t utf16le remote-install-rsync-windows.ps1 | base64 -w0 | tr -d '\n')
exec cf ssh $rsync_app_name -c "IF EXIST deps\rsync.bat ( deps\rsync.bat $rsync_args ) else ( powershell -EncodedCommand $encoded_command & deps\rsync.bat $rsync_args)"
