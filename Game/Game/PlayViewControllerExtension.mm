//
//  PlayViewControllerExtension.m
//  Game
//
//  Created by Raunak Rajpuria on 3/3/13.
//  Copyright (c) 2013 Raunak Rajpuria. All rights reserved.
//
/*
    This class is a category of the PlayViewController class and acts as an interface between the game and the physics engine. It contains all the methods to set up the physics engine, as well as respond to object collisions
 */

#import "PlayViewControllerExtension.h"

@implementation PlayViewController (PlayViewControllerExtension)

- (IBAction)buttonPressed:(id)sender {
    UIButton *button = (UIButton*)sender;
    NSString *buttonName = [button titleForState:UIControlStateNormal];
    if ([buttonName isEqual:@"Load"]) {
        [self load];
    }
    else if ([buttonName isEqual:@"Restart"]) {
        [self restart];
    }
    else if ([buttonName isEqual:@"Back"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

//Since I have used a common method to load objects from file in the super class, all objects in the palette will also be loaded. This method is used to remove such objects from the view
//Returns NO if there is no wolf or no pig in the game area. This is invalid and the game will not start.
-(BOOL)removePaletteObjects {
    if (self.wolf.modelObject.currentState == kInPalette || self.pig.modelObject.currentState == kInPalette) {
        return NO;
    }
    int deletedBlockID = -1;
    for (NSNumber* key in self.blocks) {
        GameBlock* gb = [self.blocks objectForKey:key];
        if (gb.modelObject.currentState == kInPalette) {
            deletedBlockID = ((Block*)gb.modelObject).blockID;
            [gb.view removeFromSuperview];
        }
    }
    if (deletedBlockID != -1) {
        [self.blocks removeObjectForKey:[NSNumber numberWithInt:deletedBlockID]];
    }
    return YES;
}

//Responds to changes to didLoad property in super class
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (keyPath == @"didLoad" && (NSNumber*)[change objectForKey:NSKeyValueChangeNewKey] == [NSNumber numberWithInt:YES]) {
        if ([self removePaletteObjects]) {
            [self startPlay];
            self.didLoad = NO;
        }
        else {
            self.startErrorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to Start Game\nThere should be 1 Wolf and 1 Pig in Game Area" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [self.startErrorAlert show];
        }
    }
}

#pragma mark Setup Physics World

-(void)startPlay {
    [self removeGestures];
    [self setUpWorld];
    [self setUpWalls];
    [self setUpGameObjects];
    [self setUpTimer];
}

//Remove all gestures from design mode as they are not needed in Play mode
-(void)removeGestures {
    [self.wolf removeAllGestures];
    [self.pig removeAllGestures];
    for (NSString* key in self.blocks) {
        GameObject* block = [self.blocks objectForKey:key];
        [block removeAllGestures];
    }
}

-(void)setUpWorld {
    self.listener = new ContactListener(self);
    self.world->SetContactListener(self.listener);
}

-(void)setUpWalls {
    self.walls = [NSMutableArray array];
    GameModel* bottomWall = [[GameModel alloc] initWithMass:INFINITY
                                                     origin:CGPointMake(0, self.gamearea.frame.size.height-GROUND_IMAGE_HEIGHT)
                                                       size:CGSizeMake(BOTTOM_WALL_WIDTH, BOTTOM_WALL_HEIGHT)
                                                   rotation:0
                                                      scale:1
                                                      state:kInGameArea
                                                 objectType:kGameObjectWall
                                                   velocity:[Vector2D vectorWith:0.0 y:0.0]
                                            angularVelocity:0
                                                      force:[Vector2D vectorWith:0.0 y:0.0]
                                                     torque:0
                                              frictionCoeff:WALL_FRICTION
                                           restitutionCoeff:WALL_RESTITUTION
                                                 hasExpired:NO
                                                      shape:kRectangle];
    [self.walls addObject:bottomWall];
    b2Vec2 edge1(bottomWall.origin.x/PTM_RATIO, bottomWall.origin.y/PTM_RATIO);
    b2Vec2 edge2((bottomWall.origin.x + bottomWall.size.width)/PTM_RATIO, bottomWall.origin.y/PTM_RATIO);
    [self addWallObjectToWorld:bottomWall withEdge1:edge1 andEdge2:edge2];
    
    GameModel* rightWall = [[GameModel alloc] initWithMass:INFINITY
                                                    origin:CGPointMake(RIGHT_EDGE_X, self.gamearea.superview.frame.origin.y)
                                                      size:CGSizeMake(RIGHT_WALL_WIDTH, self.gamearea.frame.size.height-GROUND_IMAGE_HEIGHT)
                                                  rotation:0
                                                     scale:1
                                                     state:kInGameArea
                                                objectType:kGameObjectWall
                                                  velocity:[Vector2D vectorWith:0.0 y:0.0]
                                           angularVelocity:0
                                                     force:[Vector2D vectorWith:0.0 y:0.0]
                                                    torque:0
                                             frictionCoeff:WALL_FRICTION
                                          restitutionCoeff:WALL_RESTITUTION
                                                hasExpired:NO
                                                     shape:kRectangle];
    [self.walls addObject:rightWall];
    edge1.Set(rightWall.origin.x/PTM_RATIO, rightWall.origin.y/PTM_RATIO);
    edge2.Set(rightWall.origin.x/PTM_RATIO, (rightWall.origin.y + rightWall.size.height)/PTM_RATIO);
    [self addWallObjectToWorld:rightWall withEdge1:edge1 andEdge2:edge2];
    
    GameModel* leftWall= [[GameModel alloc] initWithMass:INFINITY
                                                  origin:CGPointMake(LEFT_EDGE_X, self.gamearea.superview.frame.origin.y)
                                                    size:CGSizeMake(LEFT_WALL_WIDTH, self.gamearea.frame.size.height-GROUND_IMAGE_HEIGHT)
                                                rotation:0
                                                   scale:1
                                                   state:kInGameArea
                                              objectType:kGameObjectWall
                                                velocity:[Vector2D vectorWith:0.0 y:0.0]
                                         angularVelocity:0
                                                   force:[Vector2D vectorWith:0.0 y:0.0]
                                                  torque:0
                                           frictionCoeff:WALL_FRICTION
                                        restitutionCoeff:WALL_RESTITUTION
                                              hasExpired:NO
                                                   shape:kRectangle];
    [self.walls addObject:leftWall];
    edge1.Set(leftWall.origin.x/PTM_RATIO, leftWall.origin.y/PTM_RATIO);
    edge2.Set(leftWall.origin.x/PTM_RATIO, (leftWall.origin.y + leftWall.size.height)/PTM_RATIO);
    [self addWallObjectToWorld:leftWall withEdge1:edge1 andEdge2:edge2];
}

-(void)setUpGameObjects {
    [(GameWolf*)self.wolf setStartMode];
    ((GameWolf*)self.wolf).breathDelegate = self;
    
    [self addRectangleObjectToWorld:self.pig.modelObject];
    
    for (NSNumber* key in self.blocks) {
        GameBlock* gb = [self.blocks objectForKey:key];
        [self addRectangleObjectToWorld:gb.modelObject];
    }
}

-(b2BodyDef)getBodyDef:(GameModel*)o {
    b2BodyDef bodyDef;
    if (o.objectType == kGameObjectWall) {
        bodyDef.position.Set(0, 0);
        bodyDef.type = b2_staticBody;
    }
    else {
        bodyDef.position.Set(([o getCenter].x)/PTM_RATIO, ([o getCenter].y)/PTM_RATIO);
        bodyDef.type = b2_dynamicBody;
        bodyDef.linearVelocity.Set(o.velocity.x, o.velocity.y);
    }
    bodyDef.angle = o.rotation;
    bodyDef.allowSleep = true;
    return bodyDef;
}

-(b2FixtureDef)getFixtureDef:(GameModel*)o forShape:(b2Shape*)shape {
    b2FixtureDef fixtureDef;
    fixtureDef.restitution = o.restitutionCoeff;
    fixtureDef.friction = o.frictionCoeff;
    fixtureDef.density = o.mass;
    fixtureDef.shape = shape;
    return fixtureDef;
}

-(void)addBody:(GameModel*)o forBodyDef:(b2BodyDef)bd fixtureDef:(b2FixtureDef)fd {
    b2Body* body = self.world->CreateBody(&bd);
    body->CreateFixture(&fd);
    body->SetUserData((__bridge void*)o); //Store the GameModel* object as user data
}

-(void)addWallObjectToWorld:(GameModel*)wall withEdge1:(b2Vec2)edge1 andEdge2:(b2Vec2)edge2 {
    b2BodyDef wallBodyDef = [self getBodyDef:wall];
    
    b2EdgeShape wallShape;
    wallShape.Set(edge1, edge2);
    
    b2FixtureDef wallFixtureDef = [self getFixtureDef:wall forShape:&wallShape];
    [self addBody:wall forBodyDef:wallBodyDef fixtureDef:wallFixtureDef];
}

-(void)addRectangleObjectToWorld:(GameModel*)o {
    b2BodyDef bodyDef = [self getBodyDef:o];
    
    b2PolygonShape bodyShape;
    bodyShape.SetAsBox(([o getScaledSize].width)/(PTM_RATIO*2), ([o getScaledSize].height)/(PTM_RATIO*2));
    
    b2FixtureDef fixtureDef = [self getFixtureDef:o forShape:&bodyShape];
    
    [self addBody:o forBodyDef:bodyDef fixtureDef:fixtureDef];
}

-(void)addCircleObjectToWorld:(GameModel*)o {
    b2BodyDef bodyDef = [self getBodyDef:o];
    
    b2CircleShape bodyShape;
    bodyShape.m_radius = [o getScaledSize].width/(PTM_RATIO*2);
    
    b2FixtureDef fixtureDef = [self getFixtureDef:o forShape:&bodyShape];
    
    [self addBody:o forBodyDef:bodyDef fixtureDef:fixtureDef];
}

-(void)setUpTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval: TIMESTEP
                                                  target: self
                                                selector: @selector(updateObjects:)
                                                userInfo: nil
                                                 repeats: YES];
}

