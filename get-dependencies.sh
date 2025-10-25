#!/bin/sh

set -ex

EXTRA_PACKAGES="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/get-debloated-pkgs.sh"

echo "Installing dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	base-devel         \
	cmake              \
	ccache             \
	curl               \
	gcc-libs           \
	git                \
	libao              \
	libdecor           \
	libpulse           \
	libx11             \
	libxrandr          \
	libxss             \
	openal             \
	pipewire-audio     \
	pkgconf            \
	python             \
	pulseaudio         \
	pulseaudio-alsa    \
	sdl2               \
	wget               \
	xorg-server-xvfb   \
	zlib               \
	zsync

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
wget --retry-connrefused --tries=30 "$EXTRA_PACKAGES" -O ./get-debloated-pkgs.sh
chmod +x ./get-debloated-pkgs.sh
./get-debloated-pkgs.sh --add-common
