# rsync over cf ssh

## Requirements
* Linux/Mac workstation with rsync installed
* Cloud Foundry with Windows 2019 cells

## Usage 

1. Ensure your logged into a running Cloud Foundry
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
1. Use rsync to fetch existing app directory from CF instance
    ```sh
    rsync --rsh="./cf-rsh-linux.sh" --resursive --verbose my-existing-app:app/ my-app-copy
    ```

1. Make changes to local my-app-copy directory

1. Use rsync to upload and overwrite app directory in CF instance
    ```sh
    rsync --rsh="./cf-rsh-linux.sh" --resursive --verbose my-app-copy/ my-existing-app:app
    ```

1. Visit the app URL in browser and see the updated content

* Note: apps languages/buildpacks must support dynamic code/content reloading. Server process may need to be signalled or restarted to reload content.


### Windows - Debugging hwc apps
1. Push empty app from this repo
    ```sh
    cf push my-rsync-app -p app -s windows2016 -b binary_buildpack -u none -c 'powershell Start-Sleep 99999' 
    ```

1. Download latest hwc 
    ```sh
    curl -L https://github.com/cloudfoundry/hwc/releases/download/15.0.0/hwc.exe -o hwc.exe
    ```
    
1. Use rsync to copy hwc to CF instance
    ```sh
    rsync --rsh="./cf-rsh-windows.sh" --resursive --verbose hwc.exe my-rsync-app:app/hwc.exe
    ```

1. Use rsync to copy app directory to CF instance
    ```sh
    rsync --rsh="./cf-rsh-windows.sh" --resursive --verbose my-app/ my-rsync-app:app
    ```

1. Start hwc over cf ssh
    ```sh
    cf ssh my-rsync-app -c 'app\hwc.exe -appRootPath app'
    ```

1. Visit the app URL in browser

1. Make changes to app (republish if needed) and repeat three prior steps to reload
