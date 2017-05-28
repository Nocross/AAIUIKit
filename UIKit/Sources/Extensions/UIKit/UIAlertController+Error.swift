/*
    Copyright (c) 2017 Andrey Ilskiy.

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

extension UIAlertController {

    @nonobjc
    public convenience init(with error: Error, preferredStyle: UIAlertControllerStyle = .alert) {
        var message: String

        if let localized = error as? LocalizedError {
            message = localized.errorMessage
        } else {
            message = error.localizedDescription
        }

        self.init(title: nil, message: message, preferredStyle: preferredStyle)
    }

    public func addRecoveryActions(for error: RecoverableError, resultHandler: @escaping (Bool) -> Void) {
        var action: UIAlertAction!
        for tuple in error.recoveryOptions.enumerated() {

            action = UIAlertAction(recoverFrom: error, optionIndex: tuple.offset, alertController: self, resultHandler: resultHandler)

            self.addAction(action)
        }
    }
}

//MARK: -

extension UIAlertAction {
    public convenience init(recoverFrom error: RecoverableError, optionIndex: Int, title: String? = nil, alertController: UIAlertController, style: UIAlertActionStyle = .default, resultHandler: @escaping (Bool) -> Void) {
        let title = title ?? error.recoveryOptions[optionIndex]
        let handler = { [weak alert = alertController](action: UIAlertAction) -> Void in
            guard let this = alert else { return }

            if this.presentingViewController != nil && !this.isBeingDismissed && !this.isBeingPresented {
                error.attemptRecovery(optionIndex: optionIndex, resultHandler: resultHandler)
            }
        }

        self.init(title: title, style: style, handler: handler)
    }
}

//MARK: -

fileprivate extension LocalizedError {
    var errorMessage: String {
        var result = self.localizedDescription

        if let description = self.errorDescription {
            result = description
        }

        if let reason = self.failureReason {
            let format = String.Localized.Error.reasonFormat
            result = String(format: format, result, reason)
        }

        if let suggestion = self.recoverySuggestion {
            let format = String.Localized.Error.recoverySuggestionFormat
            result = String(format: format, result, suggestion)
        }

        return result
    }
}
