//
//  NSDictionary+Parsing.m
//  ChordsList
//
//  Created by Dmitry on 16.09.13.
//  Copyright (c) 2013 Dmitiy. All rights reserved.
//

#import "NSDictionary+Parsing.h"

@implementation NSDictionary (Parsing)
- (id)objectOrNilForKey:(id)aKey 
{
    id object = [self objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}

@end
