//
//  RadAudioUnit.h
//  AUFilePlayer
//
//  Created by Tim Burks on 6/28/13.
//
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

// we have to put this somewhere
void CheckError(OSStatus error, const char *operation);

@interface RadAudioFormat : NSObject
{
@public
    AudioStreamBasicDescription format;
}

@end

@interface RadAudioUnit : NSObject
{
@public // temporary
    AUGraph graph;
    AUNode audioUnitNode;
    AudioUnit audioUnit;
    BOOL playing;
}
- (id) initWithGraph:(AUGraph) owningGraph;
- (AudioUnit) audioUnit;

- (RadAudioFormat *) formatForInput:(int) inputNumber;
- (RadAudioFormat *) formatForInput;
- (RadAudioFormat *) formatForOutput;

- (void) setFormat:(RadAudioFormat *) format forInput:(int) inputNumber;
- (void) setFormat:(RadAudioFormat *) format forOutput:(int) outputNumber;
@end