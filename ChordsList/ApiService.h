
#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "Reachability.h"
#import "ConfigService.h"

#import "NSString+SSToolkitAdditions.h"
#import "DataManager.h"
//#import "VideoObject.h"

#define ApiServiceInstance [ApiService sharedInstance]

@class AFJSONRequestOperation;
@class Reachability;

//typedef void (^ ApiSuccessResultBlock)(NSDictionary *result);
//typedef void (^ ApiErrorResultBlock)(NSError *error, NSDictionary *result);
//typedef void (^ CategoriesCollectionSuccessResultBlock)();
//typedef void (^ CategoriesCollectionErrorResultBlock)(NSError *error);

typedef void (^JSONResponseBlock)(NSDictionary* json);
typedef void (^CompletionBlock)(id, NSError*);

@interface ApiService : ConfigService//NSObject
{
    Reachability* internetReachable;
    Reachability* hostReachable;
}
@property (strong,nonatomic) NSNumber *internetActive;
@property (nonatomic,strong) AFHTTPClient *httpAFClient;

+ (ApiService*)sharedInstance;
- (ConfigService *)configService;
-(void) addInternetCheckerObserver;
-(void) apiGetAllChords:(void (^)(BOOL success))completionBlock error:(void (^)(NSError *))errorResult;



//old

//- (AFJSONRequestOperation *) loginMethod: (ApiSuccessResultBlock)success  error: (ApiErrorResultBlock)error;
-(void) apiLoginPostRequest;
-(void) apiPostLoginSystem;
-(void) apiAddContacs;

-(void) apiUpdateContactsRequestOnCompletion:(void (^)(id JSON))JSONResult error:(void (^)(NSError *))errorResult;


-(void) apiSettingsUpdate;
-(void) apiChangedMode;

-(void) startUploadingUnsyncedFiles;

-(void) apiUploadAllUnsyncData;
@end