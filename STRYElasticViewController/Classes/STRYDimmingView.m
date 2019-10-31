//
//  STRYDimmingView.m
//  InteractiveTransitions
//
//  Created by Terry Lewis on 31/10/19.
//  Copyright © 2019 Terry Lewis. All rights reserved.
//

#import "STRYDimmingView.h"

@implementation STRYDimmingView

- (instancetype)initWithFrame:(CGRect)frame{
  if (self = [super initWithFrame:frame]) {
    self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
  }
  return self;
}

- (BOOL)isUserInteractionEnabled {
  return YES;
}

- (void)reset{
  self.alpha = 0.1f;
}

- (void)didMoveToSuperview{
  [super didMoveToSuperview];
  self.frame = self.superview.frame;
  self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
}

@end
