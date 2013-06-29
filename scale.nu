
(load "RadAudio")

(set player ((RadAudioGraph alloc) init))
(player openGraph)

(set outputNode (player addOutputNode))
(set toneGeneratorNode (player addToneGeneratorNode))

(player connectOutputOfNode:toneGeneratorNode toInputOfNode:outputNode)
(player initializeGraph)

(set C2 261.626)
(set D2 293.665)
(set E2 329.628)
(set F2 349.228)
(set G2 391.995)
(set A3 440.000)
(set B3 493.883)
(set C3 523.251)

(set scale (array C2 D2 E2 F2 G2 A3 B3 C3))

(set usleep (NuBridgedFunction functionWithName:"usleep" signature:"vi"))

(set QUARTERNOTE 250000)
(toneGeneratorNode setFrequency:C2)

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


