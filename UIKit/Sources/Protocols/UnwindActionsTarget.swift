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


import Foundation.NSObject
import UIKit.UIStoryboardSegue;


@objc
public protocol UnwindActionsTarget {
    @objc optional func action(forUnwindSegue segue: UIStoryboardSegue)
    @objc optional func success(forUnwindSegue segue: UIStoryboardSegue)
    @objc optional func failure(forUnwindSegue segue: UIStoryboardSegue)
    @objc optional func save(forUnwindSegue segue: UIStoryboardSegue)
    @objc optional func update(forUnwindSegue segue: UIStoryboardSegue)
    @objc optional func modify(forUnwindSegue segue: UIStoryboardSegue)
    @objc optional func delete(forUnwindSegue segue: UIStoryboardSegue)
}
