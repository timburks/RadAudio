
(load "RadAudio")

(set player ((RadAudioGraph alloc) init))
(player openGraph)

(set outputNode (player addOutputNode))
(set toneGeneratorNode (player addToneGeneratorNode))

(player connectOutputOfNode:toneGeneratorNode toInputOfNode:outputNode)
(player initializeGraph)

(set C4 261.626)
(set D4 293.665)
(set E4 329.628)
(set F4 349.228)
(set G4 391.995)
(set A4 440.000)
(set B4 493.883)
(set C5 523.251)

(set scale (array C4 D4 E4 F4 G4 A4 B4 C5))

(set usleep (NuBridgedFunction functionWithName:"usleep" signature:"vi"))

(set QUARTERNOTE 250000)
(toneGeneratorNode setFrequency:C4)

(player start)
(2 times:
   (do (i)
       (scale each:
              (do (note)
                  (toneGeneratorNode setFrequency:note)
                  (usleep QUARTERNOTE)))     
       ((scale reversedArray) each:
        (do (note)
            (toneGeneratorNode setFrequency:note)
            (usleep QUARTERNOTE)))))
(usleep (* 4 QUARTERNOTE))
(player stop)


