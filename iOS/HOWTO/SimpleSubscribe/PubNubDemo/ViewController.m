//
//  ViewController.m
//  PubNubDemo
//
//  Created by geremy cohen on 3/27/13.
//  Copyright (c) 2013 geremy cohen. All rights reserved.
//

#import "ViewController.h"
#import "PNMessage+Protected.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize textView, config, filterField, originField, currentOrigin;

- (void)applyNewSettings {

    if (![currentOrigin isEqualToString:originField.text]) {
        [PubNub disconnect];
    }

    self.config = [PNConfiguration configurationForOrigin:self.originField.text publishKey:@"demo" subscribeKey:@"demo" secretKey:@"demo"];
    self.config.filter = self.filterField.text;
    [PubNub setConfiguration:self.config];

    if ([[PubNub sharedInstance] isConnected]) {
        [self resetConnection];
        return;
    }

    [PubNub connectWithSuccessBlock:^(NSString *origin) {

                self.currentOrigin = origin;
                PNLog(PNLogGeneralLevel, self, @"{BLOCK} PubNub client connected to: %@", origin);

                // wait 1 second
                int64_t delayInSeconds = 1.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC); dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

                [self resetConnection];


            }); }
            // In case of error you always can pull out error code and identify what happened and what you can do // additional information is stored inside error's localizedDescription, localizedFailureReason and
            // localizedRecoverySuggestion)
                         errorBlock:^(PNError *connectionError) {
                             if (connectionError.code == kPNClientConnectionFailedOnInternetFailureError) {
                                 PNLog(PNLogGeneralLevel, self, @"Connection will be established as soon as internet connection will be restored");
                             }

                             UIAlertView *connectionErrorAlert = [UIAlertView new];
                             connectionErrorAlert.title = [NSString stringWithFormat:@"%@(%@)",
                                                                                     [connectionError localizedDescription],
                                                                                     NSStringFromClass([self class])];
                             connectionErrorAlert.message = [NSString stringWithFormat:@"Reason:\n%@\n\nSuggestion:\n%@",
                                                                                       [connectionError localizedFailureReason],
                                                                                       [connectionError localizedRecoverySuggestion]];
                             [connectionErrorAlert addButtonWithTitle:@"OK"];
                             [connectionErrorAlert show];
                         }];

}

- (void)resetConnection {
    PNChannel *myChannel = [PNChannel channelWithName:@"hello" shouldObservePresence:NO];
    [PubNub unsubscribeFromChannel:myChannel];
    [PubNub subscribeOnChannel:myChannel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [PubNub setClientIdentifier:@"SimpleSubscribe"];

    [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self
                                                         withBlock:^(PNMessage *message) {

                                                             NSString *messageString = @"";
                                                             id messageData = message.message;

                                                             if ([messageData isKindOfClass:[NSDictionary class]]) {

                                                                 messageString = [NSString stringWithFormat:@"tag: %@, message: <%@>",
                                                                                                                      [(NSDictionary *)messageData valueForKey:@"tags"],
                                                                                                                      [(NSDictionary *)messageData valueForKey:@"msg"]];
                                                             } else if ([messageData isKindOfClass:[NSString class]]) {
                                                                 messageString = messageData;
                                                             }

                                                             NSLog(@"Text Length: %i", textView.text.length);

                                                             if (textView.text.length > 150) {
                                                                 [textView setText:@""];
                                                             }

                                                             [textView setText:[messageString stringByAppendingFormat:@"\n%@\n", textView.text]];

                                                         }];

    [self applyNewSettings];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"tag entered %@",self.filterField.text);
    NSLog(@"origin entered %@",self.originField.text);

    self.config.filter = self.filterField.text;
    [self.filterField resignFirstResponder];
    [self applyNewSettings];

    return YES;
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clearAll:(id)sender {
    textView.text = @"";
}


@end
