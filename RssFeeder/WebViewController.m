//
//  WebViewController.m
//  RssFeeder
//
//  Created by Vladimir Tsenev on 7/3/12.
//  Copyright (c) 2012 MentorMate. All rights reserved.
//

#import "WebViewController.h"
#import "RSSEntry.h"

@interface WebViewController ()

@property (nonatomic, strong) IBOutlet UIWebView *webView;

@end

@implementation WebViewController
@synthesize webView;
@synthesize entry;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [self setWebView:nil];
    [self setEntry:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    NSURL *url = [NSURL URLWithString:self.entry.articleUrl];
    [self setTitle:self.entry.articleTitle];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
