//
//  GamePig.m
//  Game
//
//  Created by Raunak Rajpuria on 1/29/13.
//  Copyright (c) 2013 Raunak Rajpuria. All rights reserved.
//
/*
  Sub class of GameObject. Deals with specific functionalities for pig object
*/

#import "GamePig.h"

@interface GamePig ()
@end

@implementation GamePig

@synthesize modelObject;

-(id)initWithOrigin:(CGPoint)o size:(CGSize)s state:(GameObjectState)st {
    self = [super init];
    if (self) {
        modelObject = [[GameModel alloc] initWithMass:PIG_MASS
                                               origin:o
                                                 size:s
                                             rotation:0
                                                scale:1
                                                state:st
                                           objectType:kGameObjectPig
                                             velocity:[Vector2D vectorWith:0 y:0]
                                      angularVelocity:0
                                                force:[Vector2D vectorWith:0 y:0]
                                               torque:0
                                        frictionCoeff:PIG_FRICTION
                                     restitutionCoeff:PIG_RESTITUTION
                                           hasExpired:NO
                                                shape:kRectangle];
        
        self.view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:PIG_IMAGE]];
        self.view.frame = CGRectMake(o.x, o.y, s.width, s.height);
    }
    return self;
}

//If the translation starts from the palette
- (void)translateFromPalette:(CGPoint)translation GestureState:(UIGestureRecognizerState)state {
    [super translateFromPalette:translation GestureState:state];
    
    //If the pig object is completely below the palette area, then add it to the game area
    //The pig is added at a default position in the game area
    if (self.modelObject.origin.y > self.view.superview.frame.size.height) {
        UIView* gamearea = [self.view.superview.superview viewWithTag:1];
        [self.modelObject setCenter:[gamearea convertPoint:self.view.center fromView: self.view.superview]];
        [self.modelObject setSize:CGSizeMake(GAMEAREA_PIG_SIZE_WIDTH, GAMEAREA_PIG_SIZE_HEIGHT)];
        
        [gamearea addSubview:self.view];
        [self.modelObject setCurrentState:kInGameArea];
        [self.selfDelegate objectMovedToGameAreaOfType:self.modelObject.objectType];
    }
    if(state == UIGestureRecognizerStateEnded) {
        if (self.modelObject.origin.y <= self.view.superview.frame.size.height) {
        	//Move the pig back to its position in the palette, if the user does not drag it out completely
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.5];
            [self.modelObject setOrigin:CGPointMake(PALETTE_PIG_ORIGIN_X, PALETTE_PIG_ORIGIN_Y)];
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
    [self.modelObject setOrigin:CGPointMake(PALETTE_PIG_ORIGIN_X, PALETTE_PIG_ORIGIN_Y)];
    [self.modelObject setSize:CGSizeMake(PALETTE_PIG_SIZE_WIDTH, PALETTE_PIG_SIZE_HEIGHT)];
    [self.modelObject setDefaultRotation];
    [self.modelObject setDefaultScale];
    UIView* paletteArea = [self.view.superview.superview viewWithTag:5];
    [paletteArea addSubview:self.view];
    [self.modelObject setCurrentState:kInPalette];
}

//Reduce Pig's Health
-(void)applyDamage:(CGFloat)impulse {
    self.modelObject.health -= impulse;
    if (self.modelObject.health < PIG_HEALTH/2.0) {
        [((UIImageView*)self.view) setImage:[UIImage imageNamed:@"pig2.png"]];
    }
    if (self.modelObject.health < 0.0) {
        self.modelObject.hasExpired = YES;
    }
}

//Method to animate the pig's death
-(void)removePig {
    NSArray* pigDie = [self getFramesForImage:[UIImage imageNamed:@"pig-die-smoke.png"] withRows:5 andColumns:2];
    UIImageView* pigDieView = [[UIImageView alloc] initWithImage:pigDie[0]];
    pigDieView.frame = self.view.frame;
    [self.view.superview addSubview:pigDieView];
    [self.view removeFromSuperview];
    [pigDieView setAnimationImages:pigDie];
    [pigDieView setAnimationDuration:1];
    [pigDieView setAnimationRepeatCount:1];
    [pigDieView startAnimating];
    [self performSelector:@selector(completedPigDie:) withObject:pigDieView afterDelay:0.8];
}

//Remove pig's image after its death
-(void)completedPigDie:(UIImageView*)pigDieView {
    [pigDieView removeFromSuperview];
    pigDieView = nil;
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

-(void) viewDidUnload {
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
