#!/bin/sh

set -ex

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
	pulseaudio         \
	pulseaudio-alsa    \
	sdl2               \
	wget               \
	xorg-server-xvfb   \
	zlib               \
	zsync

echo "All done!"
echo "---------------------------------------------------------------"
