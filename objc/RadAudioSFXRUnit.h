#import <Foundation/Foundation.h>

typedef enum {
    SFXR_SquareWave,
    SFXR_SawtoothWave,
    SFXR_SineWave,
    SFXR_Noise
} SFXR_WaveType;

#import "RadAudioUnit.h"

@interface RadAudioSFXRUnit : RadAudioUnit

{
    // characteristic parameters
    int wave_type;          // WAVE TYPE
    float sound_vol;        // VOLUME
    
    float p_env_attack;     // ATTACK TIME
    float p_env_sustain;    // SUSTAIN TIME
    float p_env_decay;      // DECAY TIME
    float p_env_punch;      // SUSTAIN PUNCH

    float p_base_freq;      // START FREQUENCY
    float p_freq_limit;     // MIN FREQUENCY
    float p_freq_ramp;      // SLIDE
    float p_freq_dramp;     // DELTA SLIDE
    float p_duty;           // SQUARE DUTY
    float p_duty_ramp;      // DUTY SWEEP
    float p_vib_strength;   // VIBRATO DEPTH
    float p_vib_speed;      // VIBRATO SPEED
    
    float p_lpf_resonance;  // LP FILTER RESONANCE
    float p_lpf_freq;       // LP FILTER CUTOFF
    float p_lpf_ramp;       // LP FILTER CUTOFF SWEEP
    float p_hpf_freq;       // HP FILTER CUTOFF
    float p_hpf_ramp;       // HP FILTER CUTOFF SWEEP
    float p_pha_offset;     // PHASER OFFSET
    float p_pha_ramp;       // PHASER SWEEP
    float p_repeat_speed;   // REPEAT SPEED
    float p_arp_speed;      // CHANGE SPEED
    float p_arp_mod;        // CHANGE AMOUNT
    // end of characteristic parameters

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


@property (nonatomic, copy) RadRenderProc renderer;
@property (nonatomic, copy) RenderBlock renderBlock;

- (void) prepare;

// "standard" sounds
- (void) explosion;
- (void) powerup;
- (void) laser_shoot;
- (void) hit_hurt;
- (void) jump;
- (void) blip_select;
- (void) pop;

// sound modifiers
- (void) randomize;
- (void) mutate;

@end
