
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include <string.h>

#include "RadAudioSFXRUnit.h"
#include "RadAudioSFXRTone.h"

#define rnd(n) (rand()%(n+1))
static float frnd(float range)
{
	return (float)rnd(10000)/10000*range;
}

@interface RadAudioSFXRUnit ()
{
    bool playing_sample;
    float master_vol;
    bool mute_stream;
    
    int phase;
    double fperiod;
    double fmaxperiod;
    double fslide;
    double fdslide;
    int period;
    float square_duty;
    float square_slide;
    int env_stage;
    int env_time;
    int env_length[3];
    float env_vol;
    float fphase;
    float fdphase;
    int iphase;
    float phaser_buffer[1024];
    int ipp;
    float noise_buffer[32];
    float fltp;
    float fltdp;
    float fltw;
    float fltw_d;
    float fltdmp;
    float fltphp;
    float flthp;
    float flthp_d;
    float vib_phase;
    float vib_speed;
    float vib_amp;
    int rep_time;
    int rep_limit;
    int arp_time;
    int arp_limit;
    double arp_mod;
}
@property (nonatomic, copy) RadRenderProc renderer;
@property (nonatomic, copy) RenderBlock renderBlock;
@end

OSStatus RadAudioSFXRUnitRenderProc(void *inRefCon,
                                    AudioUnitRenderActionFlags *ioActionFlags,
                                    const AudioTimeStamp *inTimeStamp,
                                    UInt32 inBusNumber,
                                    UInt32 inNumberFrames,
                                    AudioBufferList *ioData) {
    RadAudioSFXRUnit *player = (__bridge RadAudioSFXRUnit *)inRefCon;
    Float32 *leftChannel = (Float32 *)ioData->mBuffers[0].mData;
    Float32 *rightChannel = (Float32 *)ioData->mBuffers[1].mData;
    if (player.renderBlock) {
        player.renderBlock(inTimeStamp, inNumberFrames, leftChannel);
        memcpy(rightChannel, leftChannel, inNumberFrames*sizeof(float));
    }
    
    if (player.observer) {
        //NSLog(@"%f", inTimeStamp->mSampleTime);
        int tock = (int) (inTimeStamp->mSampleTime / (44100.0/11));
        dispatch_async(dispatch_get_main_queue(), ^{
            [player.observer tick:tock];
        });
    }
    
    return noErr;
}

@implementation RadAudioSFXRUnit

- (id) initWithGraph:(AUGraph)owningGraph {
    if (self = [super initWithGraph:owningGraph]) {
        mute_stream = NO;
        playing_sample = NO;
        master_vol = 1.0f;
        
        RadAudioSFXRUnit *player = self;
        self.renderBlock = ^(const AudioTimeStamp *time, int frames, float *output) {
            [player synthesizeSampleOfLength:frames inBuffer:output];
        };
        
    }
    return self;
}

- (void) prepare
{
    AURenderCallbackStruct input;
    input.inputProc = RadAudioSFXRUnitRenderProc;
    input.inputProcRefCon = (__bridge void *) self;
    CheckError(AudioUnitSetProperty([self audioUnit],
                                    kAudioUnitProperty_SetRenderCallback,
                                    kAudioUnitScope_Input,
                                    0,
                                    &input,
                                    sizeof(input)),
               "AudioUnitSetProperty failed");
}


