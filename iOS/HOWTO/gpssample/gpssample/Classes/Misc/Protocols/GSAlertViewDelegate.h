//
//  GSAlertViewDelegate.h
//  gpssample
//
//  Created by Sergey Mamontov on 2/24/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Class forward

@class GSAlertView;


#pragma mark - Delegate interface declaration

@protocol GSAlertViewDelegate <NSObject>


@required

/**
 If delegate implement this method, it will be notified that alert view is closed.
 
 @param view
 \b GSAlertView instance which called this callback method.
 
 @param buttonIndex
 Index of the button with which user closed alert.
 */
- (void)alertView:(GSAlertView *)view didDismissWithButtonIndex:(NSUInteger)buttonIndex;

#pragma mark -


@end
