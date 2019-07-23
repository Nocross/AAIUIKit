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
    public typealias CellClass = UICollectionViewCell
    
    public typealias SupplementaryViewClass = UICollectionReusableView
    
    @IBOutlet public var collectionViewBackground: UIView? {
        get { return self.backgroundView }
        
        set { self.backgroundView = newValue }
    }
    
    open func dequeueReusableCell<T: CellClass>(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> T {
        let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        guard let result = cell as? T else { preconditionFailure("Cell type mismatch") }
        
        return result
    }
    
    open func dequeueReusableSupplementaryView<T: SupplementaryViewClass>(ofKind elementKind: String, withReuseIdentifier identifier: String, for indexPath: IndexPath) -> T {
        let cell = dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: identifier, for: indexPath)
        guard let result = cell as? T else { preconditionFailure("Supplementary view type mismatch") }
        
        return result
    }
}
