//
//  BGShadowEnableView.h
//  Background Enabled Sample Application
//
//  Created by Sergey Mamontov on 4/17/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import <UIKit/UIKit.h>


#pragma mark Public interface declaration

@interface BGShadowEnableView : UIView


#pragma mark - Properties

/**
 Specify radius for the view's corners.
 */
@property (nonatomic, strong) NSNumber *cornerRadius;

/**
 Stores corner radius value for upper left and right corners.
 
 @note This value will be discarded if \c cornerRadius specified.
 */
@property (nonatomic, strong) NSNumber *topCornerRadius;

/**
 Stores corner radius value for bottom left and right corners.
 
 @note This value will be discarded if \c cornerRadius specified.
 */
@property (nonatomic, strong) NSNumber *bottomCornerRadius;

/**
 Specify color of the border around view.
 */
@property (nonatomic, strong) UIColor *borderColor;

/**
 Specify shadow size (by default it will be set to 5)
 */
@property (nonatomic, strong) NSNumber *shadowSize;

/**
 Specify shadow offset (by default it will be set to {0.0f, 0.0f})
 */
@property (nonatomic, assign) CGSize shadowOffest;


#pragma mark - Instance methods

- (void)updateShadow;

#pragma mark -


@end