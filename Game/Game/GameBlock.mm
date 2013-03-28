//
//  GameBlock.m
//  Game
//
//  Created by Raunak Rajpuria on 1/29/13.
//  Copyright (c) 2013 Raunak Rajpuria. All rights reserved.
//
/*
  Sub class of GameObject. Deals with specific functionalities for block object
*/

#import "GameBlock.h"

@interface GameBlock () {
    int tapCount;
}
@property (readwrite) GameModel* modelObject;
@end

@implementation GameBlock
@synthesize modelObject;

-(id)initWithOrigin:(CGPoint)o size:(CGSize)s state:(GameObjectState)st blockType:(BlockType)bt blockID:(int)i {
    self = [super init];
    if (self) {
        CGFloat tempMass = 0, tempFriction = 0, tempRestitition = 0;
        switch (bt) {
            case kStrawBlock:
                tempMass = STRAW_BLOCK_MASS;
                tempFriction = STRAW_BLOCK_FRICTION;
                tempRestitition = STRAW_BLOCK_RESTITUTION;
                self.view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:STRAW_IMAGE]];
                break;
            case kWoodBlock:
                tempMass = WOOD_BLOCK_MASS;
                tempFriction = WOOD_BLOCK_FRICTION;
                tempRestitition = WOOD_BLOCK_RESTITUTION;
                self.view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:WOOD_IMAGE]];
                break;
            case kStoneBlock:
                tempMass = STONE_BLOCK_MASS;
                tempFriction = STONE_BLOCK_FRICTION;
                tempRestitition = STONE_BLOCK_RESTITUTION;
                self.view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:STONE_IMAGE]];
                break;
            case kIronBlock:
                tempMass = IRON_BLOCK_MASS;
                tempFriction = IRON_BLOCK_FRICTION;
                tempRestitition = IRON_BLOCK_RESTITUTION;
                self.view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:IRON_IMAGE]];
                break;
            default:
                break;
        }
        modelObject = [[Block alloc] initWithMass:tempMass
                                           origin:o
                                             size:s
                                         rotation:0
                                            scale:1
                                            state:st
                                       objectType:kGameObjectBlock
                                         velocity:[Vector2D vectorWith:0 y:0]
                                  angularVelocity:0
                                            force:[Vector2D vectorWith:0 y:0]
                                           torque:0
                                    frictionCoeff:tempFriction
                                 restitutionCoeff:tempRestitition
                                       hasExpired:NO
                                            shape:kRectangle
                                        blockType:bt
                                          blockID:i];
                
        self.view.frame = CGRectMake(o.x, o.y, s.width, s.height);
    }
    return self;
}

//If the translation starts from the palette
- (void)translateFromPalette:(CGPoint)translation GestureState:(UIGestureRecognizerState)state {
    [super translateFromPalette:translation GestureState:state];
    
    //If the block object is completely below the palette area, then add it to the game area
    //The block is added at a default position in the game area
    if (self.modelObject.origin.y > self.view.superview.frame.size.height) {
        UIView* gamearea = [self.view.superview.superview viewWithTag:1];
        [self.modelObject setCenter:[gamearea convertPoint:self.view.center fromView: self.view.superview]];
        [self.modelObject setSize:CGSizeMake(GAMEAREA_BLOCK_SIZE_WIDTH, GAMEAREA_BLOCK_SIZE_HEIGHT)];
        
        [gamearea addSubview:self.view];
        [self.modelObject setCurrentState:kInGameArea];
        [self.selfDelegate newBlockAdded];
    }
    
    if(state == UIGestureRecognizerStateEnded) {
        if (self.modelObject.origin.y <= self.view.superview.frame.size.height) {
        	//Move the block back to its position in the palette, if the user does not drag it out completely
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.5];
            [self.modelObject setOrigin:CGPointMake(PALETTE_BLOCK_ORIGIN_X, PALETTE_BLOCK_ORIGIN_Y)];
            [UIView commitAnimations];
        }
    }
}

- (void)doubleTap:(UIGestureRecognizer *)gesture {
	//double tap not allowed in palette
    if (self.modelObject.currentState == kInPalette) {
        return;
    }
    [self.view removeFromSuperview];
    [self.selfDelegate blockDeleted:((Block*)self.modelObject).blockID];
}

//Change block type in round robin manner
-(void)singleTap:(UIGestureRecognizer*)gesture {
    tapCount++;
    switch(tapCount) {
        case 0:[(Block*)self.modelObject setType:kStrawBlock];
            break;
        case 1:[(Block*)self.modelObject setType:kWoodBlock];
            break;
        case 2:[(Block*)self.modelObject setType:kStoneBlock];
            break;
        case 3:[(Block*)self.modelObject setType:kIronBlock];
            tapCount=-1;
            break;
        default: break;
    };
}

//Objects of this class need to conform to NSCoding protocol
-(void)encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:self.modelObject forKey:@"Block Model"];
}

-(id)initWithCoder:(NSCoder*)decoder {
    self.modelObject = [decoder decodeObjectForKey:@"Block Model"];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewDidUnload {
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
