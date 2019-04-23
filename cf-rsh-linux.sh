#!/bin/bash

set -o errexit
set -o pipefail

rsync_app_name=$1
rsync_args="$3 $4 $5 $6 $7"
exec cf ssh $rsync_app_name -c "rsync $rsync_args"
