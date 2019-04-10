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

import AAIFoundation

extension UIAlertController {
    //MARK - Information

    public convenience init(infoWithTitle title: String?, message: String?, preferredStyle: UIAlertController.Style = .alert) {
        self.init(title: title, message: message, preferredStyle: preferredStyle)
    }

    //MARK - Settings

    public convenience init(requestSettingsWithTitle title: String?, message: String?, preferredStyle: UIAlertController.Style = .alert) {
        self.init(title: title, message: message, preferredStyle: preferredStyle)

        let settingsTitle = String.Localized.Common.settings
        let url = URL(string: UIApplication.openSettingsURLString)!

        let completion: (Bool) -> Void = { [weak self] _ in
            self?.dismiss()
        }

        let handler: (UIAlertAction) -> Void = { _ in
            let app = UIApplication.shared

            if #available(iOS 10.0, *) {
                app.open(url, options: [:], completionHandler: completion)
            } else {
                completion(app.openURL(url))
            }
        }
        let settingsAction = UIAlertAction(title: settingsTitle, style: .default, handler: handler)
        addAction(settingsAction)
    }

    //MARK: -

    public func addDismissAction(with title: String? = nil, style: UIAlertAction.Style = .cancel) {
        let title = title ?? String.Localized.Common.Confirmation.ok
        let dismissAction = UIAlertAction(dismissWithTitle: title, style: style, alertController: self)

        addAction(dismissAction)
    }
}

//MARK: - UIAlertAction(s)

extension UIAlertAction {
    public convenience init(dismissWithTitle title: String, style: UIAlertAction.Style = .cancel, alertController: UIAlertController) {
        let handler = { [weak alert = alertController](action: UIAlertAction) -> Void in
            guard let this = alert else { return }

            if this.presentingViewController != nil && !this.isBeingDismissed && !this.isBeingPresented {
                this.dismiss(animated: UIView.areAnimationsEnabled, completion: nil)
            }
        }

        self.init(title: title, style: style, handler: handler)
    }
}
