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

extension UIStoryboardSegue {
    public struct Identifier: StringRepresentableIdentifierProtocol {
        public typealias RawValue = String

        public let rawValue: RawValue

        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }

    public convenience init(identifier: Identifier?, source: UIViewController, destination: UIViewController) {
        self.init(identifier: identifier?.rawValue, source: source, destination: destination)
    }

    public convenience init(identifier: Identifier?, source: UIViewController, destination: UIViewController, performHandler: @escaping () -> Swift.Void) {
        self.init(identifier: identifier?.rawValue, source: source, destination: destination, performHandler: performHandler)
    }
    
    public var identifierValue: Identifier? {
        var result: Identifier?
        if let some = self.identifier {
            result = Identifier(rawValue: some)
        }
        
        return result
    }
}

//MARK: -

extension UIStoryboardSegue.Identifier {
    public static var show: UIStoryboardSegue.Identifier {
        return UIStoryboardSegue.Identifier(rawValue: "show")
    }

    public static var present: UIStoryboardSegue.Identifier {
        return UIStoryboardSegue.Identifier(rawValue: "present")
    }

    public static var replace: UIStoryboardSegue.Identifier {
        return UIStoryboardSegue.Identifier(rawValue: "replace")
    }

    public static var dismiss: UIStoryboardSegue.Identifier {
        return UIStoryboardSegue.Identifier(rawValue: "dismiss")
    }

    public static var done: UIStoryboardSegue.Identifier {
        return UIStoryboardSegue.Identifier(rawValue: "done")
    }

    public static var discard: UIStoryboardSegue.Identifier {
        return UIStoryboardSegue.Identifier(rawValue: "discard")
    }
    
    public static var cancel: UIStoryboardSegue.Identifier {
        return UIStoryboardSegue.Identifier(rawValue: "cancel")
    }
}

//MARK: -

extension UIViewController {
    public func performSegue(withIdentifier identifier: UIStoryboardSegue.Identifier, sender: Any?) {
        performSegue(withIdentifier: identifier.rawValue, sender: sender)
    }
    
    public func shouldPerformSegue(withIdentifier identifier: UIStoryboardSegue.Identifier, sender: Any?) -> Bool {
        return shouldPerformSegue(withIdentifier: identifier.rawValue, sender: sender)
    }
}


