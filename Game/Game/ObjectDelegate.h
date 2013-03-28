//
//  BlockDelegate.h
//  Game
//
//  Created by Raunak Rajpuria on 2/1/13.
//  Copyright (c) 2013 Raunak Rajpuria. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"   

@protocol ObjectDelegate <NSObject>

//Inform the View Controller that new block needs to be added
-(void)newBlockAdded;
//Inform the View Controller that existing block has to be deleted
-(void)blockDeleted:(int)ID;
//Inform the View Controller to fade the default palette images
-(void)objectMovedToGameAreaOfType:(GameObjectType)type;
-(void)objectMovedToPaletteOfType:(GameObjectType)type;

@end
