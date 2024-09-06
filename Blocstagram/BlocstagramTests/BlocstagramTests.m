//
//  BlocstagramTests.m
//  BlocstagramTests
//
//  Created by Ryan Summe on 7/9/15.
//  Copyright (c) 2015 Ryan Summe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "User.h"
#import "Media.h"

@interface BlocstagramTests : XCTestCase

@end

@implementation BlocstagramTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testThatInitializationWorks {
    NSDictionary *sourceDictionary = @{@"id": @"8675309",
                                       @"username" : @"d'oh",
                                       @"full_name" : @"Homer Simpson",
                                       @"profile_picture" : @"http://www.example.com/example.jpg"};
    User *testUser = [[User alloc] initWithDictionary:sourceDictionary];
    
    XCTAssertEqualObjects(testUser.idNumber, sourceDictionary[@"id"], @"The ID number should be equal");
    XCTAssertEqualObjects(testUser.userName, sourceDictionary[@"username"], @"The username should be equal");
    XCTAssertEqualObjects(testUser.fullName, sourceDictionary[@"full_name"], @"The full name should be equal");
    XCTAssertEqualObjects(testUser.profilePictureURL, [NSURL URLWithString:sourceDictionary[@"profile_picture"]], @"The profile picture should be equal");
}

- (void)testMediaInit {
    NSDictionary *srcDict = @{@"id" : @"4393294",
                              @"user" : @{@"id" : @"7373",
                                          @"username" : @"Avisen",
                                          @"full_name" : @"Bruce Wayne",
                                          @"profile_picture" : @"http://www.example.com/example.jpg"},
                              @"images" : @{@"standard_resolution" : @{@"url" : @"http://www.example.com/example.jpg"}},
                              @"caption" : @{@"text" : @"test"},
                              @"comments" : @{@"data" : @{@"id" : @"74823748",
                                                          @"text" : @"test",
                                                          @"from" : @{@"id" : @"84639",
                                                                      @"username" : @"raesu",
                                                                      @"full_name" : @"Ryan Summe",
                                                                      @"profile_picture" : @"http://www.example.com/example.jpg"}}},
                              @"likes" : @{@"count" : @"544"},
                              @"user_has_liked" : @1};
    
    Media *testMedia = [[Media alloc] initWithDictionary:srcDict];
    
    XCTAssertEqualObjects(testMedia, srcDict, @"Objects should be equal");
}

@end
