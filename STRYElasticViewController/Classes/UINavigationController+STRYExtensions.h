//
//  UINavigationController+UINavigationController_STRYExtensions.h
//  InteractiveTransitions
//
//  Created by Terry Lewis on 31/10/19.
//  Copyright © 2019 Terry Lewis. All rights reserved.
//

@import UIKit;
#import "STRYNavigationControllerDelegate.h"

@interface UINavigationController (STRYExtensions)

//@property (nonatomic, strong) UIViewController *STRY_nextViewController;
@property (nonatomic) BOOL STRY_cacheForwardViewControllers;
@property (nonatomic, retain) STRYNavigationControllerDelegate *STRY_strongDelegate;

- (BOOL)STRY_pushNextStoredControllerAnimated:(BOOL)animated;
- (void)STRY_clearForwardCachedControllers;

- (void)STRY_cleanupStoredViewControllers;

@end
