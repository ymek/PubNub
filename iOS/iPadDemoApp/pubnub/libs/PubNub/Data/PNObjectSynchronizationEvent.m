//
//  PNObjectSynchronizationEvent.m
//  pubnub
//
//  Created by Sergey Mamontov on 7/13/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNObjectSynchronizationEvent+Protected.h"


#pragma mark Public interface implementation

@implementation PNObjectSynchronizationEvent


#pragma mark - Class methods

+ (PNObjectSynchronizationEvent *)synchronizationEvent:(PNObjectSynchronizationEventType)type forObject:(NSString *)objectIdentifier
                                            atLocation:(NSString *)changeLocation changeDate:(NSString *)changeDate
                                               andData:(id)changedData {

    return [[self alloc] initWithEvent:type forObject:objectIdentifier atLocation:changeLocation changeDate:changeDate
                               andData:changedData];
}


#pragma mark - Instance methods

- (id)initWithEvent:(PNObjectSynchronizationEventType)type forObject:(NSString *)objectIdentifier
         atLocation:(NSString *)changeLocation changeDate:(NSString *)changeDate andData:(id)changedData {

    // Check whether initialization has been successful or not.
    if ((self = [super init])) {

        self.type = type;
        self.objectIdentifier = objectIdentifier;
        self.changeLocation = [changeLocation stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@.", self.objectIdentifier]
                                                                        withString:@""];
        self.changeDate = (changeDate ? changeDate :
                                        PNStringFromUnsignedLongLongNumber([[PNDate dateWithDate:[NSDate date]] timeToken]));
        self.changedData = changedData;
    }


    return self;
}

#pragma mark -


@end
