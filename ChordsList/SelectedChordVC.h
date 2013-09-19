//
//  SelectedChordVC.h
//  ChordsList
//
//  Created by Dmitiy on 9/16/13.
//  Copyright (c) 2013 Dmitiy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "iCarousel.h"
#import "Chord.h"
#import "SmallSchemeView.h"
#import "UIView+DrawGuitarMarkers.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AudioToolbox/AudioToolbox.h>

#import "ConfigService.h"

@interface SelectedChordVC : UIViewController<iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, strong) IBOutlet UIView *fretBoardView;
@property (nonatomic, strong) IBOutlet iCarousel *carousel;
@property (nonatomic, strong) IBOutlet UILabel *chordNameLbl;
@property (nonatomic, strong) NSString *chordName;

@property (nonatomic, strong) NSArray *selectedChordArray;
@property (nonatomic, retain) AVAudioPlayer *player;
- (IBAction)playChord:(UIButton *)sender;

@end
