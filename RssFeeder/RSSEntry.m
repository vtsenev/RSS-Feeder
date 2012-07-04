//
//  RSSEntry.m
//  RssFeeder
//
//  Created by Vladimir Tsenev on 7/3/12.
//  Copyright (c) 2012 MentorMate. All rights reserved.
//

#import "RSSEntry.h"

@implementation RSSEntry

@synthesize blogTitle;
@synthesize articleTitle;
@synthesize articleUrl;
@synthesize articleDate;

- (id)initWithBlogTitle:(NSString *)aBlogTitle articleTitle:(NSString *)anArticleTitle articleUrl:(NSString *)anArticleUrl articleDate:(NSDate *)anArticleDate {
    if ((self = [super init])) {
        self.blogTitle = aBlogTitle;
        self.articleTitle = anArticleTitle;
        self.articleUrl = anArticleUrl;
        self.articleDate = anArticleDate;
    }
    return self;
}

@end
