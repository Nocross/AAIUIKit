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

import AAICoreData

public class FetchedResultsTableDataSource<FetchResultType: NSFetchRequestResult>: NSObject, NSFetchedResultsControllerDelegate, UITableViewDataSource {

    public typealias CellDequeueBlock = (_ tableView: UITableView, _ indexPath: IndexPath, _ object: FetchResultType) -> UITableViewCell
    public typealias InsertionBlock = (_ tableView: UITableView, _ indexPath: IndexPath) -> FetchResultType
    public typealias ReloadBlock = (_ tableView: UITableView, _ indexPath: IndexPath,  _ object: FetchResultType) -> Bool

    public private(set) weak var tableView: UITableView?
    public let fetchedResultsController: NSFetchedResultsController<FetchResultType>

    public let dequeueBlock: CellDequeueBlock
    public let insertionBlock: InsertionBlock?
    public let shouldReloadBlock: ReloadBlock?
    
    private var batch: [() -> Void]?

    public init(withTableView tableView: UITableView, fetchedResultsController frc: NSFetchedResultsController<FetchResultType>, cellDequeueBlock: @escaping CellDequeueBlock, insertionBlock: InsertionBlock? = nil, shouldReloadBlock: ReloadBlock? = nil) {
        self.tableView = tableView

        fetchedResultsController = frc
        dequeueBlock = cellDequeueBlock
        self.insertionBlock = insertionBlock
        self.shouldReloadBlock = shouldReloadBlock
    }

    public func performFetch() throws {
        if fetchedResultsController.delegate !== self {
            fetchedResultsController.delegate = self;
        }

        try self.fetchedResultsController.performFetch()
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
        let cell = dequeueBlock(tableView, indexPath, object)

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

    // Editing

    // Moving/reordering

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

        guard let object = fetchedResultsController.object(at: indexPath) as? NSManagedObject else {
            preconditionFailure()
        }

        switch editingStyle {
        case .insert:
            if let block = insertionBlock, let object = block(tableView, indexPath) as? NSManagedObject , !object.isInserted {
                fetchedResultsController.managedObjectContext.insert(object)
            }

        case .delete:
            fetchedResultsController.managedObjectContext.delete(object)

        case .none:
            debugPrint("commit to tableView \(tableView) with editing style - \(editingStyle)")
            break
            
        @unknown default:
            debugPrint("Uknown NSFetchedResultsChangeType - \(editingStyle)")
            break
        }
    }

    // Data manipulation - reorder / moving support


    //MARK: - NSFetchedResultsControllerDelegate

    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        precondition(controller == fetchedResultsController)
        precondition(batch == nil)
        
        batch = []
    }

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        precondition(controller == fetchedResultsController)
        
        guard let batch = batch else { preconditionFailure() }
        
        let isRevelant = !batch.isEmpty
        if isRevelant {
            let block = { batch.forEach { $0() } }
            process(batchUpdates: block, for: controller)
        }
        self.batch = nil
    }

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        
        var result: String?

        if !sectionName.isEmpty {
            let index = sectionName.index(after: sectionName.startIndex)
            result = String(sectionName.prefix(upTo: index))
        }

        return result
    }

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
            if let block = shouldReloadBlock  {
                let object = anObject as! FetchResultType
                shouldReload = block(tableView, indexPath!, object)
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
