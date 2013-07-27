
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include <string.h>

#include "RadAudioSFXRUnit.h"

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
    return noErr;
}

#define rnd(n) (rand()%(n+1))

float frnd(float range)
{
	return (float)rnd(10000)/10000*range;
}

@interface RadAudioSFXRUnit ()
{
    // private state variables
    bool playing_sample;
    float master_vol;
    bool mute_stream;
    
    int wav_bits;
    int wav_freq;
    
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
@end

@implementation RadAudioSFXRUnit

- (id) initWithGraph:(AUGraph)owningGraph {
    if (self = [super initWithGraph:owningGraph]) {
        wav_bits = 16;
        wav_freq = 44100.0f;
        mute_stream = NO;
        playing_sample = NO;
        master_vol = 1.0f;
        _sound_vol = 1.0f;
        
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

- (void) resetParams
{
	_wave_type = 0;
    
	_p_base_freq = 0.3f;
	_p_freq_limit = 0.0f;
	_p_freq_ramp = 0.0f;
	_p_freq_dramp = 0.0f;
	_p_duty = 0.0f;
	_p_duty_ramp = 0.0f;
    
	_p_vib_strength = 0.0f;
	_p_vib_speed = 0.0f;
    
	_p_env_attack = 0.0f;
	_p_env_sustain = 0.3f;
	_p_env_decay = 0.4f;
	_p_env_punch = 0.0f;
    
	_p_lpf_resonance = 0.0f;
	_p_lpf_freq = 1.0f;
	_p_lpf_ramp = 0.0f;
	_p_hpf_freq = 0.0f;
	_p_hpf_ramp = 0.0f;
	
	_p_pha_offset = 0.0f;
	_p_pha_ramp = 0.0f;
    
	_p_repeat_speed = 0.0f;
    
	_p_arp_speed = 0.0f;
	_p_arp_mod = 0.0f;
}

- (void) resetSampleWithRestart:(BOOL) restart
{
	if (!restart)
		phase = 0;
	fperiod = 100.0/(_p_base_freq*_p_base_freq+0.001);
	period = (int)fperiod;
	fmaxperiod = 100.0/(_p_freq_limit*_p_freq_limit+0.001);
	fslide = 1.0-pow((double)_p_freq_ramp, 3.0)*0.01;
	fdslide = -pow((double)_p_freq_dramp, 3.0)*0.000001;
	square_duty = 0.5f-_p_duty*0.5f;
	square_slide = -_p_duty_ramp*0.00005f;
	if (_p_arp_mod >= 0.0f)
		arp_mod = 1.0-pow((double)_p_arp_mod, 2.0)*0.9;
	else
		arp_mod = 1.0+pow((double)_p_arp_mod, 2.0)*10.0;
	arp_time = 0;
	arp_limit = (int)(pow(1.0f-_p_arp_speed, 2.0f)*20000+32);
	if (_p_arp_speed == 1.0f)
		arp_limit = 0;
	if (!restart) {
		// reset filter
		fltp = 0.0f;
		fltdp = 0.0f;
		fltw = pow(_p_lpf_freq, 3.0f)*0.1f;
		fltw_d = 1.0f+_p_lpf_ramp*0.0001f;
		fltdmp = 5.0f/(1.0f+pow(_p_lpf_resonance, 2.0f)*20.0f)*(0.01f+fltw);
		if (fltdmp > 0.8f) fltdmp = 0.8f;
		fltphp = 0.0f;
		flthp = pow(_p_hpf_freq, 2.0f)*0.1f;
		flthp_d = 1.0+_p_hpf_ramp*0.0003f;
		// reset vibrato
		vib_phase = 0.0f;
		vib_speed = pow(_p_vib_speed, 2.0f)*0.01f;
		vib_amp = _p_vib_strength*0.5f;
		// reset envelope
		env_vol = 0.0f;
		env_stage = 0;
		env_time = 0;
		env_length[0] = (int)(_p_env_attack*_p_env_attack*100000.0f);
		env_length[1] = (int)(_p_env_sustain*_p_env_sustain*100000.0f);
		env_length[2] = (int)(_p_env_decay*_p_env_decay*100000.0f);
        
		fphase = pow(_p_pha_offset, 2.0f)*1020.0f;
		if (_p_pha_offset < 0.0f) fphase = -fphase;
		fdphase = pow(_p_pha_ramp, 2.0f)*1.0f;
		if (_p_pha_ramp < 0.0f) fdphase = -fdphase;
		iphase = abs((int)fphase);
		ipp = 0;
		for(int i = 0; i < 1024; i++)
			phaser_buffer[i] = 0.0f;
        
		for(int i = 0; i < 32; i++)
			noise_buffer[i] = frnd(2.0f)-1.0f;
        
		rep_time = 0;
		rep_limit = (int)(pow(1.0f-_p_repeat_speed, 2.0f)*20000+32);
		if (_p_repeat_speed == 0.0f)
			rep_limit = 0;
	}
}

- (void) playSample
{
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
            if (_p_freq_limit > 0.0f) {
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
			env_vol = 1.0f + pow(1.0f-(float)env_time/env_length[1], 1.0f)*2.0f*_p_env_punch;
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
		for(int si = 0;si < 8; si++) // 8x supersampling
		{
			float sample = 0.0f;
			phase++;
			if (phase >= period) {
                //				phase=0;
				phase %= period;
				if (_wave_type == 3)
					for (int i = 0; i < 32; i++)
						noise_buffer[i] = frnd(2.0f) - 1.0f;
			}
			// base waveform
			float fp = (float)phase/period;
			switch(_wave_type) {
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
			if (_p_lpf_freq != 1.0f) {
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
        
		ssample *= 2.0f*_sound_vol;
        
		if (buffer != NULL) {
			if (ssample > 1.0f) ssample = 1.0f;
			if (ssample < -1.0f) ssample = -1.0f;
			*buffer++ = ssample;
		}		
	}
    if (!playing_sample && _p_repeat_count) {
        [self playSample];
        if (_p_repeat_count > 0) {
            _p_repeat_count--;
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

- (void) pickup_coin {
    [self resetParams];
    _p_base_freq = 0.4f+frnd(0.5f);
    _p_env_attack = 0.0f;
    _p_env_sustain = frnd(0.1f);
    _p_env_decay = 0.1f+frnd(0.4f);
    _p_env_punch = 0.3f+frnd(0.3f);
    if (rnd(1)) {
        _p_arp_speed = 0.5f+frnd(0.2f);
        _p_arp_mod = 0.2f+frnd(0.4f);
    }
    [self playSample];
}

- (void) laser_shoot {
    [self resetParams];
    _wave_type = rnd(2);
    if (_wave_type == 2 && rnd(1))
        _wave_type = rnd(1);
    _p_base_freq = 0.5f+frnd(0.5f);
    _p_freq_limit = _p_base_freq-0.2f-frnd(0.6f);
    if (_p_freq_limit<0.2f) _p_freq_limit = 0.2f;
    _p_freq_ramp = -0.15f-frnd(0.2f);
    if (rnd(2) == 0) {
        _p_base_freq = 0.3f+frnd(0.6f);
        _p_freq_limit = frnd(0.1f);
        _p_freq_ramp = -0.35f-frnd(0.3f);
    }
    if (rnd(1)) {
        _p_duty = frnd(0.5f);
        _p_duty_ramp = frnd(0.2f);
    } else {
        _p_duty = 0.4f+frnd(0.5f);
        _p_duty_ramp = -frnd(0.7f);
    }
    _p_env_attack = 0.0f;
    _p_env_sustain = 0.1f+frnd(0.2f);
    _p_env_decay = frnd(0.4f);
    if (rnd(1))
        _p_env_punch = frnd(0.3f);
    if (rnd(2) == 0) {
        _p_pha_offset = frnd(0.2f);
        _p_pha_ramp = -frnd(0.2f);
    }
    if (rnd(1))
        _p_hpf_freq = frnd(0.3f);
    
    [self playSample];
}

- (void) explosion {
    [self resetParams];
    _wave_type = 3;
    if (rnd(1)) {
        _p_base_freq = 0.1f+frnd(0.4f);
        _p_freq_ramp = -0.1f+frnd(0.4f);
    } else {
        _p_base_freq = 0.2f+frnd(0.7f);
        _p_freq_ramp = -0.2f-frnd(0.2f);
    }
    _p_base_freq *= _p_base_freq;
    if (rnd(4) == 0)
        _p_freq_ramp = 0.0f;
    if (rnd(2) == 0)
        _p_repeat_speed = 0.3f+frnd(0.5f);
    _p_env_attack = 0.0f;
    _p_env_sustain = 0.1f+frnd(0.3f);
    _p_env_decay = frnd(0.5f);
    if (rnd(1) == 0) {
        _p_pha_offset = -0.3f+frnd(0.9f);
        _p_pha_ramp = -frnd(0.3f);
    }
    _p_env_punch = 0.2f+frnd(0.6f);
    if (rnd(1)) {
        _p_vib_strength = frnd(0.7f);
        _p_vib_speed = frnd(0.6f);
    }
    if (rnd(2) == 0) {
        _p_arp_speed = 0.6f+frnd(0.3f);
        _p_arp_mod = 0.8f-frnd(1.6f);
    }
    [self playSample];
}

- (void) powerup {
    [self resetParams];
    if (rnd(1))
        _wave_type = 1;
    else
        _p_duty = frnd(0.6f);
    if (rnd(1)) {
        _p_base_freq = 0.2f+frnd(0.3f);
        _p_freq_ramp = 0.1f+frnd(0.4f);
        _p_repeat_speed = 0.4f+frnd(0.4f);
    } else {
        _p_base_freq = 0.2f+frnd(0.3f);
        _p_freq_ramp = 0.05f+frnd(0.2f);
        if (rnd(1)) {
            _p_vib_strength = frnd(0.7f);
            _p_vib_speed = frnd(0.6f);
        }
    }
    _p_env_attack = 0.0f;
    _p_env_sustain = frnd(0.4f);
    _p_env_decay = 0.1f+frnd(0.4f);
    [self playSample];
}

- (void) hit_hurt {
    [self resetParams];
    
    _wave_type = rnd(2);
    if (_wave_type == 2)
        _wave_type = 3;
    if (_wave_type == 0)
        _p_duty = frnd(0.6f);
    _p_base_freq = 0.2f + frnd(0.6f);
    _p_freq_ramp = -0.3f - frnd(0.4f);
    _p_env_attack = 0.0f;
    _p_env_sustain = frnd(0.1f);
    _p_env_decay = 0.1f + frnd(0.2f);
    if (rnd(1))
        _p_hpf_freq = frnd(0.3f);
    [self playSample];
}

- (void) jump {
    [self resetParams];
    _wave_type = 0;
    _p_duty = frnd(0.6f);
    _p_base_freq = 0.3f + frnd(0.3f);
    _p_freq_ramp = 0.1f + frnd(0.2f);
    _p_env_attack = 0.0f;
    _p_env_sustain = 0.1f + frnd(0.3f);
    _p_env_decay = 0.1f + frnd(0.2f);
    if (rnd(1))
        _p_hpf_freq = frnd(0.3f);
    if (rnd(1))
        _p_lpf_freq = 1.0f-frnd(0.6f);
    [self playSample];
}

- (void) blip_select {
    [self resetParams];
    _wave_type = rnd(1);
    if (_wave_type == 0)
        _p_duty = frnd(0.6f);
    _p_base_freq = 0.2f + frnd(0.4f);
    _p_env_attack = 0.0f;
    _p_env_sustain = 0.1f + frnd(0.1f);
    _p_env_decay = frnd(0.2f);
    _p_hpf_freq = 0.1f;
    [self playSample];
}

- (void) randomize {
    _p_base_freq = pow(frnd(2.0f)-1.0f, 2.0f);
    if (rnd(1))
        _p_base_freq = pow(frnd(2.0f)-1.0f, 3.0f)+0.5f;
    _p_freq_limit = 0.0f;
    _p_freq_ramp = pow(frnd(2.0f)-1.0f, 5.0f);
    if (_p_base_freq>0.7f && _p_freq_ramp>0.2f)
        _p_freq_ramp = -_p_freq_ramp;
    if (_p_base_freq < 0.2f && _p_freq_ramp < -0.05f)
        _p_freq_ramp = -_p_freq_ramp;
    _p_freq_dramp = pow(frnd(2.0f)-1.0f, 3.0f);
    _p_duty = frnd(2.0f)-1.0f;
    _p_duty_ramp = pow(frnd(2.0f)-1.0f, 3.0f);
    _p_vib_strength = pow(frnd(2.0f)-1.0f, 3.0f);
    _p_vib_speed = frnd(2.0f)-1.0f;
    _p_env_attack = pow(frnd(2.0f)-1.0f, 3.0f);
    _p_env_sustain = pow(frnd(2.0f)-1.0f, 2.0f);
    _p_env_decay = frnd(2.0f)-1.0f;
    _p_env_punch = pow(frnd(0.8f), 2.0f);
    if (_p_env_attack+_p_env_sustain+_p_env_decay < 0.2f) {
        _p_env_sustain += 0.2f + frnd(0.3f);
        _p_env_decay += 0.2f + frnd(0.3f);
    }
    _p_lpf_resonance = frnd(2.0f) - 1.0f;
    _p_lpf_freq = 1.0f - pow(frnd(1.0f), 3.0f);
    _p_lpf_ramp = pow(frnd(2.0f) - 1.0f, 3.0f);
    if (_p_lpf_freq < 0.1f && _p_lpf_ramp < -0.05f)
        _p_lpf_ramp = -_p_lpf_ramp;
    _p_hpf_freq = pow(frnd(1.0f), 5.0f);
    _p_hpf_ramp = pow(frnd(2.0f)-1.0f, 5.0f);
    _p_pha_offset = pow(frnd(2.0f)-1.0f, 3.0f);
    _p_pha_ramp = pow(frnd(2.0f)-1.0f, 3.0f);
    _p_repeat_speed = frnd(2.0f)-1.0f;
    _p_arp_speed = frnd(2.0f)-1.0f;
    _p_arp_mod = frnd(2.0f)-1.0f;
    [self playSample];
}

- (void) mutate
{
    if(rnd(1)) _p_base_freq += frnd(0.1f)-0.05f;
    //		if(rnd(1)) p_freq_limit += frnd(0.1f)-0.05f;
    if(rnd(1)) _p_freq_ramp += frnd(0.1f)-0.05f;
    if(rnd(1)) _p_freq_dramp += frnd(0.1f)-0.05f;
    if(rnd(1)) _p_duty += frnd(0.1f)-0.05f;
    if(rnd(1)) _p_duty_ramp += frnd(0.1f)-0.05f;
    if(rnd(1)) _p_vib_strength += frnd(0.1f)-0.05f;
    if(rnd(1)) _p_vib_speed += frnd(0.1f)-0.05f;
    if(rnd(1)) _p_env_attack += frnd(0.1f)-0.05f;
    if(rnd(1)) _p_env_sustain += frnd(0.1f)-0.05f;
    if(rnd(1)) _p_env_decay += frnd(0.1f)-0.05f;
    if(rnd(1)) _p_env_punch += frnd(0.1f)-0.05f;
    if(rnd(1)) _p_lpf_resonance += frnd(0.1f)-0.05f;
    if(rnd(1)) _p_lpf_freq += frnd(0.1f)-0.05f;
    if(rnd(1)) _p_lpf_ramp += frnd(0.1f)-0.05f;
    if(rnd(1)) _p_hpf_freq += frnd(0.1f)-0.05f;
    if(rnd(1)) _p_hpf_ramp += frnd(0.1f)-0.05f;
    if(rnd(1)) _p_pha_offset += frnd(0.1f)-0.05f;
    if(rnd(1)) _p_pha_ramp += frnd(0.1f)-0.05f;
    if(rnd(1)) _p_repeat_speed += frnd(0.1f)-0.05f;
    if(rnd(1)) _p_arp_speed += frnd(0.1f)-0.05f;
    if(rnd(1)) _p_arp_mod += frnd(0.1f)-0.05f;
    [self playSample];
}

- (void) pop
{
    [self resetParams];
    
    _wave_type = 3;
    _sound_vol = 50;
    _p_base_freq = 0.5;
    
    _p_env_attack = 0.0;
    _p_env_decay = 0.1;
    _p_env_sustain = 0.2;
    _p_env_punch = 1.0;
    
    _p_freq_ramp = -0.5;
    _p_lpf_freq = 0.2;
    _p_hpf_freq = 0.0;
    
    _p_repeat_speed = 0;
    
    [self playSample];
}

@end
