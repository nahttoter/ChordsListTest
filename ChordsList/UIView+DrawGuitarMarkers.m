//
//  UIView+DrawGuitarMarkers.m
//  ChordsList
//
//  Created by Dmitry on 18.09.13.
//  Copyright (c) 2013 Dmitiy. All rights reserved.
//

#import "UIView+DrawGuitarMarkers.h"
#define kMarkColor [UIColor blueColor]
#define kWhiteColor [UIColor whiteColor]
#define kMarkersTag 11
@implementation UIView (DrawGuitarMarkers)

-(void) createImageMarkerWithFrame:(CGRect) frame andColor:(UIColor *) color
{
    UIImageView *marker=[[UIImageView alloc] initWithFrame:frame];
    marker.clipsToBounds=YES;
    marker.layer.cornerRadius=frame.size.height/2;
    marker.backgroundColor=color;
    marker.tag=kMarkersTag;
    [self addSubview:marker];
}

-(void) createMarkerAtCenter:(CGPoint) centerPoint withRadius:(int) radius
{
    CGRect frame=CGRectMake(0, 0, 2*radius, 2*radius);
    frame.origin.x=centerPoint.x-radius;
    frame.origin.y=centerPoint.y-radius;
    [self createImageMarkerWithFrame:frame andColor:kMarkColor];
}

-(void) createFreatBoardWhiteMarkersAtCenter:(CGPoint) centerPoint withRadius:(int) radius
{
    CGRect frame=CGRectMake(0, 0, 2*radius, 2*radius);
    frame.origin.x=centerPoint.x-radius;
    frame.origin.y=centerPoint.y-radius;
    
    [self createImageMarkerWithFrame:frame andColor:kWhiteColor];

}

-(void) createMarkerAtCenter:(CGPoint) centerPoint  withRadius:(int) radius andFingerNumber:(NSString*) fingerNumb
{
    [self createMarkerAtCenter:centerPoint withRadius:radius];
    
    CGRect frame=CGRectMake(0, 0, 2*radius, 2*radius);
    frame.origin.x=centerPoint.x-radius;
    frame.origin.y=centerPoint.y-radius;
    
    UILabel  * fingerLbl = [[UILabel alloc] initWithFrame:frame];
    fingerLbl.backgroundColor=[UIColor clearColor];
    fingerLbl.textColor=kWhiteColor;
    fingerLbl.text=fingerNumb;
    fingerLbl.tag=kMarkersTag;
    fingerLbl.textAlignment=UITextAlignmentCenter;
    [self addSubview:fingerLbl];
}


-(void) createBarreAtStartPoint:(CGPoint) centerPoint andRadius:(int) radius withWidth:(int) width
{
    CGRect frame=CGRectMake(0, 0, width, 2*radius);
    frame.origin.x=centerPoint.x-radius;
    frame.origin.y=centerPoint.y-radius;
    
    [self createImageMarkerWithFrame:frame andColor:kMarkColor];
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
