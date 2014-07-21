//
//  PNPubNubDataSyncDeleteTest.m
//  pubnub
//
//  Created by Vadim Osovets on 7/20/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

static NSString * const kTestObject = @"ios_test_db_replace";
static NSString * const kTestPathFirst = @"test";
static NSString * const kTestPathComplex = @"test.second";
static const NSUInteger kTestStandardTimeout = 10;

@interface PNDataSyncDeleteTest : SenTestCase

<
PNDelegate
>

@end

@implementation PNDataSyncDeleteTest {
    dispatch_group_t _testDataInitialized;
    
    dispatch_group_t _testDelete;
    dispatch_group_t _testDeleteWithObserver;
    dispatch_group_t _testDeleteWithCompletionHandler;
    dispatch_group_t _testDeleteDataPathWithCompletionHandler;
    
    NSMutableDictionary *_testData;
}

- (instancetype)initWithInvocation:(NSInvocation *)anInvocation {
    self = [super initWithInvocation:anInvocation];
    
    if (self) {
        _testData = [@{@"test1": @"value1", @"test2": @{@"test2.1": @"test2.1 value"}} mutableCopy];
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
    
    
    // setup test data
    
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

- (void)testSimpleDeleteObject
{
    STAssertFalse([GCDWrapper isGroup:_testDataInitialized
                    timeoutFiredValue:kTestStandardTimeout], @"Cannot initialized test.");
    
    _testDelete = dispatch_group_create();
    
    dispatch_group_enter(_testDelete);
    
    [PubNub deleteObject:kTestObject];
    
    STAssertFalse([GCDWrapper isGroup:_testDelete
                    timeoutFiredValue:kTestStandardTimeout], @"Simple delete Object - failed.");
    
    _testDelete = NULL;
}

- (void)testSimpleDeleteObjectWithObserver
{
    STAssertFalse([GCDWrapper isGroup:_testDataInitialized
                    timeoutFiredValue:kTestStandardTimeout], @"Cannot initialized test.");
    
    _testDeleteWithObserver = dispatch_group_create();
    
    dispatch_group_enter(_testDeleteWithObserver);
    
    [[PNObservationCenter defaultCenter] addObjectDeleteObserver:self
                                                       withBlock:^(PNObjectModificationInformation *objectInformation, PNError *error) {
                                                           if (!error) {
                                                               STAssertTrue(objectInformation.type == PNObjectDeleteType , @"Modification type is not appropriate.");
                                                           } else {
                                                               STFail(@"Error during observation of delete.");
                                                           }
                                                           
                                                           dispatch_group_leave(_testDeleteWithObserver);
                                                       }];
    
    
    [PubNub deleteObject:kTestObject dataPath:kTestPathComplex];
    
    STAssertFalse([GCDWrapper isGroup:_testDeleteWithObserver
                    timeoutFiredValue:kTestStandardTimeout], @"Simple delete Object with observer - failed.");
    
    _testDeleteWithObserver = NULL;
}

- (void)testSimpleDeleteObjectWithCompletionHandler
{
    STAssertFalse([GCDWrapper isGroup:_testDataInitialized
                    timeoutFiredValue:kTestStandardTimeout], @"Cannot initialized test.");
    
    _testDeleteWithCompletionHandler = dispatch_group_create();
    
    dispatch_group_enter(_testDeleteWithCompletionHandler);
    
    [PubNub deleteObject:kTestObject
withCompletionHandlingBlock:^(PNObjectModificationInformation *modificationInformation, PNError *error) {
    
    if (!error) {
        STAssertTrue(modificationInformation.type == PNObjectDeleteType , @"Modification type is not appropriate.");
    } else {
        STFail(@"Error during observation of delete.");
    }
    
    dispatch_group_leave(_testDeleteWithCompletionHandler);
}];
    
    STAssertFalse([GCDWrapper isGroup:_testDeleteWithCompletionHandler
                    timeoutFiredValue:kTestStandardTimeout], @"Simple delete Object with completion handler - failed.");
    
    _testDeleteWithCompletionHandler = NULL;
}

- (void)testSimpleDeleteObjectDataPathWithCompletionHandler
{
    STAssertFalse([GCDWrapper isGroup:_testDataInitialized
                    timeoutFiredValue:kTestStandardTimeout], @"Cannot initialized test.");
    
    _testDeleteDataPathWithCompletionHandler = dispatch_group_create();
    
    dispatch_group_enter(_testDeleteDataPathWithCompletionHandler);
    dispatch_group_enter(_testDeleteDataPathWithCompletionHandler);
    
    [PubNub deleteObject:kTestObject
                dataPath:kTestPathComplex
andCompletionHandlingBlock:^(PNObjectModificationInformation *modificationInformation, PNError *error) {
    
    if (!error) {
        STAssertTrue(modificationInformation.type == PNObjectDeleteType , @"Modification type is not appropriate.");
    } else {
        STFail(@"Error during observation of delete.");
    }
    
    dispatch_group_leave(_testDeleteDataPathWithCompletionHandler);
}];
    
    STAssertFalse([GCDWrapper isGroup:_testDeleteDataPathWithCompletionHandler
                    timeoutFiredValue:kTestStandardTimeout], @"Simple delete Object with completion handler - failed.");
    
    _testDeleteDataPathWithCompletionHandler = NULL;
}

#pragma mark - PNDelegate

- (void)pubnubClient:(PubNub *)client didDeleteObject:(PNObjectModificationInformation *)modificationInformation {
    // PubNub client retrieved remote object.
    
    if (_testDelete != NULL) {
        dispatch_group_leave(_testDelete);
    }
    
    if (_testDeleteDataPathWithCompletionHandler != NULL) {
        dispatch_group_leave(_testDeleteDataPathWithCompletionHandler);
    }
}

- (void)pubnubClient:(PubNub *)client objectDeleteDidFailWithError:(PNError *)error {
    
    // PubNub client did fail to retrieve remote object.
    //
    // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
    // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
    // 'error.associatedObject' reference on PNObjectFetchInformation instance for which PubNub client was unable to
    // create local copy.
    
    if (_testDelete != NULL) {
        STFail(@"Fail to replace simple fetch: %@", [error localizedDescription]);
    }
}

#pragma mark - Notifications

- (void)simpleDeleteNotification:(NSNotification *)notif {
    if (_testDelete != NULL) {
        dispatch_group_leave(_testDelete);
    }
}

@end