#pragma mark Update Bodies after Collisions

//Sends message to engine to simulate a single time step. Updates the position of the bodies from previous time step
-(void)updateObjects:(NSTimer*)timer {
    self.world->Step(TIMESTEP, 10, 10);
    b2Body* bodyList = self.world->GetBodyList();
    int bodiesAsleep = 0;
    do {
        //If object expired in previous time step, remove it from engine world
        if (((__bridge GameModel*)bodyList->GetUserData()).hasExpired) {
            [self removeObjectFromWorld:((__bridge GameModel*)bodyList->GetUserData()) withBody:bodyList];
        }
        //Update all bodies
        else if (bodyList->GetType() == b2_dynamicBody) {
            if (!bodyList->IsAwake()) {
                bodiesAsleep++;
            }
            [self updateModel:(__bridge GameModel*)bodyList->GetUserData() withBody:bodyList];
        }
        bodyList = bodyList->GetNext();
    } while (bodyList != NULL);
    
    if (bodiesAsleep == self.world->GetBodyCount() - WALL_COUNT) { //If all objects are currently at rest
        if ([self.wolfLives count] == 0 && self.pig!=nil) {
            //If last breath has been fired, kill wolf if pig is not dead
            [(GameWolf*)self.wolf wolfDie];
            [self.timer invalidate];
            [self gameOverLoseMessage];
        }
    }
}

