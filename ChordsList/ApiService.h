
#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "Reachability.h"
#import "ConfigService.h"

#import "NSString+SSToolkitAdditions.h"
#import "DataManager.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
//#import "VideoObject.h"

#define ApiServiceInstance [ApiService sharedInstance]

@class AFJSONRequestOperation;
@class Reachability;

typedef void (^JSONResponseBlock)(NSDictionary* json);
typedef void (^CompletionBlock)(id, NSError*);

@interface ApiService : ConfigService//NSObject
{

    Reachability* hostReachable;
}
@property (nonatomic,assign) BOOL internetIsActive;
@property (nonatomic,strong) AFHTTPClient *httpAFClient;

+ (ApiService*)sharedInstance;
- (ConfigService *)configService;
-(void) addInternetCheckerObserver;

-(void) apiGetAllChords:(void (^)(BOOL success))completionBlock error:(void (^)(NSError *))errorResult;

-(void) apiGetAudioSampleOfChord:(Chord *) chord  success:(void (^)(NSData *successData))completionBlock error:(void (^)(NSError *))errorResult;

@end