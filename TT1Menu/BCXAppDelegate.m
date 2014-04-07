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
}

- (void)setupStatusItem
{
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.title = @"";
    _statusItem.image = [NSImage imageNamed:@"menu-icon"];
    _statusItem.highlightMode = YES;
    [self setupMenu];
}

- (void)setupMenu
{
    NSMenu *menu = [[NSMenu alloc] init];
    [[AFHTTPRequestOperationManager manager] GET:@"http://fsaint.net/model_lock/" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"lock"] isKindOfClass:[NSString class]]) {
            NSString *lockedBy = responseObject[@"lock"];
            if ([lockedBy isEqualToString:NSUserName()]) {
                [menu addItemWithTitle:@"Unlock DB" action:@selector(lock:) keyEquivalent:@""];
            }
            else {
                [menu addItemWithTitle:[NSString stringWithFormat:@"Locked by: %@", responseObject[@"lock"]] action:nil keyEquivalent:@""];
            }
        }
        else {
            [menu addItemWithTitle:@"Lock DB" action:@selector(lock:) keyEquivalent:@""];
        }
        [self commonMenu:menu];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        [self commonMenu:menu];
    }];
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
