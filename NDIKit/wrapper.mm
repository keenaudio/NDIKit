//
//  wrapper.m
//  ndimon
//
//  Created by Aaron Granick on 12/7/17.
//  Copyright © 2017 Aaron Granick. All rights reserved.
//

#import <string>
#import <dlfcn.h>
#import <chrono>

#import "wrapper.h"
#import <Processing.NDI.Lib.h>
//#import "wrapper.hpp"

struct NDILib {
    const NDIlib_v3 *instance;
};

const NDIlib_v3* getNDI()
{
    std::string ndi_path;

    // ToDo
    const char* p_NDI_runtime_folder = ::getenv("NDI_RUNTIME_DIR_V3");
    if (p_NDI_runtime_folder)
    {
        ndi_path = p_NDI_runtime_folder;
        ndi_path += "/libndi.dylib";
    }
    else
        ndi_path = "libndi.3.dylib"; // The standard versioning scheme on Linux based systems using sym links

    // Try to load the library
    void *hNDILib = ::dlopen(ndi_path.c_str(), RTLD_LOCAL | RTLD_LAZY);

    // The main NDI entry point for dynamic loading if we got the library
    const NDIlib_v3* (*NDIlib_v3_load)(void) = NULL;
    if (hNDILib)
        *((void**)&NDIlib_v3_load) = ::dlsym(hNDILib, "NDIlib_v3_load");

    if (!NDIlib_v3_load)
    {
        printf("Please re-install the NewTek NDI Runtimes to use this application.");
        return 0;
    }

    // Lets get all of the DLL entry points
    const NDIlib_v3* p_NDILib = NDIlib_v3_load();

    // We can now run as usual
    if (!p_NDILib->NDIlib_initialize())
    {    // Cannot run NDI. Most likely because the CPU is not sufficient (see SDK documentation).
        // you can check this directly with a call to NDIlib_is_supported_CPU()
        printf("Cannot run NDI.");
        return 0;
    }

    return p_NDILib;
}

@implementation NDISource

- (id) init {
    if (self = [super init]) {
        // TODO
    } return self;
    
}

@end

@implementation NDIFinder

- (id) init {
    if (self = [super init]) {
        lib = new NDILib();
        lib->instance = getNDI();
    } return self;

}

- (void) find:(void(^)(NDISource *))callback {
    const NDIlib_v3 *api = self->lib->instance;
    bool exit_loop = false;
    NDIlib_source_t src;
    NSString *name;
    NSString *ip;
    
    // Not required, but "correct" (see the SDK documentation.
    if (!api->NDIlib_initialize())
    {    // Cannot run NDI. Most likely because the CPU is not sufficient (see SDK documentation).
        // you can check this directly with a call to NDIlib_is_supported_CPU()
        printf("Cannot run NDI.");
        return;
    }
    
    
    // We are going to create an NDI finder that locates sources on the network.
    // including ones that are available on this machine itself. It will use the default
    // groups assigned for the current machine.
    NDIlib_find_create_t NDI_find_create_desc; /* Use defaults */
    NDIlib_find_instance_t pNDI_find = api->NDIlib_find_create_v2(&NDI_find_create_desc);
    if (!pNDI_find) return;
    
    // Run for one minute
    const auto start = std::chrono::high_resolution_clock::now();
    while (!exit_loop && std::chrono::high_resolution_clock::now() - start < std::chrono::minutes(1))
    {    // Wait up till 5 seconds to check for new sources to be added or removed
        if (!api->NDIlib_find_wait_for_sources(pNDI_find, 5000))
        {    // No new sources added !
            printf("No change to the sources found.\n");
        }
        else
        {    // Get the updated list of sources
            uint32_t no_sources = 0;
            const NDIlib_source_t* p_sources = api->NDIlib_find_get_current_sources(pNDI_find, &no_sources);
            
            // Display all the sources.
            printf("Network sources (%u found).\n", no_sources);
            for (uint32_t i = 0; i < no_sources; i++) {
                printf("%u. %s\n", i + 1, p_sources[i].p_ndi_name);
                src = p_sources[i];
//                name = theirs.p_ndi_name;
//                ip = theirs.p_ip_address;
                name = [NSString stringWithUTF8String:src.p_ndi_name];
                ip = [NSString stringWithUTF8String:src.p_ip_address];
                
                NDISource *payload = [[NDISource alloc] init];
                payload.name = name;
                payload.ip = ip;
                
                //src->ip = p_sources[i].p_ip_address as NSString;
                callback(payload);
                
                
            }
        }
    }
    
    // Destroy the NDI finder
    api->NDIlib_find_destroy(pNDI_find);
}
    
@end

@implementation NDIWrapper

- (id) init {
    if (self = [super init]) {
        lib = new NDILib();
        lib->instance = getNDI();
    } return self;
}

- (void) dealloc {
    //delete wrapper->parser;
    // TODO: cleanup ndi lib?
    delete lib;
}

@end

