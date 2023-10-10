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
    git clone --depth 1 -b v7 https://github.com/LANDIS-II-Foundation/Core-Model-v7-LINUX.git && \
    cd Core-Model-v7-LINUX/Tool-Console/src/ && \
    dotnet build -c Release && \
    for f in /LANDIS-II/Core-Model-v7-LINUX/build/Release/*.json; do sed -i '/"\/root\/\.dotnet\/.*"/d' $f; done && \
    mv /LANDIS-II/Core-Model-v7-LINUX/build /LANDIS-II/build && \
    rm -rf /LANDIS-II/Core-Model-v7-LINUX/ && \
    rm -rf /tmp/* /root/.[!.]*

RUN cd /LANDIS-II && \
    git clone --depth 1 -b v4.0.1 https://github.com/LANDIS-II-Foundation/Extension-PnET-Succession.git && \
    cp Extension-PnET-Succession/deploy/*.dll build/extensions/ && \
    cp -r Extension-PnET-Succession/deploy/Defaults build/extensions/ && \
    cp -r Extension-PnET-Succession/deploy/Defaults build/extensions/ && \
    dotnet /LANDIS-II/build/Release/Landis.Extensions.dll add Extension-PnET-Succession/deploy/installer/PnET-Succession.txt && \
    mkdir /LANDIS-II/build/Release/..\\extensions && \
    for f in /LANDIS-II/build/extensions/Defaults/*; do ln -s $f build/Release/..\\extensions/Defaults\\$(basename $f); done && \
    rm -rf Extension-PnET-Succession/

# Run LANDIS-II like this:
# dotnet /LANDIS-II/build/Release/Landis.Console.dll scenario.txt

CMD ["bash"]
