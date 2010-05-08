//
//  Note.h
//  edenx
//
//  Created by Guillaume Laurent on 3/20/10.
//  Copyright 2010 telegraph-road.org. All rights reserved.
//  Copyright 2000-2009 the Rosegarden development team.
//

#import <Cocoa/Cocoa.h>

typedef int NoteType;

static const NoteType

SixtyFourthNote     = 0,
ThirtySecondNote    = 1,
SixteenthNote       = 2,
EighthNote          = 3,
QuarterNote         = 4,
HalfNote            = 5,
WholeNote           = 6,
DoubleWholeNote     = 7,

Hemidemisemiquaver  = 0,
Demisemiquaver      = 1,
Semiquaver          = 2,
Quaver              = 3,
Crotchet            = 4,
Minim               = 5,
Semibreve           = 6,
Breve               = 7,

Shortest            = 0,
Longest             = 7;


@interface Note : NSObject {

    NoteType type;
    int dots;
}

- (uint)duration;
- (id)initWithType:(NoteType)type withDots:(int)dots;
+ (Note*)noteWithType:(NoteType)type;
+ (Note*)noteWithType:(NoteType)type withDots:(int)dots;
+ (Note*)nearestNote:(uint)duration withMaxDots:(int)maxDots;

- (uint)durationAux;

@property (readonly) NoteType type;
@property (readonly) int dots;


@end
