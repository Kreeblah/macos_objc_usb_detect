/*
	This file is part of macos_objc_usb_detect.

	macos_objc_usb_detect is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	macos_objc_usb_detect is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with macos_objc_usb_detect.  If not, see <https://www.gnu.org/licenses/>.
*/

#import "USBDetectionDevice.h"
#import "USBDetectionDetect.h"

@interface USBTest : NSObject
{
}

-(void) connectedDevice:(USBDetectionDevice*)device;
-(void) disconnectedDevice:(USBDetectionDevice*)device;
@end

@implementation USBTest
-(void) connectedDevice:(USBDetectionDevice*)device
{
	NSLog(@"%@", [@"Connected: " stringByAppendingString:(device->deviceName)]);
}

-(void) disconnectedDevice:(USBDetectionDevice*)device
{
	NSLog(@"%@", [@"Disconnected: " stringByAppendingString:(device->deviceName)]);
}
@end

void USBTestSignalHandler(int sigraised)
{
	exit(EXIT_SUCCESS);
}

int main(int argc, const char * argv[])
{
	sig_t signalHandler = signal(SIGINT, USBTestSignalHandler);
	if (signalHandler == SIG_ERR)
	{
		return EXIT_FAILURE;
	}

	@autoreleasepool
	{
		USBTest* usbTest = [[USBTest alloc] init];
		USBDetectionDetect* detectObj = [[USBDetectionDetect alloc] init];
		[detectObj addWatchedDeviceWithVendorId:0xa466 withProductId:0x0a53];
		[detectObj addWatchedDeviceWithVendorId:0x04d8 withProductId:0xe11c];

		[detectObj watchForUsbDevicesWithConnectedDeviceObj:usbTest withConnectedDeviceMethod:@selector(connectedDevice:) withDisconnectedDeviceObj:usbTest withDisconnectedDeviceMethod:@selector(disconnectedDevice:)];

		while(YES)
		{}
	}

	return EXIT_SUCCESS;
}