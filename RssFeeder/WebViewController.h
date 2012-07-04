//
//  WebViewController.h
//  RssFeeder
//
//  Created by Vladimir Tsenev on 7/3/12.
//  Copyright (c) 2012 MentorMate. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RSSEntry;

@interface WebViewController : UIViewController

@property (nonatomic, strong) RSSEntry *entry;

@end
