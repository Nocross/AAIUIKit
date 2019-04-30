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

extension UITableViewHeaderFooterView {
    
    @available(iOS 6.0, *)
    public struct ReuseIdentifier: RawRepresentable {
        public typealias RawValue = String
        
        private init() { rawValue = "" }
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        public let rawValue: RawValue
    }
    
    @available(iOS 6.0, *)
    public convenience init(reuseIdentifier: ReuseIdentifier?) {
        self.init(reuseIdentifier: reuseIdentifier?.rawValue)
    }
    
    @available(iOS 6.0, *)
    open class var reuseIdentifier: ReuseIdentifier {
        let value = reuseIdentifierString
        
        return ReuseIdentifier(rawValue: value)
    }
    
    @available(iOS 6.0, *)
    open class var reuseIdentifierString: String {
        return String(describing: self)
    }
}

//MARK: -

extension UITableView {
    
    @available(iOS 6.0, *)
    open func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(withIdentifier identifier: UITableViewHeaderFooterView.ReuseIdentifier = T.reuseIdentifier) -> T {
        let result = dequeueReusableHeaderFooterView(withIdentifier: identifier.rawValue) as T
        
        return result
    }
    
    @available(iOS 6.0, *)
    open func register(_ nib: UINib?, forHeaderFooterViewReuseIdentifier identifier: UITableViewHeaderFooterView.ReuseIdentifier) {
        register(nib, forHeaderFooterViewReuseIdentifier: identifier.rawValue)
    }
    
    @available(iOS 6.0, *)
    open func register(_ aClass: AnyClass?, forHeaderFooterViewReuseIdentifier identifier: UITableViewHeaderFooterView.ReuseIdentifier) {
        register(aClass, forHeaderFooterViewReuseIdentifier: identifier.rawValue)
    }
    
    @available(iOS 6.0, *)
    open func register<T: UITableViewHeaderFooterView>(_ aClass: T.Type, forHeaderFooterViewReuseIdentifier identifier: UITableViewHeaderFooterView.ReuseIdentifier = T.reuseIdentifier) {
        register(aClass, forHeaderFooterViewReuseIdentifier: identifier.rawValue)
    }
}
