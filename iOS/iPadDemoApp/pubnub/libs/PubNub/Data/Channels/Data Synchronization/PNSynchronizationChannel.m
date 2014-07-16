//
//  PNSynchronizationChannel.m
//  pubnub
//
//  Created by Sergey Mamontov on 7/14/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNSynchronizationChannel+Protected.h"
#import "PNObjectSynchronizationEvent.h"


#pragma mark Public interface declaration

@implementation PNSynchronizationChannel


#pragma mark - Class methods

+ (id)channelForObject:(NSString *)objectIdentifier dataPath:(NSString *)partialObjectDataPath {

    PNSynchronizationChannel *baseChannel = [self channelWithName:[NSString stringWithFormat:@"pn_ds_%@", objectIdentifier]];
    baseChannel.objectIdentifier = objectIdentifier;
    baseChannel.partialObjectDataPath = partialObjectDataPath;
    baseChannel.objectSyncronizationChannel = YES;


    return baseChannel;
}

+ (NSArray *)channelsForObject:(NSString *)objectIdentifier dataPath:(NSString *)partialObjectDataPath {

    PNSynchronizationChannel *baseChannel = [self channelWithName:[NSString stringWithFormat:@"pn_ds_%@", objectIdentifier]];
    baseChannel.objectIdentifier = objectIdentifier;
    baseChannel.partialObjectDataPath = partialObjectDataPath;
    baseChannel.objectSyncronizationChannel = YES;

    PNSynchronizationChannel *wildCardChannel = [self channelWithName:[NSString stringWithFormat:@"pn_ds_%@%@.*",
                    ([partialObjectDataPath length] > 0 ? [NSString stringWithFormat:@".%@", partialObjectDataPath] : @""),
                    objectIdentifier]];
    wildCardChannel.objectIdentifier = objectIdentifier;
    wildCardChannel.partialObjectDataPath = partialObjectDataPath;
    wildCardChannel.objectSyncronizationChannel = YES;

    PNSynchronizationChannel *transactionChannel = [[self class] channelWithName:[NSString stringWithFormat:@"pn_dstr_%@", objectIdentifier]];
    transactionChannel.objectIdentifier = objectIdentifier;
    transactionChannel.partialObjectDataPath = partialObjectDataPath;
    transactionChannel.objectSyncronizationChannel = YES;


    return @[baseChannel, wildCardChannel, transactionChannel];
}

#pragma mark -


@end
