//
//  RadAudioGraph.m
//  AUFilePlayer
//
//  Created by Tim Burks on 6/28/13.
//
//

#import "RadAudioGraph.h"



@implementation RadAudioGraph

- (id) init
{
    if (self = [super init]) {
        // Create a new AUGraph
        CheckError(NewAUGraph(&graph), "NewAUGraph failed");
    }
    return self;
}

- (void) openGraph
{
    // Opening the graph opens all contained audio units but does not allocate any resources yet
    CheckError(AUGraphOpen(graph), "AUGraphOpen failed");
}

- (void) start
{
    CheckError(AUGraphStart(graph), "AUGraphStart failed");
}

- (void) stop
{
    AUGraphStop(graph);    
}

- (void) close
{
    AUGraphUninitialize(graph);
    AUGraphClose(graph);
}

- (RadAudioUnit *) addOutputNode
{
    AudioComponentDescription outputcd = {0};
    outputcd.componentType = kAudioUnitType_Output;
    outputcd.componentSubType = kAudioUnitSubType_DefaultOutput;
    outputcd.componentManufacturer = kAudioUnitManufacturer_Apple;
    RadAudioUnit *unit = [[RadAudioUnit alloc] initWithGraph:graph];
    CheckError(AUGraphAddNode(graph, &outputcd, &(unit->audioUnitNode)),
               "AUGraphAddNode[kAudioUnitSubType_DefaultOutput] failed");
    return unit;
}

- (RadAudioFilePlayerUnit *) addFilePlayerNode
{
    AudioComponentDescription fileplayercd = {0};
    fileplayercd.componentType = kAudioUnitType_Generator;
    fileplayercd.componentSubType = kAudioUnitSubType_AudioFilePlayer;
    fileplayercd.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    //Adds a node with above description to graph
    RadAudioFilePlayerUnit *unit = [[RadAudioFilePlayerUnit alloc] initWithGraph:graph];
    CheckError(AUGraphAddNode(graph,
                              &fileplayercd,
                              &(unit->audioUnitNode)),
               "AUGraphAddNode[kAudioUnitSubType_AudioFilePlayer] failed");
    return unit;
}

- (RadAudioReverbUnit *) addReverbNode
{
    AudioComponentDescription reverbcd = {0};
    reverbcd.componentType = kAudioUnitType_Effect;
    reverbcd.componentSubType = kAudioUnitSubType_MatrixReverb;
    reverbcd.componentManufacturer = kAudioUnitManufacturer_Apple;
    // Adds a node with the above description to the graph
    RadAudioReverbUnit *unit = [[RadAudioReverbUnit alloc] initWithGraph:graph];
    CheckError(AUGraphAddNode(graph,
                              &reverbcd,
                              &(unit->audioUnitNode)),
               "AUGraphAddNode[kAudioUnitSubType_MatrixReverb] failed");
    return unit;
}

- (RadAudioUnit *) addPitchNode
{
    //Generate a description that matches the pitch effect
    AudioComponentDescription pitchcd = {0};
    pitchcd.componentType = kAudioUnitType_Effect;
    pitchcd.componentSubType = kAudioUnitSubType_Pitch;
    pitchcd.componentManufacturer = kAudioUnitManufacturer_Apple;
    RadAudioUnit *unit = [[RadAudioUnit alloc] initWithGraph:graph];
    CheckError(AUGraphAddNode(graph,
                              &pitchcd,
                              &(unit->audioUnitNode)),
               "AUGraphAddNode[kAudioUnitSubType_Pitch] failed");
    return unit;
}

- (RadAudioToneGeneratorUnit *) addToneGeneratorNode
{
    //Generate a description that matches the pitch effect
    AudioComponentDescription pitchcd = {0};
    pitchcd.componentType = kAudioUnitType_Effect;
    pitchcd.componentSubType = kAudioUnitSubType_Pitch;
    pitchcd.componentManufacturer = kAudioUnitManufacturer_Apple;
    RadAudioToneGeneratorUnit *unit = [[RadAudioToneGeneratorUnit alloc] initWithGraph:graph];
    CheckError(AUGraphAddNode(graph,
                              &pitchcd,
                              &(unit->audioUnitNode)),
               "AUGraphAddNode[kAudioUnitSubType_Pitch] failed");
    [unit prepare];
    return unit;
}

- (RadAudioMixerUnit *) addMixerNode
{
    AudioComponentDescription mixercd = {0};
    mixercd.componentFlags = 0;
    mixercd.componentFlagsMask = 0;
    mixercd.componentType = kAudioUnitType_Mixer;
    mixercd.componentSubType = kAudioUnitSubType_MultiChannelMixer;
    mixercd.componentManufacturer = kAudioUnitManufacturer_Apple;
    RadAudioMixerUnit *unit = [[RadAudioMixerUnit alloc] initWithGraph:graph];
    CheckError(AUGraphAddNode(graph,
                              &mixercd,
                              &(unit->audioUnitNode)),
               "AUGraphAddNode[kAudioUnitSubType_Pitch] failed");
    return unit;
}

- (void) connectOutputOfNode:(RadAudioUnit *) outputNode channel:(int) outputChannel
               toInputOfNode:(RadAudioUnit *) inputNode channel:(int) inputChannel
{
    CheckError(AUGraphConnectNodeInput(graph,
                                       outputNode->audioUnitNode,
                                       outputChannel,
                                       inputNode->audioUnitNode,
                                       inputChannel),
               "AUGraphConnectNodeInput failed");
}

- (void) connectOutputOfNode:(RadAudioUnit *) outputNode
               toInputOfNode:(RadAudioUnit *) inputNode
{
    CheckError(AUGraphConnectNodeInput(graph,
                                       outputNode->audioUnitNode,
                                       0,
                                       inputNode->audioUnitNode,
                                       0),
               "AUGraphConnectNodeInput failed");
}

- (void) initializeGraph {
    // initialize the graph (causes resources to be allocated)
    CheckError(AUGraphInitialize(graph),  "AUGraphInitialize failed");
}


@end
