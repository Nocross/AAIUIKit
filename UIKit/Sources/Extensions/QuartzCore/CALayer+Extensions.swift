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

import QuartzCore

public extension CALayer {
    public func pauseAnimations() {
        let time = self.convertTime(CACurrentMediaTime(), to: self.superlayer)
        self.speed = 0
        self.timeOffset = time
    }

    public func resumeAnimations() {
        let time = self.timeOffset
        let timeOffset = self.convertTime(CACurrentMediaTime(), to: self.superlayer) - time
        self.speed = 1.0
        self.timeOffset = 0
        self.beginTime = timeOffset
    }
}
