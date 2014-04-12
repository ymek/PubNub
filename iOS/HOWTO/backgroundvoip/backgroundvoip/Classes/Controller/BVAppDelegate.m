//
//  BVAppDelegate.m
//  backgroundvoip
//
//  Created by Sergey Mamontov on 4/10/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import "BVAppDelegate.h"
#import "BVBackgroundHelper.h"


#pragma mark Static

static NSTimeInterval const kBVMessageSendInterval = 1.0f;


#pragma mark - Private interface declaration

@interface BVAppDelegate () <PNDelegate>


#pragma mark - Properties

@property (nonatomic, assign) NSInteger backgroundExecutionDuration;
@property (nonatomic, assign) NSInteger foregroundExecutionDuration;


#pragma mark - Instance methods

#pragma mark - Handler methods

- (void)handleMessageSendTimer:(NSTimer *)timer;

#pragma mark -


@end


#pragma mark Public interface implementation

@implementation BVAppDelegate


#pragma mark - Instance methods

#pragma mark - Handler methods

- (void)handleMessageSendTimer:(NSTimer *)timer {
    
    if ([[PubNub sharedInstance] isConnected]) {
        
        NSString *context = @"FOREGROUND";
        NSInteger currentValue = 0;
        NSTimeInterval timeInBackgroundHasLeft = [UIApplication sharedApplication].backgroundTimeRemaining;
        NSString *backgroundInfo = @"";
        
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
            
            _backgroundExecutionDuration++;
            context = @"BACKGROUND";
            backgroundInfo = [NSString stringWithFormat:@". %f seconds or %d minutes left to work in background",
                              timeInBackgroundHasLeft, (int)(timeInBackgroundHasLeft/60)];
            currentValue = self.backgroundExecutionDuration;
        }
        else {
            
            _foregroundExecutionDuration++;
            currentValue = self.foregroundExecutionDuration;
        }
        
        [PubNub sendMessage:[NSString stringWithFormat:@"In %@ for %ld seconds or %ld minutes%@",
                             context, (long)currentValue, (long)(currentValue/60), backgroundInfo]
                  toChannel:[PNChannel channelWithName:@"iosdev-voip-background"]];
    }
}


#pragma mark - UIApplication delegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [BVBackgroundHelper launch];
    [PubNub setupWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
    [PubNub connect];
    [PubNub subscribeOnChannel:[PNChannel channelWithName:@"iosdev-voip-background"]];
    
    
    return YES;
}


#pragma mark - PNDelegate methods

- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {
    
    if (self.backgroundExecutionDuration == 0) {
        
        [NSTimer scheduledTimerWithTimeInterval:kBVMessageSendInterval target:self selector:@selector(handleMessageSendTimer:)
                                       userInfo:nil repeats:YES];
    }
}

#pragma mark -


@end
