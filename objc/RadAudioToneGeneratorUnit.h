//
//  RadAudioToneGeneratorUnit.h
//  RadAudio
//
//  Created by Michael Burks on 7/1/13.
//
//

#import "RadAudioUnit.h"


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