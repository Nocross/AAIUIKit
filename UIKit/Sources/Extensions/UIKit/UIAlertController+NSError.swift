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

import ObjectiveC

import Foundation
import UIKit

import AAIFoundation

extension UIAlertController {
    public convenience init(withError error: NSError, preferredStyle: UIAlertController.Style = .alert, recoveryDelegate: Any? = nil, didRecoverSelector: Selector? = nil, contextInfo: UnsafeMutableRawPointer? = nil) {

        self.init(title: nil, message: error.localizedErrorMessage, preferredStyle: preferredStyle)
    }

    public func addRecoveryActions(for error: NSError, delegate: ErrorRecoveryAttemptingDelegate?, contextInfo: UnsafeMutableRawPointer? = nil) {
        let selector = #selector(ErrorRecoveryAttemptingDelegate.didRecoverFromPresentedError)

        addRecoveryActions(for: error, delegate: delegate, didRecoverSelector: selector, contextInfo: contextInfo)
    }

    /* Look at NSErrorRecoveryAttempting before using */
    public func addRecoveryActions(for error: NSError, delegate: Any?, didRecoverSelector: Selector? = nil, contextInfo: UnsafeMutableRawPointer? = nil) {
        guard let options = error.localizedRecoveryOptions, error.recoveryAttempter != nil else { return }

        for tuple in options.enumerated() {
            if let action = UIAlertAction(recoverFrom: error, optionIndex: tuple.offset, recoveryDelegate: delegate, didRecoverSelector: didRecoverSelector, contextInfo: contextInfo, alertController: self) {
                addAction(action)
            }
        }
    }
}

//MARK: -

extension UIAlertAction {
    private typealias attemptRecoveryFunction = @convention(c) (Any, Selector, Error, Int, Any?, Selector?, UnsafeMutableRawPointer?) -> Void

    public convenience init?(recoverFrom error: NSError, optionIndex: Int, recoveryDelegate: Any?, didRecoverSelector: Selector?, contextInfo: UnsafeMutableRawPointer?, alertController: UIAlertController, style: UIAlertAction.Style = .default) {
        guard let attempter = error.recoveryAttempter else { return nil }

        let selector = #selector(ErrorRecoveryAttemptingDelegate.didRecoverFromPresentedError)
        guard recoveryDelegate != nil && didRecoverSelector != nil && didRecoverSelector! != selector else {
            return nil
        }
        guard let title = error.localizedRecoveryOptions?[optionIndex] else { return nil }

        let handler = { [weak alert = alertController](action: UIAlertAction) -> Void in
            guard let this = alert else { return }

            if this.presentingViewController != nil && !this.isBeingDismissed && !this.isBeingPresented {
                let function = UIAlertAction.getAttemptRecoveryFunction(from: attempter)
                function(attempter, selector, error, optionIndex, recoveryDelegate, didRecoverSelector, contextInfo)
            }
        }

        self.init(title: title, style: style, handler: handler)
    }


    /*
    As @class NSInvocation are not available...
    */

    private static func getAttemptRecoveryFunction(from attempter: Any) -> attemptRecoveryFunction {
        let cls: AnyClass! = object_getClass(attempter)
        precondition(cls != nil, "delegate doesn't have an Objective-C class")

        let selector = #selector(ErrorRecoveryAttempting.attemptRecovery(fromError:optionIndex:delegate:didRecoverSelector:contextInfo:))
        precondition(class_respondsToSelector(cls, selector), "class - \(String(describing: cls)) doesn't respond to selector - \(selector)")

        let imp = class_getMethodImplementation(cls, selector)
        precondition(imp != nil, "Missing implementation for selector - \(selector)")

        let function = unsafeBitCast(imp, to: attemptRecoveryFunction.self)

        return function
    }
}

//MARK: -

fileprivate extension NSError {
    var localizedErrorMessage: String {
        var result = self.localizedDescription

        if let reason = self.localizedFailureReason {
            let format = String.Localized.Error.reasonFormat
            result = String(format: format, result, reason)
        }

        if let suggestion = self.localizedRecoverySuggestion {
            let format = String.Localized.Error.recoverySuggestionFormat
            result = String(format: format, result, suggestion)
        }

        return result
    }
}
