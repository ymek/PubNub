//
//  BVBackgroundHelper.m
//  backgroundvoip
//
//  Created by Sergey Mamontov on 4/11/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import "BVBackgroundHelper.h"
#import <CoreLocation/CoreLocation.h>


#pragma mark Static

/**
 How many seconds it is allowed to use GPS radio to keep application working in background.
 After timeout application will be registered for awaken on intervals (those which is used to maintain connection
 once per 10 minutes).
 */
static NSTimeInterval const kBVMaximumGPSSupportedBackgroundActivity = 90.0f;

/**
 Stores reference on maximum number of messages which can be received while application is in background and use VoIP
 to support it's operation.
 */
static NSUInteger const kBVMaximumNumberOfMessages = 14;

/**
 Stores reference on maximum number of messages which can be received in VoIP background support mode out of
 schedule before switching to GPS background supporting mode. Number of messages which has been received in a row.
 */
static NSUInteger const kBVMaximumNumberOfMessagesOutOfSchedule = 3;

/**
 Stores reference on how many seconds should be between received messages if application work in background.
 This constant also used for timer which is used to measure time while application is active after awakening.
 */
static NSTimeInterval const kBVMinimumTimeDifferenceBetweenMessages = 9.0f;


#pragma mark - Private interface declaration

@interface BVBackgroundHelper () <CLLocationManagerDelegate>


#pragma mark - Properties

/**
 Stores reference on configured location manager which will allow application work while it in background.
 */
@property (nonatomic, strong) CLLocationManager *locationManager;

/**
 Stores reference on block which should be used by helper to complete application stack and PubNub client
 configuration.
 */
@property (nonatomic, copy) void(^completionHandler)(void(^)(void));

/**
 Stores reference on block which should be used by helper in case if stack reinitialization will be required.
 */
@property (nonatomic, copy) void(^reinitializationBlock)(void);

/**
 Stores reference on timer which is used to observe on how long application is running in background using GPS radio.
 */
@property (nonatomic, strong) NSTimer *gpsUsageTimer;

/**
 Stores reference on timer which is used by helper to calculate how much time application spent in active state after
  resuming from suspended state using VoIP functionality.
 */
@property (nonatomic, strong) NSTimer *activityTimer;

/**
 Stores whether helper use VoIP backgrounding style at this moment or not.
 */
@property (nonatomic, assign, getter = isVoIPBackgroundMode) BOOL VoIPBackgroundMode;

/**
 Stores whether helper completed configuration or not.
 */
@property (nonatomic, assign, getter = isConfigurationCompleted) BOOL configurationCompleted;

/**
 Stores reference on date when application has been sent to background.
*/
@property (nonatomic, strong) NSDate *applicationSuspensionDate;

/**
 Stores reference on date of last message retrieval.
*/
@property (nonatomic, strong) NSDate *lastDataAcceptanceDate;

/**
 Stores number of messages which has been received out of schedule in a row.
 */
@property (nonatomic, assign) NSUInteger numberOfUnexpectedMessages;

/**
 Stores total number of times when application has been awaken in VoIP mode.
 */
@property (nonatomic, assign) NSUInteger numberOfAwakes;


#pragma mark - Class methods

+ (BVBackgroundHelper *)sharedInstance;


#pragma mark - Instance methods

/**
 Perform calculations and check whether client exceeded limit on how many messages should be received in specified
 time frame.
 */
- (void)processNewPubNubData;

/**
 Launch activity timer if required to calculate while app is active in background for VoIP.
 */
- (void)launchActivityTimer;

/**
 Terminating activity timer.
 */
- (void)stopActivityTimer;

/**
 Allow to launch GPS location updates observation and timer which will forcefully change backgrounding style.

 @param shouldLaunchTimeoutTimer
 Whether or not timeout timer should be launched during GPS background mode usage.
 */
- (void)switchToGPSSupportedBackgroundMode:(BOOL)shouldLaunchTimeoutTimer;

