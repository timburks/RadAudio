//
//  RadAudioUnit.m
//  AUFilePlayer
//
//  Created by Tim Burks on 6/28/13.
//

#import "RadAudioUnit.h"

#pragma mark utility functions

void CheckError(OSStatus error, const char *operation)
{
    if (error == noErr) return;
    char errorString[20];
    // See if it appears to be a 4-char-code
    *(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(error);
    if (isprint(errorString[1]) && isprint(errorString[2]) &&
        isprint(errorString[3]) && isprint(errorString[4])) {
        errorString[0] = errorString[5] = '\'';
        errorString[6] = '\0';
    } else
        // No, format it as an integer
        sprintf(errorString, "%d", (int)error);
    fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
    exit(1);
}

@implementation RadAudioFormat
@end

@implementation RadAudioUnit

- (id) initWithGraph:(AUGraph) owningGraph
{
    if (self = [super init]) {
        self->graph = owningGraph;
    }
    return self;
}

- (AudioUnit) audioUnit {
    if (!audioUnit) {
        // Get the reference to the AudioUnit object for the reverb graph node
        CheckError(AUGraphNodeInfo(graph,
                                   audioUnitNode,
                                   NULL,
                                   &audioUnit),
                   "AUGraphNodeInfo failed");
    }
    return audioUnit;
}

- (RadAudioFormat *) formatForInput:(int) inputNumber
{
    RadAudioFormat *format = [[RadAudioFormat alloc] init];
    UInt32 size = sizeof(format->format);
    CheckError(AudioUnitGetProperty([self audioUnit],
                                    kAudioUnitProperty_StreamFormat,
                                    kAudioUnitScope_Input,
                                    inputNumber,
                                    &(format->format),
                                    &size),"audio unit get format failed");
    return format;
}

- (RadAudioFormat *) formatForInput
{
    return [self formatForInput:0];
}

- (RadAudioFormat *) formatForOutput
{
    RadAudioFormat *format = [[RadAudioFormat alloc] init];
    UInt32 size = sizeof(format->format);
    CheckError(AudioUnitGetProperty([self audioUnit],
                                    kAudioUnitProperty_StreamFormat,
                                    kAudioUnitScope_Output,
                                    0,
                                    &(format->format),
                                    &size), "audio unit get format failed");
    return format;
}

- (void) setFormat:(RadAudioFormat *) format forInput:(int) inputNumber
{
    AudioUnit unit = [self audioUnit];
    CheckError(AudioUnitSetProperty(unit,
                                    kAudioUnitProperty_StreamFormat,
                                    kAudioUnitScope_Input,
                                    inputNumber,
                                    &format->format,
                                    sizeof(format->format)), "Audio Unit Set Format failed");
}

- (void) setFormat:(RadAudioFormat *) format forOutput:(int) outputNumber
{
    AudioUnit unit = [self audioUnit];
    CheckError(AudioUnitSetProperty(unit,
                                    kAudioUnitProperty_StreamFormat,
                                    kAudioUnitScope_Output,
                                    outputNumber,
                                    &format->format,
                                    sizeof(format->format)), "Audio Unit Set Format Failed");
}

@end