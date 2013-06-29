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
                                    0,
                                    &format->format,
                                    sizeof(format->format)), "Audio Unit Set Format failed");
}

- (void) setFormat:(RadAudioFormat *) format forOutput:(int) outputNumber
{
    AudioUnit unit = [self audioUnit];
    CheckError(AudioUnitSetProperty(unit,
                                    kAudioUnitProperty_StreamFormat,
                                    kAudioUnitScope_Output,
                                    0,
                                    &format->format,
                                    sizeof(format->format)), "Audio Unit Set Format Failed");
}

@end

@implementation RadAudioFilePlayerUnit

- (void) prepareWithFile:(NSString *) filename;
{
    // Open the input audio file
    CFURLRef inputFileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                                          (__bridge CFStringRef) filename,
                                                          kCFURLPOSIXPathStyle,
                                                          false);    
    CheckError(AudioFileOpenURL(inputFileURL,
                                kAudioFileReadPermission,
                                0,
                                &inputFile),
               "AudioFileOpenURL failed");
    CFRelease(inputFileURL);
    
    // Get the audio data format from the file
    UInt32 propSize = sizeof(inputFormat);
    CheckError(AudioFileGetProperty(inputFile,
                                    kAudioFilePropertyDataFormat,
                                    &propSize,
                                    &inputFormat),
               "Couldn't get file's data format");
    
    AudioUnit fileAU = [self audioUnit];
    
    // Tell the file player unit to load the file we want to play
    CheckError(AudioUnitSetProperty(fileAU,
                                    kAudioUnitProperty_ScheduledFileIDs,
                                    kAudioUnitScope_Global,
                                    0,
                                    &inputFile,
                                    sizeof(inputFile)),
               "AudioUnitSetProperty[kAudioUnitProperty_ScheduledFileIDs] failed");
    
    UInt32 propsize = sizeof(nPackets);
    CheckError(AudioFileGetProperty(inputFile,
                                    kAudioFilePropertyAudioDataPacketCount,
                                    &propsize,
                                    &nPackets),
               "AudioFileGetProperty[kAudioFilePropertyAudioDataPacketCount] failed");
    
    // Tell the file player AU to play the entire file
    ScheduledAudioFileRegion rgn;
    memset(&rgn.mTimeStamp, 0, sizeof(rgn.mTimeStamp));
    rgn.mTimeStamp.mFlags = kAudioTimeStampSampleTimeValid;
    rgn.mTimeStamp.mSampleTime = 0;
    rgn.mCompletionProc = NULL;
    rgn.mCompletionProcUserData = NULL;
    rgn.mAudioFile = inputFile;
    rgn.mLoopCount = 1;
    rgn.mStartFrame = 0;
    rgn.mFramesToPlay = (UInt32) nPackets *  inputFormat.mFramesPerPacket;
    
    CheckError(AudioUnitSetProperty(fileAU,
                                    kAudioUnitProperty_ScheduledFileRegion,
                                    kAudioUnitScope_Global,
                                    0,
                                    &rgn,
                                    sizeof(rgn)),
               "AudioUnitSetProperty[kAudioUnitProperty_ScheduledFileRegion] failed");
    
    // Tell the file player AU when to start playing
    AudioTimeStamp startTime;
    memset(&startTime, 0, sizeof(startTime));
    startTime.mFlags = kAudioTimeStampSampleTimeValid;
    startTime.mSampleTime = -1;
    
    CheckError(AudioUnitSetProperty(fileAU,
                                    kAudioUnitProperty_ScheduleStartTimeStamp,
                                    kAudioUnitScope_Global,
                                    0,
                                    &startTime,
                                    sizeof(startTime)),
               "AudioUnitSetProperty[kAudioUnitProperty_ScheduleStartTimeStamp]");    
}

- (Float64) duration
{
    return (nPackets * inputFormat.mFramesPerPacket) / inputFormat.mSampleRate;
}

