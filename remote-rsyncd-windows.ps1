param (
    [Parameter(Mandatory=$true)]
    [string]$port,

    [Parameter(Mandatory=$true)]
    [string]$username,

    [Parameter(Mandatory=$true)]
    [string]$password
)

$ProgressPreference="SilentlyContinue"

$env:PATH="C:\Program Files\Git\usr\bin;C:\Program Files\Git\mingw64\bin;c:\Users\vcap\deps\cf-rsync\usr\bin;$env:PATH"

if (!(Test-Path "c:\Users\vcap\deps\cf-rsync\usr\bin\rsync.exe")) {
    New-Item -Type Directory "c:\Users\vcap\deps\cf-rsync" | Out-Null
    Invoke-WebRequest -OutFile "rsync.pkg.tar.xz" 'http://repo.msys2.org/msys/x86_64/rsync2-3.1.3dev_msys2.7.0_r3-0-x86_64.pkg.tar.xz'
    tar -x -C 'c:/Users/vcap/deps/cf-rsync' -f "rsync.pkg.tar.xz" "usr/bin/rsync.exe"
    Remove-Item -Force "rsync.pkg.tar.xz"
}

Write-Output "${username}:${password}" | Out-File -Encoding ASCII "c:\Users\vcap\deps\cf-rsync\rsyncd.secrets"

Write-Output "
port = $port
strict modes = no
read only = no
[c]
  path = /c/
  auth users = ${username}
  secrets file = /c/Users/vcap/deps/cf-rsync/rsyncd.secrets
" | Out-File -Encoding ASCII "c:\Users\vcap\deps\cf-rsync\rsyncd.conf"

rsync.exe --daemon --config /c/Users/vcap/deps/cf-rsync/rsyncd.conf