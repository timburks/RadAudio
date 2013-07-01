//
//  RadAudioFilePlayerUnit.m
//  RadAudio
//
//  Created by Michael Burks on 7/1/13.
//
//

#import "RadAudioFilePlayerUnit.h"

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
