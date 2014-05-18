//
//  BVDataManager.h
//  backgroundvoip
//
//  Created by Sergey Mamontov on 5/18/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import <Foundation/Foundation.h>



#pragma mark Constants

/**
 Notification will be sent every time when cached list of messages will be changed.
 
 \b userInfo instead of \b NSDictionary will contain \b NSArray with messages in required order.
 */
extern NSString * const kBVMessageListChangeNotification;


#pragma mark - Public interface declaration

@interface BVDataManager : NSObject


#pragma mark - Class methods

+ (instancetype)sharedInstance;

/**
 Complete shared data manager preparation.
 
 @param completionHandler
 Block called when data manager completed it's initialization and ready to use.
 */
+ (void)prepareWithCompletionHandler:(void(^)(void))completionHandler;


#pragma mark - Instance methods

- (NSUInteger)messagesCount;
- (NSString *)messageAtIndex:(NSUInteger)messageIdx;

#pragma mark -


@end
