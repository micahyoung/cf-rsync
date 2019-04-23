# rsync over cf ssh

## Requirements
* Linux/Mac workstation with rsync installed
* Cloud Foundry with Windows 2019 cells

## Usage 

### Debugging hwc apps
1. Push empty app from this repo
cf push my-rsync-app -p app -s windows2016 -b binary_buildpack -u none -c 'powershell Start-Sleep 99999' 

1. Download latest hwc 
curl -L https://github.com/cloudfoundry/hwc/releases/download/15.0.0/hwc.exe -o hwc.exe

1. Use rsync to copy app and hwc to cf instance
rsync --rsh="./cf-rsync-rsh.sh" -vr my-app my-rsync-app:app/
rsync --rsh="./cf-rsync-rsh.sh" -vr hwc.exe my-rsync-app:app/hwc.exe

1. Start hwc over cf ssh
cf ssh my-rsync-app -c 'app\hwc.exe -appRootPath app\my-app'

1. Visit the app URL in browser

1. Make changes to app repeat three prior steps to reload