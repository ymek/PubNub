//
//  PNChaosTest.m
//  pubnub
//
//  Created by Valentin Tuller on 9/19/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import "W_ChaosTest.h"
#import "PubNub.h"
#import "PubNub+Protected.h"
#import "PNConfiguration.h"
#import "PNWriteBuffer.h"
#import "PNConstants.h"
#import "PNDataManager.h"
#import "PNConnection.h"
#import "Swizzler.h"

@interface W_ChaosTest () <PNDelegate>
{
	BOOL conectedFinish;
	NSArray *pnChannels;
	BOOL subscribeOnChannelsFinish;
	BOOL participantsListForChannelFinish;
}
@end

@implementation W_ChaosTest

//-(NSNumber *)shouldReconnectPubNubClient:(id)object {
//	return [NSNumber numberWithBool: NO];
//}

- (void)handleConnectionErrorOnNetworkFailure {
	PNLog(PNLogGeneralLevel, nil, @"handleConnectionErrorOnNetworkFailure");
//	dispatch_semaphore_signal(semaphore);
	conectedFinish = YES;
}

- (void)handleConnectionErrorOnNetworkFailureWithError:(PNError *)error {
	PNLog(PNLogGeneralLevel, nil, @"handleConnectionErrorOnNetworkFailure: %@", error);
//	dispatch_semaphore_signal(semaphore);
	conectedFinish = YES;
}


-(void)setUp {
    [super setUp];
//	semaphore = dispatch_semaphore_create(0);
//	pnChannels = [PNChannel channelsWithNames:@[@"iosdev", @"andoirddev"]];
    [PubNub setDelegate:self];

	[PubNub disconnect];
	PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"chaos.pubnub.com" publishKey:@"demo" subscribeKey:@"demo" secretKey: nil cipherKey: nil];
	//	configuration.autoReconnectClient = NO;
	[PubNub setConfiguration: configuration];

    [PubNub connectWithSuccessBlock:^(NSString *origin) {

        PNLog(PNLogGeneralLevel, nil, @"{BLOCK} PubNub client connected to: %@", origin);
    }
						 errorBlock:^(PNError *connectionError) {
							 PNLog(PNLogGeneralLevel, nil, @"connectionError %@", connectionError);
							 conectedFinish = YES;
	 }];
}
//
//- (void)test10ConnectionChaos
//{
//	[PubNub disconnect];
//	PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"chaos.pubnub.com" publishKey:@"demo" subscribeKey:@"demo" secretKey: nil cipherKey: nil];
////	configuration.autoReconnectClient = NO;
//	[PubNub setConfiguration: configuration];
//
////    semaphore = dispatch_semaphore_create(0);
//	conectedFinish = NO;
//
//    [PubNub connectWithSuccessBlock:^(NSString *origin) {
//
//        PNLog(PNLogGeneralLevel, nil, @"{BLOCK} PubNub client connected to: %@", origin);
//		conectedFinish = YES;
//		STFail(@"Client should not connect to %@", origin);
////        dispatch_semaphore_signal(semaphore);
//    }
//		 errorBlock:^(PNError *connectionError) {
//			 PNLog(PNLogGeneralLevel, nil, @"connectionError %@", connectionError);
//			 conectedFinish = YES;
////			 dispatch_semaphore_signal(semaphore);
//		STFail(@"Client should not return any error, error %@", connectionError);
//	}];
//	for( int i=0; i<10 && conectedFinish == NO; i++ )
//		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
//	STAssertFalse( conectedFinish, @"conectedFinish must be YES");
//}
- (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to subscribe because of error: %@", error);
	subscribeOnChannelsFinish = YES;
}

- (void)test20SubscribeOnChannels
{
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	subscribeOnChannelsFinish = NO;
	[PubNub subscribeOnChannels: pnChannels withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
	 {
		 subscribeOnChannelsFinish = YES;
	 }];
	for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 &&
		subscribeOnChannelsFinish == NO; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( subscribeOnChannelsFinish, @"subscribeOnChannelsFinish must be YES");
}

//nonSubscriptionRequestTimeout
- (void)pubnubClient:(PubNub *)client didFailParticipantsListDownloadForChannel:(PNChannel *)channel withError:(PNError *)error {
    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to download participants list for channel %@ because of error: %@",
          channel, error);
	participantsListForChannelFinish = YES;
}
- (void)test30ParticipantsListForChannelTimeout
{
	participantsListForChannelFinish = NO;
	PNChannel *channel = [PNChannel channelsWithNames: @[@"channel"]][0];
	[PubNub requestParticipantsListForChannel: channel
						  withCompletionBlock: ^(NSArray *udids, PNChannel *channel, PNError *error)
	 {
		 participantsListForChannelFinish = YES;
	 }];
	for( int j=0; j<[PubNub sharedInstance].configuration.nonSubscriptionRequestTimeout+1 &&
		participantsListForChannelFinish == NO; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( participantsListForChannelFinish, @"subscribeOnChannelsFinish must be YES");
}

@end
