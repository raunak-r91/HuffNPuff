//
//  MainViewController.m
//  Game
//
//  Created by Raunak Rajpuria on 3/1/13.
//  Copyright (c) 2013 Raunak Rajpuria. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

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
	// Do any additional setup after loading the view.
    UIImage *bgImage = [UIImage imageNamed:BACKGROUND_IMAGE];
    UIImage *groundImage = [UIImage imageNamed:GROUND_IMAGE];
    
    UIImageView *background = [[UIImageView alloc] initWithImage:bgImage];
    background.tag = 6;
    UIImageView *ground = [[UIImageView alloc] initWithImage:groundImage];
    ground.tag = 7;
    
    CGFloat backgroundWidth = bgImage.size.width;
    CGFloat backgroundHeight = bgImage.size.height;
    CGFloat groundWidth = groundImage.size.width;
    CGFloat groundHeight = groundImage.size.height;
    
    CGFloat groundY = self.mainScreen.frame.size.height - groundHeight;
    CGFloat backgroundY = groundY - backgroundHeight;
    
    background.frame = CGRectMake(0, backgroundY, backgroundWidth, backgroundHeight);
    ground.frame = CGRectMake(0, groundY, groundWidth, groundHeight);
    
    [self.mainScreen addSubview:background];
    [self.mainScreen addSubview:ground];
    [self.mainScreen sendSubviewToBack:background];
    [self.mainScreen sendSubviewToBack:ground];
}

// Override to allow orientations other than the default portrait orientation.
// Rotation for v. 5.1.1
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        return YES;
    else
        return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setMainScreen:nil];
    [super viewDidUnload];
}
@end
