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

    public private(set) weak var tableView: UITableView?
    public let fetchedResultsController: NSFetchedResultsController<FetchResultType>

    public let dequeueBlock: CellDequeueBlock
    public let insertionBlock: InsertionBlock?

    public init(withTableView tableView: UITableView, fetchedResultsController frc: NSFetchedResultsController<FetchResultType>, cellDequeueBlock: @escaping CellDequeueBlock, insertionBlock: InsertionBlock? = nil) {
        self.tableView = tableView

        fetchedResultsController = frc
        dequeueBlock = cellDequeueBlock
        self.insertionBlock = insertionBlock
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

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
        }
    }

    // Data manipulation - reorder / moving support


    //MARK: - NSFetchedResultsControllerDelegate

    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.beginUpdates()
    }

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.endUpdates()
    }

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        var result: String?

        if !sectionName.isEmpty {
            let index = sectionName.index(after: sectionName.startIndex)
            result = sectionName.substring(to: index)
        }

        return result
    }

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        guard let tableView = self.tableView else {
            assertionFailure()
            return
        }

        let sections = IndexSet(integer: sectionIndex)

        switch type {
        case .insert:
            tableView.insertSections(sections, with: .automatic)
        case .delete:
            tableView.deleteSections(sections, with: .automatic)
        default:
            preconditionFailure("Invalid section change type - \(type)")
            break
        }
    }

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let tableView = self.tableView else {
            assertionFailure()
            return
        }

        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        }
    }
}
