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

static NSTimeInterval const kBVBackgroundTimerExecutionInterval = 5.0f;


#pragma mark - Private interface declaration

@interface BVBackgroundHelper () <CLLocationManagerDelegate>


#pragma mark - Properties

/**
 Stores reference on configured location manager which will allow application work while it in background.
 */
@property (nonatomic, strong) CLLocationManager *locationManager;

/**
 Mode which should be used to try keep application run in background persistently.
 */
@property (nonatomic, assign) BVBackgroundSupportMode backgroundSupportMode;


#pragma mark - Class methods

+ (BVBackgroundHelper *)sharedInstance;


#pragma mark - Instance methods

/**
 Terinate perviously activated helper mode.
 */
- (void)stop;

/**
 Launch code which will make sure that application is busy and system won't suspend it.
 */
- (void)launch;


#pragma mark - Handler methods

- (void)handleApplicationDidEnterBackground:(NSNotification *)notification;
- (void)handleApplicationDidBecomeActive:(NSNotification *)notification;

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

+ (void)launchForMode:(BVBackgroundSupportMode)backgroundSupportMode {
    
    [self sharedInstance].backgroundSupportMode = backgroundSupportMode;
}

#pragma mark - Instance methods

- (id)init {
    
    // Check whether initialization has been successful or not.
    if ((self = [super init])) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    
    
    return self;
}

- (void)stop {
    
    switch (self.backgroundSupportMode) {
            
        case BVBackgroundSupportGPSMode:
            
            NSLog(@"[BVBackgroundHelper::Stop] VoIP type background support mode.");
            
            break;
        case BVBackgroundSupportVoIPMode:
            
            NSLog(@"[BVBackgroundHelper::Stop] GPS type background support mode.");
            
            self.locationManager = nil;
            
            break;
            
        default:
            break;
    }
}

- (void)launch {
    
    NSLog(@"[BVBackgroundHelper::Task] Launch ");
    
    switch (self.backgroundSupportMode) {
            
        case BVBackgroundSupportGPSMode:
            
            NSLog(@"[BVBackgroundHelper::Launch] GPS type background support mode.");
            
            self.locationManager = [CLLocationManager new];
            
            if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
                
                [self.locationManager startUpdatingLocation];
            }
            
            break;
        case BVBackgroundSupportVoIPMode:
            
            NSLog(@"[BVBackgroundHelper::Launch] VoIP type background support mode.");
            
            break;
            
        default:
            break;
    }
}

- (void)setBackgroundSupportMode:(BVBackgroundSupportMode)backgroundSupportMode {
    
    BOOL isModeChanged = _backgroundSupportMode != backgroundSupportMode;
    _backgroundSupportMode = backgroundSupportMode;
    
    if (isModeChanged) {
        
        [self stop];
        [self launch];
    }
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


#pragma mark - Handler methods

- (void)handleApplicationDidEnterBackground:(NSNotification *)notification {
    
    NSLog(@"[BVBackgroundHelper::State] Application entered background execution context");
    
    switch (self.backgroundSupportMode) {
            
        case BVBackgroundSupportGPSMode:
                
            [self.locationManager startUpdatingLocation];
            
            break;
        case BVBackgroundSupportVoIPMode:
            
            break;
            
        default:
            break;
    }
}

- (void)handleApplicationDidBecomeActive:(NSNotification *)notification {
    
    NSLog(@"[BVBackgroundHelper::State] Application entered foreground execution context");
    
    switch (self.backgroundSupportMode) {
            
        case BVBackgroundSupportGPSMode:
            
            [self.locationManager stopUpdatingLocation];
            
            break;
        case BVBackgroundSupportVoIPMode:
            
            break;
            
        default:
            break;
    }
}

#pragma mark -


@end
