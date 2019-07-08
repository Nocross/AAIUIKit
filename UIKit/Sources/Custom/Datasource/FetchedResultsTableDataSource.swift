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


import CoreData
import UIKit

import AAIFoundation

import AAICoreData

@available(iOS 3.0, *)
public protocol FetchedResultsTableDataSourceAggregateStrategy {
    associatedtype FetchResultType
    
    associatedtype RowCellDequeueStategy: FetchedResultsTableDataSourceRowCellDequeueStrategy where RowCellDequeueStategy.FetchResultType == FetchResultType
    
    associatedtype ObjectInsertionStrategy: FetchedResultsTableDataSourceObjectInsertionStrategy //where ObjectInsertionStrategy.FetchResultType == FetchResultType
    
    associatedtype RowReloadDelagate: FetchedResultsTableDataSourceRowReloadDelagate where RowReloadDelagate.FetchResultType == FetchResultType
    
    associatedtype RowEditingDelegate: FetchedResultsTableDataSourceRowEditingDelegate
    
//    associatedtype RowReorderingStrategy: FetchedResultsTableDataSourceRowReorderingStrategy
    
    var rowCellDequeueStategy: RowCellDequeueStategy { get }
    var objectInsertionStrategy: ObjectInsertionStrategy? { get }
    var rowReloadDelagate: RowReloadDelagate? { get }
    var rowEditingDelegate: RowEditingDelegate? { get }
//    var rowReorderingStrategy: RowReorderingStrategy? { get }
}

//MARK: -

@available(iOS 3.0, *)
public protocol FetchedResultsTableDataSourceRowCellDequeueStrategy {
    associatedtype FetchResultType: NSFetchRequestResult
    
    func dequeueCell(for tableView: UITableView, at indexPath: IndexPath, with object: FetchResultType) -> UITableViewCell
}

@available(iOS 3.0, *)
public protocol FetchedResultsTableDataSourceObjectInsertionStrategy {
//    associatedtype FetchResultType: NSFetchRequestResult
    
    func insertObject(in tableView: UITableView, at indexPath: IndexPath, completion handler: (NSManagedObject) throws -> Void)
}

@available(iOS 3.0, *)
public protocol FetchedResultsTableDataSourceRowReloadDelagate: class {
    associatedtype FetchResultType: NSFetchRequestResult
    
    func shouldReloadRow(in tableView: UITableView, at indexPath: IndexPath, for object: FetchResultType) -> Bool
}

@available(iOS 3.0, *)
public protocol FetchedResultsTableDataSourceRowEditingDelegate: class {
    func canEditRow(in tableView: UITableView, at indexPath: IndexPath) -> Bool
}

public protocol FetchedResultsTableDataSourceRowReorderingStrategy {
    func moveRow(in tableView: UITableView, at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
}

public protocol FetchedResultsTableDataSourceRowReorderingDelegate: FetchedResultsTableDataSourceRowReorderingStrategy {
    func canMoveRow(in tableView: UITableView, at indexPath: IndexPath) -> Bool
}

//MARK: -

@available(iOS 3.0, *)
open class FetchedResultsTableDataSource<FetchResultType, Strategy>: NSObject, NSFetchedResultsControllerDelegate, UITableViewDataSource where Strategy : FetchedResultsTableDataSourceAggregateStrategy, FetchResultType == Strategy.FetchResultType {
    
    public typealias CellDequeueStategy = FetchedResultsTableDataSourceRowCellDequeueStrategy
    public typealias CellInsertionStrategy = FetchedResultsTableDataSourceObjectInsertionStrategy
    public typealias CellReloadDelagate = FetchedResultsTableDataSourceRowReloadDelagate
    public typealias RowEditingDelegate = FetchedResultsTableDataSourceRowEditingDelegate

    public private(set) weak var tableView: UITableView?
    public let fetchedResultsController: NSFetchedResultsController<FetchResultType>

    
    public let strategy: Strategy
    
    private let lock: Locking = NSRecursiveLock()
    
