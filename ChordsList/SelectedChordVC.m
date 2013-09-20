//
//  SelectedChordVC.m
//  ChordsList
//
//  Created by Dmitiy on 9/16/13.
//  Copyright (c) 2013 Dmitiy. All rights reserved.
//

#import "SelectedChordVC.h"

@interface SelectedChordVC ()

@end

@implementation SelectedChordVC
#define kVisibleChordsNumber 10
#define kCarouselWidth 82
#define kCarouselHeight 100

@synthesize carousel;
@synthesize selectedChordArray;
@synthesize audioPlayer;
@synthesize audioPlayer2;

@synthesize chordName;
@synthesize audioPlayerArr;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) setup
{
    carousel.orientation = iCarouselOrientationVertical;
    carousel.type = iCarouselTypeLinear;
    
    if ([self.selectedChordArray count]) {
        Chord *firstChord = (Chord *)[self.selectedChordArray objectAtIndex:0];
        
        self.navigationItem.title = firstChord.name;
        self.chordNameLbl.text = firstChord.name;
        [self updateFretBoardWithChord:firstChord inView:self.fretBoardView];
        [self playSelectedChord:firstChord];
        UIView *curView=[self.carousel itemViewAtIndex:0];
        [curView setBordersColor:[UIColor greenColor]];
    }

}

-(void) viewWillAppear:(BOOL)animated
{
    //configure carousel
      [self setup];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.


}

#pragma mark Guitar Logic
-(NSDictionary *) detectBarreInChord:(Chord *) selectedChord
{
    int barreStartPos, barreEndPos;
        //detect barre, counting first  finger occurrences
    int firstFingerCount = [selectedChord.fingers length] - [[selectedChord.fingers stringByReplacingOccurrencesOfString:@"1" withString:@""] length];

    if (firstFingerCount>1) {
        NSString *justFingerNumberStr=[selectedChord.fingers stringByReplacingOccurrencesOfString:@" " withString:@""];
     
        selectedChord.barre=@1;
        
        barreStartPos=[justFingerNumberStr rangeOfString:@"1" options:NSLiteralSearch].location;
        barreEndPos=[justFingerNumberStr rangeOfString:@"1" options:NSBackwardsSearch].location;
        
        
        NSDictionary *barreStatus=@{@"start":[NSNumber numberWithInt: barreStartPos],
                                    @"end":[NSNumber numberWithInt: barreEndPos] };
        //NSLog(@"Barre %@",barreStatus);
         [DataManagerSharedInstance save];
        return barreStatus;
    }
    else
    {
        selectedChord.barre=@0;
        [DataManagerSharedInstance save];
        return nil;
    }
   
}

-(void) setMarkersCentersByChord:(Chord *) selectedChord inSchemeView:(SmallSchemeView *) view
{
    
    // counter of strings, 0- 6th string, 5th - first string
    int fretY=0,stringX=0;
    int shiftX=10,shiftY=12,startX=16,startY=40 ;
    int radius=5;
    
    BOOL hasBarre=NO;
    if (selectedChord.fingers)
    {
        
        NSDictionary *barreDict = [self detectBarreInChord:selectedChord];
        if (barreDict) {
            //draw barre
            int barreStartPos = [[barreDict objectForKey:@"start"] integerValue],
                barreEndPos   = [[barreDict objectForKey:@"end"] integerValue];
            CGPoint startBarrePoint=CGPointMake(startX + barreStartPos*shiftX, startY+fretY*shiftY);
            [view createBarreAtStartPoint:startBarrePoint andRadius:radius withWidth:(barreEndPos-barreStartPos+1)*shiftX];
            hasBarre=YES;
        }
    }
    
    NSArray *schemeArr=[selectedChord.scheme componentsSeparatedByString:@" "];
    //NSLog(@"scheme array %@",schemeArr);
    
    for (NSString *fretEnum in schemeArr) {
        
        if ([fretEnum isEqualToString:@"X"] || [fretEnum isEqualToString:@"x"]) {
            //closed string, don't draw
        }
        else if ([fretEnum isEqualToString:@"0"])
        {
            CGPoint centerPoint=CGPointMake(startX + stringX*shiftX, startY-shiftY/2);
            [view createMarkerAtCenter:centerPoint withRadius:2];
            
        }
        else if ([fretEnum integerValue])
        {
            if (hasBarre && ([fretEnum integerValue] == selectedChord.fret.integerValue)) {
                //skip barre finger
            }
            else
            {
                int startPos = [selectedChord.fret integerValue];
                fretY = [[schemeArr objectAtIndex:stringX] integerValue] - startPos;
                CGPoint centerPoint=CGPointMake(startX + stringX*shiftX, startY+fretY*shiftY);
                [view createMarkerAtCenter:centerPoint withRadius:radius];
            }
        }
        
        stringX++;
    }
    
}

