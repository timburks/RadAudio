//
//  RadAudioMixerUnit.h
//  RadAudio
//
//  Created by Michael Burks on 7/1/13.
//
//

#import "RadAudioUnit.h"

@interface RadAudioMixerUnit : RadAudioUnit
- (void) setNumberOfInputs:(int) numberOfInputs;
- (void) setVolume:(float) volume forInput:(int) inputChannel;
- (void) setOutputVolume:(float) volume;
@end
