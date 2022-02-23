#!/bin/sh

compile_for_arch()
{
	ARCH_NAME="$1"
	MIN_MACOS_VER=$2
	echo "Building for architecture: ${ARCH_NAME}"
	if [[ -f "lib/libusbdetect_${ARCH_NAME}.dylib" ]]; then
		echo "Removing old library: libusbdetect_${ARCH_NAME}.dylib"
		rm "lib/libusbdetect_${ARCH_NAME}.dylib"
	fi

	if (( $(echo "${MIN_MACOS_VER} > 10.5" | bc -l) )); then
		clang -framework CoreFoundation -framework Foundation -framework Cocoa -framework AppKit -framework IOKit -lobjc -Wall -Wno-deprecated-declarations -Werror -arch "${ARCH_NAME}" -mmacosx-version-min="${MIN_MACOS_VER}" -shared -undefined dynamic_lookup -o "lib/libusbdetect_${ARCH_NAME}.dylib" USBDetectionDetect.m USBDetectionDevice.m
	else
		gcc -framework CoreFoundation -framework Foundation -framework Cocoa -framework AppKit -framework IOKit -lobjc -Wall -Wno-deprecated-declarations -Werror -arch "${ARCH_NAME}" -mmacosx-version-min="${MIN_MACOS_VER}" -shared -undefined dynamic_lookup -o "lib/libusbdetect_${ARCH_NAME}.dylib" USBDetectionDetect.m USBDetectionDevice.m
	fi

	file "lib/libusbdetect_${ARCH_NAME}.dylib"
	otool -L "lib/libusbdetect_${ARCH_NAME}.dylib"
}

if [[ -z "$1" ]]; then
	echo "Must specify one of: ppc x86 x64 arm"
	exit 1
fi

if [[ ! -d "lib" ]]; then
	mkdir "lib"
fi

if [[ "$1" == "ppc" ]]; then
	compile_for_arch ppc750 10.1
	compile_for_arch ppc7400 10.1
	compile_for_arch ppc7450 10.1
	compile_for_arch ppc970 10.2
	exit 0
fi

if [[ "$1" == "x86" ]]; then
	compile_for_arch i386 10.4
	exit 0
fi

if [[ "$1" == "x64" ]]; then
	compile_for_arch x86_64 10.6
	compile_for_arch x86_64h 10.9
	exit 0
fi

if [[ "$1" == "arm" ]]; then
	compile_for_arch arm64 11.0
	exit 0
fi

echo "Must specify one of: ppc x86 x64 arm"
exit 1
