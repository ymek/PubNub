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


#pragma mark Static

static NSUInteger const kBVConnectionTimeout = 30;
static NSUInteger const kBVMaximumMessagesPerSession = 10;


#pragma mark - Private interface declaration

@interface BVAppDelegate () <PNDelegate>


#pragma mark - Properties

@property (nonatomic, copy) void(^messageSendingBlock)(void);
@property (nonatomic, assign) NSUInteger messagesCounter;
@property (nonatomic, assign) NSUInteger sentMessagesPerSession;


#pragma mark - Instance methods

/**
 Launch background task which should be forcebly completed using timeout.
 
 @param backgroundTaskTimeout
 Timeout after which background task should be completed.
 
 @param handleBlock
 Block which is called when time out fired.
 
 @return block which can be called to terminate background execution block.
 */
- (void(^)(void))beginBackgroundTaskFor:(NSUInteger)backgroundTaskTimeout timeoutBlock:(void(^)(BOOL))handleBlock;

/**
 Launch background task.
 
 @return block which can be called to terminate background execution block.
 */
- (void(^)(void))beginBackgroundTask;

- (void)delayBlockCall:(void(^)(void))targetBlock afterTimeout:(NSInteger)timeout;

- (void)preparePubNubClient;
- (void)requestVoIPKeepAlive;

#pragma mark -


@end


#pragma mark Public interface implementation

@implementation BVAppDelegate


#pragma mark - Instance methods

- (void)delayBlockCall:(void(^)(void))targetBlock afterTimeout:(NSInteger)timeout {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (targetBlock) {
            
            targetBlock();
        }
    });
}

- (void)preparePubNubClient {
    
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    self.messageSendingBlock = ^{
        
        if([[PubNub sharedInstance] isConnected] && weakSelf.sentMessagesPerSession < kBVMaximumMessagesPerSession) {
            
            [PubNub sendMessage:@{@"msg":[NSString stringWithFormat:@"Ping message #%lu", (unsigned long)weakSelf.messagesCounter]}
                      toChannel:[PNChannel channelWithName:@"iosdev-background"] withCompletionBlock:^(PNMessageState state, id data) {
                          
                          if (state != PNMessageSending) {
                              
                              weakSelf.messagesCounter++;
                          }
                          
                          if (state != PNMessageSending) {
                              [weakSelf delayBlockCall:weakSelf.messageSendingBlock afterTimeout:1];
                          }
                      }];
            weakSelf.sentMessagesPerSession++;
        }
    };
    
    [[PNObservationCenter defaultCenter] removeMessageReceiveObserver:self];
    [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self withBlock:^(PNMessage *message) {
        
        if ([message.message isKindOfClass:[NSString class]] && [message.message isEqualToString:@"signal"]) {
            
            weakSelf.sentMessagesPerSession = 0;
            
            self.messageSendingBlock();
        }
    }];
    
    
    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
    
    BVAlertView *progressAlertView = [BVAlertView viewForProcessProgress];
    [progressAlertView showInView:self.window.rootViewController.view];
    __block void(^connectionHandleBlock)(void) = [self beginBackgroundTaskFor:kBVConnectionTimeout timeoutBlock:^(BOOL timedOut){
        
        if (timedOut) {
            
            PNLog(PNLogGeneralLevel, self, @"Well, looks like we didn't have enough time to complete connection and send init packet");
        }
        
        
        // Destroy reference on block in case if handle has chance to complete connection.
        connectionHandleBlock = nil;
    }];
    [PubNub connectWithSuccessBlock:^(NSString *origin) {
        
                            [PubNub subscribeOnChannel:[PNChannel channelWithName:@"iosdev-background"]
                           withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscribeError) {
                               
                               [PubNub sendMessage:@{@"cmd":@"Launch"} toChannel:[channels lastObject] withCompletionBlock:^(PNMessageState state, id data) {
                                   
                                   if (state != PNMessageSending) {
                                       
                                       if (connectionHandleBlock) {
                                           
                                           connectionHandleBlock();
                                       }
                                       
                                       [progressAlertView dismissWithAnimation:YES];
                                   }
                               }];
                           }];
                        }
                         errorBlock:^(PNError *connectionError) {
                             
                             NSString *detailedDescription = @"Waiting for internet connection check.";
                             if (connectionError) {
                                 
                                 detailedDescription = [NSString stringWithFormat:@"PubNub client unable to connect because of error: %@",
                                                        connectionError.localizedFailureReason];
                                 
                                 if (connectionHandleBlock) {
                                     
                                     connectionHandleBlock();
                                 }
                             }
                             
                             BVAlertView *view = [BVAlertView viewWithTitle:@"Connection state" type:BVAlertWarning
                                                               shortMessage:@"Unable to connect." detailedMessage:detailedDescription
                                                          cancelButtonTitle:@"OK" otherButtonTitles:nil andEventHandlingBlock:NULL];
                             [view showInView:self.window.rootViewController.view];
                             
                             [progressAlertView dismissWithAnimation:YES];
                         }];
//    [self requestVoIPKeepAlive];
}

- (void)requestVoIPKeepAlive {
    
    [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{
        
        [PubNub disconnect];
        [self preparePubNubClient];
    }];
}

- (void(^)(void))beginBackgroundTaskFor:(NSUInteger)backgroundTaskTimeout timeoutBlock:(void(^)(BOOL))handleBlock {
    
    __block BOOL isTimedOut = NO;
    __block BOOL shouldCallTimeoutBlock = YES;
    void(^completionBlock)(void) = ^{
        
        void(^taskCompletionBlock)(void) = [self beginBackgroundTask];
        if (taskCompletionBlock) {
            
            taskCompletionBlock();
        }
        if (handleBlock) {
            
            handleBlock(isTimedOut);
        }
        shouldCallTimeoutBlock = NO;
    };
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(backgroundTaskTimeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (shouldCallTimeoutBlock) {
            
            isTimedOut = YES;
            completionBlock();
        }
    });
    
    
    return completionBlock;
}

- (void(^)(void))beginBackgroundTask {
    
    __block BOOL shouldStop = NO;
    __block UIBackgroundTaskIdentifier identifier = UIBackgroundTaskInvalid;
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            while ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
                
                if (identifier != UIBackgroundTaskInvalid && !shouldStop) {
                    
                    [NSThread sleepForTimeInterval:1];
                }
                else if (shouldStop) {
                    
                    [[UIApplication sharedApplication] endBackgroundTask:identifier];
                    identifier = UIBackgroundTaskInvalid;
                    [self requestVoIPKeepAlive];
                }
            }
        });
        
        identifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            
            shouldStop = YES;
            [[UIApplication sharedApplication] endBackgroundTask:identifier];
            identifier = UIBackgroundTaskInvalid;
            [self requestVoIPKeepAlive];
        }];
    }
    else {
        
        [self requestVoIPKeepAlive];
    }
    
    return ^{
        
        shouldStop = YES;
    };
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
