//
//  LcOutput.m
//  letscount
//
//  Created by stage on 12/06/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LcOutput.h"
#import <AVFoundation/AVFoundation.h>

@implementation LcOutput

@synthesize player;
@synthesize bt_start;
@synthesize bt_pause;
@synthesize bt_stop;
@synthesize lb_count;
@synthesize lb_pitch;
@synthesize step_pitch;
@synthesize bt_test;
@synthesize pic_pattern;
@synthesize slide_pitch;


NSTimer *timer_pitch;
int loop_counter = 0;
int loop_max = 10;
int total_max = 1000;
int total_count = 0;
int set_count = 0;
NSMutableDictionary *datas;
NSString *lng = @"jp";
int speed = 1;
double interval = 1.0;
bool istest = NO;
NSDictionary *dic_define;

-(void)startPitch{
	[self endPitch];
	timer_pitch = [NSTimer scheduledTimerWithTimeInterval:interval
												   target:self
												 selector:@selector(pitchUpdate:)
												 userInfo:nil
												  repeats:YES];
	
}
-(void)endPitch{
	if (timer_pitch != nil){
		[timer_pitch invalidate];
		timer_pitch = nil;
	}
}

-(void)startCount{
	istest = NO;
	loop_counter = 0;
	total_count = 0;
	set_count = 0;
	
	if (!istest){
		lb_count.text = @"0 / 0";
	}

	[self startPitch];
	[bt_start setEnabled:NO];
	[bt_pause setEnabled:YES];
	[bt_stop setEnabled:YES];
	NSLog(@"start");
}
-(void)endCount{
	istest = NO;
	[self endPitch];
	[bt_start setEnabled:YES];
	[bt_pause setEnabled:NO];
	[bt_stop setEnabled:NO];
	NSLog(@"stop");
}
-(void)test{
	if (istest){
		[self endCount];
	}else {
		istest = YES;
		loop_counter = 0;
		total_count = 0;
		set_count = 0;
		[self startPitch];
	}
}


-(NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView{
	return 2;
}

-(NSInteger)pickerView:(UIPickerView*)pView numberOfRowsInComponent:(NSInteger)component{
	if (component == 0){
		NSArray *arr_lang = [dic_define objectForKey:@"lang"];
		return [arr_lang count];
	}else{
		NSDictionary *dic_pattern = [dic_define objectForKey:@"pattern"];
		return [dic_pattern count];
	}
}

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
	if (component == 0){
		NSArray *arr_lang = [dic_define objectForKey:@"lang"];
		return [arr_lang objectAtIndex:row];
	}else if (component == 1){
		NSArray *arr_pattern = [dic_define objectForKey:@"pattern_label"];
		return [arr_pattern objectAtIndex:row];
	}
	return @"-";
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
	if (component == 0){
		NSArray *arr_lang = [dic_define objectForKey:@"lang"];
		lng = [arr_lang objectAtIndex:row];
	}else if (component == 1){
		NSArray *arr_pattern = [dic_define objectForKey:@"pattern"];
		loop_max = [[arr_pattern objectAtIndex:row] integerValue]; 
		total_count = 0;
		loop_counter = 0;
		set_count = 0;
	}
}


- (IBAction)changeSpeed:(id)sender{
	int new_pitch = 0;
	if (sender == self.step_pitch){
		new_pitch = self.step_pitch.value;
	}else if (sender == self.slide_pitch){
		new_pitch = self.slide_pitch.value;
	}
		
	interval = 60 / self.step_pitch.value;
	NSString *str_speed = [NSString stringWithFormat:@"%d / min",(int)new_pitch];
	self.lb_pitch.text = str_speed;
		
	if (sender == self.step_pitch){
		self.slide_pitch.value = new_pitch;
	}else if (sender == self.slide_pitch){
		self.step_pitch.value = new_pitch;
	}
	
	if (new_pitch <= 40){
		speed = 0;
	}else if (new_pitch >= 100){
		speed = 2;
	}else{
		speed = 1;
	}
	
	if (timer_pitch != nil){
		[self startPitch];
	}
}


