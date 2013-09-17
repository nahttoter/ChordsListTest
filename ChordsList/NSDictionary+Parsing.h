//
//  NSDictionary+Parsing.h
//  ChordsList
//
//  Created by Dmitry on 16.09.13.
//  Copyright (c) 2013 Dmitiy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Parsing)
+(NSDictionary*) dictionaryWithContentsOfJSONString:(NSString*)fileLocation;
- (id)objectOrNilForKey:(id)aKey;
@end
