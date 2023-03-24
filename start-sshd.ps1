Import-Module .\OpenSSH-Win64\OpenSSHUtils

Repair-SshdConfigPermission -FilePath $env:SHELL_AUTHORIZED_USERS -Confirm:$false
Repair-SshdConfigPermission -FilePath $env:SHELL_SERVER_KEY_PATH -Confirm:$false

C:\apps\OpenSSH-Win64\sshd.exe `
  -D -e `
  -h $env:SHELL_SERVER_KEY_PATH `
  -o AuthorizedKeysFile=$env:SHELL_AUTHORIZED_USERS