/**
 Allow to launch VoIP supported background style which will periodically reinitialize application stack.
 */
- (void)switchToVoIPSupportedBackgroundMode;

/**
 Allow to disable VoIP and GPS algorithms for background supporting.
 */
- (void)disableAllBackgroundSupportingModes;

/**
 Clean up all cached values related to received data packets.
 */
- (void)resetDataPacketsStatistic;


#pragma mark - Handler methods

- (void)handleApplicationDidEnterBackground:(NSNotification *)notification;
- (void)handleApplicationDidBecomeActive:(NSNotification *)notification;
- (void)handlePubNubClientWillConnect:(NSNotification *)notification;
- (void)handleGPSSupportedBackgroundModeTimeout:(NSTimer *)timer;
- (void)handleVoIPActivityTimeout:(NSTimer *)timer;

#pragma mark -


@end


#pragma mark Public interface implementation

@implementation BVBackgroundHelper


#pragma mark - Class methods

+ (BVBackgroundHelper *)sharedInstance {
    
    static BVBackgroundHelper *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedInstance = [self new];
    });
    
    
    return _sharedInstance;
}

+ (void)prepareWithInitializationCompleteHandler:(void(^)(void(^)(void)))completionHandler
                        andReinitializationBlock:(void(^)(void))reinitializationBlock {

    __block __pn_desired_weak __typeof(self) weakSelf = self;
    [self sharedInstance].reinitializationBlock = ^{

        [weakSelf sharedInstance].configurationCompleted = NO;
        if (reinitializationBlock) {

            reinitializationBlock();
        }
    };
    [self sharedInstance].completionHandler = completionHandler;
}

+ (void)connectWithSuccessBlock:(void(^)(NSString *))success errorBlock:(void(^)(PNError *))failure {
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        
        [[self sharedInstance] switchToGPSSupportedBackgroundMode:NO];
    }
    
    [PubNub connectWithSuccessBlock:success errorBlock:failure];
}

#pragma mark - Instance methods

- (id)init {
    
    // Check whether initialization has been successful or not.
    if ((self = [super init])) {

        __block __pn_desired_weak __typeof(self) weakSelf = self;

        // Subscribe on PubNub client connection state observation.
        [[PNObservationCenter defaultCenter] addClientConnectionStateObserver:self
                                                            withCallbackBlock:^(NSString *origin, BOOL connected,
                                                                                PNError *connectionError) {

            if (connected) {

                // Lets subscribe on some controlling channel which will be responsible for awakening application to
                // accept new portion of data.
                [PubNub subscribeOnChannel:[PNChannel channelWithName:@"iosdev-background"]
               withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *array, PNError *subscribeError) {

                    // Ensure that PubNub client completed subscription to the controlling channel.
                    if (state != PNSubscriptionProcessNotSubscribedState) {

                        PNLog(PNLogGeneralLevel, weakSelf, @"{INFO} Whoooray, controlling channel plugged in and ready "
                              "to send commands.");

                        void(^completionHandler)(void) = ^{

                            weakSelf.configurationCompleted = YES;
                            [weakSelf switchToVoIPSupportedBackgroundMode];
                        };
                        if (weakSelf.completionHandler) {

                            // Passing block which will be called by user at the end of his preparations to switch
                            // execution mode back to VoIP style.
                            weakSelf.completionHandler(completionHandler);
                        }
                        else {

                            completionHandler();
                        }
                    }
                    else if (subscribeError){

                        PNLog(PNLogGeneralLevel, weakSelf, @"{ERROR} Looks like there is no ability to subscribe on "
                              "controlling channel because of error: %@", subscribeError.localizedFailureReason);

                        [weakSelf switchToVoIPSupportedBackgroundMode];
                    }
                }];
            }
            // Looks like client is unable to connect because of some reasons (no internet connection or troubles
            // with SSL),
            else if (connectionError) {

                PNLog(PNLogGeneralLevel, weakSelf, @"{ERROR} Looks like PubNub client were unable to connect to the "
                      "origin because of error: %@", connectionError.localizedFailureReason);

                switch (connectionError.code) {

                    case kPNClientConnectionFailedOnInternetFailureError:
                    case kPNClientConnectionClosedOnInternetFailureError:
                    case kPNClientConnectionClosedOnServerRequestError:

                        // We will wait, but not very long (as specified in timeout value).
                        [weakSelf switchToGPSSupportedBackgroundMode:YES];
                        break;
                    default:
                        break;
                }
            }
            // Looks like PubNub client doesn't have enough time to complete network availability check so we just
            // need to wait. Or client has been disconnected by user request.
            else if (!connectionError && !connected) {

                PNLog(PNLogGeneralLevel, weakSelf, @"{INFO} PubNub client wasn't able to check network connection "
                      "availability or disconnected by user request");

                // We will wait, but not very long (as specified in timeout value).
                [weakSelf switchToGPSSupportedBackgroundMode:YES];
            }
        }];

        // Adding observation over message receive events.
        [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self withBlock:^(PNMessage *message) {

            [weakSelf processNewPubNubData];
        }];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePubNubClientWillConnect:)
                                                     name:kPNClientWillConnectToOriginNotification object:nil];

        self.locationManager = [CLLocationManager new];
    }
    
    
    return self;
}

