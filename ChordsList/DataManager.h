//
//  ContactModelManager.h - idea and sources by Mike Nachbaur
//  reausable CoreData Singltone
//  Camarazzi
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Chord.h"
#define DataManagerSharedInstance [DataManager sharedInstance]

extern NSString * const DataManagerDidSaveNotification;
extern NSString * const DataManagerDidSaveFailedNotification;

@interface DataManager : NSObject 
{
    
}   

@property (nonatomic, readonly, retain) NSManagedObjectModel *objectModel;
@property (nonatomic, readonly, retain) NSManagedObjectContext *mainObjectContext;
@property (nonatomic, readonly, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSMutableSet *setOfChordsName;

+ (DataManager*)sharedInstance;
- (BOOL)save;
- (NSManagedObjectContext*)managedObjectContext;
- (void) savingParseResultFrom:(NSDictionary *) chordsJSONDictionary;
@end

/*
 http://www.amdm.ru/cgen/
 
 https://docs.google.com/a/demax.ru/document/d/1SxxhG6osLL-hcfY5ImT7O-44Lw0hj-woOVGOS44bcp0/edit 
 
 http://nachbaur.com/blog/smarter-core-data
 http://yannickloriot.com/2012/03/magicalrecord-how-to-make-programming-with-core-data-pleasant/#sthash.NC0YkRFT.dpbs
 http://mobile.tutsplus.com/tutorials/iphone/easy-core-data-fetching-with-magical-record/
 http://www.raywenderlich.com/16873/how-to-add-search-into-a-table-view
 */
