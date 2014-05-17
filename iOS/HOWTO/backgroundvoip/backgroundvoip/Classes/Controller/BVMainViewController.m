//
//  BVMainViewController.m
//  backgroundvoip
//
//  Created by Sergey Mamontov on 4/17/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import "BVMainViewController.h"
#import "BVBackgroundHelper.h"
#import "PNObservationCenter+Protected.h"
#import "BVAlertView.h"
#import "PNMessage+Protected.h"

#pragma mark Private interface declaration

@interface BVMainViewController ()


#pragma mark - Properties


#pragma mark - Instance methods

#pragma mark - Handler methods

#pragma mark -


@end


#pragma mark Public interface implementation

@implementation BVMainViewController

NSMutableArray *pnMessages;


#pragma mark - Instance methods

#pragma mark - Handler methods

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    // Initialize table data
    pnMessages = [NSMutableArray arrayWithObjects:nil];


    [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self
                                                         withBlock:^(PNMessage *message) {

                 [pnMessages addObject:[NSString stringWithFormat:@"%@: %@", [message.message objectForKey:@"timestamp"], [message.message objectForKey:@"data"]]];

                                                             [self reloadAndReverse];


                                                         }];

    [self preparePubNubClient];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [pnMessages count];
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];


    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }

    cell.textLabel.text = [pnMessages objectAtIndex:indexPath.row];
    cell.textLabel.font = [ UIFont fontWithName: @"Arial" size: 8.0 ];

    return cell;
}





- (void)preparePubNubClient {

    __block __pn_desired_weak __typeof (self) weakSelf = self;
    BVAlertView *progressAlertView = [BVAlertView viewForProcessProgress];

    [progressAlertView showInView:self.window.rootViewController.view];

    // Setup with PAM keys, UUID, channel, and authToken
    // In production, these values should be defined through a formal key/credentials exchange

    PNConfiguration *myConfig = [PNConfiguration configurationWithPublishKey:@"pam" subscribeKey:@"pam" secretKey:nil];
    myConfig.authorizationKey = @"iOS-authToken";

    [PubNub setConfiguration:myConfig];
    [PubNub setClientIdentifier:@"IOS-user9"];

    PNChannel *privateChannel = [PNChannel channelWithName:@"iOS-1"];
    PNChannel *publicChannel = [PNChannel channelWithName:@"public"];

    NSArray *allChannels = @[privateChannel, publicChannel];

    [BVBackgroundHelper prepareWithInitializationCompleteHandler:^(void (^completionBlock)(void)) {

        // Pull last 10 messages

        [PubNub requestHistoryForChannel:publicChannel
                                    from:nil
                                      to:nil
                                   limit:3
                     withCompletionBlock:^(NSArray *messagesArray, PNChannel *channel, PNDate *startDate, PNDate *endDate, PNError *error) {

                         for (PNMessage *message in messagesArray) {

                             [pnMessages addObject:[NSString stringWithFormat:@"%@: %@", [message.message objectForKey:@"timestamp"], [message.message objectForKey:@"data"]]];
                         }


                         [self reloadAndReverse];

                         [PubNub subscribeOnChannels:allChannels
                         withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *array, PNError *error) {

                             [progressAlertView dismissWithAnimation:YES];


                             PNLog(PNLogGeneralLevel, weakSelf, @"{INFO} User's configuration code execution completed.");

                             // Finalization block is required to change background support mode.
                             completionBlock();
                         }];

                     }];

    }
                                        andReinitializationBlock:^{

                                            PNLog(PNLogGeneralLevel, weakSelf, @"{INFO} Reinitialize block called.");

                                            [PubNub disconnect];
                                            [weakSelf preparePubNubClient];
                                        }];
    [BVBackgroundHelper connectWithSuccessBlock:^(NSString *origin) {

        PNLog(PNLogGeneralLevel, self, @"{INFO} Connected to %@", origin);


    }                                errorBlock:^(PNError *connectionError) {

        if (connectionError) {

            PNLog(PNLogGeneralLevel, self, @"{ERROR} Failed to connect because of error: %@", connectionError);
        }
    }];
}

- (void)reloadAndReverse {
    pnMessages = [[pnMessages reverseObjectEnumerator] allObjects];
    [_myTableView reloadData];
}

@end
