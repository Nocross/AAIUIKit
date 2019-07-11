/*
    Copyright (c) 2019 Andrey Ilskiy.

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

import CoreData
import UIKit

import AAICoreData

@objc
public protocol FetchedEntityPropertisSectionInfoProvider {
    
    /* Returns an array of objects that implement the FetchedEntityPropertiesSectionInfo protocol.
     This provide a convenience interface for determining the number of sections, the names and titles of the sections, and access to the model objects that belong to each section.
     */
    var sections: [FetchedEntityPropertiesSectionInfo]? { get }
}

//MARK: -

@objc
public protocol FetchedEntityPropertiesSectionInfo {
    /* Name of the section
     */
    var name: String { get }
    
    
    /* Title of the section (used when displaying the index)
     */
    var indexTitle: String? { get }
    
    
    /* Number of objects in section
     */
    var numberOfObjects: Int { get }
    
    
    /* Returns the array of objects in the section.
     */
    var properties: [NSPropertyDescription]? { get }
}

//MARK: - NSManagedObject + FetchedEntityPropertisSectionInfoProvider

extension NSManagedObject {
    private final class SectionInfo: FetchedEntityPropertiesSectionInfo {
        public var name: String
        
        public var indexTitle: String?
        
        public var numberOfObjects: Int
        
        public var properties: [NSPropertyDescription]?
        
        public init(name: String = "", indexTitle: String? = nil, numberOfObjects: Int, properties: [NSPropertyDescription]?) {
            self.name = name
            self.indexTitle = indexTitle
            self.numberOfObjects = numberOfObjects
            self.properties = properties
        }
    }
    
    private final class Provider: FetchedEntityPropertisSectionInfoProvider {
        public let entity: NSEntityDescription
        
        public var sections: [FetchedEntityPropertiesSectionInfo]? {
            var properties = [NSPropertyDescription]()
            
            for entity in self.entity.inheritanceSequence() {
                let attributes = Array(entity.attributesByName.values)
                let relationships = Array(entity.relationshipsByName.values)
                
                if !attributes.isEmpty {
                    properties.append(contentsOf: attributes)
                }
                
                if !relationships.isEmpty {
                    properties.append(contentsOf: relationships)
                }
            }
            
            let section = SectionInfo(numberOfObjects: properties.count, properties: properties)
            
            return [section]
        }
        
        init(entity: NSEntityDescription) {
            self.entity = entity
        }
    }
    
    @objc
    open var entityPropertiesSectionInfoProvider: FetchedEntityPropertisSectionInfoProvider {
        return Provider(entity: entity)
    }
}

//MARK: -

@available(iOS 3.0, *)
public enum PropertyDescriptionKind {
    case attribute(attribute: NSAttributeDescription, value: NSAttributeDescription.AttributeType?)
    case relationship(relationship: NSRelationshipDescription, value: NSRelationshipDescription.Plurality?)
    
    public func getAttribute() throws -> (value: NSAttributeDescription.AttributeType?, description: NSAttributeDescription) {
        
        switch self {
        case .attribute(let description, let value):
            return (value, description)
        default:
            preconditionFailure()
        }
    }
    
    public func getRelationship() throws -> (value: NSRelationshipDescription.Plurality?, description: NSRelationshipDescription) {
        switch self {
        case .relationship(let description, let value):
            return (value, description)
        default:
            preconditionFailure()
        }
    }
    
    fileprivate static func make(from property: NSPropertyDescription, value: Any?) -> PropertyDescriptionKind {
        let result: PropertyDescriptionKind
        
        if let attribute = property as? NSAttributeDescription {
            
            let type = attribute.attributeType
            let some = NSAttributeDescription.AttributeType.make(from: type, value: value)
            
            result = .attribute(attribute: attribute, value: some)
        } else if let relationship = property as? NSRelationshipDescription {
            let some = NSRelationshipDescription.Plurality.make(from: relationship, value: value)
            
            result = .relationship(relationship: relationship, value: some)
        } else {
            preconditionFailure()
        }
        
        return result
    }
    
