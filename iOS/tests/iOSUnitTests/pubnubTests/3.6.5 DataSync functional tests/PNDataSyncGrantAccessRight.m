//
//  PNDataSyncGrantAccessRight.m
//  pubnub
//
//  Created by Vadim Osovets on 8/1/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

static NSString * const kTestObject = @"ios_test_db_access";
static const NSUInteger kTestStandardTimeout = 30;

@interface PNDataSyncGrantAccessRight : SenTestCase

<
PNDelegate
>

@end

@implementation PNDataSyncGrantAccessRight {
        dispatch_group_t _testPAM;
        dispatch_group_t _testPAM2;
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

#pragma mark - Tests

- (void)testAccessRightsReadForObject {
    _testPAM = dispatch_group_create();
    
    dispatch_group_enter(_testPAM);
    dispatch_group_enter(_testPAM);
    dispatch_group_enter(_testPAM);
    
    [[PNObservationCenter defaultCenter] addObjectAccessRightsChangeObserver:self withBlock:^(PNObjectAccessRightsCollection *collection, PNError *error) {
        
        if (error == nil) {
            
            // PubNub client successfully changed access rights for cloud 'object' level.
        }
        else {
            
            // PubNub client did fail to changed access rights for cloud 'object' level.
            //
            // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
            // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
            // 'error.associatedObject' contains PNObjectAccessRightOptions instance which describes access level for which change
            // has been requested.
            STFail(@"Object right change did fail with error: %@", [error localizedDescription]);
        }
        
        dispatch_group_leave(_testPAM);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:) name:kPNClientObjectAccessRightsChangeDidCompleteNotification
                                               object:nil];

    
    [PubNub grantReadAccessRightForObject:kTestObject
                                forPeriod:10];
    
    [[PNObservationCenter defaultCenter] removeObjectAccessRightsObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _testPAM = NULL;
}

- (void)testAccessRightsWriteForObject {
    _testPAM2 = dispatch_group_create();
    
    dispatch_group_enter(_testPAM2);
    dispatch_group_enter(_testPAM2);
    dispatch_group_enter(_testPAM2);
    
    [[PNObservationCenter defaultCenter] addObjectAccessRightsChangeObserver:self withBlock:^(PNObjectAccessRightsCollection *collection, PNError *error) {
        
        if (error == nil) {
            
            // PubNub client successfully changed access rights for cloud 'object' level.
        }
        else {
            
            // PubNub client did fail to changed access rights for cloud 'object' level.
            //
            // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
            // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
            // 'error.associatedObject' contains PNObjectAccessRightOptions instance which describes access level for which change
            // has been requested.
            STFail(@"Object right change did fail with error: %@", [error localizedDescription]);
        }
        
        dispatch_group_leave(_testPAM2);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:) name:kPNClientObjectAccessRightsChangeDidCompleteNotification
                                               object:nil];
    
    
    [PubNub grantWriteAccessRightForObject:kTestObject
                                forPeriod:10];
    
    [[PNObservationCenter defaultCenter] removeObjectAccessRightsObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _testPAM2 = NULL;
}

#pragma mark - PNDelegate

- (void)pubnubClient:(PubNub *)client didChangeObjectAccessRights:(PNObjectAccessRightsCollection *)accessRightsCollection {
    
    // PubNub client successfully changed access rights for cloud 'object' level.
    
    dispatch_group_leave(_testPAM);
}

- (void)pubnubClient:(PubNub *)client objectAccessRightsChangeDidFailWithError:(PNError *)error {
    
    // PubNub client did fail to changed access rights for cloud 'object' level.
    //
    // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
    // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
    // 'error.associatedObject' contains PNObjectAccessRightOptions instance which describes access level for which change
    // has been requested.
    
    STFail(@"Object right change did fail with error: %@", [error localizedDescription]);
    
    dispatch_group_leave(_testPAM);
}

#pragma mark - Notifications

- (void)receivedNotification:(NSNotification *)notif {
    if (_testPAM != NULL) {
        dispatch_group_leave(_testPAM);
    }
}

@end
