#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	cmake     \
	gcc-libs  \
	libao     \
	libx11    \
	libxrandr \
	libxss    \
	openal    \
	pkgconf   \
	sdl2      \
	zlib      \

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano libdecor-mini

# Comment this out if you need an AUR package
#make-aur-package PACKAGENAME

# If the application needs to be manually built that has to be done down here
SOURCE=$(wget -q https://mednafen.github.io -O - | sed 's/[()",{} ]/\n/g' | grep -oi "https.*files.*xz$" \
	| head -1 | python -c 'import sys,html;print(html.unescape(sys.stdin.read()), end="")')

wget "$SOURCE" -O ./mednafen.tar.xz
tar -xf ./mednafen.tar.xz

(
	cd ./mednafen
	./configure --prefix="/usr"
	make -j"$(nproc)"
	make install
	make installcheck
	make clean
	make distclean
)
rm -rf ./mednafen ./mednafen.tar.xz

