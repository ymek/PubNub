//
//  BGMessageCellTableViewCell.h
//  Background Enabled Sample Application
//
//  Created by Sergey Mamontov on 5/18/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import <UIKit/UIKit.h>


#pragma mark Public interface declaration

@interface BGMessageCellTableViewCell : UITableViewCell


#pragma mark - Class methods

/**
 Fetch calculated cell height which is able to show whole message which should be shown.
 
 @param message
 \b NSString instance for which target cell height should be calculated.
 
 @return Final height for the cell.
 */
+ (CGFloat)heightForMessage:(NSString *)message;


#pragma mark - Instance methods

/**
 Updating cell content to new one which is provided from outside by data provider.
 
 @param messages
 \b NSString instance which should be shown in cell.
 */
- (void)updateForMessage:(NSString *)message;

#pragma mark -


@end
