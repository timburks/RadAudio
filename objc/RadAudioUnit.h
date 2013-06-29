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
}
- (id) initWithGraph:(AUGraph) owningGraph;
- (AudioUnit) audioUnit;

- (RadAudioFormat *) formatForInput:(int) inputNumber;
- (RadAudioFormat *) formatForInput;
- (RadAudioFormat *) formatForOutput;

- (void) setFormat:(RadAudioFormat *) format forInput:(int) inputNumber;
- (void) setFormat:(RadAudioFormat *) format forOutput:(int) outputNumber;
@end

@interface RadAudioFilePlayerUnit : RadAudioUnit
{
    AudioFileID inputFile;
    UInt64 nPackets;
    AudioStreamBasicDescription inputFormat;
}
- (void) prepareWithFile:(NSString *) filename;
- (Float64) duration;
- (void) closeFile;
@end

typedef OSStatus (^RadRenderProc)(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData);

@interface RadAudioToneGeneratorUnit : RadAudioUnit
@property (nonatomic, assign) int startingPhase;
@property (nonatomic, assign) double frequency;
@property (nonatomic, copy) RadRenderProc renderer;
- (void) prepare;
@end

@interface RadAudioReverbUnit : RadAudioUnit
- (void) setReverbRoomType:(UInt32) reverbRoomType;
@end

@interface RadAudioMixerUnit : RadAudioUnit
- (void) setNumberOfInputs:(int) numberOfInputs;
- (void) setVolume:(float) volume forInput:(int) inputChannel;
- (void) setOutputVolume:(float) volume;
@end
