//
//  RadAudioFilePlayerUnit.h
//  RadAudio
//
//  Created by Michael Burks on 7/1/13.
//
//

#import "RadAudioUnit.h"

@interface RadAudioFilePlayerUnit : RadAudioUnit
{
    AudioFileID inputFile;
    UInt64 nPackets;
    AudioStreamBasicDescription inputFormat;
    Float64 currentFrame;
    NSString *file;
}
- (void) prepareWithFile:(NSString *) filename;
- (Float64) duration;
- (void) pause;
- (void) play;
- (void) reset;
- (void) closeFile;
@end

