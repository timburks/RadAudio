#import <Foundation/Foundation.h>

typedef enum {
    SFXR_SquareWave,
    SFXR_SawtoothWave,
    SFXR_SineWave,
    SFXR_Noise
} SFXR_WaveType;

#import "RadAudioUnit.h"

@interface RadAudioSFXRUnit : RadAudioUnit

@property (nonatomic, assign) int wave_type;
@property (nonatomic, assign) float sound_vol;        // VOLUME
@property (nonatomic, assign) int p_repeat_count;     // REPEAT COUNT
@property (nonatomic, assign) float p_env_attack;     // ATTACK TIME
@property (nonatomic, assign) float p_env_sustain;    // SUSTAIN TIME
@property (nonatomic, assign) float p_env_decay;      // DECAY TIME
@property (nonatomic, assign) float p_env_punch;      // SUSTAIN PUNCH
@property (nonatomic, assign) float p_base_freq;      // START FREQUENCY
@property (nonatomic, assign) float p_freq_limit;     // MIN FREQUENCY
@property (nonatomic, assign) float p_freq_ramp;      // SLIDE
@property (nonatomic, assign) float p_freq_dramp;     // DELTA SLIDE
@property (nonatomic, assign) float p_duty;           // SQUARE DUTY
@property (nonatomic, assign) float p_duty_ramp;      // DUTY SWEEP
@property (nonatomic, assign) float p_vib_strength;   // VIBRATO DEPTH
@property (nonatomic, assign) float p_vib_speed;      // VIBRATO SPEED
@property (nonatomic, assign) float p_lpf_resonance;  // LP FILTER RESONANCE
@property (nonatomic, assign) float p_lpf_freq;       // LP FILTER CUTOFF
@property (nonatomic, assign) float p_lpf_ramp;       // LP FILTER CUTOFF SWEEP
@property (nonatomic, assign) float p_hpf_freq;       // HP FILTER CUTOFF
@property (nonatomic, assign) float p_hpf_ramp;       // HP FILTER CUTOFF SWEEP
@property (nonatomic, assign) float p_pha_offset;     // PHASER OFFSET
@property (nonatomic, assign) float p_pha_ramp;       // PHASER SWEEP
@property (nonatomic, assign) float p_repeat_speed;   // REPEAT SPEED
@property (nonatomic, assign) float p_arp_speed;      // CHANGE SPEED
@property (nonatomic, assign) float p_arp_mod;        // CHANGE AMOUNT


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
