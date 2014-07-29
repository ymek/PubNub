//
//  PNDataSyncBigData.m
//  pubnub
//
//  Created by Vadim Osovets on 7/29/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

static NSString * const kTestObject = @"ios_test_db_big";
static NSString * const kTestPathFirst = @"test";
static NSString * const kTestPathComplex = @"test.second";
static const NSUInteger kTestStandardTimeout = 10;

@interface NSMutableDictionary ()

- (NSMutableDictionary *)generateDictWithKeys:(NSUInteger)maxKeysOnLevel andDepth:(NSUInteger)depth;

@end

@implementation NSMutableDictionary

- (NSMutableDictionary *)generateDictWithKeys:(NSUInteger)maxKeysOnLevel andDepth:(NSUInteger)depth {
    
    return self;
}


@end

@interface PNDataSyncBigData : SenTestCase

<
PNDelegate
>

@end

@implementation PNDataSyncBigData {
        dispatch_group_t _testReplace;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    [PubNub setDelegate:self];
    
    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
    
    [PubNub connect];
}

- (void)tearDown
{
    
    [PubNub disconnect];
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBigData
{
    _testReplace = dispatch_group_create();
    
    dispatch_group_enter(_testReplace);
    
    NSDictionary *testDict = [self testData];
    
    [PubNub replaceObject:kTestObject withData:testDict];
    
    STAssertFalse([GCDWrapper isGroup:_testReplace
                    timeoutFiredValue:kTestStandardTimeout], @"Simple replace Object - failed.");
    
    _testReplace = NULL;
}

#pragma mark - Generate test data

- (NSDictionary *)testData {
    // generate test dictionary
    
    NSUInteger depth = 100;
    NSUInteger maxKeysOnLevel = 100;
    
    NSMutableDictionary *dict = [[NSMutableDictionary new] generateDictWithKeys:maxKeysOnLevel andDepth:depth];
    
    return dict;
}

@end
