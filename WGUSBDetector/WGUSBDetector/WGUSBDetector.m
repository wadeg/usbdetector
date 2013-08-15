//
//  WGUSBDetector.m
//  WGUSBDetector
//
//  Created by Wade Gasior on 8/14/13.
//  Copyright (c) 2013 Variable Technologies. All rights reserved.
//

#import "WGUSBDetector.h"
#include <IOKit/usb/IOUSBLib.h>

@interface WGUSBDetector() 
@property (nonatomic) long deviceVID;
@property (nonatomic) long devicePID;
@property (strong, nonatomic) NSObject<WGUSBDetectorDelegate> *delegate;
@property (nonatomic) io_iterator_t gAddedIter;
@property (nonatomic) io_iterator_t gRemovedIter;
@end

@implementation WGUSBDetector
- (id)initWithDelegate: (NSObject<WGUSBDetectorDelegate> *)delegate forVID: (long)vid forPID: (long)pid
{
    self = [super init];
    if (self) {
        self.deviceVID = vid;
        self.devicePID = pid;
        self.delegate = delegate;
        [self performSelectorInBackground:@selector(setupUSBListener) withObject:NULL];
    }
    return self;
}

- (void)setupUSBListener {
    /* For detecting when device is added */
    CFMutableDictionaryRef matchingDictAdded = IOServiceMatching(kIOUSBDeviceClassName);
    
    CFDictionarySetValue(matchingDictAdded, CFSTR(kUSBVendorID), CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &_deviceVID));
    CFDictionarySetValue(matchingDictAdded, CFSTR(kUSBProductID), CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &_devicePID));
    
    IONotificationPortRef gNotifyPort = IONotificationPortCreate(kIOMasterPortDefault);
    CFRunLoopSourceRef runLoopSource = IONotificationPortGetRunLoopSource(gNotifyPort);
    
    CFRunLoopRef gRunLoop = CFRunLoopGetCurrent();
    CFRunLoopAddSource(gRunLoop, runLoopSource, kCFRunLoopDefaultMode);
    
    IOServiceAddMatchingNotification(     gNotifyPort,             // notifyPort
                                     kIOFirstMatchNotification,    // notificationType
                                     matchingDictAdded,                 // matching
                                     deviceDetected,               // callback
                                     (__bridge void *)(self),      // refCon
                                     &_gAddedIter                  // notification
                                     );
    
    //Run once to clear iterator and check if device is already connected
    deviceDetected((__bridge void *)(self), _gAddedIter);
    
    /* For detecting when device is removed */
    CFMutableDictionaryRef matchingDictRemoved = IOServiceMatching(kIOUSBDeviceClassName);
    
    CFDictionarySetValue(matchingDictRemoved, CFSTR(kUSBVendorID), CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &_deviceVID));
    CFDictionarySetValue(matchingDictRemoved, CFSTR(kUSBProductID), CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &_devicePID));
    
    IOServiceAddMatchingNotification(gNotifyPort,
                                           kIOTerminatedNotification,
                                           matchingDictRemoved,
                                           deviceRemoved,
                                           (__bridge void *)self,
                                           &_gRemovedIter);
    
    deviceRemoved((__bridge void *)(self), _gRemovedIter);
    
    CFRunLoopRun();
}

void deviceDetected(void *refCon, io_iterator_t iterator)
{
    io_service_t        usbDevice;
    io_string_t pathName;
    WGUSBDetector *self = (__bridge WGUSBDetector *)refCon;

    while ((usbDevice = IOIteratorNext(iterator))) {
        NSLog(@"Added.");
        IORegistryEntryGetPath(usbDevice, kIOUSBPlane, pathName);
        NSLog(@"Device's path in IOUSB plane = %s\n", pathName);

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate USBDetectorDidDetectDeviceAdded:self];
        });
        
        IOObjectRelease(usbDevice);
    }
}

void deviceRemoved(void *refCon, io_iterator_t iterator)
{
    io_service_t usbDevice;
    io_string_t pathName;
    WGUSBDetector *self = (__bridge WGUSBDetector *)refCon;

    while ((usbDevice = IOIteratorNext(iterator))) {
        NSLog(@"Removed.");
        IORegistryEntryGetPath(usbDevice, kIOUSBPlane, pathName);
        NSLog(@"Device's path in IOUSB plane = %s\n", pathName);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate USBDetectorDidDetectDeviceRemoved:self];
        });
        
        IOObjectRelease(usbDevice);
    }
}

@end
