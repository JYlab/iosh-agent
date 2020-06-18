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
#import "HookerManager.h"
#import "writeData.h"
#define UINT_PTR_SIZE  sizeof(uintptr_t)
#define SIZE_T_SIZE    sizeof(size_t)
#define UINT32_SIZE    sizeof(uint32_t)

@implementation HookerManager
@synthesize opcode;

-(int)doProcess:(uint8_t)opcode operand1:(uint8_t*)data1 operand2:(uint8_t*)data2{
    self.opcode = opcode;
    
    // [ 0x00 ]
    // opcode  1byte
    // offset  4byte
    // replace 4byte
    // total : 9byte
    if(self.opcode == 0x00){
        // TODO
        uint32_t  offset  = -1;
        uint32_t  replace = -1;
        memcpy(&offset , data1, sizeof(uint32_t));
        memcpy(&replace, data2, sizeof(uint32_t));
        
        NSLog(@"OPCODE  : %02x ", self.opcode);
        NSLog(@"OFFSET  : %08x ", offset);
        NSLog(@"REPLACE : %08x ", replace);
        return 0;
        
    }else if(self.opcode == 0x01){
        // TODO
        
    }else if(self.opcode == 0x02){
        // TODO
    }
    
    return 0;
}

@end