-(IBAction)buttonPressed:(id)sender{
	if (sender == bt_start){
		[self startCount];
	}else if (sender == bt_stop){
		[self endCount];
	}else if (sender == bt_pause){
		if (timer_pitch == nil){
			[self startPitch];
			NSLog(@"restart");
		}else{
			[self endPitch];
			NSLog(@"pause");
		}
	}else if (sender == bt_test){
		[self test];
	}
	
}

-(void)playerStart:(int)idx:(NSString*)lng:(int)speed{
	[self playerStop];
	
	NSString *soundName = [NSString stringWithFormat:@"%d_%@_%d",idx,lng,speed];
	NSString *soundPath = [[NSBundle mainBundle] pathForResource:soundName ofType:@"mp3"];
	NSData *data = [NSData dataWithContentsOfFile:soundPath];
	//NSData *data = [datas objectForKey:soundName];
	
	player = [[AVAudioPlayer alloc] initWithData:data error:NULL];
	player.numberOfLoops = 0;
	[player setDelegate:self];
	[player play];

}

-(void)playerStop{
	if (player != nil){
		[player stop];
		player = nil;
	}	
}

-(void)pitchUpdate:(NSTimer*)tmr{
	loop_counter++;
	total_count++;
	NSLog(@"PITCH %d / %d / %d",loop_counter,set_count,total_count);
	
	NSString *str_count = nil;
	if (loop_max >= 10){
		str_count = [NSString stringWithFormat:@"%d / %d",loop_counter,total_count];
	}else{
		str_count = [NSString stringWithFormat:@"%d / %d",loop_counter,set_count];
	}

	if (!istest){
		lb_count.text = str_count;
	}
	
	int idx = loop_counter;
	if (loop_max >= 10){
		if (total_count%1000 == 0){
			idx = 1000;
		}else if (total_count%100 == 0){
			idx = total_count%1000;
		}else if (total_count%10 == 0){
			idx = total_count%100;
		}
	}

	
	
	
	
	[self playerStart:idx:lng:speed];

	if (loop_counter >= loop_max){
		if (istest){
			[self endCount];
			return;
		}
		loop_counter = 0;
		set_count++;
	}

	if (total_count >= total_max){
		[self endCount];
	}
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)viewDidLoad
{
    [super viewDidLoad];
	
//	datas = [NSMutableDictionary dictionary];
//	for(int i=1;i<=10;i++){
//		NSString *soundName = [NSString stringWithFormat:@"%d",i];
//		NSString *soundPath = [[NSBundle mainBundle] pathForResource:soundName ofType:@"mp3"];
//		NSData *data = [NSData dataWithContentsOfFile:soundPath];
//		[datas setObject:data forKey:soundName];
//	}
	
	NSString *defPath = [[NSBundle mainBundle]pathForResource:@"Define" ofType:@"plist"];
	dic_define = [[NSDictionary alloc]initWithContentsOfFile:defPath];
	
	self.pic_pattern.delegate = self;
	
	self.step_pitch.minimumValue = 6;
	self.step_pitch.maximumValue = 180;
	self.step_pitch.value = 60;
	self.step_pitch.stepValue = 1;
	
	self.slide_pitch.minimumValue = self.step_pitch.minimumValue;
	self.slide_pitch.maximumValue = self.step_pitch.maximumValue;
	self.slide_pitch.value = self.step_pitch.value;
	
	NSString *str_speed = [NSString stringWithFormat:@"%d / min",(int)self.step_pitch.value];
	self.lb_pitch.text = str_speed;
	
	self.lb_count.text = @"";

	[self.pic_pattern selectRow:1 inComponent:0 animated:NO];
	[self.pic_pattern selectRow:0 inComponent:1 animated:NO];
	
	//ダミー再生
	[self playerStart:0:lng:speed];
	
}

- (void)viewDidUnload
{
	[self setBt_test:nil];
	[self setPic_pattern:nil];
    [self setSlide_pitch:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
