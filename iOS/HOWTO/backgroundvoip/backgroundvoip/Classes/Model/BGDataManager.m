//
//  BGDataManager.m
//  Background Enabled Sample Application
//
//  Created by Sergey Mamontov on 5/18/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import "BGDataManager.h"
#import "PNBackgroundHelper.h"


#pragma mark Constants

NSString * const kBGMessageListChangeNotification = @"BGMessageListChangeNotification";


#pragma mark - Structures

struct BGMessageKeysStruct {
    
    /**
     This key stores message sinding date (is part of message payload).
     */
    __unsafe_unretained NSString *timestamp;
    
    /**
     This key stores message data (is part of message payload).
     */
    __unsafe_unretained NSString *message;
};

struct BGMessageKeysStruct BGMessageKeys = {
    
    .timestamp = @"timestamp",
    .message = @"data"
};


#pragma mark - Static

static NSString * const kBGClientPrivateChannelName = @"iOS-1";
static NSString * const kBGClientPublicChannelName = @"public";
static NSString * const kBGClientIdentifier = @"IOS-user9";
static NSString * const kBGClientAuthorization = @"iOS-authToken";


#pragma mark - Private interface declaration

@interface BGDataManager ()


#pragma mark - Properties

@property (nonatomic, strong) NSMutableArray *messages;


#pragma mark - Instance methods

/**
 Complete data manager preparation.
 
 @param completionHandler
 Block called when data manager completed it's initialization and ready to use.
 */
- (void)prepareWithCompletionHandler:(void(^)(void))completionHandler;

- (void)connectToPubNubService;


#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation BGDataManager


#pragma mark - Class methods

+ (instancetype)sharedInstance {
    
    static BGDataManager *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedInstance = [self new];
    });
    
    
    return _sharedInstance;
}

+ (void)prepareWithCompletionHandler:(void(^)(void))completionHandler {
    
    [[self sharedInstance] prepareWithCompletionHandler:completionHandler];
}


#pragma mark - Instance methods

- (void)prepareWithCompletionHandler:(void(^)(void))completionHandler {
    
    self.messages = [NSMutableArray new];
    
    // Setup with PAM keys, UUID, channel, and authToken
    // In production, these values should be defined through a formal key/credentials exchange
    [PubNub setConfiguration:[PNConfiguration configurationWithPublishKey:@"pam" subscribeKey:@"pam"
                                                                secretKey:nil authorizationKey:kBGClientAuthorization]];
    [PubNub setClientIdentifier:kBGClientIdentifier];
    
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    [PNBackgroundHelper prepareWithCompleteHandler:^(void (^completionBlock)(void)) {

        // Pull last 3 messages
        [PubNub requestHistoryForChannel:[PNChannel channelWithName:kBGClientPublicChannelName] from:nil limit:3
                     withCompletionBlock:^(NSArray *messages, PNChannel *channel, PNDate *startDate, PNDate *endDate,
                             PNError *historyRequestError) {

                         if (!historyRequestError) {

                             NSMutableArray *messagesToAdd = [NSMutableArray arrayWithCapacity:[messages count]];
                             for (PNMessage *message in messages) {

                                 id messageData = message.message;

                                 if ([messageData isKindOfClass:[NSDictionary class]]) {

                                     [messagesToAdd insertObject:[NSString stringWithFormat:@"%@ <%@>: %@",
                                                                                            [(NSDictionary *) messageData valueForKey:BGMessageKeys.timestamp],
                                                                                            channel.name,
                                                                                            [(NSDictionary *) messageData valueForKey:BGMessageKeys.message]]
                                                         atIndex:0];
                                 }
                             }
                             if ([messagesToAdd count]) {

                                 if (![self messagesCount]) {

                                     [self.messages addObjectsFromArray:messagesToAdd];
                                 }
                                 else {

                                     [self.messages insertObjects:messagesToAdd atIndexes:[NSMutableIndexSet indexSetWithIndex:0]];
                                 }

                                 [[NSNotificationCenter defaultCenter] postNotificationName:kBGMessageListChangeNotification
                                                                                     object:self userInfo:(id) messagesToAdd];
                             }

                         }


                         [PubNub subscribeOnChannels:[PNChannel channelsWithNames:@[kBGClientPrivateChannelName, kBGClientPublicChannelName]]
                         withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subsriptionError) {

                             if (state != PNSubscriptionProcessNotSubscribedState) {

                                 PNLog(PNLogGeneralLevel, weakSelf, @"{INFO} User's configuration code execution completed.");

                                 // Finalization block is required to change background support mode.
                                 completionBlock();

                                 if (completionHandler) {

                                     completionHandler();
                                 }
                             }
                             else if (subsriptionError) {

                                 PNLog(PNLogGeneralLevel, weakSelf, @"{ERROR} User's configuration failed with error: %@.",
                                         subsriptionError.localizedFailureReason);

                                 if (completionHandler) {

                                     completionHandler();
                                 }
                             }
                         }];
                     }];
    }
                          andReinitializationBlock:^{

                              [PubNub disconnect];
                              [weakSelf prepareWithCompletionHandler:[completionHandler copy]];
                          }];
    
    
    [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self
                                                         withBlock:^(PNMessage *message) {
                                                             
         id messageData = message.message;
         if ([messageData isKindOfClass:[NSDictionary class]]) {
             
             NSString *messageString = [NSString stringWithFormat:@"%@ <%@>: %@",
                                        [(NSDictionary *)messageData valueForKey:BGMessageKeys.timestamp],
                                        message.channel.name,
                                        [(NSDictionary *)messageData valueForKey:BGMessageKeys.message]];
             
             if (![weakSelf.messages count]) {
                 
                 [weakSelf.messages addObject:messageString];
             }
             else {
                 
                 [weakSelf.messages insertObject:messageString atIndex:0];
             }
             
             [[NSNotificationCenter defaultCenter] postNotificationName:kBGMessageListChangeNotification
                                                                 object:self userInfo:(id)@[messageString]];
             
         }
     }];
    
    
    [self connectToPubNubService];
}

- (void)connectToPubNubService {
    
    [PNBackgroundHelper connectWithSuccessBlock:^(NSString *origin) {

        PNLog(PNLogGeneralLevel, self, @"{INFO} Connected to %@", origin);

    }
                                     errorBlock:^(PNError *connectionError) {

                                         if (connectionError) {

                                             PNLog(PNLogGeneralLevel, self, @"{ERROR} Failed to connect because of error: %@", connectionError);
                                         }
                                     }];
}

- (NSUInteger)messagesCount {
    
    return [self.messages count];
}

- (NSString *)messageAtIndex:(NSUInteger)messageIdx {
    
    NSString *message = nil;
    if (messageIdx < [self messagesCount]) {
        
        message = [self.messages objectAtIndex:messageIdx];
    }
    
    
    return message;
}

#pragma mark -


@end
