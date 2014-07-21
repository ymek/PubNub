//
//  PNPubNubDataSyncUpdateTest.m
//  pubnub
//
//  Created by Vadim Osovets on 7/20/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

static NSString * const kTestObject = @"ios_test_db_replace";
static NSString * const kTestPathFirst = @"test_first_level";
static NSString * const kTestPathComplex = @"test.second_level";
static const NSUInteger kTestStandardTimeout = 10;

@interface PNDataSyncUpdateTest : SenTestCase

<
PNDelegate
>

@end

@implementation PNDataSyncUpdateTest {
    dispatch_group_t _testDataInitialized;
    
    dispatch_group_t _testUpdate;
    dispatch_group_t _testUpdateWithObserver;
    dispatch_group_t _testUpdateWithCompletionHandler;
    dispatch_group_t _testUpdateDataPathWithCompletionHandler;
    
    NSMutableDictionary *_testData;
    NSMutableDictionary *_testUpdateData;
    NSMutableDictionary *_testResultData;
}

- (instancetype)initWithInvocation:(NSInvocation *)anInvocation {
    self = [super initWithInvocation:anInvocation];
    
    if (self) {
        _testData = [@{@"test1": @"value1", @"test2": @{@"test2.1": @"test2.1 value"}} mutableCopy];
        _testUpdateData = [@{@"test1": @"value1", @"test3": @{@"test3.1": @"test3.1 value"}} mutableCopy];
        _testResultData = [@{@"test1": @"value1", @"test3": @{@"test3.1": @"test3.1 value", }, @"test2": @{@"test2.1": @"test2.1 value"}} mutableCopy];
    }
    
    return self;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    [PubNub setDelegate:self];
    
    [PubNub setConfiguration:[PNConfiguration configurationForOrigin:@"pubsub-beta.pubnub.com"
                                                          publishKey:@"demo" subscribeKey:@"demo" secretKey:@"demo"]];
    
    [PubNub connect];
    
    _testDataInitialized = dispatch_group_create();
    
    dispatch_group_enter(_testDataInitialized);
    dispatch_group_enter(_testDataInitialized);
    
    // setup test data
    
    // remove whole data
    [PubNub deleteObject:kTestObject withCompletionHandlingBlock:^(PNObjectModificationInformation *modificationInfo, PNError *error) {
        if (!error) {
            STAssertTrue(modificationInfo.type == PNObjectDeleteType , @"Modification type is not appropriate.");
        } else {
            STFail(@"Error during observation of delete.");
        }
        
        dispatch_group_leave(_testDataInitialized);
    }];
    
    [PubNub replaceObject:kTestObject
                 dataPath:kTestPathComplex
                 withData:_testData
andCompletionHandlingBlock:^(PNObjectModificationInformation *modificationInformation, PNError *error) {
    if (!error) {
        dispatch_group_leave(_testDataInitialized);
    } else {
        STFail(@"Cannot initialize delete test: %@", error.localizedDescription);
    }
}];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    [PubNub disconnect];
}

#pragma mark - Tests

- (void)testSimpleUpdateObjectDataPath
{
    STAssertFalse([GCDWrapper isGroup:_testDataInitialized
                    timeoutFiredValue:kTestStandardTimeout], @"Cannot initialized test.");
    
    _testUpdate = dispatch_group_create();
    
    dispatch_group_enter(_testUpdate);
    
    [PubNub updateObject:kTestObject dataPath:kTestPathComplex withData:_testUpdateData];
    
    STAssertFalse([GCDWrapper isGroup:_testUpdate
                    timeoutFiredValue:kTestStandardTimeout], @"Simple update Object - failed.");
    
    _testUpdate = NULL;
    
    // check correctness of merging
    
    _testUpdate = dispatch_group_create();
    
    dispatch_group_enter(_testUpdate);
    
    [PubNub fetchObject:kTestObject
withCompletionHandlingBlock:^(PNObject *object, PNError *error) {
    
    if (!error) {
        
        STAssertEqualObjects([object valueForKeyPath:kTestPathComplex], _testResultData, @"Merged is failed.");
    }
    else {
        
        NSLog(@"Failed to retrieve because of error: %@", error);
        STFail(@"Cannot retrieve test data");
    }
    
    dispatch_group_leave(_testUpdate);
}];
    
    STAssertFalse([GCDWrapper isGroup:_testUpdate
                    timeoutFiredValue:kTestStandardTimeout], @"Simple merge Object - failed.");
    
    _testUpdate = NULL;
}

- (void)testSimpleUpdateObjectDataPathWithObserver
{
    STAssertFalse([GCDWrapper isGroup:_testDataInitialized
                    timeoutFiredValue:kTestStandardTimeout], @"Cannot initialized test.");
    
    _testUpdateWithCompletionHandler = dispatch_group_create();
    
    dispatch_group_enter(_testUpdateWithCompletionHandler);
    
    [PubNub updateObject:kTestObject dataPath:kTestPathComplex withData:_testUpdateData andCompletionHandlingBlock:^(PNObjectModificationInformation *modificationObject, PNError *error) {
        if (!error) {
            dispatch_group_leave(_testUpdateWithCompletionHandler);
        } else {
            STFail(@"Cannot update object: %@", error.localizedDescription);
        }
    }];
    
    STAssertFalse([GCDWrapper isGroup:_testUpdateWithCompletionHandler
                    timeoutFiredValue:kTestStandardTimeout], @"Simple update Object - failed.");
    
    _testUpdateWithCompletionHandler = NULL;
    
    // check correctness of merging
    
    _testUpdateWithCompletionHandler = dispatch_group_create();
    
    dispatch_group_enter(_testUpdateWithCompletionHandler);
    
    [PubNub fetchObject:kTestObject
withCompletionHandlingBlock:^(PNObject *object, PNError *error) {
    
    if (!error) {
        
        STAssertEqualObjects([object valueForKeyPath:kTestPathComplex], _testResultData, @"Merged is failed.");
    }
    else {
        
        NSLog(@"Failed to retrieve because of error: %@", error);
        STFail(@"Cannot retrieve test data");
    }
    
    dispatch_group_leave(_testUpdateWithCompletionHandler);
}];
    
    STAssertFalse([GCDWrapper isGroup:_testUpdateWithCompletionHandler
                    timeoutFiredValue:kTestStandardTimeout], @"Simple merge Object - failed.");
    
    _testUpdateWithCompletionHandler = NULL;
}

#pragma mark - PNDelegate

- (void)pubnubClient:(PubNub *)client didUpdateObject:(PNObjectModificationInformation *)modificationInformation {
    // PubNub client retrieved remote object.
    
    if (_testUpdate != NULL) {
        dispatch_group_leave(_testUpdate);
    }
}

- (void)pubnubClient:(PubNub *)client objectUpdateDidFailWithError:(PNError *)error {
    
    // PubNub client did fail to retrieve remote object.
    //
    // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
    // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
    // 'error.associatedObject' reference on PNObjectFetchInformation instance for which PubNub client was unable to
    // create local copy.
    
    if (_testUpdate != NULL) {
        STFail(@"Fail to replace simple fetch: %@", [error localizedDescription]);
    }
}

#pragma mark - Notifications

- (void)simpleDeleteNotification:(NSNotification *)notif {
    if (_testUpdate != NULL) {
        dispatch_group_leave(_testUpdate);
    }
}

@end
