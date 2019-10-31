//
//  Utils.h
//  InteractiveTransitions
//
//  Created by Terry Lewis on 31/10/19.
//  Copyright © 2019 Terry Lewis. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef Utils_h
#define Utils_h

void SwizzleSelector(SEL oldSelector, Class targetClass, SEL newSelector, Class newMethodClass);

id ObjectForPseudoProperty(id target, SEL key);

void StoreObjectForPseudoProperty(id target, SEL key, id object);

#endif /* Utils_h */
