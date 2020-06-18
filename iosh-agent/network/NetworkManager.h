//
//  NetworkManager.h
//  iosh-agent
//
//  Created by Junyeong Lee on 2020/06/16.
//  Copyright © 2020 Junyeong Lee. All rights reserved.
//

#ifndef NetworkManager_h
#define NetworkManager_h
#import "HookerManager.h"

@interface NetworkManager : NSObject
@property HookerManager * hook_manager;
-(int)doProcess;


@end

#endif /* NetworkManager_h */
