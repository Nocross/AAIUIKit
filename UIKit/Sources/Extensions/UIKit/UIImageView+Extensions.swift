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


import Foundation

/*
 FOUNDATION_STATIC_INLINE void setAssociatedImage(UIImageView *imageView, UIImage *image, SEL selector);

 @implementation UIImageView (SPXEnabled)

 @dynamic disabledImage;
 @dynamic enabled;

 - (UIImage *)disabledImage {
 return objc_getAssociatedObject(self, _cmd);
 }

 - (void)setDisabledImage:(UIImage *)disabledImage {
 setAssociatedImage(self, disabledImage, @selector(disabledImage));
 }

 - (BOOL)isEnabled {
 return objc_getAssociatedObject(self, _cmd) == nil;
 }

 - (void)setEnabled:(BOOL)enabled {
 if (enabled) {
 UIImage * const image = objc_getAssociatedObject(self, @selector(isEnabled));
 if (image) {
 self.image = image;
 setAssociatedImage(self, nil, @selector(isEnabled));
 }
 } else {
 UIImage * const disabledImage = self.disabledImage;
 if (disabledImage) {
 UIImage * const image = self.image;
 if (image) {
 setAssociatedImage(self, image, @selector(isEnabled));
 self.image = self.disabledImage;
 }
 }
 }
 }

 @end

 void setAssociatedImage(UIImageView *imageView, UIImage *image, SEL selector) {
 objc_setAssociatedObject(imageView, selector, image, OBJC_ASSOCIATION_COPY_NONATOMIC);
 }

 */
