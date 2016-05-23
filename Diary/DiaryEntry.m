//
//  DiaryEntry.m
//  Diary
//
//  Created by Ethan Neff on 6/9/14.
//  Copyright (c) 2014 Ethan Neff. All rights reserved.
//

#import "DiaryEntry.h"


@implementation DiaryEntry

@dynamic date;  //instead of synthesized b/c will add getters and setters at runtime
@dynamic body;
@dynamic image;
@dynamic mood;
@dynamic location;

// should be cached
- (NSString *)sectionName {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy"];
    
    return [dateFormatter stringFromDate:date];
}

@end