#pragma mark fretboard methods

-(void) updateFretBoardWithChord:(Chord *) selectedChord inView:(UIView *) view
{
    [view removeAllMarkers]; // from previous chord
    self.fretLabel.text=[NSString romanianStringForObjectValue:selectedChord.fret];
    
    // counter of strings, 0- 6th string, 5th - first string
    int fretY=0,stringX=0;
    int shiftX=170/5,shiftY=320/5,
        startX=27,startY=42 ;
    int radius=12;          //market radius
    int imageFretRange=5; //how many frets could be displayed on image at once
    
    NSArray *fretBoardWhiteMarkersArr=@[@3,@5,@7,@9,@15,@17,@21];
    NSMutableArray *drawingWhiteMarkersArr=[[NSMutableArray alloc] init];
    int displayMin=[selectedChord.fret integerValue], displayMax=displayMin+imageFretRange;
    
    //draw only 12 fret with 2 white points
    if (displayMin>=7) {
       
        fretY = 12-displayMin;
        if (fretY<imageFretRange) {
            CGPoint centerPoint=CGPointMake(startX + 1.5*shiftX, startY+fretY*shiftY);
            [view createFreatBoardWhiteMarkersAtCenter:centerPoint withRadius:radius ];
            CGPoint centerPoint2=CGPointMake(startX + 3.5*shiftX, startY+fretY*shiftY);
            [view createFreatBoardWhiteMarkersAtCenter:centerPoint2 withRadius:radius ];
        }
    }
    
    for (NSNumber *numb in fretBoardWhiteMarkersArr) {
        if ((numb.integerValue >= displayMin) && (numb.integerValue < displayMax)) {
            NSNumber *drawNumb=[NSNumber numberWithInt:(numb.integerValue-displayMin)];
            [drawingWhiteMarkersArr addObject:drawNumb];
        }
    }
    
    for (NSNumber *drawNumb in drawingWhiteMarkersArr)
    {
         //int startPos = [selectedChord.fret integerValue];
         fretY = drawNumb.integerValue;
         CGPoint centerPoint=CGPointMake(startX + 2.5*shiftX, startY+fretY*shiftY);
         [view createFreatBoardWhiteMarkersAtCenter:centerPoint withRadius:radius ];
    }
    
    
    fretY=0;
    BOOL hasBarre=NO;
    if (selectedChord.fingers)
    {
        
        NSDictionary *barreDict = [self detectBarreInChord:selectedChord];
        if (barreDict) {
            //draw barre
            int barreStartPos = [[barreDict objectForKey:@"start"] integerValue],
            barreEndPos   = [[barreDict objectForKey:@"end"] integerValue];
            CGPoint startBarrePoint=CGPointMake(startX + barreStartPos*shiftX, startY+fretY*shiftY);
            [view createBarreAtStartPoint:startBarrePoint andRadius:radius withWidth:(barreEndPos-barreStartPos+1)*shiftX];
            hasBarre=YES;
        }
    }
    
    NSArray *schemeArr=[selectedChord.scheme componentsSeparatedByString:@" "];
    NSArray *putFinger=[selectedChord.fingers componentsSeparatedByString:@" "];
    NSLog(@"put finher %@ %@",putFinger,selectedChord);

    for (NSString *fretEnum in schemeArr) {
        
        if ([fretEnum isEqualToString:@"X"] || [fretEnum isEqualToString:@"x"]) {
            //closed string, don't draw
        }
        else if ([fretEnum isEqualToString:@"0"])
        {
            CGPoint centerPoint=CGPointMake(startX + stringX*shiftX, startY-shiftY/2);
            [view createMarkerAtCenter:centerPoint withRadius:7];
            
        }
        else if ([fretEnum integerValue])
        {
            if (hasBarre && ([fretEnum integerValue] == selectedChord.fret.integerValue)) {
                //skip blue marker for barre, already drwaed
                int startPos = [selectedChord.fret integerValue];
                fretY = [[schemeArr objectAtIndex:stringX] integerValue] - startPos;
                CGPoint centerPoint=CGPointMake(startX + stringX*shiftX, startY+fretY*shiftY);
                if ([putFinger count]>stringX) {
                    [view createMarkerAtCenter:centerPoint withRadius:radius andFingerNumber:(NSString*)[putFinger objectAtIndex:stringX]];
                }
                
            }
            else
            {
                int startPos = [selectedChord.fret integerValue];
                fretY = [[schemeArr objectAtIndex:stringX] integerValue] - startPos;
                CGPoint centerPoint=CGPointMake(startX + stringX*shiftX, startY+fretY*shiftY);
                if ([putFinger count]>stringX) {
                    [view createMarkerAtCenter:centerPoint withRadius:radius andFingerNumber:(NSString*)[putFinger objectAtIndex:stringX]];
                }
                else
                {
                    [view createMarkerAtCenter:centerPoint withRadius:radius];
                }
            }
        } 
        stringX++;
    }

}

