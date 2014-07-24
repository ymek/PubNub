//
//  PNDataSyncSyncTest.m
//  pubnub
//
//  Created by Vadim Osovets on 7/23/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

// it is important that in this test we need to use some other client for PubNub
// because functionality of synchronization related to change object outside of client.

#import <SenTestingKit/SenTestingKit.h>

static NSString * const kTestObject = @"ios_test_db_sync";
static NSString * const kTestPathFirst = @"test_first_level";
static NSString * const kTestPathComplex = @"test.second_level";
static const NSUInteger kTestStandardTimeout = 10;

@interface PNDataSyncSyncTest : SenTestCase

<
PNDelegate
>

@end

@implementation PNDataSyncSyncTest {
    dispatch_group_t _testSync;
    dispatch_group_t _testSyncWithObserver;
    dispatch_group_t _testSyncWithHandlerBlock;
    dispatch_group_t _testSyncWithDataPathAndHandlerBlock;
    
    dispatch_group_t _testSyncChange;
    
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
    
    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
    
    [PubNub connect];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    [PubNub disconnect];
}

#pragma mark - Tests

- (void)testSimpleSync
{
    _testSync = dispatch_group_create();
    
    dispatch_group_enter(_testSync);
    dispatch_group_enter(_testSync);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(simpleSyncNotif:) name:kPNClientDidStartObjectSynchronizationNotification
                                               object:nil];
    
    [PubNub startObjectSynchronization:kTestObject];
    
    STAssertFalse([GCDWrapper isGroup:_testSync
                    timeoutFiredValue:kTestStandardTimeout], @"Simple sync Object - failed.");
    
    _testSync = NULL;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)testSimpleSyncWithObserver
{
    _testSyncWithObserver = dispatch_group_create();
    
    dispatch_group_enter(_testSyncWithObserver);
    
    [PubNub startObjectSynchronization:kTestObject
                              dataPath:kTestPathComplex];
    
    [[PNObservationCenter defaultCenter] addObjectSynchronizationStartObserver:self
                                                                     withBlock:^(PNObject *object, PNError *error) {
                                                                         if (!error) {
                                                                             
                                                                             NSLog(@"Retrieved object: %@", object);
                                                                         }
                                                                         else {
                                                                             
                                                                             NSLog(@"Failed to observe because of error: %@", error);
                                                                             STFail(@"Cannot start observe test data");                                                                         }
                                                                         dispatch_group_leave(_testSyncWithObserver);
      
                                                                     }];
    
    STAssertFalse([GCDWrapper isGroup:_testSyncWithObserver
                    timeoutFiredValue:kTestStandardTimeout], @"Simple sync Object - failed.");
    
    _testSyncWithObserver = NULL;
    [[PNObservationCenter defaultCenter] removeObjectSynchronizationStartObserver:self];
}

- (void)testSimpleSyncWithHandlerBlock
{
    _testSyncWithHandlerBlock = dispatch_group_create();
    
    dispatch_group_enter(_testSyncWithHandlerBlock);
    
    [PubNub startObjectSynchronization:kTestObject
           withCompletionHandlingBlock:^(PNObject *object, PNError *error) {
               
               if (!error) {
                   NSLog(@"Retrieved object: %@", object);
               } else {
                   
                   NSLog(@"Failed to observe because of error: %@", error);
                   STFail(@"Cannot start observe test data");                                                                         }
               dispatch_group_leave(_testSyncWithHandlerBlock);
               
           }];
    
    STAssertFalse([GCDWrapper isGroup:_testSyncWithHandlerBlock
                    timeoutFiredValue:kTestStandardTimeout], @"Simple sync Object - failed.");
    
    _testSyncWithHandlerBlock = NULL;
}

- (void)testSimpleSyncWithDataPathAndHandlerBlock
{
    _testSyncWithDataPathAndHandlerBlock = dispatch_group_create();
    
    dispatch_group_enter(_testSyncWithDataPathAndHandlerBlock);
    
    [PubNub startObjectSynchronization:kTestObject dataPath:kTestPathComplex
           withCompletionHandlingBlock:^(PNObject *object, PNError *error) {
               
               if (!error) {
                   NSLog(@"Retrieved object: %@", object);
               } else {
                   
                   NSLog(@"Failed to observe because of error: %@", error);
                   STFail(@"Cannot start observe test data");                                                                         }
               dispatch_group_leave(_testSyncWithDataPathAndHandlerBlock);
               
           }];
    
    STAssertFalse([GCDWrapper isGroup:_testSyncWithDataPathAndHandlerBlock
                    timeoutFiredValue:kTestStandardTimeout], @"Simple sync Object - failed.");
    
    _testSyncWithDataPathAndHandlerBlock = NULL;
}

