//
//  GameBreath.h
//  Game
//
//  Created by Raunak Rajpuria on 2/26/13.
//  Copyright (c) 2013 Raunak Rajpuria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameModel.h"

@interface GameBreath : UIViewController

@property (readonly) GameModel* modelObject;

-(id)initWithOrigin:(CGPoint)o size:(CGSize)s velocity:(Vector2D*)v;
-(void)addTrajectoryTracer;
-(void)removeBreath;
-(void)removeTrajectoryTracer;
@end
