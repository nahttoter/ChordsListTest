//  ChordsList
//
//  Created by Dmitiy on 9/15/13.
//  Copyright (c) 2013 Dmitiy. All rights reserved.
//

#import <Foundation/Foundation.h>
#define ConfigServiceInstance [ConfigService sharedInstance]
@interface ConfigService : NSObject

@property (readonly, nonatomic) NSDictionary *values;
+ (ConfigService *)sharedInstance;
- (ConfigService *) init;

- (NSObject *) getObject: (NSString *)key;
- (NSString *) getApiHost;
- (NSString *) getApiUrlFor: (NSString *)type;

@end