- (void)setLocationManager:(CLLocationManager *)locationManager {
    
    if (!locationManager) {
        
        [_locationManager stopUpdatingLocation];
        _locationManager.delegate = nil;
    }
    else {
        
        locationManager.delegate = self;
        locationManager.pausesLocationUpdatesAutomatically = NO;
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        locationManager.distanceFilter = 5;
        if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
            
            [locationManager startUpdatingLocation];
            [locationManager stopUpdatingLocation];
        }
    }
    _locationManager = locationManager;
}

- (void)processNewPubNubData {

    BOOL isAwaken = NO;

    // Checking whether data processing has been called while application was in background execution context for
    // first time (activity time will be disabled)
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground && ![self.activityTimer isValid]) {

        if (self.isVoIPBackgroundMode) {
            
            PNLog(PNLogGeneralLevel, self, @"{INFO} Application has been awaken. In plain VoIP background support mode "
                  "there is roughly.");

            isAwaken = YES;

            [self launchActivityTimer];

            PNLog(PNLogGeneralLevel, self, @"{INFO} There is roughly %f seconds to complete all operations before "
                  "suspension.", kBVMinimumTimeDifferenceBetweenMessages);
        }
    }
    else if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {

        [self stopActivityTimer];
    }

    if (isAwaken) {

        if (self.isVoIPBackgroundMode) {

            self.numberOfAwakes++;
            BOOL shouldSwitchToGPSSupportMode = NO;
            NSDate *currentDate = [NSDate date];
            NSTimeInterval timeInBackground = [currentDate timeIntervalSinceDate:self.applicationSuspensionDate];

            // Checking whether we received to many messages in 300 seconds time window or not.
            if ((self.numberOfAwakes > kBVMaximumNumberOfMessages) && timeInBackground < 300) {

                PNLog(PNLogGeneralLevel, self, @"{WARN} Exceeded limit on count of data packets received in 300 "
                      "seconds.");

                shouldSwitchToGPSSupportMode = YES;
            }
            // Looks like application run in background for very long period of time.
            else if (timeInBackground >= 300) {

                [self resetDataPacketsStatistic];
                self.applicationSuspensionDate = [NSDate date];
            }

            if (shouldSwitchToGPSSupportMode) {

                PNLog(PNLogGeneralLevel, self, @"{INFO} Switching to GPS background support mode for %f seconds.",
                      kBVMaximumGPSSupportedBackgroundActivity);

                [self resetDataPacketsStatistic];
                [self switchToGPSSupportedBackgroundMode:YES];
            }
            else {

                self.lastDataAcceptanceDate = [NSDate date];
            }
        }
        else {

            [self resetDataPacketsStatistic];
            [self stopActivityTimer];
        }
    }
    // Looks like client already active in background execution context.
    else if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground && [self.activityTimer isValid]) {

        if (self.isVoIPBackgroundMode) {

            if (self.lastDataAcceptanceDate) {

                NSDate *currentDate = [NSDate date];
                if ([currentDate timeIntervalSinceDate:self.lastDataAcceptanceDate] < kBVMinimumTimeDifferenceBetweenMessages) {

                    self.numberOfUnexpectedMessages++;
                }
                else {

                    self.numberOfUnexpectedMessages = 0;
                }

                self.lastDataAcceptanceDate = currentDate;
            }
            else {

                self.lastDataAcceptanceDate = [NSDate date];
            }

            if (self.numberOfUnexpectedMessages >= kBVMaximumNumberOfMessagesOutOfSchedule) {

                PNLog(PNLogGeneralLevel, self, @"{WARN} Too many messages out of expected time frames.");

                PNLog(PNLogGeneralLevel, self, @"{INFO} Switching to GPS background support mode for %f seconds.",
                      kBVMaximumGPSSupportedBackgroundActivity);

                [self resetDataPacketsStatistic];
                [self switchToGPSSupportedBackgroundMode:YES];
            }
        }
        else {

            [self resetDataPacketsStatistic];
            [self stopActivityTimer];
        }
    }
    else {

        [self resetDataPacketsStatistic];
        [self stopActivityTimer];
    }
}

