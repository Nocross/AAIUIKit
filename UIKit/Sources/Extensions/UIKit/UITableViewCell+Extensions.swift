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

public extension UITableViewCell {
    public class var cellIdentifier : String {
        return String(describing: self)
    }

    //MARK:

    @IBOutlet public private(set) weak var labelView: UILabel? {
        get {
            var key = self.labelViewAssociationKey
            return withUnsafePointer(to: &key, { return objc_getAssociatedObject(self, $0) as? UILabel })
        }

        set {
            var key = self.labelViewAssociationKey
            withUnsafePointer(to: &key, { objc_setAssociatedObject(self, $0, newValue, .OBJC_ASSOCIATION_ASSIGN) })
        }
    }

    private var labelViewAssociationKey: Selector {
        return #selector(getter: type(of: self).labelView)
    }

    @IBOutlet public private(set) weak var detailLabelView: UILabel? {
        get {
            var key = self.detailLabelViewAssociationKey
            return withUnsafePointer(to: &key, { return objc_getAssociatedObject(self, $0) as? UILabel })
        }

        set {
            var key = self.detailLabelViewAssociationKey
            withUnsafePointer(to: &key, { objc_setAssociatedObject(self, $0, newValue, .OBJC_ASSOCIATION_ASSIGN) })
        }
    }

    private var detailLabelViewAssociationKey: Selector {
        return #selector(getter: type(of: self).detailLabelView)
    }

    //MARK:

    @IBOutlet public private(set) weak var iconView: UIImageView? {
        get {
            var key = self.iconViewAssociationKey
            return withUnsafePointer(to: &key, { return objc_getAssociatedObject(self, $0) as? UIImageView })
        }

        set {
            var key = self.iconViewAssociationKey
            withUnsafePointer(to: &key, { objc_setAssociatedObject(self, $0, newValue, .OBJC_ASSOCIATION_ASSIGN) })
        }
    }

    private var iconViewAssociationKey: Selector {
        return #selector(getter: type(of: self).iconView)
    }

    @IBOutlet public private(set) weak var indicationView: UIImageView? {
        get {
            var key = self.indicationViewAssociationKey
            return withUnsafePointer(to: &key, { return objc_getAssociatedObject(self, $0) as? UIImageView })
        }

        set {
            var key = self.indicationViewAssociationKey
            withUnsafePointer(to: &key, { objc_setAssociatedObject(self, $0, newValue, .OBJC_ASSOCIATION_ASSIGN) })
        }
    }

    private var indicationViewAssociationKey: Selector {
        return #selector(getter: type(of: self).indicationView)
    }

    //MARK:

    @IBOutlet public private(set) weak var switchView: UISwitch? {
        get {
            var key = self.switchViewAssociationKey
            return withUnsafePointer(to: &key, { return objc_getAssociatedObject(self, $0) as? UISwitch })
        }

        set {
            var key = self.switchViewAssociationKey
            withUnsafePointer(to: &key, { objc_setAssociatedObject(self, $0, newValue, .OBJC_ASSOCIATION_ASSIGN) })
        }
    }

    private var switchViewAssociationKey: Selector {
        return #selector(getter: type(of: self).switchView)
    }
}
