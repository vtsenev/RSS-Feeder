//
//  NSArray+Extras.h
//  RssFeeder
//
//  Created by Vladimir Tsenev on 7/3/12.
//  Copyright (c) 2012 MentorMate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Extras)

typedef NSInteger (^compareBlock)(id a, id b);

-(NSUInteger)indexForInsertingObject:(id)anObject sortedUsingBlock:(compareBlock)compare;

@end
