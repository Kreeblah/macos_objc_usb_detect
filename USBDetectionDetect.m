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

@implementation USBDetectionDetect

-(id) init
{
	[super init];
	if(nil == usbDetectSelfObj)
	{
		usbDetectSelfObj = self;
	}

	connectedUSBDevices = [[NSMutableDictionary alloc] init];
	watchedUSBDevices = [[NSMutableArray alloc] init];
	return usbDetectSelfObj;
}

-(void) watchForUsbDevicesWithConnectedDeviceObj:(id)connectedDeviceObj withConnectedDeviceMethod:(SEL)connectedDeviceMethod withDisconnectedDeviceObj:(id)disconnectedDeviceObj withDisconnectedDeviceMethod:(SEL)disconnectedDeviceMethod
{
	deviceConnectionObj = connectedDeviceObj;
	deviceConnectionSelector = connectedDeviceMethod;
	deviceRemovalObj = disconnectedDeviceObj;
	deviceRemovalSelector = disconnectedDeviceMethod;

	for(USBDetectionDevice* tempDevice in watchedUSBDevices)
	{
		io_iterator_t deviceIterator;

		CFMutableDictionaryRef matchingDict = IOServiceMatching(kIOUSBDeviceClassName);
		if (matchingDict == NULL)
		{
			return;
		}
	
		CFNumberRef numberRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &(tempDevice->vendorID));
		CFDictionarySetValue(matchingDict, CFSTR(kUSBVendorID), numberRef);
		CFRelease(numberRef);

		numberRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &(tempDevice->productID));
		CFDictionarySetValue(matchingDict, CFSTR(kUSBProductID), numberRef);
		CFRelease(numberRef);
		numberRef = NULL;

		if(ioNotificationPortRef == NULL)
		{
			ioNotificationPortRef = IONotificationPortCreate(kIOMasterPortDefault);
		}

		CFRunLoopAddSource(CFRunLoopGetCurrent(), IONotificationPortGetRunLoopSource(ioNotificationPortRef), kCFRunLoopDefaultMode);
		IOServiceAddMatchingNotification(ioNotificationPortRef, kIOFirstMatchNotification, matchingDict, CUSBDeviceAdded, NULL, &deviceIterator);
										
		CUSBDeviceAdded(NULL, deviceIterator);
	}

	CFRunLoopRun();
}

-(void) addConnectedDevice:(USBDetectionDevice*)device
{
	[connectedUSBDevices setObject:device forKey:[NSNumber numberWithUnsignedInt:(unsigned int)device->locationID]];
}

-(void) removeConnectedDevice:(UInt32)deviceLocation
{
	[connectedUSBDevices removeObjectForKey:[NSNumber numberWithUnsignedInt:(unsigned int)deviceLocation]];
}

-(void) addWatchedDevice:(USBDetectionDevice*)device
{
	[watchedUSBDevices addObject:device];
}

-(void) addWatchedDeviceWithVendorId:(long)watchedVendorID withProductId:(long)watchedProductID
{
	USBDetectionDevice* tempDevice = [[USBDetectionDevice alloc] init];
	tempDevice->vendorID = watchedVendorID;
	tempDevice->productID = watchedProductID;
	[watchedUSBDevices addObject:tempDevice];
}

-(void) clearWatchedDevices
{
	[watchedUSBDevices removeAllObjects];
}

-(NSMutableDictionary<NSNumber*, USBDetectionDevice*>*) getConnectedDeviceDictionary
{
	return connectedUSBDevices;
}

-(NSArray<USBDetectionDevice*>*) getConnectedDeviceArray
{
	return [connectedUSBDevices allValues];
}

-(void) detectedDeviceConnection:(USBDetectionDevice*)usbDevice
{
	[self addConnectedDevice:usbDevice];
	[deviceConnectionObj performSelector:deviceConnectionSelector withObject:usbDevice];
}

-(void) detectedDeviceRemoval:(USBDetectionDevice*)usbDevice
{
	[self removeConnectedDevice:(usbDevice->locationID)];
	[deviceRemovalObj performSelector:deviceRemovalSelector withObject:usbDevice];
}

void CUSBDeviceNotification(void *refCon, io_service_t service, natural_t messageType, void *messageArgument)
{
	USBDetectionDevice* usbDevice = (USBDetectionDevice*)refCon;
	
	if (messageType == kIOMessageServiceIsTerminated)
	{
		if (usbDevice->deviceInterface)
		{
			(*(usbDevice->deviceInterface))->Release(usbDevice->deviceInterface);
		}
		
		IOObjectRelease(usbDevice->notification);

		[usbDetectSelfObj detectedDeviceRemoval:usbDevice];
	}
}

void CUSBDeviceAdded(void *refCon, io_iterator_t iterator)
{
	io_service_t usbDevice;
	IOCFPlugInInterface **plugInInterface = NULL;
	SInt32 score;

	while ((usbDevice = IOIteratorNext(iterator)))
	{
		USBDetectionDevice* tempUsbDevice = [[USBDetectionDevice alloc] init];
		io_name_t deviceIoName;
		UInt32 locationID;
		
		kern_return_t kern_return = IORegistryEntryGetName(usbDevice, deviceIoName);
		if (kern_return != KERN_SUCCESS)
		{
			deviceIoName[0] = '\0';
		}
		
		tempUsbDevice->deviceName = (NSString*)CFStringCreateWithCString(kCFAllocatorDefault, deviceIoName, kCFStringEncodingASCII);
		
		IOCreatePlugInInterfaceForService(usbDevice, kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID, &plugInInterface, &score);

		(*plugInInterface)->QueryInterface(plugInInterface, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID), (LPVOID*) &(tempUsbDevice->deviceInterface));
		
		(*plugInInterface)->Release(plugInInterface);

		(*(tempUsbDevice->deviceInterface))->GetLocationID(tempUsbDevice->deviceInterface, &locationID);

		tempUsbDevice->locationID = locationID;

		IOServiceAddInterestNotification(usbDetectSelfObj->ioNotificationPortRef, usbDevice, kIOGeneralInterest, CUSBDeviceNotification, tempUsbDevice, &(tempUsbDevice->notification));
												
		IOObjectRelease(usbDevice);

		[usbDetectSelfObj detectedDeviceConnection:tempUsbDevice];
	}
}
@end
