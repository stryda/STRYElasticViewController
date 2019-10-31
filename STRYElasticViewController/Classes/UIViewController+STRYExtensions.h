//
//  UIViewController+UIViewController.h
//  InteractiveTransitions
//
//  Created by Terry Lewis on 31/10/19.
//  Copyright © 2019 Terry Lewis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (STRYExtensions)

@property (nonatomic, strong, nullable) UIViewController *STRY_nextViewController;

- (void)STRY_viewControllerWillBeCached;
- (void)STRY_cachedViewControllerWillBePushed:(BOOL)animated;

@end
