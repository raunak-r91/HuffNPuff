//
//  Constants.h
//  Game
//
//  Created by Raunak Rajpuria on 1/30/13.
//  Copyright (c) 2013 Raunak Rajpuria. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

typedef enum {kInPalette, kInGameArea} GameObjectState;
typedef enum {kGameObjectWolf, kGameObjectPig, kGameObjectBlock, kGameObjectBreath, kGameObjectWall} GameObjectType;
typedef enum {kGameBuilderMode, kGamePlayMode, kGameOver} GameState;
typedef enum {
    kStrawBlock = 0,
    kWoodBlock,
    kIronBlock,
    kStoneBlock
}BlockType;
typedef enum {kRectangle, kCircle} GameObjectShape;

#define PALETTE_ORIGIN_X 0
#define PALETTE_ORIGIN_Y 44
#define PALETTE_SIZE_WIDTH 1024
#define PALETTE_SIZE_HEIGHT 75
#define GAMEAREA_ORIGIN_X 0
#define GAMEAREA_ORIGIN_Y 119
#define GAMEAREA_SIZE_WIDTH 1024
#define GAMEAREA_SIZE_HEIGHT 585

#define CLOUD1_ORIGIN_X 50
#define CLOUD1_ORIGIN_Y 10
#define CLOUD2_ORIGIN_X 800
#define CLOUD2_ORIGIN_Y 20
#define CLOUD3_ORIGIN_X 1300
#define CLOUD3_ORIGIN_Y 15

#define GAMEAREA_RED 255.0/255 
#define GAMEAREA_GREEN 177.0/255
#define GAMEAREA_BLUE 158.0/255
#define PALETTE_RED 188.0/255
#define PALETTE_GREEN 119.0/255
#define PALETTE_BLUE 103.0/255

#define PALETTE_WOLF_ORIGIN_X 10
#define PALETTE_WOLF_ORIGIN_Y 5
#define PALETTE_WOLF_SIZE_WIDTH 65
#define PALETTE_WOLF_SIZE_HEIGHT 65
#define GAMEAREA_WOLF_ORIGIN_X 0
#define GAMEAREA_WOLF_ORIGIN_Y 330
#define GAMEAREA_WOLF_SIZE_WIDTH 225
#define GAMEAREA_WOLF_SIZE_HEIGHT 150

#define PALETTE_PIG_ORIGIN_X 85
#define PALETTE_PIG_ORIGIN_Y 10
#define PALETTE_PIG_SIZE_WIDTH 55
#define PALETTE_PIG_SIZE_HEIGHT 55
#define GAMEAREA_PIG_ORIGIN_X 200
#define GAMEAREA_PIG_ORIGIN_Y 400
#define GAMEAREA_PIG_SIZE_WIDTH 88
#define GAMEAREA_PIG_SIZE_HEIGHT 88

#define PLAY_PIG_ORIGIN_X 350
#define PLAY_PIG_ORIGIN_Y 10
#define PLAY_HEALTH_ORIGIN_X 415
#define PLAY_HEALTH_ORIGIN_Y 35
#define PLAY_HEALTH_SIZE_WIDTH 204
#define PLAY_HEALTH_SIZE_HEIGHT 24

#define PLAY_SCORE_ORIGIN_X 750
#define PLAY_SCORE_ORIGIN_Y 30
#define PLAY_SCORE_SIZE_WIDTH 95
#define PLAY_SCORE_SIZE_HEIGHT 25
#define PLAY_NUMBERS_SIZE_WIDTH 30
#define PLAY_NUMBERS_SIZE_HEIGHT 46
#define PLAY_HUNDREDS_ORIGIN_X 850
#define PLAY_HUNDREDS_ORIGIN_Y 20
#define PLAY_TENS_ORIGIN_X 880
#define PLAY_TENS_ORIGIN_Y 20
#define PLAY_ONES_ORIGIN_X 910
#define PLAY_ONES_ORIGIN_Y 20

#define PLAY_HEART1_ORIGIN_X 80
#define PLAY_HEART1_ORIGIN_Y 30
#define PLAY_HEART2_ORIGIN_X 120
#define PLAY_HEART2_ORIGIN_Y 30
#define PLAY_HEART3_ORIGIN_X 160
#define PLAY_HEART3_ORIGIN_Y 30
#define PLAY_HEART_SIZE_WIDTH 36
#define PLAY_HEART_SIZE_HEIGHT 31

