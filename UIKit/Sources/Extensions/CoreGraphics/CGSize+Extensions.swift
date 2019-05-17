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

extension CGSize {
    public var ceiled: CGSize {
        let width = Darwin.ceil(self.width)
        let height = Darwin.ceil(self.height)
        
        return CGSize(width: width, height: height)
    }
    
    public mutating func ceil() {
        width = Darwin.ceil(width)
        height = Darwin.ceil(height)
    }
}
