//
//  PNBackgroundHelper.h
//
//  Created by Sergey Mamontov on 4/11/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Public interface declaration

@interface PNBackgroundHelper : NSObject


#pragma mark - Class methods

/**
 Perform helper initialization and prepare it to handle all application transitions and \b PubNub client state change.

 @param completionHandler
 Block which is used by helper to notify user about initial configuration completed. Block pass reference on block
 which should be called by user when he will complete his part of PubNub and application stack configuration.

 @param reinitializationBlock
 Block which will be called from background helper in case if application stack reinitialization will be required.
 */
+ (void)prepareWithCompleteHandler:(void(^)(void(^)(void)))completionHandler
          andReinitializationBlock:(void(^)(void))reinitializationBlock;

/**
 Forward connection request to the \b PubNub client for further processing.
 */
+ (void)connectWithSuccessBlock:(void(^)(NSString *))success errorBlock:(void(^)(PNError *))failure;

#pragma mark -


@end