- (void) resetSampleWithRestart:(BOOL) restart
{
	if (!restart)
		phase = 0;
	fperiod = 100.0/(self.tone.base_freq*self.tone.base_freq+0.001);
	period = (int)fperiod;
	fmaxperiod = 100.0/(self.tone.freq_limit*self.tone.freq_limit+0.001);
	fslide = 1.0-pow((double)self.tone.freq_ramp, 3.0)*0.01;
	fdslide = -pow((double)self.tone.freq_dramp, 3.0)*0.000001;
	square_duty = 0.5f-self.tone.duty*0.5f;
	square_slide = -self.tone.duty_ramp*0.00005f;
	if (self.tone.arp_mod >= 0.0f)
		arp_mod = 1.0-pow((double)self.tone.arp_mod, 2.0)*0.9;
	else
		arp_mod = 1.0+pow((double)self.tone.arp_mod, 2.0)*10.0;
	arp_time = 0;
	arp_limit = (int)(pow(1.0f-self.tone.arp_speed, 2.0f)*20000+32);
	if (self.tone.arp_speed == 1.0f)
		arp_limit = 0;
	if (!restart) {
		// reset filter
		fltp = 0.0f;
		fltdp = 0.0f;
		fltw = pow(self.tone.lpf_freq, 3.0f)*0.1f;
		fltw_d = 1.0f+self.tone.lpf_ramp*0.0001f;
		fltdmp = 5.0f/(1.0f+pow(self.tone.lpf_resonance, 2.0f)*20.0f)*(0.01f+fltw);
		if (fltdmp > 0.8f) fltdmp = 0.8f;
		fltphp = 0.0f;
		flthp = pow(self.tone.hpf_freq, 2.0f)*0.1f;
		flthp_d = 1.0+self.tone.hpf_ramp*0.0003f;
		// reset vibrato
		vib_phase = 0.0f;
		vib_speed = pow(self.tone.vib_speed, 2.0f)*0.01f;
		vib_amp = self.tone.vib_strength*0.5f;
		// reset envelope
		env_vol = 0.0f;
		env_stage = 0;
		env_time = 0;
		env_length[0] = (int)(self.tone.env_attack*self.tone.env_attack*100000.0f);
		env_length[1] = (int)(self.tone.env_sustain*self.tone.env_sustain*100000.0f);
		env_length[2] = (int)(self.tone.env_decay*self.tone.env_decay*100000.0f);
        
		fphase = pow(self.tone.pha_offset, 2.0f)*1020.0f;
		if (self.tone.pha_offset < 0.0f) fphase = -fphase;
		fdphase = pow(self.tone.pha_ramp, 2.0f)*1.0f;
		if (self.tone.pha_ramp < 0.0f) fdphase = -fdphase;
		iphase = abs((int)fphase);
		ipp = 0;
		for(int i = 0; i < 1024; i++)
			phaser_buffer[i] = 0.0f;
        
		for(int i = 0; i < 32; i++)
			noise_buffer[i] = frnd(2.0f)-1.0f;
        
		rep_time = 0;
		rep_limit = (int)(pow(1.0f-self.tone.repeat_speed, 2.0f)*20000+32);
		if (self.tone.repeat_speed == 0.0f)
			rep_limit = 0;
	}
}

- (void) playSample
{
    if (playing_sample) {
        return;
    }
	[self resetSampleWithRestart:NO];
	playing_sample = YES;
}

