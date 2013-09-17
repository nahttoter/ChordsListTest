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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //configure carousel
    carousel.orientation = iCarouselOrientationVertical;
    carousel.type = iCarouselTypeLinear;
    
    NSLog(@"%@",selectedChordArray);
    Chord *lastChord=(Chord *)[self.selectedChordArray lastObject];
    self.navigationItem.title=lastChord.name;
    self.chordNameLbl.text=lastChord.name;
    //navItem.title = @"Custom";

}

#pragma mark -
#pragma mark iCarousel methods

-(void) setMarkersCentersByChord:(Chord *) selectedChord inView:(SmallSchemeView *) view
{
    
    NSArray *schemeArr=[selectedChord.scheme componentsSeparatedByString:@" "];
    
    int fretY=0,stringX=0; // counter of strings, 0- 6th string, 5th - first string
    int shiftX=10,shiftY=12,startX=16,startY=40 ;
    
    int radius=5;
    
    for (NSString *fert in schemeArr) {
        
        if ([fert isEqualToString:@"X"]) {
            fretY=0;
            //CGPoint centerPoint=CGPointMake(startX + stringX*shiftX, startY+fretY*shiftY);
            //[view createMarkerAtCenter:centerPoint withRadius:0];
        }
        else if ([fert isEqualToString:@"0"])
        {
            CGPoint centerPoint=CGPointMake(startX + stringX*shiftX, startY-shiftY/2);
            [view createMarkerAtCenter:centerPoint withRadius:2];
            
        }
        else
        {
            int startPos = [selectedChord.fret integerValue];
            fretY = [[schemeArr objectAtIndex:stringX] integerValue] - startPos;
            CGPoint centerPoint=CGPointMake(startX + stringX*shiftX, startY+fretY*shiftY);
            [view createMarkerAtCenter:centerPoint withRadius:radius];
        }
        
        stringX++;
        
    }
    
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [selectedChordArray count];
}

-(UIView *) createSmallSchemeAtIndex:(NSUInteger)index
{
   
    if (index<[selectedChordArray count]) {
        Chord *thisChord=[selectedChordArray objectAtIndex:index];
         NSLog(@"%@ %d",thisChord,index);
        
        SmallSchemeView *smallSch=[[SmallSchemeView alloc] init];
        smallSch.fretLbl.text = [NSString stringWithFormat:@"Fret %d",[thisChord.fret integerValue]];
        smallSch.schemeLbl.text = thisChord.scheme;
        [self setMarkersCentersByChord:thisChord inView:smallSch];
        
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
    
	//create a placeholder view
//	UIView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"page.png"]];
//	UILabel *label = [[UILabel alloc] initWithFrame:view.bounds] ;
//	label.text = (index == 0)? @"[": @"]";
//	label.backgroundColor = [UIColor clearColor];
//	label.textAlignment = UITextAlignmentCenter;
//	label.font = [label.font fontWithSize:12];
//	[view addSubview:label];
//	return view;
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

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel
{
	//NSLog(@"Carousel did end scrolling");
}

- (void)carousel:(iCarousel *)_carousel didSelectItemAtIndex:(NSInteger)index
{
	if (index == carousel.currentItemIndex)
	{
		//note, this will only ever happen if USE_BUTTONS == NO
		//otherwise the button intercepts the tap event
		NSLog(@"Selected current item");
	}
	else
	{
		NSLog(@"Selected item number %i", index);
	}
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setChordNameLbl:nil];
    [super viewDidUnload];
}
@end