    public var property: NSPropertyDescription {
        let result: NSPropertyDescription
        
        switch self {
        case .attribute(let attribute, _):
            result = attribute
        case .relationship(let relationship, _):
            result = relationship
        }
        
        return result
    }
}

//MARK: - FetchedEntityTableDataSource

@available(iOS 3.0, *)
open class FetchedEntityTableDataSource<ManagedType: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate, UITableViewDataSource {
    
    public typealias CellDequeueStrategy = (_ tableView: UITableView, _ indexPath: IndexPath, _ propertyKind: PropertyDescriptionKind) -> UITableViewCell
    public typealias ReloadStrategy = (_ tableView: UITableView, _ indexPath: IndexPath,  _ propertyKind: PropertyDescriptionKind) -> Bool
    
    public private(set) unowned var tableView: UITableView?
    
    public var managedObjectContext: NSManagedObjectContext {
        return fetchedResultsController.managedObjectContext
    }
    
    public let dequeueStrategy: CellDequeueStrategy
    public let shouldReloadStrategy: ReloadStrategy?
    
    private let fetchedResultsController: NSFetchedResultsController<ManagedType>
//    private let properties: [NSPropertyDescription]
    
    private var batch: [() -> Void]?
    
    private var keyPaths = [String]()
    
    public init(withTableView tableView: UITableView, managedObjectID objectID: NSManagedObjectID, managedObjectContext: NSManagedObjectContext, cellDequeueStrategy: @escaping CellDequeueStrategy, shouldReloadStrategy: ReloadStrategy? = nil) {
        
        let isSane = objectID.entity.managedObjectClass === ManagedType.self
        guard isSane else {
            let message = "Generic class/type must match the type of provided object ID's entity"
            preconditionFailure(message)
        }
        
        let entity = objectID.entity
        guard let entityName = entity.name else {
            let message = "Undefined entity name in entity description for Object ID - \(objectID)"
            preconditionFailure(message)
        }
        
        let request = NSFetchRequest(entityName: entityName) as NSFetchRequest<ManagedType>
        request.resultType = .managedObjectResultType
        
        request.includesPendingChanges = true
        request.includesPropertyValues = true
        request.returnsObjectsAsFaults = false
        
        request.predicate = NSPredicate(format: "self == %@", argumentArray: [objectID])
        
//        let randomKey = entity.attributesByName.keys.randomElement()
//        let sortDescriptor = NSSortDescriptor(key: randomKey, ascending: <#T##Bool#>)
        let keyPath = \ManagedType.objectID
        let sortDescriptor = NSSortDescriptor(keyPath: keyPath, ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController = frc
        
        self.tableView = tableView
        
        dequeueStrategy = cellDequeueStrategy
        self.shouldReloadStrategy = shouldReloadStrategy
    }
    
    deinit {
        if fetchedResultsController.fetchedObjects != nil {
            guard let properties = properties else { return }
            guard let object = self.fetchedResultsController.fetchedObjects?.first else {
                preconditionFailure()
            }
            
            for property in properties {
                object.removeObserver(self, forKeyPath: property.name, context: nil)
            }
        }
    }
    
    public func performFetch() throws {
        if fetchedResultsController.delegate !== self {
            fetchedResultsController.delegate = self;
        }
        
        try self.fetchedResultsController.performFetch()
        
        guard let properties = properties else { return }
        guard let object = self.fetchedResultsController.fetchedObjects?.first else {
            preconditionFailure()
        }
        
        let options: NSKeyValueObservingOptions = [.new]
        
        for property in properties {
            object.addObserver(self, forKeyPath: property.name, options: options, context: nil)
        }
    }
    
    //MARK: -
    /*
    // returns nil if cell is not visible
    open func object(for cell: UITableViewCell) -> ManagedType? {
        var result: ManagedType?
        
        // returns nil if cell is not visible
        if let indexPath = tableView?.indexPath(for: cell) {
            result = object(at: indexPath)
        }
        
        return result
    }
    */
    
    //MARK: -
    
    open var properties: [NSPropertyDescription]? {
        guard let object = fetchedResultsController.fetchedObjects?.first else { return nil }
        
        var result: [NSPropertyDescription]?
        if let sections = object.entityPropertiesSectionInfoProvider.sections {
            result = sections.reduce(into: [NSPropertyDescription]()) { (result, section) in
                if let properties = section.properties {
                    result.append(contentsOf: properties)
                }
            }
        }
        
        return result
    }

    open func property(at indexPath: IndexPath) -> NSPropertyDescription {
        guard let object = fetchedResultsController.fetchedObjects?.first else { preconditionFailure() }
        
        let result: NSPropertyDescription
        
        
        guard let sections = object.entityPropertiesSectionInfoProvider.sections else { preconditionFailure() }
        precondition(indexPath.section < sections.count)
        
        let section = sections[indexPath.section]
        precondition(indexPath.row < section.numberOfObjects)
        
        guard let properties = section.properties else { preconditionFailure() }
        
        result = properties[indexPath.row]
        
        return result
    }
    
    open func indexPath(forProperty property: NSPropertyDescription) -> IndexPath? {
        guard let object = fetchedResultsController.fetchedObjects?.first else { preconditionFailure() }
        
        var result: IndexPath?
        
        let sections = object.entityPropertiesSectionInfoProvider.sections
        
        var row: Int?
        let section = sections?.firstIndex {
            row = $0.properties?.firstIndex(of: property)
            return row != nil
        }
        
        if section != nil, row != nil {
            result = [section!, row!]
        }
        
        return result
    }
    
    open func propertyKind(at indexPath: IndexPath) -> PropertyDescriptionKind {
        let property = self.property(at: indexPath)
        
        let frc = fetchedResultsController
        let context = frc.managedObjectContext
        
        let result = context.evaluateAndWait { () -> PropertyDescriptionKind in
            let object = frc.object(at: [0,0])
            let value = object.value(forKey: property.name)
            return PropertyDescriptionKind.make(from: property, value: value)
        }
        
        return result
    }
    
    //MARK: - UITableViewDataSource
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        assert(tableView === self.tableView, "Called from unregistered table view")
        
        let frc = fetchedResultsController
        
        let context = frc.managedObjectContext
        
        let result = context.evaluateAndWait { () -> Int in
            let object = frc.object(at: [0,0])
            let sectionInfo = object.entityPropertiesSectionInfoProvider.sections?[section]
            
            return sectionInfo?.numberOfObjects ?? 0
        }
        
        return result
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        assert(tableView === self.tableView, "Called from unregistered table view")
        
        let frc = fetchedResultsController
        let strategy = dequeueStrategy
        
        let context = frc.managedObjectContext
        let result = context.evaluateAndWait { () -> UITableViewCell in
            let object = frc.object(at: [0,0])
            guard let sections = object.entityPropertiesSectionInfoProvider.sections else { preconditionFailure() }
            guard let properties = sections[indexPath.section].properties else { preconditionFailure() }
            let property = properties[indexPath.row]
            
            let value = object.value(forKey: property.name)
            let kind = PropertyDescriptionKind.make(from: property, value: value)
            
            return strategy(tableView, indexPath, kind)
        }
        
        return result
    }
    
