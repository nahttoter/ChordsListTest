
#import "ApiService.h"

static NSString *const baseURLString = @"http://www.raywenderlich.com/downloads/weather_sample/";

@implementation ApiService {
    NSString *_host;
    NSInteger  _timeout;
    NSMutableSet *currentObjectsSet;
    Float32 apiTotalExpectBytesForUpload;
    Float32 apiTotalUploadedBytes;

}



@synthesize httpAFClient;
@synthesize internetActive;

- (ConfigService *)configService
{
    ConfigService *configService=[[ConfigService alloc] init];
    return configService;
}

+ (ApiService*)sharedInstance {
    static ApiService *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[ApiService alloc] init];
        
       
    });
    
    return __sharedInstance;
}

- (ApiService *) init
{
    if (self = [super init]) {
       
        [self addInternetCheckerObserver];
        _host = (NSString *)[self.configService getApiHost];
        
        self.httpAFClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:_host]];
        [AFJSONRequestOperation addAcceptableContentTypes: [NSSet setWithObject:@"text/html"]];
       
        NSLog(@"Current work host: %@", _host);
        _timeout = [(NSString *)[self.configService getObject: @"Timeout"] intValue];
        NSLog(@"Current timeout: %d", _timeout);
        
       
    }
    return self;
}

#pragma mark inet status
-(void) addInternetCheckerObserver
{
    // check for internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    // check if a pathway to a host exists
    hostReachable = [Reachability reachabilityWithHostname:(NSString *)[self.configService getObject: @"reachabilityHostCheck"]] ;
    [hostReachable startNotifier];
}

-(void) checkNetworkStatus:(NSNotification *)notice
{
    Reachability * reach = [notice object];
    if([reach isReachable])
    {
        NSLog(@"API:The host is present.");
    }
    else
    {
        NSLog(@"API:The host is down.");
        
    }
    
    // called after network status changes
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    switch (hostStatus)
    {
        case NotReachable:
        {
        
            NSLog(@"The internet is down.");

           // [self postNitifcationWithObject:self.internetActive];
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"API: inet byWifi");
            

            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"The internet is working via WWAN.");
            break;
        }
    }
}



/*
 * Return new instance of request for API action
 */

- (NSString *)stringWithFormEncodedComponentsIn:(NSDictionary *) dict {
	NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:[dict count]];
	[dict enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
		[arguments addObject:[NSString stringWithFormat:@"%@=%@",
							  [key stringByEscapingForURLQuery],
							  [[object description] stringByEscapingForURLQuery]]];
	}];
	
	return [arguments componentsJoinedByString:@"&"];
}

- (NSMutableURLRequest *) createGETRequest: (NSString *)action params:(NSDictionary *)params
{
    NSMutableString *urlString = [[NSMutableString alloc] initWithString:_host];
    [urlString appendString:[[self configService] getApiUrlFor:action]];
    
    if (params != nil) {
        [urlString appendString:@"?"];
       // [urlString appendString: [params stringWithFormEncodedComponents]];
    }
    NSLog(@"Create request for URL: %@", urlString);
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
            initWithURL:url
            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                    
// try NSURLRequestReturnCacheDataElseLoad
        timeoutInterval: _timeout];
    request.HTTPMethod = @"GET";

    return request;
}


+ (BOOL) isSuccessResult: (NSDictionary *)JSON
{
    if ([JSON objectForKey:@"error"]) {
        return NO;
    }
    else
    {
    return YES;
    }//[JSON objectForKey:@"status"] ;
}

#pragma mark Api Methods


-(void) apiGetAllChords:(void (^)(BOOL success))completionBlock error:(void (^)(NSError *))errorResult
{
    NSMutableString *urlString = [[NSMutableString alloc] initWithString:_host];
    [urlString appendString:[[self configService] getApiUrlFor:@"chordDiagram"]];
    //NSURL *urlRequest=[NSURL URLWithString:urlString];
    //NSURLRequest *request = [self.httpAFClient requestWithMethod:@"GET" path:urlString parameters:nil ];
    
    NSURLRequest *request = [self createGETRequest:@"chordDiagram" params:nil];
    
    /*[NSURLRequest requestWithURL:urlRequest
                                            cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                        timeoutInterval:_timeout];
    */
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        // code for successful return goes here
        [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
        
        //NSLog(@"Response result %@",JSON);
        
        [self parseDataJSON:JSON];
         completionBlock(YES);
        
    }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        // code for failed request goes here
        [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
        NSLog(@"Return error by request chords list %@",error.description);
        
        errorResult(error);
    }];
    
    [self.httpAFClient enqueueHTTPRequestOperation:operation];
    
}

-(void) parseDataJSON:(id) DataJSON
{
    [DataManagerSharedInstance savingParseResultFrom:(NSDictionary*)DataJSON];
}

-(void) apiLoginPostRequestonCompletion:(void (^)(BOOL success))completionBlock error:(void (^)(NSError *))errorResult
{
    NSDictionary *params;
    
    NSMutableString *urlString = [[NSMutableString alloc] initWithString:_host];
    [urlString appendString:[[self configService] getApiUrlFor:@"login"]];
    
    NSDictionary *POSTDict=[NSDictionary dictionaryWithObject:params forKey:@"params"];
    
    NSLog(@"Post dict login %@,",POSTDict);
    
    NSURLRequest *request = [self.httpAFClient requestWithMethod:@"POST" path:@"/api/login" parameters:POSTDict ];
    
    NSString* newStr=nil;
    if ([[request HTTPBody] length]) {
        newStr   =  [[NSString alloc] initWithData:[request HTTPBody]
                                          encoding:NSUTF8StringEncoding] ;
        //[[NSString alloc] initWithUTF8String:[[request HTTPBody] bytes]]
        
    }
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        // code for successful return goes here
        [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
        
        [self parseDataJSON:JSON];
        completionBlock(YES);
        
    }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        // code for failed request goes here
        [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
        NSLog(@"return error login %@",JSON);
        
        errorResult(error);
    }];
    
    [self.httpAFClient enqueueHTTPRequestOperation:operation];
    
}

@end

