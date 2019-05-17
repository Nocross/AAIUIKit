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

extension UIView {
    @IBInspectable public var borderColor: UIColor? {
        get { return (self.layer.borderColor != nil) ? UIColor(cgColor: self.layer.borderColor!) : nil }
        set { self.layer.borderColor = newValue?.cgColor }
    }

    @IBInspectable public var borderWidth: CGFloat {
        get { return self.layer.borderWidth }
        set { self.layer.borderWidth = newValue }
    }

    @IBInspectable public var corderRadius: CGFloat {
        get { return self.layer.cornerRadius }
        set { self.layer.cornerRadius = newValue }
    }
}

extension UIView {
    public func compressSizeToFit(_ size: CGSize) {
        var fittingSize = self.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        var bounds = CGRect(origin: CGPoint.zero, size: fittingSize)
        self.bounds = bounds
        
        fittingSize = sizeThatFits(fittingSize)
        bounds = CGRect(origin: CGPoint.zero, size: fittingSize)
        
        self.bounds = bounds
    }
}

extension UIView.AutoresizingMask: CustomStringConvertible {
    public var description: String {
        let mirror = customMirror
        
        let result = mirror.children.reduce(into: "") {
            if !$0.isEmpty { $0.append("+") }
            
            let description = String(describing: $1.value)
            $0.append("\(description)")
        }
        
        return result
    }
}

extension UIView.AutoresizingMask: CustomReflectable {
    public var customMirror: Mirror {
        var result: Mirror
        if isEmpty {
            result = Mirror(self, unlabeledChildren: "None", displayStyle: .none)
        } else {
            var children = [String]()
            
            if contains(.flexibleLeftMargin) {
                children.append("LM")
            }
            if contains(.flexibleWidth) {
                children.append("W")
            }
            if contains(.flexibleRightMargin) {
                children.append("RM")
            }
            if contains(.flexibleTopMargin) {
                children.append("TM")
            }
            if contains(.flexibleHeight) {
                children.append("H")
            }
            if contains(.flexibleBottomMargin) {
                children.append("BM")
            }
            
            result = Mirror(self, unlabeledChildren: children, displayStyle: .set)
        }
        
        return result
    }
}
