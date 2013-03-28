//
//  ContactListener.mm
//  Game
//
//  Created by Raunak Rajpuria on 2/28/13.
//  Copyright (c) 2013 Raunak Rajpuria. All rights reserved.
//

#import <Box2D/Box2D.h>
#import "GameModel.h"
#import "CollisionDelegate.h"

class ContactListener : public b2ContactListener {
    id<CollisionDelegate> delegate;
    
public:
    ContactListener(id<CollisionDelegate> sender) {
        delegate = sender;
    }
    
    void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) {
        GameModel* objectA = ((__bridge GameModel*)contact->GetFixtureA()->GetBody()->GetUserData());
        GameModel* objectB = ((__bridge GameModel*)contact->GetFixtureB()->GetBody()->GetUserData());
        [this ->delegate object:objectA didCollideWith:objectB withImpulse:impulse];
    }
};
