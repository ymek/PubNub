//
//  BVBackgroundHelper.m
//  backgroundvoip
//
//  Created by Sergey Mamontov on 4/11/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import "BVBackgroundHelper.h"


#pragma mark Static

static NSTimeInterval const kBVBackgroundTimerExecutionInterval = 5.0f;


#pragma mark - Private interface declaration

@interface BVBackgroundHelper ()


#pragma mark - Properties

/**
 Stores reference on block which will handle background task execution completion to reissue request for extension once
 more.
 */
@property (nonatomic, copy) void(^backgroundHandlerBlock)(void);

/**
 Stores reference on identifier for recently launched background execution task.
 */
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskIdentifier;

/**
 Stores whether previous background execution task expired or not.
 */
@property (nonatomic, assign, getter = isTaskExpired) BOOL taskExpired;

@property (nonatomic, assign) NSInteger backgroundExecutionDuration;


#pragma mark - Class methods

+ (BVBackgroundHelper *)sharedInstance;

/**
 Extend time which can be used by application for tasks execution while in background execution context.
 */
+ (void)prolongueBackgroundExecutionTime;


#pragma mark - Instance methods

/**
 Launch code which will make sure that application is busy and system won't suspend it.
 */
- (void)launchProlongueTask;


#pragma mark - Handler methods

- (void)handleApplicationDidEnterBackground:(NSNotification *)notification;
- (void)handleApplicationDidBecomeActive:(NSNotification *)notification;
- (void)handleTimer:(NSTimer *)timer;

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

+ (void)launch {
    
    // Trigger singleton creation.
    [self sharedInstance];
    
    NSLog(@"[BVBackgroundHelper] Helper started it's work and observation.");
    
    // Check whether application launched while in background so we can extend our background execution time right away.
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        
        [self prolongueBackgroundExecutionTime];
    }
}

+ (void)prolongueBackgroundExecutionTime {
    
    if ([self sharedInstance].backgroundTaskIdentifier == UIBackgroundTaskInvalid) {
        
        NSLog(@"[BVBackgroundHelper::Prolongue] Launch background execution period prolongue");
        
        [[self sharedInstance] launchProlongueTask];
        [self sharedInstance].backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:[self sharedInstance].backgroundHandlerBlock];
        
        [self sharedInstance].backgroundExecutionDuration = 0;
        [NSTimer scheduledTimerWithTimeInterval:kBVBackgroundTimerExecutionInterval target:[self sharedInstance]
                                       selector:@selector(handleTimer:) userInfo:nil repeats:YES];
    }
    else {
        
        NSLog(@"[BVBackgroundHelper::Prolongue] Already running background exection period prolongue code");
    }
}


#pragma mark - Instance methods

- (id)init {
    
    // Check whether initialization has been successful or not.
    if ((self = [super init])) {
        
        self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        
        __block __pn_desired_weak __typeof(self) weakSelf = self;
        self.backgroundHandlerBlock = ^{
            
            [[UIApplication sharedApplication] endBackgroundTask:weakSelf.backgroundTaskIdentifier];
            weakSelf.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
            weakSelf.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:weakSelf.backgroundHandlerBlock];
            
            NSLog(@"[BVBackgroundHelper::Prolongue] Background execution period prolongue expired");
            
            weakSelf.taskExpired = YES;
            while(weakSelf.isTaskExpired) {
                
                [NSThread sleepForTimeInterval:1];
            }
            [weakSelf launchProlongueTask];
        };
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    
    
    return self;
}

- (void)launchProlongueTask {
    
    NSLog(@"[BVBackgroundHelper::Task] Launch prolongue task");
    
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        while ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground && !weakSelf.isTaskExpired) {
            
            [NSThread sleepForTimeInterval:1];
        }
        
        weakSelf.taskExpired = NO;
    });
}

#pragma mark - Handler methods

- (void)handleApplicationDidEnterBackground:(NSNotification *)notification {
    
    NSLog(@"[BVBackgroundHelper::State] Application entered background execution context");
    
    [[self class] prolongueBackgroundExecutionTime];
}

- (void)handleApplicationDidBecomeActive:(NSNotification *)notification {
    
    NSLog(@"[BVBackgroundHelper::State] Application entered foreground execution context");
    
    if (self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
        
        NSLog(@"[BVBackgroundHelper::Prolongue] Suspend background execution period prolongue");
        
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
        self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    }
}

- (void)handleTimer:(NSTimer *)timer {
    
    _backgroundExecutionDuration += (int)timer.timeInterval;
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        
        NSLog(@"[BVBackgroundHelper::Background] In background for %ld seconds (%ld minutes)",
              (long)self.backgroundExecutionDuration, (long)(self.backgroundExecutionDuration/60));
    }
    else {
        
        self.backgroundExecutionDuration = 0;
        [timer invalidate];
    }
}

#pragma mark -


@end
