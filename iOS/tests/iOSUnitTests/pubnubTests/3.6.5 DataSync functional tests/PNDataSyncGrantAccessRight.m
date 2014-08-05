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
        dispatch_group_t _testPAM1;
        dispatch_group_t _testPAM2;
        dispatch_group_t _testPAM3;
        dispatch_group_t _testPAM4;
        dispatch_group_t _testPAM5;
        dispatch_group_t _testPAM6;
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

#pragma mark - Read

- (void)testAccessRightsReadForObject {
    _testPAM1 = dispatch_group_create();
    
    dispatch_group_enter(_testPAM1);
    dispatch_group_enter(_testPAM1);
    dispatch_group_enter(_testPAM1);
    
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
        
        dispatch_group_leave(_testPAM1);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:) name:kPNClientObjectAccessRightsChangeDidCompleteNotification
                                               object:nil];

    
    [PubNub grantReadAccessRightForObject:kTestObject
                                forPeriod:10];
    
    STAssertFalse([GCDWrapper isGroup:_testPAM1
                    timeoutFiredValue:kTestStandardTimeout], @"Timeout Received.");
    
    [[PNObservationCenter defaultCenter] removeObjectAccessRightsObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _testPAM1 = NULL;
}

- (void)testReadAccessRightForObjectsWithCompletionHandlingBlock {
    _testPAM3 = dispatch_group_create();
    
    dispatch_group_enter(_testPAM3);
    dispatch_group_enter(_testPAM3);
    dispatch_group_enter(_testPAM3);
    dispatch_group_enter(_testPAM3);
    
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
        
        dispatch_group_leave(_testPAM3);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:) name:kPNClientObjectAccessRightsChangeDidCompleteNotification
                                               object:nil];
    
    [PubNub grantReadAccessRightForObjects:@[kTestObject, @"ios_test_db_access1", @"ios_test_db_access2"] forPeriod:10 withCompletionHandlingBlock:^(PNObjectAccessRightsCollection *collection, PNError *error) {
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
        
        dispatch_group_leave(_testPAM3);

    }];
    
//    [PubNub grantReadAccessRightForObject:<#(NSString *)#> forPeriod:<#(NSInteger)#> clients:<#(NSArray *)#> withCompletionHandlingBlock:<#^(PNObjectAccessRightsCollection *, PNError *)handlerBlock#>]
    
//    [PubNub grantReadAccessRightForObject:<#(NSString *)#> forPeriod:<#(NSInteger)#> clients:<#(NSArray *)#>]
    
//    [PubNub grantReadAccessRightForObject:<#(NSString *)#> forPeriod:<#(NSInteger)#> client:<#(NSString *)#> withCompletionHandlingBlock:<#^(PNObjectAccessRightsCollection *, PNError *)handlerBlock#>]
    
//    [PubNub grantReadAccessRightForObject:<#(NSString *)#> forPeriod:<#(NSInteger)#> client:<#(NSString *)#>]
    
    STAssertFalse([GCDWrapper isGroup:_testPAM3
                    timeoutFiredValue:kTestStandardTimeout], @"Timeout Received.");
    
    [[PNObservationCenter defaultCenter] removeObjectAccessRightsObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _testPAM3 = NULL;
}

- (void)testReadAccessRightForObjects {
    _testPAM4 = dispatch_group_create();
    
    dispatch_group_enter(_testPAM4);
    dispatch_group_enter(_testPAM4);
    dispatch_group_enter(_testPAM4);
    
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
        
        dispatch_group_leave(_testPAM4);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:) name:kPNClientObjectAccessRightsChangeDidCompleteNotification
                                               object:nil];
    
    [PubNub grantReadAccessRightForObjects:@[kTestObject, @"ios_test_db_access1", @"ios_test_db_access2"] forPeriod:10];
    
    STAssertFalse([GCDWrapper isGroup:_testPAM4
                    timeoutFiredValue:kTestStandardTimeout], @"Timeout Received.");
    
    [[PNObservationCenter defaultCenter] removeObjectAccessRightsObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _testPAM4 = NULL;
}

