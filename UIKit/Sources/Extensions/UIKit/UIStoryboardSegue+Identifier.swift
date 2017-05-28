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

extension UIStoryboardSegue {
    public struct Identifier: Hashable, RawRepresentable {
        public typealias RawValue = String

        let value: String

        public var rawValue: String {
            return value
        }

        public init?(rawValue: RawValue) {
            value = rawValue
        }

        public var hashValue: Int {
            return value.hashValue
        }
    }

    public convenience init(identifier: Identifier?, source: UIViewController, destination: UIViewController) {
        self.init(identifier: identifier?.rawValue, source: source, destination: destination)
    }

    public convenience init(identifier: Identifier?, source: UIViewController, destination: UIViewController, performHandler: @escaping () -> Swift.Void) {
        self.init(identifier: identifier?.rawValue, source: source, destination: destination, performHandler: performHandler)
    }
}

//MARK: -

extension UIStoryboardSegue.Identifier {
    public static var show: UIStoryboardSegue.Identifier {
        return UIStoryboardSegue.Identifier(rawValue: "show").unsafelyUnwrapped
    }

    public static var present: UIStoryboardSegue.Identifier {
        return UIStoryboardSegue.Identifier(rawValue: "present").unsafelyUnwrapped
    }

    public static var replace: UIStoryboardSegue.Identifier {
        return UIStoryboardSegue.Identifier(rawValue: "reaplce").unsafelyUnwrapped
    }

    public static var dismiss: UIStoryboardSegue.Identifier {
        return UIStoryboardSegue.Identifier(rawValue: "dismiss").unsafelyUnwrapped
    }

    public static var done: UIStoryboardSegue.Identifier {
        return UIStoryboardSegue.Identifier(rawValue: "done").unsafelyUnwrapped
    }

    public static var discard: UIStoryboardSegue.Identifier {
        return UIStoryboardSegue.Identifier(rawValue: "discard").unsafelyUnwrapped
    }
}

//MARK: -

extension UIViewController {
    func performSegue(withIdentifier identifier: UIStoryboardSegue.Identifier, sender: Any?) {
        performSegue(withIdentifier: identifier.rawValue, sender: sender)
    }
}


