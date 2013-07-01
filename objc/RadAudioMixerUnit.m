//
//  RadAudioMixerUnit.m
//  RadAudio
//
//  Created by Michael Burks on 7/1/13.
//
//

#import "RadAudioMixerUnit.h"

@implementation RadAudioMixerUnit

- (void) setNumberOfInputs:(int) numberOfInputs
{
    UInt32 numbuses = numberOfInputs;
    UInt32 size = sizeof(numbuses);
    AudioUnitSetProperty([self audioUnit],
                         kAudioUnitProperty_ElementCount,
                         kAudioUnitScope_Input,
                         0,
                         &numbuses,
                         size);
}

- (void) setVolume:(float) volume forInput:(int) inputChannel
{
    AudioUnitSetParameter([self audioUnit],
                          kMultiChannelMixerParam_Volume,
                          kAudioUnitScope_Input,
                          inputChannel,
                          volume,
                          0);
}

- (void) setOutputVolume:(float) volume
{
    AudioUnitSetParameter([self audioUnit],
                          kMultiChannelMixerParam_Volume,
                          kAudioUnitScope_Output,
                          0,
                          volume,
                          0);
}
@end