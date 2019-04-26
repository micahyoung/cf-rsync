#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

source env.sh

RSYNC_INTERNAL_PORT="8730"

cf delete -f -r $APP_NAME > /dev/null

cp "$(dirname $0)/../../remote-rsyncd-windows.ps1" app/

cat > app/.profile.bat <<EOF
START /B powershell c:\Users\vcap\app\remote-rsyncd-windows.ps1 -port $RSYNC_INTERNAL_PORT -username $RSYNC_USERNAME -password $RSYNC_PASSWORD
EOF

CF_SPACE=$(cf target | awk '/space:/ {print $2}')

cf push $APP_NAME -p app/ -s windows2016 -b hwc_buildpack --no-start

APP_GUID=$(cf app $APP_NAME --guid)
cf curl /v2/apps/$APP_GUID -X PUT -d "{\"ports\":[8080,$RSYNC_INTERNAL_PORT]}"

cf start $APP_NAME

TCP_FQDN_PORT=$(cf create-route $CF_SPACE $TCP_DOMAIN --random-port | awk '/has been created/ {print $2}')
TCP_FQDN=$(echo $TCP_FQDN_PORT | awk -F':' '{print $1}')
TCP_EXTERNAL_PORT=$(echo $TCP_FQDN_PORT | awk -F':' '{print $2}')

TCP_ROUTE_GUID=$(cf curl /v2/routes?q=port:$TCP_EXTERNAL_PORT | jq -r .resources[0].metadata.guid)

cf curl /v2/route_mappings -X POST -d "{\"app_guid\": \"$APP_GUID\", \"route_guid\": \"$TCP_ROUTE_GUID\", \"app_port\": $RSYNC_INTERNAL_PORT}"

HTTP_ROUTE_FQDN=$(cf app $APP_NAME | awk '/routes:/ {print $2}' | awk -F',' '{print $1}')

curl --fail $HTTP_ROUTE_FQDN || echo "404"

echo '<% response.write("Hello world!") %>' > app/default.asp

RSYNC_PASSWORD=$RSYNC_PASSWORD rsync --recursive --delete --verbose --exclude="hwc.exe" app/ $RSYNC_USERNAME@$TCP_FQDN::c/Users/vcap/app --port $TCP_EXTERNAL_PORT

curl --fail $HTTP_ROUTE_FQDN && echo "200"

rm app/remote-rsyncd-windows.ps1 app/default.asp
