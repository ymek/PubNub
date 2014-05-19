//
//  UIScreen+BGAddition.m
//  Background Enabled Sample Application
//
//  Created by Sergey Mamontov on 4/17/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import "UIScreen+BGAddition.h"


#pragma mark Public interface implementation

@implementation UIScreen (BGAddition)


#pragma mark - Instance methods

- (CGRect)applicationFrameForCurrentOrientation {
    
    CGRect frame = [self applicationFrame];
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        
        frame = (CGRect){(CGPoint){.x = frame.origin.y, .y = frame.origin.x},
            (CGSize){.width = frame.size.height, .height = frame.size.width}};
        
        if (orientation == UIInterfaceOrientationLandscapeRight && frame.origin.y == 0.0f) {
            
            frame.origin.y = [[UIApplication sharedApplication] statusBarFrame].size.width;
        }
    }
    
    
    return frame;
}

- (CGRect)normalizedForCurrentOrientationFrame:(CGRect)frame {
    
    CGRect targetFrame = frame;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        
        targetFrame.size = (CGSize){.width = frame.size.height, .height = frame.size.width};
        if (orientation == UIInterfaceOrientationLandscapeRight && frame.origin.y == 0.0f) {
            
            if (frame.origin.x == 0.0f) {
                
                CGRect applicationFrame = [self applicationFrameForCurrentOrientation];
                targetFrame.origin = (CGPoint){.y = (applicationFrame.origin.y + applicationFrame.size.height - targetFrame.size.height)};
            }
            else {
                
                targetFrame.origin = (CGPoint){.x = frame.origin.y, .y = frame.origin.x};
            }
        }
        else {
            
            targetFrame.origin = (CGPoint){.x = frame.origin.y, .y = frame.origin.x};
        }
    }
    
    
    return targetFrame;
}

#pragma mark -


@end
