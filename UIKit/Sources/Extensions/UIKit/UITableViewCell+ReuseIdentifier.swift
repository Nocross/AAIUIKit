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

extension UITableViewCell {
    
    @available(iOS 5.0, *)
    public struct ReuseIdentifier: RawRepresentable {
        public typealias RawValue = String
        
        private init() { rawValue = "" }
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        public let rawValue: RawValue
    }
    
    @available(iOS 5.0, *)
    public convenience init(reusableCellWithStyle style: UITableViewCell.CellStyle) {
        self.init(style: style, reuseIdentifier: type(of: self).reuseIdentifierString)
    }
    
    @available(iOS 5.0, *)
    public class var reuseIdentifier: ReuseIdentifier {
        let value = reuseIdentifierString
        
        return ReuseIdentifier(rawValue: value)
    }
    
    @available(iOS 5.0, *)
    public class var reuseIdentifierString: String {
        return String(describing: self)
    }
}

//MARK: -

extension UITableView {
    
    @available(iOS 6.0, *)
    open func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath, withIdentifier identifier: UITableViewCell.ReuseIdentifier = T.reuseIdentifier) -> T {
        
        let result = dequeueReusableCell(withIdentifier: identifier.rawValue, for: indexPath) as T
        
        return result
    }
    
    @available(iOS 5.0, *)
    open func register(_ nib: UINib?, forCellReuseIdentifier identifier: UITableViewCell.ReuseIdentifier) {
        register(nib, forHeaderFooterViewReuseIdentifier: identifier.rawValue)
    }
    
    @available(iOS 6.0, *)
    open func register(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: UITableViewCell.ReuseIdentifier) {
        register(cellClass, forHeaderFooterViewReuseIdentifier: identifier.rawValue)
    }
    
    @available(iOS 6.0, *)
    open func register<T: UITableViewCell>(_ cellClass: T.Type, forCellReuseIdentifier identifier: UITableViewCell.ReuseIdentifier = T.reuseIdentifier) {
        register(cellClass, forHeaderFooterViewReuseIdentifier: identifier.rawValue)
    }
}
