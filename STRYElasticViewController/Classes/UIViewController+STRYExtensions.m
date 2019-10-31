//
//  UIViewController+UIViewController.m
//  InteractiveTransitions
//
//  Created by Terry Lewis on 31/10/19.
//  Copyright © 2019 Terry Lewis. All rights reserved.
//

#import "UIViewController+STRYExtensions.h"
#import "Utils.h"

@implementation UIViewController (STRYExtensions)

//returns the controller cache.
- (NSArray *)STRY_nextViewController{
  return ObjectForPseudoProperty(self, @selector(STRY_nextViewController));
}

//sets whether or not the navigation controller stores the previously popped view controllers.
- (void)setSTRY_nextViewController:(UIViewController *)STRY_nextViewController{
  StoreObjectForPseudoProperty(self, @selector(STRY_nextViewController), STRY_nextViewController);
}

- (void)STRY_viewControllerWillBeCached{
  //    stub, override in subclass
}

- (void)STRY_cachedViewControllerWillBePushed:(BOOL)animated{
  //    stub, override in subclass
}

@end
