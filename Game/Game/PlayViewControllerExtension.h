//
//  PlayViewControllerExtension.h
//  Game
//
//  Created by Raunak Rajpuria on 3/3/13.
//  Copyright (c) 2013 Raunak Rajpuria. All rights reserved.
//

#import "PlayViewController.h"

@interface PlayViewController (PlayViewControllerExtension) <BreathDelegate, CollisionDelegate>
- (IBAction)buttonPressed:(id)sender;
@end
