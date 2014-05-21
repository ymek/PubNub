//
//  BGAppDelegate.m
//  Background Enabled Sample Application
//
//  Created by Sergey Mamontov on 4/10/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import "BGAppDelegate.h"
#import "BGDataManager.h"
#import "BGAlertView.h"


#pragma mark Public interface implementation

@implementation BGAppDelegate


#pragma mark - UIApplication delegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    BGAlertView *progressAlertView = [BGAlertView viewForProcessProgress];
    [progressAlertView showInView:self.window.rootViewController.view];
    
    [BGDataManager prepareWithCompletionHandler:^{

        [progressAlertView dismissWithAnimation:YES];
    }];
    

    return YES;
}

#pragma mark -


@end
