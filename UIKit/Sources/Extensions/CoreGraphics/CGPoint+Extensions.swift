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

import CoreGraphics

extension CGPoint {
    public var ceiled: CGPoint {
        let x = Darwin.ceil(self.x)
        let y = Darwin.ceil(self.y)
        
        return CGPoint(x: x, y: y)
    }
    
    public mutating func ceil() {
        x = Darwin.ceil(x)
        y = Darwin.ceil(y)
    }
}
