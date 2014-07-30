//
//  PNDataSyncBigData.m
//  pubnub
//
//  Created by Vadim Osovets on 7/29/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

static NSString * const kTestObject = @"ios_test_db_big_1";
static NSString * const kTestPathFirst = @"test";
static NSString * const kTestPathComplex = @"test.second";
static const NSUInteger kTestStandardTimeout = 20;

@interface PNDataSyncBigData : SenTestCase

<
PNDelegate
>

@end

@implementation PNDataSyncBigData {
        dispatch_group_t _testReplace1Kb;
        dispatch_group_t _testReplace1Mb;
        dispatch_group_t _testReplace100Mb;
        dispatch_group_t _testReplace500Mb;
        dispatch_group_t _testReplace1Gb;
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

- (void)t1estBigData1Kb
{
    _testReplace1Kb = dispatch_group_create();
    
    dispatch_group_enter(_testReplace1Kb);
    
    NSDictionary *testDict = [self generateTestDictWithDepth:2 maxKeysOnLevel:4];
    
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:[NSDictionary dictionaryWithDictionary:testDict]
                                                              format:NSPropertyListXMLFormat_v1_0 options:NSProprietaryStringEncoding error:NULL];
    NSLog(@"Data size: %luKb", (unsigned long)[data length]/1024);
    
    [PubNub replaceObject:kTestObject withData:testDict andCompletionHandlingBlock:^(PNObjectModificationInformation *objectModification, PNError *error) {
        
        if (error) {
            STFail(@"Cannot set object with size:  %luKb", (unsigned long)[data length]/1024);
        }
        
        dispatch_group_leave(_testReplace1Kb);
    }];
    
    STAssertFalse([GCDWrapper isGroup:_testReplace1Kb
                    timeoutFiredValue:kTestStandardTimeout], @"Simple replace Object - failed.");

    
    dispatch_group_enter(_testReplace1Kb);
    [PubNub fetchObject:kTestObject withCompletionHandlingBlock:^(PNObject *obj, PNError *error) {
        if (error) {
            STFail(@"Cannot set object with size:  %luKb", (unsigned long)[data length]/1024);
        }
        
        dispatch_group_leave(_testReplace1Kb);
    }];
    
    STAssertFalse([GCDWrapper isGroup:_testReplace1Kb
                    timeoutFiredValue:kTestStandardTimeout], @"Simple fetch Object - failed.");
    
    _testReplace1Kb = NULL;
}

- (void)testBigData1Mb
{
    _testReplace1Mb = dispatch_group_create();
    
    dispatch_group_enter(_testReplace1Mb);
    
//    NSDictionary *testDict = [self generateTestDictWithDepth:6 maxKeysOnLevel:5];
    NSDictionary *testDict = [self generateTestDictWithDepth:4 maxKeysOnLevel:5];

    
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:[NSDictionary dictionaryWithDictionary:testDict]
                                                              format:NSPropertyListXMLFormat_v1_0 options:NSProprietaryStringEncoding error:NULL];
    NSLog(@"Data size: %luKb", (unsigned long)[data length]/1024);
    
    [PubNub replaceObject:kTestObject withData:testDict andCompletionHandlingBlock:^(PNObjectModificationInformation *objectModification, PNError *error) {
        
        if (error) {
            STFail(@"Cannot set object with size:  %luKb", (unsigned long)[data length]/1024);
        }
        
        dispatch_group_leave(_testReplace1Mb);
    }];
    
    STAssertFalse([GCDWrapper isGroup:_testReplace1Mb
                    timeoutFiredValue:kTestStandardTimeout], @"Simple replace Object - failed.");
    
    dispatch_group_enter(_testReplace1Mb);
    [PubNub fetchObject:kTestObject withCompletionHandlingBlock:^(PNObject *obj, PNError *error) {
        if (error) {
            STFail(@"Cannot set object with size:  %luKb", (unsigned long)[data length]/1024);
        }
        
        dispatch_group_leave(_testReplace1Mb);
    }];
    
    STAssertFalse([GCDWrapper isGroup:_testReplace1Mb
                    timeoutFiredValue:kTestStandardTimeout], @"Simple fetch Object - failed.");
    
    _testReplace1Mb = NULL;
}

#pragma mark - Generate test data

- (NSDictionary *)generateTestDictWithDepth:(NSUInteger)depth maxKeysOnLevel:(NSUInteger)maxKeysOnLevel {
    // generate test dictionary

    NSLog(@"Start generating test data:\n\t depth: %lu, \n\tmax keys: %lu", depth, maxKeysOnLevel);
    
    NSMutableDictionary *dict = [self parentDictionary:[NSMutableDictionary new] generateDictWithKeys:maxKeysOnLevel
                                              andDepth:depth];
    
    NSLog(@"End");
    
    return dict;
}

- (NSMutableDictionary *)parentDictionary:(NSDictionary *)parentDict
                     generateDictWithKeys:(NSUInteger)maxKeysOnLevel
                                 andDepth:(NSUInteger)depth {
    
//    NSLog(@"\tcurrent depth: %lu", depth);
    
    if (depth == 0) {
        return [@{[NSString stringWithFormat:@"%lu", (unsigned long)depth]: @"end"} mutableCopy];
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    for (NSUInteger i = 0; i < maxKeysOnLevel; i++) {
        dict[[NSString stringWithFormat:@"%lu.%lu", (unsigned long)depth, (unsigned long)i]] = [self parentDictionary:dict
                                                                 generateDictWithKeys:maxKeysOnLevel andDepth:depth - 1];
    }
    
    return dict;
}

@end
