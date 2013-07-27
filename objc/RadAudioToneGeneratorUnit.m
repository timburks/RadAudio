//
//  RadAudioToneGeneratorUnit.m
//  RadAudio
//
//  Created by Michael Burks on 7/1/13.
//
//

#import <Accelerate/Accelerate.h>


#import "RadAudioToneGeneratorUnit.h"


@interface RadAudioToneGeneratorUnit ()
@end

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
    
    //NSLog(@"%f", inTimeStamp->mSampleTime);
    
    Float32 *leftChannel = (Float32 *)ioData->mBuffers[0].mData;
    Float32 *rightChannel = (Float32 *)ioData->mBuffers[1].mData;
    if (player.renderBlock) {
        player.renderBlock(inTimeStamp, inNumberFrames, leftChannel);
        player.renderBlock(inTimeStamp, inNumberFrames, rightChannel);
    }    
    return noErr;
}

#pragma mark callback function

- (id) initWithGraph:(AUGraph)owningGraph {
    if (self = [super initWithGraph:owningGraph]) {
        self.frequency = 880;
        
        self.renderBlock = ^(const AudioTimeStamp *time, int frames, float *output) {
            double cycleLength = 44100. / self.frequency;
            float step  = 2.0*M_PI/cycleLength;
            float start = time->mSampleTime * step;
            
            int bufferSize = frames;
            Float32 ramp[bufferSize];
            vDSP_vramp(&start, &step, ramp, 1, bufferSize);
            vvsinf(output, ramp, &bufferSize);
        };
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