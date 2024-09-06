//
//  CropImageViewController.h
//  Blocstagram
//
//  Created by Ryan Summe on 7/20/15.
//  Copyright (c) 2015 Ryan Summe. All rights reserved.
//

#import "MediaFullScreenViewController.h"

@class CropImageViewController;

@protocol CropImageViewControllerDelegate <NSObject>

- (void)cropControllerFinishedWithImage:(UIImage *)croppedImage;

@end

@interface CropImageViewController : MediaFullScreenViewController

- (instancetype)initWithImage:(UIImage *)sourceImage;
@property (nonatomic, weak) NSObject <CropImageViewControllerDelegate> *delegate;

@end
