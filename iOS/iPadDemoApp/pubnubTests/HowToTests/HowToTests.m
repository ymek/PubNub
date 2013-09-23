//
//  PNBaseRequestTest.m
//  UnitTestSample
//
//  Created by Vadim Osovets on 5/19/13.
//  Copyright (c) 2013 Micro-B. All rights reserved.
//

#import "HowToTests.h"
#import "PNBaseRequest.h"
#import "PNBaseRequest+Protected.h"

#import <OCMock/OCMock.h>

#import "PubNub.h"
#import "PubNub+Protected.h"
#import "PNConfiguration.h"
#import "PNWriteBuffer.h"
#import "PNConstants.h"
#import "PNDataManager.h"

@interface HowToTests ()

@property (nonatomic, assign) NSUInteger retryCount;

@end

@interface HowToTests () <PNDelegate>
{
	NSArray *pnChannels;
	NSArray *pnChannelsBad;
	dispatch_semaphore_t semaphoreNotification;
}

@property (nonatomic, retain) NSConditionLock *theLock;

@end


@implementation HowToTests

- (void)setUp
{
    [super setUp];
	semaphoreNotification = dispatch_semaphore_create(0);
    [PubNub setDelegate:self];
	pnChannels = [PNChannel channelsWithNames:@[@"iosdev", @"andoirddev", @"wpdev", @"ubuntudev", @"1"]];
	pnChannelsBad = [PNChannel channelsWithNames:@[@"iosdev", @"andoirddev", @"wpdev", @"", @""]];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

#pragma mark - PubNub client delegate methods

//- (void)pubnubClient:(PubNub *)client didEnablePushNotificationsOnChannels:(NSArray *)channels {
//	dispatch_semaphore_signal(semaphoreNotification);
//    PNLog(PNLogGeneralLevel, self, @"PubNub client enabled push notifications on channels: %@", channels);
//}
//
//- (void)pubnubClient:(PubNub *)client pushNotificationEnableDidFailWithError:(PNError *)error {
//	dispatch_semaphore_signal(semaphoreNotification);
//	STFail(@"connectionError %@", error);
//    PNLog(PNLogGeneralLevel, self, @"PubNub client failed push notification enable because of error: %@", error);
//}
//
//- (void)pubnubClient:(PubNub *)client didDisablePushNotificationsOnChannels:(NSArray *)channels {
//	dispatch_semaphore_signal(semaphoreNotification);
//    PNLog(PNLogGeneralLevel, self, @"PubNub client disabled push notifications on channels: %@", channels);
//}
//
//- (void)pubnubClient:(PubNub *)client pushNotificationDisableDidFailWithError:(PNError *)error {
//	dispatch_semaphore_signal(semaphoreNotification);
//	STFail(@"connectionError %@", error);
//    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to disable push notifications because of error: %@", error);
//}
//
//- (void)pubnubClient:(PubNub *)client didReceivePushNotificationEnabledChannels:(NSArray *)channels {
//	dispatch_semaphore_signal(semaphoreNotification);
//    PNLog(PNLogGeneralLevel, self, @"PubNub client received push notificatino enabled channels: %@", channels);
//}
//
//- (void)pubnubClient:(PubNub *)client pushNotificationEnabledChannelsReceiveDidFailWithError:(PNError *)error {
//	dispatch_semaphore_signal(semaphoreNotification);
//	STFail(@"connectionError %@", error);
//    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to receive list of channels because of error: %@", error);
//}
//
//- (void)pubnubClientDidRemovePushNotifications:(PubNub *)client {
//	dispatch_semaphore_signal(semaphoreNotification);
//    PNLog(PNLogGeneralLevel, self, @"PubNub client removed push notifications from all channels");
//}
//
//- (void)pubnubClient:(PubNub *)client pushNotificationsRemoveFromChannelsDidFailWithError:(PNError *)error {
//	dispatch_semaphore_signal(semaphoreNotification);
//	STFail(@"connectionError %@", error);
//    PNLog(PNLogGeneralLevel, self, @"PubNub client failed remove push notifications from channels because of error: %@", error);
//}
//
//- (void)pubnubClient:(PubNub *)client error:(PNError *)error {
//	dispatch_semaphore_signal(semaphoreNotification);
//    PNLog(PNLogGeneralLevel, self, @"PubNub client report that error occurred: %@", error);
//}
//
//- (void)pubnubClient:(PubNub *)client willConnectToOrigin:(NSString *)origin {
//	dispatch_semaphore_signal(semaphoreNotification);
//}
//
//- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {
//	dispatch_semaphore_signal(semaphoreNotification);
//}
//
//- (void)pubnubClient:(PubNub *)client connectionDidFailWithError:(PNError *)error {
//	dispatch_semaphore_signal(semaphoreNotification);
//	STFail(@"connectionError %@", error);
//    PNLog(PNLogGeneralLevel, self, @"#1 PubNub client was unable to connect because of error: %@", error);
//}
//
//- (void)pubnubClient:(PubNub *)client willDisconnectWithError:(PNError *)error {
//	dispatch_semaphore_signal(semaphoreNotification);
//    PNLog(PNLogGeneralLevel, self, @"PubNub clinet will close connection because of error: %@", error);
//}
//
//- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin withError:(PNError *)error {
//	dispatch_semaphore_signal(semaphoreNotification);
//    PNLog(PNLogGeneralLevel, self, @"PubNub client closed connection because of error: %@", error);
//}
//
//- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin {
//	dispatch_semaphore_signal(semaphoreNotification);
//    PNLog(PNLogGeneralLevel, self, @"PubNub client disconnected from PubNub origin at: %@", origin);
//}
//
//- (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels {
//	dispatch_semaphore_signal(semaphoreNotification);
//    PNLog(PNLogGeneralLevel, self, @"PubNub client successfully subscribed on channels: %@", channels);
//}
//
//- (void)pubnubClient:(PubNub *)client willRestoreSubscriptionOnChannels:(NSArray *)channels {
//	dispatch_semaphore_signal(semaphoreNotification);
//    PNLog(PNLogGeneralLevel, self, @"PubNub client resuming subscription on: %@", channels);
//}
//
//- (void)pubnubClient:(PubNub *)client didRestoreSubscriptionOnChannels:(NSArray *)channels {
//	dispatch_semaphore_signal(semaphoreNotification);
//    PNLog(PNLogGeneralLevel, self, @"PubNub client successfully restored subscription on channels: %@", channels);
//}
//
//- (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
//	dispatch_semaphore_signal(semaphoreNotification);
//	STFail(@"connectionError %@", error);
//    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to subscribe because of error: %@", error);
//}
//
//- (void)pubnubClient:(PubNub *)client didUnsubscribeOnChannels:(NSArray *)channels {
//	dispatch_semaphore_signal(semaphoreNotification);
//    PNLog(PNLogGeneralLevel, self, @"PubNub client successfully unsubscribed from channels: %@", channels);
//}
//
//- (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error {
//	dispatch_semaphore_signal(semaphoreNotification);
//	STFail(@"connectionError %@", error);
//    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to unsubscribe because of error: %@", error);
//}
//
//- (void)pubnubClient:(PubNub *)client didEnablePresenceObservationOnChannels:(NSArray *)channels {
//	dispatch_semaphore_signal(semaphoreNotification);
//    PNLog(PNLogGeneralLevel, self, @"PubNub client successfully enabled presence observation on channels: %@", channels);
//}
//
//- (void)pubnubClient:(PubNub *)client presenceObservationEnablingDidFailWithError:(PNError *)error {
//	dispatch_semaphore_signal(semaphoreNotification);
//	STFail(@"connectionError %@", error);
//    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to enable presence observation because of error: %@", error);
//}
//
//- (void)pubnubClient:(PubNub *)client didDisablePresenceObservationOnChannels:(NSArray *)channels {
//	dispatch_semaphore_signal(semaphoreNotification);
//    PNLog(PNLogGeneralLevel, self, @"PubNub client successfully disabled presence observation on channels: %@", channels);
//}
//
//- (void)pubnubClient:(PubNub *)client presenceObservationDisablingDidFailWithError:(PNError *)error {
//	dispatch_semaphore_signal(semaphoreNotification);
//	STFail(@"connectionError %@", error);
//    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to disable presence observation because of error: %@", error);
//}
//
//- (void)pubnubClient:(PubNub *)client didReceiveTimeToken:(NSNumber *)timeToken {
//	dispatch_semaphore_signal(semaphoreNotification);
//    PNLog(PNLogGeneralLevel, self, @"PubNub client recieved time token: %@", timeToken);
//}
//
//- (void)pubnubClient:(PubNub *)client timeTokenReceiveDidFailWithError:(PNError *)error {
//	dispatch_semaphore_signal(semaphoreNotification);
//	STFail(@"connectionError %@", error);
//    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to receive time token because of error: %@", error);
//}
//
//- (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
//	dispatch_semaphore_signal(semaphoreNotification);
//    PNLog(PNLogGeneralLevel, self, @"PubNub client is about to send message: %@", message);
//}
//
//- (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
//	dispatch_semaphore_signal(semaphoreNotification);
//	STFail(@"connectionError %@", error);
//    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to send message '%@' because of error: %@", message, error);
//}
//
//- (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
//	dispatch_semaphore_signal(semaphoreNotification);
//    PNLog(PNLogGeneralLevel, self, @"PubNub client sent message: %@", message);
//}
//
//- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {
//	dispatch_semaphore_signal(semaphoreNotification);
//    PNLog(PNLogGeneralLevel, self, @"PubNub client received message: %@", message);
//}
//
//- (void)pubnubClient:(PubNub *)client didReceivePresenceEvent:(PNPresenceEvent *)event {
//	dispatch_semaphore_signal(semaphoreNotification);
//    PNLog(PNLogGeneralLevel, self, @"PubNub client received presence event: %@", event);
//}
//
//- (void)pubnubClient:(PubNub *)client
//didReceiveMessageHistory:(NSArray *)messages
//              forChannel:(PNChannel *)channel
//            startingFrom:(PNDate *)startDate
//                      to:(PNDate *)endDate
//{
//	dispatch_semaphore_signal(semaphoreNotification);
//    PNLog(PNLogGeneralLevel, self, @"PubNub client received history for %@ starting from %@ to %@: %@",
//          channel, startDate, endDate, messages);
//}
//
//- (void)pubnubClient:(PubNub *)client didFailHistoryDownloadForChannel:(PNChannel *)channel withError:(PNError *)error
//{
//	dispatch_semaphore_signal(semaphoreNotification);
//	STFail(@"connectionError %@", error);
//    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to download history for %@ because of error: %@",
//          channel, error);
//}
//
//- (void)pubnubClient:(PubNub *)client
//didReceiveParticipantsList:(NSArray *)participantsList
//                forChannel:(PNChannel *)channel {
//	dispatch_semaphore_signal(semaphoreNotification);
//    PNLog(PNLogGeneralLevel, self, @"PubNub client received participants list for channel %@: %@",
//          participantsList, channel);
//}
//
//- (void)pubnubClient:(PubNub *)client
//didFailParticipantsListDownloadForChannel:(PNChannel *)channel
//                                withError:(PNError *)error {
//	dispatch_semaphore_signal(semaphoreNotification);
//	STFail(@"connectionError %@", error);
//    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to download participants list for channel %@ because of error: %@",
//          channel, error);
//}

//- (NSNumber *)shouldResubscribeOnConnectionRestore {
//
//    NSNumber *shouldResubscribeOnConnectionRestore = @(YES);
//
//    PNLog(PNLogGeneralLevel, self, @"PubNub client should restore subscription? %@", [shouldResubscribeOnConnectionRestore boolValue] ? @"YES" : @"NO");
//
//
//    return shouldResubscribeOnConnectionRestore;
//}
//
//- (NSNumber *)shouldRestoreSubscriptionFromLastTimeToken {
//
//    NSNumber *shouldRestoreSubscriptionFromLastTimeToken = @(NO);
//    NSString *lastTimeToken = @"0";
//
//    if ([[PubNub subscribedChannels] count] > 0) {
//
//        lastTimeToken = [[[PubNub subscribedChannels] lastObject] updateTimeToken];
//    }
//
//    PNLog(PNLogGeneralLevel, self, @"PubNub client should restore subscription from last time token? %@ (last time token: %@)",
//		  [shouldRestoreSubscriptionFromLastTimeToken boolValue]?@"YES":@"NO", lastTimeToken);
//
//
//    return shouldRestoreSubscriptionFromLastTimeToken;
//}

#pragma mark - States tests

- (void)test05AddClientConnectionStateObserver
{
    [[PNObservationCenter defaultCenter] addClientConnectionStateObserver:self
                                                        withCallbackBlock:^(NSString *origin,
                                                                            BOOL connected,
                                                                            PNError *error)
	{
		STAssertNil( error, @"error %@", error);
		if (!connected && error) {
				PNLog(PNLogGeneralLevel, self, @"#2 PubNub client was unable to connect because of error: %@",
					  [error localizedDescription],
					  [error localizedFailureReason]);
			}
		}];
}

- (void)test06ClientChannelSubscriptionStateObserver
{
    // Subscribe application delegate on subscription updates
    // (events when client subscribe on some channel)
    __pn_desired_weak __typeof__(self) weakSelf = self;
    [[PNObservationCenter defaultCenter] addClientChannelSubscriptionStateObserver:weakSelf
                                                                 withCallbackBlock:^(PNSubscriptionProcessState state,
                                                                                     NSArray *channels,
                                                                                     PNError *subscriptionError)
	{
		STAssertNil( subscriptionError, @"subscriptionError %@", subscriptionError);
		STAssertFalse( state == PNSubscriptionProcessNotSubscribedState, @"state == PNSubscriptionProcessNotSubscribedState, %@", subscriptionError );
	 }];
}

//- (void)test07addPresenceEventObserver
//{
//    __pn_desired_weak __typeof__(self) weakSelf = self;
//    [[PNObservationCenter defaultCenter] addPresenceEventObserver:weakSelf
//                                                        withBlock:^(PNPresenceEvent *presenceEvent) {
//
//                                                            PNLog(PNLogGeneralLevel, weakSelf, @"{BLOCK-P} PubNubc client received new event: %@",
//																  presenceEvent);
//                                                        }];
//}
- (void)test08AddPresenceEventObserver
{
    // Subscribe on presence event arrival events with block
	__pn_desired_weak __typeof__(self) weakSelf = self;
    [[PNObservationCenter defaultCenter] addPresenceEventObserver:weakSelf
                                                        withBlock:^(PNPresenceEvent *presenceEvent) {

                                                            PNLog(PNLogGeneralLevel, weakSelf, @"{BLOCK-P} PubNubc client received new event: %@",
																  presenceEvent);
                                                        }];
}


- (void)test10Connect
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
//	PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"chaos.pubnub.com" publishKey:@"demo" subscribeKey:@"demo" secretKey: nil cipherKey: nil];
//	//	configuration.autoReconnectClient = NO;
//	[PubNub setConfiguration: configuration];

    [PubNub connectWithSuccessBlock:^(NSString *origin) {

        PNLog(PNLogGeneralLevel, nil, @"{BLOCK} PubNub client connected to: %@", origin);
        dispatch_semaphore_signal(semaphore);
    }
                         errorBlock:^(PNError *connectionError) {
							 PNLog(PNLogGeneralLevel, nil, @"connectionError %@", connectionError);
							 dispatch_semaphore_signal(semaphore);
							 STFail(@"connectionError %@", connectionError);
                         }];
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}

