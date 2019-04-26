ARG os_version
FROM cloudfoundry/windows2016fs:${os_version}

COPY remote-install-rsync-windows.ps1 remote-install-rsync-windows.ps1

RUN powershell c:\\remote-install-rsync-windows.ps1