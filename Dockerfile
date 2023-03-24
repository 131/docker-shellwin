# escape=`
FROM mcr.microsoft.com/powershell:lts-nanoserver-1809
WORKDIR c:/apps
RUN curl -L -o docker-20.10.21.zip https://download.docker.com/win/static/stable/x86_64/docker-20.10.21.zip && tar -xvf docker-20.10.21.zip docker/docker.exe && del docker-20.10.21.zip
RUN curl -L -o openssh.zip https://github.com/PowerShell/Win32-OpenSSH/releases/download/v9.2.0.0p1-Beta/OpenSSH-Win64.zip && tar -xvf openssh.zip && del openssh.zip
USER Administrator
RUN net accounts /MaxPWAge:unlimited
RUN net user root /add
RUN net localgroup Administrators /add root
USER root

RUN setx /M PATH "%PATH%;c:/apps/docker"

ADD ./sshd_config C:\\ProgramData\\ssh\\sshd_config
ADD start-sshd.ps1 .
ENTRYPOINT ["pwsh.exe", "-command"]
CMD ["./start-sshd.ps1"]
LABEL "org.opencontainers.image.version"="0.0.1"
