//
//  HookerManager.h
//  iosh-agent
//
//  Created by Junyeong Lee on 2020/06/16.
//  Copyright © 2020 Junyeong Lee. All rights reserved.
//
#ifndef HookerManager_h
#define HookerManager_h

#import <Foundation/Foundation.h>
#include <sys/types.h>
#import "../substrate/substrate.h"


bool       IOSH_writeData(uintptr_t offset, void* data, size_t size);       // opcode : 0x00
bool       IOSH_HookProcess(pid_t pid, const char *library);                // opcode : 0x01
MSImageRef IOSH_GetImageByName(const char *file);                           // opcode : 0x02
void *     IOSH_FindSymbol(MSImageRef image, const char *name);             // opcode : 0x03
void       IOSH_HookFunction(void *symbol, void *replace, void **result);   // opcode : 0x04
void       IOSH_HookMessageEx(Class _class, SEL sel, IMP imp, IMP *result); // opcode : 0x05

@interface HookerManager : NSObject
@property uint8_t opcode;
-(int)doProcess:(uint8_t)opcode operand1:(uint8_t*)data1 operand2:(uint8_t*)data2;
@end

#endif
