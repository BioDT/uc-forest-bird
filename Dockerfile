FROM docker.io/ubuntu:22.04 AS wine

ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386 && \
    apt-get update -qy && \
    apt-get install -qy --no-install-recommends \
        wget \
        ca-certificates \
        xvfb \
        wine \
        wine32 \
        && \
    apt-get clean

ENV WINEPREFIX=/wine \
    WINEARCH=win32

RUN for url in \
      'https://github.com/LANDIS-II-Foundation/Extension-PnET-Succession/////////raw/master/deploy/installer/LANDIS-II-V7 PnET-Succession 4.0.1-setup.exe' \
      'https://github.com/LANDIS-II-Foundation/Extension-Biomass-Harvest/////////raw/master/deploy/installer/LANDIS-II-V7 Biomass Harvest 4.4-setup.exe' \
      'https://github.com/LANDIS-II-Foundation/Extension-Base-Fire///////////////raw/master/deploy/installer/LANDIS-II-V7 Base Fire 4.0-setup.exe' \
      'https://github.com/LANDIS-II-Foundation/Extension-Output-Biomass-PnET/////raw/master/deploy/installer/LANDIS-II-V7 Output-PnET 4.0-setup.exe' \
      'https://github.com/LANDIS-II-Foundation/Extension-Output-Biomass-Reclass//raw/master/deploy/installer/LANDIS-II-V7 Output Biomass Reclass 3.1-setup.exe' \
      'https://github.com/LANDIS-II-Foundation/Extension-Output-Max-Species-Age//raw/master/deploy/installer/LANDIS-II-V7 Output Max Species Age 3.0-setup.exe' \
    ; do \
      echo "$url" && \
      wget -q "$url" -O setup.exe && \
      xvfb-run wine setup.exe /verysilent /suppressmsgboxes && \
      rm setup.exe && \
      ls -l "$WINEPREFIX/drive_c/Program Files/LANDIS-II-v7/extensions" && \
      echo "ok" \
    ; done && \
    mv "$WINEPREFIX/drive_c/Program Files/LANDIS-II-v7" / && \
    rm -r /LANDIS-II-v7/examples && \
    rm -rf /tmp/wine-*


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

ENV LANDIS_DIR=/LANDIS-II-v7

# Build core model
RUN REPO=$LANDIS_DIR/Core-Model-v7-LINUX && \
    git clone --depth 1 -b v7 https://github.com/LANDIS-II-Foundation/Core-Model-v7-LINUX.git $REPO && \
    cd $REPO/Tool-Console/src/ && \
    dotnet build -c Release && \
    for f in $REPO/build/Release/*.json; do sed -i '/"\/root\/\.dotnet\/.*"/d' $f; done && \
    mv $REPO/build/* $LANDIS_DIR && \
    rm -rf $REPO && \
    rm -rf /tmp/* /root/.[!.]*

# Copy extension files
COPY --from=wine /LANDIS-II-v7 $LANDIS_DIR

# Register extensions
RUN for SRC in $LANDIS_DIR/plug-ins-installer-files/*.txt \
    ; do \
      dotnet $LANDIS_DIR/Release/Landis.Extensions.dll add "$SRC" \
    ; done

# Create Windows paths for accessing files under extensions/Defaults
RUN mkdir $LANDIS_DIR/Release/..\\extensions && \
    for SRC in $LANDIS_DIR/extensions/Defaults/* \
    ; do \
      TGT="$LANDIS_DIR/Release/..\\extensions/Defaults\\$(basename $SRC)"; \
      ln -s $(realpath --relative-to=$(dirname $TGT) $SRC) $TGT \
    ; done

# Run LANDIS-II like this:
# dotnet $LANDIS_DIR/Release/Landis.Console.dll scenario.txt

CMD ["bash"]