/*
 It is cover standard flow when we start
 sync wait for changes and stop sync then.
 */

- (void)testSimpleSyncСhange
{
    __weak PNObject *testedObject = nil;
    
    _testSyncChange = dispatch_group_create();
    
    dispatch_group_enter(_testSyncChange);
    
    [PubNub startObjectSynchronization:kTestObject
           withCompletionHandlingBlock:^(PNObject *object, PNError *error) {
               if (!error) {
                   NSLog(@"Start sync for object: %@", object);
               } else {
                   
                   NSLog(@"Failed to start sync because of error: %@", error);
                   
                   STFail(@"Cannot start observe test data");                                                                         }
               dispatch_group_leave(_testSyncChange);
           }];
    
    STAssertFalse([GCDWrapper isGroup:_testSyncChange
                    timeoutFiredValue:kTestStandardTimeout], @"Simple sync Object - failed.");
    
    _testSyncChange = NULL;
    
    // change value outside of test
    
    _testSyncChange = dispatch_group_create();
    
    dispatch_group_enter(_testSyncChange);
    dispatch_group_enter(_testSyncChange);
    dispatch_group_enter(_testSyncChange);
    
    [[PNObservationCenter defaultCenter] addObjectChangeObserver:self
                                                       withBlock:^(PNObject *object) {
                                                           if ([object.identifier isEqualToString:kTestObject]) {
                                                               dispatch_group_leave(_testSyncChange);
                                                               [[PNObservationCenter defaultCenter] removeObjectChangeObserver:self];
                                                           }
                                                       }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(simpleObjectChangeNotif:)
                                                 name:kPNClientDidReceiveObjectChangesNotification object:nil];
    
    NSLog(@"\n\n\t\t change value of object: %@ from external source.", kTestObject);
    
    STAssertFalse([GCDWrapper isGroup:_testSyncChange
                    timeoutFiredValue:120], @"Simple sync Object - failed.");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    // stop object sync
    dispatch_group_enter(_testSyncChange);
    
    [PubNub stopObjectSynchronization:kTestObject
          withCompletionHandlingBlock:^(PNObject *object, PNError *error) {
              if (error) {
                  STFail(@"Fail to stop sync from object.");
              }
              
              dispatch_group_leave(_testSyncChange);
          }];
    
    STAssertFalse([GCDWrapper isGroup:_testSyncChange
                    timeoutFiredValue:kTestStandardTimeout], @"Simple sync Object - failed.");
}

#pragma mark - PNDelegate

- (void)pubnubClient:(PubNub *)client didStartObjectSynchronization:(PNObject *)object {
    // PubNub client retrieved remote object.
    
    if (_testSync != NULL) {
        dispatch_group_leave(_testSync);
    }
}

- (void)pubnubClient:(PubNub *)client didFailToStartObjectSynchronizationWithError:(PNError *)error {
    
    // PubNub client did fail to retrieve remote object.
    //
    // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
    // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
    // 'error.associatedObject' reference on PNObjectFetchInformation instance for which PubNub client was unable to
    // create local copy.
    
    if (_testSync != NULL) {
        STFail(@"Fail to retrieve simple fetch: %@", [error localizedDescription]);
    }
}

- (void)pubnubClient:(PubNub *)client didReceiveObjectChangeEvent:(PNObject *)
object {
    if ([object.identifier isEqualToString:kTestObject]) {
        dispatch_group_leave(_testSyncChange);
    }
}

#pragma mark - Notifications

- (void)simpleSyncNotif:(NSNotification *)notif {
    if (_testSync != NULL) {
        dispatch_group_leave(_testSync);
    }
}

- (void)simpleObjectChangeNotif:(NSNotification *)notif {
    if (_testSyncChange != NULL) {
        dispatch_group_leave(_testSyncChange);
    }
}

@end
