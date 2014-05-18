//
//  BVAppDelegate.m
//  backgroundvoip
//
//  Created by Sergey Mamontov on 4/10/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import "BVAppDelegate.h"
#import "BVDataManager.h"
#import "BVAlertView.h"


#pragma mark Public interface implementation

@implementation BVAppDelegate


#pragma mark - UIApplication delegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    BVAlertView *progressAlertView = [BVAlertView viewForProcessProgress];
    [progressAlertView showInView:self.window.rootViewController.view];
    
    [BVDataManager prepareWithCompletionHandler:^{
        
        [progressAlertView dismissWithAnimation:YES];
    }];
    

    return YES;
}

#pragma mark -


@end
