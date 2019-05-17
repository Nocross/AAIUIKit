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
import CoreData

import AAIFoundation
import AAICoreData

protocol PrimaryDocument {
    static func primaryDocumentName() -> String

    static func primaryStoreURL() -> URL

    static func primaryModelName() -> String?
}

open class ManagedDocument: UIManagedDocument {

    private static let _primaryDocument = ManagedDocument(fileURL: ManagedDocument.primaryStoreURL())

    internal let _managedObjectModel : NSManagedObjectModel!

    open class var primary: UIManagedDocument {
        return _primaryDocument
    }

    public override init(fileURL url: URL) {
        var mom : NSManagedObjectModel! = nil
        if let name = type(of: self).primaryModelName() {
            mom = NSManagedObjectModel(withName: name)
        }
        _managedObjectModel = mom

        super.init(fileURL: url)
    }

    public init(fileURL url: URL, managedObjectModel: NSManagedObjectModel) {
        _managedObjectModel = managedObjectModel

        super.init(fileURL: url)
    }

    open override var managedObjectModel: NSManagedObjectModel {
        return _managedObjectModel ?? super.managedObjectModel
    }

    open override func configurePersistentStoreCoordinator(for storeURL: URL, ofType fileType: String, modelConfiguration configuration: String?, storeOptions: [AnyHashable : Any]? = nil) throws {
        
        let storeType = self.persistentStoreType(forFileType: fileType)
        var options = NSPersistentStore.defaultOptions(forStoreType: storeType)

        if var userOptions : [AnyHashable : Any] = storeOptions, let defaultOptions = options {
            /* add missing options from default */
            let predicate = { (option: (key: AnyHashable, value: Any)) in
                if userOptions.index(forKey: option.key) == nil {
                    userOptions[option.key] = option.value
                }
            };
            defaultOptions.forEach(predicate)

            options = userOptions
        }

        try super.configurePersistentStoreCoordinator(for: storeURL, ofType: fileType, modelConfiguration: configuration, storeOptions: storeOptions)
    }

    open override func handleError(_ error: Error, userInteractionPermitted: Bool) {
//        let nserror = error as NSError
//
//        if userInteractionPermitted {
//            <#code#>
//        }

        super.handleError(error, userInteractionPermitted: userInteractionPermitted)
    }

    open override func finishedHandlingError(_ error: Error, recovered: Bool) {
        super.finishedHandlingError(error, recovered: recovered)
    }
    
    //MARK: - PrimaryDocument
    
    open class func primaryDocumentName() -> String {
        return "primaryDocument"
    }
    
    open class func primaryStoreURL() -> URL {
        let documentsURL = FileManager.default.userDocumentsDirectoryURL
        return URL(fileURLWithPath: self.primaryDocumentName(), isDirectory: false, relativeTo: documentsURL)
    }
    
    open class func primaryModelName() -> String? {
        let bundle = Bundle.main
        
        let result = bundle.object(forInfoDictionaryKey: SPXModelNameKey) as? String
        
        return result
    }
}
