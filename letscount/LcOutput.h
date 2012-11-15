//
//  LcOutput.h
//  letscount
//
//  Created by stage on 12/06/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface LcOutput : UIViewController <AVAudioPlayerDelegate,UIPickerViewDelegate>

@property(nonatomic,retain)IBOutlet AVAudioPlayer *player;

@property(nonatomic,retain)IBOutlet UIButton *bt_start;
@property(nonatomic,retain)IBOutlet UIButton *bt_pause;
@property(nonatomic,retain)IBOutlet UIButton *bt_stop;
@property(nonatomic,retain)IBOutlet UILabel *lb_count;
@property(nonatomic,retain)IBOutlet UILabel *lb_pitch;
@property(nonatomic,retain)IBOutlet UIStepper *step_pitch;
@property (strong, nonatomic) IBOutlet UIButton *bt_test;
@property (strong, nonatomic) IBOutlet UIPickerView *pic_pattern;
@property (strong, nonatomic) IBOutlet UISlider *slide_pitch;

-(IBAction)buttonPressed:(id)sender;
-(void)pitchUpdate:(NSTimer*)tmr;
//-(void)playerStart:(int)idx:(NSString*)lng:(int)speed;
//-(void)playerStop;
- (IBAction)changeSpeed:(id)sender;


@end
