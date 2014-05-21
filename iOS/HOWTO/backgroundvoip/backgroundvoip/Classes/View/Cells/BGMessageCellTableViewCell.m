//
//  BGMessageCellTableViewCell.m
//  Background Enabled Sample Application
//
//  Created by Sergey Mamontov on 5/18/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import "BGMessageCellTableViewCell.h"


#pragma mark Static

static NSUInteger kBGMaximumNumberOfLines = 10;
static CGFloat kBGMaximumLabelFontSize = 14.0f;
static CGFloat kBGContentVerticalMargin = 5.0f;
static CGFloat kBGMaximumWidth = 260.0f;


#pragma mark - Public interface implementation

@implementation BGMessageCellTableViewCell


#pragma mark - Class methods

+ (CGFloat)heightForMessage:(NSString *)message {
    
    static UIFont *targetCellFont;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        targetCellFont = [UIFont fontWithName:@"HelveticaNeue" size:kBGMaximumLabelFontSize];
    });
    
    return [message sizeWithFont:targetCellFont constrainedToSize:(CGSize){.width = kBGMaximumWidth,
                                                                           .height = MAXFLOAT}
                   lineBreakMode:NSLineBreakByWordWrapping].height + 2.0 * kBGContentVerticalMargin;
}


#pragma mark - Instance methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    // Check whether initialization has been successful or not.
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        
        self.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1.0f];
        self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:kBGMaximumLabelFontSize];
        self.textLabel.highlightedTextColor = self.textLabel.textColor;
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.textLabel.numberOfLines = kBGMaximumNumberOfLines;
        
        self.selectedBackgroundView = [UIView new];
        self.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1.0f];
    }
    
    
    return self;
}

- (void)updateForMessage:(NSString *)message {
    
    self.textLabel.text = message;
}

#pragma mark -


@end
