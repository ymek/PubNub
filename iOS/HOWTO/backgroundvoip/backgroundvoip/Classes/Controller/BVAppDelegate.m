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


#pragma mark - Properties

@property (nonatomic, assign) NSInteger backgroundExecutionDuration;
@property (nonatomic, assign) NSInteger foregroundExecutionDuration;


#pragma mark - Instance methods

- (void)preparePubNubClient;

#pragma mark -


@end


#pragma mark Public interface implementation

@implementation BVAppDelegate


#pragma mark - Instance methods

- (void)preparePubNubClient {
    
    [[PNObservationCenter defaultCenter] removeMessageReceiveObserver:self];
    [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self withBlock:^(PNMessage *message) {
        
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
            
            if ([message.message isKindOfClass:[NSDictionary class]] && [message.message valueForKey:@"pong"] == nil) {
                
                UILocalNotification *notification = [UILocalNotification new];
                notification.alertBody = [NSString stringWithFormat:@"PubNub received:\n%@", message.message];
                notification.alertAction = @"Back to PubNub";
                notification.soundName = UILocalNotificationDefaultSoundName;
                notification.applicationIconBadgeNumber = ([UIApplication sharedApplication].applicationIconBadgeNumber + 1);
                
                [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                
                [PubNub sendMessage:@{@"pong":message.message} toChannel:message.channel];
            }
        }
    }];
    
    
    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
    
    BVAlertView *progressAlertView = [BVAlertView viewForProcessProgress];
    [progressAlertView showInView:self.window.rootViewController.view];
    [PubNub connectWithSuccessBlock:^(NSString *origin) {
        
        [PubNub subscribeOnChannel:[PNChannel channelWithName:@"iosdev-background"]
       withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscribeError) {
           
           [progressAlertView dismissWithAnimation:YES];
       }];
    }
                         errorBlock:^(PNError *connectionError) {
                             
                             NSString *detailedDescription = @"Waiting for internet connection check.";
                             if (connectionError) {
                                 
                                 detailedDescription = [NSString stringWithFormat:@"PubNub client unable to connect because of error: %@",
                                                        connectionError.localizedFailureReason];
                             }
                             
                             BVAlertView *view = [BVAlertView viewWithTitle:@"Connection state" type:BVAlertWarning
                                                               shortMessage:@"Unable to connect." detailedMessage:detailedDescription
                                                          cancelButtonTitle:@"OK" otherButtonTitles:nil andEventHandlingBlock:NULL];
                             [view showInView:self.window.rootViewController.view];
                             
                             [progressAlertView dismissWithAnimation:YES];
                         }];
    
    [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{
        
        [PubNub disconnect];
        [self preparePubNubClient];
    }];
}

#pragma mark - UIApplication delegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self preparePubNubClient];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

#pragma mark -


@end