- (void)launchActivityTimer {

    if (self.activityTimer == nil || ![self.activityTimer isValid]) {

        // Create and launch timeout timer.
        self.activityTimer = [NSTimer scheduledTimerWithTimeInterval:kBVMinimumTimeDifferenceBetweenMessages target:self
                                                            selector:@selector(handleVoIPActivityTimeout:)
                                                            userInfo:nil repeats:NO];
    }
}

- (void)stopActivityTimer {

    if ([self.activityTimer isValid]) {

        [self.activityTimer invalidate];
    }
    self.activityTimer = nil;
}

- (void)switchToGPSSupportedBackgroundMode:(BOOL)shouldLaunchTimeoutTimer {

    [self resetDataPacketsStatistic];

    // GPS background support mode can be used only when application is in background execution context.
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {

        PNLog(PNLogGeneralLevel, self, @"{INFO} Launching GPS location monitoring to support further execution in "
              "background.");
        
        // Launch location manager which will allow our application to run in background till the moment when it will
        // be stopped.
        [self.locationManager startUpdatingLocation];

        // Unregister from awakening on specified intervals to maintain connection to the origin.
        [[UIApplication sharedApplication] clearKeepAliveTimeout];
        self.VoIPBackgroundMode = NO;
        self.applicationSuspensionDate = nil;
        [self stopActivityTimer];

        // Invalidate any timeout timer so it accidentally won't switch to VoIP backgrounding mode.
        if ([self.gpsUsageTimer isValid]) {

            [self.gpsUsageTimer invalidate];
        }
        self.gpsUsageTimer = nil;

        if (shouldLaunchTimeoutTimer) {

            PNLog(PNLogGeneralLevel, self, @"{INFO} GPS background support has been launched on limited amount of time.");

            // Create and launch timeout timer.
            self.gpsUsageTimer = [NSTimer scheduledTimerWithTimeInterval:kBVMaximumGPSSupportedBackgroundActivity target:self
                                                                selector:@selector(handleGPSSupportedBackgroundModeTimeout:)
                                                                userInfo:nil repeats:NO];
        }
    }
    // Looks like application is active and we can switch back to VoIP style.
    else {

        [self switchToVoIPSupportedBackgroundMode];
    }
}

