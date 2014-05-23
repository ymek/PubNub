//
//  GSStateManager.m
//  gpssample
//
//  Created by Sergey Mamontov on 5/22/14.
//  Copyright (c) 2014 PubNub. All rights reserved.
//

#import "GSStateManager.h"
#import <CoreLocation/CLLocationManagerDelegate.h>
#import <CoreLocation/CLLocationManager.h>


#pragma mark Static

/**
 Name of the channel which should be used by state manager.
 */
static NSString * const kVSChannelName = @"gpsChannel";

NSString * const kVSStateManagerWillConnectNotification = @"VSStateManagerWillConnectNotification";
NSString * const kVSStateManagerDidConnectNotification = @"VSStateManagerDidConnectNotification";
NSString * const kVSStateManagerConnectionDidFailNotification = @"VSStateManagerConnectionDidFailNotification";


#pragma mark - Private interface declaration

@interface GSStateManager () <CLLocationManagerDelegate>


#pragma mark - Properties

@property (nonatomic, assign, getter = isConnecting) BOOL connecting;

@property (nonatomic, strong) NSString *messages;
@property (nonatomic, strong) CLLocationManager *locationManager;


#pragma mark - Class methods

/**
 Complete manager preparation and make it ready for further usage.
 */
+ (void)prepare;


#pragma mark - Instance methods

- (void)startBackgroundSupport;
- (void)stopBackgroundSupport;


#pragma mark - Handler methods

- (void)handleApplicationDidEnterBackground:(NSNotification *)notification;
- (void)handleApplicationDidBecomeActive:(NSNotification *)notification;

#pragma mark -


@end


#pragma mark - Public interface declaration

@implementation GSStateManager


#pragma mark - Class methods

+ (GSStateManager *)sharedInstance {
    
    static GSStateManager *_sharedInstance;
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
        
        [[self sharedInstance] startBackgroundSupport];
    }
    else {
        
        [[self sharedInstance] stopBackgroundSupport];
    }
        
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

             [UIApplication sharedApplication].applicationIconBadgeNumber = ([UIApplication sharedApplication].applicationIconBadgeNumber + 1);
        }];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        
        [self startBackgroundSupport];
    }
    
    
    return self;
}

- (void)startBackgroundSupport {
    
    PNLog(PNLogGeneralLevel, self, @"{INFO} Use GPS to support background execution.");
    
    if (!self.locationManager) {
        
        self.locationManager = [CLLocationManager new];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        [self.locationManager startUpdatingLocation];
    }
}

- (void)stopBackgroundSupport {
    
    if (self.locationManager && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
    
        PNLog(PNLogGeneralLevel, self, @"{INFO} Stop using GPS background execution support.");
        
        [self.locationManager stopUpdatingLocation];
        self.locationManager = nil;
    }
}


#pragma mark - Handler methods

- (void)handleApplicationDidEnterBackground:(NSNotification *)notification {
    
    [self startBackgroundSupport];
}

- (void)handleApplicationDidBecomeActive:(NSNotification *)notification {
        
    [self stopBackgroundSupport];
}


#pragma mark - CLLocationManager delegate methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    [self stopBackgroundSupport];
}

#pragma mark -


@end
