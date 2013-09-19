//
//  ChordsListTableVC.h
//  ChordsList
//
//  Created by Dmitry on 16.09.13.
//  Copyright (c) 2013 Dmitiy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectedChordVC.h"

@interface ChordsListTableVC : UITableViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>
{
    
}
@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) NSArray *chordsArray;
@end
