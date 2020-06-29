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


mach_port_t g_target_task = 0;
bool g_firstScan = false;


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
    g_firstScan = true;
    
    int pid = [[NSProcessInfo processInfo] processIdentifier];
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

#define COMPARED_TYPE sizeof(uint32_t) // TODO. If it is uint32_t

-(bool)compare:(void*)target data:(void*)data type:(NSString*)type{
    if( [type isEqualToString:@"eq"] ){
        if(data == target)
            return true;
    }
    return false;
}

// (TODO) scan API like 'cheat engine' -> Don't use it. not finsih dev yet. (2020.06.29)
-(scan_result_t)scan:(void*)target compare_type:(NSString*)compare_type{
    scan_result_t result;
    
    vector<IOSH_Region>::iterator itRegion;
    for(itRegion = self.region_vec->begin(); itRegion != self.region_vec->end(); itRegion++){
        IOSH_Region region = *itRegion;
        vector<IOSH_Region> * used_regions = new vector<IOSH_Region>();
        
        vm_size_t raw_data_read_count = 0;
        size_t data_count = region.size / COMPARED_TYPE;

        uint8_t * region_data_p = new uint8_t[region.size];
        kern_return_t ret = vm_read_overwrite(g_target_task, region.address, region.size, (vm_address_t) region_data_p, &raw_data_read_count);
        if (ret == KERN_SUCCESS) {
            vector<uint32_t> * match_offs_vec = new vector<uint32_t>;
            uint8_t  * itRegion_data    = region_data_p;
            uint32_t match_count  = 0;
            
            if(g_firstScan){
                uint32_t idx = 0;
                uint8_t * end_p = (region_data_p + region.size);
                while (itRegion_data < end_p) {
                    if([self compare:target data:itRegion_data type:@"eq"]){
                        result.matched_offset->push_back(idx);
                        ++ match_count;
                    }
                    itRegion_data += COMPARED_TYPE;
                    idx += COMPARED_TYPE;
                }
            }
            if(match_count > 0){
                
            }
        }
    }
    [self freeRegion];
    return result;
}
@end


MemScanCore * g_scanner = [[MemScanCore alloc] init];

