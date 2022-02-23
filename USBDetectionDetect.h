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

#import "USBDetectionDetect.h"
#import "USBDetectionDevice.h"

#import <Cocoa/Cocoa.h>
#import <CoreFoundation/CoreFoundation.h>
#import <IOKit/usb/IOUSBLib.h>
#import <IOKit/IOMessage.h>
#import <IOKit/IOCFPlugIn.h>

@class USBDevice;
@interface USBDetectionDetect : NSObject
{
#if __MAC_OS_X_VERSION_MIN_REQUIRED > 1050
	NSMutableDictionary<NSNumber*, USBDetectionDevice*>* connectedUSBDevices;
	NSMutableArray<USBDetectionDevice*>* watchedUSBDevices;
#else
	NSMutableDictionary* connectedUSBDevices;
	NSMutableArray* watchedUSBDevices;
#endif

	@public IONotificationPortRef ioNotificationPortRef;

	id deviceConnectionObj;
	id deviceRemovalObj;
	SEL deviceConnectionSelector;
	SEL deviceRemovalSelector;
}

-(void) watchForUsbDevicesWithConnectedDeviceObj:(id)connectedDeviceObj withConnectedDeviceMethod:(SEL)connectedDeviceMethod withDisconnectedDeviceObj:(id)disconnectedDeviceObj withDisconnectedDeviceMethod:(SEL)disconnectedDeviceMethod;
-(void) addWatchedDevice:(USBDetectionDevice*)device;
-(void) addWatchedDeviceWithVendorId:(long)vendorID withProductId:(long)productID;
-(void) clearWatchedDevices;
#if __MAC_OS_X_VERSION_MIN_REQUIRED > 1050
-(NSMutableDictionary<NSNumber*, USBDetectionDevice*>*) getConnectedDeviceDictionary;
-(NSArray<USBDetectionDevice*>*) getConnectedDeviceArray;
#else
-(NSMutableDictionary*) getConnectedDeviceDictionary;
-(NSArray*) getConnectedDeviceArray;
#endif

void CUSBDeviceNotification(void *refCon, io_service_t service, natural_t messageType, void *messageArgument);
void CUSBDeviceAdded(void *refCon, io_iterator_t iterator);
@end

static USBDetectionDetect* usbDetectSelfObj;
