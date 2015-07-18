//
//  CameraToolbar.h
//  Blocstagram
//
//  Created by Ryan Summe on 7/17/15.
//  Copyright (c) 2015 Ryan Summe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CameraToolbar;

@protocol CameraToolbarDelegate <NSObject>

- (void)leftButtonPressedOnToolbar:(CameraToolbar *)toolbar;
- (void)rightButtonPressedOnToolbar:(CameraToolbar *)toolbar;
- (void)cameraButtonPressedOnToolbar:(CameraToolbar *)toolbar;

@end

@interface CameraToolbar : UIView

@property (nonatomic, weak) NSObject <CameraToolbarDelegate> *delegate;

- (instancetype) initWithImageNames:(NSArray *)imageNames;

@end
