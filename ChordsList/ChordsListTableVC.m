//
//  ChordsListTableVC.m
//  ChordsList
//
//  Created by Dmitry on 16.09.13.
//  Copyright (c) 2013 Dmitiy. All rights reserved.
//

#import "ChordsListTableVC.h"
#define kDetailChordSegue @"showChordsDetailSegue"
#define chordsArrayFilename @"chordsArray.dat"
@interface ChordsListTableVC ()

@end

@implementation ChordsListTableVC
@synthesize chordsArray;
@synthesize searchResults;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSArray *) readChordsArray
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:chordsArrayFilename];
    NSLog(@"Loaded arr");
    return [NSArray arrayWithContentsOfFile:filePath];

}
-(void) storeChordsArray:(NSArray *) chordsArr
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:chordsArrayFilename];
    [chordsArr writeToFile:filePath atomically:YES];
    
    NSLog(@"Stored");
    
}
-(void) setup
{
    //if is first launcg parse data from json
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([prefs integerForKey:@"firstTimeLaunch"]==1) {
        self.chordsArray=[self readChordsArray];
        [self.tableView reloadData];
    }
    else
    {
#warning del
        UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc]     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityView.center=self.view.center;
        [activityView startAnimating];
        [self.view addSubview:activityView];
        
        NSDictionary *chordsData = [NSDictionary dictionaryWithContentsOfJSONString:@"chordDiagrams.json"];
         NSLog(@"Started");
        [DataManagerSharedInstance savingParseResultFrom:chordsData];
        NSLog(@"Finished");
        [prefs setValue:@1 forKey:@"firstTimeLaunch"];
        [prefs synchronize];
        if ([DataManagerSharedInstance.setOfChordsName count]) {
            self.chordsArray=[NSArray arrayWithArray:[DataManagerSharedInstance.setOfChordsName allObjects]];
            [self.tableView reloadData];
            
            [self storeChordsArray:self.chordsArray];
            NSLog(@"Loaded chords from storage");
        }
        
        [activityView stopAnimating];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setup];
    
    /*
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^()
    {
        [ApiServiceInstance apiGetAllChords:^(BOOL success)
         {
             NSLog(@"Loaded chords from json"); 
         }
                                      error:^(NSError *error)
         {
             
         }];
        
        dispatch_async(dispatch_get_main_queue(), ^()
                       {
                           // most UIKit tasks are permissible only from the main queue or thread,
                           // so if you want to update an UI as a result of the completed action,
                           // this is a safe way to proceed
                           self.chordsArray=[NSArray arrayWithArray:[DataManagerSharedInstance.setOfChordsName allObjects]];
                           [self.tableView reloadData];
                       });
    });
    */
    /*
    NSOperationQueue *theQueue = [[NSOperationQueue alloc] init];
    
    theQueue.name = @"Parsing data Queue";
    NSBlockOperation *parseBlock = [NSBlockOperation blockOperationWithBlock:^{
       
        
    }];
    
    
    NSBlockOperation *updateDataBlock = [NSBlockOperation blockOperationWithBlock:^{
       
        self.chordsArray=[NSArray arrayWithArray:[DataManagerSharedInstance.setOfChordsName allObjects]];
        searchResults=[[NSArray alloc] init];
        [self.tableView reloadData];
        NSLog(@"Loaded chords from json");        
    }];
    
    parseBlock.threadPriority=NSOperationQueuePriorityNormal;
    updateDataBlock.threadPriority=NSOperationQueuePriorityNormal;
    
    
    [updateDataBlock addDependency:updateDataBlock];
    [theQueue addOperation:parseBlock];
    [theQueue addOperation:updateDataBlock];
    
  //  [theQueue waitUntilAllOperationsAreFinished];
    */
    

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.searchResults count];
        
    } else {
        return [self.chordsArray count];
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*static NSString *CellIdentifier = @"ChordsName";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
       cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }*/
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if( cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        cell.textLabel.text = [self.chordsArray objectAtIndex:indexPath.row];
    }
    
    return cell;
}


#pragma mark - Search Table view delegate



- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"SELF contains[cd] %@",
                                    searchText];
    
    searchResults = [self.chordsArray filteredArrayUsingPredicate:resultPredicate];
    NSLog(@"search count %d %@",[searchResults count], self.searchResults);
    [self.tableView reloadData];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    NSLog(@"%@ seraching",searchString);
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        [self performSegueWithIdentifier: kDetailChordSegue sender: self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kDetailChordSegue]) {
        SelectedChordVC *destinationViewController = segue.destinationViewController;
          
        NSIndexPath *indexPath = nil;
        if ([self.searchDisplayController isActive]) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            destinationViewController.selectedChordArray = [DataManagerSharedInstance fetchSpecificChordsByName:[self.searchResults objectAtIndex:indexPath.row]];
            
        } else {
            indexPath = [self.tableView indexPathForSelectedRow];
            destinationViewController.selectedChordArray = [DataManagerSharedInstance fetchSpecificChordsByName:[self.chordsArray objectAtIndex:indexPath.row]];
        }
    }
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}
@end
