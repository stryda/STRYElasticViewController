//
//  STRYNavigationControllerDelegate.m
//  InteractiveTransitions
//
//  Created by Terry Lewis on 31/10/19.
//  Copyright © 2019 Terry Lewis. All rights reserved.
//

#import "STRYNavigationControllerDelegate.h"
#import "UINavigationController+STRYExtensions.h"
#import "STRYDimmingView.h"

@interface STRYNavigationControllerDelegate () <UIGestureRecognizerDelegate>{
  UIScreenEdgePanGestureRecognizer *_leftEdgeScreenEdgePanGestureRecogniser, *_rightEdgeScreenEdgePanGestureRecogniser;
  STRYDimmingView *_dimmingView;
  __weak id <UIViewControllerContextTransitioning> _activeTransitionContext;
}
@property (nonatomic) UINavigationControllerOperation operation;
@property (nonatomic, assign) BOOL shouldCompleteTransition;
@property (nonatomic, getter=isInteractive) BOOL interactive;
@property (nonatomic, getter=isCurrentlyAnimating) BOOL currentlyAnimating;
@end

@implementation STRYNavigationControllerDelegate

+ (instancetype)sharedInstance{
  static id sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[[self class] alloc] init];
  });
  return sharedInstance;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
  [self.navigationController STRY_cleanupStoredViewControllers];
  [self setEdgeGestureRecognisersEnabled:YES];
}

- (instancetype)init{
  if (self = [super init]) {
    _dimmingView = [[STRYDimmingView alloc] init];
    _useDefaultAnimationsForNonInteractiveTransitions = NO;
  }
  return self;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
  if (self.isInteractive || self.useDefaultAnimationsForNonInteractiveTransitions == NO) {
    self.operation = operation;
    return self;
  }
  return nil;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController{
  if (self.isInteractive) {
    return self;
  }
  return nil;
}

- (void)setNavigationController:(UINavigationController *)navigationController{
  _navigationController = navigationController;
  [self attachPanGestureRecogniserToNavigationController];
}

- (void)attachPanGestureRecogniserToNavigationController{
  _leftEdgeScreenEdgePanGestureRecogniser = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleEdgePan:)];
  _leftEdgeScreenEdgePanGestureRecogniser.edges = UIRectEdgeLeft;
  [_navigationController.view addGestureRecognizer:_leftEdgeScreenEdgePanGestureRecogniser];
  
  _rightEdgeScreenEdgePanGestureRecogniser = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleEdgePan:)];
  _rightEdgeScreenEdgePanGestureRecogniser.edges = UIRectEdgeRight;
  [_navigationController.view addGestureRecognizer:_rightEdgeScreenEdgePanGestureRecogniser];
}

- (void)setEdgeGestureRecognisersEnabled:(BOOL)enabled{
  _leftEdgeScreenEdgePanGestureRecogniser.enabled = enabled;
  _rightEdgeScreenEdgePanGestureRecogniser.enabled = enabled;
}

- (void)handleEdgePan:(UIScreenEdgePanGestureRecognizer *)gestureRecogniser {
  
  switch (gestureRecogniser.state) {
    case UIGestureRecognizerStateBegan:
      if (gestureRecogniser == _leftEdgeScreenEdgePanGestureRecogniser) {
        _operation = UINavigationControllerOperationPop;
      }else if(gestureRecogniser == _rightEdgeScreenEdgePanGestureRecogniser){
        _operation = UINavigationControllerOperationPush;
      }
      [self gestureRecogniserBeganAction:gestureRecogniser];
      break;
    case UIGestureRecognizerStateChanged: {
      [self gestureRecogniserChangedAction:gestureRecogniser];
      break;
    }
    case UIGestureRecognizerStateEnded:
      [self setEdgeGestureRecognisersEnabled:NO];
    case UIGestureRecognizerStateCancelled:
      [self gestureRecogniserCancelledAction:gestureRecogniser];
      break;
    default:
      break;
  }
}

- (void)gestureRecogniserBeganAction:(UIScreenEdgePanGestureRecognizer *)gestureRecogniser{
  self.interactive = YES;
  
  if (_operation == UINavigationControllerOperationPop) {
    if (![self.navigationController popViewControllerAnimated:YES]) {
      [self cancelInteractiveTransition];
      gestureRecogniser.enabled = NO;
    }
  }else if(_operation == UINavigationControllerOperationPush){
    if (![self.navigationController STRY_pushNextStoredControllerAnimated:YES]){
      [self cancelInteractiveTransition];
      gestureRecogniser.enabled = NO;
    }
  }
}