-(void)removeObjectFromWorld:(GameModel*)obj withBody:(b2Body*)b {
    if (obj.objectType == kGameObjectPig) {
        self.world->DestroyBody(b);
        [(GamePig*)self.pig removePig];
        self.pig = nil;
        [self gameOverWinMessage];
    }
    else if (obj.objectType == kGameObjectBreath) {
        //This selector is scheduled to destroy the game breath after 5 seconds if it is not already destroyed
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(killBreath) object:nil]; 
        self.world->DestroyBody(b);
        [self.wolfBreath removeBreath];
    }
    else if (obj.objectType == kGameObjectBlock) {
        self.world->DestroyBody(b);
        GameBlock* tempBlock = [self.blocks objectForKey:[NSNumber numberWithInt:((Block*)obj).blockID]];
        [tempBlock.view removeFromSuperview];
        [self.blocks removeObjectForKey:[NSNumber numberWithInt:((Block*)obj).blockID]];
    }
}

//Update the position and rotation of the model. It will then notify the GameViewController of a change in value, which will then update its view
-(void)updateModel:(GameModel*)m withBody:(b2Body*)b {
    [m setRotationStep:b->GetAngle() - m.rotation];
    m.rotation = b->GetAngle();
    [m setCenter:CGPointMake(b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO)];
}

//Implementing delegate protocol method to create new breath when user has tapped twice on the wolf
-(void)createBreathWithVelocity:(Vector2D*)velocity {
    if ([self.wolfLives count] > 0) { //Only create breath if wolf has lives remaining
        if (self.wolfBreath != nil) {   //If there is a previous breath
            [self.wolfBreath removeTrajectoryTracer]; //Remove trajectory from previous breath
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(killBreath) object:nil];
            [self removeBreathObject];
            self.wolfBreath = nil;
        }
        
        //Create new GameBreath object and add it to the engine world
        [[self.wolfLives lastObject] setAlpha:0.4f];
        [self.wolfLives removeLastObject];
        CGPoint breathOrigin = CGPointMake(self.wolf.view.frame.origin.x + self.wolf.view.frame.size.width, self.wolf.view.frame.origin.y );
        self.wolfBreath = [[GameBreath alloc] initWithOrigin:breathOrigin
                                                        size:CGSizeMake(70, 70)
                                                    velocity:velocity];
        [self.wolfBreath.modelObject setDelegate:self];
        [self.gamearea addSubview:self.wolfBreath.view];
        [self addCircleObjectToWorld:self.wolfBreath.modelObject];
        
        //Setup selector to destroy breath after 5 seconds if it is not already destroyed
        [self performSelector:@selector(killBreath) withObject:nil afterDelay:5];
    }
}