    // Optional
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        assert(tableView === self.tableView, "Called from unregistered table view")
        
        let frc = fetchedResultsController
        
        let context = frc.managedObjectContext
        let result = context.evaluateAndWait { () -> Int in
            let object = frc.object(at: [0,0])
            return object.entityPropertiesSectionInfoProvider.sections?.count ?? 0
        }
        
        return result
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        assert(tableView === self.tableView, "Called from unregistered table view")
        
        let frc = fetchedResultsController
        
        let context = frc.managedObjectContext
        let result = context.evaluateAndWait { () -> String? in
            let object = frc.object(at: [0,0])
            return object.entityPropertiesSectionInfoProvider.sections?[section].name
        }
        
        return result
    }
    
    // Editing
    
    // Moving/reordering
    
    // Index
    
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        assert(tableView === self.tableView, "Called from unregistered table view")
        
        let frc = fetchedResultsController
        
        let context = frc.managedObjectContext
        let result = context.evaluateAndWait { () -> [String]? in
            let object = frc.object(at: [0,0])
            return object.entityPropertiesSectionInfoProvider.sections?.compactMap { $0.indexTitle }
        }
        
        return result
    }
    
    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        assert(tableView === self.tableView, "Called from unregistered table view")
        
        let frc = fetchedResultsController
        let context = frc.managedObjectContext
        
        let result = context.evaluateAndWait { () -> Int? in
            let object = frc.object(at: [0,0])
            return object.entityPropertiesSectionInfoProvider.sections?.firstIndex { $0.indexTitle == title }
        }
        precondition(result != nil)
        
        return result!
    }
    
    // Data manipulation - insert and delete support
