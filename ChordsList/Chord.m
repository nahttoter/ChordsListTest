//
//  Chord.m
//  ChordsList
//
//  Created by Dmitry on 17.09.13.
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
@dynamic barre;
@dynamic fret;


-(void) updateChordWithDictionary:(NSDictionary *) chordDictionary
{
    self.fingers = [chordDictionary objectOrNilForKey:@"fingers"];
    self.idChord = [chordDictionary objectOrNilForKey:@"id"];
    self.name    = [chordDictionary objectOrNilForKey:@"name"];
    self.priority= [chordDictionary objectOrNilForKey:@"priority"];
    self.scheme  = [chordDictionary objectOrNilForKey:@"scheme"];
    self.type    = [chordDictionary objectOrNilForKey:@"type"];
  
    if (self.scheme) {
        [self calculateFret];  
    }
    
}

//in my logic - fret lowest value in scheme, except 0 and X
-(void) calculateFret
{
    NSArray *schemeArr=[self.scheme componentsSeparatedByString:@" "];;  
    NSNumber *lowestNumber= [schemeArr valueForKeyPath:@"@max.intValue"];
    int lowestInt=[lowestNumber integerValue];
    for (NSNumber *theNumber in schemeArr)
    {
        if ( (lowestInt > [theNumber integerValue]) && ([theNumber integerValue] > 0) )
        {
            lowestInt = [theNumber integerValue];
            }
    }
    self.fret=[NSNumber numberWithInt:lowestInt];

}

@end
