//
//  RadAudioToneGeneratorUnit.h
//  RadAudio
//
//  Created by Michael Burks on 7/1/13.
//
//

#import "RadAudioUnit.h"

#define SINE_LOOKUP_INDEXES 1024
#define MAX_TONE_EVENTS 5

typedef enum {
	STATE_INACTIVE = 0,  //ToneEvent is not used for playing a tone
	STATE_ATTACK = 1,    //ToneEvent is begun
    STATE_DECAY = 2,
    STATE_SUSTAIN = 3,
	STATE_RELEASE = 4,   //ToneEvent is released and ringing out
} ToneEventState;

typedef struct {
	ToneEventState state; //the state of the tone
	float freq;           //frequency of the tone
	float phase;          //current step for the oscillator
    float adsr;           //multiplier based on position in adsr envelope
} ToneEvent;

typedef OSStatus (^RadRenderProc)(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData);

@interface RadAudioToneGeneratorUnit : RadAudioUnit {
    @public
    ToneEvent tones[MAX_TONE_EVENTS];
    float sineTable[SINE_LOOKUP_INDEXES];
}

//@property (nonatomic, assign) int startingPhase;
//@property (nonatomic, assign) double frequency;
@property (nonatomic, copy) RadRenderProc renderer;
- (void) prepare;

- (int)playFrequency:(double)freq; //returns the index of the toneEvent
- (void)stopToneEvent:(int)n;
- (void)stopToneEventWithObject:(NSNumber *)n;

@end