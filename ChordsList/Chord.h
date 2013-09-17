//
//  Chord.h
//  ChordsList
//
//  Created by Dmitry on 17.09.13.
//  Copyright (c) 2013 Dmitiy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSDictionary+Parsing.h"

@interface Chord : NSManagedObject

@property (nonatomic, retain) NSString * fingers;
@property (nonatomic, retain) NSNumber * idChord;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) NSString * scheme;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * barre;
@property (nonatomic, retain) NSNumber * fret;
-(void) updateChordWithDictionary:(NSDictionary *) chordDictionary;

@end
