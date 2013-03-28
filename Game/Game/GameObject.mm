//
//  GameObject.m
//  Game
//
//  Created by Raunak Rajpuria on 1/29/13.
//  Copyright (c) 2013 Raunak Rajpuria. All rights reserved.
//
/*
  GameObject is a superclass which deals with the user gestures on the game objects
  This class performs the necessary calculations and updates the model classes
*/
#import "GameObject.h"

@interface GameObject () {
    CGFloat previousScale;
}
@property GameModel* modelObject;
@end

@implementation GameObject

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

-(void)setDelegate:(id<ObjectDelegate>)delegate {
    self.selfDelegate = delegate;
}

-(void)translate:(UIGestureRecognizer *)gesture {
// MODIFIES: object model (coordinates)
// REQUIRES: game in designer mode
// EFFECTS: the user drags around the object with one finger
//          if the object is in the palette, it will be moved in the game area

    //disable scroll for UIScrollView when panning begins
    if ([gesture state] == UIGestureRecognizerStateBegan) {
        UIView* gamearea = [self.view.superview.superview viewWithTag:1];
        [(UIScrollView*)gamearea setScrollEnabled:NO];
    }
    
    //Get Translation step
    CGPoint translation = [(UIPanGestureRecognizer*)gesture translationInView:self.view.superview];
    if (self.modelObject.currentState == kInPalette) {
        [self translateFromPalette:translation GestureState:[(UIPanGestureRecognizer*)gesture state]];
    }
    else {
        [self translateFromGameArea:translation GestureState:[(UIPanGestureRecognizer*)gesture state]];
    }
    
    //Reset translation property to get correct value in next iteration
    [(UIPanGestureRecognizer*)gesture setTranslation:CGPointMake(0, 0) inView:self.view.superview];
    
    //Re-enable scroll after panning ends
    if ([gesture state] == UIGestureRecognizerStateEnded) {
        UIView* gamearea = [self.view.superview.superview viewWithTag:1];
        [(UIScrollView*)gamearea setScrollEnabled:YES];
    }
}

- (void)translateFromGameArea:(CGPoint)translation GestureState:(UIGestureRecognizerState)state {
    CGPoint initialCenter = [self.modelObject getCenter];
    CGPoint initialOrigin = [self.modelObject getBoundingBox].origin;
    CGSize initialSize = [self.modelObject getBoundingBox].size;
    CGPoint translatedCenter = CGPointMake(initialCenter.x + translation.x, initialCenter.y + translation.y);
    CGPoint translatedOrigin = CGPointMake(initialOrigin.x + translation.x, initialOrigin.y + translation.y);
    
    //Calculate boundaries of region where object can be moved
    
    //Top boundary of game area
    CGFloat top = self.view.superview.superview.frame.origin.y;
    //Bottom boundary of background (at ground level)
    CGFloat bottom = [self.view.superview.superview viewWithTag:6].frame.origin.y + [self.view.superview.superview viewWithTag:6].frame.size.height;
    //Left edge of screen    
    CGFloat left = [self.view.superview.superview viewWithTag:1].frame.origin.x;
    //Right edge of background
    CGFloat right = [self.view.superview.superview viewWithTag:6].frame.size.width;
    
    //If object tries to move beyond the boundaries, then move it back
    if (translatedOrigin.x <= left) {
        translatedCenter.x = left + initialSize.width/2;
    }
    if (translatedOrigin.x + initialSize.width >= right) {
        translatedCenter.x = right - initialSize.width/2;
    }
    if (translatedOrigin.y <= top ) {
        translatedCenter.y = top + initialSize.height/2;
    }
    if (translatedOrigin.y + initialSize.height >= bottom) {
        translatedCenter.y = bottom - initialSize.height/2;
    }
    
    //Update model
    [self.modelObject setCenter:translatedCenter];
}


//This method is implemented completely in each subclass
- (void)translateFromPalette:(CGPoint)translation GestureState:(UIGestureRecognizerState)state {
    CGPoint initialCenter = [self.modelObject getCenter];
    CGPoint translatedCenter = CGPointMake(initialCenter.x + translation.x, initialCenter.y + translation.y);
    
    //Update model
    [self.modelObject setCenter:translatedCenter];
}

- (void)rotate:(UIGestureRecognizer *)gesture {
// MODIFIES: object model (rotation)
// REQUIRES: game in designer mode, object in game area
// EFFECTS: the object is rotated with a two-finger rotation gesture
    //Do not allow rotation if object is in palette
    if (self.modelObject.currentState == kInPalette) {
        return;
    }
    [self.modelObject setRotationStep:((UIRotationGestureRecognizer*)gesture).rotation];
    [self.modelObject setRotation:self.modelObject.rotation + ((UIRotationGestureRecognizer*)gesture).rotation];
    //Reset rotation property of gesture
    ((UIRotationGestureRecognizer*)gesture).rotation = 0;
}

- (void)zoom:(UIGestureRecognizer *)gesture {
// MODIFIES: object model (size)
// REQUIRES: game in designer mode, object in game area
// EFFECTS: the object is scaled up/down with a pinch gesture
	//Do not allow rotation if object is in palette
    if (self.modelObject.currentState == kInPalette) {
        return;
    }
	//Obtain the current scale of the object before zoom begins
    if ([gesture state] == UIGestureRecognizerStateBegan) {
        previousScale = self.modelObject.scale;
    }
    
    CGFloat currentScale = MAX(MIN([(UIPinchGestureRecognizer*)gesture scale] * self.modelObject.scale, MAX_SCALE), MIN_SCALE);
    CGFloat scaleStep = currentScale / previousScale;
    [self.modelObject setScaleStep:scaleStep];
    
    previousScale = currentScale;
    
    //Store the new scale of the object after zoom ends
    if ([gesture state] == UIGestureRecognizerStateEnded) {
        [self.modelObject setScale:currentScale];
    }
}

//Implemented in individual sub classes
- (void)doubleTap:(UIGestureRecognizer *)gesture {
    
}

- (void)setAllGestures {
	//Pan Gesture
    self.view.userInteractionEnabled = YES;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(translate:)];
    [pan setMinimumNumberOfTouches:1];
    [pan setMaximumNumberOfTouches:1];
    [pan setDelegate:self];
    [self.view addGestureRecognizer:pan];
    
    //Rotation Gesture
    UIRotationGestureRecognizer *rotate = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];
    [rotate setDelegate:self];
    [self.view addGestureRecognizer:rotate];
    
    //Pinch Gesture
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoom:)];
    [pinch setDelegate:self];
    [self.view addGestureRecognizer:pinch];
    
    //Double Tap Gesture
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [doubleTap setDelegate:self];
    [self.view addGestureRecognizer:doubleTap];
    
    //Single tap Gesture (only for block object)
    if (self.modelObject.objectType == kGameObjectBlock) {
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [singleTap setNumberOfTapsRequired:1];
        [singleTap setDelegate:self];
        [singleTap requireGestureRecognizerToFail:doubleTap];
        [singleTap requireGestureRecognizerToFail:pan];
        [singleTap requireGestureRecognizerToFail:rotate];
        [singleTap requireGestureRecognizerToFail:pinch];
        [self.view addGestureRecognizer:singleTap];
    }
}

-(void)removeAllGestures {
    for (UIGestureRecognizer* recognizer in self.view.gestureRecognizers) {
        [self.view removeGestureRecognizer:recognizer];
    }
}

//Delegate protocol method to enable simultaneous gestures
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

-(void)viewDidUnload {
    self.modelObject = nil;
    [super viewDidUnload];
}

@end
