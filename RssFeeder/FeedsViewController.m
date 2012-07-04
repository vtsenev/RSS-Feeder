//
//  FeedsViewController.m
//  RssFeeder
//
//  Created by Vladimir Tsenev on 7/3/12.
//  Copyright (c) 2012 MentorMate. All rights reserved.
//

#import "FeedsViewController.h"
#import "RSSEntry.h"
#import "ASIHTTPRequest.h"
#import "GDataXMLNode.h"
#import "GDataXMLElement-Extras.h"
#import "NSDate+InternetDateTime.h"
#import "NSArray+Extras.h"
#import "WebViewController.h"

@interface FeedsViewController ()

@property (nonatomic, strong) NSMutableArray *allEntries;

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSArray *feeds;
@property (nonatomic, strong) WebViewController *webViewController;

- (void)refresh;
- (void)parseFeed:(GDataXMLElement *)rootElement entries:(NSMutableArray *)entries;
- (void)parseRss:(GDataXMLElement *)rootElement entries:(NSMutableArray *)entries;
- (void)parseAtom:(GDataXMLElement *)rootElement entries:(NSMutableArray *)entries;

@end

@implementation FeedsViewController
@synthesize allEntries;
@synthesize queue;
@synthesize feeds;
@synthesize webViewController;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"RSS Feeder";
    self.allEntries = [NSMutableArray array];

    self.queue = [[NSOperationQueue alloc] init];
    self.feeds = [NSArray arrayWithObjects:@"http://feeds.feedburner.com/RayWenderlich",
                  @"http://feeds.feedburner.com/vmwstudios",
                  @"http://idtypealittlefaster.blogspot.com/feeds/posts/default",
                  @"http://www.71squared.com/feed/",
                  @"http://cocoawithlove.com/feeds/posts/default",
                  @"http://feeds2.feedburner.com/brandontreb",
                  @"http://feeds.feedburner.com/CoryWilesBlog",
                  @"http://geekanddad.wordpress.com/feed/",
                  @"http://iphonedevelopment.blogspot.com/feeds/posts/default",
                  @"http://karnakgames.com/wp/feed/",
                  @"http://kwigbo.com/rss",
                  @"http://shawnsbits.com/feed/",
                  @"http://pocketcyclone.com/feed/",
                  @"http://www.alexcurylo.com/blog/feed/",
                  @"http://feeds.feedburner.com/maniacdev",
                  @"http://feeds.feedburner.com/macindie",
                  @"http://mentormate.com/feed",
                  nil];
    [self refresh];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [self setAllEntries:nil];
    [self setWebViewController:nil];
    [self setQueue:nil];
    [self setFeeds:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.allEntries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    RSSEntry *entry = [self.allEntries objectAtIndex:[indexPath row]];
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *articleDateString = [dateFormatter stringFromDate:entry.articleDate];
    
    [cell.textLabel setText:entry.articleTitle];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", articleDateString, entry.blogTitle];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.allEntries removeObjectAtIndex:[indexPath row]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.webViewController == nil) {
        self.webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:[NSBundle mainBundle]];
    }
    
    RSSEntry *entry = [self.allEntries objectAtIndex:indexPath.row];
    self.webViewController.entry = entry;
    [self.navigationController pushViewController:self.webViewController animated:YES];
}

# pragma mark - ASIHTTPRequest delegate methods

- (void)requestFinished:(ASIHTTPRequest *)request {
    [self.queue addOperationWithBlock:^{
        NSError *error;
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:[request responseData]
                                                               options:0 error:&error];
        if (doc == nil) {
            NSLog(@"Failed to parse %@", request.url);
        } else {
            NSMutableArray *entries = [NSMutableArray array];
            [self parseFeed:doc.rootElement entries:entries];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                for (RSSEntry *entry in entries) {
                    int insertIdx = [self.allEntries indexForInsertingObject:entry sortedUsingBlock:^(id a, id b) {
                        RSSEntry *entry1 = (RSSEntry *) a;
                        RSSEntry *entry2 = (RSSEntry *) b;
                        return [entry1.articleDate compare:entry2.articleDate];
                    }];
                    [self.allEntries insertObject:entry atIndex:insertIdx];
                    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:insertIdx inSection:0]]
                                          withRowAnimation:UITableViewRowAnimationRight];
                }
            }];
        }        
    }];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"Error: %@", error);
}

# pragma mark - private methods

- (void)refresh {
    for (NSString *feed in self.feeds) {
        NSURL *url = [NSURL URLWithString:feed];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [request setDelegate:self];
        [self.queue addOperation:request];
    }
}

- (void)parseFeed:(GDataXMLElement *)rootElement entries:(NSMutableArray *)entries {
    if ([rootElement.name compare:@"rss"] == NSOrderedSame) {
        [self parseRss:rootElement entries:entries];
    } else if ([rootElement.name compare:@"feed"] == NSOrderedSame) {
        [self parseAtom:rootElement entries:entries];
    } else {
        NSLog(@"Unsupported root element: %@", rootElement.name);
    }
}

- (void)parseRss:(GDataXMLElement *)rootElement entries:(NSMutableArray *)entries {
    NSArray *channels = [rootElement elementsForName:@"channel"];
    for (GDataXMLElement *channel in channels) {
        
        NSString *blogTitle = [channel valueForChild:@"title"];
        
        NSArray *items = [channel elementsForName:@"item"];
        for (GDataXMLElement *item in items) {
            
            NSString *articleTitle = [item valueForChild:@"title"];
            NSString *articleUrl = [item valueForChild:@"link"];
            NSString *articleDateString = [item valueForChild:@"pubDate"];
            NSDate *articleDate = [NSDate dateFromInternetDateTimeString:articleDateString formatHint:DateFormatHintRFC822];
            
            RSSEntry *entry = [[RSSEntry alloc] initWithBlogTitle:blogTitle
                                                      articleTitle:articleTitle
                                                        articleUrl:articleUrl
                                                       articleDate:articleDate];
            [entries addObject:entry];
        }
    }
}

- (void)parseAtom:(GDataXMLElement *)rootElement entries:(NSMutableArray *)entries {
    NSString *blogTitle = [rootElement valueForChild:@"title"];
    
    NSArray *items = [rootElement elementsForName:@"entry"];
    for (GDataXMLElement *item in items) {
        
        NSString *articleTitle = [item valueForChild:@"title"];
        NSString *articleUrl = nil;
        NSArray *links = [item elementsForName:@"link"];
        for(GDataXMLElement *link in links) {
            NSString *rel = [[link attributeForName:@"rel"] stringValue];
            NSString *type = [[link attributeForName:@"type"] stringValue];
            if ([rel compare:@"alternate"] == NSOrderedSame &&
                [type compare:@"text/html"] == NSOrderedSame) {
                articleUrl = [[link attributeForName:@"href"] stringValue];
            }
        }
        
        NSString *articleDateString = [item valueForChild:@"updated"];
        NSDate *articleDate = [NSDate dateFromInternetDateTimeString:articleDateString formatHint:DateFormatHintRFC3339];
        RSSEntry *entry = [[RSSEntry alloc] initWithBlogTitle:blogTitle
                                                  articleTitle:articleTitle
                                                    articleUrl:articleUrl
                                                   articleDate:articleDate];
        [entries addObject:entry];
    }
}

@end
