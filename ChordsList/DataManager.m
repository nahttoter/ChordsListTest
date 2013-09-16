//
//  ContactModelManager.m
//  Camarazzi
//
//  Created by Dmitry on 13.08.13.
//  Copyright (c) 2013 MaximaLabs. All rights reserved.
//

#import "DataManager.h"

NSString * const DataManagerDidSaveNotification = @"DataManagerDidSaveNotification";
NSString * const DataManagerDidSaveFailedNotification = @"DataManagerDidSaveFailedNotification";

#define  decoysPhotosCount 4
#define  videosSec 1


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
    
    //NSLog(@"store URL %@",storeURL.path);
    
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
#pragma mark parsing to DB methods

- (void) savingParseResultFrom:(NSDictionary *) chordsJSONDictionary
{
    self.setOfChordsName=[[NSMutableSet alloc] init];
    
    //parsing all chord and saving to coredata
    for (NSDictionary *chordDict in chordsJSONDictionary) {
        
        Chord *newChord =(Chord *)[NSEntityDescription insertNewObjectForEntityForName:@"Chord" inManagedObjectContext:self.mainObjectContext];
        [newChord updateChordWithDictionary:chordDict];
        //NSLog(@"%@ saving hord, succes %d",newChord,[self save]);
        
        //creating set of chords name for table view, exlidung names, which already in set
        NSString *chordNameStr=[chordDict objectOrNilForKey:@"name"];
        if (![self.setOfChordsName containsObject:chordNameStr]) {
            [self.setOfChordsName addObject:chordNameStr];
        }
        
            
    }
    NSLog(@"Names %@ %d",self.setOfChordsName,[self.setOfChordsName count]);
    
    [self save];
}
/*
-(void) updateContactID:(int) idRecip
               withName:(NSString *) nameStr
                  phone:(NSString*) phoneStr
                  email:(NSString*) emailStr
                   type:(int) typeInt
{
   
  
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Recipient"] ;
        NSArray *recipientsArr=[[self.mainObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
        NSLog(@"Contact dataModel update %@, count %d", recipientsArr ,[recipientsArr count]);
        
        
        if ([recipientsArr count]>0) {
         for(Recipient *currentRecipient in recipientsArr)
         {
         if (currentRecipient.type==0) {
         [self.mainObjectContext deleteObject:currentRecipient];
         NSLog(@"deleted contact");
         }
         
         }
         }
         
        
        //check if contact already in db
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"( idRecip = %d)",idRecip];
        [fetchRequest setPredicate:predicate];
        
        NSError *error=nil;
        NSArray *array = [self.mainObjectContext executeFetchRequest:fetchRequest error:&error];
        
        Recipient *newRecip;
        if ([array count]) {
            newRecip =(Recipient*)[array lastObject];
        }
        else
        {
            newRecip =(Recipient *)[NSEntityDescription insertNewObjectForEntityForName:@"Recipient" inManagedObjectContext:self.mainObjectContext];
        }
        
        
        // Create and configure a new instance of the  entity.
        
        newRecip.idRecip=[NSNumber numberWithInt:idRecip];
        
        switch (typeInt) {
            case 0:
                [newRecip setDefaultsForNormalRecepients];
                break;
            case 1:
                [newRecip setDefaultsForEmailRecipient];
                break;
            case 2:
                [newRecip setDefaultsForDuressRecepients];
                break;
            default:
                break;
        }
        
        if ([nameStr length]) {
            newRecip.name =nameStr;
        }
        
        if ([emailStr length]) {
            newRecip.email=emailStr;
        }
        
        if ([phoneStr length]) {
            newRecip.phone=phoneStr;
        }
        if (typeInt) {
            newRecip.type=[NSNumber numberWithInt:typeInt ];
        }
        
        if (![self.mainObjectContext save:&error]) {
            NSLog(@"Error while saving");
        }
        
        else
        {
            NSLog(@"success update DB with contactid %d ",idRecip);
        }

   
   
}


-(NSArray*) getContactsOfType:(int) typeInt
{
    
    if ([GVUserDefaults standardUserDefaults].isDuressModeNow) {
        typeInt=2;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Recipient"] ;
    NSArray *recipientsArr=[[self.mainObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    NSLog(@"Contact dataModel get %@, count %d", recipientsArr ,[recipientsArr count]);
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"( type = %d)",typeInt];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"idRecip" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    NSArray *array = [self.mainObjectContext executeFetchRequest:fetchRequest error:&error];
    if (array == nil)
    {
        // Deal with error...
    }
    else
    {
        recipientsArr = [array mutableCopy];
    }
    NSLog(@"array %@ %@",recipientsArr,array);
    return recipientsArr;
}

-(NSArray*) getUnsyncedImages
{   
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ImageObject"] ;
    NSArray *recipientsArr=[[self.mainObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    NSLog(@"Unsync Photos get %@, count %d", recipientsArr ,[recipientsArr count]);
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"( isTransmitted = 0)"];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"captureTime" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    NSArray *array = [self.mainObjectContext executeFetchRequest:fetchRequest error:&error];
    if (array == nil)
    {
        // Deal with error...
    }
    else
    {
        recipientsArr = [array mutableCopy];
    }
    NSLog(@"Fatched array %@ %@",recipientsArr,array);
    return recipientsArr;
  
}


-(NSArray *) getLastSessionPhotosForSendingAndOrderForw:(BOOL) ascend
{
    BOOL isTransmitted=NO;
    
    if (StandartDefaultsInstance.sessionStartedNSDate) {
    
    
    //NSError *error;
    NSFetchRequest *request =[[NSFetchRequest alloc] initWithEntityName:@"ImageObject"] ;
    
    //get new captured photos
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"captureTime" ascending:ascend];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"((captureTime >= %@) AND (isTransmitted = %d))", StandartDefaultsInstance.sessionStartedNSDate,isTransmitted];
    [request setPredicate:predicate];
    NSLog(@"predicate %@",predicate);
    
    NSArray *results = [self.mainObjectContext executeFetchRequest:request error:NULL];
    NSLog(@"total fetched new photos %d",[results count]);
       return results; 
    }
    else return nil;
}


-(NSArray *) getLastSessionVideosForSendingAndOrderForw:(BOOL) ascend
{
    BOOL isTransmitted=NO;
    
    if (StandartDefaultsInstance.sessionStartedNSDate) {
        
        
        //NSError *error;
        NSFetchRequest *request =[[NSFetchRequest alloc] initWithEntityName:@"VideoObject"] ;
        
        //get new captured photos
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"captureTime" ascending:ascend];
        [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"((captureTime >= %@) AND (isTransmitted = %d))", StandartDefaultsInstance.sessionStartedNSDate,isTransmitted];
        [request setPredicate:predicate];
        NSLog(@"predicate %@",predicate);
        
        NSArray *results = [self.mainObjectContext executeFetchRequest:request error:NULL];
        NSLog(@"total fetched new videos %d",[results count]);
        return results; 
    }
    else return nil;
}

-(NSArray *) getPhotosSortedByTimeAscending:(BOOL) ascend AndIsDecoy:(int) isDecoy
{
    //NSError *error;
    NSFetchRequest *request =[[NSFetchRequest alloc] initWithEntityName:@"ImageObject"] ;
    
    //get new captured photos
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"captureTime" ascending:ascend];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"( isDecoy = %d)",isDecoy];
    [request setPredicate:predicate];
    
    NSArray *results = [self.mainObjectContext executeFetchRequest:request error:NULL];
    NSLog(@"total fetched count %d Is decoy %d",[results count],isDecoy);
    return results;
}

-(NSArray *) getVideosSortedByTimeAscending:(BOOL) ascend AndIsDecoy:(int) isDecoy
{
    //NSError *error;
    NSFetchRequest *request =[[NSFetchRequest alloc] initWithEntityName:@"VideoObject"] ;
    
    //get new captured photos
    //NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"captureTime" ascending:ascend];
    //[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"( isDecoy = %d)",isDecoy];
    [request setPredicate:predicate];
    
    NSArray *results = [self.mainObjectContext executeFetchRequest:request error:NULL];
    NSLog(@"total fetched count %d Is decoy %d",[results count],isDecoy);
    return results;
}

-(void) deployPhotosDecoys
{
    NSError *error;
    NSArray *results = [self getPhotosSortedByTimeAscending:NO AndIsDecoy:0];
    NSArray *decoysArray;
    if ([results count]>decoysPhotosCount) {
        decoysArray =[results subarrayWithRange:NSMakeRange(0, decoysPhotosCount)];
    }
    else  //copy all obj
        decoysArray=[results copy];
    
    if ([decoysArray count]) {
        for (ImageObject *obj in decoysArray) {
            ImageObject *newObj = (ImageObject*) [obj cloneInContext:self.mainObjectContext exludeEntities:nil];
            [newObj addDecoyInfo];
        }
        if (![self.mainObjectContext save:&error]) {
            NSLog(@"Error while saving");
        }
        else
        {
            // NSLog(@"Saved copy ");
        }
    }
}

*/


@end
