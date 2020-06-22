//
//  MemoryScan.m
//  iosh-agent
//
//  Created by Junyeong Lee on 2020/06/21.
//  Copyright © 2020 Junyeong Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MemScanCore.h"
#include <sys/proc.h>
#include <libproc.h>

@implementation MemScanCore
@synthesize region_vec;

// Delete all of 'obj' in 'region_vec'
-(void)freeRegion{
    for(int i =0; self.region_vec->size(); ++i){
        (*self.region_vec)[i].address = 0;
        (*self.region_vec)[i].matched_count = 0;
        (*self.region_vec)[i].size = 0;
        delete (*self.region_vec)[i].matched_offs;
    }
    delete self.region_vec;
    self.region_vec = NULL;
}


// Get regions that can be write
-(void)resetRegions{
    if(self.region_vec){
        [self freeRegion];
    }
    int pid = 0; // TODO
    kern_return_t ret = NULL;
    struct proc_regioninfo region_info;
    uint64_t address = 0;
    int count = 0;
    self.region_vec = new std::vector<IOSH_Region>();
    while(true){
        ret = proc_pidinfo(pid, PROC_PIDREGIONINFO, address, &region_info, sizeof(region_info));
        address = region_info.pri_address + region_info.pri_size;
        
        if( ret == sizeof(region_info) ) break;
        if (address){
            boolean_t writable = (region_info.pri_protection & VM_PROT_DEFAULT) == VM_PROT_DEFAULT;
            if (writable) {
                IOSH_Region iosh_region;
                iosh_region.address = region_info.pri_address;
                iosh_region.size    = region_info.pri_size;
                self.region_vec->push_back(iosh_region);
                count ++;
            }
        }
    }
}

// (TODO) scan API like 'cheat engine'
-(scan_result_t)scan:(void*)target compare_type:(char*)compare_type{
    scan_result_t result;
    

    return result;
    
}
@end
