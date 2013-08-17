//
//  SFXViewController.m
//  RadAudio
//
//  Created by Tim Burks on 7/26/13.
//
//

#import "SFXViewController.h"
#import "RadAudioGraph.h"
#import "RadAudioSFXRTone.h"

@interface LightView : UIView
@property (nonatomic, strong) NSMutableArray *lights;
@end

@implementation LightView

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor redColor];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        int n = 16;
        
        self.lights = [NSMutableArray array];
        CGRect lightRect = self.bounds;
        lightRect.size.height = 40;
        lightRect.size.width /= n;
        for (int i = 0; i < n; i++) {
            UIView *light = [[UIView alloc] initWithFrame:CGRectInset(lightRect,15,15)];
            [self addSubview:light];
            lightRect.origin.x += lightRect.size.width;
            light.backgroundColor = [UIColor yellowColor];
            [self.lights addObject:light];
        }
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGRect lightRect = self.bounds;
    lightRect.size.height = 40;
    lightRect.size.width /= [self.lights count];
    for (int i = 0; i < [self.lights count]; i++) {
        UIView *light = [self.lights objectAtIndex:i];
        CGRect innerRect = CGRectInset(lightRect,5,5);
        lightRect.origin.x += lightRect.size.width;
        light.frame = innerRect;
    }
}

@end


@interface SFXViewController () <AudioObserver>

@property (nonatomic, strong) RadAudioSFXRTone *tone0;
@property (nonatomic, strong) RadAudioSFXRTone *tone1;
@property (nonatomic, strong) RadAudioSFXRTone *tone2;

@property (nonatomic, strong) RadAudioSFXRUnit *sfxr0;
@property (nonatomic, strong) RadAudioSFXRUnit *sfxr1;
@property (nonatomic, strong) RadAudioSFXRUnit *sfxr2;


@property (nonatomic, strong) LightView *lightView;

@end

@implementation SFXViewController

- (id) init
{
    self = [self initWithNibName:@"SFXViewController" bundle:nil];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.lightView = [[LightView alloc] initWithFrame:CGRectMake(0,20,self.view.bounds.size.width, 40)];
    [self.view addSubview:self.lightView];
    
    
    
    RadAudioGraph *player = [[RadAudioGraph alloc] init];
    [player openGraph];
    
    //RadAudioFilePlayerUnit *filePlayerNode = [player addFilePlayerNode];
    
    RadAudioUnit *outputNode = [player addOutputNode];
    RadAudioMixerUnit *mixerNode = [player addMixerNode];
    
    // RadAudioToneGeneratorUnit *toneGeneratorNode1 = [player addToneGeneratorNode];
    // toneGeneratorNode1.frequency = 660;
    
    self.tone0 = [[RadAudioSFXRTone alloc] init];
    self.tone1 = [[RadAudioSFXRTone alloc] init];
    self.tone2 = [[RadAudioSFXRTone alloc] init];
    
    self.sfxr0 = [player addSFXRNode];
    self.sfxr0.observer = self;
    self.sfxr1 = [player addSFXRNode];
    self.sfxr2 = [player addSFXRNode];
    
    self.sfxr0.tone = self.tone0;
    self.sfxr1.tone = self.tone1;
    self.sfxr2.tone = self.tone2;
    
    self.tone0.base_freq = 0.2;
    self.tone1.base_freq = 0.4;
    self.tone2.base_freq = 0.3;
    
    // [player connectOutputOfNode:filePlayerNode channel:0 toInputOfNode:mixerNode channel:0];
    // [player connectOutputOfNode:toneGeneratorNode1 channel:0 toInputOfNode:mixerNode channel:1];
    
    [player connectOutputOfNode:self.sfxr0 channel:0 toInputOfNode:mixerNode channel:0];
    [player connectOutputOfNode:self.sfxr1 channel:0 toInputOfNode:mixerNode channel:1];
    [player connectOutputOfNode:self.sfxr2 channel:0 toInputOfNode:mixerNode channel:2];
    [player connectOutputOfNode:mixerNode toInputOfNode:outputNode];
    
    [player initializeGraph];
    
    [mixerNode setNumberOfInputs:1];
    [mixerNode setVolume:1.0 forInput:0];
    [mixerNode setOutputVolume:1.0];
    
#ifdef NONO
    if (filePlayerNode) {
        [filePlayerNode prepareWithFile:[[NSBundle mainBundle] pathForResource:@"money" ofType:@"m4a"]];
    }
#endif
    [player start];
    
    
}


- (void) tick:(int) time {
    
    for (UIView *light in self.lightView.lights) {
        light.backgroundColor = [UIColor blackColor];
    }
    UIView *light = [self.lightView.lights objectAtIndex:time % [self.lightView.lights count]];
    light.backgroundColor = [UIColor yellowColor];
    
    
    
    switch (time % 16) {
        case 0:
            [self.sfxr0 playSample];
            break;
        case 4:
            [self.sfxr1 playSample];
            break;
        case 8:
            [self.sfxr2 playSample];
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) buttonPressed:(id) sender
{
    switch ([sender tag]) {
        case 0:
            [self.tone0 jump];
            [self.sfxr0 playSample];
            break;
        case 1:
            [self.tone1 explosion];
            [self.sfxr1 playSample];
            break;
        case 2:
            [self.tone2 pickup_coin];
            [self.sfxr2 playSample];
            break;
        default:
            break;
    }
}

@end