- (void)gestureRecogniserChangedAction:(UIScreenEdgePanGestureRecognizer *)gestureRecogniser{
  CGPoint point = [gestureRecogniser translationInView:gestureRecogniser.view];
  float percent = point.x / gestureRecogniser.view.frame.size.width;
  static float kGoalVelocity = 800.0f;
  
  if (_operation == UINavigationControllerOperationPush) {
    percent = -percent;
  }
  
  CGFloat xVelocity = ABS([gestureRecogniser velocityInView:gestureRecogniser.view].x);
  if (xVelocity > kGoalVelocity) {
    self.shouldCompleteTransition = YES;
  }else{
    self.shouldCompleteTransition = (percent > 0.50);
  }
  CGFloat adjustedPercent = (percent <= 0.0) ? 0.0 : percent;
  [self updateInteractiveTransition: adjustedPercent];
}

- (void)gestureRecogniserCancelledAction:(UIScreenEdgePanGestureRecognizer *)gestureRecogniser{
  self.interactive = NO;
  if (!self.shouldCompleteTransition || gestureRecogniser.state == UIGestureRecognizerStateCancelled){
    [self cancelInteractiveTransition];
  }else{
    [self finishInteractiveTransition];
    _operation = UINavigationControllerOperationNone;
  }
}

#pragma mark - AnimationHandling

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
  return 0.3f;
}

- (CGFloat)horizontalOffsetForView:(UIView *)view{
  CGFloat offset;
  switch (_operation) {
    case UINavigationControllerOperationNone:
      offset = 0;
      break;
    case UINavigationControllerOperationPop:
      offset = view.frame.size.width;
      break;
    case UINavigationControllerOperationPush:
      offset = -view.frame.size.width;
      break;
    default:
      break;
  }
  return offset;
}

- (void)addLeftSideShadowToViewWithFading:(UIView *)view withTransitionContext:(id <UIViewControllerContextTransitioning>)transitionContext{
  CGFloat shadowWidth = 3.0f;
  CGFloat shadowVerticalPadding = -20.0f; // negative padding, so the shadow isn't rounded near the top and the bottom
  CGFloat shadowHeight = CGRectGetHeight(view.frame) - 2 * shadowVerticalPadding;
  CGRect shadowRect = CGRectMake(-shadowWidth, shadowVerticalPadding, shadowWidth, shadowHeight);
  UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:shadowRect];
  view.layer.shadowPath = [shadowPath CGPath];
  static CGFloat baseOpacity = 0.3f;
  CGFloat invertedCompletionPercentage = 1.0f - [self percentComplete];
  CGFloat calculatedOpacity = invertedCompletionPercentage * baseOpacity;
  view.layer.shadowOpacity = calculatedOpacity;
  
  // fade shadow during transition
  CGFloat toValue = 0.1f;
  CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
  animation.duration = [self transitionDuration:transitionContext];
  animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
  animation.fromValue = @(view.layer.shadowOpacity);
  animation.toValue = @(toValue);
  
  [view.layer addAnimation:animation forKey:nil];
  view.layer.shadowOpacity = toValue;
}

- (UIViewKeyframeAnimationOptions)appropriateAnimationOptionsForContext:(id <UIViewControllerContextTransitioning>)transitionContext{
  //    this is weird, we actually need to return UIViewAnimationOptionCurveLinear to get a linear curve. the SDK demands the UIViewKeyframeAnimationOption type, so we must bit shift UIViewAnimationOption and UIViewKeyframeAnimationOption. In theory, this should provide some kind of "hopeful" security in an update, since each targets a separate bit – hopeful assuming they don't introduce something that uses the extra bits.
  if ([transitionContext isInteractive]) {
    return UIViewAnimationOptionCurveLinear|UIViewKeyframeAnimationOptionCalculationModeLinear;
  }
  //    prevents warning
  return 0|UIViewAnimationOptionCurveEaseInOut;
}

- (CGFloat)bottomViewOffsetFactor{
  //    about what Apple uses.
  return 1.0 / 3.0;
}

#pragma UIViewControllerAnimatedTransitioning

