//
//  PNAccessRightsCollectionTest.m
//  pubnub
//
//  Created by Valentin Tuller on 1/22/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PNAccessRightsCollection.h"
#import "PNAccessRightsCollection+Protected.h"
#import "PNAccessRightsInformation+Protected.h"
#import "PNAccessRightsInformation.h"
#import "PNChannel.h"
#import "PNStructures.h"

@interface PNAccessRightsCollection (test)

- (void)storeClientAccessRightsInformation:(PNAccessRightsInformation *)information forChannel:(PNChannel *)channel;

@end

@interface PNAccessRightsCollectionTest : SenTestCase

@end

@implementation PNAccessRightsCollectionTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
	[NSThread sleepForTimeInterval:1.0];
}

- (void)testAccessRightsCollectionForApplication {
	PNAccessRightsCollection *collection = [PNAccessRightsCollection accessRightsCollectionForApplication: @"key" andAccessRightsLevel: PNApplicationAccessRightsLevel];
	STAssertNotNil( collection, @"");
	STAssertEqualObjects( collection.applicationKey, @"key", @"");
	STAssertTrue( [collection.channelsAccessRightsInformation isKindOfClass: [NSMutableDictionary class]] == YES, @"");
	STAssertTrue( [collection.clientsAccessRightsInformation isKindOfClass: [NSMutableDictionary class]] == YES, @"");
}

-(void)testAccessRightsInformationForApplication {
	PNAccessRightsCollection *collection = [PNAccessRightsCollection accessRightsCollectionForApplication: @"key" andAccessRightsLevel: PNApplicationAccessRightsLevel];
	collection.applicationAccessRightsInformation = [[PNAccessRightsInformation alloc] init];
	PNAccessRightsInformation *info = [collection accessRightsInformationForApplication];
	STAssertTrue( info == collection.applicationAccessRightsInformation, @"");

	collection.applicationAccessRightsInformation = nil;
	info = [collection accessRightsInformationForApplication];
	STAssertTrue( info.level == PNApplicationAccessRightsLevel, @"");
	STAssertTrue( info.rights == PNUnknownAccessRights, @"");
	STAssertTrue( [info.subscriptionKey isEqualToString: @"key"] == TRUE, @"");
	STAssertTrue( info.channel == nil, @"");
	STAssertTrue( info.authorizationKey == nil, @"");
	STAssertTrue( info.accessPeriodDuration == 0, @"");
}

-(void)testAccessRightsInformationForAllChannels {
	PNAccessRightsCollection *collection = [PNAccessRightsCollection accessRightsCollectionForApplication: @"key" andAccessRightsLevel: PNApplicationAccessRightsLevel];
	[collection.channelsAccessRightsInformation setObject: @"obj" forKey: @"key"];
	NSArray *arr = [collection accessRightsInformationForAllChannels];

	STAssertTrue( [arr isEqualToArray: [collection.channelsAccessRightsInformation allValues]], @"");
}

-(void)testAccessRightsInformationForChannel {
	PNAccessRightsCollection *collection = [PNAccessRightsCollection accessRightsCollectionForApplication: @"key" andAccessRightsLevel: PNApplicationAccessRightsLevel];
	PNChannel *channel = [PNChannel channelWithName: @"channel"];

	PNAccessRightsInformation *info = [collection accessRightsInformationForChannel: channel];
	STAssertTrue( info.level == PNChannelAccessRightsLevel, @"");
	STAssertTrue( info.rights == PNUnknownAccessRights, @"");
	STAssertTrue( [info.subscriptionKey isEqualToString: @"key"] == TRUE, @"");
	STAssertTrue( info.channel == channel, @"");
	STAssertTrue( info.authorizationKey == nil, @"");
	STAssertTrue( info.accessPeriodDuration == 0, @"");

	collection = [PNAccessRightsCollection accessRightsCollectionForApplication: @"key" andAccessRightsLevel: PNApplicationAccessRightsLevel];
	info = [PNAccessRightsInformation accessRightsInformationForLevel: PNChannelAccessRightsLevel rights: PNReadAccessRight | PNWriteAccessRight applicationKey: @"key" forChannel: channel client: @"client" accessPeriod: 123];
	[collection storeChannelAccessRightsInformation: info];

	info = [collection accessRightsInformationForChannel: channel];
	STAssertTrue( info.level == PNChannelAccessRightsLevel, @"");
	STAssertTrue( info.rights == (PNReadAccessRight | PNWriteAccessRight), @"");
	STAssertTrue( [info.subscriptionKey isEqualToString: @"key"] == TRUE, @"");
	STAssertTrue( info.channel == channel, @"");
	STAssertTrue( [info.authorizationKey isEqualToString: @"client"], @"");
	STAssertTrue( info.accessPeriodDuration == 123, @"");
}

-(void)testAccessRightsForClientsOnChannel {
	PNAccessRightsCollection *collection = [PNAccessRightsCollection accessRightsCollectionForApplication: @"key" andAccessRightsLevel: PNApplicationAccessRightsLevel];
	PNChannel *channel = [PNChannel channelWithName: @"channel"];

	STAssertTrue( [[collection accessRightsForClientsOnChannel: channel] count] == 0, @"");

	PNAccessRightsInformation *info = [PNAccessRightsInformation accessRightsInformationForLevel: PNChannelAccessRightsLevel rights: PNReadAccessRight | PNWriteAccessRight applicationKey: @"key" forChannel: channel client: @"client" accessPeriod: 123];
	[collection storeClientAccessRightsInformation: info forChannel: channel];
	NSArray *arr = [collection accessRightsForClientsOnChannel: channel];
	STAssertTrue( [[collection accessRightsForClientsOnChannel: channel] count] == 1, @"");
	info = arr[0];
	STAssertTrue( info.level == PNChannelAccessRightsLevel, @"");
	STAssertTrue( info.rights == (PNReadAccessRight | PNWriteAccessRight), @"");
	STAssertTrue( [info.subscriptionKey isEqualToString: @"key"] == TRUE, @"");
	STAssertTrue( info.channel == channel, @"");
	STAssertTrue( [info.authorizationKey isEqualToString: @"client"], @"");
	STAssertTrue( info.accessPeriodDuration == 123, @"");
}

@end




