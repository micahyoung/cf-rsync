#!/bin/bash

set -o errexit
set -o pipefail

rsync_app_name=$1
rsync_args="$3 $4 $5 $6 $7"
install_script_path="$(dirname $0)/remote-install-rsync-windows.ps1"
encoded_command=$(iconv -f utf8 -t utf16le $install_script_path | base64 -w0 | tr -d '\n')
exec cf ssh $rsync_app_name -c "IF EXIST deps\cf-rsync\rsync.bat ( deps\cf-rsync\rsync.bat $rsync_args ) ELSE ( powershell -EncodedCommand $encoded_command & deps\cf-rsync\rsync.bat $rsync_args )"
