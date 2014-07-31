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
static const NSUInteger kTestStandardTimeout = 30;

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

- (void)testBigData1Kb
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

- (void)t1estBigData1Mb
{
    _testReplace1Mb = dispatch_group_create();
    
    dispatch_group_enter(_testReplace1Mb);
    
//    NSDictionary *testDict = [self generateTestDictWithDepth:6 maxKeysOnLevel:5];
    NSDictionary *testDict = [self generateTestDictWithDepth:5 maxKeysOnLevel:5];

    
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
                    timeoutFiredValue:kTestStandardTimeout], @"Replace object with data size: %luKb failed", (unsigned long)[data length]/1024);
    
    dispatch_group_enter(_testReplace1Mb);
    [PubNub fetchObject:kTestObject withCompletionHandlingBlock:^(PNObject *obj, PNError *error) {
        if (error) {
            STFail(@"Cannot set object with size:  %luKb", (unsigned long)[data length]/1024);
        }
        
        dispatch_group_leave(_testReplace1Mb);
    }];
    
    STAssertFalse([GCDWrapper isGroup:_testReplace1Mb
                    timeoutFiredValue:kTestStandardTimeout], @"Fetch object with data size: %luKb failed", (unsigned long)[data length]/1024);
    
    _testReplace1Mb = NULL;
}

- (void)testBigData100Mb
{
    _testReplace100Mb = dispatch_group_create();

    // 1211Mb - 10/5
    // 44Mb - 8/5
    // 1811Mb - 8/8
    // 185Mb - 8/6
    // 1169Mb - 9/6
    // 573Mb - 5/23
    // 94Mb - 5/16
    
    NSDictionary *testDict = [self generateTestDictWithDepth:5 maxKeysOnLevel:16];
    
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:[NSDictionary dictionaryWithDictionary:testDict]
                                                              format:NSPropertyListXMLFormat_v1_0 options:NSProprietaryStringEncoding error:NULL];
    NSLog(@"Data size: %luMb", (unsigned long)[data length]/(1024 * 1024));
    
    [PubNub replaceObject:kTestObject withData:testDict andCompletionHandlingBlock:^(PNObjectModificationInformation *objectModification, PNError *error) {
        
        if (error) {
            STFail(@"Cannot set object with size:  %luMb", (unsigned long)[data length]/(1024 * 1024));
        }
        
        dispatch_group_leave(_testReplace100Mb);
    }];
    
    STAssertFalse([GCDWrapper isGroup:_testReplace100Mb
                    timeoutFiredValue:kTestStandardTimeout], @"Replace object with data size: %luMb failed", (unsigned long)[data length]/(1024 * 1024));
    
    dispatch_group_enter(_testReplace100Mb);
    [PubNub fetchObject:kTestObject withCompletionHandlingBlock:^(PNObject *obj, PNError *error) {
        if (error) {
            STFail(@"Cannot set object with size:  %luMb", (unsigned long)[data length]/(1024 * 1024));
        }
        
        dispatch_group_leave(_testReplace100Mb);
    }];
    
    STAssertFalse([GCDWrapper isGroup:_testReplace100Mb
                    timeoutFiredValue:kTestStandardTimeout], @"Fetch object with data size: %luMb failed", (unsigned long)[data length]/(1024 * 1024));
    
    _testReplace100Mb = NULL;
}

- (void)testBigData500Mb
{
    _testReplace500Mb = dispatch_group_create();
    
    dispatch_group_enter(_testReplace500Mb);
    // 1211Mb - 10/5
    // 44Mb - 8/5
    // 1811Mb - 8/8
    // 185Mb - 8/6
    // 1169Mb - 9/6
    
    NSDictionary *testDict = [self generateTestDictWithDepth:5 maxKeysOnLevel:23];
    
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:[NSDictionary dictionaryWithDictionary:testDict]
                                                              format:NSPropertyListXMLFormat_v1_0 options:NSProprietaryStringEncoding error:NULL];
    NSLog(@"Data size: %luMb", (unsigned long)[data length]/(1024 * 1024));
    
    [PubNub replaceObject:kTestObject withData:testDict andCompletionHandlingBlock:^(PNObjectModificationInformation *objectModification, PNError *error) {
        
        if (error) {
            STFail(@"Cannot set object with size:  %luMb", (unsigned long)[data length]/(1024 * 1024));
        }
        
        dispatch_group_leave(_testReplace500Mb);
    }];
    
    STAssertFalse([GCDWrapper isGroup:_testReplace500Mb
                    timeoutFiredValue:kTestStandardTimeout], @"Replace object with data size: %luMb failed", (unsigned long)[data length]/(1024 * 1024));
    
    dispatch_group_enter(_testReplace500Mb);
    [PubNub fetchObject:kTestObject withCompletionHandlingBlock:^(PNObject *obj, PNError *error) {
        if (error) {
            STFail(@"Cannot set object with size:  %luMb", (unsigned long)[data length]/(1024 * 1024));
        }
        
        dispatch_group_leave(_testReplace500Mb);
    }];
    
    STAssertFalse([GCDWrapper isGroup:_testReplace500Mb
                    timeoutFiredValue:kTestStandardTimeout], @"Fetch object with data size: %luMb failed", (unsigned long)[data length]/(1024 * 1024));
    
    _testReplace500Mb = NULL;
}

- (void)testBigData1Gb
{
    _testReplace1Gb = dispatch_group_create();
    
    dispatch_group_enter(_testReplace1Gb);
    
    NSDictionary *testDict = [self generateTestDictWithDepth:9 maxKeysOnLevel:6];
    
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:[NSDictionary dictionaryWithDictionary:testDict]
                                                              format:NSPropertyListXMLFormat_v1_0 options:NSProprietaryStringEncoding error:NULL];
    NSLog(@"Data size: %luMb", (unsigned long)[data length]/(1024 * 1024));
    
    [PubNub replaceObject:kTestObject withData:testDict andCompletionHandlingBlock:^(PNObjectModificationInformation *objectModification, PNError *error) {
        
        if (error) {
            STFail(@"Cannot set object with size:  %luMb", (unsigned long)[data length]/(1024 * 1024));
        }
        
        dispatch_group_leave(_testReplace1Gb);
    }];
    
    STAssertFalse([GCDWrapper isGroup:_testReplace1Gb
                    timeoutFiredValue:kTestStandardTimeout], @"Replace object with data size: %luMb failed", (unsigned long)[data length]/(1024 * 1024));
    
    dispatch_group_enter(_testReplace1Gb);
    [PubNub fetchObject:kTestObject withCompletionHandlingBlock:^(PNObject *obj, PNError *error) {
        if (error) {
            STFail(@"Cannot set object with size:  %luMb", (unsigned long)[data length]/(1024 * 1024));
        }
        
        dispatch_group_leave(_testReplace1Gb);
    }];
    
    STAssertFalse([GCDWrapper isGroup:_testReplace1Gb
                    timeoutFiredValue:kTestStandardTimeout], @"Fetch object with data size: %luMb failed", (unsigned long)[data length]/(1024 * 1024));
    
    _testReplace1Gb = NULL;
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
