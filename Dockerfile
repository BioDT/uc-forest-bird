FROM docker.io/ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qy && \
    apt-get install -qy --no-install-recommends \
        wget \
        ca-certificates \
        apt-transport-https \
        git \
        libpng16-16 libjpeg62 libxml2 \
        && \
    apt-get clean

ENV DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    NUGET_PACKAGES=/nuget/packages

RUN UBUNTU_VERSION=$(grep -oP '(?<=^VERSION_ID=")[^"]+' /etc/os-release) && \
    wget https://packages.microsoft.com/config/ubuntu/$UBUNTU_VERSION/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    apt-get update -qy && \
    apt-get install -qy --no-install-recommends \
        dotnet-sdk-2.2 \
        && \
    apt-get clean && \
    rm -rf /tmp/* /root/.[!.]*

RUN mkdir /LANDIS-II && \
    cd /LANDIS-II && \
    git clone https://github.com/LANDIS-II-Foundation/Core-Model-v7-LINUX.git && \
    cd Core-Model-v7-LINUX/Tool-Console/src/ && \
    dotnet build -c Release && \
    rm -rf /tmp/* /root/.[!.]*

# Run LANDIS-II like this:
# dotnet /LANDIS-II/Core-Model-v7-LINUX/build/Release/Landis.Console.dll scenario.txt

CMD ["bash"]
