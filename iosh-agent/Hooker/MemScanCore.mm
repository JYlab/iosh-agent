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
@synthesize region;

-(void)freeRegion{
    delete [] self.region;
}

-(void)resetRegions{
    if(region){
        [self freeRegion];
    }
    region = new IOSH_Region();
    
}

-(scan_result_t)scan:(void*)target compare_type:(char*)compare_type{
    scan_result_t result;
    

    return result;
    
}
@end
