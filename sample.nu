
(load "RadAudio")

(set player ((RadAudioGraph alloc) init))
(player openGraph)

(set filePlayerNode (player addFilePlayerNode))
(set pitchNode (player addPitchNode))
(set toneGeneratorNode1 (player addToneGeneratorNode))
(set toneGeneratorNode2 (player addToneGeneratorNode))
(set mixerNode (player addMixerNode))
(set reverbNode (player addReverbNode))
(set outputNode (player addOutputNode))


(player connectOutputOfNode:filePlayerNode toInputOfNode:pitchNode)
(player connectOutputOfNode:pitchNode channel:0 toInputOfNode:mixerNode channel:0)
(player connectOutputOfNode:toneGeneratorNode1 channel:0 toInputOfNode:mixerNode channel:1)
(player connectOutputOfNode:toneGeneratorNode2 channel:0 toInputOfNode:mixerNode channel:2)
(player connectOutputOfNode:mixerNode toInputOfNode:reverbNode)
(player connectOutputOfNode:reverbNode toInputOfNode:outputNode)

(player initializeGraph)

(toneGeneratorNode1 setFrequency:440)
(toneGeneratorNode2 setFrequency:660)

(filePlayerNode prepareWithFile:@"money.m4a")
(set filePlayerFormat (filePlayerNode formatForOutput))

(mixerNode setNumberOfInputs:3)
(mixerNode setFormat:filePlayerFormat forInput:0)
(mixerNode setFormat:filePlayerFormat forOutput:0)
(mixerNode setVolume:1.0 forInput:0)
(mixerNode setVolume:0.1 forInput:1)
(mixerNode setVolume:0.1 forInput:1)
(mixerNode setOutputVolume:1.0)

(set kReverbRoomType_Cathedral 8)
(reverbNode setReverbRoomType:kReverbRoomType_Cathedral)

(set playTime (filePlayerNode duration))
(NSLog "playing for #{playTime}s")
(player start)
(sleep playTime)
(player stop)
(filePlayerNode closeFile)


