//
//  PlayViewController.m
//  Game
//
//  Created by Raunak Rajpuria on 3/1/13.
//  Copyright (c) 2013 Raunak Rajpuria. All rights reserved.
//
/*
 PlayViewController is responsible for setting up and updating the objects in the Play view which are displayed to the user. It only deals with the Play Mode.
 This class sets up the view for the play mode by reading the data from a saved file.nOnce loaded, the extension category of this class starts the physics engine and deals with collisions
 */

#import "PlayViewController.h"

@interface PlayViewController () 
@end

@implementation PlayViewController

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
    [self setUp];
    [self createPalette];
    [self load];
}

- (void)setUp {
    self.currentScore = 0;
    
    //Add self as KVO observer for didLoad property of super class. This property is set to YES once the objects have been loaded from file. Only then is the physics engine started
    [super addObserver:self forKeyPath:@"didLoad" options:NSKeyValueObservingOptionNew context:nil];
    
    //Initialize physics engine
    b2Vec2 gravity(GRAVITY_X, GRAVITY_Y);
    self.world = new b2World(gravity);
}

-(void)load {
    [super displayLoadScreen];
}

-(void)restart {
    [self reset];
    [super loadDirectlyFromFile:self.currentLevelName];
    self.didLoad = YES;
}

//Implementing UIAlertViewDelegate protocol method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (!([alertView isEqual:self.startErrorAlert]) && !([alertView isEqual:self.gameOverAlert])) {
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    }
    else {
        if ([alertView isEqual:self.startErrorAlert]) {
            if (buttonIndex == 0) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
        else if ([alertView isEqual:self.gameOverAlert]) {
            if (buttonIndex == 0) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else if (buttonIndex == 1) {
                [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
                [self load];
            }
            else if (buttonIndex == 2) {
                [self restart];
            }
        }
    }
}

-(void)createPalette {
    [self setWolfLives];
    [self setPigHealth];
    [self setScore];
}

-(void)setWolfLives {
    UIImageView* defaultWolf = [[UIImageView alloc] initWithImage:[UIImage imageNamed:WOLF_IMAGE]];
    defaultWolf.frame = CGRectMake(PALETTE_WOLF_ORIGIN_X, PALETTE_WOLF_ORIGIN_Y, PALETTE_WOLF_SIZE_WIDTH, PALETTE_WOLF_SIZE_HEIGHT);
    [self.paletteView addSubview:defaultWolf];
    
    UIImageView* heart1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heart.png"]];
    heart1.frame = CGRectMake(PLAY_HEART1_ORIGIN_X, PLAY_HEART1_ORIGIN_Y, PLAY_HEART_SIZE_WIDTH, PLAY_HEART_SIZE_HEIGHT);
    UIImageView* heart2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heart.png"]];
    heart2.frame = CGRectMake(PLAY_HEART2_ORIGIN_X, PLAY_HEART2_ORIGIN_Y, PLAY_HEART_SIZE_WIDTH, PLAY_HEART_SIZE_HEIGHT);
    UIImageView* heart3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heart.png"]];
    heart3.frame = CGRectMake(PLAY_HEART3_ORIGIN_X, PLAY_HEART3_ORIGIN_Y, PLAY_HEART_SIZE_WIDTH, PLAY_HEART_SIZE_HEIGHT);
    
    self.wolfLives = [NSMutableArray arrayWithObjects:heart1, heart2, heart3, nil];
    [self.paletteView addSubview:heart1];
    [self.paletteView addSubview:heart2];
    [self.paletteView addSubview:heart3];
}

-(void)setPigHealth {
    UIImageView* defaultPig = [[UIImageView alloc] initWithImage:[UIImage imageNamed:PIG_IMAGE]];
    [defaultPig setFrame:CGRectMake(PLAY_PIG_ORIGIN_X, PLAY_PIG_ORIGIN_Y, PALETTE_PIG_SIZE_WIDTH, PALETTE_PIG_SIZE_HEIGHT)];
    [self.paletteView addSubview:defaultPig];
    
    self.staticHealthBar = [[UIImageView alloc] initWithFrame:CGRectMake(PLAY_HEALTH_ORIGIN_X, PLAY_HEALTH_ORIGIN_Y, PLAY_HEALTH_SIZE_WIDTH, PLAY_HEALTH_SIZE_HEIGHT)];
    [self.staticHealthBar setBackgroundColor:[UIColor redColor]];
    [self.staticHealthBar setAlpha:0.4f];
    [self.staticHealthBar.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [self.staticHealthBar.layer setBorderWidth:2];
    [self.paletteView addSubview:self.staticHealthBar];
    
    self.dynamicHealthBar = [[UIImageView alloc] initWithFrame:CGRectMake(PLAY_HEALTH_ORIGIN_X+2, PLAY_HEALTH_ORIGIN_Y+2, PLAY_HEALTH_SIZE_WIDTH-4, PLAY_HEALTH_SIZE_HEIGHT-4)];
    [self.dynamicHealthBar setBackgroundColor:[UIColor greenColor]];
    [self.paletteView addSubview:self.dynamicHealthBar];
}

-(void)setScore {
    UIImageView* scoreView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"score.png"]];
    scoreView.frame = CGRectMake(PLAY_SCORE_ORIGIN_X, PLAY_SCORE_ORIGIN_Y, PLAY_SCORE_SIZE_WIDTH, PLAY_SCORE_SIZE_HEIGHT);
    [self.paletteView addSubview:scoreView];
    
    self.numbers = [self getFramesForImage:[UIImage imageNamed:@"numbers.png"] withRows:10 andColumns:1];
    ((NSMutableArray*)self.numbers)[1] = [UIImage imageNamed:@"number1.png"];
    UIImageView* scoreHundreds = [[UIImageView alloc] initWithImage:self.numbers[0]];
    scoreHundreds.frame = CGRectMake(PLAY_HUNDREDS_ORIGIN_X, PLAY_HUNDREDS_ORIGIN_Y, PLAY_NUMBERS_SIZE_WIDTH, PLAY_NUMBERS_SIZE_HEIGHT);
    UIImageView* scoreTens = [[UIImageView alloc] initWithImage:self.numbers[0]];
    scoreTens.frame = CGRectMake(PLAY_TENS_ORIGIN_X, PLAY_TENS_ORIGIN_Y, PLAY_NUMBERS_SIZE_WIDTH, PLAY_NUMBERS_SIZE_HEIGHT);
    UIImageView* scoreOnes = [[UIImageView alloc] initWithImage:self.numbers[0]];
    scoreOnes.frame = CGRectMake(PLAY_ONES_ORIGIN_X, PLAY_ONES_ORIGIN_Y, PLAY_NUMBERS_SIZE_WIDTH, PLAY_NUMBERS_SIZE_HEIGHT);
    
    self.score = [NSMutableArray arrayWithObjects:scoreHundreds, scoreTens, scoreOnes, nil];
    [self.paletteView addSubview:scoreHundreds];
    [self.paletteView addSubview:scoreTens];
    [self.paletteView addSubview:scoreOnes];
}

