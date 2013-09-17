//
//  SelectedChordVC.h
//  ChordsList
//
//  Created by Dmitiy on 9/16/13.
//  Copyright (c) 2013 Dmitiy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "Chord.h"
#import "SmallSchemeView.h"

@interface SelectedChordVC : UIViewController<iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, retain) IBOutlet iCarousel *carousel;
@property (strong, nonatomic) IBOutlet UILabel *chordNameLbl;
@property (nonatomic, retain) NSArray *selectedChordArray;

@end
