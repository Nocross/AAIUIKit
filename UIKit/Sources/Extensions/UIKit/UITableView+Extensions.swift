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

extension UITableView {
    @IBOutlet public var tableViewHeader: UIView? {
        get { return self.tableHeaderView }

        set { self.tableHeaderView = newValue }
    }

    @IBOutlet public var tableViewFooter: UIView? {
        get { return self.tableFooterView }

        set { self.tableFooterView = newValue }
    }

    @IBOutlet public var tableViewBackground: UIView? {
        get { return self.backgroundView }

        set { self.backgroundView = newValue }
    }
}
