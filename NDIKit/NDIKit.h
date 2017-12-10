//
//  NDIKit.h
//  NDIKit
//
//  Created by Aaron Granick on 12/8/17.
//  Copyright © 2017 Aaron Granick. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//! Project version number for NDIKit.
FOUNDATION_EXPORT double NDIKitVersionNumber;

//! Project version string for NDIKit.
FOUNDATION_EXPORT const unsigned char NDIKitVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <NDIKit/PublicHeader.h>


#include <Foundation/Foundation.h>

struct NDILib;

@interface NDIWrapper: NSObject {
    struct NDILib *lib;
}

- (id) init;
- (void) dealloc;
@end

@interface NDISource : NSObject

@property NSString *name;
@property NSString *ip;

@end

@interface NDIFinder: NSObject {
    struct NDILib *lib;
}

- (id) init;
- (void) find:(void(^)(NDISource *))callback;
@end


//#import "wrapper.h"
