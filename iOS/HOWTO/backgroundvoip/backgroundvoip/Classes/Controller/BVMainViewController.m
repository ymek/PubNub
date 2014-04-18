//
//  BVMainViewController.m
//  backgroundvoip
//
//  Created by Sergey Mamontov on 4/17/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import "BVMainViewController.h"
#import "BVBackgroundHelper.h"
#import "BVButton.h"


#pragma mark Private interface declaration

@interface BVMainViewController ()


#pragma mark - Properties

@property (nonatomic, pn_desired_weak) IBOutlet BVButton *gpsButton;
@property (nonatomic, pn_desired_weak) IBOutlet BVButton *voipButton;


#pragma mark - Instance methods

#pragma mark - Handler methods

- (IBAction)handleButtonTap:(id)sender;

#pragma mark -


@end


#pragma mark Public interface implementation

@implementation BVMainViewController


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward method call to the super class
    [super awakeFromNib];
}


#pragma mark - Handler methods

- (IBAction)handleButtonTap:(id)sender {
    
    if ([sender isEqual:self.gpsButton]) {
        
        NSLog(@"USE GPS");
        self.voipButton.enabled = YES;
        ((BVButton *)sender).enabled = NO;
        [BVBackgroundHelper launchForMode:BVBackgroundSupportGPSMode];
    }
    else {
        
        NSLog(@"USE VoIP");
        self.gpsButton.enabled = YES;
        ((BVButton *)sender).enabled = NO;
        [BVBackgroundHelper launchForMode:BVBackgroundSupportVoIPMode];
    }
}


#pragma mark -


@end
