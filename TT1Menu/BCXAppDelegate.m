//
//  BCXAppDelegate.m
//  TT1Menu
//
//  Created by Rodrigo Aguilar on 4/7/14.
//  Copyright (c) 2014 bContext. All rights reserved.
//

#import "BCXAppDelegate.h"
#import <AFNetworking/AFNetworking.h>


@implementation BCXAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self setupStatusItem];
    self.ws = [[SRWebSocket alloc] initWithURL:[[NSURL alloc] initWithString:@"http://fsaint.net/model_lock/ws/"]];
    self.ws.delegate = self;
    [self.ws open];
    NSLog(@"Did Fin");
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    NSError *error;
    
    NSString *string_data = (NSString *)message;
    
    
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:[string_data dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    
    [self updateMenu:response];

}


- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Did Open");
}
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@"Fail Error");
}
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"Did Close");
}


- (void)setupStatusItem
{
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.title = @"";
    _statusItem.image = [NSImage imageNamed:@"menu-icon"];
    _statusItem.highlightMode = YES;
    [self setupMenu];
}

-(void)updateMenu:(NSDictionary *)responseObject{
    NSMenu *menu = [[NSMenu alloc] init];
    if ([responseObject[@"lock"] isKindOfClass:[NSString class]]) {
        NSString *lockedBy = responseObject[@"lock"];
        if ([lockedBy isEqualToString:NSUserName()]) {
            [menu addItemWithTitle:@"Unlock DB" action:@selector(lock:) keyEquivalent:@""];
            
        }
        else {
            [menu addItemWithTitle:[NSString stringWithFormat:@"Locked by: %@", responseObject[@"lock"]] action:nil keyEquivalent:@""];
            
        }
        _statusItem.image = [NSImage imageNamed:@"menu-icon-locked"];
    }
    else {
        [menu addItemWithTitle:@"Lock DB" action:@selector(lock:) keyEquivalent:@""];
        _statusItem.image = [NSImage imageNamed:@"menu-icon"];
    }
    
    
    [self commonMenu:menu];

}

- (void)setupMenu
{
    NSMenu *menu = [[NSMenu alloc] init];
    [[AFHTTPRequestOperationManager manager] GET:@"http://fsaint.net/model_lock/" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self updateMenu:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        [self commonMenu:menu];
    }];
}
-(void)testWS:(id)sender{
    NSLog(@"TEST WS");
    

}
- (void)commonMenu:(NSMenu *)menu
{
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:@"Quit TT1Menu" action:@selector(terminate:) keyEquivalent:@""];
    self.statusItem.menu = menu;
}

- (void)lock:(NSMenuItem *)sender
{
    if ([sender.title isEqualToString:@"Lock DB"]) {
        NSString *path = [NSString stringWithFormat:@"http://fsaint.net/model_lock/lock?user=%@", NSUserName()];
        [[AFHTTPRequestOperationManager manager] GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            sender.title = @"Unlock DB";
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        }];
    }
    else {
        NSString *path = [NSString stringWithFormat:@"http://fsaint.net/model_lock/unlock?user=%@", NSUserName()];
        [[AFHTTPRequestOperationManager manager] GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            sender.title = @"Lock DB";
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        }];
    }
}

- (void)terminate:(id)sender
{
    [[NSApplication sharedApplication] terminate:self.statusItem.menu];
}

@end
