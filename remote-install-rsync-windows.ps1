#NO BOM
$ProgressPreference="SilentlyContinue"

$env:PATH="C:\Program Files\Git\usr\bin;C:\Program Files\Git\mingw64\bin;c:\Users\vcap\deps\cf-rsync\usr\bin;$env:PATH"

if (!(Test-Path "c:\Users\vcap\deps\cf-rsync\usr\bin\rsync.exe")) {
    New-Item -Type Directory "c:\Users\vcap\deps\cf-rsync"
    Invoke-WebRequest -OutFile "rsync.pkg.tar.xz" 'http://repo.msys2.org/msys/x86_64/rsync2-3.1.3dev_msys2.7.0_r3-0-x86_64.pkg.tar.xz'
    tar -x -C 'c:/Users/vcap/deps/cf-rsync' -f "rsync.pkg.tar.xz" "usr/bin/rsync.exe"
    Remove-Item -Force "rsync.pkg.tar.xz"
}

Write-Output '@echo off
set PATH=C:\Program Files\Git\usr\bin;C:\Program Files\Git\mingw64\bin;c:\Users\vcap\deps\cf-rsync\usr\bin;%PATH%
rsync.exe %1 %2 %3 %4 %5 %6 %7' | Out-File -Encoding ASCII "c:\Users\vcap\deps\cf-rsync\rsync.bat"
