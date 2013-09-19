
//  ChordsList
//
//  Created by Dmitiy on 9/15/13.
//  Copyright (c) 2013 Dmitiy. All rights reserved.
//

#import "ConfigService.h"

@implementation ConfigService

@synthesize values = _values;

+ (ConfigService *)sharedInstance {
    static ConfigService *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[ConfigService alloc] init];
    });
    
    return __sharedInstance;
}

- (ConfigService *) init
{
    self = [super init];
    
    if (self) {
        NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"];
        _values = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    }
    return self;
}

/*
    Return object value for key
 */
- (NSObject *) getObject: (NSString *)key
{
    return [_values objectForKey:key];
}

- (NSString *)getApiHost
{
    return [_values objectForKey:@"Host"];
}

/*
    Return api action url part
 */
- (NSString *) getApiUrlFor: (NSString *)action
{
    NSString *url = [[_values objectForKey:@"URL"] objectForKey:action];
    if (url == nil) {
        [NSException raise:@"Invalid action name" format:@"Action %@ is invalid", action];
    }
    return url;
}


@end
