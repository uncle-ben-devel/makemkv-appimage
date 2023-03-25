FROM amd64/ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive
# depends for makemkv and general use
RUN apt-get update && apt-get install -y \
    build-essential pkg-config libc6-dev libssl-dev libexpat1-dev libavcodec-dev libgl1-mesa-dev qtbase5-dev zlib1g-dev \
    wget software-properties-common
    
# depends for linuxdeployqt    
RUN add-apt-repository ppa:beineri/opt-qt-5.15.2-bionic &&\
    apt update && apt install -y \
    qt515base \
    patchelf binutils desktop-file-utils xz-utils file

# build and install makemkv libraries
ARG LIBRARY_BUILD_DIRECTORY="/build/libraries"
ARG LIBRARY_ARCHIVE_NAME="makemkv-oss-1.17.3"
WORKDIR "$LIBRARY_BUILD_DIRECTORY"
RUN wget "https://www.makemkv.com/download/$LIBRARY_ARCHIVE_NAME.tar.gz" &&\
    tar -xzf *.tar.gz
WORKDIR "$LIBRARY_BUILD_DIRECTORY/$LIBRARY_ARCHIVE_NAME"
RUN ./configure &&\
    make &&\
    make install

# build and install makemkv binaries
ARG BINARY_BUILD_DIRECTORY="/build/binaries"
ARG BINARY_ARCHIVE_NAME="makemkv-bin-1.17.3"
WORKDIR "$BINARY_BUILD_DIRECTORY"
RUN wget "https://www.makemkv.com/download/$BINARY_ARCHIVE_NAME.tar.gz" &&\
    tar -xzf *.tar.gz
WORKDIR "$BINARY_BUILD_DIRECTORY/$BINARY_ARCHIVE_NAME"
RUN echo "export EULA_AGREED=yes" > src/ask_eula.sh
RUN make &&\
    make install
    
# get linuxdeployqt
ARG APPIMAGE_BUILD_DIRECTORY="/build/appimage"
WORKDIR /usr/bin
RUN wget "https://github.com/probonopd/linuxdeployqt/releases/download/8/linuxdeployqt-continuous-x86_64.AppImage" &&\
    chmod +x linuxdeployqt-continuous-x86_64.AppImage


# create appdir
WORKDIR "$APPIMAGE_BUILD_DIRECTORY"
RUN mkdir -p usr/bin &&\
    mkdir -p usr/lib &&\
    mkdir -p usr/share/applications &&\
    mkdir -p usr/share/icons/hicolor/32x32/apps &&\
    mkdir -p usr/share/icons/hicolor/22x22/apps &&\
    mkdir -p usr/share/icons/hicolor/16x16/apps &&\
    mkdir -p usr/share/icons/hicolor/128x128/apps &&\
    mkdir -p usr/share/icons/hicolor/64x64/apps &&\
    mkdir -p usr/share/icons/hicolor/256x256/apps
    
# copy makemkv files into the appdir
ARG SEARCH_PATH="usr/bin"
RUN find "/$SEARCH_PATH" -type f | grep "makemkv" | xargs -d '\n' -I ? cp ? "$SEARCH_PATH"
ARG SEARCH_PATH="usr/lib"
RUN find "/$SEARCH_PATH" -type f | grep "makemkv" | xargs -d '\n' -I ? cp ? "$SEARCH_PATH"
ARG SEARCH_PATH="usr/share/applications"
RUN find "/$SEARCH_PATH" -type f | grep "makemkv" | xargs -d '\n' -I ? cp ? "$SEARCH_PATH"
ARG SEARCH_PATH="usr/share/icons/hicolor/32x32/apps"
RUN find "/$SEARCH_PATH" -type f | grep "makemkv" | xargs -d '\n' -I ? cp ? "$SEARCH_PATH"
ARG SEARCH_PATH="usr/share/icons/hicolor/22x22/apps"
RUN find "/$SEARCH_PATH" -type f | grep "makemkv" | xargs -d '\n' -I ? cp ? "$SEARCH_PATH"
ARG SEARCH_PATH="usr/share/icons/hicolor/16x16/apps"
RUN find "/$SEARCH_PATH" -type f | grep "makemkv" | xargs -d '\n' -I ? cp ? "$SEARCH_PATH"
ARG SEARCH_PATH="usr/share/icons/hicolor/128x128/apps"
RUN find "/$SEARCH_PATH" -type f | grep "makemkv" | xargs -d '\n' -I ? cp ? "$SEARCH_PATH"
ARG SEARCH_PATH="usr/share/icons/hicolor/64x64/apps"
RUN find "/$SEARCH_PATH" -type f | grep "makemkv" | xargs -d '\n' -I ? cp ? "$SEARCH_PATH"
ARG SEARCH_PATH="usr/share/icons/hicolor/256x256/apps"
RUN find "/$SEARCH_PATH" -type f | grep "makemkv" | xargs -d '\n' -I ? cp ? "$SEARCH_PATH"

# create appimage from desktop file in appdir
RUN linuxdeployqt-continuous-x86_64.AppImage --appimage-extract-and-run \
    usr/share/applications/makemkv.desktop \
    -executable=usr/bin/makemkvcon \
    -appimage \
    -qmake="/opt/qt515/bin/qmake" \
    -exclude-libs="**/libgmodule-2.0.so*" \
    -verbose=2

# copy appimage to known location so it can be copied out of the image easily
ARG BUILD_ARTIFACT_DIRECTORY="/build-artifacts"
WORKDIR "$BUILD_ARTIFACT_DIRECTORY"
RUN cp "$APPIMAGE_BUILD_DIRECTORY/"*.AppImage .
