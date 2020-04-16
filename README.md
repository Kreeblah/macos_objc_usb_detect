# macos_objc_usb_detect
Methods for detecting USB devices being plugged in or removed and calling selectors to process them.  See USBTest.m for an example.

Compile with:

    clang -framework CoreFoundation -framework Foundation -framework Cocoa -framework AppKit -framework IOKit -lobjc -Wall -Werror -arch x86_64 USBDetectionDetect.m USBDetectionDevice.m USBTest.m -o USBTest