-(void) updateBorderColorsInSchemeWithSelectedIndex:(NSInteger) index
{
    for (UIView *view in [self.carousel visibleItemViews])
    {
        [view setBordersColor:[UIColor clearColor]];
    }
    UIView *currentView=[self.carousel itemViewAtIndex:index];
    [currentView setBordersColor:[UIColor greenColor]];
}

#pragma mark AudioPlaying Methods
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)playerEnd successfully:(BOOL)flag {
    [self.audioPlayerArr removeObject:playerEnd];
}

-(void) playSelectedChord:(Chord *) chord
{
    //not sure about dictionary with open strings mids - use 3 image to create it
    NSDictionary *midiDict=@{@"0":@52,
                            @"1":@47,
                            @"2":@43,
                            @"3":@38,
                            @"4":@33,
                            @"5":@28};
    
    NSArray *schemeArr=[chord.scheme componentsSeparatedByString:@" "];
    NSMutableArray *playingMidiArr=[[NSMutableArray alloc] init];
    
    //in scheme order starts from 6 strin, so going backwords by strings
    int stringX=5;
    for (NSString *fretEnum in schemeArr)
    {
        
        if ([fretEnum isEqualToString:@"X"] || [fretEnum isEqualToString:@"x"]) {
            //don't play this string
        }
        else
        {
            NSNumber *openStringID=[midiDict objectOrNilForKey:[NSString stringWithFormat:@"%d",stringX]];
            if (openStringID)
            {
                NSInteger playingFretId=[fretEnum integerValue]+[openStringID integerValue];
                if (playingFretId>70)
                    playingFretId-=12; //- have sounds only to 18fret of 1st string, so after 70th midi play lower note
                
                NSNumber *midiNumb=[NSNumber numberWithInt:playingFretId];
                [playingMidiArr addObject:midiNumb];
            }
        }
        stringX--;
    }
    
    //NSLog(@"Preparing to play midis %@",playingMidiArr);
    
    self.audioPlayerArr = [[NSMutableArray alloc] init];
    stringX=0;
    float delayBetweenPlayers=.25;
    
    for (NSNumber *midiNum in playingMidiArr)
    {
        NSString *filePath= [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d",midiNum.integerValue] ofType:@"dat"];

        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSURL *sound_file = [[NSURL alloc] initFileURLWithPath:filePath];
            AVAudioPlayer *player1 = [[AVAudioPlayer alloc] initWithContentsOfURL:sound_file error:nil];
            if (player1) {
                player1.delegate=self;
                [audioPlayerArr addObject:player1];
                [player1 prepareToPlay];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, stringX * delayBetweenPlayers * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
                    [player1 play];
                    //NSLog(@"Playing %@",sound_file.path);
                });
                stringX++;
            }
        }
    }
    
}

