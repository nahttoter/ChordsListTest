//
//  Chord.m
//  ChordsList
//
//  Created by Dmitry on 16.09.13.
//  Copyright (c) 2013 Dmitiy. All rights reserved.
//

#import "Chord.h"


@implementation Chord

@dynamic fingers;
@dynamic idChord;
@dynamic name;
@dynamic priority;
@dynamic scheme;
@dynamic type;

-(void) updateChordWithDictionary:(NSDictionary *) chordDictionary
{
    self.fingers = [chordDictionary objectOrNilForKey:@"fingers"];
    self.idChord = [chordDictionary objectOrNilForKey:@"id"];
    self.name    = [chordDictionary objectOrNilForKey:@"name"];
    self.priority= [chordDictionary objectOrNilForKey:@"priority"];
    self.scheme  = [chordDictionary objectOrNilForKey:@"scheme"];
    self.type    = [chordDictionary objectOrNilForKey:@"type"];
}

@end
