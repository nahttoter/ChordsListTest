//  ChordsList
//
//  Created by Dmitiy on 9/15/13.
//  Copyright (c) 2013 Dmitiy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConfigService : NSObject

@property (readonly, nonatomic) NSDictionary *values;

- (ConfigService *) init;

- (NSObject *) getObject: (NSString *)key;
- (NSString *) getApiHost;
- (NSString *) getApiUrlFor: (NSString *)type;

@end
