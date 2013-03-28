//
//  DesignViewControllerExtension.h
//

#import "DesignViewController.h"
#import "Constants.h"

@interface DesignViewController (DesignViewControllerExtension) <UIAlertViewDelegate>

- (IBAction)buttonPressed:(id)sender;

- (void)save;
  // REQUIRES: game in designer mode
  // EFFECTS: game objects are saved 

- (void)load;
  // MODIFIES: self (game objects)
  // REQUIRES: game in designer mode
  // EFFECTS: game objects are loaded

- (void)reset;
  // MODIFIES: self (game objects)
  // REQUIRES: game in designer mode
  // EFFECTS: current game objects are deleted and palette contains all objects

@end
