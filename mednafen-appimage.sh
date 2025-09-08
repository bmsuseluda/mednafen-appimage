#!/bin/sh

set -ex
ARCH="$(uname -m)"
REPO="https://mednafen.github.io/releases/files/mednafen-1.32.1.tar.xz"
GRON="https://raw.githubusercontent.com/xonixx/gron.awk/refs/heads/main/gron.awk"

export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
wget "$GRON" -O ./gron.awk
chmod +x ./gron.awk
VERSION=1.32.1

tar -xf "$REPO"

# BUILD mednafen
(
	cd ./mednafen

	# backport fix from aur package
	sed -i \
	  "s/virtual auto saveName() -> string { return pak->attribute(\"name\"); }/virtual auto saveName() -> string { return name(); }/g" \
	  ./mia/pak/pak.hpp

	./configure
	make
	make install --prefix="/usr"
	make installcheck
	make clean
	make distclean
)
rm -rf ./mednafen
[ -n "$VERSION" ] && echo "$VERSION" > ~/version

# NOW MAKE APPIMAGE
URUNTIME="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/uruntime2appimage.sh"
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"

export ADD_HOOKS="self-updater.bg.hook"
export OUTNAME=mednafen-"$VERSION"-anylinux-"$ARCH".AppImage
export DESKTOP=/usr/share/applications/mednafen.desktop
export ICON=/usr/share/icons/hicolor/256x256/apps/mednafen.png
export DEPLOY_OPENGL=1 
export DEPLOY_PIPEWIRE=1

# "fix" xvfb-run failing to kill the process in aarch64
if [ "$ARCH" = "aarch64" ]; then
	sed -i 's#kill $XVFBPID#kill $XVFBPID || true#' "$(command -v xvfb-run)"
fi

# ADD LIBRARIES
wget --retry-connrefused --tries=30 "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun
./quick-sharun /usr/bin/mednafen /usr/bin/sourcery

# turn appdir into appimage
wget --retry-connrefused --tries=30 "$URUNTIME" -O ./uruntime2appimage
chmod +x ./uruntime2appimage
./uruntime2appimage

mkdir -p ./dist
mv -v ./*.AppImage* ./dist

echo "All Done!"
