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
import AAIFoundation

extension UICollectionView {
    public struct ElementKind: StringRepresentableIdentifierProtocol {
        public typealias RawValue = String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public let rawValue: String
    }
}

extension UICollectionView {
    open func register<T: SupplementaryViewClass>(_ viewClass: T.Type, forSupplementaryViewOfKind elementKind: ElementKind, withReuseIdentifier identifier: String) {
        register(viewClass, forSupplementaryViewOfKind: elementKind.rawValue, withReuseIdentifier: identifier)
    }
    
    open func register(_ nib: UINib?, forSupplementaryViewOfKind kind: ElementKind, withReuseIdentifier identifier: String) {
        register(nib, forSupplementaryViewOfKind: kind.rawValue, withReuseIdentifier: identifier)
    }
    
    open func dequeueReusableSupplementaryView<T: SupplementaryViewClass>(ofKind elementKind: ElementKind, withReuseIdentifier identifier: String, for indexPath: IndexPath) -> T {
        let result = dequeueReusableSupplementaryView(ofKind: elementKind.rawValue, withReuseIdentifier: identifier, for: indexPath) as T
        
        return result
    }
    
    private func register(_ viewClass: AnyClass?, forSupplementaryViewOfKind elementKind: ElementKind, withReuseIdentifier identifier: String) {
        register(viewClass, forSupplementaryViewOfKind: elementKind.rawValue, withReuseIdentifier: identifier)
    }
}