//file://localhost/Users/tuller/work/pubnub/iOS/3.4/pubnubTests/RequestTests/PNBaseRequestTest.m: error: test20SubscribeOnChannels (PNBaseRequestTest) failed: "((subscriptionError) == nil)" should be true. subscriptionError Domain=com.pubnub.pubnub; Code=106; Description="Subscription failed by timeout"; Reason="Looks like there is some packets lost because of which request failed by timeout"; Fix suggestion="Try send request again later."; Associated object=(

- (void)test20SubscribeOnChannels
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	[PubNub subscribeOnChannels: pnChannels
	withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
	{
		dispatch_semaphore_signal(semaphore);
		STAssertNil( subscriptionError, @"subscriptionError %@", subscriptionError);
		STAssertEquals( pnChannels.count, channels.count, @"pnChannels.count %d, channels.count %d", pnChannels.count, channels.count);
//		connectedChannels = channels;
		switch(state) {
			case PNSubscriptionProcessNotSubscribedState:
				// Check whether 'subscriptionError' instance is nil or not (if not, handle error)
				break;
			case PNSubscriptionProcessSubscribedState:
				// Do something after subscription completed
				break;
			case PNSubscriptionProcessWillRestoreState:
				// Library is about to restore subscription on channels after connection went down and restored
				break;
			case PNSubscriptionProcessRestoredState:
				// Handle event that client completed resubscription
				break;
		}
	}];
    // Run loop
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
}

