//
//  NSArray+Extras.m
//  RssFeeder
//
//  Created by Vladimir Tsenev on 7/3/12.
//  Copyright (c) 2012 MentorMate. All rights reserved.
//

#import "NSArray+Extras.h"

@implementation NSArray (Extras)

-(NSUInteger)indexForInsertingObject:(id)anObject sortedUsingBlock:(compareBlock)compare {
    NSUInteger index = 0;
    NSUInteger topIndex = [self count];
    while (index < topIndex) {
        NSUInteger midIndex = (index + topIndex) / 2;
        id testObject = [self objectAtIndex:midIndex];
        if (compare(anObject, testObject) < 0) {
            index = midIndex + 1;
        } else {
            topIndex = midIndex;
        }
    }
    return index;
}

@end
