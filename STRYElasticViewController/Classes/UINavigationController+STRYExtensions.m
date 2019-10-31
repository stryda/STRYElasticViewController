//
//  UINavigationController+UINavigationController_STRYExtensions.m
//  InteractiveTransitions
//
//  Created by Terry Lewis on 31/10/19.
//  Copyright © 2019 Terry Lewis. All rights reserved.
//

#import "UINavigationController+STRYExtensions.h"
#import "STRYNavigationControllerDelegate.h"
#import "UIViewController+STRYExtensions.h"
#import "Utils.h"

@interface UINavigationController (STRYExtensions_Private)

@property (nonatomic, readonly, copy) NSMutableArray *STRY_nextViewControllerStack;

@end

@implementation UINavigationController (NIFExtensions)

+ (void)load{
  SwizzleSelector(@selector(setDelegate:), self, @selector(STRY_setDelegate:), self);
  SwizzleSelector(@selector(popViewControllerAnimated:), self, @selector(STRY_popViewControllerAnimated:), self);
  SwizzleSelector(@selector(initWithNibName:bundle:), self, @selector(STRY_initWithNibName:bundle:), self);
  SwizzleSelector(@selector(initWithCoder:), self, @selector(STRY_initWithCoder:), self);
  SwizzleSelector(@selector(pushViewController:animated:), self, @selector(STRY_pushViewController:animated:), self);
}

- (void)STRY_pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
  UIViewController *current = [self STRY_activeViewController];
  [viewController STRY_viewControllerWillBeCached];
  current.STRY_nextViewController = viewController;
  [self STRY_pushViewController:viewController animated:animated];
}

//designated initialiser overrides
- (instancetype)STRY_initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil{
  UINavigationController *controller = [self STRY_initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  [controller STRY_commonInit];
  return controller;
}

//designated initialiser overrides
- (nullable instancetype)STRY_initWithCoder:(NSCoder *)aDecoder{
  UINavigationController *controller = [self STRY_initWithCoder:aDecoder];
  [controller STRY_commonInit];
  return controller;
}

- (void)STRY_commonInit{
  //    cache controllers by default
  [self setSTRY_cacheForwardViewControllers:YES];
  //    create array to be used as controller cache
  NSMutableArray *array = [[NSMutableArray alloc] init];
  StoreObjectForPseudoProperty(self, @selector(STRY_nextViewControllerStack), array);
}

- (void)STRY_setDelegate:(id<UINavigationControllerDelegate>)delegate{
  [self STRY_setDelegate:delegate];
  //    create a reference to the navigation controller in the delegate.
  if ([delegate isKindOfClass:[STRYNavigationControllerDelegate class]]) {
    STRYNavigationControllerDelegate *castDelegate = (STRYNavigationControllerDelegate *)delegate;
    castDelegate.navigationController = self;
  }else{
    [self setSTRY_strongDelegate:nil];
  }
}

- (UIViewController *)STRY_popViewControllerAnimated:(BOOL)animated{
  //    store the current controller
  return [self STRY_popViewControllerAnimated:animated];
}

//retrieves the current view controller, the one that is pushed, not the modal one.
//self.visibleViewController may return the modal controller, we don't want that, so we must use this.
- (UIViewController *)STRY_activeViewController{
  UIViewController *controller = nil;
  NSInteger index = self.viewControllers.count - 1;
  if (index >= 0) {
    controller = [self.viewControllers objectAtIndex:index];
  }
  return controller;
}

//push the first stored controller, if there is one and if it not the same as the current controller
- (BOOL)STRY_pushNextStoredControllerAnimated:(BOOL)animated{
  UIViewController *currentController = [self STRY_activeViewController];
  UIViewController *nextController = currentController.STRY_nextViewController;
  if (nextController) {
    [nextController STRY_cachedViewControllerWillBePushed:animated];
    [self pushViewController:nextController animated:animated];
    return YES;
  }else{
    return NO;
  }
}

//removes the first stored view controller, (this method may be extended, it is public and may eventually call other cleanup methods).
- (void)STRY_cleanupStoredViewControllers{
}

//sets whether or not the navigation controller stores the previously popped view controllers.
- (void)setSTRY_cacheForwardViewControllers:(BOOL)STRY_cacheForwardViewControllers{
  StoreObjectForPseudoProperty(self, @selector(STRY_cacheForwardViewControllers), @(STRY_cacheForwardViewControllers));
}

//whether or not the navigation controller stores the previously popped view controllers.
- (BOOL)STRY_cacheForwardViewControllers{
  return [ObjectForPseudoProperty(self, @selector(STRY_cacheForwardViewControllers)) boolValue];
}

- (void)STRY_clearForwardCachedControllers{
  NSArray *controllers = [self.viewControllers copy];
  for (UIViewController *controller in controllers) {
    controller.STRY_nextViewController = nil;
  }
}

- (STRYNavigationControllerDelegate *)STRY_strongDelegate{
  return ObjectForPseudoProperty(self, @selector(STRY_strongDelegate));
}

- (void)setSTRY_strongDelegate:(STRYNavigationControllerDelegate *)STRY_strongDelegate{
  if ([STRY_strongDelegate isEqual:[self STRY_strongDelegate]]) {
    return;
  }
  if (![STRY_strongDelegate isKindOfClass:[STRYNavigationControllerDelegate class]]) {
    NSLog(@"setSTRY_strongDelegate: only accepts objects of or inheriting the class STRYNavigationControllerDelegate, the provided object was %@, of class: %@", STRY_strongDelegate, [STRY_strongDelegate class]);
    return;
  }
  StoreObjectForPseudoProperty(self, @selector(STRY_strongDelegate), STRY_strongDelegate);
  self.delegate = STRY_strongDelegate;
}

@end
