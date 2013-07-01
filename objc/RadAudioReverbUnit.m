//
//  RadAudioReverbUnit.m
//  RadAudio
//
//  Created by Michael Burks on 7/1/13.
//
//

#import "RadAudioReverbUnit.h"

@implementation RadAudioReverbUnit
- (void) setReverbRoomType:(UInt32) reverbRoomType
{
    AudioUnit reverbUnit = [self audioUnit];
    UInt32 roomType = reverbRoomType;
    CheckError(AudioUnitSetProperty(reverbUnit,
                                    kAudioUnitProperty_ReverbRoomType,
                                    kAudioUnitScope_Global,
                                    0,
                                    &roomType,
                                    sizeof(UInt32)),
               "AudioUnitSetProperty[kAudioUnitProperty_ReverbRoomType] failed");
}
@end
