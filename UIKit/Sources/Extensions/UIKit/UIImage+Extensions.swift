/*
    Copyright (c) 2019 Andrey Ilskiy.

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

extension UIImage {
    open class func make(from color: UIColor) -> UIImage {
        let size = CGSize(width: 1,height: 1)
        let rect = CGRect(origin: CGPoint.zero, size: size)
        
        UIGraphicsBeginImageContext(size)
        
        guard let context = UIGraphicsGetCurrentContext() else { fatalError("Missing context after 'UIGraphicsBeginImageContext' call") }
        context.setFillColor(color.cgColor)
        context.fill(rect)
        
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { fatalError("Failed to get image from opened context - \(context)") }
        
        UIGraphicsEndImageContext()
        
        return result
    }
}
