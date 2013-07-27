//
//  RadAudioToneGeneratorUnit.h
//  RadAudio
//
//  Created by Michael Burks on 7/1/13.
//
//

#import "RadAudioUnit.h"

@interface RadAudioToneGeneratorUnit : RadAudioUnit
@property (nonatomic, assign) int startingPhase;
@property (nonatomic, assign) double frequency;
@property (nonatomic, copy) RadRenderProc renderer;
@property (nonatomic, copy) RenderBlock renderBlock;
- (void) prepare;
@end