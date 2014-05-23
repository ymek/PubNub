//
//  GSStateManager.h
//  gpssample
//
//  Created by Sergey Mamontov on 5/22/14.
//  Copyright (c) 2014 PubNub. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Static

extern NSString * const kVSStateManagerWillConnectNotification;
extern NSString * const kVSStateManagerDidConnectNotification;
extern NSString * const kVSStateManagerConnectionDidFailNotification;


#pragma mark - Public interface declaration

@interface GSStateManager : NSObject


#pragma mark - Class methods

+ (GSStateManager *)sharedInstance;

/**
 In case if application is in foreground, connection attempt will be performed.
 */
+ (void)connect;

/**
 Remove all messages from storage.
 */
+ (void)clearMessagesLog;

+ (BOOL)isConnecting;

#pragma mark -


@end
