//
//  wrapper.h
//  ndimon
//
//  Created by Aaron Granick on 12/7/17.
//  Copyright © 2017 Aaron Granick. All rights reserved.
//

#ifndef wrapper_h
#define wrapper_h

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


#endif /* wrapper_h */
