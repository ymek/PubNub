//
//  BGPopoverView.h
//  Background Enabled Sample Application
//
//  Created by Sergey Mamontov on 4/17/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BGShadowEnableView.h"


#pragma mark Public interface declaration

@interface BGPopoverView : BGShadowEnableView


#pragma mark - Properties

/**
 This property allow to specify whether background elements should be disabled when this popover view appear or not.
 */
@property (nonatomic, assign, getter = shouldDisableBackgroundElementsOnAppear) BOOL disableBackgroundElementsOnAppear;

/**
 This property allow to specify whether background should be dimmed or not (work only if \c disableBackgroundElementsOnAppear
 set to \c YES).
 */
@property (nonatomic, assign, getter = shouldDimmBackgroundOnAppear) BOOL dimmBackgroundOnAppear;

#pragma mark -


@end
