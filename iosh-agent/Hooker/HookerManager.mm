//
//  HookerManager.m
//  iosh-agent
//
//  Created by Junyeong Lee on 2020/06/16.
//  Copyright © 2020 Junyeong Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <inttypes.h>

#import "HookerManager.h"
#import "writeData.h"
#import "MemScanCore.h"

#define UINT_PTR_SIZE  sizeof(uintptr_t)
#define SIZE_T_SIZE    sizeof(size_t)
#define UINT32_SIZE    sizeof(uint32_t)
#define free_operand(x, y) free(x);free(y);
#define SWAP_UINT32(x) (((x) >> 24) | (((x) & 0x00FF0000) >> 8) | (((x) & 0x0000FF00) << 8) | ((x) << 24))


extern MemScanCore * g_scanner;

@implementation HookerManager
@synthesize opcode;

-(int)doProcess:(uint8_t)opcode operand1:(uint8_t*)data1 operand2:(uint8_t*)data2 {
    self.opcode = opcode;
    NSLog(@"Start doProcess");
    
    if(self.opcode == 0x00){
        /*
            -- OPCODE 0x00 : memory hacking --
            opcode  size : 1 byte
            offset  size : 8 byte
            replace size : 8 byte (->but 4 byte used)
            total   size : 17 byte
        */
        uintptr_t  offset  = 0;
        uint32_t   replace = 0;
        memcpy(&offset , data1, sizeof(uint64_t));
        memcpy(&replace, data2, sizeof(uint32_t));
        SWAP_UINT32(replace);
        
        NSLog(@"OPCODE  : %02x " , self.opcode);
        NSLog(@"OFFSET  : 0x%08lx" , offset);
        NSLog(@"REPLACE : 0x%08x " , replace);
        BOOL ret = writeData(offset, replace);
        free_operand(data1, data2);
        return ret;
    
    }else if(self.opcode == 0x01){
        /*
            -- OPCODE 0x01 : memory scanner --
            opcode     size : 1 byte
            offset     size : 8 byte
            reset flag size : 1 byte
            total      size : 10 byte
        */
        NSLog(@"Start opcode 0x01");
        uint64_t resetOP = 0;
        memcpy(&resetOP , data2, sizeof(uint64_t));
        if(resetOP == 1){
            [g_scanner resetRegions];
            NSLog(@"finish reset");
        }
        NSLog(@"g_scanner start");
        scan_result_t result = [g_scanner scan:data1 compare_type:@"eq"]; // TODO -> Chnage hardcoding "eq"
        NSLog(@"g_scanner finish");
        for(int i=0; result.matched_offset->size(); i++){
            
            NSLog(@"Matched Offset  : 0x%llu", (*result.matched_offset)[i] );
        }
    
    }else if(self.opcode == 0x02){
        /*
            -- OPCODE 0x00 : memory hacking by raw address --
            opcode  size : 1byte
            offset  size : 8byte
            replace size : 8byte (->but 4 byte used)
            total   size : 17byte
        */
        uintptr_t raw_address = 0;
        uint32_t  replace = 0;
        memcpy(&raw_address , data1, sizeof(uint64_t));
        memcpy(&replace, data2, sizeof(uint32_t));
        SWAP_UINT32(replace);
        
        NSLog(@"OPCODE      : %02x "  , self.opcode);
        NSLog(@"raw_address : 0x%08lx", raw_address);
        NSLog(@"REPLACE     : 0x%08x ", replace);
        
        if (KERN_SUCCESS != vm_write( GET_PID(), raw_address, (vm_offset_t)&replace, COMPARED_TYPE )) {
            NSLog(@"Failed memory hacking by raw address");
        }
    }
    
    return 0;
}

@end
