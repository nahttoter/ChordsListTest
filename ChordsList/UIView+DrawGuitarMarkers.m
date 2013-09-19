//
//  UIView+DrawGuitarMarkers.m
//  ChordsList
//
//  Created by Dmitry on 18.09.13.
//  Copyright (c) 2013 Dmitiy. All rights reserved.
//

#import "UIView+DrawGuitarMarkers.h"
#define kMarkColor [UIColor blueColor]
#define kMarkersTag 11
@implementation UIView (DrawGuitarMarkers)
-(void) createMarkerAtCenter:(CGPoint) centerPoint withRadius:(int) radius
{
    CGRect frame=CGRectMake(0, 0, 2*radius, 2*radius);
    frame.origin.x=centerPoint.x-radius;
    frame.origin.y=centerPoint.y-radius;
    
    UIImageView *marker=[[UIImageView alloc] initWithFrame:frame];
    marker.clipsToBounds=YES;
    marker.layer.cornerRadius=radius;
    marker.backgroundColor=kMarkColor;
    marker.tag=kMarkersTag;
    [self addSubview:marker];
}

-(void) createBarreAtStartPoint:(CGPoint) centerPoint andRadius:(int) radius withWidth:(int) width
{
    CGRect frame=CGRectMake(0, 0, width, 2*radius);
    frame.origin.x=centerPoint.x-radius;
    frame.origin.y=centerPoint.y-radius;
    
    UIImageView *barre=[[UIImageView alloc] initWithFrame:frame];
    barre.clipsToBounds=YES;
    barre.layer.cornerRadius=radius;
    barre.backgroundColor=kMarkColor;
    barre.tag=kMarkersTag;
    [self addSubview:barre];
}

-(void) removeAllMarkers
{
    for (UIView *view in [self subviews]) {
        if (view.tag==kMarkersTag) {
            [view removeFromSuperview];
        }
    }

}

-(void) setBordersColor:(UIColor *) color
{
    self.layer.borderWidth=2;
    self.layer.borderColor=color.CGColor;
}

@end
