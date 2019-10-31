//
//  ViewController.h
//  InteractiveTransitions
//
//  Created by Terry Lewis on 31/10/19.
//  Copyright © 2019 Terry Lewis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic, readonly) NSUInteger depth;

- (instancetype)initWithDepth:(NSUInteger)depth;

@end