//- (void)test21SubscribeOnChannelsBad
//{
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//	[PubNub subscribeOnChannels: pnChannelsBad
//	withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
//	 {
//		 dispatch_semaphore_signal(semaphore);
//		 STAssertNotNil( subscriptionError, @"subscriptionError %@", subscriptionError);
//	 }];
//    // Run loop
//    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
//        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
//                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
//}

-(void)test30RequestParticipantsListForChannel
{
	for( int i=0; i<pnChannels.count; i++ )
	{
		dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//		PNLog(PNLogGeneralLevel, nil, @"pnChannels[i] %@", pnChannels[i]);
		[PubNub requestParticipantsListForChannel:pnChannels[i]
							  withCompletionBlock:^(NSArray *udids, PNChannel *channel, PNError *error)
		{
			if( error != nil )
				PNLog(PNLogGeneralLevel, nil, @"error %@", error);
			STAssertNil( error, @"error %@", error);
			dispatch_semaphore_signal(semaphore);
			NSLog(@"udids %@", udids);
		  }];
		while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
									 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
	}
}

-(void)test35RequestServerTimeTokenWithCompletionBlock
{
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	// Unsubscribe from set of channels and notify everyone that we are left
	[PubNub requestServerTimeTokenWithCompletionBlock:^(NSNumber *timeToken, PNError *error)
	{
		dispatch_semaphore_signal(semaphore);
		STAssertNil( error, @"error %@", error);
	}];
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
}