- (void) synthesizeSampleOfLength:(int) length
                         inBuffer:(float *) buffer
{
    if (!playing_sample) {
        for (int i = 0; i < length; i++) {
            buffer[i] = 0.0;
        }
        return;
    }
    
	for (int i = 0; i < length; i++) {
		if (!playing_sample) {
			break;
        }
        
		rep_time++;
		if (rep_limit != 0 && (rep_time >= rep_limit)) {
			rep_time = 0;
            [self resetSampleWithRestart:YES];
		}
        
		// frequency envelopes/arpeggios
		arp_time++;
		if ((arp_limit != 0) && (arp_time >= arp_limit)) {
			arp_limit = 0;
			fperiod *= arp_mod;
		}
		fslide += fdslide;
		fperiod *= fslide;
		if (fperiod > fmaxperiod) {
			fperiod = fmaxperiod;
            if (self.tone.freq_limit > 0.0f) {
                playing_sample = NO;
            }
		}
		float rfperiod = fperiod;
		if (vib_amp > 0.0f) {
			vib_phase += vib_speed;
			rfperiod = fperiod*(1.0+sin(vib_phase)*vib_amp);
		}
		period = (int)rfperiod;
		if (period < 8) period = 8;
		square_duty += square_slide;
		if (square_duty < 0.0f) square_duty = 0.0f;
		if (square_duty > 0.5f) square_duty = 0.5f;
		// volume envelope
		env_time++;
		if (env_time > env_length[env_stage]) {
			env_time = 0;
			env_stage++;
            if (env_stage == 3) {
                playing_sample = NO;
            }
		}
		if (env_stage == 0)
			env_vol = (float)env_time/env_length[0];
		if (env_stage == 1)
			env_vol = 1.0f + pow(1.0f-(float)env_time/env_length[1], 1.0f)*2.0f*self.tone.env_punch;
		if (env_stage == 2)
			env_vol = 1.0f - (float)env_time/env_length[2];
        
		// phaser step
		fphase += fdphase;
		iphase = abs((int)fphase);
		if (iphase > 1023) iphase = 1023;
        
		if (flthp_d != 0.0f) {
			flthp *= flthp_d;
			if (flthp < 0.00001f) flthp = 0.00001f;
			if (flthp > 0.1f) flthp = 0.1f;
		}
        
		float ssample = 0.0f;
		for(int si = 0; si < 8; si++) // 8x supersampling
		{
			float sample = 0.0f;
			phase++;
			if (phase >= period) {
                //				phase=0;
				phase %= period;
				if (self.tone.wave_type == 3)
					for (int i = 0; i < 32; i++)
						noise_buffer[i] = frnd(2.0f) - 1.0f;
			}
			// base waveform
			float fp = (float)phase/period;
			switch(self.tone.wave_type) {
                case 0: // square
                    if (fp < square_duty)
                        sample = 0.5f;
                    else
                        sample = -0.5f;
                    break;
                case 1: // sawtooth
                    sample = 1.0f - fp*2;
                    break;
                case 2: // sine
                    sample = (float)sin(fp*2*M_PI);
                    break;
                case 3: // noise
                    sample = noise_buffer[phase*32/period];
                    break;
			}
			// lp filter
			float pp = fltp;
			fltw *= fltw_d;
			if (fltw < 0.0f) fltw = 0.0f;
			if (fltw > 0.1f) fltw = 0.1f;
			if (self.tone.lpf_freq != 1.0f) {
				fltdp += (sample-fltp)*fltw;
				fltdp -= fltdp*fltdmp;
			} else {
				fltp = sample;
				fltdp = 0.0f;
			}
			fltp += fltdp;
			// hp filter
			fltphp += fltp-pp;
			fltphp -= fltphp*flthp;
			sample = fltphp;
			// phaser
			phaser_buffer[ipp&1023] = sample;
			sample += phaser_buffer[(ipp-iphase+1024)&1023];
			ipp = (ipp+1)&1023;
			// final accumulation and envelope application
			ssample += sample*env_vol;
		}
		ssample = ssample/8*master_vol;
        
		ssample *= 2.0f*self.tone.sound_vol;
        
		if (buffer != NULL) {
			if (ssample > 1.0f) ssample = 1.0f;
			if (ssample < -1.0f) ssample = -1.0f;
			*buffer++ = ssample;
		}
	}
    if (!playing_sample && self.tone.repeat_count) {
        [self playSample];
        if (self.tone.repeat_count > 0) {
            self.tone.repeat_count--;
        }
    }
}

- (int) fillBuffer:(void *) buffer frames:(int) frames {
    void *stream = buffer;
    int len = frames;
	if (playing_sample && !mute_stream)
	{
		unsigned int l = len;
		float fbuf[l];
		memset(fbuf, 0, sizeof(fbuf));
		[self synthesizeSampleOfLength:l inBuffer:fbuf];
		while (l--) {
			float f = fbuf[l];
			if (f < -1.0) f = -1.0;
			if (f > 1.0) f = 1.0;
			((SInt16 *)stream)[l] = (SInt16)(f * 0x7FFF);
		}
	} else {
        memset(stream, 0, 2*len);
    }
    return len;
}



@end
