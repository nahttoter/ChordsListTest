//
//  ChordsListTableVC.m
//  ChordsList
//
//  Created by Dmitry on 16.09.13.
//  Copyright (c) 2013 Dmitiy. All rights reserved.
//

#import "ChordsListTableVC.h"
#define kDetailChordSegue @"showChordsDetailSegue"
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSOperationQueue *theQueue = [[NSOperationQueue alloc] init];
    
    theQueue.name = @"Parsing data Queue";
    NSBlockOperation *parseBlock = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"Running block saving video");
        [ApiServiceInstance apiGetAllChords:^(BOOL success)
         {
             self.chordsArray=[NSArray arrayWithArray:[DataManagerSharedInstance.setOfChordsName allObjects]];
             [self.tableView reloadData];
         }
                                      error:^(NSError *error)
         {
             
         }];
    }];
    
    
    NSBlockOperation *updateDataBlock = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"Running block saving DB");
        self.chordsArray=[NSArray arrayWithArray:[DataManagerSharedInstance.setOfChordsName allObjects]];
        searchResults=[[NSArray alloc] init];
        [self.tableView reloadData];
    }];
    
    parseBlock.threadPriority=NSOperationQueuePriorityHigh;
    updateDataBlock.threadPriority=NSOperationQueuePriorityHigh;
    
    
    [updateDataBlock addDependency:updateDataBlock];
    [theQueue addOperation:parseBlock];
    [theQueue addOperation:updateDataBlock];
    
  //  [theQueue waitUntilAllOperationsAreFinished];
    
    

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
        NSLog(@"show %@",cell.textLabel.text);
    } else {
        cell.textLabel.text = [self.chordsArray objectAtIndex:indexPath.row];
        NSLog(@"hide %@",cell.textLabel.text);
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
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        [self performSegueWithIdentifier: kDetailChordSegue sender: self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kDetailChordSegue]) {
        //RecipeDetailViewController *destViewController = segue.destinationViewController;
        
        NSIndexPath *indexPath = nil;
        
        if ([self.searchDisplayController isActive]) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
           // destViewController.recipeName = [searchResults objectAtIndex:indexPath.row];
            
        } else {
            indexPath = [self.tableView indexPathForSelectedRow];
           // destViewController.recipeName = [recipes objectAtIndex:indexPath.row];
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
