//
//  Utils.c
//  InteractiveTransitions
//
//  Created by Terry Lewis on 31/10/19.
//  Copyright © 2019 Terry Lewis. All rights reserved.
//

#include "Utils.h"
#import <objc/runtime.h>

void SwizzleSelector(SEL oldSelector, Class targetClass, SEL newSelector, Class newMethodClass){
  Method oldMethod = class_getInstanceMethod(targetClass, oldSelector);
  Method newMethod = class_getInstanceMethod(newMethodClass, newSelector);
  
  if (class_addMethod(newMethodClass, oldSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
    class_replaceMethod(newMethodClass, newSelector, method_getImplementation(oldMethod), method_getTypeEncoding(oldMethod));
  }else{
    method_exchangeImplementations(oldMethod, newMethod);
  }
}

id ObjectForPseudoProperty(id target, SEL key){
  return objc_getAssociatedObject(target, key);
}

void StoreObjectForPseudoProperty(id target, SEL key, id object){
  objc_setAssociatedObject(target, key, object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
