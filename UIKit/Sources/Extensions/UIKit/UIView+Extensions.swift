/*
    Copyright (c) 2016 Andrey Ilskiy.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
 */


import UIKit

public extension UIView {
    @IBInspectable public var borderColor: UIColor? {
        get { return (self.layer.borderColor != nil) ? UIColor(cgColor: self.layer.borderColor!) : nil }
        set { self.layer.borderColor = newValue?.cgColor }
    }

    @IBInspectable public var borderWidth: CGFloat {
        get { return self.layer.borderWidth }
        set { self.layer.borderWidth = newValue }
    }

    @IBInspectable public var corderRadius: CGFloat {
        get { return self.layer.cornerRadius }
        set { self.layer.cornerRadius = newValue }
    }
}

/*
 
 - (UIEdgeInsets)hitAreaEdgeInsets {
 NSValue * const value = objc_getAssociatedObject(self, @selector(hitAreaEdgeInsets));
 if(value) {
 UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
 [value getValue:&edgeInsets];
 return edgeInsets;
 } else {
 return UIEdgeInsetsZero;
 }
 }

 - (void)setHitAreaEdgeInsets:(UIEdgeInsets)hitAreaEdgeInsets {
 const UIEdgeInsets insets = self.hitAreaEdgeInsets;
 NSValue * const value = UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, hitAreaEdgeInsets) ? nil : [NSValue valueWithBytes:&hitAreaEdgeInsets objCType:@encode(UIEdgeInsets)];
 objc_setAssociatedObject(self, @selector(hitAreaEdgeInsets), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);


 Class cls = self.class;
 #pragma clang diagnostic push
 #pragma clang diagnostic ignored "-Wselector"
 #pragma clang diagnostic ignored "-Wundeclared-selector"
 const SEL selector = @selector(pointInside:withEvent:);
 #pragma clang diagnostic pop
 const SEL swizzleSelector = @selector(swizzled_pointInside:withEvent:);
 Method method = class_getSubclassClassMethod(cls, selector);

 if (UIEdgeInsetsEqualToEdgeInsets(insets, UIEdgeInsetsZero) && value) {
 if (method) {
 method_exchangeImplementations(method, class_getClassMethod(cls, swizzleSelector));
 } else {
 method = class_getClassMethod(class_getSuperclass(cls), selector);
 const Method swizzleMethod = class_getClassMethod(cls, swizzleSelector);
 BOOL const success = class_addMethod(cls, selector, method_getImplementation(swizzleMethod), method_getTypeEncoding(method));
 NSParameterAssert(success);

 method_setImplementation(swizzleMethod, method_getImplementation(method));
 }
 } else if (value == nil) {
 const Method swizzleMethod = class_getClassMethod(cls, swizzleSelector);
 method_exchangeImplementations(method, swizzleMethod);
 }
 }

 - (BOOL)swizzled_pointInside:(CGPoint)point withEvent:(UIEvent *)event {
 BOOL result = NO;
 const UIEdgeInsets insets = self.hitAreaEdgeInsets;
 if(!(UIEdgeInsetsEqualToEdgeInsets(insets, UIEdgeInsetsZero) && self.hidden)) {
 const CGRect relativeFrame = self.bounds;
 const CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, insets);
 result = CGRectContainsPoint(hitFrame, point);
 } else {
 result = [self swizzled_pointInside:point withEvent:event];
 }

 return result;
 }


 */
