//
//  PNPubNubDataSyncSetTest.m
//  pubnub
//
//  Created by Vadim Osovets on 7/19/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

static NSString * const kTestFetchObject = @"ios_test_db";
static NSString * const kTestFetchPathFirst = @"test";
static NSString * const kTestFetchPathSecond = @"test/second";

@interface PNPubNubDataSyncSetTest : SenTestCase

<
PNDelegate
>

@end

@implementation PNPubNubDataSyncSetTest {
    dispatch_group_t _testSet;
    dispatch_group_t _testFetchObserver;
    dispatch_group_t _testFetchNotification;
    dispatch_group_t _testFetchObjectDataPath;
    dispatch_group_t _testFetchCompleteBlock;
}

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

- (void)testExample
{
    STFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end
