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




// Cpp
typedef struct {
    uint32_t matched;
} scan_result_t;


class IOSH_Region {
public:
    IOSH_Region() {
        matched_offs = NULL;
    }
    struct proc_regioninfo a;
    vm_address_t address;
    vm_size_t size;
    std::vector<uintptr_t> * matched_offs;
    uint32_t matched_count;
};


// ObjC
@interface MemScanCore : NSObject
@property IOSH_Region * region;
-(void)resetRegions;
-(scan_result_t)scan:(void*)target compare_type:(char*)compare_type;



@end

#endif /* memoryScan_h */
