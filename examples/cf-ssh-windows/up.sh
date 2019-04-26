#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

source env.sh

cf delete -f -r $APP_NAME > /dev/null

cf push $APP_NAME -p app/ -s windows2016 -b hwc_buildpack

HTTP_ROUTE_FQDN=$(cf app $APP_NAME | awk '/routes:/ {print $2}')

curl --fail $HTTP_ROUTE_FQDN || echo "404"

echo '<% response.write("Hello world!") %>' > app/default.asp

rsync --rsh="$(dirname $0)/../../cf-rsh-windows.sh" --recursive --delete --verbose --exclude="hwc.exe" app/ $APP_NAME:app

curl --fail $HTTP_ROUTE_FQDN && echo "200"

rm app/default.asp
