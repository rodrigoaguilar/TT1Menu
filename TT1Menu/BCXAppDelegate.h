//
//  BCXAppDelegate.h
//  TT1Menu
//
//  Created by Rodrigo Aguilar on 4/7/14.
//  Copyright (c) 2014 bContext. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SRWebSocket.h"

@interface BCXAppDelegate : NSObject <NSApplicationDelegate,SRWebSocketDelegate>


@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) NSString *lock;
@property (strong, nonatomic) SRWebSocket *ws;
@end
