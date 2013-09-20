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
#define chordsArrayDatFile @"chordsArray"
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

//read plist of Different chords
-(NSArray *) readChordsArray
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"chordsArray" ofType:@"dat"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSArray *loadedArray = [[NSArray alloc] initWithContentsOfFile:path];
        return loadedArray;
    }
    else return nil;
}


-(void) loadData
{
    self.chordsArray=[self readChordsArray];
    [self.tableView reloadData];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTablewViewWithNewData) name:kNotifDataUpdated object:nil];
    
    [self loadData];

}

-(void) updateTablewViewWithNewData
{
    NSLog(@"Reload table after updating CoreData");
    if ([DataManagerSharedInstance.setOfChordsName count]) {
        self.chordsArray=[DataManagerSharedInstance.setOfChordsName allObjects];
        [self.tableView reloadData];
    }

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
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.searchResults count];
        
    } else {
        return [self.chordsArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
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
    //NSLog(@"search count %d %@",[searchResults count], self.searchResults);
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
            destinationViewController.chordName=[NSString stringWithString: [self.searchResults objectAtIndex:indexPath.row]] ;

            destinationViewController.selectedChordArray = [DataManagerSharedInstance fetchSpecificChordsByName:[self.searchResults objectAtIndex:indexPath.row]];
            
        } else {
            indexPath = [self.tableView indexPathForSelectedRow];
            destinationViewController.chordName=[NSString stringWithString: [self.chordsArray objectAtIndex:indexPath.row]] ;
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
