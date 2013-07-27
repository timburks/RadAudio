//
//  main.m
//  RadAudio
//
//  Created by Tim Burks on 6/25/12.
//  Copyright (c) 2013 Radtastical Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RadAudioUnit.h"
#import "RadAudioGraph.h"

int main(int argc, const char *argv[])
{    
    RadAudioGraph *player = [[RadAudioGraph alloc] init];
    
    // TB: it seems odd to do this before we've created nodes, but this appears
    // to cause audio units to be created as nodes are added, which is convenient
    [player openGraph];
    
    RadAudioFilePlayerUnit *filePlayerNode = [player addFilePlayerNode];
    RadAudioUnit *pitchNode = [player addPitchNode];
    RadAudioReverbUnit *reverbNode = [player addReverbNode];
    RadAudioUnit *outputNode = [player addOutputNode];
    RadAudioMixerUnit *mixerNode = [player addMixerNode];
    
    RadAudioToneGeneratorUnit *toneGeneratorNode1 = [player addToneGeneratorNode];
    toneGeneratorNode1.frequency = 660;
    
    RadAudioSFXRUnit *sfxrNode = [player addSFXRNode];
    RadAudioSFXRUnit *sfxrNode2 = [player addSFXRNode];
    
    
    [player connectOutputOfNode:filePlayerNode toInputOfNode:pitchNode];
    [player connectOutputOfNode:pitchNode channel:0 toInputOfNode:mixerNode channel:0];
    [player connectOutputOfNode:toneGeneratorNode1 channel:0 toInputOfNode:mixerNode channel:1];
    [player connectOutputOfNode:sfxrNode channel:0 toInputOfNode:mixerNode channel:2];
    [player connectOutputOfNode:sfxrNode2 channel:0 toInputOfNode:mixerNode channel:3];
    [player connectOutputOfNode:mixerNode toInputOfNode:reverbNode];
    [player connectOutputOfNode:reverbNode toInputOfNode:outputNode];
    
    [player initializeGraph];
    
    RadAudioFormat *filePlayerFormat = [filePlayerNode formatForOutput];

    [mixerNode setNumberOfInputs:4];
    [mixerNode setFormat:filePlayerFormat forInput:0];
    [mixerNode setFormat:filePlayerFormat forOutput:0];    
    [mixerNode setVolume:1.0 forInput:0];
    [mixerNode setVolume:0.02 forInput:1];
    [mixerNode setVolume:0.02 forInput:2];
    [mixerNode setVolume:0.02 forInput:3];
    [mixerNode setOutputVolume:1.0];
    
    [reverbNode setReverbRoomType:kReverbRoomType_Plate];
    
    int playTime;
    if (filePlayerNode) {
        [filePlayerNode prepareWithFile:@"/Users/tim/Desktop/Repositories/RadAudio/money.m4a"];
        playTime = [filePlayerNode duration];
    } else {
        playTime = 10;
    }
    
    [sfxrNode jump];
    [sfxrNode2 explosion];
    
    [player start];

    usleep(playTime*1000*1000);
    [player stop];
    
    [filePlayerNode closeFile];
    
    return 0;
}

