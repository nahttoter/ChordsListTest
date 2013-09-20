//
//  UIView+DrawGuitarMarkers.h
//  ChordsList
//
//  Created by Dmitry on 18.09.13.
//  Copyright (c) 2013 Dmitiy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@interface UIView (DrawGuitarMarkers)

-(void) createMarkerAtCenter:(CGPoint) centerPoint withRadius:(int) radius;
-(void) createMarkerAtCenter:(CGPoint) centerPoint withRadius:(int) radius andFingerNumber:(NSString*) fingerNumb;

-(void) createBarreAtStartPoint:(CGPoint) centerPoint andRadius:(int) radius withWidth:(int) width;
-(void) createFreatBoardWhiteMarkersAtCenter:(CGPoint) centerPoint withRadius:(int) radius;

-(void) removeAllMarkers;
-(void) setBordersColor:(UIColor *) color;
@end
