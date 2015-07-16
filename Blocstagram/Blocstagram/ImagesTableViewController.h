//
//  ImagesTableViewController.h
//  Blocstagram
//
//  Created by Ryan Summe on 7/9/15.
//  Copyright (c) 2015 Ryan Summe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Media.h"
#import "Comment.h"
#import "DataSource.h"
#import "MediaTableViewCell.h"

@interface ImagesTableViewController : UITableViewController
- (void)cell:(MediaTableViewCell *)cell didLongPressImageView:(UIImageView *)imageView;
@end
