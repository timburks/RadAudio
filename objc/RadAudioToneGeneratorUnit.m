//
//  RadAudioToneGeneratorUnit.m
//  RadAudio
//
//  Created by Michael Burks on 7/1/13.
//
//

#import "RadAudioToneGeneratorUnit.h"

@implementation RadAudioToneGeneratorUnit

OSStatus RadAudioToneGeneratorUnitRenderProc(void *inRefCon,
                                             AudioUnitRenderActionFlags *ioActionFlags,
                                             const AudioTimeStamp *inTimeStamp,
                                             UInt32 inBusNumber,
                                             UInt32 inNumberFrames,
                                             AudioBufferList *ioData) {
    RadAudioToneGeneratorUnit *player = (__bridge RadAudioToneGeneratorUnit *)inRefCon;
    //    printf ("ToneGeneratorRenderProc needs %ld frames at %f\n",
    //            (unsigned long) inNumberFrames, CFAbsoluteTimeGetCurrent());
    
    double cycleLength = 44100. / player.frequency;
    CGFloat step  = 2*M_PI/cycleLength;
    CGFloat start = player.startingPhase * step;
    Float32 *leftChannel = (Float32 *)ioData->mBuffers[0].mData;
    Float32 *rightChannel = (Float32 *)ioData->mBuffers[1].mData;
    
#define SINE
#ifdef SINE
    for (int frame = 0; frame < inNumberFrames; frame++) {
        Float32 value = (Float32) sin(frame*step+start);
        leftChannel[frame] = value;
        rightChannel[frame] = value;
    }
#else
    for (int frame = 0; frame < inNumberFrames; frame++) {
        Float32 value = (Float32) sin(frame*step+start);
        if (value > 0) value = 1;
        else value = -1;
        leftChannel[frame] = value;
        rightChannel[frame] = value;
    }
#endif
    
    player.startingPhase += inNumberFrames;
    return noErr;
}

#pragma mark callback function

- (id) init {
    if (self = [super init]) {
        self.frequency = 880;
        self.startingPhase = 0;
    }
    return self;
}

- (void) prepare
{
    AURenderCallbackStruct input;
    input.inputProc = RadAudioToneGeneratorUnitRenderProc;
    input.inputProcRefCon = (__bridge void *) self;
    CheckError(AudioUnitSetProperty([self audioUnit],
                                    kAudioUnitProperty_SetRenderCallback,
                                    kAudioUnitScope_Input,
                                    0,
                                    &input,
                                    sizeof(input)),
               "AudioUnitSetProperty failed");
}
@end