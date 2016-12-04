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

public extension UIAlertController {
    public convenience init(withError error: NSError, preferredStyle: UIAlertControllerStyle = .alert) {
        self.init(title: error.localizedFailureReason, message: error.localizedDescription, preferredStyle: preferredStyle)

        if error.recoveryAttempter != nil {
            fatalError("attempter handling not yet implemented")
        } else {
            let title = NSLocalizedString("common.confirmation.ok", comment: "OK")
            let dismissAction = UIAlertAction(dismissWithTitle: title, alertController: self)

            self.addAction(dismissAction);
        }
    }

    public convenience init(infoWithTitle title: String?, message: String?, preferredStyle: UIAlertControllerStyle = .alert) {
        self.init(title: title, message: message, preferredStyle: preferredStyle)

        let title = NSLocalizedString("common.confirmation.ok", comment: "OK")
        let dismissAction = UIAlertAction(dismissWithTitle: title, alertController: self)

        self.addAction(dismissAction)
    }

    public convenience init(requestSettingsWithTitle title: String?, message: String?, preferredStyle: UIAlertControllerStyle = .alert) {
        self.init(title: title, message: message, preferredStyle: preferredStyle)

        let dismissTitle = NSLocalizedString("common.rejection.cancel", comment: "Cancel")
        let dissmissAction = UIAlertAction(dismissWithTitle: dismissTitle, alertController: self)
        self.addAction(dissmissAction)

        let settingsTitle = NSLocalizedString("common.application.settings", comment: "Settings")
        let url = URL(string: UIApplicationOpenSettingsURLString)!

        let completion: (Bool) -> Void = { [weak self] _ in
            self?.dismiss(animated: UIView.areAnimationsEnabled, completion: nil)
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
        self.addAction(settingsAction)
    }
}

public extension UIAlertAction {
    public convenience init(dismissWithTitle title: String, alertController: UIAlertController) {
        let handler = { [weak alert = alertController](action: UIAlertAction) -> Void in
            guard let this = alert else {
                return
            }

            if this.presentingViewController != nil && !this.isBeingDismissed && !this.isBeingPresented {
                this .dismiss(animated: UIView.areAnimationsEnabled, completion: nil)
            }
        }

        self.init(title: title, style: .cancel, handler: handler)
    }
}
