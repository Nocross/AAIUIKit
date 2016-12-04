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

#include "UIKit-Bridging-Header.h"

#define INTERNAL_CONCAT(a,b) a ## b
#define VERSION_NUMBER(PREFIX) INTERNAL_CONCAT(PREFIX,UIKitVersionNumber)
#define VERSION_STRING(PREFIX) INTERNAL_CONCAT(PREFIX, UIKitVersionString)

////! Project version number for UIKit.
extern double VERSION_NUMBER(PRODUCT_NAME_PREFIX);

////! Project version string for UIKit.
extern const unsigned char VERSION_STRING(PRODUCT_NAME_PREFIX)[];


extern double getUIKitVersionNumber() __attribute__ ((used)) ;
extern const unsigned char* getUIKitVersionString() __attribute__ ((used)) ;

double getUIKitVersionNumber() {
    return VERSION_NUMBER(PRODUCT_NAME_PREFIX);
}

const unsigned char *getUIKitVersionString() {
    return VERSION_STRING(PRODUCT_NAME_PREFIX);
}
