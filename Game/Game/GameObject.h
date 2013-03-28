//
//  GameObject.h
//  Game
//
//  Created by Raunak Rajpuria on 1/29/13.
//  Copyright (c) 2013 Raunak Rajpuria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameModel.h"
#import "Constants.h"
#include "ObjectDelegate.h"

@interface GameObject : UIViewController <UIGestureRecognizerDelegate> 

@property (readonly) GameModel* modelObject;
@property (weak) id<ObjectDelegate> selfDelegate;

- (void)setAllGestures;
- (void)removeAllGestures;
- (void)translate:(UIGestureRecognizer *)gesture;
// MODIFIES: object model (coordinates)
// REQUIRES: game in designer mode
// EFFECTS: the user drags around the object with one finger
//          if the object is in the palette, it will be moved in the game area

- (void)rotate:(UIGestureRecognizer *)gesture;
// MODIFIES: object model (rotation)
// REQUIRES: game in designer mode, object in game area
// EFFECTS: the object is rotated with a two-finger rotation gesture

- (void)zoom:(UIGestureRecognizer *)gesture;
// MODIFIES: object model (size)
// REQUIRES: game in designer mode, object in game area
// EFFECTS: the object is scaled up/down with a pinch gesture

// You will need to define more methods to complete the specification.
- (void)doubleTap:(UIGestureRecognizer *)gesture;
- (void)setDelegate:(id<ObjectDelegate>)delegate;
- (void)translateFromGameArea:(CGPoint)translation GestureState:(UIGestureRecognizerState)state;
- (void)translateFromPalette:(CGPoint)translation GestureState:(UIGestureRecognizerState)state;


@end
