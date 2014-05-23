//
//  VSStateManager.m
//  voipsample
//
//  Created by Sergey Mamontov on 5/22/14.
//  Copyright (c) 2014 PubNub. All rights reserved.
//

#import "VSStateManager.h"


#pragma mark Static

/**
 Name of the channel which should be used by state manager.
 */
static NSString * const kVSChannelName = @"voipChannel";

NSString * const kVSStateManagerWillConnectNotification = @"VSStateManagerWillConnectNotification";
NSString * const kVSStateManagerDidConnectNotification = @"VSStateManagerDidConnectNotification";
NSString * const kVSStateManagerConnectionDidFailNotification = @"VSStateManagerConnectionDidFailNotification";


#pragma mark - Private interface declaration

@interface VSStateManager ()


#pragma mark - Properties

@property (nonatomic, assign, getter = isConnecting) BOOL connecting;

@property (nonatomic, strong) NSString *messages;


#pragma mark - Class methods

/**
 Complete manager preparation and make it ready for further usage.
 */
+ (void)prepare;


#pragma mark - Instance methods

#pragma mark - Handler methods

- (void)handleApplicationDidEnterBackground:(NSNotification *)notification;
- (void)handleApplicationDidBecomeActive:(NSNotification *)notification;

#pragma mark -


@end


#pragma mark - Public interface declaration

@implementation VSStateManager


#pragma mark - Class methods

+ (VSStateManager *)sharedInstance {
    
    static VSStateManager *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedInstance = [self new];
    });
    
    
    return _sharedInstance;
}

+ (void)prepare {
    
    [self sharedInstance];
}

+ (void)connect {
    
    [self prepare];
    
    // Check whether application is running in background or not.
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        
        PNLog(PNLogGeneralLevel, self, @"{INFO} Ask user to launch application for sockets configuration completion.");
        
        UILocalNotification *notification = [UILocalNotification new];
        notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1.0f];
        notification.alertBody = @"Please restart the app";
        notification.applicationIconBadgeNumber = ([UIApplication sharedApplication].applicationIconBadgeNumber + 1);
        notification.alertAction = @"Launch";
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    else {
        
        PNLog(PNLogGeneralLevel, self, @"{INFO} Connect to PubNub services.");
        
        [self sharedInstance].connecting = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:kVSStateManagerWillConnectNotification
                                                            object:[self sharedInstance] userInfo:nil];
        [PubNub connectWithSuccessBlock:^(NSString *origin) {
            
            [PubNub subscribeOnChannel:[PNChannel channelWithName:kVSChannelName]
           withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
               
               if (state != PNSubscriptionProcessNotSubscribedState) {
                   
                   [self sharedInstance].connecting = NO;
                   [[NSNotificationCenter defaultCenter] postNotificationName:kVSStateManagerDidConnectNotification
                                                                       object:[self sharedInstance]
                                                                     userInfo:[channels lastObject]];
               }
               else if (subscriptionError) {
                   
                   [self sharedInstance].connecting = NO;
                   [[NSNotificationCenter defaultCenter] postNotificationName:kVSStateManagerDidConnectNotification
                                                                       object:[self sharedInstance]
                                                                     userInfo:(id)subscriptionError];
               }
           }];
        }
                             errorBlock:^(PNError *connectionError) {
                                 
                                 [self sharedInstance].connecting = NO;
                                 [[NSNotificationCenter defaultCenter] postNotificationName:kVSStateManagerDidConnectNotification
                                                                                     object:[self sharedInstance]
                                                                                   userInfo:(id)connectionError];
                             }];
    }
}

+ (void)clearMessagesLog {
    
    [self sharedInstance].messages = @"";
}

+ (BOOL)isConnecting {
    
    return [self sharedInstance].isConnecting;
}


#pragma mark - Instance methods

- (id)init {
    
    // Check whether initializarion has been successful or not.
    if ((self = [super init])) {
        
        [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
        self.messages = @"";
        
        __block __pn_desired_weak __typeof(self) weakSelf = self;
        [[PNObservationCenter defaultCenter] addMessageReceiveObserver:weakSelf
                                                             withBlock:^(PNMessage *message) {
                                                                 
             NSDateFormatter *dateFormatter = [NSDateFormatter new];
             dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
             
             weakSelf.messages = [weakSelf.messages stringByAppendingFormat:@"<%@> %@\n",
                                  [dateFormatter stringFromDate:message.receiveDate.date],
                                  message.message];
        }];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    
    
    return self;
}


#pragma mark - Handler methods

- (void)handleApplicationDidEnterBackground:(NSNotification *)notification {
    
    if (self.isConnecting || ![PubNub sharedInstance].isConnected) {
        
        [PubNub disconnect];
        self.connecting = NO;
        UILocalNotification *notification = [UILocalNotification new];
        notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1.0f];
        notification.alertBody = @"Please keep app actove till connection completion.";
        notification.applicationIconBadgeNumber = ([UIApplication sharedApplication].applicationIconBadgeNumber + 1);
        notification.alertAction = @"Open";
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    else {
        
        PNLog(PNLogGeneralLevel, self, @"{INFO} Use VoIP to support background execution.");
        
        __block __pn_desired_weak __typeof(self) weakSelf = self;
        // In case if client was unable to connect or connect to controlling channel we will ask system to
        // pull our application back in 10 minutes and 10 seconds.
        [[UIApplication sharedApplication] setKeepAliveTimeout:610 handler:^{
            
            [[weakSelf class] connect];
        }];
    }
}

- (void)handleApplicationDidBecomeActive:(NSNotification *)notification {
    
    PNLog(PNLogGeneralLevel, self, @"{INFO} Stop using VoIP background execution support.");
    
    // Unregister from awakening on specified intervals to maintain connection to the origin.
    [[UIApplication sharedApplication] clearKeepAliveTimeout];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    if (!self.isConnecting && ![PubNub sharedInstance].isConnected) {
        
        [[self class] connect];
    }
}

#pragma mark -


@end
