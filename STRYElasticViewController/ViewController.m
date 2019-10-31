//
//  ViewController.m
//  InteractiveTransitions
//
//  Created by Terry Lewis on 31/10/19.
//  Copyright © 2019 Terry Lewis. All rights reserved.
//

#import "ViewController.h"
#import "Classes/STRYNavigationControllerDelegate.h"
#import "Classes/UINavigationController+STRYExtensions.h"

@interface ViewController () <UINavigationControllerDelegate>

@end

@implementation ViewController

- (instancetype)initWithDepth:(NSUInteger)depth {
  if (self = [super init]) {
    _depth = depth;
    self.title = [NSString stringWithFormat:@"Controller index: %lu", (unsigned long)self.depth];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor whiteColor];
  UIButton *push = [UIButton buttonWithType:UIButtonTypeSystem];
  push.backgroundColor = [UIColor colorWithRed:0.1 green:0.4 blue:0.7 alpha:0.8];
  push.layer.borderColor = [UIColor colorWithRed:0.1 green:0.4 blue:0.7 alpha:1].CGColor;
  push.tintColor = UIColor.whiteColor;
  push.layer.cornerRadius = 8;
  push.layer.masksToBounds = YES;
  push.titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];
  push.frame = CGRectMake(0, 0, 300, 100);
  [push setTitle:@"Push new controller!" forState:UIControlStateNormal];
  [self.view addSubview:push];
  push.center = self.view.center;
  [push addTarget:self action:@selector(push:) forControlEvents:UIControlEventTouchUpInside];
  
  srand48(self.depth);
  CGFloat min = 0;
  CGFloat max = 255;
  CGFloat red = (CGFLOAT_TYPE)(round(drand48() * (max-min)) + min) / max;
  CGFloat green = (CGFLOAT_TYPE)(round(drand48() * (max-min)) + min) / max;
  CGFloat blue = (CGFLOAT_TYPE)(round(drand48() * (max-min)) + min) / max;
  self.view.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)push:(id)sender{
  ViewController *controller = [[ViewController alloc] initWithDepth:self.depth + 1];
  [self.navigationController pushViewController:controller animated:YES];
}

@end
