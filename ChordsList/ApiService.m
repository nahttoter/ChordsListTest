
#import "ApiService.h"

@implementation ApiService {
    NSString *_host;
    NSInteger  _timeout;
    BOOL isUpdatedData;
 }

@synthesize httpAFClient;
@synthesize internetIsActive;

- (ConfigService *)configService
{
    return ConfigServiceInstance;
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
       
        NSLog(@"Current host: %@", _host);
        _timeout = [(NSString *)[self.configService getObject: @"Timeout"] intValue];
        isUpdatedData=NO;
        //NSLog(@"Current timeout: %d", _timeout);
   
    }
    return self;
}

#pragma mark inet status
-(void) addInternetCheckerObserver
{
    // check for internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    // check if a pathway to a host exists
    hostReachable = [Reachability reachabilityWithHostname:(NSString *)[self.configService getObject: @"reachabilityHostCheck"]];
    [hostReachable connectionRequired];
    [hostReachable startNotifier];
}


// called after network status changes
-(void) checkNetworkStatus:(NSNotification *)notice
{
    Reachability * reach = [notice object];
    if([reach isReachable])
    {
        //NSLog(@"API:The host is present.");
        if (isUpdatedData==NO)
        {
            [self updateCoreDataFromServer];
        }
    }
    else
    {
        NSLog(@"API:The host is down.");
    }
    
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    switch (hostStatus)
    {
        case NotReachable:
        {
            //NSLog(@"The internet is down.");
            self.internetIsActive=NO;
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"API: inet byWifi");
            self.internetIsActive=YES;
            break;
        }
        case ReachableViaWWAN:
        {
            self.internetIsActive=YES;            
            NSLog(@"The internet is working via WWAN.");
            break;
        }
    }
}

- (NSString *)stringWithFormEncodedComponentsIn:(NSDictionary *) dict {
	NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:[dict count]];
	[dict enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
		[arguments addObject:[NSString stringWithFormat:@"%@=%@",
							  [key stringByEscapingForURLQuery],
							  [[object description] stringByEscapingForURLQuery]]];
	}];
	
	return [arguments componentsJoinedByString:@"&"];
}

//Return new instance of request for API action

- (NSMutableURLRequest *) createGETRequest: (NSString *)action params:(NSDictionary *)params
{
    NSMutableString *urlString = [[NSMutableString alloc] initWithString:_host];
    [urlString appendString:[[self configService] getApiUrlFor:action]];
    
    if (params != nil) {
        [urlString appendString:@"?"];
    }
    //NSLog(@"Create request for URL: %@", urlString);
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
            initWithURL:url
            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
            timeoutInterval: _timeout];
    request.HTTPMethod = @"GET";

    return request;
}

#pragma mark Api Methods

-(void) updateCoreDataFromServer
{
    isUpdatedData=YES;
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW,0), ^(void)
                   {
                       NSLog(@"Request chords from server");
                       [ApiServiceInstance apiGetAllChords:^(BOOL success)
                        {
                            NSLog(@"Loaded chords from json");  
                        }
                                                     error:^(NSError *error)
                        {
                            isUpdatedData=NO;
                        }];
                   });
}


//Get chords Data from server
-(void) apiGetAllChords:(void (^)(BOOL success))completionBlock error:(void (^)(NSError *))errorResult
{
    if (self.internetIsActive)
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        NSMutableString *urlString = [[NSMutableString alloc] initWithString:_host];
        [urlString appendString:[[self configService] getApiUrlFor:@"chordDiagram"]];

        NSURLRequest *request = [self createGETRequest:@"chordDiagram" params:nil];
        
            AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
        {
            [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            //NSLog(@"Response result %@",JSON);        
            [self parseDataJSON:JSON];
             completionBlock(YES);
      
        }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            // code for failed request goes here
            [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            NSLog(@"Return error by request chords list %@",error.description);
            
            errorResult(error);
        }];
        [self.httpAFClient enqueueHTTPRequestOperation:operation];
    }
    
}

//saving music dat to memory
-(void) storeDataOfFile:(NSData *) data andID:(NSInteger)idChord
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName=[NSString stringWithFormat:@"chordsFile%d.dat",idChord];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    if ([data writeToFile:filePath atomically:YES]) {
        NSLog(@"Stored file %@",filePath);
    } 
}

//didn't finish this nethod - have to calculate Midi Sample Codes
-(void) apiGetAudioSampleOfChord:(Chord *) chord  success:(void (^)(NSData *successData))completionBlock error:(void (^)(NSError *))errorResult;
{
    if (self.internetIsActive)
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        NSMutableString *urlString = [[NSMutableString alloc] initWithString:_host];
        [urlString appendString:[[self configService] getApiUrlFor:@"tuningNoteSample"]];

        //Need to correct sample ID
        [urlString appendString:[NSString stringWithFormat:@"40"]];
        
        [urlString appendString:[[self configService] getApiUrlFor:@"instrument"]];
        
        NSURLRequest *urlRequest=[[NSURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest ];
       
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
            if (operation.responseData) {
                
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
                
                [self storeDataOfFile:operation.responseData andID:chord.idChord.integerValue];
                completionBlock(operation.responseData);
                
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
                errorResult(error);
        }];
          
        [self.httpAFClient enqueueHTTPRequestOperation:operation];
    }
}

-(void) parseDataJSON:(id) DataJSON
{
    [DataManagerSharedInstance savingParseResultFrom:(NSDictionary*)DataJSON];
}

@end

