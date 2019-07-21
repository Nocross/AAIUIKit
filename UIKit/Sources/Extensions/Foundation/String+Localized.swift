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

import Foundation
import AAIFoundation

extension String.Localized.Error {
    public static var reasonFormat: String {
        let key = "%s, because %s"
        let comment = "error reason format i.e. \(key)"
        let format = NSLocalizedString(key, tableName: nil, bundle: Bundle.embeddedFramework, value: key, comment: comment)
        return format
    }

    public static var recoverySuggestionFormat: String {
        let key = "%s.\n %s"
        let comment = "error recovery suggestion format i.e. \(key)"
        let format = NSLocalizedString(key, tableName: nil, bundle: Bundle.embeddedFramework, value: key, comment: comment)
        return format
    }
}

//MARK: -

extension String.Localized.Common {
    public static var settings: String {
        let key = "common.settings"
        let value = "Settings"
        return NSLocalizedString(key, tableName: nil, bundle: Bundle.embeddedFramework, value: value, comment: "Settings")
    }
}

extension String.Localized.Common.Confirmation {
    public static var ok: String {
        let key = "common.confirmation.ok"
        let value = "OK"
        return NSLocalizedString(key, tableName: nil, bundle: Bundle.embeddedFramework, value: value, comment: "OK")
    }
}

extension String.Localized.Common.Dismissal {
    public static var cancel: String {
        let key = "common.dismissal.cancel"
        let value = "Cancel"
        return NSLocalizedString(key, tableName: nil, bundle: Bundle.embeddedFramework, value: value, comment: value)
    }
}

//MARK: -

fileprivate extension Bundle {
    static var embeddedFramework: Bundle {
        return Bundle(for: UIKit.self)
    }
}