- (void)testReadAccessRightForObjectsAndClientsWithCompletionBlock {
    _testPAM5 = dispatch_group_create();
    
    dispatch_group_enter(_testPAM5);
    dispatch_group_enter(_testPAM5);
    dispatch_group_enter(_testPAM5);
    dispatch_group_enter(_testPAM5);
    
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
        
        dispatch_group_leave(_testPAM5);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:) name:kPNClientObjectAccessRightsChangeDidCompleteNotification
                                               object:nil];
    
    [PubNub grantReadAccessRightForObject:kTestObject
                                forPeriod:10
                                  clients:@[@"client1", @"client2"]
              withCompletionHandlingBlock:^(PNObjectAccessRightsCollection *collection, PNError *error) {
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
                  
                  dispatch_group_leave(_testPAM5);
              }];
    
    STAssertFalse([GCDWrapper isGroup:_testPAM5
                    timeoutFiredValue:kTestStandardTimeout], @"Timeout Received.");
    
    [[PNObservationCenter defaultCenter] removeObjectAccessRightsObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _testPAM5 = NULL;
}

- (void)testGrantReadAccessRightForObjectWithCompletionHandlerBlock {
    _testPAM6 = dispatch_group_create();
    
    dispatch_group_enter(_testPAM6);
    dispatch_group_enter(_testPAM6);
    dispatch_group_enter(_testPAM6);
    dispatch_group_enter(_testPAM6);
    
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
        
        dispatch_group_leave(_testPAM6);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:) name:kPNClientObjectAccessRightsChangeDidCompleteNotification
                                               object:nil];
    
    [PubNub grantReadAccessRightForObjects:@[kTestObject, @"ios_test_db_access1", @"ios_test_db_access2"] forPeriod:10 withCompletionHandlingBlock:^(PNObjectAccessRightsCollection *collection, PNError *error) {
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
        
        dispatch_group_leave(_testPAM6);
    }];
    
    //    [PubNub grantReadAccessRightForObject:<#(NSString *)#> forPeriod:<#(NSInteger)#> clients:<#(NSArray *)#>]
    //    [PubNub grantReadAccessRightForObject:<#(NSString *)#> forPeriod:<#(NSInteger)#> client:<#(NSString *)#> withCompletionHandlingBlock:<#^(PNObjectAccessRightsCollection *, PNError *)handlerBlock#>]
    //    [PubNub grantReadAccessRightForObject:<#(NSString *)#> forPeriod:<#(NSInteger)#> client:<#(NSString *)#>]
    
    STAssertFalse([GCDWrapper isGroup:_testPAM6
                    timeoutFiredValue:kTestStandardTimeout], @"Timeout Received.");
    
    [[PNObservationCenter defaultCenter] removeObjectAccessRightsObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _testPAM6 = NULL;
}

#pragma mark - Write

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
    if (_testPAM1) {
        dispatch_group_leave(_testPAM1);
    } else if (_testPAM2){
        dispatch_group_leave(_testPAM2);
    } else if (_testPAM3) {
        dispatch_group_leave(_testPAM3);
    } else if (_testPAM4) {
        dispatch_group_leave(_testPAM4);
    } else if (_testPAM5) {
        dispatch_group_leave(_testPAM5);
    } else if (_testPAM6) {
        dispatch_group_leave(_testPAM6);
    }
}

- (void)pubnubClient:(PubNub *)client objectAccessRightsChangeDidFailWithError:(PNError *)error {
    
    // PubNub client did fail to changed access rights for cloud 'object' level.
    //
    // Always check 'error.code' to find out what caused error (check PNErrorCodes header file and use -localizedDescription /
    // -localizedFailureReason and -localizedRecoverySuggestion to get human readable description for error).
    // 'error.associatedObject' contains PNObjectAccessRightOptions instance which describes access level for which change
    // has been requested.
    
    STFail(@"Object right change did fail with error: %@", [error localizedDescription]);
    
    if (_testPAM1) {
        dispatch_group_leave(_testPAM1);
    } else if (_testPAM2){
        dispatch_group_leave(_testPAM2);
    } else if (_testPAM3) {
        dispatch_group_leave(_testPAM3);
    } else if (_testPAM4) {
        dispatch_group_leave(_testPAM4);
    } else if (_testPAM5) {
        dispatch_group_leave(_testPAM5);
    } else if (_testPAM6) {
        dispatch_group_leave(_testPAM6);
    }
}

#pragma mark - Notifications

- (void)receivedNotification:(NSNotification *)notif {
    if (_testPAM1) {
        dispatch_group_leave(_testPAM1);
    } else if (_testPAM2){
        dispatch_group_leave(_testPAM2);
    } else if (_testPAM3) {
        dispatch_group_leave(_testPAM3);
    } else if (_testPAM4) {
        dispatch_group_leave(_testPAM4);
    } else if (_testPAM5) {
        dispatch_group_leave(_testPAM5);
    } else if (_testPAM6) {
        dispatch_group_leave(_testPAM6);
    }
}

@end
