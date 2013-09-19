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

@property (nonatomic, assign) NSString * fingers;
@property (nonatomic, assign) NSNumber * idChord;
@property (nonatomic, assign) NSString * name;
@property (nonatomic, assign) NSNumber * priority;
@property (nonatomic, assign) NSString * scheme;
@property (nonatomic, assign) NSString * type;
@property (nonatomic, assign) NSNumber * barre;
@property (nonatomic, assign) NSNumber * fret;
-(void) updateChordWithDictionary:(NSDictionary *) chordDictionary;

@end
