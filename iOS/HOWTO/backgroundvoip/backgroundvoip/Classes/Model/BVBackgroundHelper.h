//
//  BVBackgroundHelper.h
//  backgroundvoip
//
//  Created by Sergey Mamontov on 4/11/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Structures

typedef enum _BVBackgroundSupportMode {
    
    /**
     Background support mode is unknown or not set ye.
     */
    BVBackgroundSupportUnknownMode,
    
    /**
     Background operation should be supported by enabling GSP radio for persistent operation.
     */
    BVBackgroundSupportGPSMode,
    
    /**
     Background operation should be supported by enabling VoIP socket and it's usage by continuous pinging.
     */
    BVBackgroundSupportVoIPMode
} BVBackgroundSupportMode;


#pragma mark - Public interface declaration

@interface BVBackgroundHelper : NSObject


#pragma mark - Class methods

/**
 Launch helper which will handle application transitions and try to extend background execution time.
 
 @param backgroundSupportMode
 Mode which should be used by helper to keep app running in background and accept data.
 */
+ (void)launchForMode:(BVBackgroundSupportMode)backgroundSupportMode;

#pragma mark -


@end
