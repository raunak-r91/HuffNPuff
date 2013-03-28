//
//  GameWolf.m
//  Game
//
//  Created by Raunak Rajpuria on 1/29/13.
//  Copyright (c) 2013 Raunak Rajpuria. All rights reserved.
//
/*
  Sub class of GameObject. Deals with specific functionalities for wolf object. Includes Functionalities for the Play Mode such as direction arrow and power bar
*/

#import "GameWolf.h"

@interface GameWolf () {
    CGFloat arrowRotation;
    CGFloat breathPower;
    UIImage* breathBarImage;
    BOOL barIncrease;
    int tapCount;
    int breathCount;
}

@property UIImageView* directionArrow;
@property UIImageView* breathBar;
@property UIImageView* fixedBreathBar;
@property NSTimer* powerTimer;
@end

@implementation GameWolf

@synthesize modelObject;

-(id)initWithOrigin:(CGPoint)o size:(CGSize)s state:(GameObjectState)st {
    self = [super init];
    if (self) {
        modelObject = [[GameModel alloc] initWithMass:WOLF_MASS
                                               origin:o
                                                 size:s
                                             rotation:0
                                                scale:1
                                                state:st
                                           objectType:kGameObjectWolf
                                             velocity:[Vector2D vectorWith:0 y:0]
                                      angularVelocity:0
                                                force:[Vector2D vectorWith:0 y:0]
                                               torque:0
                                        frictionCoeff:WOLF_FRICTION
                                     restitutionCoeff:WOLF_RESTITUTION
                                           hasExpired:NO
                                                shape:kRectangle];
        
        self.view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:WOLF_IMAGE]];
        self.view.frame = CGRectMake(o.x, o.y, s.width, s.height);
    }
    return self;
}

//If the translation starts from the palette
- (void)translateFromPalette:(CGPoint)translation GestureState:(UIGestureRecognizerState)state {
    [super translateFromPalette:translation GestureState:state];
    
    //If the wolf object is completely below the palette area, then add it to the game area
    //The wolf is added at a default position in the game area
    if (self.modelObject.origin.y > self.view.superview.frame.size.height) {
        UIView* gamearea = [self.view.superview.superview viewWithTag:1];
        [self.modelObject setCenter:[gamearea convertPoint:self.view.center fromView: self.view.superview]];
        [self.modelObject setSize:CGSizeMake(GAMEAREA_WOLF_SIZE_WIDTH, GAMEAREA_WOLF_SIZE_HEIGHT)];
        
        [gamearea addSubview:self.view];
        [self.modelObject setCurrentState:kInGameArea];
        [self.selfDelegate objectMovedToGameAreaOfType:self.modelObject.objectType];
    }
    if(state == UIGestureRecognizerStateEnded) {
        if (self.modelObject.origin.y <= self.view.superview.frame.size.height) {
        	//Move the wolf back to its position in the palette, if the user does not drag it out completely
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.5];
            [self.modelObject setOrigin:CGPointMake(PALETTE_WOLF_ORIGIN_X, PALETTE_WOLF_ORIGIN_Y)];
            [UIView commitAnimations]; 
        }
    }
}

- (void)doubleTap:(UIGestureRecognizer *)gesture {
	//double tap not allowed in palette
    if (self.modelObject.currentState == kInPalette) {
        return;
    }
    [self setDefaultPaletteState];
    [self.selfDelegate objectMovedToPaletteOfType:self.modelObject.objectType];
}

- (void)setDefaultPaletteState {
    [self.view setTransform:CGAffineTransformIdentity];
    [self.modelObject setOrigin:CGPointMake(PALETTE_WOLF_ORIGIN_X, PALETTE_WOLF_ORIGIN_Y)];
    [self.modelObject setSize:CGSizeMake(PALETTE_WOLF_SIZE_WIDTH, PALETTE_WOLF_SIZE_HEIGHT)];
    [self.modelObject setDefaultRotation];
    [self.modelObject setDefaultScale];
    [self.modelObject setCurrentState:kInPalette];
    UIView* paletteArea = [self.view.superview.superview viewWithTag:5];
    [paletteArea addSubview:self.view];
}

//Prepare for Play Mode
- (void)setStartMode {
    [self createArrow];
    [self createPowerBar];
    
    //Add Tap Gesture Recognizer to Wolf (Used only in Play Mode)
    UITapGestureRecognizer *startModeSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [startModeSingleTap setNumberOfTapsRequired:1];
    [startModeSingleTap setDelegate:self];
    [self.view addGestureRecognizer:startModeSingleTap];
    
    //Set Default Values
    tapCount = 0;
    breathCount = WOLF_LIVES;
}

//Deal with single tap gestures
-(void)handleSingleTap:(UIGestureRecognizer*)gesture {
    tapCount++;
    switch (tapCount) {
        case 1:
            [self.directionArrow setHidden:NO];
            [self.fixedBreathBar setHidden:NO];
            [self.breathBar setHidden:NO];
            [self startPowerBar];
            break;
        case 2:
             [self stopPowerBar];
            break;
        default:
            break;
    }
}

