//
//  GSViewController.m
//  gpssample
//
//  Created by Sergey Mamontov on 5/24/14.
//  Copyright (c) 2014 PubNub. All rights reserved.
//

#import "GSViewController.h"
#import "GSStateManager.h"
#import "GSConsoleView.h"
#import "GSAlertView.h"


#pragma mark Private interface declaration

@interface GSViewController ()


#pragma mark - Properties

@property (nonatomic, pn_desired_weak) IBOutlet UIView *contentHolderView;
@property (nonatomic, pn_desired_weak) IBOutlet GSConsoleView *console;
@property (nonatomic, pn_desired_weak) IBOutlet UILabel *channelName;

@property (nonatomic, strong) GSAlertView *progressView;


#pragma mark - Instance methods

/**
 Complete \b PubNub client initialization with required configuration, delegate and observations.
 */
- (void)initializePubNubClient;


#pragma mark - Handler methods

- (IBAction)handleClearButtonTap:(id)sender;
- (void)handleWillConnect:(NSNotification *)notification;
- (void)handleDidConnect:(NSNotification *)notification;
- (void)handleConnectionDidFail:(NSNotification *)notification;


#pragma mark - Misc methods

- (void)startObservation;
- (void)stopObservation;

#pragma mark -


@end


#pragma mark - Public interface declaration

@implementation GSViewController


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward method call to the super class.
    [super awakeFromNib];
    
    [self startObservation];
    [self initializePubNubClient];
}

- (void)viewWillAppear:(BOOL)animated {
    
    // Forward method call to the super class.
    [super viewWillAppear:animated];
    
    
    if ([GSStateManager isConnecting]) {
        
        [self handleWillConnect:nil];
    }
}

- (void)initializePubNubClient {
    
    self.channelName.text = @"- Unknown -";
    [GSStateManager connect];
}


#pragma mark - Handler methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([keyPath isEqualToString:@"messages"]){
        
        [self.console setOutputTo:[change valueForKey:NSKeyValueChangeNewKey]];
        
        CGRect targetRect = self.console.bounds;
        targetRect.origin.y = self.console.contentSize.height - targetRect.size.height;
        if (targetRect.size.height < self.console.contentSize.height) {
            
            [self.console flashScrollIndicators];
        }
        
        [self.console scrollRectToVisible:targetRect animated:YES];
    }
}

- (IBAction)handleClearButtonTap:(id)sender {
    
    [GSStateManager clearMessagesLog];
}

- (void)handleWillConnect:(NSNotification *)notification {
    
    self.contentHolderView.hidden = YES;
    if (self.progressView) {
        
        [self.progressView dismissWithAnimation:YES];
        self.progressView = nil;
    }
    
    self.progressView = [GSAlertView viewForProcessProgress];
    [self.progressView showInView:self.view];
}

- (void)handleDidConnect:(NSNotification *)notification {
    
    self.contentHolderView.hidden = NO;
    if (self.progressView) {
        
        [self.progressView dismissWithAnimation:YES];
        self.progressView = nil;
    }
    
    self.channelName.text = ((PNChannel *)notification.userInfo).name;
}

- (void)handleConnectionDidFail:(NSNotification *)notification {
    
    if (self.progressView) {
        
        [self.progressView dismissWithAnimation:YES];
        self.progressView = nil;
    }
    
    PNError *error = (PNError *)notification.userInfo;
    GSAlertView *view = [GSAlertView viewWithTitle:@"Error" type:GSAlertWarning shortMessage:@"Connection error"
                                   detailedMessage:error.localizedFailureReason cancelButtonTitle:nil
                                 otherButtonTitles:nil andEventHandlingBlock:NULL];
    [view showInView:self.view];
}


#pragma mark - Misc methods

- (void)startObservation {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWillConnect:)
                                                 name:kVSStateManagerWillConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidConnect:)
                                                 name:kVSStateManagerDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleConnectionDidFail:)
                                                 name:kVSStateManagerConnectionDidFailNotification object:nil];
    [[GSStateManager sharedInstance] addObserver:self forKeyPath:@"messages" options:NSKeyValueObservingOptionNew
                                         context:nil];
}

- (void)stopObservation {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kVSStateManagerWillConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kVSStateManagerDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kVSStateManagerConnectionDidFailNotification object:nil];
    [[GSStateManager sharedInstance] removeObserver:self forKeyPath:@"messages"];
}

- (void)dealloc {
    
    [self stopObservation];
}

#pragma mark -

@end
