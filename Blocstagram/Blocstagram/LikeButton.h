//
//  LikeButton.h
//  Blocstagram
//
//  Created by Ryan Summe on 7/17/15.
//  Copyright (c) 2015 Ryan Summe. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LikeState) {
    LikeStateNotLiked             = 0,
    LikeStateLiking               = 1,
    LikeStateLiked                = 2,
    LikeStateUnliking             = 3
};

@interface LikeButton : UIButton

@property (nonatomic, assign) LikeState likeButtonState;

@end
