//
//  ContactModelManager.m
//
//  Created by Dmitry on 13.08.13.
//  Copyright (c) 2013. All rights reserved.
//

#import "DataManager.h"

NSString * const DataManagerDidSaveNotification = @"DataManagerDidSaveNotification";
NSString * const DataManagerDidSaveFailedNotification = @"DataManagerDidSaveFailedNotification";

#define  decoysPhotosCount 4
#define  videosSec 1
#define kChordEntityName @"Chord"

@interface DataManager ()

- (NSString*)sharedDocumentsPath;

@end

@implementation DataManager

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize mainObjectContext = _mainObjectContext;
@synthesize objectModel = _objectModel;
@synthesize setOfChordsName;

NSString * const kDataManagerBundleName = @"ChordsList";
NSString * const kDataManagerModelName = @"ChordsDBModel";
NSString * const kDataManagerSQLiteName = @"ChordsDBModel.sqlite";

#pragma mark parsing to DB methods

-(void) findOrAddChordFromDict:(NSDictionary *)chordDict inContext:(NSManagedObjectContext *)context
{
    
    //check if chord already in DB
    NSString *idChord=[chordDict objectOrNilForKey:@"id"];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:kChordEntityName] ;
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(idChord = %@)",idChord];
    [fetchRequest setPredicate:predicate];
    NSError *error=nil;
    
    if ([context countForFetchRequest:fetchRequest error:&error]) {
        //chord already in DB, do nothing
    }
    else
    {
        Chord *newChord =(Chord *)[NSEntityDescription insertNewObjectForEntityForName:kChordEntityName inManagedObjectContext:context];
        [newChord updateChordWithDictionary:chordDict];
        
    }
    if (error) {
        NSLog(@"Error fetching by chordId %@",error.description);
    }
   
}

- (void) savingParseResultFrom:(NSDictionary *) chordsJSONDictionary
{
    //parsing all chord and saving to coredata
 
    double delayInSeconds = 0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW,0), ^(void)
    {
        self.setOfChordsName=[[NSMutableSet alloc] init];

        //parsing all chord and saving to coredata
        for (NSDictionary *chordDict in chordsJSONDictionary)
        {
            [self findOrAddChordFromDict:chordDict inContext:self.managedObjectContext];
            
            //creating set of chords name for table view, exlidung names, which already in set
            NSString *chordNameStr=[chordDict objectOrNilForKey:@"name"];
            if (![self.setOfChordsName containsObject:chordNameStr])
                [self.setOfChordsName addObject:chordNameStr];    
        }
            [self save];
        
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotifDataUpdated
                                                            object:nil];
        
            NSLog(@"Finished updating from server to CoreData");
        });
    
}

-(NSArray *) fetchSpecificChordsByName:(NSString *) chordsName 
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:kChordEntityName] ;
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"(name = %@)",chordsName];
    [fetchRequest setPredicate:predicate];
    
    NSError *error=nil;
    NSArray *fetchedChords = [self.mainObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"Error fetching chords %@",error.description);
    }
    //NSLog(@"Fetch result %@",fetchedChords);
    return fetchedChords;
    
}

#pragma mark Coredata Singletone Methods
+ (DataManager*)sharedInstance {
	static dispatch_once_t pred;
	static DataManager *sharedInstance = nil;
	dispatch_once(&pred, ^{ sharedInstance = [[self alloc] init]; });
	return sharedInstance;
}

- (void)dealloc {
	[self save];
}

- (NSManagedObjectModel*)objectModel {
	
    if (_objectModel != nil) {
        return _objectModel;
    }
    _objectModel = [NSManagedObjectModel mergedModelFromBundles:nil] ;
    return _objectModel;
}

- (NSPersistentStoreCoordinator*)persistentStoreCoordinator {
	if (_persistentStoreCoordinator)
		return _persistentStoreCoordinator;

	// Get the paths to the SQLite file
	NSString *storePath = [[self sharedDocumentsPath] stringByAppendingPathComponent:kDataManagerSQLiteName];
	NSURL *storeURL = [NSURL fileURLWithPath:storePath];
 
    //copy preloaded sqlite DB with Chords
    if (![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]) {
        NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"ChordsDBModel" ofType:@"sqlite"]];
        NSError* err = nil;
        
        if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:storeURL error:&err]) {
            NSLog(@"Сould copy preloaded data");
        }
    }
    
	// Define the Core Data version migration options
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                             nil];
    
	// Attempt to load the persistent store
	NSError *error = nil;
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.objectModel];
	if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:options
                                                           error:&error]) {
		NSLog(@"Fatal error while creating persistent store: %@", error);
		abort();
	}
    
	return _persistentStoreCoordinator;
}

- (NSManagedObjectContext*)mainObjectContext {
	if (_mainObjectContext)
		return _mainObjectContext;
    
	// Create the main context only on the main thread
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(mainObjectContext)
                               withObject:nil
                            waitUntilDone:YES];
		return _mainObjectContext;
	}
    
	_mainObjectContext = [[NSManagedObjectContext alloc] init];
	[_mainObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    
	return _mainObjectContext;
}

- (BOOL)save {
	if (![self.mainObjectContext hasChanges])
		return YES;
    
	NSError *error = nil;
	if (![self.mainObjectContext save:&error]) {
		NSLog(@"Error while saving: %@\n%@", [error localizedDescription], [error userInfo]);
		[[NSNotificationCenter defaultCenter] postNotificationName:DataManagerDidSaveFailedNotification
                                                            object:error];
		return NO;
	}
    
	[[NSNotificationCenter defaultCenter] postNotificationName:DataManagerDidSaveNotification object:nil];
	return YES;
}

- (NSString*)sharedDocumentsPath {
	static NSString *SharedDocumentsPath = nil;
	if (SharedDocumentsPath)
		return SharedDocumentsPath;
    
	// Compose a path to the <Library>/Database directory
	NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] ;
	SharedDocumentsPath = [libraryPath stringByAppendingPathComponent:@"Database"] ;
    
	// Ensure the database directory exists
	NSFileManager *manager = [NSFileManager defaultManager];
	BOOL isDirectory;
	if (![manager fileExistsAtPath:SharedDocumentsPath isDirectory:&isDirectory] || !isDirectory) {
		NSError *error = nil;
		NSDictionary *attr = [NSDictionary dictionaryWithObject:NSFileProtectionComplete
                                                         forKey:NSFileProtectionKey];
		[manager createDirectoryAtPath:SharedDocumentsPath
		   withIntermediateDirectories:YES
                            attributes:attr
                                 error:&error];
		if (error)
			NSLog(@"Error creating directory path: %@", [error localizedDescription]);
	}
    
	return SharedDocumentsPath;
}

- (NSManagedObjectContext*)managedObjectContext {
	NSManagedObjectContext *ctx = [[NSManagedObjectContext alloc] init] ;
	[ctx setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    
	return ctx;
}

@end
