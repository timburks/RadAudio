//
//  RadAudioSFXRTone.m
//  RadAudio
//
//  Created by Tim Burks on 8/16/13.
//
//

#import "RadAudioSFXRTone.h"


#define rnd(n) (rand()%(n+1))

static float frnd(float range)
{
	return (float)rnd(10000)/10000*range;
}

@implementation RadAudioSFXRTone

- (id) init
{
    if (self = [super init]) {
        [self resetParams];
        _sound_vol = 1;
        _wave_type = 2;
    }
    return self;
}

- (void) resetParams
{
	_wave_type = 0;
    _sound_vol = 1.0f;

	_base_freq = 0.3f;
	_freq_limit = 0.0f;
	_freq_ramp = 0.0f;
	_freq_dramp = 0.0f;
	_duty = 0.0f;
	_duty_ramp = 0.0f;
    
	_vib_strength = 0.0f;
	_vib_speed = 0.0f;
    
	_env_attack = 0.0f;
	_env_sustain = 0.3f;
	_env_decay = 0.4f;
	_env_punch = 0.0f;
    
	_lpf_resonance = 0.0f;
	_lpf_freq = 1.0f;
	_lpf_ramp = 0.0f;
	_hpf_freq = 0.0f;
	_hpf_ramp = 0.0f;
	
	_pha_offset = 0.0f;
	_pha_ramp = 0.0f;
    
	_repeat_speed = 0.0f;
    
	_arp_speed = 0.0f;
	_arp_mod = 0.0f;
}

- (void) pickup_coin {
    [self resetParams];
    _base_freq = 0.4f+frnd(0.5f);
    _env_attack = 0.0f;
    _env_sustain = frnd(0.1f);
    _env_decay = 0.1f+frnd(0.4f);
    _env_punch = 0.3f+frnd(0.3f);
    if (rnd(1)) {
        _arp_speed = 0.5f+frnd(0.2f);
        _arp_mod = 0.2f+frnd(0.4f);
    }
}

- (void) laser_shoot {
    [self resetParams];
    _wave_type = rnd(2);
    if (_wave_type == 2 && rnd(1))
        _wave_type = rnd(1);
    _base_freq = 0.5f+frnd(0.5f);
    _freq_limit = _base_freq-0.2f-frnd(0.6f);
    if (_freq_limit<0.2f) _freq_limit = 0.2f;
    _freq_ramp = -0.15f-frnd(0.2f);
    if (rnd(2) == 0) {
        _base_freq = 0.3f+frnd(0.6f);
        _freq_limit = frnd(0.1f);
        _freq_ramp = -0.35f-frnd(0.3f);
    }
    if (rnd(1)) {
        _duty = frnd(0.5f);
        _duty_ramp = frnd(0.2f);
    } else {
        _duty = 0.4f+frnd(0.5f);
        _duty_ramp = -frnd(0.7f);
    }
    _env_attack = 0.0f;
    _env_sustain = 0.1f+frnd(0.2f);
    _env_decay = frnd(0.4f);
    if (rnd(1))
        _env_punch = frnd(0.3f);
    if (rnd(2) == 0) {
        _pha_offset = frnd(0.2f);
        _pha_ramp = -frnd(0.2f);
    }
    if (rnd(1))
        _hpf_freq = frnd(0.3f);
    
}

- (void) explosion {
    [self resetParams];
    _wave_type = 3;
    if (rnd(1)) {
        _base_freq = 0.1f+frnd(0.4f);
        _freq_ramp = -0.1f+frnd(0.4f);
    } else {
        _base_freq = 0.2f+frnd(0.7f);
        _freq_ramp = -0.2f-frnd(0.2f);
    }
    _base_freq *= _base_freq;
    if (rnd(4) == 0)
        _freq_ramp = 0.0f;
    if (rnd(2) == 0)
        _repeat_speed = 0.3f+frnd(0.5f);
    _env_attack = 0.0f;
    _env_sustain = 0.1f+frnd(0.3f);
    _env_decay = frnd(0.5f);
    if (rnd(1) == 0) {
        _pha_offset = -0.3f+frnd(0.9f);
        _pha_ramp = -frnd(0.3f);
    }
    _env_punch = 0.2f+frnd(0.6f);
    if (rnd(1)) {
        _vib_strength = frnd(0.7f);
        _vib_speed = frnd(0.6f);
    }
    if (rnd(2) == 0) {
        _arp_speed = 0.6f+frnd(0.3f);
        _arp_mod = 0.8f-frnd(1.6f);
    }
}

- (void) powerup {
    [self resetParams];
    if (rnd(1))
        _wave_type = 1;
    else
        _duty = frnd(0.6f);
    if (rnd(1)) {
        _base_freq = 0.2f+frnd(0.3f);
        _freq_ramp = 0.1f+frnd(0.4f);
        _repeat_speed = 0.4f+frnd(0.4f);
    } else {
        _base_freq = 0.2f+frnd(0.3f);
        _freq_ramp = 0.05f+frnd(0.2f);
        if (rnd(1)) {
            _vib_strength = frnd(0.7f);
            _vib_speed = frnd(0.6f);
        }
    }
    _env_attack = 0.0f;
    _env_sustain = frnd(0.4f);
    _env_decay = 0.1f+frnd(0.4f);
}

- (void) hit_hurt {
    [self resetParams];
    
    _wave_type = rnd(2);
    if (_wave_type == 2)
        _wave_type = 3;
    if (_wave_type == 0)
        _duty = frnd(0.6f);
    _base_freq = 0.2f + frnd(0.6f);
    _freq_ramp = -0.3f - frnd(0.4f);
    _env_attack = 0.0f;
    _env_sustain = frnd(0.1f);
    _env_decay = 0.1f + frnd(0.2f);
    if (rnd(1))
        _hpf_freq = frnd(0.3f);
}

