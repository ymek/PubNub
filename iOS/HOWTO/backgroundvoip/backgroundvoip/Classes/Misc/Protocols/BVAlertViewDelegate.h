//
//  BVAlertViewDelegate.h
//  backgroundvoip
//
//  Created by Sergey Mamontov on 4/17/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Class forward

@class BVAlertView;


#pragma mark - Delegate interface declaration

@protocol BVAlertViewDelegate <NSObject>


@required

/**
 If delegate implement this method, it will be notified that alert view is closed.
 
 @param view
 \b PNAlertView instance which called this callback method.
 
 @param buttonIndex
 Index of the button with which user closed alert.
 */
- (void)alertView:(BVAlertView *)view didDismissWithButtonIndex:(NSUInteger)buttonIndex;

#pragma mark -


@end
