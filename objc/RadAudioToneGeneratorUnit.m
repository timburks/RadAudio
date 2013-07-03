//
//  RadAudioToneGeneratorUnit.m
//  RadAudio
//
//  Created by Michael Burks on 7/1/13.
//
//

#import "RadAudioToneGeneratorUnit.h"

const float ATTACK_TIME = 0.03f;
const float DECAY_TIME = 0.2f;
const float RELEASE_TIME = 0.1f;
const float ATTACK_HEIGHT = 1.0f;
const float SUSTAIN_HEIGHT = 0.9f;

@implementation RadAudioToneGeneratorUnit

OSStatus RadAudioToneGeneratorUnitRenderProc(void *inRefCon,
                                             AudioUnitRenderActionFlags *ioActionFlags,
                                             const AudioTimeStamp *inTimeStamp,
                                             UInt32 inBusNumber,
                                             UInt32 inNumberFrames,
                                             AudioBufferList *ioData) {
    RadAudioToneGeneratorUnit *player = (__bridge RadAudioToneGeneratorUnit *)inRefCon;
    
    for (int frame = 0; frame < inNumberFrames; frame++) {
        
        float m = 0.0f;  // the mixed value for this frame
        for (int n = 0; n < MAX_TONE_EVENTS; ++n)
        {
            if (player->tones[n].state == STATE_INACTIVE)  //filter out inactive tones
                continue;
            
            int x = SINE_LOOKUP_INDEXES*player->tones[n].phase/44100.0;
            if ((x < 0) || (x >= SINE_LOOKUP_INDEXES)) {
                NSLog(@"oops %d", x);
            }
            
            float sineValue = player->sineTable[x];
            player->tones[n].phase += player->tones[n].freq;
            if ((player->tones[n].phase) >= 44100)
                player->tones[n].phase -= 44100;
            
            if (player->tones[n].state == STATE_ATTACK) {
                player->tones[n].adsr += ATTACK_HEIGHT/(ATTACK_TIME * 44100.0);
                if (player->tones[n].adsr >= ATTACK_HEIGHT) {
                    player->tones[n].state = STATE_DECAY;
                }
            }
            
            if (player->tones[n].state == STATE_DECAY) {
                player->tones[n].adsr -= (ATTACK_HEIGHT - SUSTAIN_HEIGHT)/(DECAY_TIME * 44100.0);
                if (player->tones[n].adsr <= SUSTAIN_HEIGHT) {
                    player->tones[n].state = STATE_SUSTAIN;
                }
            }
            
            if (player->tones[n].state == STATE_RELEASE) {
                player->tones[n].adsr -= SUSTAIN_HEIGHT/(DECAY_TIME * 44100.0);
                if (player->tones[n].adsr <= 0) {
                    player->tones[n].state = STATE_INACTIVE;
                    continue;
                }
            }
            
            // Calculate the final sample value.
            float s = sineValue * player->tones[n].adsr;
            m += s;
        }
        
        float *leftData = ioData->mBuffers[0].mData;
        leftData[frame] = m;
        
        float *rightData = ioData->mBuffers[1].mData;
        rightData[frame] = m;
    }
    
    
    return noErr;
}

#pragma mark callback function

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
    for (int i = 0; i < SINE_LOOKUP_INDEXES; i++) {
        sineTable[i] = sinf(2.0f*i*M_PI/SINE_LOOKUP_INDEXES);
    }
}

- (int)playFrequency:(double)freq {
    for (int i = 0; i < MAX_TONE_EVENTS; i++)
        if (tones[i].state == STATE_INACTIVE)  // find an empty slot
        {
            tones[i].state = STATE_ATTACK;
            tones[i].phase = 0.0f;
            tones[i].adsr = 0.0f;
            tones[i].freq = freq;// + (rand()*2.0/RAND_MAX-1.0)*.3;
            return i;
        }
    NSLog(@"No available channels");
    return -1;
}

- (void)stopToneEvent:(int)n {
    if (n >= 0 && n < MAX_TONE_EVENTS) {
        if (tones[n].state == STATE_ATTACK || tones[n].state == STATE_DECAY || tones[n].state == STATE_SUSTAIN) {
            tones[n].state = STATE_RELEASE;
        }
    }
}

-(void)stopToneEventWithObject:(NSNumber *)n {
    [self stopToneEvent:[n intValue]];
}


@end