- (void) jump {
    [self resetParams];
    _wave_type = 0;
    _duty = frnd(0.6f);
    _base_freq = 0.3f + frnd(0.3f);
    _freq_ramp = 0.1f + frnd(0.2f);
    _env_attack = 0.0f;
    _env_sustain = 0.1f + frnd(0.3f);
    _env_decay = 0.1f + frnd(0.2f);
    if (rnd(1))
        _hpf_freq = frnd(0.3f);
    if (rnd(1))
        _lpf_freq = 1.0f-frnd(0.6f);
}

- (void) blip_select {
    [self resetParams];
    _wave_type = rnd(1);
    if (_wave_type == 0)
        _duty = frnd(0.6f);
    _base_freq = 0.2f + frnd(0.4f);
    _env_attack = 0.0f;
    _env_sustain = 0.1f + frnd(0.1f);
    _env_decay = frnd(0.2f);
    _hpf_freq = 0.1f;
}

- (void) randomize {
    _base_freq = pow(frnd(2.0f)-1.0f, 2.0f);
    if (rnd(1))
        _base_freq = pow(frnd(2.0f)-1.0f, 3.0f)+0.5f;
    _freq_limit = 0.0f;
    _freq_ramp = pow(frnd(2.0f)-1.0f, 5.0f);
    if (_base_freq>0.7f && _freq_ramp>0.2f)
        _freq_ramp = -_freq_ramp;
    if (_base_freq < 0.2f && _freq_ramp < -0.05f)
        _freq_ramp = -_freq_ramp;
    _freq_dramp = pow(frnd(2.0f)-1.0f, 3.0f);
    _duty = frnd(2.0f)-1.0f;
    _duty_ramp = pow(frnd(2.0f)-1.0f, 3.0f);
    _vib_strength = pow(frnd(2.0f)-1.0f, 3.0f);
    _vib_speed = frnd(2.0f)-1.0f;
    _env_attack = pow(frnd(2.0f)-1.0f, 3.0f);
    _env_sustain = pow(frnd(2.0f)-1.0f, 2.0f);
    _env_decay = frnd(2.0f)-1.0f;
    _env_punch = pow(frnd(0.8f), 2.0f);
    if (_env_attack+_env_sustain+_env_decay < 0.2f) {
        _env_sustain += 0.2f + frnd(0.3f);
        _env_decay += 0.2f + frnd(0.3f);
    }
    _lpf_resonance = frnd(2.0f) - 1.0f;
    _lpf_freq = 1.0f - pow(frnd(1.0f), 3.0f);
    _lpf_ramp = pow(frnd(2.0f) - 1.0f, 3.0f);
    if (_lpf_freq < 0.1f && _lpf_ramp < -0.05f)
        _lpf_ramp = -_lpf_ramp;
    _hpf_freq = pow(frnd(1.0f), 5.0f);
    _hpf_ramp = pow(frnd(2.0f)-1.0f, 5.0f);
    _pha_offset = pow(frnd(2.0f)-1.0f, 3.0f);
    _pha_ramp = pow(frnd(2.0f)-1.0f, 3.0f);
    _repeat_speed = frnd(2.0f)-1.0f;
    _arp_speed = frnd(2.0f)-1.0f;
    _arp_mod = frnd(2.0f)-1.0f;
}

- (void) mutate
{
    if(rnd(1)) _base_freq     += frnd(0.1f)-0.05f;
    //if(rnd(1)) p_freq_limit     += frnd(0.1f)-0.05f;
    if(rnd(1)) _freq_ramp     += frnd(0.1f)-0.05f;
    if(rnd(1)) _freq_dramp    += frnd(0.1f)-0.05f;
    if(rnd(1)) _duty          += frnd(0.1f)-0.05f;
    if(rnd(1)) _duty_ramp     += frnd(0.1f)-0.05f;
    if(rnd(1)) _vib_strength  += frnd(0.1f)-0.05f;
    if(rnd(1)) _vib_speed     += frnd(0.1f)-0.05f;
    if(rnd(1)) _env_attack    += frnd(0.1f)-0.05f;
    if(rnd(1)) _env_sustain   += frnd(0.1f)-0.05f;
    if(rnd(1)) _env_decay     += frnd(0.1f)-0.05f;
    if(rnd(1)) _env_punch     += frnd(0.1f)-0.05f;
    if(rnd(1)) _lpf_resonance += frnd(0.1f)-0.05f;
    if(rnd(1)) _lpf_freq      += frnd(0.1f)-0.05f;
    if(rnd(1)) _lpf_ramp      += frnd(0.1f)-0.05f;
    if(rnd(1)) _hpf_freq      += frnd(0.1f)-0.05f;
    if(rnd(1)) _hpf_ramp      += frnd(0.1f)-0.05f;
    if(rnd(1)) _pha_offset    += frnd(0.1f)-0.05f;
    if(rnd(1)) _pha_ramp      += frnd(0.1f)-0.05f;
    if(rnd(1)) _repeat_speed  += frnd(0.1f)-0.05f;
    if(rnd(1)) _arp_speed     += frnd(0.1f)-0.05f;
    if(rnd(1)) _arp_mod       += frnd(0.1f)-0.05f;
}

- (void) pop
{
    [self resetParams];
    
    _wave_type = 3;
    _sound_vol = 50;
    _base_freq = 0.5;
    
    _env_attack = 0.0;
    _env_decay = 0.1;
    _env_sustain = 0.2;
    _env_punch = 1.0;
    
    _freq_ramp = -0.5;
    _lpf_freq = 0.2;
    _hpf_freq = 0.0;
    
    _repeat_speed = 0;
    
}

@end
