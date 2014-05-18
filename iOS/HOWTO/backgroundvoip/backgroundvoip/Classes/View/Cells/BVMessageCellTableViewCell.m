//
//  BVMessageCellTableViewCell.m
//  backgroundvoip
//
//  Created by Sergey Mamontov on 5/18/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import "BVMessageCellTableViewCell.h"


#pragma mark Static

static NSUInteger kBVMaximumNumberOfLines = 10;
static CGFloat kBVMaximumLabelFontSize = 14.0f;
static CGFloat kBVContentVerticalMargin = 5.0f;
static CGFloat kBVMaximumWidth = 260.0f;


#pragma mark - Public interface implementation

@implementation BVMessageCellTableViewCell


#pragma mark - Class methods

+ (CGFloat)heightForMessage:(NSString *)message {
    
    static UIFont *targetCellFont;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        targetCellFont = [UIFont fontWithName:@"HelveticaNeue" size:kBVMaximumLabelFontSize];
    });
    
    return [message sizeWithFont:targetCellFont constrainedToSize:(CGSize){.width = kBVMaximumWidth,
                                                                           .height = MAXFLOAT}
                   lineBreakMode:NSLineBreakByWordWrapping].height + 2.0 * kBVContentVerticalMargin;
}


#pragma mark - Instance methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    // Check whether initialization has been successful or not.
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        
        self.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1.0f];
        self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:kBVMaximumLabelFontSize];
        self.textLabel.highlightedTextColor = self.textLabel.textColor;
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.textLabel.numberOfLines = kBVMaximumNumberOfLines;
        
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
