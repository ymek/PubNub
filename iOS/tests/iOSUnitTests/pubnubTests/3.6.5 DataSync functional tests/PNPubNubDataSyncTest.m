//
//  PNPubNubDataSyncTest.m
//  pubnub
//
//  Created by Vadim Osovets on 7/17/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@interface PNPubNubDataSyncTest : SenTestCase

@end

@implementation PNPubNubDataSyncTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSimpleFetch
{
    [PubNub setConfiguration:[PNConfiguration configurationForOrigin:@"pubsub-beta.pubnub.com"
                                                         publishKey:@"demo" subscribeKey:@"demo" secretKey:@"demo"]];
    
    dispatch_group_t syncGroup = dispatch_group_create();
    
    [PubNub connect];
    
    dispatch_group_enter(syncGroup);
    
    [PubNub fetchObject:@"ios_test_db" dataPath:@"a"
withCompletionHandlingBlock:^(PNObject *object, PNError *error) {
//    [PubNub fetchObject:@"hello_db" dataPath:@"/a"
//withCompletionHandlingBlock:^(PNObject *object, PNError *error) {
    
    if (!error) {
        
        NSLog(@"Retrieved object: %@", object);
        
        STFail(@"Cannot retrieve test data");
    }
    else {
        
        NSLog(@"Failed to retrieve because of error: %@", error);
    }
    
    dispatch_group_leave(syncGroup);
}];
    
    [GCDWrapper waitGroup:syncGroup];
}

@end
