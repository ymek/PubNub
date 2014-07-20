//
//  PNPubNubDataSyncSetTest.m
//  pubnub
//
//  Created by Vadim Osovets on 7/19/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

/*
 Set method represented by list of "replace*" methods.
 */

#import <SenTestingKit/SenTestingKit.h>

static NSString * const kTestObject = @"ios_test_db_replace";
static NSString * const kTestPathFirst = @"test";
static NSString * const kTestPathComplex = @"test.second";
static const NSUInteger kTestStandardTimeout = 10;

@interface PNPubNubDataSyncSetTest : SenTestCase

<
PNDelegate
>

@end

@implementation PNPubNubDataSyncSetTest {
    dispatch_group_t _testReplace;
    dispatch_group_t _testReplaceWithObserver;
    dispatch_group_t _testReplaceWithCompletionHandler;
    dispatch_group_t _testReplaceDataPathWithCompletionHandler;
    
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
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    [PubNub disconnect];
}

- (void)testSimpleReplaceObject
{
    
    _testReplace = dispatch_group_create();
    
    dispatch_group_enter(_testReplace);
    
    [PubNub replaceObject:kTestObject withData:_testData];
    
    STAssertFalse([GCDWrapper isGroup:_testReplace
                   timeoutFiredValue:kTestStandardTimeout], @"Simple replace Object - failed.");
    
    _testReplace = NULL;
}


- (void)testSimpleReplaceObserver
{
    _testReplaceWithObserver = dispatch_group_create();
    
    dispatch_group_enter(_testReplaceWithObserver);
    
    [PubNub replaceObject:kTestObject withData:_testData];
    
    [[PNObservationCenter defaultCenter] addObjectReplaceObserver:self
                                                        withBlock:^(PNObjectModificationInformation *modificationInformation, PNError *error) {
                                                          if (_testReplaceWithObserver != NULL) {
                                                              
                                                              if (!error) {
                                                                  
                                                                  // PubNub client retrieved remote object.
                                                                  
                                                                  STAssertEqualObjects(_testData, modificationInformation.data, @"Data's are not equal.");
                                                                  
                                                              } else {
                                                                  
                                                                  // PubNub client did fail to retrieve remote object.
                                                                  //
                                                                  // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
                                                                  // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
                                                                  // 'error.associatedObject' reference on PNObjectFetchInformation instance for which PubNub client was unable to
                                                                  // create local copy.
                                                                  
                                                                  STFail(@"Fail to retrieve simple fetch: %@", [error localizedDescription]);
                                                              }
                                                              
                                                              dispatch_group_leave(_testReplaceWithObserver);
                                                          }
                                                      }];
    
    STAssertFalse([GCDWrapper isGroup:_testReplaceWithObserver
                    timeoutFiredValue:kTestStandardTimeout], @"Simple replace Object using observer - failed.");
    
    [[PNObservationCenter defaultCenter] removeObjectReplaceObserver:self];
    
    _testReplaceWithObserver = NULL;
}


- (void)testSimpleReplaceWithCompletionHandler
{
    _testReplaceWithCompletionHandler = dispatch_group_create();
    
    dispatch_group_enter(_testReplaceWithCompletionHandler);
    
    [PubNub replaceObject:kTestObject
                 withData:_testData
andCompletionHandlingBlock:^(PNObjectModificationInformation *modificationInfo, PNError *error) {
    if (!error) {
        NSLog(@"Replaced object: %@", modificationInfo.data);
    }
    else {
        NSLog(@"Failed to replace object because of error: %@", error);
        STFail(@"Cannot replace test object.");
    }
    
    dispatch_group_leave(_testReplaceWithCompletionHandler);
}];
    
    STAssertFalse([GCDWrapper isGroup:_testReplaceWithCompletionHandler
                    timeoutFiredValue:kTestStandardTimeout], @"Simple replace Object with completion handler - failed.");
    
    _testReplaceWithCompletionHandler = NULL;
}

- (void)testSimpleReplaceObjectDataPath
{
    _testReplaceDataPathWithCompletionHandler = dispatch_group_create();
    
    dispatch_group_enter(_testReplaceDataPathWithCompletionHandler);
    dispatch_group_enter(_testReplaceDataPathWithCompletionHandler);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(simpleReplaceNotification:)
                                                 name:kPNClientDidReplaceObjectNotification
                                               object:nil];
    
    [PubNub replaceObject:kTestObject
                 dataPath:kTestPathComplex
                 withData:_testData
andCompletionHandlingBlock:^(PNObjectModificationInformation *modificationInformation, PNError *error) {
    if (!error) {
        NSLog(@"Replaced object: %@", modificationInformation.data);
    }
    else {
        NSLog(@"Failed to replace object because of error: %@", error);
        STFail(@"Cannot replace test object.");
    }
    
    dispatch_group_leave(_testReplaceDataPathWithCompletionHandler);
}];
    
    STAssertFalse([GCDWrapper isGroup:_testReplaceDataPathWithCompletionHandler
                    timeoutFiredValue:kTestStandardTimeout], @"Simple replace Object with data path - failed.");

    _testReplaceDataPathWithCompletionHandler = NULL;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - PNDelegate

- (void)pubnubClient:(PubNub *)client didReplaceObject:(PNObjectModificationInformation *)modificationInformation {
    // PubNub client retrieved remote object.
    
    if (_testReplace != NULL) {
        
        STAssertEqualObjects(_testData, modificationInformation.data, @"Data's are not equal.");
        
        dispatch_group_leave(_testReplace);
    }
}

- (void)pubnubClient:(PubNub *)client objectReplaceDidFailWithError:(PNError *)error {
    
    // PubNub client did fail to retrieve remote object.
    //
    // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
    // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
    // 'error.associatedObject' reference on PNObjectFetchInformation instance for which PubNub client was unable to
    // create local copy.
    
    if (_testReplace != NULL) {
        STFail(@"Fail to replace simple fetch: %@", [error localizedDescription]);
    }
}

#pragma mark - Notifications

- (void)simpleReplaceNotification:(NSNotification *)notif {
    if (_testReplace != NULL) {
        dispatch_group_leave(_testReplace);
    }
    
    if (_testReplaceDataPathWithCompletionHandler != NULL) {
        dispatch_group_leave(_testReplaceDataPathWithCompletionHandler);
    }
}

@end
