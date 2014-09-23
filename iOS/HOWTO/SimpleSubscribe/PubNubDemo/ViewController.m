//
//  ViewController.m
//  PubNubDemo
//
//  Created by geremy cohen on 3/27/13.
//  Copyright (c) 2013 geremy cohen. All rights reserved.
//

#import "ViewController.h"


#pragma mark Private interface declaration

@interface ViewController () <UITextFieldDelegate, UIScrollViewDelegate>


#pragma mark - Properties

@property (nonatomic, weak) IBOutlet UIScrollView *scrollableView;
@property (weak, nonatomic) IBOutlet UITextField *publishMessage;
@property (weak, nonatomic) IBOutlet UITextField *publishFilter;
@property (weak, nonatomic) IBOutlet UITextField *filterField;
@property (weak, nonatomic) IBOutlet UITextField *originField;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (nonatomic, assign) CGRect selectedTextFieldFrame;
@property (nonatomic, strong) PNConfiguration *config;
@property (nonatomic, copy) NSString *currentOrigin;
@property (nonatomic, strong) PNChannel *channel;


#pragma mark - Instance methods

- (void)completeUserInterfaceInitialization;


#pragma mark - Handler methods

- (IBAction)sendMessage:(id)sender;

- (void)handleKeyboardWillShow:(NSNotification *)notification;
- (void)handleKeyboardWillHide:(NSNotification *)notification;


#pragma mark - Misc methods

- (void)configurePubNubClient;
- (void)updatePubNubClientConfiguration;

- (void)subscribeOnNotifications;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation ViewController


#pragma mark - Instance methods

- (void)viewDidLoad {
    
    // Forward method call to the super class
    [super viewDidLoad];
    
    [self completeUserInterfaceInitialization];
    [self subscribeOnNotifications];
    [self configurePubNubClient];
}

- (void)completeUserInterfaceInitialization {
    
    self.scrollableView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height * 1.5f);
}

- (void)resetSubscription {

    self.channel = [PNChannel channelWithName:@"hello" shouldObservePresence:NO];
    [PubNub unsubscribeFromChannel:self.channel];
    [PubNub subscribeOnChannel:self.channel];
}

#pragma mark - Handler methods

- (IBAction)sendMessage:(id)sender {

    NSArray *tagsArray = [self.publishFilter.text componentsSeparatedByString:@","];
    [PubNub sendMessage:@{@"tags":tagsArray,@"msg":self.publishMessage.text} toChannel:self.channel];
}

- (void)handleKeyboardWillShow:(NSNotification *)notification {
    
    // Retrieve keyboard size
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGRect visibleFrame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - keyboardSize.height);
    
    // Checking whether visible frame encloses selected text field frame or not
    if (!CGRectContainsRect(visibleFrame, self.selectedTextFieldFrame)) {
        
        // Calculating on how much we should move text field to make it appear above keyboard
        CGFloat overlappedTextFieldVerticlaPosition = visibleFrame.size.height - (CGRectGetMaxY(self.selectedTextFieldFrame) + 10.0f);
        
        [self.scrollableView setContentOffset:CGPointMake(0.0f, -overlappedTextFieldVerticlaPosition) animated:YES];
    }
    else if (self.scrollableView.contentOffset.y > 0.0f || self.scrollableView.contentOffset.y < 0.0) {
        
        [self.scrollableView setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
    }
}

- (void)handleKeyboardWillHide:(NSNotification *)notification {
    
    [self.scrollableView setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
}


#pragma mark - Misc methods

- (void)configurePubNubClient {

    [PubNub setClientIdentifier:@"SimpleSubscribe"];

    [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self withBlock:^(PNMessage *message) {

        id messageData = message.message;
        NSString *messageString = messageData;

        if ([messageData isKindOfClass:[NSDictionary class]]) {

            // Check whether special payload arrived or not
            if ((NSDictionary *)messageData[@"tags"] && (NSDictionary *)messageData[@"msg"]) {

                messageString = [NSString stringWithFormat:@"tag: %@, message: <%@>",
                                (NSDictionary *)messageData[@"tags"], (NSDictionary *)messageData[@"msg"]];
            }
        }

        // Checking whether there is too much information shown in console output field.
        if (self.textView.text.length > 96) {

            NSLog(@"Text field show too much data (%d). Clearing...", self.textView.text.length);
            [self.textView setText:@""];
        }

        [self.textView setText:[messageString stringByAppendingFormat:@"\n%@\n", self.textView.text]];

    }];

    [self updatePubNubClientConfiguration];
}

- (void)updatePubNubClientConfiguration {

    if (![self.currentOrigin isEqualToString:self.originField.text]) {

        [PubNub disconnect];
    }

    self.config = [PNConfiguration configurationForOrigin:self.originField.text publishKey:@"demo" subscribeKey:@"demo" secretKey:@"demo"];
    self.config.filter = self.filterField.text;
    [PubNub setConfiguration:self.config];

    if ([[PubNub sharedInstance] isConnected]) {

        [self resetSubscription];
    }
    else {

        [PubNub connectWithSuccessBlock:^(NSString *origin) {

                    self.currentOrigin = origin;
                    PNLog(PNLogGeneralLevel, self, @"{BLOCK} PubNub client connected to: %@", origin);

                    // wait 1 second
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

                        [self resetSubscription];
                    });
                }
                // In case of error you always can pull out error code and identify what happened and what you can do
                // additional information is stored inside error's localizedDescription, localizedFailureReason and
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
}

- (void)subscribeOnNotifications {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


#pragma mark - UITextField delegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    self.selectedTextFieldFrame = textField.frame;
    
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    BOOL shouldUpdateConfiguration = NO;
    if ([textField isEqual:self.originField]) {
        
        // Checking whether user changed connection origin
        if (![self.originField.text isEqualToString:self.config.origin]) {
            
            NSLog(@"\n\nCHANGED ORIGIN: %@\n\n", self.originField.text);
            shouldUpdateConfiguration = YES;
        }
    }
    else if ([textField isEqual:self.filterField]) {
        
        // Chechking whether set of subscribe tags changes or not
        if (![self.filterField.text isEqual:self.config.filter]) {
            
            NSLog(@"\n\nCHANGED SUBSCRIBE TAG LIST: %@\n\n",self.filterField.text);
            
            self.config.filter = self.filterField.text;
            shouldUpdateConfiguration = YES;
        }
    }
    else if ([textField isEqual:self.publishMessage]) {
        
        [self sendMessage:textField];
    }
    
    [self.view endEditing:YES];
    
    if (shouldUpdateConfiguration) {
        
        [self updatePubNubClientConfiguration];
    }
    
    return YES;
}

#pragma mark -


@end
