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


import UIKit
import ObjectiveC

extension UITableViewCell {
    public class var cellIdentifier : String {
        return String(describing: self)
    }
    
    @IBInspectable
    public var selectionColor: UIColor? {
        get { return selectedBackgroundView?.backgroundColor }
        set {
            let view = UIView()
            selectedBackgroundView = view //NOTE: - should be repaced for color to take effect
            
            //NOTE: - dealy to next runloop as UIKit will skip/or prioritze UIAppearance for current one
            OperationQueue.main.addOperation { view.backgroundColor = newValue }
        }
    }

    //MARK: -

    @IBOutlet public private(set) weak var labelView: UILabel? {
        get {
            let key = labelViewAssociationKeyPtr
            return objc_getAssociatedObject(self, key) as? UILabel
        }

        set {
            let key = labelViewAssociationKeyPtr
            objc_setAssociatedObject(self, key, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }

    private var labelViewAssociationKeyPtr: UnsafeRawPointer {
        let selector = #selector(getter: type(of: self).labelView)
        return unsafeBitCast(selector, to: UnsafeRawPointer.self)
    }

    @IBOutlet public private(set) weak var detailLabelView: UILabel? {
        get {
            let key = detailLabelViewAssociationKeyPtr
            return objc_getAssociatedObject(self, key) as? UILabel
        }

        set {
            let key = detailLabelViewAssociationKeyPtr
            objc_setAssociatedObject(self, key, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }

    private var detailLabelViewAssociationKeyPtr: UnsafeRawPointer {
        let selector = #selector(getter: type(of: self).detailLabelView)
        return unsafeBitCast(selector, to: UnsafeRawPointer.self)
    }

    //MARK:

    @IBOutlet public private(set) weak var iconView: UIImageView? {
        get {
            let key = iconViewAssociationKeyPtr
            return objc_getAssociatedObject(self, key) as? UIImageView
        }

        set {
            let key = iconViewAssociationKeyPtr
            objc_setAssociatedObject(self, key, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }

    private var iconViewAssociationKeyPtr: UnsafeRawPointer {
        let selector = #selector(getter: type(of: self).iconView)
        return unsafeBitCast(selector, to: UnsafeRawPointer.self)
    }

    @IBOutlet public private(set) weak var indicationView: UIImageView? {
        get {
            let key = indicationViewAssociationKeyPtr
            return objc_getAssociatedObject(self, key) as? UIImageView
        }

        set {
            let key = indicationViewAssociationKeyPtr
            objc_setAssociatedObject(self, key, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }

    private var indicationViewAssociationKeyPtr: UnsafeRawPointer {
        let selector = #selector(getter: type(of: self).indicationView)
        return unsafeBitCast(selector, to: UnsafeRawPointer.self)
    }

    //MARK:

    @IBOutlet public private(set) weak var switchView: UISwitch? {
        get {
            let key = switchViewAssociationKeyPtr
             return objc_getAssociatedObject(self, key) as? UISwitch
        }

        set {
            let key = switchViewAssociationKeyPtr
            objc_setAssociatedObject(self, key, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }

    private var switchViewAssociationKeyPtr: UnsafeRawPointer {
        let selector = #selector(getter: type(of: self).switchView)
        return unsafeBitCast(selector, to: UnsafeRawPointer.self)
    }
}

//MARK: -

extension UITableViewCell.StateMask {
    public static var defaultMask: UITableViewCell.StateMask {
        return UITableViewCell.StateMask(rawValue: 0)
    }
}