#define PALETTE_BLOCK_ORIGIN_X 165
#define PALETTE_BLOCK_ORIGIN_Y 10
#define PALETTE_BLOCK_SIZE_WIDTH 55
#define PALETTE_BLOCK_SIZE_HEIGHT 55
#define GAMEAREA_BLOCK_ORIGIN_X 325
#define GAMEAREA_BLOCK_ORIGIN_Y 325
#define GAMEAREA_BLOCK_SIZE_WIDTH 30
#define GAMEAREA_BLOCK_SIZE_HEIGHT 150

#define LOAD_TABLEVIEW_ORIGIN_X 15
#define LOAD_TABLEVIEW_ORIGIN_Y 45
#define LOAD_TABLEVIEW_SIZE_WIDTH 255
#define LOAD_TABLEVIEW_SIZE_HEIGHT 225
#define LOAD_TABLEVIEW_CORNER_RADIUS 5

#define WOLF_IMAGE @"wolf.png"
#define PIG_IMAGE @"pig.png"
#define STRAW_IMAGE @"straw.png"
#define WOOD_IMAGE @"wood.png"
#define STONE_IMAGE @"stone.png"
#define IRON_IMAGE @"iron.png"
#define BACKGROUND_IMAGE @"background.png"
#define GROUND_IMAGE @"ground.png"
#define BREATH_IMAGE @"wolf-breath.png"
#define WIND_DISPERSE @"wind-disperse.png"
#define DIRECTION_ARROW_IMAGE @"direction-arrow.png"
#define DIRECTION_ARROW_SELECTED_IMAGE @"direction-arrow-selected.png"
#define BREATH_BAR @"breath-bar.png"
#define WOLF_ANIMATION @"wolfs.png"
#define WIND_SUCK @"windsuck.png"

#define WOLF_MASS 2
#define PIG_MASS 2
#define STRAW_BLOCK_MASS 0.5
#define WOOD_BLOCK_MASS 1
#define STONE_BLOCK_MASS 1.5
#define IRON_BLOCK_MASS 2
#define BREATH_MASS 2

#define WOLF_FRICTION 1
#define PIG_FRICTION 1
#define STRAW_BLOCK_FRICTION 1
#define WOOD_BLOCK_FRICTION 1
#define STONE_BLOCK_FRICTION 1
#define IRON_BLOCK_FRICTION 1
#define BREATH_FRICTION 1
#define WALL_FRICTION 1

#define WOLF_RESTITUTION 0.1
#define PIG_RESTITUTION 0.1
#define STRAW_BLOCK_RESTITUTION 0.2
#define WOOD_BLOCK_RESTITUTION 0.2
#define STONE_BLOCK_RESTITUTION 0.2
#define IRON_BLOCK_RESTITUTION 0.2
#define BREATH_RESTITUTION 0.4
#define WALL_RESTITUTION 0.1

#define BOTTOM_WALL_WIDTH [UIImage imageNamed:BACKGROUND_IMAGE].size.width
#define BOTTOM_WALL_HEIGHT 1
#define RIGHT_WALL_WIDTH 1
#define LEFT_WALL_WIDTH 1
#define LEFT_EDGE_X 0
#define RIGHT_EDGE_X [UIImage imageNamed:BACKGROUND_IMAGE].size.width
#define GROUND_IMAGE_HEIGHT [UIImage imageNamed:GROUND_IMAGE].size.height 

#define FADED 0.4f
#define OPAQUE 1

#define MAX_SCALE 1.5
#define MIN_SCALE 0.5

#define PTM_RATIO 20.0
#define TIMESTEP 1.0/60
#define PIG_HEALTH 800.0
#define GRAVITY_X 0.0f
#define GRAVITY_Y 10.0f
#define WOLF_LIVES 3
#define WALL_COUNT 3

#define STRAW_DESTROY_POINTS 100
#define BREATH_DESTROY_PENALTY 50
#define DAMAGE_THRESHOLD 2
#define TRACE_DISTANCE 50
#define TRACE_WIDTH 15
#define TRACE_HEIGHT 15
#define DIRECTION_ARROW_WIDTH 293
#define DIRECTION_ARROW_HEIGHT 50
#define WOLF_MOUTH_RATIO 28.0/147
#define ROTATION_MIN M_PI/6
#define ROTATION_MAX -(5*M_PI/12)

#define LEVEL1 @"Level 1 - The Beginning"
#define LEVEL2 @"Level 2 - Blocks To The Rescue"
#define LEVEL3 @"Level 3 - On A Pedestal"
#define LEVEL4 @"Level 4 - Aim High"
#define LEVEL5 @"Level 5 - Fortress"
#define LEVEL6 @"Level 6 - Obstacle Course"

@end