-(void)requestHistoryForChannel:(PNChannel *)channel
                            from:(PNDate *)startDate
                              to:(PNDate *)endDate
                           limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory
{
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	[PubNub requestHistoryForChannel:channel
								from:startDate
								  to:endDate
							   limit:limit
					  reverseHistory:NO
				 withCompletionBlock:^(NSArray *messages,
									   PNChannel *channel,
									   PNDate *startDate,
									   PNDate *endDate,
									   PNError *error)
	 {
		 dispatch_semaphore_signal(semaphore);
		 STAssertNil( error, @"error %@", error);
	 }];
}

-(void)test40RequestHistoryForChannel
{
	for( int i=0; i<pnChannels.count; i++ )
	{
		PNDate *startDate = [PNDate dateWithDate:[NSDate dateWithTimeIntervalSinceNow:(-3600.0f)]];
		PNDate *endDate = [PNDate dateWithDate:[NSDate date]];
		int limit = 34;
		[self requestHistoryForChannel: pnChannels[i] from: startDate to: endDate limit: limit reverseHistory: YES];
		[self requestHistoryForChannel: pnChannels[i] from: startDate to: endDate limit: limit reverseHistory: NO];
		[self requestHistoryForChannel: pnChannels[i] from: startDate to: endDate limit: 0 reverseHistory: YES];
		[self requestHistoryForChannel: pnChannels[i] from: startDate to: endDate limit: 0 reverseHistory: NO];
		[self requestHistoryForChannel: pnChannels[i] from: nil to: endDate limit: 0 reverseHistory: YES];
		[self requestHistoryForChannel: pnChannels[i] from: startDate to: nil limit: 0 reverseHistory: NO];
	}
}

