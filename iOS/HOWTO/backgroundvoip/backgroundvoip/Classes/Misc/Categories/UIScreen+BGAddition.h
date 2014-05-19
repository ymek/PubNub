//
//  UIScreen+BGAddition.h
//  Background Enabled Sample Application
//
//  Created by Sergey Mamontov on 4/17/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import <UIKit/UIKit.h>


#pragma mark Public interface declaration

@interface UIScreen (BGAddition)


#pragma mark - Instance methods

/**
 Method will return application frame basing on current interface orientation,
 
 @return Normalized application frame.
 */
- (CGRect)applicationFrameForCurrentOrientation;

/**
 Convert provided rect from portrait orientation into current orientation.
 
 @param frame
 \b CGRect which represent dimension information for portrait orientation.
 
 @return Normalized frame.
 */
- (CGRect)normalizedForCurrentOrientationFrame:(CGRect)frame;

#pragma mark -


@end
