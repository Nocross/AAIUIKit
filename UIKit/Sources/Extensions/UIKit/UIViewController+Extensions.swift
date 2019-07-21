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

extension UIViewController {
    @IBInspectable public var hidesBackButton: Bool {
        get { return navigationItem.hidesBackButton }
        set { navigationItem.setHidesBackButton(newValue, animated: false) }
    }

    public func setHidesBackButton(_ hidesBackButton: Bool, animated: Bool) {
        navigationItem.setHidesBackButton(hidesBackButton, animated: animated)
    }

    public func dismiss(animated flag: Bool? = nil, completionHandler: (() -> Swift.Void)? = nil) {
        dismiss(animated: flag ?? UIView.areAnimationsEnabled, completion: completionHandler)
    }
    
    public func present(viewController: UIViewController, animated: Bool? = nil , completion: (() -> Void)? = nil) {
        present(viewController, animated: animated ?? UIView.areAnimationsEnabled, completion: completion)
    }
}
