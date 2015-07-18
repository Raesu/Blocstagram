//
//  UIImage+ImageUtilities.h
//  Blocstagram
//
//  Created by Ryan Summe on 7/18/15.
//  Copyright (c) 2015 Ryan Summe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageUtilities)

- (UIImage *)imageWithFixedOrientation;
- (UIImage *)imageResizedToMatchAspectRatioOfSize:(CGSize)size;
- (UIImage *)imageCroppedToRect:(CGRect)cropRect;

@end