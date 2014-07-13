//
//  PNObjectSynchronizationEvent+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 7/13/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNObjectSynchronizationEvent.h"


#pragma mark Private interface declaration

@interface PNObjectSynchronizationEvent ()


#pragma mark - Properties

@property (nonatomic, assign) PNObjectSynchronizationEventType type;
@property (nonatomic, copy) NSString *objectIdentifier;
@property (nonatomic, copy) NSString *changeLocation;
@property (nonatomic, copy) NSString *changeDate;
@property (nonatomic, strong) id changedData;


#pragma mark - Class methods

/**
 Construct synchronization event for concrete remote object.

 @param type
 One of \b PNObjectSynchronizationEventType fields which specify concrete change event action which should be
 performed on local copy of the object.

 @param objectIdentifier
 Reference on remote object identifier for which this event has been generated.

 @param changeLocation
 Reference on location at which change should be preformed.

 @param changeDate
 Reference on date when this change has been generated.

 @param changedData
 \a id object which store reference on data which should be applied using \c changeLocation path and \c type for
 concrete action.

 @return Ready to use \b PNObjectSynchronizationEvent instance.
 */
+ (PNObjectSynchronizationEvent *)synchronizationEvent:(PNObjectSynchronizationEventType)type forObject:(NSString *)objectIdentifier
                                            atLocation:(NSString *)changeLocation changeDate:(NSString *)changeDate
                                               andData:(id)changedData;


#pragma mark - Instance methods

/**
 Initialize synchronization event for concrete remote object.

 @param type
 One of \b PNObjectSynchronizationEventType fields which specify concrete change event action which should be
 performed on local copy of the object.

 @param objectIdentifier
 Reference on remote object identifier for which this event has been generated.

 @param changeLocation
 Reference on location at which change should be preformed.

 @param changeDate
 Reference on date when this change has been generated.

 @param changedData
 \a id object which store reference on data which should be applied using \c changeLocation path and \c type for
 concrete action.

 @return Ready to use \b PNObjectSynchronizationEvent instance.
 */
- (id)initWithEvent:(PNObjectSynchronizationEventType)type forObject:(NSString *)objectIdentifier
         atLocation:(NSString *)changeLocation changeDate:(NSString *)changeDate andData:(id)changedData;

#pragma mark -


@end