    private var batch: [() -> Void]? {
        get { return lock.withCritical { return _batch } }
        set { lock.withCritical { _batch = newValue } }
    }
    private var _batch: [() -> Void]?
    
    public init(withTableView tableView: UITableView, fetchedResultsController frc: NSFetchedResultsController<FetchResultType>, strategy: Strategy) {
        self.tableView = tableView
        
        fetchedResultsController = frc
        
        self.strategy = strategy
    }
    
    deinit {
        fetchedResultsController.delegate = nil
        batch = nil
    }

    public func performFetch() throws {
        if fetchedResultsController.delegate !== self {
            fetchedResultsController.delegate = self;
        }

        try self.fetchedResultsController.performFetch()
    }
    
    //MARK: -
    
    // returns nil if cell is not visible
    open func object(for cell: UITableViewCell) -> FetchResultType? {
        var result: FetchResultType?
        
        // returns nil if cell is not visible
        if let indexPath = tableView?.indexPath(for: cell) {
            result = object(at: indexPath)
        }
        
        return result
    }
    
    //MARK: -
    
    open var fetchedObjects: [FetchResultType]? {
        return fetchedResultsController.fetchedObjects
    }
    
    open func object(at indexPath: IndexPath) -> FetchResultType {
        return fetchedResultsController.object(at: indexPath)
    }
    
    open func indexPath(forObject object: FetchResultType) -> IndexPath? {
        return fetchedResultsController.indexPath(forObject: object)
    }

    //MARK: - UITableViewDataSource

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        assert(tableView === self.tableView, "Called from unregistered table view")

        var result: Int = 0
        if let sectionInfo = fetchedResultsController.sections?[section] {
            result = sectionInfo.numberOfObjects
        }

        return result
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        assert(tableView === self.tableView, "Called from unregistered table view")

        let object = fetchedResultsController.object(at: indexPath)
        let cell = strategy.rowCellDequeueStategy.dequeueCell(for: tableView, at: indexPath, with: object)

        return cell
    }

    // Optional

    public func numberOfSections(in tableView: UITableView) -> Int {
        assert(tableView === self.tableView, "Called from unregistered table view")

        var result: Int = 0;

        if let sections = fetchedResultsController.sections {
            result = sections.count
        }

        return result
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        assert(tableView === self.tableView, "Called from unregistered table view")

        var result: String? = nil

        if let sectionInfo = fetchedResultsController.sections?[section] {
            result = sectionInfo.name
        }

        return result
    }
    
//    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//        <#code#>
//    }

    // Editing
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let result = strategy.rowEditingDelegate?.canEditRow(in:tableView, at: indexPath)
        
        return result ?? true
    }

    // Moving/reordering
    
//    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
    
