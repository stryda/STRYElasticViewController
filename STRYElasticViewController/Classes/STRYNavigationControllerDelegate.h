//
//  STRYNavigationControllerDelegate.h
//  InteractiveTransitions
//
//  Created by Terry Lewis on 31/10/19.
//  Copyright © 2019 Terry Lewis. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface STRYNavigationControllerDelegate : UIPercentDrivenInteractiveTransition <UINavigationControllerDelegate, UIViewControllerAnimatedTransitioning>

+ (instancetype)sharedInstance;

@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic) BOOL useDefaultAnimationsForNonInteractiveTransitions;

@end
