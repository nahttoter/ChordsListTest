//
//  ContactModelManager.h - idea and part of code by Mike Nachbaur
//  reausable CoreData Singltone
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Chord.h"
#define DataManagerSharedInstance [DataManager sharedInstance]

extern NSString * const DataManagerDidSaveNotification;
extern NSString * const DataManagerDidSaveFailedNotification;

@interface DataManager : NSObject 

@property (nonatomic, readonly, retain) NSManagedObjectModel *objectModel;
@property (nonatomic, readonly, retain) NSManagedObjectContext *mainObjectContext;
@property (nonatomic, readonly, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSMutableSet * setOfChordsName;
+ (DataManager*)sharedInstance;
- (BOOL)save;
- (NSManagedObjectContext*)managedObjectContext;

- (void) savingParseResultFrom:(NSDictionary *) chordsJSONDictionary;
- (NSArray *) fetchSpecificChordsByName:(NSString *) chordsName;
@end

