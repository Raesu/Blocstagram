//
//  DataSource.h
//  Blocstagram
//
//  Created by Ryan Summe on 7/9/15.
//  Copyright (c) 2015 Ryan Summe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataSource : NSObject

@property(nonatomic, strong, readonly) NSArray *mediaItems;
+ (instancetype) sharedInstance;
@end
