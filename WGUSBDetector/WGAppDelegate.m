//
//  WGAppDelegate.m
//  WGUSBDetector
//
//  Created by Wade Gasior on 8/14/13.
//  Copyright (c) 2013 Variable Technologies. All rights reserved.
//

#import "WGAppDelegate.h"

@implementation WGAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.usbDetector = [[WGUSBDetector alloc] initWithDelegate:self forVID:0x03EB forPID:0x2FDC];
}

- (void)USBDetectorDidDetectDeviceAdded:(WGUSBDetector *)detector
{
    self.colorWell.color = [NSColor greenColor];
}

- (void)USBDetectorDidDetectDeviceRemoved:(WGUSBDetector *)detector
{
    self.colorWell.color = [NSColor redColor];
}

@end
