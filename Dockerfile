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

ENV LANDIS_DIR=/LANDIS-II/build

RUN REPO=/LANDIS-II/Core-Model-v7-LINUX && \
    git clone --depth 1 -b v7 https://github.com/LANDIS-II-Foundation/Core-Model-v7-LINUX.git $REPO && \
    cd $REPO/Tool-Console/src/ && \
    dotnet build -c Release && \
    for f in $REPO/build/Release/*.json; do sed -i '/"\/root\/\.dotnet\/.*"/d' $f; done && \
    mv $REPO/build $LANDIS_DIR && \
    rm -rf $REPO && \
    rm -rf /tmp/* /root/.[!.]*

RUN REPO=/LANDIS-II/Extension-PnET-Succession && \
    git clone --depth 1 -b v4.0.1 https://github.com/LANDIS-II-Foundation/Extension-PnET-Succession.git $REPO && \
    cp $REPO/deploy/*.dll $LANDIS_DIR/extensions/ && \
    cp -r $REPO/deploy/Defaults $LANDIS_DIR/extensions/ && \
    dotnet $LANDIS_DIR/Release/Landis.Extensions.dll add $REPO/deploy/installer/PnET-Succession.txt && \
    mkdir $LANDIS_DIR/Release/..\\extensions && \
    for f in $LANDIS_DIR/extensions/Defaults/*; do ln -s $f $LANDIS_DIR/Release/..\\extensions/Defaults\\$(basename $f); done && \
    rm -rf $REPO

# Run LANDIS-II like this:
# dotnet $LANDIS_DIR/Release/Landis.Console.dll scenario.txt

CMD ["bash"]
