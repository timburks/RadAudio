//
//  RadAudioGraph.h
//  AUFilePlayer
//
//  Created by Tim Burks on 6/28/13.
//
//

#import <Foundation/Foundation.h>
#import "RadAudioUnit.h"
#import "RadAudioToneGeneratorUnit.h"
#import "RadAudioSFXRUnit.h"
#import "RadAudioFilePlayerUnit.h"
#import "RadAudioReverbUnit.h"
#import "RadAudioMixerUnit.h"


@interface RadAudioGraph : NSObject
{
@public
    AUGraph graph;
}

- (void) openGraph;
- (void) start;
- (void) stop;

- (RadAudioUnit *) addOutputNode;
- (RadAudioFilePlayerUnit *) addFilePlayerNode;
- (RadAudioReverbUnit *) addReverbNode;
- (RadAudioUnit *) addPitchNode;
- (RadAudioToneGeneratorUnit *) addToneGeneratorNode;
- (RadAudioSFXRUnit *) addSFXRNode;
- (RadAudioMixerUnit *) addMixerNode;

- (void) connectOutputOfNode:(RadAudioUnit *) outputNode channel:(int) outputChannel
               toInputOfNode:(RadAudioUnit *) inputNode channel:(int) inputChannel;
- (void) connectOutputOfNode:(RadAudioUnit *) outputNode
               toInputOfNode:(RadAudioUnit *) inputNode;

- (void) initializeGraph;
@end