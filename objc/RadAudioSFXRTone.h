//
//  RadAudioSFXRTone.h
//  RadAudio
//
//  Created by Tim Burks on 8/16/13.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    SFXR_SquareWave,
    SFXR_SawtoothWave,
    SFXR_SineWave,
    SFXR_Noise
} SFXR_WaveType;

@interface RadAudioSFXRTone : NSObject

@property (nonatomic, assign) int wave_type;
@property (nonatomic, assign) float sound_vol;      // VOLUME
@property (nonatomic, assign) int repeat_count;     // REPEAT COUNT

@property (nonatomic, assign) float env_attack;     // ATTACK TIME
@property (nonatomic, assign) float env_sustain;    // SUSTAIN TIME
@property (nonatomic, assign) float env_punch;      // SUSTAIN PUNCH
@property (nonatomic, assign) float env_decay;      // DECAY TIME

@property (nonatomic, assign) float base_freq;      // START FREQUENCY
@property (nonatomic, assign) float freq_limit;     // MIN FREQUENCY
@property (nonatomic, assign) float freq_ramp;      // SLIDE
@property (nonatomic, assign) float freq_dramp;     // DELTA SLIDE
@property (nonatomic, assign) float vib_strength;   // VIBRATO DEPTH
@property (nonatomic, assign) float vib_speed;      // VIBRATO SPEED

@property (nonatomic, assign) float arp_mod;        // CHANGE AMOUNT
@property (nonatomic, assign) float arp_speed;      // CHANGE SPEED

@property (nonatomic, assign) float duty;           // SQUARE DUTY
@property (nonatomic, assign) float duty_ramp;      // DUTY SWEEP

@property (nonatomic, assign) float repeat_speed;   // REPEAT SPEED

@property (nonatomic, assign) float pha_offset;     // PHASER OFFSET
@property (nonatomic, assign) float pha_ramp;       // PHASER SWEEP

@property (nonatomic, assign) float lpf_freq;       // LP FILTER CUTOFF
@property (nonatomic, assign) float lpf_ramp;       // LP FILTER CUTOFF SWEEP
@property (nonatomic, assign) float lpf_resonance;  // LP FILTER RESONANCE
@property (nonatomic, assign) float hpf_freq;       // HP FILTER CUTOFF
@property (nonatomic, assign) float hpf_ramp;       // HP FILTER CUTOFF SWEEP

// "standard" sounds
- (void) explosion;
- (void) powerup;
- (void) laser_shoot;
- (void) hit_hurt;
- (void) jump;
- (void) blip_select;
- (void) pop;
- (void) pickup_coin;

// sound modifiers
- (void) randomize;
- (void) mutate;

@end