- (IBAction)playChord:(UIButton *)sender {
    [self playSelectedChord:[selectedChordArray objectAtIndex:self.carousel.currentItemIndex]];
}

#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    if ([self.selectedChordArray count]) {
        return [self.selectedChordArray count];
    }
    else return 0;
    
}

-(UIView *) createSmallSchemeAtIndex:(NSUInteger)index
{
   
       if (index<[selectedChordArray count]) {
        Chord *thisChord=[selectedChordArray objectAtIndex:index];
        //NSLog(@"%@ %d",thisChord,index);
        
        SmallSchemeView *smallSch=[[SmallSchemeView alloc] init];
        smallSch.fretLbl.text = [NSString stringWithFormat:@"Fret %@",[NSString romanianStringForObjectValue:thisChord.fret]];
        
        smallSch.schemeLbl.text = thisChord.scheme;
        [self setMarkersCentersByChord:thisChord inSchemeView:smallSch];
        [smallSch setBordersColor:[UIColor clearColor]];

        return smallSch;

    }
    else return nil;
   
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index
{
    return [self createSmallSchemeAtIndex:index];
}

- (NSUInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel
{
	//note: placeholder views are only displayed on some carousels if wrapping is disabled
	return 1;
}

- (UIView *)carousel:(iCarousel *)carousel placeholderViewAtIndex:(NSUInteger)index
{
    
    return nil;//[self createSmallSchemeAtIndex:index];
}

- (NSUInteger)numberOfVisibleItemsInCarousel:(iCarousel *)carousel
{
    //limit the number of items views loaded concurrently (for performance reasons)
    return kVisibleChordsNumber;
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel
{
    //slightly wider than item view
    return kCarouselWidth;
}

- (CGFloat)carouselItemHeight:(iCarousel *)carousel
{
    //slightly taller than item view
    return kCarouselHeight;
}

- (CATransform3D)carousel:(iCarousel *)_carousel transformForItemView:(UIView *)view withOffset:(CGFloat)offset
{
    //implement 'flip3D' style carousel
    
    //set opacity based on distance from camera
    view.alpha = 1.0 - fminf(fmaxf(offset, 0.0), 1.0);
    
    CGFloat itemLinearSize = (iCarouselOrientationHorizontal == _carousel.orientation) ? carousel.itemWidth : carousel.itemHeight;
    //do 3d transform
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = self.carousel.perspective;
    transform = CATransform3DRotate(transform, M_PI / 8.0, 0, 1.0, 0);
    return CATransform3DTranslate(transform, 0.0, 0.0, offset * itemLinearSize);
}

- (void)carouselWillBeginDragging:(iCarousel *)carousel
{
	//NSLog(@"Carousel will begin dragging");
}

- (void)carouselDidEndDragging:(iCarousel *)carousel willDecelerate:(BOOL)decelerate
{
	//NSLog(@"Carousel did end dragging and %@ decelerate", decelerate? @"will": @"won't");
}

- (void)carouselWillBeginDecelerating:(iCarousel *)carousel
{
	//NSLog(@"Carousel will begin decelerating");
}

- (void)carouselDidEndDecelerating:(iCarousel *)carousel
{
	//NSLog(@"Carousel did end decelerating");
}

- (void)carouselWillBeginScrollingAnimation:(iCarousel *)carousel
{
	//NSLog(@"Carousel will begin scrolling");
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)iCarousel
{
	NSLog(@"Carousel did end scrolling, update fretboard index %d",iCarousel.currentItemIndex);
   // [self updateFretBoardWithChord:[self.selectedChordArray objectAtIndex:iCarousel.currentItemIndex] inView:self.fretBoardView];
    
}

- (void)carousel:(iCarousel *)_carousel didSelectItemAtIndex:(NSInteger)index
{
    
    Chord *thisChord=[self.selectedChordArray objectAtIndex:index];
    [self updateFretBoardWithChord:thisChord inView:self.fretBoardView];
    [self playSelectedChord:thisChord];
 
    [self updateBorderColorsInSchemeWithSelectedIndex:index];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setChordNameLbl:nil];
    [self setFretBoardView:nil];
    [self setFretLabel:nil];
    [super viewDidUnload];
}



@end
