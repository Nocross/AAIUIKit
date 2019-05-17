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

open class NibProvider: NSObject {
    private var _nib: UINib!
    
    public private(set) var nib: UINib? {
        get {
            var result: UINib!
            
            if let some = _nib {
                result = some
            } else if let name = self.name {
                result = UINib(nibName: name, bundle: bundle)
                
                if result != nil {
                    _nib = result
                }
            }
            
            return result
            
        }
        
        set { _nib = newValue }
    }
    
    @IBInspectable
    open private(set) var name: String?
    
    @IBInspectable
    open private(set) var bundleIdentifier: String? {
        get { return bundle?.bundleIdentifier }
        set { bundle = newValue == nil ? nil : Bundle(identifier: newValue!) }
    }
    
    @IBInspectable
    open private(set) var bundle: Bundle?
    
    public override init() {
        super.init()
    }
    
    public init(nibName name: String, bundle bundleOrNil: Bundle?) {
        self.name = name
        bundle = bundleOrNil
    }
    
    public init(data: Data, bundle bundleOrNil: Bundle?) {
        super.init()
        
        nib = UINib(data: data, bundle: bundleOrNil)
    }
    
    //MARK: -
    
    open override func responds(to aSelector: Selector!) -> Bool {
        return nib?.responds(to: aSelector) ?? false
    }
    
    open override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return nib
    }
}
