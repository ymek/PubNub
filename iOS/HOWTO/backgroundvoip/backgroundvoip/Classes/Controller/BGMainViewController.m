//
//  BGMainViewController.m
//  Background Enabled Sample Application
//
//  Created by Sergey Mamontov on 4/17/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import "BGMainViewController.h"
#import "BGMessageCellTableViewCell.h"
#import "BGDataManager.h"


#pragma mark Private interface declaration

@interface BGMainViewController () <UITableViewDelegate, UITableViewDelegate>


#pragma mark - Properties

@property (nonatomic, pn_desired_weak) IBOutlet UITableView *messagesList;
@property (nonatomic, strong) NSDictionary *messageCellHeightCacheMap;


#pragma mark - Instance methods

/**
 Prepare view controller after it has been loaded from XIB file.
 */
- (void)prepare;

- (void)prepareData;


#pragma mark - Handler methods

- (void)handleMessageListChangeNotification:(NSNotification *)notification;

#pragma mark -


@end


#pragma mark Public interface implementation

@implementation BGMainViewController


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward method call to the super class.
    [super awakeFromNib];
    
    [self prepare];
}

- (void)prepare {
    
    [self prepareData];
}

- (void)prepareData {
    
    self.messageCellHeightCacheMap = [NSMutableDictionary dictionary];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMessageListChangeNotification:)
                                                 name:kBGMessageListChangeNotification object:nil];
}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kBGMessageListChangeNotification object:nil];
}


#pragma mark - Handler methods

- (void)handleMessageListChangeNotification:(NSNotification *)notification {
    
    NSUInteger messagesCount = [(NSArray *)notification.userInfo count];
    
    if (messagesCount) {
        
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:messagesCount];
        for (int row = 0; row < messagesCount; row++) {
            
            [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:0]];
        }
    
        [self.messagesList insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


#pragma mark - UITableVide delegate / data source methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[BGDataManager sharedInstance] messagesCount];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *message = [[BGDataManager sharedInstance] messageAtIndex:indexPath.row];
    if (![self.messageCellHeightCacheMap valueForKey:message]) {
        
        [self.messageCellHeightCacheMap setValue:@([BGMessageCellTableViewCell heightForMessage:message]) forKey:message];
    }
    
    
    return [[self.messageCellHeightCacheMap valueForKey:message] floatValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"messageCellIdentifier";
    BGMessageCellTableViewCell *cell = (BGMessageCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        
        cell = [[BGMessageCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell updateForMessage:[[BGDataManager sharedInstance] messageAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark -


@end