//    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        <#code#>
//    }


    // Index
    
    

    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        assert(tableView === self.tableView, "Called from unregistered table view")

        return fetchedResultsController.sectionIndexTitles
    }

    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        assert(tableView === self.tableView, "Called from unregistered table view")

        return fetchedResultsController.section(forSectionIndexTitle: title, at: index)
    }

    // Data manipulation - insert and delete support

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        assert(tableView === self.tableView, "Called from unregistered table view")
        
        switch editingStyle {
        case .insert:
            let context = NSManagedObjectContext(parent: fetchedResultsController.managedObjectContext, concurrencyType: .mainQueueConcurrencyType)
            
            strategy.objectInsertionStrategy?.insertObject(in: tableView, at: indexPath) {
                context.insert($0)
                
                try $0.validateForInsert()
                try context.save()
            }
            
        case .delete:
            let context = fetchedResultsController.managedObjectContext
            
            let work = { [unowned self] in
                guard let object = self.fetchedResultsController.object(at: indexPath) as? NSManagedObject else {
                    preconditionFailure()
                }
                
                self.fetchedResultsController.managedObjectContext.delete(object)
            }
            
            context.concurrencyType == .mainQueueConcurrencyType ? work() : context.performAndWait(work)
            
        case .none:
            debugPrint("commit to tableView \(tableView) with editing style - \(editingStyle)")
            break
            
        @unknown default:
            fatalUnknownValueError(editingStyle)
        }
    }

    // Data manipulation - reorder / moving support


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
        
        var result: String?

        if !sectionName.isEmpty {
            let index = sectionName.index(after: sectionName.startIndex)
            result = String(sectionName.prefix(upTo: index))
        }

        return result
    }
    */

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
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

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let tableView = self.tableView else {
            assertionFailure()
            return
        }
        
        var block: (() -> Void)?

        switch type {
        case .insert:
            block = { tableView.insertRows(at: [newIndexPath!], with: .automatic) }
        case .delete:
            block = { tableView.deleteRows(at: [indexPath!], with: .automatic) }
        case .move:
            block = { tableView.moveRow(at: indexPath!, to: newIndexPath!) }
        case .update:
            let shouldReload: Bool
            if let strategy = strategy.rowReloadDelagate  {
                let object = anObject as! FetchResultType
                shouldReload = strategy.shouldReloadRow(in: tableView, at: indexPath!, for: object)
            } else {
                shouldReload = true
            }
            
            if shouldReload {
                block = { tableView.reloadRows(at: [indexPath!], with: .automatic) }
            }
            
        @unknown default:
            debugPrint("Uknown NSFetchedResultsChangeType - \(type)")
            break
        }
        
        if let some = block {
            batch?.append(some)
        }
    }
    
    //MARK: -
    
    private func process(batchUpdates: @escaping () -> Void, for controller: NSFetchedResultsController<NSFetchRequestResult>) {
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

@available(iOS 3.0, *)
public class SimplifiedFetchedResultsTableDataSource<FetchResultType>:
FetchedResultsTableDataSource<FetchResultType,
FetchedResultsTableDataSourceStrategyValue<FetchResultType,
CellDequeueStategyValue<FetchResultType>,
ObjectInsertionStrategyValue<FetchResultType>,
CellReloadDelagateValue<FetchResultType>,
RowEditingDelegateValue<FetchResultType> /* CellDequeueStategyValue */> /* FetchedResultsTableDataSource */> where FetchResultType: NSFetchRequestResult {
    
    public typealias CellDequeueBlock = CellDequeueStategyValue<FetchResultType>.CellDequeueBlock
    public typealias InsertionBlock = ObjectInsertionStrategyValue<FetchResultType>.InsertionBlock
    public typealias ShouldReloadRowBlock = CellReloadDelagateValue<FetchResultType>.ShouldReloadRowBlock
    
    public typealias CanEditRowStrategy = RowEditingDelegateValue<FetchResultType>.CanEditRowStrategy
    
    //MARK: -
    
    public init(withTableView tableView: UITableView, fetchedResultsController frc: NSFetchedResultsController<FetchResultType>, cellDequeueBlock: @escaping CellDequeueBlock, insertionBlock: InsertionBlock? = nil, shouldReloadBlock: ShouldReloadRowBlock? = nil, canEditRow: CanEditRowStrategy? = nil) {
        
        let dequeue = CellDequeueStategyValue<FetchResultType>(dequeueCell: cellDequeueBlock)
        let insert = insertionBlock == nil ? nil : ObjectInsertionStrategyValue<FetchResultType>(insertion: insertionBlock!)
        let reload = shouldReloadBlock == nil ? nil : CellReloadDelagateValue(with: shouldReloadBlock!)
        let edit = canEditRow == nil ? nil : RowEditingDelegateValue<FetchResultType>(with: canEditRow!)
        
        let strategy = FetchedResultsTableDataSourceStrategyValue(rowCellDequeueStategy: dequeue, objectInsertionStrategy: insert, rowReloadDelagate: reload, rowEditingDelegate: edit)
        
        super.init(withTableView: tableView, fetchedResultsController: frc, strategy: strategy)
    }
}

//MARK: -

@available(iOS 3.0, *)
public struct FetchedResultsTableDataSourceStrategyValue<FetchResultType, CellDequeueStategyType, ObjectInsertionStrategyType, CellReloadDelagateType, RowEditingDelegateType>: FetchedResultsTableDataSourceAggregateStrategy where CellDequeueStategyType : FetchedResultsTableDataSourceRowCellDequeueStrategy, CellDequeueStategyType.FetchResultType == FetchResultType, ObjectInsertionStrategyType : FetchedResultsTableDataSourceObjectInsertionStrategy/*, ObjectInsertionStrategyType.FetchResultType == FetchResultType*/, CellReloadDelagateType : FetchedResultsTableDataSourceRowReloadDelagate, CellReloadDelagateType.FetchResultType == FetchResultType, RowEditingDelegateType: FetchedResultsTableDataSourceRowEditingDelegate {
    
    public typealias FetchResultType = FetchResultType
    
    public typealias RowCellDequeueStategy = CellDequeueStategyType
    
    public typealias ObjectInsertionStrategy = ObjectInsertionStrategyType
    
    public typealias RowReloadDelagate = CellReloadDelagateType
    
    public typealias RowEditingDelegate = RowEditingDelegateType
    
    public let rowCellDequeueStategy: RowCellDequeueStategy
    
    public let objectInsertionStrategy: ObjectInsertionStrategy?
    
    public let rowReloadDelagate: RowReloadDelagate?
    
    public let rowEditingDelegate: RowEditingDelegate?
}

//MARK: -

@available(iOS 3.0, *)
public struct CellDequeueStategyValue<FetchResultType>: FetchedResultsTableDataSourceRowCellDequeueStrategy where FetchResultType: NSFetchRequestResult {
    
    public typealias CellDequeueBlock = (_ tableView: UITableView, _ indexPath: IndexPath, _ object: FetchResultType) -> UITableViewCell
    
    public let dequeueCell: CellDequeueBlock
    
    public func dequeueCell(for tableView: UITableView, at indexPath: IndexPath, with object: FetchResultType) -> UITableViewCell {
        return dequeueCell(tableView, indexPath, object)
    }
}

@available(iOS 3.0, *)
public struct ObjectInsertionStrategyValue<Object>: FetchedResultsTableDataSourceObjectInsertionStrategy where Object : NSFetchRequestResult {
    public typealias FetchResultType = Object
    
    public typealias InsertionBlock = (_ tableView: UITableView, _ indexPath: IndexPath, _ handler: (NSManagedObject) throws -> Void) -> Void
    
    public let insertion: InsertionBlock
    
    public func insertObject(in tableView: UITableView, at indexPath: IndexPath, completion handler: (NSManagedObject) throws -> Void) {
        return insertion(tableView, indexPath, handler)
    }
}

@available(iOS 3.0, *)
public class CellReloadDelagateValue<Object>: FetchedResultsTableDataSourceRowReloadDelagate where Object : NSFetchRequestResult {
    public typealias FetchResultType = Object
    
    public typealias ShouldReloadRowBlock = (_ tableView: UITableView, _ indexPath: IndexPath,  _ object: FetchResultType) -> Bool
    
    private let shouldReload: ShouldReloadRowBlock
    
    init(with block: @escaping ShouldReloadRowBlock) {
        shouldReload = block
    }
    
    public func shouldReloadRow(in tableView: UITableView, at indexPath: IndexPath, for object: Object) -> Bool {
        return shouldReload(tableView, indexPath, object)
    }
}

@available(iOS 3.0, *)
public class RowEditingDelegateValue<Object>: FetchedResultsTableDataSourceRowEditingDelegate where Object : NSFetchRequestResult {
    typealias FetchResultType = Object
    
    public typealias CanEditRowStrategy = (_ tableView: UITableView, _ indexPath: IndexPath) -> Bool
    
    public init(with block: @escaping CanEditRowStrategy) {
        canEdit = block
    }
    
    private let canEdit: CanEditRowStrategy
    
    public func canEditRow(in tableView: UITableView, at indexPath: IndexPath) -> Bool {
        return canEdit(tableView, indexPath)
    }
}
