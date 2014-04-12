//
//  BVBackgroundHelper.h
//  backgroundvoip
//
//  Created by Sergey Mamontov on 4/11/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Public interface declaration

@interface BVBackgroundHelper : NSObject


#pragma mark - Class methods

/**
 Launch helper which will handle application transitions and try to extend background execution time.
 */
+ (void)launch;

#pragma mark -


@end
