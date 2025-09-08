#!/bin/sh

set -ex
ARCH="$(uname -m)"
SOURCE=$(wget -q https://mednafen.github.io -O - | sed 's/[()",{} ]/\n/g' | grep -oi "https.*files.*xz$" \
	| head -1 | python -c 'import sys,html;print(html.unescape(sys.stdin.read()), end="")')

export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"

wget "$SOURCE" -O ./mednafen.tar.xz
tar -xf ./mednafen.tar.xz

# BUILD mednafen
(
	cd ./mednafen

	./configure --prefix="/usr"
	make
	make install
	make installcheck
	make clean
	make distclean
)
rm -rf ./mednafen ./mednafen.tar.xz
VERSION="$(mednafen 2>/dev/null | awk '{print $3; exit}')"
[ -n "$VERSION" ] && echo "$VERSION" > ~/version

# NOW MAKE APPIMAGE
URUNTIME="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/uruntime2appimage.sh"
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"

export ADD_HOOKS="self-updater.bg.hook"
export OUTNAME=mednafen-"$VERSION"-anylinux-"$ARCH".AppImage
export DESKTOP="$PWD"/mednafen.desktop
export ICON="$PWD"/mednafen.png
export DEPLOY_OPENGL=1 
export DEPLOY_PIPEWIRE=1

# ADD LIBRARIES
wget --retry-connrefused --tries=30 "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun
./quick-sharun /usr/bin/mednafen

# turn appdir into appimage
wget --retry-connrefused --tries=30 "$URUNTIME" -O ./uruntime2appimage
chmod +x ./uruntime2appimage
./uruntime2appimage

mkdir -p ./dist
mv -v ./*.AppImage* ./dist

echo "All Done!"