/*
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        assert(tableView === self.tableView, "Called from unregistered table view")
        
        let frc = fetchedResultsController
        let context = frc.managedObjectContext
        
        guard let object = fetchedResultsController.object(at: indexPath) as? NSManagedObject else {
            preconditionFailure()
        }
        
        switch editingStyle {
        case .insert:
            break
//            if let strategy = insertionStrategy, let object = strategy(tableView, indexPath) as? NSManagedObject , !object.isInserted {
//                fetchedResultsController.managedObjectContext.insert(object)
//            }
            
        case .delete:
            fetchedResultsController.managedObjectContext.delete(object)
            
        case .none:
            let message = "commit to tableView \(tableView) with editing style - \(editingStyle)"
            preconditionFailure(message)
            
        @unknown default:
            let message = "Uknown NSFetchedResultsChangeType - \(editingStyle)"
            preconditionFailure(message)
        }
    }
*/
    // Data manipulation - reorder / moving support
    
    //MARK: - KVO/KVC
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else { return }
        
        guard let object = fetchedResultsController.fetchedObjects?.first else { return }
        guard let property = object.entity.propertiesByName[keyPath] else { return }
        
        
        keyPaths.append(property.name)
    }
    
    //MARK: - NSFetchedResultsControllerDelegate
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        precondition(controller === fetchedResultsController)
        precondition(batch == nil)
        
        batch = []
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        precondition(controller === fetchedResultsController)
        
        guard let batch = batch else { preconditionFailure() }
        
        let isRevelant = !batch.isEmpty
        if isRevelant {
            let block = { batch.forEach { $0() } }
            process(batchUpdates: block, for: controller)
        }
        self.batch = nil
    }
    
/*
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        precondition(controller === fetchedResultsController)
        
        var result: String?
        
        if !sectionName.isEmpty {
            let index = sectionName.index(after: sectionName.startIndex)
            result = String(sectionName.prefix(upTo: index))
        }
        
        return result
    }
 */
