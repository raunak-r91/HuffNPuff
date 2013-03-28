//
//  GameBlock.h
//  Game
//
//  Created by Raunak Rajpuria on 1/29/13.
//  Copyright (c) 2013 Raunak Rajpuria. All rights reserved.
//

#import "GameObject.h"
#import "Block.h"

@interface GameBlock : GameObject

-(id)initWithOrigin:(CGPoint)o size:(CGSize)s state:(GameObjectState)st blockType:(BlockType)bt blockID:(int)i;
-(void)singleTap:(UIGestureRecognizer*)gesture;
-(void)encodeWithCoder:(NSCoder*)encoder;
-(id)initWithCoder:(NSCoder*)decoder;

@end