//Create Arrow for Play Mode and set it to HIDDEN
-(void)createArrow {
    if (self.directionArrow == nil) {
        UIImage* arrowImage = [UIImage imageNamed:DIRECTION_ARROW_IMAGE];
        self.directionArrow = [[UIImageView alloc] initWithImage:arrowImage];
        
        self.directionArrow.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, DIRECTION_ARROW_WIDTH, DIRECTION_ARROW_HEIGHT);
        self.directionArrow.center = CGPointMake(self.view.frame.origin.x + self.view.frame.size.width, self.view.frame.origin.y + (self.view.frame.size.height*WOLF_MOUTH_RATIO));  //Move Direction Arrow To Wolf's Mouth
        [self.view.superview addSubview:self.directionArrow];
        [self.view.superview insertSubview:self.directionArrow belowSubview:self.view];
        arrowRotation = 0; //Set Default Rotation
        [self.directionArrow setHidden:YES];
        
        //Add OneFingerRotationGesture to arrow
        [self.directionArrow setUserInteractionEnabled:YES];
        OneFingerGestureRecognizer* arrowRotate = [[OneFingerGestureRecognizer alloc] initWithTarget:self action:@selector(rotateArrow:)];
        [arrowRotate setDelegate:self];
        [self.directionArrow addGestureRecognizer:arrowRotate];
    }
}

//Deal with OneFingerRotation
-(void)rotateArrow:(UIGestureRecognizer*)gesture {
    if ([gesture state] == UIGestureRecognizerStateBegan) {
        //Change Color of arrow if selected
        [((UIScrollView*)[self.view.superview.superview viewWithTag:1]) setScrollEnabled:NO];
        [self.directionArrow setImage:[UIImage imageNamed:DIRECTION_ARROW_SELECTED_IMAGE]];
    }
    
    //Set Limits of rotation
    CGFloat limitedAngle = MAX(MIN(arrowRotation + ((OneFingerGestureRecognizer*)gesture).rotation, ROTATION_MIN), ROTATION_MAX);
    CGFloat currentAngle = limitedAngle - arrowRotation;
    arrowRotation = limitedAngle;
    
    [self.directionArrow setTransform:CGAffineTransformRotate(self.directionArrow.transform, currentAngle)];
    ((OneFingerGestureRecognizer*)gesture).rotation = 0;
    
    if ([gesture state] == UIGestureRecognizerStateEnded) {
        //Change back to original Color
        [((UIScrollView*)[self.view.superview.superview viewWithTag:1]) setScrollEnabled:YES];
        [self.directionArrow setImage:[UIImage imageNamed:DIRECTION_ARROW_IMAGE]];
    }
}

//Create 2 Power Bars (one is the static one and the other is the dynamic one) for Play Mode and set them To HIDDEN
-(void)createPowerBar{
    if (self.directionArrow == nil) {
        return;
    }
    breathBarImage = [UIImage imageNamed:BREATH_BAR];
    self.breathBar = [[UIImageView alloc] initWithImage:breathBarImage];
    self.fixedBreathBar = [[UIImageView alloc] initWithImage:breathBarImage];
    [self.fixedBreathBar setAlpha:0.5];
    
    self.breathBar.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - breathBarImage.size.height*2, 0, breathBarImage.size.height);
    self.fixedBreathBar.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - breathBarImage.size.height*2, self.view.frame.size.width, breathBarImage.size.height);
    
    [self.view.superview addSubview:self.breathBar];
    [self.view.superview insertSubview:self.fixedBreathBar belowSubview:self.breathBar];
    [self.fixedBreathBar setHidden:YES];
    [self.breathBar setHidden:YES];
}

-(void)startPowerBar {
    self.powerTimer = [NSTimer scheduledTimerWithTimeInterval:0.005 target:self selector:@selector(changePowerCounter:) userInfo:nil repeats:YES];
    barIncrease = YES;
}

-(void)changePowerCounter:(NSTimer*)timer {
    if (barIncrease) {
        [self increasePowerCounter];
    }
    else {
        [self decreasePowerCounter];
    }
}

-(void)increasePowerCounter {
    CGFloat newWidth = (self.breathBar.frame.size.width + 1 > self.view.frame.size.width) ? (self.view.frame.size.width) : (self.breathBar.frame.size.width + 1); //Do not allow breath bar to become bigger than static bar
    if (newWidth < self.view.frame.size.width) {
        [UIView beginAnimations:nil context:nil];
        self.breathBar.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - breathBarImage.size.height*2, self.breathBar.frame.size.width + 1, breathBarImage.size.height);
        [UIView commitAnimations];
    }
    else if (newWidth == self.view.frame.size.width) {
        barIncrease = NO;
    }
}

