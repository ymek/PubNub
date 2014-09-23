//
//  ViewController.h
//  PubNubDemo
//
//  Created by geremy cohen on 3/27/13.
//  Copyright (c) 2013 geremy cohen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
- (IBAction)clearAll:(id)sender;
@property(nonatomic, strong) PNConfiguration *config;
@property (weak, nonatomic) IBOutlet UITextField *filterField;
@property (weak, nonatomic) IBOutlet UITextField *originField;

@property(nonatomic, weak) NSString *currentOrigin;
@end
