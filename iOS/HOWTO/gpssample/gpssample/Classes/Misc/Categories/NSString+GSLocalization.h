//
//  NSString+GSLocalization.h
//  gpssample
//
//  Created by Sergey Mamontov on 3/30/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Public interface declaration

@interface NSString (GSLocalization)


#pragma mark - Instance methods

/**
 Search for localization for receiver.
 
 @return Localized string from Localizable.strings file or receiver itself.
 */
- (NSString *)localized;

#pragma mark -


@end
