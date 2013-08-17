#import <Foundation/Foundation.h>



#import "RadAudioUnit.h"

@class RadAudioSFXRTone;

@interface RadAudioSFXRUnit : RadAudioUnit

@property (nonatomic, strong) RadAudioSFXRTone *tone;

- (void) prepare;

// play current sound
- (void) playSample;

@end
