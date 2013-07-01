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
}
- (void) prepareWithFile:(NSString *) filename;
- (Float64) duration;
- (void) closeFile;
@end

