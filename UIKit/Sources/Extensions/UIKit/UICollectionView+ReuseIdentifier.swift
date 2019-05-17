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

extension UICollectionView {
    open func register<T: CellClass>(_ cellClass: T.Type, forCellWithReuseIdentifier identifier: ReuseIdentifier) {
        register(cellClass, forCellWithReuseIdentifier: identifier.rawValue)
    }
    
    open func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: ReuseIdentifier) {
        register(nib, forCellWithReuseIdentifier: identifier.rawValue)
    }
}

//MARK: -

extension UICollectionView {
    public typealias ReuseIdentifier = UICollectionReusableView.ReuseIdentifier
    
    open func dequeueReusableCell<T: CellClass>(withReuseIdentifier identifier: ReuseIdentifier = T.reuseIdentifier, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: identifier.rawValue, for: indexPath) as T
    }
    
    open func dequeueReusableSupplementaryView(ofKind elementKind: String, withReuseIdentifier identifier: ReuseIdentifier, for indexPath: IndexPath) -> UICollectionReusableView {
        return dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: identifier.rawValue, for: indexPath)
    }
}

//MARK: -

extension UICollectionReusableView {
    public struct ReuseIdentifier: ReuseIdentifierProtocol {
        public typealias RawValue = String
        
        private init() { rawValue = "" }
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        public let rawValue: RawValue
    }
    
    public class var reuseIdentifier: ReuseIdentifier {
        let value = reuseIdentifierString
        
        return ReuseIdentifier(rawValue: value)
    }
    
    @objc
    public class var reuseIdentifierString: String {
        return String(describing: self)
    }
}
