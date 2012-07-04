//
//  RSSEntry.h
//  RssFeeder
//
//  Created by Vladimir Tsenev on 7/3/12.
//  Copyright (c) 2012 MentorMate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSSEntry : NSObject

@property (nonatomic, copy) NSString *blogTitle;
@property (nonatomic, copy) NSString *articleTitle;
@property (nonatomic, copy) NSString *articleUrl;
@property (nonatomic, copy) NSDate *articleDate;

- (id)initWithBlogTitle:(NSString*)aBlogTitle articleTitle:(NSString*)anArticleTitle articleUrl:(NSString*)anArticleUrl articleDate:(NSDate*)anArticleDate;

@end
