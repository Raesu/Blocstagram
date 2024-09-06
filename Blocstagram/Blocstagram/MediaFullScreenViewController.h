//
//  MediaFullScreenViewController.h
//  Blocstagram
//
//  Created by Ryan Summe on 7/15/15.
//  Copyright (c) 2015 Ryan Summe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImagesTableViewController.h"
#import "MediaTableViewCell.h"

@class Media;

@interface MediaFullScreenViewController : UIViewController

@property (nonatomic, strong) Media *media;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) ImagesTableViewController *imagesVC;
@property (nonatomic, strong) MediaTableViewCell *cell;

- (instancetype)initWithMedia:(Media *)media;
- (void)centerScrollView;
- (void)recalculateZoomScale;

@end
