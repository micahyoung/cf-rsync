@echo off
set PATH=C:\Program Files\Git\usr\bin;C:\Program Files\Git\mingw64\bin;c:\Users\vcap\app\usr\bin;%PATH%

if exist c:\Users\vcap\app\usr\bin\rsync.exe (
    REM rsync exists
) else (
    powershell -Command "Invoke-WebRequest -OutFile rsync.pkg.tar.xz 'http://repo.msys2.org/msys/x86_64/rsync2-3.1.3dev_msys2.7.0_r3-0-x86_64.pkg.tar.xz'"
    tar -x -C c:/Users/vcap/app -f rsync.pkg.tar.xz "usr/bin/rsync.exe" 
)

rsync.exe %1 %2 %3 %4 %5 %6 %7