- (void)completeAnimationWithTransitionContext:(id <UIViewControllerContextTransitioning>)transitionContext toView:(UIView *)toView fromView:(UIView *)fromView{
  BOOL successful = ![transitionContext transitionWasCancelled];
  
  [transitionContext completeTransition:successful];
  toView.transform = CGAffineTransformIdentity;
  fromView.transform = CGAffineTransformIdentity;
  self.currentlyAnimating = NO;
  [self setEdgeGestureRecognisersEnabled:YES];
  [_dimmingView removeFromSuperview];
}

- (void)performPushAnimationFromView:(UIView *)fromView toView:(UIView *)toView withTransitionContext:(id <UIViewControllerContextTransitioning>)transitionContext{
  
  __weak STRYDimmingView *weakDimmingView = _dimmingView;
  CGFloat width = [transitionContext finalFrameForViewController:[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey]].size.width;
  toView.transform = CGAffineTransformMakeTranslation(width, 0);
  _dimmingView.alpha = 0.0f;
  [UIView animateKeyframesWithDuration:[self transitionDuration:transitionContext]
                                 delay:0
                               options:[self appropriateAnimationOptionsForContext:transitionContext]
                            animations:^{
    toView.alpha = 1;
    toView.transform = CGAffineTransformMakeTranslation(0, 0);
    fromView.transform = CGAffineTransformMakeTranslation(width * -[self bottomViewOffsetFactor], 0);
    weakDimmingView.alpha = 0.1f;
  } completion:^(BOOL finished) {
    [self completeAnimationWithTransitionContext:transitionContext toView:toView fromView:fromView];
  }];
}

- (void)performPopAnimationFromView:(UIView *)fromView toView:(UIView *)toView withTransitionContext:(id <UIViewControllerContextTransitioning>)transitionContext{
  CGFloat width = [transitionContext finalFrameForViewController:[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey]].size.width;
  toView.transform = CGAffineTransformMakeTranslation(width * -[self bottomViewOffsetFactor], 0);
  _dimmingView.alpha = 0.1f;
  __weak STRYDimmingView *weakDimmingView = _dimmingView;
  [UIView animateKeyframesWithDuration:[self transitionDuration:transitionContext]
                                 delay:0
                               options:[self appropriateAnimationOptionsForContext:transitionContext]
                            animations:^{
    toView.alpha = 1;
    fromView.transform = CGAffineTransformMakeTranslation(width, 0);
    toView.transform = CGAffineTransformIdentity;
    weakDimmingView.alpha = 0.0f;
  } completion:^(BOOL finished) {
    [self completeAnimationWithTransitionContext:transitionContext toView:toView fromView:fromView];
  }];
}

- (void)configurateViewsInContextForAnimation:(id <UIViewControllerContextTransitioning>)transitionContext animationsWillEnd:(BOOL)animationsWillEnd{
  if (!animationsWillEnd) {
    _activeTransitionContext = transitionContext;
  }
  UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
  UIView * containerView = [transitionContext containerView];
  UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
  UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
  containerView.backgroundColor = fromView.backgroundColor;
  
  // fix for rotation bug in iOS 9
  toView.frame = [transitionContext finalFrameForViewController:toVC];
  //
  if (_operation == UINavigationControllerOperationPop) {
    [containerView addSubview:toView];
    [toView addSubview:_dimmingView];
    [containerView addSubview:fromView];
    [self addLeftSideShadowToViewWithFading:fromView withTransitionContext:transitionContext];
    
    if (!animationsWillEnd) {
      [self performPopAnimationFromView:fromView toView:toView withTransitionContext:transitionContext];
    }
  }else if (_operation == UINavigationControllerOperationPush){
    [containerView addSubview:fromView];
    [fromView addSubview:_dimmingView];
    [containerView addSubview:toView];
    [self addLeftSideShadowToViewWithFading:toView withTransitionContext:transitionContext];
    
    if (!animationsWillEnd) {
      [self performPushAnimationFromView:fromView toView:toView withTransitionContext:transitionContext];
    }
  }
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
  [self configurateViewsInContextForAnimation:transitionContext animationsWillEnd:NO];
}

- (UIViewAnimationCurve)completionCurve {
  return UIViewAnimationCurveLinear;
}

- (void)finishInteractiveTransition {
  [self configurateViewsInContextForAnimation:_activeTransitionContext animationsWillEnd:YES];
  [super finishInteractiveTransition];
}

- (void)cancelInteractiveTransition {
  [self configurateViewsInContextForAnimation:_activeTransitionContext animationsWillEnd:YES];
  [super cancelInteractiveTransition];
}

@end