/*
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        precondition(controller === fetchedResultsController)
        
        guard let tableView = self.tableView else {
            assertionFailure()
            return
        }
        
        let sections = IndexSet(integer: sectionIndex)
        
        var block: () -> Void
        
        switch type {
        case .insert:
            block = { tableView.insertSections(sections, with: .automatic) }
        case .delete:
            block = { tableView.deleteSections(sections, with: .automatic) }
        default:
            preconditionFailure("Invalid section change type - \(type)")
            break
        }
        
        batch?.append(block)
    }
*/

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        precondition(controller === fetchedResultsController)
        
        guard let tableView = self.tableView else {
            assertionFailure()
            return
        }
        
        switch type {
        case .delete:
//            block = { tableView.deleteRows(at: [indexPath!], with: .automatic) }
            break
        case .move:
//            block = { tableView.moveRow(at: indexPath!, to: newIndexPath!) }
            preconditionFailure()
            
        case .insert:
//            block = { tableView.insertRows(at: [newIndexPath!], with: .automatic) }
            fallthrough
        case .update:
            let object = anObject as! ManagedType
            
            let entity = object.entity
            
            for name in keyPaths {
                guard let property = entity.propertiesByName[name] else { continue }
                guard let indexPath = self.indexPath(forProperty: property) else { continue }
                
                let shouldReload: Bool
                
                if let strategy = shouldReloadStrategy  {
                    let value = object.value(forKey: name)
                    let kind = PropertyDescriptionKind.make(from: property, value: value)
                    
                    shouldReload = strategy(tableView, indexPath, kind)
                } else {
                    shouldReload = true
                }
                
                var block: (() -> Void)?
                
                if shouldReload {
                    block = { tableView.reloadRows(at: [indexPath], with: .automatic) }
                }
                
                if let some = block {
                    batch?.append(some)
                }
            }

//            let changes = changedPropertiesForCurrentEvent(in: object)
//            guard changes.isEmpty else { return }
//
//            for change in changes {
//                let shouldReload: Bool
//                if let strategy = shouldReloadStrategy  {
//                    let value = object.value(forKey: change.1.name)
//                    let kind = PropertyDescriptionKind.make(from: change.1, value: value)
//
//                    shouldReload = strategy(tableView, change.0, kind)
//                } else {
//                    shouldReload = true
//                }
//
//                var block: (() -> Void)?
//
//                if shouldReload {
//                    block = { tableView.reloadRows(at: [change.0], with: .automatic) }
//                }
//
//                if let some = block {
//                    batch?.append(some)
//                }
//            }
            
        @unknown default:
            debugPrint("Uknown NSFetchedResultsChangeType - \(type)")
            break
        }
    }
    
    private func changedPropertiesForCurrentEvent(in object: ManagedType) -> [(IndexPath, NSPropertyDescription)] {
        var result = [(IndexPath, NSPropertyDescription)]()
        
        let changes = Set(object.changedPropertiesForCurrentEvent())
        guard !changes.isEmpty else { return result }
        
        let provider = object.entityPropertiesSectionInfoProvider
        guard let sections = provider.sections else { preconditionFailure() }
        
        for (section, value) in sections.enumerated() {
            if let properties = value.properties {
                for (row, property) in properties.enumerated() {
                    if changes.contains(property) {
                        result.append(([section, row], property))
                    }
                }
            }
        }
        
        return result
    }
    
    //MARK: -
    
    private func process(batchUpdates: @escaping () -> Void, for controller: NSFetchedResultsController<NSFetchRequestResult>) {
        precondition(controller === fetchedResultsController)
        
        let tableView = self.tableView
        let callout = {
            if #available(iOS 11.0, *) {
                let handler: ((Bool) -> Void)? = nil
                tableView?.performBatchUpdates(batchUpdates, completion: handler)
            } else {
                tableView?.beginUpdates()
                
                batchUpdates()
                
                tableView?.endUpdates()
            }
        }
        
        let concurrencyType = controller.managedObjectContext.concurrencyType
        let isMainQueue: Bool
        if #available(iOS 9.0, *) {
            let isRelevant = concurrencyType == .mainQueueConcurrencyType
            isMainQueue = isRelevant && Thread.isMainThread
        } else {
            let isRelevant = concurrencyType == .mainQueueConcurrencyType || concurrencyType == .confinementConcurrencyType
            isMainQueue = isRelevant && Thread.isMainThread
        }
        
        if isMainQueue {
            callout()
        } else {
            OperationQueue.main.addOperation(callout)
        }
    }
}

//MARK: -

extension NSManagedObject {
    public func changedPropertiesForCurrentEvent() -> [NSPropertyDescription] {
        let changes = changedValuesForCurrentEvent()
        guard changes.isEmpty else { return [] }
        
        let propertiesByName = entity.propertiesByName
        
        let result = changes.keys.compactMap { propertiesByName[$0] }
        
        return result
    }
}

fileprivate extension NSEntityDescription {
    func inheritanceSequence() -> AnySequence<NSEntityDescription> {
        let result = sequence(first: self) { $0.superentity }
        
        return AnySequence(result.lazy.reversed())
    }
}
