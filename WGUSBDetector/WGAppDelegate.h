//
//  WGAppDelegate.h
//  WGUSBDetector
//
//  Created by Wade Gasior on 8/14/13.
//  Copyright (c) 2013 Variable Technologies. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WGUSBDetector.h"

@interface WGAppDelegate : NSObject <NSApplicationDelegate, WGUSBDetectorDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (strong, nonatomic) WGUSBDetector *usbDetector;
@property (weak) IBOutlet NSColorWell *colorWell;

@end
