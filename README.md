# rsync over cf ssh

## Requirements
* Linux/Mac workstation with rsync installed
* Cloud Foundry (optionally, with Windows Server Core cells)

## Usage 

1. Ensure you are logged into a running Cloud Foundry
1. Ensure you have running app
1. Run your rsync command, using either script as the `rsh` option running app's name as the remote host name:
```sh
# list files in app directory
rsync --rsh="<./cf-rsh-linux.sh or ./cf-rsh-windows.sh>" <your app name>:app/

# alternative, use `RSYNC_RSH` environment variable
export RSYNC_RSH=<$PWD/cf-rsh-linux.sh or $PWD/cf-rsh-windows.sh>
rsync <your app name>:app/
```

## Examples

### Linux - modify existing app (ruby/nodejs/python)
1. Push app but override healthcheck and start command
    ```sh
    cf push my-rsync-app -p my-original-app/ -u none -c 'sleep 99999'
    ```

1. Make changes to local `my-original-app` directory

1. Use rsync to upload and overwrite app directory in CF instance
    ```sh
    rsync --rsh="./cf-rsh-linux.sh" --resursive --verbose  --delete my-original-app/ my-rsync-app:app
    ```

1. Visit the app URL in browser and see the updated content

* Note: apps languages/buildpacks must support dynamic code/content reloading. If not, the server process may need to be signalled or restarted to reload content.


### Windows - modify existing app (hwc)
1. Push app but override healthcheck and start command to ignore when `hwc.exe` 
    ```sh
    cf push my-rsync-app -p my-original-app/ -s windows2016 -b hwc_buildpack -u none -c 'powershell Start-Sleep 99999'
    ```

1. Make changes to local `my-original-app` directory (or republish from Visual Studio to app directory)

1. Use rsync to copy app directory to CF instance
    ```sh
    rsync --rsh="./cf-rsh-windows.sh" --resursive --verbose --delete my-original-app/ my-rsync-app:app
    ```

1. (Re)Start hwc over cf ssh
    ```sh
    cf ssh my-rsync-app -c 'taskkill /F /IM "hwc.exe" & app\.cloudfoundry\hwc.exe -appRootPath app'
    ```

1. Visit the app URL in browser and see the updated content

## Notes
* Restarting an app will discard all `rsync` changes and restore the app state to the original `cf push` state.
* Apps should be scaled to one instance before use.
* Windows containers do not contain a `rsync` binary so the `cf-rsh` script will download and extract an msys2 binary to `c:\Users\vcap\deps\cf-rsync\` from the repo on first connection and re-used.
