//
//  iosh_agent.m
//  iosh-agent
//
//  Created by Junyeong Lee on 2020/06/16.
//  Copyright © 2020 Junyeong Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iosh_agent.h"
#import "substrate/substrate.h"
#import "Hooker/HookerManager.h"
#import "NetworkManager.h"

@implementation Iosh_agent


+(void)load{
    NSLog(@"[iosh] Start iosh_agent Load");
    NSBundle * bundle = [NSBundle mainBundle];
    NSString * app_name = [bundle bundleIdentifier];
    NSMutableDictionary * targets = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/Library/MobileSubstrate/DynamicLibraries/iosh_target.plist"];

    id target = [targets objectForKeyedSubscript:app_name];
    BOOL b = [target boolValue];
    if(b){
        NSLog(@"[iosh] TARGET NAME: %@",app_name);
        NetworkManager * networkMng = [[NetworkManager alloc] init];
        int ret = [networkMng doProcess];
        NSLog(@"[iosh] RET %08x",ret);
    }else{
        NSLog(@"[iosh] THIS IS NOT TARGET");
        return;
    }
}
@end
