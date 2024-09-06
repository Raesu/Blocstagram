//
//  ImageLibraryViewController.h
//  Blocstagram
//
//  Created by Ryan Summe on 7/20/15.
//  Copyright (c) 2015 Ryan Summe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageLibraryViewController;

@protocol ImageLibraryViewControllerDelegate <NSObject>

- (void)imageLibraryViewController:(ImageLibraryViewController *)imageLibraryViewController didCompleteWithImage:(UIImage *)image;

@end

@interface ImageLibraryViewController : UICollectionViewController

@property (nonatomic, weak) NSObject <ImageLibraryViewControllerDelegate> *delegate;

@end