- (void) closeFile
{
    AudioFileClose(inputFile);
}

@end

@implementation RadAudioToneGeneratorUnit

OSStatus RadAudioToneGeneratorUnitRenderProc(void *inRefCon,
                                             AudioUnitRenderActionFlags *ioActionFlags,
                                             const AudioTimeStamp *inTimeStamp,
                                             UInt32 inBusNumber,
                                             UInt32 inNumberFrames,
                                             AudioBufferList *ioData) {
    RadAudioToneGeneratorUnit *player = (__bridge RadAudioToneGeneratorUnit *)inRefCon;
    //    printf ("ToneGeneratorRenderProc needs %ld frames at %f\n",
    //            (unsigned long) inNumberFrames, CFAbsoluteTimeGetCurrent());
    
    double cycleLength = 44100. / player.frequency;
    CGFloat step  = 2*M_PI/cycleLength;
    CGFloat start = player.startingPhase * step;
    Float32 *leftChannel = (Float32 *)ioData->mBuffers[0].mData;
    Float32 *rightChannel = (Float32 *)ioData->mBuffers[1].mData;
    
#define SINE
#ifdef SINE
    for (int frame = 0; frame < inNumberFrames; frame++) {
        Float32 value = (Float32) sin(frame*step+start);
        leftChannel[frame] = value;
        rightChannel[frame] = value;
    }
#else
    for (int frame = 0; frame < inNumberFrames; frame++) {
        Float32 value = (Float32) sin(frame*step+start);
        if (value > 0) value = 1;
        else value = -1;
        leftChannel[frame] = value;
        rightChannel[frame] = value;
    }
#endif
    
    player.startingPhase += inNumberFrames;
    return noErr;
}

#pragma mark callback function

- (id) init {
    if (self = [super init]) {
        self.frequency = 880;
        self.startingPhase = 0;
    }
    return self;
}

- (void) prepare
{
    AURenderCallbackStruct input;
    input.inputProc = RadAudioToneGeneratorUnitRenderProc;
    input.inputProcRefCon = (__bridge void *) self;
    CheckError(AudioUnitSetProperty([self audioUnit],
                                    kAudioUnitProperty_SetRenderCallback,
                                    kAudioUnitScope_Input,
                                    0,
                                    &input,
                                    sizeof(input)),
               "AudioUnitSetProperty failed");
}
@end


@implementation RadAudioReverbUnit

- (void) setReverbRoomType:(UInt32) reverbRoomType
{
    AudioUnit reverbUnit = [self audioUnit];
    UInt32 roomType = reverbRoomType;
    CheckError(AudioUnitSetProperty(reverbUnit,
                                    kAudioUnitProperty_ReverbRoomType,
                                    kAudioUnitScope_Global,
                                    0,
                                    &roomType,
                                    sizeof(UInt32)),
               "AudioUnitSetProperty[kAudioUnitProperty_ReverbRoomType] failed");
}

@end

@implementation RadAudioMixerUnit

- (void) setNumberOfInputs:(int) numberOfInputs
{
    UInt32 numbuses = numberOfInputs;
    UInt32 size = sizeof(numbuses);
    AudioUnitSetProperty([self audioUnit],
                         kAudioUnitProperty_ElementCount,
                         kAudioUnitScope_Input,
                         0,
                         &numbuses,
                         size);
}

- (void) setVolume:(float) volume forInput:(int) inputChannel
{
    AudioUnitSetParameter([self audioUnit],
                          kMultiChannelMixerParam_Volume,
                          kAudioUnitScope_Input,
                          inputChannel,
                          volume,
                          0);
}

- (void) setOutputVolume:(float) volume
{
    AudioUnitSetParameter([self audioUnit],
                          kMultiChannelMixerParam_Volume,
                          kAudioUnitScope_Output,
                          0,
                          volume,
                          0);
}
@end