//Helper method to divide animation sprite into individual images
-(NSArray*)getFramesForImage:(UIImage*)img withRows:(int)rows andColumns:(int)columns {
    NSArray* imageFrames = [NSMutableArray array];
    CGFloat widthPerFrame = img.size.width/rows;
    CGFloat heightPerFrame = img.size.height/columns;
    
    for (int i = 0; i < rows*columns; i++) {
        CGFloat originX = widthPerFrame * (i % rows);
        CGFloat originY = heightPerFrame * (i / rows);
        
        CGRect imageBox = CGRectMake(originX, originY, widthPerFrame, heightPerFrame);
        CGImage *tempImage = [img CGImage];
        CGImageRef imageRef = CGImageCreateWithImageInRect(tempImage, imageBox);
        UIImage *subImage = [UIImage imageWithCGImage:imageRef];
        [(NSMutableArray*)imageFrames addObject: subImage];
    }
    return imageFrames;
}

-(void)gameOverWinMessage {
    [self.gamearea setContentOffset:CGPointMake(0, 0)];
    self.gameOverAlert = [[UIAlertView alloc] initWithTitle:@"You Won" message:[NSString stringWithFormat:@"Your Final Score is: %d",self.currentScore] delegate:self cancelButtonTitle:@"Back" otherButtonTitles:@"Load", @"Restart", nil];
    [self.gameOverAlert show];
}

-(void)gameOverLoseMessage {
    [self.gamearea setContentOffset:CGPointMake(0, 0)];
    self.gameOverAlert = [[UIAlertView alloc] initWithTitle:@"You Lost" message:[NSString stringWithFormat:@"Your Final Score is: %d",self.currentScore] delegate:self cancelButtonTitle:@"Back" otherButtonTitles:@"Load", @"Restart", nil];
    [self.gameOverAlert show];
}

-(void)reset {
    [self.timer invalidate];
    [self removeSubviews];
    [self resetPalette];
    self.wolf = nil;
    self.pig = nil;
    self.wolfBreath = nil;
    [self.blocks removeAllObjects];
    [self resetWorld];
    self.timer = nil;
    self.listener = nil;
    self.walls = nil;
    self.currentScore = 0;
}

//Remove all objects from physics world
-(void)resetWorld {
    b2Body* bodyList = self.world->GetBodyList();
    if (bodyList!=NULL) {
        do {
            b2Body* currentBody = bodyList;
            bodyList = bodyList->GetNext();
            self.world->DestroyBody(currentBody);
        }while (bodyList != NULL);
    }
    
}

-(void)removeSubviews {
    [(GameWolf*)self.wolf resetStartMode];
    [self.wolf.view removeFromSuperview];
    [self.pig.view removeFromSuperview];
    [self.wolfBreath.view removeFromSuperview];
    for (NSNumber* key in self.blocks) {
        GameBlock* gb = [self.blocks objectForKey:key];
        [gb.view removeFromSuperview];
    }
}

-(void)resetPalette {
    for (UIImageView* i in self.paletteView.subviews) {
        [i removeFromSuperview];
    }
    [self.wolfBreath removeTrajectoryTracer];
    self.wolfLives = nil;
    self.staticHealthBar = nil;
    self.dynamicHealthBar = nil;
    self.score = nil;
    [self createPalette];
}

//Implementing UITableView Delegate method to deal with selection of cell by user
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString* fileName = [self.savedFileNames objectAtIndex:indexPath.row];
    self.currentLevelName = fileName;
    [self reset];
    [super loadObjectsFromFile:fileName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)viewDidUnload {
    [super viewDidUnload];
}

-(void)viewWillDisappear:(BOOL)animated {
    [self.timer invalidate];
    [super removeObserver:self forKeyPath:@"didLoad"];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(killBreath) object:nil];
    self.world = NULL;
    self.timer = nil;
    self.listener = nil;
    self.walls = nil;
    self.wolfLives = nil;
    self.staticHealthBar = nil;
    self.dynamicHealthBar = nil;
    self.score = nil;
    self.numbers= nil;
    self.startErrorAlert = nil;
    self.gameOverAlert = nil;
    [super viewWillDisappear:animated];
}



@end