-(void)test50SendMessage
{
	for( int i=0; i<pnChannels.count; i++ )
	{
		dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

		/*PNMessage *helloMessage = */[PubNub sendMessage:@"Hello PubNub"
												toChannel:pnChannels[i]
									  withCompletionBlock:^(PNMessageState messageSendingState, id data)
									   {
										   dispatch_semaphore_signal(semaphore);
										   STAssertFalse(messageSendingState==PNMessageSendingError, @"messageSendingState==PNMessageSendingError %@", data);
										   switch (messageSendingState)
										   {
											   case PNMessageSending:
												   // Handle message sending event (it means that message processing started and
												   // still in progress)
												   break;
											   case PNMessageSent:
												   // Handle message sent event
												   break;
											   case PNMessageSendingError:
												   // Retry message sending (but in real world should check error and hanle it)
												   //											  [PubNub sendMessage:helloMessage];
												   break;
										   }
									   }];

		while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
									 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
	}
}

//-(void)test51SendMessageBad
//{
//	for( int i=0; i<pnChannels.count; i++ )
//	{
//		dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//
//		/*PNMessage *helloMessage = */[PubNub sendMessage:@[@"1", @"2", [NSNumber numberWithDouble:123.0], pnChannels]
//												toChannel:pnChannels[i]
//									  withCompletionBlock:^(PNMessageState messageSendingState, id data)
//									   {
//										   dispatch_semaphore_signal(semaphore);
//										   STAssertTrue(messageSendingState==PNMessageSendingError, @"messageSendingState==PNMessageSendingError %@", data);
//									   }];
//
//		while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
//			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
//									 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
//	}
//}


