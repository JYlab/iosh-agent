//
//  memoryScan.h
//  iosh-agent
//
//  Created by Junyeong Lee on 2020/06/21.
//  Copyright © 2020 Junyeong Lee. All rights reserved.
//

#ifndef memoryScan_h
#define memoryScan_h
#include <mach/mach.h>
#include <libproc.h>
#include <memory>
#include <string>
#include <vector>

#define GET_PID() [[NSProcessInfo processInfo] processIdentifier]
#define COMPARED_TYPE sizeof(uint32_t) // TODO. If it is uint32_t

using namespace std;

// Cpp
typedef struct {
    vector<uint64_t> * matched_offset; // TODO: uint32_t -> defined by user
} scan_result_t;


class IOSH_Memory_Page {
public:
    IOSH_Memory_Page() {
        addresses = NULL;
        data = NULL;
        data_size = 0;
    }
    ~IOSH_Memory_Page() {
        if (addresses) {
            delete addresses;
        }
        if (data) {
            delete[] data;
        }
    }
public:
    vector<vm_address_t> * addresses;
    uint8_t * data;
    size_t data_size;
};


class IOSH_Region {
public:
    IOSH_Region() {
        this->address       = NULL;
        this->size          = NULL;
        this->matched_offs  = NULL;
    }
    ~IOSH_Region(){
        this->address       = NULL;
        this->size          = NULL;
        this->matched_count = NULL;
        delete  this->matched_offs;
        this->matched_offs  = NULL;
    }
    vm_address_t address             = NULL;
    vm_size_t size                   = 0;
    vector<uintptr_t> * matched_offs = NULL;
    uint32_t matched_count           = 0;
};


// ObjC
@interface MemScanCore : NSObject
@property std::vector<IOSH_Region> * region_vec;
-(void)resetRegions;
-(scan_result_t)scan:(void*)target compare_type:(NSString*)compare_type;

@end

#endif /* memoryScan_h */
