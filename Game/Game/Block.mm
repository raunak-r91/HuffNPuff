//
//  Block.m
//  Game
//
//  Created by Raunak Rajpuria on 1/29/13.
//  Copyright (c) 2013 Raunak Rajpuria. All rights reserved.
//
//This is a subclass of GameObject and contains two attributes specific to block objects namely blockID and blockType
#import "Block.h"

@interface Block ()
@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize size;
@property (nonatomic) CGFloat rotation;
@property (nonatomic) CGFloat scale;
@property (nonatomic) GameObjectState currentState;
@property (nonatomic) Vector2D* velocity;
@property (nonatomic) CGFloat angularVelocity;
@property (nonatomic) Vector2D* force;
@property (nonatomic) CGFloat torque;
@property (nonatomic) BOOL canMove;
@property (nonatomic) BlockType type;
@property int blockID;
@end

@implementation Block

-(id)initWithMass:(CGFloat)m origin:(CGPoint)o size:(CGSize)s rotation:(CGFloat)r scale:(CGFloat)sc state:(GameObjectState)st objectType:(GameObjectType)ot velocity:(Vector2D*)v angularVelocity:(CGFloat)av force:(Vector2D*)f torque:(CGFloat)t frictionCoeff:(CGFloat)fc restitutionCoeff:(CGFloat)rcf hasExpired:(BOOL)he shape:(GameObjectShape)sh blockType:(BlockType)bt blockID:(int)i {
    self = [super initWithMass:m origin:o size:s rotation:r scale:sc state:st objectType:ot velocity:v angularVelocity:av force:f torque:t frictionCoeff:fc restitutionCoeff:rcf hasExpired:he shape:sh];
    if (self) {
        _type = bt;
        _blockID = i;
    }
    return self;
}

-(void)setOrigin:(CGPoint)o {
    super.origin = o;
    [self.selfDelegate blockDidMove:self.blockID];
}

-(void)setSize:(CGSize)s {
    super.size = s;
    [self.selfDelegate blockDidResize:self.blockID];
}

-(void)setType:(BlockType)t {
    _type = t;
    [self.selfDelegate blockDidChangeType:self.blockID];
}

-(void)setRotationStep:(CGFloat)rotationStep {
    [self.selfDelegate blockDidRotate:self.blockID By:rotationStep];
}

-(void)setScaleStep:(CGFloat)scaleStep {
    [self.selfDelegate blockDidScale:self.blockID By:scaleStep];
}

-(void)setCenter:(CGPoint)c {
    self.origin = CGPointMake(c.x - self.size.width/2, c.y - self.size.height/2);
}

-(void)encodeWithCoder:(NSCoder*)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeInt:self.type forKey:@"Block Type"];
    [encoder encodeInt:self.blockID forKey:@"Block ID"];
}

-(id)initWithCoder:(NSCoder*)decoder {
    self = [super initWithCoder:decoder];
    self.type = (BlockType)[decoder decodeIntForKey:@"Block Type"];
    self.blockID = [decoder decodeIntForKey:@"Block ID"];
    return self;
}


@end