-(void)test900UnsubscribeFromChannels
{
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	// Unsubscribe from set of channels and notify everyone that we are left
	[PubNub unsubscribeFromChannels: pnChannels
				  withPresenceEvent:YES
		 andCompletionHandlingBlock:^(NSArray *channels, PNError *unsubscribeError)
	 {
		 // Check whether "unsubscribeError" is nil or not (if not, than handle error)
		 dispatch_semaphore_signal(semaphore);
		 STAssertNil( unsubscribeError, @"unsubscribeError %@", unsubscribeError);
		 STAssertEquals( pnChannels.count, channels.count, @"pnChannels.count %d, channels.count %d", pnChannels.count, channels.count);
	 }];
    // Run loop
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
}
//-(void)test910UnsubscribeFromChannelsBad
//{
//	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//	// Unsubscribe from set of channels and notify everyone that we are left
//	[PubNub unsubscribeFromChannels: pnChannelsBad
//				  withPresenceEvent:YES
//		 andCompletionHandlingBlock:^(NSArray *channels, PNError *unsubscribeError)
//	 {
//		 // Check whether "unsubscribeError" is nil or not (if not, than handle error)
//		 dispatch_semaphore_signal(semaphore);
//		 STAssertNotNil( unsubscribeError, @"unsubscribeError %@", unsubscribeError);
//	 }];
//    // Run loop
//    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
//        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
//                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
//}

@end
