//
//  RadAudioUnit.h
//  AUFilePlayer
//
//  Created by Tim Burks on 6/28/13.
//
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@protocol AudioObserver <NSObject>
- (void) tick:(int) time;
@end


// we have to put this somewhere
void CheckError(OSStatus error, const char *operation);

typedef OSStatus (^RadRenderProc)(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData);

typedef void(^RenderBlock)(const AudioTimeStamp *time, int frames, float *output);

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
@property (nonatomic, weak) id<AudioObserver> observer;

- (id) initWithGraph:(AUGraph) owningGraph;
- (AudioUnit) audioUnit;

- (RadAudioFormat *) formatForInput:(int) inputNumber;
- (RadAudioFormat *) formatForInput;
- (RadAudioFormat *) formatForOutput;

- (void) setFormat:(RadAudioFormat *) format forInput:(int) inputNumber;
- (void) setFormat:(RadAudioFormat *) format forOutput:(int) outputNumber;
@end