# macos_objc_usb_detect
Methods for detecting USB devices being plugged in or removed and calling selectors to process them.  See USBTest.m for an example.

Compile with:

    clang -framework CoreFoundation -framework Foundation -framework Cocoa -framework AppKit -framework IOKit -lobjc -Wall -Werror -arch YOUR_ARCH_HERE USBDetectionDetect.m USBDetectionDevice.m USBTest.m -o USBTest

Releases are built as universal binaries with compiled support for `ppc750`, `ppc7400`, `ppc7450`, `ppc970`, `i386`, `x86_64`, `x86_64h`, and `arm64` per https://tenfourfox.blogspot.com/2020/06/the-super-duper-universal-binary.html and combined with `lipo`.