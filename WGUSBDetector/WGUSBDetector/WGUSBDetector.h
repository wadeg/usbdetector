//
//  WGUSBDetector.h
//  WGUSBDetector
//
//  Created by Wade Gasior on 8/14/13.
//  Copyright (c) 2013 Variable Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WGUSBDetector;

@protocol WGUSBDetectorDelegate <NSObject>

- (void)USBDetectorDidDetectDeviceAdded:(WGUSBDetector *)detector;
- (void)USBDetectorDidDetectDeviceRemoved:(WGUSBDetector *)detector;

@end

@interface WGUSBDetector : NSObject

- (id)initWithDelegate: (NSObject<WGUSBDetectorDelegate> *)delegate forVID: (long)vid forPID: (long)pid;

@end
