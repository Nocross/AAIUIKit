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

public extension String.Localized.Common {
    public static var settings: String {
        return NSLocalizedString("common.settings", tableName: nil, bundle: Bundle.embeddedFramework, value: "Settings", comment: "Settings")
    }
}

public extension String.Localized.Common.Confirmation {
    public static var ok: String {
        return NSLocalizedString("common.confirmation.ok", tableName: nil, bundle: Bundle.embeddedFramework, value: "OK", comment: "OK")
    }
}

public extension String.Localized.Common.Dismissal {
    public static var cancel: String {
        return NSLocalizedString("common.dissmisal.cancel", tableName: nil, bundle: Bundle.embeddedFramework, value: "OK", comment: "OK")
    }
}

fileprivate extension Bundle {
    static var embeddedFramework: Bundle {
        return Bundle(for: UIKit.self)
    }
}
