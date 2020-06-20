//
//  MemoryScan.m
//  iosh-agent
//
//  Created by Junyeong Lee on 2020/06/21.
//  Copyright © 2020 Junyeong Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MemoryScan.h"



@implementation MemScanCore
@synthesize region;

-(void)freeRegion{
    delete [] self.region;
}

-(void)initRegions{
    if(region){
        [self freeRegion];
    }
}

-(scan_result_t)scan:(void*)target compare_op:(char*)compare_op{
    scan_result_t result;
    

    return result;
    
}
@end
