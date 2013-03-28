//
//  ViewController.h
//  Game
//
//  Created by Raunak Rajpuria on 1/27/13.
//  Copyright (c) 2013 Raunak Rajpuria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GameViewController.h"
#import "GameWolf.h"
#import "GamePig.h"
#import "GameBlock.h"
#import "GameBreath.h"
#import "ModelDelegate.h"
#import "ObjectDelegate.h"
#import "BreathDelegate.h"
#import "PlayViewController.h"
#import <Box2D/Box2D.h>

@interface DesignViewController : GameViewController <ModelDelegate, ObjectDelegate, UIAlertViewDelegate> 

@property int blockCount;
@property UIAlertView* saveAlert;

@end
