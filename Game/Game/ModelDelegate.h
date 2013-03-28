//
//  ModelDelegate.h
//  Game
//
//  Created by Raunak Rajpuria on 1/31/13.
//  Copyright (c) 2013 Raunak Rajpuria. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@protocol ModelDelegate <NSObject>

-(void)blockDidMove:(int)blockID;
-(void)blockDidRotate:(int)blockID By:(CGFloat)r;
-(void)blockDidResize:(int)blockID;
-(void)blockDidScale:(int)blockID By:(CGFloat)s;
-(void)blockDidChangeType:(int)blockID;
-(void)objectDidMoveOfType:(GameObjectType)type;
-(void)objectDidRotateBy:(CGFloat)r OfType:(GameObjectType)type;
-(void)objectDidResizeOfType:(GameObjectType)type;
-(void)objectDidScaleBy:(CGFloat)s OfType:(GameObjectType)type;

@end
