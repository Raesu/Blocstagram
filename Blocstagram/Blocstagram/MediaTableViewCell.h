//
//  MediaTableViewCell.h
//  
//
//  Created by Ryan Summe on 7/9/15.
//
//

#import <UIKit/UIKit.h>

@class Media;

@interface MediaTableViewCell : UITableViewCell

@property (nonatomic, strong) Media *mediaItem;
+ (CGFloat)heightForMediaItem:(Media *)mediaItem width:(CGFloat)width;

@end
