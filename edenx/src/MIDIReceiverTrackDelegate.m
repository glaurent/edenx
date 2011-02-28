//
//  MIDIReceiverTrackDelegate.m
//  edenx
//
//  Created by Guillaume Laurent on 9/20/09.
//  Copyright 2009 telegraph-road.org. All rights reserved.
//

#import <CoreAudio/CoreAudio.h>

#import "MIDIReceiverTrackDelegate.h"
#import "SMMessage.h"
#import "SMVoiceMessage.h"
#import "MyDocument.h"

#import "TracksController.h"

@implementation MIDIReceiverTrackDelegate

- (id)initWithTrack:(NSManagedObject<Segment>*)aSegment withStartTime:(MIDITimeStamp)startTime withMusicSequence:(MusicSequence)aSeq
{
    self = [super init];
    segment = aSegment;
    recordingStartTime = startTime;
    sequence = aSeq;
    return self; 
}

- (void)didReceiveMessage:(NSArray *)messages count:(unsigned int)count
{
    for(int i = 0; i < count; ++i, ++idx) {
        SMMessage* msg = [messages objectAtIndex:idx];
        NSLog(@"MIDIReceiverTrackDelegate : at %@ - type : %@ - %@", [msg timeStampForDisplay], [msg typeForDisplay], [msg dataForDisplay]);
        
        SMMessageType msgType = [msg messageType];
        
        if (msgType == SMMessageTypeNoteOn || msgType == SMMessageTypeNoteOff) {

            SMVoiceMessage* vmsg = (SMVoiceMessage*)msg;            
            
            // check if NoteOn and non-null velocity
            if (msgType == SMMessageTypeNoteOn && [vmsg dataByte2] != 0) {
                
                NSLog(@"MIDIReceiverTrackDelegate Got NoteOn - storing on table %@", vmsg);
                // store note on table
                table[ ([vmsg channel] - 1) * [vmsg dataByte1] ] = vmsg;                
                
            } else if (msgType == SMMessageTypeNoteOff ||
                       (msgType == SMMessageTypeNoteOn && [vmsg dataByte2] == 0)) {
                
                // find associated NoteOn
                
//                NSLog(@"MIDIReceiverTrackDelegate Got NoteOff - getting corresponding NoteOn");
                
                SMVoiceMessage* noteOnMsg = table[ ([vmsg channel] - 1) * [vmsg dataByte1] ];
                
                NSLog(@"MIDIReceiverTrackDelegate : noteOnMsg = %@", noteOnMsg);
                
                // clear table
                table[ ([vmsg channel] - 1) * [vmsg dataByte1] ] = 0;
                
                if (noteOnMsg != nil) {
                    MIDITimeStamp noteOffTimeStamp = [vmsg timeStamp];
                    MIDITimeStamp noteOnTimeStamp = [noteOnMsg timeStamp];
                    MusicTimeStamp noteOffMusicTimeStamp, noteOnMusicTimeStamp;
                    
                    MusicSequenceGetBeatsForSeconds(sequence, noteOnTimeStamp  / 1e9, &noteOnMusicTimeStamp);
                    MusicSequenceGetBeatsForSeconds(sequence, noteOffTimeStamp / 1e9, &noteOffMusicTimeStamp);
                    
                    MusicTimeStamp duration = noteOffMusicTimeStamp - noteOnMusicTimeStamp;
                    
                    
                    NSLog(@"MIDIReceiverTrackDelegate : duration = %f", duration);
                    
                    NSManagedObject<Note>* newNote = [NSEntityDescription insertNewObjectForEntityForName:@"Note" 
                                                                                   inManagedObjectContext:[segment managedObjectContext]];
                    
                    [newNote setDuration:[NSNumber numberWithDouble:duration]];
                    [newNote setNote:[NSNumber numberWithUnsignedInt:[vmsg dataByte1]]];
                    [newNote setVelocity:[NSNumber numberWithUnsignedInt:[noteOnMsg dataByte2]]];
                    MusicTimeStamp timeStamp;
                    MusicSequenceGetBeatsForSeconds(sequence, (AudioGetCurrentHostTime() - recordingStartTime) / 1e9, &timeStamp);
                    [newNote setAbsoluteTime:[NSNumber numberWithDouble:timeStamp]];
                     
                    NSLog(@"MIDIReceiverTrackDelegate : recording %@", newNote);
//                  NSLog(@"MIDIReceiverTrackDelegate - events = %@ , nb events = %d", trackEventsSet, [trackEventsSet count]);
                    
                    [segment addEventsObject:newNote];
                    
                } else {
                    NSLog(@"Couldn't find an associated NoteOn for this NoteOff event %@", vmsg);
                }
                
                
            }

            
        } // end if msgType == Note

    }
    
}

- (void)reset
{
    idx = 0;
    memset(table, 0, tablesize * sizeof(id));
}

@end
