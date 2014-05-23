//
//  VSAlertViewDelegate.h
//  voipsample
//
//  Created by Sergey Mamontov on 2/24/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Class forward

@class VSAlertView;


#pragma mark - Delegate interface declaration

@protocol VSAlertViewDelegate <NSObject>


@required

/**
 If delegate implement this method, it will be notified that alert view is closed.
 
 @param view
 \b VSAlertView instance which called this callback method.
 
 @param buttonIndex
 Index of the button with which user closed alert.
 */
- (void)alertView:(VSAlertView *)view didDismissWithButtonIndex:(NSUInteger)buttonIndex;

#pragma mark -


@end
