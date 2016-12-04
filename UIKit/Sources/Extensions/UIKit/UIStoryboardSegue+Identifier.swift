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
    public struct Identifier {
        private init() {}
    }
}

extension UIStoryboardSegue.Identifier {
    public static var show: String {
        return "show"
    }

    public static var present: String {
        return "present"
    }

    public static var replace: String {
        return "reaplce"
    }

    public static var dismiss: String {
        return "dismiss"
    }

    public static var done: String {
        return "done"
    }

    public static var discard: String {
        return "discard"
    }
}
