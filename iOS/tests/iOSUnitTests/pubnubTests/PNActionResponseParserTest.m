//
//  PNActionResponseParserTest.m
//  pubnub
//
//  Created by Valentin Tuller on 1/23/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PNActionResponseParser.h"
#import "PNResponse.h"
#import "PNStructures.h"

@interface PNActionResponseParser (test)

@property (nonatomic, assign) PNOperationResultEvent actionType;
- (id)initWithResponse:(PNResponse *)response;

@end

@interface PNResponse (test)

@property (nonatomic, strong) id response;

@end


@interface PNActionResponseParserTest : SenTestCase

@end

@implementation PNActionResponseParserTest

-(void)setUp {
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

-(void)tearDown {
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

-(void)testInit {
	PNResponse *response = [[PNResponse alloc] init];
	response.response = @{ @"action" : @"leave" };
	PNActionResponseParser *parser = [[PNActionResponseParser alloc] initWithResponse: response];
	STAssertTrue( parser.actionType == PNOperationResultLeave, @"");

	STAssertTrue( [[parser parsedData] intValue] == PNOperationResultLeave, @"");
}

@end