-(void)decreasePowerCounter {
    CGFloat newWidth = (self.breathBar.frame.size.width - 1 < 0) ? 0 : (self.breathBar.frame.size.width - 1);
    if (newWidth > 0) {
        [UIView beginAnimations:nil context:nil];
        self.breathBar.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - breathBarImage.size.height*2, self.breathBar.frame.size.width - 1, breathBarImage.size.height);
        [UIView commitAnimations];
    }
    else if (newWidth == 0) {
        barIncrease = YES;
    }
}

-(void)stopPowerBar {
    [self.powerTimer invalidate];
    //Set Breath Power
    breathPower = self.breathBar.frame.size.width / self.view.frame.size.width;
    [self wolfBlow];
}

//Animate the wolf inhaling/exhaling + Sucking wind
-(void)wolfBlow {
    NSArray* wolfBlow = [self getFramesForImage:[UIImage imageNamed:WOLF_ANIMATION] withRows:5 andColumns:3];
    NSArray* windSuck = [self getFramesForImage:[UIImage imageNamed:WIND_SUCK] withRows:4 andColumns:2];
    
    //Add wind suck image near wolf's mouth
    UIImageView* windSuckView = [[UIImageView alloc] initWithImage:windSuck[0]];
    windSuckView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, windSuckView.image.size.width, windSuckView.image.size.height);
    windSuckView.center = CGPointMake(self.view.frame.origin.x + self.view.frame.size.width +  windSuckView.image.size.width/2, self.view.frame.origin.y + (self.view.frame.size.height*WOLF_MOUTH_RATIO));
    [self.view.superview addSubview:windSuckView];
    
    [(UIImageView*)self.view setAnimationImages:wolfBlow];
    [windSuckView setAnimationImages:windSuck];
    [(UIImageView*)self.view setAnimationDuration:1.5];
    [windSuckView setAnimationDuration:1.5];
    [(UIImageView*)self.view setAnimationRepeatCount:1];
    [windSuckView setAnimationRepeatCount:1];
    [(UIImageView*)self.view startAnimating];
    [windSuckView startAnimating];
    [self performSelector:@selector(completedWolfBlow:) withObject:windSuckView afterDelay:1.5];
}

//Release Breath after animation
-(void)completedWolfBlow:(UIImageView*)windSuckView {
    [windSuckView removeFromSuperview];
    windSuckView = nil;
    
    //Hide breath bars and arrow
    [self.fixedBreathBar setHidden:YES];
    [self.breathBar setHidden:YES];
    [self.directionArrow setHidden:YES];
    tapCount = 0;
    breathCount--;
    
    //Send Message to delegate to create breath with given velocity
    [self.breathDelegate createBreathWithVelocity:[Vector2D vectorWith:breathPower*30*cosf(arrowRotation) y:breathPower*30*sinf(arrowRotation)]];
    if (breathCount == 0) {
        [self.view removeGestureRecognizer:self.view.gestureRecognizers[0]]; //If no more breath's left
    }
}

//Animate wolf's death
-(void)wolfDie {
    NSArray* wolfDie = [self getFramesForImage:[UIImage imageNamed:@"wolfdie.png"] withRows:4 andColumns:4];
    [(UIImageView*)self.view setAnimationImages:wolfDie];
    [(UIImageView*)self.view setAnimationDuration:3];
    [(UIImageView*)self.view setAnimationRepeatCount:1];
    [(UIImageView*)self.view setImage:((UIImageView*)self.view).animationImages.lastObject];
    [(UIImageView*)self.view startAnimating];
    [self performSelector:@selector(completedWolfDie) withObject:nil afterDelay:3];
}

-(void)completedWolfDie {
}

-(void)resetStartMode {
    [self.directionArrow removeFromSuperview];
    [self.breathBar removeFromSuperview];
    [self.fixedBreathBar removeFromSuperview];
    self.directionArrow = nil;
    self.breathBar = nil;
    self.fixedBreathBar = nil;
    [self.powerTimer invalidate];
    self.powerTimer = nil;
}

//Helper Method to divide animation sprite into individual images
-(NSArray*)getFramesForImage:(UIImage*)img withRows:(int)rows andColumns:(int)columns {
    NSArray* imageFrames = [NSMutableArray array];
    CGFloat widthPerFrame = img.size.width/rows;
    CGFloat heightPerFrame = img.size.height/columns;

    for (int i = 0; i < rows*columns; i++) {
        CGFloat originX = widthPerFrame * (i % rows);
        CGFloat originY = heightPerFrame * (i / rows);

        CGRect imageBox = CGRectMake(originX, originY, widthPerFrame, heightPerFrame);
        [(NSMutableArray*)imageFrames addObject:[UIImage imageWithCGImage:CGImageCreateWithImageInRect([img CGImage], imageBox)]];
    }
    return imageFrames;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewDidUnload {
    self.directionArrow = nil;
    self.breathBar = nil;
    self.fixedBreathBar = nil;
    self.powerTimer = nil;
    breathBarImage = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