-(void)killBreath {
    if (!self.wolfBreath.modelObject.hasExpired) {
        [self removeBreathObject];
    }
}


//Helper method to remove breath from world
-(void)removeBreathObject {
    b2Body* bodyList = self.world->GetBodyList();
    for (int i  = 0; i < self.world->GetBodyCount(); i++) {
        b2Body* currentBody = bodyList;
        bodyList = bodyList->GetNext();
        if (currentBody->GetType() == b2_dynamicBody) {
            if (((__bridge GameModel*)currentBody->GetUserData()).objectType == kGameObjectBreath) {
                self.world->DestroyBody(currentBody);
                [self.wolfBreath removeBreath];
            }
        }
    }
}

//Implementing Delegate protocol method of ContactListener to deal with impulses after collision
-(void)object:(GameModel *)a didCollideWith:(GameModel *)b withImpulse:(const b2ContactImpulse *)impulse {
    if (a.objectType == kGameObjectBreath || b.objectType == kGameObjectBreath) {
        GameModel* breath = a.objectType == kGameObjectBreath ? a : b ;
        GameModel* otherObject = a.objectType == kGameObjectBreath ? b : a ;
        [self breath:breath didCollideWith:otherObject withImpulse:impulse];
    }
    else if (a.objectType == kGameObjectPig || b.objectType == kGameObjectPig) {
        GameModel* pig = a.objectType == kGameObjectPig ? a : b ;
        GameModel* otherObject = a.objectType == kGameObjectPig ? b : a ;
        [self pig:pig didCollideWith:otherObject withImpulse:impulse];
    }
}

-(void)pig:(GameModel*)pig didCollideWith:(GameModel*)otherObject withImpulse:(const b2ContactImpulse *)impulse {
    if (self.wolfLives.count != WOLF_LIVES) {
        [self pigHitWithImpulse:impulse];
    }
}

-(void)pigHitWithImpulse:(const b2ContactImpulse *)impulse {
    CGFloat damage = ((impulse->normalImpulses[0] + impulse->normalImpulses[1])/2)/self.pig.modelObject.mass;
    if (damage > DAMAGE_THRESHOLD) {
        [(GamePig*)self.pig applyDamage:damage];
        
        //Calculate new width for health bar
        int newHealthBarWidth = MAX(0, self.pig.modelObject.health*PLAY_HEALTH_SIZE_WIDTH/PIG_HEALTH);
        self.dynamicHealthBar.frame = CGRectMake(self.dynamicHealthBar.frame.origin.x, self.dynamicHealthBar.frame.origin.y, newHealthBarWidth, self.dynamicHealthBar.frame.size.height);
        int score = PIG_HEALTH - self.pig.modelObject.health;
        
        //Update score
        self.currentScore = score;
        [((UIImageView*)self.score[0]) setImage:self.numbers[score/100]];
        score = score%100;
        [((UIImageView*)self.score[1]) setImage:self.numbers[score/10]];
        score = score%10;
        [((UIImageView*)self.score[2]) setImage:self.numbers[score]];
    }
}

-(void)breath:(GameModel*)breath didCollideWith:(GameModel*)otherObject withImpulse:(const b2ContactImpulse *)impulse {
    if (otherObject.objectType == kGameObjectBlock) {
        if (((Block*)otherObject).type == kStrawBlock) {
            //Breath collided with straw block. Reduce its velocity by half.
            breath.velocity = [Vector2D vectorWith:breath.velocity.x/2 y:breath.velocity.y/2];
            otherObject.hasExpired = YES;
        }
        else {
            //Breath collided with other type of blocks
            breath.hasExpired = YES;
        }
    }
    else if (otherObject.objectType == kGameObjectPig) {
        breath.hasExpired = YES;
        [self pigHitWithImpulse:impulse];
    }
}

//Helper method to remove block object from world
-(void)removeBlockObject:(GameModel*)block {
    GameBlock* tempBlock = [self.blocks objectForKey:[NSNumber numberWithInt:((Block*)block).blockID]];
    [tempBlock.view removeFromSuperview];
    [self.blocks removeObjectForKey:[NSNumber numberWithInt:((Block*)block).blockID]];
    b2Body* bodyList = self.world->GetBodyList();
    for (int i  = 0; i < self.world->GetBodyCount(); i++) {
        b2Body* currentBody = bodyList;
        bodyList = bodyList->GetNext();
        if (((__bridge GameModel*)currentBody->GetUserData()).objectType == kGameObjectBlock) {
            if (((__bridge Block*)currentBody->GetUserData()).blockID == ((Block*)block).blockID) {
                self.world->DestroyBody(currentBody);
            }
        }
    }
}

@end
