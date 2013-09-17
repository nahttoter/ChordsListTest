//
//  smallSchemeView.h
//  ChordsList
//
//  Created by Dmitry on 17.09.13.
//  Copyright (c) 2013 Dmitiy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SmallSchemeView : UIView
@property (strong, nonatomic) IBOutlet UILabel *fretLbl;
@property (strong, nonatomic) IBOutlet UILabel *schemeLbl;

-(void) createMarkerAtCenter:(CGPoint) centerPoint withRadius:(int) radius;
-(void) createBarreAtStartPoint:(CGPoint) centerPoint andRadius:(int) radius withWidth:(int) width;

@end
