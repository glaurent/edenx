//
//  Note.m
//  edenx
//
//  Created by Guillaume Laurent on 3/20/10.
//  Copyright 2010 telegraph-road.org. All rights reserved.
//  Copyright 2000-2009 the Rosegarden development team.
//

#import "Note.h"

static const unsigned int shortestTime = 960 / 16;
//static const NoteType
//
//SixtyFourthNote     = 0,
//ThirtySecondNote    = 1,
//SixteenthNote       = 2,
//EighthNote          = 3,
//QuarterNote         = 4,
//HalfNote            = 5,
//WholeNote           = 6,
//DoubleWholeNote     = 7,
//
//Hemidemisemiquaver  = 0,
//Demisemiquaver      = 1,
//Semiquaver          = 2,
//Quaver              = 3,
//Crotchet            = 4,
//Minim               = 5,
//Semibreve           = 6,
//Breve               = 7,
//
//Shortest            = 0,
//Longest             = 7;

@implementation Note

- (id)initWithType:(NoteType)t withDots:(int)d
{
    self = [super init];
    if (self) {
        type = t;
        dots = d;
    }
    return self;        
}

+ (Note*)noteWithType:(NoteType)t
{
    self = [[Note alloc] initWithType:t withDots:0];
    return self;
}

+ (Note*)noteWithType:(NoteType)t withDots:(int)d
{
    self = [[Note alloc] initWithType:t withDots:d];
    return self;
}


- (uint)duration
{
    return (dots) ? [self durationAux] : shortestTime * (1 << type);
}

- (uint)durationAux
{
    int duration = shortestTime * (1 << type);
    int extra = duration / 2;
    for (int lDots = dots; lDots > 0; --lDots) {
        duration += extra;
        extra /= 2;
    }
    
    return duration;
}

+ (Note*)nearestNote:(uint)duration withMaxDots:(int)maxDots
{
    int tag = Shortest - 1;
    uint d = (duration / shortestTime);
    while (d > 0) { ++tag; d /= 2; }
    
    //    cout << "Note::getNearestNote: duration " << duration <<
    //      " leading to tag " << tag << endl;
    if (tag < Shortest) return [Note noteWithType:Shortest];
    if (tag > Longest)  return [Note noteWithType:Longest withDots:maxDots];
    
    uint prospective = [[Note noteWithType:tag withDots:0] duration];
    int dots = 0;
    uint extra = prospective / 2;
    
    while (dots <= maxDots &&
           dots <= tag) { // avoid TooManyDots exception from Note ctor
        prospective += extra;
        if (prospective > duration) return [Note noteWithType:tag withDots:dots];
        extra /= 2;
        ++dots;
        //      cout << "added another dot okay" << endl;
    }
    
    if (tag < Longest) return [Note noteWithType:(tag + 1) withDots:0];
    else return [Note noteWithType:tag withDots:((maxDots > tag) ? maxDots : tag)];
    
}


@synthesize type;
@synthesize dots;

@end
