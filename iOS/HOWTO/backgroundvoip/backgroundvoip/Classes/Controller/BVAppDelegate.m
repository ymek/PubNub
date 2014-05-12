//
//  BVAppDelegate.m
//  backgroundvoip
//
//  Created by Sergey Mamontov on 4/10/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import "BVAppDelegate.h"
#import "BVBackgroundHelper.h"
#import "BVAlertView.h"


#pragma mark Private interface declaration

@interface BVAppDelegate () <PNDelegate>


#pragma mark - Instance methods

- (void)preparePubNubClient;

#pragma mark -


@end


#pragma mark Public interface implementation

@implementation BVAppDelegate


#pragma mark - Instance methods

- (void)preparePubNubClient {

    __block __pn_desired_weak __typeof(self) weakSelf = self;
    BVAlertView *progressAlertView = [BVAlertView viewForProcessProgress];
    [progressAlertView showInView:self.window.rootViewController.view];

    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
    [PubNub setClientIdentifier:@"iPhoneVOIP1"
            ""];
    [BVBackgroundHelper prepareWithInitializationCompleteHandler:^(void (^completionBlock)(void)) {

        [PubNub subscribeOnChannel:[PNChannel channelWithName:@"zzz"]
        withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *array, PNError *error) {

            [progressAlertView dismissWithAnimation:YES];

            PNLog(PNLogGeneralLevel, weakSelf, @"{INFO} User's configuration code execution completed.");

            // Finalization block is required to change background support mode.
            completionBlock();
        }];
    }
                                        andReinitializationBlock:^{

                                            PNLog(PNLogGeneralLevel, weakSelf, @"{INFO} Reinitialize block called.");

                                            [PubNub disconnect];
                                            [weakSelf preparePubNubClient];
                                        }];
    [BVBackgroundHelper connectWithSuccessBlock:^(NSString *origin) {
        
        PNLog(PNLogGeneralLevel, self, @"{INFO} Connected to %@", origin);
    } errorBlock:^(PNError *connectionError) {
        
        if (connectionError) {
            
            PNLog(PNLogGeneralLevel, self, @"{ERROR} Failed to connect because of error: %@", connectionError);
        }
    }];
}


#pragma mark - UIApplication delegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self preparePubNubClient];


    return YES;
}

#pragma mark -


@end
