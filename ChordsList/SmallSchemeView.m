//
//  smallSchemeView.m
//  ChordsList
//
//  Created by Dmitry on 17.09.13.
//  Copyright (c) 2013 Dmitiy. All rights reserved.
//

#import "SmallSchemeView.h"

@implementation SmallSchemeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        self = [[[NSBundle mainBundle] loadNibNamed:@"smallSchemeView" owner:self options:nil] lastObject];
    }
    return self;
}

-(void) createMarkerAtCenter:(CGPoint) centerPoint withRadius:(int) radius
{
    CGRect frame=CGRectMake(0, 0, 2*radius, 2*radius);
    frame.origin.x=centerPoint.x-radius;
    frame.origin.y=centerPoint.y-radius;
    
    UIImageView *marker=[[UIImageView alloc] initWithFrame:frame];
    marker.clipsToBounds=YES;
    marker.layer.cornerRadius=radius;
    marker.backgroundColor=[UIColor blueColor];
    [self addSubview:marker];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
