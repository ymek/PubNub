//
//  BVMainViewController.m
//  backgroundvoip
//
//  Created by Sergey Mamontov on 4/17/14.
//  Copyright (c) 2014 Sergey Mamontov. All rights reserved.
//

#import "BVMainViewController.h"
#import "BVBackgroundHelper.h"
#import "BVButton.h"
#import "PNObservationCenter+Protected.h"


#pragma mark Private interface declaration

@interface BVMainViewController ()


#pragma mark - Properties


#pragma mark - Instance methods

#pragma mark - Handler methods

#pragma mark -


@end


#pragma mark Public interface implementation

@implementation BVMainViewController

NSArray *recipes;


#pragma mark - Instance methods

#pragma mark - Handler methods

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    // Initialize table data
    recipes = [NSArray arrayWithObjects:@"Egg Benedict", @"Mushroom Risotto", @"Full Breakfast", @"Hamburger", @"Ham and Egg Sandwich", @"Creme Brelee", @"White Chocolate Donut", @"Starbucks Coffee", @"Vegetable Curry", @"Instant Noodle with Egg", @"Noodle with BBQ Pork", @"Japanese Noodle with Pork", @"Green Tea", @"Thai Shrimp Cake", @"Angry Birds Cake", @"Ham and Cheese Panini", nil];

    [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self
                                                         withBlock:^(PNMessage *message) {

                                                             NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!! MESSAGE!");

//                                                             NSLog(@"Text Length: %i", textView.text.length);
//
//                                                             if (textView.text.length > 2000) {
//                                                                 [textView setText:@""];
//                                                             }
//
//                                                             [textView setText:[message.message stringByAppendingFormat:@"\n%@\n", textView.text]];

                                                         }];

    [[PNObservationCenter defaultCenter] addClientAsHistoryDownloadObserverWithBlock:^(NSArray *array, PNChannel *channel, PNDate *startDate, PNDate *endDate, PNError *error) {
        NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!! HISTORY!");

    }];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [recipes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }

    cell.textLabel.text = [recipes objectAtIndex:indexPath.row];
    return cell;
}

@end