- (void)switchToVoIPSupportedBackgroundMode {

    self.VoIPBackgroundMode = NO;
    self.lastDataAcceptanceDate = nil;
    
    PNLog(PNLogGeneralLevel, self, @"{INFO} Use VoIP background execution support mode.");


    if (self.reinitializationBlock) {

        self.VoIPBackgroundMode = YES;

        // In case if client was unable to connect or connect to controlling channel we will ask system to
        // pull our application back in 10 minutes and 10 seconds.
        [[UIApplication sharedApplication] setKeepAliveTimeout:610 handler:self.reinitializationBlock];
    }
    else {

        // User didn't specified any block which can be used for stack reinitialization so we cancel our
        // request to periodically awake application.
        [[UIApplication sharedApplication] clearKeepAliveTimeout];
    }

    // Checking whether switched to VoIP background support mode while in background execution context or not.
    if (self.VoIPBackgroundMode && [UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {

        PNLog(PNLogGeneralLevel, self, @"{INFO} Store date of entering background / suspension.");

        // Storing date when app possibly has been suspended. This date will be used to calculate whether application
        // exceeded on number of message which it can receive over VoIP sockets or not.
        self.applicationSuspensionDate = [NSDate date];
    }


    // Invalidate any timeout timer so it accidentally won't switch to VoIP backgrounding mode.
    if ([self.gpsUsageTimer isValid]) {

        [self.gpsUsageTimer invalidate];
    }
    self.gpsUsageTimer = nil;

    [self.locationManager stopUpdatingLocation];
}

- (void)disableAllBackgroundSupportingModes {

    [self resetDataPacketsStatistic];
    [self switchToVoIPSupportedBackgroundMode];

    self.VoIPBackgroundMode = NO;
    self.applicationSuspensionDate = nil;
    [self stopActivityTimer];
    [[UIApplication sharedApplication] clearKeepAliveTimeout];
}

- (void)resetDataPacketsStatistic {

    self.lastDataAcceptanceDate = nil;

    // Resetting all counters as for how many messages has been received and allowance rate.
    self.numberOfUnexpectedMessages = 0;
    self.numberOfAwakes = 0;
}


#pragma mark - Handler methods

- (void)handleApplicationDidEnterBackground:(NSNotification *)notification {
    
    NSLog(@"[BVBackgroundHelper::State] Application entered background execution context");

    // In case if PubNub client didn't have enough time to connect helper will switch to GPS supported background
    // execution mode.
    if ([PubNub sharedInstance].isConnected && self.isConfigurationCompleted) {

        [self switchToVoIPSupportedBackgroundMode];
    }
    else if (![PubNub sharedInstance].isConnected || !self.isConfigurationCompleted) {

        [self switchToGPSSupportedBackgroundMode:NO];
    }
}

- (void)handleApplicationDidBecomeActive:(NSNotification *)notification {

    NSLog(@"[BVBackgroundHelper::State] Application entered foreground execution context");

    [self disableAllBackgroundSupportingModes];
}

- (void)handlePubNubClientWillConnect:(NSNotification *)notification {

    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {

        [self switchToGPSSupportedBackgroundMode:NO];
    }
}

- (void)handleGPSSupportedBackgroundModeTimeout:(NSTimer *)timer {

    if ([self.gpsUsageTimer isValid]) {

        [self.gpsUsageTimer invalidate];
    }
    self.gpsUsageTimer = nil;
    [self switchToVoIPSupportedBackgroundMode];
}

/**
 Basically when this method is called it means that application will be suspended in few seconds.
 */
- (void)handleVoIPActivityTimeout:(NSTimer *)timer {

    if ([self.activityTimer isValid]) {

        [self.activityTimer invalidate];
    }
    self.activityTimer = nil;

    // Update suspension date.
    self.applicationSuspensionDate = [NSDate date];
}

#pragma mark -


@end
